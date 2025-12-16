# 🚀 FIRESTORE OPTIMIZATION - TIER 1 IMPLEMENTATION

> **Priorità**: 🔴 CRITICAL - Implementare SUBITO
>
> **Tempo Stimato**: 2 ore totali
>
> **Risparmio**: ~65,000 reads/giorno (con 1000 utenti)

---

## 📋 OTTIMIZZAZIONE #1: CACHE USER PROFILE

**File**: `/Users/michele/gymbro_flutter_new/lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart`

**Linee**: 63-74

**Problema**: `_loadUserProfile()` chiamato ad OGNI `authStateChanges()` event
- Cambio app foreground/background = auth event
- Network reconnect = auth event
- **Risultato**: 50-100 reads EXTRA per utente/giorno

### Implementazione

```dart
// LINEA 63-74 (PRIMA)
void _initUserProfileListener() {
  _userProfileSubscription = _auth.authStateChanges().listen((user) async {
    if (_isDisposed) return;

    if (user != null) {
      await _loadUserProfile(user.uid); // ❌ CHIAMATO SEMPRE
    } else {
      _cachedUserProfile = null;
    }
  });
}

// LINEA 63-74 (DOPO)
void _initUserProfileListener() {
  _userProfileSubscription = _auth.authStateChanges().listen((user) async {
    if (_isDisposed) return;

    if (user != null) {
      // ✅ CARICA SOLO SE CACHE VUOTA O USER DIVERSO
      if (_cachedUserProfile == null || _cachedUserProfile!.userId != user.uid) {
        await _loadUserProfile(user.uid);
      }
    } else {
      _cachedUserProfile = null;
    }
  });
}
```

### Test

```dart
// Test che cache funzioni correttamente
test('User profile caricato una sola volta', () async {
  final repo = HybridWorkoutRepositoryImpl(...);

  // Primo caricamento
  await repo._loadUserProfile('user123');
  expect(firestoreReadCount, 1);

  // Trigger auth change (stesso user)
  authController.add(mockUser);
  await Future.delayed(Duration(milliseconds: 100));

  // NO nuovo caricamento
  expect(firestoreReadCount, 1); // ✅ Ancora 1!
});
```

**Risparmio**: **95% profile reads** (~47,500 reads/giorno con 1000 utenti)

---

## 📋 OTTIMIZZAZIONE #2: REMOVE FIRESTORE CONNECTIVITY CHECK

**File**: `/Users/michele/gymbro_flutter_new/lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart`

**Linee**: 111-122

**Problema**: `hasConnection` fa query Firestore per check connessione
- Chiamato prima di ogni operazione cloud
- 10-20 volte/giorno per utente
- **Risultato**: +15,000 reads/giorno (1000 utenti)

### Implementazione

**Step 1**: Aggiungi dependency in `pubspec.yaml`

```yaml
dependencies:
  connectivity_plus: ^6.0.5  # ✅ Aggiungere
```

**Step 2**: Aggiorna imports (LINEA 18)

```dart
// PRIMA (LINEA 18)
import 'package:flutter/foundation.dart';

// DOPO (LINEA 18)
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // ✅ AGGIUNGERE
```

**Step 3**: Sostituisci metodo (LINEA 111-122)

```dart
// LINEA 111-122 (PRIMA)
Future<bool> get hasConnection async {
  try {
    // ❌ QUERY FIRESTORE = 1 READ
    await FirebaseFirestore.instance
        .collection('_connectivity_check')
        .doc('test')
        .get(const GetOptions(source: Source.server));
    return true;
  } catch (_) {
    return false;
  }
}

// LINEA 111-122 (DOPO)
Future<bool> get hasConnection async {
  try {
    // ✅ USA CONNECTIVITY PLUS (NO FIRESTORE)
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((result) =>
      result != ConnectivityResult.none
    );
  } catch (_) {
    return false; // Fallback safe
  }
}
```

### Test

