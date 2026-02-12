/// Workout Customization Modal V5 - Simplified
///
/// Streamlined modal with clear organization:
/// - Tracciamento: RPE system with sub-options (collapsible)
/// - Aspetto: Visual customization (collapsible)
///
/// Note: Core behavior settings (auto rest timer, auto collapse, sound, custom timers)
/// are always enabled and not configurable by the user.
library;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/interface_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Simplified Workout Customization Modal
class WorkoutCustomizationModalV3 extends ConsumerStatefulWidget {
  const WorkoutCustomizationModalV3({super.key});

  static Future<void> show(BuildContext context) {
    return ModalService.showSheet(context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => const WorkoutCustomizationModalV3(),
    );
  }

  @override
  ConsumerState<WorkoutCustomizationModalV3> createState() =>
      _WorkoutCustomizationModalV3State();
}

class _WorkoutCustomizationModalV3State
    extends ConsumerState<WorkoutCustomizationModalV3> {
  // === TRACCIAMENTO ===
  late bool _rpeTracking;
  late bool _autoAdjustWeightFromRpe;
  late bool _autoAdjustRestFromRpe;
  late bool _setDurationTracking;

  // === ASPETTO (from ExerciseCardSettings - single source of truth) ===
  late bool _showInsight;
  late bool _showTimer;
  late bool _showPlates;
  late bool _showRpe;
  late InterfaceSize _interfaceSize;

  // ✅ Initial values for change tracking (feedback on close)
  late bool _initialRpeTracking;
  late bool _initialAutoAdjustWeightFromRpe;
  late bool _initialAutoAdjustRestFromRpe;
  late bool _initialSetDurationTracking;
  late bool _initialShowInsight;
  late bool _initialShowTimer;
  late bool _initialShowPlates;
  late bool _initialShowRpe;
  late InterfaceSize _initialInterfaceSize;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);
    final cardSettings = ref.read(exerciseCardSettingsProvider);

    // Tracciamento
    _rpeTracking = config.rpeTracking ?? false;
    _autoAdjustWeightFromRpe = config.autoAdjustWeightFromRpe ?? false;
    _autoAdjustRestFromRpe = config.autoAdjustRestFromRpe ?? false;
    _setDurationTracking = config.setDurationTracking ?? false;

    // Aspetto - reads from ExerciseCardSettings (single source of truth)
    _showInsight = cardSettings.showInsight;
    _showTimer = cardSettings.showTimer;
    _showPlates = cardSettings.showPlates;
    _showRpe = cardSettings.showRpe;
    _interfaceSize =
        config.interfaceSize ?? InterfaceSize.fromFontSize(config.fontSize);

    // ✅ Store initial values for change tracking
    _initialRpeTracking = _rpeTracking;
    _initialAutoAdjustWeightFromRpe = _autoAdjustWeightFromRpe;
    _initialAutoAdjustRestFromRpe = _autoAdjustRestFromRpe;
    _initialSetDurationTracking = _setDurationTracking;
    _initialShowInsight = _showInsight;
    _initialShowTimer = _showTimer;
    _initialShowPlates = _showPlates;
    _initialShowRpe = _showRpe;
    _initialInterfaceSize = _interfaceSize;
  }

  /// ✅ Calculate number of changes made in this session
  int _countChanges() {
    int changes = 0;
    if (_rpeTracking != _initialRpeTracking) changes++;
    if (_autoAdjustWeightFromRpe != _initialAutoAdjustWeightFromRpe) changes++;
    if (_autoAdjustRestFromRpe != _initialAutoAdjustRestFromRpe) changes++;
    if (_setDurationTracking != _initialSetDurationTracking) changes++;
    if (_showInsight != _initialShowInsight) changes++;
    if (_showTimer != _initialShowTimer) changes++;
    if (_showPlates != _initialShowPlates) changes++;
    if (_showRpe != _initialShowRpe) changes++;
    if (_interfaceSize != _initialInterfaceSize) changes++;
    return changes;
  }

  /// ✅ Handle modal close - show feedback toast
  void _handleClose(BuildContext context) {
    final changes = _countChanges();
    if (changes > 0) {
      // Show toast with number of changes
      final message = changes == 1
          ? context.l10n.settingsChangedSingular
          : context.l10n.settingsChangedPlural(changes);
      SnackBarService.showInfo(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleClose(context);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.tune,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.customizeWorkout,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),

                    // === TRACCIAMENTO AVANZATO ===
                    _buildExpandableSection(
                      context,
                      icon: AppIcons.speed,
                      title: context.l10n.advancedTrackingTitle,
                      subtitle: context.l10n.advancedTrackingSubtitle,
                      color: context.colors.tertiary,
                      initiallyExpanded: _rpeTracking,
                      children: [
                        _buildToggleRow(
                          context,
                          icon: AppIcons.speed,
                          title: context.l10n.rpeTitle,
                          subtitle: context.l10n.rpeSubtitle,
                          value: _rpeTracking,
                          onChanged: (v) {
                            setState(() {
                              _rpeTracking = v;
                              if (!v) {
                                _autoAdjustWeightFromRpe = false;
                                _autoAdjustRestFromRpe = false;
                              }
                            });
                            _saveAll();
                          },
                        ),
                        // Sub-options (only visible when RPE is ON)
                        if (_rpeTracking) ...[
                          _buildDivider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _buildToggleRow(
                              context,
                              icon: AppIcons.workout,
                              title: context.l10n.suggestWeightTitle,
                              subtitle: context.l10n.suggestWeightSubtitle,
                              value: _autoAdjustWeightFromRpe,
                              onChanged: (v) {
                                setState(() => _autoAdjustWeightFromRpe = v);
                                _saveAll();
                              },
                              compact: true,
                            ),
                          ),
                          _buildDivider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _buildToggleRow(
                              context,
                              icon: AppIcons.timer,
                              title: context.l10n.adjustRestTitle,
                              subtitle: context.l10n.adjustRestSubtitle,
                              value: _autoAdjustRestFromRpe,
                              onChanged: (v) {
                                setState(() => _autoAdjustRestFromRpe = v);
                                _saveAll();
                              },
                              compact: true,
                            ),
                          ),
                        ],
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.schedule,
                          title: context.l10n.setDurationTitle,
                          subtitle: context.l10n.setDurationSubtitle,
                          value: _setDurationTracking,
                          onChanged: (v) {
                            setState(() => _setDurationTracking = v);
                            _saveAll();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // === ASPETTO (unified with ExerciseCardSettings) ===
                    _buildExpandableSection(
                      context,
                      icon: AppIcons.colorLens,
                      title: context.l10n.appearanceSection,
                      subtitle: context.l10n.appearanceSubtitle,
                      color: context.colors.secondary,
                      initiallyExpanded: false,
                      children: [
                        _buildToggleRow(
                          context,
                          icon: AppIcons.insights,
                          title: context.l10n.showInsight,
                          subtitle: context.l10n.showInsightDescription,
                          value: _showInsight,
                          onChanged: (v) {
                            setState(() => _showInsight = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.timer,
                          title: context.l10n.showTimer,
                          subtitle: context.l10n.showTimerDescription,
                          value: _showTimer,
                          onChanged: (v) {
                            setState(() => _showTimer = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.calculateRounded,
                          title: context.l10n.showPlates,
                          subtitle: context.l10n.showPlatesDescription,
                          value: _showPlates,
                          onChanged: (v) {
                            setState(() => _showPlates = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.speed,
                          title: context.l10n.showRpe,
                          subtitle: context.l10n.showRpeDescription,
                          value: _showRpe,
                          onChanged: (v) {
                            setState(() => _showRpe = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildInterfaceSizeSelector(context),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.changesAutoSaved,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === BUILDERS ===

  Widget _buildExpandableSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool initiallyExpanded,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: theme.colorScheme.surface.withValues(alpha: 0),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool compact = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: compact ? 18 : 22,
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      (compact
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.bodyLarge)
                          ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CNSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  /// Interface Size Selector (unified font + layout)
  /// Replaces separate Font Size + Set Row Size controls
  Widget _buildInterfaceSizeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(AppIcons.formatSize, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.interfaceSize,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  context.l10n.interfaceSizeSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<InterfaceSize>(
                  segments: [
                    ButtonSegment(
                      value: InterfaceSize.extraSmall,
                      label: Text(context.l10n.settingsFontSizeExtraSmall),
                    ),
                    ButtonSegment(
                      value: InterfaceSize.small,
                      label: Text(context.l10n.settingsFontSizeSmall),
                    ),
                    ButtonSegment(
                      value: InterfaceSize.medium,
                      label: Text(context.l10n.settingsFontSizeNormal),
                    ),
                    ButtonSegment(
                      value: InterfaceSize.mediumLarge,
                      label: Text(context.l10n.settingsFontSizeMediumLarge),
                    ),
                    ButtonSegment(
                      value: InterfaceSize.large,
                      label: Text(context.l10n.settingsFontSizeLarge),
                    ),
                  ],
                  selected: {_interfaceSize},
                  onSelectionChanged: (selected) {
                    HapticFeedback.selectionClick();
                    final newSize = selected.first;
                    setState(() => _interfaceSize = newSize);

                    // Save interface size - SetDisplayMode will automatically
                    // derive from the new InterfaceSize.setRowMode
                    ref
                        .read(appConfigProvider.notifier)
                        .setInterfaceSize(newSize);
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  // === SAVE ===

  void _saveAll() {
    // Save workout/tracking settings to AppConfig
    ref
        .read(appConfigProvider.notifier)
        .updateWorkoutSettings(
          autoRestTimer: true, // Always enabled
          autoCollapseCompleted: true, // Always enabled
          rpeTracking: _rpeTracking,
          autoAdjustWeightFromRpe: _autoAdjustWeightFromRpe,
          autoAdjustRestFromRpe: _autoAdjustRestFromRpe,
          setDurationTracking: _setDurationTracking,
        );

    // Save appearance settings to ExerciseCardSettings (single source of truth)
    final notifier = ref.read(exerciseCardSettingsProvider.notifier);
    notifier.setShowInsight(_showInsight);
    notifier.setShowTimer(_showTimer);
    notifier.setShowPlates(_showPlates);
    notifier.setShowRpe(_showRpe);

    // Sound is always enabled (hardcoded)
    ref.read(appConfigProvider.notifier).setSoundEnabled(true);
  }
}

