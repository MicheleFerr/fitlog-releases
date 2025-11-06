import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_history_search_modal.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Secondary Actions widget for the optimized homepage
///
/// This widget provides quick access to secondary app features like:
/// - Analytics dashboard
/// - Settings and customization
/// - Workout templates
/// - Exercise database
/// - Community features
/// - Notifications center
///
/// Features:
/// - Clean Architecture compliance
/// - Full localization support
/// - Theme-aware colors and styling
/// - Responsive grid layout
/// - Performance optimized with const constructors
/// - Accessibility support
class SecondaryActions extends ConsumerWidget {
  const SecondaryActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.otherTools,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            // Optional "View All" button for future expansion
            // TextButton(
            //   onPressed: () => _showAllActions(context),
            //   child: Text(l10n.seeAll),
            // ),
          ],
        ),
        const SizedBox(height: 16),

        // Secondary Actions Grid
        _buildSecondaryActionsGrid(context, l10n, ref),
      ],
    );
  }

  Widget _buildSecondaryActionsGrid(
      BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final actions = _getSecondaryActions(context, l10n, ref);

    // Use a responsive layout - 3 columns on larger screens, 2 on smaller
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 3;
    final aspectRatio = screenWidth > 600 ? 1.2 : 1.0;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }

  List<Widget> _getSecondaryActions(
      BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return [
      // Analytics & Progress
      _SecondaryActionCard(
        icon: AppIcons.analyticsOutlined,
        activeIcon: AppIcons.analytics,
        title: l10n.analytics,
        subtitle: l10n.trackProgress,
        color: _SecondaryActionColors.analytics,
        onTap: () => context.goNamed('analytics'),
      ),

      // Settings & Customization
      _SecondaryActionCard(
        icon: AppIcons.settingsOutlined,
        activeIcon: AppIcons.settings,
        title: l10n.settings,
        subtitle: l10n.customizeApp,
        color: _SecondaryActionColors.settings,
        onTap: () => context.goNamed('settings'),
      ),


      // Exercise Database
      _SecondaryActionCard(
        icon: AppIcons.searchOutlined,
        activeIcon: AppIcons.search,
        title: l10n.exercises,
        subtitle: l10n.searchExercises,
        color: _SecondaryActionColors.exercises,
        onTap: () => _showExerciseOptions(context, ref),
      ),

      // Community Hub
      _SecondaryActionCard(
        icon: AppIcons.peopleOutline,
        activeIcon: AppIcons.people,
        title: l10n
            .community, // This key exists in the router but may need to be added to ARB
        subtitle: l10n.community, // Reusing community for now
        color: _SecondaryActionColors.community,
        onTap: () => context.goNamed('community'),
      ),

      // Workout History Database
      _SecondaryActionCard(
        icon: AppIcons.historyOutlined,
        activeIcon: AppIcons.history,
        title: l10n.history,
        subtitle: l10n.viewPastWorkouts,
        color: _SecondaryActionColors.history,
        onTap: () => context.pushNamed('workout-history'),
      ),

      // Notifications Center
      _SecondaryActionCard(
        icon: AppIcons.notificationsOutlined,
        activeIcon: AppIcons.notifications,
        title: l10n.notifications,
        subtitle: l10n.notifications, // Reusing for subtitle
        color: _SecondaryActionColors.notifications,
        onTap: () => _showNotifications(context),
      ),

      // Exercise Import Tool (developer/admin feature)
      _SecondaryActionCard(
        icon: AppIcons.fileUploadOutlined,
        activeIcon: AppIcons.fileUpload,
        title: l10n.importExercises,
        subtitle: l10n.loadFromJson,
        color: _SecondaryActionColors.import,
        onTap: () => context.goNamed('import-exercises'),
      ),
    ];
  }

  void _showExerciseOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(AppIcons.history),
                title: Text(l10n.exerciseHistory),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet

                  // Get user model
                  final userModel = ref.read(currentUserProvider).value;
                  if (userModel?.email == null || userModel!.email.isEmpty) {
                    // Handle case where user is not logged in or email is not available
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Utente non trovato.')));
                    }
                    return;
                  }
                  final userEmail = userModel.email;

                  // Fetch activities
                  final repository = ExerciseActivityRepository();
                  final activities =
                      await repository.getUserActivities(userEmail: userEmail);

                  // Show history modal
                  if (context.mounted) {
                    ExerciseHistorySearchModal.show(context, activities);
                  }
                },
              ),
              ListTile(
                leading: const Icon(AppIcons.search),
                title: Text(l10n.searchExercises),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  context.goNamed('exercises'); // The original action
                },
              ),
              ListTile(
                leading: const Icon(AppIcons.insights),
                title: Text(l10n.exerciseProgress),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  context.push('/exercise-progress');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeatureComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              AppIcons.construction,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$featureName coming soon!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              AppIcons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).notifications),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.notificationsOffOutlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noNotifications,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).notificationsDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Individual secondary action card with hover and press animations
class _SecondaryActionCard extends StatefulWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_SecondaryActionCard> createState() => _SecondaryActionCardState();
}

class _SecondaryActionCardState extends State<_SecondaryActionCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _bounceController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Scale animation for press effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutCubic,
    ));

    // Bounce animation for release
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Glow animation for premium effect
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutQuart,
    ));

    // Elevation animation
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
    _pressController.forward();
    _glowController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _glowController.reverse();

    // Trigger bounce animation
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _glowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _bounceAnimation, _glowAnimation, _elevationAnimation]),
      builder: (context, child) {
        final combinedScale = _scaleAnimation.value * _bounceAnimation.value;

        return Transform.scale(
          scale: combinedScale,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                // Glassmorphism background
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed
                      ? widget.color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                    spreadRadius: 1,
                  ),
                  // Glow effect when pressed
                  if (_isPressed) BoxShadow(
                    color: widget.color.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    offset: const Offset(0, 0),
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _isPressed ? 8 : 2,
                    sigmaY: _isPressed ? 8 : 2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.05),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with enhanced animation (NO rotation)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.all(_isPressed ? 6 : 4),
                            decoration: BoxDecoration(
                              color: _isPressed
                                  ? widget.color.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                _isPressed ? widget.activeIcon : widget.icon,
                                key: ValueKey(_isPressed),
                                color: _isPressed
                                    ? widget.color
                                    : colorScheme.onSurface.withValues(alpha: 0.8),
                                size: 28,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Title with enhanced styling
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _isPressed
                                  ? widget.color
                                  : colorScheme.onSurface,
                              letterSpacing: _isPressed ? 0.5 : 0.0,
                            ) ?? const TextStyle(),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Subtitle with smooth transition
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _isPressed
                                  ? colorScheme.onSurface.withValues(alpha: 0.8)
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                            ) ?? const TextStyle(),
                            child: Text(
                              widget.subtitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Color definitions for different secondary action categories
/// Using Material 3 color palette for consistency
class _SecondaryActionColors {
  static const Color analytics = Color(0xFF6750A4);     // Purple - data/insights
  static const Color settings = Color(0xFF625B71);      // Neutral - customization
  static const Color exercises = Color(0xFF6B5B73);     // Violet - exploration
  static const Color community = Color(0xFF006A6B);     // Teal - social/connection
  static const Color history = Color(0xFF8B5A3C);       // Brown - past/heritage
  static const Color notifications = Color(0xFF984061); // Rose - attention/alerts
  static const Color import = Color(0xFF006494);        // Blue - utility/technical
}
