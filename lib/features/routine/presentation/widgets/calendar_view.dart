/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// CALENDAR VIEW - Monthly calendar showing routine schedule
///
/// Features:
/// - Month view with day status colors
/// - Tap to see day details
/// - Legend for status colors
library;

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Calendar widget for routine schedule
class CalendarView extends StatefulWidget {

  const CalendarView({
    super.key,
    required this.routine,
    required this.onDayTap,
  });
  final FlexibleRoutine routine;
  final Function(DateTime) onDayTap;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.calendar,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Schedule',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calendar
          TableCalendar(
            firstDay: widget.routine.startDate,
            lastDay: widget.routine.endDate,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDayTap(selectedDay);
            },
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
                return _buildDayCell(context, day, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(context, day, true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(context, day, false, isToday: true);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    bool isSelected, {
    bool isToday = false,
  }) {
    final dayInfo = widget.routine.getDayInfo(day);
    if (dayInfo == null) {
      return Center(
        child: Text(
          '${day.day}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    Color? backgroundColor;
    Color? textColor;

    switch (dayInfo.status) {
      case DayStatus.completed:
        backgroundColor = context.colors.success.withValues(alpha: 0.2);
        textColor = context.colors.success.withValues(red: context.colors.success.r * 0.7, green: context.colors.success.g * 0.7, blue: context.colors.success.b * 0.7);
        break;
      case DayStatus.skipped:
        backgroundColor = context.colors.error.withValues(alpha: 0.2);
        textColor = context.colors.error;
        break;
      case DayStatus.recovered:
        backgroundColor = context.colors.primary.withValues(alpha: 0.2);
        textColor = context.colors.primary.withValues(red: context.colors.primary.r * 0.7, green: context.colors.primary.g * 0.7, blue: context.colors.primary.b * 0.7);
        break;
      case DayStatus.rest:
        backgroundColor = context.colors.secondary.withValues(alpha: 0.2);
        textColor = context.colors.secondary;
        break;
      case DayStatus.scheduled:
        backgroundColor = context.colors.primaryContainer.withValues(alpha: 0.3);
        textColor = context.colors.primary;
        break;
    }

    if (isSelected) {
      backgroundColor = context.colors.primary;
      textColor = context.colors.onPrimary;
    } else if (isToday) {
      backgroundColor = context.colors.primary.withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(
                color: context.colors.primary,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final legendItems = [
      (context.colors.success, 'Completed'),
      (context.colors.primary, 'Scheduled'),
      (context.colors.error, 'Skipped'),
      (context.colors.secondary, 'Rest'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: legendItems.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.$1.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: item.$1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.$2,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
