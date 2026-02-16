import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/recent_templates_carousel.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/todays_workout_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Welcome/empty state view displayed when no workout is active.
///
/// Redesigned as an intelligent launcher that shows:
/// - Prominent Quick Start CTA
/// - AI-suggested template for today
/// - Recently used templates (max 3)
///
/// Template management actions have been moved to the Templates tab.
class WelcomeView extends ConsumerWidget {
  const WelcomeView({
    required this.onQuickStart,
    required this.onStartTemplate,
    super.key,
  });

  /// Callback when the user taps the quick start button
  final VoidCallback onQuickStart;

  /// Callback when the user starts a workout from a template
  final void Function(WorkoutTemplate template) onStartTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Quick Start Card - Prominent CTA (2x size)
              _buildQuickStartCard(context),
              const SizedBox(height: AppSpacing.lg),

              // 2. Today's Workout Card - AI Suggestion
              TodaysWorkoutCard(
                onStartTemplate: onStartTemplate,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Recently Used Templates Section Header
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  context.l10n.recentlyUsed,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 4. Recently Used Templates Carousel
              RecentTemplatesCarousel(
                onStartTemplate: onStartTemplate,
              ),

              // Bottom padding to prevent overlap with bottom nav bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
            ]),
          ),
        ),
      ],
    );
  }

  /// Builds the prominent quick start card - Clean Apple-style CTA
  Widget _buildQuickStartCard(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        label: context.l10n.startNow,
        hint: context.l10n.startImmediately,
        button: true,
        child: InkWell(
          onTap: onQuickStart,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.primary,
                  HSLColor.fromColor(context.colors.primary)
                      .withLightness(
                        (HSLColor.fromColor(context.colors.primary).lightness -
                                0.08)
                            .clamp(0.0, 1.0),
                      )
                      .toColor(),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg, // Increased from md for prominence
              ),
              child: Row(
                children: [
                  // Clean icon container
                  Container(
                    width: 56, // Increased from 48
                    height: 56,
                    decoration: BoxDecoration(
                      color: context.colors.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SemanticIcon(
                      icon: AppIcons.flashOn,
                      semanticLabel: 'Start workout now',
                      size: AppIconSize.xlarge, // Increased from large
                      color: context.colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.startNow,
                          style: context.textTheme.headlineSmall?.copyWith(
                            // Increased from titleLarge
                            fontWeight: FontWeight.bold,
                            color: context.colors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.startImmediately,
                          style: context.textTheme.bodyMedium?.copyWith(
                            // Increased from bodySmall
                            color: context.colors.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Simple chevron
                  SemanticIcon(
                    icon: AppIcons.forwardIos,
                    semanticLabel: 'Start',
                    size: AppIconSize.medium, // Increased from small
                    color: context.colors.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
