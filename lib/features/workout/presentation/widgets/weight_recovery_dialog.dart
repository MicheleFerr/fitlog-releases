import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

enum WeightRecoveryOption {
  exact,        // Si (esatti)
  increase,     // Si +2.5%
  decrease,     // Si -2.5%
  none,         // No (vuoto)
}

class WeightRecoveryDialog extends ConsumerStatefulWidget {

  const WeightRecoveryDialog({
    super.key,
    required this.previousWorkout,
    required this.lastSessionDate,
    required this.daysSinceLastSession,
  });
  final Workout previousWorkout;
  final DateTime lastSessionDate;
  final int daysSinceLastSession;

  @override
  ConsumerState<WeightRecoveryDialog> createState() => _WeightRecoveryDialogState();

  /// Mostra il dialog e ritorna l'opzione selezionata
  static Future<WeightRecoveryOption?> show(
    BuildContext context,
    Workout previousWorkout,
    DateTime lastSessionDate,
    int daysSinceLastSession,
  ) {
    return showDialog<WeightRecoveryOption>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WeightRecoveryDialog(
        previousWorkout: previousWorkout,
        lastSessionDate: lastSessionDate,
        daysSinceLastSession: daysSinceLastSession,
      ),
    );
  }
}

class _WeightRecoveryDialogState extends ConsumerState<WeightRecoveryDialog> {
  WeightRecoveryOption? _selectedOption;
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _showPreview && _selectedOption != null
            ? _buildPreview(context, theme, l10n)
            : _buildOptions(context, theme, l10n),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.history,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recoverWeights,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLastSessionText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Session Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.workout,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.previousWorkout.exercises.length} esercizi',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  AppIcons.calendar,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.daysSinceLastSession} giorni fa',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Options Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildOptionCard(
                theme,
                l10n,
                icon: AppIcons.trendUp,
                label: 'Si +2.5%',
                subtitle: l10n.progressiveOverload,
                color: context.colors.success,
                option: WeightRecoveryOption.increase,
              ),
              _buildOptionCard(
                theme,
                l10n,
                icon: AppIcons.complete,
                label: 'Si (esatti)',
                subtitle: l10n.sameWeights,
                color: theme.colorScheme.primary,
                option: WeightRecoveryOption.exact,
              ),
              _buildOptionCard(
                theme,
                l10n,
                icon: AppIcons.trendDown,
                label: 'Si -2.5%',
                subtitle: 'Deload',
                color: context.colors.secondary,
                option: WeightRecoveryOption.decrease,
              ),
              _buildOptionCard(
                theme,
                l10n,
                icon: AppIcons.close,
                label: 'No',
                subtitle: l10n.startEmpty,
                color: theme.colorScheme.outline,
                option: WeightRecoveryOption.none,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required WeightRecoveryOption option,
  }) {
    final isSelected = _selectedOption == option;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedOption = option;
        });

        // Se l'opzione è "None", chiudi subito senza preview
        if (option == WeightRecoveryOption.none) {
          Navigator.of(context).pop(option);
          return;
        }

        // Altrimenti mostra la preview dopo un breve delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showPreview = true;
            });
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final multiplier = _getMultiplier(_selectedOption!);
    final previewExercises = _generatePreview(multiplier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getOptionColor(theme, _selectedOption!).withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Icon(
                _getOptionIcon(_selectedOption!),
                color: _getOptionColor(theme, _selectedOption!),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.previewWeights(_getOptionLabel(_selectedOption!)),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${previewExercises.length} esercizi verranno aggiornati',
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

        // Preview List
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: previewExercises.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final preview = previewExercises[index];
              return _buildPreviewItem(theme, preview);
            },
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showPreview = false;
                      _selectedOption = null;
                    });
                  },
                  child: Text(context.l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(_selectedOption);
                  },
                  icon: const Icon(AppIcons.check),
                  label: Text(context.l10n.confirm),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(ThemeData theme, _PreviewItem preview) {
    final hasChange = preview.oldWeight != preview.newWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          preview.exerciseName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Old weight
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${preview.oldWeight}kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: hasChange ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            if (hasChange) ...[
              const SizedBox(width: 8),
              Icon(
                AppIcons.arrowForward,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              // New weight
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getOptionColor(theme, _selectedOption!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getOptionColor(theme, _selectedOption!),
                  ),
                ),
                child: Text(
                  '${preview.newWeight}kg',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getOptionColor(theme, _selectedOption!),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Sets info
            Text(
              '${preview.setsCount}×${preview.reps}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getLastSessionText() {
    final l10n = AppLocalizations.of(context);

    if (widget.daysSinceLastSession == 0) {
      return l10n.lastSessionToday;
    } else if (widget.daysSinceLastSession == 1) {
      return l10n.lastSessionYesterday;
    } else if (widget.daysSinceLastSession < 7) {
      return 'Ultima sessione: ${widget.daysSinceLastSession} giorni fa';
    } else {
      final weeks = (widget.daysSinceLastSession / 7).floor();
      return 'Ultima sessione: $weeks ${weeks == 1 ? 'settimana' : 'settimane'} fa';
    }
  }

  double _getMultiplier(WeightRecoveryOption option) {
    switch (option) {
      case WeightRecoveryOption.increase:
        return 1.025; // +2.5%
      case WeightRecoveryOption.exact:
        return 1.0;
      case WeightRecoveryOption.decrease:
        return 0.975; // -2.5%
      case WeightRecoveryOption.none:
        return 0.0;
    }
  }

  List<_PreviewItem> _generatePreview(double multiplier) {
    final List<_PreviewItem> previews = [];

    for (final exercise in widget.previousWorkout.exercises) {
      if (exercise.sets.isEmpty) continue;

      // Usa il peso del primo set come riferimento
      final firstSet = exercise.sets.first;
      final oldWeight = firstSet.weight;
      final reps = firstSet.reps;

      // Skip exercises without weight or reps
      if (oldWeight == null || reps == null) continue;

      // Applica il moltiplicatore
      final newWeight = _smartRound(oldWeight * multiplier);

      previews.add(_PreviewItem(
        exerciseName: exercise.name,
        oldWeight: oldWeight,
        newWeight: newWeight,
        setsCount: exercise.sets.length,
        reps: reps,
      ));
    }

    return previews;
  }

  /// Arrotondamento intelligente basato su dischi comuni
  /// - Fino a 20kg: arrotonda a 0.5kg (manubri)
  /// - Oltre 20kg: arrotonda a 2.5kg (bilanciere con dischi 1.25kg)
  double _smartRound(double weight) {
    if (weight <= 0) return weight;

    if (weight < 20) {
      // Arrotonda a 0.5kg (manubri)
      return (weight * 2).round() / 2;
    } else {
      // Arrotonda a 2.5kg (bilanciere)
      return (weight / 2.5).round() * 2.5;
    }
  }

  String _getOptionLabel(WeightRecoveryOption option) {
    switch (option) {
      case WeightRecoveryOption.increase:
        return '+2.5%';
      case WeightRecoveryOption.exact:
        return 'esatti';
      case WeightRecoveryOption.decrease:
        return '-2.5%';
      case WeightRecoveryOption.none:
        return '';
    }
  }

  IconData _getOptionIcon(WeightRecoveryOption option) {
    switch (option) {
      case WeightRecoveryOption.increase:
        return AppIcons.trendUp;
      case WeightRecoveryOption.exact:
        return AppIcons.complete;
      case WeightRecoveryOption.decrease:
        return AppIcons.trendDown;
      case WeightRecoveryOption.none:
        return AppIcons.close;
    }
  }

  Color _getOptionColor(ThemeData theme, WeightRecoveryOption option) {
    switch (option) {
      case WeightRecoveryOption.increase:
        return context.colors.success;
      case WeightRecoveryOption.exact:
        return theme.colorScheme.primary;
      case WeightRecoveryOption.decrease:
        return context.colors.secondary;
      case WeightRecoveryOption.none:
        return theme.colorScheme.outline;
    }
  }
}

class _PreviewItem {

  _PreviewItem({
    required this.exerciseName,
    required this.oldWeight,
    required this.newWeight,
    required this.setsCount,
    required this.reps,
  });
  final String exerciseName;
  final double oldWeight;
  final double newWeight;
  final int setsCount;
  final int reps;
}
