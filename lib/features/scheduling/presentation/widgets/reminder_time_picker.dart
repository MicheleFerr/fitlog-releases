import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Enum for reminder time presets
enum ReminderTimePreset {
  morning, // 8:00 - 10:00 (default: 09:00)
  afternoon, // 16:00 - 18:00 (default: 17:00)
  evening, // 20:00 - 22:00 (default: 21:00)
  custom, // User picks custom time
}

/// Extension to get TimeOfDay from preset
extension ReminderTimePresetExtension on ReminderTimePreset {
  /// Get default TimeOfDay for this preset
  TimeOfDay get defaultTime {
    switch (this) {
      case ReminderTimePreset.morning:
        return const TimeOfDay(hour: 9, minute: 0);
      case ReminderTimePreset.afternoon:
        return const TimeOfDay(hour: 17, minute: 0);
      case ReminderTimePreset.evening:
        return const TimeOfDay(hour: 21, minute: 0);
      case ReminderTimePreset.custom:
        return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  /// Get icon for this preset
  IconData get icon {
    switch (this) {
      case ReminderTimePreset.morning:
        return AppIcons.wbSunny;
      case ReminderTimePreset.afternoon:
        return AppIcons.wbTwilight;
      case ReminderTimePreset.evening:
        return AppIcons.nightsStay;
      case ReminderTimePreset.custom:
        return AppIcons.schedule;
    }
  }
}

/// Widget for selecting reminder time for scheduled workouts
///
/// Features:
/// - 3 preset time slots: Morning (8-10), Afternoon (16-18), Evening (20-22)
/// - Custom option with time picker
/// - Visual feedback with icons and colors
class ReminderTimePicker extends StatefulWidget {
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
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  ReminderTimePreset _selectedPreset = ReminderTimePreset.morning;
  TimeOfDay? _customTime;

  @override
  void initState() {
    super.initState();
    _detectPresetFromTime(widget.selectedTime);
  }

  /// Detect which preset matches the current time
  void _detectPresetFromTime(TimeOfDay time) {
    final hour = time.hour;

    if (hour >= 8 && hour < 10) {
      _selectedPreset = ReminderTimePreset.morning;
    } else if (hour >= 16 && hour < 18) {
      _selectedPreset = ReminderTimePreset.afternoon;
    } else if (hour >= 20 && hour < 22) {
      _selectedPreset = ReminderTimePreset.evening;
    } else {
      _selectedPreset = ReminderTimePreset.custom;
      _customTime = time;
    }
  }

  void _onPresetSelected(ReminderTimePreset preset) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedPreset = preset;
    });

    if (preset == ReminderTimePreset.custom) {
      _showTimePicker();
    } else {
      widget.onTimeChanged(preset.defaultTime);
    }
  }

  Future<void> _showTimePicker() async {
    final initialTime = _customTime ?? const TimeOfDay(hour: 12, minute: 0);

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
      setState(() {
        _customTime = time;
        _selectedPreset = ReminderTimePreset.custom;
      });
      widget.onTimeChanged(time);
    }
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

  String _getPresetLabel(BuildContext context, ReminderTimePreset preset) {
    switch (preset) {
      case ReminderTimePreset.morning:
        return context.l10n.reminderTimePresetMorning;
      case ReminderTimePreset.afternoon:
        return context.l10n.reminderTimePresetAfternoon;
      case ReminderTimePreset.evening:
        return context.l10n.reminderTimePresetEvening;
      case ReminderTimePreset.custom:
        return context.l10n.reminderTimePresetCustom;
    }
  }

  String _getPresetSubtitle(BuildContext context, ReminderTimePreset preset) {
    switch (preset) {
      case ReminderTimePreset.morning:
        return context.l10n.reminderTimePresetMorningRange;
      case ReminderTimePreset.afternoon:
        return context.l10n.reminderTimePresetAfternoonRange;
      case ReminderTimePreset.evening:
        return context.l10n.reminderTimePresetEveningRange;
      case ReminderTimePreset.custom:
        if (_customTime != null) {
          return _formatTime(context, _customTime!);
        }
        return '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.notifications,
                color: context.iconPrimary,
                size: AppIconSize.medium,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.reminderTime,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Preset chips in a wrap
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ReminderTimePreset.values.map((preset) {
              final isSelected = _selectedPreset == preset;

              return _PresetChip(
                preset: preset,
                label: _getPresetLabel(context, preset),
                subtitle: _getPresetSubtitle(context, preset),
                isSelected: isSelected,
                onTap: () => _onPresetSelected(preset),
              );
            }).toList(),
          ),

          // Show current selection summary
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.alarmOn,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _selectedPreset == ReminderTimePreset.custom && _customTime != null
                        ? _formatTime(context, _customTime!)
                        : _formatTime(context, _selectedPreset.defaultTime),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_selectedPreset == ReminderTimePreset.custom)
                  IconButton(
                    icon: Icon(
                      AppIcons.edit,
                      color: context.colors.primary,
                      size: AppIconSize.small,
                    ),
                    onPressed: _showTimePicker,
                    tooltip: context.l10n.reminderTimePresetCustom,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual preset chip widget
class _PresetChip extends StatelessWidget {
  final ReminderTimePreset preset;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                preset.icon,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                size: AppIconSize.medium,
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? context.colors.onPrimaryContainer.withValues(alpha: 0.8)
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  AppIcons.checkCircle,
                  color: context.colors.primary,
                  size: AppIconSize.small,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
