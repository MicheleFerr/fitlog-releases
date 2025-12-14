# CustomExerciseLimitService - Usage Guide

## Overview

The `CustomExerciseLimitService` manages business logic for custom exercise limits and ad-unlock functionality.

**Location**: `lib/features/custom_exercises/domain/services/custom_exercise_limit_service.dart`

## Key Features

- Free tier limit enforcement (5 permanent exercises)
- Ad-unlock flow (7-day temporary unlocks)
- Premium user detection (unlimited exercises)
- Expired exercise tracking
- Automatic cleanup of old expired exercises

## Setup in Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/services/custom_exercise_limit_service.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

/// Custom Exercise Limit Service Provider
final customExerciseLimitServiceProvider = Provider<CustomExerciseLimitService>((ref) {
  return CustomExerciseLimitService(
    repository: ref.read(customExerciseRepositoryProvider),
    isPremiumUser: () {
      // Get isPremium from consolidated user provider
      final userProfileAsync = ref.read(userProfileProvider);
      return userProfileAsync.value?.isPremium ?? false;
    },
  );
});
```

## Usage Examples

### 1. Check if User Can Create Exercise

```dart
class CreateExerciseScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitService = ref.read(customExerciseLimitServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        final canCreate = await limitService.canCreatePermanent();

        if (canCreate) {
          // User has free slots or is premium
          _showCreateExerciseDialog();
        } else {
          // Show ad-unlock dialog
          _showAdUnlockDialog();
        }
      },
      child: Text('Create Exercise'),
    );
  }
}
```

### 2. Display Quota in UI

```dart
class CustomExerciseQuotaWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitService = ref.read(customExerciseLimitServiceProvider);

    return FutureBuilder<LimitCheckResult>(
      future: limitService.checkLimits(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final result = snapshot.data!;

        if (result.isPremium) {
          return Text('Premium: Unlimited Exercises ∞');
        }

        return Column(
          children: [
            Text(
              'Custom Exercises: ${result.permanentCount}/${CustomExerciseLimitService.freeLimit}',
              style: TextStyle(fontSize: 16),
            ),
            if (result.expiredCount > 0)
              Chip(
                label: Text('${result.expiredCount} expired - Watch ad to renew'),
                backgroundColor: Colors.orange,
              ),
          ],
        );
      },
    );
  }
}
```

### 3. Prepare Exercise Before Save

```dart
class CreateExerciseProvider extends StateNotifier<AsyncValue<void>> {
  CreateExerciseProvider(this._limitService, this._repository)
    : super(const AsyncValue.data(null));

  final CustomExerciseLimitService _limitService;
  final CustomExerciseRepository _repository;

  Future<void> createExercise(CustomExercise draft) async {
    state = const AsyncValue.loading();

    try {
      // Service automatically determines if permanent or temporary
      final exerciseToSave = await _limitService.prepareExerciseForSave(draft);

      // Save to repository
      final result = await _repository.save(exerciseToSave);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = const AsyncValue.data(null),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### 4. Handle Ad Completion

```dart
class AdRewardHandler {
  final CustomExerciseLimitService _limitService;

  AdRewardHandler(this._limitService);

  Future<void> onAdWatched(String exerciseId) async {
    try {
      // Service handles logic:
      // - Convert to permanent if user has free slots
      // - Extend temporary unlock by 7 days otherwise
      await _limitService.onAdWatched(exerciseId);

      // Show success message
      _showSuccessSnackbar('Exercise unlocked for 7 days!');
    } catch (e) {
      _showErrorSnackbar('Failed to unlock exercise: $e');
    }
  }
}
```

### 5. Show Expired Exercises

```dart
class ExpiredExercisesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitService = ref.read(customExerciseLimitServiceProvider);

    return FutureBuilder<List<CustomExercise>>(
      future: limitService.getExpiredExercises(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final expired = snapshot.data!;

        if (expired.isEmpty) {
          return Text('No expired exercises');
        }

        return ListView.builder(
          itemCount: expired.length,
          itemBuilder: (context, index) {
            final exercise = expired[index];

            return ListTile(
              title: Text(exercise.nome),
              subtitle: Text('Expired ${exercise.daysRemaining ?? 0} days ago'),
              trailing: ElevatedButton(
                onPressed: () => _watchAdToRenew(exercise.id),
                child: Text('Watch Ad to Renew'),
              ),
            );
          },
        );
      },
    );
  }
}
```

### 6. Cleanup Old Expired Exercises

```dart
class MaintenanceService {
  final CustomExerciseLimitService _limitService;

  MaintenanceService(this._limitService);

  /// Run daily cleanup to remove exercises expired > 30 days
  Future<void> runDailyCleanup() async {
    try {
      // Removes exercises expired for more than 30 days
      await _limitService.cleanupExpiredExercises(
        daysAfterExpiration: 30,
      );

      debugPrint('✅ Cleanup completed');
    } catch (e) {
      debugPrint('❌ Cleanup failed: $e');
    }
  }
}
```

## Business Logic Reference

### Free Tier Rules

- **Permanent Limit**: 5 exercises
- **Temporary Unlocks**: Unlimited (7-day expiry)
- **After Limit**: Must watch ad to unlock each new exercise
- **Expiration Behavior**: Exercise remains in existing workouts, blocked for new additions

### Premium Benefits

- **Permanent Limit**: Unlimited
- **Temporary Unlocks**: N/A (all permanent)
- **Cloud Sync**: Available

### Ad-Unlock Flow

1. User creates 6th exercise
2. Service detects limit reached
3. UI shows "Watch Ad" or "Go Premium" dialog
4. User watches ad
5. Service creates exercise with `unlockedUntil = now + 7 days`
6. After 7 days: Exercise expires
7. User can renew by watching another ad

### Slot Management

When user **deletes** a permanent exercise:
- Free slot becomes available
- Next temporary exercise can be converted to permanent
- Service automatically handles this in `onAdWatched`

## Constants

```dart
CustomExerciseLimitService.freeLimit = 5       // Max permanent exercises
CustomExerciseLimitService.tempUnlockDays = 7  // Days per ad-unlock
```

## LimitCheckResult

```dart
class LimitCheckResult {
  final LimitStatus status;         // available | requiresAd | unlimited
  final int remainingSlots;         // 0-5 for free, 999 for premium
  final int permanentCount;         // Current permanent count
  final int expiredCount;           // Exercises needing renewal

  // Computed properties
  bool get canCreatePermanent;      // Can create without ad?
  bool get requiresAd;              // Must watch ad?
  bool get isPremium;               // Is premium user?
}
```

## Error Handling

Service uses **fail-safe** approach:
- On repository errors: Returns safe defaults (0 count, empty list)
- On critical errors: Throws exceptions with descriptive messages
- Repository operations: Propagates Either<Failure, T> errors

## Testing Considerations

When testing, mock the service:

```dart
class MockCustomExerciseLimitService extends Mock
    implements CustomExerciseLimitService {}

// Test example
test('should show ad dialog when limit reached', () async {
  final mockService = MockCustomExerciseLimitService();

  when(mockService.canCreatePermanent())
    .thenAnswer((_) async => false);

  // Test your widget logic...
});
```

## Integration Points

### UI Components
- Create Exercise Modal
- Exercise Quota Indicator
- Expired Exercises List
- Ad Unlock Dialog
- Premium Upsell Screen

### Providers
- Custom Exercise Repository
- User Profile Provider (for isPremium)
- Ad Manager Provider

### Analytics
- Track limit reached events
- Monitor ad watch completion rate
- Measure premium conversion rate
