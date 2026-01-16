import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/equipment_selector.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/muscle_chip_selector.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/widgets/pattern_selector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Main form for creating/editing custom exercises with progressive disclosure.
///
/// Features:
/// - Progressive disclosure pattern (starts minimal, expands on demand)
/// - Pre-filled from base exercise when creating variant
/// - Name field required, rest optional/inherited
/// - Inline warning when modifying categorization
/// - Validation and error handling
///
/// Usage:
/// ```dart
/// // Create new custom exercise
/// final result = await CustomExerciseFormSheet.show(context);
///
/// // Create variant from base exercise
/// final result = await CustomExerciseFormSheet.show(
///   context,
///   baseExercise: exercise,
/// );
///
/// // Edit existing custom exercise
/// final result = await CustomExerciseFormSheet.show(
///   context,
///   existingCustom: customExercise,
/// );
/// ```
class CustomExerciseFormSheet extends ConsumerStatefulWidget {
  const CustomExerciseFormSheet({
    super.key,
    this.baseExercise,
    this.existingCustom,
    required this.onSave,
  });

  /// Base exercise when creating a variant
  final ExerciseDefinition? baseExercise;

  /// Existing custom exercise when editing
  final CustomExercise? existingCustom;

  /// Callback when save button is pressed
  final ValueChanged<CustomExercise> onSave;

  /// Show modal bottom sheet to create/edit custom exercise
  static Future<CustomExercise?> show(
    BuildContext context, {
    ExerciseDefinition? baseExercise,
    CustomExercise? existingCustom,
    required ValueChanged<CustomExercise> onSave,
  }) {
    return showModalBottomSheet<CustomExercise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomExerciseFormSheet(
        baseExercise: baseExercise,
        existingCustom: existingCustom,
        onSave: onSave,
      ),
    );
  }

  @override
  ConsumerState<CustomExerciseFormSheet> createState() =>
      _CustomExerciseFormSheetState();
}

