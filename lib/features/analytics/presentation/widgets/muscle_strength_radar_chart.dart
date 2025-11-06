import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Radar chart interattivo per visualizzare la forza relativa
/// dei diversi gruppi muscolari
class MuscleStrengthRadarChart extends StatefulWidget {
  
  const MuscleStrengthRadarChart({
    super.key,
    required this.currentStrength,
    this.targetStrength,
    this.previousStrength,
    this.onMuscleGroupTap,
    this.showValues = true,
    this.animated = true,
  });
  final Map<MuscleGroup, double> currentStrength;
  final Map<MuscleGroup, double>? targetStrength;
  final Map<MuscleGroup, double>? previousStrength;
  final Function(MuscleGroup)? onMuscleGroupTap;
  final bool showValues;
  final bool animated;

  @override
  State<MuscleStrengthRadarChart> createState() => _MuscleStrengthRadarChartState();
}

class _MuscleStrengthRadarChartState extends State<MuscleStrengthRadarChart>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  MuscleGroup? _selectedMuscle;
  bool _showComparison = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Controls
        _buildControls(theme),
        const SizedBox(height: 20),
        
        // Radar Chart
        SizedBox(
          height: 300,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTapUp: (details) => _handleTap(details, context),
                    child: RadarChart(
                      RadarChartData(
                        radarBorderData: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        radarBackgroundColor: Colors.transparent,
                        radarShape: RadarShape.polygon,
                        tickCount: 5,
                        tickBorderData: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        gridBorderData: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        titlePositionPercentageOffset: 0.2,
                        ticksTextStyle: const TextStyle(fontSize: 0), // Hide numbers
                        getTitle: (index, angle) {
                          final muscle = MuscleGroup.values[index];
                          final isSelected = muscle == _selectedMuscle;
                          
                          return RadarChartTitle(
                            text: _getMuscleLabel(muscle),
                            angle: 0,
                            positionPercentageOffset: isSelected ? 0.3 : 0.2,
                          );
                        },
                        titleTextStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        dataSets: _buildDataSets(theme),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Legend
        _buildLegend(theme),
        
        // Selected muscle details
        if (_selectedMuscle != null)
          _buildMuscleDetails(theme),
      ],
    );
  }
  
  Widget _buildControls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.previousStrength != null)
          FilterChip(
            label: const Text('Confronta'),
            selected: _showComparison,
            onSelected: (selected) {
              setState(() {
                _showComparison = selected;
              });
              HapticFeedback.lightImpact();
            },
            avatar: Icon(
              _showComparison ? AppIcons.visibility : AppIcons.visibilityOff,
              size: 18,
            ),
          ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: () {
            _animationController.reset();
            _animationController.forward();
            HapticFeedback.mediumImpact();
          },
          tooltip: 'Ricarica animazione',
        ),
      ],
    );
  }
  
  List<RadarDataSet> _buildDataSets(ThemeData theme) {
    final dataSets = <RadarDataSet>[];
    
    // Current strength
    dataSets.add(
      RadarDataSet(
        fillColor: theme.colorScheme.primary.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary,
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: MuscleGroup.values.map((muscle) {
          final value = widget.currentStrength[muscle] ?? 0.0;
          return RadarEntry(value: value * _scaleAnimation.value);
        }).toList(),
      ),
    );
    
    // Previous strength (for comparison)
    if (_showComparison && widget.previousStrength != null) {
      dataSets.add(
        RadarDataSet(
          fillColor: context.colors.secondary.withValues(alpha: 0.2),
          borderColor: context.colors.secondary.withValues(alpha: 0.7),
          borderWidth: 2,
          entryRadius: 3,
          dataEntries: MuscleGroup.values.map((muscle) {
            final value = widget.previousStrength![muscle] ?? 0.0;
            return RadarEntry(value: value * _scaleAnimation.value);
          }).toList(),
        ),
      );
    }
    
    // Target strength
    if (widget.targetStrength != null) {
      dataSets.add(
        RadarDataSet(
          fillColor: Colors.transparent,
          borderColor: context.colors.success.withValues(alpha: 0.5),
          borderWidth: 1,
          entryRadius: 0,
          dataEntries: MuscleGroup.values.map((muscle) {
            final value = widget.targetStrength![muscle] ?? 0.0;
            return RadarEntry(value: value);
          }).toList(),
        ),
      );
    }
    
    return dataSets;
  }
  
  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(
          color: theme.colorScheme.primary,
          label: 'Attuale',
          theme: theme,
        ),
        if (_showComparison && widget.previousStrength != null)
          _buildLegendItem(
            color: context.colors.secondary,
            label: 'Precedente',
            theme: theme,
          ),
        if (widget.targetStrength != null)
          _buildLegendItem(
            color: context.colors.success,
            label: 'Obiettivo',
            isDashed: true,
            theme: theme,
          ),
      ],
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed ? Border.all(color: color, width: 1) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildMuscleDetails(ThemeData theme) {
    if (_selectedMuscle == null) return const SizedBox.shrink();
    
    final current = widget.currentStrength[_selectedMuscle!] ?? 0;
    final previous = widget.previousStrength?[_selectedMuscle!];
    final target = widget.targetStrength?[_selectedMuscle!];
    
    final improvement = previous != null ? current - previous : 0;
    final improvementPercent = previous != null && previous > 0
        ? (improvement / previous * 100)
        : 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMuscleIcon(_selectedMuscle!),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getMuscleFullName(_selectedMuscle!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedMuscle = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Strength bar
          _buildStrengthBar(
            label: 'Forza attuale',
            value: current,
            maxValue: 100,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          
          if (target != null) ...[
            const SizedBox(height: 8),
            _buildStrengthBar(
              label: 'Obiettivo',
              value: target,
              maxValue: 100,
              color: context.colors.success,
              theme: theme,
            ),
          ],
          
          if (previous != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  improvement >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: improvement >= 0 ? context.colors.success : context.colors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)} '
                  '(${improvementPercent >= 0 ? '+' : ''}${improvementPercent.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: improvement >= 0 ? context.colors.success : context.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'vs ultimo mese',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _buildStrengthBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / maxValue,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
  
  void _handleTap(TapUpDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // Calculate which muscle group was tapped based on position
    // This is a simplified implementation
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final angle = math.atan2(
      localPosition.dy - center.dy,
      localPosition.dx - center.dx,
    );
    
    // Convert angle to muscle group index
    final normalizedAngle = (angle + math.pi) / (2 * math.pi);
    final index = (normalizedAngle * MuscleGroup.values.length).round() % 
                  MuscleGroup.values.length;
    
    setState(() {
      _selectedMuscle = MuscleGroup.values[index];
    });
    
    HapticFeedback.lightImpact();
    widget.onMuscleGroupTap?.call(MuscleGroup.values[index]);
  }
  
  String _getMuscleLabel(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return 'Petto';
      case MuscleGroup.back:
        return 'Dorso';
      case MuscleGroup.shoulders:
        return 'Spalle';
      case MuscleGroup.arms:
        return 'Braccia';
      case MuscleGroup.legs:
        return 'Gambe';
      case MuscleGroup.core:
        return 'Core';
    }
  }
  
  String _getMuscleFullName(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return 'Pettorali';
      case MuscleGroup.back:
        return 'Dorsali';
      case MuscleGroup.shoulders:
        return 'Deltoidi';
      case MuscleGroup.arms:
        return 'Braccia (Bicipiti/Tricipiti)';
      case MuscleGroup.legs:
        return 'Gambe (Quadricipiti/Femorali)';
      case MuscleGroup.core:
        return 'Core (Addominali/Lombari)';
    }
  }
  
  IconData _getMuscleIcon(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return AppIcons.workout;
      case MuscleGroup.back:
        return AppIcons.straighten;
      case MuscleGroup.shoulders:
        return AppIcons.accessibility;
      case MuscleGroup.arms:
        return AppIcons.sportsHandball;
      case MuscleGroup.legs:
        return AppIcons.cardio;
      case MuscleGroup.core:
        return AppIcons.flexibility;
    }
  }
  
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
}
