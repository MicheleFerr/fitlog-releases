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
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class SuperLikeButton extends ConsumerWidget {

  const SuperLikeButton({
    super.key,
    required this.superLikesRemaining,
    this.onSuperLike,
    this.isEnabled = true,
  });
  final int superLikesRemaining;
  final VoidCallback? onSuperLike;
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    final hasRemaining = superLikesRemaining > 0;
    final canSuperLike = isEnabled && hasRemaining && onSuperLike != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Super Like Button
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: canSuperLike
                ? const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !canSuperLike ? colorScheme.surfaceContainerHighest : null,
            boxShadow: canSuperLike
                ? [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: canSuperLike ? onSuperLike : null,
              customBorder: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: AnimatedScale(
                  scale: canSuperLike ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    AppIcons.star,
                    size: 28,
                    color: canSuperLike 
                        ? context.colors.surface 
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 8),
        
        // Remaining count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.superLikesRemaining(superLikesRemaining),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class SuperLikeAnimation extends StatefulWidget {

  const SuperLikeAnimation({
    super.key,
    required this.child,
    this.animate = false,
  });
  final Widget child;
  final bool animate;

  @override
  State<SuperLikeAnimation> createState() => _SuperLikeAnimationState();
}

class _SuperLikeAnimationState extends State<SuperLikeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _scaleCurve;
  late CurvedAnimation _rotationCurve;
  late CurvedAnimation _slideCurve;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _rotationCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_scaleCurve);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(_rotationCurve);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(_slideCurve);
  }

  @override
  void didUpdateWidget(SuperLikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate && !oldWidget.animate) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleCurve.dispose();
    _rotationCurve.dispose();
    _slideCurve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Floating Super Like overlay for dramatic effect
class SuperLikeOverlay extends StatefulWidget {

  const SuperLikeOverlay({
    super.key,
    required this.isVisible,
    this.onComplete,
  });
  final bool isVisible;
  final VoidCallback? onComplete;

  @override
  State<SuperLikeOverlay> createState() => _SuperLikeOverlayState();
}

class _SuperLikeOverlayState extends State<SuperLikeOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _fadeCurve;
  late CurvedAnimation _scaleCurve;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeCurve);

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_scaleCurve);
  }

  @override
  void didUpdateWidget(SuperLikeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _controller.reverse().then((_) {
            widget.onComplete?.call();
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeCurve.dispose();
    _scaleCurve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: ColoredBox(
            color: context.colors.onSurface.withValues(alpha: 0.3 * _fadeAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF29B6F6).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.star,
                          size: 64,
                          color: context.colors.surface,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).superLike,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }
}
