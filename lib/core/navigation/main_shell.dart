/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/navigation
/// Feature: Main Shell with Bottom Navigation
/// Type: StatefulShellRoute Container
///
/// Provides persistent bottom navigation across main branches
/// with state preservation using StatefulShellRoute pattern.
///
/// **Architecture**:
/// ```
/// MainShell (Scaffold, extendBody: true)
///   └── body: Stack
///         ├── MediaQuery(adjustedPadding) → NavigationShell
///         ├── WorkoutMiniBar (if active, above nav bar)
///         ├── _NativeIOSTabBar (iOS: CNTabBar Liquid Glass)
///         └── _FloatingBottomNavBar (Android: custom floating bar)
/// ```
///
/// **Branches**:
/// 1. Home (index 0) - Dashboard and quick actions
/// 2. Workout (index 1) - Active workout and templates
/// 3. Profile (index 2) - App configuration
/// 4. AI Coach (index 3) - AI-powered coaching (feature flag)
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/config/feature_flags.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_sync_listener.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/registry/hint_registry.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/discoverability_hint_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/hint_peek.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_mini_bar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// iOS CNTabBar approximate content height (native intrinsic ~49pt)
const _kIOSTabBarHeight = 49.0;

/// Android floating nav bar height
const _kAndroidNavBarHeight = 48.0;

/// Android floating nav bar bottom margin from safe area
const _kAndroidNavBarBottomMargin = 10.0;

/// Android floating nav bar horizontal margin
const _kAndroidNavBarHorizontalMargin = 24.0;

/// Global key for bottom navigation bar - used by home tour
final bottomNavKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

