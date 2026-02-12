# Redesign UX - Creazione Superset / DropSet / RestPause

**Data**: 2026-02-11
**Status**: Da implementare
**Complessita stimata**: Media-Alta (11 step)
**File principali**: `add_exercise_modal.dart`, `superset_builder_widget.dart`

---

## Problema

La creazione di esercizi avanzati (Superset, DropSet, RestPause) e percepita come "difficile e senza senso". Analisi dettagliata dei problemi:

### Problemi UX identificati

| # | Problema | Gravita | Dove |
|---|---------|---------|------|
| 1 | **RestPause info card ROSSA** (`errorContainer`) - sembra un errore | Alta | add_exercise_modal.dart:1083 |
| 2 | **Info card inconsistenti** tra i 3 tipi (gradient/flat/rosso) | Media | 3 file diversi |
| 3 | **Controller `_nameController` condiviso** tra DropSet e RestPause - bug cross-tab | Alta | add_exercise_modal.dart:86 |
| 4 | **DropSet peso via modal obbligatorio** - ogni stage richiede apertura picker | Media | add_exercise_modal.dart:1769-1795 |
| 5 | **RestPause 4 campi simultanei** senza preview di cosa verra creato | Media | add_exercise_modal.dart:1161-1219 |
| 6 | **Toggle auto-compaction** distraente (si restringe dopo 600ms) | Bassa | add_exercise_modal.dart:138-167 |
| 7 | **"Salva come Template"** troppo prominente (stessa visual weight del CTA) | Bassa | add_exercise_modal.dart:956-968 |
| 8 | **Troppo scroll** - spacing eccessivo, preview ridondanti | Media | add_exercise_modal.dart |
| 9 | **Nessun chip esercizi recenti** nei tab avanzati (solo nel tab Singolo) | Media | add_exercise_modal.dart:326-381 |

### Navigazione scelta

**Opzione C: Sub-toggle fisso** - Manteniamo la struttura a tab con `Singolo | Avanzati` e sub-tab `Superset | DropSet | RestPause`, migliorando il contenuto interno. Niente estrazione in sheet separati.

```
Modal → [Singolo | Avanzati] → [Superset | DropSet | RestPause] (toggle fisso, 1 tap per cambiare)
FAB long-press → apre direttamente il sub-tab giusto (invariato)
```

---

## Piano di implementazione

### Step 1: `AdvancedInfoCard` - Widget condiviso

**Nuovo file**: `lib/features/workout/presentation/widgets/advanced_info_card.dart`

Widget che sostituisce le 3 info card inconsistenti con un design uniforme.

**Design**:
- Sfondo: `accentColor.withValues(alpha: 0.08)`
- Bordo sinistro: 4px con `accentColor`
- Collassabile: auto-collapse dopo 3s, tap per toggle
- Collapsed: icon + titolo in una riga
- Expanded: icon + titolo + descrizione

**Props**:
```dart
class AdvancedInfoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  // auto-collapse dopo 3s, initiallyExpanded = true
}
```

**Stima**: ~80 righe

---

### Step 2: Separare controller per tab

**File**: `lib/features/workout/presentation/widgets/add_exercise_modal.dart`

**Problema**: `_nameController` (riga 86) e `_notesController` (riga 87) sono condivisi tra DropSet e RestPause. Switchare tab trascina lo stato dell'altro.

**Soluzione**: Controller dedicati per ogni tab:

```dart
// PRIMA
final _nameController = TextEditingController();
final _notesController = TextEditingController();

// DOPO
final _dropsetNameController = TextEditingController();
final _dropsetNotesController = TextEditingController();
final _restPauseNameController = TextEditingController();
final _restPauseNotesController = TextEditingController();
```

**Impatto**: Aggiornare tutti i riferimenti in `_buildDropSetTab()`, `_buildRestPauseTab()`, `_onDropSetExerciseSelected()`, `_onRestPauseExerciseSelected()`, `_createDropSetExercise()`, `_createRestPauseExercise()`, `_canCreateDropSet()`, `_canCreateRestPause()`, `dispose()`.

