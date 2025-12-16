# Calendar Scheduling - Implementation Plan

**Generated**: 2025-11-27 11:00
**Source**: task-master.dev (WebFetch) + FitLog Pro enrichments
**Status**: 📋 READY FOR IMPLEMENTATION
**Complexity Score**: HIGH
**Total Tasks**: 20
**Estimated Time**: ~10-12h
**Plan Version**: 1.0

---

## 📋 Original Request

> Implementare scheduling workout con multi-select calendar. User flow: template → schedule button → bottom sheet con calendario → tap giorni → conferma → notifiche reminder.

---

## 🎯 Scope: Phase 1 MVP

**Incluso**:
- ✅ Multi-select calendar con tap toggle
- ✅ Persistenza locale (Hive)
- ✅ Notifiche reminder
- ✅ Lista scheduled workouts
- ✅ Localizzazione EN/IT
- ✅ Theme support

**Escluso (Phase 2)**:
- ❌ Device calendar sync (iOS EventKit, Android Calendar)
- ❌ Live Activity reminder
- ❌ Google Calendar sync

---

## 📊 Task Overview

| Layer | Tasks | Est. Time |
|-------|-------|-----------|
| Domain | 3 | ~1h |
| Data | 4 | ~2h |
| Presentation | 9 | ~5h |
| Testing | 3 | ~2.5h |
| Localization | 1 | ~15min |
| **TOTAL** | **20** | **~10-12h** |

---

## 🏗️ Domain Layer (3 tasks)

### Task 1.1: Create ScheduledWorkout Entity
- **File**: `lib/features/scheduling/domain/entities/scheduled_workout.dart`
- **Est. Time**: 20 min
- **Dependencies**: None
- **Blocking**: Task 1.2, 2.1

**Implementation**:
```dart
@freezed
class ScheduledWorkout with _$ScheduledWorkout {
  const factory ScheduledWorkout({
    required String id,
    required String templateId,
    required String templateName,
    required DateTime scheduledDate,
    required TimeOfDay reminderTime,
    @Default(ScheduleStatus.pending) ScheduleStatus status,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _ScheduledWorkout;
}

enum ScheduleStatus { pending, due, completed, skipped, missed }
```

**Verification**:
- [ ] Entity is immutable (freezed)
- [ ] All required fields in constructor
- [ ] Enum covers all status states

---

### Task 1.2: Define Scheduling Repository Contract
- **File**: `lib/features/scheduling/domain/repositories/scheduling_repository.dart`
- **Est. Time**: 15 min
- **Dependencies**: Task 1.1
- **Blocking**: Task 2.2

**Implementation**:
```dart
abstract class SchedulingRepository {
  Future<List<ScheduledWorkout>> getScheduledWorkouts();
  Future<List<ScheduledWorkout>> getScheduledWorkoutsForDate(DateTime date);
  Future<ScheduledWorkout?> getScheduledWorkout(String id);
  Future<void> scheduleWorkout(ScheduledWorkout workout);
  Future<void> scheduleMultipleWorkouts(List<ScheduledWorkout> workouts);
  Future<void> updateSchedule(ScheduledWorkout workout);
  Future<void> deleteSchedule(String id);
  Future<void> markAsCompleted(String id);
  Future<void> markAsSkipped(String id);
}
```

**Verification**:
- [ ] Contract covers all CRUD operations
- [ ] Batch scheduling method exists
- [ ] Status update methods exist

---

### Task 1.3: Create Scheduling Use Cases (Optional)
- **File**: `lib/features/scheduling/domain/usecases/`
- **Est. Time**: 30 min
- **Dependencies**: Task 1.1, 1.2
- **Note**: May skip if using repository directly in provider

**Files**:
- `schedule_workout_usecase.dart`
- `get_scheduled_workouts_usecase.dart`
- `delete_schedule_usecase.dart`

**Verification**:
- [ ] Each use case accepts repository
- [ ] Returns Future with proper types

---

