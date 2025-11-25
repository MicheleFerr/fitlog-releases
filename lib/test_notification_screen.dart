import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/notification_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class TestNotificationScreen extends StatelessWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    
    final soundOptions = [
      {'name': 'Timer Complete', 'file': 'timer_complete'},
      {'name': 'Light Weight', 'file': 'LightWeight'},
      {'name': 'Yeah Buddy', 'file': 'YehBuddie'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notification Sounds'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Immediate Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...soundOptions.map((sound) => Card(
            child: ListTile(
              title: Text(sound['name']!),
              subtitle: Text('Sound file: ${sound['file']}.caf'),
              trailing: ElevatedButton(
                onPressed: () async {
                  // Request permissions first
                  await notificationService.requestPermissions();
                  
                  // Send test notification
                  await notificationService.sendTimerCompletionNotification(
                    exerciseName: 'Test Exercise',
                    currentSet: 1,
                    totalSets: 3,
                    customSoundFile: sound['file'],
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification sent with ${sound['name']} sound'),
                    ),
                  );
                },
                child: const Text('Test'),
              ),
            ),
          )),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Test Scheduled Notifications (5 seconds)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...soundOptions.map((sound) => Card(
            child: ListTile(
              title: Text('${sound['name']} (Scheduled)'),
              subtitle: const Text('Will play in 5 seconds'),
              trailing: ElevatedButton(
                onPressed: () async {
                  // Cancel any existing scheduled notification
                  await notificationService.cancelScheduledTimerNotification();
                  
                  // Schedule new notification
                  await notificationService.scheduleTimerCompletionNotification(
                    delay: const Duration(seconds: 5),
                    exerciseName: 'Scheduled Test',
                    currentSet: 2,
                    totalSets: 3,
                    customSoundFile: sound['file'],
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Scheduled with ${sound['name']} sound (5s)'),
                    ),
                  );
                },
                child: const Text('Schedule'),
              ),
            ),
          )),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () async {
              await notificationService.cancelScheduledTimerNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All scheduled notifications cancelled'),
                ),
              );
            },
            child: const Text('Cancel All Scheduled'),
          ),
        ],
      ),
    );
  }
}