**Nota**: Il `_nameController` originale resta per il tab Singolo (`_buildExerciseSearchSection`). La `_searchController` (riga 88) e gia separata.

---

### Step 3: Fix RestPause info card (ROSSO → secondary)

**File**: `add_exercise_modal.dart`, righe 1082-1102

**Prima**:
```dart
Card(
  color: context.colors.errorContainer,  // ← ROSSO! Sembra un errore
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(AppIcons.info, color: context.colors.onErrorContainer),
        ...
```

**Dopo**:
```dart
AdvancedInfoCard(
  icon: AppIcons.pauseCircle,
  title: context.l10n.restPauseTraining,
  description: context.l10n.restPauseInfoCard,
  accentColor: context.colors.secondary,
),
```

---

### Step 4: Fix DropSet info card (uniformare)

**File**: `add_exercise_modal.dart`, righe 796-818

**Prima**:
```dart
Card(
  color: context.colors.tertiaryContainer,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(AppIcons.info, color: context.colors.onTertiaryContainer),
        ...
```

**Dopo**:
```dart
AdvancedInfoCard(
  icon: AppIcons.trendDown,
  title: context.l10n.dropSetTraining,
  description: context.l10n.dropSetInfoCard,
  accentColor: context.colors.tertiary,
),
```

---

### Step 5: Fix Superset info card (uniformare)

**File**: `superset_builder_widget.dart`, righe 98-192

**Prima**: 95 righe di widget complesso con gradient, `AnimatedContainer`, `AnimatedCrossFade`, `AnimatedRotation`, state `_isInfoCardExpanded`, `Future.delayed`.

**Dopo**:
```dart
AdvancedInfoCard(
  icon: AppIcons.link,
  title: l10n.supersetTraining,
  description: l10n.supersetDescription,
  accentColor: theme.colorScheme.primary,
),
```

Rimuovere: `_isInfoCardExpanded` state, il `Future.delayed` di 3s in `initState` (righe 49-53).

---

### Step 6: DropSet - Input peso inline

**File**: `add_exercise_modal.dart`, metodo `_buildDropSetStage()` (righe 1738-1829)

**Problema attuale**: Il campo peso e un `InkWell` wrappato in `InputDecorator` che apre `DropSetWeightPickerModal` ad ogni tap. L'utente DEVE aprire un modal per ogni stage.

**Soluzione**: `TextFormField` diretto con `keyboardType: numberWithOptions(decimal: true)`. Il `DropSetWeightPickerModal` resta accessibile tramite un piccolo `IconButton` calcolatrice nel `suffixIcon`.

**Prima** (righe 1769-1795):
```dart
Expanded(
  child: InkWell(
    onTap: () => _openWeightPicker(index),
    borderRadius: BorderRadius.circular(8),
    child: InputDecorator(
      decoration: InputDecoration(labelText: context.l10n.weightKgLabel, ...),
      child: Text(stageData.weightController.text.isEmpty ? '---' : '${stageData.weightController.text} kg'),
    ),
  ),
),
```

**Dopo**:
```dart
Expanded(
  child: TextFormField(
    controller: stageData.weightController,
    decoration: InputDecoration(
      labelText: context.l10n.weightKgLabel,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      suffixIcon: IconButton(
        icon: const Icon(AppIcons.calculate, size: 18),
        onPressed: () => _openWeightPicker(index),
        tooltip: context.l10n.smartWeightHelper,
      ),
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  ),
),
```

---

### Step 7: RestPause - Preview serie generate

**File**: `add_exercise_modal.dart`

Nuovo metodo `_buildRestPauseSetPreview()` da inserire dopo i 4 campi di configurazione (dopo riga ~1220) e prima del Notes field.

Mostra in tempo reale cosa verra generato:

```
┌─────────────────────────────────────────────┐
│ Serie generate:                             │
│ ① 6 reps → ⏸15s → ② 3 reps → ⏸15s → ③ 3 │
└─────────────────────────────────────────────┘
```

Si aggiorna automaticamente quando l'utente modifica target reps, pausa, o max serie. Usa un listener sui controller per rebuild.

