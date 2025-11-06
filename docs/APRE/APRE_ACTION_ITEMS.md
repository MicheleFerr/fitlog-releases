# ✅ APRE SYSTEM - ACTION ITEMS & IMPLEMENTATION ROADMAP

**Data**: 2025-11-06  
**Priorità**: 4 Fasi (P1 → P4)  
**Estimated Time**: T1: 3-4h, T2: 5-6h, T3: 3-4h, T4: 2h

---

## 🎯 FASE 1 (P1): CORE FIXES - FONDAMENTALI ⚡

**Obiettivo**: Risolvere problemi di trasparenza e chiarezza nel calcolo 1RM

### T1.1: Aggiungere Enum `CalculationConfidence` in Domain

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Codice**:
```dart
/// Livelli di confidenza basati su qualità dati
enum CalculationConfidence {
  /// ≥10 set, < 7 giorni, SD ≤ 5%
  veryHigh,
  
  /// 7-9 set, < 14 giorni, SD ≤ 8%
  high,
  
  /// 4-6 set, < 30 giorni, SD ≤ 12%
  medium,
  
  /// 1-3 set, < 60 giorni
  low,
  
  /// 0 set - richiede input manuale
  unknown,
}

/// Estensione per helper text
extension ConfidenceHelper on CalculationConfidence {
  String get description {
    switch (this) {
      case CalculationConfidence.veryHigh:
        return '✅ Eccellente: dati ampi e consistenti';
      case CalculationConfidence.high:
        return '✅ Buono: dati sufficienti';
      case CalculationConfidence.medium:
        return '⚠️ Moderato: dati limitati';
      case CalculationConfidence.low:
        return '⚠️ Basso: pochi dati';
      case CalculationConfidence.unknown:
        return '❌ Non disponibile: richiesto input manuale';
    }
  }
  
  Color get uiColor {
    switch (this) {
      case CalculationConfidence.veryHigh:
      case CalculationConfidence.high:
        return Colors.green;
      case CalculationConfidence.medium:
        return Colors.orange;
      case CalculationConfidence.low:
        return Colors.red.shade300;
      case CalculationConfidence.unknown:
        return Colors.grey;
    }
  }
}
```

**Ticket**: [APRE-001] Add CalculationConfidence enum  
**Priority**: P0 (Blocker)  
**Time**: 30 min

---

### T1.2: Costante Formula 1RM Globale

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Codice**:
```dart
class APREAutoRegulationService {
  /// Formula scientifica usata per calcolo 1RM da storico
  static const String USED_1RM_FORMULA = 'Brzycki';
  
  /// Descrizione della formula
  static const String FORMULA_DESCRIPTION = 
    'Brzycki (1-10 reps): 1RM = weight × (36 / (37 - reps))';
  
  /// Range di validità della formula
  static const int MIN_FORMULA_REPS = 1;
  static const int MAX_FORMULA_REPS = 10;
  
  // ... resto della classe
}
```

**Ticket**: [APRE-002] Add global formula constant  
**Priority**: P0  
**Time**: 15 min

---

### T1.3: Implementare Helper Methods per Metadata

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Codice**:
```dart
static CalculationConfidence _calculateConfidence({
  required int dataPoints,
  required Duration dataAge,
  required double standardDeviation,
  required double estimated1RM,
}) {
  // Soglie variabili per confidence
  if (dataPoints >= 10 && dataAge.inDays <= 7 && standardDeviation <= 5) {
    return CalculationConfidence.veryHigh;
  } else if (dataPoints >= 7 && dataAge.inDays <= 14 && standardDeviation <= 8) {
    return CalculationConfidence.high;
  } else if (dataPoints >= 4 && dataAge.inDays <= 30 && standardDeviation <= 12) {
    return CalculationConfidence.medium;
  } else if (dataPoints >= 1) {
    return CalculationConfidence.low;
  } else {
    return CalculationConfidence.unknown;
  }
}

static Duration _calculateDataAge(List<dynamic> sets) {
  if (sets.isEmpty) return Duration.zero;
  
  final now = DateTime.now();
  final dates = sets.map((s) => s.date as DateTime).toList()..sort();
  final midIndex = dates.length ~/ 2;
  
  return now.difference(dates[midIndex]);
}

static double _calculateStandardDeviation(List<double> values) {
  if (values.length < 2) return 0;
  
  final mean = values.fold(0.0, (sum, v) => sum + v) / values.length;
  final variance = values
    .map((v) => pow(v - mean, 2) as double)
    .fold(0.0, (sum, v) => sum + v) / values.length;
  
  return sqrt(variance);
}

static List<double> _robustAverage(List<double> values) {
  if (values.isEmpty) return [];
  if (values.length == 1) return values;
  
  values.sort();
  
  // Calcola quartili per IQR (Interquartile Range)
  final q1Index = (values.length / 4).floor();
  final q3Index = ((values.length * 3) / 4).floor();
  final q1 = values[q1Index];
  final q3 = values[q3Index];
  final iqr = q3 - q1;
  
  // Rimuovi outlier
  final filtered = values.where((v) =>
    v >= (q1 - 1.5 * iqr) && v <= (q3 + 1.5 * iqr)
  ).toList();
  
  return filtered;
}
```

