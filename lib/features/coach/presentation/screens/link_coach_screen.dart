/// Link Coach Screen
///
/// Screen for athletes to enter a coach code and link to their coach.
/// Shows OTP-style input for the 6-character code.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/coach/domain/repositories/coach_repository.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Screen for athletes to link to a coach via code
class LinkCoachScreen extends ConsumerStatefulWidget {
  const LinkCoachScreen({super.key});

  @override
  ConsumerState<LinkCoachScreen> createState() => _LinkCoachScreenState();
}

class _LinkCoachScreenState extends ConsumerState<LinkCoachScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isValidating = false;
  CoachInfo? _foundCoach;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(title: Text(context.l10n.linkToCoach)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and description
              Text(
                context.l10n.enterCoachCode,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Il tuo PT ti avrà fornito un codice di 6 caratteri',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // OTP-style code input
              _buildCodeInput(context),
              const SizedBox(height: AppSpacing.xl),

              // Validation state
              if (_isValidating)
                const Center(child: LoadingIndicator())
              else if (_error != null)
                _buildErrorMessage(context)
              else if (_foundCoach != null)
                _buildCoachFoundCard(context),

              const Spacer(),

              // Action button
              _buildActionButton(context),
              const SizedBox(height: AppSpacing.md),

              // Skip option
              TextButton(
                onPressed: _skip,
                child: Text(context.l10n.noCodeSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.xs),
          child: SizedBox(
            width: 48,
            height: 56,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 1,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: context.colors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.error, width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
              onChanged: (value) => _onCodeChanged(index, value),
            ),
          ),
        );
      }),
    );
  }

  void _onCodeChanged(int index, String value) {
    // Clear any previous error
    if (_error != null) {
      setState(() {
        _error = null;
        _foundCoach = null;
      });
    }

    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }

    // Check if code is complete
    if (_currentCode.length == 6) {
      _validateCode();
    }
  }

  Future<void> _validateCode() async {
    if (_currentCode.length != 6) return;

    setState(() {
      _isValidating = true;
      _error = null;
      _foundCoach = null;
    });

    try {
      final coach = await ref.read(coachLookupProvider(_currentCode).future);

      setState(() {
        _isValidating = false;
        if (coach != null) {
          _foundCoach = coach;
        } else {
          _error = context.l10n.invalidCoachCode;
        }
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _error = e.toString();
      });
    }
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, color: context.colors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _error ?? context.l10n.invalidCoachCode,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachFoundCard(BuildContext context) {
    final coach = _foundCoach!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Coach avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.primary,
            child: Text(
              _getInitials(coach.coachName),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Coach info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.complete,
                      color: context.colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.coachFound,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  coach.coachName,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isEnabled = _foundCoach != null && !_isLoading;

    return FilledButton(
      onPressed: isEnabled ? _linkToCoach : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
      ),
      child: _isLoading
          ? LoadingIndicator(size: 24, color: context.colors.onPrimary)
          : Text(context.l10n.linkToCoach),
    );
  }

  Future<void> _linkToCoach() async {
    if (_foundCoach == null) return;

    setState(() => _isLoading = true);

    try {
      final id = await ref
          .read(athleteActionsProvider.notifier)
          .linkViaCode(_currentCode);

      if (mounted) {
        if (id != null) {
          SnackBarService.showSuccess(
            context,
            context.l10n.linkedToCoach(_foundCoach!.coachName),
          );
          Navigator.of(context).pop(true);
        } else {
          SnackBarService.showError(context, context.l10n.somethingWentWrong);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        SnackBarService.showError(
          context,
          errorMessage.isNotEmpty
              ? errorMessage
              : context.l10n.somethingWentWrong,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skip() {
    Navigator.of(context).pop(false);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