**Implementazione**:
```dart
Widget _buildRestPauseSetPreview() {
  final targetReps = int.tryParse(_restPauseTargetRepsController.text);
  final restSeconds = int.tryParse(_restPauseRestSecondsController.text) ?? 15;
  final maxSets = int.tryParse(_restPauseMaxSetsController.text) ?? 3;
  if (targetReps == null || targetReps <= 0) return const SizedBox.shrink();

  final circleNumbers = ['\u2460', '\u2461', '\u2462', '\u2463', '\u2464']; // ①②③④⑤
  final buffer = StringBuffer();
  for (var i = 0; i < maxSets && i < 5; i++) {
    if (i > 0) buffer.write(' \u2192 \u23f8${restSeconds}s \u2192 ');
    final reps = i == 0 ? targetReps : (targetReps * 0.5).round().clamp(1, targetReps);
    buffer.write('${circleNumbers[i]} $reps reps');
  }

  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.generatedSets, style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        )),
        const SizedBox(height: 4),
        Text(buffer.toString(), style: context.textTheme.bodyMedium),
      ],
    ),
  );
}
```

**Nota**: Aggiungere listener ai controller in `initState` per rebuild automatico:
```dart
_restPauseTargetRepsController.addListener(_onRestPauseConfigChanged);
_restPauseRestSecondsController.addListener(_onRestPauseConfigChanged);
_restPauseMaxSetsController.addListener(_onRestPauseConfigChanged);
```

---

### Step 8: Compattare layout + demote "Save as Template"

**File**: `add_exercise_modal.dart`

**8a. Ridurre spacing**:
- Tutti i `SizedBox(height: 20)` tra sezioni → `SizedBox(height: 12)` (in `_buildDropSetTab` e `_buildRestPauseTab`)

**8b. Rimuovere preview ridondanti**:
- Rimuovere `_buildDropSetPreview()` (righe 478-576) - gli stage sono gia visibili inline
- Rimuovere `_buildRestPausePreview()` (righe 580-692) - sostituito dal set preview (Step 7)
- Rimuovere le chiamate a `_buildDropSetPreview()` (riga 938) e `_buildRestPausePreview()` (riga 1235)

**8c. Demote "Salva come Template"**:

DropSet (righe 954-968):
```dart
// PRIMA
const SizedBox(height: 12),
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: _showSaveDropsetTemplateDialog,
    icon: const Icon(AppIcons.template),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(context.l10n.saveAsTemplate),
    ),
  ),
),

// DOPO
const SizedBox(height: 8),
Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: _canCreateDropSet() ? _showSaveDropsetTemplateDialog : null,
    icon: const Icon(AppIcons.template, size: 16),
    label: Text(context.l10n.saveAsTemplate),
  ),
),
```

Stessa cosa per RestPause (righe 1252-1265).

---

### Step 9: Chip esercizi recenti nei tab avanzati

**File**: `add_exercise_modal.dart`

Nuovo metodo condiviso `_buildAdvancedRecentChips()` da inserire in cima a `_buildDropSetTab()` e `_buildRestPauseTab()`, DOPO l'info card e PRIMA del bottone "Cerca nel database".

Il metodo riusa `recentExercisesForModalProvider` (gia usato nel tab Singolo) e accetta un callback per la selezione.

**Inserimento in `_buildDropSetTab()` (dopo riga 819)**:
```dart
const SizedBox(height: 12),
_buildAdvancedRecentChips(onSelected: _onDropSetExerciseSelected),
const SizedBox(height: 12),
```

**Inserimento in `_buildRestPauseTab()` (dopo riga 1103)**:
```dart
const SizedBox(height: 12),
_buildAdvancedRecentChips(onSelected: _onRestPauseExerciseSelected),
const SizedBox(height: 12),
```

**Nota**: `_onDropSetExerciseSelected` e `_onRestPauseExerciseSelected` accettano `ExerciseDB.Exercise`. I chip dal provider contengono `exerciseName` (String). Serve un adapter che cerca l'esercizio nel DB per nome, oppure che crea un exercise placeholder da passare al callback.

---

### Step 10: Rimuovere auto-compaction toggle

**File**: `add_exercise_modal.dart`

