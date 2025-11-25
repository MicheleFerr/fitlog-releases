/// Script per normalizzare exercises_it.json
///
/// Esegui con: dart scripts/normalize_exercises.dart
///
/// Normalizzazioni:
/// 1. Nomi italiani corretti (capitalizzazione)
/// 2. Pattern movimento specifici (no "Vario")
/// 3. Attrezzatura standardizzata
/// 4. Aliases IT/EN aggiunti
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Normalizzazione Exercises IT...\n');

  // Leggi JSON
  final file = File('assets/data/exercises_it.json');
  if (!file.existsSync()) {
    print('❌ File non trovato: ${file.path}');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);

  print('📊 Totale esercizi: ${exercises.length}\n');

  // Normalizza ogni esercizio
  int normalized = 0;
  for (var i = 0; i < exercises.length; i++) {
    final exercise = exercises[i] as Map<String, dynamic>;

    // Progress indicator
    if ((i + 1) % 50 == 0) {
      print('   Processati: ${i + 1}/${exercises.length}');
    }

    var modified = false;

    // 1. Normalizza nome italiano
    if (exercise['nome'] != null) {
      final originalNome = exercise['nome'] as String;
      final normalizedNome = normalizeNomeItaliano(originalNome);
      if (normalizedNome != originalNome) {
        exercise['nome'] = normalizedNome;
        modified = true;
      }
    }

    // 2. Normalizza pattern movimento (sostituisci "Vario")
    if (exercise['patternMovimento'] == 'Vario' ||
        exercise['patternMovimento'] == '' ||
        exercise['patternMovimento'] == null) {
      final newPattern = inferPatternMovimento(exercise);
      if (newPattern != null) {
        exercise['patternMovimento'] = newPattern;
        modified = true;
      }
    }

    // 3. Normalizza attrezzatura
    if (exercise['attrezzatura'] != null) {
      final originalAttr = exercise['attrezzatura'] as String;
      final normalizedAttr = normalizeAttrezzatura(originalAttr);
      if (normalizedAttr != originalAttr) {
        exercise['attrezzatura'] = normalizedAttr;
        modified = true;
      }
    }

    // 4. Aggiungi aliases se mancanti
    if (exercise['aliases'] == null || (exercise['aliases'] as List).isEmpty) {
      final aliases = generateAliases(exercise);
      if (aliases.isNotEmpty) {
        exercise['aliases'] = aliases;
        modified = true;
      }
    }

    if (modified) normalized++;
  }

  print('\n✅ Normalizzati: $normalized esercizi\n');

  // Backup originale
  final backup = File('assets/data/exercises_it.json.backup');
  await file.copy(backup.path);
  print('💾 Backup salvato: ${backup.path}');

  // Salva JSON normalizzato (pretty-printed)
  const encoder = JsonEncoder.withIndent('  ');
  final prettyJson = encoder.convert(exercises);
  await file.writeAsString(prettyJson);

  print('✅ File salvato: ${file.path}');
  print('\n🎉 Normalizzazione completata!\n');
}

