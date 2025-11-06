# 🚀 APRE SYSTEM - MIGLIORAMENTI FRUIBILITÀ & CHIARIMENTI

**Data**: 2025-11-06  
**Status**: Analisi dettagliata con proposte concrete di improvement

---

## 📋 RISPOSTE ALLE TUE 4 DOMANDE SPECIFICHE

### ❓ #1: "Come funziona esattamente il calcolo 1RM da history?"

#### Situazione attuale
```dart
// APREAutoRegulationService.calculateAPREWeights()
// Linea cruciale: "Based on 10 sets (Confidence: High)"

static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,  // ← COME VIENE ORDINATA?
  required int protocol,
  bool useMetricSystem = true,
})
// Output: 'metadata': 'Based on 10 sets (Confidence: High)'
```

#### PROBLEMI identificati

1. **❌ Formula non specificata**: Quale formula Brzycki/Epley/Lander usa?
   - Non è documentato nel codice
   - Non c'è costante `const formulaUsed = 'Brzycki'`
   - User non sa quale sia

2. **❌ Ordinamento ambiguo**: Come ordina i "top 10"?
   ```
   Opzione A: Top 10 per PESO (max weight)
   Opzione B: Top 10 per DATA (più recenti)
   Opzione C: Top 10 per ESTIMATED 1RM
   Opzione D: Top 10 per (peso × reps) = volume
   ```
   **ATTUALMENTE**: Non è chiaro dalla documentazione

3. **❌ Cosa succede se < 10 set?**
   ```
   Scenario: User nuovo, solo 3 set registrati
   
   Logica attuale: "Top 10" ma ce ne sono solo 3
   → Usa i 3 disponibili?
   → Metadata che dice? 'Based on 3 sets (Confidence: Low)'?
   → Non è gestito!
   ```

4. **❌ Metadata vago**: "Confidence: High" non significa nulla
   ```
   Cosa determina confidence?
   - Numero di set?
   - Anzianità dei dati?
   - Consistenza reps?
   - Variabilità peso?
   
   Attualmente: Magico, non documentato!
   ```

#### 🎯 PROPOSTA DI MIGLIORAMENTO #1

```dart
// APREAutoRegulationService.calculateAPREWeights() MIGLIORATO

/// Confidenza calcolata basata su qualità dati disponibili
enum CalculationConfidence {
  veryHigh,   // ≥ 10 set, < 7 giorni, SD ≤ 5%
  high,       // 7-9 set, < 14 giorni, SD ≤ 8%
  medium,     // 4-6 set, < 30 giorni, SD ≤ 12%
  low,        // 1-3 set, qualsiasi data
  unknown,    // 0 set (user deve input manuale)
}

/// Formula OneRM usata nel sistema
const String USED_1RM_FORMULA = 'Brzycki';  // ← DOCUMENTA

static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
}) {
  // STEP 1: Ordina per criterio chiaro
  final sortedByWeight = historicalSets.sort((a, b) => b.weight.compareTo(a.weight));
  
  // STEP 2: Prendi TOP 10 (o meno se disponibili)
  final topSets = sortedByWeight.take(10).toList();
  
  // STEP 3: Se < 10, calcola confidence ridotta
  late CalculationConfidence confidence;
  if (topSets.isEmpty) {
    confidence = CalculationConfidence.unknown;
    return {
      'calculated1RM': null,
      'confidence': confidence,
      'dataPoints': 0,
      'warning': 'Nessuno storico disponibile. Inserisci manualmente il tuo 1RM stimato.',
      'metadata': 'Nessun set storico - richiesto input manuale',
    };
  } else if (topSets.length >= 10) {
    confidence = CalculationConfidence.high;
  } else if (topSets.length >= 7) {
    confidence = CalculationConfidence.medium;
  } else {
    confidence = CalculationConfidence.low;
  }
  
  // STEP 4: Calcola 1RM per ogni set usando formula specificata
  final estimates1RM = topSets.map((set) {
    return OneRMCalculator.calculateBrzycki(
      weight: set.weight,
      reps: set.reps,
    );
  }).toList();
  
  // STEP 5: Media con robustezza (remove outliers?)
  final calculated1RM = _robustAverage(estimates1RM);
  
  // STEP 6: Return con metadata TRASPARENTE
  return {
    'calculated1RM': calculated1RM,
    'calculated3RM': calculated1RM * 0.92,
    'calculated6RM': calculated1RM * 0.83,
    'calculated10RM': calculated1RM * 0.75,
    'confidence': confidence,
    'dataPoints': topSets.length,
    'formula': USED_1RM_FORMULA,  // ← NUOVO: Specifica formula
    'metadata': 'Based on ${topSets.length} sets (Formula: $USED_1RM_FORMULA, Confidence: ${confidence.name})',
    'ageOfData': _calculateDataAge(topSets),  // ← NUOVO: Quanto vecchi i dati?
    'stdDeviation': _calculateStandardDeviation(estimates1RM),  // ← NUOVO: Variabilità
  };
}

/// Calcola età media dei dati
static Duration _calculateDataAge(List<dynamic> sets) {
  if (sets.isEmpty) return Duration.zero;
  
  final now = DateTime.now();
  final avgDate = sets
    .map((s) => s.date as DateTime)
    .reduce((a, b) => DateTime.fromMillisecondsSinceEpoch(
      (a.millisecondsSinceEpoch + b.millisecondsSinceEpoch) ~/ 2
    ));
  
  return now.difference(avgDate);
}

/// Media robusta (remove outliers con IQR)
static double _robustAverage(List<double> values) {
  if (values.isEmpty) return 0;
  if (values.length == 1) return values.first;
  
  values.sort();
  final q1Index = (values.length / 4).floor();
  final q3Index = ((values.length * 3) / 4).floor();
  
  final q1 = values[q1Index];
  final q3 = values[q3Index];
  final iqr = q3 - q1;
  
  final filtered = values.where((v) =>
    v >= (q1 - 1.5 * iqr) && v <= (q3 + 1.5 * iqr)
  ).toList();
  
  return filtered.fold(0, (sum, v) => sum + v) / filtered.length;
}
```

