import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

void main() {
  group('calculateBrzycki', () {
    test('should calculate correct 1RM for 100kg x 5 reps', () {
      // ESEMPIO PRATICO: Utente fa 100kg × 5 reps bench press
      // Formula Brzycki: 100 × (36 / (37 - 5)) = 100 × 1.125 = 112.5kg
      final result = OneRMCalculator.calculateBrzycki(100, 5);
      
      expect(result, closeTo(112.5, 0.1));
      
      // 🐛 BUG PREVENTED: Senza questo test, se la formula fosse (35/(37-reps))
      // invece di (36/(37-reps)), il risultato sarebbe 109.375kg - 3kg di errore!
      // L'utente programmerebbe allenamenti con pesi sbagliati.
    });

    test('should return weight when reps = 1', () {
      // ESEMPIO PRATICO: Utente testa 1RM reale a 120kg
      final result = OneRMCalculator.calculateBrzycki(120, 1);
      
      expect(result, 120.0);
      
      // 🐛 BUG PREVENTED: Se mancasse il check "if (reps == 1) return weight",
      // la formula calcolerebbe 120 × (36/36) = 120, ma potrebbe dare NaN
      // se ci fossero divisioni per zero in futuro refactoring.
    });

    test('should return 0 for invalid inputs', () {
      // ESEMPIO PRATICO: Database corrotto o input utente malformato
      expect(OneRMCalculator.calculateBrzycki(0, 5), 0.0);
      expect(OneRMCalculator.calculateBrzycki(-10, 5), 0.0);
      expect(OneRMCalculator.calculateBrzycki(100, 0), 0.0);
      expect(OneRMCalculator.calculateBrzycki(100, -5), 0.0);
      
      // 🐛 BUG PREVENTED: Senza questi check, calcoli con valori negativi
      // darebbero risultati assurdi tipo "-150kg 1RM" che crasherebbero
      // i grafici o causerebbero raccomandazioni folli.
    });

    test('should return 0 for reps > 36', () {
      // ESEMPIO PRATICO: Utente fa 40 reps di push-up con 20kg
      final result = OneRMCalculator.calculateBrzycki(20, 40);
      
      expect(result, 0.0);
      
      // 🐛 BUG PREVENTED: Formula Brzycki diventa (36/(37-40)) = (36/-3) = -12
      // Risultato negativo! Senza questo check: "1RM = -240kg" ❌
      // Con check: ritorna 0 (formula non applicabile per alte rep)
    });

    test('should handle low rep ranges accurately', () {
      // ESEMPIO PRATICO: Powerlifter fa 2-3 reps pesanti
      final twoReps = OneRMCalculator.calculateBrzycki(95, 2);
      final threeReps = OneRMCalculator.calculateBrzycki(90, 3);
      
      expect(twoReps, closeTo(97.71, 0.1)); // 95 × (36/35)
      expect(threeReps, closeTo(95.29, 0.1)); // 90 × (36/34)
      
      // 🐛 BUG PREVENTED: Brzycki è ottima per 2-10 reps ma non per 15+.
      // Se usassimo Brzycki per 20 reps, sovrastimeremmo il 1RM di 10-15kg!
    });
  });

  group('calculateEpley', () {
    test('should calculate correct 1RM using Epley formula', () {
      // ESEMPIO PRATICO: Utente fa 80kg × 8 reps
      // Formula Epley: 80 × (1 + 8/30) = 80 × 1.267 = 101.33kg
      final result = OneRMCalculator.calculateEpley(80, 8);
      
      expect(result, closeTo(101.33, 0.1));
      
      // 🐛 BUG PREVENTED: Se usassimo (1 + 8/3) invece di (1 + 8/30),
      // risultato sarebbe 80 × 3.67 = 293kg - COMPLETAMENTE SBAGLIATO!
    });

    test('should match Brzycki for 1 rep', () {
      // ESEMPIO PRATICO: Confronto tra formule per coerenza
      final epley = OneRMCalculator.calculateEpley(100, 1);
      final brzycki = OneRMCalculator.calculateBrzycki(100, 1);
      
      expect(epley, brzycki);
      
      // 🐛 BUG PREVENTED: Se Epley e Brzycki dessero risultati diversi per 1 rep,
      // l'utente vedrebbe "1RM stimato: 100kg" e "1RM alternativo: 105kg" per
      // lo stesso lift - confusione totale!
    });

    test('should handle edge cases', () {
      expect(OneRMCalculator.calculateEpley(0, 5), 0.0);
      expect(OneRMCalculator.calculateEpley(100, 0), 0.0);
      
      // 🐛 BUG PREVENTED: Input zero causerebbero divisioni per zero
      // o risultati "Infinity" che crashano JSON serialization.
    });
  });

  group('calculateAverage - The Smart Average', () {
    test('should weight formulas differently for low reps (1-5)', () {
      // ESEMPIO PRATICO: Powerlifter fa 3 reps pesanti
      final result = OneRMCalculator.calculateAverage(95, 3);
      
      // Low reps: Brzycki 35% + Epley 35% + others 10% each
      final brzycki = OneRMCalculator.calculateBrzycki(95, 3);
      final epley = OneRMCalculator.calculateEpley(95, 3);
      
      expect(result, greaterThan(brzycki * 0.3));
      expect(result, greaterThan(epley * 0.3));
      
      // 🐛 BUG PREVENTED: Se dessimo peso uguale a tutte le formule,
      // Lombardi (ottima per alte rep) influenzerebbe troppo le basse rep,
      // dando stime 5-10kg più alte del reale.
    });

    test('should use balanced weights for medium reps (6-10)', () {
      // ESEMPIO PRATICO: Bodybuilder fa 8 reps hypertrophy range
      final result = OneRMCalculator.calculateAverage(80, 8);
      
      // Medium reps: tutte le formule contribuiscono in modo bilanciato
      expect(result, greaterThan(95.0));
      expect(result, lessThan(105.0));
      
      // 🐛 BUG PREVENTED: Range 6-10 reps è il più comune - peso bilanciato
      // dà miglior accuratezza. Se privilegiassimo Brzycki, sottostimeremmo
      // per reps > 8.
    });

    test('should prefer Lombardi and Wathan for high reps (11+)', () {
      // ESEMPIO PRATICO: Endurance training con 15 reps
      final result = OneRMCalculator.calculateAverage(50, 15);
      
      // High reps: Lombardi 30% + Wathan 30% (più accurate per alte rep)
      expect(result, greaterThan(50.0));
      expect(result, lessThan(80.0));
      
      // 🐛 BUG PREVENTED: Brzycki ed Epley SOVRASTIMANO per reps > 12.
      // Se usassimo solo Brzycki per 15 reps: stimerebbe 1RM di 85-90kg
      // invece del reale 70-75kg - utente proverebbe 80kg e fallirebbe!
    });

    test('should return 0 for invalid inputs', () {
      expect(OneRMCalculator.calculateAverage(0, 5), 0.0);
      expect(OneRMCalculator.calculateAverage(100, 0), 0.0);
      expect(OneRMCalculator.calculateAverage(-50, 5), 0.0);
      
      // 🐛 BUG PREVENTED: Input invalidi causerebbero eccezioni in tutte
      // le 5 formule chiamate internamente - crash multipli!
    });

    test('should aggregate all 5 formulas correctly', () {
      // ESEMPIO PRATICO: Verifica che tutte le formule contribuiscano
      const weight = 100.0;
      const reps = 5;
      
      final average = OneRMCalculator.calculateAverage(weight, reps);
      final brzycki = OneRMCalculator.calculateBrzycki(weight, reps);
      OneRMCalculator.calculateEpley(weight, reps);
      
      // Average deve essere vicina a Brzycki/Epley per basse rep
      expect((average - brzycki).abs(), lessThan(5.0));
      
      // 🐛 BUG PREVENTED: Se una formula desse NaN o Infinity,
      // contaminerebbe l'average rendendola inutilizzabile.
    });
  });

  group('calculateWeightForReps - Reverse Calculation', () {
    test('should calculate weight needed for target reps', () {
      // ESEMPIO PRATICO: 1RM = 100kg, voglio fare 5 reps
      // Formula inversa Brzycki: 100 × (37-5)/36 = 100 × 0.889 = 88.9kg
      final result = OneRMCalculator.calculateWeightForReps(100, 5);
      
      expect(result, closeTo(88.89, 0.1));
      
      // 🐛 BUG PREVENTED: Senza formula inversa corretta, l'app
      // suggerirebbe "usa 95kg per 5 reps" quando dovresti usare 89kg.
      // Utente fallirebbe il set e penserebbe di essere debole!
    });

    test('should return 1RM when target is 1 rep', () {
      final result = OneRMCalculator.calculateWeightForReps(120, 1);
      
      expect(result, 120.0);
      
      // 🐛 BUG PREVENTED: Se calcolasse 120 × (37-1)/36 = 120kg,
      // funzionerebbe, ma è meglio return diretto per chiarezza.
    });

    test('should handle training percentage calculations', () {
      // ESEMPIO PRATICO: 1RM 100kg, voglio fare 8 reps (75-80% 1RM)
      final eightReps = OneRMCalculator.calculateWeightForReps(100, 8);
      
      expect(eightReps, closeTo(80.56, 0.1)); // ~80% del 1RM
      
      // 🐛 BUG PREVENTED: Se formula inversa fosse sbagliata,
      // tutte le % di training (75% per hypertrophy, 85% per strength)
      // sarebbero sbagliate - intero programma di allenamento rovinato!
    });

    test('should return 0 for invalid inputs', () {
      expect(OneRMCalculator.calculateWeightForReps(0, 5), 0.0);
      expect(OneRMCalculator.calculateWeightForReps(100, 0), 0.0);
      expect(OneRMCalculator.calculateWeightForReps(-100, 5), 0.0);
      
      // 🐛 BUG PREVENTED: Input negativi darebbero pesi negativi
      // tipo "-75kg per 5 reps" che crasherebbero UI.
    });
  });

  group('calculateWithRPE - RPE-Adjusted 1RM', () {
    test('should estimate higher 1RM for low RPE', () {
      // ESEMPIO PRATICO: Fai 80kg × 5 reps ma RPE = 7 (facile)
      // RPE 7 = 3 reps in reserve → potresti fare 8 reps totali
      // Quindi 1RM è più alto di quanto sembri
      final result = OneRMCalculator.calculateWithRPE(80, 5, 7);

      // Con RPE, stima 1RM su 80kg × 8 reps invece di 5
      // 80kg × 8 reps = ~99-100kg 1RM (invece di 80×5 = ~95kg)
      expect(result, greaterThan(95.0)); // Più alto che 80×5 normale (~90-95kg)
      expect(result, closeTo(99.58, 1.0)); // Calcolo preciso con adjusted reps

      // 🐛 BUG PREVENTED: Senza RPE adjustment, sottostimeremmo forza reale.
      // Utente pensa "1RM = 95kg" quando è veramente 100kg.
    });

    test('should estimate accurate 1RM for RPE 10 (max effort)', () {
      // ESEMPIO PRATICO: 90kg × 3 reps @ RPE 10 (zero reps in reserve)
      final result = OneRMCalculator.calculateWithRPE(90, 3, 10);
      
      // RPE 10 = 0 reps in reserve → stima su 3 reps effettivi
      final normalEstimate = OneRMCalculator.calculateAverage(90, 3);
      expect(result, closeTo(normalEstimate, 1.0));
      
      // 🐛 BUG PREVENTED: Se ignorassimo RPE 10, potremmo sovrastimare
      // facendo calcoli su "6 reps possibili" invece di 3 reali.
    });

    test('should return 0 for invalid RPE values', () {
      expect(OneRMCalculator.calculateWithRPE(100, 5, 5), 0.0); // RPE < 6
      expect(OneRMCalculator.calculateWithRPE(100, 5, 11), 0.0); // RPE > 10
      
      // 🐛 BUG PREVENTED: RPE scale è 6-10. Se accettassimo RPE 3,
      // avremmo "7 reps in reserve" per 5 reps fatti = 12 reps totali!
      // Stima 1RM completamente assurda.
    });

    test('should calculate reps in reserve correctly', () {
      // ESEMPIO PRATICO: RPE 8 = 2 reps in reserve
      final rpe8 = OneRMCalculator.calculateWithRPE(80, 5, 8); // 5+2 = 7 reps
      final rpe9 = OneRMCalculator.calculateWithRPE(80, 5, 9); // 5+1 = 6 reps
      
      expect(rpe8, greaterThan(rpe9)); // Più RIR = 1RM più alto
      
      // 🐛 BUG PREVENTED: Se RIR fosse calcolato male (es. RIR = rpe - 10),
      // avremmo valori negativi e 1RM sottostimato drasticamente.
    });
  });

  group('calculateTrainingPercentages', () {
    test('should return correct training zones', () {
      // ESEMPIO PRATICO: 1RM = 100kg, calcola pesi per ogni zona
      final percentages = OneRMCalculator.calculateTrainingPercentages(100);
      
      expect(percentages['max_strength'], 90.0);  // 90% - 1-3 reps
      expect(percentages['strength'], 85.0);      // 85% - 4-6 reps
      expect(percentages['hypertrophy'], 75.0);   // 75% - 8-12 reps
      expect(percentages['endurance'], 60.0);     // 60% - 15+ reps
      expect(percentages['warmup'], 50.0);        // 50% - warmup sets
      
      // 🐛 BUG PREVENTED: Se percentuali fossero sbagliate (es. 95% hypertrophy),
      // utente userebbe pesi troppo pesanti per 12 reps e fallirebbe ogni set!
    });

    test('should return 0 for invalid 1RM', () {
      final result = OneRMCalculator.calculateTrainingPercentages(0);
      
      expect(result['max_strength'], 0.0);
      expect(result['strength'], 0.0);
      
      // 🐛 BUG PREVENTED: 1RM = 0 causerebbe divisioni per zero in calcoli
      // successivi tipo "reps = volume / (1RM × percentage)".
    });

    test('should maintain percentage relationships', () {
      final percentages = OneRMCalculator.calculateTrainingPercentages(100);
      
      // Verifica ordine corretto: max > strength > hypertrophy > endurance
      expect(percentages['max_strength']!, greaterThan(percentages['strength']!));
      expect(percentages['strength']!, greaterThan(percentages['hypertrophy']!));
      expect(percentages['hypertrophy']!, greaterThan(percentages['endurance']!));
      
      // 🐛 BUG PREVENTED: Se ordine fosse sbagliato (hypertrophy 90%, strength 75%),
      // programmi di allenamento sarebbero completamente invertiti!
    });
  });

  group('calculateConfidenceInterval', () {
    test('should return range with lower < average < upper', () {
      // ESEMPIO PRATICO: 80kg × 8 reps - diverse formule danno risultati diversi
      final interval = OneRMCalculator.calculateConfidenceInterval(80, 8);
      
      expect(interval['lower']!, lessThan(interval['average']!));
      expect(interval['average']!, lessThan(interval['upper']!));
      
      // 🐛 BUG PREVENTED: Se lower > upper, UI mostrerebbe grafico invertito
      // tipo "Range: 110-95kg" invece di "95-110kg".
    });

    test('should show formula variance for different rep ranges', () {
      // ESEMPIO PRATICO: Basse rep hanno meno varianza (formule d'accordo)
      final lowReps = OneRMCalculator.calculateConfidenceInterval(95, 3);
      final highReps = OneRMCalculator.calculateConfidenceInterval(50, 15);
      
      final lowVariance = lowReps['upper']! - lowReps['lower']!;
      final highVariance = highReps['upper']! - highReps['lower']!;
      
      expect(highVariance, greaterThan(lowVariance));
      
      // 🐛 BUG PREVENTED: Se non mostrassimo confidence interval,
      // utente non saprebbe che stima per 15 reps è ±10kg imprecisa!
    });

    test('should use calculateAverage for average value', () {
      final interval = OneRMCalculator.calculateConfidenceInterval(80, 8);
      final average = OneRMCalculator.calculateAverage(80, 8);
      
      expect(interval['average'], closeTo(average, 0.1));
      
      // 🐛 BUG PREVENTED: Se average fosse (lower+upper)/2 invece di
      // weighted average, ignoreremmo i pesi intelligenti per rep range.
    });

    test('should return 0 for invalid inputs', () {
      final result = OneRMCalculator.calculateConfidenceInterval(0, 5);
      
      expect(result['lower'], 0.0);
      expect(result['average'], 0.0);
      expect(result['upper'], 0.0);
      
      // 🐛 BUG PREVENTED: Input zero causerebbero exception quando
      // facciamo results.sort() su lista con valori null/NaN.
    });
  });

  group('isRealisticLift - Sanity Check', () {
    test('should validate realistic lifts across all rep ranges', () {
      // FIXED: Previously failed due to overlapping condition logic
      // Now using proper if-else ranges
      const oneRM = 100.0;

      // 1 rep: up to 105% allowed (adrenaline variance)
      expect(OneRMCalculator.isRealisticLift(100, 1, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(105, 1, oneRM), true);

      // 2-3 reps: up to 93% allowed
      expect(OneRMCalculator.isRealisticLift(90, 3, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(93, 3, oneRM), true);

      // 4-5 reps: up to 87% allowed
      expect(OneRMCalculator.isRealisticLift(85, 5, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(87, 5, oneRM), true);

      // 6-8 reps: up to 80% allowed
      expect(OneRMCalculator.isRealisticLift(75, 8, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(80, 8, oneRM), true);

      // 9-12 reps: up to 70% allowed
      expect(OneRMCalculator.isRealisticLift(65, 12, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(70, 12, oneRM), true);

      // 13-15 reps: up to 65% allowed
      expect(OneRMCalculator.isRealisticLift(60, 15, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(65, 15, oneRM), true);

      // 16-20 reps: up to 60% allowed
      expect(OneRMCalculator.isRealisticLift(55, 20, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(60, 20, oneRM), true);

      // 🐛 BUG FIXED: 60kg × 5 reps with 100kg 1RM (60%) now correctly returns TRUE
      // Previous overlapping conditions caused false negatives
      expect(OneRMCalculator.isRealisticLift(60, 5, oneRM), true);
    });

    test('should reject unrealistic heavy lifts', () {
      // ESEMPIO PRATICO: 1RM stimato 100kg
      // - 98kg × 5 reps = IMPOSSIBILE (98% per 5 reps? No way!)
      // - 95kg × 10 reps = IMPOSSIBILE (95% per 10 reps? No way!)
      expect(OneRMCalculator.isRealisticLift(98, 5, 100), false);
      expect(OneRMCalculator.isRealisticLift(95, 10, 100), false);
      
      // 🐛 BUG PREVENTED: Utente inserisce per errore "95kg × 10"
      // invece di "95kg × 1" - senza check, contamina tutte le statistiche!
    });

    test('should allow small variance for 1RM tests', () {
      // ESEMPIO PRATICO: Test 1RM - adrenalina può dare 102-105kg
      // quando 1RM calcolato era 100kg
      expect(OneRMCalculator.isRealisticLift(102, 1, 100), true);
      expect(OneRMCalculator.isRealisticLift(105, 1, 100), true);
      expect(OneRMCalculator.isRealisticLift(110, 1, 100), false); // +10% troppo
      
      // 🐛 BUG PREVENTED: Se non permettessimo varianza, tutti i PR reali
      // sarebbero rifiutati come "impossibili" - utente frustrato!
    });

    test('should use strength standards for validation', () {
      // ESEMPIO PRATICO: Standard scientifici per rep ranges
      // 3 reps = max 93% 1RM, 8 reps = max 80% 1RM, etc.
      const oneRM = 100.0;
      
      expect(OneRMCalculator.isRealisticLift(94, 3, oneRM), false); // >93%
      expect(OneRMCalculator.isRealisticLift(81, 8, oneRM), false); // >80%
      
      // 🐛 BUG PREVENTED: Senza standard, accetteremmo input fisicamente
      // impossibili che farebbero sembrare l'utente Superman o bugiardo.
    });

    test('should return false for invalid inputs', () {
      expect(OneRMCalculator.isRealisticLift(0, 5, 100), false);
      expect(OneRMCalculator.isRealisticLift(80, 0, 100), false);
      expect(OneRMCalculator.isRealisticLift(80, 5, 0), false);

      // 🐛 BUG PREVENTED: Input zero bypasserebbero validation e
      // corromperebbero database con garbage data.
    });

    test('should reject lifts above 20 reps', () {
      // ESEMPIO PRATICO: Above 20 reps, percentages become unreliable
      const oneRM = 100.0;

      expect(OneRMCalculator.isRealisticLift(50, 21, oneRM), false);
      expect(OneRMCalculator.isRealisticLift(40, 30, oneRM), false);

      // 🐛 BUG PREVENTED: High-rep sets (21+) have too much variance to validate
      // accurately - reject to maintain data integrity
    });

    test('should validate boundary conditions correctly', () {
      // ESEMPIO PRATICO: Test exact boundary values
      const oneRM = 100.0;

      // Just at the limit - should pass
      expect(OneRMCalculator.isRealisticLift(87, 5, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(80, 8, oneRM), true);
      expect(OneRMCalculator.isRealisticLift(70, 12, oneRM), true);

      // Just over the limit - should fail
      expect(OneRMCalculator.isRealisticLift(87.1, 5, oneRM), false);
      expect(OneRMCalculator.isRealisticLift(80.1, 8, oneRM), false);
      expect(OneRMCalculator.isRealisticLift(70.1, 12, oneRM), false);

      // 🐛 BUG PREVENTED: Boundary testing ensures no off-by-one errors
    });
  });

  group('OneRMExtensions', () {
    test('should convert kg to lbs correctly', () {
      // ESEMPIO PRATICO: Utente americano vuole vedere 100kg in lbs
      final lbs = (100.0).toLbs();
      
      expect(lbs, closeTo(220.46, 0.1));
      
      // 🐛 BUG PREVENTED: Se fattore fosse 2.0 invece di 2.20462,
      // tutte le conversioni sarebbero sbagliate di 10%!
    });

    test('should convert lbs to kg correctly', () {
      // ESEMPIO PRATICO: Utente americano inserisce 225lbs
      final kg = (225.0).toKg();
      
      expect(kg, closeTo(102.06, 0.1));
      
      // 🐛 BUG PREVENTED: Conversione sbagliata = utente usa pesi completamente
      // diversi da quelli intesi. "225lbs bench press" diventerebbe "225kg"!
    });

    test('should round to nearest 2.5kg plate', () {
      // ESEMPIO PRATICO: Calcolo dice "usa 83.7kg" ma barra ha solo dischi da 2.5kg
      final rounded = (83.7).roundToPlate();
      
      expect(rounded, 82.5); // Nearest 2.5kg increment
      
      // 🐛 BUG PREVENTED: Senza rounding, app suggerirebbe "usa 83.7kg"
      // quando bilanciere va a 82.5kg o 85kg - impossibile da caricare!
    });

    test('should support custom plate increments', () {
      // ESEMPIO PRATICO: Gym ha solo dischi da 5kg
      final rounded5kg = (87.3).roundToPlate(increment: 5.0);
      
      expect(rounded5kg, 85.0);
      
      // 🐛 BUG PREVENTED: Se incremento fosse hardcoded a 2.5kg,
      // utenti con dischi da 5kg o 1.25kg non potrebbero personalizzare.
    });

    test('should handle edge cases in rounding', () {
      expect((0.0).roundToPlate(), 0.0);
      expect((1.0).roundToPlate(), 0.0); // Arrotonda a 0 (meno di 1.25kg)
      expect((2.0).roundToPlate(), 2.5); // Arrotonda a 2.5kg
      
      // 🐛 BUG PREVENTED: Pesi molto bassi (warmup) senza rounding corretto
      // causerebbero "usa 0.8kg" quando minimum è 2.5kg.
    });
  });

  group('Integration Tests - Real World Scenarios', () {
    test('complete workout analysis flow', () {
      // 🏋️ SCENARIO REALE: Utente fa Bench Press workout
      final workingSets = [
        {'weight': 80.0, 'reps': 8, 'rpe': 7}, // Warmup progressivo
        {'weight': 90.0, 'reps': 5, 'rpe': 8}, // Ramping up
        {'weight': 95.0, 'reps': 3, 'rpe': 9}, // Top set
      ];
      
      // Calcola 1RM per ogni set
      final estimates = workingSets.map((set) {
        return OneRMCalculator.calculateWithRPE(
          set['weight'] as double,
          set['reps'] as int,
          set['rpe'] as int,
        );
      }).toList();
      
      // Tutti gli estimate dovrebbero convergere verso stesso 1RM
      final avgEstimate = estimates.reduce((a, b) => a + b) / estimates.length;
      for (final estimate in estimates) {
        expect((estimate - avgEstimate).abs(), lessThan(5.0)); // <5kg variance
      }
      
      // 🐛 BUG PREVENTED: Se formule fossero inconsistenti, stesso workout
      // darebbe stime "1RM = 105kg" e "1RM = 95kg" - quale è giusto?!
    });

    test('training program generation', () {
      // 🏋️ SCENARIO REALE: Generate 12-week strength program
      const oneRM = 100.0;

      // Week 1-4: Hypertrophy (8-12 reps @ 70-75%)
      final week1Weight = OneRMCalculator.calculateWeightForReps(oneRM, 10);
      expect(week1Weight, closeTo(75.0, 1.0)); // Formula: 100 × (37-10)/36 = 75kg

      // Week 5-8: Strength (4-6 reps @ 80-85%)
      final week5Weight = OneRMCalculator.calculateWeightForReps(oneRM, 5);
      expect(week5Weight, closeTo(88.89, 1.0)); // Formula: 100 × (37-5)/36 = 88.89kg

      // Week 9-12: Peaking (1-3 reps @ 90-95%)
      final week9Weight = OneRMCalculator.calculateWeightForReps(oneRM, 2);
      expect(week9Weight, closeTo(97.22, 1.0)); // Formula: 100 × (37-2)/36 = 97.22kg

      // 🐛 BUG PREVENTED: Se percentuali fossero sbagliate, intero programma
      // 12-week sarebbe troppo pesante o troppo leggero - utente fallisce goals!
    });

    test('progressive overload tracking', () {
      // 🏋️ SCENARIO REALE: Track progress over 8 weeks
      final week1 = OneRMCalculator.calculateAverage(80, 5); // ~95kg
      final week4 = OneRMCalculator.calculateAverage(85, 5); // ~100kg
      final week8 = OneRMCalculator.calculateAverage(90, 5); // ~106kg
      
      final progressWeek1to4 = week4 - week1;
      final progressWeek4to8 = week8 - week4;
      
      expect(progressWeek1to4, greaterThan(3.0)); // At least +3kg
      expect(progressWeek4to8, greaterThan(3.0)); // Consistent progress
      
      // 🐛 BUG PREVENTED: Se formule non fossero consistenti nel tempo,
      // progress tracking mostrerebbe "regressed from 100kg to 98kg"
      // quando utente in realtà è migliorato!
    });
  });
}
