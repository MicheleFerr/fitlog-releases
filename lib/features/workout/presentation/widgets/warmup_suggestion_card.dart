import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/warmup_calculator_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_customization_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class WarmupSuggestionCard extends ConsumerStatefulWidget {
  
  const WarmupSuggestionCard({
    super.key,
    required this.workingWeight,
    required this.targetReps,
    required this.onAddWarmupSets,
    this.onDismiss,
    required this.exerciseName,
  });
  final double workingWeight;
  final int targetReps;
  final Function(List<ExerciseSet>) onAddWarmupSets;
  final VoidCallback? onDismiss;
  final String exerciseName;

  @override
  ConsumerState<WarmupSuggestionCard> createState() => _WarmupSuggestionCardState();
}

class _WarmupSuggestionCardState extends ConsumerState<WarmupSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late WarmupCalculatorService _warmupCalculator;

  bool _isExpanded = false;
  List<WarmupSet> _warmupSets = [];
  
  @override
  void initState() {
    super.initState();

    _warmupCalculator = WarmupCalculatorService();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _calculateWarmupSets();

    // Auto-show if it's a heavy compound movement
    if (widget.workingWeight >= 60 && _shouldAutoShow()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _toggleExpanded();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  bool _shouldAutoShow() {
    return _warmupCalculator.isLikelyBarbellExercise(widget.exerciseName) &&
        widget.workingWeight >= 60;
  }

  void _calculateWarmupSets() {
    final isBarbell =
        _warmupCalculator.isLikelyBarbellExercise(widget.exerciseName);
    _warmupSets = _warmupCalculator.calculateWarmupSets(
      widget.workingWeight,
      isBarbell: isBarbell,
    );
  }

  /// Formats plate configuration as human-readable string
  /// Example: "20 + 10 per side" or "Empty bar"
  String _formatPlatesPerSide(double totalWeight) {
    final l10n = context.l10n;

    if (totalWeight <= WarmupCalculatorService.defaultBarbellWeight) {
      return l10n.emptyBarbell;
    }

    final plateCounts = _warmupCalculator.calculatePlatesPerSide(totalWeight);

    if (plateCounts.isEmpty) {
      return l10n.emptyBarbell;
    }

    // Format as "20 + 10 + 5 per side"
    final platesList = plateCounts.entries
        .map((entry) {
          final weight = entry.key;
          final count = entry.value;
          if (count == 1) {
            return weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1);
          }
          return '${count}x${weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1)}';
        })
        .join(' + ');

    return l10n.warmupPerSide(platesList);
  }

  void _openCustomizationModal() {
    HapticFeedback.lightImpact();
    WarmupCustomizationModal.show(
      context: context,
      initialSets: _warmupSets,
      onConfirm: (updatedSets) {
        setState(() {
          _warmupSets = updatedSets;
        });
        HapticFeedback.mediumImpact();
        SnackBarService.showSuccess(
          context,
          context.l10n.warmupSetsAdded('${updatedSets.length}'),
        );
      },
    );
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    HapticFeedback.lightImpact();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_warmupSets.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          // Collapsed header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: l10n.warmup,
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.warmupRecommended,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.warmupSetsTarget(
                              _warmupSets.length,
                              widget.workingWeight,
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                      color: context.colors.onSurfaceVariant,
                      size: AppIconSize.medium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warmup sets list
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: _warmupSets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final warmupSet = entry.value;

                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Set number badge
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: context.colors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.xs,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),

                                  // Weight and reps
                                  Expanded(
                                    child: Text(
                                      '${warmupSet.weight}kg × ${warmupSet.reps}',
                                      style:
                                          context.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // Percentage badge
                                  if (warmupSet.percentage > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.primary
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.xs,
                                        ),
                                      ),
                                      child: Text(
                                        '${warmupSet.percentage}%',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // Plates per side
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _formatPlatesPerSide(warmupSet.weight),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Science note
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppSpacing.md),
                      ),
                    ),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.science,
                          semanticLabel: l10n.warmupScienceBased,
                          size: AppIconSize.tiny,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.warmupScienceBased,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Customize button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openCustomizationModal,
                            icon: SemanticIcon(
                              icon: AppIcons.edit,
                              semanticLabel: l10n.warmupCustomize,
                              size: AppIconSize.tiny,
                              color: context.colors.primary,
                            ),
                            label: Text(l10n.warmupCustomize),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: context.colors.primary,
                              side: BorderSide(color: context.colors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Add All button
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addAllWarmupSets,
                            icon: SemanticIcon(
                              icon: AppIcons.add,
                              semanticLabel: l10n.warmupAddAll,
                              size: AppIconSize.tiny,
                              color: context.colors.onPrimary,
                            ),
                            label: Text(l10n.warmupAddAll),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  


  void _addAllWarmupSets() {
    final l10n = AppLocalizations.of(context);
    final sets = _warmupSets.map((warmup) {
      return ExerciseSet(
        setNumber: 0, // Will be assigned by parent
        reps: warmup.reps,
        weight: warmup.weight,
        isCompleted: false,
        isWarmup: true,
      );
    }).toList();
    
    widget.onAddWarmupSets(sets);
    _toggleExpanded();
    
    HapticFeedback.mediumImpact();
    
    SnackBarService.showSuccess(
      context,
      l10n.warmupSetsAdded('${sets.length}'),
    );
  }
  
}

class WarmupSet {

  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });
  final double weight;
  final int reps;
  final int percentage;
}

