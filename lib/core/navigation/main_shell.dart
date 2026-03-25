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
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/hint_peek.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/hints/hint_micro_tip.dart'
    as discoverability_hints;
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_mini_bar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/quick_actions_overlay_content.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// iOS CNTabBar approximate content height (native intrinsic ~49pt)
const _kIOSTabBarHeight = 49.0;

/// `cupertino_native` tab bar visuals only match the intended Liquid Glass
/// design on iOS 26+.
const _kMinimumNativeIOSTabBarMajorVersion = 26;

/// Android floating nav bar height
const _kAndroidNavBarHeight = 48.0;

/// Android floating nav bar height in compact mode
const _kAndroidNavBarCompactHeight = 40.0;

/// Android floating nav bar height in dormant mode during workouts.
const _kAndroidNavBarDormantHeight = 32.0;

/// Android floating nav bar bottom margin from safe area
const _kAndroidNavBarBottomMargin = 10.0;

/// Android floating nav bar bottom margin in dormant mode.
const _kAndroidNavBarDormantBottomMargin = 8.0;

/// Android floating nav bar horizontal margin
const _kAndroidNavBarHorizontalMargin = 24.0;

/// Android floating nav bar horizontal margin in dormant mode.
const _kAndroidNavBarDormantHorizontalMargin = 56.0;

/// High-contrast accent for the center + button
const _kCenterButtonColor = Color(0xFF0A84FF);

/// Tab index of the center "+" button (not a real branch)
const _kPlusButtonTabIndex = 2;

/// Delay before auto-compacting nav bar after inactivity.
const _kNavBarCompactDelay = Duration(seconds: 5);

/// Delay before entering a more dormant nav bar state during workouts.
const _kNavBarDormantDelay = Duration(minutes: 5);

/// Duration for compact/expand nav bar transitions.
const _kNavBarCompactAnimationDuration = Duration(milliseconds: 500);

/// Global key for bottom navigation bar - used by home tour
final bottomNavKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

/// Signal provider: incremented when user taps the already-active tab.
/// Screens can watch this to scroll to top on same-tab tap.
final sameTabTapSignalProvider = NotifierProvider<_SameTabTapNotifier, int>(
  _SameTabTapNotifier.new,
);

class _SameTabTapNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void signal() => state = state + 1;
}

