/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Enhanced empty state widget riutilizzabile per tutta l'app
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Tipi di empty state disponibili
enum EmptyStateType {
  /// Info generale (blu)
  info,

  /// Motivazionale (primario del tema)
  motivational,

  /// Warning/Attenzione (arancione)
  warning,

  /// Successo (verde)
  success,

  /// Errore (rosso)
  error,

  /// Personalizzato (usa colore fornito)
  custom,
}

/// Widget per mostrare stati vuoti con stile e animazioni
///
/// Supporta:
/// - Icone animate
/// - Titolo e descrizione localizzati
/// - Quote motivazionali opzionali
/// - Pro tips opzionali
/// - Fino a 2 azioni (primaria e secondaria)
/// - Diversi tipi predefiniti con colori appropriati
/// - Animazioni di entrata smooth
class EnhancedEmptyState extends StatelessWidget {

  const EnhancedEmptyState({
    super.key,
    this.type = EmptyStateType.info,
    required this.icon,
    required this.title,
    required this.description,
    this.motivationalQuote,
    this.proTip,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.customColor,
    this.primaryActionIcon,
    this.secondaryActionIcon,
  });
  /// Tipo di empty state (determina colori e stile)
  final EmptyStateType type;

  /// Icona da mostrare
  final IconData icon;

  /// Titolo principale
  final String title;

  /// Sottotitolo/descrizione
  final String description;

  /// Quote motivazionale opzionale
  final String? motivationalQuote;

  /// Pro tip opzionale
  final String? proTip;

  /// Label per azione primaria
  final String? primaryActionLabel;

  /// Callback per azione primaria
  final VoidCallback? onPrimaryAction;

  /// Label per azione secondaria
  final String? secondaryActionLabel;

  /// Callback per azione secondaria
  final VoidCallback? onSecondaryAction;

  /// Colore custom (usato solo se type == EmptyStateType.custom)
  final Color? customColor;

  /// Icona per azione primaria
  final IconData? primaryActionIcon;

  /// Icona per azione secondaria
  final IconData? secondaryActionIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final effectiveColor = _getEffectiveColor(colorScheme);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona animata
            _buildAnimatedIcon(effectiveColor),

            const SizedBox(height: 24),

            // Titolo
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Descrizione
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Quote motivazionale
            if (motivationalQuote != null) ...[
              const SizedBox(height: 24),
              _buildMotivationalQuote(context, colorScheme),
            ],

            // Pro tip
            if (proTip != null) ...[
              const SizedBox(height: 16),
              _buildProTip(context, l10n),
            ],

            // Azioni
            if (primaryActionLabel != null || secondaryActionLabel != null) ...[
              const SizedBox(height: 32),
              _buildActions(context, effectiveColor),
            ],
          ],
        ),
      ),
    );
  }

  /// Determina il colore effettivo in base al tipo
  Color _getEffectiveColor(ColorScheme colorScheme) {
    switch (type) {
      case EmptyStateType.info:
        return colorScheme.primary;
      case EmptyStateType.motivational:
        return colorScheme.primary;
      case EmptyStateType.warning:
        return Colors.orange;
      case EmptyStateType.success:
        return colorScheme.success;
      case EmptyStateType.error:
        return colorScheme.error;
      case EmptyStateType.custom:
        return customColor ?? colorScheme.primary;
    }
  }

  /// Costruisce l'icona con animazione
  Widget _buildAnimatedIcon(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
        );
      },
    );
  }

  /// Costruisce la card con la quote motivazionale
  Widget _buildMotivationalQuote(BuildContext context, ColorScheme colorScheme) {
    final quoteColor = type == EmptyStateType.motivational
        ? colorScheme.secondary
        : _getEffectiveColor(colorScheme);

    return Card(
      color: quoteColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              AppIcons.formatQuote,
              color: quoteColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              motivationalQuote!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: quoteColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce la card con il pro tip
  Widget _buildProTip(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              AppIcons.tip,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proTip,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    proTip!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Costruisce i bottoni di azione
  Widget _buildActions(BuildContext context, Color effectiveColor) {
    return Column(
      children: [
        // Azione primaria
        if (primaryActionLabel != null && onPrimaryAction != null)
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onPrimaryAction!();
            },
            icon: Icon(primaryActionIcon ?? AppIcons.forward),
            label: Text(primaryActionLabel!),
            style: FilledButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: context.colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

        // Azione secondaria
        if (secondaryActionLabel != null && onSecondaryAction != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSecondaryAction!();
            },
            icon: Icon(secondaryActionIcon ?? AppIcons.info),
            label: Text(secondaryActionLabel!),
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveColor,
              side: BorderSide(color: effectiveColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }
}
