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
  late String _status;
  final FirebaseExerciseImporter _importer = FirebaseExerciseImporter();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _status = context.l10n.importExercisesReady;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.importExercises),
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
              context.l10n.firebaseExerciseImporter,
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
                context.l10n.testSingleExercise,
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
                          context.l10n.importing,
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      context.l10n.importAllExercises,
                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 30),
            Text(
              context.l10n.importExercisesDescription,
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
      _status = context.l10n.testingExercise;
    });

    try {
      await _importer.testSingleExercise();
      setState(() {
        _status = context.l10n.testSuccess;
      });
    } catch (e) {
      setState(() {
        _status = context.l10n.testFailed;
      });
    }
  }

  Future<void> _importAllExercises() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmImportTitle),
        content: Text(
          context.l10n.confirmImportMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.importAction),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isImporting = true;
      _status = context.l10n.importStarting;
    });

    try {
      await _importer.importExercisesFromJson();
      setState(() {
        _isImporting = false;
        _status = context.l10n.importSuccess;
      });
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.importSuccessTitle),
            content: Text(context.l10n.importSuccessMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: Text(context.l10n.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _status = context.l10n.importFailed;
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.importFailedTitle),
            content: Text(context.l10n.error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.ok),
              ),
            ],
          ),
        );
      }
    }
  }
}
