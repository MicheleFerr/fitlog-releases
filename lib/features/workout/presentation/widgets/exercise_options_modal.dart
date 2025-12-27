import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_card_feedback.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
/// 🚀 TIER-1: Modal condiviso per opzioni esercizio sia per single che superset
class ExerciseOptionsModal extends StatelessWidget {

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
  final String languageCode;

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // GIF Preview (if available)
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: context.colors.onSurface.withValues(alpha: 0.87),
                    barrierDismissible: true,
                    builder: (context) => ExerciseGifFullscreen(
                      gifUrl: imageUrl!,
                      exerciseName: exercise.name,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: LoadingIndicator(
                                progress: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                AppIcons.imageNotSupported,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            );
                          },
                        ),
                      ),
                      // Hint overlay
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.zoomOutMap,
                                size: 16,
                                color: context.colors.surface.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.exerciseOptionsTapToEnlarge,
                                style: TextStyle(
                                  color: context.colors.surface.withValues(alpha: 0.9),
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
                    subtitle: Text(context.l10n.exerciseOptionsExerciseInfoSubtitle),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && context.mounted) {
                        _showExerciseInfoModal(context, exerciseData);
                      } else if (context.mounted) {
                        SnackBarService.showInfo(context, context.l10n.datiEsercizioNonDisponibili);
                      }
                    },
                  ),

                  // Info Riscaldamento
                  ListTile(
                    leading: Icon(AppIcons.whatshot, color: context.colors.warning),
                    title: Text(context.l10n.exerciseOptionsWarmupInfo),
                    subtitle: Text(context.l10n.exerciseOptionsWarmupInfoSubtitle),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && _hasWarmupData(exerciseData) && context.mounted) {
                        _showWarmupModal(context, exerciseData);
                      } else if (context.mounted) {
                        SnackBarService.showInfo(context, exerciseData == null
                                ? context.l10n.datiEsercizioNonDisponibili
                                : context.l10n.exerciseOptionsNoWarmupDataAvailable);
                      }
                    },
                  ),

                  // Aggiungi Set Riscaldamento
                  if (onAddWarmupSets != null) ...[
                    ListTile(
                      leading: Icon(AppIcons.addCircleOutline, color: context.colors.warning),
                      title: Text(context.l10n.addWarmupSets),
                      subtitle: Text(context.l10n.addWarmupSetsSubtitle),
                      onTap: () {
                        Navigator.pop(context);
                        onAddWarmupSets!();
                      },
                    ),
                  ],

                  // Prevenzione infortuni
                  ListTile(
                    leading: Icon(AppIcons.shieldOutlined, color: context.colors.success),
                    title: Text(context.l10n.exerciseOptionsInjuryPrevention),
                    subtitle: Text(context.l10n.exerciseOptionsInjuryPreventionSubtitle),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && _hasInjuryPreventionData(exerciseData) && context.mounted) {
                        _showInjuryPreventionModal(context, exerciseData);
                      } else if (context.mounted) {
                        SnackBarService.showInfo(context, exerciseData == null
                                ? context.l10n.datiEsercizioNonDisponibili
                                : context.l10n.exerciseOptionsNoInjuryPreventionDataAvailable);
                      }
                    },
                  ),

                  const Divider(),

                  // 🆕 Segnala problema
                  ListTile(
                    leading: Icon(AppIcons.flagOutlined, color: context.colors.warning),
                    title: Text(context.l10n.exerciseOptionsReportIssue),
                    subtitle: Text(context.l10n.exerciseOptionsReportIssueSubtitle),
                    onTap: () {
                      Navigator.pop(context);
                      // Show feedback dialog
                      ExerciseFeedbackButton.showFeedbackDialog(
                        context,
                        exerciseId: exercise.id,
                        exerciseName: exercise.name,
                        version: '1.0.0',
                      );
                    },
                  ),

                  const Divider(),
                  
                  // Storico
                  ListTile(
                    leading: const Icon(AppIcons.history),
                    title: Text(context.l10n.exerciseOptionsHistory),
                    onTap: () {
                      Navigator.pop(context);
                      if (onHistory != null) onHistory!();
                    },
                  ),
                  
                  // Show other options only if callbacks are provided
                  if (onEdit != null) ...[
                    ListTile(
                      leading: const Icon(AppIcons.edit),
                      title: Text(context.l10n.exerciseOptionsEditNameAndNotes),
                      subtitle: Text(context.l10n.exerciseOptionsEditNameAndNotesSubtitle),
                      onTap: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                    ),
                  ],

                  if (onChangeCountingMode != null) ...[
                    ListTile(
                      leading: const Icon(AppIcons.swapHoriz),
                      title: Text(context.l10n.exerciseOptionsChangeCountingFormat),
                      subtitle: Text(context.l10n.exerciseOptionsChangeCountingFormatSubtitle),
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

  /// Load exercise data from JSON
  static Future<Map<String, dynamic>?> _loadExerciseDataFromJson(String exerciseName, String languageCode) async {
    try {
      // Load from new folder structure with fallback
      final exercises = await ExerciseJsonLoader.loadExercises(languageCode);
      debugPrint('[ExerciseOptions] Loading data for: "$exerciseName"');

      // Find exercise by name (case-insensitive)
      Map<String, dynamic>? exercise;
      try {
        exercise = exercises.firstWhere(
          (ex) => ex['nome']?.toString().toLowerCase() == exerciseName.toLowerCase(),
        );
      } catch (e) {
        exercise = null;
      }

      if (exercise == null) {
        debugPrint('[ExerciseOptions] Exercise not found: "$exerciseName"');
        debugPrint('[ExerciseOptions] Available exercises (first 5): ${exercises.take(5).map((e) => e['nome']).toList()}');
      } else {
        debugPrint('[ExerciseOptions] Exercise found with keys: ${exercise.keys.toList()}');
      }

      return exercise;
    } catch (e) {
      debugPrint('[ExerciseOptions] Error loading exercise data: $e');
      return null;
    }
  }

  /// Check if exercise has warmup data
  static bool _hasWarmupData(Map<String, dynamic> exerciseData) {
    return exerciseData['mobilitaPre'] != null ||
           exerciseData['attivazionePre'] != null ||
           exerciseData['warmupSets'] != null;
  }

  /// Check if exercise has injury prevention data
  static bool _hasInjuryPreventionData(Map<String, dynamic> exerciseData) {
    return exerciseData['prevenzioneInfortuni'] != null ||
           exerciseData['cooldownConsigliato'] != null ||
           exerciseData['noteTecniche'] != null;
  }

  /// Show exercise info modal
  static void _showExerciseInfoModal(BuildContext context, Map<String, dynamic> exerciseData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(AppIcons.info, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exerciseData['nome'] ?? context.l10n.exerciseOptionsExerciseInfoTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (exerciseData['focus'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsPrimaryMuscles,
                        exerciseData['focus'],
                        AppIcons.workout,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['muscoliSecondari'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsSecondaryMuscles,
                        exerciseData['muscoliSecondari'],
                        AppIcons.sports,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['attrezzatura'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsEquipment,
                        exerciseData['attrezzatura'],
                        AppIcons.build,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['difficolta'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsDifficultyLevel,
                        exerciseData['difficolta'],
                        AppIcons.trendUp,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show warmup modal
  static void _showWarmupModal(BuildContext context, Map<String, dynamic> exerciseData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(AppIcons.whatshot, color: context.colors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.exerciseOptionsWarmupInfoTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (exerciseData['mobilitaPre'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsPreWorkoutMobility,
                        exerciseData['mobilitaPre'],
                        AppIcons.accessibility,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['attivazionePre'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsPreWorkoutActivation,
                        exerciseData['attivazionePre'],
                        AppIcons.flashOn,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['warmupSets'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsWarmupSets,
                        exerciseData['warmupSets'],
                        AppIcons.repeat,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show injury prevention modal
  static void _showInjuryPreventionModal(BuildContext context, Map<String, dynamic> exerciseData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(AppIcons.shieldOutlined, color: context.colors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.exerciseOptionsInjuryPreventionTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (exerciseData['prevenzioneInfortuni'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsInjuryPreventionSection,
                        exerciseData['prevenzioneInfortuni'],
                        AppIcons.warningAmber,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['cooldownConsigliato'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsRecommendedCooldown,
                        exerciseData['cooldownConsigliato'],
                        AppIcons.spa,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['noteTecniche'] != null) ...[
                      _buildInfoSection(
                        context,
                        context.l10n.exerciseOptionsTechnicalTips,
                        exerciseData['noteTecniche'],
                        AppIcons.tip,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to format step text for better readability
  static String _formatStepText(String text) {
    // Se il testo contiene " | ", lo dividiamo per gli step
    if (text.contains(' | ')) {
      return text.split(' | ').join('\n\n');
    }
    return text;
  }

  /// Helper method to build info sections
  static Widget _buildInfoSection(
    BuildContext context,
    String title,
    dynamic content,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (content is List) ...[
            ...content.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ] else ...[
            Text(
              _formatStepText(content.toString()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  /// Static method to show the modal
  static void show(BuildContext context, Exercise exercise, {
    VoidCallback? onEdit,
    VoidCallback? onHistory,
    VoidCallback? onDuplicate,
    VoidCallback? onDelete,
    VoidCallback? onChangeCountingMode,
    VoidCallback? onAddWarmupSets,
    String? imageUrl,
    String languageCode = 'en',
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
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
        languageCode: languageCode,
      ),
    );
  }
}
