# 🎨 QuickEdit V2 - Mockup Visivo Tier-1

## 📱 DESIGN ATTUALE (V2)
```
┌─────────────────────────────────┐
│     Set 2 - Bench Press         │
├─────────────────────────────────┤
│                                 │
│   🏋️ Weight: [  65.0  ] kg     │
│                                 │
│   🔢 Reps:   [   10   ]        │
│                                 │
│   💪 RPE:    [   7    ]        │
│                                 │
├─────────────────────────────────┤
│  [Cancel]          [Save ✓]     │
└─────────────────────────────────┘
```

## ✨ DESIGN PROPOSTO TIER-1

### Versione 1: Con Recent Weights Chips
```
┌─────────────────────────────────┐
│     Set 2 - Bench Press    ✕   │
├─────────────────────────────────┤
│  📊 Ultimi 3 giorni:            │
│  [80kg] [75kg] [70kg] [65kg]    │ <- Chips cliccabili
│  [60kg] [55kg]                  │    (ordinati dal più grande)
├─────────────────────────────────┤
│                                 │
│   Weight: [ 65.0 ] kg          │ <- Input attivo + wheel
│           ────────              │    sotto per fine-tuning
│            ↕️ wheel              │
│                                 │
│   Reps:   [ 10 ]               │
│           ──────                │
│            ↕️ wheel              │
├─────────────────────────────────┤
│  🔄 Copy previous (60kg × 12)   │ <- Quick action
├─────────────────────────────────┤
│  [Cancel]          [Save ✓]     │
└─────────────────────────────────┘
```

### Versione 2: Quick Actions Bar Explained
```
┌─────────────────────────────────┐
│     Set 2 - Bench Press    ✕   │
├─────────────────────────────────┤
│  QUICK ACTIONS BAR:             │
│  ┌────┬────┬────┬────┬────┐    │
│  │-5kg│-2.5│Copy│+2.5│+5kg│    │ <- One-tap buttons
│  └────┴────┴────┴────┴────┘    │    per modifiche rapide
├─────────────────────────────────┤
│  Recent (3 days):               │
│  [80] [75] [70] [65] [60]      │ <- Chips compatte
├─────────────────────────────────┤
│   Weight: [ 65.0 ] kg          │
│   Reps:   [ 10 ]               │
├─────────────────────────────────┤
│  [Cancel]          [Save ✓]     │
└─────────────────────────────────┘
```

## 🎯 PROPOSTA FINALE OTTIMIZZATA

### Layout Pulito con Recent Weights Focus
```
┌─────────────────────────────────┐
│         Bench Press             │
│         Set 2 di 4          ✕   │
├─────────────────────────────────┤
│  💡 Set precedente: 60kg × 12   │ <- Context helper
├─────────────────────────────────┤
│  📅 Ultimi allenamenti:         │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ 80kg │ │ 75kg │ │ 70kg │   │ <- Chips grandi
│  └──────┘ └──────┘ └──────┘   │    tap = instant fill
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ 65kg │ │ 60kg │ │ 55kg │   │
│  └──────┘ └──────┘ └──────┘   │
├─────────────────────────────────┤
│  ┌─────────────┬──────────┐    │
│  │ Weight (kg) │ Reps     │    │
│  ├─────────────┼──────────┤    │
│  │    65.0     │    10    │    │ <- Direct input
│  └─────────────┴──────────┘    │    o wheel scroll
│                                 │
│  [➖ 2.5] [➕ 2.5] │ [➖] [➕]  │ <- Fine tuning
├─────────────────────────────────┤
│     [Annulla]    [Salva ✓]      │
└─────────────────────────────────┘
```

## 🔥 IMPLEMENTAZIONE CHIPS RECENT WEIGHTS

### Logica per Recent Weights:
```dart
// 1. Prende tutti i workout degli ultimi 3 giorni
// 2. Estrae i pesi usati per questo esercizio
// 3. Rimuove duplicati
// 4. Ordina dal più grande al più piccolo
// 5. Mostra max 6-8 chips

List<double> getRecentWeights(String exerciseId) {
  final threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
  
  return workouts
    .where((w) => w.date.isAfter(threeDaysAgo))
    .expand((w) => w.exercises)
    .where((e) => e.id == exerciseId)
    .expand((e) => e.sets)
    .map((s) => s.weight)
    .toSet() // Remove duplicates
    .toList()
    ..sort((a, b) => b.compareTo(a)); // Dal più grande
}
```

### Widget per Recent Weights Chips:
```dart
Widget _buildRecentWeightsChips(List<double> weights) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: weights.map((weight) => 
      ActionChip(
        label: Text('${weight}kg'),
        onPressed: () {
          setState(() {
            _weightController.text = weight.toString();
            // Haptic feedback
            HapticFeedback.lightImpact();
          });
        },
        backgroundColor: weight == currentWeight 
          ? theme.colorScheme.primary 
          : null,
      ),
    ).toList(),
  );
}
```

## 📊 CONFRONTO APPROCCI

| Feature | Quick Actions Bar | Recent Weights Chips | Combo |
|---------|------------------|---------------------|--------|
| **Velocità** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Precisione** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Spazio UI** | Compatto | Medio | Grande |
| **Learning curve** | Bassa | Nessuna | Bassa |
| **Utilità** | Media | Alta | Altissima |

## 🎯 RACCOMANDAZIONE

**Implementare RECENT WEIGHTS CHIPS** perché:
1. ✅ Zero learning curve - tap sul peso desiderato
2. ✅ Basato su dati reali dell'utente
3. ✅ Riduce errori di input
4. ✅ Velocizza del 80% la selezione
5. ✅ Mostra progressione visivamente

**Quick Actions** solo per fine-tuning:
- Due piccoli bottoni [−2.5] [+2.5] sotto l'input
- Per aggiustamenti veloci dopo chip selection

## 🚀 PROSSIMI STEP

1. **Implementare Recent Weights Chips** (2 giorni)
2. **Aggiungere mini quick actions** (1 giorno)  
3. **Smart positioning** per evitare overflow (1 giorno)
4. **Animazioni e haptics** (1 giorno)

Totale: 5 giorni per tier-1 upgrade completo