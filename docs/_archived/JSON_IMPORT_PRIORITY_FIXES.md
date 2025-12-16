# 🎯 JSON Import System - Priority Fixes & Implementation Guide

**Quick Reference**: 5 critical fixes to enable UX improvement
**Time to Implement**: ~2-3 weeks
**Impact**: Unblocks all user import workflows

---

## ✅ Priority Fix #1: File Picker Support

**Severity**: 🔴 CRITICAL
**Time**: 3-4 hours
**Impact**: Enable file-based import (currently broken)

### What's Broken
```dart
// Current: throws UnimplementedError
Future<String> _readFileContent(String filePath) async {
  throw UnimplementedError('File reading not implemented for this platform');
}
```

### Fix Required

**File**: `lib/features/workout_templates/domain/services/batch_import_service.dart`

**Add dependency to pubspec.yaml**:
```yaml
dependencies:
  file_picker: ^8.0.0
```

**Implement file reading**:
```dart
import 'dart:io';
import 'dart:convert';

Future<String> _readFileContent(String filePath) async {
  try {
    final file = File(filePath);

    // Check file exists
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    // Check file size (max 5MB)
    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      throw Exception('File too large. Maximum 5MB allowed. Current: ${(size / 1024 / 1024).toStringAsFixed(1)}MB');
    }

    // Read file
    final content = await file.readAsString(encoding: utf8);

    if (content.isEmpty) {
      throw Exception('File is empty');
    }

    return content;
  } catch (e) {
    throw Exception('Failed to read file: $e');
  }
}
```

**Add UI for file selection**:
```dart
// In templates_home_screen.dart - add to _createNewTemplate()

import 'package:file_picker/file_picker.dart';

Future<void> _importFromFile(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json', 'txt'],
    withData: true,
  );

  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    final jsonText = String.fromCharCodes(file.bytes!);
    await _importFromJson(context, jsonText);
  }
}
```

**Update UI modal**:
```dart
void _createNewTemplate(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text(l10n.createManually),
          onTap: () {
            Navigator.pop(context);
            context.push('/templates/create');
          },
        ),
        ListTile(
          leading: Icon(Icons.upload_file),
          title: Text('Import from File'),  // NEW
          subtitle: Text('JSON or TXT file'),
          onTap: () {
            Navigator.pop(context);
            _importFromFile(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.content_paste),
          title: Text(l10n.importFromJSON),
          subtitle: Text('Paste JSON'),
          onTap: () {
            Navigator.pop(context);
            _showJsonImportDialog(context);
          },
        ),
      ],
    ),
  );
}
```

---

## ✅ Priority Fix #2: User-Friendly Error Messages

**Severity**: 🔴 CRITICAL
**Time**: 4-5 hours
**Impact**: Users can understand and fix errors

### What's Wrong
```dart
// Current: Raw exception strings confuse users
SnackBarService.showError(
  context,
  l10n.errorImportingJSON(e.toString()), // ❌ "Invalid JSON format: FormatException: Unexpected character at line 5, column 10"
);
```

### Fix Required

**Create error mapper** - New file `lib/features/workout_templates/domain/utils/import_error_mapper.dart`:

```dart
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class ImportErrorMapper {
  static String mapError(String error, AppLocalizations l10n) {
    // JSON parsing errors
    if (error.contains('FormatException')) {
      return 'Invalid JSON format. Check for missing commas, brackets, or quotes.';
    }

    // Missing required fields
    if (error.contains('Template name is required')) {
      return 'Each template needs a name (e.g., "name": "Push Day")';
    }

    if (error.contains('exercises')) {
      if (error.contains('empty')) {
        return 'Add at least one exercise to your template';
      }
      return 'Make sure each exercise has a name and sets';
    }

    if (error.contains('sets')) {
      return 'Each exercise needs at least one set with reps and weight';
    }

    if (error.contains('name')) {
      return 'Exercise or set name is missing. Check your JSON.';
    }

    if (error.contains('weight') || error.contains('reps')) {
      return 'Check that weight and reps are valid numbers';
    }

    if (error.contains('Duplicate')) {
      return 'A template with this name already exists. It will be renamed.';
    }

    if (error.contains('File not found')) {
      return 'The file does not exist. Select a valid file.';
    }

    if (error.contains('too large')) {
      return 'File is too large. Maximum 5MB allowed.';
    }

    if (error.contains('empty')) {
      return 'JSON content is empty. Paste some content.';
    }

    // Default user-friendly error
    return 'Import failed. Please check your JSON format and try again.';
  }

  static String mapErrorWithContext(String error, String field) {
    if (field.isEmpty) return 'Invalid data';

    return 'Error in $field: ${mapError(error, null)}';
  }
}
```

