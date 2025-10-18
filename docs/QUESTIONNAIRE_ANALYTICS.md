# 📊 Questionnaire Analytics System

## Overview

The Questionnaire Analytics system tracks user behavior during the fitness profile questionnaire to identify UX bottlenecks, measure completion rates, and optimize the onboarding experience.

## Implementation Status

✅ **Feature #1: Questionnaire Analytics with Drop-off Tracking** - COMPLETED

## Architecture

### Domain Layer

#### QuestionnaireAnalytics Entity
Location: `lib/features/strength_standards/domain/entities/questionnaire_analytics.dart`

Tracks individual questionnaire sessions with:
- **Session metadata**: userId, startedAt, completedAt timestamps
- **Step tracking**: lastStepReached, stepDurations map
- **Completion status**: wasAbandoned flag
- **Feedback**: stepFeedback map (1-5 star ratings per step)
- **Context**: platform (iOS/Android), appVersion
- **Metrics**: totalDurationSeconds

Key calculated properties:
```dart
double get completionRate       // 0.0 to 1.0
double get averageStepDuration  // Seconds per step
int? get dropOffStep            // null if completed
bool get isCompleted
double get totalDurationMinutes
double? get averageFeedbackRating
```

#### QuestionnaireAnalyticsAggregated
Provides admin/analytics view with:
- Total attempts and completions
- Average completion time
- Drop-off counts by step (identifies problematic steps)
- Average feedback ratings by step

### Data Layer

#### QuestionnaireAnalyticsDataSource
Location: `lib/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart`

Hive-based local storage with two boxes:
- `questionnaire_analytics`: Stores individual sessions
- `suggestion_accuracy`: Ready for future accuracy tracking

Key methods:
```dart
// Save and retrieve
Future<void> saveQuestionnaireAnalytics(QuestionnaireAnalytics analytics)
Future<QuestionnaireAnalytics?> getLatestAnalytics(String userId)
Future<List<QuestionnaireAnalytics>> getAllAnalytics(String userId)

// Aggregation
Future<QuestionnaireAnalyticsAggregated> getAggregatedAnalytics()

// Privacy
Future<void> clearAllUserData(String userId)
```

### Presentation Layer

#### Providers
Location: `lib/features/strength_standards/presentation/providers/strength_standards_providers.dart`

**QuestionnaireAnalyticsNotifier**: Manages active session state

Key methods:
```dart
void startSession()                        // Initialize tracking with platform/version
void trackStepComplete(int step)          // Record step completion and duration
void trackStepFeedback(int step, int rating) // Record 1-5 star feedback
Future<void> trackCompletion()            // Mark questionnaire completed
Future<void> trackAbandon(int lastStep)   // Mark questionnaire abandoned
```

**Available Providers**:
```dart
// Active session tracking
final currentAnalytics = ref.watch(currentQuestionnaireAnalyticsProvider);

// User's latest session
final latest = ref.watch(latestQuestionnaireAnalyticsProvider);

// Admin view (all users aggregated)
final aggregated = ref.watch(aggregatedQuestionnaireAnalyticsProvider);
```

#### UI Integration
Location: `lib/features/strength_standards/presentation/screens/fitness_questionnaire_screen.dart`

Tracking points:
1. **initState()**: Start session when screen opens
2. **_nextStep()**: Track step completion and duration
3. **_completeQuestionnaire()**: Track successful completion
4. **dispose()**: Track abandonment if incomplete

## Data Flow

```
User opens questionnaire
         ↓
    initState()
         ↓
   startSession() ← Captures platform, app version, start timestamp
         ↓
User navigates steps
         ↓
  trackStepComplete() ← Records step number and duration
         ↓
    User exits?
     ↙     ↘
   YES      NO
    ↓        ↓
 dispose()  _completeQuestionnaire()
    ↓        ↓
trackAbandon() → trackCompletion()
    ↓        ↓
    └────────┘
         ↓
   Save to Hive
```

## Privacy & GDPR Compliance

- **Local-first**: All data stored locally in Hive
- **User-scoped**: Each record tied to userId
- **Deletion support**: `clearAllUserData(userId)` for account deletion
- **No PII**: Only behavioral metrics tracked (no personal data)
- **Optional cloud sync**: Can be implemented later with user consent

## Usage Examples

### Start Tracking Session
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(currentQuestionnaireAnalyticsProvider.notifier).startSession();
  });
}
```

### Track Step Completion
```dart
void _nextStep() {
  if (!_validateCurrentStep()) return;

  ref.read(currentQuestionnaireAnalyticsProvider.notifier)
    .trackStepComplete(_currentStep);

  setState(() => _currentStep++);
}
```

### Track Abandonment
```dart
@override
void dispose() {
  final analytics = ref.read(currentQuestionnaireAnalyticsProvider);
  if (analytics != null && !analytics.isCompleted) {
    ref.read(currentQuestionnaireAnalyticsProvider.notifier)
      .trackAbandon(_currentStep);
  }
  super.dispose();
}
```

### Track Completion
```dart
Future<void> _completeQuestionnaire() async {
  // Save profile data
  await _saveProfile();

  // Track completion
  await ref.read(currentQuestionnaireAnalyticsProvider.notifier)
    .trackCompletion();
}
```

### View Analytics (Admin)
```dart
final aggregated = ref.watch(aggregatedQuestionnaireAnalyticsProvider);