/// Main shell widget containing bottom navigation and branch content
///
/// Uses [StatefulNavigationShell] to preserve branch state when switching tabs.
/// On iOS: native CNTabBar (Liquid Glass) via cupertino_native package.
/// On Android: custom floating bottom nav bar with backdrop blur.
/// Shows WorkoutMiniBar when workout is active and user is not on workout tab.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // Track if user has visited workout screen since workout started
  bool _hasVisitedWorkoutScreen = false;
  String? _lastWorkoutId;

  // Track previous tab index for auto-pause feature
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(currentWorkoutProvider);
    final currentIndex = widget.navigationShell.currentIndex;
    final isIOS = Platform.isIOS;
    final bottomSafeArea = MediaQuery.of(context).viewPadding.bottom;

    // Reset tracking if workout changed or ended
    if (workout?.id != _lastWorkoutId) {
      _hasVisitedWorkoutScreen = false;
      _lastWorkoutId = workout?.id;
    }

    // Mark as visited when user enters workout tab with active workout
    if (currentIndex == 1 && workout != null) {
      _hasVisitedWorkoutScreen = true;
    }

    // Handle auto-pause/resume when navigating between tabs
    _handleAutoPause(currentIndex, workout);

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

    // Calculate total nav bar height (content + safe area)
    final navBarTotalHeight = isIOS
        ? _kIOSTabBarHeight + bottomSafeArea
        : _kAndroidNavBarHeight + _kAndroidNavBarBottomMargin + bottomSafeArea;

    // Inject adjusted MediaQuery so scroll views add bottom inset for nav bar.
    // IMPORTANT: Zero out viewInsets.bottom because MainShell's Scaffold already
    // handles keyboard resize via resizeToAvoidBottomInset. Preserving viewInsets
    // would cause child Scaffolds to double-resize, creating a black gap.
    final existingMediaQuery = MediaQuery.of(context);
    final keyboardVisible = existingMediaQuery.viewInsets.bottom > 0;
    final adjustedMediaQuery = existingMediaQuery.copyWith(
      padding: existingMediaQuery.padding.copyWith(
        // When keyboard covers the nav bar, no need for extra bottom padding
        bottom: keyboardVisible ? 0 : navBarTotalHeight,
      ),
      viewInsets: existingMediaQuery.viewInsets.copyWith(
        bottom: 0, // MainShell Scaffold handles this
      ),
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ExerciseSyncListener(
        child: Stack(
          children: [
            // Main content with adjusted bottom padding via MediaQuery
            MediaQuery(
              data: adjustedMediaQuery,
              child: widget.navigationShell,
            ),

            // Floating mini-bar positioned just above nav bar
            if (showMiniBar)
              Positioned(
                left: 0,
                right: 0,
                bottom: navBarTotalHeight - 4,
                child: _buildMiniBar(workout!, context),
              ),

            // Bottom navigation bar - hidden when a bottom sheet is open
            ValueListenableBuilder<int>(
              valueListenable: ModalService.openSheetCount,
              builder: (context, sheetCount, child) {
                final isHidden = sheetCount > 0;
                if (isIOS) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      offset: Offset(0, isHidden ? 1.0 : 0.0),
                      child: _NativeIOSTabBar(
                        navKey: ref.watch(bottomNavKeyProvider),
                        currentIndex: currentIndex,
                        onTap: (index) => _onDestinationSelected(context, index),
                      ),
                    ),
                  );
                }
                return Positioned(
                  left: _kAndroidNavBarHorizontalMargin,
                  right: _kAndroidNavBarHorizontalMargin,
                  bottom: _kAndroidNavBarBottomMargin + bottomSafeArea,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    offset: Offset(0, isHidden ? 2.0 : 0.0),
                    child: _FloatingBottomNavBar(
                      navKey: ref.watch(bottomNavKeyProvider),
                      currentIndex: currentIndex,
                      onTap: (index) => _onDestinationSelected(context, index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build mini bar with optional HintPeek wrapper
  Widget _buildMiniBar(Workout workout, BuildContext context) {
    final miniBar = WorkoutMiniBar(
      workout: workout,
      onDiscard: () => _showDiscardConfirmation(context),
      onSave: () => _showSaveConfirmation(context),
    );

    final showHint = ref.watch(
      shouldShowHintProvider(HintRegistry.swipeMiniBar.hintId),
    );
    if (showHint) {
      return HintPeek(
        hint: HintRegistry.swipeMiniBar,
        child: miniBar,
      );
    }
    return miniBar;
  }

  /// Handle auto-pause/resume when navigating between tabs
  ///
  /// When user leaves workout tab (index 1) with active workout -> auto-pause
  /// When user returns to workout tab with paused workout -> auto-resume
  void _handleAutoPause(int currentIndex, Workout? workout) {
    if (_previousIndex == null) {
      _previousIndex = currentIndex;
      return;
    }

    final config = ref.read(appConfigProvider);

    // Leaving workout tab -> auto-pause
    if (_previousIndex == 1 &&
        currentIndex != 1 &&
        config.autoPauseOnNavigateAway &&
        workout != null &&
        workout.status == WorkoutStatus.inProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWorkoutProvider.notifier).pauseWorkout();
      });
    }

    // Returning to workout tab -> auto-resume
    if (_previousIndex != 1 &&
        currentIndex == 1 &&
        config.autoPauseOnNavigateAway &&
        workout != null &&
        workout.status == WorkoutStatus.paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWorkoutProvider.notifier).resumeWorkout();
      });
    }

    _previousIndex = currentIndex;
  }

  /// Handle destination selection with branch switching
  void _onDestinationSelected(BuildContext context, int index) {
    HapticFeedback.lightImpact();

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Show confirmation dialog before discarding workout
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
      ref.read(currentWorkoutProvider.notifier).clearWorkout();
      return true;
    }

    return false;
  }

  /// Show confirmation dialog before saving workout
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
      ref.read(currentWorkoutProvider.notifier).pauseWorkout();

      SnackBarService.showSuccess(
        context,
        context.l10n.workoutSaved,
        duration: const Duration(seconds: 2),
      );
      return true;
    }

    return false;
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// iOS: Native CNTabBar (Liquid Glass)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Native iOS tab bar using CNTabBar from cupertino_native package.
/// Renders a real UITabBar with Liquid Glass appearance and SF Symbols.
class _NativeIOSTabBar extends StatelessWidget {
  const _NativeIOSTabBar({
    required this.currentIndex,
    required this.onTap,
    this.navKey,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlobalKey? navKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: navKey,
      width: double.infinity,
      child: CNTabBar(
        iconSize: 15,
        shrinkCentered: false,
        items: [
          CNTabBarItem(
            label: context.l10n.home,
            icon: const CNSymbol('house', size: 15, weight: CNSymbolWeight.light),
          ),
          CNTabBarItem(
            label: context.l10n.workout,
            icon: const CNSymbol('dumbbell', size: 15, weight: CNSymbolWeight.light),
          ),
          CNTabBarItem(
            label: context.l10n.profile,
            icon: const CNSymbol('person', size: 15, weight: CNSymbolWeight.light),
          ),
          if (FeatureFlags.aiCoachEnabled)
            CNTabBarItem(
              label: context.l10n.aiCoach,
              icon: const CNSymbol('brain.head.profile', size: 15, weight: CNSymbolWeight.light),
            ),
        ],
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Android: Floating Bottom Nav Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Custom floating bottom navigation bar for Android.
/// Uses ClipRRect + BackdropFilter for glassmorphic appearance.
class _FloatingBottomNavBar extends StatelessWidget {
  const _FloatingBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    this.navKey,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlobalKey? navKey;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItemData>[
      _NavItemData(AppIcons.homeOutlined, context.l10n.home),
      _NavItemData(AppIcons.workoutOutlined, context.l10n.workout),
      _NavItemData(AppIcons.profileOutlined, context.l10n.profile),
      if (FeatureFlags.aiCoachEnabled)
        _NavItemData(AppIcons.psychology, context.l10n.aiCoach),
    ];

    return ClipRRect(
      key: navKey,
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: _kAndroidNavBarHeight,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < items.length; i++)
                _FloatingNavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
