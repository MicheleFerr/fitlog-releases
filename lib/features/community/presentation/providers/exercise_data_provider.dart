import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Provider che fornisce i dati degli esercizi con merge delle contribuzioni community
final exerciseDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, exerciseName) async {
  // 1. Carica i dati base dal JSON
  final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
  final List<dynamic> exercises = json.decode(jsonString);
  
  // Trova l'esercizio per nome
  final baseData = exercises.firstWhere(
    (e) => e['nome'] == exerciseName,
    orElse: () => <String, dynamic>{},
  );
  
  if (baseData.isEmpty) {
    return {};
  }
  
  // Crea una copia modificabile
  final mergedData = Map<String, dynamic>.from(baseData);
  
  // 2. Query per correzioni approvate da Firestore
  try {
    // Query semplificata per evitare indici compositi
    final correctionsSnapshot = await FirebaseFirestore.instance
        .collection('community_contributions')
        .where('exerciseName', isEqualTo: exerciseName)
        .limit(50)
        .get();
    
    // 3. Applica ogni correzione approvata (filtra in memoria)
    for (final doc in correctionsSnapshot.docs) {
      final data = doc.data();
      
      // Filtra solo correzioni approvate
      if (data['type'] != 'correction' || data['status'] != 'approved') {
        continue;
      }
      
      final metadata = data['metadata'] as Map<String, dynamic>?;
      
      // Se c'è un campo specifico da correggere
      if (metadata != null && metadata['field'] != null) {
        final fieldToCorrect = metadata['field'] as String;
        final newValue = data['suggestedValue'] ?? data['description'];
        
        // APPLICA L'OVERRIDE
        print('🔄 Applying correction: $fieldToCorrect = $newValue');
        mergedData[_mapFieldName(fieldToCorrect)] = newValue;
      }
    }
    
    // 4. Aggiungi tips e warnings approvati (usa la stessa query semplificata)
    final tips = [];
    final warnings = [];
    
    // Filtra tips e warnings dalla stessa query
    for (final doc in correctionsSnapshot.docs) {
      final data = doc.data();
      
      if (data['type'] == 'tip' && data['status'] == 'approved') {
        tips.add({
          'description': data['description'],
          'upvotes': data['upvotes'] ?? 0,
        });
      } else if (data['type'] == 'warning' && data['status'] == 'approved') {
        warnings.add({
          'description': data['description'],
          'upvotes': data['upvotes'] ?? 0,
        });
      }
    }
    
    // Ordina per upvotes
    tips.sort((a, b) => (b['upvotes'] as int).compareTo(a['upvotes'] as int));
    warnings.sort((a, b) => (b['upvotes'] as int).compareTo(a['upvotes'] as int));
    
    // Aggiungi al merged data
    mergedData['communityTips'] = tips
        .take(5)
        .map((t) => t['description'] as String)
        .toList();
    
    mergedData['communityWarnings'] = warnings
        .take(3)
        .map((w) => w['description'] as String)
        .toList();
    
    // Flag per indicare che ci sono correzioni community
    if (correctionsSnapshot.docs.isNotEmpty) {
      mergedData['hasCommunityCorrections'] = true;
      mergedData['lastCommunityUpdate'] = correctionsSnapshot.docs.first.data()['approvedAt'];
    }
    
  } catch (e) {
    print('Error fetching community corrections: $e');
    // In caso di errore, ritorna solo i dati base
  }
  
  return mergedData;
});

// Mappa i nomi dei campi dall'UI al JSON
String _mapFieldName(String uiFieldName) {
  switch (uiFieldName) {
    case 'Serie riscaldamento':
      return 'warmupSets';
    case 'Durata riscaldamento':
      return 'tempoWarmup';
    case 'Tipo riscaldamento':
      return 'attivazionePre';
    case 'Muscoli target':
      return 'focus';
    case 'Muscoli secondari':
      return 'muscoliSecondari';
    case 'Attrezzatura':
      return 'attrezzatura';
    case 'Descrizione':
      return 'noteTecniche';
    case 'Mobilità articolare':
      return 'mobilitaPre';
    case 'Attivazione muscolare':
      return 'attivazionePre';
    case 'Progressione carico':
      return 'warmupSets';
    case 'Prevenzione infortuni':
      return 'prevenzioneInfortuni';
    case 'Note tecniche':
      return 'noteTecniche';
    case 'Drill tecnico':
      return 'drillTecnico';
    case 'Cooldown consigliato':
      return 'cooldownConsigliato';
    case 'Errori comuni':
      return 'erroriComuni';
    case 'Difficoltà':
      return 'difficolta';
    case 'Tipo esercizio':
      return 'tipoEsercizio';
    case 'Range ripetizioni':
      return 'rangeRipetizioni';
    case 'Pattern movimento':
      return 'patternMovimento';
    default:
      return uiFieldName.toLowerCase().replaceAll(' ', '');
  }
}

/// Provider per il caching dei dati merged
final mergedExerciseDataCacheProvider = StateProvider<Map<String, Map<String, dynamic>>>((ref) => {});

/// Provider ottimizzato con cache
final cachedExerciseDataProvider = Provider.family<AsyncValue<Map<String, dynamic>>, String>((ref, exerciseName) {
  final cache = ref.watch(mergedExerciseDataCacheProvider);
  
  // Se è in cache, ritorna subito
  if (cache.containsKey(exerciseName)) {
    return AsyncValue.data(cache[exerciseName]!);
  }
  
  // Altrimenti carica e metti in cache
  return ref.watch(exerciseDataProvider(exerciseName)).whenData((data) {
    ref.read(mergedExerciseDataCacheProvider.notifier).update((state) => {
      ...state,
      exerciseName: data,
    });
    return data;
  });
});

/// Provider per verificare se ci sono aggiornamenti community per un esercizio
final hasCommunityCorrectionProvider = FutureProvider.family<bool, String>((ref, exerciseName) async {
  try {
    final corrections = await FirebaseFirestore.instance
        .collection('community_contributions')
        .where('exerciseName', isEqualTo: exerciseName)
        .limit(10)
        .get();
    
    // Filtra in memoria per trovare correzioni approvate
    return corrections.docs.any((doc) => 
      doc.data()['type'] == 'correction' && 
      doc.data()['status'] == 'approved'
    );
  } catch (e) {
    print('Error checking community corrections: $e');
    return false;
  }
});

/// Provider per il badge di "contenuto verificato dalla community"
final communityVerifiedBadgeProvider = Provider.family<bool, String>((ref, exerciseName) {
  final hasCorrections = ref.watch(hasCommunityCorrectionProvider(exerciseName));
  return hasCorrections.maybeWhen(
    data: (value) => value,
    orElse: () => false,
  );
});