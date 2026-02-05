# Design: Condivisione Workout in Tempo Reale

**Data**: 2025-02-05
**Status**: Approvato
**Autore**: Claude + Michele

---

## Obiettivo

Permettere agli utenti di condividere un'immagine del workout in corso su WhatsApp (o altre app) direttamente dalla schermata di allenamento.

**Use case principale**: "Mentre mi alleno, voglio condividere con la mia ragazza cosa sto facendo, con tutti gli esercizi e il tempo in palestra."

---

## Decisioni di Design

### Formato condivisione
- **Immagine PNG** generata da widget Flutter
- Dimensioni ottimizzate per WhatsApp (~400px larghezza)
- Alta qualità (pixelRatio: 3.0)

### Trigger UI
- Titolo workout nell'header diventa tappabile
- Icona share (📤) accanto al nome: `Push Day 📤`
- Rimozione testo "Allenamento" ridondante dall'header

### Contenuto immagine
- Nome workout/template
- Nome utente
- Durata corrente
- Volume totale (kg)
- Lista esercizi con dettaglio set completo (peso, reps, RPE)
- Esercizi non completati mostrati in grigio compatto
- Logo FitLog Pro in basso a destra

### Gestione liste lunghe
- Immagine lunga quanto necessario (scrollabile su WhatsApp)
- Nessun limite artificiale al numero di esercizi

---

## Struttura Immagine

```
┌─────────────────────────────────────────┐
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  🏋️ PUSH DAY                    │   │  ← Header gradient
│  │  Michele · 45 min · 2,450 kg    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─ ✓ Panca Piana ─────────────────┐   │
│  │  Set 1   80kg × 10    RPE 7     │   │
│  │  Set 2   85kg × 8     RPE 8     │   │
│  │  Set 3   85kg × 6     RPE 9     │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─ ✓ Croci ai Cavi ───────────────┐   │
│  │  Set 1   15kg × 12    RPE 6     │   │
│  │  Set 2   15kg × 12    RPE 7     │   │
│  │  Set 3   15kg × 10    RPE 8     │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─ ○ Dip ─────────────────────────┐   │
│  │  3 set pianificati              │   │  ← Grigio, non fatto
│  └─────────────────────────────────┘   │
│                                         │
│                        ┌────────────┐  │
│                        │ 🔥 FitLog  │  │
│                        │    Pro     │  │
│                        └────────────┘  │
└─────────────────────────────────────────┘
```

### Specifiche visive
- **Larghezza**: ~400px
- **Sfondo**: Tema scuro app (es. #1a1a2e)
- **Colori**: Primary color per check ✓, grigio per non completati
- **Font**: Sistema (San Francisco iOS / Roboto Android)
- **Logo**: FitLog Pro in basso a destra con "Generata da FitLog Pro"

---

## Architettura Tecnica

### Package utilizzati
- `screenshot: ^3.0.0` - Generazione immagine da widget
- `share_plus` (già presente) - Condivisione nativa
- `path_provider` (già presente) - File temporanei

### File da creare

```
lib/features/workout/
├── presentation/
│   └── widgets/
│       └── share/
│           ├── workout_share_card.dart      # Widget card condivisibile
│           ├── share_exercise_item.dart     # Singolo esercizio nella card
│           └── share_header.dart            # Header con stats
└── services/
    └── workout_share_service.dart           # Logica generazione + share
```

### File da modificare

```
lib/features/workout/presentation/workout_screen/widgets/
└── workout_header.dart                      # Aggiungere titolo tappabile
```

### Flusso tecnico

```dart
// 1. Usa screenshot package
final controller = ScreenshotController();

// 2. Genera da widget (off-screen, non serve mostrarlo)
final imageBytes = await controller.captureFromLongWidget(
  WorkoutShareCard(
    workout: currentWorkout,
    userName: user.displayName,
  ),
  pixelRatio: 3.0,  // Alta qualità
);

// 3. Salva file temporaneo
final tempDir = await getTemporaryDirectory();
final file = File('${tempDir.path}/workout_share_${DateTime.now().millisecondsSinceEpoch}.png');
await file.writeAsBytes(imageBytes);

// 4. Condividi con share_plus
await Share.shareXFiles(
  [XFile(file.path)],
  sharePositionOrigin: shareButtonRect,  // Importante per iPad
);

// 5. Cleanup file temporaneo
await file.delete();
```

---

## Modifiche UI Header

### Prima
```
┌────────────────────────────────────────┐
│  ←  Allenamento          ⋮  ▶️  ⏱️    │
└────────────────────────────────────────┘
```

### Dopo
```
┌────────────────────────────────────────┐
│  ←  Push Day 📤          ⋮  ▶️  ⏱️    │
└────────────────────────────────────────┘
      └────────┘
       tappabile
```

**Comportamento**:
1. Tap su "Push Day 📤"
2. Mostra loading indicator breve
3. Genera immagine in background
4. Apre share sheet nativo
5. Utente sceglie WhatsApp/altro

---

## Considerazioni tecniche

### Best practices applicate (da ricerca web)

1. **pixelRatio: 3.0** - Evita immagini pixelate
2. **captureFromLongWidget** - Gestisce liste lunghe senza problemi
3. **sharePositionOrigin** - Obbligatorio per iPad (evita crash)
4. **File cleanup** - Elimina file temp dopo condivisione
5. **Off-screen rendering** - Non serve mostrare la card a schermo

### Limitazioni note

1. **App Meta (WhatsApp/Instagram)** - `share_plus` ha limitazioni documentate con app Meta. Usiamo share sheet nativo che funziona meglio.
2. **Platform Views** - Screenshot non supporta Google Maps/Camera (non rilevante per noi)

---

## Localizzazione

Nuove stringhe da aggiungere:

```yaml
# app_en.arb
"workoutShareTitle": "Share Workout",
"workoutShareGenerating": "Generating image...",
"workoutShareError": "Could not generate image",
"workoutShareSetsPlanned": "{count} sets planned",
"workoutShareGeneratedBy": "Generated by FitLog Pro"

# app_it.arb
"workoutShareTitle": "Condividi Allenamento",
"workoutShareGenerating": "Generazione immagine...",
"workoutShareError": "Impossibile generare immagine",
"workoutShareSetsPlanned": "{count} set pianificati",
"workoutShareGeneratedBy": "Generata da FitLog Pro"
```

---

## Checklist implementazione

- [ ] Aggiungere `screenshot` package a pubspec.yaml
- [ ] Creare `WorkoutShareCard` widget
- [ ] Creare `ShareExerciseItem` widget
- [ ] Creare `ShareHeader` widget
- [ ] Creare `WorkoutShareService`
- [ ] Modificare `WorkoutHeader` - titolo tappabile con icona share
- [ ] Aggiungere stringhe localizzazione (EN + IT)
- [ ] Testare su iOS (specialmente iPad con sharePositionOrigin)
- [ ] Testare su Android
- [ ] Testare condivisione WhatsApp

---

## Fonti

- [Flutter toImage API](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html)
- [screenshot package](https://pub.dev/packages/screenshot)
- [share_plus package](https://pub.dev/packages/share_plus)
- [FreeCodeCamp - Production Guide](https://www.freecodecamp.org/news/how-to-save-and-share-flutter-widgets-as-images-a-complete-production-ready-guide/)
