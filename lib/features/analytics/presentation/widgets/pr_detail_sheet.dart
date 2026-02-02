/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal (responsive: bottom sheet mobile, dialog desktop)
///
/// PR DETAIL SHEET - Shows detailed information about a Personal Record
///
/// Displays:
/// - Exercise image + name
/// - Record value (weight × reps)
/// - e1RM estimation
/// - Date achieved
/// - Previous best comparison
/// - Session summary
/// - Link to full session history
///
/// Example:
/// ```dart
/// showPRDetailSheet(
///   context: context,
///   data: PRDetailData(
///     exerciseId: 'bench-press',
///     exerciseName: 'Bench Press',
///     muscleGroup: 'chest',
///     prValue: 100.0,
///     achievedDate: DateTime.now(),
///   ),
/// );
/// ```
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_avatar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Data class for PR detail information
class PRDetailData {
  const PRDetailData({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.prValue,
    required this.achievedDate,
    this.reps,
    this.weight,
    this.previousBest,
    this.previousBestDate,
    this.sessionId,
    this.sessionName,
    this.sessionDuration,
    this.sessionExercises,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final double prValue; // e1RM value
  final DateTime achievedDate;
  final int? reps;
  final double? weight;
  final double? previousBest;
  final DateTime? previousBestDate;
  final String? sessionId;
  final String? sessionName;
  final Duration? sessionDuration;
  final List<String>? sessionExercises; // Brief list of exercises in session
}

/// Show PR detail as bottom sheet (mobile) or dialog (desktop)
///
/// Automatically detects platform and screen size to choose appropriate UI.
Future<void> showPRDetailSheet({
  required BuildContext context,
  required PRDetailData data,
}) async {
  // Desktop/Web: use dialog
  // Mobile: use bottom sheet
  final isDesktop = kIsWeb || MediaQuery.of(context).size.width > 600;

  if (isDesktop) {
    await showDialog<void>(
      context: context,
      builder: (context) => _PRDetailDialog(data: data),
    );
  } else {
    unawaited(HapticFeedback.lightImpact());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PRDetailBottomSheet(data: data),
    );
  }
}

/// Desktop dialog version of PR detail
class _PRDetailDialog extends StatelessWidget {
  const _PRDetailDialog({required this.data});

  final PRDetailData data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isDialog: true),
              const SizedBox(height: 24),

              // Content
              _buildContent(context),

              // Actions
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isDialog}) {
    return Row(
      children: [
        SemanticIcon(
          icon: AppIcons.achievement,
          semanticLabel: context.l10n.pr,
          size: AppIconSize.large,
          color: context.colors.success,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.l10n.prDetails,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SemanticIcon(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise info row
        _buildExerciseInfo(context),
        const SizedBox(height: 20),

        // Record value card
        _buildRecordCard(context),
        const SizedBox(height: 16),

        // Date info
        _buildDateInfo(context),

        // Session summary (if available)
        if (data.sessionExercises != null &&
            data.sessionExercises!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSessionSummary(context),
        ],
      ],
    );
  }

  Widget _buildExerciseInfo(BuildContext context) {
    return Row(
      children: [
        ExerciseAvatarLarge(
          exerciseId: data.exerciseId,
          exerciseName: data.exerciseName,
          muscleGroup: data.muscleGroup,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.exerciseName,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.successContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${context.l10n.weight} ${context.l10n.pr}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSuccessContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context) {
    final improvement = data.previousBest != null
        ? ((data.prValue - data.previousBest!) / data.previousBest! * 100)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Record value
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.achievement,
                semanticLabel: context.l10n.pr,
                size: AppIconSize.medium,
                color: context.colors.success,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.record,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weight × Reps (if available)
          if (data.weight != null && data.reps != null)
            Text(
              '${data.weight!.toStringAsFixed(1)} kg × ${data.reps} reps',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

          // e1RM value
          Text(
            'e1RM: ${data.prValue.toStringAsFixed(1)} kg',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Previous best comparison
          if (data.previousBest != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.pr_previous_value,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${data.previousBest!.toStringAsFixed(1)} kg',
                        style: context.textTheme.bodyMedium,
                      ),
                      if (data.previousBestDate != null)
                        Text(
                          DateFormat('MMM yyyy').format(data.previousBestDate!),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Improvement badge
                if (improvement != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${improvement.toStringAsFixed(1)}%',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.onSuccess,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.calendar,
            semanticLabel: context.l10n.recordedTime,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.recordedTime,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(data.achievedDate),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (data.sessionName != null)
                  Text(
                    data.sessionName!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.workout,
                semanticLabel: context.l10n.exercises,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.exercises,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Exercise list
          ...data.sessionExercises!
              .take(4)
              .map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercise,
                          style: context.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (data.sessionExercises!.length > 4)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '+ ${data.sessionExercises!.length - 4} ${context.l10n.exercises.toLowerCase()}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.close),
        ),
        const SizedBox(width: 8),
        if (data.sessionId != null)
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to workout history
              context.pushNamed(AppRoutes.workoutHistoryName);
            },
            icon: SemanticIcon(
              icon: AppIcons.arrowForward,
              semanticLabel: context.l10n.viewWorkoutHistory,
              size: AppIconSize.buttonPrimary,
            ),
            label: Text(context.l10n.viewWorkoutHistory),
          ),
      ],
    );
  }
}

/// Mobile bottom sheet version of PR detail
class _PRDetailBottomSheet extends StatelessWidget {
  const _PRDetailBottomSheet({required this.data});

  final PRDetailData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.achievement,
                    semanticLabel: context.l10n.pr,
                    size: AppIconSize.large,
                    color: context.colors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.prDetails,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reuse content from dialog
              _PRDetailDialog(data: data)._buildExerciseInfo(context),
              const SizedBox(height: 20),
              _PRDetailDialog(data: data)._buildRecordCard(context),
              const SizedBox(height: 16),
              _PRDetailDialog(data: data)._buildDateInfo(context),

              if (data.sessionExercises != null &&
                  data.sessionExercises!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _PRDetailDialog(data: data)._buildSessionSummary(context),
              ],

              // View history button
              if (data.sessionId != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pushNamed(AppRoutes.workoutHistoryName);
                    },
                    icon: SemanticIcon(
                      icon: AppIcons.arrowForward,
                      semanticLabel: context.l10n.viewWorkoutHistory,
                      size: AppIconSize.buttonPrimary,
                    ),
                    label: Text(context.l10n.viewWorkoutHistory),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
