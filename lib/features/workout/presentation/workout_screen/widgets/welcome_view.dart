import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart'
    as wt;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Key for SharedPreferences to track if swipe hint was shown
const _kSwipeHintShownKey = 'swipe_hint_shown_v1';

/// Welcome/empty state view displayed when no workout is active.
///
/// Features a prominent "Quick Start" card at the top that triggers
/// the context-gathering flow, followed by tabbed template lists
/// (custom and predefined templates).
class WelcomeView extends ConsumerWidget {
  const WelcomeView({
    required this.onQuickStart,
    required this.onStartTemplate,
    required this.onShareTemplate,
    required this.onDuplicateTemplate,
    required this.onEditTemplate,
    required this.onDeleteTemplate,
    required this.onCreateTemplate,
    this.onScheduleTemplate,
    this.onRefreshTemplate,
    this.onViewTemplate,
    super.key,
  });

  /// Callback when the user taps the quick start button
  final VoidCallback onQuickStart;

  /// Callback when the user starts a workout from a template
  final void Function(wt.WorkoutTemplate template) onStartTemplate;

  /// Callback when the user wants to share a template as PDF
  final void Function(wt.WorkoutTemplate template) onShareTemplate;

  /// Callback when the user wants to duplicate a template
  final void Function(wt.WorkoutTemplate template) onDuplicateTemplate;

  /// Callback when the user wants to edit a template
  final void Function(wt.WorkoutTemplate template) onEditTemplate;

  /// Callback when the user wants to delete a template
  final void Function(wt.WorkoutTemplate template) onDeleteTemplate;

  /// Callback when the user wants to create a new template
  final VoidCallback onCreateTemplate;

  /// Callback when the user wants to schedule a template (swipe right action)
  final void Function(wt.WorkoutTemplate template)? onScheduleTemplate;

  /// Callback when the user wants to refresh template from database (sync TUT)
  final void Function(wt.WorkoutTemplate template)? onRefreshTemplate;

  /// Callback when the user wants to view a template in presentation mode
  final void Function(wt.WorkoutTemplate template)? onViewTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Start Card - Most prominent (Elevated design with gradient)
            _buildQuickStartCard(context),
            const SizedBox(height: AppSpacing.md),

            // Quick Start e Template
            Expanded(child: _buildQuickStartList(context, ref)),
          ],
        ),
      ),
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
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Clean icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.flashOn,
                    semanticLabel: 'Start workout now',
                    size: AppIconSize.large,
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
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.startImmediately,
                        style: context.textTheme.bodySmall?.copyWith(
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
                  size: AppIconSize.small,
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

  /// Builds the template list (custom templates only - single view)
  Widget _buildQuickStartList(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - Clean text-only design with liquid glass effect
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.yourTemplates,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
        ),

        // Template List
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final customTemplatesAsync = ref.watch(
                customWorkoutTemplatesProvider,
              );

              return customTemplatesAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Center(
                  child: Text(
                    context.l10n.errorLoading(error.toString()),
                  ),
                ),
                data: (customTemplates) {
                  return _buildTemplateList(
                    context,
                    customTemplates,
                    isCustomTab: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds a template list for a single tab
  Widget _buildTemplateList(
    BuildContext context,
    List<wt.WorkoutTemplate> templates, {
    required bool isCustomTab,
  }) {
    if (templates.isEmpty) {
      return _buildEmptyTemplateState(context, isCustomTab);
    }

    // For custom tab, add +1 for the "Create New" card at the end
    final itemCount = isCustomTab ? templates.length + 1 : templates.length;

    // Use vertical ListView with SwipeableTemplateCard (iOS-style swipe actions)
    // Add bottom padding to prevent overlap with bottom navigation bar
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Last item in custom tab is the "Create New Template" card
        if (isCustomTab && index == templates.length) {
          return _buildCreateTemplateCard(context);
        }

        final template = templates[index];
        final card = SizedBox(
          height: 216, // 200px card + 16px margin
          child: SwipeableTemplateCard(
            key: ValueKey(template.id),
            template: template,
            onTap: () => onStartTemplate(template),
            onShare: () => onShareTemplate(template),
            onDuplicate: () => onDuplicateTemplate(template),
            onEdit: () => onEditTemplate(template),
            onDelete: () => onDeleteTemplate(template),
            onSchedule: onScheduleTemplate != null
                ? () => onScheduleTemplate!(template)
                : null,
            onRefresh: (onRefreshTemplate != null && template.isCustom)
                ? () => onRefreshTemplate!(template)
                : null,
            onView: onViewTemplate != null
                ? () => onViewTemplate!(template)
                : null,
          ),
        );

        // Show swipe hint animation only on first card
        if (index == 0) {
          return _SwipeHintWrapper(child: card);
        }
        return card;
      },
    );
  }

  /// Builds the "Create New Template" card shown at the end of custom templates
  Widget _buildCreateTemplateCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onCreateTemplate,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              color: context.colors.primaryContainer.withValues(alpha: 0.1),
            ),
            child: SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SemanticIcon(
                      icon: AppIcons.add,
                      semanticLabel: context.l10n.createNewTemplate,
                      size: AppIconSize.large,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.createNewTemplate,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.buildFromScratch,
                        style: context.textTheme.bodySmall?.copyWith(
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
      ),
    );
  }

  /// Builds the empty state when no templates are available
  Widget _buildEmptyTemplateState(BuildContext context, bool isCustomTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: isCustomTab ? AppIcons.noteAdd : AppIcons.inventory2Outlined,
            semanticLabel: isCustomTab
                ? 'No custom templates'
                : 'No predefined workouts',
            size: AppIconSize.xxlarge,
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isCustomTab
                ? context.l10n.noCustomTemplates
                : context.l10n.noPredefinedWorkouts,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isCustomTab
                ? context.l10n.createFirstTemplate
                : context.l10n.predefinedWorkoutsComingSoon,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
          if (isCustomTab) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreateTemplate,
              icon: SemanticIcon(
                icon: AppIcons.add,
                semanticLabel: context.l10n.createNewTemplate,
                size: AppIconSize.medium,
              ),
              label: Text(context.l10n.createNewTemplate),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget that wraps a child and shows a "peek" animation to hint swipe actions.
/// Only shows the animation once, then saves to SharedPreferences.
class _SwipeHintWrapper extends StatefulWidget {
  const _SwipeHintWrapper({required this.child});

  final Widget child;

  @override
  State<_SwipeHintWrapper> createState() => _SwipeHintWrapperState();
}

class _SwipeHintWrapperState extends State<_SwipeHintWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Peek animation: slide left slightly, then back
    _offsetAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.08, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.08, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _checkAndAnimate();
  }

  Future<void> _checkAndAnimate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShown = prefs.getBool(_kSwipeHintShownKey) ?? false;

      if (!hasShown && mounted) {
        setState(() => _shouldAnimate = true);
        // Delay before starting animation
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          await _controller.forward();
          // Mark as shown
          await prefs.setBool(_kSwipeHintShownKey, true);
        }
      }
    } catch (_) {
      // Ignore errors - hint is not critical
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldAnimate) {
      return widget.child;
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