#### 🎨 MIGLIORAMENTO UI (AutoAdjustmentModal)

```dart
// autoAdjustmentModal_improved.dart

Widget _buildCalculationMetadata() {
  return Card(
    color: Colors.blue.shade50,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header trasparente
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
          
          // Riga 1: Formula usata
          _buildMetadataRow(
            label: 'Formula:',
            value: 'Brzycki (standard scientifico)',
            icon: Icons.calculate,
          ),
          
          // Riga 2: Quanti set
          _buildMetadataRow(
            label: 'Set analizzati:',
            value: '${_calculations['dataPoints']} / 10 (top 10 per peso)',
            icon: Icons.dataset,
            color: _confidenceColor(_calculations['confidence']),
          ),
          
          // Riga 3: Età dati
          _buildMetadataRow(
            label: 'Dati da:',
            value: '${_ageOfDataDays} giorni fa (media)',
            icon: Icons.access_time,
            warning: _ageOfDataDays > 7 ? '⚠️ Considera ricacolo' : null,
          ),
          
          // Riga 4: Variabilità
          _buildMetadataRow(
            label: 'Variabilità:',
            value: '±${_calculations['stdDeviation'].toStringAsFixed(1)} kg',
            icon: Icons.show_chart,
          ),
          
          // Riga 5: Confidence con tooltip
          Row(
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
                message: _getConfidenceTooltip(_calculations['confidence']),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _confidenceColor(_calculations['confidence']).withOpacity(0.2),
                    border: Border.all(
                      color: _confidenceColor(_calculations['confidence']),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _calculations['confidence'].name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _confidenceColor(_calculations['confidence']),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _getConfidenceTooltip(CalculationConfidence conf) {
  return {
    CalculationConfidence.veryHigh: '✅ Eccellente: ≥10 set recenti, dati consistenti',
    CalculationConfidence.high: '✅ Buono: 7-9 set, variabilità normale',
    CalculationConfidence.medium: '⚠️ Moderato: 4-6 set, ricacola quando possibile',
    CalculationConfidence.low: '⚠️ Basso: 1-3 set soli, aggiungi più dati',
    CalculationConfidence.unknown: '❌ Non disponibile: inserisci manualmente',
  }[conf] ?? '';
}

Color _confidenceColor(CalculationConfidence conf) {
  return {
    CalculationConfidence.veryHigh: Colors.green,
    CalculationConfidence.high: Colors.green.shade700,
    CalculationConfidence.medium: Colors.orange,
    CalculationConfidence.low: Colors.red.shade300,
    CalculationConfidence.unknown: Colors.grey,
  }[conf] ?? Colors.grey;
}

// Pulsante "Ricacola Manuale"
ElevatedButton(
  onPressed: _recalculateManually,
  child: Text('🔄 Ricacola 1RM Adesso'),
),
```

