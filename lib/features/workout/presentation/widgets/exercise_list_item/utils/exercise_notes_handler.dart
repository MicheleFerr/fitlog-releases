/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets/exercise_list_item/utils
/// 🎯 Feature: Exercise Notes Handler
/// 🔧 Type: Static utility class for notes operations
///
/// Static helper class for exercise notes operations including
/// displaying notes dialog and formatting notes preview.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Static helper class for exercise notes operations
///
/// Provides utilities for:
/// - Showing notes editing dialog
/// - Formatting notes preview with truncation
class ExerciseNotesHandler {
  // Private constructor to prevent instantiation
  ExerciseNotesHandler._();

  /// Shows notes editing dialog
  ///
  /// Displays a modal bottom sheet with text field for editing exercise notes.
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing dialog and localization
  /// - [currentNotes]: Current note text to display (can be null)
  ///
  /// Returns:
  /// - `Future<String?>` with new notes text, or null if cancelled
  ///
  /// Example:
  /// ```dart
  /// final newNotes = await ExerciseNotesHandler.showNotesDialog(
  ///   context,
  ///   exercise.notes,
  /// );
  /// if (newNotes != null) {
  ///   // Save notes
  /// }
  /// ```
  static Future<String?> showNotesDialog(
    BuildContext context,
    String? currentNotes,
  ) async {
    final controller = TextEditingController(text: currentNotes);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.notes,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.notesHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, controller.text);
                    },
                    child: Text(context.l10n.save),
                  ),
                ],
              ),
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
