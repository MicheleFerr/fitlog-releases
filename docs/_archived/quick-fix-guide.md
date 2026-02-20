# 🤖 Quick Reference per Claude Code - Fix Errori Flutter

## ⚡ Comandi Rapidi per Testing

```bash
# Monitor log in tempo reale
flutter run --verbose

# Restart veloce dopo modifica
r  # Hot reload
R  # Hot restart

# Analisi statica codice
flutter analyze

# Clean completo
flutter clean && flutter pub get

# DevTools per debugging
flutter run --profile
# Poi apri DevTools dal link mostrato
```

---

## 🎯 I 3 Fix CRITICI da Fare SUBITO

### 1️⃣ Provider Modification Error (PIÙ URGENTE)

**Cerca questo pattern nel codice:**
```dart
// ❌ SBAGLIATO - Cerca TUTTI questi casi
@override
Widget build(BuildContext context) {
  ref.read(provider.notifier).update(...); // ❌ MAI
}

@override
void initState() {
  super.initState();
  ref.read(provider.notifier).update(...); // ❌ MAI
}
```

**Sostituisci con:**
```dart
// ✅ CORRETTO
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(provider.notifier).update(...); // ✅ OK
  });
}

// OPPURE (meglio):
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(provider.notifier).update(...); // ✅ OK
  });
}
```

**File da controllare:**
- Tutti i widget che usano `ExerciseSuggestionsNotifier`
- Cerca pattern: `grep -r "ref.read.*notifier" lib/`

---

### 2️⃣ RenderFlex Overflow (URGENTE)

**File specifico:** `lib/features/home/presentation/widgets/secondary_actions.dart:498`

**Fix veloce:**
```dart
// Trova la Column alla linea 498 e avvolgila così:

// ❌ PRIMA:
Column(
  children: [...],
)

// ✅ DOPO:
SingleChildScrollView(
  child: Column(
    children: [...],
  ),
)
```

**Oppure usa Expanded:**
```dart
Column(
  children: [
    FixedWidget(),
    Expanded(  // ✅ Si adatta automaticamente
      child: FlexibleWidget(),
    ),
    FixedWidget(),
  ],
)
```

---

### 3️⃣ GIF Loading 100+ volte (CRITICO per Performance)

**Trova il widget che carica GIF:**
```bash
grep -r "ExerciseGifWidget" lib/
grep -r "CachedNetworkImage" lib/
```

**Aggiungi AutomaticKeepAliveClientMixin:**
```dart
// ✅ SOLUZIONE COMPLETA
class ExerciseGifWidget extends StatefulWidget {
  final String gifUrl;
  final String exerciseId;
  
  const ExerciseGifWidget({
    Key? key,
    required this.gifUrl,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ExerciseGifWidget> createState() => _ExerciseGifWidgetState();
}

class _ExerciseGifWidgetState extends State<ExerciseGifWidget> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;  // ✅ CHIAVE: Previene rebuild
  
  @override
  Widget build(BuildContext context) {
    super.build(context);  // ✅ IMPORTANTE: chiamare super.build()
    
    return CachedNetworkImage(
      imageUrl: widget.gifUrl,
      cacheKey: 'exercise_${widget.exerciseId}',  // ✅ Key univoca
      memCacheHeight: 400,
      memCacheWidth: 400,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
```

---

## 🟡 Fix Secondari (Fare dopo i critici)

### WCAG Colors - Fix Theme

**File da modificare:** `lib/core/theme/app_theme.dart` (o dove definisci ColorScheme)

```dart
// ✅ Sostituisci con questi valori testati per accessibilità:

ColorScheme.light(
  primary: Color(0xFF6750A4),
  onPrimary: Color(0xFFFFFFFF),  // Bianco puro
  secondary: Color(0xFF4A4458),  // ✅ Più scuro
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFC0281E),  // ✅ Più scuro
  onError: Color(0xFFFFFFFF),
)

ColorScheme.dark(
  primary: Color(0xFFD0BCFF),
  onPrimary: Color(0xFF381E72),  // ✅ Contrasto OK
  secondary: Color(0xFFCCC2DC),
  onSecondary: Color(0xFF332D41),  // ✅ Contrasto OK
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),  // ✅ Contrasto OK
)
```

**Verifica contrasto:** https://webaim.org/resources/contrastchecker/

---

### Analytics Boolean Error

**Cerca questi eventi:**
```bash
grep -r "pattern_detection" lib/
grep -r "suggestion_shown" lib/
grep -r "pattern_found" lib/
grep -r "has_pattern" lib/
```

**Fix veloce:**
```dart
// ❌ PRIMA:
analytics.logEvent(
  name: 'pattern_detection',
  parameters: {
    'pattern_found': false,  // ❌ Boolean non accettato
    'has_pattern': true,     // ❌ Boolean non accettato
  },
);

// ✅ DOPO:
analytics.logEvent(
  name: 'pattern_detection',
  parameters: {
    'pattern_found': 0,  // ✅ 0 o 1 invece di false/true
    'has_pattern': 1,    // ✅ Oppure "false"/"true" come string
  },
);
```