---

### ❓ #2: "Cosa succede se cambio protocol da 6 a 3?"

#### Situazione attuale

```dart
// User modifica: apreProtocol: 6 → 3
// In AutoAdjustmentModal:
exercise = exercise.copyWith(
  apreProtocol: 3,  // ← CAMBIO
);

// MA: Cosa succede ai pesi Set 1-4?
// Cosa succede se sono IN MEZZO al workout?
```

#### PROBLEMI identificati

1. **❌ I pesi Set 1-4 si ricacalano?**
   ```
   Set structure attuale (Protocol 6):
   Set 1: 41.5kg (50% 1RM)
   Set 2: 62.25kg (75% 1RM)
   Set 3: 83kg (100% 1RM)
   Set 4: Adjusted (?)
   
   Se cambio a Protocol 3 (92% 1RM):
   Set 1: 46.0kg (50% 1RM) ← CAMBIEREBBE?
   Set 2: 69.0kg (75% 1RM) ← CAMBIEREBBE?
   Set 3: 92.0kg (100% 1RM) ← CAMBIEREBBE!
   Set 4: Adjusted (?)
   
   ATTUALMENTE: Non è gestito!
   ```

2. **❌ Durante workout in corso?**
   ```
   User ha completato Set 1-2 con Protocol 6
   Poi cambia a Protocol 3
   
   Scenario:
   - Set 1-2 sono già saved con Protocol 6
   - Set 3-4 userebbero Protocol 3
   - Inconsistenza nel workout!
   ```

3. **❌ Warn user o silent change?**
   ```
   Opzione A: Silenzioso (male!)
   Opzione B: Modal warning (bene!)
   Opzione C: Preview peso nuovo (ottimo!)
   
   ATTUALMENTE: Silenzioso
   ```

#### 🎯 PROPOSTA DI MIGLIORAMENTO #2

```dart
// APREAutoRegulationService.changeProtocol() NUOVO METODO

/// Cambia protocol con validazione e ricacolo
static Exercise changeProtocol({
  required Exercise exercise,
  required int newProtocol,
  required bool isWorkoutInProgress,
}) {
  // VALIDAZIONE 1: Protocollo valido?
  if (![3, 6, 10].contains(newProtocol)) {
    throw ArgumentError('Protocol must be 3, 6, or 10');
  }
  
  // VALIDAZIONE 2: Se workout in corso, warn!
  if (isWorkoutInProgress) {
    throw WorkoutInProgressException(
      'Cannot change protocol during active workout. '
      'Finish current workout or discard changes.',
    );
  }
  
  // STEP 1: Ricacola pesi Set 1-4
  final newSetStructure = getAPRESetStructure(
    newProtocol,
    exercise.apreBaseWeight!,
  );
  
  // STEP 2: Update exercise con nuovo protocol
  return exercise.copyWith(
    apreProtocol: newProtocol,
    // ← I pesi saranno auto-calcolati quando caricati
    // NON salvare pesi singoli, calcolarli on-the-fly
  );
}
```

#### 🎨 MIGLIORAMENTO UI (AutoAdjustmentModal)

