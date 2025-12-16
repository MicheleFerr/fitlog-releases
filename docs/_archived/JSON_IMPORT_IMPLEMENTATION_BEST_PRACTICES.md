# 🚀 JSON Import - Implementation Best Practices 2025

**Guida Pratica**: Consigli dalle best practice Flutter 2025 per implementare i 5 priority fixes
**Autore**: AI Developer Assistant
**Date**: October 20, 2025
**Status**: Ready to implement

---

## 1️⃣ File Picker: Approccio Production-Ready

### Setup Dipendenze

```yaml
dependencies:
  file_picker: ^8.0.0
  path: ^1.9.0
```

### Pattern di Validazione Robusto

Implementa controlli multilivello **prima** di leggere il file:

- ✅ **Dimensione massima**: 5MB limite (evita freeze UI)
- ✅ **Estensioni**: `.json` con fallback `FileType.any` + validazione manuale
- ✅ **File vuoti**: Verifica `file.lengthSync() > 0` prima parsing
- ✅ **Permessi**: Gestisci eccezioni per filesystem (desktop/mobile)

### Implementazione Concreta

```dart
// lib/features/workout_templates/presentation/utils/file_import_helper.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileImportHelper {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  static Future<String?> pickAndValidateJsonFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null) return null; // User cancelled

      final file = File(result.files.single.path!);

      // Validate file exists
      if (!await file.exists()) {
        throw FileSystemException('File not found');
      }

      // Validate file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception(
          'File too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB max 5MB)',
        );
      }

      // Validate file not empty
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Read file content
      final content = await file.readAsString(encoding: utf8);

      if (content.trim().isEmpty) {
        throw Exception('File contains no valid content');
      }

      return content;
    } catch (e) {
      rethrow; // Pass to error mapper
    }
  }
}
```

### ⚠️ Nota Importante Android

Su Android, alcuni file explorer di terze parti ignorano le restrizioni MIME. **Soluzione**:

```dart
// Use FileType.any as fallback, then validate extension
FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.any,
  allowMultiple: false,
);

if (result != null) {
  final fileName = result.files.single.name.toLowerCase();
  if (!fileName.endsWith('.json')) {
    throw Exception('Please select a JSON file');
  }
  // Continue with import
}
```

---

## 2️⃣ Error Mapping: Messaggi UX-Friendly

### Architettura Centralizzata

```dart
// lib/features/workout_templates/domain/utils/import_error_mapper.dart

import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class ImportErrorMapper {
  static String mapToUserMessage(dynamic error, AppLocalizations l10n) {
    // JSON parsing errors
    if (error is FormatException) {
      return l10n.error_json_malformed; // "JSON non valido"
    }

    // File system errors
    if (error is FileSystemException) {
      if (error.toString().contains('ENOENT')) {
        return l10n.error_file_not_found;
      }
      if (error.toString().contains('EACCES')) {
        return l10n.error_file_permission;
      }
      return l10n.error_file_access;
    }

    // File size errors
    if (error.toString().contains('File too large')) {
      return l10n.error_file_too_large; // "File troppo grande (max 5MB)"
    }

    if (error.toString().contains('File is empty')) {
      return l10n.error_file_empty;
    }

    // Validation errors
    if (error.toString().contains('Template name is required')) {
      return l10n.error_template_name_missing;
    }

    if (error.toString().contains('exercises')) {
      if (error.toString().contains('empty')) {
        return l10n.error_no_exercises;
      }
      return l10n.error_exercises_invalid;
    }

    if (error.toString().contains('sets')) {
      return l10n.error_sets_required;
    }

    if (error.toString().contains('weight') ||
        error.toString().contains('reps')) {
      return l10n.error_invalid_numbers;
    }

    if (error.toString().contains('Duplicate')) {
      return l10n.error_duplicate_template;
    }

    // Generic fallback
    return l10n.error_import_failed;
  }

  /// Get error context with field info
  static String mapErrorWithContext(String error, String field) {
    if (field.isEmpty) return error;
    return 'Error in $field: $error';
  }
}
```

### Validazione JSON con Pattern Matching (Dart 3)

```dart
// Usa pattern matching per validazione strutturata
factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
  if (json case {
    'name': String name,
    'exercises': List exercises,
  } when name.isNotEmpty && exercises.isNotEmpty) {
    return WorkoutTemplate(
      name: name,
      exercises: exercises.map((e) => Exercise.fromJson(e)).toList(),
    );
  } else {
    throw FormatException(
      'Invalid template: missing "name" or "exercises"',
    );
  }
}
```

### Integrazione in UI

