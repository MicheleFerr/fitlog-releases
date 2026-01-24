/// Script per pubblicare esercizi su Firebase
///
/// Esegui con:
/// ```bash
/// cd /Users/michele/gymbro_flutter_new
/// flutter run -t scripts/publish_exercises_to_firebase.dart -d macos
/// ```
///
/// Oppure usa l'admin screen nell'app: Settings > Admin > Database Manager > Publish New Version
library;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/exercise_publish_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - handle case where it's already initialized natively on iOS
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Already initialized (common on iOS where native init happens first)
    debugPrint('Firebase already initialized: $e');
  }

  runApp(const PublishExercisesApp());
}

class PublishExercisesApp extends StatelessWidget {
  const PublishExercisesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Publish Exercises',
      theme: ThemeData.dark(),
      home: const PublishScreen(),
    );
  }
}

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  String _status = 'Ready to publish';
  bool _isPublishing = false;
  final List<String> _logs = [];

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
    debugPrint(message);
  }

  Future<void> _publishExercises() async {
    if (_isPublishing) return;

    setState(() {
      _isPublishing = true;
      _status = 'Publishing...';
      _logs.clear();
    });

    final service = ExercisePublishService();

    try {
      // Get current version
      final currentVersion = await service.getCurrentVersion();
      _log('📊 Current version on Firebase: $currentVersion');

      // Publish version 2.0.0 (as per design document)
      const newVersion = '2.0.0';
      const changelog = [
        'Upload completo database 2282 esercizi',
        'Fix inconsistenze collection Firebase',
        'Sync collection exercises_it e exercises_en',
      ];

      _log('');
      _log('📤 Publishing version $newVersion...');
      _log('   Changelog entries: ${changelog.length}');

      await service.publishNewVersion(
        version: newVersion,
        changelogEntries: changelog,
        isRequired: false,
      );

      _log('');
      _log('✅ SUCCESS! Version $newVersion published');
      _log('');
      _log('📋 Next steps:');
      _log('   1. Verify Firebase Console');
      _log('   2. Delete orphan collections');

      setState(() {
        _status = '✅ Published v2.0.0!';
      });

    } catch (e) {
      _log('');
      _log('❌ FAILED: $e');
      setState(() {
        _status = '❌ Failed: $e';
      });
    } finally {
      setState(() {
        _isPublishing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Exercises to Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version: 2.0.0', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('This will upload 2282 exercises to Firebase:'),
                    const Text('• exercises_it collection'),
                    const Text('• exercises_en collection'),
                    const Text('• exercises_metadata/version_info'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isPublishing ? null : _publishExercises,
                      icon: _isPublishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isPublishing ? 'Publishing...' : 'Publish Now'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Status: $_status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
