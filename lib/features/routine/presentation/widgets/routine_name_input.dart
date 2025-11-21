/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget (form input)
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE NAME INPUT WIDGET - Text Input with Validation
///
/// Features:
/// - Text input field for routine name
/// - Validation (required, max length 50 chars)
/// - Theme-aware styling
/// - Material 3 design system compliance
/// - Clear button when text is present
/// - Used in RoutineCreationStep1Screen
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Routine Name Input - Text field with validation for routine names
class RoutineNameInput extends StatefulWidget {
  const RoutineNameInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.autofocus = false,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Auto-focus on field when widget is built
  final bool autofocus;

  @override
  State<RoutineNameInput> createState() => _RoutineNameInputState();
}

class _RoutineNameInputState extends State<RoutineNameInput> {
  /// Max length for routine name
  static const int maxLength = 50;

  /// Whether to show clear button
  bool get _showClearButton => widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes to rebuild for clear button
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
    widget.onChanged?.call(widget.controller.text);
  }

  void _clearText() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  /// Validate routine name
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.routineNameRequired;
    }

    if (value.trim().length > maxLength) {
      return context.l10n.routineNameTooLong;
    }

    return null; // Valid
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      maxLength: maxLength,
      validator: _validateName,
      decoration: InputDecoration(
        labelText: context.l10n.routineName,
        hintText: context.l10n.enterRoutineName,
        prefixIcon: Icon(
          Icons.fitness_center,
          color: context.colors.primary,
        ),
        suffixIcon: _showClearButton
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: context.colors.onSurfaceVariant,
                ),
                onPressed: _clearText,
                tooltip: context.l10n.clear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: context.colors.surfaceContainerHighest,
      ),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
    );
  }
}