```dart
// templates_home_screen.dart

Future<void> _importFromJson(BuildContext context, String jsonText) async {
  final l10n = AppLocalizations.of(context);

  try {
    final json = jsonDecode(jsonText) as Map<String, dynamic>;
    // ... import logic
  } on FormatException catch (e) {
    final message = ImportErrorMapper.mapToUserMessage(e, l10n);
    SnackBarService.showError(context, message);
  } on FileSystemException catch (e) {
    final message = ImportErrorMapper.mapToUserMessage(e, l10n);
    SnackBarService.showError(context, message);
  } catch (e) {
    final message = ImportErrorMapper.mapToUserMessage(e, l10n);
    SnackBarService.showError(context, message);
  }
}
```

---

## 3️⃣ Progress Dialog: Comunicazione Visuale

### Pattern FutureBuilder + AlertDialog

```dart
// lib/features/workout_templates/presentation/widgets/import_progress_dialog.dart

import 'package:flutter/material.dart';

Future<void> showImportProgress(
  BuildContext context,
  Future<int> importFuture,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // Blocca chiusura accidentale
    builder: (context) => AlertDialog(
      title: const Text('Importing Templates'),
      content: FutureBuilder<int>(
        future: importFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Successo: chiudi automaticamente dopo 1s
            Future.delayed(const Duration(seconds: 1), () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '${snapshot.data} templates imported!',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            final l10n = AppLocalizations.of(context);
            final errorMsg = ImportErrorMapper.mapToUserMessage(
              snapshot.error,
              l10n,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          } else {
            // In progress
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Parsing JSON...'),
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
            );
          }
        },
      ),
    ),
  );
}
```

### Integrazione con State Management

```dart
// templates_home_screen.dart

Future<void> _importFromJson(BuildContext context, String jsonText) async {
  final importFuture = _performImport(jsonText);

  if (context.mounted) {
    await showImportProgress(context, importFuture);
  }
}

Future<int> _performImport(String jsonText) async {
  // Simula operazione asincrona
  await Future.delayed(const Duration(milliseconds: 500));
  return 3; // Templates importati
}
```

---

## 4️⃣ Exercise Disambiguation: Fuzzy Matching

### Setup Dipendenze

```yaml
dependencies:
  string_similarity: ^2.0.0
```

### Implementazione Fuzzy Matching

```dart
// lib/features/workout_templates/data/services/fuzzy_exercise_matching.dart

import 'package:string_similarity/string_similarity.dart';

class FuzzyExerciseMatching {
  static const double minConfidenceThreshold = 0.5;

  static List<ExerciseMatch> findMatches(
    String inputName,
    List<Exercise> database, {
    int maxResults = 5,
  }) {
    final results = <ExerciseMatch>[];

    for (final exercise in database) {
      final score = inputName.similarityTo(exercise.name);

      if (score >= minConfidenceThreshold) {
        results.add(ExerciseMatch(
          exercise: exercise,
          confidence: score,
          reason: _getMatchReason(inputName, exercise.name, score),
        ));
      }
    }

    // Sort by confidence descending
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    return results.take(maxResults).toList();
  }

  static String _getMatchReason(String input, String exerciseName, double score) {
    if (score > 0.9) return 'Exact match';
    if (score > 0.7) return 'Very similar';
    if (score > 0.5) return 'Possible match';
    return 'Similar';
  }
}

class ExerciseMatch {
  final Exercise exercise;
  final double confidence;
  final String reason;

  ExerciseMatch({
    required this.exercise,
    required this.confidence,
    required this.reason,
  });
}
```

### UI Dialog Interattivo

```dart
// lib/features/workout_templates/presentation/widgets/exercise_disambiguation_dialog.dart

Future<Exercise?> showExerciseDisambiguationDialog(
  BuildContext context, {
  required String originalName,
  required List<ExerciseMatch> matches,
}) async {
  return showDialog<Exercise>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm: "$originalName"'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Did you mean one of these?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...matches.map((match) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(match.exercise.name),
                  subtitle: Text(
                    '${match.reason} • ${(match.confidence * 100).toInt()}% match',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(context, match.exercise),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              )).toList(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Keep original name'),
                subtitle: const Text('Create new exercise'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

### Precarica Database Esercizi

```dart
// main.dart or app_startup.dart

Future<void> preloadExerciseDatabase() async {
  try {
    const String jsonString = '''[
      {"id": "1", "name": "Bench Press", "category": "chest"},
      {"id": "2", "name": "Squat", "category": "legs"}
    ]''';

    final List<dynamic> jsonList = json.decode(jsonString);
    final exercises = jsonList
        .map((json) => Exercise.fromJson(json))
        .toList();

    // Cache in memory
    _exerciseDatabase = exercises;
  } catch (e) {
    debugPrint('Failed to preload exercise database: $e');
  }
}
```

---

## 5️⃣ Riverpod State Integration: Architettura MVVM

### Provider con Fasi Strutturate

```dart
// lib/features/workout_templates/presentation/providers/template_import_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'template_import_provider.g.dart';

