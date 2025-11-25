import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Provider for template quota (used/max templates)
final templateQuotaProvider = FutureProvider.autoDispose<({int used, int max})>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return (used: 0, max: 5);

  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) return (used: 0, max: 5);

    final data = userDoc.data()!;
    final quotaData = data['templateQuota'] as Map<String, dynamic>?;

    if (quotaData == null) return (used: 0, max: 5);

    final used = quotaData['usedPrivateTemplates'] as int? ?? 0;
    final max = quotaData['maxPrivateTemplates'] as int? ?? 5;

    return (used: used, max: max);
  } catch (e) {
    debugPrint('❌ Error fetching template quota: $e');
    return (used: 0, max: 5);
  }
});

/// Debug logger for template carousel widget (TEMPORARY FOR DEBUGGING)
class _CarouselLogger {
  static const bool _enableDebugLogs = true; // TEMPORARY: Remove after fixing

  static void log(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🎠 CAROUSEL [$timestamp] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('❌ CAROUSEL_ERROR [$timestamp] $message${error != null ? ' - $error' : ''}');
    }
  }

  static void step(String step, String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('📍 CAROUSEL_STEP [$timestamp] $step: $message');
    }
  }
}

class TemplateCarousel extends ConsumerWidget {
  const TemplateCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _CarouselLogger.log('🚀 TemplateCarousel.build() called');

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    _CarouselLogger.log('Context and theme obtained');

    // LEGACY SYSTEM: Usa il repository legacy per templates utente
    _CarouselLogger.step('PROVIDER', 'Watching customWorkoutTemplatesProvider...');
    final userTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final quotaAsync = ref.watch(templateQuotaProvider);
    _CarouselLogger.step('PROVIDER', 'Provider state: ${userTemplatesAsync.runtimeType}');

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
        
        // Carousel Content
        SizedBox(
          height: 180,
          child: userTemplatesAsync.when(
            loading: () => _buildLoadingCarousel(colorScheme),
            error: (error, stackTrace) => _buildErrorState(theme, colorScheme, l10n, ref),
            data: (templates) => _buildTemplatesCarousel(context, ref, templates, theme, colorScheme, l10n),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingCarousel(ColorScheme colorScheme) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) => Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              color: colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorLoadingTemplates,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                _CarouselLogger.log('🔄 Retry button pressed - invalidating customWorkoutTemplatesProvider');
                // Invalidate the provider to reload templates
                ref.invalidate(customWorkoutTemplatesProvider);
                _CarouselLogger.log('✅ Provider invalidated');
              },
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
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(context, theme, colorScheme, l10n);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: templates.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, ref, template, theme, colorScheme, l10n);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.workout,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTemplatesYet,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.createFirstTemplate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTemplateSelected(context, ref, template),
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.8),
                  colorScheme.secondaryContainer.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.workout,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (template.difficulty != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                template.difficulty!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      SemanticIcon(
  icon: AppIcons.schedule,
  semanticLabel: 'Schedule',
  size: AppIconSize.tiny,
  color: colorScheme.onSurface.withValues(alpha: 0.7,
),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${_estimateTemplateDuration(template)} ${l10n.minutes}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.tiny,
  color: colorScheme.onSurface.withValues(alpha: 0.7,
),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.exercises.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
