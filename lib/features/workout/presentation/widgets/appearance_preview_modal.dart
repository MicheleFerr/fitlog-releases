/// Appearance Preview Modal - Live preview di come appare la card dell'esercizio
/// con le impostazioni di aspetto attive/disattive
///
/// Features:
/// - Card di esempio LIVE con un esercizio finto
/// - Toggle per Exercise Notes, Progress Charts, Quick Icons, Plate Calculator
/// - Live preview: quando cambi un toggle, la card si aggiorna istantaneamente
/// - Auto-save quando chiudi (senza rerender della schermata durante workout)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_set.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/interface_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Sample exercise for preview
Exercise _createSampleExercise() {
  return Exercise(
    id: 'sample-exercise-id',
    name: 'Barbell Bench Press',
    countingMode: CountingMode.reps,
    notes: 'Keep chest up, touch chest lightly',
    sets: [
      ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        reps: 8,
        weight: 100.0,
        isCompleted: true,
      ),
      ExerciseSet(
        id: 'set-2',
        setNumber: 2,
        reps: 6,
        weight: 105.0,
        isCompleted: false,
      ),
      ExerciseSet(
        id: 'set-3',
        setNumber: 3,
        reps: 5,
        weight: 110.0,
        isCompleted: false,
      ),
    ],
  );
}

class AppearancePreviewModal extends ConsumerStatefulWidget {
  const AppearancePreviewModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => const AppearancePreviewModal(),
    );
  }

  @override
  ConsumerState<AppearancePreviewModal> createState() =>
      _AppearancePreviewModalState();
}

class _AppearancePreviewModalState extends ConsumerState<AppearancePreviewModal> {
  late bool _showExerciseNotes;
  late bool _showExerciseInsights;
  late bool _showQuickIcons;
  late bool _plateCalculator;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);

    _showExerciseNotes = config.showExerciseNotes ?? false;
    _showExerciseInsights = config.showExerciseInsights ?? false;
    _showQuickIcons =
        (config.showQuickInfoIcon ?? false) ||
        (config.showWarmupIcon ?? false) ||
        (config.showPreventionIcon ?? false);
    _plateCalculator = config.plateCalculator ?? true;
  }

  void _saveSettings() {
    ref
        .read(appConfigProvider.notifier)
        .updateDisplaySettings(
          showExerciseNotes: _showExerciseNotes,
          showExerciseInsights: _showExerciseInsights,
          showCustomTimers: false, // Not changed here
          // Unified quick icons - set all 3 to same value
          showQuickInfoIcon: _showQuickIcons,
          showWarmupIcon: _showQuickIcons,
          showPreventionIcon: _showQuickIcons,
        );
  }

  void _handleClose(BuildContext context) {
    _saveSettings();
    SnackBarService.showInfo(context, context.l10n.changesAutoSaved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sampleExercise = _createSampleExercise();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleClose(context);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
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
                      AppIcons.preview,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.appearancePreview,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content: Split in 2 sections (preview + toggles)
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),

                    // ===== SEZIONE SUPERIORE: PREVIEW CARD =====
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise Name (always shown)
                          Row(
                            children: [
                              Text(
                                sampleExercise.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                AppIcons.moreVert,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Exercise Notes (conditional)
                          if (_showExerciseNotes) ...[
                            Text(
                              sampleExercise.notes ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Sets list
                          Column(
                            children: sampleExercise.sets
                                .map(
                                  (set) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        // Quick Icons (conditional)
                                        if (_showQuickIcons) ...[
                                          Icon(
                                            AppIcons.info,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                        ],

                                        // Set info
                                        Expanded(
                                          child: Text(
                                            '${set.reps}x ${set.weight}kg',
                                            style:
                                                theme.textTheme.bodyMedium,
                                          ),
                                        ),

                                        // Completed badge
                                        if (set.isCompleted)
                                          Icon(
                                            AppIcons.check,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 12),

                          // Progress Charts (conditional)
                          if (_showExerciseInsights) ...[
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  context.l10n.progressChart,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Plate Calculator (conditional)
                          if (_plateCalculator) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⚖️ ${context.l10n.plateCalculator}: 1x20kg + 2x5kg',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== SEZIONE INFERIORE: TOGGLE CONTROLS =====
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context.l10n.appearanceOptions,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Exercise Notes Toggle
                          _buildToggleRow(
                            context,
                            icon: AppIcons.noteAlt,
                            title: context.l10n.exerciseNotesTitle,
                            subtitle: context.l10n.exerciseNotesSubtitle,
                            value: _showExerciseNotes,
                            onChanged: (v) {
                              setState(() => _showExerciseNotes = v);
                            },
                          ),
                          _buildDivider(theme),

                          // Progress Charts Toggle
                          _buildToggleRow(
                            context,
                            icon: AppIcons.insights,
                            title: context.l10n.progressChartsTitle,
                            subtitle: context.l10n.progressChartsSubtitle,
                            value: _showExerciseInsights,
                            onChanged: (v) {
                              setState(() => _showExerciseInsights = v);
                            },
                          ),
                          _buildDivider(theme),

                          // Quick Icons Toggle
                          _buildToggleRow(
                            context,
                            icon: AppIcons.touchApp,
                            title: context.l10n.quickIconsTitle,
                            subtitle: context.l10n.quickIconsSubtitle,
                            value: _showQuickIcons,
                            onChanged: (v) {
                              setState(() => _showQuickIcons = v);
                            },
                          ),
                          _buildDivider(theme),

                          // Plate Calculator Toggle
                          _buildToggleRow(
                            context,
                            icon: AppIcons.weight,
                            title: context.l10n.plateCalculatorTitle,
                            subtitle: context.l10n.plateCalculatorSubtitle,
                            value: _plateCalculator,
                            onChanged: (v) {
                              setState(() => _plateCalculator = v);
                            },
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
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
                          Expanded(
                            child: Text(
                              context.l10n.changesAutoSaved,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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

  Widget _buildToggleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
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
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}
