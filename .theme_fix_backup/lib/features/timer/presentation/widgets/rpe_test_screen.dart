import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/live_activity_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/rpe_live_activity_widget.dart';

/// Screen di test per il sistema RPE Live Activities
class RPETestScreen extends ConsumerWidget {
  const RPETestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test RPE Live Activity'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎯 Test del Sistema RPE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Questo widget simula il comportamento delle Live Activities per l\'input RPE dopo il completamento di un set.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Simulazione Live Activity RPE
            RPELiveActivityWidget(
              rpeData: RPELiveActivityData(
                exerciseName: 'Bench Press',
                targetReps: 10,
                weight: 80.0,
                currentSet: 2,
                totalSets: 4,
                workoutName: 'Push Day',
                timestamp: DateTime.now(),
              ),
              activityId: 'test_activity_id',
            ),
            
            const SizedBox(height: 32),
            
            // Widget compatto per iOS
            const Text(
              '📱 Versione Compatta (iOS Live Activity)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            CompactRPELiveActivityWidget(
              rpeData: RPELiveActivityData(
                exerciseName: 'Bench Press',
                targetReps: 10,
                weight: 80.0,
                currentSet: 2,
                totalSets: 4,
                workoutName: 'Push Day',
                timestamp: DateTime.now(),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Test button
            ElevatedButton.icon(
              onPressed: () => _testRPESystem(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('🧪 Testa Sistema RPE'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Spiegazione
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Come Funziona',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Timer termina → Audio + Live Activity RPE\n'
                    '2. Utente modifica reps se necessario\n'
                    '3. Utente seleziona RPE (5-10)\n'
                    '4. Conferma → Set completato → Prossimo set\n'
                    '5. Design senza ombreggiature come richiesto',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testRPESystem(BuildContext context, WidgetRef ref) async {
    final liveActivityService = ref.read(liveActivityProvider);
    
    try {
      // Simula avvio RPE interface
      final activityId = await liveActivityService.showRPEInterface(
        exerciseName: 'Test Exercise',
        targetReps: 12,
        weight: 60.0,
        currentSet: 1,
        totalSets: 3,
        workoutName: 'Test Workout',
      );
      
      if (activityId != null) {
        // Setup callbacks
        liveActivityService.setupRPECallbacks(
          onRPEConfirmed: (actualReps, rpe, notes) {
            _showTestResult(context, 'RPE Confermato', 
                'Reps: $actualReps, RPE: $rpe, Note: $notes');
          },
          onRPECancelled: () {
            _showTestResult(context, 'RPE Cancellato', 
                'L\'utente ha cancellato l\'input RPE');
          },
          onRepsModified: (newReps) {
            _showTestResult(context, 'Reps Modificate', 
                'Nuove reps: $newReps');
          },
        );
        
        _showTestResult(context, 'Test Avviato', 
            'RPE Interface creata con ID: $activityId');
      } else {
        _showTestResult(context, 'Test Fallito', 
            'Impossibile creare RPE Interface');
      }
      
    } catch (e) {
      _showTestResult(context, 'Errore Test', 
          'Errore durante test: $e');
    }
  }

  void _showTestResult(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}