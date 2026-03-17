# Design: Community Video Links per Esercizi

**Data**: 2026-03-16
**Stato**: Approvato
**Feature**: Community video links negli esercizi

---

## Panoramica

Ogni esercizio nel database può avere link video contribuiti dalla community degli utenti. I link sono condivisi pubblicamente (pool unico): aggiungere un link lo rende visibile a tutti gli utenti. L'utente può eliminare i propri link.

---

## Scelte di Design

| Aspetto | Decisione | Motivazione |
|---|---|---|
| Pool video | Community unico (non privato) | Massima utilità, semplicità architetturale |
| Sicurezza | Whitelist domini: YouTube, TikTok, Instagram | Zero link malevoli, nessuna moderazione manuale |
| Player | `url_launcher` + `LaunchMode.inAppBrowserView` | Package ufficiale Flutter, SFSafariViewController nativo su iOS, Custom Tabs su Android |
| Entry point | Chip discreta in `ExerciseDetailsModal` | Non ingombrante, contestuale |
| Lista video | Bottom sheet separato, lista verticale | Più informazioni (autore, data, dominio) |
| Aggiunta link | Solo URL, titolo estratto automaticamente | Zero friction per l'utente |

---

## UI Flow

```
ExerciseDetailsModal
  └── [Chip] "🎬 3 video dalla community" (nascosta se 0 video)
        └── tap → ExerciseVideosSheet
              ├── Lista video (ExerciseVideoTile × N)
              │     └── tap → url_launcher (inAppBrowserView)
              └── Bottone "+ Aggiungi"
                    └── tap → AddVideoLinkSheet
                          ├── Campo URL con validazione live
                          ├── Preview titolo (dopo fetch oEmbed)
                          └── Bottone "Aggiungi" → Cloud Function
```

---

## Architettura Firestore

```
exercise_videos/
  {exerciseId}/              # document per ogni esercizio
    videos/                  # sub-collection
      {videoId}:
        url: string          # URL originale
        domain: string       # "youtube.com" | "tiktok.com" | "instagram.com"
        title: string        # estratto via oEmbed/noembed
        thumbnailUrl: string # estratto via oEmbed (nullable)
        addedBy: string      # userId
        addedByName: string  # displayName al momento dell'aggiunta
        createdAt: timestamp
        exerciseId: string   # denormalizzato per query inverse

users/{uid}/stats/videosByExercise/{exerciseId}:
  count: number              # contatore per-esercizio per rate limiting
```

**Limite**: max **3 link per utente per esercizio** (enforced in Cloud Function).

---

## Componenti Flutter

### Nuovi widget

| Widget | File | Responsabilità |
|---|---|---|
| `ExerciseVideosChip` | `exercise_videos/presentation/widgets/exercise_videos_chip.dart` | Chip "N video" in ExerciseDetailsModal |
| `ExerciseVideosSheet` | `exercise_videos/presentation/screens/exercise_videos_sheet.dart` | Sheet lista video + bottone aggiungi |
| `AddVideoLinkSheet` | `exercise_videos/presentation/screens/add_video_link_sheet.dart` | Input URL, preview titolo, submit |
| `ExerciseVideoTile` | `exercise_videos/presentation/widgets/exercise_video_tile.dart` | Singola riga: icona dominio colorata, titolo, autore, data |

### Provider Riverpod

| Provider | Tipo | Stream/Future |
|---|---|---|
| `exerciseVideosProvider(exerciseId)` | `StreamProvider<List<ExerciseVideo>>` | Stream Firestore sub-collection |
| `addExerciseVideoProvider` | `AsyncNotifierProvider` | Stato submit (loading/error/success) |

### Repository

```
exercise_videos/
  data/
    repositories/exercise_video_repository_impl.dart
    datasources/exercise_video_remote_datasource.dart
  domain/
    entities/exercise_video.dart
    repositories/i_exercise_video_repository.dart
```

---

## Cloud Functions

### `addExerciseVideo` (callable)

```typescript
Input: { exerciseId: string, url: string }

1. Verifica autenticazione (request.auth)
2. Valida URL con new URL() + Set hostname esatti
3. Controlla contatore users/{uid}/stats/videosByExercise/{exerciseId}.count < 3
4. Chiama oEmbed/noembed per estrarre titolo + thumbnailUrl
5. Scrive in exercise_videos/{exerciseId}/videos/{auto-id}
6. Incrementa users/{uid}/stats/videosByExercise/{exerciseId}.count (transazione)
```

