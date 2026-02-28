import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Shared UI tokens for initial onboarding screens.
///
/// Keeps spacing, button hierarchy and card treatment consistent
/// across all onboarding steps.
class InitialOnboardingStyle {
  InitialOnboardingStyle._();

  static const double horizontalPadding = 24;
  static const double topSpacing = 24;
  static const double cardRadius = 18;
  static const double cardPadding = 16;
  static const double optionSpacing = 14;
  static const double primaryButtonHeight = 56;

  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(primaryButtonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      elevation: 0,
      textStyle: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  static BoxDecoration optionCardDecoration(
    BuildContext context, {
    required bool selected,
  }) {
    return BoxDecoration(
      color: selected
          ? context.colors.primary.withValues(alpha: 0.08)
          : context.colors.surface,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: selected
            ? context.colors.primary
            : context.colors.outline.withValues(alpha: 0.24),
        width: selected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: selected ? 0.06 : 0.03),
          blurRadius: selected ? 14 : 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
