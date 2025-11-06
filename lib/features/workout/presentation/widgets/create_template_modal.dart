import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/unified_template_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/template_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_onboarding_overlay.dart';
import 'package:uuid/uuid.dart';
// Input Validation
import 'package:gymbro_flutter_new/shared/domain/validation/template_validator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class CreateTemplateModal extends ConsumerStatefulWidget {
  const CreateTemplateModal({super.key});

  @override
  ConsumerState<CreateTemplateModal> createState() => _CreateTemplateModalState();
}

class _CreateTemplateModalState extends ConsumerState<CreateTemplateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  // final _imageUrlController = TextEditingController(); // Commentato - feature futura

  // GlobalKeys per onboarding spotlight
  final _nameFieldKey = GlobalKey();
  final _descriptionFieldKey = GlobalKey();
  final _tagsKey = GlobalKey();
  final _timerKey = GlobalKey();

  final List<String> _selectedTags = [];
  int? _defaultRestTime;
  final List<String> _availableTags = [
    'upper',
    'lower',
    'full-body',
    'strength',
    'hypertrophy',
    'cardio',
    'hiit',
    'beginner',
    'intermediate',
    'advanced',
    'push',
    'pull',
    'legs',
    'core',
    'abs',
  ];

  bool _createFromCurrentWorkout = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Avvia l'onboarding DOPO che i widget sono renderizzati
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Aspetta un frame aggiuntivo per assicurarsi che i GlobalKey siano pronti
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(templateOnboardingProvider.notifier).startOnboarding();
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // _imageUrlController.dispose(); // Commentato
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final hasActiveWorkout = currentWorkout != null && currentWorkout.exercises.isNotEmpty;
    final localizations = AppLocalizations.of(context);

    return Stack(
      children: [
        Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Titolo
          Row(
            children: [
              const Icon(AppIcons.addCircleOutline, size: 24),
              const SizedBox(width: 8),
              Text(
                localizations.createTemplate ?? 'Crea Template',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Opzione per creare da workout attuale
          if (hasActiveWorkout) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.workout,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Workout Attuale Rilevato',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentWorkout.exercises.length} esercizi trovati: "${currentWorkout.name}"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _createFromCurrentWorkout,
                    onChanged: (value) {
                      setState(() {
                        _createFromCurrentWorkout = value;
                        if (value && _nameController.text.isEmpty) {
                          _nameController.text = '${currentWorkout.name} Template';
                        }
                      });
                    },
                    title: const Text('Crea da workout attuale'),
                    subtitle: const Text('Include tutti gli esercizi e set'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome template
                    TextFormField(
                      key: _nameFieldKey,
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.templateNameLabel ?? 'Nome Template *',
                        hintText: 'es. Upper Body Strength',
                        border: const OutlineInputBorder(),
                        helperText: 'Max ${TemplateValidator.maxNameLength} characters',
                      ),
                      maxLength: TemplateValidator.maxNameLength,
                      validator: (value) => TemplateValidator.validateTemplateName(value),
                      onChanged: (value) {
                        // Auto-sanitize as user types
                        final sanitized = TemplateValidator.sanitizeTemplateName(value);
                        if (sanitized != value) {
                          _nameController.value = TextEditingValue(
                            text: sanitized,
                            selection: TextSelection.collapsed(offset: sanitized.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descrizione (opzionale)
                    TextFormField(
                      key: _descriptionFieldKey,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: localizations.templateDescriptionOptional,
                        hintText: localizations.templateDescriptionHint ?? 'Breve descrizione del workout...',
                        border: const OutlineInputBorder(),
                        helperText: 'Optional, max ${TemplateValidator.maxDescriptionLength} characters',
                      ),
                      maxLines: 3,
                      maxLength: TemplateValidator.maxDescriptionLength,
                      validator: (value) => TemplateValidator.validateTemplateDescription(value),
                      onChanged: (value) {
                        // Auto-sanitize as user types
                        if (value.isNotEmpty) {
                          final sanitized = TemplateValidator.sanitizeTemplateDescription(value);
                          if (sanitized != value) {
                            _descriptionController.value = TextEditingValue(
                              text: sanitized,
                              selection: TextSelection.collapsed(offset: sanitized.length),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // URL Immagine - COMMENTATO per feature futura
                    // TextFormField(
                    //   controller: _imageUrlController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'URL Immagine (opzionale)',
                    //     hintText: 'https://...',
                    //     border: OutlineInputBorder(),
                    //     prefixIcon: Icon(AppIcons.image),
                    //   ),
                    //   validator: (value) {
                    //     if (value != null && value.isNotEmpty) {
                    //       final uri = Uri.tryParse(value);
                    //       if (uri == null || !uri.hasScheme) {
                    //         return 'URL non valido';
                    //       }
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // const SizedBox(height: 20),

                    // Tag selection
                    Container(
                      key: _tagsKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.tags ?? 'Tag',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.selectTagsDescription ?? 'Seleziona i tag che descrivono il tuo template',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),

                    // Timer di default
                    Container(
                      key: _timerKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.defaultRestTimer ?? 'Timer di Recupero Default',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.defaultRestTimerDescription ??
                              'Imposta un timer di default che verrà applicato a tutti gli esercizi del template',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _showDefaultRestTimePicker,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.timer,
                              color: _defaultRestTime != null 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _defaultRestTime != null 
                                    ? 'Timer: ${_formatRestTime(_defaultRestTime!)}'
                                    : 'Nessun timer di default',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _defaultRestTime != null 
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Icon(
                              AppIcons.forwardIos,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // DISABLED: Fitness Profile / Weight Suggestions
                    // Reason: GDPR compliance concerns - medical questionnaire data
                    // Date: 2025-01-21
                    /*
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.workout,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Weight Suggestions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, _) {
                              final questionnaire = ref.watch(userFitnessQuestionnaireProvider);

                              if (questionnaire != null && questionnaire.isValid) {
                                return Text(
                                  'Profile configured (${questionnaire.experienceLevel.name}) - weight suggestions available',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              }

                              return Text(
                                'Configure your fitness profile to get personalized weight suggestions',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Consumer(
                            builder: (context, ref, _) {
                              final questionnaire = ref.watch(userFitnessQuestionnaireProvider);

                              return OutlinedButton.icon(
                                onPressed: () async {
                                  final result = await showModalBottomSheet<bool>(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    builder: (_) => const FitnessQuestionnaireScreen(),
                                  );
                                  if (result == true && context.mounted) {
                                    ref.invalidate(userFitnessQuestionnaireProvider);
                                  }
                                },
                                icon: Icon(
                                  questionnaire != null ? AppIcons.edit : AppIcons.addCircleOutline,
                                ),
                                label: Text(
                                  questionnaire != null
                                      ? 'Update Profile'
                                      : 'Calculate Your Level',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    */

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Pulsanti azione
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _createTemplate,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crea Template'),
                ),
              ),
            ],
          ),
        ],
      ),
        ),

        // Onboarding overlay
        TemplateOnboardingOverlay(
          nameFieldKey: _nameFieldKey,
          descriptionFieldKey: _descriptionFieldKey,
          tagsKey: _tagsKey,
          timerKey: _timerKey,
        ),
      ],
    );
  }

  Future<void> _createTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final unifiedRepository = ref.read(unifiedTemplateRepositoryProvider);
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final templateId = const Uuid().v4();
      List<Map<String, dynamic>> exercisesRaw = [];
      String templateName = _nameController.text.trim();

      if (_createFromCurrentWorkout) {
        final currentWorkout = ref.read(currentWorkoutProvider)!;
        templateName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : currentWorkout.name;
        
        var exercisesToAdd = currentWorkout.exercises;
        if (_defaultRestTime != null) {
          exercisesToAdd = currentWorkout.exercises.map((exercise) {
            if (exercise.restTime == null) {
              return exercise.copyWith(restTime: _defaultRestTime);
            }
            return exercise;
          }).toList();
        }
        exercisesRaw = exercisesToAdd.map((e) => e.toJson()).toList();
      }

      final newTemplate = UnifiedWorkoutTemplate(
        id: templateId,
        name: templateName,
        description: _descriptionController.text.trim(),
        exercisesRaw: exercisesRaw,
        isCustom: true,
        userId: userId,
        authorName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: _selectedTags,
        imageUrl: null, // _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        source: TemplateSource.modern,
        exerciseFormat: ExerciseFormat.legacy,
        version: 1,
      );

      await unifiedRepository.createTemplate(newTemplate);

      // Invalidate providers to refresh UI
      ref.invalidate(userTemplatesProvider);
      ref.invalidate(customWorkoutTemplatesProvider);

      // Feedback di successo
      HapticFeedback.lightImpact();
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "$templateName" creato con successo!'),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella creazione: $e'),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDefaultRestTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RestTimePickerModal(
        initialRestTime: _defaultRestTime,
        onRestTimeSelected: (restTime) {
          setState(() {
            _defaultRestTime = restTime;
          });
        },
      ),
    );
  }

  String _formatRestTime(int seconds) {
    if (seconds == 0) return '0s';
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes == 0) {
      return '${seconds}s';
    } else if (remainingSeconds == 0) {
      return '${minutes}min';
    } else {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
