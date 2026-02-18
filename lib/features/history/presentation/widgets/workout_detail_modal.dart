/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/history/presentation/widgets
/// 🎯 Feature: workout_history
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (AppLocalizations)
/// 🎨 Theme: ✅ YES (Theme.of(context))
/// 📱 Platform: Universal
///
/// WORKOUT DETAIL MODAL - Full details of a completed workout
///
/// Shows:
/// - Workout name and date
/// - Stats summary (volume, duration, sets, avg RPE)
/// - Toggle to show/hide warmup sets
/// - All exercises with sets (warmup styled differently)
/// - Share as PNG button
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/history_share_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal showing full workout details
class WorkoutDetailModal extends StatefulWidget {
  const WorkoutDetailModal({
    super.key,
    required this.workout,
    this.scrollController,
  });

  final WorkoutHistoryDetail workout;
  final ScrollController? scrollController;

  @override
  State<WorkoutDetailModal> createState() => _WorkoutDetailModalState();
}

class _WorkoutDetailModalState extends State<WorkoutDetailModal> {
  bool _showWarmupSets = true;
  bool _isSharing = false;
  final _screenshotController = ScreenshotController();

  // --- Computed stats (working sets only, warmup excluded) ---

  double get _workingVolume {
    return widget.workout.exercises.fold(0.0, (sum, ex) {
      return sum +
          ex.sets
              .where((s) => !s.isWarmup)
              .fold(0.0, (setSum, s) => setSum + s.volume);
    });
  }

  int get _workingSetsCount {
    return widget.workout.exercises.fold(0, (sum, ex) {
      return sum + ex.sets.where((s) => !s.isWarmup).length;
    });
  }

  int get _totalWarmupSets {
    return widget.workout.exercises.fold(0, (sum, ex) {
      return sum + ex.sets.where((s) => s.isWarmup).length;
    });
  }

  double get _workingAverageRPE {
    final sets = widget.workout.exercises
        .expand((e) => e.sets)
        .where((s) => !s.isWarmup && s.rpe > 0)
        .toList();
    if (sets.isEmpty) return 0.0;
    return sets.map((s) => s.rpe).reduce((a, b) => a + b) / sets.length;
  }

  // --- Formatters ---

  String _formatVolume(double volume) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toInt()} kg';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  // --- Share ---

  Future<void> _shareAsImage(BuildContext context) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final imageBytes = await _screenshotController.captureFromLongWidget(
        HistoryShareCard(workout: widget.workout),
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/workout_history_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: widget.workout.name,
        ),
      );

      Future.delayed(const Duration(seconds: 30), () async {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('❌ [HistoryShare] Error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasWarmup = _totalWarmupSets > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row: title + share + close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workout.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy - HH:mm',
                          ).format(widget.workout.completedAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  _isSharing
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: () => _shareAsImage(context),
                          tooltip: 'Condividi',
                          icon: const SemanticIcon(
                            icon: AppIcons.share,
                            semanticLabel: 'Condividi allenamento',
                          ),
                        ),
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const SemanticIcon(
                      icon: AppIcons.close,
                      semanticLabel: 'Close',
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatChip(
                      icon: AppIcons.workout,
                      label: _formatVolume(_workingVolume),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: AppIcons.timerOutlined,
                      label: _formatDuration(widget.workout.duration),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: AppIcons.fitnessCenterOutlined,
                      label: '$_workingSetsCount set',
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    if (_workingAverageRPE > 0) ...[
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: AppIcons.localFireDepartment,
                        label: 'RPE ${_workingAverageRPE.toStringAsFixed(1)}',
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Warmup toggle
            if (hasWarmup)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showWarmupSets = !_showWarmupSets),
                    icon: SemanticIcon(
                      icon: _showWarmupSets
                          ? AppIcons.visibility
                          : AppIcons.visibilityOff,
                      semanticLabel: '',
                      size: 14,
                    ),
                    label: Text(
                      _showWarmupSets
                          ? 'Nascondi warmup ($_totalWarmupSets)'
                          : 'Mostra warmup ($_totalWarmupSets)',
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: theme.textTheme.bodySmall,
                      foregroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ),
              ),

            // Exercise list
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                key: PageStorageKey(
                  'workout_detail_exercises_${widget.workout.id}',
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.workout.exercises[index];
                  final visibleSets = _showWarmupSets
                      ? exercise.sets
                      : exercise.sets.where((s) => !s.isWarmup).toList();

                  if (visibleSets.isEmpty) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...visibleSets.map(
                          (set) => _SetRow(
                            set: set,
                            colorScheme: colorScheme,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper widgets ---

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.set,
    required this.colorScheme,
    required this.theme,
  });

  final SetHistoryDetail set;
  final ColorScheme colorScheme;
  final ThemeData theme;

  Color _rpeColor() {
    if (set.rpe <= 6) return colorScheme.tertiary.withValues(alpha: 0.2);
    if (set.rpe <= 8) return colorScheme.secondary.withValues(alpha: 0.2);
    return colorScheme.error.withValues(alpha: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final isWarmup = set.isWarmup;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Set number badge — "W" for warmup, number for working
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isWarmup
                  ? colorScheme.onSurface.withValues(alpha: 0.08)
                  : colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isWarmup ? 'W' : '${set.setNumber}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWarmup ? 10 : null,
                  color: isWarmup
                      ? colorScheme.onSurface.withValues(alpha: 0.45)
                      : colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Weight × reps
          Text(
            '${set.weight.toInt()}kg × ${set.reps} reps',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isWarmup
                  ? colorScheme.onSurface.withValues(alpha: 0.5)
                  : null,
              fontSize: isWarmup ? 13 : null,
            ),
          ),
          const Spacer(),
          // RPE badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isWarmup
                  ? colorScheme.onSurface.withValues(alpha: 0.07)
                  : _rpeColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'RPE ${set.rpe}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isWarmup
                    ? colorScheme.onSurface.withValues(alpha: 0.4)
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: isWarmup ? 11 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
