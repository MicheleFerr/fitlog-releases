import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/timer/presentation/providers/timer_provider.dart';
import 'shared/presentation/l10n/generated/app_localizations.dart';

/// Test page per verificare il suono del timer
class TestTimerAudioPage extends ConsumerWidget {
  const TestTimerAudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Test Timer Audio',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            if (timer != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      timer.formattedTime,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${timer.status.name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 48),
            
            // Test buttons
            Text(
              '🧪 Test Timer Audio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick test buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _TestButton(
                  label: '5 sec',
                  seconds: 5,
                  color: colorScheme.primary,
                  onPressed: () => _startTimer(ref, 5),
                ),
                _TestButton(
                  label: '10 sec',
                  seconds: 10,
                  color: colorScheme.primary,
                  onPressed: () => _startTimer(ref, 10),
                ),
                _TestButton(
                  label: '15 sec',
                  seconds: 15,
                  color: colorScheme.secondary,
                  onPressed: () => _startTimer(ref, 15),
                ),
                _TestButton(
                  label: '30 sec',
                  seconds: 30,
                  color: colorScheme.secondary,
                  onPressed: () => _startTimer(ref, 30),
                ),
                _TestButton(
                  label: '60 sec',
                  seconds: 60,
                  color: colorScheme.tertiary,
                  onPressed: () => _startTimer(ref, 60),
                ),
                _TestButton(
                  label: '120 sec',
                  seconds: 120,
                  color: colorScheme.tertiary,
                  onPressed: () => _startTimer(ref, 120),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '📋 Test Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Start a timer\n'
                    '2. Lock the device or put app in background\n'
                    '3. Wait for timer to complete\n'
                    '4. You should hear the completion sound\n'
                    '5. Check logs in Xcode for debug info',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stop button
            if (timer != null && timer.isActive)
              ElevatedButton(
                onPressed: () => ref.read(timerProvider.notifier).cancel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Stop Timer'),
              ),
          ],
        ),
      ),
    );
  }
  
  static void _startTimer(WidgetRef ref, int seconds) {
    ref.read(timerProvider.notifier).startTimer(
      durationSeconds: seconds,
      exerciseName: 'Test Audio Timer',
      currentSet: 1,
      totalSets: 1,
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final int seconds;
  final Color color;
  final VoidCallback onPressed;
  
  const _TestButton({
    required this.label,
    required this.seconds,
    required this.color,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }
}