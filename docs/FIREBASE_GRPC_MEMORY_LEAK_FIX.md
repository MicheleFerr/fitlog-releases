# 🔥 Firebase gRPC Memory Leak - Analisi e Fix

**Data**: 2026-02-10
**Status**: 🔴 Bug Confermato nel Firebase iOS SDK
**Impatto**: 🟡 Medio (10-15KB leak, lento ma contenuto)
**Versioni**: `cloud_firestore: ^6.0.3`, `firebase_core: ^4.2.0`

---

## 📊 Sintesi Problema

Durante profiling con Xcode Instruments (template: Leaks), sono stati rilevati **memory leak costanti** nel codice nativo iOS:

| Fonte Leak | % Totale | Componente |
|------------|----------|------------|
| **grpc** (gRPC C++) | ~60% | `CFStreamEndpointImpl::Connect` |
| **CFNetwork** (iOS) | ~35% | `SocketStream`, `NSInputStream/OutputStream` |
| **absl** (Abseil C++) | ~5% | `Status::Status` allocations |

**Dimensione**: ~10-15KB totale, ~1-2KB/minuto durante uso attivo
**Frequenza**: Leak continui durante connessioni Firestore attive

---

## ✅ VERIFICA INFORMAZIONI (Fonti Ufficiali)

### ✅ Corretto: Bug Confermato

