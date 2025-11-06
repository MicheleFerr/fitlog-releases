import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Horizontal bar chart for muscle balance visualization
///
/// Based on scientific research (Baz-Valle 2022, Schoenfeld 2017):
/// - Optimal balance: ~17% per major muscle group
/// - Primary volume = sets where muscle is main target
/// - Secondary volume = sets where muscle is synergist
class HorizontalMuscleBalanceChart extends StatelessWidget {

  const HorizontalMuscleBalanceChart({
    super.key,
    required this.muscleData,
    this.onMuscleGroupTap,
  });
  final Map<MuscleGroup, MuscleStrengthData> muscleData;
  final Function(MuscleGroup muscle)? onMuscleGroupTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = muscleData.entries.toList()
      ..sort((a, b) => b.value.currentStrength.compareTo(a.value.currentStrength));

    // Calculate total volume for percentage
    final totalVolume = muscleData.values.fold<double>(
      0, (sum, data) => sum + data.totalVolume,
    );

    return Column(
      children: [
        // Legend
        _buildLegend(theme),
        const SizedBox(height: 16),

        // Muscle bars
        ...sortedEntries.map((entry) {
          final muscleGroup = entry.key;
          final data = entry.value;
          final percentage = totalVolume > 0
            ? (data.totalVolume / totalVolume * 100).toDouble()
            : 0.0;

          return _buildMuscleBar(
            context,
            theme,
            muscleGroup,
            data,
            percentage,
          );
        }),

        const SizedBox(height: 16),

        // Reference line for optimal balance
        _buildOptimalReference(theme),
      ],
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          theme,
          'Primary',
          theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          theme,
          'Secondary',
          theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          theme,
          'Target: 17%',
          theme.colorScheme.tertiary,
          isDashed: true,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    ThemeData theme,
    String label,
    Color color, {
    bool isDashed = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
            ? CustomPaint(
                painter: DashedLinePainter(color: color),
              )
            : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleBar(
    BuildContext context,
    ThemeData theme,
    MuscleGroup muscleGroup,
    MuscleStrengthData data,
    double percentage,
  ) {
    final isBalanced = (percentage - 17).abs() < 3; // Within 3% of optimal
    final isUnderworked = percentage < 14;
    final isOverworked = percentage > 20;

    // Use real primary/secondary volume data (Baz-Valle 2022 methodology)
    final totalVolume = data.primaryVolume + data.secondaryVolume;
    final primaryPercentage = totalVolume > 0
      ? (data.primaryVolume / totalVolume * percentage)
      : 0;
    // Secondary percentage is calculated implicitly in gradient (percentage - primaryPercentage)

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onMuscleGroupTap != null
          ? () => onMuscleGroupTap!(muscleGroup)
          : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Muscle name and percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getMuscleDisplayName(muscleGroup),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isBalanced
                            ? context.colors.success
                            : isUnderworked
                              ? context.colors.secondary
                              : isOverworked
                                ? context.colors.error
                                : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isBalanced
                          ? AppIcons.complete
                          : isUnderworked
                            ? AppIcons.arrowUpward
                            : AppIcons.arrowDownward,
                        size: 16,
                        color: isBalanced
                          ? context.colors.success
                          : isUnderworked
                            ? context.colors.secondary
                            : context.colors.error,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Horizontal bar with primary/secondary segments
              Stack(
                children: [
                  // Background bar
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Primary volume bar
                  FractionallySizedBox(
                    widthFactor: (primaryPercentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Secondary volume bar (stacked on top)
                  FractionallySizedBox(
                    widthFactor: (percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.4),
                          ],
                          stops: [
                            (primaryPercentage / percentage).clamp(0.0, 1.0),
                            (primaryPercentage / percentage).clamp(0.0, 1.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Target line (17%)
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.17 - 32, // Adjust for padding
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Volume info
              Text(
                '${(data.totalVolume / 1000).toStringAsFixed(1)}k kg total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimalReference(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.tip,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Optimal balance: ~17% per muscle group. Research shows balanced training prevents injuries and maximizes growth (Baz-Valle 2022)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleDisplayName(MuscleGroup muscle) {
    // These labels are already localized in the ARB files
    switch (muscle) {
      case MuscleGroup.chest:
        return 'PETT (Pectorals)'; // Will be replaced by localized version
      case MuscleGroup.back:
        return 'DORSO (Back)';
      case MuscleGroup.shoulders:
        return 'DELT (Deltoids)';
      case MuscleGroup.arms:
        return 'BRACCI (Arms)';
      case MuscleGroup.legs:
        return 'GAMBE (Legs)';
      case MuscleGroup.core:
        return 'CORE (Abs/Lower Back)';
    }
  }
}

/// Custom painter for dashed line in legend
class DashedLinePainter extends CustomPainter {

  DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
