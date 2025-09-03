import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/set_execution_timer_widget.dart';

/// Enhanced exercise card with TIER-1 real-time tracking visualization
class EnhancedExerciseCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int currentSetNumber;
  final Function(ExerciseSet) onSetComplete;
  
  const EnhancedExerciseCard({
    Key? key,
    required this.exercise,
    required this.currentSetNumber,
    required this.onSetComplete,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedExerciseCard> createState() => _EnhancedExerciseCardState();
}

class _EnhancedExerciseCardState extends ConsumerState<EnhancedExerciseCard> {
  bool _isTrackingSet = false;
  List<double> _completedSetTimes = [];
  
  // Mock velocity data - in production would come from sensors
  double _currentVelocity = 0.0;
  final double _targetVelocity = 0.45; // m/s for bench press
  final double _personalBestVelocity = 0.52;
  
  void _startSetTracking() {
    setState(() {
      _isTrackingSet = true;
      // Simulate velocity changes
      _simulateVelocity();
    });
  }
  
  void _completeSet() {
    // Add mock time for demo
    final mockTime = 25 + (_completedSetTimes.length * 3.0);
    setState(() {
      _completedSetTimes.add(mockTime);
      _isTrackingSet = false;
    });
    
    // Call parent callback
    if (widget.currentSetNumber <= widget.exercise.sets.length) {
      widget.onSetComplete(widget.exercise.sets[widget.currentSetNumber - 1]);
    }
  }
  
  void _simulateVelocity() {
    if (!_isTrackingSet) return;
    
    // Simulate decreasing velocity over time (fatigue)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || !_isTrackingSet) return;
      
      setState(() {
        _currentVelocity = 0.45 - (_completedSetTimes.length * 0.02);
        _currentVelocity += (DateTime.now().millisecond % 100) / 1000; // Add variation
        _currentVelocity = _currentVelocity.clamp(0.2, 0.6);
      });
      
      _simulateVelocity(); // Continue simulation
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set ${widget.currentSetNumber} of ${widget.exercise.sets.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // Show exercise info
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // TIER-1 Set Execution Timer
            SetExecutionTimerWidget(
              exercise: widget.exercise,
              setNumber: widget.currentSetNumber,
              isTracking: _isTrackingSet,
              onTap: _isTrackingSet ? _completeSet : _startSetTracking,
            ),
            
            // Velocity indicator (if tracking)
            if (_isTrackingSet) ...[
              const SizedBox(height: 16),
              VelocityIndicatorWidget(
                currentVelocity: _currentVelocity,
                targetVelocity: _targetVelocity,
                personalBestVelocity: _personalBestVelocity,
              ),
            ],
            
            // Set times chart (if we have completed sets)
            if (_completedSetTimes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Set Times',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SetTimesChartWidget(
                setTimes: _completedSetTimes,
                currentSetIndex: widget.currentSetNumber - 1,
              ),
            ],
            
            // Current set details
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSetDetail(
                    context,
                    'Weight',
                    '${widget.exercise.sets[widget.currentSetNumber - 1].weight ?? 0} kg',
                    Icons.fitness_center,
                  ),
                  _buildSetDetail(
                    context,
                    'Reps',
                    '${widget.exercise.sets[widget.currentSetNumber - 1].reps ?? 0}',
                    Icons.repeat,
                  ),
                  if (widget.exercise.sets[widget.currentSetNumber - 1].rpe != null)
                    _buildSetDetail(
                      context,
                      'RPE',
                      '${widget.exercise.sets[widget.currentSetNumber - 1].rpe}',
                      Icons.speed,
                    ),
                ],
              ),
            ),
            
            // Action buttons
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTrackingSet ? null : _startSetTracking,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Set'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTrackingSet ? _completeSet : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Complete'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            // Performance insights
            if (_completedSetTimes.length >= 2) ...[
              const SizedBox(height: 16),
              _buildPerformanceInsights(context),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSetDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceInsights(BuildContext context) {
    final avgTime = _completedSetTimes.reduce((a, b) => a + b) / _completedSetTimes.length;
    final lastTime = _completedSetTimes.last;
    final fatigue = ((lastTime - _completedSetTimes.first) / _completedSetTimes.first * 100);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInsight(
                context,
                'Avg Time',
                '${avgTime.toStringAsFixed(1)}s',
                Icons.timer,
                Colors.blue,
              ),
              _buildInsight(
                context,
                'Fatigue',
                '${fatigue.abs().toStringAsFixed(0)}%',
                Icons.battery_alert,
                fatigue > 20 ? Colors.orange : Colors.green,
              ),
              _buildInsight(
                context,
                'Trend',
                fatigue > 0 ? 'Slower' : 'Faster',
                fatigue > 0 ? Icons.trending_up : Icons.trending_down,
                fatigue > 0 ? Colors.orange : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsight(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}