**Update templates_home_screen.dart**:
```dart
import 'package:gymbro_flutter_new/features/workout_templates/domain/utils/import_error_mapper.dart';

Future<void> _importFromJson(BuildContext context, String jsonText) async {
  final l10n = AppLocalizations.of(context);
  try {
    // ... existing code ...
  } catch (e) {
    final userMessage = ImportErrorMapper.mapError(e.toString(), l10n);
    SnackBarService.showError(
      context,
      userMessage, // ✅ User-friendly!
    );
  }
}
```

**Add localization keys** - In `assets/i18n/app_en.arb`:
```json
{
  "errorJsonInvalid": "Invalid JSON format. Check brackets and commas.",
  "errorTemplateName": "Each template needs a name",
  "errorNoExercises": "Add at least one exercise",
  "errorExerciseName": "Exercise name is missing",
  "errorNoSets": "Each exercise needs at least one set",
  "errorInvalidWeight": "Weight must be a number",
  "errorInvalidReps": "Reps must be a number",
  "errorFileTooLarge": "File is too large (max 5MB)",
  "errorFileNotFound": "File not found"
}
```

---

## ✅ Priority Fix #3: Import Progress Dialog

**Severity**: 🔴 CRITICAL
**Time**: 5-6 hours
**Impact**: Users see import is working, not frozen

### What's Missing
Currently no loading indicator during import.

### Fix Required

**Create progress dialog** - New file `lib/features/workout_templates/presentation/widgets/import_progress_dialog.dart`:

```dart
import 'package:flutter/material.dart';

class ImportProgressDialog extends StatelessWidget {
  final double progress;
  final String currentPhase;
  final String currentStep;
  final bool isCompleted;
  final VoidCallback? onCancel;

  const ImportProgressDialog({
    this.progress = 0.0,
    this.currentPhase = 'Initializing...',
    this.currentStep = '',
    this.isCompleted = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompleted) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                l10n.importing,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                currentPhase,
                style: theme.textTheme.bodyMedium,
              ),
              if (currentStep.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  currentStep,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              if (onCancel != null)
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(l10n.cancel),
                  onPressed: onCancel,
                ),
            ] else ...[
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.importSuccess,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Update templates_home_screen.dart**:
```dart
Future<void> _importFromJson(BuildContext context, String jsonText) async {
  final l10n = AppLocalizations.of(context);

  // Show progress dialog
  final progressNotifier = ValueNotifier<Map<String, dynamic>>({
    'progress': 0.0,
    'phase': 'Parsing JSON...',
    'step': '',
  });

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ValueListenableBuilder(
      valueListenable: progressNotifier,
      builder: (context, value, _) => ImportProgressDialog(
        progress: value['progress'] as double,
        currentPhase: value['phase'] as String,
        currentStep: value['step'] as String,
        onCancel: () => Navigator.pop(dialogContext),
      ),
    ),
  );

  try {
    // Simulate progress updates
    progressNotifier.value = {'progress': 0.25, 'phase': 'Validating...', 'step': ''};

    final json = jsonDecode(jsonText) as Map<String, dynamic>;

    // ... rest of import logic ...

    progressNotifier.value = {'progress': 1.0, 'phase': 'Complete!', 'step': ''};

    Navigator.pop(context); // Close dialog

  } catch (e) {
    Navigator.pop(context); // Close dialog
    SnackBarService.showError(context, e.toString());
  }
}
```

---

## ✅ Priority Fix #4: Exercise Disambiguation UI

**Severity**: 🟠 HIGH
**Time**: 6-8 hours
**Impact**: Users can resolve exercise name conflicts

### What's Missing
Backend finds exercise suggestions but UI not implemented.

### Fix Required

**Create disambiguation dialog** - Update `lib/features/workout_templates/presentation/widgets/exercise_selection_dialog.dart`:

```dart
class ExerciseDisambiguationDialog extends StatefulWidget {
  final String originalName;
  final List<ExerciseOption> suggestions;
  final Function(String? selected) onSelected;

