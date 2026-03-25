/// GymBro TrackLog - Flutter Fitness App
///
/// PROFESSIONAL BODY HEATMAP
/// Uses professional SVG muscle diagram with heat-mapped colors.
///
/// Features:
/// - Professional anatomical SVG from muscle_selector package
/// - Heat-mapped muscles (blue -> yellow -> red)
/// - Front and back body views (both visible)
/// - Tap to see muscle details
/// - Smooth animations and haptic feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Muscle groups mapping (from muscle_selector package)
const _muscleGroups = {
  'chest': ['chest1', 'chest2'],
  'shoulders': ['shoulder1', 'shoulder2', 'shoulder3', 'shoulder4'],
  'obliques': ['obliques1', 'obliques2'],
  'abs': ['abs1', 'abs2', 'abs3', 'abs4', 'abs5', 'abs6', 'abs7', 'abs8'],
  'abductors': ['abductor1', 'abductor2'],
  'biceps': ['biceps1', 'biceps2'],
  'calves': ['calves1', 'calves2', 'calves3', 'calves4'],
  'forearms': ['forearm1', 'forearm2', 'forearm3', 'forearm4'],
  'glutes': ['glutes1', 'glutes2'],
  'hamstrings': ['harmstrings1', 'harmstrings2'], // Note: typo in SVG
  'lats': ['lats1', 'lats2'],
  'upper_back': ['upper_back1', 'upper_back2'],
  'quadriceps': ['quads1', 'quads2', 'quads3', 'quads4'],
  'trapezius': [
    'trapezius1',
    'trapezius2',
    'trapezius3',
    'trapezius4',
    'trapezius5',
  ],
  'triceps': ['triceps1', 'triceps2'],
  'adductors': ['adductors1', 'adductors2'],
  'lower_back': ['lower_back'],
  'neck': ['neck'],
};

/// Muscle data parsed from SVG
class _MuscleData {
  _MuscleData({required this.id, required this.title, required this.path});

  final String id;
  final String title;
  final Path path;
}

/// Heat data for muscles
class MuscleHeatValues {
  MuscleHeatValues(Map<String, double> values)
    : _values = _normalizeKeys(values);

  final Map<String, double> _values;

  /// Normalizes input keys to SVG heatmap group names.
  ///
  /// Uses centralized [MuscleAbbreviationMapper.normalizeToHeatmapKey] as
  /// SINGLE SOURCE OF TRUTH for abbreviation → heatmap key conversion.
  ///
  /// This handles:
  /// - IT abbreviations: 'lat', 'pett', 'quad' → 'lats', 'chest', 'quadriceps'
  /// - EN names: 'back', 'chest' → 'lats', 'chest'
  /// - Already correct keys: 'lats', 'quadriceps' → pass through
  static Map<String, double> _normalizeKeys(Map<String, double> input) {
    final normalized = <String, double>{};
    for (final entry in input.entries) {
      // Use centralized mapper for abbreviation → heatmap key conversion
      final mappedKey = MuscleAbbreviationMapper.normalizeToHeatmapKey(
        entry.key,
      );
      // Accumulate values (multiple abbreviations may map to same group)
      normalized[mappedKey] =
          (normalized[mappedKey] ?? 0) + (entry.value / 100).clamp(0.0, 1.0);
    }
    // Clamp accumulated values to 1.0 max
    return normalized.map((k, v) => MapEntry(k, v.clamp(0.0, 1.0)));
  }

  /// Get heat value for a muscle group (0.0 - 1.0)
  double getHeat(String groupName) {
    final normalized = groupName.toLowerCase().replaceAll(' ', '_');
    return _values[normalized] ?? 0.0;
  }

  /// Get heat for a specific muscle ID
  double getHeatForId(String muscleId) {
    // Find which group this muscle belongs to
    for (final entry in _muscleGroups.entries) {
      if (entry.value.contains(muscleId)) {
        return getHeat(entry.key);
      }
    }
    // Try direct match
    return _values[muscleId.toLowerCase()] ?? 0.0;
  }
}

