/// GymBro TrackLog - Flutter Fitness App
///
/// ANATOMICAL BODY HEATMAP
/// Beautiful interactive body diagram with realistic muscle visualization.
///
/// Features:
/// - Anatomically accurate muscle regions using bezier curves
/// - Front/back view with smooth flip animation
/// - Heat-mapped muscles (blue → yellow → red)
/// - Tap to see muscle details
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Body view enum
enum AnatomicalView { front, back }

/// Muscle group data with heat value
class MuscleHeatData {
  const MuscleHeatData({
    required this.muscleHeatValues,
  });

  /// Create from volume percentages (converts 0-100 to 0-1)
  factory MuscleHeatData.fromVolumePercentages(
    Map<String, double> percentages,
  ) {
    final normalized = <String, double>{};
    for (final entry in percentages.entries) {
      // Normalize: muscle slug mapping
      final slug = _normalizeMuscleName(entry.key);
      normalized[slug] = (entry.value / 100).clamp(0.0, 1.0);
    }
    return MuscleHeatData(muscleHeatValues: normalized);
  }

  /// Map of muscle slug to heat value (0.0 - 1.0)
  final Map<String, double> muscleHeatValues;

  /// Get heat value for a muscle (default to 0 if not found)
  double getHeat(String slug) => muscleHeatValues[slug] ?? 0.0;

  static String _normalizeMuscleName(String name) {
    final lower = name.toLowerCase();
    // Map common names to slugs
    const mapping = {
      'chest': 'chest',
      'pectorals': 'chest',
      'pecs': 'chest',
      'shoulders': 'deltoids',
      'delts': 'deltoids',
      'deltoids': 'deltoids',
      'biceps': 'biceps',
      'triceps': 'triceps',
      'forearms': 'forearms',
      'forearm': 'forearms',
      'abs': 'abs',
      'abdominals': 'abs',
      'core': 'abs',
      'obliques': 'obliques',
      'quadriceps': 'quadriceps',
      'quads': 'quadriceps',
      'hamstrings': 'hamstrings',
      'calves': 'calves',
      'glutes': 'glutes',
      'gluteals': 'glutes',
      'back': 'upper_back',
      'upper back': 'upper_back',
      'lats': 'lats',
      'latissimus': 'lats',
      'lower back': 'lower_back',
      'traps': 'trapezius',
      'trapezius': 'trapezius',
      'adductors': 'adductors',
      'abductors': 'abductors',
      'neck': 'neck',
    };
    return mapping[lower] ?? lower;
  }
}

/// Anatomical Body Heatmap Widget
///
/// Displays a realistic human body diagram with heat-mapped muscles.
class AnatomicalBodyHeatmap extends StatefulWidget {
  const AnatomicalBodyHeatmap({
    required this.heatData,
    this.onMuscleTap,
    super.key,
  });

  final MuscleHeatData heatData;
  final void Function(String muscleSlug)? onMuscleTap;

  @override
  State<AnatomicalBodyHeatmap> createState() => _AnatomicalBodyHeatmapState();
}

