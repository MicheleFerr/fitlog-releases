# 📋 Workout Templates Screen - Mini Report Tecnico

**Data**: 21 Ottobre 2025
**Versione**: 1.0
**Schermata**: WorkoutTemplatesScreen
**File Principale**: `lib/features/workout/presentation/screens/workout_templates_screen.dart`

---

## 📸 Screenshot Riferimento

La schermata analizzata mostra:
- **Titolo**: "Le Mie Schede"
- **Banner verde**: "Inizia Subito" (quick start)
- **2 Tab**: "I Tuoi Template" + "Schede Predefinite"
- **Template Card**: Pull, Push, Arms, Push v2 (con badge "Personalizzato")
- **FAB**: "Crea Scheda"

---

## 🎯 Cosa Fa Questa Schermata?

### Funzionalità Principali

1. **Visualizzazione Template** (3 sezioni)
   - **All Templates**: Tutti i template disponibili (predefiniti + custom)
   - **Popular Templates**: Template pubblici più usati
   - **My Templates**: Solo template personalizzati dell'utente

2. **Gestione Template**
   - Creare nuovi template
   - Modificare template esistenti
   - Eliminare template personalizzati
   - Avviare workout da template

3. **Ricerca e Filtri**
   - Barra di ricerca per template
   - Filtro per categoria/tipo

4. **Sincronizzazione**
   - Sync Firebase automatico
   - Indicatore stato online/offline
   - Gestione modifiche offline

---

## 🏗️ Architettura e Componenti

### 1. Screen Layer (`WorkoutTemplatesScreen`)

**Responsabilità**:
- UI principale con TabController (3 tab)
- Gestione stato UI (ricerca, filtri)
- Navigazione tra schermate
- Lifecycle management (init, dispose)

**Componenti UI**:
```dart
AppBar
  ├─ Cloud Sync Indicator (solo se autenticato)
  ├─ Create Button
  └─ Back Button

TabBar (3 tab)
  ├─ All Templates (icona lista)
  ├─ Popular Templates (icona trending)
  └─ My Templates (icona persona)

SearchBar (con filtro)

TabBarView
  ├─ _buildAllTemplatesTab()
  ├─ _buildPopularTemplatesTab()
  └─ _buildMyTemplatesTab()

FAB: "Crea Template"

Banner Ad (in fondo)
```

---

### 2. Provider Layer (State Management)

**Provider Principali**:

| Provider | Tipo | Scopo |
|----------|------|-------|
| `customWorkoutTemplatesProvider` | AsyncValue<List<WorkoutTemplate>> | Template custom dell'utente |
| `userTemplatesProvider` | AsyncValue<List<UnifiedWorkoutTemplate>> | Template utente (UNIFIED) |
| `publicTemplatesProvider` | AsyncValue<List<UnifiedWorkoutTemplate>> | Template pubblici |
| `templateSearchQueryProvider` | StateProvider<String> | Query di ricerca |
| `templateSearchResultsProvider` | AsyncValue<List<WorkoutTemplate>> | Risultati ricerca |
| `firebaseTemplateNotifierProvider` | TemplateState | Stato sync Firebase |

**Flusso Dati**:
```
UI (WorkoutTemplatesScreen)
  ↓ watch()
Provider (customWorkoutTemplatesProvider)
  ↓ read()
Repository (UnifiedTemplateRepository)
  ↓ query()
Storage (Hive + Firebase)
```

---

### 3. Repository Layer (Data Sources)

**Sistema UNIFIED** (nuovo):
- `UnifiedTemplateRepository`: Repository principale che gestisce Hive + Firebase
- `TemplateBridge`: Conversione tra `UnifiedWorkoutTemplate` ↔ `WorkoutTemplate` (legacy)

**Storage**:
- **Hive** (local-first): Cache locale, offline-first
- **Firebase** (cloud sync): Sincronizzazione cloud, condivisione

---

### 4. Widget Components

#### `TemplateCard` (`template_card.dart`)

**Cosa mostra**:
```
┌─────────────────────────────────────┐
│ [Nome Template]           [Menu...] │
│ Descrizione template...             │
│                                      │
│ [🏋️ 6] [⏱️ 45 min] [📊 12 utilizzi] │
│                                      │
│ [Badge: Personalizzato] [tags...]   │
│                                      │
│ ESERCIZI: 6                          │
│ • Panca Piana                        │
│ • Squat                              │
│ • ... e altri 4                      │
└─────────────────────────────────────┘
```