```dart
test('Connectivity check non usa Firestore', () async {
  final repo = HybridWorkoutRepositoryImpl(...);

  // Check connessione 100 volte
  for (int i = 0; i < 100; i++) {
    await repo.hasConnection;
  }

  // Zero query Firestore
  expect(firestoreReadCount, 0); // ✅ Zero reads!
});
```

**Risparmio**: **~15,000 reads/giorno** (1000 utenti × 15 checks)

---

## 📋 OTTIMIZZAZIONE #3: CACHE QUOTA LOCALLY

**File**: `/Users/michele/gymbro_flutter_new/lib/features/workout/data/repositories/firebase_workout_template_repository.dart`

**Linee**: 704-757

**Problema**: `_checkAndUpdateQuota()` read+write ad OGNI template save
- 2 ops (read + write) per template
- 1000 utenti × 10 template = **20,000 ops**

### Implementazione

**Step 1**: Aggiungi classe Quota Cache (DOPO LINEA 10)

```dart
// DOPO LINEA 10 (dopo imports)
/// Cache locale per template quota
class TemplateQuotaCache {
  const TemplateQuotaCache({
    required this.maxPrivateTemplates,
    required this.maxPublicTemplates,
    required this.usedPrivateTemplates,
    required this.usedPublicTemplates,
    required this.lastUpdated,
  });

  factory TemplateQuotaCache.fromJson(Map<String, dynamic> json) {
    return TemplateQuotaCache(
      maxPrivateTemplates: json['maxPrivateTemplates'] ?? 10,
      maxPublicTemplates: json['maxPublicTemplates'] ?? 2,
      usedPrivateTemplates: json['usedPrivateTemplates'] ?? 0,
      usedPublicTemplates: json['usedPublicTemplates'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
  final int maxPrivateTemplates;
  final int maxPublicTemplates;
  final int usedPrivateTemplates;
  final int usedPublicTemplates;
  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
    'maxPrivateTemplates': maxPrivateTemplates,
    'maxPublicTemplates': maxPublicTemplates,
    'usedPrivateTemplates': usedPrivateTemplates,
    'usedPublicTemplates': usedPublicTemplates,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  /// Cache valida se < 1 ora
  bool get isValid =>
    DateTime.now().difference(lastUpdated).inHours < 1;

  /// Ha spazio disponibile
  bool hasSpace(bool isPublic) {
    if (isPublic) {
      return usedPublicTemplates < maxPublicTemplates;
    }
    return usedPrivateTemplates < maxPrivateTemplates;
  }

  /// Incrementa counter locale
  TemplateQuotaCache increment(bool isPublic) {
    return TemplateQuotaCache(
      maxPrivateTemplates: maxPrivateTemplates,
      maxPublicTemplates: maxPublicTemplates,
      usedPrivateTemplates: isPublic
        ? usedPrivateTemplates
        : usedPrivateTemplates + 1,
      usedPublicTemplates: isPublic
        ? usedPublicTemplates + 1
        : usedPublicTemplates,
      lastUpdated: DateTime.now(),
    );
  }
}
```

**Step 2**: Aggiungi cache key (LINEA 18 - dopo altre costanti)

```dart
// DOPO LINEA 18
static const String _quotaCacheKey = 'template_quota_cache';
```

**Step 3**: Aggiungi metodi cache (DOPO LINEA 934)

```dart
// DOPO LINEA 934 (dopo _migrateTemplatesIsCustomField)

/// Get cached quota (local)
Future<TemplateQuotaCache?> _getCachedQuota(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${_quotaCacheKey}_$userId';
    final cacheJson = prefs.getString(cacheKey);

    if (cacheJson == null) return null;

    final cache = TemplateQuotaCache.fromJson(json.decode(cacheJson));
    return cache.isValid ? cache : null;
  } catch (e) {
    return null; // Cache invalida
  }
}

/// Save quota cache (local)
Future<void> _saveCachedQuota(String userId, TemplateQuotaCache cache) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${_quotaCacheKey}_$userId';
    await prefs.setString(cacheKey, json.encode(cache.toJson()));
  } catch (e) {
    // Ignore cache errors
  }
}

/// Clear quota cache (local)
Future<void> _clearCachedQuota(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '${_quotaCacheKey}_$userId';
    await prefs.remove(cacheKey);
  } catch (e) {
    // Ignore
  }
}
```

