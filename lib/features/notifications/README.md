# 🔔 Smart Notifications System

Sistema intelligente di notifiche per workout e recovery con scheduling automatico.

## 📋 Features

### ✅ Implemented

- **Workout Reminders**: Notifiche automatiche prima dei workout programmati
- **Recovery Alerts**: Alert per giorni di allenamento saltati da recuperare
- **Streak Motivation**: Messaggi motivazionali per mantenere la streak attiva
- **Rest Day Reminders**: Reminder per giorni di riposo programmati
- **Smart Scheduling**: Ottimizzazione automatica degli orari e anti-spam
- **Do Not Disturb**: Rispetto della finestra "Non disturbare" utente
- **Priority Levels**: 3 livelli di priorità (low/medium/high)
- **User Preferences**: Configurazione completa tramite UI

## 🏗️ Architecture

```
features/notifications/
├── domain/
│   ├── entities/
│   │   └── workout_notification.dart      # Entity con Freezed + Settings
│   └── repositories/
│       └── notification_repository.dart   # Interface
├── data/
│   ├── repositories/
│   │   └── local_notification_repository.dart  # flutter_local_notifications
│   └── utils/
│       └── timezone_helper.dart           # Timezone initialization
└── presentation/
    ├── providers/
    │   └── notification_providers.dart     # Riverpod DI
    ├── services/
    │   └── smart_notification_service.dart # Intelligent logic
    └── screens/
        └── notification_settings_screen.dart # Settings UI
```

## 🚀 Usage

### 1. Initialization (in main.dart)

```dart
import 'package:timezone/timezone.dart' as tz;
import 'features/notifications/data/utils/timezone_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone for scheduled notifications
  await TimezoneHelper.initialize();
  
  runApp(const MyApp());
}
```

### 2. Initialize Notification System

```dart
// In your app initialization
final notificationService = ref.read(smartNotificationServiceProvider);
await notificationService.initialize();
```

### 3. Schedule Notifications for a Routine

```dart
// Automatically schedule notifications when routine is created/activated
final service = ref.read(smartNotificationServiceProvider);
await service.scheduleNotificationsForRoutine(routine);
```

### 4. Cancel Notifications

```dart
// Cancel all notifications for a specific routine
await service.cancelNotificationsForRoutine(routineId);

// Cancel all notifications
await service.cancelAllNotifications();
```

### 5. Navigate to Settings

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NotificationSettingsScreen(),
  ),
);
```

## 📊 Notification Types

### WorkoutReminder
- **Priority**: Medium
- **Icon**: 💪
- **Trigger**: X minutes before scheduled workout
- **Configurable**: Yes (user can enable/disable)

### RecoveryAlert
- **Priority**: High
- **Icon**: 🔄
- **Trigger**: When skipped workouts need recovery
- **Configurable**: Yes (user can enable/disable)

### StreakMotivation
- **Priority**: Low
- **Icon**: 🔥
- **Trigger**: Daily if streak is active
- **Configurable**: Yes (disabled by default)

### RestDayReminder
- **Priority**: Low
- **Icon**: 😴
- **Trigger**: On scheduled rest days
- **Configurable**: Yes (disabled by default)

## ⚙️ User Settings

### Notification Types (Enable/Disable)
- Workout Reminders (default: ON)
- Recovery Alerts (default: ON)
- Streak Motivation (default: OFF)
- Rest Day Reminders (default: OFF)

### Preferred Time
- Morning (8:00)
- Midday (12:30)
- Afternoon (16:00)
- Evening (19:00)
- Custom (user-defined)

### Smart Features
- **Smart Scheduling**: Automatically optimize timing and avoid spam (default: ON)
- **Do Not Disturb**: Delay notifications during sleep hours (default: OFF)
  - Default window: 22:00 - 7:00
  - Notifications in this window are delayed to 7:00 AM

### Advanced
- **Reminder Minutes Before**: How many minutes before workout to notify (default: 60)

## 🧠 Smart Scheduling Logic

### Anti-Spam
- Maximum 2 notifications per day
- Duplicate detection
- Priority-based filtering

### Grouping
- Consecutive skipped days are grouped into single recovery alert
- Multiple workouts on same day share preferred time slot

### Do Not Disturb
- Notifications scheduled during DND window are automatically delayed
- Delayed notifications show at end of DND window (7:00 AM by default)

## 🔐 Permissions

### Android
- **Android 13+**: Runtime permission required (`POST_NOTIFICATIONS`)
- **Android < 13**: No permission required

### iOS
- Runtime permission required for:
  - Alert
  - Badge
  - Sound

## 🧪 Testing

```dart
// Show immediate test notification
final service = ref.read(smartNotificationServiceProvider);
await service.showTestNotification();
```

## 📱 Platform-Specific Notes

### Android
- 3 notification channels created automatically:
  - `gymbro_low_priority`: Non-urgent notifications
  - `gymbro_medium_priority`: Workout reminders (default)
  - `gymbro_high_priority`: Important alerts
  
### iOS
- Uses DarwinNotificationDetails
- Supports badge, alert, and sound
- Respects iOS notification settings

## 🔄 Integration with Routines

The notification system automatically integrates with FlexibleRoutine:

1. When a routine is activated → notifications are scheduled for next 30 days
2. When a routine is deactivated → notifications are cancelled
3. When workout is skipped → recovery alert is updated
4. When workout is recovered → recovery alert is removed

## 🐛 Debugging

```dart
// Check initialization status
final isInitialized = ref.read(notificationInitializationProvider);

// Check permissions
final hasPermissions = ref.read(notificationPermissionProvider);

// View pending notifications
final pending = ref.read(pendingNotificationsProvider);
print('Pending notifications: ${pending.length}');
```

## 📚 Dependencies

- `flutter_local_notifications: ^16.3.0`
- `timezone: ^0.9.2`
- `shared_preferences: ^2.2.2`

## 🚧 Future Enhancements

- [ ] Custom notification sounds
- [ ] Rich notifications with actions (Mark Complete, Skip, etc.)
- [ ] Notification history
- [ ] Weekly summary notifications
- [ ] Achievement notifications
- [ ] Firebase Cloud Messaging for remote notifications
- [ ] Notification analytics

## 🙏 Notes

- Notifications are scheduled locally using `flutter_local_notifications`
- No server-side component required
- Timezone detection is automatic
- Settings persist in SharedPreferences
- Fully offline-capable
