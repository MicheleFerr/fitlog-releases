# Onboarding Edge Cases Analysis

> **Scopo**: Documentare tutti gli edge case da gestire nei tutorial/tour dell'app.

---

## Edge Cases Identificati

### 1. Widget Non Renderizzato

**Scenario**: Il widget target non esiste nel tree perché:
- È condizionale (mostra solo se premium)
- È basato su dati (mostra solo se ci sono workout)
- È nascosto in un altro stato (collapsed, different tab)

**Gestione Attuale**:
```dart
if (key == null || key.currentContext == null) {
  debugPrint('⚠️ Skipping step $step - no valid key');
  continue;
}
```

**Miglioramenti Suggeriti**:
- [ ] Pre-verificare che tutti i target esistano prima di iniziare
- [ ] Mostrare messaggio "Questa funzione non è disponibile" per step premium
- [ ] Forzare rendering temporaneo dei widget necessari

---

### 2. Scroll Position

**Scenario**: Il widget target è fuori viewport (scroll necessario).

**Gestione Attuale**:
```dart
await Scrollable.ensureVisible(
  targetContext,
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  alignment: 0.5, // Center vertically
);
```

**Edge Cases Specifici**:
- Widget in nested ScrollView
- Widget in PageView/TabBarView
- Widget in sliver list con lazy loading
- Widget in ExpansionTile (collapsed)

**Miglioramenti Suggeriti**:
- [ ] Gestire nested scrollable widgets
- [ ] Espandere automaticamente ExpansionTile se necessario
- [ ] Switchare tab se widget è in altra tab

---

### 3. Context Invalidation

**Scenario**: Il context diventa invalido durante operazioni async.

**Gestione Attuale**:
```dart
if (!context.mounted) {
  debugPrint('⚠️ Context no longer mounted, aborting');
  return;
}
```

**Quando Succede**:
- Navigazione durante tutorial
- App va in background
- Rotazione schermo su alcuni device
- Hot reload durante sviluppo

**Miglioramenti Suggeriti**:
- [ ] Salvare stato corrente per riprendere
- [ ] Mostrare "Tutorial interrotto" al rientro
- [ ] Offrire opzione "Riprendi tutorial"

---

### 4. SharedPreferences Failure

**Scenario**: Il salvataggio dello stato di completamento fallisce.

**Gestione Attuale**:
```dart
try {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_completedKey, true);
} catch (e) {
  // Still update local state
  debugPrint('⚠️ Failed to save completion: $e');
}
```

**Quando Succede**:
- Storage pieno
- Permessi negati (raro)
- Crash durante write

**Miglioramenti Suggeriti**:
- [ ] Retry con backoff
- [ ] Fallback a memoria (session-based)
- [ ] Sync con cloud per persistenza cross-device

---

### 5. Interruzioni di Sistema

**Scenario**: Tutorial interrotto da eventi esterni.

**Eventi Possibili**:
- Chiamata in arrivo
- Notifica importante
- Low battery alert
- Permission dialog
- App goes to background

**Gestione Attuale**: Nessuna (tutorial viene perso).

**Miglioramenti Suggeriti**:
- [ ] Listener per `WidgetsBindingObserver.didChangeAppLifecycleState`
- [ ] Salvare step corrente in SharedPreferences
- [ ] Riprendere da ultimo step al rientro

---

### 6. Orientamento Schermo

**Scenario**: Utente ruota il device durante tutorial.

**Problemi**:
- GlobalKey punta a widget distrutto
- Posizioni cambiano
- Layout completamente diverso

**Gestione Attuale**: Nessuna (crash potenziale).

**Miglioramenti Suggeriti**:
- [ ] Bloccare orientamento durante tutorial (UX controversa)
- [ ] Ricostruire targets dopo rotation
- [ ] Usare `OrientationBuilder` per adattare content align

---

### 7. Dark/Light Mode Switch

**Scenario**: Utente cambia tema durante tutorial.

**Problemi**:
- Colori overlay potrebbero non adattarsi
- Contrasto insufficiente
- Widget rebuilds

**Gestione Attuale**: Tema è letto all'inizio e usato per tutto il tour.