**Rimuovere**:
- `_isMainToggleCompacted` state (riga 91)
- `_isAdvancedToggleCompacted` state (riga 92)
- `Future.delayed` auto-compact main (righe 138-142)
- `Future.delayed` auto-compact advanced (righe 161-167)

**Semplificare `_buildCompactableMainToggle()`** (righe 273-307):
```dart
Widget _buildMainToggle() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    height: 40,
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TabBar(
      controller: _tabController,
      indicator: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: context.colors.onPrimary,
      unselectedLabelColor: context.colors.onSurfaceVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(text: context.l10n.tabSingle),
        Tab(text: context.l10n.tabAdvanced),
      ],
    ),
  );
}
```

**Semplificare `_buildCompactableAdvancedToggle()`** (righe 715-753):
```dart
Widget _buildAdvancedToggle() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    height: 36,
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TabBar(
      controller: _advancedTabController,
      indicator: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: context.colors.onSecondary,
      unselectedLabelColor: context.colors.onSurfaceVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(text: context.l10n.tabSuperset),
        Tab(text: context.l10n.tabDropSet),
        Tab(text: context.l10n.tabRestPause),
      ],
    ),
  );
}
```

---

### Step 11: Localizzazione

**File**: `assets/i18n/app_en.arb` + `assets/i18n/app_it.arb`

Nuove chiavi:

| Key | EN | IT |
|-----|----|----|
| `restPauseTraining` | "Rest-Pause Training" | "Allenamento Rest-Pause" |
| `dropSetTraining` | "Drop Set Training" | "Allenamento Drop Set" |
| `smartWeightHelper` | "Smart weight calculator" | "Calcolatore peso smart" |
| `generatedSets` | "Generated sets" | "Serie generate" |

Dopo: `flutter gen-l10n`

---

## Ordine di implementazione

```
 1. Step 11  Localizzazione (chiavi servono subito)
 2. Step 1   AdvancedInfoCard widget
 3. Step 2   Separare controller (fix bug)
 4. Step 10  Rimuovere auto-compaction (semplifica i toggle prima di altre modifiche)
 5. Step 3   Fix RestPause info card
 6. Step 4   Fix DropSet info card
 7. Step 5   Fix Superset info card
 8. Step 6   DropSet input peso inline
 9. Step 7   RestPause preview serie
10. Step 8   Compattare layout + demote template
11. Step 9   Chip esercizi recenti nei tab avanzati
12. flutter analyze + flutter gen-l10n + performance check
```

---

## File coinvolti

| File | Tipo | Complessita |
|------|------|-------------|
| `lib/features/workout/presentation/widgets/advanced_info_card.dart` | NUOVO | Bassa |
| `lib/features/workout/presentation/widgets/add_exercise_modal.dart` | MODIFICA PESANTE | Alta |
| `lib/features/workout/presentation/widgets/superset_builder_widget.dart` | MODIFICA LEGGERA | Bassa |
| `assets/i18n/app_en.arb` | AGGIUNTA chiavi | Bassa |
| `assets/i18n/app_it.arb` | AGGIUNTA chiavi | Bassa |

---

## Verifica post-implementazione

- [ ] `flutter analyze` → 0 errori
- [ ] `flutter gen-l10n` → traduzioni rigenerate
- [ ] Tab Singolo: funzionamento invariato
- [ ] Sub-toggle avanzato: dimensione fissa, no auto-compaction
- [ ] Info card: uniformi per tutti e 3 i tipi, colori coerenti
- [ ] RestPause: info card NON rossa (secondary color)
- [ ] DropSet: peso editabile direttamente tramite keyboard
- [ ] DropSet: calcolatrice peso accessibile da icon button
- [ ] RestPause: preview serie generate in tempo reale
- [ ] Controller separati: switch tra DropSet e RestPause non trascina stato
- [ ] "Salva come Template": compatto (TextButton), non prominente
- [ ] FAB long-press: deep-link ai sub-tab funziona correttamente
- [ ] Chip recenti: visibili nei tab DropSet e RestPause
- [ ] Scroll ridotto: meno spacing, preview ridondanti rimosse