class _CustomExerciseFormSheetState
    extends ConsumerState<CustomExerciseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  // Form state
  List<String> _focus = [];
  List<String> _muscoliSecondari = [];
  String _tipoEsercizio = 'Compound';
  MovementPattern? _pattern;
  String _attrezzatura = 'Bilanciere';

  // UI state
  bool _showSecondaryMuscles = false;

  @override
  void initState() {
    super.initState();
    _initializeFromBase();

    // Auto-focus name field after sheet animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// Initialize form state from base exercise or existing custom
  void _initializeFromBase() {
    if (widget.existingCustom != null) {
      // Editing existing custom exercise
      final custom = widget.existingCustom!;
      _nameController.text = custom.nome;
      _focus = List<String>.from(custom.focus);
      _muscoliSecondari = List<String>.from(custom.muscoliSecondari);
      _tipoEsercizio = custom.tipoEsercizio;
      _pattern = _parseMovementPattern(custom.patternMovimento);
      _attrezzatura = custom.attrezzatura;

      // Expand sections if they have values
      _showSecondaryMuscles = _muscoliSecondari.isNotEmpty;
    } else if (widget.baseExercise != null) {
      // Creating variant from base exercise
      final base = widget.baseExercise!;
      _nameController.text = '${base.nome} - Variante';
      _focus = List<String>.from(base.focus);
      _muscoliSecondari = List<String>.from(base.muscoliSecondari);
      _tipoEsercizio = base.tipoEsercizio;
      _pattern = _parseMovementPattern(base.patternMovimento);
      _attrezzatura = base.attrezzatura;
    } else {
      // Pure custom exercise - use defaults
      _pattern = MovementPattern.push;
    }
  }

  /// Parse movement pattern from string
  MovementPattern? _parseMovementPattern(String? patternStr) {
    if (patternStr == null) return null;
    final normalized = patternStr.toLowerCase();
    return MovementPattern.values.firstWhere(
      (p) => p.label.toLowerCase() == normalized,
      orElse: () => MovementPattern.push,
    );
  }

  /// Check if categorization has been modified from base
  bool get _hasModifiedCategorization {
    if (widget.baseExercise == null) return false;

    final base = widget.baseExercise!;
    final baseFocus = base.focus.toSet();
    final currentFocus = _focus.toSet();
    final basePattern = _parseMovementPattern(base.patternMovimento);

    return !baseFocus.containsAll(currentFocus) ||
        !currentFocus.containsAll(baseFocus) ||
        basePattern != _pattern;
  }

  /// Validate and save the form
  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      SnackBarService.showError(
        context,
        context.l10n.pleaseEnterValidData,
      );
      return;
    }

    if (_focus.isEmpty) {
      SnackBarService.showError(
        context,
        context.l10n.primaryMuscles,
      );
      return;
    }

    if (_pattern == null) {
      SnackBarService.showError(
        context,
        context.l10n.movementPattern,
      );
      return;
    }

    final customExercise = widget.existingCustom?.copyWith(
          nome: _nameController.text.trim(),
          focus: _focus,
          muscoliSecondari: _muscoliSecondari,
          tipoEsercizio: _tipoEsercizio,
          patternMovimento: _pattern!.label,
          attrezzatura: _attrezzatura,
          isModifiedFromBase: _hasModifiedCategorization,
        ) ??
        (widget.baseExercise != null
            ? CustomExercise.fromBase(
                baseExerciseId: widget.baseExercise!.id,
                nome: _nameController.text.trim(),
                focus: _focus,
                muscoliSecondari: _muscoliSecondari,
                tipoEsercizio: _tipoEsercizio,
                patternMovimento: _pattern!.label,
                attrezzatura: _attrezzatura,
                isModifiedFromBase: _hasModifiedCategorization,
              )
            : CustomExercise.createNew(
                nome: _nameController.text.trim(),
                focus: _focus,
                muscoliSecondari: _muscoliSecondari,
                tipoEsercizio: _tipoEsercizio,
                patternMovimento: _pattern!.label,
                attrezzatura: _attrezzatura,
              ));

    widget.onSave(customExercise);
    Navigator.pop(context, customExercise);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCustom != null;
    final isVariant = widget.baseExercise != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(isEditing, isVariant),

              // Scrollable form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        _buildNameField(),
                        const SizedBox(height: AppSpacing.lg),

                        // Base exercise info (if variant)
                        if (isVariant) ...[
                          _buildBaseExerciseInfo(),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Categorization section
                        _buildCategorizationSection(),

                        // Warning about categorization changes
                        if (_hasModifiedCategorization) ...[
                          const SizedBox(height: AppSpacing.md),
                          _buildCategorizationWarning(),
                        ],

                        // Bottom padding for safe area
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Save button at bottom
              _buildStickyActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isEditing, bool isVariant) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isEditing
                    ? context.l10n.editCustomExercise
                    : (isVariant
                        ? context.l10n.createVariant
                        : context.l10n.createCustomExercise),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: SemanticIcon(
                icon: AppIcons.close,
                semanticLabel: context.l10n.close,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      decoration: InputDecoration(
        labelText: '${context.l10n.exerciseName} *',
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.exerciseNameRequired;
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
    );
  }

  Widget _buildBaseExerciseInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.info,
            color: context.colors.primary,
            semanticLabel: 'Info',
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.basedOn,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs / 2),
                Text(
                  widget.baseExercise!.nome,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.category,
              size: 20,
              color: context.colors.primary,
              semanticLabel: 'Category',
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.categorization,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Primary muscles
        MuscleChipSelector(
          selectedMuscles: _focus,
          onSelectionChanged: (muscles) {
            setState(() {
              _focus = muscles;
            });
          },
          label: context.l10n.primaryMuscles,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Secondary muscles (expandable)
        _buildExpandableSection(
          title: context.l10n.secondaryMuscles,
          isExpanded: _showSecondaryMuscles,
          onToggle: () {
            setState(() {
              _showSecondaryMuscles = !_showSecondaryMuscles;
            });
          },
          child: MuscleChipSelector(
            selectedMuscles: _muscoliSecondari,
            onSelectionChanged: (muscles) {
              setState(() {
                _muscoliSecondari = muscles;
              });
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),

        // Exercise type (Compound/Isolation)
        Text(
          context.l10n.exerciseType,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<String>(
          segments: [
            ButtonSegment<String>(
              value: 'Compound',
              label: Text(context.l10n.compound),
            ),
            ButtonSegment<String>(
              value: 'Isolamento',
              label: Text(context.l10n.isolation),
            ),
          ],
          selected: {_tipoEsercizio},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _tipoEsercizio = newSelection.first;
            });
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Movement pattern
        PatternSelector(
          selectedPattern: _pattern,
          onPatternChanged: (pattern) {
            setState(() {
              _pattern = pattern;
            });
          },
          label: context.l10n.movementPattern,
        ),

        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),

        // Equipment with chips
        EquipmentSelector(
          selectedEquipment: _attrezzatura,
          onEquipmentChanged: (equipment) {
            setState(() {
              _attrezzatura = equipment;
            });
          },
          label: context.l10n.equipment,
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: isExpanded
                      ? AppIcons.expandLess
                      : AppIcons.expandMore,
                  semanticLabel: isExpanded ? 'Collapse' : 'Expand',
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ],
    );
  }

  Widget _buildCategorizationWarning() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.1),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemanticIcon(
            icon: AppIcons.warning,
            color: context.colors.warning,
            size: 20,
            semanticLabel: 'Warning',
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.categorizationWarning,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky action bar at bottom with Save button
  Widget _buildStickyActionBar() {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + bottomPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48, // Material Design 3 minimum touch target
        child: FilledButton.icon(
          onPressed: _handleSave,
          icon: SemanticIcon(
            icon: AppIcons.save,
            color: context.colors.onPrimary,
            semanticLabel: 'Save',
          ),
          label: Text(context.l10n.save),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
          ),
        ),
      ),
    );
  }
}
