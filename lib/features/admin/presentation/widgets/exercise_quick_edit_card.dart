/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Card per editing veloce degli esercizi con inline dropdown
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/database_manager_provider.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/database_manager_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class ExerciseQuickEditCard extends ConsumerStatefulWidget {

  const ExerciseQuickEditCard({
    super.key,
    required this.exercise,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onTap,
  });
  final Exercise exercise;
  final bool isSelected;
  final Function(bool?)? onSelectionChanged;
  final VoidCallback? onTap;

  @override
  ConsumerState<ExerciseQuickEditCard> createState() => _ExerciseQuickEditCardState();
}

class _ExerciseQuickEditCardState extends ConsumerState<ExerciseQuickEditCard> {
  bool _isSaving = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dropdownValues = ref.watch(exerciseDropdownValuesProvider);
    final requiresWeight = ref.watch(requiresWeightProvider(widget.exercise.attrezzatura));

    return Card(
      elevation: widget.isSelected ? 4 : 1,
      color: widget.isSelected
          ? context.colors.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row con checkbox, nome e badges
              Row(
                children: [
                  // Checkbox selezione
                  if (widget.onSelectionChanged != null)
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: widget.onSelectionChanged,
                    ),

                  // Immagine esercizio (se disponibile)
                  if (widget.exercise.imageUrl != null)
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.colors.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.exercise.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.fitness_center,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  // Nome esercizio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.nome,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.exercise.focusDisplayName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge corpo libero
                  if (!requiresWeight)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: context.colors.onSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NO PESI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Indicatore salvataggio
                  if (_isSaving)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Basic quick edit fields
              dropdownValues.when(
                data: (values) => _buildBasicFields(context, values),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 8),

              // Expand/Collapse button
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isExpanded ? 'Meno dettagli' : 'Più dettagli',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded fields
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                dropdownValues.when(
                  data: (values) => _buildExpandedFields(context, values),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],

              // Focus muscles chips
              if (widget.exercise.focus.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildMuscleChips(context, 'Focus:', widget.exercise.focus, context.colors.primary),
              ],

              // Secondary muscles chips
              if (widget.exercise.muscoliSecondari.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildMuscleChips(context, 'Secondari:', widget.exercise.muscoliSecondari, context.colors.secondary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicFields(BuildContext context, ExerciseDropdownValues values) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Dropdown Attrezzatura
        _QuickDropdown(
          icon: Icons.fitness_center,
          value: widget.exercise.attrezzatura,
          items: values.equipments,
          onChanged: (value) => _updateField('attrezzatura', value),
          tooltip: l10n.equipment,
          width: 140,
          isHighlighted: widget.exercise.attrezzatura == 'Corpo Libero',
        ),

        // Dropdown Difficoltà
        _QuickDropdown(
          icon: Icons.trending_up,
          value: widget.exercise.difficolta,
          items: values.difficulties,
          onChanged: (value) => _updateField('difficolta', value),
          tooltip: l10n.difficulty,
          width: 130,
          color: _getDifficultyColor(widget.exercise.difficolta),
        ),

        // Dropdown Tipo Esercizio
        _QuickDropdown(
          icon: Icons.category,
          value: widget.exercise.tipoEsercizio,
          items: values.exerciseTypes,
          onChanged: (value) => _updateField('tipoEsercizio', value),
          tooltip: l10n.exerciseType,
          width: 130,
        ),

        // Dropdown Range Ripetizioni
        _QuickDropdown(
          icon: Icons.repeat,
          value: widget.exercise.rangeRipetizioni,
          items: values.repRanges,
          onChanged: (value) => _updateField('rangeRipetizioni', value),
          tooltip: l10n.repRange,
          width: 100,
        ),

        // Dropdown TUT (Time Under Tension)
        if (widget.exercise.tempoEsecuzione != null)
          _QuickDropdown(
            icon: Icons.timer,
            value: widget.exercise.tempoEsecuzione ?? '',
            items: values.tutOptions,
            onChanged: (value) => _updateField('tempoEsecuzione', value),
            tooltip: l10n.tempoEsecuzione,
            width: 120,
            color: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildExpandedFields(BuildContext context, ExerciseDropdownValues values) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pattern di movimento
        if (widget.exercise.patternMovimento.isNotEmpty) ...[
          _buildExpandedField(
            context,
            'Pattern Movimento',
            widget.exercise.patternMovimento,
            Icons.directions_run,
          ),
          const SizedBox(height: 8),
        ],

        // Immagine con preview
        if (widget.exercise.imageUrl != null) ...[
          _buildImageField(context),
          const SizedBox(height: 8),
        ],

        // Note tecniche
        if (widget.exercise.noteTecniche != null) ...[
          _buildExpandedField(
            context,
            'Note Tecniche',
            widget.exercise.noteTecniche!,
            Icons.notes,
          ),
          const SizedBox(height: 8),
        ],

        // Mobilità pre-workout
        if (widget.exercise.mobilitaPre != null) ...[
          _buildExpandedField(
            context,
            'Mobilità Pre',
            widget.exercise.mobilitaPre!,
            Icons.accessibility_new,
          ),
          const SizedBox(height: 8),
        ],

        // Attivazione pre-workout
        if (widget.exercise.attivazionePre != null) ...[
          _buildExpandedField(
            context,
            'Attivazione Pre',
            widget.exercise.attivazionePre!,
            Icons.bolt,
          ),
          const SizedBox(height: 8),
        ],

        // Tempo note se presente
        if (widget.exercise.tempoNote != null) ...[
          _buildExpandedField(
            context,
            'Nota TUT',
            widget.exercise.tempoNote!,
            Icons.schedule,
          ),
        ],
      ],
    );
  }

  Widget _buildMuscleChips(BuildContext context, String label, List<String> muscles, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: muscles.map((muscle) =>
            Chip(
              label: Text(
                muscle,
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide(color: color.withOpacity(0.3)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildExpandedField(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageField(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showImagePreview(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                widget.exercise.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: context.colors.surface,
                  child: Icon(
                    Icons.broken_image,
                    size: 20,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Immagine esercizio',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tieni premuto per anteprima',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.touch_app,
              size: 16,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateField(String field, String? value) async {
    if (value == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(databaseManagerProvider.notifier).quickUpdateField(
        widget.exercise.id,
        field,
        value,
      );

      // Mostra feedback se è stato cambiato a corpo libero
      if (field == 'attrezzatura' && value == 'Corpo Libero') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Pesi disabilitati per ${widget.exercise.nome}'),
              backgroundColor: context.colors.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showImagePreview(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: context.colors.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: context.colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.imagePreview,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Image
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                widget.exercise.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Errore caricamento immagine',
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Implementa cambio immagine
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cambio immagine - Coming soon')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.changeImage),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzato':
        return Colors.red;
      default:
        return null;
    }
  }
}

/// Dropdown compatto per quick edit
class _QuickDropdown extends StatelessWidget {

  const _QuickDropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.tooltip,
    required this.width,
    this.color,
    this.isHighlighted = false,
  });
  final IconData icon;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final String tooltip;
  final double width;
  final Color? color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(
          color: isHighlighted
              ? context.colors.secondary
              : context.colors.outline.withOpacity(0.3),
          width: isHighlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isHighlighted
            ? context.colors.secondary.withOpacity(0.1)
            : null,
      ),
      child: Tooltip(
        message: tooltip,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items.map((item) =>
              DropdownMenuItem(
                value: item,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
            onChanged: onChanged,
            isDense: true,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