class _AnatomicalBodyHeatmapState extends State<AnatomicalBodyHeatmap>
    with SingleTickerProviderStateMixin {
  AnatomicalView _currentView = AnatomicalView.front;
  String? _selectedMuscle;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleView() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_currentView == AnatomicalView.front) {
        _currentView = AnatomicalView.back;
        _flipController.forward();
      } else {
        _currentView = AnatomicalView.front;
        _flipController.reverse();
      }
      _selectedMuscle = null;
    });
  }

  void _onMuscleTap(String muscleSlug) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMuscle = _selectedMuscle == muscleSlug ? null : muscleSlug;
    });
    widget.onMuscleTap?.call(muscleSlug);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // View toggle
        Center(
          child: FilledButton.tonalIcon(
            onPressed: _toggleView,
            icon: const Icon(AppIcons.swapHoriz, size: AppIconSize.small),
            label: Text(
              _currentView == AnatomicalView.front
                  ? l10n.backView
                  : l10n.frontView,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Body diagram
        Expanded(
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final showBack = angle > math.pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildBodyDiagram(AnatomicalView.back),
                      )
                    : _buildBodyDiagram(AnatomicalView.front),
              );
            },
          ),
        ),

        // Selected muscle card
        if (_selectedMuscle != null) ...[
          const SizedBox(height: 12),
          _MuscleDetailCard(
            muscleSlug: _selectedMuscle!,
            heatValue: widget.heatData.getHeat(_selectedMuscle!),
          ),
        ],

        // Heat legend
        const SizedBox(height: 12),
        const _HeatLegend(),
      ],
    );
  }

  Widget _buildBodyDiagram(AnatomicalView view) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) => _handleTap(details, constraints.biggest, view),
          child: CustomPaint(
            size: constraints.biggest,
            painter: _AnatomicalBodyPainter(
              view: view,
              heatData: widget.heatData,
              selectedMuscle: _selectedMuscle,
              colorScheme: context.colors,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, Size size, AnatomicalView view) {
    final tapPos = details.localPosition;
    final normalizedX = tapPos.dx / size.width;
    final normalizedY = tapPos.dy / size.height;

    // Check which muscle was tapped
    final regions = view == AnatomicalView.front
        ? _AnatomicalPaths.frontMuscles
        : _AnatomicalPaths.backMuscles;

    for (final entry in regions.entries) {
      if (_isPointInMuscle(normalizedX, normalizedY, entry.value)) {
        _onMuscleTap(entry.key);
        return;
      }
    }

    // Clear selection if tapped outside
    setState(() => _selectedMuscle = null);
  }

  bool _isPointInMuscle(double x, double y, _MuscleRegion region) {
    // Simple bounding box check + center distance
    final bounds = region.bounds;
    if (x < bounds.left ||
        x > bounds.right ||
        y < bounds.top ||
        y > bounds.bottom) {
      return false;
    }

    // Check distance from center
    final center = region.center;
    final dx = x - center.dx;
    final dy = y - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance < region.tapRadius;
  }
}

/// Custom painter for anatomical body
class _AnatomicalBodyPainter extends CustomPainter {
  _AnatomicalBodyPainter({
    required this.view,
    required this.heatData,
    required this.colorScheme,
    this.selectedMuscle,
  });

  final AnatomicalView view;
  final MuscleHeatData heatData;
  final ColorScheme colorScheme;
  final String? selectedMuscle;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw body outline first
    _drawBodyOutline(canvas, size);

    // Draw muscles
    final muscles = view == AnatomicalView.front
        ? _AnatomicalPaths.frontMuscles
        : _AnatomicalPaths.backMuscles;

    for (final entry in muscles.entries) {
      final slug = entry.key;
      final region = entry.value;
      final heat = heatData.getHeat(slug);
      final isSelected = slug == selectedMuscle;

      _drawMuscle(canvas, size, region, heat, isSelected);
    }
  }

  void _drawBodyOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = _AnatomicalPaths.bodyOutline(size, view);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawMuscle(
    Canvas canvas,
    Size size,
    _MuscleRegion region,
    double heat,
    bool isSelected,
  ) {
    final path = region.getPath(size);
    final color = _getHeatColor(heat);

    // Fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: isSelected ? 0.85 : 0.65)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = isSelected ? colorScheme.primary : color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.0;

    canvas.drawPath(path, strokePaint);
  }

  Color _getHeatColor(double heat) {
    // Cold (blue) → Medium (yellow) → Hot (red)
    if (heat < 0.5) {
      // Blue to Yellow
      final t = heat * 2;
      return Color.lerp(
        const Color(0xFF2196F3), // Blue
        const Color(0xFFFFC107), // Amber
        t,
      )!;
    } else {
      // Yellow to Red
      final t = (heat - 0.5) * 2;
      return Color.lerp(
        const Color(0xFFFFC107), // Amber
        const Color(0xFFF44336), // Red
        t,
      )!;
    }
  }

  @override
  bool shouldRepaint(_AnatomicalBodyPainter oldDelegate) {
    return oldDelegate.view != view ||
        oldDelegate.selectedMuscle != selectedMuscle ||
        oldDelegate.heatData != heatData;
  }
}

/// Muscle region definition
class _MuscleRegion {
  const _MuscleRegion({
    required this.pathBuilder,
    required this.bounds,
    required this.center,
    this.tapRadius = 0.08,
  });

  final Path Function(Size size) pathBuilder;
  final Rect bounds; // Normalized 0-1 bounds
  final Offset center; // Normalized 0-1 center
  final double tapRadius;

  Path getPath(Size size) => pathBuilder(size);
}

