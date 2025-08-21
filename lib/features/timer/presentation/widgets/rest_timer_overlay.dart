import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/timer_provider.dart';
import '../../domain/entities/rest_timer.dart';

class RestTimerOverlay extends ConsumerWidget {
  const RestTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(currentTimerProvider);
    
    if (timer == null || !timer.isActive) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: _getGradientColors(timer, context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTimerContent(context, ref, timer),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerContent(BuildContext context, WidgetRef ref, RestTimer timer) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with exercise info
        Row(
          children: [
            Icon(
              _getTimerIcon(timer.status),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rest Timer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (timer.exerciseName != null)
                    Text(
                      timer.exerciseName!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (timer.currentSet != null && timer.totalSets != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Set ${timer.currentSet}/${timer.totalSets}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Timer display with progress ring
        Row(
          children: [
            // Progress ring
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  // Background circle
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: ProgressRingPainter(
                      progress: 0.0,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      progressColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: ProgressRingPainter(
                      progress: timer.progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      progressColor: Colors.white,
                    ),
                  ),
                  // Timer icon in center
                  Center(
                    child: Icon(
                      timer.isPaused ? Icons.pause : Icons.timer,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Time display and controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time remaining
                  Text(
                    timer.formattedTime,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status text
                  Text(
                    _getStatusText(timer),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Control buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add time button
                _TimerActionButton(
                  icon: Icons.add,
                  onPressed: () => ref.read(currentTimerProvider.notifier).addTime(30),
                  tooltip: '+30s',
                ),
                const SizedBox(width: 8),
                // Pause/Resume button
                _TimerActionButton(
                  icon: timer.isPaused ? Icons.play_arrow : Icons.pause,
                  onPressed: () {
                    if (timer.isPaused) {
                      ref.read(currentTimerProvider.notifier).resumeTimer();
                    } else {
                      ref.read(currentTimerProvider.notifier).pauseTimer();
                    }
                  },
                  tooltip: timer.isPaused ? 'Resume' : 'Pause',
                ),
                const SizedBox(width: 8),
                // Skip button
                _TimerActionButton(
                  icon: Icons.skip_next,
                  onPressed: () => ref.read(currentTimerProvider.notifier).skipTimer(),
                  tooltip: 'Skip',
                ),
              ],
            ),
          ],
        ),
        
        // Progress bar
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: timer.progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }

  List<Color> _getGradientColors(RestTimer timer, BuildContext context) {
    if (timer.isCompleted) {
      return [Colors.green.shade600, Colors.green.shade800];
    } else if (timer.isPaused) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else if (timer.remainingSeconds <= 30) {
      return [Colors.red.shade600, Colors.red.shade800];
    } else if (timer.remainingSeconds <= 60) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else {
      return [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withRed(
          (Theme.of(context).colorScheme.primary.red * 0.8).round(),
        ),
      ];
    }
  }

  IconData _getTimerIcon(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return Icons.timer;
      case TimerStatus.paused:
        return Icons.pause_circle;
      case TimerStatus.completed:
        return Icons.check_circle;
      case TimerStatus.idle:
        return Icons.timer_outlined;
    }
  }

  String _getStatusText(RestTimer timer) {
    if (timer.isCompleted) {
      return 'Rest complete! Ready for next set';
    } else if (timer.isPaused) {
      return 'Timer paused';
    } else if (timer.remainingSeconds <= 30) {
      return 'Get ready...';
    } else {
      return 'Rest time';
    }
  }
}

class _TimerActionButton extends StatelessWidget {
  const _TimerActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    if (progressColor != Colors.transparent && progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor;
  }
}