## 💾 Data Layer (4 tasks)

### Task 2.1: Create ScheduledWorkoutModel + Hive Adapter
- **File**: `lib/features/scheduling/data/models/scheduled_workout_model.dart`
- **Est. Time**: 25 min
- **Dependencies**: Task 1.1
- **Blocking**: Task 2.2, 2.3

**Implementation**:
```dart
@HiveType(typeId: 50) // Check available typeId in hive_registrar.g.dart
class ScheduledWorkoutModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String templateId;
  @HiveField(2) String templateName;
  @HiveField(3) DateTime scheduledDate;
  @HiveField(4) int reminderHour;
  @HiveField(5) int reminderMinute;
  @HiveField(6) int status; // enum index
  @HiveField(7) DateTime? completedAt;
  @HiveField(8) DateTime? createdAt;

  // toEntity() and fromEntity() methods
}
```

**Verification**:
- [ ] TypeId is unique (check existing adapters)
- [ ] Adapter registered in `hive_registrar.g.dart`
- [ ] Model serializes/deserializes correctly

---

### Task 2.2: Create Local Scheduling DataSource
- **File**: `lib/features/scheduling/data/datasources/hive_scheduling_datasource.dart`
- **Est. Time**: 30 min
- **Dependencies**: Task 2.1
- **Blocking**: Task 2.3

**Implementation**:
```dart
class HiveSchedulingDatasource {
  static const String boxName = 'scheduled_workouts';

  Future<Box<ScheduledWorkoutModel>> get _box async =>
      Hive.openBox<ScheduledWorkoutModel>(boxName);

  Future<void> saveScheduledWorkout(ScheduledWorkoutModel model);
  Future<List<ScheduledWorkoutModel>> getAllScheduledWorkouts();
  Future<ScheduledWorkoutModel?> getScheduledWorkout(String id);
  Future<void> deleteScheduledWorkout(String id);
  Future<void> updateScheduledWorkout(ScheduledWorkoutModel model);
}
```

**Verification**:
- [ ] Box name is unique
- [ ] CRUD operations work correctly
- [ ] Query by date range works

---

### Task 2.3: Implement Scheduling Repository
- **File**: `lib/features/scheduling/data/repositories/scheduling_repository_impl.dart`
- **Est. Time**: 40 min
- **Dependencies**: Task 1.2, 2.2
- **Blocking**: Task 3.1

**Implementation**:
```dart
class SchedulingRepositoryImpl implements SchedulingRepository {
  final HiveSchedulingDatasource _datasource;

  // Implement all abstract methods
  // Map between Model and Entity
}
```

**Verification**:
- [ ] All repository methods implemented
- [ ] Entity/Model mapping correct
- [ ] Error handling in place

---

### Task 2.4: Create Scheduling Notification Service
- **File**: `lib/features/scheduling/data/services/scheduling_notification_service.dart`
- **Est. Time**: 35 min
- **Dependencies**: Task 1.1, existing notification system
- **Blocking**: Task 3.1

**Implementation**:
```dart
class SchedulingNotificationService {
  final NotificationRepository _notificationRepository;

  Future<void> scheduleWorkoutReminder({
    required ScheduledWorkout workout,
    required AppLocalizations l10n,
  }) async {
    // Day-of notification at reminder time
    await _notificationRepository.scheduleNotification(
      type: NotificationType.workoutReminder,
      message: l10n.workoutReminderMessage(workout.templateName),
      scheduledTime: _buildScheduledTime(workout),
    );
  }

  Future<void> cancelWorkoutReminder(String workoutId);
}
```

**Verification**:
- [ ] Integrates with existing NotificationRepository
- [ ] Reminders fire at correct time
- [ ] Cancel works when schedule deleted

---

## 🎨 Presentation Layer (9 tasks)

### Task 3.1: Create Scheduling Provider (Riverpod Notifier)
- **File**: `lib/features/scheduling/presentation/providers/scheduling_provider.dart`
- **Est. Time**: 40 min
- **Dependencies**: Task 2.3, 2.4
- **Blocking**: Task 3.5, 3.6