/// Professional Body Heatmap Widget
///
/// Renders the professional anatomical body SVG with heat-mapped muscles.
class ProfessionalBodyHeatmap extends StatefulWidget {
  const ProfessionalBodyHeatmap({
    required this.heatValues,
    this.onMuscleTap,
    this.enableSelection = true,
    this.showSelectionInfo = true,
    this.showLegend = true,
    this.svgSourceLoader,
    this.lowHeatColor = const Color(0xFF2196F3),
    this.mediumHeatColor = const Color(0xFFFFC107),
    this.highHeatColor = const Color(0xFFF44336),
    super.key,
  });

  final MuscleHeatValues heatValues;
  final void Function(String muscleGroup, double heatValue)? onMuscleTap;
  final bool enableSelection;
  final bool showSelectionInfo;
  final bool showLegend;
  final Future<String> Function()? svgSourceLoader;
  final Color lowHeatColor;
  final Color mediumHeatColor;
  final Color highHeatColor;

  @override
  State<ProfessionalBodyHeatmap> createState() =>
      _ProfessionalBodyHeatmapState();
}

class _ProfessionalBodyHeatmapState extends State<ProfessionalBodyHeatmap> {
  /// ⚡ PERFORMANCE: Static cache prevents re-parsing heavy SVG when widget rebuilds
  static List<_MuscleData>? _cachedMuscles;
  static Size? _cachedSvgSize;
  static Future<void>? _pendingLoad;

  List<_MuscleData> _muscles = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedMuscleGroup;
  Size _svgSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    // Return cached data if available
    if (_cachedMuscles != null && _cachedSvgSize != null) {
      setState(() {
        _muscles = _cachedMuscles!;
        _svgSize = _cachedSvgSize!;
        _isLoading = false;
      });
      return;
    }

    // If already loading, wait for it
    if (_pendingLoad != null) {
      await _pendingLoad;
      if (_cachedMuscles != null && _cachedSvgSize != null) {
        setState(() {
          _muscles = _cachedMuscles!;
          _svgSize = _cachedSvgSize!;
          _isLoading = false;
        });
      }
      return;
    }