/// Anatomical path definitions
class _AnatomicalPaths {
  // ============================================
  // BODY OUTLINE
  // ============================================
  static Path bodyOutline(Size size, AnatomicalView view) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Head
    final headCenterX = w * 0.5;
    final headCenterY = h * 0.06;
    final headRadius = w * 0.08;
    path.addOval(Rect.fromCircle(
      center: Offset(headCenterX, headCenterY),
      radius: headRadius,
    ));

    // Neck
    path.moveTo(w * 0.46, h * 0.11);
    path.lineTo(w * 0.46, h * 0.14);
    path.moveTo(w * 0.54, h * 0.11);
    path.lineTo(w * 0.54, h * 0.14);

    // Torso
    path.moveTo(w * 0.32, h * 0.16);
    path.quadraticBezierTo(w * 0.25, h * 0.18, w * 0.22, h * 0.22);
    path.lineTo(w * 0.22, h * 0.24);
    path.quadraticBezierTo(w * 0.18, h * 0.26, w * 0.15, h * 0.32);
    path.lineTo(w * 0.20, h * 0.28);
    path.lineTo(w * 0.28, h * 0.42);
    path.quadraticBezierTo(w * 0.30, h * 0.48, w * 0.35, h * 0.50);
    path.lineTo(w * 0.38, h * 0.52);
    path.lineTo(w * 0.40, h * 0.55);

    // Left leg
    path.quadraticBezierTo(w * 0.38, h * 0.65, w * 0.36, h * 0.75);
    path.quadraticBezierTo(w * 0.35, h * 0.85, w * 0.36, h * 0.95);
    path.lineTo(w * 0.44, h * 0.95);
    path.quadraticBezierTo(w * 0.45, h * 0.85, w * 0.46, h * 0.75);
    path.quadraticBezierTo(w * 0.48, h * 0.65, w * 0.48, h * 0.55);

    // Crotch
    path.lineTo(w * 0.52, h * 0.55);

    // Right leg
    path.quadraticBezierTo(w * 0.52, h * 0.65, w * 0.54, h * 0.75);
    path.quadraticBezierTo(w * 0.55, h * 0.85, w * 0.56, h * 0.95);
    path.lineTo(w * 0.64, h * 0.95);
    path.quadraticBezierTo(w * 0.65, h * 0.85, w * 0.64, h * 0.75);
    path.quadraticBezierTo(w * 0.62, h * 0.65, w * 0.60, h * 0.55);

    path.lineTo(w * 0.62, h * 0.52);
    path.lineTo(w * 0.65, h * 0.50);
    path.quadraticBezierTo(w * 0.70, h * 0.48, w * 0.72, h * 0.42);
    path.lineTo(w * 0.80, h * 0.28);
    path.lineTo(w * 0.85, h * 0.32);
    path.quadraticBezierTo(w * 0.82, h * 0.26, w * 0.78, h * 0.24);
    path.lineTo(w * 0.78, h * 0.22);
    path.quadraticBezierTo(w * 0.75, h * 0.18, w * 0.68, h * 0.16);

    // Close at neck
    path.quadraticBezierTo(w * 0.58, h * 0.14, w * 0.54, h * 0.14);
    path.lineTo(w * 0.46, h * 0.14);
    path.quadraticBezierTo(w * 0.42, h * 0.14, w * 0.32, h * 0.16);

