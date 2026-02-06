import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Badge compatto che mostra progress "X/Y"
///
/// Usato per coerenza visiva in tutti i tipi di esercizio:
/// - Single Exercise: "Sets (2/3)"
/// - Superset: "Rounds (1/4)"
/// - Dropset: "Stages (0/3)"
/// - RestPause: "Mini-sets (2/?)"
///
/// Supporta anche progress verso target (es. "15/20 reps")
///
/// **Design System Compliance:**
/// - Usa semantic colors da ColorSchemeExtensions
/// - Padding/border radius coerenti con chip design
class ProgressBadge extends StatelessWidget {
  const ProgressBadge({
    super.key,
    required this.completed,
    required this.total,
    this.label,
    this.suffix,
    this.showAsComplete = false,
    this.compact = false,
  });

  /// Numero di elementi completati
  final int completed;

  /// Numero totale di elementi (può essere 0 per "?")
  final int total;

  /// Label opzionale (es. "Sets", "Stages", "Reps")
  /// Se null, mostra solo "X/Y"
  final String? label;

  /// Suffisso opzionale (es. "reps", "kg")
  final String? suffix;

  /// Forza lo stato "completato" anche se completed < total
  /// Utile per RestPause dove il target è raggiungibile
  final bool showAsComplete;

  /// Versione compatta con padding ridotto
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isComplete = showAsComplete || (total > 0 && completed >= total);
    final isInProgress = completed > 0 && !isComplete;
    // isPending è implicito quando !isComplete && !isInProgress

    // Determina colori in base allo stato
    final backgroundColor = isComplete
        ? context.colors.exerciseCompletedContainer
        : isInProgress
            ? context.colors.exerciseInProgressContainer
            : context.colors.exercisePendingContainer;

    final textColor = isComplete
        ? context.colors.exerciseCompleted
        : isInProgress
            ? context.colors.exerciseInProgress
            : context.colors.exercisePending;

    // Costruisci il testo
    final totalDisplay = total > 0 ? total.toString() : '?';
    String text;
    if (label != null) {
      text = '$label ($completed/$totalDisplay)';
    } else if (suffix != null) {
      text = '$completed/$totalDisplay $suffix';
    } else {
      text = '$completed/$totalDisplay';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: compact ? 10 : null,
        ),
      ),
    );
  }
}

/// Variante del ProgressBadge con progress bar integrata
///
/// Utile per RestPause dove il progress verso target è più importante
/// del conteggio dei mini-sets
class ProgressBadgeWithBar extends StatelessWidget {
  const ProgressBadgeWithBar({
    super.key,
    required this.current,
    required this.target,
    this.label,
    this.suffix,
    this.barHeight = 6.0,
  });

  /// Valore corrente (es. reps completate)
  final int current;

  /// Valore target (es. reps obiettivo)
  final int target;

  /// Label opzionale sopra la barra
  final String? label;

  /// Suffisso per il testo (es. "reps")
  final String? suffix;

  /// Altezza della progress bar
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= target && target > 0;

    final barColor = isComplete
        ? context.colors.exerciseCompleted
        : context.colors.exerciseActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label != null)
              Text(
                label!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            Text(
              suffix != null ? '$current/$target $suffix' : '$current/$target',
              style: context.textTheme.labelSmall?.copyWith(
                color: isComplete
                    ? context.colors.exerciseCompleted
                    : context.colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: context.colors.exercisePendingContainer,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: barHeight,
          ),
        ),
      ],
    );
  }
}
