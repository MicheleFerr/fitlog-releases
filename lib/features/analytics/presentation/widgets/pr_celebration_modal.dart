import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// PR Celebration Modal Widget
///
/// Full-screen modal celebrating a personal record achievement with:
/// - Confetti animation
/// - PR details (exercise name, values, improvement %)
/// - Share and dismiss actions
/// - Haptic feedback
/// - Theme-aware design
/// - Localization support
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => PRCelebrationModal(
///     celebration: prCelebration,
///     onShare: () => _shareToSocial(),
///     onDismiss: () => Navigator.pop(context),
///   ),
/// );
/// ```
class PRCelebrationModal extends StatefulWidget {
  const PRCelebrationModal({
    required this.celebration,
    required this.onShare,
    required this.onDismiss,
    super.key,
  });

  final PRCelebration celebration;
  final VoidCallback onShare;
  final VoidCallback onDismiss;

  @override
  State<PRCelebrationModal> createState() => _PRCelebrationModalState();
}

class _PRCelebrationModalState extends State<PRCelebrationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale + fade animation for modal content
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start animations after modal build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final improvementPercentage = widget.celebration.improvementPercentage;
    final isSignificant = widget.celebration.isSignificantPR;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.achievement,
                        size: 48,
                        color: context.colors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      context.l10n.pr_celebration_title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Exercise name
                    if (widget.celebration.exerciseName != null)
                      Text(
                        widget.celebration.exerciseName!,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 24),

                    // PR details card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Previous value
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.pr_previous_value,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color:
                                      context.colors.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${widget.celebration.previousValue.toStringAsFixed(1)} kg',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Arrow indicator
                          Icon(
                            AppIcons.arrowDownward,
                            color: context.colors.primary,
                            size: 24,
                          ),

                          const SizedBox(height: 12),

                          // New value
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.pr_new_value,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color:
                                      context.colors.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${widget.celebration.newValue.toStringAsFixed(1)} kg',
                                style: context.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Improvement percentage badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSignificant
                                  ? context.colors.primary.withValues(alpha: 0.1)
                                  : context.colors.secondary
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.trendingUp,
                                  size: 20,
                                  color: isSignificant
                                      ? context.colors.primary
                                      : context.colors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${improvementPercentage.toStringAsFixed(1)}%',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSignificant
                                        ? context.colors.primary
                                        : context.colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        // Share button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onShare();
                            },
                            icon: const Icon(AppIcons.shareOutlined),
                            label: Text(context.l10n.share),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: context.colors.primary),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Continue button
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onDismiss();
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(context.l10n.continue_text),
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
}
