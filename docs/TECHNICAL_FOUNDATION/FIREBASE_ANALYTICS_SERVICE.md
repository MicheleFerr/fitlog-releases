# 🔥 Firebase Analytics Service: Backend Integration & Dashboard

> **HIGH Priority System** - Cloud analytics infrastructure
> **Location**: `lib/core/services/analytics/firebase_analytics_service.dart`
> **Status**: Production (active)
> **Last Updated**: October 2025

## Overview

**Firebase Analytics Service** bridges local event tracking with Firebase backend:
- **Event Transmission**: Sends queued events to Firebase
- **User Properties**: Links events to user profiles
- **Audience Segmentation**: Group users by behavior
- **Real-Time Dashboards**: View metrics as they happen
- **Custom Reports**: Analyze specific user cohorts

## Architecture

### Service Components

**FirebaseAnalyticsService**: Main integration class
```dart
- initialize(): Setup Firebase Analytics
- logEvent(): Send single event
- setUserProperty(): Set user attribute
- setUserId(): Identify user
- setUserConsentGiven(): GDPR compliance
```

### Data Flow

```
Event Tracked (local)
  ↓
Queue event in memory
  ↓
BatchQueue (50 events or 5 min)
  ↓
Firebase Analytics API
  ↓
Firebase Backend
  ↓
Real-time Dashboard
```

## Implementation

```dart
// Initialize on app startup
Future<void> setupAnalytics(WidgetRef ref) async {
  final analytics = ref.read(firebaseAnalyticsProvider);
  await analytics.initialize();

  // Identify user
  await analytics.setUserId('user_123');

  // Set user properties
  await analytics.setUserProperties({
    'tier': 'premium',
    'app_version': '2.1.0',
    'has_health_integration': true,
  });
}

// Log event with Firebase
final service = ref.read(firebaseAnalyticsProvider);
await service.logEvent(
  name: 'workout_completed',
  parameters: {
    'duration': 45,
    'exercise_count': 8,
    'total_weight': 1250,
  },
);
```

## Event Batching

| Parameter | Value |
|-----------|-------|
| **Batch Size** | 50 events |
| **Time Window** | 5 minutes |
| **Max Queue** | 1000 events |
| **Retry Attempts** | 3 |
| **Offline Buffer** | Up to 1 hour |

## Firebase Console Access

```
1. Open Firebase Console
2. Select GymBro project
3. Go to Analytics → Events
4. View real-time events
5. Create custom reports
```

### Dashboard Views
- **Users**: Active, returning, new
- **Events**: Usage frequency, user journeys
- **Conversions**: Premium upgrade funnels
- **Retention**: Day 1, 7, 30 retention rates
- **Custom Dashboards**: Build your own metrics

## User Consent (GDPR)

```dart
// Request consent before tracking
bool userConsent = await requestUserConsent();

if (userConsent) {
  // Enable analytics
  await analytics.setUserConsentGiven(true);
} else {
  // Disable analytics
  await analytics.setUserConsentGiven(false);
}
```

## Performance Impact

- **Network**: < 1KB per batch upload
- **Battery**: Minimal (batched, offline-first)
- **Storage**: 1-2MB for offline queue
- **CPU**: Negligible impact

## Troubleshooting

### Events Not Appearing
1. Check Firebase project ID correct
2. Verify user authenticated
3. Check network connectivity
4. Wait 24 hours for first day data

### High Data Usage
- Reduce event frequency
- Batch events better
- Filter out test events

### Privacy Concerns
- Use consent system
- Don't track sensitive data
- Review GDPR compliance
- Use anonymized user IDs

---

**See Also**:
- `ANALYTICS_EVENT_TRACKING_SYSTEM.md` (local tracking)
- `FIREBASE_APP_CHECK_SETUP.md` (security)