aggregated.when(
  data: (analytics) {
    print('Completion rate: ${(analytics.completionRate * 100).toStringAsFixed(1)}%');
    print('Most problematic step: ${analytics.mostProblematicStep}');
    print('Average completion time: ${analytics.averageCompletionTime.inMinutes}min');
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## Analytics Insights

### Key Metrics Tracked

1. **Completion Rate**: `completions / attempts`
2. **Drop-off by Step**: Identifies where users abandon
3. **Average Time per Step**: Detects confusing/slow steps
4. **Total Completion Time**: Measures questionnaire efficiency
5. **Feedback Ratings**: Direct user sentiment per step

### Optimization Opportunities

Based on tracked data, you can:

1. **Identify Drop-off Steps**: High abandonment rate → simplify or clarify
2. **Optimize Long Steps**: High duration → split into smaller steps
3. **Improve Low-rated Steps**: Poor feedback → redesign UX
4. **A/B Test Changes**: Track completion rate before/after changes
5. **Platform Differences**: Compare iOS vs Android completion rates

## Future Enhancements (Not Yet Implemented)

These features are designed but awaiting implementation:

- **Feature #2**: Stale profile banner on home screen
- **Feature #3**: Suggestion accuracy tracker (entities ready)
- **Feature #5**: Adaptive learning service
- **Feature #6**: In-app feedback widget (infrastructure ready)
- **Cloud Sync**: Optional Firebase sync with GDPR consent
- **A/B Testing**: Variant tracking for UX experiments
- **Cohort Analysis**: Segment by experience level, goal, etc.

## Testing

### Manual Testing

1. Open fitness questionnaire screen
2. Progress through 2-3 steps
3. Close app (trigger abandonment tracking)
4. Check Hive database for saved analytics

### Verification Queries

```dart
// Check if analytics were saved
final datasource = QuestionnaireAnalyticsDataSource();
final latest = await datasource.getLatestAnalytics(userId);

print('Session started: ${latest?.startedAt}');
print('Last step reached: ${latest?.lastStepReached}');
print('Was abandoned: ${latest?.wasAbandoned}');
print('Step durations: ${latest?.stepDurations}');
```

### Hive Inspector

```dart
// View raw Hive data
final box = await Hive.openBox<Map>('questionnaire_analytics');
for (final key in box.keys) {
  print('Key: $key');
  print('Value: ${box.get(key)}');
}
```

## Troubleshooting

### Issue: Analytics not saving

**Solution**: Ensure Hive initialization is called in `main.dart`:
```dart
await QuestionnaireAnalyticsDataSource.initialize();
```

### Issue: Session not starting

**Solution**: Verify postFrameCallback is used in initState:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(currentQuestionnaireAnalyticsProvider.notifier).startSession();
});
```

### Issue: Abandonment not tracked

**Solution**: Check dispose() implementation and ensure analytics is not null:
```dart
final analytics = ref.read(currentQuestionnaireAnalyticsProvider);
if (analytics != null && !analytics.isCompleted) {
  ref.read(currentQuestionnaireAnalyticsProvider.notifier)
    .trackAbandon(_currentStep);
}
```

## Related Files

### Created Files
- `lib/features/strength_standards/domain/entities/questionnaire_analytics.dart`
- `lib/features/strength_standards/domain/entities/suggestion_accuracy.dart`
- `lib/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart`
- Generated: `*.freezed.dart`, `*.g.dart` files

### Modified Files
- `lib/features/strength_standards/presentation/providers/strength_standards_providers.dart`
- `lib/features/strength_standards/presentation/screens/fitness_questionnaire_screen.dart`
- `lib/main.dart` (added Hive initialization)

## Dependencies

- `hive_flutter`: Local database storage
- `freezed`: Immutable entities
- `json_serializable`: JSON serialization
- `uuid`: Generate unique IDs for accuracy records
- `package_info_plus`: Capture app version
- `dart:io`: Capture platform (iOS/Android)

## Next Steps

Per user instruction, features 2, 3, 5, 6 are pending:

1. **Stale Profile Banner**: Show reminder if profile not updated in 30+ days
2. **Suggestion Accuracy Tracker**: Track suggested vs actual weights
3. **Adaptive Learning Service**: Adjust suggestions based on accuracy
4. **In-App Feedback Widget**: Allow users to rate each step

---

**Status**: ✅ Feature #1 Complete | Ready for Testing
**Last Updated**: 2025-10-14
