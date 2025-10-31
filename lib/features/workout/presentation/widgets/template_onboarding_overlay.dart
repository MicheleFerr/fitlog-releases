/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/template_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class TemplateOnboardingOverlay extends ConsumerWidget {

  const TemplateOnboardingOverlay({
    super.key,
    required this.nameFieldKey,
    required this.descriptionFieldKey,
    required this.tagsKey,
    required this.timerKey,
  });
  final GlobalKey nameFieldKey;
  final GlobalKey descriptionFieldKey;
  final GlobalKey tagsKey;
  final GlobalKey timerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(templateOnboardingProvider);
    final localizations = AppLocalizations.of(context);

    if (!onboardingState.isActive) {
      return const SizedBox.shrink();
    }

    // Verifica che il targetKey sia pronto
    final targetKey = _getTargetKey(onboardingState.currentStep);
    if (targetKey.currentContext == null) {
      return const SizedBox.shrink();
    }

    return _OnboardingStep(
      currentStep: onboardingState.currentStep,
      targetKey: targetKey,
      title: _getTitle(localizations, onboardingState.currentStep),
      subtitle: _getSubtitle(localizations, onboardingState.currentStep),
      onNext: () => ref.read(templateOnboardingProvider.notifier).nextStep(),
      onSkip: () => ref.read(templateOnboardingProvider.notifier).skipOnboarding(),
      isLastStep: onboardingState.currentStep == 3,
    );
  }

  GlobalKey _getTargetKey(int step) {
    switch (step) {
      case 0:
        return nameFieldKey;
      case 1:
        return descriptionFieldKey;
      case 2:
        return tagsKey;
      case 3:
        return timerKey;
      default:
        return nameFieldKey;
    }
  }

  String _getTitle(AppLocalizations localizations, int step) {
    switch (step) {
      case 0:
        return localizations.templateOnboardingNameTitle;
      case 1:
        return localizations.templateOnboardingDescriptionTitle;
      case 2:
        return localizations.templateOnboardingTagsTitle;
      case 3:
        return localizations.templateOnboardingRestTimerTitle;
      default:
        return '';
    }
  }

  String? _getSubtitle(AppLocalizations localizations, int step) {
    switch (step) {
      case 1:
        return localizations.templateOnboardingDescriptionSubtitle;
      case 2:
        return localizations.templateOnboardingTagsSubtitle;
      case 3:
        return localizations.templateOnboardingRestTimerSubtitle;
      default:
        return null;
    }
  }
}

class _OnboardingStep extends StatelessWidget {

  const _OnboardingStep({
    required this.currentStep,
    required this.targetKey,
    required this.title,
    this.subtitle,
    required this.onNext,
    required this.onSkip,
    required this.isLastStep,
  });
  final int currentStep;
  final GlobalKey targetKey;
  final String title;
  final String? subtitle;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    // Verifica che il widget sia pronto
    final targetContext = targetKey.currentContext;
    if (targetContext == null) {
      return const SizedBox.shrink();
    }

    final renderObject = targetContext.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Custom paint per spotlight (deve coprire tutto lo schermo)
        // IgnorePointer per non bloccare gli eventi sul widget in focus
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightPainter(
                targetKey: targetKey,
                spotlightPadding: 8,
              ),
            ),
          ),
        ),

        // Content box (Positioned figlio diretto di Stack)
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context);

    // Get target position
    final targetContext = targetKey.currentContext;
    if (targetContext == null) {
      // Context non disponibile, non mostrare nulla
      return const SizedBox.shrink();
    }

    final renderObject = targetContext.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      // RenderObject non disponibile
      return const SizedBox.shrink();
    }

    final renderBox = renderObject as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    // Calculate content position (below the target)
    final contentTop = targetPosition.dy + targetSize.height + 20;
    final screenHeight = MediaQuery.of(context).size.height;
    const contentHeight = 200.0; // Estimated height

    // If not enough space below, show above
    final showAbove = contentTop + contentHeight > screenHeight - 50;
    final finalTop = showAbove
        ? targetPosition.dy - contentHeight - 20
        : contentTop;

    return Positioned(
      left: 16,
      right: 16,
      top: finalTop.clamp(80.0, screenHeight - contentHeight - 80),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.onSurface.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currentStep + 1}/4',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Skip button
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    localizations.templateOnboardingSkip,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            // Subtitle (if present)
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(
                  isLastStep
                      ? localizations.templateOnboardingGotIt
                      : localizations.templateOnboardingNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter per creare lo spotlight
class _SpotlightPainter extends CustomPainter {

  _SpotlightPainter({
    required this.targetKey,
    required this.spotlightPadding,
  });
  final GlobalKey targetKey;
  final double spotlightPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;

    final renderObject = targetContext.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final renderBox = renderObject as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    // Create spotlight rect
    final spotlightRect = Rect.fromLTWH(
      targetPosition.dx - spotlightPadding,
      targetPosition.dy - spotlightPadding,
      targetSize.width + (spotlightPadding * 2),
      targetSize.height + (spotlightPadding * 2),
    );

    // Draw overlay with spotlight cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          spotlightRect,
          const Radius.circular(8),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = context.colors.onSurface.withValues(alpha: 0.8),
    );

    // Draw spotlight border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        spotlightRect,
        const Radius.circular(8),
      ),
      Paint()
        ..color = context.colors.surface.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}