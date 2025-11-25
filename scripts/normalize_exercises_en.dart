/// Script to normalize exercises.json (English)
///
/// Run with: dart scripts/normalize_exercises_en.dart
///
/// Normalizations:
/// 1. English names capitalized correctly (Title Case)
/// 2. Specific movement patterns (no "Vario")
/// 3. Standardized equipment
/// 4. IT/EN aliases added
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Normalizing Exercises EN...\n');

  // Read JSON
  final file = File('assets/data/exercises.json');
  if (!file.existsSync()) {
    print('❌ File not found: ${file.path}');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);

  print('📊 Total exercises: ${exercises.length}\n');

  // Normalize each exercise
  int normalized = 0;
  for (var i = 0; i < exercises.length; i++) {
    final exercise = exercises[i] as Map<String, dynamic>;

    // Progress indicator
    if ((i + 1) % 50 == 0) {
      print('   Processed: ${i + 1}/${exercises.length}');
    }

    var modified = false;

    // 1. Normalize English name (Title Case)
    if (exercise['nome'] != null) {
      final originalNome = exercise['nome'] as String;
      final normalizedNome = normalizeEnglishName(originalNome);
      if (normalizedNome != originalNome) {
        exercise['nome'] = normalizedNome;
        modified = true;
      }
    }

    // 2. Normalize movement pattern (replace "Vario")
    if (exercise['patternMovimento'] == 'Vario' ||
        exercise['patternMovimento'] == '' ||
        exercise['patternMovimento'] == null) {
      final newPattern = inferMovementPattern(exercise);
      if (newPattern != null) {
        exercise['patternMovimento'] = newPattern;
        modified = true;
      }
    }

    // 3. Normalize equipment
    if (exercise['attrezzatura'] != null) {
      final originalEquip = exercise['attrezzatura'] as String;
      final normalizedEquip = normalizeEquipment(originalEquip);
      if (normalizedEquip != originalEquip) {
        exercise['attrezzatura'] = normalizedEquip;
        modified = true;
      }
    }

    // 4. Add aliases if missing
    if (exercise['aliases'] == null || (exercise['aliases'] as List).isEmpty) {
      final aliases = generateAliases(exercise);
      if (aliases.isNotEmpty) {
        exercise['aliases'] = aliases;
        modified = true;
      }
    }

    if (modified) normalized++;
  }

  print('\n✅ Normalized: $normalized exercises\n');

  // Backup original
  final backup = File('assets/data/exercises.json.backup');
  await file.copy(backup.path);
  print('💾 Backup saved: ${backup.path}');

  // Save normalized JSON (pretty-printed)
  const encoder = JsonEncoder.withIndent('  ');
  final prettyJson = encoder.convert(exercises);
  await file.writeAsString(prettyJson);

  print('✅ File saved: ${file.path}');
  print('\n🎉 Normalization complete!\n');
}

