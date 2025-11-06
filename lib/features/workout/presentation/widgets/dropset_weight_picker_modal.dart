import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/presentation/utils/weight_rounding_utils.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Modal for picking weight in DropSet exercises with smart rounding
///
/// Features:
/// - First stage: Direct weight input
/// - Subsequent stages: Percentage drop selection with smart rounding
/// - Equipment type detection (barbell/dumbbell)
/// - Dumbbell increment preference (0.5kg, 1kg, 2kg)
class DropSetWeightPickerModal extends StatefulWidget {

  const DropSetWeightPickerModal({
    super.key,
    required this.stageIndex,
    this.previousStageWeight,
    this.initialWeight,
    this.selectedExercise,
    this.exerciseName,
  });
  /// Stage number (0-indexed: 0 = first stage, 1+ = subsequent stages)
  final int stageIndex;

  /// Weight of the previous stage (null for first stage)
  final double? previousStageWeight;

  /// Initial weight value (if editing existing stage)
  final double? initialWeight;

  /// Exercise information for equipment detection
  final ExerciseDB.Exercise? selectedExercise;

  /// Exercise name for equipment detection (fallback)
  final String? exerciseName;

  @override
  State<DropSetWeightPickerModal> createState() => _DropSetWeightPickerModalState();

  /// Static method to show modal and return selected weight
  static Future<double?> show({
    required BuildContext context,
    required int stageIndex,
    double? previousStageWeight,
    double? initialWeight,
    ExerciseDB.Exercise? selectedExercise,
    String? exerciseName,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DropSetWeightPickerModal(
        stageIndex: stageIndex,
        previousStageWeight: previousStageWeight,
        initialWeight: initialWeight,
        selectedExercise: selectedExercise,
        exerciseName: exerciseName,
      ),
    );
  }
}

