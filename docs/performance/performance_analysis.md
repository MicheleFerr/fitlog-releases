# GymBro Performance Analysis - iOS Profiling Results

## Executive Summary

Il profiling iOS ha evidenziato problemi critici di performance:
- **Main Thread: 40.8% (18.77s)** - TROPPO ALTO (target: <20%)
- **Memory Allocations: ~600ms** - Indicatore di creazione oggetti eccessiva
- **Garbage Collection: ~230ms** - Conseguenza diretta di allocazioni eccessive
- **Crc32.compute: 83ms** - Non previsto nel codebase (probabilmente Hive)
- **Timeline events: 82ms** - Overhead diagnostica
- **RegExp: 69ms** - Validazione/parsing pattern
- **Raster thread: 20.7%** - Accettabile ma migliorabile

## Cause Identificate

### 1. TIMER UPDATES - MASSIMO IMPATTO
**Problema**: Timer.periodic a 1Hz causa rebuild chain massiva
- `unified_timer_provider.dart`: Timer ogni 1s aggiorna stato
- `header_rest_timer.dart`: USA .select() (BENE) ma ancora 10 watch diversi
- `workout_mini_bar.dart`: Timer separato ogni 1s per UI update
- `exercise_autocollapse_provider.dart`: Timer countdown ogni 1s

**Impatto**: 60+ state update/minuto * N widgets in ascolto = centinaia di rebuild/min

### 2. LIST RENDERING - ALTO IMPATTO
**Problema**: Exercise list senza ottimizzazioni adeguate
- `workout_view.dart`: Usa MaterialScrollList (custom) ma senza lazy loading
- `exercise_list_item_orchestrator.dart`: AutomaticKeepAliveClientMixin ATTIVO
  - PRO: Previene dispose/init su scroll
  - CONTRO: Tiene in memoria TUTTI i widget (anche fuori viewport)
- Ogni ExerciseListItem ha:
  - GIF animata (Timer.periodic 800ms)
  - Multiple provider watches (9+ per item)
  - JSON loading per exercise data

**Impatto**: Con 10+ esercizi = 100+ provider watches attivi simultaneamente

### 3. IMAGE/GIF LOADING - MEDIO IMPATTO
**Problema**: CachedNetworkImage + animazione custom
- `exercise_gif_widget.dart`: Timer.periodic 800ms per 2-frame animation
- Ogni esercizio nella lista ha una GIF che si anima
- 10 esercizi = 10 timer attivi + 10 CachedNetworkImage + rebuild AnimatedSwitcher

**Impatto**: ~12 frame update/sec per esercizio (800ms flip-flop)

### 4. PROVIDER WATCHES - MEDIO IMPATTO
**Problema**: ref.watch() invece di .select() in molti widget
- Rapporto .select(): 33 usi vs ref.watch(): 196 usi (ratio 1:6)
- `exercise_list_item_orchestrator.dart`: 9 ref.watch vs 7 .select
- Molti widget ascoltano intero provider invece di campi specifici

**Impatto**: Rebuild inutili quando campi non rilevanti cambiano

### 5. REGEXP OPERATIONS - BASSO IMPATTO
**Problema**: 69ms totali di RegExp operations
- Prevalentemente in input validation (`input_validator.dart`)
- Exercise search/filtering (`exercise_search_service.dart`)

**Impatto**: Marginale ma ottimizzabile con caching

### 6. MEMORY ALLOCATIONS - CONSEGUENZA
**Problema**: 600ms in allocazioni + 230ms GC
- Causato da rebuild eccessivi (punto 1-4)
- Ogni rebuild = nuovi widget objects, render objects, etc.
- GC deve ripulire oggetti inutilizzati

## Piano Ottimizzazione Prioritizzato

### PRIORITY 1: Timer Updates Optimization (Impatto: -15% main thread)

#### File: `lib/features/timer/presentation/providers/unified_timer_provider.dart`
**Azioni**:
1. Introdurre ValueNotifier<int> per remainingSeconds invece di state update
2. Esporre Stream<int> invece di forcing rebuild provider
3. Widget consumano stream con StreamBuilder (rebuild solo widget specifico)

#### File: `lib/features/workout/presentation/widgets/header_rest_timer.dart`
**Azioni**:
1. Ridurre 10 .select() watches consolidando stato
2. Usare StreamBuilder per remainingSeconds invece di provider watch
3. Implementare RepaintBoundary per isolare ripaint

#### File: `lib/features/workout/presentation/widgets/workout_mini_bar.dart`
**Azioni**:
1. Rimuovere Timer.periodic locale
2. Ascoltare stream da unified_timer_provider
3. Usare ValueListenableBuilder invece di setState

### PRIORITY 2: List Rendering Optimization (Impatto: -10% main thread)

#### File: `lib/features/workout/presentation/workout_screen/widgets/workout_view.dart`
**Azioni**:
1. Verificare MaterialScrollList implementa caching corretto
2. Aggiungere addAutomaticKeepAlives: false a ListView
3. Implementare itemExtent se altezza item fissa (skip layout calculation)

