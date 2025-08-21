/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: ConsumerWidget
 * - Firebase: None
 * - Hive: None
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/exercise.dart';

class RpeSelectorBottomSheet extends ConsumerStatefulWidget {
  final ExerciseSet set;
  final int targetReps;
  final Function(int actualReps, double actualWeight, int rpe) onConfirm;

  const RpeSelectorBottomSheet({
    super.key,
    required this.set,
    required this.targetReps,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required ExerciseSet set,
    required int targetReps,
    required Function(int actualReps, double actualWeight, int rpe) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      builder: (context) => RpeSelectorBottomSheet(
        set: set,
        targetReps: targetReps,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  ConsumerState<RpeSelectorBottomSheet> createState() => _RpeSelectorBottomSheetState();
}

class _RpeSelectorBottomSheetState extends ConsumerState<RpeSelectorBottomSheet> {
  late int _actualReps;
  double _actualWeight = 0.0;
  int? _selectedRpe;
  int? _calculatedRir;
  bool _showWeightAndReps = true;

  @override
  void initState() {
    super.initState();
    _actualReps = widget.set.actualReps ?? widget.targetReps;
    _actualWeight = widget.set.weight ?? 0.0;
    _selectedRpe = widget.set.rpe;
    _updateRir();
  }

  void _updateRir() {
    if (_selectedRpe != null) {
      // Simple RIR calculation: RIR ≈ 10 - RPE
      _calculatedRir = 10 - _selectedRpe!;
    } else {
      _calculatedRir = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                l10n.recordSetCompletion,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Toggle for Weight & Reps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verify Weight & Reps',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _showWeightAndReps,
                      onChanged: (value) {
                        setState(() {
                          _showWeightAndReps = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Weight & Reps Section - Premium design
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _showWeightAndReps ? Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surfaceVariant.withOpacity(0.4),
                    colorScheme.surfaceVariant.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Weight Section
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Weight',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Decrease weight
                            InkWell(
                              onTap: _actualWeight > 0
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _actualWeight = (_actualWeight - 2.5).clamp(0, 999));
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.remove, size: 18, color: colorScheme.error),
                              ),
                            ),
                            // Weight display
                            Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _actualWeight == widget.set.weight
                                      ? colorScheme.primary.withOpacity(0.5)
                                      : colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _actualWeight.toStringAsFixed(1),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'kg',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Increase weight
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _actualWeight += 2.5);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.add, size: 18, color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    width: 1,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                  
                  // Reps Section
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.repeat, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Reps',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Decrease reps
                            InkWell(
                              onTap: _actualReps > 0
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _actualReps--);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.remove, size: 18, color: colorScheme.error),
                              ),
                            ),
                            // Reps display
                            Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _actualReps == widget.targetReps
                                      ? colorScheme.primary.withOpacity(0.5)
                                      : colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$_actualReps',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _actualReps == widget.targetReps
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '/${widget.targetReps}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Increase reps
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _actualReps++);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.add, size: 18, color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ) : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // RPE Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.rpe,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.rpe),
                              content: Text(l10n.rpeDescription),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.howHardWasTheSet,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // RPE buttons - Responsive row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rpe = index + 6; // RPE from 6 to 10
                      final isSelected = _selectedRpe == rpe;
                      
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // Always allow selection/change of RPE
                                _selectedRpe = (_selectedRpe == rpe) ? null : rpe;
                                _updateRir();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 75,
                              decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: _getRpeGradient(rpe),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: !isSelected
                                  ? colorScheme.surfaceVariant.withOpacity(0.5)
                                  : null,
                              border: Border.all(
                                color: isSelected
                                    ? _getRpeColor(rpe, colorScheme)
                                    : colorScheme.outline.withOpacity(0.3),
                                width: isSelected ? 2.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _getRpeColor(rpe, colorScheme)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getRpeEmoji(rpe),
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$rpe',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _getRpeShortLabel(rpe),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.95)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  // RIR display - Premium animated appearance
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _calculatedRir != null
                        ? Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer.withOpacity(0.5),
                                  colorScheme.primaryContainer.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.rir}: $_calculatedRir',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      l10n.repsInReserve,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons - Premium design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Skip button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onConfirm(_actualReps, _actualWeight, 0);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.skipRpe,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm button - Premium gradient
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _selectedRpe != null
                            ? LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedRpe != null
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: FilledButton(
                        onPressed: _selectedRpe != null
                            ? () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context).pop();
                                widget.onConfirm(_actualReps, _actualWeight, _selectedRpe!);
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_selectedRpe != null) ...[
                              const Icon(Icons.check_circle, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              l10n.confirmSet,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRpeColor(int rpe, ColorScheme colorScheme) {
    switch (rpe) {
      case 6:
        return const Color(0xFF4CAF50); // Green
      case 7:
        return const Color(0xFF8BC34A); // Light Green
      case 8:
        return const Color(0xFFFF9800); // Orange
      case 9:
        return const Color(0xFFFF5722); // Deep Orange
      case 10:
        return const Color(0xFFF44336); // Red
      default:
        return colorScheme.primary;
    }
  }

  List<Color> _getRpeGradient(int rpe) {
    switch (rpe) {
      case 6:
        return [const Color(0xFF66BB6A), const Color(0xFF4CAF50)];
      case 7:
        return [const Color(0xFF9CCC65), const Color(0xFF8BC34A)];
      case 8:
        return [const Color(0xFFFFB74D), const Color(0xFFFF9800)];
      case 9:
        return [const Color(0xFFFF7043), const Color(0xFFFF5722)];
      case 10:
        return [const Color(0xFFEF5350), const Color(0xFFF44336)];
      default:
        return [Colors.grey, Colors.grey.shade600];
    }
  }

  String _getRpeEmoji(int rpe) {
    switch (rpe) {
      case 6:
        return '😌'; // Very Easy - Relaxed
      case 7:
        return '🙂'; // Easy - Slightly smiling
      case 8:
        return '😤'; // Moderate - Huffing
      case 9:
        return '😣'; // Hard - Persevering
      case 10:
        return '🥵'; // Maximal - Overheated
      default:
        return '💪';
    }
  }

  String _getRpeShortLabel(int rpe) {
    switch (rpe) {
      case 6:
        return 'Very\nEasy';
      case 7:
        return 'Easy';
      case 8:
        return 'Moderate';
      case 9:
        return 'Hard';
      case 10:
        return 'Max';
      default:
        return '';
    }
  }

  String _getRpeLabel(int rpe, AppLocalizations l10n) {
    switch (rpe) {
      case 6:
        return l10n.veryEasy;
      case 7:
        return l10n.easy;
      case 8:
        return l10n.moderate;
      case 9:
        return l10n.hard;
      case 10:
        return l10n.maximal;
      default:
        return '';
    }
  }
}