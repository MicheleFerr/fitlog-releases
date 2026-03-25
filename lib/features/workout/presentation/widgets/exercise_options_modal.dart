import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as database_exercise;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_details_modal.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_card_feedback.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// 🚀 TIER-1: Modal condiviso per opzioni esercizio sia per single che superset
class ExerciseOptionsModal extends ConsumerWidget {
  const ExerciseOptionsModal({
    super.key,
    required this.exercise,
    this.onEdit,
    this.onHistory,
    this.onDuplicate,
    this.onDelete,
    this.onChangeCountingMode,
    this.onAddWarmupSets,
    this.imageUrl,
    this.databaseExercise,
    this.languageCode = 'en',
  });
  final Exercise exercise;
  final VoidCallback? onEdit;
  final VoidCallback? onHistory;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeCountingMode;
  final VoidCallback? onAddWarmupSets;
  final String? imageUrl;
  final database_exercise.ExerciseDefinition? databaseExercise;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the exercise database version (e.g., "2.0.8")
    final dbVersionAsync = ref.watch(exerciseVersionInfoProvider);
    final dbVersion = dbVersionAsync.asData?.value ?? '1.0.0';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // GIF Preview (if available)
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: context.colors.onSurface.withValues(
                      alpha: 0.87,
                    ),
                    barrierDismissible: true,
                    builder: (context) => ExerciseGifFullscreen(
                      gifUrl: imageUrl!,
                      exerciseName: exercise.name,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ExerciseGifWidget(
                            gifUrl: imageUrl!,
                            exerciseName: exercise.name,
                            size: 220,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            iconColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      // Hint overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.zoomOutMap,
                                size: 16,
                                color: context.colors.surface.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.exerciseOptionsTapToEnlarge,
                                style: TextStyle(
                                  color: context.colors.surface.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    AppIcons.workout,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  // Info Esercizio
                  ListTile(
                    leading: const Icon(AppIcons.info),
                    title: Text(context.l10n.exerciseOptionsExerciseInfo),
                    subtitle: Text(
                      context.l10n.exerciseOptionsExerciseInfoSubtitle,
                    ),
                    onTap: () async {
                      final presentationContext =
                          AppRoutes.rootNavigatorKey.currentContext ?? context;
                      Navigator.pop(context);
                      final exerciseDetails = await _resolveExerciseDetails();
                      if (exerciseDetails != null &&
                          presentationContext.mounted) {
                        await ExerciseDetailsModal.show(
                          presentationContext,
                          exerciseDetails,
                        );
                      } else if (presentationContext.mounted) {
                        SnackBarService.showInfo(
                          presentationContext,
                          presentationContext.l10n.datiEsercizioNonDisponibili,
                        );
                      }
                    },
                  ),

                  // Aggiungi Set Riscaldamento
                  if (onAddWarmupSets != null) ...[
                    ListTile(
                      leading: Icon(
                        AppIcons.addCircleOutline,
                        color: context.colors.warning,
                      ),
                      title: Text(context.l10n.addWarmupSets),
                      subtitle: Text(context.l10n.addWarmupSetsSubtitle),
                      onTap: () {
                        Navigator.pop(context);
                        onAddWarmupSets!();
                      },
                    ),
                  ],

                  const Divider(),

                  // 🆕 Segnala problema
                  ListTile(
                    leading: Icon(
                      AppIcons.flagOutlined,
                      color: context.colors.warning,
                    ),
                    title: Text(context.l10n.exerciseOptionsReportIssue),
                    subtitle: Text(
                      context.l10n.exerciseOptionsReportIssueSubtitle,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Show feedback dialog with database version
                      ExerciseFeedbackButton.showFeedbackDialog(
                        context,
                        exerciseId: exercise.stableExerciseId,
                        exerciseName: exercise.name,
                        version: dbVersion,
                      );
                    },
                  ),
                  // Show other options only if callbacks are provided
                  if (onHistory != null) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(AppIcons.history),
                      title: Text(context.l10n.exerciseOptionsHistory),
                      onTap: () {
                        Navigator.pop(context);
                        onHistory!();
                      },
                    ),
                  ],

                  // Show other options only if callbacks are provided
                  if (onEdit != null) ...[
                    ListTile(
                      leading: const Icon(AppIcons.edit),
                      title: Text(context.l10n.exerciseOptionsEditNameAndNotes),
                      subtitle: Text(
                        context.l10n.exerciseOptionsEditNameAndNotesSubtitle,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                    ),
                  ],

                  if (onChangeCountingMode != null) ...[
                    ListTile(
                      leading: const Icon(AppIcons.swapHoriz),
                      title: Text(
                        context.l10n.exerciseOptionsChangeCountingFormat,
                      ),
                      subtitle: Text(
                        context
                            .l10n
                            .exerciseOptionsChangeCountingFormatSubtitle,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onChangeCountingMode!();
                      },
                    ),
                  ],

                  if (onDuplicate != null) ...[
                    ListTile(
                      leading: const Icon(AppIcons.iconCopy),
                      title: Text(context.l10n.exerciseOptionsDuplicate),
                      onTap: () {
                        Navigator.pop(context);
                        onDuplicate!();
                      },
                    ),
                  ],

                  if (onDelete != null) ...[
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        AppIcons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        context.l10n.exerciseOptionsDelete,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onDelete!();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<database_exercise.ExerciseDefinition?>
  _resolveExerciseDetails() async {
    if (databaseExercise != null) {
      return databaseExercise;
    }

    final exerciseData = await _loadExerciseDataFromJson(
      exercise.stableExerciseId,
      exercise.name,
      languageCode,
    );
    if (exerciseData == null) {
      return null;
    }

    return database_exercise.ExerciseDefinition.fromJson(exerciseData);
  }

  /// Load exercise data from JSON
  static Future<Map<String, dynamic>?> _loadExerciseDataFromJson(
    String exerciseId,
    String exerciseName,
    String languageCode,
  ) async {
    try {
      final exercises = await ExerciseJsonLoader.loadExercises(languageCode);
      debugPrint('[ExerciseOptions] Loading data for: "$exerciseName"');

      final normalizedName = _normalizeLookupValue(exerciseName);

      Map<String, dynamic>? exercise = exercises.firstWhereOrNull(
        (ex) => ex['id']?.toString() == exerciseId,
      );

      exercise ??= exercises.firstWhereOrNull(
        (ex) =>
            _normalizeLookupValue(ex['nome']?.toString() ?? '') ==
            normalizedName,
      );

      exercise ??= exercises.firstWhereOrNull(
        (ex) => _normalizeLookupValue(
          ex['nome']?.toString() ?? '',
        ).contains(normalizedName),
      );

      if (exercise == null) {
        debugPrint('[ExerciseOptions] Exercise not found: "$exerciseName"');
        debugPrint(
          '[ExerciseOptions] Available exercises (first 5): ${exercises.take(5).map((e) => e['nome']).toList()}',
        );
      } else {
        debugPrint(
          '[ExerciseOptions] Exercise found with keys: ${exercise.keys.toList()}',
        );
      }

      return exercise;
    } catch (e) {
      debugPrint('[ExerciseOptions] Error loading exercise data: $e');
      return null;
    }
  }

  static String _normalizeLookupValue(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Static method to show the modal
  static void show(
    BuildContext context,
    Exercise exercise, {
    VoidCallback? onEdit,
    VoidCallback? onHistory,
    VoidCallback? onDuplicate,
    VoidCallback? onDelete,
    VoidCallback? onChangeCountingMode,
    VoidCallback? onAddWarmupSets,
    String? imageUrl,
    database_exercise.ExerciseDefinition? databaseExercise,
    String languageCode = 'en',
  }) {
    HapticFeedback.mediumImpact();
    ModalService.showSheet(
      context,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (context) => ExerciseOptionsModal(
        exercise: exercise,
        onEdit: onEdit,
        onHistory: onHistory,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
        onChangeCountingMode: onChangeCountingMode,
        onAddWarmupSets: onAddWarmupSets,
        imageUrl: imageUrl,
        databaseExercise: databaseExercise,
        languageCode: languageCode,
      ),
    );
  }
}