@freezed
class ImportState with _$ImportState {
  const factory ImportState.idle() = _Idle;
  const factory ImportState.loading({
    required String phase,
    required double progress,
  }) = _Loading;
  const factory ImportState.success(int templatesImported) = _Success;
  const factory ImportState.error(String message) = _Error;
}

@riverpod
class TemplateImportNotifier extends _$TemplateImportNotifier {
  @override
  ImportState build() => const ImportState.idle();

  Future<int> importFromFile(String filePath) async {
    state = const ImportState.loading(phase: 'Parsing JSON', progress: 0.0);

    try {
      // Fase 1: Lettura file (0.0 → 0.2)
      final content = await _readFile(filePath);
      state = state.copyWith(progress: 0.2);

      // Fase 2: Parsing (0.2 → 0.4)
      final templates = await _parseTemplates(content);
      state = const ImportState.loading(phase: 'Matching exercises', progress: 0.4);

      // Fase 3: Exercise matching (0.4 → 0.7)
      final resolved = await _resolveExercises(templates);
      state = state.copyWith(progress: 0.7);

      // Fase 4: Salvataggio (0.7 → 1.0)
      state = const ImportState.loading(phase: 'Saving templates', progress: 0.9);
      final count = await _saveToDatabase(resolved);

      state = ImportState.success(count);
      return count;
    } catch (e, stack) {
      state = ImportState.error(e.toString());
      rethrow;
    }
  }

  Future<void> handleExerciseDisambiguation(
    String exerciseName,
    Exercise selected,
  ) async {
    // Update mapping cache
    // ...
  }

  Future<String> _readFile(String filePath) async {
    // Implementation
    throw UnimplementedError();
  }

  Future<List<WorkoutTemplate>> _parseTemplates(String content) async {
    // Implementation
    throw UnimplementedError();
  }

  Future<List<WorkoutTemplate>> _resolveExercises(
    List<WorkoutTemplate> templates,
  ) async {
    // Implementation
    throw UnimplementedError();
  }

  Future<int> _saveToDatabase(List<WorkoutTemplate> templates) async {
    // Implementation
    throw UnimplementedError();
  }
}

@riverpod
final templateImportProvider = StateNotifierProvider<
  TemplateImportNotifier,
  ImportState
>((ref) {
  return TemplateImportNotifier();
});
```

### UI Connection (MVVM Pattern)

```dart
// templates_home_screen.dart

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(templateImportProvider);

    return importState.when(
      idle: () => _buildImportButton(context, ref),
      loading: (phase, progress) => _buildProgressDialog(phase, progress),
      success: (count) => _buildSuccessMessage(count),
      error: (msg) => _buildErrorAlert(context, msg),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () async {
        final file = await FileImportHelper.pickAndValidateJsonFile();
        if (file != null && context.mounted) {
          await ref.read(templateImportProvider.notifier).importFromFile(file);
        }
      },
      child: const Text('Import Template'),
    );
  }

  Widget _buildProgressDialog(String phase, double progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(phase),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress),
      ],
    );
  }

  Widget _buildSuccessMessage(int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        Text('$count templates imported successfully!'),
      ],
    );
  }

  Widget _buildErrorAlert(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }
}
```

---

## 6️⃣ Localizzazione ARB: Setup Multilingua

### Struttura File

```
lib/l10n/
├── app_en.arb  # Template master (English)
└── app_it.arb  # Italian translation
```

### app_it.arb (Italian)

```json
{
  "@@locale": "it",
  "error_json_malformed": "File JSON non valido",
  "@error_json_malformed": {
    "description": "Errore mostrato quando il JSON è malformato"
  },
  "error_file_not_found": "File non trovato",
  "error_file_permission": "Permesso negato per accedere al file",
  "error_file_access": "Impossibile leggere il file",
  "error_file_too_large": "File troppo grande (massimo {maxSize}MB)",
  "@error_file_too_large": {
    "placeholders": {
      "maxSize": {"type": "int"}
    }
  },
  "error_file_empty": "Il file è vuoto",
  "error_template_name_missing": "Ogni template ha bisogno di un nome",
  "error_no_exercises": "Aggiungi almeno un esercizio",
  "error_exercises_invalid": "I dati degli esercizi non sono validi",
  "error_sets_required": "Ogni esercizio ha bisogno di almeno una serie",
  "error_invalid_numbers": "Pesi e ripetizioni devono essere numeri validi",
  "error_duplicate_template": "Un template con questo nome esiste già",
  "error_import_failed": "Importazione fallita. Controlla il file e riprova.",
  "import_progress_parsing": "Analisi JSON in corso...",
  "import_progress_matching": "Ricerca esercizi: {current}/{total}",
  "@import_progress_matching": {
    "placeholders": {
      "current": {"type": "int"},
      "total": {"type": "int"}
    }
  },
  "import_success": "Importazione completata!",
  "import_cancel": "Annulla"
}
```

### pubspec.yaml Configuration

```yaml
flutter:
  generate: true
  localizations:
    arb-dir: lib/l10n
    template-arb-file: app_en.arb
    output-localization-file: app_localizations.dart
