/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets/exercise_list_item/utils
/// 🎯 Feature: Exercise Notes Handler
/// 🔧 Type: Static utility class for notes operations
///
/// Static helper class for exercise notes operations including
/// displaying two-level notes dialog and formatting notes preview.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Result from notes dialog
class NotesDialogResult {
  NotesDialogResult({this.formCues, this.sessionNotes});

  final String? formCues;
  final String? sessionNotes;
}

/// Static helper class for exercise notes operations
///
/// Provides utilities for:
/// - Showing two-level notes editing dialog (Form Cues + Session Notes)
/// - Formatting notes preview with truncation
class ExerciseNotesHandler {
  // Private constructor to prevent instantiation
  ExerciseNotesHandler._();

  /// Shows two-level notes editing dialog
  ///
  /// Displays a modal bottom sheet with two distinct sections:
  /// 1. Form Cues - Persistent technique reminders
  /// 2. Session Notes - Per-workout observations
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing dialog and localization
  /// - [exerciseId]: Exercise ID for form cues lookup (can be null)
  /// - [exerciseName]: Exercise name for display
  /// - [currentSessionNotes]: Current session note text (can be null)
  /// - [currentFormCues]: Current form cues text (can be null)
  ///
  /// Returns:
  /// - `Future<NotesDialogResult?>` with form cues and session notes, or null if cancelled
  ///
  /// Example:
  /// ```dart
  /// final result = await ExerciseNotesHandler.showNotesDialog(
  ///   context,
  ///   exerciseId: exercise.id,
  ///   exerciseName: exercise.name,
  ///   currentSessionNotes: exercise.notes,
  ///   currentFormCues: exercise.formCues,
  /// );
  /// if (result != null) {
  ///   // Save both form cues and session notes
  /// }
  /// ```
  static Future<NotesDialogResult?> showNotesDialog(
    BuildContext context, {
    required String? exerciseId,
    required String exerciseName,
    required String? currentSessionNotes,
    required String? currentFormCues,
  }) async {
    final formCuesController = TextEditingController(text: currentFormCues);
    final sessionNotesController =
        TextEditingController(text: currentSessionNotes);

    return showModalBottomSheet<NotesDialogResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                context.l10n.notes,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Form Cues Section (Prominent)
              Container(
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.editNote,
                          color: context.colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.formCues,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: formCuesController,
                      maxLines: 3,
                      style: context.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: context.l10n.formCuesHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: context.colors.surface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          AppIcons.infoOutlined,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l10n.formCuesHelper,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Session Notes Section (Subtle)
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLowest,
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.notes,
                          color: context.colors.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.sessionNotes,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sessionNotesController,
                      maxLines: 3,
                      style: context.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: context.l10n.sessionNotesHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: context.colors.surface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          AppIcons.infoOutlined,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l10n.sessionNotesHelper,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        NotesDialogResult(
                          formCues: formCuesController.text.trim().isEmpty
                              ? null
                              : formCuesController.text.trim(),
                          sessionNotes:
                              sessionNotesController.text.trim().isEmpty
                                  ? null
                                  : sessionNotesController.text.trim(),
                        ),
                      );
                    },
                    child: Text(context.l10n.save),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats notes for display preview
  ///
  /// Truncates long notes with ellipsis for compact display in UI.
  ///
  /// Parameters:
  /// - [notes]: Notes text to format (can be null)
  /// - [maxLength]: Maximum length before truncation (default: 50)
  ///
  /// Returns:
  /// - Formatted string with ellipsis if truncated, or empty string if notes is null
  ///
  /// Example:
  /// ```dart
  /// final preview = ExerciseNotesHandler.formatNotesPreview(
  ///   'This is a very long note that should be truncated',
  ///   maxLength: 20,
  /// );
  /// // Returns: "This is a very long..."
  /// ```
  static String formatNotesPreview(String? notes, {int maxLength = 50}) {
    if (notes == null || notes.isEmpty) return '';

    if (notes.length <= maxLength) {
      return notes;
    }

    return '${notes.substring(0, maxLength)}...';
  }
}