/// Main shell widget containing bottom navigation and branch content
///
/// Uses [StatefulNavigationShell] to preserve branch state when switching tabs.
/// On iOS: native CNTabBar (Liquid Glass) via cupertino_native package.
/// On Android: custom floating bottom nav bar with backdrop blur.
/// Shows WorkoutMiniBar when workout is active and user is not on workout tab.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  // Track if user has visited workout screen since workout started
  bool _hasVisitedWorkoutScreen = false;
  String? _lastWorkoutId;

  // Track previous tab index for auto-pause feature
  int? _previousIndex;

  // Guard against multiple quick actions overlay openings
  bool _isQuickActionsOpen = false;

  // Quick actions overlay animation (Stack-based, not dialog)
  late final AnimationController _overlayController;
  late final Animation<double> _overlayAnimation;
  bool _showOverlay = false;

  // Auto-compact nav bar state
  Timer? _navBarIdleTimer;
  Timer? _navBarDormantTimer;
  bool _isNavBarCompact = false;
  bool _isNavBarDormant = false;
  bool _isNavBarHovered = false;
  bool _wasWorkoutActive = false;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _restartNavBarIdleTimers();
  }

  @override
  void dispose() {
    _navBarIdleTimer?.cancel();
    _navBarDormantTimer?.cancel();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(currentWorkoutProvider);
    final currentIndex = widget.navigationShell.currentIndex;
    final isIOS = Platform.isIOS;
    final useNativeIOSTabBar = isIOS && _supportsNativeIOSTabBar;
    final existingMediaQuery = MediaQuery.of(context);
    final bottomSafeArea = existingMediaQuery.viewPadding.bottom;
    final keyboardVisible = existingMediaQuery.viewInsets.bottom > 0;
    final isWorkoutActive = _hasActiveWorkout(workout);
    const supportsNavBarCompaction = true;
    final isSheetOpen = ModalService.openSheetCount.value > 0;
    final isDormantForInset =
        supportsNavBarCompaction &&
        _isNavBarDormant &&
        !_isQuickActionsOpen &&
        !keyboardVisible &&
        !isSheetOpen;
    final isCompactForInset =
        supportsNavBarCompaction &&
        (_isNavBarCompact || isDormantForInset) &&
        !_isQuickActionsOpen &&
        !keyboardVisible &&
        !isSheetOpen;

    if (isWorkoutActive != _wasWorkoutActive) {
      _wasWorkoutActive = isWorkoutActive;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _restartNavBarIdleTimers();
      });
    }

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
    final showMiniBar =
        workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused) &&
        currentIndex != 1 &&
        _hasVisitedWorkoutScreen &&
        !keyboardVisible;
    final showPlusEmptyWorkoutHint =
        !showMiniBar &&
        !_isQuickActionsOpen &&
        !keyboardVisible &&
        ref.watch(
          shouldShowHintProvider(HintRegistry.plusEmptyWorkoutDiscovery.hintId),
        );

    // Calculate total nav bar height (content + safe area).
    // In compact mode we reduce the content inset too, so body gets more space.
    final navBarContentHeight = useNativeIOSTabBar
        ? (isDormantForInset
              ? _kIOSTabBarHeight * 0.76
              : isCompactForInset
              ? _kIOSTabBarHeight * 0.9
              : _kIOSTabBarHeight)
        : (isCompactForInset
              ? (isDormantForInset
                    ? _kAndroidNavBarDormantHeight
                    : _kAndroidNavBarCompactHeight)
              : _kAndroidNavBarHeight);
    final androidNavBarBottomMargin = isDormantForInset
        ? _kAndroidNavBarDormantBottomMargin
        : _kAndroidNavBarBottomMargin;
    final navBarTotalHeight = useNativeIOSTabBar
        ? navBarContentHeight + bottomSafeArea
        : navBarContentHeight + androidNavBarBottomMargin + bottomSafeArea;
    final effectiveNavBarInset = keyboardVisible ? 0.0 : navBarTotalHeight;

    // Inject adjusted MediaQuery so scroll views add bottom inset for nav bar.
    // IMPORTANT: Zero out viewInsets.bottom because MainShell's Scaffold already
    // handles keyboard resize via resizeToAvoidBottomInset. Preserving viewInsets
    // would cause child Scaffolds to double-resize, creating a black gap.
    final adjustedMediaQuery = existingMediaQuery.copyWith(
      padding: existingMediaQuery.padding.copyWith(
        // When keyboard covers the nav bar, no need for extra bottom inset.
        bottom: effectiveNavBarInset,
      ),
      viewInsets: existingMediaQuery.viewInsets.copyWith(
        bottom: 0, // MainShell Scaffold handles this
      ),
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ExerciseSyncListener(
        child: Stack(
          children: [
            // Main content with adjusted bottom padding via MediaQuery.
            // TabBarInset exposes navBarTotalHeight to all descendants
            // so they can add transparent bottom padding dynamically.
            TabBarInset(
              height: effectiveNavBarInset,
              child: MediaQuery(
                data: adjustedMediaQuery,
                child: widget.navigationShell,
              ),
            ),

            // Floating mini-bar positioned just above nav bar.
            // Hidden while keyboard is visible.
            if (showMiniBar)
              ValueListenableBuilder<int>(
                valueListenable: ModalService.openSheetCount,
                builder: (context, sheetCount, child) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: navBarTotalHeight + 8,
                    child: AnimatedSlide(
                      duration: _kNavBarCompactAnimationDuration,
                      curve: Curves.easeInOut,
                      offset: Offset(0, sheetCount > 0 ? 3.0 : 0.0),
                      child: child!,
                    ),
                  );
                },
                child: _buildMiniBar(workout, context),
              ),

            if (showPlusEmptyWorkoutHint)
              Positioned(
                left: 16,
                right: 16,
                bottom: navBarTotalHeight + 12,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: discoverability_hints.HintMicroTip(
                      hintId: HintRegistry.plusEmptyWorkoutDiscovery.hintId,
                      hint: HintRegistry.plusEmptyWorkoutDiscovery,
                      message: context.l10n.hintPlusEmptyWorkout,
                      icon: AppIcons.add,
                    ),
                  ),
                ),
              ),

            // Quick actions overlay (above content, below tab bar in z-order)
            if (_showOverlay)
              Positioned.fill(
                child: _QuickActionsOverlay(
                  animation: _overlayAnimation,
                  onClose: _closeQuickActions,
                  navigationShell: widget.navigationShell,
                  bottomOffset: effectiveNavBarInset,
                ),
              ),

            // Bottom navigation bar - hidden when a bottom sheet is open
            // or while keyboard is visible.
            // Tab indices: [Home(0), Workout(1), +(2), Profile(3), AI Coach(4)]
            // Branch indices: [Home(0), Workout(1), Profile(2), AI Coach(3)]
            ValueListenableBuilder<int>(
              valueListenable: ModalService.openSheetCount,
              builder: (context, sheetCount, child) {
                final isHidden = sheetCount > 0 || keyboardVisible;
                final isDormant =
                    supportsNavBarCompaction &&
                    _isNavBarDormant &&
                    !_isQuickActionsOpen &&
                    !isHidden;
                final isCompact =
                    supportsNavBarCompaction &&
                    (_isNavBarCompact || isDormant) &&
                    !_isQuickActionsOpen &&
                    !isHidden;
                // Map branch index → tab display index (skip + button at 2)
                final tabDisplayIndex = currentIndex < _kPlusButtonTabIndex
                    ? currentIndex
                    : currentIndex + 1;
                if (useNativeIOSTabBar) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSlide(
                      duration: _kNavBarCompactAnimationDuration,
                      curve: Curves.easeInOut,
                      offset: Offset(0, isHidden ? 1.0 : 0.0),
                      child: AnimatedPadding(
                        duration: _kNavBarCompactAnimationDuration,
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDormant ? 20 : 0,
                        ),
                        child: _wrapNavBarInteraction(
                          child: AnimatedScale(
                            duration: _kNavBarCompactAnimationDuration,
                            curve: Curves.easeOutCubic,
                            scale: isDormant
                                ? 0.82
                                : isCompact
                                ? 0.9
                                : 1.0,
                            child: AnimatedOpacity(
                              duration: _kNavBarCompactAnimationDuration,
                              opacity: isDormant
                                  ? 0.7
                                  : isCompact
                                  ? 0.92
                                  : 1.0,
                              child: _NativeIOSTabBar(
                                navKey: ref.watch(bottomNavKeyProvider),
                                currentIndex: tabDisplayIndex,
                                height: navBarTotalHeight,
                                isCompact: isCompact,
                                isDormant: isDormant,
                                onTap: (index) => _onTabBarTap(context, index),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: androidNavBarBottomMargin + bottomSafeArea,
                  child: AnimatedSlide(
                    duration: _kNavBarCompactAnimationDuration,
                    curve: Curves.easeInOut,
                    offset: Offset(0, isHidden ? 2.0 : 0.0),
                    child: AnimatedPadding(
                      duration: _kNavBarCompactAnimationDuration,
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDormant
                            ? _kAndroidNavBarDormantHorizontalMargin
                            : _kAndroidNavBarHorizontalMargin,
                      ),
                      child: _wrapNavBarInteraction(
                        child: AnimatedOpacity(
                          duration: _kNavBarCompactAnimationDuration,
                          opacity: isDormant ? 0.82 : 1.0,
                          child: _FloatingBottomNavBar(
                            navKey: ref.watch(bottomNavKeyProvider),
                            currentIndex: tabDisplayIndex,
                            isCompact: isCompact,
                            isDormant: isDormant,
                            onTap: (index) => _onTabBarTap(context, index),
                          ),
                        ),
                      ),
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
      return HintPeek(hint: HintRegistry.swipeMiniBar, child: miniBar);
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

  /// Handle tab bar tap with index mapping.
  ///
  /// Tab indices include the + button: [Home(0), Workout(1), +(2), Profile(3), AI Coach(4)]
  /// Branch indices skip it: [Home(0), Workout(1), Profile(2), AI Coach(3)]
  void _onTabBarTap(BuildContext context, int tabIndex) {
    _registerNavBarInteraction();
    if (tabIndex == _kPlusButtonTabIndex) {
      final hintId = HintRegistry.plusEmptyWorkoutDiscovery.hintId;
      final activeHint = ref
          .read(discoverabilityHintServiceProvider)
          .activeHint;
      if (activeHint?.hintId == hintId) {
        unawaited(ref.read(hintActionsProvider.notifier).completeHint(hintId));
      } else {
        unawaited(
          ref.read(tutorialStateProvider.notifier).markTutorialSeen(hintId),
        );
      }
      if (_isQuickActionsOpen) {
        _closeQuickActions();
      } else {
        _showQuickActionsModal(context);
      }
      return;
    }
    // Close overlay if open, then navigate
    if (_isQuickActionsOpen) {
      _closeQuickActions();
    }
    // Map tab index → branch index (subtract 1 for items after the + button)
    final branchIndex = tabIndex < _kPlusButtonTabIndex
        ? tabIndex
        : tabIndex - 1;
    _onDestinationSelected(context, branchIndex);
  }

  /// Handle destination selection with branch switching
  void _onDestinationSelected(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    final isSameTab = index == widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(index, initialLocation: isSameTab);

    // Signal same-tab tap after navigation so the branch root is mounted even
    // when the user re-taps the active tab from a nested route.
    if (isSameTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(sameTabTapSignalProvider.notifier).signal();
      });
    }
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
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
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

  /// Show quick actions overlay within the Stack (tab bar stays visible)
  void _showQuickActionsModal(BuildContext context) {
    _navBarIdleTimer?.cancel();
    _navBarDormantTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _isNavBarCompact = false;
      _isNavBarDormant = false;
      _isQuickActionsOpen = true;
      _showOverlay = true;
    });
    _overlayController.forward();
  }

  /// Close quick actions overlay with reverse animation
  void _closeQuickActions() {
    _overlayController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isQuickActionsOpen = false;
          _showOverlay = false;
        });
        _restartNavBarIdleTimers();
      }
    });
  }

  Widget _wrapNavBarInteraction({required Widget child}) {
    return Listener(
      onPointerDown: (_) => _registerNavBarInteraction(),
      child: MouseRegion(
        onEnter: (_) {
          _isNavBarHovered = true;
          _registerNavBarInteraction();
        },
        onExit: (_) {
          _isNavBarHovered = false;
          _restartNavBarIdleTimers();
        },
        child: child,
      ),
    );
  }

  void _registerNavBarInteraction() {
    _navBarIdleTimer?.cancel();
    _navBarDormantTimer?.cancel();
    if ((_isNavBarCompact || _isNavBarDormant) && mounted) {
      setState(() {
        _isNavBarCompact = false;
        _isNavBarDormant = false;
      });
    }
    if (!_isNavBarHovered) {
      _restartNavBarIdleTimers();
    }
  }

  void _restartNavBarIdleTimers() {
    _navBarIdleTimer?.cancel();
    _navBarDormantTimer?.cancel();
    _navBarIdleTimer = Timer(_kNavBarCompactDelay, () {
      if (!mounted || _isQuickActionsOpen || _isNavBarHovered) return;
      if (_isNavBarCompact) return;
      setState(() => _isNavBarCompact = true);
    });

    final workout = ref.read(currentWorkoutProvider);
    if (!_hasActiveWorkout(workout)) {
      if (_isNavBarDormant && mounted) {
        setState(() => _isNavBarDormant = false);
      }
      return;
    }

    _navBarDormantTimer = Timer(_kNavBarDormantDelay, () {
      if (!mounted || _isQuickActionsOpen || _isNavBarHovered) return;
      final activeWorkout = ref.read(currentWorkoutProvider);
      if (!_hasActiveWorkout(activeWorkout)) return;
      setState(() {
        _isNavBarCompact = true;
        _isNavBarDormant = true;
      });
    });
  }

  bool _hasActiveWorkout(Workout? workout) {
    return workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused);
  }

  bool get _supportsNativeIOSTabBar {
    if (!Platform.isIOS) return false;

    final versionString = Platform.operatingSystemVersion;
    final versionMatch = RegExp(
      r'version\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(versionString);
    final fallbackMatch = RegExp(r'(\d+)').firstMatch(versionString);
    final majorVersion = int.tryParse(
      versionMatch?.group(1) ?? fallbackMatch?.group(1) ?? '',
    );

    return (majorVersion ?? 0) >= _kMinimumNativeIOSTabBarMajorVersion;
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
    required this.height,
    required this.isCompact,
    required this.isDormant,
    required this.onTap,
    this.navKey,
  });

  final int currentIndex;
  final double height;
  final bool isCompact;
  final bool isDormant;
  final ValueChanged<int> onTap;
  final GlobalKey? navKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: navKey,
      width: double.infinity,
      child: CNTabBar(
        height: height,
        iconSize: isDormant
            ? 12
            : isCompact
            ? 13
            : 15,
        shrinkCentered: false,
        items: [
          CNTabBarItem(
            label: isCompact ? '' : context.l10n.home,
            icon: CNSymbol(
              'house',
              size: isDormant ? 13 : 15,
              weight: CNSymbolWeight.light,
            ),
          ),
          CNTabBarItem(
            label: isCompact ? '' : context.l10n.workout,
            icon: CNSymbol(
              'dumbbell',
              size: isDormant ? 13 : 15,
              weight: CNSymbolWeight.light,
            ),
          ),
          // Center "+" button item
          CNTabBarItem(
            label: '',
            icon: CNSymbol(
              'plus.circle.fill',
              size: isDormant
                  ? 21
                  : isCompact
                  ? 24
                  : 28,
              weight: CNSymbolWeight.medium,
              color: _kCenterButtonColor,
            ),
          ),
          CNTabBarItem(
            label: isCompact ? '' : context.l10n.profile,
            icon: CNSymbol(
              'person',
              size: isDormant ? 13 : 15,
              weight: CNSymbolWeight.light,
            ),
          ),
          if (FeatureFlags.aiCoachEnabled)
            CNTabBarItem(
              label: isCompact ? '' : context.l10n.aiCoach,
              icon: CNSymbol(
                'brain.head.profile',
                size: isDormant ? 13 : 15,
                weight: CNSymbolWeight.light,
              ),
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
    required this.isCompact,
    required this.isDormant,
    required this.onTap,
    this.navKey,
  });

  final int currentIndex;
  final bool isCompact;
  final bool isDormant;
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
        child: AnimatedContainer(
          duration: _kNavBarCompactAnimationDuration,
          curve: Curves.easeOutCubic,
          height: isDormant
              ? _kAndroidNavBarDormantHeight
              : isCompact
              ? _kAndroidNavBarCompactHeight
              : _kAndroidNavBarHeight,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer.withValues(
              alpha: isDormant ? 0.7 : 0.85,
            ),
            borderRadius: BorderRadius.circular(
              isDormant
                  ? 18
                  : isCompact
                  ? 20
                  : 24,
            ),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(
                alpha: isDormant ? 0.12 : 0.2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Items before the + button
              for (var i = 0; i < _kPlusButtonTabIndex; i++)
                _FloatingNavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isCompact: isCompact,
                  isDormant: isDormant,
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              // Center + button
              _FloatingPlusItem(
                onTap: () => onTap(_kPlusButtonTabIndex),
                semanticLabel: context.l10n.quickActions,
                isCompact: isCompact,
                isDormant: isDormant,
              ),
              // Items after the + button
              for (var i = _kPlusButtonTabIndex; i < items.length; i++)
                _FloatingNavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isCompact: isCompact,
                  isDormant: isDormant,
                  isSelected: (i + 1) == currentIndex,
                  onTap: () => onTap(i + 1),
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
    required this.isCompact,
    required this.isDormant,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isCompact;
  final bool isDormant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: isDormant
            ? 40
            : isCompact
            ? 44
            : 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isDormant
                  ? 15
                  : isCompact
                  ? 16
                  : AppIconSize.small,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            if (!isCompact) ...[
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
          ],
        ),
      ),
    );
  }
}