**Ticket**: [APRE-003] Add metadata calculation helpers  
**Priority**: P0  
**Time**: 45 min

---

### T1.4: Refactor `calculateAPREWeights()` con Metadata

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Codice**:
```dart
static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
  int? maxSetsToUse = 10,
}) {
  // HANDLE: Empty history
  if (historicalSets.isEmpty) {
    return {
      'calculated1RM': null,
      'calculated3RM': null,
      'calculated6RM': null,
      'calculated10RM': null,
      'confidence': CalculationConfidence.unknown,
      'dataPoints': 0,
      'formula': USED_1RM_FORMULA,
      'metadata': 'Nessuno storico disponibile - richiesto input manuale',
      'requiresManualInput': true,
      'standardDeviation': 0,
      'dataAge': Duration.zero,
    };
  }
  
  // STEP 1: Ordina per peso (top 10 o meno)
  final sortedByWeight = historicalSets
    .sorted((a, b) => b.weight.compareTo(a.weight));
  final topSets = sortedByWeight.take(maxSetsToUse ?? 10).toList();
  
  // STEP 2: Calcola 1RM per ogni set
  final estimates1RM = topSets.map((set) {
    return OneRMCalculator.calculateBrzycki(
      weight: set.weight as double,
      reps: set.reps as int,
    );
  }).toList();
  
  // STEP 3: Calcola dati statistici
  final dataAge = _calculateDataAge(topSets);
  final stdDev = _calculateStandardDeviation(estimates1RM);
  final robustAvgEstimates = _robustAverage(estimates1RM);
  
  final calculated1RM = robustAvgEstimates.isNotEmpty
    ? robustAvgEstimates.fold(0.0, (sum, v) => sum + v) / robustAvgEstimates.length
    : estimates1RM.fold(0.0, (sum, v) => sum + v) / estimates1RM.length;
  
  // STEP 4: Calcola confidence
  final confidence = _calculateConfidence(
    dataPoints: topSets.length,
    dataAge: dataAge,
    standardDeviation: stdDev,
    estimated1RM: calculated1RM,
  );
  
  // STEP 5: Ritorna metadata completo
  return {
    'calculated1RM': calculated1RM,
    'calculated3RM': calculated1RM * 0.92,
    'calculated6RM': calculated1RM * 0.83,
    'calculated10RM': calculated1RM * 0.75,
    'confidence': confidence,
    'dataPoints': topSets.length,
    'formula': USED_1RM_FORMULA,
    'standardDeviation': stdDev,
    'dataAge': dataAge,
    'metadata': 'Based on ${topSets.length} sets (Formula: $USED_1RM_FORMULA, '
        'Confidence: ${confidence.name}, ±${stdDev.toStringAsFixed(1)}kg)',
    'requiresManualInput': false,
  };
}
```

**Ticket**: [APRE-004] Refactor calculateAPREWeights with metadata  
**Priority**: P0  
**Time**: 1h

---

### T1.5: Aggiungere Exception `WorkoutInProgressException`

**File**: `/lib/features/workout/domain/exceptions/workout_exceptions.dart` (NUOVO FILE)

**Codice**:
```dart
class WorkoutInProgressException implements Exception {
  final String message;
  
  WorkoutInProgressException(this.message);
  
  @override
  String toString() => 'WorkoutInProgressException: $message';
}

class APREConfigurationException implements Exception {
  final String message;
  
  APREConfigurationException(this.message);
  
  @override
  String toString() => 'APREConfigurationException: $message';
}
```

