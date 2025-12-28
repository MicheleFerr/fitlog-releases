import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Tier-1 Muscle Balance Radar Chart with full explanations and customization
class Tier1MuscleBalanceChart extends ConsumerStatefulWidget {
  
  const Tier1MuscleBalanceChart({
    super.key,
    required this.muscleData,
    this.onTargetChanged,
    this.onMuscleGroupTap,
    this.showTutorial = true,
  });
  final Map<MuscleGroup, MuscleStrengthData> muscleData;
  final Function(MuscleGroup, double)? onTargetChanged;
  final Function(MuscleGroup)? onMuscleGroupTap;
  final bool showTutorial;

  @override
  ConsumerState<Tier1MuscleBalanceChart> createState() => _Tier1MuscleBalanceChartState();
}

class _Tier1MuscleBalanceChartState extends ConsumerState<Tier1MuscleBalanceChart>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  MuscleGroup? _selectedMuscle;
  MuscleGroup? _hoveredMuscle;
  bool _showComparison = false;
  final bool _showHelp = false;
  
  // Touch detection regions for accurate muscle selection
  final Map<MuscleGroup, Path> _muscleRegions = {};
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Show tutorial on first use
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialDialog();
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Header with help button
        _buildHeader(theme, l10n),
        const SizedBox(height: 16),
        
        // Controls
        _buildControls(theme, l10n),
        const SizedBox(height: 20),
        
        // Main Radar Chart
        Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient
            Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.surface.withValues(alpha: 0),
                  ],
                  radius: 1.5,
                ),
              ),
            ),
            
            // Radar Chart
            SizedBox(
              height: 320,
              width: 320,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _calculateMuscleRegions(constraints.biggest);
                        return GestureDetector(
                          onTapUp: (details) => _handleTap(details),
                          onPanUpdate: (details) => _handleHover(details),
                          child: CustomPaint(
                            painter: _EnhancedRadarPainter(
                              muscleData: widget.muscleData,
                              selectedMuscle: _selectedMuscle,
                              hoveredMuscle: _hoveredMuscle,
                              theme: theme,
                              animation: _scaleAnimation.value,
                              showComparison: _showComparison,
                              muscleRegions: _muscleRegions,
                              successColor: context.colors.success,
                              warningColor: context.colors.warning,
                              errorColor: context.colors.error,
                            ),
                            child: RadarChart(
                              RadarChartData(
                                radarBorderData: BorderSide.none,
                                radarBackgroundColor: theme.colorScheme.surface.withValues(alpha: 0),
                                radarShape: RadarShape.polygon,
                                tickCount: 5,
                                tickBorderData: BorderSide(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                                gridBorderData: BorderSide(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                                titlePositionPercentageOffset: 0.25,
                                ticksTextStyle: theme.textTheme.labelSmall!.copyWith(fontSize: 0),
                                getTitle: (index, angle) {
                                  final muscle = MuscleGroup.values[index];
                                  final isSelected = muscle == _selectedMuscle;
                                  final isHovered = muscle == _hoveredMuscle;
                                  final data = widget.muscleData[muscle];
                                  final status = data != null
                                      ? VolumeZone.getStatus(data.currentStrength)
                                      : VolumeStatus.insufficient;
                                  final statusIcon = _getStatusIcon(status);

                                  return RadarChartTitle(
                                    text: '$statusIcon ${_getMuscleLabel(muscle, l10n)}',
                                    angle: 0,
                                    positionPercentageOffset: isSelected || isHovered ? 0.35 : 0.25,
                                  );
                                },
                                titleTextStyle: theme.textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                dataSets: _buildDataSets(theme),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Center info
            if (_selectedMuscle == null)
              _buildCenterInfo(theme, l10n),
          ],
        ),
        
        // Legend with explanations
        _buildEnhancedLegend(theme, l10n),
        
        // Selected muscle details with editing
        if (_selectedMuscle != null)
          _buildEnhancedMuscleDetails(theme, l10n),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          AppIcons.analytics,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.muscleGroupBalance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Help button
        IconButton(
          icon: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  AppIcons.help,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
          onPressed: _showHelpDialog,
          tooltip: l10n.howIsThisCalculated,
        ),
      ],
    );
  }
  
  Widget _buildControls(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Compare with previous
        FilterChip(
          label: Text(l10n.comparePrevious),
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
        
        // Reset animation
        IconButton(
          icon: const SemanticIcon(
  icon: AppIcons.refresh,
  semanticLabel: 'Refresh',
),
          onPressed: () {
            _animationController.reset();
            _animationController.forward();
            HapticFeedback.mediumImpact();
          },
          tooltip: l10n.refreshAnimation,
        ),
        const SizedBox(width: 12),
        
        // Edit targets
        TextButton.icon(
          icon: const SemanticIcon(
  icon: AppIcons.edit,
  semanticLabel: 'Edit',
  size: AppIconSize.small,
),
          label: Text(l10n.editTargets),
          onPressed: _showTargetEditDialog,
        ),
      ],
    );
  }

  Widget _buildCenterInfo(ThemeData theme, AppLocalizations l10n) {
    final overallBalance = _calculateOverallBalance();
    final balanceColor = _getBalanceColor(overallBalance);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${overallBalance.toStringAsFixed(0)}%',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: balanceColor,
          ),
        ),
        Text(
          l10n.overallBalance,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: balanceColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: balanceColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _getBalanceRating(overallBalance, l10n),
            style: theme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: balanceColor,
            ),
          ),
        ),
      ],
    );
  }

  List<RadarDataSet> _buildDataSets(ThemeData theme) {
    final dataSets = <RadarDataSet>[];
    
    // Current strength (calculated from volume)
    dataSets.add(
      RadarDataSet(
        fillColor: theme.colorScheme.primary.withValues(alpha: 0.25),
        borderColor: theme.colorScheme.primary,
        borderWidth: 2.5,
        entryRadius: 5,
        dataEntries: MuscleGroup.values.map((muscle) {
          final data = widget.muscleData[muscle];
          final value = (data?.currentStrength ?? 0) * _scaleAnimation.value;
          return RadarEntry(value: value.clamp(0, 100));
        }).toList(),
      ),
    );
    
    // Previous month comparison
    if (_showComparison) {
      dataSets.add(
        RadarDataSet(
          fillColor: context.colors.secondary.withValues(alpha: 0.15),
          borderColor: context.colors.secondary.withValues(alpha: 0.7),
          borderWidth: 2,
          entryRadius: 3,
          dataEntries: MuscleGroup.values.map((muscle) {
            final data = widget.muscleData[muscle];
            final value = (data?.previousStrength ?? 0) * _scaleAnimation.value;
            return RadarEntry(value: value.clamp(0, 100));
          }).toList(),
        ),
      );
    }
    
    // Target strength (customizable)
    dataSets.add(
      RadarDataSet(
        fillColor: context.colors.surface.withValues(alpha: 0),
        borderColor: context.colors.success.withValues(alpha: 0.4),
        borderWidth: 1.5,
        entryRadius: 0,
        dataEntries: MuscleGroup.values.map((muscle) {
          final data = widget.muscleData[muscle];
          final value = data?.targetStrength ?? 75;
          return RadarEntry(value: value);
        }).toList(),
      ),
    );
    
    return dataSets;
  }

  Widget _buildEnhancedLegend(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Zone legend (new)
          _buildZoneLegend(theme, l10n),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Data legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: theme.colorScheme.primary,
                label: l10n.currentStrength,
                value: _calculateAverageStrength(),
                theme: theme,
              ),
              if (_showComparison)
                _buildLegendItem(
                  color: context.colors.secondary,
                  label: l10n.lastMonth,
                  value: _calculateAveragePreviousStrength(),
                  theme: theme,
                ),
              _buildLegendItem(
                color: context.colors.success,
                label: l10n.target,
                value: _calculateAverageTarget(),
                isDashed: true,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Explanation text
          Text(
            l10n.strengthCalculationHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build zone legend showing insufficient/optimal/excessive zones
  Widget _buildZoneLegend(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildZoneIndicator(
          color: context.colors.error,
          label: l10n.insufficientVolume,
          range: '0-40%',
          theme: theme,
        ),
        _buildZoneIndicator(
          color: context.colors.success,
          label: l10n.optimalVolume,
          range: '40-80%',
          theme: theme,
        ),
        _buildZoneIndicator(
          color: context.colors.warning,
          label: l10n.excessiveVolume,
          range: '80%+',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildZoneIndicator({
    required Color color,
    required String label,
    required String range,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: color, width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          range,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double value,
    bool isDashed = false,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Row(
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
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMuscleDetails(ThemeData theme, AppLocalizations l10n) {
    if (_selectedMuscle == null) return const SizedBox.shrink();
    
    final data = widget.muscleData[_selectedMuscle!];
    if (data == null) return const SizedBox.shrink();
    
    final improvement = data.currentStrength - (data.previousStrength ?? data.currentStrength);
    final improvementPercent = data.previousStrength != null && data.previousStrength! > 0
        ? (improvement / data.previousStrength! * 100)
        : 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with muscle info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMuscleIcon(_selectedMuscle!),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMuscleFullName(_selectedMuscle!, l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.tapToEditTarget,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
  size: AppIconSize.small,
),
                onPressed: () {
                  setState(() {
                    _selectedMuscle = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Strength metrics with explanations
          _buildMetricRow(
            icon: AppIcons.workout,
            label: l10n.currentStrength,
            value: data.currentStrength,
            color: theme.colorScheme.primary,
            explanation: l10n.strengthExplanation(data.totalVolume.toStringAsFixed(0)),
            theme: theme,
            l10n: l10n,
          ),
          
          const SizedBox(height: 12),
          
          // Target with edit button
          _buildEditableMetricRow(
            icon: AppIcons.flag,
            label: l10n.targetStrength,
            value: data.targetStrength,
            color: context.colors.success,
            onEdit: () => _editTarget(_selectedMuscle!, data.targetStrength),
            theme: theme,
            l10n: l10n,
          ),
          
          // Progress indicator
          if (improvement != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (improvement >= 0 ? context.colors.success : context.colors.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (improvement >= 0 ? context.colors.success : context.colors.error).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    improvement >= 0 ? AppIcons.trendingUp : AppIcons.trendingDown,
                    color: improvement >= 0 ? context.colors.success : context.colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}% '
                          '(${improvementPercent >= 0 ? '+' : ''}${improvementPercent.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: improvement >= 0 ? context.colors.success : context.colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.comparedToLastMonth,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          
          // Volume breakdown
          if (data.exerciseBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SemanticIcon(
  icon: AppIcons.barChart,
  semanticLabel: 'Chart',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurface.withValues(alpha: 0.7,
),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.volumeBreakdown,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...data.exerciseBreakdown.entries.take(3).map((entry) {
                  final percentage = (entry.value / data.totalVolume * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required String explanation,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          explanation,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableMetricRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required VoidCallback onEdit,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
            const Spacer(),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.toStringAsFixed(0)}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SemanticIcon(
  icon: AppIcons.edit,
  semanticLabel: 'Edit',
  size: AppIconSize.tiny,
  color: color,
),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  void _calculateMuscleRegions(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Il radar chart di fl_chart dispone i punti partendo dall'alto (12 ore)
    // e procedendo in senso orario
    // Dobbiamo mappare correttamente ogni segmento al gruppo muscolare corrispondente
    
    for (int i = 0; i < MuscleGroup.values.length; i++) {
      final muscle = MuscleGroup.values[i];
      
      // Calcoliamo gli angoli per ogni segmento
      // Partiamo da -π/2 (in alto) e procediamo in senso orario
      final anglePerSegment = 2 * math.pi / MuscleGroup.values.length;
      final startAngle = (i * anglePerSegment) - math.pi / 2;
      final endAngle = ((i + 1) * anglePerSegment) - math.pi / 2;
      
      // Creiamo il Path per il segmento del muscolo
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      // Aggiungiamo un raggio maggiore per catturare i tap più facilmente
      final extendedRadius = radius * 1.2;
      
      // Disegniamo il segmento
      path.lineTo(
        center.dx + extendedRadius * math.cos(startAngle),
        center.dy + extendedRadius * math.sin(startAngle),
      );
      
      // Aggiungiamo l'arco
      path.arcTo(
        Rect.fromCircle(center: center, radius: extendedRadius),
        startAngle,
        anglePerSegment,
        false,
      );
      
      path.close();
      
      _muscleRegions[muscle] = path;
    }
  }

  void _handleTap(TapUpDetails details) {
    for (final entry in _muscleRegions.entries) {
      if (entry.value.contains(details.localPosition)) {
        setState(() {
          _selectedMuscle = entry.key;
        });
        HapticFeedback.lightImpact();
        widget.onMuscleGroupTap?.call(entry.key);
        break;
      }
    }
  }

  void _handleHover(DragUpdateDetails details) {
    for (final entry in _muscleRegions.entries) {
      if (entry.value.contains(details.localPosition)) {
        if (_hoveredMuscle != entry.key) {
          setState(() {
            _hoveredMuscle = entry.key;
          });
        }
        return;
      }
    }
    
    if (_hoveredMuscle != null) {
      setState(() {
        _hoveredMuscle = null;
      });
    }
  }

  void _showHelpDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.howStrengthIsCalculated),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.strengthCalculationExplanation),
              const SizedBox(height: 16),
              _buildFormulaCard(
                title: l10n.volumeFormula,
                formula: 'Volume = Sets × Reps × Weight',
                example: '3 sets × 10 reps × 50kg = 1500kg',
              ),
              const SizedBox(height: 12),
              _buildFormulaCard(
                title: l10n.strengthPercentage,
                formula: 'Strength % = (Current Volume / Max Volume) × 100',
                example: '(1500kg / 5000kg) × 100 = 30%',
              ),
              const SizedBox(height: 16),
              Text(
                l10n.targetExplanation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard({
    required String title,
    required String formula,
    required String example,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formula,
              style: theme.textTheme.bodyMedium!.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            example,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog() {
    // Tutorial implementation
  }

  void _showTargetEditDialog() {
    // Target edit dialog implementation
  }

  void _editTarget(MuscleGroup muscle, double currentTarget) {
    // Individual target edit implementation
  }

  double _calculateOverallBalance() {
    if (widget.muscleData.isEmpty) return 0;
    
    final strengths = widget.muscleData.values
        .map((data) => data.currentStrength)
        .toList();
    
    if (strengths.isEmpty) return 0;
    
    final mean = strengths.reduce((a, b) => a + b) / strengths.length;
    final variance = strengths.map((s) => math.pow(s - mean, 2)).reduce((a, b) => a + b) / strengths.length;
    final standardDeviation = math.sqrt(variance);
    
    // Balance score: 100 when perfectly balanced, decreases with imbalance
    final balanceScore = 100 * math.exp(-standardDeviation / 20);
    return balanceScore.clamp(0, 100);
  }

  Color _getBalanceColor(double balance) {
    if (balance >= 80) return context.colors.success;
    if (balance >= 60) return context.colors.secondary;
    return context.colors.error;
  }

  String _getBalanceRating(double balance, AppLocalizations l10n) {
    if (balance >= 80) return l10n.excellentBalance;
    if (balance >= 60) return l10n.goodBalance;
    if (balance >= 40) return l10n.moderateBalance;
    return l10n.poorBalance;
  }

  double _calculateAverageStrength() {
    if (widget.muscleData.isEmpty) return 0;
    final total = widget.muscleData.values
        .map((data) => data.currentStrength)
        .reduce((a, b) => a + b);
    return total / widget.muscleData.length;
  }

  double _calculateAveragePreviousStrength() {
    if (widget.muscleData.isEmpty) return 0;
    final total = widget.muscleData.values
        .map((data) => data.previousStrength ?? 0)
        .reduce((a, b) => a + b);
    return total / widget.muscleData.length;
  }

  double _calculateAverageTarget() {
    if (widget.muscleData.isEmpty) return 75;
    final total = widget.muscleData.values
        .map((data) => data.targetStrength)
        .reduce((a, b) => a + b);
    return total / widget.muscleData.length;
  }

  /// Get status icon for the zone
  String _getStatusIcon(VolumeStatus status) {
    switch (status) {
      case VolumeStatus.insufficient:
        return '⚠️'; // Warning - needs more volume
      case VolumeStatus.optimal:
        return '✅'; // Good - in optimal range
      case VolumeStatus.excessive:
        return '🔥'; // Fire - might be overtraining
    }
  }

  String _getMuscleLabel(MuscleGroup muscle, AppLocalizations l10n) {
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chest;
      case MuscleGroup.back:
        return l10n.back;
      case MuscleGroup.shoulders:
        return l10n.shoulders;
      case MuscleGroup.arms:
        return l10n.arms;
      case MuscleGroup.legs:
        return l10n.legs;
      case MuscleGroup.core:
        return l10n.core;
    }
  }

  String _getMuscleFullName(MuscleGroup muscle, AppLocalizations l10n) {
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chestFull;
      case MuscleGroup.back:
        return l10n.backFull;
      case MuscleGroup.shoulders:
        return l10n.shouldersFull;
      case MuscleGroup.arms:
        return l10n.armsFull;
      case MuscleGroup.legs:
        return l10n.legsFull;
      case MuscleGroup.core:
        return l10n.coreFull;
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

/// Zone thresholds for muscle balance visualization
class VolumeZone {
  const VolumeZone._();

  /// Insufficient volume threshold (0-40%)
  static const double insufficientMax = 0.40;

  /// Optimal volume range (40-80%)
  static const double optimalMin = 0.40;
  static const double optimalMax = 0.80;

  /// Excessive volume threshold (80%+)
  static const double excessiveMin = 0.80;

  /// Get zone status for a given strength percentage (0-100)
  static VolumeStatus getStatus(double strengthPercent) {
    final normalized = strengthPercent / 100;
    if (normalized < insufficientMax) return VolumeStatus.insufficient;
    if (normalized <= optimalMax) return VolumeStatus.optimal;
    return VolumeStatus.excessive;
  }
}

/// Volume status enum
enum VolumeStatus {
  insufficient,
  optimal,
  excessive;

  String get labelKey {
    switch (this) {
      case VolumeStatus.insufficient:
        return 'insufficient';
      case VolumeStatus.optimal:
        return 'optimal';
      case VolumeStatus.excessive:
        return 'excessive';
    }
  }
}

// Enhanced custom painter for better visuals with zone rings
class _EnhancedRadarPainter extends CustomPainter {

  _EnhancedRadarPainter({
    required this.muscleData,
    this.selectedMuscle,
    this.hoveredMuscle,
    required this.theme,
    required this.animation,
    required this.showComparison,
    this.muscleRegions = const {},
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });
  final Map<MuscleGroup, MuscleStrengthData> muscleData;
  final MuscleGroup? selectedMuscle;
  final MuscleGroup? hoveredMuscle;
  final ThemeData theme;
  final double animation;
  final bool showComparison;
  final Map<MuscleGroup, Path> muscleRegions;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.35;
    final numPoints = MuscleGroup.values.length;

    // Draw colored zone rings (from outer to inner so they layer correctly)
    _drawZoneRings(canvas, center, maxRadius, numPoints);

    // Paint touch regions
    if (muscleRegions.isNotEmpty) {
      for (final entry in muscleRegions.entries) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = theme.colorScheme.outline.withValues(alpha: 0.2);

        // Highlight selected or hovered region
        if (entry.key == selectedMuscle) {
          paint
            ..style = PaintingStyle.fill
            ..color = theme.colorScheme.primary.withValues(alpha: 0.15);
          canvas.drawPath(entry.value, paint);

          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = theme.colorScheme.primary;
          canvas.drawPath(entry.value, paint);
        } else if (entry.key == hoveredMuscle) {
          paint
            ..style = PaintingStyle.fill
            ..color = theme.colorScheme.primary.withValues(alpha: 0.08);
          canvas.drawPath(entry.value, paint);
        }
      }
    }
  }

  /// Draw colored zone rings to indicate insufficient/optimal/excessive
  void _drawZoneRings(Canvas canvas, Offset center, double maxRadius, int numPoints) {
    // Zone boundaries (as percentage of max radius)
    // 0-40% = Insufficient (red/orange)
    // 40-80% = Optimal (green)
    // 80-100% = Excessive (orange/yellow)

    final zones = [
      // Excessive zone (80-100%) - outer ring
      _ZoneRing(
        innerPercent: VolumeZone.excessiveMin,
        outerPercent: 1.0,
        color: warningColor.withValues(alpha: 0.15),
        borderColor: warningColor.withValues(alpha: 0.4),
      ),
      // Optimal zone (40-80%) - middle ring
      _ZoneRing(
        innerPercent: VolumeZone.optimalMin,
        outerPercent: VolumeZone.optimalMax,
        color: successColor.withValues(alpha: 0.12),
        borderColor: successColor.withValues(alpha: 0.35),
      ),
      // Insufficient zone (0-40%) - inner area
      _ZoneRing(
        innerPercent: 0,
        outerPercent: VolumeZone.insufficientMax,
        color: errorColor.withValues(alpha: 0.10),
        borderColor: errorColor.withValues(alpha: 0.3),
      ),
    ];

    for (final zone in zones) {
      _drawPolygonRing(
        canvas,
        center,
        maxRadius * zone.innerPercent * animation,
        maxRadius * zone.outerPercent * animation,
        numPoints,
        zone.color,
        zone.borderColor,
      );
    }
  }

  /// Draw a polygon ring (donut shape) for a zone
  void _drawPolygonRing(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    int numPoints,
    Color fillColor,
    Color borderColor,
  ) {
    if (outerRadius <= 0) return;

    final outerPath = _createPolygonPath(center, outerRadius, numPoints);
    final innerPath = _createPolygonPath(center, innerRadius, numPoints);

    // Create ring by subtracting inner from outer
    final ringPath = Path.combine(PathOperation.difference, outerPath, innerPath);

    // Fill
    canvas.drawPath(
      ringPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor,
    );

    // Outer border only (more subtle)
    canvas.drawPath(
      outerPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = borderColor,
    );
  }

  /// Create a regular polygon path
  Path _createPolygonPath(Offset center, double radius, int numPoints) {
    final path = Path();
    if (radius <= 0) {
      path.addOval(Rect.fromCenter(center: center, width: 1, height: 1));
      return path;
    }

    for (int i = 0; i < numPoints; i++) {
      // Start from top (-π/2) and go clockwise
      final angle = (i * 2 * math.pi / numPoints) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _EnhancedRadarPainter oldDelegate) =>
    oldDelegate.selectedMuscle != selectedMuscle ||
    oldDelegate.hoveredMuscle != hoveredMuscle ||
    oldDelegate.animation != animation;
}

/// Helper class for zone ring data
class _ZoneRing {
  const _ZoneRing({
    required this.innerPercent,
    required this.outerPercent,
    required this.color,
    required this.borderColor,
  });

  final double innerPercent;
  final double outerPercent;
  final Color color;
  final Color borderColor;
}

// Data models
enum MuscleGroup {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
}

class MuscleStrengthData { // Volume from secondary exercises (weighted)

  MuscleStrengthData({
    required this.currentStrength,
    this.previousStrength,
    this.targetStrength = 75,
    required this.totalVolume,
    this.exerciseBreakdown = const {},
    this.primaryVolume = 0,
    this.secondaryVolume = 0,
  });
  final double currentStrength; // 0-100 percentage
  final double? previousStrength; // Previous period strength
  final double targetStrength; // User-defined target
  final double totalVolume; // Total volume in kg
  final Map<String, double> exerciseBreakdown; // Exercise name -> volume
  final double primaryVolume; // Volume from primary exercises
  final double secondaryVolume;

  /// Percentage of volume from primary exercises
  double get primaryPercentage {
    if (totalVolume == 0) return 0;
    return (primaryVolume / totalVolume * 100);
  }

  /// Percentage of volume from secondary exercises
  double get secondaryPercentage {
    if (totalVolume == 0) return 0;
    return (secondaryVolume / totalVolume * 100);
  }
}
