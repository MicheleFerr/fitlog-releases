import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduling_ui_state.freezed.dart';

/// UI state for the schedule bottom sheet
@freezed
abstract class ScheduleBottomSheetState with _$ScheduleBottomSheetState {

  const factory ScheduleBottomSheetState({
    /// Currently selected dates for scheduling
    @Default([]) List<DateTime> selectedDates,

    /// Hour component of reminder time
    @Default(9) int reminderHour,

    /// Minute component of reminder time
    @Default(0) int reminderMinute,

    /// Whether the form is currently submitting
    @Default(false) bool isSubmitting,

    /// Error message if submission failed
    String? errorMessage,

    /// Success message after successful scheduling
    String? successMessage,
  }) = _ScheduleBottomSheetState;
  const ScheduleBottomSheetState._();

  /// Get reminder time as TimeOfDay
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Check if any dates are selected
  bool get hasSelection => selectedDates.isNotEmpty;

  /// Get count of selected dates
  int get selectionCount => selectedDates.length;

  /// Check if form can be submitted
  bool get canSubmit => hasSelection && !isSubmitting;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Check if submission was successful
  bool get isSuccess => successMessage != null;
}

/// Extension to create a copy with TimeOfDay
extension ScheduleBottomSheetStateExtension on ScheduleBottomSheetState {
  /// Create a copy with updated reminder time
  ScheduleBottomSheetState copyWithReminderTime(TimeOfDay time) {
    return copyWith(reminderHour: time.hour, reminderMinute: time.minute);
  }

  /// Toggle a date selection
  ScheduleBottomSheetState toggleDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final currentDates = List<DateTime>.from(selectedDates);

    final existingIndex = currentDates.indexWhere(
      (d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day,
    );

    if (existingIndex >= 0) {
      currentDates.removeAt(existingIndex);
    } else {
      currentDates.add(normalizedDate);
    }

    // Sort dates chronologically
    currentDates.sort((a, b) => a.compareTo(b));

    return copyWith(selectedDates: currentDates);
  }

  /// Clear all selected dates
  ScheduleBottomSheetState clearSelection() {
    return copyWith(selectedDates: []);
  }

  /// Set submitting state
  ScheduleBottomSheetState setSubmitting(bool submitting) {
    return copyWith(isSubmitting: submitting, errorMessage: null);
  }

  /// Set error state
  ScheduleBottomSheetState setError(String message) {
    return copyWith(isSubmitting: false, errorMessage: message);
  }

  /// Set success state
  ScheduleBottomSheetState setSuccess(String message) {
    return copyWith(isSubmitting: false, successMessage: message);
  }
}
