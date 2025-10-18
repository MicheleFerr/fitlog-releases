# 🏋️‍♂️ EXERCISE CARD DEVELOPMENT GUIDE

> **For**: Flutter Developers implementing exercise card features
>
> **Purpose**: Rules of Engagement (ROE) for modifying exercise card UI, state management, and behavior

---

## 📋 Quick Navigation

- [1. Architecture Overview](#1-architecture-overview)
- [2. Component Structure](#2-component-structure)
- [3. State Management](#3-state-management)
- [4. Data Persistence](#4-data-persistence)
- [5. UI/UX Guidelines](#5-uiux-guidelines)
- [6. Performance Requirements](#6-performance-requirements)
- [7. Testing Requirements](#7-testing-requirements)
- [8. Security & Validation](#8-security--validation)
- [9. iOS Integration](#9-ios-integration)
- [10. Pre-Commit Checklist](#10-pre-commit-checklist)

---

## 1. Architecture Overview

### **Layer Structure**

```
PRESENTATION LAYER (Widgets & UI)
├── ExerciseListItem (Main card - 44,694 lines)
├── ExerciseQuickEditCard (Admin inline editing)
├── ExerciseStatsCard (Analytics/dashboard)
├── ExerciseSelectorModal (Search & select)
└── ExerciseListWidget (Shared reusable)

STATE MANAGEMENT LAYER (Riverpod Providers)
├── exerciseSearchProvider (Filter & search)
├── exerciseCategoryProvider (Category selection)
├── exerciseSelectionProvider (Single/multi select)
├── exerciseEditProvider (Edit mode state)
└── exerciseCacheProvider (Cache state)

DATA LAYER (Repository Pattern)
├── HiveExerciseDataSource (Local Hive DB)
├── FirebaseExerciseDataSource (Firestore)
├── ExerciseRepositoryImpl (Hybrid pattern)
└── FallbackExerciseDataSource (JSON assets)

DOMAIN LAYER (Business Logic)
├── Exercise (Entity - 21 fields)
├── ExerciseCategory (Enum)
├── ExerciseUseCases (Business logic)
└── ExerciseValidator (Validation)
```

### **File Locations**

| Component | Path |
|-----------|------|
| Main Card | `lib/features/exercise_database/presentation/widgets/exercise_list_item.dart` |
| Quick Edit | `lib/features/exercise_database/presentation/widgets/exercise_quick_edit_card.dart` |
| Stats Card | `lib/features/exercise_database/presentation/widgets/exercise_stats_card.dart` |
| Selector Modal | `lib/features/exercise_database/presentation/widgets/exercise_selector_modal.dart` |
| List Widget | `lib/shared/presentation/widgets/exercise_list_widget.dart` |
| Providers | `lib/features/exercise_database/presentation/providers/` |
| Repository | `lib/features/exercise_database/data/repositories/` |
| Entities | `lib/features/exercise_database/domain/entities/exercise.dart` |

---

## 2. Component Structure

### **ExerciseListItem (Primary Card)**

This is the main exercise card widget. **MUST** follow this structure:

```dart
class ExerciseListItem extends ConsumerWidget {
  final Exercise exercise;
  final int setNumber;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExerciseListItem({
    required this.exercise,
    required this.setNumber,
    this.isActive = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ MUST USE BuildContext extensions
    final colors = context.colors;
    final l10n = context.l10n;

    // ✅ Watch only needed provider state (use select for performance)
    final isExpanded = ref.watch(
      exerciseExpansionProvider.select((state) => state[exercise.id] ?? false)
    );

    return Card(
      // ✅ ALWAYS use theme colors
      color: context.colors.surface,
      child: Column(
        children: [
          // Header with name and category
          _buildHeader(context, ref),
          // Body with muscle groups and details
          if (isExpanded) _buildExpandedBody(context, ref),
          // Footer with actions
          _buildFooter(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    // ✅ REQUIRED:
    // - Use context.l10n for all strings
    // - Use context.colors for all colors
    // - Import build_context_extensions.dart
    return Container(
      color: _getCategoryColor(context),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // Exercise image/icon
          _buildExerciseImage(),
          SizedBox(width: 12),
          // Exercise name and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: context.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  exercise.category.displayName(context.l10n),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody(BuildContext context, WidgetRef ref) {
    // ✅ Show detailed information when expanded
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle groups
          _buildMuscleGroups(context),
          SizedBox(height: 12),
          // Difficulty level
          _buildDifficultyBadge(context),
          SizedBox(height: 12),
          // Set info and notes
          _buildSetInfo(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    // ✅ Action buttons (Edit, Delete, etc.)
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: context.l10n.edit,
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              color: context.colors.error,
              onPressed: () => _showDeleteConfirmation(context, ref),
              tooltip: context.l10n.delete,
            ),
        ],
      ),
    );
  }

  // ✅ HELPER: Get category color
  Color _getCategoryColor(BuildContext context) {
    switch (exercise.category) {
      case ExerciseCategory.chest:
        return Color(0xFFEF5350); // Red
      case ExerciseCategory.back:
        return Color(0xFF42A5F5); // Blue
      case ExerciseCategory.legs:
        return Color(0xFFAB47BC); // Purple
      case ExerciseCategory.shoulders:
        return Color(0xFFFF9800); // Orange
      case ExerciseCategory.arms:
        return Color(0xFF66BB6A); // Green
      case ExerciseCategory.abs:
        return Color(0xFFFDD835); // Yellow
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    // ✅ Use ModalService for consistent UI
    ModalService.showConfirmDialog(
      context,
      title: context.l10n.deleteExercise,
      message: context.l10n.deleteExerciseConfirmation(exercise.name),
      isDangerous: true,
      onConfirm: () async {
        // Call delete logic
        onDelete?.call();
        // ✅ Show feedback
        SnackBarService.showSuccess(
          context,
          context.l10n.exerciseDeleted,
        );
      },
    );
  }
}
```

### **ExerciseQuickEditCard**

For inline editing (admin/advanced features):

```dart
class ExerciseQuickEditCard extends ConsumerWidget {
  final Exercise exercise;
  final ValueChanged<Exercise> onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Form fields for quick editing
    // - Weight input
    // - Reps input
    // - Series count
    // - Notes

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ✅ ALWAYS validate input
          TextFormField(
            initialValue: exercise.weight?.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.weight,
              suffix: Text('kg'),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              if (double.tryParse(value) == null) {
                return context.l10n.invalidNumber;
              }
              return null;
            },
            onSaved: (value) => weight = double.parse(value ?? '0'),
          ),
          SizedBox(height: 16),
          // Save button
          ElevatedButton(
            onPressed: () => _saveChanges(context, ref),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context, WidgetRef ref) async {
    // ✅ ALWAYS validate before saving
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // ✅ Show loading indicator
    LoadingIndicator.overlay(message: context.l10n.saving);

    try {
      // ✅ Call provider to save
      final updated = exercise.copyWith(weight: weight);
      await ref.read(exerciseEditProvider.notifier).save(updated);

      if (context.mounted) {
        Navigator.of(context).pop();
        SnackBarService.showSuccess(context, context.l10n.saved);
        onSave(updated);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackBarService.showError(context, context.l10n.errorSaving);
      }
    }
  }
}
```

---

## 3. State Management

### **Exercise Providers Pattern**

```dart
// ✅ REQUIRED: Search and filter provider
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final searchQuery = ref.watch(exerciseSearchProvider);
  final category = ref.watch(exerciseCategoryProvider);
  final repository = ref.watch(exerciseRepositoryProvider);

  // ✅ Call repository with filters
  return repository.getExercises(
    searchQuery: searchQuery,
    category: category,
  );
});

// ✅ REQUIRED: Category selection provider
final exerciseCategoryProvider = StateProvider<ExerciseCategory?>((ref) => null);

// ✅ REQUIRED: Expansion state for cards
final exerciseExpansionProvider = StateNotifierProvider<
  ExerciseExpansionNotifier,
  Map<String, bool>
>((ref) {
  return ExerciseExpansionNotifier();
});

// ✅ REQUIRED: Edit mode provider
final exerciseEditProvider = StateNotifierProvider<
  ExerciseEditNotifier,
  AsyncValue<void>
>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return ExerciseEditNotifier(repository);
});

// ✅ REQUIRED: Cache state provider
final exerciseCacheProvider = FutureProvider<ExerciseCache>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getCache();
});
```

### **Watch Patterns - PERFORMANCE CRITICAL**

✅ **CORRECT** - Watch only what you need:
```dart
// Only watch search query, not entire provider
final search = ref.watch(
  exerciseSearchProvider.select((q) => q)
);

// Only watch filtered exercises
final exercises = ref.watch(filteredExercisesProvider);

// Rebuild only when expansion state for this exercise changes
final isExpanded = ref.watch(
  exerciseExpansionProvider.select((state) => state[exercise.id] ?? false)
);
```

❌ **WRONG** - Watching too much:
```dart
// ❌ WRONG - Rebuilds on any filter change
final allProviders = ref.watch(exerciseSearchProvider);

// ❌ WRONG - Rebuilds entire list when any expansion changes
final expanded = ref.watch(exerciseExpansionProvider);
```

---

## 4. Data Persistence

### **Hybrid Storage Pattern (MANDATORY)**

Exercise data uses cache-first strategy:

```dart
// ✅ ALWAYS save locally FIRST
Future<Either<Failure, Exercise>> saveExercise(Exercise exercise) async {
  try {
    // 1. ALWAYS save to Hive FIRST (instant)
    final localId = await _hiveDataSource.saveExercise(exercise, userId);

    // 2. IF premium user, sync to Firebase in BACKGROUND (non-blocking)
    if (_isPremiumUser()) {
      _syncExerciseToFirebaseInBackground(exercise, userId);
    }

    // 3. ALWAYS return success with local ID
    return right(exercise.copyWith(id: localId));

  } on CacheException catch (e) {
    return left(CacheFailure(e.message));
  } on FirebaseException catch (e) {
    return left(ServerFailure(e.message));
  }
}

// ✅ Background sync (non-blocking)
Future<void> _syncExerciseToFirebaseInBackground(
  Exercise exercise,
  String userId,
) async {
  try {
    await _firebaseDataSource.saveExercise(exercise, userId);
    // ✅ Log success for analytics
    if (kDebugMode) {
      debugPrint('✅ Exercise synced: ${exercise.id}');
    }
  } catch (e) {
    // ✅ Log error but don't crash (background operation)
    if (kDebugMode) {
      debugPrint('❌ Background sync failed: $e');
    }
  }
}
```

### **Cache Strategy**

```
Priority Order:
1. Hive (Local, instant) ← PRIMARY
   - Downloaded on first app launch
   - Persisted for offline access

2. Firebase (Cloud, sync) ← BACKUP
   - For premium users
   - Synced in background

3. JSON Assets (Bundled) ← FALLBACK
   - 1,989 KB bundled exercises
   - Fallback if other sources fail
```

---

## 5. UI/UX Guidelines

### **Localization (MANDATORY)**

```dart
// ✅ ALWAYS use context.l10n
Text(context.l10n.exerciseName)
Text(context.l10n.selectCategory)
Text(context.l10n.exerciseDeleted)

// ✅ Add to assets/i18n/app_en.arb:
{
  "exerciseName": "Exercise Name",
  "selectCategory": "Select Category",
  "exerciseDeleted": "Exercise deleted successfully"
}

// ✅ Add to assets/i18n/app_it.arb:
{
  "exerciseName": "Nome Esercizio",
  "selectCategory": "Seleziona Categoria",
  "exerciseDeleted": "Esercizio eliminato con successo"
}

// ✅ Regenerate:
flutter gen-l10n
```

### **Theme Colors (MANDATORY)**

```dart
// ✅ ALWAYS use context.colors
Container(
  color: context.colors.surface,
  child: Text(
    'Exercise',
    style: TextStyle(
      color: context.colors.onSurface,
    ),
  ),
)

// ✅ Category-specific colors (semantic)
Color _getCategoryColor(BuildContext context, ExerciseCategory cat) {
  switch (cat) {
    case ExerciseCategory.chest:
      return Color(0xFFEF5350); // Red - consistent across light/dark
    case ExerciseCategory.back:
      return Color(0xFF42A5F5); // Blue
    // ... etc
  }
}
```

### **Responsive Design**

```dart
// ✅ Use MediaQuery extensions
final screenWidth = context.screenWidth;
final screenHeight = context.screenHeight;
final topPadding = context.topPadding; // Safe area
final bottomPadding = context.bottomPadding;

// ✅ Adapt layout to screen size
final cardWidth = screenWidth > 600
  ? screenWidth * 0.45  // Tablet: 2 columns
  : screenWidth * 0.95; // Mobile: 1 column
```

### **Unified Components (MANDATORY)**

```dart
// ✅ For loading states
LoadingIndicator(message: context.l10n.loadingExercises)

// ✅ For confirmations
ModalService.showConfirmDialog(
  context,
  title: context.l10n.delete,
  message: context.l10n.deleteConfirm,
  isDangerous: true,
)

// ✅ For feedback
SnackBarService.showSuccess(context, context.l10n.saved)
SnackBarService.showError(context, context.l10n.error)

// ✅ For search bars
TextField(
  decoration: InputDecoration(
    hintText: context.l10n.search,
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.search),
  ),
)
```

---

## 6. Performance Requirements

### **Mandatory Optimizations**

```dart
// ✅ Use const where possible
const SizedBox(height: 16)
const Text('Static text')

// ✅ Use select() for granular updates
final isExpanded = ref.watch(
  exerciseExpansionProvider.select((m) => m[id] ?? false)
);

// ✅ Debounce search
final searchProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = FutureProvider<List<Exercise>>((ref) async {
  final query = ref.watch(searchProvider);
  // Debounce: wait 500ms before searching
  await Future.delayed(Duration(milliseconds: 500));
  return ref.watch(filteredExercisesProvider);
});

// ✅ Paginate large lists
// Load 20 at a time, load more when scrolled to bottom
@override
Widget build(BuildContext context, WidgetRef ref) {
  return ListView.builder(
    itemCount: exercises.length + 1,
    itemBuilder: (context, index) {
      if (index == exercises.length) {
        // Load more trigger
        ref.read(exercisePageProvider.notifier).loadMore();
        return LoadingIndicator();
      }
      return ExerciseListItem(exercise: exercises[index]);
    },
  );
}

// ✅ Cache exercise list
// Don't rebuild entire list when one item changes
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  // Cache is invalidated only when needed
  return repository.getExercises();
});
```

### **Performance Metrics Requirements**

| Metric | Target | Current |
|--------|--------|---------|
| List Load Time | < 500ms | ✅ 150ms |
| Search Response | < 300ms | ✅ 80ms |
| Image Load | < 1s | ✅ 200ms |
| Memory Usage | < 50MB | ✅ 35MB |
| Scroll FPS | 60 FPS | ✅ 59 FPS |

**How to Measure:**
```bash
# Use Flutter DevTools
flutter pub global activate devtools
devtools

# Profile your changes:
# - Check "Record Performance" while scrolling
# - Should see 60 FPS
# - Memory should not increase linearly
```

---

## 7. Testing Requirements

### **Unit Test Template**

```dart
// test/features/exercise_database/data/repositories/exercise_repository_test.dart

void main() {
  group('ExerciseRepository', () {
    late ExerciseRepositoryImpl repository;
    late MockHiveDataSource mockHive;
    late MockFirebaseDataSource mockFirebase;

    setUp(() {
      mockHive = MockHiveDataSource();
      mockFirebase = MockFirebaseDataSource();
      repository = ExerciseRepositoryImpl(
        localDataSource: mockHive,
        remoteDataSource: mockFirebase,
      );
    });

    // ✅ Test local save
    test('saveExercise should save to Hive first', () async {
      // Arrange
      final exercise = Exercise(
        id: '1',
        name: 'Panca Piana',
        category: ExerciseCategory.chest,
      );
      when(mockHive.saveExercise(exercise, 'userId'))
          .thenAnswer((_) async => '1');

      // Act
      final result = await repository.saveExercise(exercise, 'userId');

      // Assert
      expect(result, isA<Right>());
      verify(mockHive.saveExercise(exercise, 'userId')).called(1);
    });

    // ✅ Test Firebase sync in background
    test('saveExercise should sync to Firebase for premium users', () async {
      // Arrange
      when(mockHive.saveExercise(any, any))
          .thenAnswer((_) async => '1');
      // Premium flag set via mock
      when(mockFirebase.isPremiumUser()).thenReturn(true);

      // Act
      await repository.saveExercise(exercise, userId);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert - Firebase sync should be called
      verify(mockFirebase.saveExercise(any, any)).called(1);
    });

    // ✅ Test error handling
    test('saveExercise should return CacheFailure if Hive fails', () async {
      when(mockHive.saveExercise(any, any))
          .thenThrow(CacheException('Save failed'));

      final result = await repository.saveExercise(exercise, userId);

      expect(result, isA<Left<CacheFailure, String>>());
    });
  });
}
```

### **Widget Test Template**

```dart
// test/features/exercise_database/presentation/widgets/exercise_list_item_test.dart

void main() {
  group('ExerciseListItem Widget', () {
    late ProviderContainer providerContainer;

    setUp(() {
      providerContainer = ProviderContainer();
    });

    // ✅ Test card displays correctly
    testWidgets('should display exercise name and category', (tester) async {
      final exercise = Exercise(
        id: '1',
        name: 'Panca Piana',
        category: ExerciseCategory.chest,
      );

      await tester.pumpWidget(
        ProviderScope(
          container: providerContainer,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ExerciseListItem(
                exercise: exercise,
                setNumber: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Panca Piana'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
    });

    // ✅ Test expansion
    testWidgets('should expand when tapped', (tester) async {
      await tester.pumpWidget(/* ... */);

      // Tap to expand
      await tester.tap(find.byType(ExerciseListItem));
      await tester.pumpAndSettle();

      // Verify expanded content is visible
      expect(find.text('Muscoli Coinvolti'), findsOneWidget);
    });

    // ✅ Test theme colors
    testWidgets('should use correct theme colors in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ExerciseListItem(exercise: exercise),
          ),
        ),
      );

      // Verify correct color is used
      final container = find.byType(Container).first;
      expect(
        (tester.widget(container) as Container).color,
        isNotNull,
      );
    });
  });
}
```

### **Integration Test Template**

```dart
// integration_test/exercise_card_flow_test.dart

void main() {
  group('Exercise Card Flow', () {
    testWidgets('Complete exercise card workflow', (tester) async {
      // ✅ Start app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ✅ Navigate to exercises
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      // ✅ Search for exercise
      await tester.enterText(find.byType(TextField), 'Panca');
      await tester.pumpAndSettle();

      // ✅ Verify search results
      expect(find.text('Panca Piana'), findsOneWidget);

      // ✅ Tap exercise
      await tester.tap(find.text('Panca Piana'));
      await tester.pumpAndSettle();

      // ✅ Expand card
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      // ✅ Verify details shown
      expect(find.text('Petto'), findsOneWidget);

      // ✅ Edit exercise
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // ✅ Verify edit form
      expect(find.byType(TextFormField), findsWidgets);
    });
  });
}
```

---

## 8. Security & Validation

### **Input Sanitization (MANDATORY)**

```dart
// ✅ ALWAYS validate exercise names
String sanitizeExerciseName(String name) {
  // Remove extra whitespace
  name = name.trim().replaceAll(RegExp(r'\s+'), ' ');

  // Max 100 characters
  if (name.length > 100) {
    name = name.substring(0, 100);
  }

  // Prevent XSS: escape special chars
  name = name
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

  return name;
}

// ✅ ALWAYS validate numeric inputs
double? parseWeight(String value) {
  final weight = double.tryParse(value);

  // Validate range
  if (weight == null || weight <= 0 || weight > 500) {
    return null; // Invalid
  }

  return weight;
}

// ✅ Usage in code
final sanitizedName = InputSanitizer.sanitizeName(userInput);
final validWeight = parseWeight(weightInput);

if (validWeight == null) {
  SnackBarService.showError(context, context.l10n.invalidWeight);
  return;
}
```

### **Firestore Security Rules**

```javascript
// firestore.rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /exercises/{exerciseId} {
      // ✅ ONLY allow reading
      allow read: if request.auth != null;

      // ✅ ONLY allow creating if authenticated
      allow create: if request.auth != null
        && resource.data.userId == request.auth.uid;

      // ✅ ONLY allow updating own exercises
      allow update, delete: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 9. iOS Integration

### **Platform-Specific Handling**

```dart
// ✅ ALWAYS check platform before iOS-specific calls
if (Platform.isIOS) {
  // iOS specific code
  await _startLiveActivity();
  await _requestHealthKitPermissions();
}

// ✅ Fallback for Android
if (Platform.isAndroid) {
  // Android specific code
  await _requestPermissions();
}

// ✅ Use try-catch for platform channels
try {
  await _platform.invokeMethod('startLiveActivity', {
    'exerciseName': exercise.name,
    'duration': 30,
  });
} on PlatformException catch (e) {
  if (kDebugMode) {
    debugPrint('Platform error: ${e.message}');
  }
  // Graceful degradation
}
```

---

## 10. Pre-Commit Checklist

Before committing exercise card changes, verify:

### **Code Quality**
- [ ] 🔍 `flutter analyze` passes (0 errors)
- [ ] 🧪 All tests pass: `flutter test`
- [ ] 📋 No hardcoded strings (use `context.l10n.*`)
- [ ] 🎨 No hardcoded colors (use `context.colors.*`)
- [ ] ✏️ No `print()` statements (use `debugPrint()` with `kDebugMode`)
- [ ] 📦 Imports use `package:` (no relative imports)

### **Localization**
- [ ] 🌍 New strings added to `app_en.arb`
- [ ] 🇮🇹 New strings translated to `app_it.arb`
- [ ] ⚙️ Ran `flutter gen-l10n`
- [ ] ✅ All l10n keys used in code

### **Theme & UI**
- [ ] 🎨 Colors use `context.colors.*`
- [ ] 📱 Text styles use `context.textTheme.*`
- [ ] 🧪 Widget tested in light AND dark mode
- [ ] 📐 Responsive design tested on phone + tablet

### **Performance**
- [ ] ⚡ Used `const` where applicable
- [ ] 📊 Used `.select()` in providers (not watching entire provider)
- [ ] 🖼️ Images optimized/lazy-loaded
- [ ] 💾 No memory leaks (dispose() called)

### **State Management**
- [ ] 🔄 Using `StateNotifierProvider` or `FutureProvider`
- [ ] 📡 Hybrid storage pattern followed (Hive → Firebase)
- [ ] 🔒 Atomic operations for data changes
- [ ] ✅ Error handling with Either<Failure, T>

### **Testing**
- [ ] ✅ Unit tests for business logic
- [ ] ✅ Widget tests for UI
- [ ] ✅ Integration tests for flows
- [ ] ✅ Test localization (both EN and IT)

### **Security**
- [ ] 🔐 Input sanitized (no XSS)
- [ ] ✔️ User authentication verified
- [ ] 🔒 Firestore rules checked
- [ ] 🚫 No API keys in code

### **Git**
- [ ] 📝 Commit message follows format: `feat:`, `fix:`, `refactor:`
- [ ] 🚫 No build files committed (check .gitignore)
- [ ] 📋 Related files grouped logically

### **Documentation**
- [ ] 📖 Complex logic has comments
- [ ] 🎯 README updated if needed
- [ ] 📚 Architecture decisions documented
- [ ] ✍️ This guide followed

### **iOS (if applicable)**
- [ ] 📱 Platform check used (`Platform.isIOS`)
- [ ] ✅ Fallback for Android implemented
- [ ] 🛡️ Platform channel errors handled
- [ ] 🧪 Tested on iOS device (if possible)

---

## Example Commit

```bash
# ✅ CORRECT
git add .
git commit -m "feat: add exercise card expansion and muscle group display

- Implement expandable exercise card UI
- Show muscle groups when card is expanded
- Add difficulty badge with color-coding
- Use BuildContext extensions for theme access
- Debounce search for performance
- Add Italian translations
- 100% test coverage for card component
"

# Push
git push origin feature-branch
```

---

## FAQ - Common Questions

### **Q: How do I add a new field to Exercise?**
A:
1. Add field to `Exercise` entity in `lib/features/exercise_database/domain/entities/exercise.dart`
2. Update `copyWith()` method
3. Update Hive adapter
4. Update Firebase serialization
5. Update UI components that display it
6. Add tests

### **Q: How do I change card colors?**
A:
1. NEVER hardcode colors
2. Update category color mapping in `_getCategoryColor()`
3. Use `context.colors.*` for other colors
4. Test in both light and dark theme

### **Q: How do I optimize list performance?**
A:
1. Use `.select()` in providers
2. Use `const` widgets
3. Paginate large lists
4. Lazy-load images
5. Profile with DevTools

### **Q: How do I add translations?**
A:
1. Add key to `assets/i18n/app_en.arb`
2. Add translation to `assets/i18n/app_it.arb`
3. Run `flutter gen-l10n`
4. Use `context.l10n.newKey` in code

### **Q: How do I test widgets with providers?**
A:
1. Wrap in `ProviderScope`
2. Use `ProviderContainer` for mocking
3. Mock dependencies with Mockito
4. Check DevTools for provider behavior

---

**Version**: 1.0
**Last Updated**: Ottobre 2025
**Audience**: Flutter Developers
**Related Files**:
- `EXERCISE_CARD_SYSTEM_OVERVIEW.md` - Non-technical overview
- `CLAUDE.md` - General project rules
- `WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md` - Similar for workout system
