# 🏋️ Sistema Libbre (lbs) - Design e Implementazione

## 📊 Conversione e Matematica

### Fattore di Conversione
```
1 kg = 2.20462 lbs
1 lb = 0.453592 kg
```

### Equivalenze degli Scatti
Con il sistema attuale di **0.25 kg** per scatto:
```
0.25 kg = 0.551156 lbs ≈ 0.5 lbs
```

**Raccomandazione**: Per le libbre, usare scatti di **0.5 lbs** (equivalente a ~0.227 kg).

---

## ⚙️ Implementazione Tecnica

### Incrementi Picker (0.5 lbs)

```dart
// Per kg (attuale)
childCount: 801,  // 0 - 200 kg in 0.25 kg increments
final weight = index / 4.0;  // index / 4.0 = 0.25 kg per scatto

// Per lbs (proposto)
childCount: 881,  // 0 - 440 lbs in 0.5 lbs increments (equivalente a 200 kg)
final weight = index / 2.0;  // index / 2.0 = 0.5 lbs per scatto
```

**Range Equivalente**:
- **Kg**: 0 - 200 kg (scatti di 0.25 kg = 801 elementi)
- **Lbs**: 0 - 440 lbs (scatti di 0.5 lbs = 881 elementi)

---

## 🚀 Pulsanti Quick Jump per Libbre

### Sistema Dinamico Proposto

#### **Peso = 0 lbs**
```
[+5] [+10] [+25] [+50]
```

#### **Peso > 0 e ≤ 25 lbs**
```
[-5] [+10] [+25] [+50]
```

#### **Peso > 25 e ≤ 50 lbs**
```
[-10] [+10] [+25] [+50]
```

#### **Peso > 50 lbs**
```
[-25] [-10] [+10] [+25]
```

### Logica Implementativa

```dart
List<int> getQuickJumpsLbs(double weight) {
  if (weight == 0) {
    return [5, 10, 25, 50];
  } else if (weight <= 25) {
    return [-5, 10, 25, 50];
  } else if (weight <= 50) {
    return [-10, 10, 25, 50];
  } else {
    return [-25, -10, 10, 25];
  }
}
```

### Comparazione kg vs lbs

| Scenario | Kg Quick Jumps | Lbs Quick Jumps | Note |
|----------|----------------|-----------------|------|
| Da zero | +10, +20, +50, +100 | +5, +10, +25, +50 | ~2.2x fattore |
| Warmup (0-10kg / 0-25lbs) | -10, +20, +50, +100 | -5, +10, +25, +50 | Simmetrico |
| Mid-range (10-20kg / 25-50lbs) | -10, +20, +50, +100 | -10, +10, +25, +50 | Più granulare |
| Heavy (>20kg / >50lbs) | -20, -10, +10, +20 | -25, -10, +10, +25 | Proporzionato |

---

## 🎯 UX Scenarios con Libbre

### **Scenario 1: Warmup Rapido**
Utente vuole passare da 0 a 90 lbs (~40 kg):
1. Tap **+50** → 50 lbs (1 tap)
2. Tap **+25** → 75 lbs (1 tap)
3. Tap **+10** → 85 lbs (1 tap)
4. Scroll +5 lbs → 90 lbs

**Totale**: 3 tap + 1 scroll ⚡

### **Scenario 2: Microloading**
Utente vuole passare da 180 lbs a 185 lbs:
1. Tap **+10** → 190 lbs
2. Tap **-10** → 180 lbs
3. Scroll +5 lbs → 185 lbs

**O meglio**: Scroll diretto di 10 scatti (5 lbs in scatti di 0.5)

### **Scenario 3: Drop Set**
Utente vuole ridurre da 225 lbs a 180 lbs:
1. Tap **-25** → 200 lbs (1 tap)
2. Tap **-25** → 175 lbs (1 tap)
3. Scroll +5 lbs → 180 lbs

**Totale**: 2 tap + 1 scroll ⚡

---

## 💻 Modifiche al Codice Necessarie

### 1. **Aggiungere Enum per Unità di Misura**

```dart
enum WeightUnit {
  kg,
  lbs,
}
```

### 2. **Provider per Impostazioni Utente**

