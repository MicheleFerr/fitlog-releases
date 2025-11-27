import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/spotlight_painter.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Position of the overlay relative to target widget.
enum OverlayPosition {
  above,
  below,
  left,
  right,
}

/// Unified contextual overlay for tutorial tips.
///
/// Features:
/// - Spotlight effect on target widget
/// - Pulsing animation for attention
/// - Auto-hide after duration
/// - Fallback to snackbar if positioning fails
/// - CompositedTransformFollower for smooth positioning
///
/// ## Usage:
/// ```dart
/// // Target widget must have LayerLink and GlobalKey
/// final _layerLink = LayerLink();
/// final _targetKey = GlobalKey();
///
/// CompositedTransformTarget(
///   link: _layerLink,
///   child: Container(key: _targetKey, ...),
/// )
///
/// // Show overlay
/// UnifiedContextualOverlay(
///   targetLink: _layerLink,
///   targetKey: _targetKey,
///   title: 'How to log a set',
///   description: 'Tap here to enter weight and reps',
///   onDismiss: () => removeOverlay(),
/// )
/// ```
class UnifiedContextualOverlay extends StatefulWidget {
  const UnifiedContextualOverlay({
    super.key,
    required this.targetLink,
    required this.targetKey,
    required this.title,
    required this.description,
    required this.onDismiss,
    this.preferredPosition = OverlayPosition.below,
    this.actionLabel,
    this.onAction,
    this.autoHide = const Duration(seconds: 5),
    this.showPulse = true,
    this.showSpotlight = true,
  });

  /// LayerLink connected to target widget via CompositedTransformTarget.
  final LayerLink targetLink;

  /// GlobalKey of the target widget for bounds calculation.
  final GlobalKey targetKey;

  /// Preferred position of tooltip relative to target.
  final OverlayPosition preferredPosition;

  /// Title text for the tooltip.
  final String title;

  /// Description text for the tooltip.
  final String description;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action button callback.
  final VoidCallback? onAction;

  /// Callback when overlay is dismissed.
  final VoidCallback onDismiss;

  /// Duration before auto-hiding. Set to Duration.zero to disable.
  final Duration autoHide;

  /// Whether to show pulsing animation around target.
  final bool showPulse;

  /// Whether to show spotlight/scrim effect.
  final bool showSpotlight;

  @override
  State<UnifiedContextualOverlay> createState() =>
      _UnifiedContextualOverlayState();
}

class _UnifiedContextualOverlayState extends State<UnifiedContextualOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _autoHideTimer;
  late AnimationController _pulseController;
  Offset? _targetPosition;
  Size? _targetSize;
  int _retryCount = 0;

  static const _maxRetries = 3;
  static const _retryDelayMs = 100;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startAutoHideTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePosition());
  }

  void _calculatePosition() {
    try {
      final RenderBox? renderBox =
          widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox == null || !renderBox.hasSize) {
        _scheduleRetry();
        return;
      }

      setState(() {
        _targetPosition = renderBox.localToGlobal(Offset.zero);
        _targetSize = renderBox.size;
      });
    } catch (e) {
      _handlePositioningError(e);
    }
  }

  void _scheduleRetry() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(Duration(milliseconds: _retryDelayMs * _retryCount), () {
        if (mounted) _calculatePosition();
      });
    } else {
      _showFallbackSnackbar();
    }
  }

  void _handlePositioningError(Object error) {
    debugPrint('Tutorial overlay positioning failed: $error');
    _showFallbackSnackbar();
  }

  void _showFallbackSnackbar() {
    if (!mounted) return;
    SnackBarService.showInfo(
      context,
      '${widget.title}: ${widget.description}',
      duration: widget.autoHide,
    );
    widget.onDismiss();
  }

  void _startAutoHideTimer() {
    if (widget.autoHide == Duration.zero) return;
    _autoHideTimer = Timer(widget.autoHide, () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait for position calculation
    if (_targetPosition == null || _targetSize == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Scrim with spotlight cutout
        if (widget.showSpotlight)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: CustomPaint(
                painter: AnimatedSpotlightPainter(
                  targetRect: Rect.fromLTWH(
                    _targetPosition!.dx,
                    _targetPosition!.dy,
                    _targetSize!.width,
                    _targetSize!.height,
                  ),
                  animation: _pulseController,
                  spotlightPadding: 8.0,
                  glowColor: widget.showPulse ? context.colors.primary : null,
                ),
              ),
            ),
          ),

        // Pulse animation border on target
        if (widget.showPulse)
          Positioned(
            left: _targetPosition!.dx - 4,
            top: _targetPosition!.dy - 4,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: _targetSize!.width + 8,
                  height: _targetSize!.height + 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.primary.withValues(
                        alpha: 0.3 + (_pulseController.value * 0.4),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Tooltip with CompositedTransformFollower
        CompositedTransformFollower(
          link: widget.targetLink,
          targetAnchor: _getTargetAnchor(),
          followerAnchor: _getFollowerAnchor(),
          offset: _getOffset(),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: context.colors.surface,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: context.textTheme.bodyMedium,
                  ),
                  if (widget.actionLabel != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          widget.onAction?.call();
                          widget.onDismiss();
                        },
                        child: Text(widget.actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Alignment _getTargetAnchor() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => Alignment.topCenter,
      OverlayPosition.below => Alignment.bottomCenter,
      OverlayPosition.left => Alignment.centerLeft,
      OverlayPosition.right => Alignment.centerRight,
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => Alignment.bottomCenter,
      OverlayPosition.below => Alignment.topCenter,
      OverlayPosition.left => Alignment.centerRight,
      OverlayPosition.right => Alignment.centerLeft,
    };
  }

  Offset _getOffset() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => const Offset(0, -8),
      OverlayPosition.below => const Offset(0, 8),
      OverlayPosition.left => const Offset(-8, 0),
      OverlayPosition.right => const Offset(8, 0),
    };
  }
}
