/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// REVIEW STEP - Step 3 of routine creation wizard
///
/// Shows summary of:
/// - Routine details
/// - Selected pattern
/// - Duration and schedule preview
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 3: Review and confirm
class ReviewStep extends ConsumerWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routineEditorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Review & Create',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review your routine before creating it',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          SizedBox(height: 32),

          // Routine details
          _buildDetailSection(
            context,
            icon: AppIcons.label,
            title: 'Routine Details',
            children: [
              _buildDetailRow(
                context,
                label: 'Name',
                value: state.name,
                valueStyle: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              if (state.description != null && state.description!.isNotEmpty)
                _buildDetailRow(
                  context,
                  label: 'Description',
                  value: state.description!,
                ),
              _buildDetailRow(
                context,
                label: 'Type',
                value: _formatRoutineType(state.type),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Duration
          _buildDetailSection(
            context,
            icon: AppIcons.calendar,
            title: 'Duration',
            children: [
              _buildDetailRow(
                context,
                label: 'Start Date',
                value: _formatDate(state.startDate),
              ),
              _buildDetailRow(
                context,
                label: 'End Date',
                value: _formatDate(state.endDate),
              ),
              _buildDetailRow(
                context,
                label: 'Total Days',
                value: '${state.endDate.difference(state.startDate).inDays + 1} days',
                valueStyle: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Pattern
          if (state.selectedPattern != null)
            _buildPatternSection(context, state),

          SizedBox(height: 32),

          // Success message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primaryContainer.withValues(alpha: 0.3),
                  context.colors.primaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.complete,
                  color: context.colors.primary,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to Start!',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Create Routine" to begin your fitness journey',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
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
                icon,
                color: context.colors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSection(
    BuildContext context,
    RoutineEditorState state,
  ) {
    final pattern = state.selectedPattern!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
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
                AppIcons.gridView,
                color: context.colors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Training Pattern',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Pattern name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: context.colors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pattern.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Pattern description
          Text(
            pattern.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),

          SizedBox(height: 16),

          // Weekly sequence
          Text(
            'Weekly Sequence:',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: pattern.sequence.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isRest = day.toLowerCase() == 'rest';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isRest
                      ? context.colors.secondary.withValues(alpha: 0.2)
                      : context.colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isRest
                        ? context.colors.secondary.withValues(alpha: 0.3)
                        : context.colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Day ${index + 1}:',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isRest
                            ? context.colors.secondary
                            : context.colors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      isRest ? AppIcons.bed : AppIcons.workout,
                      size: 14,
                      color: isRest
                          ? context.colors.secondary
                          : context.colors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatDayLabel(day),
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isRest
                            ? context.colors.secondary
                            : context.colors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatRoutineType(RoutineType type) {
    switch (type) {
      case RoutineType.weekly:
        return 'Weekly';
      case RoutineType.monthly:
        return 'Monthly';
      case RoutineType.bimonthly:
        return 'Bimonthly';
      case RoutineType.semester:
        return 'Semester';
      case RoutineType.custom:
        return 'Custom';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDayLabel(String day) {
    if (day.toLowerCase() == 'rest') return 'Rest';
    return day.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}
