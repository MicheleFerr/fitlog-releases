import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              child: const Center(
                child: Text(
                  '\u{1F4AA}', // 💪 emoji
                  style: TextStyle(fontSize: 80),
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
              icon: AppIcons.exercise,
              text: context.l10n.initialOnboardingFeature1,
              backgroundColor: context.colors.primary,
            ),
            const SizedBox(height: 20),
            _FeatureItem(
              icon: AppIcons.tip,
              text: context.l10n.initialOnboardingFeature2,
              backgroundColor: context.colors.tertiary,
            ),
            const SizedBox(height: 20),
            _FeatureItem(
              icon: AppIcons.analytics,
              text: context.l10n.initialOnboardingFeature3,
              backgroundColor: context.colors.secondary,
            ),

            const Spacer(flex: 3),

            // CTA Button with gradient feel
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .nextStep();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.initialOnboardingStart,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      AppIcons.arrowForward,
                      size: 22,
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
    required this.icon,
    required this.text,
    required this.backgroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Colored circle background
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: backgroundColor, size: 26),
        ),
        const SizedBox(width: 20),
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