**Interazioni**:
- **Tap**: Avvia workout da template
- **Long Press**: Mostra menu contestuale
- **Menu**: Modifica / Elimina (solo template custom)

**Statistiche visualizzate**:
- Numero esercizi
- Durata stimata
- Contatore utilizzi (se > 0)
- Badge tipo (Personalizzato vs Predefinito)
- Preview primi 3 esercizi

---

## 🔄 Flussi Principali

### Flusso 1: Visualizzazione Template

```
User apre la schermata
  ↓
initState() inizializza TabController
  ↓
Provider carica template (watch)
  ↓
Repository query Hive (local-first)
  ↓
Se online: Background sync Firebase
  ↓
UI mostra liste template per tab
```

**Codice chiave** (`workout_templates_screen.dart:336-378`):
```dart
Widget _buildMyTemplatesTab() {
  final customTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);

  return customTemplatesAsync.when(
    loading: () => const Center(child: LoadingIndicator()),
    error: (error, stack) => Center(child: Text('Errore: $error')),
    data: (templates) {
      if (templates.isEmpty) {
        return _buildEmptyState(); // CTA: "Crea il tuo primo template"
      }
      return _buildTemplatesList(templates);
    },
  );
}
```

---

### Flusso 2: Creazione Template

```
User tap FAB "Crea Scheda"
  ↓
_showCreateTemplateModal()
  ↓
Mostra BottomSheet con opzioni
  ├─ Crea Manualmente
  └─ (Futuro: Import JSON)
  ↓
Tap "Crea Manualmente"
  ↓
Apre CreateTemplateModal
  ↓
User inserisce dati (nome, descrizione, esercizi)
  ↓
Save → Repository.createTemplate()
  ↓
Hive salva locale + Firebase sync (se online)
  ↓
Provider.invalidate() → Refresh UI
  ↓
Snackbar: "✅ Template creato"
```

**Codice chiave** (`workout_templates_screen.dart:413-444`):
```dart
void _showCreateTemplateModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      child: ListTile(
        leading: Icon(Icons.edit, color: context.colors.primary),
        title: Text(context.l10n.createManually),
        subtitle: Text(context.l10n.buildFromScratch),
        onTap: () {
          Navigator.pop(context);
          _showCreateTemplateModalOriginal(context);
        },
      ),
    ),
  );
}
```

---

### Flusso 3: Avvio Workout da Template

```
User tap su TemplateCard
  ↓
_showStartWorkoutConfirmation()
  ↓
Dialog: "Vuoi iniziare [Template Name]?"
  ↓
User conferma
  ↓
_startWorkoutFromTemplate(template)
  ↓
1. Incrementa useCount template (Firebase)
2. Crea nuovo workout (WorkoutProvider)
3. Associa templateId al workout
4. 🎯 WEIGHT RECOVERY SYSTEM
   ├─ Cerca ultimo workout dello stesso template
   ├─ Se trovato: Mostra dialog opzioni
   │  ├─ Increase (+2.5%)
   │  ├─ Exact (stessi pesi)
   │  ├─ Decrease (-2.5%)
   │  └─ None (pesi vuoti)
   └─ Applica pesi agli esercizi
5. Aggiungi esercizi al workout
6. Avvia workout timer
  ↓
Navigate → /workout (WorkoutScreen)
  ↓
Snackbar: "✅ Workout [Template] avviato!"
```

**Codice chiave - Weight Recovery** (`workout_templates_screen.dart:513-531`):
```dart
// 🎯 WEIGHT RECOVERY: Recupera workout precedente
WeightRecoveryOption? selectedOption;
try {
  final recoveryData = await ref.read(
    weightRecoveryDataProvider(template.id).future
  );

  if (recoveryData.hasData && recoveryData.previousWorkout != null) {
    // Mostra dialog di recupero pesi
    selectedOption = await WeightRecoveryDialog.show(
      context,
      recoveryData.previousWorkout!,
      recoveryData.lastSessionDate!,
      recoveryData.daysSinceLastSession,
    );
  }
} catch (e) {
  debugPrint('⚠️ Errore nel recupero workout precedente: $e');
}
```

