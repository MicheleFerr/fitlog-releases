/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/presentation/widgets
/// Feature: Tab Bar Safe Area
/// Type: InheritedWidget + Helper Widgets
///
/// Provides the overlay tab bar height to descendant widgets so they can
/// add appropriate transparent bottom padding without hardcoded values.
///
/// MainShell wraps its content with [TabBarInset] to propagate the height.
/// Child screens access it via `TabBarInset.of(context)` or `context.tabBarInset`.
library;

import 'package:flutter/material.dart';

/// Provides the height of the bottom tab bar overlay to descendant widgets.
///
/// Placed by [MainShell] above the navigation shell content.
/// Child screens use this to know how much transparent bottom padding
/// they need so content doesn't hide behind the overlay tab bar.
///
/// ```dart
/// // Access the height directly:
/// final height = TabBarInset.of(context);
///
/// // Or via the BuildContext extension:
/// final height = context.tabBarInset;
/// ```
class TabBarInset extends InheritedWidget {
  const TabBarInset({
    required this.height,
    required super.child,
    super.key,
  });

  /// Total height of the bottom tab bar including safe area padding.
  final double height;

  /// Get the tab bar inset height from the nearest ancestor.
  /// Returns 0 if no [TabBarInset] is found (e.g., outside MainShell).
  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<TabBarInset>()
            ?.height ??
        0;
  }

  @override
  bool updateShouldNotify(TabBarInset oldWidget) => height != oldWidget.height;
}

/// Transparent bottom padding that matches the tab bar overlay height.
///
/// Use inside [Column], [Stack], or other non-scrollable layouts to prevent
/// content from being hidden behind the overlay tab bar.
///
/// For slivers ([CustomScrollView]), use [SliverTabBarBottomPadding] instead.
///
/// ```dart
/// Column(
///   children: [
///     Expanded(child: content),
///     const TabBarBottomPadding(), // transparent spacer
///   ],
/// )
/// ```
class TabBarBottomPadding extends StatelessWidget {
  const TabBarBottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: TabBarInset.of(context));
  }
}

/// Sliver version of [TabBarBottomPadding] for use inside [CustomScrollView].
///
/// Adds transparent bottom space matching the tab bar height so the last
/// item in a sliver list can scroll fully above the overlay tab bar.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverList(...),
///     const SliverTabBarBottomPadding(), // last item
///   ],
/// )
/// ```
class SliverTabBarBottomPadding extends StatelessWidget {
  const SliverTabBarBottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: TabBarInset.of(context)),
    );
  }
}
