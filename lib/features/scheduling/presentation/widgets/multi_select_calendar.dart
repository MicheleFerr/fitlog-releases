import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Multi-select calendar widget for scheduling workouts
class MultiSelectCalendar extends StatelessWidget {
  /// Currently selected dates
  final List<DateTime> selectedDates;

  /// Callback when selection changes
  final ValueChanged<List<DateTime>> onSelectionChanged;

  /// Dates that are disabled (e.g., already scheduled)
  final List<DateTime>? disabledDates;

  /// Minimum selectable date (defaults to today)
  final DateTime? minDate;

  /// Maximum selectable date (defaults to 90 days from now)
  final DateTime? maxDate;

  const MultiSelectCalendar({
    super.key,
    required this.selectedDates,
    required this.onSelectionChanged,
    this.disabledDates,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMinDate = minDate ?? DateTime.now();
    final effectiveMaxDate =
        maxDate ?? DateTime.now().add(const Duration(days: 90));

    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        calendarType: CalendarDatePicker2Type.multi,
        selectedDayHighlightColor: context.colors.primary,
        selectedDayTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        todayTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onSurface,
        ),
        weekdayLabelTextStyle: context.textTheme.labelMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        controlsTextStyle: context.textTheme.titleMedium?.copyWith(
          color: context.colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        lastMonthIcon: Icon(
          AppIcons.chevronLeft,
          color: context.colors.onSurface,
        ),
        nextMonthIcon: Icon(
          AppIcons.chevronRight,
          color: context.colors.onSurface,
        ),
        disabledDayTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.3),
        ),
        disableModePicker: true,
        firstDate: effectiveMinDate,
        lastDate: effectiveMaxDate,
        selectableDayPredicate: (date) => _isDateSelectable(date),
        dayBorderRadius: BorderRadius.circular(8),
        yearBorderRadius: BorderRadius.circular(8),
        weekdayLabels: _getWeekdayLabels(context),
        firstDayOfWeek: 1, // Monday
      ),
      value: selectedDates,
      onValueChanged: (dates) {
        final validDates = dates
            .whereType<DateTime>()
            .map((d) => DateTime(d.year, d.month, d.day))
            .toList();
        onSelectionChanged(validDates);
      },
    );
  }

  bool _isDateSelectable(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    // Can't select past dates
    if (normalizedDate.isBefore(normalizedToday)) {
      return false;
    }

    // Check if date is in disabled list
    if (disabledDates != null) {
      for (final disabled in disabledDates!) {
        final normalizedDisabled = DateTime(
          disabled.year,
          disabled.month,
          disabled.day,
        );
        if (normalizedDate.isAtSameMomentAs(normalizedDisabled)) {
          return false;
        }
      }
    }

    return true;
  }

  List<String> _getWeekdayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'it') {
      return ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    }

    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }
}
