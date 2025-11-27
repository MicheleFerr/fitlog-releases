import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget for selecting reminder time for scheduled workouts
class ReminderTimePicker extends StatelessWidget {
  /// Currently selected time
  final TimeOfDay selectedTime;

  /// Callback when time is changed
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ReminderTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        AppIcons.clock,
        color: context.iconPrimary,
      ),
      title: Text(
        context.l10n.reminderTime,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Text(
        _formatTime(context, selectedTime),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        AppIcons.chevronRight,
        color: context.iconSecondary,
      ),
      onTap: () => _showTimePicker(context),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    // Use 24h format for Italian locale
    if (Localizations.localeOf(context).languageCode == 'it') {
      return '${time.hour.toString().padLeft(2, '0')}:$minute';
    }

    return '$hour:$minute $period';
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: context.colors.surface,
              hourMinuteColor: context.colors.surfaceContainerHighest,
              dayPeriodColor: context.colors.surfaceContainerHighest,
              dialBackgroundColor: context.colors.surfaceContainerHighest,
              dialHandColor: context.colors.primary,
              entryModeIconColor: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      onTimeChanged(time);
    }
  }
}
