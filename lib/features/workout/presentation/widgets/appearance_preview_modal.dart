/// Appearance Preview Modal - Live preview di come appare la card dell'esercizio
/// con le impostazioni di aspetto attive/disattive
///
/// Features:
/// - Card di esempio LIVE con un esercizio finto
/// - Toggle per Exercise Notes, Progress Charts, Quick Icons, Plate Calculator
/// - Live preview: quando cambi un toggle, la card si aggiorna istantaneamente
/// - Auto-save quando chiudi (senza rerender della schermata durante workout)
///
/// ✅ DESIGN: La preview card replica fedelmente l'aspetto di ExerciseListItem
/// per fornire un'anteprima accurata di come appariranno le schede durante il workout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Sample exercise for preview
Exercise _createSampleExercise() {
  return Exercise(
    id: 'sample-exercise-id',
    name: 'Barbell Bench Press',
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
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
    return ModalService.showSheet(context,
      isScrollControlled: true,
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
                    // ✅ DESIGN: Replica fedele di ExerciseListItem styling
                    DecoratedBox(
                      decoration: BoxDecoration(
                        // Match ExerciseListItem: surfaceContainer for active cards
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          // Match ExerciseListItem shadow
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0),
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== HEADER ROW (matches ExerciseListItemHeader) =====
                              Row(
                                children: [
                                  // Exercise Icon (simplified - no GIF in preview)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SemanticIcon(
                                      icon: AppIcons.workout,
                                      semanticLabel: 'Exercise icon',
                                      color: theme.colorScheme.primary,
                                      size: AppIconSize.small,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Name and badges column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Exercise Name Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                sampleExercise.name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SemanticIcon(
                                              icon: AppIcons.info,
                                              semanticLabel: 'Information',
                                              size: AppIconSize.small,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Badge Row (Timer, Quick Icons)
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              // Rest timer badge (always shown)
                                              _buildTimerBadge(theme, context),
                                              const SizedBox(width: 8),
                                              // Quick Icons (conditional)
                                              if (_showQuickIcons) ...[
                                                _buildQuickActionIcon(
                                                  theme: theme,
                                                  icon: AppIcons.info,
                                                  color: context.infoColor,
                                                ),
                                                const SizedBox(width: 8),
                                                _buildQuickActionIcon(
                                                  theme: theme,
                                                  icon: AppIcons.whatshot,
                                                  color: context.warningColor,
                                                ),
                                                const SizedBox(width: 8),
                                                _buildQuickActionIcon(
                                                  theme: theme,
                                                  icon: AppIcons.shieldOutlined,
                                                  color: context.successColor,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // Insight chip (conditional)
                                        if (_showExerciseInsights) ...[
                                          const SizedBox(height: 4),
                                          _buildInsightChip(theme, context),
                                        ],
                                        // Notes chip (conditional)
                                        if (_showExerciseNotes &&
                                            sampleExercise.notes != null &&
                                            sampleExercise.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          _buildNotesChip(theme, context, sampleExercise.notes!),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Popup menu
                                  PopupMenuButton<void>(
                                    icon: Icon(
                                      AppIcons.moreVert,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    itemBuilder: (context) => [],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ===== SETS SECTION (matches ExerciseListItemSets) =====
                              // Sets progress header
                              Row(
                                children: [
                                  Text(
                                    '1 / ${sampleExercise.sets.length} ${context.l10n.sets}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: 1 / sampleExercise.sets.length,
                                        backgroundColor: theme.colorScheme
                                            .surfaceContainerHighest,
                                        color: theme.colorScheme.primary,
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Sets list (matches real set row styling)
                              ...sampleExercise.sets.map((set) => _buildSetRow(
                                theme,
                                context,
                                set,
                              )),

                              // Add set button
                              const SizedBox(height: 8),
                              _buildAddSetButton(theme, context),

                              // Plate Calculator (conditional)
                              if (_plateCalculator) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SemanticIcon(
                                        icon: AppIcons.weight,
                                        semanticLabel: 'Plate calculator',
                                        size: AppIconSize.small,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${context.l10n.plateCalculator}: 1×20kg + 2×5kg',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== SEZIONE INFERIORE: TOGGLE CONTROLS =====
                    DecoratedBox(
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

  // ========================================================================
  // PREVIEW CARD HELPER WIDGETS
  // These match the styling from ExerciseListItem components
  // ========================================================================

  /// Timer badge matching ExerciseListItemHeader styling
  Widget _buildTimerBadge(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.timer,
            semanticLabel: 'Rest timer',
            size: AppIconSize.tiny,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '90s',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 2),
          SemanticIcon(
            icon: AppIcons.edit,
            semanticLabel: 'Edit',
            size: AppIconSize.tiny,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  /// Quick action icon matching ExerciseListItemHeader styling
  Widget _buildQuickActionIcon({
    required ThemeData theme,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: SemanticIcon(
        icon: icon,
        semanticLabel: 'Quick action',
        size: AppIconSize.tiny,
        color: color,
      ),
    );
  }

  /// Insight chip matching ExerciseListItemHeader styling
  Widget _buildInsightChip(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.insights,
            semanticLabel: 'Insights',
            size: AppIconSize.tiny,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '100kg×8 (2g)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          SemanticIcon(
            icon: AppIcons.chevronRight,
            semanticLabel: 'View history',
            size: AppIconSize.tiny,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  /// Notes chip matching ExerciseListItemHeader styling
  Widget _buildNotesChip(ThemeData theme, BuildContext context, String notes) {
    final preview = notes.length > 35 ? '${notes.substring(0, 35)}...' : notes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.lightbulb,
            semanticLabel: context.l10n.notes,
            size: AppIconSize.tiny,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              preview,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Set row matching ExerciseListItemSets styling
  Widget _buildSetRow(ThemeData theme, BuildContext context, ExerciseSet set) {
    final isCompleted = set.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Set number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? SemanticIcon(
                        icon: AppIcons.check,
                        semanticLabel: 'Completed',
                        size: AppIconSize.tiny,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        '${set.setNumber}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Weight
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${set.weight?.toStringAsFixed(set.weight == set.weight?.truncate() ? 0 : 1) ?? '-'} kg',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Reps
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${set.reps ?? '-'} reps',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Tap hint or check
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.tap,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Add set button matching ExerciseListItemSets styling
  Widget _buildAddSetButton(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.add,
            semanticLabel: context.l10n.addSet,
            size: AppIconSize.small,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.addSet,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
