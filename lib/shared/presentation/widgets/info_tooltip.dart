/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Info tooltip widget per spiegare metriche e concetti scientifici
library;

import 'package:flutter/material.dart';

/// Widget tooltip informativo per metriche scientifiche
///
/// Mostra un'icona info che, quando toccata, visualizza
/// una spiegazione della metrica in un tooltip
class InfoTooltip extends StatelessWidget {

  const InfoTooltip({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.iconSize = 18,
    this.iconColor,
  });
  /// Titolo della metrica
  final String title;

  /// Descrizione dettagliata
  final String description;

  /// Icona personalizzata (default: info_outline)
  final IconData? icon;

  /// Dimensione icona
  final double iconSize;

  /// Colore icona (default: onSurfaceVariant)
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = iconColor ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Tooltip(
      message: '$title\n\n$description',
      preferBelow: false,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onInverseSurface,
      ),
      child: GestureDetector(
        onTap: () => _showInfoDialog(context),
        child: Icon(
          icon ?? Icons.info_outline,
          size: iconSize,
          color: defaultColor,
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

/// Widget compatto per tooltip inline
///
/// Mostra solo l'icona info senza dialog, utile per layout compatti
class CompactInfoTooltip extends StatelessWidget {

  const CompactInfoTooltip({
    super.key,
    required this.message,
    this.icon,
    this.iconSize = 16,
  });
  final String message;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: message,
      preferBelow: false,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onInverseSurface,
      ),
      child: Icon(
        icon ?? Icons.help_outline,
        size: iconSize,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
