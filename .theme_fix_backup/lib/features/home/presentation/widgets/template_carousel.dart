import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
// UNIFIED SYSTEM IMPORT
import 'package:gymbro_flutter_new/shared/domain/entities/template_bridge.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/unified_template_repository.dart';

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

    // UNIFIED SYSTEM: Usa il repository unificato per templates utente
    _CarouselLogger.step('PROVIDER', 'Watching userTemplatesProvider...');
    final unifiedTemplatesAsync = ref.watch(userTemplatesProvider);
    _CarouselLogger.step('PROVIDER', 'Provider state: ${unifiedTemplatesAsync.runtimeType}');

    // Converti a formato legacy per compatibilità UI
    _CarouselLogger.step('CONVERSION', 'Converting unified templates to legacy format...');
    final userTemplatesAsync = unifiedTemplatesAsync.when(
      data: (unifiedTemplates) {
        _CarouselLogger.step('CONVERSION', 'Processing ${unifiedTemplates.length} unified templates');

        // Show both custom and predefined templates in the carousel
        final availableTemplates = unifiedTemplates.toList();
        _CarouselLogger.step('CONVERSION', 'Found ${availableTemplates.length} available templates');
        _CarouselLogger.step('CONVERSION', 'Template breakdown:');
        final customCount = unifiedTemplates.where((t) => t.isCustom).length;
        final predefinedCount = unifiedTemplates.where((t) => !t.isCustom).length;
        _CarouselLogger.step('CONVERSION', '  - Custom: $customCount');
        _CarouselLogger.step('CONVERSION', '  - Predefined: $predefinedCount');

        final limitedTemplates = availableTemplates.take(5).toList(); // Mostra solo i primi 5 nel carousel
        _CarouselLogger.step('CONVERSION', 'Limited to ${limitedTemplates.length} templates for carousel');

        final legacyTemplates = limitedTemplates
            .map((unified) {
              _CarouselLogger.step('CONVERSION', 'Converting template: ${unified.name}');
              return TemplateBridge.toLegacy(unified);
            })
            .toList();

        _CarouselLogger.step('CONVERSION', '✅ Successfully converted ${legacyTemplates.length} templates to legacy format');
        return AsyncValue.data(legacyTemplates);
      },
      loading: () {
        _CarouselLogger.step('PROVIDER', '⏳ Provider is in LOADING state');
        return const AsyncValue.loading();
      },
      error: (error, stack) {
        _CarouselLogger.error('💥 Provider is in ERROR state', error);
        _CarouselLogger.error('Error details: $error');
        _CarouselLogger.error('Stack trace: $stack');
        return AsyncValue.error(error, stack);
      },
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.yourTemplates,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateToTemplates(context),
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary,
                ),
                label: Text(
                  l10n.seeAll,
                  style: TextStyle(color: colorScheme.primary),
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
            error: (error, stackTrace) => _buildErrorState(colorScheme, l10n, ref),
            data: (templates) => _buildTemplatesCarousel(context, ref, templates, colorScheme, l10n),
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

  Widget _buildErrorState(ColorScheme colorScheme, AppLocalizations l10n, WidgetRef ref) {
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
              Icons.error_outline,
              color: colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorLoadingTemplates,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                _CarouselLogger.log('🔄 Retry button pressed - invalidating userTemplatesProvider');
                // Invalidate the correct provider for unified system
                ref.invalidate(userTemplatesProvider);
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
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(context, colorScheme, l10n);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: templates.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, ref, template, colorScheme, l10n);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, AppLocalizations l10n) {
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
              Icons.fitness_center,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTemplatesYet,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.createFirstTemplate,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
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
          child: Container(
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
                          Icons.fitness_center,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (template.difficulty != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                template.difficulty!,
                                style: TextStyle(
                                  fontSize: 12,
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
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${_estimateTemplateDuration(template)} ${l10n.minutes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.exercises.length}',
                        style: TextStyle(
                          fontSize: 12,
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