**Ticket**: [APRE-005] Add custom exceptions  
**Priority**: P0  
**Time**: 20 min

---

## 🎨 FASE 2 (P2): UI IMPROVEMENTS - VISIBILITÀ 👁️

**Obiettivo**: Migliorare UX con metadata display, tooltip, warning

### T2.1: Creare Widget `CalculationMetadataDisplay`

**File**: `/lib/features/workout/presentation/widgets/apre_metadata_display.dart` (NUOVO FILE)

**Codice**:
```dart
class CalculationMetadataDisplay extends StatelessWidget {
  final Map<String, dynamic> calculations;
  final VoidCallback? onRecalculate;
  
  const CalculationMetadataDisplay({
    required this.calculations,
    this.onRecalculate,
  });
  
  @override
  Widget build(BuildContext context) {
    final conf = calculations['confidence'] as CalculationConfidence;
    final stdDev = calculations['standardDeviation'] as double;
    final dataAge = calculations['dataAge'] as Duration;
    final formula = calculations['formula'] as String;
    final dataPoints = calculations['dataPoints'] as int;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 8),
                Text(
                  'Analisi dei Tuoi Dati',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Formula
            _buildMetadataRow(
              label: 'Formula:',
              value: '$formula (standard scientifico)',
              icon: Icons.calculate,
            ),
            
            // Data points
            _buildMetadataRow(
              label: 'Set analizzati:',
              value: '$dataPoints / 10 (top 10 per peso)',
              icon: Icons.dataset,
              color: conf.uiColor,
            ),
            
            // Data age
            _buildMetadataRow(
              label: 'Dati da:',
              value: '${dataAge.inDays} giorni fa (media)',
              icon: Icons.access_time,
              warning: dataAge.inDays > 7 
                ? '⚠️ Considera ricacolo' 
                : null,
            ),
            
            // Variabilità
            _buildMetadataRow(
              label: 'Variabilità:',
              value: '±${stdDev.toStringAsFixed(1)} kg',
              icon: Icons.show_chart,
            ),
            
            // Confidence con tooltip
            _buildConfidenceRow(context, conf),
            
            // Recalculate button
            if (onRecalculate != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRecalculate,
                  icon: Icon(Icons.refresh),
                  label: Text('🔄 Ricacola 1RM Adesso'),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataRow({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
    String? warning,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              SizedBox(width: 8),
              Text(label),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value),
                if (warning != null)
                  Text(
                    warning,
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfidenceRow(BuildContext context, CalculationConfidence conf) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user, size: 18),
            SizedBox(width: 8),
            Text('Affidabilità:'),
          ],
        ),
        Tooltip(
          message: conf.description,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: conf.uiColor.withOpacity(0.2),
              border: Border.all(color: conf.uiColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              conf.name.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: conf.uiColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Ticket**: [APRE-006] Create metadata display widget  
**Priority**: P1  
**Time**: 1h

---

### T2.2: Creare Widget `AutoAdjustmentModalNoHistory`

**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal_no_history.dart` (NUOVO FILE)

**Lunghezza**: ~200 linee (vedi documento APRE_MIGLIORAMENTI.md per full code)

**Ticket**: [APRE-007] Create no-history dialog  
**Priority**: P1  
**Time**: 1.5h

---

### T2.3: Migliorare `AutoAdjustmentModal` - Protocol Preview

**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (MODIFICA)

**Codice key changes**:
```dart
// Aggiungi preview widget
Widget _buildProtocolPreview() {
  final baseWeight = exercise.apreBaseWeight!;
  final structure = APREService.getAPRESetStructure(
    _selectedProtocol,
    baseWeight,
  );
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      border: Border.all(color: Colors.blue.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pesi previsti con Protocol $_selectedProtocol:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...structure.indexed.map((indexed) {
          final (index, set) = indexed;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Set ${set.setNumber}: ${set.targetReps}? reps'),
                Text(
                  '${set.weight?.toStringAsFixed(1)} kg',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}
```

**Ticket**: [APRE-008] Add protocol preview in modal  
**Priority**: P1  
**Time**: 45 min

---

### T2.4: Aggiungere Warning Dialog per Protocol Change Mid-Workout

