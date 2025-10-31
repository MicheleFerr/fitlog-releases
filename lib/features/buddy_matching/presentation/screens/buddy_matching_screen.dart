/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: Via repository
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/providers/buddy_matching_provider.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/swipeable_buddy_card.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/buddy_action_buttons.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/buddy_filter_sheet.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/matches_preview_bar.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/empty_matches_view.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/widgets/location_permission_widget.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/screens/edit_buddy_profile_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class BuddyMatchingScreen extends ConsumerStatefulWidget {
  const BuddyMatchingScreen({super.key});

  @override
  ConsumerState<BuddyMatchingScreen> createState() => _BuddyMatchingScreenState();
}

class _BuddyMatchingScreenState extends ConsumerState<BuddyMatchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final matchingState = ref.watch(matchingProvider);
    final activeMatches = ref.watch(activeMatchesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // floatingActionButton: const DemoProfilesFab(),
      body: LocationPermissionWidget(
        child: SafeArea(
          child: Column(
          children: [
            // Header with filters and matches preview
            _buildHeader(context, theme, l10n),
            
            // Matches preview bar
            activeMatches.when(
              data: (matches) => matches.isNotEmpty
                  ? MatchesPreviewBar(matches: matches)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // Main content
            Expanded(
              child: _buildMainContent(context, theme, l10n, matchingState),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.buddyMatching,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  l10n.findYourWorkoutPartner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              // Filter button
              IconButton(
                onPressed: () => _showFilterSheet(context),
                icon: Icon(
                  Icons.tune,
                  color: theme.colorScheme.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Edit Profile button
              IconButton(
                onPressed: () => _navigateToEditProfile(context),
                icon: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Refresh button
              IconButton(
                onPressed: () => _refreshMatches(),
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    MatchingState state,
  ) {
    if (state.isLoading) {
      return _buildLoadingView(theme, l10n);
    }

    if (state.error != null) {
      return _buildErrorView(theme, l10n, state.error!);
    }

    if (!state.hasMatches) {
      return EmptyMatchesView(
        onRefresh: _refreshMatches,
        onSetupProfile: () => _navigateToPreferences(context),
      );
    }

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        
        // Card stack
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCardStack(context, theme, state),
          ),
        ),
        
        // Action buttons at bottom
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: BuddyActionButtons(
            onDislike: _handleDislike,
            onLike: _handleLike,
            onSuperLike: _handleSuperLike,
            isEnabled: state.currentMatch != null,
          ),
        ),
        
        // Celebration overlay
        AnimatedBuilder(
          animation: _celebrationAnimation,
          builder: (context, child) {
            if (_celebrationAnimation.value == 0) return const SizedBox.shrink();
            
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: context.colors.onSurface.withValues(alpha: 0.3 * _celebrationAnimation.value),
                  child: Center(
                    child: Transform.scale(
                      scale: _celebrationAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 48,
                              color: context.colors.surface,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.itsAMatch,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: context.colors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardStack(BuildContext context, ThemeData theme, MatchingState state) {
    final visibleCards = <Widget>[];
    
    // Show up to 3 cards in the stack
    for (int i = 0; i < 3 && (state.currentIndex + i) < state.potentialMatches.length; i++) {
      final profile = state.potentialMatches[state.currentIndex + i];
      final isTop = i == 0;
      
      visibleCards.add(
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, i * 8.0),
            child: Transform.scale(
              scale: 1 - (i * 0.05),
              child: SwipeableBuddyCard(
                profile: profile,
                isInteractable: isTop,
                onSwipe: isTop ? _handleCardSwipe : null,
                animationController: isTop ? _cardAnimationController : null,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: visibleCards.reversed.toList());
  }

  Widget _buildLoadingView(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchingForMatches,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, AppLocalizations l10n, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.oops,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshMatches,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _handleCardSwipe(SwipeDirection direction, String profileId) {
    HapticFeedback.lightImpact();
    
    switch (direction) {
      case SwipeDirection.left:
        _handleDislike();
        break;
      case SwipeDirection.right:
        _handleLike();
        break;
      case SwipeDirection.up:
        _handleSuperLike();
        break;
    }
  }

  void _handleDislike() async {
    HapticFeedback.lightImpact();
    await ref.read(matchingProvider.notifier).dislikeCurrentProfile();
  }

  void _handleLike() async {
    HapticFeedback.mediumImpact();
    final match = await ref.read(matchingProvider.notifier).likeCurrentProfile();
    
    if (match != null && match.isMutualMatch) {
      _showMatchCelebration();
    }
  }

  void _handleSuperLike() async {
    HapticFeedback.heavyImpact();
    // Super like implementation
    _handleLike();
  }

  void _showMatchCelebration() {
    _celebrationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _celebrationController.reverse();
      });
    });
  }

  void _refreshMatches() {
    HapticFeedback.lightImpact();
    ref.read(matchingProvider.notifier).refreshMatches();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BuddyFilterSheet(),
    );
  }

  void _navigateToPreferences(BuildContext context) {
    // Navigate to buddy preferences setup screen
    // This will be implemented in the onboarding flow
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditBuddyProfileScreen(),
      ),
    );
  }
}

enum SwipeDirection { left, right, up }