**Implementation**:
```dart
@riverpod
class SchedulingNotifier extends _$SchedulingNotifier {
  @override
  Future<List<ScheduledWorkout>> build() async {
    return _loadScheduledWorkouts();
  }

  Future<void> scheduleWorkouts({
    required String templateId,
    required String templateName,
    required List<DateTime> selectedDates,
    required TimeOfDay reminderTime,
  }) async {
    // Create ScheduledWorkout for each date
    // Save via repository
    // Schedule notifications
    // Refresh state
  }

  Future<void> deleteSchedule(String id);
  Future<void> markAsCompleted(String id);
}
```

**Verification**:
- [ ] Uses Notifier pattern (not StateNotifier)
- [ ] State updates correctly
- [ ] Notifications scheduled on create

---

### Task 3.2: Create UI State Model
- **File**: `lib/features/scheduling/presentation/models/scheduling_ui_state.dart`
- **Est. Time**: 15 min
- **Dependencies**: None
- **Blocking**: Task 3.5

**Implementation**:
```dart
@freezed
class ScheduleBottomSheetState with _$ScheduleBottomSheetState {
  const factory ScheduleBottomSheetState({
    @Default([]) List<DateTime> selectedDates,
    @Default(TimeOfDay(hour: 9, minute: 0)) TimeOfDay reminderTime,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ScheduleBottomSheetState;
}
```

**Verification**:
- [ ] Covers all UI flow states
- [ ] Default reminder time is sensible

---

### Task 3.3: Build Multi-Select Calendar Widget
- **File**: `lib/features/scheduling/presentation/widgets/multi_select_calendar.dart`
- **Est. Time**: 45 min
- **Dependencies**: calendar_date_picker2 package
- **Blocking**: Task 3.5

**Implementation**:
```dart
class MultiSelectCalendar extends StatelessWidget {
  final List<DateTime> selectedDates;
  final ValueChanged<List<DateTime>> onSelectionChanged;
  final List<DateTime>? disabledDates; // Already scheduled
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        calendarType: CalendarDatePicker2Type.multi,
        selectedDayHighlightColor: context.colors.primary,
        todayHighlightColor: context.colors.secondary.withOpacity(0.3),
        disableModePicker: true,
        firstDate: minDate ?? DateTime.now(),
        lastDate: maxDate ?? DateTime.now().add(Duration(days: 90)),
        selectableDayPredicate: (date) =>
            disabledDates?.contains(date) != true,
      ),
      value: selectedDates,
      onValueChanged: (dates) => onSelectionChanged(
        dates.whereType<DateTime>().toList(),
      ),
    );
  }
}
```

**Verification**:
- [ ] Toggle selection works (tap = select/deselect)
- [ ] Highlights selected days correctly
- [ ] Past dates disabled
- [ ] Theme colors applied

---

### Task 3.4: Create Reminder Time Picker Widget
- **File**: `lib/features/scheduling/presentation/widgets/reminder_time_picker.dart`
- **Est. Time**: 30 min
- **Dependencies**: None
- **Blocking**: Task 3.5

**Implementation**:
```dart
class ReminderTimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(AppIcons.clock, color: context.iconPrimary),
      title: Text(context.l10n.reminderTime),
      subtitle: Text(_formatTime(selectedTime, context)),
      trailing: Icon(AppIcons.chevronRight),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (time != null) onTimeChanged(time);
      },
    );
  }
}
```

**Verification**:
- [ ] Picker opens on tap
- [ ] Selection updates parent state
- [ ] Time formatted correctly for locale

---

### Task 3.5: Build Schedule Bottom Sheet
- **File**: `lib/features/scheduling/presentation/widgets/schedule_bottom_sheet.dart`
- **Est. Time**: 50 min
- **Dependencies**: Task 3.1, 3.2, 3.3, 3.4
- **Blocking**: Task 3.7

