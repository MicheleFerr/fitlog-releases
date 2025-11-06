import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/barbell_selector_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class PlateCalculatorWidget extends ConsumerStatefulWidget {
  
  const PlateCalculatorWidget({
    super.key,
    required this.targetWeight,
    required this.onWeightChanged,
    this.unit = 'kg',
  });
  final double targetWeight;
  final Function(double) onWeightChanged;
  final String unit;

  @override
  ConsumerState<PlateCalculatorWidget> createState() => _PlateCalculatorWidgetState();
}

class _PlateCalculatorWidgetState extends ConsumerState<PlateCalculatorWidget> {
  // Default available plates in kg
  static const List<double> allPlates = [25, 20, 15, 10, 5, 2.5, 1.25, 0.5];
  late List<double> availablePlates;
  bool _showPlateConfig = false;
  
  double? _barbellWeight = 20.0; // Now nullable to support "no barbell" option
  late double _targetWeight;
  final Map<double, int> _plateCounts = {};
  
  @override
  void initState() {
    super.initState();
    _targetWeight = widget.targetWeight;
    
    // Load saved available plates from config or use defaults
    final config = ref.read(appConfigProvider);
    availablePlates = config.availablePlates ?? List.from(allPlates);
    
    _calculatePlates();
  }
  
  @override
  void didUpdateWidget(PlateCalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetWeight != widget.targetWeight) {
      _targetWeight = widget.targetWeight;
      _calculatePlates();
    }
  }
  
  void _calculatePlates() {
    _plateCounts.clear();
    
    if (_targetWeight <= 0) return;
    
    double remainingWeight = _targetWeight;
    
    // Subtract barbell weight if included
    if (_barbellWeight != null && _barbellWeight! > 0) {
      remainingWeight -= _barbellWeight!;
    }
    
    if (remainingWeight <= 0) return;
    
    // Calculate weight per side
    double weightPerSide = remainingWeight / 2;
    
    // Greedy algorithm to find minimum plates
    for (double plate in availablePlates) {
      final int count = (weightPerSide / plate).floor();
      if (count > 0) {
        _plateCounts[plate] = count;
        weightPerSide -= count * plate;
      }
    }
    
    // Handle remaining weight with smallest plate
    if (weightPerSide > 0.01) {
      final double smallestPlate = availablePlates.last;
      _plateCounts[smallestPlate] = (_plateCounts[smallestPlate] ?? 0) + 1;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header with barbell selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.workout,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_targetWeight.toStringAsFixed(_targetWeight % 1 == 0 ? 0 : 1)} ${widget.unit}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (_barbellWeight != null && _barbellWeight! > 0)
                      Text(
                        AppLocalizations.of(context).barbellIncluded(_barbellWeight!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Text(
                        AppLocalizations.of(context).noBarbell,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showBarbellSelector(context),
                icon: Icon(
                  _barbellWeight != null ? Icons.fitness_center : AppIcons.block,
                  size: 16,
                ),
                label: Text(
                  _barbellWeight != null 
                      ? '${_barbellWeight}kg' 
                      : AppLocalizations.of(context).selectBarbellButton,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Visual plate display
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left side plates
              Expanded(
                child: _buildPlatesSide(isLeft: true),
              ),
              
              // Barbell
              Container(
                width: 60,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Right side plates
              Expanded(
                child: _buildPlatesSide(isLeft: false),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Plate list
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppIcons.formatListNumbered,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).perSide,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_plateCounts.isEmpty)
                Text(
                  _barbellWeight != null && _barbellWeight! > 0 
                      ? AppLocalizations.of(context).onlyBarbell
                      : AppLocalizations.of(context).noPlates,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ..._plateCounts.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPlateColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value}x ${entry.key}kg',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Plate configuration toggle
        InkWell(
          onTap: () {
            setState(() {
              _showPlateConfig = !_showPlateConfig;
            });
            HapticFeedback.selectionClick();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.settings,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).configureAvailablePlates,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showPlateConfig ? AppIcons.expandLess : AppIcons.expandMore,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
        
        // Plate configuration UI
        if (_showPlateConfig) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).selectAvailablePlates,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allPlates.map((plate) {
                    final isAvailable = availablePlates.contains(plate);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isAvailable) {
                            availablePlates.remove(plate);
                          } else {
                            availablePlates.add(plate);
                            availablePlates.sort((a, b) => b.compareTo(a));
                          }
                          _calculatePlates();
                          _saveAvailablePlates();
                        });
                        HapticFeedback.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAvailable 
                              ? _getPlateColor(plate).withValues(alpha: 0.3)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAvailable
                                ? _getPlateColor(plate)
                                : theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: isAvailable ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAvailable)
                              Icon(
                                AppIcons.complete,
                                size: 16,
                                color: _getPlateColor(plate),
                              )
                            else
                              Icon(
                                AppIcons.cancel,
                                size: 16,
                                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '${plate}kg',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isAvailable
                                    ? _getPlateColor(plate)
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
                                decoration: isAvailable ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            availablePlates = List.from(allPlates);
                            _calculatePlates();
                            _saveAvailablePlates();
                          });
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(AppIcons.selectAll, size: 16),
                        label: Text(AppLocalizations.of(context).plateCalculatorAll),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            availablePlates = [20, 10, 5, 2.5, 1.25];
                            _calculatePlates();
                            _saveAvailablePlates();
                          });
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(AppIcons.star, size: 16),
                        label: Text(AppLocalizations.of(context).plateCalculatorStandard),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Quick weight buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [20, 40, 60, 80, 100, 120, 140].map((weight) {
            final isSelected = _targetWeight == weight.toDouble();
            return InkWell(
              onTap: () {
                setState(() {
                  _targetWeight = weight.toDouble();
                  _calculatePlates();
                });
                widget.onWeightChanged(weight.toDouble());
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${weight}kg',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildPlatesSide({required bool isLeft}) {
    if (_plateCounts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final List<Widget> plates = [];
    
    _plateCounts.forEach((weight, count) {
      for (int i = 0; i < count; i++) {
        plates.add(_buildPlateVisual(weight));
      }
    });
    
    return Row(
      mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isLeft ? plates.reversed.toList() : plates,
    );
  }
  
  Widget _buildPlateVisual(double weight) {
    final color = _getPlateColor(weight);
    final height = _getPlateHeight(weight);
    
    return Container(
      width: 6,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.black26,
          width: 0.5,
        ),
      ),
    );
  }
  
  Color _getPlateColor(double weight) {
    if (weight >= 25) return Colors.red;
    if (weight >= 20) return Colors.blue;
    if (weight >= 15) return Colors.yellow.shade700;
    if (weight >= 10) return Colors.green;
    if (weight >= 5) return Colors.grey.shade600;
    if (weight >= 2.5) return Colors.orange;
    if (weight >= 1.25) return Colors.purple;
    return Colors.grey.shade400;
  }
  
  double _getPlateHeight(double weight) {
    if (weight >= 25) return 60;
    if (weight >= 20) return 55;
    if (weight >= 15) return 50;
    if (weight >= 10) return 45;
    if (weight >= 5) return 40;
    if (weight >= 2.5) return 35;
    if (weight >= 1.25) return 30;
    return 25;
  }
  
  void _saveAvailablePlates() {
    final notifier = ref.read(appConfigProvider.notifier);
    notifier.updateConfig(
      notifier.state.copyWith(availablePlates: availablePlates),
    );
  }
  
  void _showBarbellSelector(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Row(
                  children: [
                    Icon(
                      AppIcons.workout,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context).selectBarbell,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(AppIcons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Barbell selector widget
                Expanded(
                  child: BarbellSelectorWidget(
                    selectedBarbellWeight: _barbellWeight,
                    onBarbellSelected: (weight) {
                      setState(() {
                        _barbellWeight = weight;
                        _calculatePlates();
                      });
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
