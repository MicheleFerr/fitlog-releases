import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/tools/firebase_exercise_importer.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class ImportExercisesScreen extends StatefulWidget {
  const ImportExercisesScreen({super.key});

  @override
  State<ImportExercisesScreen> createState() => _ImportExercisesScreenState();
}

class _ImportExercisesScreenState extends State<ImportExercisesScreen> {
  bool _isImporting = false;
  String _status = 'Ready to import exercises';
  final FirebaseExerciseImporter _importer = FirebaseExerciseImporter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Exercises'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              AppIcons.cloudUpload,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Firebase Exercise Importer',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isImporting ? null : _testSingleExercise,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.orange,
              ),
              child: Text(
                '🧪 Test Single Exercise',
                style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isImporting ? null : _importAllExercises,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
              ),
              child: _isImporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Importing...',
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      '🔥 Import All Exercises',
                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 30),
            Text(
              'This will import all exercises from assets/data/exercises.json to Firebase Firestore.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testSingleExercise() async {
    setState(() {
      _status = '🧪 Testing single exercise conversion...';
    });

    try {
      await _importer.testSingleExercise();
      setState(() {
        _status = '✅ Test completed successfully! Check console for details.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Test failed';
      });
    }
  }

  Future<void> _importAllExercises() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: const Text(
          'This will delete all existing exercises and import new ones from JSON. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isImporting = true;
      _status = '🔥 Starting import process...';
    });

    try {
      await _importer.importExercisesFromJson();
      setState(() {
        _isImporting = false;
        _status = '✅ Import completed successfully! All exercises imported to Firebase.';
      });
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Successful'),
            content: const Text('All exercises have been imported to Firebase. You can now use them in the app!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _status = '❌ Import failed';
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Failed'),
            content: Text(context.l10n.error),
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
  }
}