  const ExerciseDisambiguationDialog({
    required this.originalName,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  State<ExerciseDisambiguationDialog> createState() => _ExerciseDisambiguationDialogState();
}

class _ExerciseDisambiguationDialogState extends State<ExerciseDisambiguationDialog> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text('Select exercise'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You searched for: "${widget.originalName}"',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Did you mean one of these?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...widget.suggestions.map((suggestion) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                value: suggestion.id,
                groupValue: _selectedId,
                onChanged: (value) => setState(() => _selectedId = value),
                title: Text(suggestion.name),
                subtitle: Text(
                  'Confidence: ${(suggestion.confidence * 100).toInt()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            )).toList(),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'skip',
              groupValue: _selectedId,
              onChanged: (value) => setState(() => _selectedId = value),
              title: const Text('Keep original name'),
              subtitle: const Text('Use as-is'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selectedId != null
            ? () {
              widget.onSelected(_selectedId == 'skip' ? null : _selectedId);
              Navigator.pop(context);
            }
            : null,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
```

**Show during import** - In `templates_home_screen.dart`:
```dart
// When exercise matching finds ambiguities
if (matches.isNotEmpty) {
  final selected = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ExerciseDisambiguationDialog(
      originalName: exerciseName,
      suggestions: matches.map((m) => ExerciseOption(
        id: m.exercise.id,
        name: m.exercise.nome,
        confidence: m.similarity,
      )).toList(),
      onSelected: (selected) {
        // Apply selection
      },
    ),
  );
}
```

---

## ✅ Priority Fix #5: Connection to Provider State

**Severity**: 🟠 HIGH
**Time**: 4-5 hours
**Impact**: Bridge between UI and business logic

### What's Missing
Import provider exists but not connected to UI flow.

### Fix Required

**Update template_import_provider.dart** - Connect all phases:

```dart
// Expose public methods to handle user interactions
class TemplateImportNotifier extends StateNotifier<TemplateImportState> {

  /// Process JSON from user input
  Future<void> importJsonWithProgress(String jsonText) async {
    try {
      _updateProgress(0.1, 'Parsing JSON...');
      state = state.copyWith(currentPhase: ImportPhase.parsing);

      await importFromJson(jsonText);

      // After all phases complete
      if (state.errors.isEmpty) {
        _updateProgress(1.0, 'Import complete!');
        state = state.copyWith(currentPhase: ImportPhase.completed);
      }
    } catch (e) {
      state = state.copyWith(
        errors: [ImportError(message: e.toString(), field: 'import', isBlocking: true)],
        progress: 0.0,
      );
    }
  }

  /// Handle exercise disambiguation selection
  void selectExerciseOption(String disambiguationId, String selectedExerciseId) {
    final updated = state.exerciseDisambiguations
        .map((d) => d.exerciseId == disambiguationId
            ? d.copyWith(selectedExercise: selectedExerciseId)
            : d)
        .toList();

    state = state.copyWith(exerciseDisambiguations: updated);
  }

  /// Confirm all disambiguations done
  Future<void> proceedAfterDisambiguation() async {
    if (state.exerciseDisambiguations.any((d) => d.selectedExercise == null)) {
      state = state.copyWith(
        errors: [
          ImportError(
            message: 'Please select exercises for all ambiguities',
            field: 'disambiguation',
            isBlocking: false,
          ),
        ],
      );
      return;
    }

    await _processPercentageConversion();
  }

  /// Get import status
  String getStatusMessage() {
    if (state.currentPhase == ImportPhase.completed) {
      return 'Import successful! ${state.finalTemplates.length} templates added.';
    }
    if (state.errors.isNotEmpty) {
      return 'Import failed: ${state.errors.first.message}';
    }
    return state.currentStep ?? 'Processing...';
  }
}
```

---

## 📋 Implementation Checklist

### Phase 1: Critical Fixes (2 weeks)

- [ ] **Fix #1: File Picker**
  - [ ] Add `file_picker` to pubspec.yaml
  - [ ] Implement `_readFileContent()`
  - [ ] Add "Import from File" UI option
  - [ ] Test file selection and import
  - [ ] Test file size validation

- [ ] **Fix #2: User-Friendly Errors**
  - [ ] Create `import_error_mapper.dart`
  - [ ] Map all technical errors to user messages
  - [ ] Add localization keys
  - [ ] Update error display in UI
  - [ ] Test with various JSON errors

- [ ] **Fix #3: Progress Dialog**
  - [ ] Create `import_progress_dialog.dart`
  - [ ] Integrate into import flow
  - [ ] Add phase tracking
  - [ ] Add cancel button
  - [ ] Test with mock imports

- [ ] **Fix #4: Exercise Disambiguation**
  - [ ] Update `exercise_selection_dialog.dart`
  - [ ] Connect to matching service
  - [ ] Show confidence scores
  - [ ] Handle user selection
  - [ ] Test with ambiguous names

- [ ] **Fix #5: Provider Connection**
  - [ ] Update `template_import_provider.dart`
  - [ ] Expose new methods
  - [ ] Connect UI to state changes
  - [ ] Test complete flow
  - [ ] Handle all error scenarios

### Phase 2: Testing

- [ ] Unit tests for error mapper
- [ ] Widget tests for dialogs
- [ ] Integration tests for full import flow
- [ ] Test with real JSON files
- [ ] Test edge cases (empty, huge, invalid)

### Phase 3: Documentation

- [ ] Update user guide
- [ ] Add import tutorial
- [ ] Document JSON format
- [ ] Create example templates
- [ ] Add troubleshooting FAQ

---

## 🔍 Testing Scenarios

### Test 1: File Import
```
1. Click "Import from File"
2. Select valid JSON file
3. Import completes
Expected: ✅ Templates added
```

### Test 2: Error Handling
```
1. Paste invalid JSON
2. Click "Import"
Expected: ✅ User-friendly error shown
```

### Test 3: Exercise Disambiguation
```
1. Import template with ambiguous exercise name
2. Dialog shows suggestions
3. User selects correct exercise
Expected: ✅ Exercise matched correctly
```

### Test 4: Progress Tracking
```
1. Start large import
2. Watch progress dialog update
Expected: ✅ Progress moves from 0→100%
```

---

## 📌 File Changes Summary

| File | Change | Time |
|------|--------|------|
| pubspec.yaml | Add `file_picker` | 5 min |
| batch_import_service.dart | Implement file reading | 1 hr |
| import_error_mapper.dart | NEW - Error mapping | 1.5 hrs |
| templates_home_screen.dart | Update UI, wire fixes | 2 hrs |
| import_progress_dialog.dart | NEW - Progress UI | 1.5 hrs |
| exercise_selection_dialog.dart | Update for disambiguation | 1.5 hrs |
| template_import_provider.dart | Connect state | 1 hr |
| app_en.arb / app_it.arb | Add localization | 30 min |

**Total**: ~9-10 hours of development

---

## 💡 Quick Tips

1. **Start with Fix #2** (error mapping) - lowest risk, highest impact
2. **Test each fix** independently before combining
3. **Use mock data** during development (file picker, exercises)
4. **Get user feedback** early on error messages
5. **Document JSON format** clearly for users

---

**Last Updated**: October 20, 2025
**Next Update**: After Phase 1 implementation
