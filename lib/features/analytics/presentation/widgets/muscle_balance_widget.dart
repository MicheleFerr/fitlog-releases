import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget showing muscle group balance analysis
class MuscleBalanceWidget extends StatelessWidget {

  const MuscleBalanceWidget({
    super.key,
    required this.balance,
  });
  final MuscleGroupBalance balance;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (balance.volumeDistribution.isEmpty) {
      return _buildEmptyState(context, localizations);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.equalizer,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.muscleBalance,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildBalanceIndicator(context, balance.isBalanced),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _MuscleBalanceRadarPainter(
                  balance: balance,
                  colorScheme: colorScheme,
                ),
                child: Container(),
              ),
            ),
            const SizedBox(height: 20),
            _buildMuscleGroupList(context, colorScheme),
            if (!balance.isBalanced) ...[
              const SizedBox(height: 16),
              _buildImbalanceWarning(context, localizations),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(BuildContext context, bool isBalanced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBalanced ? context.colors.success.withValues(alpha: 0.2) : context.colors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            size: 16,
            color: isBalanced ? context.colors.success : context.colors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            isBalanced ? 'Balanced' : 'Imbalanced',
            style: TextStyle(
              color: isBalanced ? context.colors.success : context.colors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupList(BuildContext context, ColorScheme colorScheme) {
    final groups = balance.volumeDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: groups.map((entry) {
        final imbalanceScore = balance.imbalanceScores[entry.key] ?? 0;
        final color = _getColorForImbalance(imbalanceScore, colorScheme);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: colorScheme.surfaceContainerLow,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImbalanceWarning(BuildContext context, AppLocalizations localizations) {
    final neglected = balance.mostNeglected;
    final overdeveloped = balance.overdeveloped;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.warningAmber,
            color: context.colors.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (neglected != null)
                  Text(
                    'Focus more on $neglected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (overdeveloped != null)
                  Text(
                    'Consider reducing $overdeveloped volume',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.equalizer,
                size: 48,
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No muscle group data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForImbalance(double score, ColorScheme colorScheme) {
    if (score < 0.5) {
      return colorScheme.error; // Very underdeveloped
    } else if (score < 0.7) {
      return colorScheme.secondary; // Underdeveloped
    } else if (score < 1.3) {
      return colorScheme.success; // Balanced
    } else if (score < 1.5) {
      return colorScheme.secondary; // Overdeveloped
    } else {
      return colorScheme.error; // Very overdeveloped
    }
  }
}

/// Custom painter for muscle balance radar chart
class _MuscleBalanceRadarPainter extends CustomPainter {

  _MuscleBalanceRadarPainter({
    required this.balance,
    required this.colorScheme,
  });
  final MuscleGroupBalance balance;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Define muscle groups in order
    final groups = ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core'];
    final angleStep = (2 * math.pi) / groups.length;
    
    // Draw grid
    _drawGrid(canvas, center, radius, groups.length);
    
    // Draw axes
    _drawAxes(canvas, center, radius, groups, angleStep);
    
    // Draw data
    _drawData(canvas, center, radius, groups, angleStep);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, int axes) {
    final paint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw concentric polygons
    for (int i = 1; i <= 5; i++) {
      final r = radius * (i / 5);
      final path = Path();
      
      for (int j = 0; j < axes; j++) {
        final angle = j * (2 * math.pi / axes) - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius, List<String> groups, double angleStep) {
    final paint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < groups.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      
      // Draw axis line
      canvas.drawLine(center, Offset(endX, endY), paint);
      
      // Draw label
      textPainter.text = TextSpan(
        text: groups[i],
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      
      final labelX = center.dx + (radius + 15) * math.cos(angle) - textPainter.width / 2;
      final labelY = center.dy + (radius + 15) * math.sin(angle) - textPainter.height / 2;
      
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  void _drawData(Canvas canvas, Offset center, double radius, List<String> groups, double angleStep) {
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < groups.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final value = balance.imbalanceScores[groups[i]] ?? 0;
      final normalizedValue = math.min(math.max(value, 0), 2); // Clamp between 0 and 2
      final r = radius * (normalizedValue / 2); // Normalize to 0-1 range for display
      
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);
    
    // Draw data points
    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < groups.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final value = balance.imbalanceScores[groups[i]] ?? 0;
      final normalizedValue = math.min(math.max(value, 0), 2);
      final r = radius * (normalizedValue / 2);
      
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}