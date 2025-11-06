import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Real-time set execution timer widget with TIER-1 visualization
class SetExecutionTimerWidget extends ConsumerStatefulWidget {
  
  const SetExecutionTimerWidget({
    super.key,
    required this.exercise,
    required this.setNumber,
    required this.isTracking,
    this.onTap,
  });
  final Exercise exercise;
  final int setNumber;
  final bool isTracking;
  final VoidCallback? onTap;

  @override
  ConsumerState<SetExecutionTimerWidget> createState() => _SetExecutionTimerWidgetState();
}

class _SetExecutionTimerWidgetState extends ConsumerState<SetExecutionTimerWidget> 
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  
  // Animation for pulsing effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Personal best tracking
  Duration? _personalBest;
  bool _isApproachingPB = false;
  bool _hasExceededPB = false;
  
  @override
  void initState() {
    super.initState();
    
    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Load personal best for this exercise
    _loadPersonalBest();
  }
  
  @override
  void didUpdateWidget(SetExecutionTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start/stop tracking based on isTracking prop
    if (widget.isTracking && !oldWidget.isTracking) {
      _startTracking();
    } else if (!widget.isTracking && oldWidget.isTracking) {
      _stopTracking();
    }
  }
  
  void _loadPersonalBest() {
    // TODO: Load from repository
    // For now, use a dummy value
    _personalBest = const Duration(seconds: 25);
  }
  
  void _startTracking() {
    final durationTracker = ref.read(setDurationTrackerProvider);
    
    // IMPORTANTE: Quando l'utente inizia il tracking manualmente,
    // vogliamo usare ADESSO come inizio, non il timestamp del timer
    // che potrebbe essere di 60+ secondi fa
    _startTime = DateTime.now();
    
    // Aggiorna anche il tracker con il tempo corrente
    durationTracker.setStartTime(widget.exercise.id, widget.setNumber, _startTime!);
    
    // Start the timer for UI updates
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
        
        // Check if approaching or exceeding personal best
        if (_personalBest != null) {
          final pbSeconds = _personalBest!.inSeconds;
          final elapsedSeconds = _elapsed.inSeconds;
          
          // Start pulsing when within 5 seconds of PB
          if (elapsedSeconds >= pbSeconds - 5 && !_isApproachingPB) {
            _isApproachingPB = true;
            _pulseController.repeat(reverse: true);
          }
          
          // Change color when PB exceeded
          if (elapsedSeconds > pbSeconds && !_hasExceededPB) {
            _hasExceededPB = true;
            _pulseController.stop();
          }
        }
      });
    });
  }
  
  void _stopTracking() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
  
  Color _getTimerColor() {
    if (_hasExceededPB) {
      return Colors.red.shade400;
    } else if (_isApproachingPB) {
      return Colors.orange.shade400;
    } else if (widget.isTracking) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.5);
    }
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = (duration.inMilliseconds.remainder(1000) / 10).floor();
    
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
    } else {
      return '$seconds.${milliseconds.toString().padLeft(2, '0')}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    const showMilliseconds = true; // config.showPreciseTimings ?? true; // TODO: Add showPreciseTimings to AppConfig
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isApproachingPB ? _pulseAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getTimerColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTimerColor(),
                  width: widget.isTracking ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main timer display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isTracking)
                        Icon(
                          AppIcons.timer,
                          color: _getTimerColor(),
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        showMilliseconds 
                          ? _formatDuration(_elapsed)
                          : '${_elapsed.inSeconds}s',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getTimerColor(),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  
                  // Status indicators
                  if (widget.isTracking) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Personal best indicator
                        if (_personalBest != null) ...[
                          if (_hasExceededPB) ...[
                            const Icon(
                              AppIcons.trendUp,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Over PB',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (_isApproachingPB) ...[
                            const Icon(
                              AppIcons.bolt,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Near PB!',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              AppIcons.clock,
                              color: Theme.of(context).colorScheme.outline,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PB: ${_formatDuration(_personalBest!)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                  
                  // Instruction text when not tracking
                  if (!widget.isTracking) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap to start tracking',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Velocity indicator widget for power/speed tracking
class VelocityIndicatorWidget extends StatelessWidget {
  
  const VelocityIndicatorWidget({
    super.key,
    required this.currentVelocity,
    required this.targetVelocity,
    this.personalBestVelocity,
  });
  final double currentVelocity;
  final double targetVelocity;
  final double? personalBestVelocity;
  
  Color _getVelocityColor(BuildContext context) {
    final ratio = currentVelocity / targetVelocity;
    if (ratio >= 1.1) {
      return Colors.green.shade600; // Exceeding target
    } else if (ratio >= 0.9) {
      return Theme.of(context).colorScheme.primary; // On target
    } else if (ratio >= 0.7) {
      return Colors.orange.shade600; // Below target
    } else {
      return Colors.red.shade600; // Far below target
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final percentage = (currentVelocity / targetVelocity * 100).clamp(0, 150);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Velocity',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${currentVelocity.toStringAsFixed(2)} m/s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getVelocityColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_getVelocityColor(context)),
            ),
          ),
          const SizedBox(height: 4),
          
          // Target and PB indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${targetVelocity.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (personalBestVelocity != null)
                Text(
                  'PB: ${personalBestVelocity!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini chart showing set times progression
class SetTimesChartWidget extends StatelessWidget {
  
  const SetTimesChartWidget({
    super.key,
    required this.setTimes,
    required this.currentSetIndex,
  });
  final List<double> setTimes; // in seconds
  final int currentSetIndex;
  
  @override
  Widget build(BuildContext context) {
    if (setTimes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final maxTime = setTimes.reduce((a, b) => a > b ? a : b);
    final minTime = setTimes.reduce((a, b) => a < b ? a : b);
    final range = maxTime - minTime;
    
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(setTimes.length, (index) {
          final time = setTimes[index];
          final heightRatio = range > 0 ? (time - minTime) / range : 0.5;
          final height = 20 + (heightRatio * 20); // 20-40 pixels
          
          final isCurrentSet = index == currentSetIndex;
          final isCompleted = index < currentSetIndex;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 9,
                      color: isCurrentSet 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                      fontWeight: isCurrentSet ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: height,
                    decoration: BoxDecoration(
                      color: isCurrentSet
                        ? Theme.of(context).colorScheme.primary
                        : isCompleted
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
