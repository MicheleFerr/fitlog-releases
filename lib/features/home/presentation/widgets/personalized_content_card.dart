/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Personalized Content Card
/// Type: Widget
///
/// Compact card for accessing personalized templates and custom exercises.
/// Replaces the more complex templates carousel with a cleaner entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Compact card for personalized content access
///
/// Shows a simple entry point to manage:
/// - Custom workout templates
/// - Custom exercises/variants
///
/// Design: Elevated Card pattern following DESIGN_GUIDELINES.md
/// - Radial gradient (primaryContainer → secondaryContainer)
/// - Double shadow (primary tint + black)
/// - Border with white overlay
/// - Standard press feedback (0.98 scale, 150ms, light haptic)
class PersonalizedContentCard extends ConsumerStatefulWidget {
  const PersonalizedContentCard({super.key});

  @override
  ConsumerState<PersonalizedContentCard> createState() =>
      _PersonalizedContentCardState();
}

class _PersonalizedContentCardState
    extends ConsumerState<PersonalizedContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Standard feedback: 0.98 scale, 150ms (DESIGN_GUIDELINES.md)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    // Watch counts for display
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final customExercisesAsync = ref.watch(allCustomExercisesProvider);
    final entitlements = ref.watch(tierEntitlementsProvider);

    final templateCount = templatesAsync.valueOrNull?.length ?? 0;
    final exerciseCount = customExercisesAsync.valueOrNull?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GestureDetector(
        onTapDown: (_) {
          // Light haptic feedback - standard tier (DESIGN_GUIDELINES.md)
          HapticFeedback.lightImpact();
          _scaleController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          _openPersonalizedContent(context);
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 1.5,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer.withValues(alpha: 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Icon with gradient background
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              colorScheme.secondary.withValues(alpha: 0.9),
                              colorScheme.secondary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.secondary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: SemanticIcon(
                          icon: AppIcons.dashboard,
                          semanticLabel: context.l10n.myTemplates,
                          size: AppIconSize.medium,
                          color: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.myTemplates,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Stats row
                            Row(
                              children: [
                                _StatChip(
                                  icon: AppIcons.listAlt,
                                  count: templateCount,
                                  max: entitlements.maxTemplates,
                                  label: context.l10n.templates,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 12),
                                _StatChip(
                                  icon: AppIcons.workout,
                                  count: exerciseCount,
                                  max: entitlements.maxCustomSingleExercises,
                                  label: context.l10n.exercises,
                                  color: colorScheme.tertiary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow indicator
                      SemanticIcon(
                        icon: AppIcons.chevronRight,
                        semanticLabel: context.l10n.view,
                        size: AppIconSize.small,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
          },
        ),
      ),
    );
  }

  void _openPersonalizedContent(BuildContext context) {
    // Haptic feedback gestito da InteractiveElement (FeedbackTier.standard → light haptic)
    context.push('/templates');
  }
}

/// Small stat chip showing count/max
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.count,
    required this.max,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int count;
  final int max;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isUnlimited = max >= 999;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            isUnlimited ? '$count' : '$count/$max',
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
