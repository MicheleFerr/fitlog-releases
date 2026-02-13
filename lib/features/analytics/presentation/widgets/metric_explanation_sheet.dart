/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Metric Explanation Sheet - Educational tooltips content
///
/// **Purpose**: Bottom sheet showing detailed explanation of a metric
/// **Features**:
/// - Simple title in Italian
/// - 2-3 sentence explanation
/// - Practical example with numbers
/// - "Why it matters" section
///
/// **Localization Note**:
/// Metric explanations are intentionally hardcoded in Italian (not in l10n)
/// for faster implementation in single-language app context.
/// If internationalization is needed in future, extract to:
/// - context.l10n.metricRpeTitle / metricRpeDescription / metricRpeExample / metricRpeWhy
/// - (same pattern for: 1rm, volume, tonnage, correlation)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Bottom sheet showing metric explanation
class MetricExplanationSheet extends StatelessWidget {
  const MetricExplanationSheet({
    super.key,
    required this.metricKey,
  });

  final String metricKey;

  /// Show the metric explanation sheet
  static Future<void> show(
    BuildContext context, {
    required String metricKey,
  }) {
    return ModalService.showSheet<void>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ✅ Semi-transparent background
      builder: (context) => MetricExplanationSheet(metricKey: metricKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metric = _getMetricData(context, metricKey);

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: safeMax,
      snap: true,
      snapSizes: [0.6, safeMax],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle - DraggableScrollableSheet handles drag automatically
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        metric.icon,
                        color: context.colors.primary,
                        size: AppIconSize.large,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        metric.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Description
                    _SectionCard(
                      icon: AppIcons.info,
                      title: 'Cos\'è',
                      child: Text(
                        metric.description,
                        style: context.textTheme.bodyLarge,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Example
                    _SectionCard(
                      icon: AppIcons.template,
                      title: 'Esempio pratico',
                      child: Text(
                        metric.example,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Why it matters
                    _SectionCard(
                      icon: AppIcons.star,
                      title: 'Perché è importante',
                      child: Text(
                        metric.why,
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get metric data based on key
  _MetricData _getMetricData(BuildContext context, String key) {
    switch (key) {
      case 'rpe':
        return const _MetricData(
          icon: AppIcons.speed,
          title: 'RPE - Quanto è stato difficile',
          description:
              'RPE significa "Rate of Perceived Exertion" (Scala dello Sforzo Percepito). '
              'È un numero da 1 a 10 che indica quanto ti sei sforzato durante una serie. '
              'Ti aiuta a capire se stai allenandoti con la giusta intensità.',
          example:
              'RPE 7 = "Potevo fare altre 3 ripetizioni"\n'
              'RPE 9 = "Potevo fare solo 1 ripetizione in più"\n'
              'RPE 10 = "Non potevo fare neanche una in più, cedimento totale"',
          why:
              'Usare l\'RPE ti permette di dosare l\'intensità dell\'allenamento senza dover sempre '
              'andare al cedimento muscolare. Questo riduce il rischio di infortuni e ottimizza il recupero.',
        );

      case '1rm':
        return const _MetricData(
          icon: AppIcons.weight,
          title: '1RM - Massimale',
          description:
              '1RM è il peso massimo che puoi sollevare per una singola ripetizione. '
              'FitLog lo stima automaticamente basandosi sulle tue serie normali, '
              'quindi non devi rischiare di testarlo direttamente.',
          example:
              'Se fai 3 serie da 8 ripetizioni con 80kg, il tuo 1RM stimato sarà circa 100kg. '
              'Questo significa che teoricamente potresti sollevare 100kg una volta sola.',
          why:
              'Il 1RM ti dà un numero semplice per misurare la tua forza massima e confrontare '
              'i tuoi progressi nel tempo. È particolarmente utile per esercizi fondamentali come panca, squat e stacco.',
        );

      case 'volume':
        return const _MetricData(
          icon: AppIcons.barChart,
          title: 'Volume - Lavoro totale',
          description:
              'Il volume è la quantità totale di lavoro che fai in un allenamento. '
              'Si calcola moltiplicando peso × ripetizioni × serie. '
              'Più volume fai, più stimolo dai ai muscoli per crescere.',
          example:
              'Panca Piana: 3 serie da 10 ripetizioni con 70kg\n'
              'Volume = 70 × 10 × 3 = 2.100 kg totali sollevati',
          why:
              'Il volume è uno dei fattori più importanti per l\'ipertrofia muscolare. '
              'Monitorarlo ti aiuta a capire se stai facendo abbastanza lavoro per crescere, '
              'senza esagerare e rischiare il sovrallenamento.',
        );

      case 'tonnage':
        return const _MetricData(
          icon: AppIcons.trendUp,
          title: 'Tonnellaggio - Volume totale',
          description:
              'Il tonnellaggio è il volume totale di un intero allenamento, '
              'sommando tutti gli esercizi. Esprime quanti kg hai sollevato in totale.',
          example:
              'Allenamento Push:\n'
              '- Panca: 2.100 kg\n'
              '- Military Press: 900 kg\n'
              '- Tricipiti: 600 kg\n'
              'Tonnellaggio totale = 3.600 kg (3.6 tonnellate!)',
          why:
              'Il tonnellaggio è un ottimo indicatore della densità dell\'allenamento. '
              'Aumentarlo nel tempo indica che stai diventando più forte o che stai facendo più lavoro.',
        );

      case 'r_squared':
      case 'correlation':
        return const _MetricData(
          icon: AppIcons.analytics,
          title: 'Correlazione - Relazione tra dati',
          description:
              'La correlazione misura quanto due cose sono collegate tra loro. '
              'Per esempio, "quando aumenti il peso, aumenta anche il tuo RPE?" '
              'Un valore alto significa che sono molto collegate.',
          example:
              'Correlazione forte (r² > 0.7): "Quando il peso sale, l\'RPE sale sempre"\n'
              'Correlazione debole (r² < 0.3): "Peso e RPE non sembrano collegati"\n'
              'Correlazione moderata: "Sono un po\' collegati, ma non sempre"',
          why:
              'Capire le correlazioni ti aiuta a identificare pattern nel tuo allenamento. '
              'Per esempio, se peso e RPE non sono collegati, potresti avere un\'ottima gestione dell\'intensità.',
        );

      default:
        return const _MetricData(
          icon: AppIcons.info,
          title: 'Metrica sconosciuta',
          description: 'Spiegazione non disponibile per questa metrica.',
          example: 'Nessun esempio disponibile.',
          why: 'Consulta la documentazione per maggiori informazioni.',
        );
    }
  }
}

/// Section card widget
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// Metric data model
class _MetricData {
  const _MetricData({
    required this.icon,
    required this.title,
    required this.description,
    required this.example,
    required this.why,
  });

  final IconData icon;
  final String title;
  final String description;
  final String example;
  final String why;
}
