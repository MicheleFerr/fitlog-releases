import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Test screen for lockscreen audio functionality
class LockscreenAudioTestScreen extends StatelessWidget {
  const LockscreenAudioTestScreen({super.key});

  static const _notificationChannel = MethodChannel('com.gymbro/notifications');

  Future<void> _runLockscreenTest() async {
    try {
      await _notificationChannel.invokeMethod('testLockscreenAudio');
    } catch (e) {
      debugPrint('Error running lockscreen test: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lockscreen Audio Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.lockOutline,
                size: 80,
                color: context.colors.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'Test Lockscreen Audio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This test will:\n'
                '1. Configure audio session for lockscreen\n'
                '2. Schedule a notification in 5 seconds\n'
                '3. Play a sound when device is locked\n\n'
                'After pressing the button, lock your device!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _runLockscreenTest,
                icon: const Icon(AppIcons.play),
                label: const Text('Run Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              const Card(
                color: context.colors.secondary,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: context.colors.surface),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Make sure notifications are enabled in Settings!',
                          style: TextStyle(color: context.colors.surface),
                        ),
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
