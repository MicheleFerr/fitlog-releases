import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget to display APRE calculation metadata with transparency
///
/// Shows detailed information about the 1RM calculation including:
/// - Formula used (Brzycki)
/// - Number of data points
/// - Data age (days since median data)
/// - Standard deviation
/// - Confidence level with emoji and color coding
/// - Last calculation date
///
/// Design follows Material 3 principles with theme-aware colors
class CalculationMetadataDisplay extends StatelessWidget {
  /// The calculation results map from APREAutoRegulationService
  final Map<String, dynamic> calculations;

  /// Optional last calculation date (from exercise entity)
  final DateTime? lastCalculationDate;

  const CalculationMetadataDisplay({
    super.key,
    required this.calculations,
    this.lastCalculationDate,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = calculations['confidence'] as CalculationConfidence?;
    final dataPoints = calculations['dataPoints'] as int? ?? 0;
    final formula = calculations['formula'] as String? ?? 'Unknown';
    final dataAge = calculations['dataAge'] as Duration? ?? Duration.zero;
    final stdDev = calculations['standardDeviation'] as double? ?? 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: context.l10n.apreCalculationMetadata,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.apreCalculationMetadata,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Formula row
            _buildMetadataRow(
              context: context,
              icon: AppIcons.calculate,
              label: context.l10n.apreFormula,
              value: formula,
            ),
            SizedBox(height: 8),

            // Data points row
            _buildMetadataRow(
              context: context,
              icon: AppIcons.storage,
              label: context.l10n.apreDataPoints,
              value: '$dataPoints / 10',
              valueColor: _getDataPointsColor(context, dataPoints),
            ),
            SizedBox(height: 8),

            // Data age row
            _buildMetadataRow(
              context: context,
              icon: AppIcons.clock,
              label: context.l10n.apreDataAge,
              value: context.l10n.apreDaysAgo(dataAge.inDays),
              valueColor: _getDataAgeColor(context, dataAge.inDays),
            ),
            SizedBox(height: 8),

            // Standard deviation row
            _buildMetadataRow(
              context: context,
              icon: AppIcons.analytics,
              label: context.l10n.apreStandardDeviation,
              value: '±${stdDev.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 12),

            // Confidence row (emphasized)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getConfidenceBackgroundColor(context, confidence)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getConfidenceColor(context, confidence)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.verifiedUser,
                    semanticLabel: context.l10n.apreConfidence,
                    size: AppIconSize.small,
                    color: _getConfidenceColor(context, confidence),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.apreConfidence,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(context, confidence)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getConfidenceColor(context, confidence),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          confidence?.emoji ?? '❓',
                          style: const TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        Text(
                          _getConfidenceName(confidence),
                          style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getConfidenceColor(context, confidence),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Last calculation date (if available)
            if (lastCalculationDate != null) ...[
              SizedBox(height: 12),
              _buildMetadataRow(
                context: context,
                icon: AppIcons.calendar,
                label: context.l10n.apreLastCalculation,
                value: _formatDate(context, lastCalculationDate!),
                isSubdued: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single metadata row with icon, label, and value
  Widget _buildMetadataRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isSubdued = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.small,
          color: isSubdued
              ? context.colors.onSurfaceVariant
              : context.colors.onSurface,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gets color for confidence level (theme-aware)
  Color _getConfidenceColor(
      BuildContext context, CalculationConfidence? confidence) {
    if (confidence == null) return context.colors.onSurfaceVariant;

    switch (confidence) {
      case CalculationConfidence.veryHigh:
      case CalculationConfidence.high:
        return context.colors.tertiary; // Success green
      case CalculationConfidence.medium:
        return context.colors.secondary; // Warning orange
      case CalculationConfidence.low:
      case CalculationConfidence.unknown:
        return context.colors.error; // Error red
    }
  }

  /// Gets background color for confidence container
  Color _getConfidenceBackgroundColor(
      BuildContext context, CalculationConfidence? confidence) {
    return _getConfidenceColor(context, confidence);
  }

  /// Gets confidence level name (uppercase)
  String _getConfidenceName(CalculationConfidence? confidence) {
    if (confidence == null) return 'UNKNOWN';
    return confidence.name.toUpperCase();
  }

  /// Gets color for data points indicator
  Color _getDataPointsColor(BuildContext context, int dataPoints) {
    if (dataPoints >= 10) return context.colors.tertiary; // Good
    if (dataPoints >= 7) return context.colors.secondary; // Medium
    if (dataPoints >= 4) return context.colors.secondary; // Medium-low
    return context.colors.error; // Low
  }

  /// Gets color for data age indicator
  Color _getDataAgeColor(BuildContext context, int days) {
    if (days <= 7) return context.colors.tertiary; // Fresh
    if (days <= 14) return context.colors.secondary; // Acceptable
    if (days <= 30) return context.colors.secondary; // Getting old
    return context.colors.error; // Stale
  }

  /// Formats date relative to now (e.g., "2 days ago", "Today")
  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today'; // TODO: Add localization
    } else if (difference.inDays == 1) {
      return 'Yesterday'; // TODO: Add localization
    } else {
      return context.l10n.apreDaysAgo(difference.inDays);
    }
  }
}