```dart
// auto_adjustment_modal_improved.dart

// Protocol Selector con Preview
Widget _buildProtocolSelector() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APRE Protocol',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          
          // Segmented Button con preview
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 3,
                label: Text('3 (Strength)'),
                tooltip: '3RM @ 92% - 3min rest\nSet: 50%, 75%, 92%, Adjusted',
              ),
              ButtonSegment(
                value: 6,
                label: Text('6 (Hypertrophy)'),
                tooltip: '6RM @ 83% - 2min rest\nSet: 50%, 75%, 83%, Adjusted',
              ),
              ButtonSegment(
                value: 10,
                label: Text('10 (Endurance)'),
                tooltip: '10RM @ 75% - 1min rest\nSet: 50%, 75%, 75%, Adjusted',
              ),
            ],
            selected: {_selectedProtocol},
            onSelectionChanged: (newSelection) {
              final newProtocol = newSelection.first;
              
              // Se cambio mid-workout, show warning
              if (_isWorkoutInProgress) {
                _showProtocolChangeWarning(newProtocol);
              } else {
                // Preview nuovo structure
                _showProtocolPreview(newProtocol);
              }
              
              setState(() => _selectedProtocol = newProtocol);
            },
          ),
          
          // Preview pesi nuovo protocol
          SizedBox(height: 16),
          if (_showPreview) _buildProtocolPreview(),
        ],
      ),
    ),
  );
}

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
          'Pesi previsti con Protocol ${_selectedProtocol}:',
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
          Text('3️⃣ Crea un nuovo esercizio con Protocol $newProtocol'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            // Discard changes to current protocol
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

#### 💾 Aggiorna Workout Provider

```dart
// workout_provider_improved.dart

Future<void> updateExerciseProtocol({
  required String exerciseId,
  required int newProtocol,
}) async {
  // Check: Workout in progress?
  final currentWorkout = state.currentWorkout;
  if (currentWorkout != null && currentWorkout.isActive) {
    throw WorkoutInProgressException(
      'Cannot modify exercise protocol during active workout',
    );
  }
  
  // Update exercise
  final exercise = state.exercises[exerciseId]!;
  final updated = APREAutoRegulationService.changeProtocol(
    exercise: exercise,
    newProtocol: newProtocol,
    isWorkoutInProgress: false,
  );
  
  // Save & broadcast
  await _exerciseRepository.update(updated);
  state = state.copyWith(
    exercises: {...state.exercises, exerciseId: updated},
  );
}
```

---

### ❓ #3: "Come gestisce il caso senza history?"

#### Situazione attuale

```dart
// User nuovo o esercizio nuovo
// historicalSets.isEmpty

// Attualmente: ???
// Documentazione non specifica
```

#### PROBLEMI identificati

1. **❌ Nessuna gestione esplicita**
   ```
   Se no history:
   - Crash? (null pointer)
   - Default? (quale?)
   - Chiede input? (non implementato)
   ```

2. **❌ User non sa cosa fare**
   ```
   User: "Sono nuovo, non ho history"
   App: ... (silenzio)
   ```

3. **❌ Fallback non documentato**
   ```
   Forse usa:
   - Default 1RM?
   - Formula 5 reps × peso?
   - Chiede manualmente?
   - Non supporta APRE se no history?
   ```

#### 🎯 PROPOSTA DI MIGLIORAMENTO #3

```dart
// APREAutoRegulationService.calculateAPREWeights() - CASO NO HISTORY

static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
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
      'metadata': 'Nessuno storico - richiesto input manuale',
      'requiresManualInput': true,
      'suggestedInputMethod': 'EstimateFrom1RMKnown',  // User conosce 1RM?
    };
  }
  
  // ... resto della logica
}
```

#### 🎨 MIGLIORAMENTO UI (AutoAdjustmentModal - NO HISTORY CASE)

```dart
// auto_adjustment_modal_no_history.dart

class AutoAdjustmentModalNoHistory extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onSaved;

  @override
  State<AutoAdjustmentModalNoHistory> createState() =>
      _AutoAdjustmentModalNoHistoryState();
}

class _AutoAdjustmentModalNoHistoryState extends State<AutoAdjustmentModalNoHistory> {
  late TextEditingController _oneRmController;
  String _inputMethod = 'EstimateFrom1RM'; // Or '1RM from test', 'From last workout'