**Step 4**: Sostituisci `_checkAndUpdateQuota()` (LINEA 704-757)

```dart
// LINEA 704-757 (PRIMA)
Future<void> _checkAndUpdateQuota(bool isPublic) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) return;

  // ❌ SEMPRE query Firestore (1 read + 1 write)
  final userDoc = await rateLimitedRead(() async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return doc;
  });

  final userData = userDoc.data()!;
  final quotaData = userData['templateQuota'] as Map<String, dynamic>?;

  // ... resto logica

  await rateLimitedWrite(() async {
    await _firestore.collection('users').doc(userId).update({
      'templateQuota.usedPrivateTemplates': ...,
      'templateQuota.usedPublicTemplates': ...,
    });
  });
}

// LINEA 704-757 (DOPO)
Future<void> _checkAndUpdateQuota(bool isPublic) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) return;

  // ✅ PROVA CACHE PRIMA
  var cachedQuota = await _getCachedQuota(userId);

  // Se cache valida E ha spazio, usa cache
  if (cachedQuota != null && cachedQuota.hasSpace(isPublic)) {
    // Incrementa counter locale
    final updated = cachedQuota.increment(isPublic);
    await _saveCachedQuota(userId, updated);
    return; // ✅ SKIP FIRESTORE!
  }

  // Cache invalida o quota esaurita → Query Firestore
  final userDoc = await rateLimitedRead(() async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return doc;
  });

  final userData = userDoc.data()!;
  final quotaData = userData['templateQuota'] as Map<String, dynamic>?;

  if (quotaData == null) {
    // Initialize quota (rate-limited write)
    await rateLimitedWrite(() async {
      await _firestore.collection('users').doc(userId).update({
        'accountTier': 'free',
        'templateQuota': {
          'maxPrivateTemplates': 10,
          'maxPublicTemplates': 2,
          'usedPrivateTemplates': 0,
          'usedPublicTemplates': 0,
        }
      });
    });

    // Cache nuova quota
    final newCache = TemplateQuotaCache(
      maxPrivateTemplates: 10,
      maxPublicTemplates: 2,
      usedPrivateTemplates: 0,
      usedPublicTemplates: 0,
      lastUpdated: DateTime.now(),
    );
    await _saveCachedQuota(userId, newCache);
    return;
  }

  // Check quota limits
  final maxPrivate = quotaData['maxPrivateTemplates'] ?? 10;
  final maxPublic = quotaData['maxPublicTemplates'] ?? 2;
  final usedPrivate = quotaData['usedPrivateTemplates'] ?? 0;
  final usedPublic = quotaData['usedPublicTemplates'] ?? 0;

  if (isPublic && usedPublic >= maxPublic) {
    throw Exception('Public template quota exceeded. Maximum allowed: $maxPublic');
  }

  if (!isPublic && usedPrivate >= maxPrivate) {
    throw Exception('Private template quota exceeded. Maximum allowed: $maxPrivate');
  }

  // Update quota count (rate-limited write)
  await rateLimitedWrite(() async {
    await _firestore.collection('users').doc(userId).update({
      'templateQuota.usedPrivateTemplates': isPublic ? usedPrivate : usedPrivate + 1,
      'templateQuota.usedPublicTemplates': isPublic ? usedPublic + 1 : usedPublic,
    });
  });

  // ✅ AGGIORNA CACHE
  final updatedCache = TemplateQuotaCache(
    maxPrivateTemplates: maxPrivate,
    maxPublicTemplates: maxPublic,
    usedPrivateTemplates: isPublic ? usedPrivate : usedPrivate + 1,
    usedPublicTemplates: isPublic ? usedPublic + 1 : usedPublic,
    lastUpdated: DateTime.now(),
  );
  await _saveCachedQuota(userId, updatedCache);
}
```

