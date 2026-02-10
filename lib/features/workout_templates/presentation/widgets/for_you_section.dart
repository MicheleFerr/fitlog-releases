/// "Per Te" hero section - Smart template recommendations
///
/// UX Research Base:
/// - Reduces decision fatigue for Marco (beginner persona)
/// - Shows contextually relevant templates based on user tier
/// - Netflix-style personalization without complexity
///
/// Logic:
/// 1. Starter tier → Beginner/Express templates (non-intimidating)
/// 2. Bronze/Silver → Home/Express/Intermediate (growth path)
/// 3. Gold/Platinum → Intermediate/Advanced/Specialty (challenge seekers)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';

/// Hero section showing personalized template recommendations
///
/// Features:
/// - Prominent "Per te" header with gradient icon
/// - Horizontal scroll of 3 recommended templates
/// - Cards with category colors and clear CTAs
/// - Tier-based recommendation logic
class ForYouSection extends ConsumerWidget {
  const ForYouSection({
    super.key,
    required this.allTemplates,
    required this.onTemplateUse,
    required this.onTemplatePreview,
  });

  /// All available templates to filter recommendations from
  final List<WorkoutTemplate> allTemplates;

  /// Callback when user taps "Use" on a template
  final void Function(WorkoutTemplate) onTemplateUse;

  /// Callback when user taps on a template card to preview
  final void Function(WorkoutTemplate) onTemplatePreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userTier = ref.watch(userTierProvider);

    // Get recommended templates based on user tier
    final recommendations = _getRecommendations(userTier, allTemplates);

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  AppIcons.autoAwesome,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.forYou,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.recommendedForYourLevel,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Horizontal scroll of recommended cards (max 3)
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final template = recommendations[index];
              return _ForYouCard(
                template: template,
                onUse: () => onTemplateUse(template),
                onPreview: () => onTemplatePreview(template),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  /// Get recommended templates based on user tier
  ///
  /// Recommendation logic:
  /// - Starter: Express + Beginner (quick wins, non-intimidating)
  /// - Bronze/Silver: Home + Express + Intermediate (growth path)
  /// - Gold/Platinum: Intermediate + Advanced + Specialty (challenge)
  List<WorkoutTemplate> _getRecommendations(
    UserTier tier,
    List<WorkoutTemplate> templates,
  ) {
    final List<String> targetCategories;

    switch (tier) {
      case UserTier.starter:
        targetCategories = ['express', 'beginner'];
      case UserTier.bronze:
      case UserTier.silver:
        targetCategories = ['home', 'express', 'intermediate'];
      case UserTier.gold:
      case UserTier.platinum:
        targetCategories = ['intermediate', 'advanced', 'specialty'];
    }

    return templates
        .where((t) => targetCategories.contains(t.category))
        .take(3)
        .toList();
  }
}

/// Individual recommendation card
class _ForYouCard extends StatelessWidget {
  const _ForYouCard({
    required this.template,
    required this.onUse,
    required this.onPreview,
  });

  final WorkoutTemplate template;
  final VoidCallback onUse;
  final VoidCallback onPreview;

  /// Get color based on template category
  Color _getCategoryColor(BuildContext context, TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.colors.error;
      case TemplateCategory.cardio:
        return context.colors.primary;
      case TemplateCategory.flexibility:
        return context.colors.success;
      case TemplateCategory.hybrid:
        return context.colors.tertiary;
    }
  }

  /// Get icon based on template category
  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return AppIcons.workout;
      case TemplateCategory.cardio:
        return AppIcons.directionsRun;
      case TemplateCategory.flexibility:
        return AppIcons.flexibility;
      case TemplateCategory.hybrid:
        return AppIcons.fitnessCenter;
    }
  }

  /// Get localized category name
  String _getCategoryName(BuildContext context, TemplateCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case TemplateCategory.strength:
        return l10n.strength;
      case TemplateCategory.cardio:
        return l10n.cardio;
      case TemplateCategory.flexibility:
        return l10n.flexibility;
      case TemplateCategory.hybrid:
        return l10n.templateCategoryHybrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = template.effectiveCategory;
    final color = _getCategoryColor(context, category);
    final categoryIcon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(context, category);

    return GestureDetector(
      onTap: onPreview,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.surface,
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                categoryIcon,
                size: 80,
                color: color.withValues(alpha: 0.08),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          categoryName,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Template name
                  Text(
                    template.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Stats row
                  Row(
                    children: [
                      Icon(
                        AppIcons.workout,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.exercises.length} ${l10n.exercises}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        AppIcons.timer,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.estimatedDuration}\'',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Use button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onUse();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        l10n.startWorkout,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