**Moltiplicatori pesi**:
- **Increase**: 1.025 (+2.5%)
- **Exact**: 1.0 (stessi pesi)
- **Decrease**: 0.975 (-2.5%)
- **None**: Pesi vuoti (user inserisce manualmente)

---

### Flusso 4: Eliminazione Template

```
User long press su TemplateCard → Menu
  ↓
User tap "Elimina"
  ↓
_deleteTemplate(template)
  ↓
Dialog conferma: "Sei sicuro?"
  ↓
User conferma
  ↓
Show LoadingIndicator
  ↓
Delete da TUTTI i repository:
  1. UnifiedRepository (principale)
  2. LegacyRepository (sicurezza)
  3. HybridRepository (nuovi template)
  ↓
Invalidate ALL providers:
  - userTemplatesProvider
  - customWorkoutTemplatesProvider
  - allWorkoutTemplatesProvider
  - templateSearchResultsProvider
  ↓
Force refresh providers (100ms delay)
  ↓
Hide LoadingIndicator
  ↓
Snackbar: "✅ Template eliminato"
```

**Codice chiave** (`workout_templates_screen.dart:641-691`):
```dart
// Step 1: Delete from unified repository (handles all sources)
final unifiedRepository = ref.read(unifiedTemplateRepositoryProvider);
await unifiedRepository.deleteTemplate(template.id);

// Step 2-3: Try legacy and hybrid (for safety)
try {
  final legacyRepository = ref.read(workoutTemplateRepositoryProvider);
  await legacyRepository.deleteTemplate(template.id);
} catch (e) { /* expected for new templates */ }

// Step 4: Invalidate ALL providers
ref.invalidate(userTemplatesProvider);
ref.invalidate(customWorkoutTemplatesProvider);
// ... altri provider

// Wait for invalidation to propagate
await Future.delayed(const Duration(milliseconds: 100));

// Force refresh
await ref.refresh(customWorkoutTemplatesProvider.future);
```

---

## 🔄 Sistema di Sincronizzazione

### Indicatore Sync (AppBar)

**Stato visibile**:
- **Blu pulsante**: Sync in corso
- **Arancione**: Modifiche offline da sincronizzare
- **Grigio**: Tutto sincronizzato

**Codice** (`workout_templates_screen.dart:77-123`):
```dart
Consumer(
  builder: (context, ref, child) {
    final firebaseState = ref.watch(firebaseTemplateNotifierProvider);

    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.cloud),
          if (firebaseState.isSyncing)
            Positioned(
              right: 0, top: 0,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (firebaseState.hasOfflineChanges)
            Positioned(
              right: 0, top: 0,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => _showSyncInfo(context, syncStatus),
    );
  },
)
```

### Dialog Info Sync

**Info mostrate**:
- Status sync ("Sincronizzato", "Offline", "In Sync...")
- Ultimo sync timestamp
- Numero template totali
- Avviso modifiche offline

**Azioni**:
- **Sincronizza Ora**: Force sync manuale (solo se online)

---

## 🎨 UI/UX Features

### 1. Empty States

**My Templates vuoto**:
```
🏋️ (icona grande grigia)
Nessun template personalizzato

Crea il tuo primo template personalizzato

[Button: Crea Template]
```

**Search no results**:
```
🔍 (icona grande grigia)
Nessun template trovato
```

### 2. Loading States

- **Schermata intera**: `LoadingIndicator()` (componente unificato)
- **Durante delete**: Dialog con LoadingIndicator bloccante

### 3. Error States

- **Error loading**: Icona errore + messaggio + button "Riprova"
- **Error deleting**: SnackBar rosso con messaggio errore

### 4. Success Feedback

- **Template creato**: SnackBar verde "✅ Template creato"
- **Template eliminato**: SnackBar verde "✅ Template eliminato"
- **Workout avviato**: SnackBar verde "✅ Workout [Nome] avviato!"

---

## 📦 Dipendenze Principali

### Packages
- **flutter_riverpod**: State management
- **go_router**: Navigation
- **firebase_auth**: Autenticazione
- **hive**: Storage locale

