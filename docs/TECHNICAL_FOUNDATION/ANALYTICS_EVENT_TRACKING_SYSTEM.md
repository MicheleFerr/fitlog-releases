# 📊 Analytics Event Tracking System: User Behavior & Performance Metrics

> **HIGH Priority System** - Comprehensive user analytics pipeline
> **Location**: `lib/core/analytics/trackers/`
> **Status**: Production (active tracking)
> **Last Updated**: October 2025

## Overview

The **Analytics Event Tracking System** captures:
- **User Actions**: Workout starts, exercise selections, timer interactions
- **Performance Metrics**: Load times, save latency, sync performance
- **Feature Usage**: Which features users engage with most
- **Error Events**: Crashes, API failures, permission denials
- **Custom Events**: Business-specific KPIs

## Architecture

### Event Trackers

**WorkoutEventTracker**: Workout lifecycle events
- `trackWorkoutStarted(workoutId, exerciseCount)`
- `trackWorkoutCompleted(workoutId, duration, calories)`
- `trackExerciseAdded(exerciseId, isCustom)`
- `trackSetCompleted(workoutId, exerciseId, reps, weight)`

**TimerEventTracker**: Rest/workout timer events
- `trackTimerStarted(duration, type)`
- `trackTimerCompleted(duration, type)`
- `trackTimerPaused(duration, elapsed)`
- `trackTimerInteraction(action)`

**PresetSelectionTracker**: Preset usage
- `trackPresetSelected(presetId, exerciseId)`
- `trackPresetCreated(exerciseId)`
- `trackPresetDeleted(presetId)`

## Event Flow

```
User Action
  ↓
Tracker captures event
  ↓
Add metadata (userId, timestamp, sessionId)
  ↓
Queue event locally
  ↓
Batch send to Firebase Analytics
  ↓
Available in Analytics Dashboard
```

## Implementation

```dart
// Track event
ref.read(workoutEventTrackerProvider).trackWorkoutStarted(
  workoutId: 'w123',
  exerciseCount: 5,
);

// Track with custom properties
ref.read(timerEventTrackerProvider).trackTimerCompleted(
  duration: Duration(seconds: 90),
  type: 'rest',
  customProperties: {
    'exerciseType': 'compound',
    'userLevel': 'intermediate',
  },
);
```

## Firebase Analytics Integration

Events automatically sent to Firebase under:
- Event name: `workout_started`, `timer_completed`, etc.
- User ID: Automatically from Auth
- Session ID: Unique per app launch
- Custom parameters: Context-specific data

## Common Events

| Event | Purpose | Key Metrics |
|-------|---------|-------------|
| `workout_started` | Engagement | Daily Active Users |
| `workout_completed` | Retention | Completion Rate |
| `timer_interaction` | Feature Usage | Feature Adoption |
| `exercise_added` | Content | Custom vs. Preset |
| `error_occurred` | Quality | Error Rate & Types |

## Best Practices

1. **Track at user action point**: When user takes action, not system event
2. **Include context**: Exercise type, duration, user level
3. **Batch events**: Don't fire every 100ms
4. **Use consistent naming**: `snake_case`, descriptive names
5. **Include user properties**: Premium status, experiment group
6. **Track errors**: Failures help identify issues

## Accessing Analytics

```dart
// Via Firebase Console
// Analytics → Events → See all tracked events

// Via custom reports
final metrics = ref.read(analyticsProvider).getMetrics(
  eventName: 'workout_completed',
  dateRange: DateRange.lastWeek,
);
```

## Performance

- **Local queue**: Non-blocking event capture
- **Batch size**: 50 events per upload
- **Upload interval**: 5 minutes or on app background
- **Storage**: < 1MB for queued events

---

**See Also**: `FIREBASE_ANALYTICS_SERVICE.md` (backend integration)
