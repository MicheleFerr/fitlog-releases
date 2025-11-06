/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/dialogs
/// 🎯 Feature: flexible_routine
/// 🔧 Type: dialog
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// RECOVERY PICKER DIALOG - Dialog for selecting recovery date
///
/// Features:
/// - Calendar picker for recovery date
/// - Validation (not in past, not on occupied day)
/// - Schedule preview
/// - Suggested recovery dates
library;

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Dialog for selecting recovery date for a skipped workout
class RecoveryPickerDialog extends StatefulWidget {

  const RecoveryPickerDialog({
    super.key,
    required this.originalDate,
    required this.routine,
  });
  final DateTime originalDate;
  final FlexibleRoutine routine;

  /// Show the dialog and return selected date or null if cancelled
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime originalDate,
    required FlexibleRoutine routine,
  }) async {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => RecoveryPickerDialog(
        originalDate: originalDate,
        routine: routine,
      ),
    );
  }

  @override
  State<RecoveryPickerDialog> createState() => _RecoveryPickerDialogState();
}

class _RecoveryPickerDialogState extends State<RecoveryPickerDialog> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recover Workout',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'From ${_formatDate(widget.originalDate)}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Info message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.colors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select a future date to make up for this missed workout. Choose a rest day or add an extra session.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Suggested dates section
              _buildSuggestedDates(),

              SizedBox(height: 20),

              // Calendar
              Text(
                'Or pick a date',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(height: 12),

              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: widget.routine.endDate,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day);
                    },
                  ),
                ),
              ),

              // Validation error
              if (_validationError != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.error,
                        color: context.colors.error,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Impact preview
              if (_selectedDay != null && _validationError == null)
                _buildImpactPreview(),

              SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: context.colors.onSurface),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_selectedDay == null || _validationError != null)
                        ? null
                        : _confirmRecovery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Recover Workout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedDates() {
    final suggestedDates = _getSuggestedRecoveryDates();

    if (suggestedDates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested dates',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedDates.map((date) {
            final isSelected = _selectedDay != null && isSameDay(_selectedDay!, date);
            return InkWell(
              onTap: () => _onDaySelected(date, date),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.calendar,
                      size: 16,
                      color: isSelected ? context.colors.surface : context.colors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _formatDateShort(date),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? context.colors.surface : context.colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(Rest day)',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? context.colors.surface.withValues(alpha: 0.8)
                            : context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime day) {
    final dayInfo = widget.routine.getDayInfo(day);
    final isRestDay = dayInfo?.status == DayStatus.rest;
    final isOccupied = dayInfo != null && dayInfo.status != DayStatus.rest;

    Color? backgroundColor;
    if (isRestDay) {
      backgroundColor = context.colors.success.withValues(alpha: 0.2);
    } else if (isOccupied) {
      backgroundColor = context.colors.error.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: isOccupied
                ? context.colors.onSurface.withValues(alpha: 0.3)
                : context.colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildImpactPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.completeOutline,
                color: context.colors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Recovery impact',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildImpactRow(
            icon: AppIcons.trendUp,
            label: 'Adherence Rate',
            value: 'Will improve',
            isPositive: true,
          ),
          const SizedBox(height: 8),
          _buildImpactRow(
            icon: AppIcons.eventAvailable,
            label: 'Recovery Date',
            value: _formatDate(_selectedDay!),
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPositive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        if (isPositive)
          Icon(
            AppIcons.arrowUpward,
            size: 14,
            color: context.colors.primary,
          ),
        SizedBox(width: 4),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }

  List<DateTime> _getSuggestedRecoveryDates() {
    final now = DateTime.now();
    final suggestions = <DateTime>[];

    // Find next 3 rest days
    for (int i = 1; i <= 30 && suggestions.length < 3; i++) {
      final date = now.add(Duration(days: i));
      if (date.isAfter(widget.routine.endDate)) break;

      final dayInfo = widget.routine.getDayInfo(date);
      if (dayInfo?.status == DayStatus.rest) {
        suggestions.add(date);
      }
    }

    return suggestions;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _validationError = _validateDate(selectedDay);
    });
  }

  String? _validateDate(DateTime date) {
    // Check if date is in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(today)) {
      return 'Cannot recover in the past';
    }

    // Check if date is within routine range
    if (date.isAfter(widget.routine.endDate)) {
      return 'Date is after routine ends';
    }

    // Check if date is already occupied by a workout
    final dayInfo = widget.routine.getDayInfo(date);
    if (dayInfo != null && dayInfo.status != DayStatus.rest) {
      return 'This day already has a workout scheduled';
    }

    return null;
  }

  void _confirmRecovery() {
    if (_selectedDay == null || _validationError != null) return;
    Navigator.of(context).pop(_selectedDay);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
