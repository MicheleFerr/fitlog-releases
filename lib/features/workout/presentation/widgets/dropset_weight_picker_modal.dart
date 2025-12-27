import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/presentation/utils/weight_rounding_utils.dart';

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
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
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
  static const String _prefKeyUseAbsoluteDrop = 'dropset_use_absolute_weight_drop';
  static const List<double> absoluteDropValues = [2.5, 5, 10, 15, 20];

  late final TextEditingController _weightController;
  EquipmentType? _detectedEquipmentType;
  EquipmentType? _userSelectedEquipmentType;
  final DumbbellIncrement _dumbbellIncrement = DumbbellIncrement.standard;
  bool _showEquipmentSelector = false;
  bool _useAbsoluteDrop = true; // Default to absolute (more intuitive)
  int? _selectedDropPercentage;
  double? _selectedAbsoluteDrop;
  double? _calculatedWeight;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight?.toStringAsFixed(1) ?? '',
    );

    // Load preference and detect equipment
    _loadPreferences();
    _detectEquipment();

    // If subsequent stage, show drop selector with default
    if (widget.stageIndex > 0 && widget.previousStageWeight != null) {
      _initializeDropSelector();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _useAbsoluteDrop = prefs.getBool(_prefKeyUseAbsoluteDrop) ?? true;
      });
      // Recalculate if we have a drop selected
      if (widget.stageIndex > 0 && widget.previousStageWeight != null) {
        _initializeDropSelector();
      }
    }
  }

  Future<void> _savePreference(bool useAbsolute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyUseAbsoluteDrop, useAbsolute);
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

    // Only show equipment selector if truly unknown (no JSON data)
    if (_detectedEquipmentType == EquipmentType.unknown) {
      _showEquipmentSelector = true;
    }
  }

  void _initializeDropSelector() {
    // Don't auto-show if we already have initial weight
    if (widget.initialWeight != null) return;

    if (_useAbsoluteDrop) {
      // Default to -5kg for absolute mode
      _selectedAbsoluteDrop = 5;
      _selectedDropPercentage = null;
    } else {
      // Default to 20% for percentage mode
      _selectedDropPercentage = 20;
      _selectedAbsoluteDrop = null;
    }
    _calculateDroppedWeight();
  }

  void _calculateDroppedWeight() {
    if (widget.previousStageWeight == null) return;

    double? calculatedWeight;

    if (_useAbsoluteDrop && _selectedAbsoluteDrop != null) {
      // Absolute mode: subtract directly
      calculatedWeight = widget.previousStageWeight! - _selectedAbsoluteDrop!;
      if (calculatedWeight < 0) calculatedWeight = 0;
    } else if (!_useAbsoluteDrop && _selectedDropPercentage != null) {
      // Percentage mode: use smart rounding
      final equipmentType = _userSelectedEquipmentType ?? _detectedEquipmentType ?? EquipmentType.unknown;
      calculatedWeight = WeightRoundingUtils.calculateNextStageWeight(
        currentWeight: widget.previousStageWeight!,
        dropPercentage: _selectedDropPercentage!,
        equipmentType: equipmentType,
        dumbbellIncrement: _dumbbellIncrement,
      );
    }

    if (calculatedWeight != null) {
      setState(() {
        _calculatedWeight = calculatedWeight;
        _weightController.text = calculatedWeight!.toStringAsFixed(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Equipment selector - ONLY if unknown
                  _buildEquipmentSection(),

                  // For subsequent stages: percentage chips + calculated weight
                  if (widget.stageIndex > 0 && widget.previousStageWeight != null) ...[
                    _buildPercentageSelector(),
                    const SizedBox(height: 16),
                    // Show calculated weight prominently
                    if (_calculatedWeight != null)
                      Center(
                        child: Text(
                          '${_calculatedWeight!.toStringAsFixed(1)} kg',
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],

                  // Weight input (compact for subsequent stages)
                  _buildWeightInput(),

                  const SizedBox(height: 16),

                  // Confirm button - show weight in button for clarity
                  FilledButton(
                    onPressed: _canConfirm() ? _confirmWeight : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _weightController.text.isNotEmpty
                            ? '${context.l10n.confirm} ${_weightController.text} kg'
                            : context.l10n.confirm,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: context.bottomPadding + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection() {
    // ONLY show equipment selector if equipment is truly unknown
    // If auto-detected from JSON, don't show anything - just use the data silently
    if (_showEquipmentSelector) {
      return _buildEquipmentSelector();
    }

    // Equipment auto-detected - no UI needed, data used silently
    return const SizedBox.shrink();
  }

  Widget _buildEquipmentSelector() {
    return Card(
      color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
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
              ? context.colors.primary.withValues(alpha: 0.1)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode toggle - subtle, saved in preferences
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeChip(true, 'kg'),
            const SizedBox(width: 8),
            _buildModeChip(false, '%'),
          ],
        ),
        const SizedBox(height: 12),

        // Drop value chips based on mode
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _useAbsoluteDrop
              ? _buildAbsoluteDropChips()
              : _buildPercentageDropChips(),
        ),
      ],
    );
  }

  Widget _buildModeChip(bool isAbsolute, String label) {
    final isSelected = _useAbsoluteDrop == isAbsolute;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && _useAbsoluteDrop != isAbsolute) {
          setState(() {
            _useAbsoluteDrop = isAbsolute;
            _selectedAbsoluteDrop = null;
            _selectedDropPercentage = null;
            _calculatedWeight = null;
          });
          _savePreference(isAbsolute);
          _initializeDropSelector();
        }
      },
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }

  List<Widget> _buildAbsoluteDropChips() {
    return absoluteDropValues.map((drop) {
      final isSelected = _selectedAbsoluteDrop == drop;
      final label = drop == 2.5 ? '-2.5' : '-${drop.toInt()}';
      return ChoiceChip(
        label: Text('$label kg'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedAbsoluteDrop = selected ? drop : null;
            _selectedDropPercentage = null;
          });
          _calculateDroppedWeight();
        },
        visualDensity: VisualDensity.compact,
      );
    }).toList();
  }

  List<Widget> _buildPercentageDropChips() {
    return WeightRoundingUtils.standardDropPercentages.map((percentage) {
      final isSelected = _selectedDropPercentage == percentage;
      return ChoiceChip(
        label: Text('-$percentage%'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedDropPercentage = selected ? percentage : null;
            _selectedAbsoluteDrop = null;
          });
          _calculateDroppedWeight();
        },
        visualDensity: VisualDensity.compact,
      );
    }).toList();
  }

  Widget _buildWeightInput() {
    // For stage 1: show title, for subsequent stages: just the field (calculated weight is shown above)
    final showTitle = widget.stageIndex == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            context.l10n.enterInitialWeight,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: showTitle ? '100.0' : null,
            suffixText: 'kg',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