### Internal Dependencies
```dart
// Domain
import 'features/workout/domain/entities/workout_template.dart';
import 'features/workout/domain/entities/exercise.dart';

// Presentation
import 'features/workout/presentation/providers/workout_provider.dart';
import 'features/workout/presentation/widgets/template_card.dart';
import 'features/workout/presentation/widgets/create_template_modal.dart';

// Shared
import 'shared/presentation/l10n/generated/app_localizations.dart';
import 'shared/presentation/extensions/build_context_extensions.dart';
import 'shared/presentation/widgets/loading_indicator.dart';
import 'shared/presentation/services/snackbar_service.dart';

// Repository
import 'shared/data/repositories/unified_template_repository.dart';
import 'shared/domain/entities/template_bridge.dart';
```

---

## 🔒 Sistema UNIFIED (Nuovo)

### Problema Risolto

Prima c'erano **3 repository diversi**:
1. `WorkoutTemplateRepository` (legacy)
2. `HybridTemplateRepository` (ibrido)
3. `FirebaseTemplateRepository` (cloud)

**Risultato**: Template non si vedevano, duplicazioni, sync incerto

### Soluzione: UnifiedTemplateRepository

**Un solo punto di accesso**:
- Gestisce Hive + Firebase automaticamente
- Conversione automatica legacy ↔ unified
- Single source of truth

**TemplateBridge**:
```dart
// Conversione WorkoutTemplate → UnifiedWorkoutTemplate
final unified = TemplateBridge.toUnified(legacyTemplate);

// Conversione UnifiedWorkoutTemplate → WorkoutTemplate
final legacy = TemplateBridge.toLegacy(unifiedTemplate);
```

**Vantaggi**:
- ✅ Nessun template perso
- ✅ Sync consistente
- ✅ Eliminazione sicura (da TUTTI i repository)
- ✅ Migrazione graduale (supporta entrambi i formati)

---

## 🎯 Weight Recovery System

### Funzionalità

Quando avvii un workout da template, il sistema:
1. **Cerca ultimo workout** dello stesso template
2. **Calcola giorni** dall'ultimo allenamento
3. **Mostra dialog** con 4 opzioni:
   - **Increase (+2.5%)**: Sovraccarico progressivo
   - **Exact**: Stessi pesi dell'ultima volta
   - **Decrease (-2.5%)**: Deload (se stanco)
   - **None**: Nessun peso pre-caricato

4. **Applica pesi** agli esercizi del workout
5. **User modifica** se necessario durante workout

### Provider

**`weightRecoveryDataProvider`**:
```dart
final weightRecoveryDataProvider = FutureProvider.family<
  WeightRecoveryData,
  String
>((ref, templateId) async {
  final service = ref.read(weightRecoveryServiceProvider);
  return service.getRecoveryData(templateId);
});
```

**`WeightRecoveryData`**:
- `hasData`: bool (workout precedente trovato?)
- `previousWorkout`: Workout? (ultimo workout)
- `lastSessionDate`: DateTime? (data ultimo workout)
- `daysSinceLastSession`: int (giorni trascorsi)

### Dialog

**WeightRecoveryDialog.show()**:
- Mostra data ultimo workout
- Mostra giorni trascorsi
- 4 pulsanti con icone
- Return: `WeightRecoveryOption?`

---

## 📊 Performance & Ottimizzazioni

### 1. ListView.builder

```dart
ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: templates.length,
  itemBuilder: (context, index) {
    final template = templates[index];
    return TemplateCard(template: template, ...);
  },
)
```

**Vantaggi**:
- Lazy loading: solo widget visibili
- Memory efficient per liste lunghe

### 2. Provider Invalidation Strategy

**Dopo delete**:
```dart
// Invalidate multiple providers
ref.invalidate(userTemplatesProvider);
ref.invalidate(customWorkoutTemplatesProvider);
ref.invalidate(allWorkoutTemplatesProvider);

// Wait for propagation
await Future.delayed(const Duration(milliseconds: 100));

// Force refresh
await ref.refresh(customWorkoutTemplatesProvider.future);
```

**Perché?**
- Assicura refresh completo
- Evita stale data
- Propagazione cambiamenti

### 3. Const Constructors

```dart
const Center(child: LoadingIndicator())
const SizedBox(height: 16)
const Icon(Icons.fitness_center)
```

**Benefici**:
- Riduci rebuild
- Memory saving
- Performance migliorata

---

## 🐛 Debug Features

### 1. Debug Banners

**Banner blu** (top):
```
🔵 WORKOUT TEMPLATES LIST SCREEN (principale)
```

