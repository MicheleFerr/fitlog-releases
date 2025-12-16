# Notification System Fix - Implementation Plan

**Generated**: 2025-01-25
**Source**: task-master.dev + Best Practices Research 2024-2025
**Complexity Score**: HIGH
**Total Tasks**: 19
**Estimated Time**: ~12h
**Plan Version**: 1.0

---

## Original Request

> Fix and complete the notification system that doesn't work at all. The main issues are:
> - NotificationServicesInitializer never initialized
> - LocalNotificationRepository has 40+ stub methods
> - FCM handlers incomplete
> - Android 14 / iOS specific issues

---

## Best Practices Applied (2024-2025)

| Practice | Source | Applied In |
|----------|--------|------------|
| Riverpod keepAlive instead of singleton | Code with Andrea | T13 |
| @pragma('vm:entry-point') for background | pub.dev | T09 |
| Android 14 SCHEDULE_EXACT_ALARM | GitHub Issues | T07 |
| iOS Xcode capabilities | FlutterFire Docs | T08 |
| getInitialMessage after Firebase.initializeApp | Stack Overflow | T06, T10 |
| zonedSchedule androidScheduleMode required | Changelog | T11 |
| tz.initializeTimeZones() first | LogRocket | T12 |

---

## Task Breakdown

### P0 - CRITICAL

#### T01: Initialize NotificationServicesInitializer in main.dart
- **Time**: 20min | **Deps**: None
- **Files**: `lib/main.dart`
- **Verification**: App logs show initialization

#### T02: Implement LocalNotificationRepository core methods
- **Time**: 1.5h | **Deps**: T01
- **Files**: `lib/features/notifications/data/repositories/local_notification_repository.dart`
- **Verification**: 40+ methods implemented

#### T03: Implement FCMService tap navigation handler
- **Time**: 45min | **Deps**: T01
- **Files**: `lib/features/notifications/data/services/fcm_service.dart`
- **Verification**: Tap navigates correctly

### P1 - HIGH

#### T04: Enable SmartNotificationService.scheduleNotificationsForRoutine()
- **Time**: 30min | **Deps**: T02
- **Files**: `lib/features/notifications/domain/services/smart_notification_service.dart`

#### T05: Unify WorkoutNotification and UnifiedNotification
- **Time**: 50min | **Deps**: None
- **Files**: `lib/features/notifications/domain/entities/`

#### T06: Fix FCMService provider async race condition
- **Time**: 40min | **Deps**: T01, T03
- **Files**: `lib/features/notifications/presentation/providers/notification_providers.dart`

#### T07: Android 14 SCHEDULE_EXACT_ALARM handling
- **Time**: 35min | **Deps**: T02
- **Files**: `android/app/src/main/AndroidManifest.xml`, repository

#### T08: Verify iOS Xcode capabilities
- **Time**: 25min | **Deps**: None
- **Files**: `ios/Runner.xcodeproj/project.pbxproj`

#### T09: Add @pragma to background handler
- **Time**: 15min | **Deps**: None
- **Files**: `lib/features/notifications/data/services/fcm_service.dart`

#### T10: Implement both getInitialMessage() and onMessageOpenedApp
- **Time**: 50min | **Deps**: T03, T06
- **Files**: `lib/features/notifications/data/services/fcm_service.dart`

#### T11: zonedSchedule androidScheduleMode required
- **Time**: 20min | **Deps**: T02
- **Files**: `local_notification_repository.dart`

#### T12: Initialize timezone before scheduling
- **Time**: 15min | **Deps**: T02
- **Files**: `notification_services_initializer.dart`

### P2 - MEDIUM

#### T13: Migrate to Riverpod Provider with keepAlive
- **Time**: 45min | **Deps**: T02
- **Files**: `notification_providers.dart`

#### T14: Implement notification streams (non-empty)
- **Time**: 35min | **Deps**: T02
- **Files**: `local_notification_repository.dart`

#### T15: Implement cleanupOldNotifications()
- **Time**: 30min | **Deps**: T02
- **Files**: `local_notification_repository.dart`

#### T16: Replace isSystemHealthy() stub
- **Time**: 40min | **Deps**: T02, T07, T08
- **Files**: `smart_notification_service.dart`

#### T17: Add EN/IT localization
- **Time**: 50min | **Deps**: T02
- **Files**: `app_en.arb`, `app_it.arb`

#### T18: Unit tests
- **Time**: 1h | **Deps**: T02, T03, T04, T16
- **Files**: `test/features/notifications/`

#### T19: Integration test
- **Time**: 1h | **Deps**: T02, T03, T10
- **Files**: `integration_test/`

---

## Execution Order

```
Phase 1 (Config & P0): T01 → T08 → T07 → T09 → T02 → T03 → T06
Phase 2 (P1 Logic):    T04 → T05 → T10 → T11 → T12
Phase 3 (P2 & Tests):  T13 → T14 → T15 → T16 → T17 → T18 → T19
```

---

## Notes & Decisions

- Using Riverpod keepAlive pattern instead of singleton (best practice 2024)
- Android 14: fallback to inexact scheduling if permission denied
- iOS: will verify Xcode capabilities programmatically
- Will consolidate WorkoutNotification INTO UnifiedNotification (single source of truth)
