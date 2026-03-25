/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Personalized Content Card
/// Type: Widget
///
/// Two side-by-side tiles for accessing templates and custom exercises.
/// Uses consistent outline style matching other home cards.
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
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Two side-by-side tiles for personalized content access
///
/// - Left tile: "Library" (primary) → /templates
/// - Right tile: "Esercizi custom" (tertiary) → /templates?tab=1
class PersonalizedContentCard extends ConsumerWidget {
  const PersonalizedContentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;

    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);
    final customExercisesAsync = ref.watch(allCustomExercisesProvider);
    final entitlements = ref.watch(tierEntitlementsProvider);

    final templateCount =
        templatesAsync.value?.where((template) => template.isEditable).length ??
        0;
    final exerciseCount = customExercisesAsync.value?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              // Left tile: Templates
              Expanded(
                child: _ContentTile(
                  icon: AppIcons.listAlt,
                  title: context.l10n.libraryTab,
                  count: templateCount,
                  max: entitlements.maxLibraryTemplates,
                  color: colorScheme.primary,
                  onTap: () => context.push('/templates'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Right tile: Custom exercises
              Expanded(
                child: _ContentTile(
                  icon: AppIcons.workout,
                  title: context.l10n.customExercises,
                  count: exerciseCount,
                  max: entitlements.maxCustomSingleExercises,
                  color: colorScheme.tertiary,
                  onTap: () => context.push('/templates?tab=1'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: AppIcons.public,
                  label: context.l10n.storeTab,
                  onTap: () => context.push('/templates?tab=2'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionButton(
                  icon: AppIcons.qrCode,
                  label: context.l10n.useCode,
                  onTap: () => context.push('/templates?tab=2&action=useCode'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _ContentTile extends StatefulWidget {
  const _ContentTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.max,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final int max;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ContentTile> createState() => _ContentTileState();
}

class _ContentTileState extends State<_ContentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlimited = widget.max >= 999;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: 0.12),
                    widget.color.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, size: 20, color: widget.color),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    widget.title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Counter
                  Text(
                    isUnlimited
                        ? '${widget.count}'
                        : '${widget.count}/${widget.max}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
