import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/timer_sound.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Dialog to test timer sounds directly on iOS
class TimerSoundTestDialog extends ConsumerStatefulWidget {
  const TimerSoundTestDialog({super.key});

  @override
  ConsumerState<TimerSoundTestDialog> createState() => _TimerSoundTestDialogState();
}

class _TimerSoundTestDialogState extends ConsumerState<TimerSoundTestDialog> {
  static const _testChannel = MethodChannel('com.gymbro.sound_test');
  bool _isTestRunning = false;
  String _testStatus = '';

  Future<void> _runSoundTest() async {
    setState(() {
      _isTestRunning = true;
      _testStatus = 'Running sound test...';
    });

    try {
      // Run iOS native sound test
      await _testChannel.invokeMethod('testSounds');
      
      setState(() {
        _testStatus = 'Test notifications scheduled!\n\n'
            'You should hear:\n'
            '• timer_complete at 5 seconds\n'
            '• LightWeight at 8 seconds\n'
            '• YehBuddie at 11 seconds\n\n'
            'Make sure your phone is not in silent mode!';
      });
    } catch (e) {
      setState(() {
        _testStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isTestRunning = false;
      });
    }
  }

  Future<void> _testSpecificSound(TimerSound sound) async {
    final config = ref.read(appConfigProvider);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing ${sound.displayName} sound in 3 seconds...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Start a 3-second timer with the specific sound
    await ref.read(unifiedTimerProvider.notifier).startTimer(
      durationSeconds: 3,
      type: TimerType.rest,
      exerciseName: 'Sound Test',
      customSound: sound.fileName,
    );
  }

  Future<void> _clearTests() async {
    try {
      await _testChannel.invokeMethod('clearTests');
      setState(() {
        _testStatus = 'Test notifications cleared';
      });
    } catch (e) {
      setState(() {
        _testStatus = 'Error clearing tests: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final currentSound = TimerSound.fromFileName(config.timerSound);

    return AlertDialog(
      title: const Text('Test Timer Sounds'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Sound: ${currentSound.getLocalizedName()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Individual sound test buttons
            const Text(
              'Test Individual Sounds:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            for (final sound in TimerSound.values) ...[
              ListTile(
                leading: Icon(
                  sound == currentSound ? AppIcons.complete : Icons.circle_outlined,
                  color: sound == currentSound ? Colors.green : null,
                ),
                title: Text(sound.getLocalizedName()),
                subtitle: const Text('Tap to test with 3-second timer'),
                onTap: () => _testSpecificSound(sound),
              ),
            ],
            
            const Divider(height: 24),
            
            // iOS notification test
            const Text(
              'iOS Notification Test:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isTestRunning ? null : _runSoundTest,
              icon: _isTestRunning 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(AppIcons.play),
              label: const Text('Run Full Sound Test'),
            ),
            
            const SizedBox(height: 8),
            
            if (_testStatus.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testStatus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Important:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Make sure your phone is NOT in silent mode'),
                  Text('• Check that notification sounds are enabled'),
                  Text('• Volume should be turned up'),
                  Text('• App needs notification permissions'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _clearTests,
          child: const Text('Clear Tests'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.close),
        ),
      ],
    );
  }
}

/// Helper function to show the test dialog
void showTimerSoundTestDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const TimerSoundTestDialog(),
  );
}
