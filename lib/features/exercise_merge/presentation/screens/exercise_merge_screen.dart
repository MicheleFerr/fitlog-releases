/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/presentation/screens
/// 🎯 Feature: exercise_merge
/// 🔧 Type: screen
///
/// Schermata principale per merge esercizi
/// UX: ExpansionTile per ogni esercizio custom, match inline con immagini
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/providers/exercise_merge_providers.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/widgets/merge_confirmation_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Schermata per merge esercizi
///
/// **Flusso UX migliorato**:
/// 1. Lista esercizi custom come ExpansionTile
/// 2. Tap espande e mostra match possibili con immagini
/// 3. Selezione target inline
/// 4. Bottom sheet conferma con preview
class ExerciseMergeScreen extends ConsumerStatefulWidget {
  const ExerciseMergeScreen({super.key});

  @override
  ConsumerState<ExerciseMergeScreen> createState() =>
      _ExerciseMergeScreenState();
}

class _ExerciseMergeScreenState extends ConsumerState<ExerciseMergeScreen> {
  /// Indice candidato espanso (-1 = nessuno)
  int _expandedIndex = -1;

  /// Match selezionato per il candidato espanso
  ExerciseMatch? _selectedMatch;

  /// Cache dei candidati per evitare loader durante merge
  List<MergeCandidate> _lastCandidates = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final candidatesAsync = ref.watch(mergeCandidatesProvider);
    final mergeState = ref.watch(mergeExecutionProvider);

