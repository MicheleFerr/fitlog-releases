// ✅ V4: dart:async import removed (no Timer usage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/toggle_dependency_validation.dart';

/// 🚀 Workout Customization Modal V3 - Enhanced with separate toggles and validation
///
/// **Key Improvements over V2**:
/// - ✅ Separate toggles for granular control (3 icons + 2 details)
/// - ✅ Dependency validation (auto-enable/disable cascade)
/// - ✅ Safe mode switch with confirmation + undo (Phase 3 Day 2)
class WorkoutCustomizationModalV3 extends ConsumerStatefulWidget {
  const WorkoutCustomizationModalV3({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkoutCustomizationModalV3(),
    );
  }

  @override
  ConsumerState<WorkoutCustomizationModalV3> createState() => _WorkoutCustomizationModalV3State();
}

class _WorkoutCustomizationModalV3State extends ConsumerState<WorkoutCustomizationModalV3>
    with ToggleDependencyValidation {
  // Core features
  late bool _autoRestTimer;
  late bool _warmupSuggestions;
  late bool _autoCollapseCompleted;

  // APRE Auto-regulation settings
  late bool _enableApre;
  late int _defaultApreProtocol;
  late bool _autoAdjustRestTimeApre;

  // RPE Auto-regulation settings
  late bool _rpeTracking;
  late bool _autoAdjustWeightFromRpe;
  late bool _autoAdjustRestFromRpe;

  // Information & Insights - ✅ V3: SEPARATE toggles (was combined in V2)
  late bool _showExerciseNotes; // Separate toggle for notes
  late bool _showExerciseInsights; // Separate toggle for insights/charts
  late bool _showCommunitySuggestions;
  late bool _showTutInfo;

  // Quick Access Icons - ✅ V3: 3 SEPARATE toggles (was 1 combined in V2)
  late bool _showQuickInfoIcon; // Separate toggle for info icon
  late bool _showWarmupIcon; // Separate toggle for warmup icon
  late bool _showPreventionIcon; // Separate toggle for prevention icon

  // Interface & Performance
  late bool _showAdvancedMenu;
  late bool _showCustomTimers;
  late bool _showCollapseCountdown;
  late bool _simplifiedAnimations;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);

    // ✅ V4: Universal smart defaults (no Pro/Base mode)
    // Core features
    _autoRestTimer = config.autoRestTimer ?? true; // Default ON
    _warmupSuggestions = config.warmupSuggestions ?? true; // Default ON (changed from false)
    _autoCollapseCompleted = config.autoCollapseCompleted ?? false;

    // APRE settings
    _enableApre = config.enableApre ?? false;
    _defaultApreProtocol = config.defaultApreProtocol ?? 6;
    _autoAdjustRestTimeApre = config.autoAdjustRestTime ?? true;

    // RPE settings - V4: Default OFF (beginner-friendly)
    _rpeTracking = config.rpeTracking ?? false; // Changed from true to false
    _autoAdjustWeightFromRpe = config.autoAdjustWeightFromRpe ?? false;
    _autoAdjustRestFromRpe = config.autoAdjustRestFromRpe ?? false;

    // Information - ✅ V3: SEPARATE initialization (was combined in V2)
    _showExerciseNotes = config.showExerciseNotes ?? false;
    _showExerciseInsights = config.showExerciseInsights ?? false;
    _showCommunitySuggestions = config.showCommunitySuggestions ?? false;
    _showTutInfo = config.showTutInfo ?? false;

    // Quick Access Icons - ✅ V3: 3 SEPARATE initializations (was 1 combined in V2)
    _showQuickInfoIcon = config.showQuickInfoIcon ?? false;
    _showWarmupIcon = config.showWarmupIcon ?? false;
    _showPreventionIcon = config.showPreventionIcon ?? false;

    // Interface
    _showAdvancedMenu = config.showAdvancedMenu ?? false;
    _showCustomTimers = config.showCustomTimers ?? false;
    _showCollapseCountdown = config.showCollapseCountdown ?? false;
    _simplifiedAnimations = config.simplifiedAnimations ?? true;
  }

  // ✅ V4: No dispose needed (removed _undoTimer)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tune,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.customizeWorkout,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.customizeWorkoutSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ V4: Mode toggle removed (no Pro/Base mode)

            // Scrollable Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ✅ V4: Essentials Section (3 core toggles, always visible)
                  _buildEssentialsSection(theme, l10n),

                  const SizedBox(height: 24),

                  // ✅ V4: Advanced Section (collapsible with 3 subcategories)
                  _buildAdvancedSection(theme, l10n),

                  const SizedBox(height: 24),


                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settingsAutoSaved,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ V4: _buildModeToggleSection and _buildModeButton removed (no Pro/Base mode)

  /// ✅ V4 Phase 3: Smart dependency dialog
  /// Shows clear dialog when enabling dependent feature without master enabled
  /// Returns true if user confirmed to enable master, false to cancel
  Future<bool> _showDependencyDialog({
    required BuildContext context,
    required String dependentName,
    required String masterName,
  }) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attentionRequired),
        content: Text(
          'Per utilizzare "$dependentName", devi prima abilitare "$masterName".\n\nAbilitare "$masterName" ora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(l10n.enable),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSubsectionHeader(ThemeData theme, AppLocalizations l10n, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tooltip,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: value
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.help_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showTooltip(context, title, tooltip),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '',
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildApreSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildToggleCard(
          theme,
          l10n,
          icon: Icons.fitness_center,
          iconColor: context.colors.tertiary,
          title: l10n.enableApreTitle,
          subtitle: l10n.enableApreDescription,
          tooltip: l10n.enableApreTooltip,
          value: _enableApre,
          onChanged: (value) {
            setState(() {
              _enableApre = value;

              // ✅ VALIDATION: Auto-disable dependents when master disabled
              if (!value) {
                final dependents = autoDisableDependents(
                  master: value,
                  dependents: {
                    'autoAdjustRestTimeApre': _autoAdjustRestTimeApre,
                  },
                  context: context,
                );

                _autoAdjustRestTimeApre = dependents['autoAdjustRestTimeApre']!;
              }
            });
            _saveSettings();
          },
        ),
        if (_enableApre) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.apreProtocolTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment<int>(
                      value: 3,
                      label: Text(l10n.apre3),
                      icon: const Icon(Icons.looks_3, size: 20),
                    ),
                    ButtonSegment<int>(
                      value: 6,
                      label: Text(l10n.apre6),
                      icon: const Icon(Icons.looks_6, size: 20),
                    ),
                    ButtonSegment<int>(
                      value: 10,
                      label: Text(l10n.apre10),
                      icon: const Icon(Icons.filter_9_plus, size: 20),
                    ),
                  ],
                  selected: {_defaultApreProtocol},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _defaultApreProtocol = newSelection.first;
                    });
                    _saveSettings();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _getApreProtocolDescription(_defaultApreProtocol, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: context.colors.tertiary.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustRestApreTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustRestApreDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustRestApreTitle,
                        l10n.autoAdjustRestApreTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustRestTimeApre,
                      onChanged: (value) {
                        setState(() {
                          // ✅ VALIDATION: Auto-enable master if dependent enabled
                          _enableApre = validateAndEnableMaster(
                            dependent: value,
                            master: _enableApre,
                            masterName: l10n.enableApreTitle,
                            context: context,
                          );
                          _autoAdjustRestTimeApre = value;
                        });
                        _saveSettings();
                      },
                      activeThumbColor: context.colors.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRpeSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildToggleCard(
          theme,
          l10n,
          icon: Icons.speed,
          iconColor: context.colors.secondary,
          title: l10n.enableRpeTitle,
          subtitle: l10n.enableRpeDescription,
          tooltip: l10n.enableRpeTooltip,
          value: _rpeTracking,
          onChanged: (value) {
            setState(() {
              _rpeTracking = value;

              // ✅ VALIDATION: Auto-disable dependents when master disabled
              if (!value) {
                final dependents = autoDisableDependents(
                  master: value,
                  dependents: {
                    'autoAdjustWeightFromRpe': _autoAdjustWeightFromRpe,
                    'autoAdjustRestFromRpe': _autoAdjustRestFromRpe,
                  },
                  context: context,
                );

                _autoAdjustWeightFromRpe = dependents['autoAdjustWeightFromRpe']!;
                _autoAdjustRestFromRpe = dependents['autoAdjustRestFromRpe']!;
              }
            });
            _saveSettings();
          },
        ),
        if (_rpeTracking) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustWeightRpeTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustWeightRpeDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustWeightRpeTitle,
                        l10n.autoAdjustWeightRpeTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustWeightFromRpe,
                      onChanged: (value) {
                        setState(() {
                          // ✅ VALIDATION: Auto-enable master if dependent enabled
                          _rpeTracking = validateAndEnableMaster(
                            dependent: value,
                            master: _rpeTracking,
                            masterName: l10n.enableRpeTitle,
                            context: context,
                          );
                          _autoAdjustWeightFromRpe = value;
                        });
                        _saveSettings();
                      },
                      activeThumbColor: context.colors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: context.colors.secondary.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustRestRpeTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustRestRpeDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustRestRpeTitle,
                        l10n.autoAdjustRestRpeTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustRestFromRpe,
                      onChanged: (value) {
                        setState(() {
                          // ✅ VALIDATION: Auto-enable master if dependent enabled
                          _rpeTracking = validateAndEnableMaster(
                            dependent: value,
                            master: _rpeTracking,
                            masterName: l10n.enableRpeTitle,
                            context: context,
                          );
                          _autoAdjustRestFromRpe = value;
                        });
                        _saveSettings();
                      },
                      activeThumbColor: context.colors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showTooltip(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).gotIt),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ V4: _setMode removed (no Pro/Base mode)

  // ✅ V4: _hasCustomSettings removed (no Pro/Base mode)

  // ✅ V4: _captureCurrentConfig removed (no undo system)

  // ✅ V4: _setModeSafe removed (no Pro/Base mode)

  // ✅ V4: _showUndoSnackBar removed (no undo system)

  // ✅ V4: _undoModeSwitch removed (no undo system)

  /// ✅ V4: Essentials Section - 3 core toggles always visible
  Widget _buildEssentialsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Row(
          children: [
            Icon(Icons.star, color: context.colors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.essentialsSection,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.essentialsSectionDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Toggle 1: Auto Rest Timer (Default ON)
        _buildToggleCard(
          theme,
          l10n,
          icon: Icons.timer,
          iconColor: context.colors.primary,
          title: l10n.autoRestTimerTitle,
          subtitle: l10n.autoRestTimerDescription,
          tooltip: l10n.autoRestTimerTooltip,
          value: _autoRestTimer,
          onChanged: (value) {
            setState(() => _autoRestTimer = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 8),

        // Toggle 2: Warmup Suggestions (Default ON)
        _buildToggleCard(
          theme,
          l10n,
          icon: Icons.whatshot,
          iconColor: context.colors.secondary,
          title: l10n.warmupSuggestionsTitle,
          subtitle: l10n.warmupSuggestionsDescription,
          tooltip: l10n.warmupSuggestionsTooltip,
          value: _warmupSuggestions,
          onChanged: (value) {
            setState(() => _warmupSuggestions = value);
            _saveSettings();
          },
        ),
        const SizedBox(height: 8),

        // Toggle 3: RPE Tracking (Default OFF - moved from Auto-Regulation)
        _buildToggleCard(
          theme,
          l10n,
          icon: Icons.fitness_center,
          iconColor: context.colors.tertiary,
          title: l10n.enableRpeTitle,
          subtitle: l10n.enableRpeDescription,
          tooltip: l10n.enableRpeTooltip,
          value: _rpeTracking,
          onChanged: (value) {
            setState(() {
              _rpeTracking = value;
              // ✅ V4 Phase 3: Auto-disable dependents when master disabled (no dialog needed)
              if (!value) {
                _autoAdjustWeightFromRpe = false;
                _autoAdjustRestFromRpe = false;
              }
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  /// ✅ V4: Advanced Section - Collapsible with 3 subcategories
  Widget _buildAdvancedSection(ThemeData theme, AppLocalizations l10n) {
    return ExpansionTile(
      leading: Icon(Icons.settings, color: context.colors.tertiary),
      title: Text(
        l10n.advancedSection,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        l10n.advancedSectionDesc,
        style: theme.textTheme.bodySmall,
      ),
      initiallyExpanded: false, // Collapsed by default
      children: [
        const SizedBox(height: 12),

        // Subcategory 1: Visualizzazione
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.visualizationCategory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),

              // Exercise Notes
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.note_alt,
                iconColor: context.colors.warning,
                title: l10n.exerciseNotesTitle,
                subtitle: l10n.exerciseNotesDescription,
                tooltip: l10n.exerciseNotesTooltip,
                value: _showExerciseNotes,
                onChanged: (value) {
                  setState(() => _showExerciseNotes = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Exercise Insights
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.insights,
                iconColor: context.colors.secondary,
                title: l10n.exerciseInsightsTitle,
                subtitle: l10n.exerciseInsightsDescription,
                tooltip: l10n.exerciseInsightsTooltip,
                value: _showExerciseInsights,
                onChanged: (value) {
                  setState(() => _showExerciseInsights = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Community Suggestions
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.lightbulb,
                iconColor: context.colors.secondary,
                title: l10n.communitySuggestionsTitle,
                subtitle: l10n.communitySuggestionsDescription,
                tooltip: l10n.communitySuggestionsTooltip,
                value: _showCommunitySuggestions,
                onChanged: (value) {
                  setState(() => _showCommunitySuggestions = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // TUT Info
              _buildToggleCard(
                theme,
                l10n,
                icon: AppIcons.timer,
                iconColor: Colors.teal,
                title: l10n.tutInfoTitle,
                subtitle: l10n.tutInfoDescription,
                tooltip: l10n.tutInfoTooltip,
                value: _showTutInfo,
                onChanged: (value) {
                  setState(() => _showTutInfo = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Quick Info Icon
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.info_outline,
                iconColor: context.colors.primary,
                title: l10n.quickInfoIconTitle,
                subtitle: l10n.quickInfoIconDescription,
                tooltip: l10n.quickInfoIconTooltip,
                value: _showQuickInfoIcon,
                onChanged: (value) {
                  setState(() => _showQuickInfoIcon = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Quick Warmup Icon
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.fitness_center,
                iconColor: context.colors.warning,
                title: l10n.quickWarmupIconTitle,
                subtitle: l10n.quickWarmupIconDescription,
                tooltip: l10n.quickWarmupIconTooltip,
                value: _showWarmupIcon,
                onChanged: (value) {
                  setState(() => _showWarmupIcon = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Quick Prevention Icon
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.health_and_safety,
                iconColor: context.colors.success,
                title: l10n.quickPreventionIconTitle,
                subtitle: l10n.quickPreventionIconDescription,
                tooltip: l10n.quickPreventionIconTooltip,
                value: _showPreventionIcon,
                onChanged: (value) {
                  setState(() => _showPreventionIcon = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Advanced Menu
              _buildToggleCard(
                theme,
                l10n,
                icon: AppIcons.moreVert,
                iconColor: context.colors.error,
                title: l10n.advancedMenuTitle,
                subtitle: l10n.advancedMenuDescription,
                tooltip: l10n.advancedMenuTooltip,
                value: _showAdvancedMenu,
                onChanged: (value) {
                  setState(() => _showAdvancedMenu = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Custom Timers
              _buildToggleCard(
                theme,
                l10n,
                icon: AppIcons.timer,
                iconColor: context.colors.success,
                title: l10n.customTimersTitle,
                subtitle: l10n.customTimersDescription,
                tooltip: l10n.customTimersTooltip,
                value: _showCustomTimers,
                onChanged: (value) {
                  setState(() => _showCustomTimers = value);
                  _saveDisplaySettings();
                },
              ),

              const SizedBox(height: 24),

              // Subcategory 2: Auto-regolazione
              Text(
                l10n.autoRegulationCategory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.tertiary,
                ),
              ),
              const SizedBox(height: 8),

              // APRE System
              _buildApreSection(theme, l10n),
              const SizedBox(height: 8),

              // Auto-adjust Weight from RPE (depends on RPE tracking)
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.fitness_center,
                iconColor: context.colors.warning,
                title: l10n.autoAdjustWeightRpeTitle,
                subtitle: l10n.autoAdjustWeightRpeDescription,
                tooltip: l10n.autoAdjustWeightRpeTooltip,
                value: _autoAdjustWeightFromRpe,
                onChanged: (value) async {
                  // ✅ V4 Phase 3: Smart dependency handling with dialog
                  if (value && !_rpeTracking) {
                    // Show dialog asking to enable master
                    final confirmed = await _showDependencyDialog(
                      context: context,
                      dependentName: l10n.autoAdjustWeightRpeTitle,
                      masterName: l10n.enableRpeTitle,
                    );

                    if (!confirmed) return; // User cancelled

                    // User confirmed: enable both
                    setState(() {
                      _rpeTracking = true;
                      _autoAdjustWeightFromRpe = true;
                    });
                  } else {
                    // Just toggle normally
                    setState(() {
                      _autoAdjustWeightFromRpe = value;
                    });
                  }
                  _saveSettings();
                },
              ),
              const SizedBox(height: 8),

              // Auto-adjust Rest from RPE (depends on RPE tracking)
              _buildToggleCard(
                theme,
                l10n,
                icon: AppIcons.timer,
                iconColor: context.colors.success,
                title: l10n.autoAdjustRestRpeTitle,
                subtitle: l10n.autoAdjustRestRpeDescription,
                tooltip: l10n.autoAdjustRestRpeTooltip,
                value: _autoAdjustRestFromRpe,
                onChanged: (value) async {
                  // ✅ V4 Phase 3: Smart dependency handling with dialog
                  if (value && !_rpeTracking) {
                    // Show dialog asking to enable master
                    final confirmed = await _showDependencyDialog(
                      context: context,
                      dependentName: l10n.autoAdjustRestRpeTitle,
                      masterName: l10n.enableRpeTitle,
                    );

                    if (!confirmed) return; // User cancelled

                    // User confirmed: enable both
                    setState(() {
                      _rpeTracking = true;
                      _autoAdjustRestFromRpe = true;
                    });
                  } else {
                    // Just toggle normally
                    setState(() {
                      _autoAdjustRestFromRpe = value;
                    });
                  }
                  _saveSettings();
                },
              ),

              const SizedBox(height: 24),

              // Subcategory 3: Interfaccia
              Text(
                l10n.interfaceCategory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),

              // Auto-collapse Completed (moved from Core Features)
              _buildToggleCard(
                theme,
                l10n,
                icon: AppIcons.unfoldLess,
                iconColor: Colors.indigo,
                title: l10n.autoCollapseTitle,
                subtitle: l10n.autoCollapseDescription,
                tooltip: l10n.autoCollapseTooltip,
                value: _autoCollapseCompleted,
                onChanged: (value) {
                  setState(() => _autoCollapseCompleted = value);
                  _saveSettings();
                },
              ),
              const SizedBox(height: 8),

              // Collapse Countdown
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.visibility_off,
                iconColor: context.colors.tertiary,
                title: l10n.collapseCountdownTitle,
                subtitle: l10n.collapseCountdownDescription,
                tooltip: l10n.collapseCountdownTooltip,
                value: _showCollapseCountdown,
                onChanged: (value) {
                  setState(() => _showCollapseCountdown = value);
                  _saveDisplaySettings();
                },
              ),
              const SizedBox(height: 8),

              // Simplified Animations
              _buildToggleCard(
                theme,
                l10n,
                icon: Icons.animation,
                iconColor: context.colors.warning,
                title: l10n.simplifiedAnimationsTitle,
                subtitle: l10n.simplifiedAnimationsDescription,
                tooltip: l10n.simplifiedAnimationsTooltip,
                value: _simplifiedAnimations,
                onChanged: (value) {
                  setState(() => _simplifiedAnimations = value);
                  _saveDisplaySettings();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    final l10n = AppLocalizations.of(context);

    ref.read(appConfigProvider.notifier).updateWorkoutSettings(
      rpeTracking: _rpeTracking,
      autoRestTimer: _autoRestTimer,
      setDurationTracking: false, // TUT tracking removed - keep disabled
      plateCalculator: true,
      warmupSuggestions: _warmupSuggestions,
      autoCollapseCompleted: _autoCollapseCompleted,
      // ✅ V4: isProMode parameter removed (no Pro/Base mode)
      enableApre: _enableApre,
      defaultApreProtocol: _defaultApreProtocol,
      autoAdjustRestTime: _autoAdjustRestTimeApre,
      autoAdjustWeightFromRpe: _autoAdjustWeightFromRpe,
      autoAdjustRestFromRpe: _autoAdjustRestFromRpe,
    );

    _saveDisplaySettings();

    // ✅ V4: Simple success message (no mode-specific text)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _saveDisplaySettings() {
    ref.read(appConfigProvider.notifier).updateDisplaySettings(
      showTutInfo: _showTutInfo,
      // ✅ V3: SEPARATE values (was combined in V2)
      showExerciseNotes: _showExerciseNotes,
      showExerciseInsights: _showExerciseInsights,
      showCommunitySuggestions: _showCommunitySuggestions,
      showCustomTimers: _showCustomTimers,
      showAdvancedMenu: _showAdvancedMenu,
      showCollapseCountdown: _showCollapseCountdown,
      simplifiedAnimations: _simplifiedAnimations,
      // ✅ V3: 3 SEPARATE icon values (was 1 combined in V2)
      showQuickInfoIcon: _showQuickInfoIcon,
      showWarmupIcon: _showWarmupIcon,
      showPreventionIcon: _showPreventionIcon,
    );
  }

  String _getApreProtocolDescription(int protocol, AppLocalizations l10n) {
    switch (protocol) {
      case 3:
        return l10n.apre3Description;
      case 6:
        return l10n.apre6Description;
      case 10:
        return l10n.apre10Description;
      default:
        return '';
    }
  }
}
