/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Template Share Sheet - Bottom sheet with sharing options
/// Allows customization of what to include when sharing a template
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: widget
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Share format options
enum ShareFormat {
  text,    // Chat/social friendly text
  compact, // Ultra compact (5x10, 3x8)
}

/// Options for customizing shared content
class ShareOptions {
  ShareOptions({
    this.useCompactFormat = true,
    this.showTechniqueChips = true,
    this.includeRestTime = true,
    this.includeNotes = false,
    this.includeDescription = true,
  });

  bool useCompactFormat; // 5x10 vs expanded
  bool showTechniqueChips; // Superset, Dropset, etc.
  bool includeRestTime;
  bool includeNotes;
  bool includeDescription;
}

/// Shows the template share bottom sheet
Future<void> showTemplateShareSheet({
  required BuildContext context,
  required WorkoutTemplate template,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TemplateShareSheetContent(template: template),
  );
}

class _TemplateShareSheetContent extends ConsumerStatefulWidget {
  const _TemplateShareSheetContent({required this.template});

  final WorkoutTemplate template;

  @override
  ConsumerState<_TemplateShareSheetContent> createState() =>
      _TemplateShareSheetContentState();
}

class _TemplateShareSheetContentState
    extends ConsumerState<_TemplateShareSheetContent> {
  ShareFormat _selectedFormat = ShareFormat.text;
  final ShareOptions _options = ShareOptions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.share,
                    semanticLabel: l10n.share,
                    size: AppIconSize.large,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shareTemplate,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.template.name,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Format selection
          _buildFormatSelector(l10n),

          // Options
          _buildOptionsSection(l10n),

          // Preview
          _buildPreview(l10n),

          // Actions
          _buildActions(l10n),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFormatSelector(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.format,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildFormatChip(
                  format: ShareFormat.text,
                  icon: AppIcons.article,
                  label: l10n.textFormat,
                  isSelected: _selectedFormat == ShareFormat.text,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildFormatChip(
                  format: ShareFormat.compact,
                  icon: AppIcons.viewCompact,
                  label: l10n.compactFormat,
                  isSelected: _selectedFormat == ShareFormat.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip({
    required ShareFormat format,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFormat = format);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.medium,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.options,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.start,
            children: [
              _buildOptionChip(
                label: l10n.restTime,
                icon: AppIcons.timer,
                isEnabled: _options.includeRestTime,
                onTap: () => setState(
                    () => _options.includeRestTime = !_options.includeRestTime),
              ),
              _buildOptionChip(
                label: l10n.notes,
                icon: AppIcons.note,
                isEnabled: _options.includeNotes,
                onTap: () =>
                    setState(() => _options.includeNotes = !_options.includeNotes),
              ),
              _buildOptionChip(
                label: l10n.techniques,
                icon: AppIcons.layers,
                isEnabled: _options.showTechniqueChips,
                onTap: () => setState(
                    () => _options.showTechniqueChips = !_options.showTechniqueChips),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? context.colors.primary
                : context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: label,
              size: AppIconSize.tiny,
              color: isEnabled
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isEnabled ? AppIcons.checkCircle : AppIcons.radioButtonUnchecked,
              size: 14,
              color: isEnabled
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    final previewText = _generateShareText();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.preview,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _copyToClipboard(previewText),
                icon: const SemanticIcon(
                  icon: AppIcons.iconCopy,
                  semanticLabel: 'Copy',
                  size: AppIconSize.tiny,
                ),
                label: Text(l10n.copy),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                previewText,
                style: context.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cancel button
          IconButton.outlined(
            onPressed: () => Navigator.pop(context),
            icon: SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: l10n.cancel,
              size: AppIconSize.medium,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Share button (larger, primary)
          IconButton.filled(
            onPressed: _shareTemplate,
            icon: SemanticIcon(
              icon: AppIcons.share,
              semanticLabel: l10n.share,
              size: AppIconSize.large,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _generateShareText() {
    switch (_selectedFormat) {
      case ShareFormat.text:
        return _generateTextFormat();
      case ShareFormat.compact:
        return _generateCompactFormat();
    }
  }

  String _generateTextFormat() {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('💪 ${widget.template.name}');

    if (_options.includeDescription && widget.template.description.isNotEmpty) {
      buffer.writeln(widget.template.description);
    }

    buffer.writeln();

    // Exercises
    for (int i = 0; i < widget.template.exercises.length; i++) {
      final exercise = widget.template.exercises[i];

      // Exercise name with number
      buffer.write('${i + 1}. ${exercise.exerciseName}');

      // Technique chips
      if (_options.showTechniqueChips) {
        final techniques = <String>[];
        if (exercise.type == ExerciseType.superset) techniques.add('🔗 Superset');
        if (exercise.type == ExerciseType.dropset) techniques.add('⬇️ Dropset');
        if (exercise.type == ExerciseType.restPause) techniques.add('⏸️ Rest-Pause');
        if (techniques.isNotEmpty) {
          buffer.write(' ${techniques.join(' ')}');
        }
      }

      buffer.writeln();

      // Working sets (templates don't have warmup tracking)
      _writeWorkingSets(buffer, exercise.sets);

      // Rest time
      if (_options.includeRestTime && exercise.restTime != null) {
        buffer.writeln('   ⏱️ ${_formatRestTime(exercise.restTime!)}');
      }

      // Notes
      if (_options.includeNotes &&
          exercise.notes != null &&
          exercise.notes!.isNotEmpty) {
        buffer.writeln('   📝 ${exercise.notes}');
      }

      buffer.writeln();
    }

    buffer.writeln('─────────────────');
    buffer.writeln('📲 Shared from FitLog Pro');

    return buffer.toString();
  }

  void _writeWorkingSets(StringBuffer buffer, List<SetTemplate> sets) {
    if (sets.isEmpty) return;

    // Group sets by weight and reps
    final groups = <String, int>{};
    for (final set in sets) {
      final key = '${set.targetWeight ?? 0}:${set.targetReps ?? 0}';
      groups[key] = (groups[key] ?? 0) + 1;
    }

    if (groups.length == 1) {
      // All sets are the same - show as NxM
      final first = sets.first;
      buffer.write('   ${sets.length}x${first.targetReps ?? '?'}');
      if (first.targetWeight != null && first.targetWeight! > 0) {
        buffer.write(' @ ${first.targetWeight}kg');
      }
      buffer.writeln();
    } else {
      // Different sets - show each
      for (int i = 0; i < sets.length; i++) {
        final set = sets[i];
        buffer.write('   Set ${i + 1}: ${set.targetReps ?? '?'}');
        if (set.targetWeight != null && set.targetWeight! > 0) {
          buffer.write(' @ ${set.targetWeight}kg');
        }
        buffer.writeln();
      }
    }
  }

  String _generateCompactFormat() {
    final buffer = StringBuffer();

    buffer.writeln('📋 ${widget.template.name}');
    buffer.writeln();

    for (int i = 0; i < widget.template.exercises.length; i++) {
      final exercise = widget.template.exercises[i];

      buffer.write('• ${exercise.exerciseName}: ');

      // Compact format: 5x10 @ 80kg or 5x10, 3x8
      final setGroups = _groupSets(exercise.sets);
      final parts = setGroups.map((group) {
        final count = group['count'] as int;
        final reps = group['reps'] as int?;
        final weight = group['weight'] as double?;

        var text = '${count}x${reps ?? '?'}';
        if (weight != null && weight > 0) {
          text += '@${weight.toStringAsFixed(0)}kg';
        }
        return text;
      });

      buffer.write(parts.join(', '));

      // Add technique chips inline
      if (_options.showTechniqueChips) {
        if (exercise.type == ExerciseType.superset) buffer.write(' 🔗');
        if (exercise.type == ExerciseType.dropset) buffer.write(' ⬇️');
        if (exercise.type == ExerciseType.restPause) buffer.write(' ⏸️');
      }

      if (_options.includeRestTime && exercise.restTime != null) {
        buffer.write(' (${_formatRestTimeShort(exercise.restTime!)})');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  List<Map<String, dynamic>> _groupSets(List<SetTemplate> sets) {
    final groups = <Map<String, dynamic>>[];

    for (final set in sets) {
      final lastGroup = groups.isNotEmpty ? groups.last : null;

      if (lastGroup != null &&
          lastGroup['reps'] == set.targetReps &&
          lastGroup['weight'] == set.targetWeight) {
        lastGroup['count'] = (lastGroup['count'] as int) + 1;
      } else {
        groups.add({
          'count': 1,
          'reps': set.targetReps,
          'weight': set.targetWeight,
        });
      }
    }

    return groups;
  }

  String _formatRestTime(int seconds) {
    if (seconds < 60) return '${seconds}s rest';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '${minutes}min rest';
    return '$minutes:${secs.toString().padLeft(2, '0')} rest';
  }

  String _formatRestTimeShort(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '${minutes}m';
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      SnackBarService.showSuccess(context, AppLocalizations.of(context).copiedToClipboard);
    }
  }

  Future<void> _shareTemplate() async {
    final text = _generateShareText();

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: widget.template.name,
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Error sharing: $e');
      }
    }
  }
}