**Issue GitHub FlutterFire:**
- [#10515](https://github.com/firebase/flutterfire/issues/10515) - **Flutter App Crashes on iOS with Memory Leak Error** (Open)
- [#4129](https://github.com/FirebaseExtended/flutterfire/issues/4129) - **Listener freeze UI thread or crash due to memory leak** (Open)
- [firebase-ios-sdk #12098](https://github.com/firebase/firebase-ios-sdk/issues/12098) - **gRPC 1.49.1 memory leak** (Closed, ma potrebbero esserci regressioni)

**Root Cause**: 500k+ linee di codice C++ da gRPC dependency nel Firebase iOS SDK.

### ✅ Corretto: Disabilitare Offline Persistence

**Fonte Ufficiale**: [Firebase Docs - Enable Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)

```dart
// ✅ Metodo CORRETTO per disabilitare persistence
await FirebaseFirestore.instance.setSettings(
  const Settings(
    persistenceEnabled: false, // iOS default: true
  ),
);
```

**IMPORTANTE**: Deve essere chiamato **PRIMA** di qualsiasi altra operazione Firestore!

### ❌ SBAGLIATO: terminate() e clearPersistence()

**⚠️ ATTENZIONE**: Nella risposta precedente ho suggerito di usare `terminate()` e `clearPersistence()` come workaround. **Questo è SBAGLIATO e causa crash!**

**Bug Confermato**: [Issue #17781](https://github.com/firebase/flutterfire/issues/17781)

**Problema**:
```dart
// ❌ NON FARE QUESTO - CAUSA CRASH!
await FirebaseFirestore.instance.terminate();
await FirebaseFirestore.instance.clearPersistence();
// ERROR: "Illegal state: The client has already been terminated"
```

**Root Cause del Bug**:
1. `terminate()` marca l'istanza come "terminated" ma **non la rimuove dalla cache**
2. `clearPersistence()` ritorna l'istanza cached (terminated)
3. Qualsiasi operazione successiva → crash immediato

**SOLUZIONE**: NON usare questi metodi in produzione!

---

## 🔬 Root Cause Analisi

### Perché i Leak Avvengono?

**gRPC Persistent Connections:**
```
App → Firestore SDK (Flutter/Dart)
    ↓
Firebase iOS SDK (Objective-C/Swift)
    ↓
gRPC C++ Library (500k+ LOC)
    ↓
CFNetwork (iOS native)
    ↓
Socket/Stream non completamente rilasciati
```

**Trigger Principali**:
1. **Offline Persistence** (abilitata di default su iOS)
   - Mantiene connessioni gRPC attive per sync
   - Background keep-alive sockets

2. **Firestore Listeners** (`.snapshots().listen()`)
   - Ogni listener = connessione gRPC persistente
   - Se non cancellati correttamente → leak

3. **Background Sync**
   - iOS mantiene socket attivi per ricevere updates
   - gRPC usa long-lived HTTP/2 connections

---

## 🛠️ Workaround SICURI e VERIFICATI

### Workaround 1: Test senza Offline Persistence

**File**: `lib/main_test_no_persistence.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ... altri import da main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 CRITICAL: Disabilita persistence PRIMA di usare Firestore
  await FirebaseFirestore.instance.setSettings(
    const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    ),
  );

  debugPrint('🔥 Firestore: Offline persistence DISABLED (test mode)');

  runApp(const MyApp());
}
```

**Come Testare**:
```bash
# 1. Run con target specifico
flutter run --target=lib/main_test_no_persistence.dart --release

# 2. Esegui workout session (15-20 min)
#    - Start workout
#    - Complete 5-6 sets
#    - Go background/foreground 3-4 volte
#    - Complete workout

# 3. Profile con Instruments (Leaks template)

# 4. Confronta con profiling precedente:
#    - Leak ridotti significativamente? → persistence era il problema
#    - No cambiamenti? → bug più profondo nel gRPC
```

---

### Workaround 2: Limita Firestore Listeners (Best Practice)

**Problema Attuale**: Listener sempre attivi consumano risorse.

**Fonte**: [FlutterFire Best Practices](https://firebase.flutter.dev/docs/firestore/usage/)

#### Pattern A: Polling invece di Listeners (quando real-time non è critico)

```dart
// ❌ EVITA: Listener sempre attivo
class MyRepository {
  Stream<UserProfile> watchProfile(String uid) {
    return _firestore
      .collection('users')
      .doc(uid)
      .snapshots() // Connessione gRPC persistente!
      .map((doc) => UserProfile.fromFirestore(doc));
  }
}

// ✅ MEGLIO: Polling on-demand
class MyRepository {
  Timer? _pollTimer;

  void startPolling(String uid, Function(UserProfile) onUpdate) {
    _pollTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      try {
        final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get(); // One-shot query, no persistent connection

        if (doc.exists) {
          onUpdate(UserProfile.fromFirestore(doc));
        }
      } catch (e) {
        debugPrint('⚠️ Poll failed: $e');
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
```

**Quando usare polling**:
- Dati che cambiano raramente (user profile, settings)
- Update ogni 5-10 minuti è accettabile
- Utente free (non premium)

**Quando usare listener**:
- Dati real-time critici (chat, live workout)
- Utente premium con sync abilitato

---

#### Pattern B: Lazy Listeners (attiva solo quando necessario)

```dart
class OptimizedRepository {
  StreamSubscription? _activeListener;
  bool _listenerActive = false;

  // Attiva listener solo quando screen è visibile
  void startListening(String uid) {
    if (_listenerActive) return;

    _activeListener = _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .listen((snapshot) {
        // Handle update
      });

    _listenerActive = true;
    debugPrint('✅ Firestore listener started');
  }

  // Disattiva quando screen è nascosta
  void stopListening() {
    _activeListener?.cancel();
    _activeListener = null;
    _listenerActive = false;
    debugPrint('🛑 Firestore listener stopped');
  }

  @override
  void dispose() {
    stopListening(); // CRITICAL: Always cleanup!
    super.dispose();
  }
}
```

**Integration con Riverpod**:
```dart
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  StreamSubscription? _subscription;

  @override
  FutureOr<UserProfile?> build() async {
    // Setup listener
    final uid = ref.watch(authProvider).value?.uid;
    if (uid == null) return null;

    _subscription = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.exists) {
          state = AsyncValue.data(UserProfile.fromFirestore(snapshot));
        }
      });

    // ✅ CRITICAL: Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    // Initial fetch
    final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

    return doc.exists ? UserProfile.fromFirestore(doc) : null;
  }
}
```

---

### Workaround 3: Batch Queries (riduci numero di connessioni)

```dart
// ❌ EVITA: Multiple queries separate
final workout1 = await _firestore.collection('workouts').doc(id1).get();
final workout2 = await _firestore.collection('workouts').doc(id2).get();
final workout3 = await _firestore.collection('workouts').doc(id3).get();
// 3 connessioni HTTP/2 separate!

// ✅ MEGLIO: Batch read
final batch = await _firestore
  .collection('workouts')
  .where(FieldPath.documentId, whereIn: [id1, id2, id3])
  .get();
// 1 sola connessione!
```

---

## 📋 Testing Plan

### Phase 1: Verifica Persistence come Causa (2-3 ore)

**Goal**: Determinare se offline persistence è la root cause primaria.

1. **Setup**:
   - Crea `lib/main_test_no_persistence.dart` (vedi sopra)
   - Build release mode

2. **Baseline Profiling** (prima di disabilitare persistence):
   ```bash
   # Con persistence abilitata (main.dart normale)
   flutter run --release
   # → Profile con Instruments (Leaks) → Save come baseline.trace
   ```

3. **Test Profiling** (dopo disabilitare persistence):
   ```bash
   # Con persistence disabilitata
   flutter run --target=lib/main_test_no_persistence.dart --release
   # → Profile con Instruments (Leaks) → Save come test_no_persist.trace
   ```

4. **Scenario Test** (identico per entrambi):
   - Login
   - Start workout (4-5 esercizi)
   - Complete 10-12 set totali
   - Background app 3 volte (30s each)
   - Navigate: Analytics → History → Settings
   - Complete workout
   - Durata totale: ~20 minuti

5. **Confronta Risultati**:
   ```
   Baseline (persistence ON):  ~10-15KB leak
   Test (persistence OFF):     ~X KB leak

   Se X < 5KB → persistence è il problema principale ✅
   Se X ≈ 10-15KB → bug più profondo in gRPC ⚠️
   ```

---

### Phase 2: Verifica Listener Management (1-2 ore)

**Goal**: Confermare che tutti i listener sono cancellati correttamente.

1. **Audit Già Completato** ✅:
   - 5 file con StreamSubscription trovati
   - Tutti hanno `.cancel()` in dispose
   - Pattern corretti (Riverpod `ref.onDispose()`, manual `dispose()`)

2. **Runtime Verification**:
   ```dart
   // Aggiungi log temporanei nei repository
   void dispose() {
     debugPrint('🧹 [CLEANUP] Canceling ${_activeListeners.length} listeners');
     for (final sub in _activeListeners.values) {
       sub.cancel();
     }
     _activeListeners.clear();
     debugPrint('✅ [CLEANUP] All listeners canceled');
   }
   ```

3. **Test con Hot Restart**:
   - Start app → navigazione normale
   - Hot restart (⌘R)
   - Check logs: tutti i "CLEANUP" devono apparire
   - Se mancano → listener non cancellati!

---

### Phase 3: Implementa Lazy Listeners (se Phase 1 non risolve)

**Se persistence OFF non riduce leak:**

1. Converti listener sempre-attivi → lazy pattern
2. Priority:
   - ✅ High: `analytics_repository_impl.dart` (Map di listener)
   - ✅ High: `optimized_base_hybrid_repository.dart` (profile listener)
   - 🟡 Medium: Altri listener in `workout_session_la_provider.dart`

3. Test again con Instruments

---

## 🎯 Decisione Finale (Dopo Testing)

### Scenario A: Persistence è il Problema

**Se test senza persistence riduce leak >50%:**

```dart
// Decisione: Disabilita persistence in produzione (iOS only)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // iOS: Disabilita persistence per prevenire leak
  if (Platform.isIOS) {
    await FirebaseFirestore.instance.setSettings(
      const Settings(persistenceEnabled: false),
    );
    debugPrint('🍎 iOS: Firestore offline persistence DISABLED');
  }

  runApp(const MyApp());
}
```

**Trade-off**:
- ✅ Pro: Elimina/riduce memory leak
- ✅ Pro: App più leggera (no local cache)
- ❌ Con: No offline support (serve connessione)
- ❌ Con: Query più lente (no cache hit)

**Mitigazione**:
- Hive cache per dati critici (workout drafts, user settings)
- Connectivity check prima di operazioni Firestore
- User feedback chiaro quando offline

---

### Scenario B: Bug gRPC Intrinseco

**Se test senza persistence NON riduce leak:**

1. **Report Bug a Firebase**:
   - Commenta su [Issue #10515](https://github.com/firebase/flutterfire/issues/10515)
   - Allega Instruments trace file
   - Specifica versioni:
     - `cloud_firestore: ^6.0.3`
     - `firebase_core: ^4.2.0`
     - iOS 17.2, iPhone 12

2. **Implementa Lazy Listeners** (vedi Workaround 2)
   - Attiva listener solo quando necessario
   - Disattiva quando screen nascosta

3. **Monitor Leak Growth**:
   - Add crash reporting (Crashlytics)
   - Track memory usage metrics
   - Alert se app > 500MB RAM

4. **Fallback Plan**:
   - Se leak causa crash frequenti → disabilita Firestore sync temporaneamente
   - Usa solo Hive per storage locale
   - Sync manuale via Cloud Functions API

---

## 📚 Best Practices Riassunte

### ✅ DO: Pattern Corretti

1. **Sempre cancella subscription**:
   ```dart
   ref.onDispose(() => _subscription?.cancel());
   ```

2. **Usa polling quando possibile** (invece di listener sempre attivi)

3. **Batch operations** (riduce numero connessioni)

4. **Test memory con Instruments** regolarmente

5. **Monitor crash rate** (Crashlytics)

### ❌ DON'T: Anti-Pattern

1. **MAI usare `terminate()` e `clearPersistence()` insieme** → causa crash

2. **Non creare listener nel widget** → usa Provider/BLoC

3. **Non dimenticare dispose** → memory leak garantito

4. **Non assumere offline = no leak** → gRPC può avere leak anche online

---

## 📖 Fonti Ufficiali

**Firebase Documentation**:
- [Enable Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [FlutterFire Usage Guide](https://firebase.flutter.dev/docs/firestore/usage/)

**GitHub Issues (Confermati)**:
- [#10515 - Flutter App Crashes on iOS with Memory Leak](https://github.com/firebase/flutterfire/issues/10515)
- [#4129 - Listener freeze UI thread or crash](https://github.com/FirebaseExtended/flutterfire/issues/4129)
- [#17781 - terminate() caching bug](https://github.com/firebase/flutterfire/issues/17781)
- [firebase-ios-sdk #12098 - gRPC 1.49.1 memory leak](https://github.com/firebase/firebase-ios-sdk/issues/12098)

**Best Practices**:
- [FlutterFire Listener Best Practices](https://moldstud.com/articles/p-best-practices-for-using-cloud-firestore-in-flutter-applications)
- [Stop listening to snapshots](https://newbe.dev/stop-listening-to-snapshot-updates-in-cloud-firestore-in-flutter)
- [Unsubscribe from Firestore watch](https://cloud.google.com/firestore/docs/samples/firestore-listen-detach)

---

## 🚀 Next Steps (Priorità)

1. **Immediate** (oggi):
   - [ ] Crea `main_test_no_persistence.dart`
   - [ ] Esegui Phase 1 testing (2-3 ore)
   - [ ] Confronta baseline vs test results

2. **Short-term** (questa settimana):
   - [ ] Se Phase 1 positivo → deploy con `persistenceEnabled: false` su TestFlight
   - [ ] Se Phase 1 negativo → implementa Lazy Listeners (Workaround 2)
   - [ ] Monitor crash rate su Crashlytics

3. **Long-term** (prossimo mese):
   - [ ] Se bug persiste → report dettagliato a Firebase team
   - [ ] Considera alternative (GraphQL, REST API custom, etc.)
   - [ ] Valuta migrazione a alternative (AppWrite, Supabase)

---

**Last Updated**: 2026-02-10
**Next Review**: Dopo Phase 1 testing
**Owner**: @michele
