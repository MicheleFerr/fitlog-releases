# Calendar Scheduling - Design Document

**Created**: 2025-11-27
**Status**: 🎨 DESIGN PHASE
**Complexity Score**: HIGH
**Estimated Time**: ~8-12h
**Plan Version**: 1.0

---

## 📋 Original Request

> Implementare scheduling workout con integrazione calendario iOS/Android. L'utente seleziona un template, tap su "Schedule", poi può selezionare multipli giorni direttamente dal calendario con tap toggle.

---

## 🎯 Feature Overview

Permette agli utenti di schedulare workout su giorni specifici del calendario con:
- **Multi-select calendar**: Tap sui giorni per selezionare/deselezionare
- **Calendar integration**: Sync con iOS Calendar (EventKit) e Google Calendar
- **Reminder notification**: Notifica il giorno dello workout schedulato
- **Future**: Live Activity reminder prima del workout

---

## 🔬 UX Research Findings

### Validazione Pattern Multi-Select

| Fonte | Finding |
|-------|---------|
| [Smashing Magazine](https://www.smashingmagazine.com/2017/07/designing-perfect-date-time-picker/) | Max 6 tap per completare task |
| [Mobiscroll](https://demo.mobiscroll.com/calendar/multiple-select) | Multi-select calendar è pattern standard |
| [UX Stack Exchange](https://ux.stackexchange.com/questions/30560/datepicker-ux-for-single-and-multiple-calendar-mode) | Conferma esplicita (OK button) dopo selezione |
| [Storyly](https://www.storyly.io/post/best-user-experience-datepicker-examples-for-mobile-and-web) | Feedback visivo immediato su selezione |

### Flutter Package Consigliato

**`calendar_date_picker2`** (pub.dev)
- ✅ Gratuito e open source
- ✅ `CalendarDatePicker2Type.multi` per multi-select
- ✅ Ottimizzato per mobile touch
- ✅ Customizzabile (colori, bordi, etc.)

---

## 🎨 User Flow Design

### Flow Principale

```
┌─────────────────────────────────────────────────────────────┐
│                    TEMPLATES SCREEN                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────┐                 │
│  │ 🏋️ Push Day                            │                 │
│  │ Chest, Shoulders, Triceps              │                 │
│  │ 5 exercises • ~45 min                  │                 │
│  │                                        │                 │
│  │  [▶️ Start]  [📅 Schedule]  [•••]     │ ← NEW BUTTON    │
│  └────────────────────────────────────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Tap "Schedule"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              SCHEDULE BOTTOM SHEET                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📅 Schedule "Push Day"                                     │
│  ─────────────────────────────────────────                  │
│                                                              │
│  Tap days to select/deselect                                │
│                                                              │
│       November 2025            [<] [>]                      │
│  ┌─────────────────────────────────────┐                    │
│  │ Mo  Tu  We  Th  Fr  Sa  Su          │                    │
│  │                          1   2       │                    │
│  │  3   4   5   6   7   8   9          │                    │
│  │ 10  11  12  13  14  15  16          │                    │
│  │ 17  18  19  20  21  22  23          │                    │
│  │ 24  25 [26] 27 [28] 29 [30]         │ ← Selected days   │
│  └─────────────────────────────────────┘     (highlighted)  │
│                                                              │
│  ┌─────────────────────────────────────┐                    │
│  │ ⏰ Reminder time: 09:00              │ ← Optional        │
│  └─────────────────────────────────────┘                    │
│                                                              │
│  ┌─────────────────────────────────────┐                    │
│  │ 📱 Add to device calendar           │ ← Toggle          │
│  └─────────────────────────────────────┘                    │
│                                                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                    │
│  3 days selected                                            │
│                                                              │
│  [Cancel]                    [✓ Confirm Schedule]           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Tap "Confirm Schedule"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  SUCCESS FEEDBACK                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ✅ "Push Day" scheduled for 3 days                         │
│                                                              │
│  • Nov 26 (Tue) at 09:00                                    │
│  • Nov 28 (Thu) at 09:00                                    │
│  • Nov 30 (Sat) at 09:00                                    │
│                                                              │
│  [View in Calendar]              [Done]                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Stati Calendar Day

```
┌─────────┬─────────┬─────────┐
│ Normal  │ Selected│ Today   │
│         │         │         │
│   15    │  [15]   │  •15•   │
│         │  (blue  │ (accent │
│         │   bg)   │ border) │
└─────────┴─────────┴─────────┘

┌─────────┬─────────┬─────────┐
│  Past   │ Already │ Weekend │
│ (gray)  │Scheduled│(subtle) │
│         │         │         │
│   10    │  15✓    │   16    │
│(disabled│ (green  │ (light  │
│  tap)   │  dot)   │   bg)   │
└─────────┴─────────┴─────────┘
```

---

## 🏗️ Architecture

### Layer Structure

```
lib/features/scheduling/
├── domain/
│   ├── entities/
│   │   ├── scheduled_workout.dart
│   │   └── workout_schedule.dart
│   ├── repositories/
│   │   └── schedule_repository.dart
│   └── services/
│       └── calendar_sync_service.dart
│
├── data/
│   ├── datasources/
│   │   ├── hive_schedule_datasource.dart
│   │   ├── ios_calendar_datasource.dart
│   │   └── android_calendar_datasource.dart
│   ├── models/
│   │   └── scheduled_workout_model.dart
│   └── repositories/
│       └── schedule_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── schedule_provider.dart
    │   └── calendar_sync_provider.dart
    ├── screens/
    │   └── scheduled_workouts_screen.dart
    └── widgets/
        ├── schedule_bottom_sheet.dart
        ├── multi_select_calendar.dart
        └── scheduled_workout_card.dart
```

### Data Model

```dart
/// Scheduled workout entity
@freezed
class ScheduledWorkout with _$ScheduledWorkout {
  const factory ScheduledWorkout({
    required String id,
    required String templateId,
    required String templateName,
    required DateTime scheduledDate,
    required TimeOfDay reminderTime,
    @Default(false) bool addedToDeviceCalendar,
    String? deviceCalendarEventId,
    @Default(ScheduleStatus.pending) ScheduleStatus status,
    DateTime? completedAt,
  }) = _ScheduledWorkout;
}

enum ScheduleStatus {
  pending,    // Scheduled, not yet due
  due,        // It's workout day!
  completed,  // Workout done
  skipped,    // User skipped
  missed,     // Day passed without action
}
```

### Platform Channels (iOS/Android Calendar)

```dart
/// Calendar sync service interface
abstract class CalendarSyncService {
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<String?> createEvent(ScheduledWorkout workout);
  Future<bool> deleteEvent(String eventId);
  Future<List<String>> getExistingWorkoutEvents();
}
```

---

## 📱 UI Components

### 1. Schedule Button (Template Card)

```dart
// In template_card.dart - add new action button
IconButton(
  icon: Icon(AppIcons.calendarPlus),
  onPressed: () => _showScheduleBottomSheet(context, template),
  tooltip: context.l10n.scheduleWorkout,
)
```

### 2. Schedule Bottom Sheet

```dart
class ScheduleBottomSheet extends ConsumerStatefulWidget {
  final WorkoutTemplate template;

  // Shows:
  // - Header with template name
  // - Multi-select calendar (calendar_date_picker2)
  // - Reminder time picker
  // - "Add to device calendar" toggle
  // - Selection counter ("3 days selected")
  // - Cancel/Confirm buttons
}
```

### 3. Multi-Select Calendar

```dart
CalendarDatePicker2(
  config: CalendarDatePicker2Config(
    calendarType: CalendarDatePicker2Type.multi,
    selectedDayHighlightColor: context.colors.primary,
    todayHighlightColor: context.colors.secondary,
    disableModePicker: true,
    firstDate: DateTime.now(), // No past dates
    lastDate: DateTime.now().add(Duration(days: 90)), // 3 months ahead
    selectableDayPredicate: (date) {
      // Disable days with existing schedules for this template
      return !_hasExistingSchedule(date);
    },
  ),
  value: selectedDates,
  onValueChanged: (dates) => setState(() => selectedDates = dates),
)
```

---

## 🔔 Notification Integration

### Reminder Flow

```
Day before scheduled workout (8pm)
         ↓
┌─────────────────────────────────────────┐
│ 📅 Workout Tomorrow                     │
│ "Push Day" is scheduled for 09:00       │
│                                         │
│ [View]              [Reschedule]        │
└─────────────────────────────────────────┘

Day of workout (at reminder time)
         ↓
┌─────────────────────────────────────────┐
│ 🏋️ Time to workout!                    │
│ "Push Day" is ready to start            │
│                                         │
│ [Start Now]              [Skip]         │
└─────────────────────────────────────────┘
```

### Integration with NotificationScheduler

```dart
// In notification_scheduler.dart - add new method
Future<void> scheduleWorkoutReminder({
  required ScheduledWorkout workout,
  required AppLocalizations l10n,
}) async {
  // Day before notification
  await _repository.scheduleNotification(
    type: NotificationType.workoutReminder,
    message: _messagePool.getMessage(
      type: NotificationType.workoutReminder,
      l10n: l10n,
      params: {'workoutName': workout.templateName},
    ),
    scheduledTime: workout.scheduledDate
        .subtract(Duration(days: 1))
        .copyWith(hour: 20, minute: 0),
  );

  // Same-day notification at reminder time
  await _repository.scheduleNotification(
    type: NotificationType.workoutDue,
    message: _messagePool.getMessage(
      type: NotificationType.workoutDue,
      l10n: l10n,
      params: {'workoutName': workout.templateName},
    ),
    scheduledTime: DateTime(
      workout.scheduledDate.year,
      workout.scheduledDate.month,
      workout.scheduledDate.day,
      workout.reminderTime.hour,
      workout.reminderTime.minute,
    ),
  );
}
```

---

## 📅 Device Calendar Integration

### iOS (EventKit)

```swift
// Platform channel method
func createWorkoutCalendarEvent(
    title: String,
    date: Date,
    duration: TimeInterval,
    notes: String?
) -> String? {
    let eventStore = EKEventStore()
    let event = EKEvent(eventStore: eventStore)

    event.title = "🏋️ \(title)"
    event.startDate = date
    event.endDate = date.addingTimeInterval(duration)
    event.notes = notes
    event.calendar = eventStore.defaultCalendarForNewEvents

    // Add alert 30 min before
    event.addAlarm(EKAlarm(relativeOffset: -1800))

    try? eventStore.save(event, span: .thisEvent)
    return event.eventIdentifier
}
```

### Android (Calendar Provider)

```kotlin
// Platform channel method
fun createWorkoutCalendarEvent(
    title: String,
    startTime: Long,
    duration: Long,
    notes: String?
): Long? {
    val values = ContentValues().apply {
        put(CalendarContract.Events.TITLE, "🏋️ $title")
        put(CalendarContract.Events.DTSTART, startTime)
        put(CalendarContract.Events.DTEND, startTime + duration)
        put(CalendarContract.Events.DESCRIPTION, notes)
        put(CalendarContract.Events.CALENDAR_ID, getDefaultCalendarId())
        put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
    }

    val uri = contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
    return uri?.lastPathSegment?.toLong()
}
```

---

## 🔮 Future: Scheduled Workout Live Activity

### Phase 2: Live Activity Reminder

Quando mancano 15 minuti al workout schedulato:

```
Dynamic Island (Compact)
┌────────────────────────┐
│ 🏋️ Push Day in 15min  │
└────────────────────────┘

Lock Screen
┌────────────────────────────────────────┐
│ 🏋️ Push Day                           │
│                                        │
│ Starts in 15 minutes                   │
│ ━━━━━━━━━░░░░░░░░░░░░░░░░  [Start]   │
└────────────────────────────────────────┘
```

---

## 📋 Implementation Tasks

### Phase 1: MVP (Local Scheduling)

- [ ] **Task 1.1**: Create ScheduledWorkout entity + model
- [ ] **Task 1.2**: Create HiveScheduleDatasource
- [ ] **Task 1.3**: Create ScheduleRepository
- [ ] **Task 1.4**: Create ScheduleProvider (Riverpod)
- [ ] **Task 1.5**: Create ScheduleBottomSheet widget
- [ ] **Task 1.6**: Integrate calendar_date_picker2
- [ ] **Task 1.7**: Add Schedule button to template card
- [ ] **Task 1.8**: Create success confirmation dialog
- [ ] **Task 1.9**: Add notification reminders
- [ ] **Task 1.10**: Create ScheduledWorkoutsScreen (view all)
- [ ] **Task 1.11**: Localization (EN + IT)
- [ ] **Task 1.12**: Unit tests

### Phase 2: Device Calendar Integration

- [ ] **Task 2.1**: iOS EventKit platform channel
- [ ] **Task 2.2**: Android Calendar Provider platform channel
- [ ] **Task 2.3**: CalendarSyncService implementation
- [ ] **Task 2.4**: Permission handling UI
- [ ] **Task 2.5**: Sync toggle in bottom sheet

### Phase 3: Live Activity Reminder (Future)

- [ ] **Task 3.1**: ScheduledWorkoutLiveActivity widget (iOS)
- [ ] **Task 3.2**: Countdown display
- [ ] **Task 3.3**: Start button action

---

## 🧪 Testing Checklist

### Functional Tests
- [ ] Multi-select calendar allows selecting multiple days
- [ ] Past dates are disabled
- [ ] Already scheduled dates show indicator
- [ ] Confirm creates schedules for all selected days
- [ ] Reminder notifications fire at correct times
- [ ] Device calendar events created (if enabled)
- [ ] Schedules persist across app restart

### Edge Cases
- [ ] Select same day twice = toggle off
- [ ] No days selected = confirm disabled
- [ ] Schedule 30+ days = performance OK
- [ ] Cancel clears selection
- [ ] Template deleted = orphan schedules handled

---

## 📝 Dependencies

### Flutter Packages

```yaml
dependencies:
  calendar_date_picker2: ^1.1.5  # Multi-select calendar
  device_calendar: ^4.3.2        # Native calendar integration (Phase 2)
```

### Localizations to Add

```arb
// app_en.arb
"scheduleWorkout": "Schedule",
"scheduleDays": "Schedule days",
"tapDaysToSelect": "Tap days to select/deselect",
"daysSelected": "{count} {count, plural, =1{day} other{days}} selected",
"reminderTime": "Reminder time",
"addToDeviceCalendar": "Add to device calendar",
"confirmSchedule": "Confirm Schedule",
"workoutScheduled": "\"{name}\" scheduled for {count} days",
"scheduledWorkouts": "Scheduled Workouts",
"noScheduledWorkouts": "No scheduled workouts",
"workoutDueToday": "Due today",
"workoutDueTomorrow": "Due tomorrow"
```

---

## 📊 Success Metrics

| Metric | Target |
|--------|--------|
| Scheduling completion rate | >80% (start→confirm) |
| Calendar sync adoption | >40% enable toggle |
| Scheduled workout completion | >60% actually done |
| Notification tap-through | >30% |