**Miglioramenti Suggeriti**:
- [ ] Listener per theme changes
- [ ] Rebuild overlay con nuovi colori
- [ ] Testare entrambi i temi in QA

---

### 8. Accessibilità

**Scenario**: Utente usa VoiceOver/TalkBack o altre assistive technologies.

**Problemi**:
- Spotlight visivo non accessibile
- Focus order interrotto
- Screen reader non legge contenuto tooltip

**Miglioramenti Suggeriti**:
- [ ] Aggiungere `Semantics` ai contenuti tooltip
- [ ] Gestire focus per screen reader
- [ ] Testare con VoiceOver e TalkBack
- [ ] Offrire versione "text-only" del tutorial

---

### 9. Animazioni e Timing

**Scenario**: Widget target sta animando o è in transizione.

**Problemi**:
- `currentContext` valido ma widget sta muovendosi
- Spotlight appare nel posto sbagliato
- Flash/glitch visivo

**Quando Succede**:
- Durante animazioni di entrata
- Hero animations
- Implicit animations

**Miglioramenti Suggeriti**:
- [ ] Attendere fine animazioni prima di mostrare spotlight
- [ ] Usare `TickerProviderStateMixin` per sincronizzazione
- [ ] Aggiungere delay configurabile

---

### 10. Multi-Tutorial Conflict

**Scenario**: Due tutorial cercano di partire contemporaneamente.

**Esempio**:
- Home Tour non completato
- Utente naviga ad Analytics
- Analytics Tour tenta di partire

**Gestione Attuale**: Nessuna (entrambi potrebbero partire).

**Miglioramenti Suggeriti**:
- [ ] Singleton/mutex per tutorial attivo
- [ ] Queue per tutorial pendenti
- [ ] Priority system (core tutorials first)

---

### 11. Stato Dati Inconsistente

**Scenario**: Tutorial assume presenza di dati che non esistono.

**Esempi**:
- Analytics tour senza workout
- Exercise card tutorial senza esercizi caricati
- PR tracking senza PR registrati

**Gestione Attuale**: Widget non renderizzati vengono skippati.

**Miglioramenti Suggeriti**:
- [ ] Pre-check dati necessari
- [ ] Mostrare empty state con spiegazione
- [ ] Creare dati demo temporanei per tutorial

---

### 12. Performance su Device Lenti

**Scenario**: Device vecchio/lento causa lag durante tutorial.

**Problemi**:
- Scroll animation stutters
- Spotlight appare prima che widget sia visibile
- Touch response lento

**Miglioramenti Suggeriti**:
- [ ] Ridurre/disabilitare animazioni su device lenti
- [ ] Aumentare delay tra step
- [ ] Ottimizzare overlay rendering

---

## Checklist Pre-Release

### Per Ogni Nuovo Tutorial

- [ ] Testato con tutti i target widgets presenti
- [ ] Testato con alcuni target mancanti
- [ ] Testato con scroll necessario
- [ ] Testato interrupt (background app)
- [ ] Testato rotation
- [ ] Testato dark mode
- [ ] Testato light mode
- [ ] Testato su device lento (simulato con throttling)
- [ ] Testato VoiceOver
- [ ] Testato TalkBack
- [ ] Testato first-run (fresh install)
- [ ] Testato dopo completion (non deve riapparire)
- [ ] Testato reset (deve riapparire)

---

## Priorità Fix

| Edge Case | Severità | Effort | Priorità |
|-----------|----------|--------|----------|
| Context Invalidation | Alta | Basso | P0 |
| Widget Non Renderizzato | Media | Basso | P1 |
| Multi-Tutorial Conflict | Media | Medio | P1 |
| Scroll Position | Media | Medio | P2 |
| SharedPreferences Failure | Bassa | Basso | P2 |
| Interruzioni Sistema | Media | Alto | P2 |
| Orientamento Schermo | Media | Alto | P3 |
| Accessibilità | Alta | Alto | P3 |
| Dark/Light Mode | Bassa | Basso | P3 |
| Animazioni/Timing | Bassa | Medio | P4 |
| Performance | Bassa | Alto | P4 |
| Stato Dati | Bassa | Medio | P4 |