**Helper da creare (CONSIGLIATO):**
```dart
// File: lib/core/utils/analytics_helper.dart

class AnalyticsHelper {
  static Map<String, dynamic> sanitize(Map<String, dynamic> params) {
    return params.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0);  // ✅ bool → int
      }
      return MapEntry(key, value);
    });
  }
}

// Uso ovunque:
analytics.logEvent(
  name: 'pattern_detection',
  parameters: AnalyticsHelper.sanitize({
    'pattern_found': false,  // Automaticamente → 0
  }),
);
```

---

## 📊 Come Verificare che i Fix Funzionano

### Dopo fix Provider:
```bash
flutter run
# Nei log NON deve comparire:
# ❌ "Tried to modify a provider while the widget tree was building"
# ❌ "StateNotifier Instance of 'ExerciseSuggestionsNotifier' threw"
```

### Dopo fix RenderFlex:
```bash
flutter run
# Nei log NON deve comparire:
# ❌ "A RenderFlex overflowed by X pixels"
# ✅ UI non deve avere strisce gialle/nere
```

### Dopo fix GIF Loading:
```bash
flutter run
# Nei log cerca:
# ✅ "⏳ Loading GIF for Stacco da Terra" dovrebbe apparire MAX 2 volte
# ❌ Se appare 10+ volte → Fix non applicato correttamente
```

### Dopo fix WCAG:
```bash
flutter run
# Nei log NON deve comparire:
# ❌ "ColorScheme has X WCAG violations"
```

### Dopo fix Analytics:
```bash
flutter run
# Nei log NON deve comparire:
# ❌ "Analytics error (pattern_detection)"
# ❌ "'string' OR 'number' must be set"
```

---

## 🔍 Comandi per Trovare Codice Problematico

```bash
# Provider modifications
grep -rn "ref.read.*notifier.*\." lib/ | grep -v "onPressed"

# RenderFlex overflow locations
grep -rn "Column" lib/features/home/presentation/widgets/

# GIF widgets
grep -rn "CachedNetworkImage" lib/
grep -rn "ExerciseGifWidget" lib/

# Analytics events
grep -rn "logEvent" lib/ | grep -E "(pattern|suggestion)"

# Theme definitions
find lib/ -name "*theme*"
```

---

## ⚠️ Cosa NON Fare

❌ NON aggiornare tutte le dipendenze insieme
❌ NON modificare provider in build/initState senza Future.microtask
❌ NON ignorare warning di RenderFlex overflow
❌ NON usare boolean in parametri Firebase Analytics
❌ NON dimenticare di testare dopo ogni modifica

---

## ✅ Workflow Consigliato

1. **Fix Provider Error** → Test → Git commit
2. **Fix RenderFlex** → Test → Git commit
3. **Fix GIF Loading** → Test → Git commit
4. **Fix WCAG Colors** → Test → Git commit
5. **Fix Analytics** → Test → Git commit

**Tra ogni step:**
```bash
flutter run
# Verifica log
# Se tutto OK:
git add .
git commit -m "Fix [descrizione problema]"
# Se errori:
git restore .
```

---

## 🆘 Se Qualcosa Va Storto

```bash
# Rollback all'ultimo commit funzionante
git log --oneline
git reset --hard <commit-hash>

# Clean completo
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..
flutter pub get
flutter run

# Se persiste, chiedi aiuto con:
flutter doctor -v
flutter analyze
# E copia output completo
```

---

## 📈 Priorità Fix (in ordine)

1. 🔴 **Provider Modification** - CRITICO (causa crash)
2. 🔴 **RenderFlex Overflow** - ALTA (UI rotta)
3. 🔴 **GIF Loading** - ALTA (performance)
4. 🟡 **WCAG Colors** - MEDIA (accessibilità)
5. 🟡 **Analytics Types** - MEDIA (tracking rotto)
6. 🟢 **Dependencies** - BASSA (può aspettare)

---

## 💾 File da Modificare (Summary)

1. **Provider Error**: Ogni widget che usa `ref.read()` in lifecycle
2. **RenderFlex**: `lib/features/home/presentation/widgets/secondary_actions.dart:498`
3. **GIF Loading**: File che contiene `ExerciseGifWidget` o widget simile
4. **WCAG**: `lib/core/theme/app_theme.dart` o file tema
5. **Analytics**: File che contiene `analytics.logEvent()` per pattern/suggestion

**Trova file velocemente:**
```bash
# Provider
find lib/ -type f -name "*.dart" -exec grep -l "ExerciseSuggestionsNotifier" {} \;

# Theme
find lib/ -type f -name "*theme*.dart"

# Analytics
find lib/ -type f -name "*.dart" -exec grep -l "pattern_detection\|suggestion_shown" {} \;
```

---

**Fine Quick Reference**
