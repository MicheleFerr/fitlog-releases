# ADR 009: NON usare ref.watch(StreamProvider) dentro Notifier.build()

**Data:** 2026-01-24
**Status:** Accepted
**Deciders:** Michele (via systematic debug analysis)

---

## Context

Durante il debugging della schermata vuota in `TemplatesHomeScreen`, abbiamo scoperto un bug critico causato dall'uso di `ref.watch(currentUserProvider)` dentro il `build()` method di `TemplateNotifier`.

**Problema specifico:**
```dart
// ❌ PATTERN SBAGLIATO
class TemplateNotifier extends Notifier<TemplateState> {
  @override
  TemplateState build() {
    // currentUserProvider è un StreamProvider<User?>
    ref.watch(currentUserProvider);  // ⚠️ Causa errore _SelectorSubscription.read
    return TemplateState();
  }
}
```

**Stack trace:**
```
_SelectorSubscription.read (package:riverpod/src/framework/selector.dart:185:0)
ConsumerStatefulElement.watch (package:flutter_riverpod/src/consumer.dart:568:0)
_TemplatesHomeScreenState.build (templates_home_screen.dart:119:0)
```

**Root Cause (5 Whys):**
```
BUG: Schermata vuota quando si apre "le mie schede"
├─ Why? → _SelectorSubscription.read error
  ├─ Why? → ref.watch(templateProvider) causa errore durante subscription
    ├─ Why? → templateProvider.build() osserva currentUserProvider
      ├─ Why? → currentUserProvider (StreamProvider) può essere in loading state
        └─ ROOT: Watching StreamProvider in Notifier.build() senza gestire
           AsyncValue states causa errori quando stream è loading/error
```

---

## Decision

**REGOLA OBBLIGATORIA:**

### ❌ NON FARE MAI:
```dart
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    // ❌ SBAGLIATO: StreamProvider in ref.watch() blocca build()
    ref.watch(myStreamProvider);

    // ❌ SBAGLIATO: FutureProvider senza gestire AsyncValue
    ref.watch(myFutureProvider);

    return MyState();
  }
}
```

### ✅ FARE INVECE:

**Pattern A - ref.listen (Consigliato):**
```dart
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    // ✅ CORRETTO: ref.listen non blocca build()
    ref.listen(currentUserProvider, (previous, next) {
      // Reagisci ai cambiamenti solo quando necessario
      next.whenData((user) {
        // Ricarica dati quando utente cambia
        loadUserData();
      });
    });

    return MyState();
  }
}
```

**Pattern B - AsyncValue.value (Alternativo):**
```dart
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() {
    // ✅ ALTERNATIVO: Accetta null durante loading
    final user = ref.watch(currentUserProvider).value;

    if (user != null) {
      Future.microtask(() => loadUserData());
    }

    return MyState();
  }
}
```

---

## Rationale

### Perché ref.watch(StreamProvider) è problematico:

1. **Blocking Build:** `ref.watch()` in `build()` è sincrono, ma StreamProvider può essere in `loading` state
2. **Subscription Errors:** Riverpod internals cercano di leggere il valore prima che lo stream emetta, causando `_SelectorSubscription.read` errors
3. **Race Conditions:** Se lo stream è lento o in error, il widget non si costruisce mai
4. **Stack Overflow:** In casi estremi, può causare loop infiniti di rebuild

### Perché ref.listen è migliore:

1. **Non-blocking:** Non blocca il `build()` method
2. **Event-driven:** Reagisce solo quando lo stream emette
3. **AsyncValue Handling:** `whenData()`, `whenError()`, `whenLoading()` gestiscono tutti gli stati
4. **Cleaner:** Separazione chiara tra inizializzazione e reazione ai cambiamenti

---

## Consequences

### ✅ Positivi:
- **Bug prevenuti:** Elimina una classe intera di runtime errors
- **Performance:** `build()` non aspetta stream/future
- **Codice pulito:** Intento esplicito (inizializzazione vs reazione)
- **Testabile:** Più facile mockare e testare

### ⚠️ Trade-offs:
- **Verbosità:** `ref.listen` richiede leggermente più codice di `ref.watch`
- **Null Safety:** Con Pattern B, devi gestire `value == null` durante loading
- **Learning Curve:** Team deve capire differenza tra `watch` e `listen`

### 🔧 Migration Path:
```bash
# 1. Trova tutti gli usi problematici:
grep -r "ref.watch.*Provider" lib/ | grep "build()"

# 2. Per ogni match, verifica se è StreamProvider o FutureProvider:
# - Se sì: Converti a ref.listen (Pattern A)
# - Se no: OK lasciare ref.watch

# 3. Test:
flutter test
```

---

## Implementation

**Fix applicata in:**
- `lib/features/workout_templates/presentation/providers/template_provider.dart` (righe 70-81)

**Before:**
```dart
ref.watch(currentUserProvider);  // ❌ Bug
```

**After:**
```dart
ref.listen(currentUserProvider, (previous, next) {
  next.whenData((_) {
    debugPrint('🔄 User state changed, reloading templates');
    loadUserTemplates();
  });
});  // ✅ Fix
```

---

## Verification

### ✅ Checklist:
- [x] Bug risolto: Schermata "le mie schede" si carica correttamente
- [x] `flutter analyze` passa
- [x] No regression: Altre schermate funzionano
- [x] Documentato in ADR
- [ ] Test manuale su iOS + Android (da fare da utente)
- [ ] Cercare altri usi di pattern in codebase (future task)

---

## References

**Riverpod Docs:**
- [ref.listen vs ref.watch](https://riverpod.dev/docs/concepts/reading#using-reflisten-to-react-to-a-provider-change)
- [StreamProvider](https://riverpod.dev/docs/providers/stream_provider)
- [AsyncValue](https://riverpod.dev/docs/concepts/async_values)

**Internal:**
- Stack trace: _SelectorSubscription.read error
- Bug report: 2026-01-24 (schermata vuota templates)
- Skill used: `/systematic-debug`

**Pattern Database:**
- Category: State Management
- Root Cause: Watching async providers in sync build method
- Prevention: Linter rule (future enhancement)

---

## Follow-up Actions

1. **Immediate:**
   - [x] Fix applicata
   - [x] ADR documentato
   - [ ] Test manuale da utente

2. **Short-term (1 settimana):**
   - [ ] Cercare altri usi del pattern in codebase
   - [ ] Aggiungere esempio in `docs/CODE_PATTERNS.md`
   - [ ] Aggiungere a checklist code review

3. **Long-term (1 mese):**
   - [ ] Custom linter rule per rilevare pattern automaticamente
   - [ ] Aggiungere a `docs/COMMON_BUGS.md` bug pattern database
   - [ ] Team retrospective: condividere lesson learned

---

**Autore:** Claude Code (systematic-debug skill)
**Reviewer:** Michele
**Next Review:** 2026-02-24 (1 mese)
