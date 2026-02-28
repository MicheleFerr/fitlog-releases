import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/initial_onboarding_style.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 1: Welcome screen with Yazio-inspired design
class WelcomeStep extends ConsumerStatefulWidget {
  const WelcomeStep({super.key});

  @override
  ConsumerState<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends ConsumerState<WelcomeStep> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InitialOnboardingStyle.horizontalPadding,
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Large emoji/icon area
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.15),
                    context.colors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/splash_no_bkg.png',
                  width: 124,
                  height: 124,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Text('\u{1F4AA}', style: TextStyle(fontSize: 80)),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title
            Text(
              context.l10n.initialOnboardingWelcomeTitle,
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              context.l10n.initialOnboardingWelcomeSubtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.65),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 56),

            // Feature list with colored backgrounds
            _FeatureItem(
              assetPath: 'assets/images/welcome_track_workouts.png',
              fallbackIcon: AppIcons.exercise,
              text: context.l10n.initialOnboardingFeature1,
            ),
            const SizedBox(height: 20),
            _FeatureItem(
              assetPath: 'assets/images/welcome_advanced_analytics.png',
              fallbackIcon: AppIcons.analytics,
              text: context.l10n.initialOnboardingFeature3,
            ),

            const Spacer(flex: 3),

            // CTA Button with gradient feel
            // Accessibility: Semantic label for screen readers
            Semantics(
              label: context.l10n.initialOnboardingStart,
              button: true,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .nextStep();
                },
                style: InitialOnboardingStyle.primaryButtonStyle(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.initialOnboardingStart),
                    const SizedBox(width: 10),
                    Icon(
                      AppIcons.arrowForward,
                      size: 20,
                      color: context.colors.onPrimary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

/// Feature item with colored circle background
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.assetPath,
    required this.fallbackIcon,
    required this.text,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Custom onboarding image (no container/background)
        SizedBox(
          width: 76,
          height: 76,
          child: Center(
            child: Image.asset(
              assetPath,
              width: 68,
              height: 68,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, color: context.colors.primary, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
