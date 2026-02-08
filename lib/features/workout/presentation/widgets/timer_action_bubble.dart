/// Timer Action Bubble Widget
///
/// Bubble menu che appare sotto il timer con 3 azioni:
/// - Pause (se running) / Resume (se paused)
/// - +30s (estendi)
/// - Skip (salta)
///
/// Design:
/// - Background: surfaceContainer con ombre profonde
/// - Border radius: 16px
/// - Triangolo connettore che punta verso il timer
/// - Animazioni: apertura elastica, chiusura con risucchio
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Bubble con azioni timer: Pausa, +30s, Salta
class TimerActionBubble extends ConsumerStatefulWidget {
  const TimerActionBubble({
    super.key,
    required this.onDismiss,
    required this.anchorPosition,
    required this.anchorSize,
  });

  /// Callback quando il bubble viene chiuso
  final VoidCallback onDismiss;

  /// Posizione dell'elemento a cui è ancorato (timer)
  final Offset anchorPosition;

  /// Dimensione dell'elemento a cui è ancorato
  final Size anchorSize;

  @override
  ConsumerState<TimerActionBubble> createState() => _TimerActionBubbleState();
}

class _TimerActionBubbleState extends ConsumerState<TimerActionBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Apertura: elastic out per effetto bounce
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _closeBubble() async {
    if (_isClosing) return;
    _isClosing = true;

    // Chiusura: easeInBack per effetto risucchio (200ms)
    _controller.duration = const Duration(milliseconds: 200);
    await _controller.animateTo(
      0.0,
      curve: Curves.easeInBack,
    );

    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = ref.watch(
      unifiedTimerProvider.select((state) => state?.isPaused ?? false),
    );

    // Calcola posizione del bubble (centrato sotto il timer, con 8px gap)
    const bubbleWidth = 200.0;
    const triangleHeight = 10.0;
    const gap = 8.0;

    final bubbleX =
        widget.anchorPosition.dx +
        (widget.anchorSize.width / 2) -
        (bubbleWidth / 2);
    final bubbleY =
        widget.anchorPosition.dy + widget.anchorSize.height + gap + triangleHeight;

    // IMPORTANT: Positioned must be direct child of Stack (in OverlayEntry)
    // Animations go INSIDE Positioned, not wrapping it
    return Positioned(
      left: bubbleX,
      top: bubbleY,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.topCenter,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Triangolo connettore
              CustomPaint(
                size: const Size(20, triangleHeight),
                painter: _TrianglePainter(
                  color: context.colors.surfaceContainer,
                  shadowColor: context.colors.shadow.withValues(alpha: 0.15),
                ),
              ),
              // Bubble principale
              Container(
                width: bubbleWidth,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause/Resume
                      _ActionButton(
                        icon: isPaused ? AppIcons.play : AppIcons.pause,
                        label: isPaused
                            ? context.l10n.resume
                            : context.l10n.timerActionPause,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (isPaused) {
                            ref
                                .read(unifiedTimerProvider.notifier)
                                .resumeTimer();
                          } else {
                            ref
                                .read(unifiedTimerProvider.notifier)
                                .pauseTimer();
                          }
                          _closeBubble();
                        },
                      ),

                      // Divider verticale
                      Container(
                        width: 1,
                        height: 32,
                        color: context.colors.outline.withValues(alpha: 0.2),
                      ),

                      // +30s
                      _ActionButton(
                        icon: AppIcons.add,
                        label: context.l10n.timerActionExtend,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(unifiedTimerProvider.notifier).addTime(30);
                          _closeBubble();
                        },
                      ),

                      // Divider verticale
                      Container(
                        width: 1,
                        height: 32,
                        color: context.colors.outline.withValues(alpha: 0.2),
                      ),

                      // Skip
                      _ActionButton(
                        icon: AppIcons.skipNext,
                        label: context.l10n.timerActionSkip,
                        color: context.colors.error,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          ref.read(unifiedTimerProvider.notifier).skipTimer();
                          _closeBubble();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulsante azione singola nel bubble
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? context.colors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isPressed
                ? effectiveColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: AppIconSize.medium,
                color: effectiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter per il triangolo connettore
class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({
    required this.color,
    required this.shadowColor,
  });

  final Color color;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Ombra
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Triangolo
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shadowColor != shadowColor;
  }
}

/// Mostra il TimerActionBubble come overlay
void showTimerActionBubble({
  required BuildContext context,
  required GlobalKey timerKey,
}) {
  final renderBox = timerKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Tap barrier per chiudere
        Positioned.fill(
          child: GestureDetector(
            onTap: () => overlayEntry.remove(),
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Bubble
        TimerActionBubble(
          onDismiss: () => overlayEntry.remove(),
          anchorPosition: position,
          anchorSize: size,
        ),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}
