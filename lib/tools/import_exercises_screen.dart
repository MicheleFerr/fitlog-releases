import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/tools/firebase_exercise_importer.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

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
        backgroundColor: context.colors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              AppIcons.cloudUpload,
              size: 80,
              color: context.colors.primary,
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
                color: context.colors.surfaceContainer,
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
                backgroundColor: context.colors.secondary,
              ),
              child: Text(
                context.l10n.testSingleExercise,
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.surface),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isImporting ? null : _importAllExercises,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: context.colors.success,
              ),
              child: _isImporting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingIndicator(
                          size: 20,
                          color: context.colors.onPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.importing,
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onPrimary),
                        ),
                      ],
                    )
                  : Text(
                      context.l10n.importAllExercises,
                      style: context.textTheme.bodyMedium?.copyWith(color: context.colors.surface),
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
        final l10n = context.l10n;
        final parentNavigator = Navigator.of(context);
        unawaited(
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
            title: Text(l10n.importSuccessTitle),
            content: Text(l10n.importExercisesSuccessMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  parentNavigator.pop(); // Go back to previous screen
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
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
        final l10n = context.l10n;
        unawaited(
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
            title: Text(l10n.importFailedTitle),
            content: Text(l10n.error),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.ok),
              ),
            ],
          ),
          ),
        );
      }
    }
  }
}
