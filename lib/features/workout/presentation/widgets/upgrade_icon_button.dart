/// Widget icona inline per upgrade esercizio
///
/// Mostra un'icona tappabile accanto al nome esercizio quando
/// esiste un match nel database ufficiale.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/upgrade_matches_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Icona upgrade inline per esercizio
///
/// Appare solo se l'esercizio ha un match disponibile nel database.
/// Tap apre il modal di upgrade rapido.
class UpgradeIconButton extends ConsumerWidget {
  const UpgradeIconButton({
    super.key,
    required this.exerciseName,
    required this.onTap,
  });

  /// Nome dell'esercizio da controllare
  final String exerciseName;

  /// Callback quando l'utente tappa l'icona
  final void Function(MergeCandidate candidate) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(upgradeMatchForExerciseProvider(exerciseName));

    // Non mostrare se non c'è match
    if (candidate == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: context.l10n.upgradeExerciseTooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(candidate);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.syncAlt,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 2),
              Text(
                '${(candidate.bestMatchScore * 100).toStringAsFixed(0)}%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante compatta solo icona (senza percentuale)
class UpgradeIconButtonCompact extends ConsumerWidget {
  const UpgradeIconButtonCompact({
    super.key,
    required this.exerciseName,
    required this.onTap,
  });

  final String exerciseName;
  final void Function(MergeCandidate candidate) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(upgradeMatchForExerciseProvider(exerciseName));

    if (candidate == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: context.l10n.upgradeExerciseTooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(candidate);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            AppIcons.syncAlt,
            size: AppIconSize.small,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
