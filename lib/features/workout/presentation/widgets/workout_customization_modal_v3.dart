/// Workout Customization Modal V5 - Simplified
///
/// Streamlined from 18 toggles to ~10 with clear organization:
/// - Comportamento: Core workout behavior (3 toggles)
/// - Tracciamento: RPE system with sub-options (collapsible)
/// - Aspetto: Visual customization (collapsible)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_display_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Font size options for the selector
enum _FontSize {
  small(0.8),
  medium(1.0),
  large(1.2);

  const _FontSize(this.value);
  final double value;
}

/// Simplified Workout Customization Modal
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
  ConsumerState<WorkoutCustomizationModalV3> createState() =>
      _WorkoutCustomizationModalV3State();
}

class _WorkoutCustomizationModalV3State
    extends ConsumerState<WorkoutCustomizationModalV3> {
  // === COMPORTAMENTO ===
  late bool _autoRestTimer;
  late bool _autoCollapseCompleted;
  late bool _soundEnabled;
  late bool _showCustomTimers;

  // === TRACCIAMENTO ===
  late bool _rpeTracking;
  late bool _autoAdjustWeightFromRpe;
  late bool _autoAdjustRestFromRpe;
  late bool _setDurationTracking;

  // === ASPETTO ===
  late bool _showExerciseNotes;
  late bool _showExerciseInsights;
  late bool _showQuickIcons; // Unified: was 3 separate toggles
  late bool _plateCalculator;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);

    // Comportamento
    _autoRestTimer = config.autoRestTimer ?? true;
    _autoCollapseCompleted = config.autoCollapseCompleted ?? false;
    _soundEnabled = config.soundEnabled;
    _showCustomTimers = config.showCustomTimers ?? false;

    // Tracciamento
    _rpeTracking = config.rpeTracking ?? false;
    _autoAdjustWeightFromRpe = config.autoAdjustWeightFromRpe ?? false;
    _autoAdjustRestFromRpe = config.autoAdjustRestFromRpe ?? false;
    _setDurationTracking = config.setDurationTracking ?? false;

    // Aspetto
    _showExerciseNotes = config.showExerciseNotes ?? false;
    _showExerciseInsights = config.showExerciseInsights ?? false;
    _showQuickIcons = (config.showQuickInfoIcon ?? false) ||
        (config.showWarmupIcon ?? false) ||
        (config.showPreventionIcon ?? false);
    _plateCalculator = config.plateCalculator ?? true;
    _fontSize = config.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

                  // === COMPORTAMENTO ===
                  _buildSectionCard(
                    context,
                    icon: AppIcons.playCircle,
                    title: 'Comportamento',
                    color: context.colors.primary,
                    children: [
                      _buildToggleRow(
                        context,
                        icon: AppIcons.timer,
                        title: context.l10n.autoRestTimerTitle,
                        subtitle: 'Avvia timer dopo ogni set',
                        value: _autoRestTimer,
                        onChanged: (v) {
                          setState(() => _autoRestTimer = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.unfoldLess,
                        title: 'Chiudi esercizi completati',
                        subtitle: 'Minimizza automaticamente',
                        value: _autoCollapseCompleted,
                        onChanged: (v) {
                          setState(() => _autoCollapseCompleted = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: _soundEnabled
                            ? AppIcons.volumeUp
                            : AppIcons.volumeOff,
                        title: 'Suoni e vibrazioni',
                        subtitle: 'Feedback audio durante workout',
                        value: _soundEnabled,
                        onChanged: (v) {
                          setState(() => _soundEnabled = v);
                          _saveSound();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.hourglassEmpty,
                        title: 'Tempo recupero su card',
                        subtitle: 'Mostra e modifica timer per esercizio',
                        value: _showCustomTimers,
                        onChanged: (v) {
                          setState(() => _showCustomTimers = v);
                          _saveAll();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // === TRACCIAMENTO AVANZATO ===
                  _buildExpandableSection(
                    context,
                    icon: AppIcons.speed,
                    title: 'Tracciamento Avanzato',
                    subtitle: 'RPE e auto-regolazione',
                    color: context.colors.tertiary,
                    initiallyExpanded: _rpeTracking,
                    children: [
                      _buildToggleRow(
                        context,
                        icon: AppIcons.speed,
                        title: 'Sforzo Percepito (RPE)',
                        subtitle: 'Traccia intensità dopo ogni set',
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
                            title: 'Suggerisci peso',
                            subtitle: 'Basato su RPE del set precedente',
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
                            title: 'Regola riposo',
                            subtitle: 'Più tempo se RPE alto',
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
                        title: 'Durata esecuzione set',
                        subtitle: 'Traccia tempo sotto tensione',
                        value: _setDurationTracking,
                        onChanged: (v) {
                          setState(() => _setDurationTracking = v);
                          _saveAll();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // === ASPETTO ===
                  _buildExpandableSection(
                    context,
                    icon: AppIcons.colorLens,
                    title: 'Aspetto',
                    subtitle: 'Personalizza interfaccia',
                    color: context.colors.secondary,
                    initiallyExpanded: false,
                    children: [
                      // Set size selector
                      _buildSetSizeSelector(context),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.noteAlt,
                        title: 'Note esercizio',
                        subtitle: 'Mostra note sotto ogni esercizio',
                        value: _showExerciseNotes,
                        onChanged: (v) {
                          setState(() => _showExerciseNotes = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.insights,
                        title: 'Grafici progresso',
                        subtitle: 'Mostra storico e trend',
                        value: _showExerciseInsights,
                        onChanged: (v) {
                          setState(() => _showExerciseInsights = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.touchApp,
                        title: 'Icone rapide',
                        subtitle: 'Info, warmup, prevenzione',
                        value: _showQuickIcons,
                        onChanged: (v) {
                          setState(() => _showQuickIcons = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildToggleRow(
                        context,
                        icon: AppIcons.weight,
                        title: 'Calcolatore dischi',
                        subtitle: 'Mostra dischi per peso',
                        value: _plateCalculator,
                        onChanged: (v) {
                          setState(() => _plateCalculator = v);
                          _saveAll();
                        },
                      ),
                      _buildDivider(),
                      _buildFontSizeSelector(context),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info footer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.2),
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
                          'Le modifiche sono salvate automaticamente',
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
    );
  }

  // === BUILDERS ===

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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
                  style: (compact
                          ? theme.textTheme.bodyMedium
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
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
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSetSizeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final displayMode = ref.watch(setDisplayProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            AppIcons.viewComfy,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dimensione righe set',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<SetDisplayMode>(
                  segments: const [
                    ButtonSegment(
                      value: SetDisplayMode.compact,
                      label: Text('Compatto'),
                    ),
                    ButtonSegment(
                      value: SetDisplayMode.comfortable,
                      label: Text('Comodo'),
                    ),
                  ],
                  selected: {displayMode},
                  onSelectionChanged: (selected) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(setDisplayProvider.notifier)
                        .setMode(selected.first);
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

  Widget _buildFontSizeSelector(BuildContext context) {
    final theme = Theme.of(context);

    // Map fontSize to enum for SegmentedButton
    _FontSize currentSize() {
      if (_fontSize <= 0.85) return _FontSize.small;
      if (_fontSize <= 1.05) return _FontSize.medium;
      return _FontSize.large;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            AppIcons.formatSize,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dimensione testo',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<_FontSize>(
                  segments: const [
                    ButtonSegment(
                      value: _FontSize.small,
                      label: Text('Piccolo'),
                    ),
                    ButtonSegment(
                      value: _FontSize.medium,
                      label: Text('Medio'),
                    ),
                    ButtonSegment(
                      value: _FontSize.large,
                      label: Text('Grande'),
                    ),
                  ],
                  selected: {currentSize()},
                  onSelectionChanged: (selected) {
                    HapticFeedback.selectionClick();
                    final newSize = selected.first.value;
                    setState(() => _fontSize = newSize);
                    ref.read(appConfigProvider.notifier).setFontSize(newSize);
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
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  // === SAVE ===

  void _saveAll() {
    // Save workout settings
    ref.read(appConfigProvider.notifier).updateWorkoutSettings(
          autoRestTimer: _autoRestTimer,
          autoCollapseCompleted: _autoCollapseCompleted,
          rpeTracking: _rpeTracking,
          autoAdjustWeightFromRpe: _autoAdjustWeightFromRpe,
          autoAdjustRestFromRpe: _autoAdjustRestFromRpe,
          setDurationTracking: _setDurationTracking,
          plateCalculator: _plateCalculator,
        );

    // Save display settings
    ref.read(appConfigProvider.notifier).updateDisplaySettings(
          showExerciseNotes: _showExerciseNotes,
          showExerciseInsights: _showExerciseInsights,
          showCustomTimers: _showCustomTimers,
          // Unified quick icons - set all 3 to same value
          showQuickInfoIcon: _showQuickIcons,
          showWarmupIcon: _showQuickIcons,
          showPreventionIcon: _showQuickIcons,
        );
  }

  void _saveSound() {
    ref.read(appConfigProvider.notifier).setSoundEnabled(_soundEnabled);
  }
}