**File**: `/lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (MODIFICA)

**Codice**:
```dart
void _showProtocolChangeWarning(int newProtocol) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('⚠️ Cambio Protocol'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Non puoi cambiare protocol durante il workout.'),
          SizedBox(height: 12),
          Text('Opzioni:'),
          SizedBox(height: 8),
          Text('1️⃣ Finisci questo workout'),
          Text('2️⃣ Scarta le modifiche'),
          Text('3️⃣ Crea nuovo esercizio con Protocol $newProtocol'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => _selectedProtocol = exercise.apreProtocol!);
            Navigator.pop(ctx);
          },
          child: Text('Mantieni Protocol ${exercise.apreProtocol}'),
        ),
      ],
    ),
  );
}
```

**Ticket**: [APRE-009] Add protocol change warning  
**Priority**: P1  
**Time**: 30 min

---

### T2.5: Visualizzare Metadata nel Banner di Suggerimento Set 4

**File**: `/lib/features/workout/presentation/widgets/edit_set_modal.dart` (MODIFICA)

**Codice** (improvement):
```dart
// Nel banner suggerimento APRE
if (_suggestedWeight != null && _showWeightSuggestionBanner)
  Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('📊 APRE Suggestion'),
          ],
        ),
        SizedBox(height: 8),
        Text('Set next weight to: ${_suggestedWeight!.toStringAsFixed(1)} kg'),
        Text(
          'Based on ${_actualReps} actual vs ${_targetReps} target reps',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        // Metadata visibile
        if (widget.exercise?.calculationMetadata != null)
          Text(
            'Calculated: ${widget.exercise!.calculationMetadata}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
      ],
    ),
  ),
```

**Ticket**: [APRE-010] Add metadata to set 4 suggestion  
**Priority**: P1  
**Time**: 30 min

---

## 🔧 FASE 3 (P3): CONFIGURABILITÀ - FLESSIBILITÀ ⚙️

**Obiettivo**: Permettere user di configurare come calcolare 1RM

### T3.1: Aggiungere Enum `OneRMCalculationConfig`

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart` (MODIFICA)

**Codice**:
```dart
enum SelectionMethod {
  topByWeight,            // Top 10 per peso assoluto
  topByEstimated1RM,      // Top 10 per 1RM stimato
  topByRecency,           // Set più recenti
  all,                    // Tutti i set
}

enum AveragingMethod {
  mean,                   // Media semplice
  robustMedian,           // Mediana (remove outliers) ← Default
  weightedRecency,        // Media pesata (più recenti = peso alto)
}

class OneRMCalculationConfig {
  final int? maxSetsToUse;
  final int? daysRecent;
  final SelectionMethod method;
  final AveragingMethod averaging;
  
  OneRMCalculationConfig({
    this.maxSetsToUse = 10,
    this.daysRecent,
    this.method = SelectionMethod.topByWeight,
    this.averaging = AveragingMethod.robustMedian,
  });
  
  // Presets
  static final scientificDefault = OneRMCalculationConfig();
  
  static final conservativeRecent = OneRMCalculationConfig(
    maxSetsToUse: 5,
    daysRecent: 30,
    method: SelectionMethod.topByWeight,
    averaging: AveragingMethod.robustMedian,
  );
  
  static final aggressive = OneRMCalculationConfig(
    maxSetsToUse: 20,
    daysRecent: 60,
    method: SelectionMethod.topByEstimated1RM,
    averaging: AveragingMethod.mean,
  );
}
```

**Ticket**: [APRE-011] Add OneRMCalculationConfig  
**Priority**: P2  
**Time**: 45 min

---

### T3.2: Implementare `_selectTopSets()` Configurabile