```dart
final weightUnitProvider = StateProvider<WeightUnit>((ref) => WeightUnit.kg);
```

### 3. **Modificare `_showWeightPicker()`**

```dart
void _showWeightPicker(BuildContext context, int roundIndex, String exerciseId, double currentWeight) {
  final theme = Theme.of(context);
  final weightUnit = ref.read(weightUnitProvider); // ✅ Leggi preferenza utente

  // ✅ Calcola valori in base all'unità
  final int childCount = weightUnit == WeightUnit.kg ? 801 : 881;
  final double divisor = weightUnit == WeightUnit.kg ? 4.0 : 2.0;
  final double maxWeight = weightUnit == WeightUnit.kg ? 200.0 : 440.0;
  final String unit = weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  double selectedWeight = currentWeight;
  final controller = FixedExtentScrollController(
    initialItem: (currentWeight * (weightUnit == WeightUnit.kg ? 4 : 2)).toInt(),
  );

  // ✅ Quick jumps dinamici in base all'unità
  List<int> getQuickJumps(double weight) {
    if (weightUnit == WeightUnit.kg) {
      // Logica attuale per kg
      if (weight == 0) return [10, 20, 50, 100];
      else if (weight <= 10) return [-10, 20, 50, 100];
      else if (weight <= 20) return [-10, 20, 50, 100];
      else return [-20, -10, 10, 20];
    } else {
      // Logica per lbs
      if (weight == 0) return [5, 10, 25, 50];
      else if (weight <= 25) return [-5, 10, 25, 50];
      else if (weight <= 50) return [-10, 10, 25, 50];
      else return [-25, -10, 10, 25];
    }
  }

  showModalBottomSheet(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Container(
        height: 380,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ... handle bar ...

            // ✅ Title con unità dinamica
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.weight,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${selectedWeight.toStringAsFixed(2)} $unit', // ✅ Unità dinamica
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            // ... quick jump buttons con getQuickJumps() ...

            // ✅ Picker con divisor dinamico
            Expanded(
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: childCount, // ✅ Dinamico: 801 (kg) o 881 (lbs)
                  builder: (context, index) {
                    final weight = index / divisor; // ✅ Dinamico: /4.0 (kg) o /2.0 (lbs)
                    final isSelected = (weight - selectedWeight).abs() < 0.05;

                    String displayText;
                    if (weight == 0) {
                      displayText = '0';
                    } else if (weight % 1 == 0) {
                      displayText = weight.toInt().toString();
                    } else {
                      displayText = weight.toStringAsFixed(weightUnit == WeightUnit.kg ? 2 : 1);
                      // ✅ Kg: 2 decimali (27.75), Lbs: 1 decimale (180.5)
                    }

                    return Center(
                      child: Text(
                        displayText,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
                onSelectedItemChanged: (index) {
                  setModalState(() => selectedWeight = index / divisor);
                  HapticFeedback.selectionClick();
                },
              ),
            ),

            // ... confirm button ...
          ],
        ),
      ),
    ),
  );
}
```

---

## 🔄 Conversione Automatica tra Unità

### Opzione 1: Memorizzare Sempre in Kg
```dart
// Quando l'utente seleziona in lbs
final weightInKg = selectedWeightLbs * 0.453592;
_updateExerciseWeight(roundIndex, exerciseId, weightInKg);

// Quando l'utente visualizza in lbs
final displayWeightLbs = storedWeightKg * 2.20462;
```

### Opzione 2: Memorizzare con Unità
```dart
class ExerciseWeight {
  final double value;
  final WeightUnit unit;

  double get inKg => unit == WeightUnit.kg ? value : value * 0.453592;
  double get inLbs => unit == WeightUnit.lbs ? value : value * 2.20462;
}
```

---

## 🌍 Localizzazione

### Preferenze Default per Paese

```dart
WeightUnit getDefaultWeightUnit(Locale locale) {
  // USA, UK, Myanmar usano lbs
  if (locale.countryCode == 'US' ||
      locale.countryCode == 'GB' ||
      locale.countryCode == 'MM') {
    return WeightUnit.lbs;
  }
  // Resto del mondo usa kg
  return WeightUnit.kg;
}
```

