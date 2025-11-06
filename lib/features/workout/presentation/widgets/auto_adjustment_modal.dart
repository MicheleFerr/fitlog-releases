import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

class AutoAdjustmentModal extends ConsumerStatefulWidget {

  const AutoAdjustmentModal({
    super.key,
    required this.exercise,
    required this.onSave,
  });
  final Exercise exercise;
  final Function(Exercise) onSave;

  @override
  ConsumerState<AutoAdjustmentModal> createState() => _AutoAdjustmentModalState();
}

class _AutoAdjustmentModalState extends ConsumerState<AutoAdjustmentModal> {
  AutoAdjustmentType? _selectedType;

  // APRE settings
  int _apreProtocol = 6;
  int? _previousProtocol; // Track protocol changes for preview
  final _apreBaseWeightController = TextEditingController();
  double? _calculated1RM;
  double? _calculated3RM;
  double? _calculated6RM;
  double? _calculated10RM;
  String? _calculationInfo;
  bool _isCalculating1RM = false;
  bool _showProtocolPreview = false;

  // RPE settings
  final _targetRPEMinController = TextEditingController();
  final _targetRPEMaxController = TextEditingController();
  final _targetRIRController = TextEditingController();
  bool _useRIR = false;

  @override
  void initState() {
    super.initState();

    // Initialize from existing exercise
    _selectedType = widget.exercise.autoAdjustmentType;

    // APRE settings
    _apreProtocol = widget.exercise.apreProtocol ?? 6;
    _previousProtocol = _apreProtocol; // Initialize previous protocol
    _apreBaseWeightController.text = widget.exercise.apreBaseWeight?.toString() ?? '';

    // Initialize cached calculations if available
    _calculated1RM = widget.exercise.calculated1RM;
    _calculated3RM = widget.exercise.calculated3RM;
    _calculated6RM = widget.exercise.calculated6RM;
    _calculated10RM = widget.exercise.calculated10RM;
    _calculationInfo = widget.exercise.calculationMetadata;

    // Debug log to check what values are loaded from exercise
    if (_calculated1RM != null || _calculated3RM != null || _calculated6RM != null || _calculated10RM != null) {
      debugPrint('[APRE-DEBUG] Modal initialized with cached values from exercise:');
      debugPrint('[APRE-DEBUG]   1RM: ${_calculated1RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   3RM: ${_calculated3RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   6RM: ${_calculated6RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   10RM: ${_calculated10RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   Protocol: $_apreProtocol');
    } else {
      debugPrint('[APRE-DEBUG] NO cached values found in exercise, will calculate from history');
      // Se non ci sono valori cached, calcoliamoli subito
      Future.microtask(() => _calculate1RMAndBaseWeight());
    }

    // If we have cached values but no base weight set, auto-set it
    if (widget.exercise.useAPRE && _apreBaseWeightController.text.isEmpty) {
      final baseWeight = _apreProtocol == 3 ? _calculated3RM :
                         _apreProtocol == 6 ? _calculated6RM :
                         _calculated10RM;
      if (baseWeight != null) {
        _apreBaseWeightController.text = baseWeight.toStringAsFixed(1);
      }
    }

    // RPE settings
    _targetRPEMinController.text = widget.exercise.targetRPEMin?.toString() ?? '7';
    _targetRPEMaxController.text = widget.exercise.targetRPEMax?.toString() ?? '9';
    _targetRIRController.text = widget.exercise.targetRIR?.toString() ?? '2';
  }