  @override
  void initState() {
    super.initState();
    _oneRmController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('⚠️ Nessuno Storico'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Non ho dati storici per ${widget.exercise.name}.\n'
              'Per attivare APRE, dammi il tuo 1RM stimato.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            
            // Metodo input
            Text('Come stimi il tuo 1RM?', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // Radio 1: Da ultimo workout
            RadioListTile<String>(
              title: Text('📊 Dal mio ultimo workout'),
              subtitle: Text('Usa il peso massimo completato'),
              value: 'FromLastWorkout',
              groupValue: _inputMethod,
              onChanged: (value) => setState(() => _inputMethod = value!),
            ),
            
            // Radio 2: Stimato
            RadioListTile<String>(
              title: Text('💡 Stima personale'),
              subtitle: Text('Conosci il tuo 1RM stimato'),
              value: 'EstimateFrom1RM',
              groupValue: _inputMethod,
              onChanged: (value) => setState(() => _inputMethod = value!),
            ),
            
            // Radio 3: Test
            RadioListTile<String>(
              title: Text('🧪 Voglio fare un test'),
              subtitle: Text('Scopri il tuo vero 1RM'),
              value: 'DoTest',
              groupValue: _inputMethod,
              onChanged: (value) => setState(() => _inputMethod = value!),
            ),
            
            SizedBox(height: 16),
            
            // Input field (se Estimate o LastWorkout selezionati)
            if (_inputMethod != 'DoTest') ...[
              TextField(
                controller: _oneRmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Inserisci 1RM (kg)',
                  hintText: 'Es: 100',
                  suffix: Text('kg'),
                  helperText: _getHelperText(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                '💡 Tip: Se non sei sicuro, inizia con un valore conservativo.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            
            // Preview risultati
            if (_oneRmController.text.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildCalculationPreview(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _oneRmController.text.isNotEmpty
              ? () => _saveManualEntry()
              : null,
          child: Text('Salva e Attiva APRE'),
        ),
      ],
    );
  }

  String _getHelperText() {
    switch (_inputMethod) {
      case 'FromLastWorkout':
        return 'Qual è il peso massimo che hai sollevato?';
      case 'EstimateFrom1RM':
        return 'Qual è il tuo 1RM stimato?';
      case 'DoTest':
        return 'Ti guiderò attraverso un test 1RM';
      default:
        return '';
    }
  }

  Widget _buildCalculationPreview() {
    final input = double.tryParse(_oneRmController.text) ?? 0;
    final rm3 = input * 0.92;
    final rm6 = input * 0.83;
    final rm10 = input * 0.75;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Con 1RM ${input.toStringAsFixed(0)} kg:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('📌 APRE-3: ${rm3.toStringAsFixed(1)} kg (92%)'),
          Text('📌 APRE-6: ${rm6.toStringAsFixed(1)} kg (83%)'),
          Text('📌 APRE-10: ${rm10.toStringAsFixed(1)} kg (75%)'),
          SizedBox(height: 8),
          Text(
            '✅ Confidence: LOW (dati manuali)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _saveManualEntry() {
    final oneRM = double.parse(_oneRmController.text);
    
    // Update exercise con manual 1RM
    final updated = widget.exercise.copyWith(
      useAPRE: true,
      apreBaseWeight: oneRM * 0.83,  // Per Protocol 6
      calculated1RM: oneRM,
      calculated3RM: oneRM * 0.92,
      calculated6RM: oneRM * 0.83,
      calculated10RM: oneRM * 0.75,
      calculationMetadata: 'Manual input (LOW confidence) - update dopo primi workout',
    );
    
    // Save
    widget.onSaved();
    Navigator.pop(context);
  }
}
```

---

### ❓ #4: "Perché usa top 10 set invece di tutti?"

#### Situazione attuale

```dart
// Line in APREAutoRegulationService:
final topSets = historicalSets.take(10).toList();
// WHY 10? Non è documentato!
```

#### PROBLEMI identificati

1. **❌ Numero magico hardcoded**
   ```
   const int TOP_SETS_FOR_1RM_CALCULATION = 10;  // ← Non esiste!
   
   Arbitrario? Scientifico? Provato?
   Non sappiamo!
   ```

2. **❌ Non configurabile**
   ```
   User potrebbe volere:
   - Top 5 (più recente)
   - Top 20 (più dati)
   - Tutti gli ultimi 30 giorni
   
   Attualmente: Locked to 10
   ```

3. **❌ Trade-off non documentato**
   ```
   Pro Top 10:
   - Calcolo più veloce
   - Recency bias (più recenti che vecchi)
   - Non sovrappesare outlier
   
   Contro:
   - Perde informazione da più di 10 set
   - User non sceglie
   - Non adattabile a esercizio
   ```

#### 🎯 PROPOSTA DI MIGLIORAMENTO #4

```dart
// APREAutoRegulationService.calculateAPREWeights() CONFIGURABILE

/// Configurazione per calcolo 1RM
class OneRMCalculationConfig {
  /// Massimo numero di set da considerare (null = tutti)
  final int? maxSetsToUse;
  
  /// Filtra solo ultimi N giorni (null = tutti)
  final int? daysRecent;
  
  /// Metodo di selezione
  final SelectionMethod method;
  
  /// Come calcolare media
  final AveragingMethod averaging;
  
  OneRMCalculationConfig({
    this.maxSetsToUse = 10,  // Default scientifico
    this.daysRecent,
    this.method = SelectionMethod.topByWeight,
    this.averaging = AveragingMethod.robustMedian,
  });
  
  /// Presets comuni
  static final scientificDefault = OneRMCalculationConfig(
    maxSetsToUse: 10,
    method: SelectionMethod.topByWeight,
    averaging: AveragingMethod.robustMedian,
  );
  
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

enum SelectionMethod {
  topByWeight,            // Top 10 per peso assoluto
  topByEstimated1RM,      // Top 10 per 1RM stimato
  topByConsistency,       // Set con meno variabilità
  topByRecency,           // Set più recenti
  all,                    // Tutti (se > threshold)
}

enum AveragingMethod {
  mean,                   // Media semplice
  robustMedian,           // Mediana (remove outliers) ← Default
  weightedRecency,        // Media pesata (più recenti = peso più alto)
}

// Uso migliorato:
static Map<String, dynamic> calculateAPREWeights({
  required List<dynamic> historicalSets,
  required int protocol,
  bool useMetricSystem = true,
  OneRMCalculationConfig? config,  // ← NEW PARAMETER
}) {
  config ??= OneRMCalculationConfig.scientificDefault;
  
  // STEP 1: Filter per recency se richiesto
  final filtered = config.daysRecent != null
    ? historicalSets
        .where((set) {
          final days = DateTime.now().difference(set.date as DateTime).inDays;
          return days <= config.daysRecent!;
        })
        .toList()
    : historicalSets;
  
  // STEP 2: Seleziona top N set
  final selected = _selectTopSets(
    filtered,
    config.maxSetsToUse ?? filtered.length,
    config.method,
  );
  
  // STEP 3: Calcola 1RM per ogni set
  final estimates = selected.map((set) {
    return OneRMCalculator.calculateBrzycki(
      weight: set.weight,
      reps: set.reps,
    );
  }).toList();
  
  // STEP 4: Calcola media con metodo specificato
  final calculated1RM = _averageEstimates(
    estimates,
    config.averaging,
  );
  
  // STEP 5: Documenta le scelte fatte
  return {
    'calculated1RM': calculated1RM,
    // ...
    'dataPoints': selected.length,
    'selectionMethod': config.method.name,
    'averagingMethod': config.averaging.name,
    'metadata': 'Based on ${selected.length} sets using ${config.method.name} '
        '(${config.averaging.name}), Confidence: ${confidence.name}',
  };
}

static List<dynamic> _selectTopSets(
  List<dynamic> sets,
  int maxSets,
  SelectionMethod method,
) {
  switch (method) {
    case SelectionMethod.topByWeight:
      return sets
        .sorted((a, b) => b.weight.compareTo(a.weight))
        .take(maxSets)
        .toList();
      
    case SelectionMethod.topByEstimated1RM:
      return sets
        .sorted((a, b) {
          final est1rmA = OneRMCalculator.calculateBrzycki(
            weight: a.weight,
            reps: a.reps,
          );
          final est1rmB = OneRMCalculator.calculateBrzycki(
            weight: b.weight,
            reps: b.reps,
          );
          return est1rmB.compareTo(est1rmA);
        })
        .take(maxSets)
        .toList();
      
    case SelectionMethod.topByRecency:
      return sets
        .sorted((a, b) => b.date.compareTo(a.date))
        .take(maxSets)
        .toList();
      
    case SelectionMethod.all:
      return sets;
      
    default:
      return sets.take(maxSets).toList();
  }
}
```

#### 🎨 MIGLIORAMENTO UI (Settings avanzate)

```dart
// workout_customization_modal_advanced.dart

Widget _buildAPREAdvancedSettings() {
  return ExpansionTile(
    title: Text('APRE - Impostazioni Avanzate'),
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preset selector
            Text('Configurazione calcolo 1RM:'),
            SizedBox(height: 8),
            
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'default',
                  label: Text('Scientifico'),
                  tooltip: 'Top 10 set (default)',
                ),
                ButtonSegment(
                  value: 'conservative',
                  label: Text('Conservativo'),
                  tooltip: 'Top 5 set ultimi 30 giorni',
                ),
                ButtonSegment(
                  value: 'aggressive',
                  label: Text('Aggressivo'),
                  tooltip: 'Top 20 set ultimi 60 giorni',
                ),
                ButtonSegment(
                  value: 'custom',
                  label: Text('Personalizza'),
                  tooltip: 'Impostazioni manuali',
                ),
              ],
              selected: {_oneRMConfigPreset},
              onSelectionChanged: (selection) {
                setState(() => _oneRMConfigPreset = selection.first);
                if (selection.first == 'custom') {
                  _showCustomConfigDialog();
                }
              },
            ),
            
            SizedBox(height: 16),
            
            // Info sul preset corrente
            _buildPresetInfo(),
            
            SizedBox(height: 16),
            
            // Pulsante ricacolo forzato
            FilledButton.icon(
              onPressed: _forceRecalculateAll1RMs,
              icon: Icon(Icons.refresh),
              label: Text('🔄 Ricacola Tutti i 1RM'),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildPresetInfo() {
  final info = {
    'default': 'Top 10 set per peso → Confidenza ALTA',
    'conservative': 'Top 5 set ultimi 30gg → Confidenza MEDIA',
    'aggressive': 'Top 20 set ultimi 60gg → Più dati',
    'custom': 'Impostazioni personali',
  };
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      info[_oneRMConfigPreset] ?? '',
      style: TextStyle(fontSize: 12),
    ),
  );
}
```

---

## 🛠️ CHECKLIST IMPLEMENTAZIONE

### Fase 1: Core (T1)
- [ ] Aggiungere enum `CalculationConfidence`
- [ ] Aggiungere costante `USED_1RM_FORMULA`
- [ ] Implementare `_calculateDataAge()`
- [ ] Implementare `_robustAverage()`
- [ ] Aggiungere metodo `changeProtocol()` con validazione

### Fase 2: UI (T2)
- [ ] Migliorare `AutoAdjustmentModal` con metadata
- [ ] Aggiungere tooltip Confidence
- [ ] Aggiungere preview protocol
- [ ] Aggiungere dialog warning protocol change
- [ ] Creare `AutoAdjustmentModalNoHistory`

### Fase 3: Configurabilità (T3)
- [ ] Aggiungere `OneRMCalculationConfig`
- [ ] Implementare `SelectionMethod` enum
- [ ] Implementare `_selectTopSets()`
- [ ] Aggiungere UI per presets

### Fase 4: Testing (T4)
- [ ] Test scenario: no history
- [ ] Test scenario: protocol change mid-workout
- [ ] Test scenario: different selection methods
- [ ] Test data age calculation

---

## 📊 SUMMARY: PROBLEMA vs SOLUZIONE

| Problema | Attuale | Proposto |
|----------|---------|----------|
| 🔴 Formula 1RM ambigua | Non documentato | Costante `USED_1RM_FORMULA` |
| 🔴 Confidence vago | Magic string | Enum + criteria specifici |
| 🔴 No history crash | Probabile crash | Modal dedicato con input manuale |
| 🔴 Protocol change silenzioso | Silent | Warning + blocco mid-workout |
| 🔴 Top 10 hardcoded | Magic number | `OneRMCalculationConfig` |
| 🔴 Dati stali non visibili | Hidden | Data age indicator + banner |
| 🔴 User confusion | Bassa UX | Clear labels + tooltips + preview |

---

## 🚀 NEXT STEPS

1. **Priorità**: Implementare Fase 1 & 2 (core + UI visibile)
2. **Timeline**: T1 (2-3h), T2 (4-5h), T3 (3-4h), T4 (2h)
3. **Testing**: Focalizzarsi su edge cases (no history, protocol change)
4. **Documentation**: Aggiornare user-facing docs con spiegazioni

---

**Document Status**: ✅ Completato  
**Last Update**: 2025-11-06  
**Author**: System Analysis
