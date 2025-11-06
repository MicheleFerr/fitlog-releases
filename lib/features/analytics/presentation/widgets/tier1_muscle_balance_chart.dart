import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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
                    Colors.transparent,
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
                            ),
                            child: RadarChart(
                              RadarChartData(
                                radarBorderData: BorderSide.none,
                                radarBackgroundColor: Colors.transparent,
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
                                ticksTextStyle: const TextStyle(fontSize: 0),
                                getTitle: (index, angle) {
                                  final muscle = MuscleGroup.values[index];
                                  final isSelected = muscle == _selectedMuscle;
                                  final isHovered = muscle == _hoveredMuscle;
                                  
                                  return RadarChartTitle(
                                    text: _getMuscleLabel(muscle, l10n),
                                    angle: 0,
                                    positionPercentageOffset: isSelected || isHovered ? 0.35 : 0.25,
                                  );
                                },
                                titleTextStyle: TextStyle(
                                  fontSize: 13,
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
          icon: const Icon(AppIcons.refresh),
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
          icon: const Icon(AppIcons.edit, size: 18),
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
            style: TextStyle(
              fontSize: 11,
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
          fillColor: Colors.orange.withValues(alpha: 0.15),
          borderColor: Colors.orange.withValues(alpha: 0.7),
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
        fillColor: Colors.transparent,
        borderColor: Colors.green.withValues(alpha: 0.4),
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
                  color: Colors.orange,
                  label: l10n.lastMonth,
                  value: _calculateAveragePreviousStrength(),
                  theme: theme,
                ),
              _buildLegendItem(
                color: Colors.green,
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
                icon: const Icon(AppIcons.close, size: 20),
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
            color: Colors.green,
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
                color: (improvement >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (improvement >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    improvement >= 0 ? AppIcons.trendUp : AppIcons.trendDown,
                    color: improvement >= 0 ? Colors.green : Colors.red,
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
                            color: improvement >= 0 ? Colors.green : Colors.red,
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
                    Icon(
                      AppIcons.barChart,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
          borderRadius: BorderRadius.circular(4),
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
                    Icon(AppIcons.edit, size: 14, color: color),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formula,
              style: TextStyle(
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
    if (balance >= 80) return Colors.green;
    if (balance >= 60) return Colors.orange;
    return Colors.red;
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

// Enhanced custom painter for better visuals
class _EnhancedRadarPainter extends CustomPainter {

  _EnhancedRadarPainter({
    required this.muscleData,
    this.selectedMuscle,
    this.hoveredMuscle,
    required this.theme,
    required this.animation,
    required this.showComparison,
    this.muscleRegions = const {},
  });
  final Map<MuscleGroup, MuscleStrengthData> muscleData;
  final MuscleGroup? selectedMuscle;
  final MuscleGroup? hoveredMuscle;
  final ThemeData theme;
  final double animation;
  final bool showComparison;
  final Map<MuscleGroup, Path> muscleRegions;

  @override
  void paint(Canvas canvas, Size size) {
    // Paint debug regions to visualize touch areas
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

  @override
  bool shouldRepaint(covariant _EnhancedRadarPainter oldDelegate) => 
    oldDelegate.selectedMuscle != selectedMuscle ||
    oldDelegate.hoveredMuscle != hoveredMuscle ||
    oldDelegate.animation != animation;
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
