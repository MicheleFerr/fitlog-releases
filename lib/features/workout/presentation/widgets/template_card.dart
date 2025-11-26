import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Apple HIG compliant template card
///
/// Features:
/// - Clean white/gray background with subtle left accent strip
/// - iOS-style shadow for depth (blur 8, offset 0,2, opacity 0.1/0.15)
/// - Category-based accent strip (2pt → 4pt on press)
/// - WCAG AA compliant difficulty badges
/// - Micro-interactions (scale 0.98, haptic feedback, animated strip)
/// - Motor 1.0.1 smooth fade-in animation
/// - Exercise preview (max 3 exercises + +X)
/// - Metadata row (⏱️ duration, 🕐 last performed)
/// - 200px fixed height for ListView optimization
class TemplateCard extends ConsumerStatefulWidget {
  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
  });

  final WorkoutTemplate template;
  final VoidCallback? onTap;

  @override
  ConsumerState<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<TemplateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Motor 1.0.1 fade-in animation on mount
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // ~500ms smooth (Motor medium2)
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized, // Material 3 emphasized curve
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get strip color based on category
  Color _getStripColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.colors.error; // Red
      case TemplateCategory.cardio:
        return context.colors.primary; // Blue
      case TemplateCategory.flexibility:
        return context.colors.success; // Green
      case TemplateCategory.hybrid:
        return context.colors.tertiary; // Purple
    }
  }

  /// Check if this template is currently active
  /// Uses select() to only rebuild when the specific templateId changes
  bool get _isActiveWorkout {
    final activeTemplateId = ref.watch(
      currentWorkoutProvider.select((w) => w?.templateId),
    );
    return activeTemplateId == widget.template.id;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final category = widget.template.effectiveCategory;
    final difficulty = widget.template.effectiveDifficulty;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Enhanced gradient background for depth
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.surface,
                  context.colors.surfaceContainerLow.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16), // Consistent with elevated design
              // Enhanced shadow system for depth
              boxShadow: [
                // Primary shadow for depth
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: isDark ? 0.25 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
                // Secondary subtle shadow
                BoxShadow(
                  color: context.colors.onSurface.withValues(alpha: isDark ? 0.1 : 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              // Subtle border for definition
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Left accent strip (category color) with enhanced glow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  width: _isPressed ? 5 : 3,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getStripColor(category).withValues(
                          alpha: _isActiveWorkout ? 1.0 : 0.9,
                        ),
                        _getStripColor(category).withValues(
                          alpha: _isActiveWorkout ? 0.9 : 0.7,
                        ),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStripColor(category).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header: Title + Difficulty Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.template.name,
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _DifficultyBadge(difficulty: difficulty),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Exercise preview (clean text, no icons)
                      _ExercisePreview(template: widget.template),

                      const Spacer(),

                      // Footer: Metadata (⏱️ duration only, no stats yet)
                      _MetadataRow(
                        template: widget.template,
                        stats: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Difficulty badge with WCAG AA compliant semantic colors
class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({
    required this.difficulty,
  });

  final DifficultyLevel difficulty;

  /// Get background color (light container)
  Color _getBackgroundColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.successContainer;
      case DifficultyLevel.intermediate:
        return context.colors.warningContainer;
      case DifficultyLevel.advanced:
        return context.colors.errorContainer;
      case DifficultyLevel.expert:
        return context.colors.tertiaryContainer; // Purple for expert
    }
  }

  /// Get border color (saturated semantic)
  Color _getBorderColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.success;
      case DifficultyLevel.intermediate:
        return context.colors.warning;
      case DifficultyLevel.advanced:
        return context.colors.error;
      case DifficultyLevel.expert:
        return context.colors.tertiary; // Purple for expert
    }
  }

  /// Get text color (on container)
  Color _getTextColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.onSuccessContainer;
      case DifficultyLevel.intermediate:
        return context.colors.onWarningContainer;
      case DifficultyLevel.advanced:
        return context.colors.onErrorContainer;
      case DifficultyLevel.expert:
        return context.colors.onTertiaryContainer; // Purple text for expert
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12), // Capsule shape
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.localizedName(context),
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: _getTextColor(context),
        ),
      ),
    );
  }
}

/// Exercise preview (clean text: "Panca · Croci · Dips +3")
class _ExercisePreview extends StatelessWidget {
  const _ExercisePreview({required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    if (template.exercises.isEmpty) {
      return Text(
        context.l10n.noExercises,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Max 3 exercises with bullet separator
    final exerciseNames = template.exercises
        .take(3)
        .map((e) => e.exerciseName)
        .join(' · ');

    final remaining = template.exercises.length > 3
        ? ' +${template.exercises.length - 3}'
        : '';

    return Text(
      '$exerciseNames$remaining',
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Metadata row (⏱️ duration • last performed)
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.template,
    required this.stats,
  });

  final WorkoutTemplate template;
  final TemplateStats? stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ⏱️ Duration
        Icon(
          AppIcons.schedule,
          size: AppIconSize.small, // 20dp
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '${template.estimatedDuration} min',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Bullet separator (8pt spacing each side)
        if (stats != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: AppSpacing.xxs,
            height: AppSpacing.xxs,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // 🕐 Last performed
          Icon(
            AppIcons.history,
            size: AppIconSize.small,
            color: stats!.statusColor(context) ?? context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            stats!.formattedLastPerformed(context),
            style: context.textTheme.bodySmall?.copyWith(
              color: stats!.statusColor(context) ?? context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