    // During merge operation, keep old list visible to avoid flashing loader
    final isMerging = mergeState.state == MergeState.loading ||
        mergeState.state == MergeState.success;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.mergeExercisesTitle),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.help),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content - use valueOrNull during merge to keep old list
          if (isMerging)
            // During merge, show last known data (or empty state)
            _buildMainContent(
                context, candidatesAsync.valueOrNull ?? _lastCandidates)
          else
            candidatesAsync.when(
              data: (candidates) {
                // Cache candidates for use during merge
                _lastCandidates = candidates;
                return _buildMainContent(context, candidates);
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, _) => _buildErrorState(context, error),
            ),

          // Progress overlay during merge
          if (mergeState.state == MergeState.loading)
            _buildMergeProgressOverlay(context, mergeState),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, List<MergeCandidate> candidates) {
    if (candidates.isEmpty) {
      return _buildEmptyState(context);
    }
    return _buildContent(context, candidates);
  }

  Widget _buildMergeProgressOverlay(
      BuildContext context, MergeProgress progress) {
    return ColoredBox(
      color: context.colors.surface.withValues(alpha: 0.9),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppSpacing.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.progress,
                        strokeWidth: 6,
                        backgroundColor:
                            context.colors.primary.withValues(alpha: 0.2),
                      ),
                      Text(
                        '${progress.progressPercent}%',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  progress.currentStep,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<MergeCandidate> candidates) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Header info
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            l10n.mergeExercisesDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // Candidate list with ExpansionTile
        ...candidates.asMap().entries.map((entry) {
          final index = entry.key;
          final candidate = entry.value;
          final isExpanded = _expandedIndex == index;

          return _CandidateExpansionTile(
            candidate: candidate,
            isExpanded: isExpanded,
            selectedMatch: isExpanded ? _selectedMatch : null,
            onExpansionChanged: (expanded) {
              HapticFeedback.lightImpact();
              setState(() {
                _expandedIndex = expanded ? index : -1;
                _selectedMatch = null;
              });
            },
            onMatchSelected: (match) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedMatch = match;
              });
            },
            onMergePressed: () => _showConfirmation(context, candidate),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.checkCircle,
                size: AppIconSize.xxlarge,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noMergeCandidates,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noMergeCandidatesDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: AppIconSize.xxlarge,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.errorLoadingData,
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, MergeCandidate candidate) {
    if (_selectedMatch == null) return;

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => MergeConfirmationBottomSheet(
        sourceExerciseName: candidate.customExerciseName,
        targetExercise: _selectedMatch!.exercise,
        sessionCount: candidate.sessionCount,
        personalRecord: candidate.personalRecord,
        onConfirm: () => _executeMerge(context, candidate),
      ),
    );
  }

  Future<void> _executeMerge(
      BuildContext context, MergeCandidate candidate) async {
    if (_selectedMatch == null) return;

    final notifier = ref.read(mergeExecutionProvider.notifier);
    final targetExercise = _selectedMatch!.exercise;

    final success = await notifier.executeMerge(
      sourceExerciseName: candidate.customExerciseName,
      targetExerciseId: targetExercise.id,
      targetExerciseName: targetExercise.nome,
      targetMuscleGroup: targetExercise.focus.isNotEmpty
          ? targetExercise.focus.first
          : 'VARIO',
    );

    if (context.mounted) {
      Navigator.of(context).pop(); // Close bottom sheet

      if (success) {
        // Reset merge state so overlay disappears and list is visible
        notifier.reset();

        setState(() {
          _expandedIndex = -1;
          _selectedMatch = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.mergeSuccessful),
            backgroundColor: context.colors.primary,
          ),
        );
      } else {
        // Reset on error too
        notifier.reset();

        final errorMessage = ref.read(mergeExecutionProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? context.l10n.mergeError),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.help, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.mergeHelpTitle),
          ],
        ),
        content: Text(l10n.mergeHelpContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

/// ExpansionTile per candidato merge
///
/// Mostra l'esercizio custom come header.
/// Quando espanso, mostra i match possibili con immagini.
class _CandidateExpansionTile extends StatelessWidget {
  const _CandidateExpansionTile({
    required this.candidate,
    required this.isExpanded,
    required this.selectedMatch,
    required this.onExpansionChanged,
    required this.onMatchSelected,
    required this.onMergePressed,
  });

  final MergeCandidate candidate;
  final bool isExpanded;
  final ExerciseMatch? selectedMatch;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<ExerciseMatch> onMatchSelected;
  final VoidCallback onMergePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      clipBehavior: Clip.antiAlias,
      color: isExpanded
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpanded
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        // Remove default ExpansionTile dividers
        data: Theme.of(context).copyWith(dividerColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0)),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: EdgeInsets.zero,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Match quality badge with tooltip
              Tooltip(
                message: l10n.matchSimilarityTooltip,
                child: _MatchQualityBadge(score: candidate.bestMatchScore),
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded ? AppIcons.arrowUpward : AppIcons.arrowDown,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          title: Text(
            candidate.customExerciseName,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                AppIcons.history,
                size: AppIconSize.tiny,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${candidate.sessionCount} ${l10n.sessions}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (candidate.personalRecord != null &&
                  candidate.personalRecord! > 0) ...[
                const SizedBox(width: 12),
                Icon(
                  AppIcons.trophy,
                  size: AppIconSize.tiny,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${candidate.personalRecord!.toStringAsFixed(1)} kg',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          children: [
            // Divider
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),

            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.arrowDown,
                    size: AppIconSize.small,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.selectTargetExercise,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Match list with images
            ...candidate.matchingExercises.map((match) {
              final isSelected = selectedMatch == match;
              return _MatchListTile(
                match: match,
                isSelected: isSelected,
                onTap: () => onMatchSelected(match),
              );
            }),

            // Merge button (visible when a match is selected)
            if (selectedMatch != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: FilledButton.icon(
                  onPressed: onMergePressed,
                  icon: const Icon(AppIcons.merge),
                  label: Text(l10n.mergeExercises),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tile per un match target con immagine esercizio
class _MatchListTile extends StatelessWidget {
  const _MatchListTile({
    required this.match,
    required this.isSelected,
    required this.onTap,
  });

  final ExerciseMatch match;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
              : colorScheme.surface.withValues(alpha: 0),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? colorScheme.secondary : colorScheme.surface.withValues(alpha: 0),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.secondary
                      : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),

            // Exercise image
            ExerciseGifWidget(
              gifUrl: match.exercise.imageUrl,
              exerciseName: match.exercise.nome,
              size: 48,
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.exercise.nome,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    match.exercise.focus.join(', '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Match score with tooltip
            Tooltip(
              message: l10n.matchSimilarityTooltip,
              child: _MatchQualityBadge(score: match.score),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge per qualità del match
class _MatchQualityBadge extends StatelessWidget {
  const _MatchQualityBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    Color backgroundColor;
    Color textColor;

    if (score >= 0.90) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (score >= 0.75) {
      backgroundColor = colorScheme.tertiary;
      textColor = colorScheme.onTertiary;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(score * 100).toStringAsFixed(0)}%',
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
