import 'dart:convert';
import 'dart:io';

/// Script per aggiungere TUT (Time Under Tension) scientificamente validi
/// a tutti gli esercizi nel JSON basandosi su pattern di movimento e ricerca reale
/// 
/// Formato TUT: "E-P1-C-P2" dove:
/// E = Eccentrica (discesa)
/// P1 = Pausa in basso
/// C = Concentrica (salita) 
/// P2 = Pausa in alto

void main() async {
  final file = File('assets/data/exercises.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);

  // Mappa TUT basata su ricerca scientifica e best practices
  final tutMap = {
    // COMPOUND PESANTI (Forza/Potenza)
    'squat': '3-1-1-0', // 3s discesa controllata, 1s pausa, esplosivo su
    'back_squat': '3-1-1-0',
    'front_squat': '3-1-1-0',
    'box_squat': '3-2-1-0', // Pausa più lunga per box squat
    'bulgarian_split_squat': '3-0-1-0',
    'goblet_squat': '2-1-2-0',
    
    // DEADLIFT VARIATIONS
    'deadlift': '1-0-1-1', // Più veloce per sicurezza
    'sumo_deadlift': '1-0-1-1',
    'romanian_deadlift': '3-0-1-0', // Eccentrica più lunga per focus femorali
    'stiff_leg_deadlift': '3-0-1-0',
    'trap_bar_deadlift': '2-0-1-0',
    
    // BENCH & CHEST
    'bench_press': '3-1-1-0', // Pausa sul petto per powerlifting
    'panca_piana': '3-1-1-0',
    'incline_bench': '3-0-1-0',
    'decline_bench': '2-0-1-0',
    'dumbbell_press': '3-0-2-0',
    'dumbbell_fly': '3-1-2-0', // Più controllo per isolamento
    'cable_fly': '2-1-2-1',
    'push_up': '2-1-2-0',
    'dips': '2-0-1-0',
    
    // BACK EXERCISES
    'pull_up': '2-1-2-0',
    'chin_up': '2-1-2-0',
    'lat_pulldown': '2-1-2-0',
    'barbell_row': '2-0-1-1',
    'pendlay_row': '1-0-1-1', // Esplosivo dal pavimento
    'dumbbell_row': '2-0-1-1',
    'cable_row': '2-1-2-0',
    't_bar_row': '2-0-1-1',
    'seal_row': '2-1-2-0',
    
    // SHOULDERS
    'military_press': '2-0-1-0',
    'overhead_press': '2-0-1-0',
    'shoulder_dumbbell_press': '2-0-2-0',
    'arnold_press': '2-0-2-0',
    'lateral_raise': '2-1-2-0', // Controllo per deltoidi
    'alzate_laterali': '2-1-2-0',
    'front_raise': '2-0-2-0',
    'alzate_frontali': '2-0-2-0',
    'rear_delt_fly': '2-1-2-0',
    'face_pull': '2-1-2-0',
    'upright_row': '2-0-2-0',
    
    // ARMS - BICEPS
    'barbell_curl': '2-0-2-1', // TUT per ipertrofia
    'ez_bar_curl': '2-0-2-1',
    'dumbbell_curl': '2-0-2-1',
    'hammer_curl': '2-0-2-0',
    'preacher_curl': '3-0-2-0', // Eccentrica più lunga
    'cable_curl': '2-1-2-0',
    'concentration_curl': '3-0-2-1', // Massimo isolamento
    'spider_curl': '2-1-2-0',
    
    // ARMS - TRICEPS  
    'close_grip_bench': '2-0-1-0',
    'tricep_dip': '2-0-1-0',
    'overhead_extension': '3-0-2-0', // Controllo per sicurezza gomiti
    'tricep_pushdown': '2-0-2-1',
    'cable_pushdown': '2-0-2-1',
    'kickback': '2-1-2-0',
    'diamond_pushup': '2-1-2-0',
    'skull_crusher': '3-0-2-0', // Eccentrica controllata
    
    // LEGS - QUADRICEPS
    'leg_press': '3-0-1-0',
    'hack_squat': '3-0-1-0',
    'leg_extension': '2-1-2-1', // Pausa per contrazione di picco
    'sissy_squat': '3-0-2-0',
    'lunges': '2-0-1-0',
    'affondi': '2-0-1-0',
    'walking_lunges': '2-0-1-0',
    'step_up': '2-0-1-0',
    
    // LEGS - HAMSTRINGS
    'leg_curl': '2-1-2-0',
    'lying_leg_curl': '2-1-2-0',
    'seated_leg_curl': '2-1-2-0',
    'nordic_curl': '4-0-1-0', // Eccentrica molto lenta
    'good_morning': '3-0-1-0',
    
    // LEGS - GLUTES
    'hip_thrust': '2-1-1-1', // Pausa in alto per attivazione
    'glute_bridge': '2-1-1-1',
    'cable_pull_through': '2-0-2-1',
    'reverse_lunge': '2-0-1-0',
    'curtsy_lunge': '2-0-1-0',
    
    // CALVES
    'calf_raise': '2-1-2-1', // Pausa in alto per contrazione
    'standing_calf': '2-1-2-1',
    'seated_calf': '2-1-2-1',
    'donkey_calf': '2-1-2-1',
    
    // ABS & CORE
    'plank': 'ISO', // Isometrico
    'side_plank': 'ISO',
    'crunch': '2-1-2-0',
    'sit_up': '2-0-2-0',
    'leg_raise': '2-1-2-0',
    'hanging_leg_raise': '2-1-2-0',
    'russian_twist': '1-0-1-0',
    'cable_crunch': '2-1-2-0',
    'ab_wheel': '3-0-1-0',
    'dead_bug': '2-1-2-1',
    'bird_dog': '2-2-2-2', // Controllo e stabilità
    'pallof_press': '2-2-2-0',
    
    // OLYMPIC LIFTS (Esplosivi, no TUT tradizionale)
    'clean': 'EXP', // Esplosivo
    'snatch': 'EXP',
    'clean_and_jerk': 'EXP',
    'power_clean': 'EXP',
    'hang_clean': 'EXP',
    
    // DEFAULT per esercizi non mappati
    'default_compound': '2-0-1-0',
    'default_isolation': '2-1-2-0',
  };

  // Funzione per determinare TUT basato su pattern
  String getTutForExercise(Map<String, dynamic> exercise) {
    final nome = exercise['nome']?.toString().toLowerCase() ?? '';
    final id = exercise['id']?.toString().toLowerCase() ?? '';
    final pattern = exercise['patternMovimento']?.toString().toLowerCase() ?? '';
    final tipo = exercise['tipoEsercizio']?.toString().toLowerCase() ?? '';
    
    // Cerca match esatto per ID
    for (final key in tutMap.keys) {
      if (id.contains(key) || nome.contains(key)) {
        return tutMap[key]!;
      }
    }
    
    // Match per pattern di movimento
    if (pattern.contains('squat')) return '3-0-1-0';
    if (pattern.contains('hinge')) return '3-0-1-0';
    if (pattern.contains('push')) return '2-0-1-0';
    if (pattern.contains('pull')) return '2-1-2-0';
    if (pattern.contains('lunge')) return '2-0-1-0';
    if (pattern.contains('carry')) return 'ISO';
    
    // Match per tipo di esercizio
    if (tipo.contains('compound') || tipo.contains('multiarticolare')) {
      return tutMap['default_compound']!;
    }
    if (tipo.contains('isolamento') || tipo.contains('isolation')) {
      return tutMap['default_isolation']!;
    }
    
    // Default generico
    return '2-1-2-0';
  }

  // Aggiungi TUT a ogni esercizio
  for (var exercise in exercises) {
    final tut = getTutForExercise(exercise);
    exercise['tempoEsecuzione'] = tut;
    
    // Aggiungi spiegazione del tempo (sarà tradotta dopo)
    if (tut == 'ISO') {
      exercise['tempoNote'] = 'Mantenere posizione isometrica';
    } else if (tut == 'EXP') {
      exercise['tempoNote'] = 'Movimento esplosivo';
    } else {
      final parts = tut.split('-');
      final eccentric = parts[0];
      final pause1 = parts[1];
      final concentric = parts[2];
      final pause2 = parts[3];
      
      // Genera nota descrittiva
      String note = '';
      if (eccentric != '0') note += '${eccentric}s discesa';
      if (pause1 != '0') {
        if (note.isNotEmpty) note += ', ';
        note += '${pause1}s pausa in basso';
      }
      if (concentric != '0') {
        if (note.isNotEmpty) note += ', ';
        note += concentric == '1' ? 'esplosivo su' : '${concentric}s salita';
      }
      if (pause2 != '0') {
        if (note.isNotEmpty) note += ', ';
        note += '${pause2}s pausa in alto';
      }
      
      exercise['tempoNote'] = note;
    }
  }

  // Salva il file aggiornato
  final updatedJson = const JsonEncoder.withIndent('  ').convert(exercises);
  await File('assets/data/exercises_with_tut.json').writeAsString(updatedJson);
  
  print('✅ TUT aggiunti a ${exercises.length} esercizi');
  print('📁 File salvato in: assets/data/exercises_with_tut.json');
  
  // Stampa alcuni esempi
  print('\n📊 Esempi di TUT aggiunti:');
  final examples = ['squat', 'bench', 'deadlift', 'barbell_curl', 'lateral_raise'];
  for (final ex in exercises) {
    if (examples.any((e) => ex['id'].toString().contains(e))) {
      print('- ${ex['nome']}: ${ex['tempoEsecuzione']} (${ex['tempoNote']})');
    }
  }
}