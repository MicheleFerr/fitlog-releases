import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Mixin for validating toggle dependencies in workout customization
///
/// Provides validation methods to ensure toggle consistency:
/// - Auto-enable master toggles when dependents are enabled
/// - Auto-disable dependent toggles when master is disabled
///
/// **Dependency Rules**:
/// 1. Enable master → show dependents (progressive disclosure)
/// 2. Disable master → auto-disable dependents (consistency)
/// 3. Try enable dependent → auto-enable master (prevent invalid state)
///
/// **Master-Dependent Relationships**:
/// - RPE Tracking (master)
///   - Auto Adjust Weight from RPE (dependent)
///   - Auto Adjust Rest from RPE (dependent)
///
/// **Example**:
/// ```dart
/// class _MyWidgetState extends ConsumerState<MyWidget>
///     with ToggleDependencyValidation {
///
///   bool _rpeTracking = false;
///   bool _autoAdjustWeight = false;
///
///   void _onDependentToggle(bool value) {
///     setState(() {
///       // Auto-enable master if needed
///       _rpeTracking = validateAndEnableMaster(
///         dependent: value,
///         master: _rpeTracking,
///         masterName: 'RPE Tracking',
///         context: context,
///       );
///       _autoAdjustWeight = value;
///     });
///   }
/// }
/// ```
mixin ToggleDependencyValidation {

  /// Validates and auto-enables master toggle if dependent is enabled
  ///
  /// Prevents invalid state where dependent feature is enabled but
  /// master is disabled. Shows informational snackbar to user.
  ///
  /// **Parameters**:
  /// - [dependent] - New state of dependent toggle
  /// - [master] - Current state of master toggle
  /// - [masterName] - Display name for snackbar message
  /// - [context] - BuildContext for localization and snackbar
  ///
  /// **Returns**: Updated master state (enabled if dependent requires it)
  ///
  /// **Example**:
  /// ```dart
  /// // User tries to enable "Auto Adjust Weight" without RPE enabled
  /// _rpeTracking = validateAndEnableMaster(
  ///   dependent: true,
  ///   master: false,
  ///   masterName: context.l10n.enableRpeTitle,
  ///   context: context,
  /// );
  /// // Result: _rpeTracking = true (auto-enabled)
  /// // Snackbar: "✅ RPE Tracking auto-enabled (required for this feature)"
  /// ```
  bool validateAndEnableMaster({
    required bool dependent,
    required bool master,
    required String masterName,
    required BuildContext context,
  }) {
    if (dependent && !master) {
      // Auto-enable master to prevent invalid state
      SnackBarService.showInfo(
        context,
        context.l10n.autoEnabledMaster(masterName),
      );
      return true; // Enable master
    }
    return master; // Keep current state
  }

  /// Auto-disables all dependents when master is disabled
  ///
  /// Ensures consistency by cascading disable from master to dependents.
  /// Shows warning snackbar with count of disabled features.
  ///
  /// **Parameters**:
  /// - [master] - New state of master toggle
  /// - [dependents] - Map of dependent toggle names to current states
  /// - [context] - BuildContext for localization and snackbar
  ///
  /// **Returns**: Updated dependents map (all false if master disabled)
  ///
  /// **Example**:
  /// ```dart
  /// // User disables RPE Tracking (master)
  /// final updatedDependents = autoDisableDependents(
  ///   master: false,
  ///   dependents: {
  ///     'autoAdjustWeightFromRpe': true,  // Was enabled
  ///     'autoAdjustRestFromRpe': true,     // Was enabled
  ///   },
  ///   context: context,
  /// );
  /// // Result: Both dependents now false
  /// // Snackbar: "⚠️ 2 dependent features auto-disabled"
  ///
  /// _autoAdjustWeightFromRpe = updatedDependents['autoAdjustWeightFromRpe']!;
  /// _autoAdjustRestFromRpe = updatedDependents['autoAdjustRestFromRpe']!;
  /// ```
  Map<String, bool> autoDisableDependents({
    required bool master,
    required Map<String, bool> dependents,
    required BuildContext context,
  }) {
    if (!master) {
      // Count how many dependents will be disabled
      final disabledCount = dependents.values.where((v) => v).length;

      if (disabledCount > 0) {
        // Show warning with count
        SnackBarService.showWarning(
          context,
          context.l10n.dependentsDisabled(disabledCount),
        );
      }

      // Disable all dependents
      return dependents.map((key, _) => MapEntry(key, false));
    }

    // Master still enabled, keep dependents as-is
    return dependents;
  }
}