/// Normalizza nome italiano (capitalizzazione corretta)
String normalizeNomeItaliano(String nome) {
  // Lowercase first
  final normalized = nome.toLowerCase();

  // Capitalizza prima lettera di ogni parola (tranne preposizioni)
  final words = normalized.split(' ');
  final exceptions = {'con', 'a', 'di', 'da', 'in', 'su', 'per', 'e', 'o'};

  for (var i = 0; i < words.length; i++) {
    if (i == 0 || !exceptions.contains(words[i])) {
      words[i] = capitalize(words[i]);
    }
  }

  return words.join(' ');
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Inferisci pattern movimento da nome/focus esercizio
String? inferPatternMovimento(Map<String, dynamic> exercise) {
  final nome = (exercise['nome'] as String?)?.toLowerCase() ?? '';
  final focus = (exercise['focus'] as String?)?.toLowerCase() ?? '';

  // Push patterns
  if (nome.contains('panca') || nome.contains('bench') ||
      nome.contains('push up') || nome.contains('dip')) {
    return 'Push Pattern';
  }

  // Pull patterns
  if (nome.contains('traz') || nome.contains('pull') ||
      nome.contains('row') || nome.contains('rema')) {
    return 'Pull Pattern';
  }

  // Squat patterns
  if (nome.contains('squat') || nome.contains('accosciat')) {
    return 'Squat Pattern';
  }

  // Hinge patterns (stacco, good morning)
  if (nome.contains('stacco') || nome.contains('deadlift') ||
      nome.contains('good morning') || nome.contains('hip hinge')) {
    return 'Hinge Pattern';
  }

  // Lunge patterns
  if (nome.contains('lunge') || nome.contains('affondo') ||
      nome.contains('split squat') || nome.contains('bulgarian')) {
    return 'Lunge Pattern';
  }

  // Isolation (curl, extension, fly, raise)
  if (nome.contains('curl') || nome.contains('extension') ||
      nome.contains('fly') || nome.contains('raise') ||
      nome.contains('lateral') || nome.contains('apertur')) {
    return 'Isolation';
  }

  // Core/Anti-rotation
  if (focus.contains('core') || focus.contains('addom') ||
      nome.contains('plank') || nome.contains('crunch') ||
      nome.contains('sit up') || nome.contains('russian twist')) {
    return 'Anti-Rotation / Core Stability';
  }

  // Carry patterns
  if (nome.contains('carry') || nome.contains('farmer') ||
      nome.contains('waiter walk')) {
    return 'Carry Pattern';
  }

  // Default se non riconosciuto
  return 'Functional Movement';
}

/// Normalizza nomi attrezzatura
String normalizeAttrezzatura(String attr) {
  final lower = attr.toLowerCase();

  if (lower.contains('bilanciere') || lower == 'bilanciere') {
    return 'Bilanciere';
  }
  if (lower.contains('manubr') || lower.contains('dumbbell')) {
    return 'Manubri';
  }
  if (lower.contains('cav') || lower.contains('cable')) {
    return 'Cavi';
  }
  if (lower.contains('macchina') || lower.contains('machine')) {
    return 'Macchina';
  }
  if (lower.contains('corpo') || lower.contains('bodyweight') ||
      lower.contains('libero')) {
    return 'Corpo Libero';
  }
  if (lower.contains('kettlebell') || lower == 'kb') {
    return 'Kettlebell';
  }
  if (lower.contains('elastic') || lower.contains('band') ||
      lower.contains('fasc')) {
    return 'Elastici';
  }
  if (lower.contains('trx') || lower.contains('suspension')) {
    return 'TRX';
  }
  if (lower.contains('palla') || lower.contains('ball')) {
    return 'Palla Medica';
  }
  if (lower.contains('sbarra') || lower.contains('pull up bar')) {
    return 'Sbarra';
  }

  // Default: capitalizza prima lettera
  return capitalize(attr);
}

/// Genera aliases IT/EN per esercizio
List<String> generateAliases(Map<String, dynamic> exercise) {
  final nome = (exercise['nome'] as String?)?.toLowerCase() ?? '';
  final aliases = <String>[];

  // Common abbreviations
  final abbreviations = {
    'panca piana': ['bench press', 'bp', 'flat bench'],
    'panca inclinata': ['incline bench', 'incline bp'],
    'panca declinata': ['decline bench', 'decline bp'],
    'squat': ['back squat', 'accosciata'],
    'stacco': ['deadlift', 'dl'],
    'trazioni': ['pull up', 'pullup', 'chin up'],
    'curl': ['ricciolo', 'bicep curl'],
    'military press': ['overhead press', 'ohp', 'shoulder press'],
    'lat machine': ['lat pulldown', 'pulldown'],
    'leg press': ['pressa'],
    'leg extension': ['estensioni'],
    'leg curl': ['flessioni gambe'],
    'calf raise': ['sollevamento polpacci'],
  };

  // Cerca match parziali
  for (final entry in abbreviations.entries) {
    if (nome.contains(entry.key)) {
      aliases.addAll(entry.value);
      break;
    }
  }

  // Aggiungi variante senza spazi/trattini
  if (nome.contains(' ') || nome.contains('-')) {
    final compact = nome.replaceAll(' ', '').replaceAll('-', '');
    if (compact.length >= 3) {
      aliases.add(compact);
    }
  }

  // Rimuovi duplicati
  return aliases.toSet().toList();
}
