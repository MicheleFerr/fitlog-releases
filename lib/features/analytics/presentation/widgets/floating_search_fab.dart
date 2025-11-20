/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// FloatingSearchFab - Floating action button that appears on scroll (50px+)
///
/// **Purpose**: Compact search button that slides in from right when user scrolls down
///
/// **Behavior**:
/// - Hidden when scroll offset < 50px
/// - Slides in from right edge with 300ms animation when scrolled
/// - Positioned top-right (16px from edges)
/// - Tappable area ≥ 44x44 (accessibility)
/// - Primary color background with white icon
///
/// **Design Specs**:
/// - Size: 56x56 (Material FAB standard)
/// - Elevation: 4dp
/// - Border radius: 16px (matches card design)
/// - Icon: Magnifying glass (AppIcons.search)
/// - Animation: Slide from right + fade (300ms decelerate)
///
/// **Integration**:
/// - Used in AnalyticsScreen
/// - Controlled by _showFab ValueNotifier
/// - Trigger: ScrollController offset > 50px
///
/// **Task**: 4.1 - Build FAB Search Button Base Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Floating search button that appears on scroll
///
/// **Visibility**: Controlled by ValueNotifier<bool> showFab
/// **Position**: Top-right corner (16px from edges)
/// **Animation**: Slide-in from right + fade (300ms)
///
/// **Accessibility**:
/// - Semantic label for screen readers
/// - Haptic feedback on tap
/// - Touch target ≥ 44x44
class FloatingSearchFab extends StatelessWidget {
  const FloatingSearchFab({
    required this.showFab,
    required this.onTap,
    super.key,
  });

  /// Controls FAB visibility (true = visible, false = hidden)
  final ValueNotifier<bool> showFab;

  /// Callback when FAB is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showFab,
      builder: (context, show, child) {
        return AnimatedPositioned(
          duration: AppAnimations.normal, // 300ms
          curve: AppAnimations.decelerate, // easeOutCubic
          // Slide in from right edge
          top: 16,
          right: show ? 16 : -72, // 56 (FAB width) + 16 (margin) = 72
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: AppAnimations.normal,
            curve: AppAnimations.decelerate,
            child: child,
          ),
        );
      },
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: context.colors.primary,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: SemanticIcon.button(
              icon: AppIcons.search,
              semanticLabel: context.l10n.search,
              size: AppIconSize.large, // 28px
              color: context.colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
