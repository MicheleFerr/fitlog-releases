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
class PersonalizedContentCard extends ConsumerWidget {
  const PersonalizedContentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;

    // Watch counts for display
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final customExercisesAsync = ref.watch(allCustomExercisesProvider);
    final entitlements = ref.watch(tierEntitlementsProvider);

    final templateCount = templatesAsync.valueOrNull?.length ?? 0;
    final exerciseCount = customExercisesAsync.valueOrNull?.length ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondaryContainer.withValues(alpha: 0.7),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: colorScheme.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openPersonalizedContent(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.secondary.withValues(alpha: 0.8),
                        colorScheme.secondary.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.2),
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
                            max: entitlements.maxCustomExercises,
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
    );
  }

  void _openPersonalizedContent(BuildContext context) {
    HapticFeedback.lightImpact();
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
    final colorScheme = context.colors;
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
