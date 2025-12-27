/// GymBro TrackLog - Flutter Fitness App
///
/// Level Info Modal - Explains the tier/level system
/// Shows current progress and tier requirements
///
/// Features:
/// - 80% default height with expand to 100% toggle
/// - All tier levels with XP requirements
/// - Current tier highlighted
/// - Progress visualization
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal that explains the level/tier progression system
class LevelInfoModal extends StatefulWidget {
  const LevelInfoModal({
    super.key,
    required this.currentXP,
    required this.currentTier,
  });

  final int currentXP;
  final UserTier currentTier;

  /// Shows the level info modal as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required int currentXP,
    required UserTier currentTier,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => LevelInfoModal(
        currentXP: currentXP,
        currentTier: currentTier,
      ),
    );
  }

  @override
  State<LevelInfoModal> createState() => _LevelInfoModalState();
}

class _LevelInfoModalState extends State<LevelInfoModal> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Default 80% height, expanded to 95%
    final height = _isExpanded
        ? context.screenHeight * 0.95
        : context.screenHeight * 0.80;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with handle bar and expand button
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current status card
                  _buildCurrentStatusCard(context),

                  const SizedBox(height: 24),

                  // Tier progression list
                  _buildTierList(context),

                  const SizedBox(height: 24),

                  // How to earn XP section
                  _buildHowToEarnSection(context),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row with expand button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SemanticIcon(
                  icon: AppIcons.achievement,
                  semanticLabel: context.l10n.levelInfo,
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.levelInfo,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.levelInfoSubtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Expand/collapse button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isExpanded = !_isExpanded);
                },
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: SemanticIcon(
                    icon: AppIcons.expand,
                    semanticLabel: _isExpanded
                        ? context.l10n.collapse
                        : context.l10n.expand,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                tooltip: _isExpanded
                    ? context.l10n.collapse
                    : context.l10n.expand,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context) {
    final nextTier = widget.currentTier.next;
    final progress = widget.currentTier.progressToNext(widget.currentXP);
    final xpToNext = nextTier != null
        ? nextTier.minXP - widget.currentXP
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.currentTier.color.withValues(alpha: 0.2),
            widget.currentTier.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.currentTier.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Current tier badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.currentTier.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: AppIcons.achievement,
                  semanticLabel: widget.currentTier.displayName,
                  size: AppIconSize.xlarge,
                  color: widget.currentTier.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tier name
          Text(
            widget.currentTier.displayName,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.currentTier.color,
            ),
          ),

          const SizedBox(height: 4),

          // XP display
          Text(
            '${widget.currentXP} XP',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),

          if (nextTier != null) ...[
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: context.colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.currentTier.color,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // XP to next tier
            Text(
              context.l10n.xpToNextTier(xpToNext, nextTier.displayName),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.maxTierReached,
              style: context.textTheme.bodyMedium?.copyWith(
                color: widget.currentTier.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTierList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.allTiers,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...UserTier.values.map((tier) => _buildTierItem(context, tier)),
      ],
    );
  }

  Widget _buildTierItem(BuildContext context, UserTier tier) {
    final isCurrentTier = tier == widget.currentTier;
    final isUnlocked = widget.currentXP >= tier.minXP;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTier
            ? tier.color.withValues(alpha: 0.1)
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTier
            ? Border.all(color: tier.color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Tier icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? tier.color.withValues(alpha: 0.2)
                  : context.colors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isUnlocked
                  ? SemanticIcon(
                      icon: AppIcons.achievement,
                      semanticLabel: tier.displayName,
                      size: AppIconSize.medium,
                      color: tier.color,
                    )
                  : SemanticIcon(
                      icon: AppIcons.lock,
                      semanticLabel: context.l10n.locked,
                      size: AppIconSize.medium,
                      color: context.colors.outline,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Tier info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tier.displayName,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? tier.color : context.colors.outline,
                      ),
                    ),
                    if (isCurrentTier) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tier.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.l10n.current,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  context.l10n.tierRequirement(tier.minXP),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Checkmark if unlocked
          if (isUnlocked)
            SemanticIcon(
              icon: AppIcons.complete,
              semanticLabel: context.l10n.unlocked,
              size: AppIconSize.medium,
              color: tier.color,
            ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.lightbulb,
                semanticLabel: context.l10n.howToEarnXP,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.howToEarnXP,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildEarnItem(
            context,
            icon: AppIcons.workout,
            title: context.l10n.earnXPWorkout,
            description: context.l10n.earnXPWorkoutDesc,
          ),
          const SizedBox(height: 8),
          _buildEarnItem(
            context,
            icon: AppIcons.streak,
            title: context.l10n.earnXPStreak,
            description: context.l10n.earnXPStreakDesc,
          ),
          const SizedBox(height: 8),
          _buildEarnItem(
            context,
            icon: AppIcons.achievement,
            title: context.l10n.earnXPAchievement,
            description: context.l10n.earnXPAchievementDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildEarnItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SemanticIcon(
            icon: icon,
            semanticLabel: title,
            size: AppIconSize.small,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
