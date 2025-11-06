/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/screens/buddy_matching_screen.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/buddy_profile_details.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/fitness_level_badge.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/workout_goals_chips.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/instagram_link_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class SwipeableBuddyCard extends StatefulWidget {

  const SwipeableBuddyCard({
    super.key,
    required this.profile,
    this.isInteractable = true,
    this.onSwipe,
    this.animationController,
  });
  final BuddyProfile profile;
  final bool isInteractable;
  final Function(SwipeDirection direction, String profileId)? onSwipe;
  final AnimationController? animationController;

  @override
  State<SwipeableBuddyCard> createState() => _SwipeableBuddyCardState();
}

class _SwipeableBuddyCardState extends State<SwipeableBuddyCard>
    with TickerProviderStateMixin {
  double _dragDistance = 0;
  double _dragAngle = 0;
  bool _isDragging = false;
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Transform.translate(
            offset: Offset(_dragDistance * 0.7, 0),
            child: Transform.rotate(
              angle: _dragAngle * 0.1,
              child: _buildCard(context, theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onPanStart: widget.isInteractable ? _onPanStart : null,
      onPanUpdate: widget.isInteractable ? _onPanUpdate : null,
      onPanEnd: widget.isInteractable ? _onPanEnd : null,
      onTap: () => _showProfileDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image and header
                    _buildProfileHeader(context, theme),
                    
                    // Profile info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildProfileInfo(context, theme),
                      ),
                    ),
                  ],
                ),
                
                // Swipe indicators
                if (_isDragging) _buildSwipeIndicator(context, theme),
                
                // Action hint overlay
                if (!_isDragging && widget.isInteractable)
                  _buildActionHint(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Profile photo placeholder or image
          if (widget.profile.photoURL != null)
            Positioned.fill(
              child: Image.network(
                widget.profile.photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildProfilePlaceholder(theme),
              ),
            )
          else
            _buildProfilePlaceholder(theme),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.colors.onSurface.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          
          // Basic info overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.profile.displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: context.colors.surface,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: context.colors.onSurface.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.profile.isVerified)
                            const Icon(
                              Icons.verified,
                              color: context.colors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          FitnessLevelBadge(
                            level: widget.profile.preferences.fitnessLevel,
                            compact: true,
                          ),
                          const SizedBox(width: 8),
                          if (widget.profile.preferences.locationName != null)
                            Flexible(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: context.colors.onSurface.withValues(alpha: 0.7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.profile.preferences.locationName!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: context.colors.onSurface.withValues(alpha: 0.7),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Online status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.profile.isOnline 
                        ? context.colors.success 
                        : widget.profile.isRecentlyActive 
                            ? context.colors.secondary 
                            : context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.surface, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          AppIcons.person,
          size: 64,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workout goals
        if (widget.profile.preferences.goals.isNotEmpty) ...[
          Text(
            l10n.workoutGoals,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          WorkoutGoalsChips(
            goals: widget.profile.preferences.goals,
            compact: true,
          ),
          const SizedBox(height: 16),
        ],
        
        // Bio
        if (widget.profile.preferences.bio != null && 
            widget.profile.preferences.bio!.isNotEmpty) ...[
          Text(
            l10n.about,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.profile.preferences.bio!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
        ],
        
        // Stats row
        Row(
          children: [
            _buildStatChip(
              context,
              theme,
              AppIcons.workout,
              '${widget.profile.totalWorkouts}',
              l10n.workouts,
            ),
            const SizedBox(width: 12),
            _buildStatChip(
              context,
              theme,
              AppIcons.handshake,
              '${widget.profile.partnershipsCount}',
              l10n.partnerships,
            ),
            const SizedBox(width: 12),
            if (widget.profile.averageRating > 0)
              _buildStatChip(
                context,
                theme,
                AppIcons.star,
                widget.profile.averageRating.toStringAsFixed(1),
                l10n.rating,
              ),
          ],
        ),
        
        const Spacer(),
        
        // Instagram link and action hint
        Row(
          children: [
            if (widget.profile.preferences.instagramHandle != null)
              Expanded(
                child: InstagramLinkButton(
                  handle: widget.profile.preferences.instagramHandle!,
                ),
              ),
            
            const Spacer(),
            
            Text(
              l10n.tapToViewMore,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator(BuildContext context, ThemeData theme) {
    final opacity = (_dragDistance.abs() / 100).clamp(0.0, 1.0);
    
    if (_dragDistance > 30) {
      // Like indicator (right swipe)
      return Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.success.withValues(alpha: 0.2 * opacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.success, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIKE',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (_dragDistance < -30) {
      // Dislike indicator (left swipe)
      return Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.error.withValues(alpha: 0.2 * opacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.error, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PASS',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildActionHint(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.onSurface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.swipeToDecide,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.colors.surface,
          ),
        ),
      ),
    );
  }

  // Event handlers
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _bounceController.forward();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
      _dragAngle = _dragDistance / 300;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _bounceController.reverse();
    
    const threshold = 100.0;
    
    if (_dragDistance > threshold) {
      // Right swipe - Like
      widget.onSwipe?.call(SwipeDirection.right, widget.profile.uid);
    } else if (_dragDistance < -threshold) {
      // Left swipe - Dislike
      widget.onSwipe?.call(SwipeDirection.left, widget.profile.uid);
    } else {
      // Snap back
      setState(() {
        _dragDistance = 0;
        _dragAngle = 0;
      });
    }
  }

  void _showProfileDetails(BuildContext context) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuddyProfileDetails(profile: widget.profile),
    );
  }
}
