import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 1: Welcome screen — premium minimal style with merge animation
/// Auto-advances after animations complete (no CTA button)
class WelcomeStep extends ConsumerStatefulWidget {
  const WelcomeStep({super.key});

  @override
  ConsumerState<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends ConsumerState<WelcomeStep> {
  @override
  void initState() {
    super.initState();
    // Auto-advance after all animations complete (~1750ms) + small pause
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) {
        ref.read(initialOnboardingNotifierProvider.notifier).nextStep();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final secondary = context.colors.secondary;
    final tertiary = context.colors.tertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Logo merge: 3 dots converging into icon ──────────────────────
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dot top-left
                _MergeDot(color: primary, dx: -52, dy: -52, delay: 0.ms),
                // Dot top-right
                _MergeDot(color: secondary, dx: 52, dy: -52, delay: 80.ms),
                // Dot bottom
                _MergeDot(color: tertiary, dx: 0, dy: 58, delay: 160.ms),

                // Central circle — appears as dots arrive
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primary.withValues(alpha: 0.18),
                        primary.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    AppIcons.exercise,
                    size: 48,
                    color: primary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 480.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      delay: 480.ms,
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                // Shimmer ring — pulse once after icon appears
                _GlowRing(color: primary),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            context.l10n.initialOnboardingWelcomeTitle,
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
              letterSpacing: -0.5,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 650.ms, duration: 450.ms)
              .slideY(
                begin: 0.18,
                end: 0,
                delay: 650.ms,
                duration: 450.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 14),

          // ── Subtitle ──────────────────────────────────────────────────────
          Text(
            context.l10n.initialOnboardingWelcomeSubtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.55),
              height: 1.55,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 820.ms, duration: 400.ms)
              .slideY(
                begin: 0.14,
                end: 0,
                delay: 820.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 52),

          // ── Feature pills ─────────────────────────────────────────────────
          _FeaturePill(
            icon: AppIcons.exercise,
            text: context.l10n.initialOnboardingFeature1,
            accentColor: primary,
            slideFromLeft: true,
            delay: 980.ms,
          ),
          const SizedBox(height: 14),
          _FeaturePill(
            icon: AppIcons.analytics,
            text: context.l10n.initialOnboardingFeature3,
            accentColor: secondary,
            slideFromLeft: false,
            delay: 1100.ms,
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ── Dot that flies in from offset and merges to center ─────────────────────
class _MergeDot extends StatelessWidget {
  const _MergeDot({
    required this.color,
    required this.dx,
    required this.dy,
    required this.delay,
  });

  final Color color;
  final double dx;
  final double dy;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset.zero,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 200.ms)
        // Start far out, converge to center
        .move(
          begin: Offset(dx, dy),
          end: Offset.zero,
          delay: delay,
          duration: 500.ms,
          curve: Curves.easeInOutCubic,
        )
        // Shrink as they merge
        .scale(
          begin: const Offset(1.4, 1.4),
          end: const Offset(0.0, 0.0),
          delay: (delay.inMilliseconds + 380).ms,
          duration: 200.ms,
          curve: Curves.easeIn,
        );
  }
}

// ── Glow ring that pulses once after icon appears ──────────────────────────
class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 300.ms)
        .then()
        .fadeOut(duration: 600.ms)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.35, 1.35),
          duration: 900.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Feature pill — slide alternato sinistra/destra ────────────────────────
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.text,
    required this.accentColor,
    required this.slideFromLeft,
    required this.delay,
  });

  final IconData icon;
  final String text;
  final Color accentColor;
  final bool slideFromLeft;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: context.colors.surfaceContainerLow,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 380.ms)
        .slideX(
          begin: slideFromLeft ? -0.12 : 0.12,
          end: 0,
          delay: delay,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
