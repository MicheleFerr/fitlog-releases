/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: debug
/// 🎯 Feature: workout
/// 🔧 Type: debug_screen
/// 🌍 Localization: N/A
/// 🎨 Theme: Universal
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/debug/exercise_history_debug.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class ExerciseHistoryDebugScreen extends ConsumerStatefulWidget {
  const ExerciseHistoryDebugScreen({super.key});

  @override
  ConsumerState<ExerciseHistoryDebugScreen> createState() => _ExerciseHistoryDebugScreenState();
}

class _ExerciseHistoryDebugScreenState extends ConsumerState<ExerciseHistoryDebugScreen> {
  final _exerciseController = TextEditingController();
  bool _isRunning = false;

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _runDebugFunction(Future<void> Function() debugFunction) async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });
    
    try {
      await debugFunction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Debug function completed. Check console for output.'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug function failed: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise History Debug'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (userId == null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'User not authenticated. Please login first.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current User:',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userId,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Text(
              'Debug Functions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Inspect all Hive data
            ElevatedButton(
              onPressed: _isRunning ? null : () => _runDebugFunction(() => ExerciseHistoryDebug.inspectHiveData(userId: userId)),
              child: const Text('Inspect All Hive Data'),
            ),
            const SizedBox(height: 8),
            
            // Test exercise name variations
            if (userId != null) ...[
              ElevatedButton(
                onPressed: _isRunning ? null : () => _runDebugFunction(() => ExerciseHistoryDebug.testExerciseNameVariations(userId: userId)),
                child: const Text('Test Exercise Name Variations'),
              ),
              const SizedBox(height: 16),
              
              // Test specific exercise
              Text(
                'Test Specific Exercise',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exerciseController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Bench Press',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRunning || _exerciseController.text.trim().isEmpty 
                          ? null 
                          : () => _runDebugFunction(() => ExerciseHistoryDebug.testExerciseHistory(
                                exerciseName: _exerciseController.text.trim(),
                                userId: userId,
                              )),
                      child: const Text('Test Exercise History'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRunning || _exerciseController.text.trim().isEmpty 
                          ? null 
                          : () => _runDebugFunction(() => ExerciseHistoryDebug.findWorkoutsWithExercise(
                                exerciseName: _exerciseController.text.trim(),
                                userId: userId,
                              )),
                      child: const Text('Find Workouts'),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            if (_isRunning) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              Text(
                'Running debug function...\nCheck the console for detailed output.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Open your device console/logs to see detailed output\n'
                    '2. Run "Inspect All Hive Data" to see all workout data\n'
                    '3. Run "Test Exercise Name Variations" to check all exercises\n'
                    '4. Enter a specific exercise name to test history retrieval\n'
                    '5. Look for debug prints starting with 🔍, ✅, or ❌',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}