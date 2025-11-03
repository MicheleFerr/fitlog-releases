/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/widgets
/// 🎯 Feature: community
/// 🔧 Type: widget
///
/// Modal per creare nuovo contributo community
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/quick_exercise_picker.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Modal per creare un nuovo contributo community
class CreateContributionModal extends ConsumerStatefulWidget {

  const CreateContributionModal({
    super.key,
    this.preselectedExerciseId,
    this.preselectedExerciseName,
  });
  final String? preselectedExerciseId;
  final String? preselectedExerciseName;

  @override
  ConsumerState<CreateContributionModal> createState() => _CreateContributionModalState();
}

class _CreateContributionModalState extends ConsumerState<CreateContributionModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalValueController = TextEditingController();
  final _suggestedValueController = TextEditingController();
  final _searchController = TextEditingController();

  ContributionType _selectedType = ContributionType.tip;
  String? _selectedExerciseId;
  String? _selectedExerciseName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedExerciseId != null) {
      _selectedExerciseId = widget.preselectedExerciseId;
      _selectedExerciseName = widget.preselectedExerciseName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalValueController.dispose();
    _suggestedValueController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nuovo Contributo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    children: [
                      // Exercise Selection
                      _buildExerciseSelector(theme),
                      SizedBox(height: 20),

                      // Contribution Type
                      _buildTypeSelector(theme),
                      SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Titolo',
                          hintText: 'Es: Migliore presa per principianti',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.title),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Il titolo è obbligatorio';
                          }
                          if (value.trim().length < 10) {
                            return 'Il titolo deve essere almeno 10 caratteri';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          hintText: _getDescriptionHint(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descrizione è obbligatoria';
                          }
                          if (value.trim().length < 20) {
                            return 'La descrizione deve essere almeno 20 caratteri';
                          }
                          return null;
                        },
                      ),

                      // Correction-specific fields
                      if (_selectedType == ContributionType.correction) ...[
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _originalValueController,
                          decoration: InputDecoration(
                            labelText: 'Valore Attuale (Errato)',
                            hintText: 'Es: Presa stretta',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.error_outline),
                          ),
                          validator: _selectedType == ContributionType.correction
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Valore attuale obbligatorio per correzioni';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _suggestedValueController,
                          decoration: InputDecoration(
                            labelText: 'Valore Corretto',
                            hintText: 'Es: Presa larga',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(AppIcons.completeOutline),
                          ),
                          validator: _selectedType == ContributionType.correction
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Valore corretto obbligatorio';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ],

                      SizedBox(height: 24),

                      // Info box
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Il tuo contributo sarà revisionato da un admin prima di essere pubblicato. Riceverai +50 XP se approvato!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Submit Button
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.send),
                        label: Text(_isSubmitting ? 'Invio...' : 'Invia Contributo'),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 80), // Space for keyboard
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseSelector(ThemeData theme) {
    if (_selectedExerciseName != null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esercizio',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    _selectedExerciseName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedExerciseId = null;
                  _selectedExerciseName = null;
                });
              },
              icon: Icon(Icons.edit),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona Esercizio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => _showExercisePicker(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tocca per selezionare un esercizio',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo di Contributo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ContributionType.values.map((type) {
            final isSelected = _selectedType == type;
            final color = _getTypeColor(type);

            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: isSelected ? context.colors.surface : color,
                  ),
                  SizedBox(width: 6),
                  Text(_getTypeLabel(type)),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
              selectedColor: color,
              checkmarkColor: context.colors.surface,
              labelStyle: TextStyle(
                color: isSelected ? context.colors.surface : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Text(
          _getTypeDescription(_selectedType),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showExercisePicker() async {
    // Usa il nuovo QuickExercisePicker condiviso
    final result = await context.showQuickExercisePicker();

    if (result != null && mounted) {
      setState(() {
        _selectedExerciseId = result.id;
        _selectedExerciseName = result.nome;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Seleziona un esercizio'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(contributionSubmissionProvider.notifier).submitContribution(
            exerciseId: _selectedExerciseId!,
            exerciseName: _selectedExerciseName!,
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            originalValue: _selectedType == ContributionType.correction
                ? _originalValueController.text.trim()
                : null,
            suggestedValue: _selectedType == ContributionType.correction
                ? _suggestedValueController.text.trim()
                : null,
          );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Contributo inviato! In attesa di approvazione'),
          backgroundColor: context.colors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getDescriptionHint() {
    switch (_selectedType) {
      case ContributionType.tip:
        return 'Condividi un consiglio utile per questo esercizio...';
      case ContributionType.warning:
        return 'Descrivi cosa evitare e perché è pericoloso...';
      case ContributionType.correction:
        return 'Spiega qual è l\'errore comune e come correggerlo...';
      case ContributionType.technique:
        return 'Descrivi la tecnica corretta passo per passo...';
      case ContributionType.variant:
        return 'Descrivi la variante dell\'esercizio...';
      case ContributionType.translation:
        return 'Fornisci la traduzione corretta...';
    }
  }

  String _getTypeDescription(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return 'Consiglio pratico per migliorare l\'esecuzione';
      case ContributionType.warning:
        return 'Avviso su errori comuni o rischi';
      case ContributionType.correction:
        return 'Correzione di informazioni errate';
      case ContributionType.technique:
        return 'Spiegazione tecnica dettagliata';
      case ContributionType.variant:
        return 'Variante dell\'esercizio';
      case ContributionType.translation:
        return 'Traduzione dell\'esercizio';
    }
  }

  Color _getTypeColor(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.colors.primary;
      case ContributionType.warning:
        return context.colors.secondary;
      case ContributionType.correction:
        return context.colors.error;
      case ContributionType.technique:
        return context.colors.success;
      case ContributionType.variant:
        return context.colors.tertiary;
      case ContributionType.translation:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return Icons.lightbulb;
      case ContributionType.warning:
        return Icons.warning;
      case ContributionType.correction:
        return Icons.edit;
      case ContributionType.technique:
        return Icons.school;
      case ContributionType.variant:
        return Icons.alt_route;
      case ContributionType.translation:
        return AppIcons.translate;
    }
  }

  String _getTypeLabel(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return 'Consiglio';
      case ContributionType.warning:
        return 'Avviso';
      case ContributionType.correction:
        return 'Correzione';
      case ContributionType.technique:
        return 'Tecnica';
      case ContributionType.variant:
        return 'Variante';
      case ContributionType.translation:
        return 'Traduzione';
    }
  }
}