    return path;
  }

  // ============================================
  // FRONT VIEW MUSCLES
  // ============================================
  static final Map<String, _MuscleRegion> frontMuscles = {
    // CHEST (Pectorals)
    'chest': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.30, 0.17, 0.70, 0.30),
      center: const Offset(0.50, 0.23),
      tapRadius: 0.12,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left pec
        path.moveTo(w * 0.46, h * 0.17);
        path.quadraticBezierTo(w * 0.38, h * 0.18, w * 0.32, h * 0.20);
        path.quadraticBezierTo(w * 0.28, h * 0.23, w * 0.30, h * 0.28);
        path.quadraticBezierTo(w * 0.35, h * 0.30, w * 0.46, h * 0.28);
        path.close();

        // Right pec
        path.moveTo(w * 0.54, h * 0.17);
        path.quadraticBezierTo(w * 0.62, h * 0.18, w * 0.68, h * 0.20);
        path.quadraticBezierTo(w * 0.72, h * 0.23, w * 0.70, h * 0.28);
        path.quadraticBezierTo(w * 0.65, h * 0.30, w * 0.54, h * 0.28);
        path.close();

        return path;
      },
    ),

    // SHOULDERS (Deltoids)
    'deltoids': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.18, 0.15, 0.82, 0.25),
      center: const Offset(0.50, 0.20),
      tapRadius: 0.10,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left deltoid
        path.moveTo(w * 0.30, h * 0.17);
        path.quadraticBezierTo(w * 0.24, h * 0.16, w * 0.20, h * 0.19);
        path.quadraticBezierTo(w * 0.18, h * 0.22, w * 0.22, h * 0.26);
        path.quadraticBezierTo(w * 0.26, h * 0.25, w * 0.30, h * 0.22);
        path.close();

        // Right deltoid
        path.moveTo(w * 0.70, h * 0.17);
        path.quadraticBezierTo(w * 0.76, h * 0.16, w * 0.80, h * 0.19);
        path.quadraticBezierTo(w * 0.82, h * 0.22, w * 0.78, h * 0.26);
        path.quadraticBezierTo(w * 0.74, h * 0.25, w * 0.70, h * 0.22);
        path.close();

        return path;
      },
    ),

    // BICEPS
    'biceps': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.14, 0.24, 0.86, 0.38),
      center: const Offset(0.50, 0.31),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left bicep
        path.moveTo(w * 0.22, h * 0.26);
        path.quadraticBezierTo(w * 0.18, h * 0.28, w * 0.16, h * 0.32);
        path.quadraticBezierTo(w * 0.15, h * 0.36, w * 0.18, h * 0.38);
        path.quadraticBezierTo(w * 0.22, h * 0.37, w * 0.24, h * 0.32);
        path.quadraticBezierTo(w * 0.25, h * 0.28, w * 0.22, h * 0.26);
        path.close();

        // Right bicep
        path.moveTo(w * 0.78, h * 0.26);
        path.quadraticBezierTo(w * 0.82, h * 0.28, w * 0.84, h * 0.32);
        path.quadraticBezierTo(w * 0.85, h * 0.36, w * 0.82, h * 0.38);
        path.quadraticBezierTo(w * 0.78, h * 0.37, w * 0.76, h * 0.32);
        path.quadraticBezierTo(w * 0.75, h * 0.28, w * 0.78, h * 0.26);
        path.close();

        return path;
      },
    ),

    // FOREARMS
    'forearms': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.12, 0.36, 0.88, 0.48),
      center: const Offset(0.50, 0.42),
      tapRadius: 0.06,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left forearm
        path.moveTo(w * 0.18, h * 0.38);
        path.quadraticBezierTo(w * 0.14, h * 0.40, w * 0.13, h * 0.44);
        path.quadraticBezierTo(w * 0.14, h * 0.48, w * 0.17, h * 0.48);
        path.quadraticBezierTo(w * 0.20, h * 0.46, w * 0.22, h * 0.42);
        path.quadraticBezierTo(w * 0.21, h * 0.39, w * 0.18, h * 0.38);
        path.close();

        // Right forearm
        path.moveTo(w * 0.82, h * 0.38);
        path.quadraticBezierTo(w * 0.86, h * 0.40, w * 0.87, h * 0.44);
        path.quadraticBezierTo(w * 0.86, h * 0.48, w * 0.83, h * 0.48);
        path.quadraticBezierTo(w * 0.80, h * 0.46, w * 0.78, h * 0.42);
        path.quadraticBezierTo(w * 0.79, h * 0.39, w * 0.82, h * 0.38);
        path.close();

        return path;
      },
    ),

    // ABS
    'abs': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.40, 0.29, 0.60, 0.50),
      center: const Offset(0.50, 0.39),
      tapRadius: 0.10,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Abs block (6-pack shape)
        path.moveTo(w * 0.44, h * 0.30);
        path.lineTo(w * 0.56, h * 0.30);
        path.quadraticBezierTo(w * 0.58, h * 0.35, w * 0.57, h * 0.40);
        path.quadraticBezierTo(w * 0.56, h * 0.45, w * 0.54, h * 0.50);
        path.lineTo(w * 0.46, h * 0.50);
        path.quadraticBezierTo(w * 0.44, h * 0.45, w * 0.43, h * 0.40);
        path.quadraticBezierTo(w * 0.42, h * 0.35, w * 0.44, h * 0.30);
        path.close();

        return path;
      },
    ),

    // OBLIQUES
    'obliques': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.32, 0.32, 0.68, 0.50),
      center: const Offset(0.50, 0.41),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left oblique
        path.moveTo(w * 0.42, h * 0.32);
        path.quadraticBezierTo(w * 0.36, h * 0.34, w * 0.34, h * 0.40);
        path.quadraticBezierTo(w * 0.35, h * 0.46, w * 0.38, h * 0.50);
        path.lineTo(w * 0.42, h * 0.50);
        path.quadraticBezierTo(w * 0.41, h * 0.42, w * 0.42, h * 0.32);
        path.close();

        // Right oblique
        path.moveTo(w * 0.58, h * 0.32);
        path.quadraticBezierTo(w * 0.64, h * 0.34, w * 0.66, h * 0.40);
        path.quadraticBezierTo(w * 0.65, h * 0.46, w * 0.62, h * 0.50);
        path.lineTo(w * 0.58, h * 0.50);
        path.quadraticBezierTo(w * 0.59, h * 0.42, w * 0.58, h * 0.32);
        path.close();

        return path;
      },
    ),

    // QUADRICEPS
    'quadriceps': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.34, 0.52, 0.66, 0.75),
      center: const Offset(0.50, 0.63),
      tapRadius: 0.12,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left quad
        path.moveTo(w * 0.40, h * 0.54);
        path.quadraticBezierTo(w * 0.36, h * 0.58, w * 0.35, h * 0.65);
        path.quadraticBezierTo(w * 0.35, h * 0.72, w * 0.37, h * 0.75);
        path.lineTo(w * 0.45, h * 0.75);
        path.quadraticBezierTo(w * 0.46, h * 0.68, w * 0.46, h * 0.60);
        path.quadraticBezierTo(w * 0.45, h * 0.56, w * 0.40, h * 0.54);
        path.close();

        // Right quad
        path.moveTo(w * 0.60, h * 0.54);
        path.quadraticBezierTo(w * 0.64, h * 0.58, w * 0.65, h * 0.65);
        path.quadraticBezierTo(w * 0.65, h * 0.72, w * 0.63, h * 0.75);
        path.lineTo(w * 0.55, h * 0.75);
        path.quadraticBezierTo(w * 0.54, h * 0.68, w * 0.54, h * 0.60);
        path.quadraticBezierTo(w * 0.55, h * 0.56, w * 0.60, h * 0.54);
        path.close();

        return path;
      },
    ),

    // ADDUCTORS (inner thigh)
    'adductors': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.44, 0.54, 0.56, 0.68),
      center: const Offset(0.50, 0.61),
      tapRadius: 0.06,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left adductor
        path.moveTo(w * 0.46, h * 0.55);
        path.quadraticBezierTo(w * 0.44, h * 0.60, w * 0.45, h * 0.68);
        path.lineTo(w * 0.48, h * 0.68);
        path.quadraticBezierTo(w * 0.48, h * 0.60, w * 0.46, h * 0.55);
        path.close();

        // Right adductor
        path.moveTo(w * 0.54, h * 0.55);
        path.quadraticBezierTo(w * 0.56, h * 0.60, w * 0.55, h * 0.68);
        path.lineTo(w * 0.52, h * 0.68);
        path.quadraticBezierTo(w * 0.52, h * 0.60, w * 0.54, h * 0.55);
        path.close();

        return path;
      },
    ),

    // CALVES (front view - tibialis)
    'calves': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.35, 0.76, 0.65, 0.92),
      center: const Offset(0.50, 0.84),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left calf (tibialis anterior)
        path.moveTo(w * 0.38, h * 0.76);
        path.quadraticBezierTo(w * 0.36, h * 0.82, w * 0.37, h * 0.88);
        path.quadraticBezierTo(w * 0.38, h * 0.92, w * 0.40, h * 0.92);
        path.lineTo(w * 0.44, h * 0.92);
        path.quadraticBezierTo(w * 0.45, h * 0.86, w * 0.44, h * 0.80);
        path.quadraticBezierTo(w * 0.42, h * 0.76, w * 0.38, h * 0.76);
        path.close();

        // Right calf
        path.moveTo(w * 0.62, h * 0.76);
        path.quadraticBezierTo(w * 0.64, h * 0.82, w * 0.63, h * 0.88);
        path.quadraticBezierTo(w * 0.62, h * 0.92, w * 0.60, h * 0.92);
        path.lineTo(w * 0.56, h * 0.92);
        path.quadraticBezierTo(w * 0.55, h * 0.86, w * 0.56, h * 0.80);
        path.quadraticBezierTo(w * 0.58, h * 0.76, w * 0.62, h * 0.76);
        path.close();

        return path;
      },
    ),
  };

  // ============================================
  // BACK VIEW MUSCLES
  // ============================================
  static final Map<String, _MuscleRegion> backMuscles = {
    // TRAPEZIUS
    'trapezius': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.35, 0.12, 0.65, 0.24),
      center: const Offset(0.50, 0.18),
      tapRadius: 0.10,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Traps (diamond shape)
        path.moveTo(w * 0.50, h * 0.12);
        path.quadraticBezierTo(w * 0.38, h * 0.14, w * 0.32, h * 0.18);
        path.quadraticBezierTo(w * 0.35, h * 0.22, w * 0.42, h * 0.24);
        path.lineTo(w * 0.50, h * 0.22);
        path.lineTo(w * 0.58, h * 0.24);
        path.quadraticBezierTo(w * 0.65, h * 0.22, w * 0.68, h * 0.18);
        path.quadraticBezierTo(w * 0.62, h * 0.14, w * 0.50, h * 0.12);
        path.close();

        return path;
      },
    ),

    // REAR DELTOIDS
    'deltoids': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.18, 0.16, 0.82, 0.26),
      center: const Offset(0.50, 0.21),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left rear delt
        path.moveTo(w * 0.30, h * 0.17);
        path.quadraticBezierTo(w * 0.24, h * 0.18, w * 0.20, h * 0.21);
        path.quadraticBezierTo(w * 0.19, h * 0.24, w * 0.22, h * 0.26);
        path.quadraticBezierTo(w * 0.26, h * 0.24, w * 0.30, h * 0.20);
        path.close();

        // Right rear delt
        path.moveTo(w * 0.70, h * 0.17);
        path.quadraticBezierTo(w * 0.76, h * 0.18, w * 0.80, h * 0.21);
        path.quadraticBezierTo(w * 0.81, h * 0.24, w * 0.78, h * 0.26);
        path.quadraticBezierTo(w * 0.74, h * 0.24, w * 0.70, h * 0.20);
        path.close();

        return path;
      },
    ),

    // UPPER BACK (Rhomboids)
    'upper_back': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.35, 0.20, 0.65, 0.32),
      center: const Offset(0.50, 0.26),
      tapRadius: 0.10,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left upper back
        path.moveTo(w * 0.42, h * 0.22);
        path.quadraticBezierTo(w * 0.35, h * 0.24, w * 0.33, h * 0.28);
        path.quadraticBezierTo(w * 0.35, h * 0.32, w * 0.42, h * 0.32);
        path.lineTo(w * 0.48, h * 0.28);
        path.close();

        // Right upper back
        path.moveTo(w * 0.58, h * 0.22);
        path.quadraticBezierTo(w * 0.65, h * 0.24, w * 0.67, h * 0.28);
        path.quadraticBezierTo(w * 0.65, h * 0.32, w * 0.58, h * 0.32);
        path.lineTo(w * 0.52, h * 0.28);
        path.close();

        return path;
      },
    ),

    // LATS
    'lats': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.28, 0.26, 0.72, 0.44),
      center: const Offset(0.50, 0.35),
      tapRadius: 0.12,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left lat (V-shape)
        path.moveTo(w * 0.33, h * 0.28);
        path.quadraticBezierTo(w * 0.28, h * 0.32, w * 0.30, h * 0.38);
        path.quadraticBezierTo(w * 0.34, h * 0.44, w * 0.42, h * 0.44);
        path.lineTo(w * 0.44, h * 0.38);
        path.quadraticBezierTo(w * 0.40, h * 0.34, w * 0.38, h * 0.28);
        path.close();

        // Right lat
        path.moveTo(w * 0.67, h * 0.28);
        path.quadraticBezierTo(w * 0.72, h * 0.32, w * 0.70, h * 0.38);
        path.quadraticBezierTo(w * 0.66, h * 0.44, w * 0.58, h * 0.44);
        path.lineTo(w * 0.56, h * 0.38);
        path.quadraticBezierTo(w * 0.60, h * 0.34, w * 0.62, h * 0.28);
        path.close();

        return path;
      },
    ),

    // TRICEPS
    'triceps': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.14, 0.24, 0.86, 0.38),
      center: const Offset(0.50, 0.31),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left tricep
        path.moveTo(w * 0.22, h * 0.26);
        path.quadraticBezierTo(w * 0.18, h * 0.28, w * 0.16, h * 0.32);
        path.quadraticBezierTo(w * 0.15, h * 0.36, w * 0.18, h * 0.38);
        path.quadraticBezierTo(w * 0.22, h * 0.37, w * 0.24, h * 0.32);
        path.quadraticBezierTo(w * 0.25, h * 0.28, w * 0.22, h * 0.26);
        path.close();

        // Right tricep
        path.moveTo(w * 0.78, h * 0.26);
        path.quadraticBezierTo(w * 0.82, h * 0.28, w * 0.84, h * 0.32);
        path.quadraticBezierTo(w * 0.85, h * 0.36, w * 0.82, h * 0.38);
        path.quadraticBezierTo(w * 0.78, h * 0.37, w * 0.76, h * 0.32);
        path.quadraticBezierTo(w * 0.75, h * 0.28, w * 0.78, h * 0.26);
        path.close();

        return path;
      },
    ),

    // FOREARMS (back)
    'forearms': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.12, 0.36, 0.88, 0.48),
      center: const Offset(0.50, 0.42),
      tapRadius: 0.06,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left forearm
        path.moveTo(w * 0.18, h * 0.38);
        path.quadraticBezierTo(w * 0.14, h * 0.40, w * 0.13, h * 0.44);
        path.quadraticBezierTo(w * 0.14, h * 0.48, w * 0.17, h * 0.48);
        path.quadraticBezierTo(w * 0.20, h * 0.46, w * 0.22, h * 0.42);
        path.quadraticBezierTo(w * 0.21, h * 0.39, w * 0.18, h * 0.38);
        path.close();

        // Right forearm
        path.moveTo(w * 0.82, h * 0.38);
        path.quadraticBezierTo(w * 0.86, h * 0.40, w * 0.87, h * 0.44);
        path.quadraticBezierTo(w * 0.86, h * 0.48, w * 0.83, h * 0.48);
        path.quadraticBezierTo(w * 0.80, h * 0.46, w * 0.78, h * 0.42);
        path.quadraticBezierTo(w * 0.79, h * 0.39, w * 0.82, h * 0.38);
        path.close();

        return path;
      },
    ),

    // LOWER BACK (Erector Spinae)
    'lower_back': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.40, 0.40, 0.60, 0.52),
      center: const Offset(0.50, 0.46),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        path.moveTo(w * 0.44, h * 0.42);
        path.quadraticBezierTo(w * 0.40, h * 0.46, w * 0.42, h * 0.52);
        path.lineTo(w * 0.58, h * 0.52);
        path.quadraticBezierTo(w * 0.60, h * 0.46, w * 0.56, h * 0.42);
        path.close();

        return path;
      },
    ),

    // GLUTES
    'glutes': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.34, 0.50, 0.66, 0.60),
      center: const Offset(0.50, 0.55),
      tapRadius: 0.10,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left glute
        path.moveTo(w * 0.42, h * 0.52);
        path.quadraticBezierTo(w * 0.35, h * 0.52, w * 0.34, h * 0.56);
        path.quadraticBezierTo(w * 0.36, h * 0.60, w * 0.44, h * 0.60);
        path.quadraticBezierTo(w * 0.48, h * 0.58, w * 0.48, h * 0.54);
        path.close();

        // Right glute
        path.moveTo(w * 0.58, h * 0.52);
        path.quadraticBezierTo(w * 0.65, h * 0.52, w * 0.66, h * 0.56);
        path.quadraticBezierTo(w * 0.64, h * 0.60, w * 0.56, h * 0.60);
        path.quadraticBezierTo(w * 0.52, h * 0.58, w * 0.52, h * 0.54);
        path.close();

        return path;
      },
    ),

    // HAMSTRINGS
    'hamstrings': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.34, 0.58, 0.66, 0.78),
      center: const Offset(0.50, 0.68),
      tapRadius: 0.12,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left hamstring
        path.moveTo(w * 0.36, h * 0.60);
        path.quadraticBezierTo(w * 0.34, h * 0.66, w * 0.35, h * 0.74);
        path.quadraticBezierTo(w * 0.37, h * 0.78, w * 0.42, h * 0.78);
        path.lineTo(w * 0.46, h * 0.78);
        path.quadraticBezierTo(w * 0.47, h * 0.70, w * 0.46, h * 0.62);
        path.quadraticBezierTo(w * 0.42, h * 0.60, w * 0.36, h * 0.60);
        path.close();

        // Right hamstring
        path.moveTo(w * 0.64, h * 0.60);
        path.quadraticBezierTo(w * 0.66, h * 0.66, w * 0.65, h * 0.74);
        path.quadraticBezierTo(w * 0.63, h * 0.78, w * 0.58, h * 0.78);
        path.lineTo(w * 0.54, h * 0.78);
        path.quadraticBezierTo(w * 0.53, h * 0.70, w * 0.54, h * 0.62);
        path.quadraticBezierTo(w * 0.58, h * 0.60, w * 0.64, h * 0.60);
        path.close();

        return path;
      },
    ),

    // CALVES (back view - gastrocnemius)
    'calves': _MuscleRegion(
      bounds: const Rect.fromLTRB(0.35, 0.76, 0.65, 0.92),
      center: const Offset(0.50, 0.84),
      tapRadius: 0.08,
      pathBuilder: (size) {
        final w = size.width;
        final h = size.height;
        final path = Path();

        // Left calf (gastrocnemius - bulge)
        path.moveTo(w * 0.37, h * 0.78);
        path.quadraticBezierTo(w * 0.34, h * 0.82, w * 0.35, h * 0.86);
        path.quadraticBezierTo(w * 0.37, h * 0.90, w * 0.40, h * 0.92);
        path.lineTo(w * 0.45, h * 0.92);
        path.quadraticBezierTo(w * 0.46, h * 0.88, w * 0.45, h * 0.82);
        path.quadraticBezierTo(w * 0.42, h * 0.78, w * 0.37, h * 0.78);
        path.close();

        // Right calf
        path.moveTo(w * 0.63, h * 0.78);
        path.quadraticBezierTo(w * 0.66, h * 0.82, w * 0.65, h * 0.86);
        path.quadraticBezierTo(w * 0.63, h * 0.90, w * 0.60, h * 0.92);
        path.lineTo(w * 0.55, h * 0.92);
        path.quadraticBezierTo(w * 0.54, h * 0.88, w * 0.55, h * 0.82);
        path.quadraticBezierTo(w * 0.58, h * 0.78, w * 0.63, h * 0.78);
        path.close();

        return path;
      },
    ),
  };
}