/// Styled "+" button for the Android floating nav bar.
class _FloatingPlusItem extends StatelessWidget {
  const _FloatingPlusItem({
    required this.onTap,
    required this.semanticLabel,
    required this.isCompact,
    required this.isDormant,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final bool isCompact;
  final bool isDormant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: isDormant
              ? 30
              : isCompact
              ? 36
              : 42,
          height: isDormant
              ? 30
              : isCompact
              ? 36
              : 42,
          decoration: BoxDecoration(
            color: _kCenterButtonColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: isDormant ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _kCenterButtonColor.withValues(
                  alpha: isDormant ? 0.28 : 0.42,
                ),
                blurRadius: isDormant ? 8 : 14,
                spreadRadius: isDormant ? 0 : 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            AppIcons.add,
            color: Colors.white,
            size: isDormant
                ? 18
                : isCompact
                ? 22
                : 26,
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Quick Actions Overlay
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _QuickActionsOverlay extends StatelessWidget {
  const _QuickActionsOverlay({
    required this.animation,
    required this.onClose,
    required this.navigationShell,
    required this.bottomOffset,
  });

  final Animation<double> animation;
  final VoidCallback onClose;
  final StatefulNavigationShell navigationShell;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Blur background - covers entire overlay area
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.black.withValues(alpha: 0.75)),
                ),
              ),
            ),

            // Content - positioned above the tab bar
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Spacer(),

                  // Quick actions content (3 sections)
                  QuickActionsOverlayContent(
                    animation: animation,
                    onClose: onClose,
                    navigationShell: navigationShell,
                  ),

                  const SizedBox(height: 48),

                  // Close button
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onClose();
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          AppIcons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // Space for tab bar + padding so close button stays above it
                  SizedBox(height: bottomOffset + 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