#### File: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart`
**Azioni**:
1. RIMUOVERE AutomaticKeepAliveClientMixin per esercizi fuori viewport
2. Implementare caching JSON data a livello provider (non widget)
3. Lazy load GIF: mostra placeholder statico, carica GIF on-demand
4. Ridurre ref.watch da 9 a 3-4 usando .select() e consolidamento

### PRIORITY 3: GIF Animation Optimization (Impatto: -5% main thread + -3% raster)

#### File: `lib/features/workout/presentation/widgets/exercise_gif_widget.dart`
**Azioni**:
1. Disabilitare animazione per item fuori viewport (IntersectionObserver pattern)
2. Usare AnimationController invece di Timer.periodic
3. Ridurre frame rate a 0.5Hz (1 flip ogni 2 sec) invece di 1.25Hz
4. Implementare RepaintBoundary attorno GIF container

#### File: `lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart`
**Azioni**:
1. Stesso pattern: AnimationController invece di Timer.periodic
2. Pre-cache frame 0 e 1 all'apertura modal

### PRIORITY 4: Provider Watch Optimization (Impatto: -5% main thread)

**Ricerca massiva**: Convertire ref.watch() -> .select() dove possibile
```bash
grep -r "ref\.watch(" lib/features/workout/presentation --include="*.dart" | \
  grep -v "\.select" | \
  wc -l
```

**File principali**:
- `exercise_list_item_orchestrator.dart`
- `superset_card.dart`
- `add_exercise_modal.dart`
- `quick_edit_overlay_v2.dart`

**Pattern**:
```dart
// BEFORE
final config = ref.watch(appConfigProvider);
final value = config.someField;

// AFTER
final value = ref.watch(appConfigProvider.select((c) => c.someField));
```

### PRIORITY 5: RegExp Caching (Impatto: -2% main thread)

#### File: `lib/shared/domain/services/input_validator.dart`
**Azioni**:
1. Cachare RegExp compilati come static final
2. Evitare RegExp() constructor ripetuto

#### File: `lib/features/exercise_database/domain/services/exercise_search_service.dart`
**Azioni**:
1. Pre-compilare regex pattern
2. Usare simple string matching dove possibile

### PRIORITY 6: Memory Management (Impatto: indiretto)

**Azioni generali**:
1. Audit dispose() in tutti StatefulWidget con timer/stream
2. Verificare che tutti Timer.periodic abbiano cancel in dispose
3. Aggiungere @pragma('vm:prefer-inline') a getter hot path
4. Considerare const constructor dove possibile

## Metriche Target Post-Ottimizzazione

| Metric | Current | Target | Improvement |
|--------|---------|--------|-------------|
| Main Thread | 40.8% | <20% | -50% |
| Memory Alloc | ~600ms | <300ms | -50% |
| GC Time | ~230ms | <100ms | -57% |
| Timer overhead | ~60 updates/min | ~4 updates/min | -93% |
| Frame time | 16-25ms | <16ms | 60fps locked |

## Quick Wins (Implementabili oggi)

1. **header_rest_timer.dart**: Consolidare 10 .select() in 3-4
2. **exercise_gif_widget.dart**: Pause animation quando fuori viewport
3. **workout_mini_bar.dart**: Rimuovere Timer.periodic locale
4. **exercise_list_item_orchestrator.dart**: Convertire 5 ref.watch() in .select()
5. **Aggiungere RepaintBoundary**: Attorno timer widget e GIF container

## File da Modificare (Ordinati per Impatto)

### Critici (giorno 1-2)
1. `/lib/features/timer/presentation/providers/unified_timer_provider.dart`
2. `/lib/features/workout/presentation/widgets/header_rest_timer.dart`
3. `/lib/features/workout/presentation/widgets/workout_mini_bar.dart`
4. `/lib/features/workout/presentation/widgets/exercise_gif_widget.dart`
5. `/lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart`

### Importanti (giorno 3-4)
6. `/lib/features/workout/presentation/workout_screen/widgets/workout_view.dart`
7. `/lib/features/workout/presentation/widgets/exercise_gif_fullscreen.dart`
8. `/lib/features/workout/presentation/providers/exercise_autocollapse_provider.dart`
9. `/lib/features/workout/presentation/widgets/superset_card.dart`
10. `/lib/shared/presentation/widgets/material_scroll_list.dart`

### Nice-to-have (giorno 5+)
11. Conversion massiva ref.watch() -> .select() (50+ file)
12. RegExp caching in validators
13. Audit dispose() generale
14. const constructor pass

## Testing Strategy

1. **Profiling**: Re-run iOS Instruments dopo ogni priority
2. **FPS Monitor**: Usa Flutter DevTools performance overlay
3. **Memory**: Track memory usage con 10+ esercizi
4. **Rebuild counter**: Aggiungere debugPrint counter in build()

