/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Rep Zone Suggestion Card v2 - Expandable card with Hero animation
///
/// **UX Research**:
/// - Tap to expand for details + alternatives
/// - Hero animation for smooth expansion
/// - Compact state shows: zone badge, exercise name, short motivation
/// - Expanded state shows: full details, score, motivations, alternatives
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Expandable card for rep zone suggestions
class RepZoneSuggestionCard extends StatefulWidget {
  const RepZoneSuggestionCard({
    required this.suggestion,
    required this.onAdd,
    required this.onSkip,
    required this.onAlternativeSelected,
    this.isTop = false,
    super.key,
  });

  final RepZoneSuggestion suggestion;
  final VoidCallback onAdd;
  final VoidCallback onSkip;
  final void Function(AlternativeExercise alternative) onAlternativeSelected;
  final bool isTop;

  @override
  State<RepZoneSuggestionCard> createState() => _RepZoneSuggestionCardState();
}

class _RepZoneSuggestionCardState extends State<RepZoneSuggestionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final zoneColor = _getZoneColor(context, widget.suggestion.targetZone);

    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            // BUGFIX: Clip content to prevent overflow onto action buttons below
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: zoneColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow
                      .withValues(alpha: widget.isTop ? 0.15 : 0.08),
                  blurRadius: widget.isTop ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zone badge header (always visible)
                _buildHeader(context, zoneColor),

                // Exercise name (always visible)
                _buildExerciseName(context),

                // Compact info (visible when collapsed)
                if (!_isExpanded) _buildCompactInfo(context, zoneColor),

                // Expanded content (animated) - wrapped in Flexible to prevent overflow
                Flexible(
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: _buildExpandedContent(context, zoneColor),
                      ),
                    ),
                  ),
                ),

                // Tap hint or swipe hints
                _buildBottomHints(context, zoneColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color zoneColor) {
    final colorScheme = context.colors;
    final suggestion = widget.suggestion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: zoneColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          // Zone badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getZoneIcon(suggestion.targetZone),
              color: zoneColor,
              size: AppIconSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.targetZone.label.toUpperCase(),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  suggestion.targetZone.repRange,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Score badge (only when expanded)
          if (_isExpanded && suggestion.score > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: zoneColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${suggestion.score}/100',
                style: context.textTheme.labelSmall?.copyWith(
                  color: zoneColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Expand indicator
          Icon(
            _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        widget.suggestion.exerciseName,
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context, Color zoneColor) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final suggestion = widget.suggestion;

    // Get short motivation
    final shortMotivation = _getShortMotivation(context, suggestion);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Short motivation
          Text(
            shortMotivation,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          // Alternatives count + tap hint
          Row(
            children: [
              if (suggestion.alternatives.isNotEmpty) ...[
                Icon(
                  AppIcons.swapHoriz,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.alternativesCount(suggestion.alternatives.length),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                l10n.tapToExpand,
                style: context.textTheme.labelSmall?.copyWith(
                  color: zoneColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                AppIcons.expandMore,
                size: 18,
                color: zoneColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, Color zoneColor) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final suggestion = widget.suggestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),

        // Target template
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                AppIcons.assignment,
                size: AppIconSize.small,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.addTo(suggestion.targetTemplate),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // PERCHE section
        _buildMotivationsSection(context, zoneColor),

        // Volume recommendation
        _buildVolumeSection(context),

        // Alternatives section
        if (suggestion.alternatives.isNotEmpty)
          _buildAlternativesSection(context, zoneColor),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMotivationsSection(BuildContext context, Color zoneColor) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final suggestion = widget.suggestion;

    // Parse motivations into readable strings
    final technicalMotivations = <String>[];
    final userDataMotivations = <String>[];

    for (final motivation in suggestion.motivations) {
      final parsed = _parseMotivation(context, motivation);
      if (parsed != null) {
        if (_isTechnicalMotivation(motivation)) {
          technicalMotivations.add(parsed);
        } else {
          userDataMotivations.add(parsed);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: zoneColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: zoneColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: zoneColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.whyThisExercise,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: zoneColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Technical
            if (technicalMotivations.isNotEmpty) ...[
              Text(
                l10n.motivationTechnical,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...technicalMotivations.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: context.textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Text(
                          m,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // User data
            if (userDataMotivations.isNotEmpty) ...[
              Text(
                l10n.motivationYourData,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...userDataMotivations.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: context.textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Text(
                          m,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final suggestion = widget.suggestion;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _VolumeItem(
            icon: AppIcons.repeat,
            value: '${suggestion.recommendedSets}',
            label: l10n.sets,
          ),
          _VolumeItem(
            icon: AppIcons.fitnessCenter,
            value: '${suggestion.recommendedReps}',
            label: l10n.reps,
          ),
          _VolumeItem(
            icon: AppIcons.timer,
            value: '${suggestion.recommendedRestSeconds ~/ 60}:${(suggestion.recommendedRestSeconds % 60).toString().padLeft(2, '0')}',
            label: l10n.rest,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesSection(BuildContext context, Color zoneColor) {
    final l10n = context.l10n;
    final alternatives = widget.suggestion.alternatives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.alternatives,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              final alt = alternatives[index];
              return _AlternativeChip(
                alternative: alt,
                zoneColor: zoneColor,
                onTap: () => widget.onAlternativeSelected(alt),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomHints(BuildContext context, Color zoneColor) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.arrowBack,
                size: AppIconSize.small,
                color: colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.skip,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.error.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                l10n.add,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                AppIcons.arrowForward,
                size: AppIconSize.small,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getZoneColor(BuildContext context, RepZone zone) {
    final colorScheme = context.colors;
    switch (zone) {
      case RepZone.strength:
        return colorScheme.error;
      case RepZone.hypertrophy:
        return colorScheme.primary;
      case RepZone.endurance:
        return colorScheme.tertiary;
    }
  }

  IconData _getZoneIcon(RepZone zone) {
    switch (zone) {
      case RepZone.strength:
        return AppIcons.fitnessCenter;
      case RepZone.hypertrophy:
        return AppIcons.trendUp;
      case RepZone.endurance:
        return AppIcons.timer;
    }
  }

  String _getShortMotivation(BuildContext context, RepZoneSuggestion suggestion) {
    final l10n = context.l10n;

    // Build short motivation from first motivation + zone info
    if (suggestion.motivations.isNotEmpty) {
      final first = suggestion.motivations.first;
      if (first.startsWith('compoundActivates:')) {
        final muscles = first.split(':')[1];
        return l10n.compoundActivatesShort(muscles);
      } else if (first.startsWith('isolationTargets:')) {
        final muscle = first.split(':')[1];
        return l10n.isolationTargetsShort(muscle);
      }
    }

    // Fallback to reason
    switch (suggestion.reasonKey) {
      case 'zoneEmpty':
        return l10n.repZoneReasonEmpty(suggestion.targetZone.label);
      case 'zoneNeglected':
        return l10n.repZoneReasonNeglected(suggestion.targetZone.label);
      default:
        return l10n.repZoneReasonBalance(suggestion.targetZone.label);
    }
  }

  bool _isTechnicalMotivation(String motivation) {
    return motivation.startsWith('compound') ||
        motivation.startsWith('isolation') ||
        motivation.startsWith('movementPattern') ||
        motivation.startsWith('naturalRepRange');
  }

  String? _parseMotivation(BuildContext context, String motivation) {
    final l10n = context.l10n;
    final parts = motivation.split(':');
    final key = parts[0];

    switch (key) {
      case 'compoundActivates':
        if (parts.length > 1) {
          return l10n.compoundActivates(parts[1]);
        }
        return null;
      case 'isolationTargets':
        if (parts.length > 1) {
          return l10n.isolationTargets(parts[1]);
        }
        return null;
      case 'movementPattern':
        if (parts.length > 1) {
          return l10n.movementPatternIs(parts[1]);
        }
        return null;
      case 'naturalRepRange':
        if (parts.length > 1) {
          return l10n.naturalRepRange(parts[1]);
        }
        return null;
      case 'zonePercentLast30Days':
        if (parts.length > 2) {
          return l10n.zonePercentLast30Days(parts[1], parts[2]);
        }
        return null;
      case 'notDoneSinceDays':
        if (parts.length > 1) {
          return l10n.notDoneSinceDays(int.tryParse(parts[1]) ?? 0);
        }
        return null;
      case 'neverDone':
        return l10n.neverDoneExercise;
      case 'equipmentAlreadyOwned':
        if (parts.length > 1) {
          return l10n.equipmentAlreadyOwned(parts[1]);
        }
        return null;
      default:
        return null;
    }
  }
}

/// Volume item widget
class _VolumeItem extends StatelessWidget {
  const _VolumeItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Column(
      children: [
        Icon(icon, size: AppIconSize.small, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Alternative exercise chip
class _AlternativeChip extends StatelessWidget {
  const _AlternativeChip({
    required this.alternative,
    required this.zoneColor,
    required this.onTap,
  });

  final AlternativeExercise alternative;
  final Color zoneColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alternative.exerciseName,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              alternative.shortReason,
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${alternative.score}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  AppIcons.swapHoriz,
                  size: 18,
                  color: zoneColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