  @override
  void dispose() {
    _apreBaseWeightController.dispose();
    _targetRPEMinController.dispose();
    _targetRPEMaxController.dispose();
    _targetRIRController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Header
            Row(
              children: [
                Icon(
                  AppIcons.autoAwesome,
                  color: context.colors.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.autoAdjustment,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.autoAdjustmentDescription,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Type Selection
            Text(
              l10n.selectAutoAdjustmentType,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),

            // Type selector cards
            _buildTypeSelector(l10n),
            SizedBox(height: 24),

            // Configuration based on selected type
            if (_selectedType != null) ...[
              Divider(color: context.colors.outlineVariant),
              const SizedBox(height: 16),

              if (_selectedType == AutoAdjustmentType.apre)
                _buildAPREConfiguration(l10n)
              else if (_selectedType == AutoAdjustmentType.rpe)
                _buildRPEConfiguration(l10n),

              const SizedBox(height: 24),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearSettings,
                    child: Text(l10n.clear ?? 'Clear'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _selectedType != null ? _saveSettings : null,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),

            // Bottom padding for safe area
            SizedBox(height: context.mediaQuery.viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return RadioGroup<AutoAdjustmentType>(
      groupValue: _selectedType,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
          if (value == AutoAdjustmentType.apre) {
            _calculate1RMAndBaseWeight();
          }
        }
      },
      child: Column(
        children: [
          // APRE Card
          Card(
            elevation: _selectedType == AutoAdjustmentType.apre ? 3 : 0,
            color: _selectedType == AutoAdjustmentType.apre
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerHighest,
            child: InkWell(
              onTap: () {
                setState(() => _selectedType = AutoAdjustmentType.apre);
                _calculate1RMAndBaseWeight();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Radio<AutoAdjustmentType>(
                      value: AutoAdjustmentType.apre,
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APRE',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          l10n.apreAutoregulationDescription,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.workout,
                    color: _selectedType == AutoAdjustmentType.apre
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),

        // RPE Card
        Card(
          elevation: _selectedType == AutoAdjustmentType.rpe ? 3 : 0,
          color: _selectedType == AutoAdjustmentType.rpe
              ? context.colors.secondaryContainer
              : context.colors.surfaceContainerHighest,
          child: InkWell(
            onTap: () => setState(() => _selectedType = AutoAdjustmentType.rpe),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Radio<AutoAdjustmentType>(
                    value: AutoAdjustmentType.rpe,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.rpeBasedAdjustment,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          l10n.rpeBasedDescription,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.ai,
                    color: _selectedType == AutoAdjustmentType.rpe
                        ? context.colors.secondary
                        : context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildAPREConfiguration(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APRE Configuration',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),

        // Protocol Selection
        Text(
          l10n.apreProtocolSelect,
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(
              value: 3,
              label: Text('APRE 3'),
              icon: Icon(Icons.looks_3),
            ),
            ButtonSegment<int>(
              value: 6,
              label: Text('APRE 6'),
              icon: Icon(Icons.looks_6),
            ),
            ButtonSegment<int>(
              value: 10,
              label: Text('APRE 10'),
              icon: Icon(AppIcons.looks),
            ),
          ],
          selected: {_apreProtocol},
          onSelectionChanged: (Set<int> newSelection) async {
            final newProtocol = newSelection.first;

            // 🚨 T2.4: Check if workout is active
            final workoutState = ref.read(currentWorkoutProvider);
            final hasActiveWorkout = workoutState != null;

            if (hasActiveWorkout) {
              // Show warning dialog - cannot change protocol during active workout
              await _showWorkoutInProgressWarning(context);
              return; // Don't change protocol
            }

            // Show preview if protocol is changing and we have calculated values
            if (newProtocol != _previousProtocol &&
                _calculated1RM != null &&
                _calculated3RM != null &&
                _calculated6RM != null &&
                _calculated10RM != null) {
              setState(() {
                _apreProtocol = newProtocol;
                _showProtocolPreview = true;
              });
            } else {
              setState(() {
                _apreProtocol = newProtocol;
                _showProtocolPreview = false;
                // Auto-set base weight for new protocol if we have cached values
                final baseWeight = _apreProtocol == 3 ? _calculated3RM :
                                  _apreProtocol == 6 ? _calculated6RM :
                                  _calculated10RM;
                if (baseWeight != null) {
                  _apreBaseWeightController.text = baseWeight.toStringAsFixed(1);
                }
              });
              // Only calculate if we don't have cached values
              if (_calculated1RM == null) {
                _calculate1RMAndBaseWeight();
              }
            }
          },
        ),
        SizedBox(height: 12),

        // Protocol Description
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.info,
                size: 16,
                color: context.colors.onPrimaryContainer,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getProtocolDescription(l10n),
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // 1RM Calculation Info
        if (_isCalculating1RM)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Calculating from your history...',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        if (_calculated1RM != null && !_isCalculating1RM) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1RM Header
                Row(
                  children: [
                    Icon(
                      AppIcons.completeOutline,
                      size: 16,
                      color: context.colors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '1RM Stimato: ${_calculated1RM!.toStringAsFixed(1)} kg',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_calculationInfo != null) ...[
                  SizedBox(height: 4),
                  Text(
                    _calculationInfo!,
                    style: context.textTheme.bodySmall,
                  ),
                ],
                SizedBox(height: 12),
                const Divider(height: 1),
                SizedBox(height: 12),
                // Rep Maxes Grid
                Text(
                  'Massimali per Range di Ripetizioni:',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRepMaxCard(
                        context,
                        '3RM',
                        _calculated3RM,
                        'Forza',
                        _apreProtocol == 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRepMaxCard(
                        context,
                        '6RM',
                        _calculated6RM,
                        'Ipertrofia',
                        _apreProtocol == 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRepMaxCard(
                        context,
                        '10RM',
                        _calculated10RM,
                        'Resistenza',
                        _apreProtocol == 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Protocol Preview (when protocol changes)
        if (_showProtocolPreview) ...[
          _buildProtocolPreview(l10n),
          const SizedBox(height: 16),
        ],

        // Base Weight Input
        TextField(
          controller: _apreBaseWeightController,
          decoration: InputDecoration(
            labelText: l10n.apreBaseWeight,
            hintText: l10n.apreBaseWeightHint,
            prefixIcon: const Icon(AppIcons.workout),
            suffixText: 'kg',
            helperText: _getBaseWeightHelper(l10n),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildProtocolPreview(AppLocalizations l10n) {
    if (_previousProtocol == null) return const SizedBox.shrink();

    // Calculate set weights for both protocols
    final previousBaseWeight = _previousProtocol == 3 ? _calculated3RM :
                               _previousProtocol == 6 ? _calculated6RM :
                               _calculated10RM;
    final newBaseWeight = _apreProtocol == 3 ? _calculated3RM :
                         _apreProtocol == 6 ? _calculated6RM :
                         _calculated10RM;

    if (previousBaseWeight == null || newBaseWeight == null) {
      return const SizedBox.shrink();
    }

    // APRE structure: Set 1 (50%), Set 2 (75%), Set 3 (100% of RM), Set 4 (adjusted)
    final prevSet1 = previousBaseWeight * 0.5;
    final prevSet2 = previousBaseWeight * 0.75;
    final prevSet3 = previousBaseWeight;

    final newSet1 = newBaseWeight * 0.5;
    final newSet2 = newBaseWeight * 0.75;
    final newSet3 = newBaseWeight;

    return Card(
      elevation: 2,
      color: context.colors.secondaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  AppIcons.preview,
                  size: 20,
                  color: context.colors.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.apreProtocolPreview,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              l10n.aprePreviewDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16),

            // Comparison table
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Set',
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.apreCurrentProtocol(_previousProtocol!),
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          AppIcons.arrowForwardRounded,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.apreNewProtocol(_apreProtocol),
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: context.colors.outlineVariant),

                  // Set 1 row
                  _buildPreviewRow(l10n, l10n.apreSet1Preview, prevSet1, newSet1),
                  Divider(height: 1, color: context.colors.outlineVariant),

                  // Set 2 row
                  _buildPreviewRow(l10n, l10n.apreSet2Preview, prevSet2, newSet2),
                  Divider(height: 1, color: context.colors.outlineVariant),

                  // Set 3 row
                  _buildPreviewRow(l10n, l10n.apreSet3Preview, prevSet3, newSet3),
                  Divider(height: 1, color: context.colors.outlineVariant),

                  // Set 4 row (adjusted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            l10n.apreSet4Preview,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Text(
                            l10n.apreAdjustedBasedOnPerformance,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _apreProtocol = _previousProtocol!;
                        _showProtocolPreview = false;
                      });
                    },
                    icon: Icon(AppIcons.cancel, size: AppIconSize.small),
                    label: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _applyProtocolChange,
                    icon: Icon(AppIcons.completeOutline, size: AppIconSize.small),
                    label: Text(l10n.apreApplyChanges),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(AppLocalizations l10n, String setLabel, double prevWeight, double newWeight) {
    final weightDiff = newWeight - prevWeight;
    final isIncrease = weightDiff > 0;
    final diffColor = isIncrease ? context.colors.success : context.colors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              setLabel,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${prevWeight.toStringAsFixed(1)} kg',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            AppIcons.arrowForwardRounded,
            size: 16,
            color: context.colors.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${newWeight.toStringAsFixed(1)} kg',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (weightDiff.abs() > 0.1) ...[
                  SizedBox(height: 2),
                  Text(
                    '${isIncrease ? '+' : ''}${weightDiff.toStringAsFixed(1)} kg',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: diffColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyProtocolChange() {
    setState(() {
      _showProtocolPreview = false;
      _previousProtocol = _apreProtocol;

      // Update base weight for new protocol
      final baseWeight = _apreProtocol == 3 ? _calculated3RM :
                        _apreProtocol == 6 ? _calculated6RM :
                        _calculated10RM;
      if (baseWeight != null) {
        _apreBaseWeightController.text = baseWeight.toStringAsFixed(1);
      }
    });
  }

  Widget _buildRPEConfiguration(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.rpeBasedAdjustment,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // RPE or RIR toggle
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('RPE Based'),
                selected: !_useRIR,
                onSelected: (selected) => setState(() => _useRIR = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: const Text('RIR Based'),
                selected: _useRIR,
                onSelected: (selected) => setState(() => _useRIR = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (!_useRIR) ...[
          // RPE Range inputs
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetRPEMinController,
                  decoration: InputDecoration(
                    labelText: 'Min RPE',
                    hintText: '7',
                    prefixIcon: const Icon(AppIcons.arrowDownward),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _targetRPEMaxController,
                  decoration: InputDecoration(
                    labelText: 'Max RPE',
                    hintText: '9',
                    prefixIcon: const Icon(AppIcons.arrowUpward),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // RPE explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Weight will be adjusted to keep your RPE within the target range',
              style: context.textTheme.bodySmall,
            ),
          ),
        ] else ...[
          // RIR input
          TextField(
            controller: _targetRIRController,
            decoration: InputDecoration(
              labelText: 'Target RIR',
              hintText: '2',
              prefixIcon: Icon(AppIcons.repeat),
              helperText: 'Repetitions in Reserve',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          // RIR explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Weight will be adjusted to maintain target RIR (reps left in tank)',
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _calculate1RMAndBaseWeight() async {
    if (_selectedType != AutoAdjustmentType.apre) return;

    // Use cached values if already available
    if (_calculated1RM != null && _calculated3RM != null &&
        _calculated6RM != null && _calculated10RM != null) {
      debugPrint('[APRE-DEBUG] Using cached values from exercise:');
      debugPrint('[APRE-DEBUG]   Cached 1RM: ${_calculated1RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   Cached 3RM: ${_calculated3RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   Cached 6RM: ${_calculated6RM?.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   Cached 10RM: ${_calculated10RM?.toStringAsFixed(1)}kg');
      setState(() {
        final baseWeight = _apreProtocol == 3 ? _calculated3RM :
                          _apreProtocol == 6 ? _calculated6RM :
                          _calculated10RM;
        if (baseWeight != null) {
          debugPrint('[APRE-DEBUG]   Setting base weight for protocol $_apreProtocol: ${baseWeight.toStringAsFixed(1)}kg');
          _apreBaseWeightController.text = baseWeight.toStringAsFixed(1);
        }
      });
      return;
    }

    setState(() {
      _isCalculating1RM = true;
      _calculated1RM = null;
      _calculated3RM = null;
      _calculated6RM = null;
      _calculated10RM = null;
      _calculationInfo = null;
    });

    try {
      // Get exercise history from provider (NEW: using workouts collection)
      debugPrint('[APRE-DEBUG] Fetching history for exercise: "${widget.exercise.name}"');
      final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(widget.exercise.name).future);

      debugPrint('[APRE-DEBUG] Received ${historyData.length} history entries');
      if (historyData.isNotEmpty) {
        debugPrint('[APRE-DEBUG] Sample entries:');
        for (final data in historyData.take(3)) {
          debugPrint('[APRE-DEBUG]   ${data.weight}kg x ${data.reps} reps on ${data.date}');
        }
      }

      if (historyData.isEmpty) {
        // No history available, use default weights
        debugPrint('[APRE-DEBUG] No history found for "${widget.exercise.name}"');
        setState(() {
          _isCalculating1RM = false;
          _calculationInfo = 'No history available. Using default weight.';
          final defaultWeight = _apreProtocol == 3 ? 70.0 : _apreProtocol == 6 ? 60.0 : 40.0;
          _apreBaseWeightController.text = defaultWeight.toStringAsFixed(1);
        });
        return;
      }

      // Find best sets for 1RM calculation (highest weight * reps combinations)
      final validSets = historyData
          .where((data) => data.weight != null && data.reps != null && data.reps! > 0 && data.reps! <= 15)
          .toList();

      debugPrint('[APRE-DEBUG] 1RM Calculation: Found ${validSets.length} valid sets for ${widget.exercise.name}');

      if (validSets.isEmpty) {
        setState(() {
          _isCalculating1RM = false;
          _calculationInfo = 'Insufficient data for calculation.';
        });
        return;
      }

      // CRITICAL FIX: Sort by estimated 1RM (weight * reps combination) descending
      // This ensures we use the HEAVIEST sets for 1RM calculation
      validSets.sort((a, b) {
        final aEstimate = OneRMCalculator.calculateAverage(a.weight!, a.reps!);
        final bEstimate = OneRMCalculator.calculateAverage(b.weight!, b.reps!);
        return bEstimate.compareTo(aEstimate); // Descending order
      });

      debugPrint('[APRE-DEBUG] Top 3 sets after sorting:');
      for (final set in validSets.take(3)) {
        final est = OneRMCalculator.calculateAverage(set.weight!, set.reps!);
        debugPrint('[APRE-DEBUG]   ${set.weight}kg x ${set.reps} reps → ~${est.toStringAsFixed(1)}kg 1RM');
      }

      // Calculate 1RM using multiple formulas and take average
      double total1RM = 0;
      int count = 0;

      for (final set in validSets.take(10)) {
        // Use best 10 sets
        final estimated = OneRMCalculator.calculateAverage(
          set.weight!,
          set.reps!,
        );
        if (estimated > 0) {
          total1RM += estimated;
          count++;
        }
      }

      debugPrint('[APRE-DEBUG] Calculated 1RM from $count sets: ${(total1RM / count).toStringAsFixed(1)}kg');

      if (count == 0) {
        setState(() {
          _isCalculating1RM = false;
          _calculationInfo = 'Could not calculate 1RM from history.';
        });
        return;
      }

      final estimated1RM = total1RM / count;

      // Calculate ALL three rep maxes (3RM, 6RM, 10RM) from 1RM
      final weight3RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 3);
      final weight6RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 6);
      final weight10RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 10);

      // Round to nearest 2.5kg
      final rounded3RM = (weight3RM / 2.5).round() * 2.5;
      final rounded6RM = (weight6RM / 2.5).round() * 2.5;
      final rounded10RM = (weight10RM / 2.5).round() * 2.5;

      // Calculate base weight for current protocol
      final baseWeight = _apreProtocol == 3 ? rounded3RM : _apreProtocol == 6 ? rounded6RM : rounded10RM;

      // Calculate confidence based on data points
      final confidence = count >= 5
          ? 'High'
          : count >= 3
              ? 'Medium'
              : 'Low';

      debugPrint('[APRE-DEBUG] Final calculations:');
      debugPrint('[APRE-DEBUG]   1RM: ${estimated1RM.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   3RM: ${rounded3RM.toStringAsFixed(1)}kg (${weight3RM.toStringAsFixed(1)}kg before rounding)');
      debugPrint('[APRE-DEBUG]   6RM: ${rounded6RM.toStringAsFixed(1)}kg (${weight6RM.toStringAsFixed(1)}kg before rounding)');
      debugPrint('[APRE-DEBUG]   10RM: ${rounded10RM.toStringAsFixed(1)}kg (${weight10RM.toStringAsFixed(1)}kg before rounding)');
      debugPrint('[APRE-DEBUG]   Selected protocol: $_apreProtocol → Base weight: ${baseWeight.toStringAsFixed(1)}kg');
      debugPrint('[APRE-DEBUG]   Confidence: $confidence (based on $count sets)');

      setState(() {
        _isCalculating1RM = false;
        _calculated1RM = estimated1RM;
        _calculated3RM = rounded3RM;
        _calculated6RM = rounded6RM;
        _calculated10RM = rounded10RM;
        _calculationInfo = 'Based on $count recent sets (Confidence: $confidence)';
        _apreBaseWeightController.text = baseWeight.toStringAsFixed(1);
      });
    } catch (e) {
      setState(() {
        _isCalculating1RM = false;
        _calculationInfo = 'Error calculating: ${e.toString()}';
      });
    }
  }

  Widget _buildRepMaxCard(BuildContext context, String label, double? weight, String type, bool isSelected) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weight != null ? '${weight.toStringAsFixed(1)}kg' : '-',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            type,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getProtocolDescription(AppLocalizations l10n) {
    switch (_apreProtocol) {
      case 3:
        return l10n.apreProtocol3Description;
      case 6:
        return l10n.apreProtocol6Description;
      case 10:
        return l10n.apreProtocol10Description;
      default:
        return '';
    }
  }

  String _getBaseWeightHelper(AppLocalizations l10n) {
    switch (_apreProtocol) {
      case 3:
        return l10n.apreProtocol3Helper;
      case 6:
        return l10n.apreProtocol6Helper;
      case 10:
        return l10n.apreProtocol10Helper;
      default:
        return '';
    }
  }

  void _clearSettings() {
    setState(() {
      _selectedType = null;
      _apreBaseWeightController.clear();
      _targetRPEMinController.text = '7';
      _targetRPEMaxController.text = '9';
      _targetRIRController.text = '2';
    });
  }

  void _saveSettings() {
    if (_selectedType == null) return;

    Exercise updatedExercise;

    if (_selectedType == AutoAdjustmentType.apre) {
      // Save APRE settings
      final baseWeight = double.tryParse(_apreBaseWeightController.text.trim());

      if (baseWeight == null || baseWeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid base weight'),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      updatedExercise = widget.exercise.copyWith(
        autoAdjustmentType: AutoAdjustmentType.apre,
        useAPRE: true,
        apreProtocol: _apreProtocol,
        apreBaseWeight: baseWeight,
        targetRPEMin: null,
        targetRPEMax: null,
        targetRIR: null,
      );
    } else {
      // Save RPE/RIR settings
      if (!_useRIR) {
        final minRPE = double.tryParse(_targetRPEMinController.text.trim());
        final maxRPE = double.tryParse(_targetRPEMaxController.text.trim());

        if (minRPE == null || maxRPE == null || minRPE < 1 || maxRPE > 10 || minRPE >= maxRPE) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter valid RPE range (1-10)'),
              backgroundColor: context.colors.error,
            ),
          );
          return;
        }

        updatedExercise = widget.exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.rpe,
          useAPRE: false,
          targetRPEMin: minRPE,
          targetRPEMax: maxRPE,
          targetRIR: null,
          apreProtocol: null,
          apreBaseWeight: null,
        );
      } else {
        final targetRIR = int.tryParse(_targetRIRController.text.trim());

        if (targetRIR == null || targetRIR < 0 || targetRIR > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter valid RIR (0-10)'),
              backgroundColor: context.colors.error,
            ),
          );
          return;
        }

        updatedExercise = widget.exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.rpe,
          useAPRE: false,
          targetRIR: targetRIR,
          targetRPEMin: null,
          targetRPEMax: null,
          apreProtocol: null,
          apreBaseWeight: null,
        );
      }
    }

    // Note: Rest time suggestion logic will be shown during workout,
    // not when configuring APRE settings

    widget.onSave(updatedExercise);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto adjustment configured'),
        backgroundColor: context.colors.primary,
      ),
    );
  }

  /// 🚨 T2.4: Shows warning dialog when attempting to change protocol during active workout
  Future<void> _showWorkoutInProgressWarning(BuildContext context) async {
    final l10n = context.l10n;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            AppIcons.warning,
            color: context.colors.warning,
            size: AppIconSize.xlarge,
          ),
          title: Text(
            l10n.apreProtocolChangeWarningTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.apreProtocolChangeWarningMessage,
            style: context.textTheme.bodyMedium,
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.apreGotIt),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