**Implementation**:
```dart
class ScheduleBottomSheet extends ConsumerStatefulWidget {
  final String templateId;
  final String templateName;

  static Future<bool?> show(BuildContext context, {
    required String templateId,
    required String templateName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScheduleBottomSheet(
        templateId: templateId,
        templateName: templateName,
      ),
    );
  }
}

// Contains:
// - Header: "Schedule {templateName}"
// - MultiSelectCalendar
// - ReminderTimePicker
// - Counter: "X days selected"
// - Cancel/Confirm buttons
```

**Verification**:
- [ ] Data flows correctly
- [ ] Confirm disabled until days selected
- [ ] Shows loading during submit
- [ ] Closes with success result

---

### Task 3.6: Create Scheduled Workouts List Screen
- **File**: `lib/features/scheduling/presentation/screens/scheduled_workouts_screen.dart`
- **Est. Time**: 45 min
- **Dependencies**: Task 3.1
- **Blocking**: None

**Implementation**:
- AppBar with title
- ListView of ScheduledWorkoutCard widgets
- Empty state if no schedules
- Swipe to delete / long press menu
- Group by date or by template

**Verification**:
- [ ] List updates after scheduling
- [ ] Delete removes entry
- [ ] Navigate from template card or settings

---

### Task 3.7: Add Schedule Button to Template Card
- **File**: `lib/features/workout_templates/presentation/widgets/template_card.dart` (MODIFY)
- **Est. Time**: 20 min
- **Dependencies**: Task 3.5
- **Blocking**: None

**Implementation**:
```dart
// Add to existing template card action buttons
IconButton(
  icon: Icon(AppIcons.calendarPlus, size: AppIconSize.medium),
  color: context.iconSecondary,
  onPressed: () => ScheduleBottomSheet.show(
    context,
    templateId: template.id,
    templateName: template.name,
  ),
  tooltip: context.l10n.scheduleWorkout,
)
```

**Verification**:
- [ ] Button appears on template card
- [ ] Bottom sheet receives correct template data
- [ ] Button uses AppIcons (not Icons.*)

---

### Task 3.8: Apply Theme Support
- **File**: All presentation widgets
- **Est. Time**: 25 min
- **Dependencies**: Task 3.3, 3.4, 3.5, 3.6
- **Blocking**: None

**Checklist**:
- [ ] All colors use `context.colors.*`
- [ ] All text styles use `context.textTheme.*`
- [ ] Calendar respects dark/light theme
- [ ] Test in both themes

---

### Task 3.9: Add Localizations
- **Files**:
  - `assets/i18n/app_en.arb`
  - `assets/i18n/app_it.arb`
- **Est. Time**: 20 min
- **Dependencies**: None
- **Blocking**: Task 4.3

**Keys to add**:
```json
{
  "scheduleWorkout": "Schedule",
  "scheduleWorkoutTitle": "Schedule \"{name}\"",
  "tapDaysToSelect": "Tap days to select/deselect",
  "daysSelected": "{count} {count, plural, =1{day} other{days}} selected",
  "reminderTime": "Reminder time",
  "confirmSchedule": "Confirm Schedule",
  "cancelSchedule": "Cancel",
  "workoutScheduledSuccess": "\"{name}\" scheduled for {count} days",
  "scheduledWorkouts": "Scheduled Workouts",
  "noScheduledWorkouts": "No scheduled workouts yet",
  "deleteScheduleConfirm": "Delete this scheduled workout?",
  "workoutReminderTitle": "Workout Reminder",
  "workoutReminderBody": "Time for \"{name}\"!"
}
```

**Verification**:
- [ ] All UI text uses `context.l10n.*`
- [ ] Both EN and IT translations complete
- [ ] `flutter gen-l10n` runs without errors

---

## 🧪 Testing (3 tasks)

### Task 4.1: Unit Test Repository
- **File**: `test/features/scheduling/data/repositories/scheduling_repository_test.dart`
- **Est. Time**: 45 min
- **Dependencies**: Task 2.3