### Traduzioni ARB

```json
// assets/i18n/app_en.arb
{
  "weightUnit": "Weight Unit",
  "kilograms": "Kilograms (kg)",
  "pounds": "Pounds (lbs)",
  "@weightUnit": {
    "description": "Setting for weight unit preference"
  }
}

// assets/i18n/app_it.arb
{
  "weightUnit": "Unità di Peso",
  "kilograms": "Chilogrammi (kg)",
  "pounds": "Libbre (lbs)"
}
```

---

## 🎨 UI/UX Considerations

### 1. **Schermata Impostazioni**
Aggiungere toggle per selezionare unità:
```
⚙️ Impostazioni
  └─ Unità di Peso
     ○ Chilogrammi (kg)
     ● Libbre (lbs)
```

### 2. **Indicatore Visuale**
Mostrare sempre l'unità attiva nel picker:
```
┌──────────────────────┐
│  Peso     180.5 lbs  │ ← Unità sempre visibile
│  [-25] [-10] [+10] [+25]
│         180.5        │
└──────────────────────┘
```

### 3. **Conversione Opzionale**
Mostrare conversione in tempo reale (opzionale):
```
┌──────────────────────┐
│  Peso     180.5 lbs  │
│         (~81.8 kg)   │ ← Conversione opzionale
└──────────────────────┘
```

---

## 📊 Tabella Comparativa Completa

| Feature | Kg System (Attuale) | Lbs System (Proposto) |
|---------|---------------------|----------------------|
| **Incremento** | 0.25 kg | 0.5 lbs |
| **Range** | 0 - 200 kg | 0 - 440 lbs |
| **Elementi Picker** | 801 | 881 |
| **Decimali Display** | 2 (27.75) | 1 (180.5) |
| **Quick Jumps @0** | +10, +20, +50, +100 | +5, +10, +25, +50 |
| **Quick Jumps Medio** | -10, +20, +50, +100 | -10, +10, +25, +50 |
| **Quick Jumps Heavy** | -20, -10, +10, +20 | -25, -10, +10, +25 |
| **Precisione** | ±0.25 kg | ±0.5 lbs (~±0.23 kg) |

---

## ✅ Checklist Implementazione

- [ ] Aggiungere `WeightUnit` enum
- [ ] Creare `weightUnitProvider` in Riverpod
- [ ] Modificare `_showWeightPicker()` per supportare entrambe le unità
- [ ] Aggiungere logica `getQuickJumps()` per lbs
- [ ] Implementare conversione automatica kg ↔ lbs
- [ ] Aggiungere impostazione UI per scegliere unità
- [ ] Tradurre stringhe in ARB (EN/IT)
- [ ] Testare con entrambe le unità
- [ ] Aggiornare documentazione utente

---

## 🎯 Raccomandazioni Finali

### **Approccio Consigliato**:
1. **Memorizzare sempre in kg** nel database (standard internazionale)
2. **Convertire in lbs** solo per display/input quando richiesto
3. **Precisione**:
   - Kg: 0.25 kg (2 decimali)
   - Lbs: 0.5 lbs (1 decimale)
4. **Default**: Basato su locale dell'utente
5. **Quick Jumps**: Scalati proporzionalmente (×2.2 circa)

### **Vantaggi**:
- ✅ Supporto completo per utenti USA/UK
- ✅ Precisione equivalente tra sistemi
- ✅ Conversione trasparente
- ✅ UX familiare per entrambi i mercati

### **Complessità**:
- ⚠️ Richiede modifica di tutti i picker peso
- ⚠️ Necessita testing su entrambi i sistemi
- ⚠️ Potenziali problemi di arrotondamento nella conversione

---

## 🔮 Future Enhancement

### Possibile Feature: **Dual Display**
Mostrare entrambe le unità contemporaneamente:
```
┌──────────────────────┐
│  180.5 lbs           │
│  (81.8 kg)           │ ← Unità secondaria
└──────────────────────┘
```

Permetterebbe agli utenti di:
- Vedere entrambe le unità senza cambiare impostazioni
- Imparare l'equivalenza tra kg e lbs
- Utile per esercizi con bilancieri standard (20 kg = 45 lbs)