```

### Genera Localizzazioni

```bash
flutter gen-l10n
```

### Usa nei Widget

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.error_json_malformed);
```

---

## 7️⃣ Testing Checklist

### Test Positivi ✅

- [ ] **File JSON valido** → Conteggio corretto templates creati
- [ ] **Batch import** → Nessun duplicato, tutti processati
- [ ] **Large file** → Gestito senza freeze (streaming se possibile)

### Error Handling ✅

- [ ] **JSON malformato** → Messaggio localizzato "JSON non valido"
- [ ] **File vuoto** → Errore specifico
- [ ] **File >5MB** → Blocco preventivo con messaggio
- [ ] **Campi mancanti** → FormatException con dettagli

### Disambiguazione ✅

- [ ] **Esercizio ambiguo** → Dialog mostrato con confidence
- [ ] **Selezione utente** → Applicata, import prosegue
- [ ] **"Keep original"** → Nuovo esercizio creato

### Progress & UX ✅

- [ ] **Progress dialog visibile** durante import
- [ ] **Fasi aggiornate** in tempo reale (0.0 → 1.0)
- [ ] **Chiusura automatica** su successo
- [ ] **Cancel button** funzionante (se implementato)

---

## 📊 Timeline Implementazione

### Settimana 1

**Giorno 1-2**: File picker + Error mapper
- [ ] Aggiungi `file_picker` a pubspec.yaml
- [ ] Implementa `FileImportHelper.pickAndValidateJsonFile()`
- [ ] Crea `ImportErrorMapper`
- [ ] Testa con JSON malformati

**Giorno 3-4**: Progress dialog + UI
- [ ] Crea `import_progress_dialog.dart`
- [ ] Integra con import flow
- [ ] Testa con mock imports

**Giorno 5**: Disambiguazione
- [ ] Setup `string_similarity` package
- [ ] Implementa `FuzzyExerciseMatching`
- [ ] Crea disambiguation dialog
- [ ] Testa con nomi ambigui

### Settimana 2

**Giorno 1-2**: Riverpod + State
- [ ] Aggiorna `template_import_provider.dart`
- [ ] Collega UI a state changes
- [ ] Testa complete flow

**Giorno 3-4**: Localizzazione
- [ ] Crea `app_it.arb`
- [ ] Esegui `flutter gen-l10n`
- [ ] Testa in italiano e inglese

**Giorno 5**: Testing e polish
- [ ] Unit tests per error mapper
- [ ] Widget tests per dialogs
- [ ] Integration tests
- [ ] User testing con utenti interni

---

## 🎯 Metriche Successo

| Metrica | Target |
|---------|--------|
| **Success Rate** | 0% → 85%+ |
| **Time-to-import** | <3 secondi per file <1MB |
| **User Satisfaction** | Feedback positivo da 3+ utenti interni |
| **Error Clarity** | 100% di errori localizzati |
| **Feature Adoption** | 25-30% di active users |

---

## ⚠️ Rischi Critici

### 1. Database Esercizi Mancante
- **Problema**: Blocca disambiguazione
- **Soluzione**: Creare `assets/exercises_it.json` + `exercises_en.json` ASAP
- **Priorità**: 🔴 ALTA

### 2. Cache Issues
- **Problema**: Dopo modifiche asset, app non aggiorna
- **Soluzione**: `flutter clean && flutter pub get`

### 3. Performance Fuzzy Search
- **Problema**: Su 500+ esercizi, matching è lento
- **Soluzione**: Considera indice Trie o BK-Tree per large datasets

---

## 📝 Prossimi Passi

1. ✅ Leggi questo documento completamente
2. 👷 Inizia con Fix #2 (error mapping) - lowest risk
3. 🧪 Testa ogni fix indipendentemente
4. 🔗 Collega tutto insieme
5. 👥 User testing con team interno
6. 🚀 Deploy Phase 1

---

**Status**: Ready to implement
**Est. Effort**: 7-8 ore development + 2-3 ore testing
**Start Date**: This week ideally
**Review Date**: After Phase 1 completion