**Banner rosso** (sotto search):
```
❌ WorkoutTemplatesScreen - Qui NON VEDO i miei template
Templates: 4
```

**Scopo**: Identificare quale schermata è attiva durante debug

### 2. Console Logs

**Provider logs**:
```dart
debugPrint('🔍 MyTemplatesTab - Using customWorkoutTemplatesProvider');
debugPrint('🔍 MyTemplatesTab - Got ${templates.length} templates');
```

**Delete logs**:
```dart
debugPrint('🗑️ Starting deletion for template: ${template.id}');
debugPrint('✅ Deleted from unified repository');
debugPrint('❌ Error deleting template: $e');
```

### 3. Template Card Debug

**Info esercizi sempre visibile**:
```
ESERCIZI: 6
• Panca Piana
• Squat
... e altri 4
```

**Template vuoto warning**:
```
TEMPLATE VUOTO! (red background)
```

---

## 🚀 Possibili Miglioramenti

### 1. UI/UX

- [ ] **Pull-to-refresh** per aggiornare template
- [ ] **Swipe actions** su card (edit/delete)
- [ ] **Filtri avanzati** (durata, difficoltà, muscoli)
- [ ] **Sorting** (alfabetico, più usati, recenti)
- [ ] **Grid view** opzione (oltre a lista)

### 2. Features

- [ ] **Duplica template** (quick copy)
- [ ] **Condividi template** (link/QR code)
- [ ] **Template pubblici** con rating/reviews
- [ ] **Categorie template** (forza, ipertrofia, endurance)
- [ ] **Template da JSON** import

### 3. Performance

- [ ] **Pagination** per liste lunghe (>50 template)
- [ ] **Search debounce** (evita query ogni carattere)
- [ ] **Image caching** per thumbnail template
- [ ] **Offline queue** per operazioni sync

### 4. Analytics

- [ ] **Track template usage** (quale template più usato)
- [ ] **Track completion rate** per template
- [ ] **Suggest template** basato su storico

---

## 📚 File Correlati

### Core Files
- **Screen**: `lib/features/workout/presentation/screens/workout_templates_screen.dart`
- **Widget**: `lib/features/workout/presentation/widgets/template_card.dart`
- **Provider**: `lib/features/workout_templates/presentation/providers/template_provider.dart`

### Alternative Implementation
- **Screen v2**: `lib/features/workout_templates/presentation/screens/templates_home_screen.dart`
- **Card v2**: `lib/features/workout_templates/presentation/widgets/template_card.dart`

### Domain & Data
- **Entity**: `lib/features/workout/domain/entities/workout_template.dart`
- **Repository**: `lib/shared/data/repositories/unified_template_repository.dart`
- **Bridge**: `lib/shared/domain/entities/template_bridge.dart`

### Related Screens
- **CreateTemplateModal**: `lib/features/workout/presentation/widgets/create_template_modal.dart`
- **EditTemplateScreen**: `lib/features/workout/presentation/screens/edit_template_screen.dart`
- **WorkoutScreen**: `lib/features/workout/presentation/workout_screen.dart`

---

## 🎓 Documentazione Correlata

Per approfondire:
- **Workout System**: `docs/WORKOUT_SYSTEM_OVERVIEW.md`
- **Template Development**: `docs/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`
- **Localization**: `docs/LOCALIZATION_GUIDE.md`
- **Architecture**: `ARCHITECTURAL_OPTIMIZATIONS_REPORT.md`

---

## 📝 Summary

**WorkoutTemplatesScreen** è la schermata centrale per gestire i template di allenamento in GymBro:

- ✅ **3 Tab**: All, Popular, My Templates
- ✅ **CRUD completo**: Create, Read, Update, Delete
- ✅ **Weight Recovery**: Recupero intelligente pesi precedenti
- ✅ **Firebase Sync**: Sincronizzazione cloud automatica
- ✅ **UNIFIED System**: Repository unificato per storage
- ✅ **Ricerca e Filtri**: Trova template velocemente
- ✅ **Empty States**: UX curata per liste vuote
- ✅ **Loading & Error**: Gestione stati completa

**Architettura**: Clean Architecture + Riverpod + Hybrid Storage (Hive + Firebase)

**Performance**: Lazy loading, const widgets, provider invalidation ottimizzata

**UX**: Card informative, feedback immediato, weight recovery intelligente

---

**Fine del Report** 🏋️‍♂️
