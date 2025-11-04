/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: modal
/// 🌍 Localization: ✅ Full support
/// 🎨 Theme: ✅ Adaptive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Flutter Material & Riverpod
/// - Community contribution system
/// - Exercise entities
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/contribution_success_dialog.dart';

class CommunityContributionModal extends ConsumerStatefulWidget {

  const CommunityContributionModal({
    super.key,
    required this.exercise,
    required this.suggestionType,
    this.initialSuggestion,
    this.contextType,
    this.exerciseData,
  });

  final Exercise exercise;
  final ContributionType suggestionType;
  final String? initialSuggestion;
  final String? contextType;
  final Map<String, dynamic>? exerciseData;

  @override
  ConsumerState<CommunityContributionModal> createState() =>
      _CommunityContributionModalState();
}

class _CommunityContributionModalState
    extends ConsumerState<CommunityContributionModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  ContributionType _selectedType = ContributionType.tip;
  String? _selectedSection;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.suggestionType;
    _titleController = TextEditingController(
      text: _getContextualTitle(),
    );
    _descriptionController = TextEditingController(
      text: widget.initialSuggestion ?? '',
    );
  }

  String _getContextualTitle() {
    if (widget.contextType == null) return '';

    switch (widget.contextType) {
      case 'exercise_info':
        return _selectedType == ContributionType.correction
            ? 'Correzione info muscoli/tecnica'
            : 'Nuovo tip per ${widget.exercise.name}';
      case 'warmup':
        return _selectedType == ContributionType.correction
            ? 'Correzione info riscaldamento'
            : 'Consiglio warmup per ${widget.exercise.name}';
      case 'injury_prevention':
        return _selectedType == ContributionType.correction
            ? 'Correzione info sicurezza'
            : 'Avviso sicurezza per ${widget.exercise.name}';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitContribution() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      SnackBarService.showWarning(
        context,
        '⚠️ Compila tutti i campi obbligatori',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Per le correzioni, salva anche il campo specifico e i valori
      String? originalValue;
      String? suggestedValue;

      if (_selectedType == ContributionType.correction && _selectedSection != null) {
        originalValue = _getCurrentSectionValue(_selectedSection!);
        suggestedValue = _descriptionController.text;
      }

      await ref.read(contributionSubmissionProvider.notifier).submitContribution(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
        originalValue: originalValue,
        suggestedValue: suggestedValue,
        metadata: _selectedType == ContributionType.correction && _selectedSection != null
          ? {'field': _selectedSection}
          : null,
      );

      if (mounted) {
        // Haptic feedback di successo
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        HapticFeedback.lightImpact();

        // Chiudi modal
        Navigator.of(context).pop();

        // Mostra dialogo di successo premium
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        HapticFeedback.heavyImpact();
        SnackBarService.showError(
          context,
          'Errore: ${e.toString()}',
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContributionSuccessDialog(
        contributionType: _selectedType,
        onViewContribution: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/community_hub');
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );

    // Auto-dismiss dopo 5 secondi
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      height: context.screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    color: context.colors.surface,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contribuisci alla Community',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Aiuta altri utenti con ${widget.exercise.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selector
                  Text(
                    'Tipo di contributo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTypeChip(
                        ContributionType.tip,
                        '💡 Consiglio',
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.warning,
                        '⚠️ Avviso',
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.correction,
                        '✏️ Correzione',
                        theme
                      ),
                      _buildTypeChip(
                        ContributionType.technique,
                        '🎯 Tecnica',
                        theme
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section selector for corrections
                  if (_selectedType == ContributionType.correction && widget.contextType != null)
                    ...[
                      Text(
                        'Sezione da correggere',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getSectionOptions().map((section) {
                          final isSelected = _selectedSection == section;
                          return ChoiceChip(
                            label: Text(section),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSection = selected ? section : null;
                                // Update title based on section
                                if (selected) {
                                  _titleController.text = 'Correzione: $section';
                                  // Pre-populate with current value
                                  _populateCurrentValue(section);
                                }
                              });
                            },
                            selectedColor: theme.colorScheme.primaryContainer,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Show current value
                      if (_selectedSection != null && _getCurrentSectionValue(_selectedSection!) != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Valore attuale da correggere:',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getCurrentSectionValue(_selectedSection!) ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                  // Title input
                  Text(
                    'Titolo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Es: Posizione corretta della schiena',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description input
                  Text(
                    'Descrizione',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: _getDescriptionPlaceholder(),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
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
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Il tuo contributo sarà revisionato dalla community prima di essere approvato',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: context.colors.onSurface.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitContribution,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(context.colors.surface),
                          ),
                        )
                      : const Text(
                          'Invia Contributo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSectionOptions() {
    switch (widget.contextType) {
      case 'exercise_info':
        return [
          'Muscoli primari',
          'Muscoli secondari',
          'Tipo esercizio',
          'Attrezzatura',
          'Range ripetizioni',
          'Pattern movimento',
        ];
      case 'warmup':
        return [
          'Serie riscaldamento',
          'Durata riscaldamento',
          'Mobilità articolare',
          'Attivazione muscolare',
          'Progressione carico',
        ];
      case 'injury_prevention':
        return [
          'Prevenzione infortuni',
          'Note tecniche',
          'Drill tecnico',
          'Cooldown consigliato',
          'Errori comuni',
        ];
      default:
        return [];
    }
  }

  String _getDescriptionPlaceholder() {
    switch (_selectedType) {
      case ContributionType.tip:
        return 'Condividi un consiglio utile che hai scoperto per questo esercizio...';
      case ContributionType.warning:
        return 'Segnala un rischio o errore comune da evitare...';
      case ContributionType.correction:
        if (_selectedSection != null) {
          return 'Spiega cosa correggere in "$_selectedSection"...';
        }
        return 'Descrivi cosa deve essere corretto e perché...';
      case ContributionType.technique:
        return 'Descrivi la tecnica corretta per eseguire questo esercizio...';
      default:
        return 'Scrivi qui il tuo contributo...';
    }
  }

  String? _getCurrentSectionValue(String section) {
    // Get the current value from loaded exercise data
    if (widget.exerciseData == null) return null;

    switch (section) {
      case 'Nome':
        return widget.exercise.name;
      case 'Serie riscaldamento':
        return widget.exerciseData?['warmupSets'];
      case 'Durata riscaldamento':
        return widget.exerciseData?['tempoWarmup'];
      case 'Tipo riscaldamento':
        return widget.exerciseData?['attivazionePre'];
      case 'Muscoli target':
        return widget.exerciseData?['focus'];
      case 'Muscoli secondari':
        return widget.exerciseData?['muscoliSecondari'];
      case 'Attrezzatura':
        return widget.exerciseData?['attrezzatura'];
      case 'Descrizione':
        return widget.exerciseData?['noteTecniche'];
      case 'Mobilità articolare':
        return widget.exerciseData?['mobilitaPre'];
      case 'Attivazione muscolare':
        return widget.exerciseData?['attivazionePre'];
      case 'Progressione carico':
        return widget.exerciseData?['warmupSets'];
      case 'Prevenzione infortuni':
        return widget.exerciseData?['prevenzioneInfortuni'];
      case 'Note tecniche':
        return widget.exerciseData?['noteTecniche'];
      case 'Drill tecnico':
        return widget.exerciseData?['drillTecnico'];
      case 'Cooldown consigliato':
        return widget.exerciseData?['cooldownConsigliato'];
      case 'Errori comuni':
        return widget.exerciseData?['erroriComuni'];
      case 'Difficoltà':
        return widget.exerciseData?['difficolta'];
      case 'Tipo esercizio':
        return widget.exerciseData?['tipoEsercizio'];
      case 'Range ripetizioni':
        return widget.exerciseData?['rangeRipetizioni'];
      case 'Pattern movimento':
        return widget.exerciseData?['patternMovimento'];
      default:
        return null;
    }
  }

  void _populateCurrentValue(String section) {
    final currentValue = _getCurrentSectionValue(section);
    if (currentValue != null) {
      // Pre-fill the description with current value for easy editing
      _descriptionController.text = 'Valore attuale: "$currentValue"\n\nValore corretto: ';
    }
  }

  Widget _buildTypeChip(ContributionType type, String label, ThemeData theme) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedType = type;
          });
        }
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}
