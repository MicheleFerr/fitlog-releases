/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/explainability
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Widget che spiega come l'AI è arrivata a un insight
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart';

class InsightExplainerCard extends StatelessWidget {
  const InsightExplainerCard({
    required this.insight,
    super.key,
  });

  final AIInsight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '🔍 Come l\'AI è arrivata a questa conclusione', // TODO: Localize
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calculation steps
            if (insight.dataPoints != null) ...[
              _buildSection(
                context,
                '📊 Dati Analizzati', // TODO: Localize
                insight.dataPoints!,
              ),
            ],

            if (insight.detailedAnalysis != null) ...[
              const SizedBox(height: 16),
              _buildAnalysisSection(context, insight.detailedAnalysis!),
            ],

            // Thresholds explanation
            const SizedBox(height: 16),
            _buildThresholdsExplanation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: context.colors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAnalysisSection(BuildContext context, String analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 16,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Analisi Dettagliata', // TODO: Localize
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analysis,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdsExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                size: 16,
                color: context.colors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Soglie Scientifiche', // TODO: Localize
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildThresholdItem(
            context,
            'MEV',
            'Minimum Effective Volume: 10 sets/week',
            Colors.orange,
          ),
          _buildThresholdItem(
            context,
            'MAV',
            'Maximum Adaptive Volume: 15-20 sets/week',
            Colors.green,
          ),
          _buildThresholdItem(
            context,
            'MRV',
            'Maximum Recoverable Volume: 25 sets/week',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdItem(
    BuildContext context,
    String label,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
