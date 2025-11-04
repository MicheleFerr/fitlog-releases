import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'dart:convert';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_card_feedback.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// 🚀 TIER-1: Modal condiviso per opzioni esercizio sia per single che superset
class ExerciseOptionsModal extends StatelessWidget {

  const ExerciseOptionsModal({
    super.key,
    required this.exercise,
    this.onEdit,
    this.onHistory,
    this.onDuplicate,
    this.onDelete,
    this.imageUrl,
    this.languageCode = 'en',
  });
  final Exercise exercise;
  final VoidCallback? onEdit;
  final VoidCallback? onHistory;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
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
                    barrierColor: Colors.black87,
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
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
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
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.zoomOutMap,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap per ingrandire',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
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
                    Icons.fitness_center,
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
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Info esercizio'),
                    subtitle: const Text('Muscoli coinvolti e tecnica'),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && context.mounted) {
                        _showExerciseInfoModal(context, exerciseData);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dati esercizio non disponibili'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                  // Info Riscaldamento
                  ListTile(
                    leading: const Icon(Icons.whatshot, color: Colors.orange),
                    title: const Text('Info riscaldamento'),
                    subtitle: const Text('Consigli per il warmup'),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && _hasWarmupData(exerciseData) && context.mounted) {
                        _showWarmupModal(context, exerciseData);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(exerciseData == null
                                ? 'Dati esercizio non disponibili'
                                : 'Nessun dato di riscaldamento disponibile'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                  // Prevenzione infortuni
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: Colors.green),
                    title: const Text('Prevenzione infortuni'),
                    subtitle: const Text('Consigli per evitare infortuni'),
                    onTap: () async {
                      Navigator.pop(context);
                      final exerciseData = await _loadExerciseDataFromJson(exercise.name, languageCode);
                      if (exerciseData != null && _hasInjuryPreventionData(exerciseData) && context.mounted) {
                        _showInjuryPreventionModal(context, exerciseData);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(exerciseData == null
                                ? 'Dati esercizio non disponibili'
                                : 'Nessun dato di prevenzione infortuni disponibile'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                  const Divider(),

                  // 🆕 Segnala problema
                  ListTile(
                    leading: const Icon(AppIcons.flagOutlined, color: Colors.orange),
                    title: const Text('Segnala problema'),
                    subtitle: const Text('Bug, errori o suggerimenti'),
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
                    leading: const Icon(Icons.history),
                    title: const Text('Storico'),
                    onTap: () {
                      Navigator.pop(context);
                      if (onHistory != null) onHistory!();
                    },
                  ),
                  
                  // Show other options only if callbacks are provided
                  if (onEdit != null) ...[
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Modifica nome e note'),
                      subtitle: const Text('Personalizza nome esercizio e aggiungi note'),
                      onTap: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                    ),
                  ],
                  
                  if (onDuplicate != null) ...[
                    ListTile(
                      leading: const Icon(Icons.copy),
                      title: const Text('Duplica esercizio'),
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
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Elimina esercizio',
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
      // Load the correct JSON file based on language
      final String fileName = languageCode == 'it'
          ? 'assets/data/exercises_it.json'
          : 'assets/data/exercises.json';

      debugPrint('[ExerciseOptions] Loading data for: "$exerciseName" from $fileName');
      final String jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> exercises = json.decode(jsonString);

      // Find exercise by name (case-insensitive)
      final exercise = exercises.firstWhere(
        (ex) => ex['nome']?.toString().toLowerCase() == exerciseName.toLowerCase(),
        orElse: () => null,
      );

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
      backgroundColor: Colors.transparent,
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
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exerciseData['nome'] ?? 'Info Esercizio',
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
                        'Muscoli Primari',
                        exerciseData['focus'],
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['muscoliSecondari'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Muscoli Secondari',
                        exerciseData['muscoliSecondari'],
                        AppIcons.sports,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['attrezzatura'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Attrezzatura',
                        exerciseData['attrezzatura'],
                        AppIcons.build,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['difficolta'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Livello Difficoltà',
                        exerciseData['difficolta'],
                        Icons.trending_up,
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
      backgroundColor: Colors.transparent,
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
                    const Icon(Icons.whatshot, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Info Riscaldamento',
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
                        'Mobilità Pre-Workout',
                        exerciseData['mobilitaPre'],
                        Icons.accessibility_new,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['attivazionePre'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Attivazione Pre-Workout',
                        exerciseData['attivazionePre'],
                        Icons.flash_on,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['warmupSets'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Serie di Riscaldamento',
                        exerciseData['warmupSets'],
                        Icons.repeat,
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
      backgroundColor: Colors.transparent,
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
                    const Icon(Icons.shield_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Prevenzione Infortuni',
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
                        'Prevenzione Infortuni',
                        exerciseData['prevenzioneInfortuni'],
                        AppIcons.warningAmber,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['cooldownConsigliato'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Defaticamento Consigliato',
                        exerciseData['cooldownConsigliato'],
                        Icons.spa,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (exerciseData['noteTecniche'] != null) ...[
                      _buildInfoSection(
                        context,
                        'Suggerimenti Tecnici',
                        exerciseData['noteTecniche'],
                        Icons.lightbulb_outline,
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
    String? imageUrl,
    String languageCode = 'en',
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExerciseOptionsModal(
        exercise: exercise,
        onEdit: onEdit,
        onHistory: onHistory,
        onDuplicate: onDuplicate,
        onDelete: onDelete,
        imageUrl: imageUrl,
        languageCode: languageCode,
      ),
    );
  }
}