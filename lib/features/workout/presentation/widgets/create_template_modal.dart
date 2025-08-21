import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/workout_template.dart';
import '../providers/workout_template_provider.dart';
import '../providers/workout_provider.dart';
import 'rest_time_picker_modal.dart';

class CreateTemplateModal extends ConsumerStatefulWidget {
  const CreateTemplateModal({super.key});

  @override
  ConsumerState<CreateTemplateModal> createState() => _CreateTemplateModalState();
}

class _CreateTemplateModalState extends ConsumerState<CreateTemplateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final hasActiveWorkout = currentWorkout != null && currentWorkout.exercises.isNotEmpty;

    return Container(
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
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Titolo
          Row(
            children: [
              const Icon(Icons.add_circle_outline, size: 24),
              const SizedBox(width: 8),
              Text(
                'Crea Template',
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
                        Icons.fitness_center,
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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Template *',
                        hintText: 'es. Upper Body Strength',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Il nome è obbligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descrizione
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrizione *',
                        hintText: 'Breve descrizione del workout...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descrizione è obbligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // URL Immagine (opzionale)
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Immagine (opzionale)',
                        hintText: 'https://...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasScheme) {
                            return 'URL non valido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tag selection
                    Text(
                      'Tag',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seleziona i tag che descrivono il tuo template',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                    Text(
                      'Timer di Recupero Default',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Imposta un timer di default che verrà applicato a tutti gli esercizi del template',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                              Icons.timer,
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
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
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
    );
  }

  Future<void> _createTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final templateNotifier = ref.read(workoutTemplateNotifierProvider.notifier);

      if (_createFromCurrentWorkout) {
        // Crea template dal workout attuale
        final currentWorkout = ref.read(currentWorkoutProvider)!;
        
        // Applica timer di default agli esercizi se impostato
        var exercisesToAdd = currentWorkout.exercises;
        if (_defaultRestTime != null) {
          exercisesToAdd = currentWorkout.exercises.map((exercise) {
            if (exercise.restTime == null) {
              return exercise.copyWith(restTime: _defaultRestTime);
            }
            return exercise;
          }).toList();
        }
        
        await templateNotifier.createTemplateFromWorkout(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          exercises: exercisesToAdd,
          tags: _selectedTags,
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
        );
      } else {
        // Crea template vuoto
        final template = WorkoutTemplate(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          exercises: [], // Template vuoto
          tags: _selectedTags,
          imageUrl: _imageUrlController.text.trim().isEmpty 
              ? null 
              : _imageUrlController.text.trim(),
        );

        await templateNotifier.saveTemplate(template);
      }

      // Feedback di successo
      HapticFeedback.lightImpact();
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${_nameController.text}" creato con successo!'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
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
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}