import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/shared/domain/validation/template_validator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Template type for quick selection (replaces 15 confusing tags)
enum TemplateType {
  upper,
  lower,
  fullBody;

  String getDisplayName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TemplateType.upper:
        return l10n.templateTypeUpper;
      case TemplateType.lower:
        return l10n.templateTypeLower;
      case TemplateType.fullBody:
        return l10n.templateTypeFullBody;
    }
  }

  IconData get icon {
    switch (this) {
      case TemplateType.upper:
        return AppIcons.arrowUpward;
      case TemplateType.lower:
        return AppIcons.arrowDownward;
      case TemplateType.fullBody:
        return AppIcons.workout;
    }
  }

  /// Convert to tag for backward compatibility
  String get tag {
    switch (this) {
      case TemplateType.upper:
        return 'upper';
      case TemplateType.lower:
        return 'lower';
      case TemplateType.fullBody:
        return 'full-body';
    }
  }
}

class CreateTemplateModal extends ConsumerStatefulWidget {
  const CreateTemplateModal({super.key});

  @override
  ConsumerState<CreateTemplateModal> createState() =>
      _CreateTemplateModalState();
}

class _CreateTemplateModalState extends ConsumerState<CreateTemplateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Quick Create state
  TemplateType? _selectedType;
  bool _showAdvancedOptions = false;

  // Advanced options
  int _defaultRestTime = 90; // Smart default: 90 seconds

  // From current workout
  bool _createFromCurrentWorkout = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-detect type from name as user types
    _nameController.addListener(_autoDetectType);
  }

  @override
  void dispose() {
    _nameController.removeListener(_autoDetectType);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Smart type detection based on template name
  void _autoDetectType() {
    final name = _nameController.text.toLowerCase();

    // Only auto-detect if user hasn't manually selected
    if (_selectedType != null) return;

    TemplateType? detected;

    // Upper body keywords
    if (name.contains('push') ||
        name.contains('upper') ||
        name.contains('chest') ||
        name.contains('shoulder') ||
        name.contains('back') ||
        name.contains('pull') ||
        name.contains('arm')) {
      detected = TemplateType.upper;
    }
    // Lower body keywords
    else if (name.contains('leg') ||
        name.contains('lower') ||
        name.contains('squat') ||
        name.contains('glute')) {
      detected = TemplateType.lower;
    }
    // Full body keywords
    else if (name.contains('full') ||
        name.contains('total') ||
        name.contains('whole')) {
      detected = TemplateType.fullBody;
    }

    // Don't setState during build - schedule for next frame
    if (detected != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedType == null) {
          setState(() => _selectedType = detected);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final hasActiveWorkout =
        currentWorkout != null && currentWorkout.exercises.isNotEmpty;
    final l10n = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Ridotto da 0.85
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: context.colors.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Titolo semplificato
          Row(
            children: [
              Icon(
                AppIcons.flashOn,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.createTemplate,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form semplificato
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Opzione per creare da workout attuale (compatta)
                    if (hasActiveWorkout) ...[
                      _buildCreateFromWorkoutOption(currentWorkout),
                      const SizedBox(height: 16),
                    ],

                    // Nome template - Semplificato
                    TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.templateNameLabel,
                        hintText: 'es. Push Day, Leg Day...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(
                          AppIcons.edit,
                          size: AppIconSize.small,
                        ),
                      ),
                      validator: (value) =>
                          TemplateValidator.validateTemplateName(value),
                    ),
                    const SizedBox(height: 20),

                    // Tipo Template - 3 opzioni chiare
                    Text(
                      l10n.templateType,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTypeSelector(),
                    const SizedBox(height: 20),

                    // Opzioni Avanzate (collapsabile)
                    _buildAdvancedOptionsSection(l10n),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Pulsante CTA prominente
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _createTemplate,
              icon: _isLoading
                  ? LoadingIndicator(size: 20, color: context.colors.onPrimary)
                  : const Icon(AppIcons.check),
              label: Text(
                l10n.createTemplateButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateFromWorkoutOption(dynamic currentWorkout) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _createFromCurrentWorkout
            ? context.colors.primaryContainer.withValues(alpha: 0.3)
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _createFromCurrentWorkout
              ? context.colors.primary.withValues(alpha: 0.5)
              : context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _createFromCurrentWorkout = !_createFromCurrentWorkout;
            if (_createFromCurrentWorkout && _nameController.text.isEmpty) {
              _nameController.text = '${currentWorkout.name}';
            }
          });
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              _createFromCurrentWorkout
                  ? AppIcons.checkCircle
                  : AppIcons.workout,
              color: _createFromCurrentWorkout
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usa workout attuale',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${currentWorkout.exercises.length} esercizi',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _createFromCurrentWorkout,
              onChanged: (value) {
                setState(() {
                  _createFromCurrentWorkout = value;
                  if (value && _nameController.text.isEmpty) {
                    _nameController.text = '${currentWorkout.name}';
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: TemplateType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != TemplateType.values.last ? 8 : 0,
            ),
            child: _buildTypeCard(type, isSelected),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeCard(TemplateType type, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: AppIconSize.large,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              type.getDisplayName(context),
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsSection(AppLocalizations l10n) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(dividerColor: context.colors.surface.withValues(alpha: 0)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        initiallyExpanded: _showAdvancedOptions,
        onExpansionChanged: (expanded) {
          setState(() => _showAdvancedOptions = expanded);
        },
        leading: Icon(
          AppIcons.settings,
          size: AppIconSize.small,
          color: context.colors.onSurfaceVariant,
        ),
        title: Text(
          l10n.advancedOptions,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          _showAdvancedOptions ? AppIcons.expandLess : AppIcons.expandMore,
          size: AppIconSize.small,
          color: context.colors.onSurfaceVariant,
        ),
        children: [
          // Descrizione
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.templateDescriptionOptional,
              hintText: l10n.templateDescriptionHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(AppIcons.note, size: AppIconSize.small),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Timer di default
          InkWell(
            onTap: _showDefaultRestTimePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.timer,
                    size: AppIconSize.medium,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.defaultRestTimer,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatRestTime(_defaultRestTime),
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.arrowForwardIos,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final templateId = const Uuid().v4();
      List<ExerciseTemplate> exerciseTemplates = [];
      // Sanitize name on submission (not during typing)
      String templateName = TemplateValidator.sanitizeTemplateName(
        _nameController.text,
      );

      if (_createFromCurrentWorkout) {
        final currentWorkout = ref.read(currentWorkoutProvider)!;
        // Sanitize the template name if using workout name
        templateName = _nameController.text.trim().isNotEmpty
            ? templateName
            : TemplateValidator.sanitizeTemplateName(currentWorkout.name);

        exerciseTemplates = currentWorkout.exercises.map((exercise) {
          // ✅ FIX: Use fromExercise() to properly preserve all fields including TUT
          return ExerciseTemplate.fromExercise(
            exercise,
          ).copyWith(restTime: _defaultRestTime);
        }).toList();
      }

      // Convert selected type to tag for backward compatibility
      final tags = _selectedType != null ? [_selectedType!.tag] : <String>[];

      // Get current user ID for Firestore security rules
      final userId = ref.read(currentUserIdProvider);

      final newTemplate = WorkoutTemplate(
        id: templateId,
        name: templateName,
        description: _descriptionController.text.trim(),
        exercises: exerciseTemplates,
        isCustom: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        imageUrl: null,
        usageCount: 0,
        userId: userId, // ✅ Required for Firestore security rules
      );

      await ref
          .read(workoutTemplateNotifierProvider.notifier)
          .saveTemplate(newTemplate);

      // Invalidate providers to refresh UI
      ref.invalidate(customWorkoutTemplatesProvider);

      // Feedback di successo
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.of(context).pop();

        // Show appropriate message based on whether template has exercises
        final isEmptyTemplate = exerciseTemplates.isEmpty;
        if (isEmptyTemplate) {
          SnackBarService.showInfo(
            context,
            'Template "$templateName" creato. Modifica per aggiungere esercizi.',
          );
        } else {
          SnackBarService.showSuccess(
            context,
            'Template "$templateName" creato!',
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        SnackBarService.showError(context, 'Errore: $e');
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
            _defaultRestTime = restTime ?? 90;
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
