// ignore_for_file: avoid_print
/// Script per unire i dati TUT da exercises_with_tut.json
/// ai file splittati in assets/data/exercises/
///
/// Uso: dart run scripts/merge_tut_data.dart
///
/// Questo script:
/// 1. Carica exercises_with_tut.json come source dei dati TUT
/// 2. Carica ogni file splittato (core.json, upper_push.json, etc.)
/// 3. Match per ID esercizio
/// 4. Aggiunge tempoEsecuzione dove mancante
/// 5. Salva i file aggiornati

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔄 TUT Data Merger - Inizio merge...\n');

  // Percorsi
  const sourceFile = 'assets/data/exercises_with_tut.json';
  const targetFolder = 'assets/data/exercises';
  const targetFiles = [
    'core.json',
    'upper_push.json',
    'upper_pull.json',
    'lower.json',
    'other.json',
  ];

  // 1. Carica source TUT data
  print('📖 Caricamento source TUT data...');
  final sourceData = await _loadJsonFile(sourceFile);
  if (sourceData == null) {
    print('❌ Errore: impossibile caricare $sourceFile');
    exit(1);
  }

  // Crea mappa NOME → TUT (normalizzato lowercase)
  // Gli ID sono diversi tra source (italiano) e target (inglese),
  // quindi usiamo il nome come chiave di match
  final tutMap = <String, String>{};
  for (final exercise in sourceData) {
    final nome = exercise['nome'] as String?;
    final tut = exercise['tempoEsecuzione'] as String?;
    if (nome != null && tut != null && tut.isNotEmpty) {
      tutMap[nome.toLowerCase().trim()] = tut;
    }
  }
  print('   ✅ Trovati ${tutMap.length} esercizi con TUT\n');

  // 2. Processa ogni file target
  var totalUpdated = 0;
  var totalSkipped = 0;
  var totalNotFound = 0;

  for (final fileName in targetFiles) {
    final filePath = '$targetFolder/$fileName';
    print('📝 Processando $fileName...');

    final exercises = await _loadJsonFile(filePath);
    if (exercises == null) {
      print('   ⚠️ File non trovato o errore, skip\n');
      continue;
    }

    var updated = 0;
    var skipped = 0;
    var notFound = 0;

    for (final exercise in exercises) {
      final nome = exercise['nome'] as String?;
      if (nome == null) continue;

      // Check se ha già TUT
      final existingTut = exercise['tempoEsecuzione'];
      if (existingTut != null && existingTut.toString().isNotEmpty) {
        skipped++;
        continue;
      }

      // Cerca TUT in source usando nome normalizzato
      final normalizedName = nome.toLowerCase().trim();
      final tut = tutMap[normalizedName];
      if (tut != null) {
        exercise['tempoEsecuzione'] = tut;
        updated++;
      } else {
        notFound++;
      }
    }

    // Salva file aggiornato
    if (updated > 0) {
      await _saveJsonFile(filePath, exercises);
      print('   ✅ Aggiornati: $updated | Skippati (già presenti): $skipped | Non trovati: $notFound');
    } else {
      print('   ℹ️ Nessun aggiornamento necessario');
    }
    print('');

    totalUpdated += updated;
    totalSkipped += skipped;
    totalNotFound += notFound;
  }

  // 3. Report finale
  print('═══════════════════════════════════════');
  print('📊 REPORT FINALE');
  print('═══════════════════════════════════════');
  print('✅ Esercizi aggiornati:     $totalUpdated');
  print('⏭️ Esercizi già con TUT:    $totalSkipped');
  print('❓ Esercizi senza match:    $totalNotFound');
  print('═══════════════════════════════════════\n');

  if (totalUpdated > 0) {
    print('🎉 Merge completato! I file sono stati aggiornati.');
    print('   Esegui "flutter clean && flutter pub get" per assicurarti');
    print('   che i nuovi asset vengano ricompilati.\n');
  } else {
    print('ℹ️ Nessuna modifica effettuata.\n');
  }
}

Future<List<Map<String, dynamic>>?> _loadJsonFile(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    final List<dynamic> jsonList = json.decode(content);
    return jsonList.cast<Map<String, dynamic>>();
  } catch (e) {
    print('   Errore caricamento $path: $e');
    return null;
  }
}

Future<void> _saveJsonFile(String path, List<Map<String, dynamic>> data) async {
  final file = File(path);
  const encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(data);
  await file.writeAsString(jsonString);
}
