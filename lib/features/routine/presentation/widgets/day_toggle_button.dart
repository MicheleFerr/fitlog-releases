/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// DAY TOGGLE BUTTON WIDGET - Reusable Toggle for Weekdays
///
/// Features:
/// - Display day name (localized)
/// - Selected/unselected states
/// - Tap handler for toggle
/// - Consistent Material 3 design
/// - Supports all weekdays (Monday-Sunday)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Day Toggle Button Widget - Toggle button for selecting training days
class DayToggleButton extends StatelessWidget {
  const DayToggleButton({
    super.key,
    required this.dayNumber,
    required this.dayName,
    required this.isSelected,
    required this.onToggle,
  });

  /// Day number (1=Monday, 7=Sunday)
  final int dayNumber;

  /// Localized day name (e.g., "Monday", "Lunedì")
  final String dayName;

  /// Whether this day is currently selected
  final bool isSelected;

  /// Callback when day is toggled (selected/unselected)
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(dayName),
      selected: isSelected,
      onSelected: onToggle,
      selectedColor: context.colors.primaryContainer,
      checkmarkColor: context.colors.primary,
      backgroundColor: context.colors.surface,
      side: BorderSide(
        color: isSelected
            ? context.colors.primary
            : context.colors.outline,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: context.textTheme.bodyMedium?.copyWith(
        color: isSelected
            ? context.colors.onPrimaryContainer
            : context.colors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: true,
    );
  }
}

/// Extension to create DayToggleButton for each weekday
extension DayToggleButtonHelper on BuildContext {
  /// Get localized day name by number (1=Monday, 7=Sunday)
  String getDayName(int day) {
    switch (day) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }
}