**Step 5**: Invalida cache su delete (LINEA 280-311)

```dart
// AGGIUNGI DOPO LINEA 308 (in deleteTemplate, dopo await _deleteTemplateFromCloud)
await _clearCachedQuota(_auth.currentUser!.uid); // ✅ Invalida cache
```

### Test

```dart
test('Quota check usa cache', () async {
  final repo = FirebaseWorkoutTemplateRepository();

  // Primo save: 1 read + 1 write (carica quota)
  await repo.saveTemplate(template1);
  expect(firestoreReadCount, 1);
  expect(firestoreWriteCount, 2); // 1 template + 1 quota

  // Secondo save: USA CACHE (no Firestore)
  await repo.saveTemplate(template2);
  expect(firestoreReadCount, 1); // ✅ Ancora 1!
  expect(firestoreWriteCount, 3); // +1 solo template

  // 10 template totali
  for (int i = 3; i <= 10; i++) {
    await repo.saveTemplate(createTemplate(i));
  }

  // Solo 1 quota check iniziale
  expect(firestoreReadCount, 1); // ✅ Solo prima volta!
});
```

**Risparmio**: **90% quota ops** (~18,000 ops con 1000 utenti)

---

## ✅ CHECKLIST IMPLEMENTAZIONE

### Pre-Implementation
- [ ] Backup codice attuale
- [ ] Review file modificati
- [ ] Test locali funzionanti

### Implementazione
- [ ] ✅ Opt #1: Cache User Profile (30 min)
- [ ] ✅ Opt #2: Remove Firestore Connectivity (30 min)
- [ ] ✅ Opt #3: Cache Quota Locally (60 min)

### Post-Implementation
- [ ] Test unitari passano
- [ ] Test manuale in app
- [ ] `flutter analyze` senza errori
- [ ] Commit con messaggio descrittivo

### Monitoring (Prima Settimana)
- [ ] Monitora Firebase Console (Usage tab)
- [ ] Verifica riduzione reads
- [ ] Controlla errori Crashlytics
- [ ] Test con utente reale

---

## 📊 RISPARMIO ATTESO

| Ottimizzazione | Risparmio/Giorno (1000 utenti) |
|----------------|---------------------------------|
| Cache User Profile | ~47,500 reads |
| Connectivity Check | ~15,000 reads |
| Cache Quota | ~600 ops |
| **TOTALE** | **~65,000 ops/giorno** |

**Impatto Economico**:
- Prima: Rischio esaurire tier gratuito
- Dopo: ~5% tier gratuito (sicurezza 20×)
- **Risparmio**: $0 → $0 (ma scala a 5000+ utenti)

---

## 🚨 NOTE IMPORTANTI

### Breaking Changes
- ❌ Nessuna breaking change
- ✅ Backward compatible

### Migration
- ❌ Non necessaria
- ✅ Funziona con dati esistenti

### Rollback
- ✅ Git revert immediato
- ✅ Nessun dato compromesso

### Dependencies
- ➕ `connectivity_plus: ^6.0.5` (unica nuova dependency)

---

## 🎯 QUANDO IMPLEMENTARE

**SUBITO** se:
- Hai >100 utenti attivi
- Pianifichi crescita rapida
- Vuoi evitare costi futuri

**OPZIONALE** se:
- Sei in beta chiusa (<10 utenti)
- Solo testing interno

**RACCOMANDAZIONE**: **Implementa comunque** - 2 ore investimento vs risparmio infinito.

---

**Generato**: 2025-01-08
**Tempo Stimato**: 2 ore totali
**Risparmio**: 95% operazioni ridondanti
**Priorità**: 🔴 CRITICAL