    // Start new load
    _pendingLoad = _loadSvgInternal();
    try {
      await _pendingLoad;
    } finally {
      _pendingLoad = null;
    }
  }

  Future<void> _loadSvgInternal() async {
    try {
      final svgString =
          await (widget.svgSourceLoader?.call() ?? _loadSvgSource());

      final muscles = <_MuscleData>[];
      final regExp = RegExp(
        r'<path[^>]*id="([^"]*)"[^>]*title="([^"]*)"[^>]*d="([^"]*)"',
        multiLine: true,
        caseSensitive: false,
      );

      Rect? bounds;

      for (final match in regExp.allMatches(svgString)) {
        final id = match.group(1)!;
        final title = match.group(2)!;
        final pathData = match.group(3)!;

        try {
          final path = parseSvgPath(pathData);
          muscles.add(_MuscleData(id: id, title: title, path: path));

          // Calculate bounds
          final pathBounds = path.getBounds();
          if (bounds == null) {
            bounds = pathBounds;
          } else {
            bounds = Rect.fromLTRB(
              bounds.left < pathBounds.left ? bounds.left : pathBounds.left,
              bounds.top < pathBounds.top ? bounds.top : pathBounds.top,
              bounds.right > pathBounds.right ? bounds.right : pathBounds.right,
              bounds.bottom > pathBounds.bottom
                  ? bounds.bottom
                  : pathBounds.bottom,
            );
          }
        } catch (e) {
          // Skip invalid paths
        }
      }

      final svgSize = Size(bounds?.width ?? 300, bounds?.height ?? 600);

      // Cache for future widget instances
      _cachedMuscles = muscles;
      _cachedSvgSize = svgSize;

      if (mounted) {
        setState(() {
          _muscles = muscles;
          _svgSize = svgSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _loadSvgSource() async {
    try {
      return await rootBundle.loadString('assets/images/human_body.svg');
    } catch (_) {
      // Fallback to the package asset if the bundled local copy is unavailable.
    }

    try {
      return await rootBundle.loadString(
        'packages/muscle_selector/assets/maps/human_body.svg',
      );
    } catch (_) {
      // Final fallback retries the local asset.
      return rootBundle.loadString('assets/images/human_body.svg');
    }
  }

  String? _getMuscleGroup(String muscleId) {
    for (final entry in _muscleGroups.entries) {
      if (entry.value.contains(muscleId)) {
        return entry.key;
      }
    }
    return null;
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (!widget.enableSelection) return;

    final tapPos = details.localPosition;

    // Calculate scale
    final scale = size.width / _svgSize.width;
    final scaledTap = Offset(tapPos.dx / scale, tapPos.dy / scale);

    // Check which muscle was tapped
    for (final muscle in _muscles.reversed) {
      if (muscle.id == 'human_body') continue; // Skip body outline

      if (muscle.path.contains(scaledTap)) {
        final group = _getMuscleGroup(muscle.id);
        if (group != null) {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedMuscleGroup = _selectedMuscleGroup == group ? null : group;
          });
          if (_selectedMuscleGroup != null) {
            widget.onMuscleTap?.call(group, widget.heatValues.getHeat(group));
          }
          return;
        }
      }
    }

    // Tapped outside - clear selection
    setState(() => _selectedMuscleGroup = null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final selectedMuscleGroup = _selectedMuscleGroup;

    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.error,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Body diagram
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate size maintaining aspect ratio
                  final aspectRatio = _svgSize.width / _svgSize.height;
                  final maxWidth = constraints.maxWidth;
                  final maxHeight = constraints.maxHeight;

                  double width, height;
                  if (maxWidth / maxHeight > aspectRatio) {
                    height = maxHeight;
                    width = height * aspectRatio;
                  } else {
                    width = maxWidth;
                    height = width / aspectRatio;
                  }

                  return Center(
                    child: GestureDetector(
                      onTapUp: (details) =>
                          _handleTap(details, Size(width, height)),
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: _BodyHeatmapPainter(
                          muscles: _muscles,
                          heatValues: widget.heatValues,
                          selectedMuscleGroup: selectedMuscleGroup,
                          colorScheme: colorScheme,
                          svgSize: _svgSize,
                          lowHeatColor: widget.lowHeatColor,
                          mediumHeatColor: widget.mediumHeatColor,
                          highHeatColor: widget.highHeatColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Heat legend
            if (widget.showLegend) ...[
              const SizedBox(height: 12),
              _HeatLegend(
                lowHeatColor: widget.lowHeatColor,
                mediumHeatColor: widget.mediumHeatColor,
                highHeatColor: widget.highHeatColor,
              ),
            ],
          ],
        ),

        if (widget.showSelectionInfo)
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: selectedMuscleGroup == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(selectedMuscleGroup),
                          padding: const EdgeInsets.only(top: 12, right: 12),
                          child: _MuscleInfoBadge(
                            muscleGroup: selectedMuscleGroup,
                            heatValue: widget.heatValues.getHeat(
                              selectedMuscleGroup,
                            ),
                            lowHeatColor: widget.lowHeatColor,
                            mediumHeatColor: widget.mediumHeatColor,
                            highHeatColor: widget.highHeatColor,
                          ),
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for body heatmap
class _BodyHeatmapPainter extends CustomPainter {
  _BodyHeatmapPainter({
    required this.muscles,
    required this.heatValues,
    required this.colorScheme,
    required this.svgSize,
    required this.lowHeatColor,
    required this.mediumHeatColor,
    required this.highHeatColor,
    this.selectedMuscleGroup,
  });

  final List<_MuscleData> muscles;
  final MuscleHeatValues heatValues;
  final ColorScheme colorScheme;
  final Size svgSize;
  final Color lowHeatColor;
  final Color mediumHeatColor;
  final Color highHeatColor;
  final String? selectedMuscleGroup;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale
    final scale = size.width / svgSize.width;
    canvas.scale(scale);

    // Draw body outline first (if exists)
    final bodyOutline = muscles.firstWhere(
      (m) => m.id == 'human_body',
      orElse: () => _MuscleData(id: '', title: '', path: Path()),
    );

    if (bodyOutline.id.isNotEmpty) {
      final outlinePaint = Paint()
        ..color = colorScheme.outline.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(bodyOutline.path, outlinePaint);
    }

    // Draw each muscle with heat color
    for (final muscle in muscles) {
      if (muscle.id == 'human_body') continue;

      final heat = heatValues.getHeatForId(muscle.id);
      final heatColor = _getHeatColor(heat);

      // Check if this muscle is in the selected group
      final muscleGroup = _getMuscleGroup(muscle.id);
      final isSelected = muscleGroup == selectedMuscleGroup;

      // Fill with heat color
      final fillPaint = Paint()
        ..color = heatColor.withValues(alpha: isSelected ? 0.9 : 0.7)
        ..style = PaintingStyle.fill;
      canvas.drawPath(muscle.path, fillPaint);

      // Stroke
      final strokePaint = Paint()
        ..color = isSelected
            ? colorScheme.primary
            : colorScheme.surface.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.0 : 0.5;
      canvas.drawPath(muscle.path, strokePaint);
    }
  }

  String? _getMuscleGroup(String muscleId) {
    for (final entry in _muscleGroups.entries) {
      if (entry.value.contains(muscleId)) {
        return entry.key;
      }
    }
    return null;
  }

  Color _getHeatColor(double heat) {
    if (heat < 0.5) {
      return Color.lerp(lowHeatColor, mediumHeatColor, heat * 2)!;
    } else {
      return Color.lerp(mediumHeatColor, highHeatColor, (heat - 0.5) * 2)!;
    }
  }

  @override
  bool shouldRepaint(_BodyHeatmapPainter oldDelegate) {
    return oldDelegate.selectedMuscleGroup != selectedMuscleGroup ||
        oldDelegate.heatValues != heatValues ||
        oldDelegate.lowHeatColor != lowHeatColor ||
        oldDelegate.mediumHeatColor != mediumHeatColor ||
        oldDelegate.highHeatColor != highHeatColor;
  }
}

/// Compact selection badge shown in the top-right corner.
class _MuscleInfoBadge extends StatelessWidget {
  const _MuscleInfoBadge({
    required this.muscleGroup,
    required this.heatValue,
    required this.lowHeatColor,
    required this.mediumHeatColor,
    required this.highHeatColor,
  });

  final String muscleGroup;
  final double heatValue;
  final Color lowHeatColor;
  final Color mediumHeatColor;
  final Color highHeatColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final heatColor = _getHeatColor(heatValue);
    final percentage = (heatValue * 100).toInt();
    final displayName = _getDisplayName(context, muscleGroup);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: heatColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: heatColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: heatColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$percentage%',
                style: context.textTheme.labelMedium?.copyWith(
                  color: heatColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(BuildContext context, String group) {
    final l10n = context.l10n;
    final isItalian = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('it');

    return switch (group) {
      'chest' => l10n.musclePectorals,
      'shoulders' => l10n.muscleDeltoids,
      'obliques' => l10n.muscleObliques,
      'abs' => l10n.muscleAbs,
      'abductors' => MuscleAbbreviationMapper.codeToDisplayName(
        'ABDU',
        italian: isItalian,
      ),
      'biceps' => l10n.muscleBiceps,
      'calves' => l10n.muscleCalves,
      'forearms' => l10n.muscleForearms,
      'glutes' => l10n.muscleGlutes,
      'hamstrings' => l10n.muscleHamstrings,
      'lats' => l10n.muscleLats,
      'upper_back' => l10n.muscleRhomboids,
      'quadriceps' => l10n.muscleQuads,
      'trapezius' => l10n.muscleTrapezius,
      'triceps' => l10n.muscleTriceps,
      'adductors' => l10n.muscleAdductors,
      'lower_back' => l10n.muscleLowerBack,
      'neck' => MuscleAbbreviationMapper.codeToDisplayName(
        'COLL',
        italian: isItalian,
      ),
      _ => group,
    };
  }

  Color _getHeatColor(double heat) {
    if (heat < 0.5) {
      return Color.lerp(lowHeatColor, mediumHeatColor, heat * 2)!;
    } else {
      return Color.lerp(mediumHeatColor, highHeatColor, (heat - 0.5) * 2)!;
    }
  }
}

/// Heat legend widget
class _HeatLegend extends StatelessWidget {
  const _HeatLegend({
    required this.lowHeatColor,
    required this.mediumHeatColor,
    required this.highHeatColor,
  });

  final Color lowHeatColor;
  final Color mediumHeatColor;
  final Color highHeatColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: lowHeatColor, label: l10n.intensityLow),
          const SizedBox(width: 16),
          _LegendItem(color: mediumHeatColor, label: l10n.intensityMedium),
          const SizedBox(width: 16),
          _LegendItem(color: highHeatColor, label: l10n.intensityHigh),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.textTheme.labelSmall),
      ],
    );
  }
}
