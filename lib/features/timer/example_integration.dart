/// Esempio di come integrare il nuovo timer minimizzabile
/// nel WorkoutScreen esistente di GymBro

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import del nuovo timer minimizzabile
import 'presentation/widgets/minimizable_timer_overlay.dart';
import 'presentation/providers/timer_position_provider.dart';

/// Esempio di come modificare il workout_screen.dart
class ExampleWorkoutScreenIntegration extends ConsumerWidget {
  const ExampleWorkoutScreenIntegration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymBro TrackLog'),
      ),
      body: Stack(
        children: [
          // Contenuto principale del workout
          _buildWorkoutContent(),
          
          // CAMBIA QUESTA LINEA:
          // const RestTimerOverlay(),
          
          // CON QUESTA:
          const MinimizableTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildWorkoutContent() {
    return const Center(
      child: Text('Workout Content Here'),
    );
  }
}

/// Esempio di come aggiungere controlli per testare il timer
class TimerDebugControls extends ConsumerWidget {
  const TimerDebugControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionState = ref.watch(timerPositionProvider);
    
    return Positioned(
      bottom: 100,
      left: 20,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timer Debug', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Mode: ${positionState.mode.name}'),
                  Text('Position: (${positionState.position.dx.toInt()}, ${positionState.position.dy.toInt()})'),
                  Text('Dragging: ${positionState.isDragging}'),
                  Text('Snapped: ${positionState.isSnappedToEdge}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => ref.read(timerPositionProvider.notifier).cycleToNextMode(),
                        child: const Text('Cycle Mode'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(timerPositionProvider.notifier).updatePosition(const Offset(20, 100)),
                        child: const Text('Reset Pos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Esempio di utilizzo completo con tutti i componenti
class FullTimerExample extends ConsumerWidget {
  const FullTimerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Minimizzabile - Demo'),
        actions: [
          IconButton(
            onPressed: () {
              // Mostra informazioni sulle gesture
              _showGestureHelp(context);
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background content
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timer Gesture Instructions:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const _GestureInstructionCard(
                  icon: Icons.pinch,
                  title: 'Pinch to Scale',
                  description: 'Pinch in per modalità Compact, Pinch out per Expanded',
                ),
                const _GestureInstructionCard(
                  icon: Icons.pan_tool,
                  title: 'Drag to Move',
                  description: 'Trascina il timer ovunque sullo schermo',
                ),
                const _GestureInstructionCard(
                  icon: Icons.touch_app,
                  title: 'Tap to Cycle',
                  description: 'Tap per ciclare tra modalità, Double tap per reset',
                ),
                const _GestureInstructionCard(
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  description: 'Vibrazione per ogni interazione',
                ),
              ],
            ),
          ),
          
          // Timer overlay minimizzabile
          const MinimizableTimerOverlay(),
          
          // Debug controls (rimuovi in produzione)
          if (const bool.fromEnvironment('DEBUG_TIMER', defaultValue: false))
            const TimerDebugControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Avvia un timer di esempio per testing
          _startExampleTimer(ref);
        },
        child: const Icon(Icons.timer),
      ),
    );
  }

  void _startExampleTimer(WidgetRef ref) {
    ref.read(currentTimerProvider.notifier).startRestTimer(
      exerciseName: 'Push-ups',
      durationSeconds: 120, // 2 minuti
      currentSet: 1,
      totalSets: 4,
    );
  }

  void _showGestureHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Gesture Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤏 Pinch in/out - Cambia dimensione'),
            Text('👆 Drag - Sposta il timer'),
            Text('👆 Tap - Cicla modalità'),
            Text('👆👆 Double tap - Reset a Normal'),
            Text('📳 Haptic feedback per ogni azione'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GestureInstructionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GestureInstructionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}