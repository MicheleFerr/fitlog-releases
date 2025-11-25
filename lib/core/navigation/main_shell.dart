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
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Main shell widget containing bottom navigation and branch content
///
/// Uses [StatefulNavigationShell] to preserve branch state when switching tabs.
/// Implements Material 3 NavigationBar with animated transitions.
class MainShell extends StatelessWidget {
  /// Creates the main shell with navigation
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell containing branch content
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
      ),
    );
  }

  /// Handle destination selection with branch switching
  void _onDestinationSelected(BuildContext context, int index) {
    // Haptic feedback on tab change
    HapticFeedback.lightImpact();

    // Navigate to selected branch
    // goBranch preserves the state of the previous branch
    navigationShell.goBranch(
      index,
      // If same branch, go to initial location (pop to root)
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Material 3 NavigationBar with 4 destinations
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      // Material 3 styling
      elevation: 0,
      backgroundColor: context.colors.surface,
      indicatorColor: context.colors.primaryContainer,
      surfaceTintColor: Colors.transparent,
      height: 80,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      animationDuration: const Duration(milliseconds: 200),
      destinations: [
        // Home
        NavigationDestination(
          icon: Icon(
            AppIcons.home,
            size: AppIconSize.medium,
            color: context.colors.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            AppIcons.home,
            size: AppIconSize.medium,
            color: context.colors.onPrimaryContainer,
          ),
          label: context.l10n.home,
          tooltip: context.l10n.home,
        ),
        // Workout
        NavigationDestination(
          icon: Icon(
            AppIcons.workout,
            size: AppIconSize.medium,
            color: context.colors.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            AppIcons.workout,
            size: AppIconSize.medium,
            color: context.colors.onPrimaryContainer,
          ),
          label: context.l10n.workout,
          tooltip: context.l10n.workout,
        ),
        // Analytics
        NavigationDestination(
          icon: Icon(
            AppIcons.analytics,
            size: AppIconSize.medium,
            color: context.colors.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            AppIcons.analytics,
            size: AppIconSize.medium,
            color: context.colors.onPrimaryContainer,
          ),
          label: context.l10n.analytics,
          tooltip: context.l10n.analytics,
        ),
        // Settings
        NavigationDestination(
          icon: Icon(
            AppIcons.settings,
            size: AppIconSize.medium,
            color: context.colors.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            AppIcons.settings,
            size: AppIconSize.medium,
            color: context.colors.onPrimaryContainer,
          ),
          label: context.l10n.settings,
          tooltip: context.l10n.settings,
        ),
      ],
    );
  }
}
