import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Provider for template quota (used/max templates)
final templateQuotaProvider = FutureProvider.autoDispose<({int used, int max})>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return (used: 0, max: 4);

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) return (used: 0, max: 4);

    final data = userDoc.data()!;
    final quotaData = data['templateQuota'] as Map<String, dynamic>?;

    if (quotaData == null) return (used: 0, max: 4);

    final used = quotaData['usedPrivateTemplates'] as int? ?? 0;
    final max = quotaData['maxPrivateTemplates'] as int? ?? 4;

    return (used: used, max: max);
  } catch (e) {
    debugPrint('❌ Error fetching template quota: $e');
    return (used: 0, max: 5);
  }
});

/// Helper class for responsive carousel dimensions
class _CarouselDimensions {
  const _CarouselDimensions({
    required this.cardWidth,
    required this.cardHeight,
    required this.padding,
    required this.iconSize,
    required this.iconContainerSize,
  });

  /// Creates responsive dimensions based on text scale factor
  factory _CarouselDimensions.fromContext(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scaleFactor = textScaler.scale(1.0);

    // Clamp scale factor to reasonable bounds (1.0 - 1.5x)
    final clampedScale = scaleFactor.clamp(1.0, 1.5);

    return _CarouselDimensions(
      cardWidth: 280 * clampedScale,
      cardHeight: 180 * clampedScale,
      padding: 20 * clampedScale,
      iconSize: 20 * clampedScale,
      iconContainerSize: 40 * clampedScale,
    );
  }

  final double cardWidth;
  final double cardHeight;
  final double padding;
  final double iconSize;
  final double iconContainerSize;
}

class TemplateCarousel extends ConsumerWidget {
  const TemplateCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Get responsive dimensions based on text scale
    final dimensions = _CarouselDimensions.fromContext(context);

    // Use ALL templates (predefined + custom) instead of just custom
    final allTemplatesAsync = ref.watch(allWorkoutTemplatesProvider);
    final quotaAsync = ref.watch(templateQuotaProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Quota Badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                l10n.yourTemplates,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              // Quota Badge
              quotaAsync.when(
                data: (quota) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quota.used >= quota.max - 1
                        ? colorScheme.error.withValues(alpha: 0.1)
                        : quota.used >= quota.max - 2
                            ? colorScheme.tertiary.withValues(alpha: 0.1)
                            : colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: quota.used >= quota.max - 1
                          ? colorScheme.error.withValues(alpha: 0.3)
                          : quota.used >= quota.max - 2
                              ? colorScheme.tertiary.withValues(alpha: 0.3)
                              : colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    l10n.templateQuotaUsed(quota.used, quota.max),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: quota.used >= quota.max - 1
                          ? colorScheme.error
                          : quota.used >= quota.max - 2
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToTemplates(context),
                icon: SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
  size: AppIconSize.tiny,
  color: colorScheme.primary,
),
                label: Text(
                  l10n.seeAll,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),

        // Carousel Content - height scales with text size
        SizedBox(
          height: dimensions.cardHeight,
          child: allTemplatesAsync.when(
            loading: () => _buildLoadingCarousel(context, dimensions),
            error: (error, stackTrace) => _buildErrorState(context, l10n, ref),
            data: (templates) => _buildTemplatesCarousel(context, ref, templates, l10n, dimensions),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingCarousel(BuildContext context, _CarouselDimensions dimensions) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) => Container(
        width: dimensions.cardWidth,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              color: context.colors.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorLoadingTemplates,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => ref.invalidate(allWorkoutTemplatesProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesCarousel(
    BuildContext context,
    WidgetRef ref,
    List<WorkoutTemplate> templates,
    AppLocalizations l10n,
    _CarouselDimensions dimensions,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: templates.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, ref, template, l10n, dimensions);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.workout,
              color: context.colors.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTemplatesYet,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.createFirstTemplate,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.goNamed('workout'),
              child: Text(l10n.createTemplate),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean, minimal template card - no gradients, solid colors
  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
    AppLocalizations l10n,
    _CarouselDimensions dimensions,
  ) {
    return Container(
      width: dimensions.cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onTemplateSelected(context, ref, template),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            padding: EdgeInsets.all(dimensions.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and title
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: dimensions.iconContainerSize,
                        height: dimensions.iconContainerSize,
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.workout,
                          color: context.colors.onPrimaryContainer,
                          size: dimensions.iconSize,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                template.name,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (template.difficulty != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                template.difficulty!,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom row with duration and exercise count
                Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.schedule,
                      semanticLabel: 'Schedule',
                      size: dimensions.iconSize,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '~${_estimateTemplateDuration(template)} ${l10n.minutes}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SemanticIcon(
                      icon: AppIcons.workout,
                      semanticLabel: 'Workout',
                      size: dimensions.iconSize,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.exercises.length}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTemplates(BuildContext context) {
    context.goNamed('workout');
  }

  void _onTemplateSelected(BuildContext context, WidgetRef ref, WorkoutTemplate template) {
    HapticFeedback.lightImpact();
    // Convert template to workout and start it
    ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);
    context.goNamed('workout');
  }

  int _estimateTemplateDuration(WorkoutTemplate template) {
    // Estimate ~8-10 minutes per exercise including rest
    final baseMinutes = template.exercises.length * 8;
    return baseMinutes.clamp(30, 90);
  }
}
