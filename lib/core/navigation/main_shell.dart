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
  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(currentWorkoutProvider);
    final currentIndex = widget.navigationShell.currentIndex;

    // Check if we should show mini-bar:
    // - Workout exists
    // - Workout is in progress or paused
    // - User is NOT on workout tab (index 1)
    final showMiniBar = workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused) &&
        currentIndex != 1;

    // TODO: Re-enable auto-pause feature
    // _handleAutoPause(currentIndex, workout);

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          // Mini-bar positioned above bottom nav
          if (showMiniBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 68, // 64pt nav + 4pt margin (compact)
              child: WorkoutMiniBar(workout: workout),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
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
                  ? context.colors.primary
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
        backgroundColor: context.colors.surface,
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
              color: context.colors.primary,
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
              color: context.colors.primary,
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
              color: context.colors.primary,
            ),
            label: context.l10n.profile,
            tooltip: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