**Domini whitelist**:
```typescript
const ALLOWED_DOMAINS = new Set([
  'www.youtube.com', 'youtube.com', 'youtu.be',
  'www.tiktok.com', 'vm.tiktok.com',
  'www.instagram.com', 'instagram.com',
]);
```

**Estrazione titolo**:
- YouTube: `https://www.youtube.com/oembed?url={url}&format=json`
- TikTok/Instagram: `https://noembed.com/embed?url={url}`
- Fallback (401 / timeout): usa dominio come titolo (`"Video da youtube.com"`)

### `deleteExerciseVideo` (callable)

```typescript
Input: { exerciseId: string, videoId: string }

1. Verifica ownership (addedBy == request.auth.uid)
2. Elimina documento
3. Decrementa contatore
```

---

## Firestore Security Rules

```javascript
// Lettura: tutti gli utenti autenticati
match /exercise_videos/{exerciseId}/videos/{videoId} {
  allow read: if request.auth != null;
  // Scrittura solo via Cloud Function (admin SDK)
  allow write: if false;
}

// Contatore per rate limiting per-esercizio (solo Cloud Function scrive)
match /users/{uid}/stats/videosByExercise/{exerciseId} {
  allow read: if request.auth.uid == uid;
  allow write: if false;
}
```

Tutta la logica di scrittura passa per Cloud Functions (Admin SDK bypassa le rules), garantendo validazione server-side completa.

---

## Validazione URL (lato client)

Prima di inviare alla Cloud Function, validazione live nel `AddVideoLinkSheet`:

```dart
bool isAllowedDomain(String url) {
  try {
    final uri = Uri.parse(url);
    const allowed = {'www.youtube.com', 'youtube.com', 'youtu.be',
                     'www.tiktok.com', 'vm.tiktok.com',
                     'www.instagram.com', 'instagram.com'};
    return uri.scheme == 'https' && allowed.contains(uri.host);
  } catch (_) {
    return false;
  }
}
```

Mostra errore inline `"Solo YouTube, TikTok e Instagram sono supportati"` senza dover chiamare il server.

---

## Gestione stati UI

| Stato | Comportamento |
|---|---|
| 0 video | Chip non mostrata nel modal |
| Utente non loggato | Chip visibile (sola lettura), bottone "Aggiungi" nascosto |
| Limite 3 raggiunto | Bottone "Aggiungi" disabilitato con tooltip |
| Titolo non estraibile | Mostra `"Video da youtube.com"` come titolo |
| Video privato (401) | Titolo fallback, link comunque salvato e apribile |

---

## Localizzazione

Chiavi ARB da aggiungere (`app_en.arb` + `app_it.arb`):

```
exerciseVideosChip: "N video dalla community"
exerciseVideosSheetTitle: "Video — {exerciseName}"
exerciseVideosAdd: "Aggiungi link"
exerciseVideosAddHint: "Incolla URL YouTube, TikTok o Instagram"
exerciseVideosInvalidDomain: "Solo YouTube, TikTok e Instagram sono supportati"
exerciseVideosLimitReached: "Hai già aggiunto 3 link per questo esercizio"
exerciseVideosFetchingTitle: "Recupero titolo..."
exerciseVideosAddedBy: "Aggiunto da {name} · {date}"
exerciseVideosEmpty: "Nessun video ancora. Sii il primo ad aggiungerne uno!"
```

---

## Struttura Feature

```
lib/features/exercise_videos/
  data/
    datasources/exercise_video_remote_datasource.dart
    repositories/exercise_video_repository_impl.dart
  domain/
    entities/exercise_video.dart
    repositories/i_exercise_video_repository.dart
  presentation/
    providers/exercise_videos_provider.dart
    screens/
      exercise_videos_sheet.dart
      add_video_link_sheet.dart
    widgets/
      exercise_videos_chip.dart
      exercise_video_tile.dart
```

---

## Package richiesti

Nessun package nuovo — `url_launcher` già in uso nel progetto.

---

## Testing

| Test | Tipo | Coverage |
|---|---|---|
| `isAllowedDomain()` con URL validi/invalidi/malicious | Unit | Domini whitelist, bypass attempts |
| `ExerciseVideosChip` visibile/nascosta | Widget | 0 video, N video, utente non loggato |
| `AddVideoLinkSheet` validazione live | Widget | URL valido, dominio non permesso, URL malformato |
| `ExerciseVideoTile` render | Widget | Ogni dominio supportato |
| `exercise_videos_provider` stream | Unit | Aggiunta, eliminazione, limite |
| Cloud Function `addExerciseVideo` | Integration | Whitelist bypass, limite 3, oEmbed fallback |
