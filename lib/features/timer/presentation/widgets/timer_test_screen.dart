import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/timer_provider.dart';
import '../providers/timer_position_provider.dart';
import 'minimizable_timer_overlay.dart';

/// Screen di test per il timer minimizzabile
/// Utile per testare tutte le gesture e funzionalità
class TimerTestScreen extends ConsumerWidget {
  const TimerTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionState = ref.watch(timerPositionProvider);
    final timer = ref.watch(currentTimerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Test - Gesture Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Background content con istruzioni
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Timer Minimizzabile Demo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                
                // Gesture Instructions
                _buildInstructionCard(
                  icon: Icons.pinch,
                  title: 'Pinch to Scale',
                  description: 'Pinch in per modalità Compact\nPinch out per modalità Expanded',
                  color: Colors.blue,
                ),
                
                _buildInstructionCard(
                  icon: Icons.pan_tool,
                  title: 'Drag to Move',
                  description: 'Trascina il timer ovunque sullo schermo\nSnap automatico ai bordi in modalità Compact',
                  color: Colors.green,
                ),
                
                _buildInstructionCard(
                  icon: Icons.touch_app,
                  title: 'Tap Gestures',
                  description: 'Tap: Cicla tra modalità\nDouble tap: Reset a modalità Normal',
                  color: Colors.orange,
                ),
                
                _buildInstructionCard(
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  description: 'Vibrazione per ogni interazione\nDiversi pattern per ogni gesture',
                  color: Colors.purple,
                ),
                
                const SizedBox(height: 30),
                
                // Status Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 Status Timer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow('Modalità', positionState.mode.name.toUpperCase()),
                        _buildStatusRow('Posizione', '(${positionState.position.dx.toInt()}, ${positionState.position.dy.toInt()})'),
                        _buildStatusRow('Dragging', positionState.isDragging ? 'SÌ' : 'NO'),
                        _buildStatusRow('Snap ai bordi', positionState.isSnappedToEdge ? 'SÌ' : 'NO'),
                        _buildStatusRow('Timer attivo', timer != null ? 'SÌ' : 'NO'),
                        if (timer != null) _buildStatusRow('Tempo rimanente', timer.formattedTime),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Control Buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎮 Controlli Test',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _startTestTimer(ref, 60),
                              icon: const Icon(Icons.timer),
                              label: const Text('Timer 1min'),
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: () => _startTestTimer(ref, 180),
                              icon: const Icon(Icons.timer),
                              label: const Text('Timer 3min'),
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: () => ref.read(currentTimerProvider.notifier).stopTimer(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop Timer'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: () => ref.read(timerPositionProvider.notifier).cycleToNextMode(),
                              icon: const Icon(Icons.crop_free),
                              label: const Text('Cycle Mode'),
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: () => ref.read(timerPositionProvider.notifier).updatePosition(const Offset(20, 100)),
                              icon: const Icon(Icons.restore),
                              label: const Text('Reset Pos'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 100), // Spazio per il timer overlay
              ],
            ),
          ),
          
          // Timer overlay minimizzabile
          const MinimizableTimerOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
  
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
  
  void _startTestTimer(WidgetRef ref, int seconds) {
    ref.read(currentTimerProvider.notifier).startRestTimer(
      exerciseName: 'Test Exercise',
      durationSeconds: seconds,
      currentSet: 1,
      totalSets: 4,
    );
  }
}