/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Muscle Heatmap Widget - Interactive body diagram with heat-mapped muscles
///
/// **Features**:
/// - Front/back view toggle
/// - Heat-mapped muscle regions (cold blue → warm red)
/// - Tap detection with muscle details
/// - Smooth animations between views
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_heatmap_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Muscle Heatmap Widget - Shows interactive body diagram with heat values
///
/// **Usage**:
/// ```dart
/// MuscleHeatmapWidget(
///   heatmapData: MuscleHeatmapData.fromVolumePercentages(
///     muscleVolumePercentages: stats.muscleVolumePercentages,
///   ),
/// )
/// ```
class MuscleHeatmapWidget extends StatefulWidget {
  const MuscleHeatmapWidget({
    required this.heatmapData,
    super.key,
  });

  final MuscleHeatmapData heatmapData;

  @override
  State<MuscleHeatmapWidget> createState() => _MuscleHeatmapWidgetState();
}

class _MuscleHeatmapWidgetState extends State<MuscleHeatmapWidget>
    with SingleTickerProviderStateMixin {
  BodyView _currentView = BodyView.front;
  String? _selectedMuscle;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      if (_currentView == BodyView.front) {
        _currentView = BodyView.back;
        _flipController.forward();
      } else {
        _currentView = BodyView.front;
        _flipController.reverse();
      }
      _selectedMuscle = null; // Clear selection on flip
    });
  }

  void _onMuscleTap(String muscleName) {
    setState(() {
      _selectedMuscle = _selectedMuscle == muscleName ? null : muscleName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      children: [
        // View Toggle Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _toggleView,
              icon: Icon(
                AppIcons.swapHoriz,
                size: AppIconSize.small,
              ),
              label: Text(
                _currentView == BodyView.front ? l10n.backView : l10n.frontView,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Body Diagram with Heatmap
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * 3.14159; // π radians = 180°
            final isBackVisible = angle > 1.5708; // π/2 radians = 90°

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(angle),
              child: AspectRatio(
                aspectRatio: 0.5, // 2:1 height:width ratio (tall body)
                child: GestureDetector(
                  onTapUp: (details) => _handleTap(details, context),
                  child: CustomPaint(
                    painter: MuscleHeatmapPainter(
                      heatmapData: widget.heatmapData,
                      currentView: _currentView,
                      selectedMuscle: _selectedMuscle,
                      colorScheme: colorScheme,
                      isBackVisible: isBackVisible,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
          },
        ),

        // Selected Muscle Details
        if (_selectedMuscle != null) ...[
          const SizedBox(height: 16),
          _MuscleDetailsCard(
            muscleName: _selectedMuscle!,
            heatValue: widget.heatmapData.getMuscleHeat(_selectedMuscle!),
          ),
        ],

        // Heat Legend
        const SizedBox(height: 16),
        _HeatLegend(),
      ],
    );
  }

  void _handleTap(TapUpDetails details, BuildContext context) {
    // Get tap position as percentage of widget size
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final tapPosition = details.localPosition;
    final percentX = (tapPosition.dx / size.width) * 100;
    final percentY = (tapPosition.dy / size.height) * 100;

    // Check which muscle region was tapped
    for (final entry in widget.heatmapData.muscleRegions.entries) {
      for (final region in entry.value) {
        if (region.view == _currentView &&
            region.containsPoint(Offset(percentX, percentY))) {
          _onMuscleTap(entry.key);
          return;
        }
      }
    }

    // Tap outside any region - clear selection
    setState(() {
      _selectedMuscle = null;
    });
  }
}

/// Custom Painter for Muscle Heatmap
class MuscleHeatmapPainter extends CustomPainter {
  const MuscleHeatmapPainter({
    required this.heatmapData,
    required this.currentView,
    required this.colorScheme,
    required this.isBackVisible,
    this.selectedMuscle,
  });

  final MuscleHeatmapData heatmapData;
  final BodyView currentView;
  final ColorScheme colorScheme;
  final String? selectedMuscle;
  final bool isBackVisible;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw body outline
    _drawBodyOutline(canvas, size);

    // Draw muscle regions with heat colors
    for (final entry in heatmapData.muscleRegions.entries) {
      final muscleName = entry.key;
      final regions = entry.value;

      for (final region in regions) {
        if (region.view == currentView) {
          final heatValue = heatmapData.getMuscleHeat(muscleName);
          final heatColor = heatmapData.getHeatColor(heatValue);
          final isSelected = muscleName == selectedMuscle;

          _drawMuscleRegion(
            canvas,
            size,
            region,
            heatColor,
            isSelected,
          );
        }
      }
    }
  }

  void _drawBodyOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Simple body outline (percentage-based)
    final headTop = _percentToPixel(Offset(50, 5), size);
    final headBottom = _percentToPixel(Offset(50, 12), size);
    final shoulderLeft = _percentToPixel(Offset(20, 15), size);
    final shoulderRight = _percentToPixel(Offset(80, 15), size);
    final waist = _percentToPixel(Offset(50, 50), size);
    final hipLeft = _percentToPixel(Offset(35, 50), size);
    final hipRight = _percentToPixel(Offset(65, 50), size);
    final footLeft = _percentToPixel(Offset(40, 95), size);
    final footRight = _percentToPixel(Offset(60, 95), size);

    // Head (circle)
    canvas.drawCircle(headTop, (headBottom.dy - headTop.dy) / 2, paint);

    // Body outline
    path
      ..moveTo(shoulderLeft.dx, shoulderLeft.dy)
      ..lineTo(shoulderRight.dx, shoulderRight.dy)
      ..lineTo(hipRight.dx, hipRight.dy)
      ..lineTo(footRight.dx, footRight.dy)
      ..moveTo(footLeft.dx, footLeft.dy)
      ..lineTo(hipLeft.dx, hipLeft.dy)
      ..lineTo(shoulderLeft.dx, shoulderLeft.dy);

    canvas.drawPath(path, paint);
  }

  void _drawMuscleRegion(
    Canvas canvas,
    Size size,
    MuscleRegion region,
    Color heatColor,
    bool isSelected,
  ) {
    final path = Path();
    final points = region.pathPoints
        .map((percentOffset) => _percentToPixel(percentOffset, size))
        .toList();

    if (points.isEmpty) return;

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    // Fill with heat color
    final fillPaint = Paint()
      ..color = heatColor.withValues(alpha: isSelected ? 0.9 : 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Stroke (outline)
    final strokePaint = Paint()
      ..color = isSelected
          ? colorScheme.primary
          : colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3 : 1;

    canvas.drawPath(path, strokePaint);
  }

  Offset _percentToPixel(Offset percentOffset, Size size) {
    return Offset(
      (percentOffset.dx / 100) * size.width,
      (percentOffset.dy / 100) * size.height,
    );
  }

  @override
  bool shouldRepaint(MuscleHeatmapPainter oldDelegate) {
    return oldDelegate.selectedMuscle != selectedMuscle ||
        oldDelegate.currentView != currentView ||
        oldDelegate.isBackVisible != isBackVisible;
  }
}

/// Muscle Details Card - Shows details for selected muscle
class _MuscleDetailsCard extends StatelessWidget {
  const _MuscleDetailsCard({
    required this.muscleName,
    required this.heatValue,
  });

  final String muscleName;
  final double heatValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final heatmapData = MuscleHeatmapData.fromVolumePercentages(
      muscleVolumePercentages: {muscleName: heatValue},
    );
    final heatColor = heatmapData.getHeatColor(heatValue);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: heatColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: heatColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  muscleName.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Training intensity: ${heatValue.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Heat Legend - Shows color scale explanation
class _HeatLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      children: [
        Text(
          l10n.trainingIntensity,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, l10n.intensityLow, const Color(0xFF2196F3)),
            const SizedBox(width: 8),
            _buildLegendItem(context, l10n.intensityMedium, const Color(0xFFFFC107)),
            const SizedBox(width: 8),
            _buildLegendItem(context, l10n.intensityHigh, const Color(0xFFF44336)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
