/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/dialogs
/// 🎯 Feature: flexible_routine
/// 🔧 Type: dialog
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// SKIP DAY DIALOG - Dialog for skipping a workout day
///
/// Features:
/// - Predefined skip reasons (injury, sick, busy, etc.)
/// - Optional custom note
/// - Impact preview on statistics
/// - Warning for consecutive skips
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Result returned when user confirms skip
class SkipDayResult {

  const SkipDayResult({
    required this.reason,
    this.note,
  });
  final String reason;
  final String? note;
}

/// Dialog for skipping a workout day with reason selection
class SkipDayDialog extends StatefulWidget {

  const SkipDayDialog({
    super.key,
    required this.date,
    required this.routine,
  });
  final DateTime date;
  final FlexibleRoutine routine;

  /// Show the dialog and return result or null if cancelled
  static Future<SkipDayResult?> show(
    BuildContext context, {
    required DateTime date,
    required FlexibleRoutine routine,
  }) async {
    return showDialog<SkipDayResult>(
      context: context,
      builder: (context) => SkipDayDialog(
        date: date,
        routine: routine,
      ),
    );
  }

  @override
  State<SkipDayDialog> createState() => _SkipDayDialogState();
}

class _SkipDayDialogState extends State<SkipDayDialog> {
  String? _selectedReason;
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConsecutiveSkip = widget.routine.skipTracker.currentSkipStreak > 0;

    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.eventBusy,
                        color: context.colors.error,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skip Workout',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(widget.date),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Warning for consecutive skips
                if (isConsecutiveSkip) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.warningAmberRounded,
                          color: context.colors.secondary,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You have ${widget.routine.skipTracker.currentSkipStreak} consecutive skip(s). Consider recovering them to maintain consistency.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.secondary.withValues(red: context.colors.secondary.r * 0.6, green: context.colors.secondary.g * 0.6, blue: context.colors.secondary.b * 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Reason selection
                Text(
                  'Why are you skipping?',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 12),

                // Reason chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildReasonChips(),
                ),

                SizedBox(height: 20),

                // Optional note
                Text(
                  'Additional notes (optional)',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'e.g., Feeling under the weather...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  style: context.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Impact preview
                _buildImpactPreview(),

                SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: context.colors.onSurface),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _selectedReason == null ? null : _confirmSkip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.error,
                        foregroundColor: context.colors.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Skip Workout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReasonChips() {
    final reasons = [
      (SkipReasons.sick, Icons.sick, 'Sick'),
      (SkipReasons.injury, Icons.healing, 'Injury'),
      (SkipReasons.busy, Icons.work, 'Busy'),
      (SkipReasons.tired, AppIcons.bedtime, 'Tired'),
      (SkipReasons.travel, Icons.flight, 'Travel'),
      (SkipReasons.weather, Icons.cloud, 'Weather'),
      (SkipReasons.other, AppIcons.moreHoriz, 'Other'),
    ];

    return reasons.map((reason) {
      final isSelected = _selectedReason == reason.$1;
      return FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reason.$2,
              size: 16,
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.onSurface.withValues(alpha: 0.7),
            ),
            SizedBox(width: 6),
            Text(reason.$3),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedReason = selected ? reason.$1 : null;
          });
        },
        selectedColor: context.colors.primary,
        backgroundColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        labelStyle: context.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? context.colors.onPrimary
              : context.colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }).toList();
  }

  Widget _buildImpactPreview() {
    // Calculate impact
    final currentStreak = widget.routine.currentStreak;
    final currentAdherence = widget.routine.adherenceRate;

    // Adherence will decrease
    final totalDays = widget.routine.totalWorkoutDays;
    final completedDays = widget.routine.completedDays;
    final newAdherence = ((completedDays / (totalDays + 1)) * 100).clamp(0.0, 100.0);
    final adherenceChange = newAdherence - currentAdherence;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.info,
                size: 20,
                color: context.colors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Impact on your progress',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildImpactRow(
            icon: AppIcons.streak,
            label: 'Current Streak',
            value: '$currentStreak days',
            change: currentStreak > 0 ? 'Will be lost' : null,
            isNegative: currentStreak > 0,
          ),
          const SizedBox(height: 8),
          _buildImpactRow(
            icon: AppIcons.trendUp,
            label: 'Adherence Rate',
            value: '${currentAdherence.toInt()}%',
            change: '${adherenceChange >= 0 ? '+' : ''}${adherenceChange.toStringAsFixed(1)}%',
            isNegative: adherenceChange < 0,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({
    required IconData icon,
    required String label,
    required String value,
    String? change,
    bool isNegative = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        if (change != null) ...[
          SizedBox(width: 8),
          Icon(
            isNegative ? AppIcons.arrowDownward : AppIcons.arrowUpward,
            size: 14,
            color: isNegative ? context.colors.error : context.colors.success,
          ),
          SizedBox(width: 4),
          Text(
            change,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNegative ? context.colors.error : context.colors.success,
            ),
          ),
        ],
      ],
    );
  }

  void _confirmSkip() {
    if (_selectedReason == null) return;

    final result = SkipDayResult(
      reason: _selectedReason!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