**File**: `/lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Codice**:
```dart
static List<dynamic> _selectTopSets(
  List<dynamic> sets,
  int maxSets,
  SelectionMethod method,
) {
  switch (method) {
    case SelectionMethod.topByWeight:
      return sets
        .sorted((a, b) => (b.weight as double).compareTo(a.weight as double))
        .take(maxSets)
        .toList();
      
    case SelectionMethod.topByEstimated1RM:
      return sets
        .sorted((a, b) {
          final est1rmA = OneRMCalculator.calculateBrzycki(
            weight: a.weight as double,
            reps: a.reps as int,
          );
          final est1rmB = OneRMCalculator.calculateBrzycki(
            weight: b.weight as double,
            reps: b.reps as int,
          );
          return est1rmB.compareTo(est1rmA);
        })
        .take(maxSets)
        .toList();
      
    case SelectionMethod.topByRecency:
      return sets
        .sorted((a, b) => (b.date as DateTime).compareTo(a.date as DateTime))
        .take(maxSets)
        .toList();
      
    case SelectionMethod.all:
      return sets;
  }
}
```

**Ticket**: [APRE-012] Implement _selectTopSets  
**Priority**: P2  
**Time**: 30 min

---

### T3.3: Aggiungere Settings UI per APRE Advanced

**File**: `/lib/features/workout/presentation/widgets/workout_customization_modal_v3.dart` (MODIFICA)

**Codice** (~100 linee):
```dart
// ExpansionTile in customization modal
ExpansionTile(
  title: Text('APRE - Impostazioni Avanzate'),
  children: [
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Preset selector
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'default', label: Text('Scientifico')),
              ButtonSegment(value: 'conservative', label: Text('Conservativo')),
              ButtonSegment(value: 'aggressive', label: Text('Aggressivo')),
            ],
            selected: {_oneRMPreset},
            onSelectionChanged: (selection) {
              setState(() => _oneRMPreset = selection.first);
            },
          ),
          SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _forceRecalculateAll1RMs,
            icon: Icon(Icons.refresh),
            label: Text('🔄 Ricacola Tutti i 1RM'),
          ),
        ],
      ),
    ),
  ],
)
```

**Ticket**: [APRE-013] Add advanced settings UI  
**Priority**: P2  
**Time**: 1h

---

## 🧪 FASE 4 (P4): TESTING & VALIDATION - ROBUSTEZZA 🛡️

**Obiettivo**: Comprehensive test coverage per edge cases

### T4.1: Test Suite - No History Scenarios

**File**: `/test/features/workout/domain/services/apre_auto_regulation_service_test.dart` (MODIFICA)

**Codice**:
```dart
group('calculateAPREWeights - No History Edge Cases', () {
  test('Empty historical sets returns unknown confidence', () {
    final result = APREAutoRegulationService.calculateAPREWeights(
      historicalSets: [],
      protocol: 6,
    );
    
    expect(result['confidence'], CalculationConfidence.unknown);
    expect(result['dataPoints'], 0);
    expect(result['requiresManualInput'], true);
  });
  
  test('Single set returns low confidence', () {
    final result = APREAutoRegulationService.calculateAPREWeights(
      historicalSets: [
        {'weight': 100.0, 'reps': 1, 'date': DateTime.now()},
      ],
      protocol: 6,
    );
    
    expect(result['confidence'], CalculationConfidence.low);
    expect(result['dataPoints'], 1);
  });
  
  test('Metadata includes formula info', () {
    final result = APREAutoRegulationService.calculateAPREWeights(
      historicalSets: [
        {'weight': 100.0, 'reps': 5, 'date': DateTime.now()},
      ],
      protocol: 6,
    );
    
    expect(result['formula'], 'Brzycki');
    expect(result['metadata'], contains('Brzycki'));
  });
});
```

**Ticket**: [APRE-014] Add no-history tests  
**Priority**: P3  
**Time**: 45 min

---

### T4.2: Test Suite - Protocol Change Mid-Workout

**File**: `/test/features/workout/presentation/providers/workout_provider_test.dart` (NUOVO)

**Codice**:
```dart
group('Protocol Change Mid-Workout', () {
  test('Cannot change protocol if workout active', () {
    final provider = WorkoutProvider();
    provider.startWorkout(workout);
    
    expect(
      () => provider.updateExerciseProtocol(exerciseId, 3),
      throwsA(isA<WorkoutInProgressException>()),
    );
  });
  
  test('Can change protocol after workout finished', () async {
    final provider = WorkoutProvider();
    provider.startWorkout(workout);
    provider.finishWorkout();
    
    // Should not throw
    await provider.updateExerciseProtocol(exerciseId, 3);
  });
});
```

**Ticket**: [APRE-015] Add protocol change tests  
**Priority**: P3  
**Time**: 30 min

---

### T4.3: Test Suite - Confidence Calculation

**File**: `/test/features/workout/domain/services/apre_auto_regulation_service_test.dart` (MODIFICA)

**Codice**:
```dart
group('Confidence Calculation', () {
  test('10+ sets, fresh, low SD → veryHigh', () {
    final result = APREAutoRegulationService.calculateAPREWeights(
      historicalSets: List.generate(
        12,
        (i) => {
          'weight': 100.0 + i,
          'reps': 1,
          'date': DateTime.now().subtract(Duration(days: 2)),
        },
      ),
      protocol: 6,
    );
    
    expect(result['confidence'], CalculationConfidence.veryHigh);
  });
  
  test('7-9 sets, moderate age → high', () {
    final result = APREAutoRegulationService.calculateAPREWeights(
      historicalSets: List.generate(
        8,
        (i) => {
          'weight': 100.0 + i,
          'reps': 1,
          'date': DateTime.now().subtract(Duration(days: 5)),
        },
      ),
      protocol: 6,
    );
    
    expect(result['confidence'], CalculationConfidence.high);
  });
});
```

**Ticket**: [APRE-016] Add confidence calculation tests  
**Priority**: P3  
**Time**: 45 min

---

### T4.4: Integration Test - Full APRE Flow

**File**: `/test/features/workout/presentation/widgets/auto_adjustment_modal_test.dart` (NUOVO)

**Codice** (~80 linee):
```dart
void main() {
  group('AutoAdjustmentModal Integration', () {
    testWidgets('Shows no-history dialog on first config', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoAdjustmentModal(
              exercise: Exercise(name: 'Bench', historicalSets: []),
            ),
          ),
        ),
      );
      
      expect(find.byType(AutoAdjustmentModalNoHistory), findsOneWidget);
    });
    
    testWidgets('Shows metadata display after calculation', (tester) async {
      // Setup mock calculations
      final calculations = {
        'confidence': CalculationConfidence.high,
        'dataPoints': 8,
        'standardDeviation': 2.1,
        'dataAge': Duration(days: 5),
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculationMetadataDisplay(
              calculations: calculations,
            ),
          ),
        ),
      );
      
      expect(find.text('Analisi dei Tuoi Dati'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);
    });
  });
}
```

**Ticket**: [APRE-017] Add integration test  
**Priority**: P3  
**Time**: 1h

---

## 📋 IMPLEMENTATION CHECKLIST

### Priorità: P0 (CRITICAL)
- [ ] T1.1 - Add CalculationConfidence enum
- [ ] T1.2 - Add formula constant
- [ ] T1.3 - Add metadata helpers
- [ ] T1.4 - Refactor calculateAPREWeights
- [ ] T1.5 - Add custom exceptions

### Priorità: P1 (HIGH)
- [ ] T2.1 - Create metadata display widget
- [ ] T2.2 - Create no-history dialog
- [ ] T2.3 - Add protocol preview
- [ ] T2.4 - Add warning for protocol change
- [ ] T2.5 - Add metadata to set 4 banner

### Priorità: P2 (MEDIUM)
- [ ] T3.1 - Add calculation config
- [ ] T3.2 - Implement _selectTopSets
- [ ] T3.3 - Add advanced settings UI

### Priorità: P3 (LOW)
- [ ] T4.1 - No-history tests
- [ ] T4.2 - Protocol change tests
- [ ] T4.3 - Confidence tests
- [ ] T4.4 - Integration tests

---

## ⏱️ TIMELINE STIMA

| Fase | Ticket | Time | Totale |
|------|--------|------|--------|
| **P0** | T1.1-T1.5 | 30+15+45+60+20 | **2.5h** |
| **P1** | T2.1-T2.5 | 60+90+45+30+30 | **4.25h** |
| **P2** | T3.1-T3.3 | 45+30+60 | **2.25h** |
| **P3** | T4.1-T4.4 | 45+30+45+60 | **2.75h** |
| **TOTAL** | - | - | **~12h** |

---

## 🎯 SUCCESS CRITERIA

- [ ] All P0 tasks completed
- [ ] No P1 crashes or console errors
- [ ] 85%+ test coverage for APRE module
- [ ] User can understand: formula, confidence, data age
- [ ] No silent failures (all edge cases handled)
- [ ] Mid-workout protocol change blocked with clear error
- [ ] No-history scenario fully supported with UI
- [ ] All tooltip/helper text i18n-ready (EN/IT)

---

## 📞 NOTES FOR DEVELOPER

1. **Start with P0**: Foundation must be solid
2. **Test as you go**: Each task should have tests
3. **UI Polish last**: T2 can iterate based on P0 results
4. **Documentation**: Update code comments for clarity
5. **Localization**: Keep keys consistent for i18n

---

**Document Status**: ✅ Completato  
**Last Update**: 2025-11-06  
**Ready for Implementation**: ✅ YES