**Test cases**:
- [ ] Save and retrieve workout
- [ ] Save multiple workouts
- [ ] Delete workout
- [ ] Update status
- [ ] Query by date

---

### Task 4.2: Unit Test Scheduling Provider
- **File**: `test/features/scheduling/presentation/providers/scheduling_provider_test.dart`
- **Est. Time**: 45 min
- **Dependencies**: Task 3.1

**Test cases**:
- [ ] Initial load returns empty list
- [ ] Schedule creates entries
- [ ] Delete removes entry
- [ ] State updates propagate

---

### Task 4.3: Widget Test Bottom Sheet
- **File**: `test/features/scheduling/presentation/widgets/schedule_bottom_sheet_test.dart`
- **Est. Time**: 50 min
- **Dependencies**: Task 3.5

**Test cases**:
- [ ] Calendar renders
- [ ] Tap day toggles selection
- [ ] Counter updates on selection
- [ ] Confirm disabled when no selection
- [ ] Confirm enabled when days selected

---

## ✅ Localization Verification (1 task)

### Task 4.4: Verify No Hardcoded Strings
- **Est. Time**: 15 min
- **Dependencies**: Task 3.9

**Command**:
```bash
./scripts/find_hardcoded_strings.sh lib/features/scheduling/
```

**Verification**:
- [ ] Zero hardcoded UI text found
- [ ] All Text widgets use `context.l10n.*`

---

## 📊 Dependency Graph

```
Phase 1: Domain (Parallel)
  Task 1.1 ─┬─→ Task 1.2 ──→ Task 1.3
            │
            ▼
Phase 2: Data (Sequential)
  Task 2.1 ──→ Task 2.2 ──→ Task 2.3
            │              │
            └──→ Task 2.4 ←┘
                    │
                    ▼
Phase 3: Presentation (Parallel after 2.3/2.4)
  Task 3.1 ◄─────────────────────────┐
    │                                │
    ├──→ Task 3.2                    │
    │                                │
  Task 3.3 ──┬──→ Task 3.5 ──→ Task 3.7
  Task 3.4 ──┘        │
                      ▼
              Task 3.6, 3.8
                      │
                      ▼
Phase 4: Testing & Localization
  Task 3.9 ──→ Task 4.4
  Task 2.3 ──→ Task 4.1
  Task 3.1 ──→ Task 4.2
  Task 3.5 ──→ Task 4.3
```

---

## 🚀 Quick Start

```bash
# 1. Add dependency
flutter pub add calendar_date_picker2

# 2. Create feature folder structure
mkdir -p lib/features/scheduling/{domain/{entities,repositories},data/{datasources,models,repositories,services},presentation/{providers,screens,widgets,models}}

# 3. Start with Task 1.1 (Entity)
```

---

## 📝 Notes & Decisions

- **Riverpod**: Using `Notifier` pattern (not deprecated `StateNotifier`)
- **No Use Cases**: May use repository directly in provider to reduce boilerplate
- **Hive TypeId**: Need to check `hive_registrar.g.dart` for available ID
- **Notification Integration**: Reuse existing `NotificationRepository`

---

## 📋 Implementation Order (Recommended)

**Day 1 (~4h)**:
1. Task 1.1: Entity
2. Task 1.2: Repository contract
3. Task 2.1: Hive model
4. Task 2.2: Datasource
5. Task 2.3: Repository impl

**Day 2 (~4h)**:
6. Task 3.1: Provider
7. Task 3.3: Calendar widget
8. Task 3.4: Time picker
9. Task 3.5: Bottom sheet
10. Task 3.7: Template card button

**Day 3 (~3h)**:
11. Task 2.4: Notification service
12. Task 3.6: List screen
13. Task 3.9: Localizations
14. Task 3.8: Theme verification

**Day 4 (~2h)**:
15. Task 4.1-4.3: Tests
16. Task 4.4: Hardcoded strings check
17. Final QA
