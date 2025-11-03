import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class VotingCard extends StatefulWidget {

  const VotingCard({
    super.key,
    required this.contribution,
    required this.onUpvote,
    required this.onDownvote,
    this.onComment,
    this.onTap,
    this.currentUserId,
    this.showActions = true,
  });
  final CommunityContribution contribution;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onComment;
  final VoidCallback? onTap; // Tap per aprire detail modal
  final String? currentUserId; // Per tracking stato voto
  final bool showActions;

  @override
  State<VotingCard> createState() => _VotingCardState();
}

class _VotingCardState extends State<VotingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  IconData _getTypeIcon() {
    switch (widget.contribution.type) {
      case ContributionType.tip:
        return Icons.lightbulb;
      case ContributionType.warning:
        return AppIcons.warningAmberRounded;
      case ContributionType.correction:
        return AppIcons.editNote;
      case ContributionType.technique:
        return Icons.fitness_center;
      case ContributionType.variant:
        return Icons.alt_route;
      case ContributionType.translation:
        return AppIcons.translate;
    }
  }
  
  Color _getTypeColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.contribution.type) {
      case ContributionType.tip:
        return context.colors.warning;
      case ContributionType.warning:
        return context.colors.secondary;
      case ContributionType.correction:
        return theme.colorScheme.primary;
      case ContributionType.technique:
        return context.colors.primary;
      case ContributionType.variant:
        return context.colors.tertiary;
      case ContributionType.translation:
        return context.colors.success;
    }
  }
  
  String _getTypeLabel() {
    switch (widget.contribution.type) {
      case ContributionType.tip:
        return 'Consiglio';
      case ContributionType.warning:
        return 'Avviso';
      case ContributionType.correction:
        return 'Correzione';
      case ContributionType.technique:
        return 'Tecnica';
      case ContributionType.variant:
        return 'Variante';
      case ContributionType.translation:
        return 'Traduzione';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(context);

    // Check user vote status
    final hasUpvoted = widget.currentUserId != null &&
        widget.contribution.upvotedBy.contains(widget.currentUserId);
    final hasDownvoted = widget.currentUserId != null &&
        widget.contribution.downvotedBy.contains(widget.currentUserId);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: context.colors.onSurface.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and user info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withValues(alpha: 0.1),
                        typeColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Type icon with animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 2 * math.pi,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getTypeIcon(),
                                color: typeColor,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getTypeLabel(),
                                    style: TextStyle(
                                      color: typeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (widget.contribution.isFeatured)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          context.colors.warning,
                                          context.colors.secondary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 10,
                                          color: context.colors.surface,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Featured',
                                          style: TextStyle(
                                            color: context.colors.surface,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.contribution.exerciseName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trust score indicator
                      if (widget.contribution.trustScore > 0)
                        _TrustScoreIndicator(
                          score: widget.contribution.trustScore,
                        ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.contribution.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Description
                      Text(
                        widget.contribution.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      
                      // Original vs Suggested (if correction)
                      if (widget.contribution.originalValue != null &&
                          widget.contribution.suggestedValue != null) ...[
                        SizedBox(height: 16),
                        _DiffDisplay(
                          original: widget.contribution.originalValue!,
                          suggested: widget.contribution.suggestedValue!,
                        ),
                      ],
                      
                      SizedBox(height: 16),
                      
                      // User info and timestamp
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              widget.contribution.userName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.contribution.userName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _formatTimeAgo(widget.contribution.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                if (widget.showActions) ...[
                  Divider(height: 1),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Upvote button
                        _VoteButton(
                          icon: Icons.thumb_up_outlined,
                          activeIcon: Icons.thumb_up,
                          count: widget.contribution.upvotes,
                          color: context.colors.success,
                          isActive: hasUpvoted,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onUpvote();
                          },
                        ),
                        SizedBox(width: 16),

                        // Downvote button
                        _VoteButton(
                          icon: Icons.thumb_down_outlined,
                          activeIcon: Icons.thumb_down,
                          count: widget.contribution.downvotes,
                          color: context.colors.error,
                          isActive: hasDownvoted,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onDownvote();
                          },
                        ),
                        
                        Spacer(),
                        
                        // Comment button
                        if (widget.onComment != null)
                          IconButton(
                            onPressed: widget.onComment,
                            icon: Badge(
                              label: Text(
                                widget.contribution.comments.length.toString(),
                              ),
                              isLabelVisible: widget.contribution.comments.isNotEmpty,
                              child: Icon(Icons.comment_outlined),
                            ),
                          ),
                        
                        // Share button
                        IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            // TODO: Implement share
                          },
                          icon: Icon(Icons.share_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} sett. fa';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m fa';
    } else {
      return 'ora';
    }
  }
}

class _VoteButton extends StatefulWidget {

  const _VoteButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final int count;
  final Color color;
  final bool isActive; // Stato voto dal parent
  final VoidCallback onTap;

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // Set initial state based on isActive
    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_VoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate quando isActive cambia
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isActive
              ? widget.color.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isActive
                ? widget.color.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (_controller.value * 0.2),
                  child: Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    size: 18,
                    color: widget.isActive
                        ? widget.color
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            SizedBox(width: 6),
            Text(
              widget.count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.isActive
                    ? widget.color
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffDisplay extends StatelessWidget {
  
  const _DiffDisplay({
    required this.original,
    required this.suggested,
  });
  final String original;
  final String suggested;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.error,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Prima',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            original,
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.success,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Dopo',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            suggested,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustScoreIndicator extends StatelessWidget {
  
  const _TrustScoreIndicator({required this.score});
  final int score;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(context);
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'Trust',
              style: TextStyle(
                fontSize: 8,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getScoreColor(BuildContext context) {
    if (score >= 80) return context.colors.success;
    if (score >= 60) return context.colors.primary;
    if (score >= 40) return context.colors.secondary;
    return context.colors.error;
  }
}