/// Muscle detail card
class _MuscleDetailCard extends StatelessWidget {
  const _MuscleDetailCard({
    required this.muscleSlug,
    required this.heatValue,
  });

  final String muscleSlug;
  final double heatValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final color = _getHeatColor(heatValue);

    // Get localized muscle name
    final displayName = _getLocalizedMuscleName(muscleSlug, l10n);
    final intensityLabel = _getIntensityLabel(heatValue, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(heatValue * 100).toInt()}%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  intensityLabel,
                  style: context.textTheme.bodySmall?.copyWith(
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

  String _getLocalizedMuscleName(String slug, dynamic l10n) {
    // Map slugs to localized names
    // TODO: Add proper l10n keys
    const names = {
      'chest': 'Chest',
      'deltoids': 'Shoulders',
      'biceps': 'Biceps',
      'triceps': 'Triceps',
      'forearms': 'Forearms',
      'abs': 'Abs',
      'obliques': 'Obliques',
      'quadriceps': 'Quadriceps',
      'hamstrings': 'Hamstrings',
      'calves': 'Calves',
      'glutes': 'Glutes',
      'trapezius': 'Trapezius',
      'upper_back': 'Upper Back',
      'lats': 'Lats',
      'lower_back': 'Lower Back',
      'adductors': 'Adductors',
    };
    return names[slug] ?? slug;
  }

  String _getIntensityLabel(double heat, dynamic l10n) {
    if (heat < 0.33) return 'Low training volume';
    if (heat < 0.66) return 'Moderate training volume';
    return 'High training volume';
  }

  Color _getHeatColor(double heat) {
    if (heat < 0.5) {
      final t = heat * 2;
      return Color.lerp(
        const Color(0xFF2196F3),
        const Color(0xFFFFC107),
        t,
      )!;
    } else {
      final t = (heat - 0.5) * 2;
      return Color.lerp(
        const Color(0xFFFFC107),
        const Color(0xFFF44336),
        t,
      )!;
    }
  }
}

/// Heat legend widget
class _HeatLegend extends StatelessWidget {
  const _HeatLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: const Color(0xFF2196F3),
          label: l10n.intensityLow,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: const Color(0xFFFFC107),
          label: l10n.intensityMedium,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: const Color(0xFFF44336),
          label: l10n.intensityHigh,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
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
          style: context.textTheme.labelSmall,
        ),
      ],
    );
  }
}