class _DropSetWeightPickerModalState extends State<DropSetWeightPickerModal> {
  late final TextEditingController _weightController;
  EquipmentType? _detectedEquipmentType;
  EquipmentType? _userSelectedEquipmentType;
  DumbbellIncrement _dumbbellIncrement = DumbbellIncrement.standard;
  bool _showEquipmentSelector = false;
  bool _showIncrementSelector = false;
  int? _selectedDropPercentage;
  double? _calculatedWeight;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight?.toStringAsFixed(1) ?? '',
    );

    // Detect equipment type
    _detectEquipment();

    // If subsequent stage and equipment is known, show percentage selector
    if (widget.stageIndex > 0 && widget.previousStageWeight != null) {
      _showPercentageSelector();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _detectEquipment() {
    final exerciseName = widget.selectedExercise?.nome ?? widget.exerciseName ?? '';
    final attrezzatura = widget.selectedExercise?.attrezzatura;

    _detectedEquipmentType = WeightRoundingUtils.detectEquipmentType(
      exerciseName: exerciseName,
      attrezzaturaField: attrezzatura,
    );

    // If unknown, show equipment selector
    if (_detectedEquipmentType == EquipmentType.unknown) {
      setState(() {
        _showEquipmentSelector = true;
      });
    } else if (_detectedEquipmentType == EquipmentType.dumbbell) {
      // For dumbbells, show increment selector
      setState(() {
        _showIncrementSelector = true;
      });
    }
  }

  void _showPercentageSelector() {
    // Don't auto-show if we already have initial weight
    if (widget.initialWeight != null) return;

    // Default to 20% drop
    _selectedDropPercentage = 20;
    _calculateDroppedWeight();
  }

  void _calculateDroppedWeight() {
    if (_selectedDropPercentage == null || widget.previousStageWeight == null) {
      return;
    }

    final equipmentType = _userSelectedEquipmentType ?? _detectedEquipmentType ?? EquipmentType.unknown;

    final calculatedWeight = WeightRoundingUtils.calculateNextStageWeight(
      currentWeight: widget.previousStageWeight!,
      dropPercentage: _selectedDropPercentage!,
      equipmentType: equipmentType,
      dumbbellIncrement: _dumbbellIncrement,
    );

    setState(() {
      _calculatedWeight = calculatedWeight;
      _weightController.text = calculatedWeight.toStringAsFixed(1);
    });
  }

  EquipmentType get _effectiveEquipmentType =>
      _userSelectedEquipmentType ?? _detectedEquipmentType ?? EquipmentType.unknown;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stageIndex == 0
                            ? context.l10n.dropsetStage1Weight
                            : context.l10n.dropsetStageNWeight(widget.stageIndex + 1),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.previousStageWeight != null)
                        Text(
                          '${context.l10n.previousStageWeight}: ${widget.previousStageWeight!.toStringAsFixed(1)} kg',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(AppIcons.close),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Equipment type info/selector
                  _buildEquipmentSection(),

                  const SizedBox(height: 20),

                  // Percentage selector (for subsequent stages)
                  if (widget.stageIndex > 0 && widget.previousStageWeight != null)
                    _buildPercentageSelector(),

                  const SizedBox(height: 20),

                  // Weight input
                  _buildWeightInput(),

                  const SizedBox(height: 24),

                  // Confirm button
                  FilledButton(
                    onPressed: _canConfirm() ? _confirmWeight : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        context.l10n.confirm,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: context.bottomPadding + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection() {
    if (_showEquipmentSelector) {
      return _buildEquipmentSelector();
    }

    // Show detected equipment type
    return Card(
      color: context.colors.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _effectiveEquipmentType == EquipmentType.barbell
                  ? AppIcons.workout
                  : _effectiveEquipmentType == EquipmentType.machine
                      ? AppIcons.settings
                      : AppIcons.gymnastics,
              color: context.colors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.detectedEquipmentType,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _effectiveEquipmentType == EquipmentType.barbell
                        ? context.l10n.barbell
                        : _effectiveEquipmentType == EquipmentType.machine
                            ? 'Machine'
                            : context.l10n.dumbbell,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _effectiveEquipmentType == EquipmentType.barbell
                        ? context.l10n.barbellRoundingInfo
                        : _effectiveEquipmentType == EquipmentType.machine
                            ? '5kg increments'
                            : '2.5kg increments',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showEquipmentSelector = !_showEquipmentSelector;
                });
              },
              child: Text(context.l10n.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSelector() {
    return Card(
      color: context.colors.tertiaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.selectEquipmentType,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEquipmentCard(
                    type: EquipmentType.barbell,
                    icon: AppIcons.workout,
                    title: context.l10n.barbell,
                    subtitle: context.l10n.barbellRoundingInfo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEquipmentCard(
                    type: EquipmentType.dumbbell,
                    icon: AppIcons.gymnastics,
                    title: context.l10n.dumbbell,
                    subtitle: '2.5kg',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEquipmentCard(
                    type: EquipmentType.machine,
                    icon: AppIcons.settings,
                    title: 'Machine',
                    subtitle: '5kg',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCard({
    required EquipmentType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _userSelectedEquipmentType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _userSelectedEquipmentType = type;
          _showEquipmentSelector = false;

          // Show increment selector only for dumbbells
          if (type == EquipmentType.dumbbell) {
            _showIncrementSelector = true;
          } else {
            _showIncrementSelector = false;
          }

          // Recalculate if we have a percentage selected
          if (_selectedDropPercentage != null) {
            _calculateDroppedWeight();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withOpacity(0.1)
              : context.colors.surface,
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? context.colors.primary : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageSelector() {
    return Card(
      color: context.colors.secondaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.trendDown,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.selectWeightDrop,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WeightRoundingUtils.standardDropPercentages.map((percentage) {
                final isSelected = _selectedDropPercentage == percentage;
                return ChoiceChip(
                  label: Text('-$percentage%'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDropPercentage = selected ? percentage : null;
                      _calculateDroppedWeight();
                    });
                  },
                  selectedColor: context.colors.secondary,
                  labelStyle: TextStyle(
                    color: isSelected ? context.colors.onSecondary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
            if (_calculatedWeight != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.primary),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.calculate,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.calculatedWeight,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${_calculatedWeight!.toStringAsFixed(1)} kg',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_effectiveEquipmentType == EquipmentType.dumbbell && _showIncrementSelector)
              _buildIncrementSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          context.l10n.dumbbellIncrementQuestion,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...DumbbellIncrement.values.map((increment) {
          final isSelected = _dumbbellIncrement == increment;
          return RadioListTile<DumbbellIncrement>(
            value: increment,
            groupValue: _dumbbellIncrement,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _dumbbellIncrement = value;
                  // Recalculate weight with new increment
                  if (_selectedDropPercentage != null) {
                    _calculateDroppedWeight();
                  }
                });
              }
            },
            title: Text(
              _getIncrementDisplayName(increment),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  String _getIncrementDisplayName(DumbbellIncrement increment) {
    switch (increment) {
      case DumbbellIncrement.standard:
        return '2.5kg (17.5, 20, 22.5, 25...)';
      case DumbbellIncrement.halfKg:
        return context.l10n.dumbbellIncrementHalfKg;
      case DumbbellIncrement.oneKg:
        return context.l10n.dumbbellIncrementOneKg;
      case DumbbellIncrement.twoKg:
        return context.l10n.dumbbellIncrementTwoKg;
    }
  }

  Widget _buildWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.stageIndex == 0
              ? context.l10n.enterInitialWeight
              : context.l10n.confirmOrAdjustWeight,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            labelText: context.l10n.weight,
            hintText: '100.0',
            suffixText: 'kg',
            prefixIcon: const Icon(AppIcons.workout),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              // User is manually adjusting, clear calculated weight indicator
              _calculatedWeight = null;
            });
          },
        ),
      ],
    );
  }

  bool _canConfirm() {
    final text = _weightController.text.trim();
    if (text.isEmpty) return false;

    final weight = double.tryParse(text);
    return weight != null && weight > 0;
  }

  void _confirmWeight() {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null) return;

    Navigator.pop(context, weight);
  }
}
