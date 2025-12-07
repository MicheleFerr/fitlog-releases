/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/navigation
/// Feature: Main Shell with Bottom Navigation
/// Type: StatefulShellRoute Container
///
/// Provides persistent bottom navigation across 4 main branches
/// with state preservation using StatefulShellRoute pattern.
///
/// **Architecture**:
/// ```
/// MainShell (Scaffold)
///   ├── body: StatefulNavigationShell (preserves branch state)
///   └── bottomNavigationBar: NavigationBar (Material 3)
/// ```
///
/// **Branches**:
/// 1. Home (index 0) - Dashboard and quick actions
/// 2. Workout (index 1) - Active workout and templates
/// 3. Analytics (index 2) - Stats and progress
/// 4. Settings (index 3) - App configuration
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_mini_bar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
// TODO: Re-enable auto-pause feature after adding autoPauseOnNavigateAway to AppConfig
// import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Main shell widget containing bottom navigation and branch content
///
/// Uses [StatefulNavigationShell] to preserve branch state when switching tabs.
/// Implements Material 3 NavigationBar with animated transitions.
/// Shows WorkoutMiniBar when workout is active and user is not on workout tab.
class MainShell extends ConsumerStatefulWidget {
  /// Creates the main shell with navigation
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell containing branch content
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // Track if user has visited workout screen since workout started
  bool _hasVisitedWorkoutScreen = false;
  String? _lastWorkoutId;

  @override
  void initState() {
    super.initState();
    // Journey Themes now auto-initialize via Notifier.build()
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(currentWorkoutProvider);
    final currentIndex = widget.navigationShell.currentIndex;

    // Reset tracking if workout changed or ended
    if (workout?.id != _lastWorkoutId) {
      _hasVisitedWorkoutScreen = false;
      _lastWorkoutId = workout?.id;
    }

    // Mark as visited when user enters workout tab with active workout
    if (currentIndex == 1 && workout != null) {
      _hasVisitedWorkoutScreen = true;
    }

    // Check if we should show mini-bar:
    // - Workout exists
    // - Workout is in progress or paused
    // - User is NOT on workout tab (index 1)
    // - User has visited workout screen at least once (exited from it)
    final showMiniBar = workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused) &&
        currentIndex != 1 &&
        _hasVisitedWorkoutScreen;

    // TODO: Re-enable auto-pause feature
    // _handleAutoPause(currentIndex, workout);

    // Determine if we should render the mini-bar (for animation purposes)
    final shouldRenderMiniBar = workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused);

    return Scaffold(
      // ✨ Material 3 2025: Subtle background veil instead of pure white
      backgroundColor: context.colors.surfaceContainer,
      body: widget.navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini-bar with slide up/down animation
          // Background matches scaffold to avoid color bleed from nav bar
          ColoredBox(
            color: context.colors.surfaceContainer,
            child: ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: shouldRenderMiniBar && showMiniBar
                    ? WorkoutMiniBar(
                        workout: workout,
                        onDiscard: () => _showDiscardConfirmation(context),
                        onSave: () => _showSaveConfirmation(context),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          _BottomNavigationBar(
            currentIndex: currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
          ),
        ],
      ),
    );
  }

  // TODO: Re-enable auto-pause feature after adding autoPauseOnNavigateAway to AppConfig
  // void _handleAutoPause(int currentIndex, Workout? workout) { ... }

  /// Handle destination selection with branch switching
  void _onDestinationSelected(BuildContext context, int index) {
    // Haptic feedback on tab change
    HapticFeedback.lightImpact();

    // Navigate to selected branch
    // goBranch preserves the state of the previous branch
    widget.navigationShell.goBranch(
      index,
      // If same branch, go to initial location (pop to root)
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Show confirmation dialog before discarding workout
  /// Returns true if user confirmed discard, false if canceled
  Future<bool> _showDiscardConfirmation(BuildContext context) async {
    unawaited(HapticFeedback.mediumImpact());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.discardWorkoutTitle),
        content: Text(context.l10n.discardWorkoutQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.discard),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear workout and navigate to home
      ref.read(currentWorkoutProvider.notifier).clearWorkout();
      context.go('/');
      return true;
    }

    return false;
  }

  /// Show confirmation dialog before saving workout
  /// Returns true if user confirmed save, false if canceled
  Future<bool> _showSaveConfirmation(BuildContext context) async {
    unawaited(HapticFeedback.mediumImpact());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.save),
        content: Text(context.l10n.saveWorkoutQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.primary,
            ),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Pause workout to save state
      ref.read(currentWorkoutProvider.notifier).pauseWorkout();

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.workoutSaved),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    }

    return false;
  }
}

/// Material 3 NavigationBar with 3 destinations
/// Redesigned: Home, Workout, Profile (Analytics/Settings moved to Profile hub)
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return context.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (context.journeyTheme?.primaryColor ?? context.colors.primary)
                  : context.colors.onSurfaceVariant,
            );
          }),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        // Material 3 styling - iOS standard 64px height
        elevation: 0,
        // ✨ Material 3 2025: Slightly elevated surface for depth
        backgroundColor: context.colors.surfaceContainerLow,
        indicatorColor: Colors.transparent, // No indicator background
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 200),
        destinations: [
          // Home - outlined icon, color change on selection
          NavigationDestination(
            icon: Icon(
              AppIcons.homeOutlined,
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              AppIcons.homeOutlined,
              size: AppIconSize.medium,
              color: context.journeyTheme?.primaryColor ?? context.colors.primary,
            ),
            label: context.l10n.home,
            tooltip: context.l10n.home,
          ),
          // Workout - outlined icon, color change on selection
          NavigationDestination(
            icon: Icon(
              AppIcons.workoutOutlined,
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              AppIcons.workoutOutlined,
              size: AppIconSize.medium,
              color: context.journeyTheme?.primaryColor ?? context.colors.primary,
            ),
            label: context.l10n.workout,
            tooltip: context.l10n.workout,
          ),
          // Profile - outlined icon, color change on selection
          NavigationDestination(
            icon: Icon(
              AppIcons.profileOutlined,
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              AppIcons.profileOutlined,
              size: AppIconSize.medium,
              color: context.journeyTheme?.primaryColor ?? context.colors.primary,
            ),
            label: context.l10n.profile,
            tooltip: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