/// Normalize English name (Title Case)
String normalizeEnglishName(String name) {
  // Lowercase first
  final normalized = name.toLowerCase();

  // Title Case (capitalize first letter of each word except articles/prepositions)
  final words = normalized.split(' ');
  final exceptions = {'a', 'an', 'the', 'and', 'or', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'from', 'by'};

  for (var i = 0; i < words.length; i++) {
    // Always capitalize first word, or if not in exceptions list
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

/// Infer movement pattern from exercise name/focus
String? inferMovementPattern(Map<String, dynamic> exercise) {
  final name = (exercise['nome'] as String?)?.toLowerCase() ?? '';
  final focus = (exercise['focus'] as String?)?.toLowerCase() ?? '';

  // Push patterns
  if (name.contains('bench') || name.contains('press') && name.contains('chest') ||
      name.contains('push up') || name.contains('pushup') || name.contains('dip')) {
    return 'Push Pattern';
  }

  // Pull patterns
  if (name.contains('pull') || name.contains('row') ||
      name.contains('chin') || name.contains('lat')) {
    return 'Pull Pattern';
  }

  // Squat patterns
  if (name.contains('squat')) {
    return 'Squat Pattern';
  }

  // Hinge patterns (deadlift, good morning, rdl)
  if (name.contains('deadlift') || name.contains('good morning') ||
      name.contains('hip hinge') || name.contains('rdl') ||
      name.contains('romanian')) {
    return 'Hinge Pattern';
  }

  // Lunge patterns
  if (name.contains('lunge') || name.contains('split squat') ||
      name.contains('bulgarian') || name.contains('step up')) {
    return 'Lunge Pattern';
  }

  // Isolation (curl, extension, fly, raise)
  if (name.contains('curl') || name.contains('extension') ||
      name.contains('fly') || name.contains('flye') ||
      name.contains('raise') || name.contains('lateral')) {
    return 'Isolation';
  }

  // Core/Anti-rotation
  if (focus.contains('core') || focus.contains('abs') ||
      name.contains('plank') || name.contains('crunch') ||
      name.contains('sit up') || name.contains('situp') ||
      name.contains('russian twist') || name.contains('bird dog')) {
    return 'Anti-Rotation / Core Stability';
  }

  // Carry patterns
  if (name.contains('carry') || name.contains('farmer') ||
      name.contains('waiter walk') || name.contains('suitcase')) {
    return 'Carry Pattern';
  }

  // Default if not recognized
  return 'Functional Movement';
}

/// Normalize equipment names
String normalizeEquipment(String equip) {
  final lower = equip.toLowerCase();

  if (lower.contains('barbell') || lower == 'barbell') {
    return 'Barbell';
  }
  if (lower.contains('dumbbell') || lower == 'dumbbell' || lower == 'db') {
    return 'Dumbbell';
  }
  if (lower.contains('cable') || lower == 'cable') {
    return 'Cable';
  }
  if (lower.contains('machine')) {
    return 'Machine';
  }
  if (lower.contains('bodyweight') || lower.contains('body weight') ||
      lower == 'bodyweight' || lower == 'bw') {
    return 'Bodyweight';
  }
  if (lower.contains('kettlebell') || lower == 'kettlebell' || lower == 'kb') {
    return 'Kettlebell';
  }
  if (lower.contains('band') || lower.contains('resistance') ||
      lower == 'band' || lower == 'elastic') {
    return 'Resistance Band';
  }
  if (lower.contains('trx') || lower.contains('suspension')) {
    return 'TRX';
  }
  if (lower.contains('medicine ball') || lower.contains('med ball')) {
    return 'Medicine Ball';
  }
  if (lower.contains('pull up bar') || lower.contains('pull-up bar') ||
      lower == 'bar') {
    return 'Pull-up Bar';
  }

  // Default: Title Case
  return capitalize(equip);
}

/// Generate IT/EN aliases for exercise
List<String> generateAliases(Map<String, dynamic> exercise) {
  final name = (exercise['nome'] as String?)?.toLowerCase() ?? '';
  final aliases = <String>[];

  // Common abbreviations
  final abbreviations = {
    'bench press': ['bp', 'bench', 'panca piana'],
    'incline bench': ['incline bp', 'panca inclinata'],
    'decline bench': ['decline bp', 'panca declinata'],
    'squat': ['accosciata', 'back squat'],
    'deadlift': ['dl', 'stacco'],
    'pull up': ['pullup', 'chin up', 'trazioni'],
    'curl': ['bicep curl', 'ricciolo'],
    'overhead press': ['ohp', 'military press', 'shoulder press'],
    'lat pulldown': ['lat machine', 'pulldown'],
    'leg press': ['pressa'],
    'leg extension': ['estensioni'],
    'leg curl': ['flessioni gambe', 'curl femorali'],
    'calf raise': ['sollevamento polpacci', 'calf'],
    'row': ['rema', 'rematore'],
    'dip': ['dips', 'parallele'],
  };

  // Find partial matches
  for (final entry in abbreviations.entries) {
    if (name.contains(entry.key)) {
      aliases.addAll(entry.value);
      break;
    }
  }

  // Add compact variant (remove spaces/hyphens)
  if (name.contains(' ') || name.contains('-')) {
    final compact = name.replaceAll(' ', '').replaceAll('-', '');
    if (compact.length >= 3) {
      aliases.add(compact);
    }
  }

  // Single-word exercise fallback aliases
  if (!name.contains(' ') && !name.contains('-') && aliases.isEmpty) {
    // Add basic abbreviation for single-word exercises
    if (name.length >= 4) {
      aliases.add(name.substring(0, 3)); // First 3 letters
    }
    // Common single-word mappings
    final singleWordMappings = {
      'burpee': ['burpees'],
      'plank': ['planks', 'core'],
      'crunch': ['crunches', 'abs'],
      'squat': ['squats', 'accosciata'],
      'lunge': ['lunges', 'affondo'],
      'dip': ['dips', 'parallele'],
      'row': ['rows', 'rema'],
      'sprint': ['sprints', 'run'],
      'run': ['running', 'sprint'],
      'handstand': ['handstands', 'vertical'],
      'hyperextension': ['hyperextensions', 'back extension'],
      'sphinx': ['sphinx pose', 'yoga'],
      'elevator': ['elevators'],
      'inchworm': ['inchworms', 'walkout'],
      'cocoons': ['cocoon', 'core'],
      'flag': ['human flag', 'core'],
      'quads': ['quadriceps', 'quad'],
    };

    if (singleWordMappings.containsKey(name)) {
      aliases.addAll(singleWordMappings[name]!);
    }
  }

  // Remove duplicates
  return aliases.toSet().toList();
}
