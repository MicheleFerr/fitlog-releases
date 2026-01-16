# FitLog Architecture: Current vs. Ideal

**Last Updated**: 2026-01-02
**Status**: 🟡 Architecture Refactoring Needed

---

## Current Architecture Issues

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Providers│  │ Screens  │  │ Widgets  │  │  l10n    │   │
│  └────▲─────┘  └──────────┘  └──────────┘  └────▲─────┘   │
└───────┼──────────────────────────────────────────┼─────────┘
        │                                          │
        │                                          │ ❌ VIOLATION
        │                                          │ Domain imports
┌───────┼──────────────────────────────────────────┼─────────┐
│       │              DOMAIN LAYER                │         │
│  ┌────┴─────┐  ┌──────────┐  ┌──────────┐  ┌────┴─────┐  │
│  │ Entities │  │Use Cases │  │ Services │  │Repository│  │
│  │          │  │          │  │          │  │Interfaces│  │
│  └──────────┘  └────▲─────┘  └────▲─────┘  └────▲─────┘  │
└─────────────────────┼──────────────┼──────────────┼────────┘
                      │              │              │
                      │              │              │ ❌ VIOLATION
                      │              │ ❌ VIOLATION │ Most repos skip
┌─────────────────────┼──────────────┼──────────────┼────────┐
│                     │     DATA LAYER               │        │
│  ┌──────────────────┴──────┐  ┌───────────────────┴─────┐  │
│  │ ❌ Only 3 repositories  │  │ ❌ Only 11 features     │  │
│  │    use BaseHybrid       │  │    have DataSources     │  │
│  │    Repository           │  │                         │  │
│  └─────────────────────────┘  └─────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Most repos directly use FirebaseFirestore ❌        │   │
│  │ (No caching, no offline support)                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Ideal Clean Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Providers│  │ Screens  │  │ Widgets  │  │  l10n    │   │
│  └────▲─────┘  └──────────┘  └──────────┘  └──────────┘   │
└───────┼────────────────────────────────────────────────────┘
        │ ✅ Only imports from domain/data
        │
┌───────┼────────────────────────────────────────────────────┐
│       │              DOMAIN LAYER                          │
│  ┌────┴─────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Entities │  │Use Cases │  │ Services │  │Repository│  │
│  │          │  │          │  │          │  │Interfaces│  │
│  └──────────┘  └────▲─────┘  └────▲─────┘  └────▲─────┘  │
│                     │              │              │        │
│  ⚡ Pure business logic, no UI or data imports     │       │
└─────────────────────┼──────────────┼──────────────┼────────┘
                      │              │              │
                      │ ✅ Implements │ ✅ Implements│
┌─────────────────────┼──────────────┼──────────────┼────────┐
│                     │     DATA LAYER               │        │
│  ┌──────────────────┴──────────────────────────────┴─────┐  │
│  │         Repository Implementation                     │  │
│  │  ✅ Extends BaseHybridRepository<T>                   │  │
│  │  ✅ Uses FirebaseErrorMapperMixin                     │  │
│  │  ✅ Delegates to DataSources (never touches DB)      │  │
│  └───────────────────▲────────────────────▲──────────────┘  │
│                      │                    │                 │
│  ┌───────────────────┴─────┐  ┌───────────┴──────────────┐  │
│  │ RemoteDataSource        │  │ LocalDataSource          │  │
│  │ (FirebaseFirestore)     │  │ (Hive)                   │  │
│  │ ✅ Network operations   │  │ ✅ Cache operations      │  │
│  │ ✅ DTOs/Models          │  │ ✅ Offline support       │  │
│  └─────────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Dependency Rules

### Current Reality ❌

```
Domain → Presentation  ❌ 20+ violations (imports providers, widgets, l10n)
Domain → Data          ❌ 10+ violations (imports models, mappers, Hive)
Data → Presentation    ❌ 6 violations (imports providers for DI)
```

### Ideal State ✅

```
Presentation → Domain, Data   ✅ ALLOWED
Data → Domain                 ✅ ALLOWED
Domain → Nothing*             ✅ PURE BUSINESS LOGIC

*except shared/domain
```

---

## Repository Pattern Comparison

### Current Pattern (35/38 repositories) ❌

```dart
class AnalyticsRepositoryImpl
    with FirebaseErrorMapperMixin
    implements AnalyticsRepository {

  AnalyticsRepositoryImpl({
    required FirebaseFirestore firestore,  // ❌ Direct Firestore
    required Box cacheBox,                  // ❌ Manual cache
  });

  final FirebaseFirestore _firestore;
  final Box _cacheBox;

  @override
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) {
    return _firestore                        // ❌ Direct Firestore access
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .snapshots()
        .map((snapshot) => /* manual mapping */);
  }
}
```

**Problems**:
- ❌ Repository knows about Firestore implementation
- ❌ Manual cache management in every repository
- ❌ No offline support
- ❌ Cache TTL logic duplicated
- ❌ Hard to test (must mock Firestore)

---

### Ideal Pattern (BaseHybridRepository) ✅

```dart
class AnalyticsRepositoryImpl
    extends BaseHybridRepository<ExerciseHistory> {

  AnalyticsRepositoryImpl({
    required AnalyticsRemoteDataSource remoteDataSource,
    required AnalyticsLocalDataSource localDataSource,
  }) : super(
    featureName: 'analytics',
    cacheTTL: Duration(minutes: 5),
  ) {
    _remoteDataSource = remoteDataSource;
    _localDataSource = localDataSource;
  }

  late final AnalyticsRemoteDataSource _remoteDataSource;
  late final AnalyticsLocalDataSource _localDataSource;

  @override
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(
    String userId,
  ) {
    // ✅ BaseHybridRepository handles cache, offline, sync
    return watchWithCache(
      cacheKey: 'exercise_history_$userId',
      remoteStream: () => _remoteDataSource.watchExerciseHistory(userId),
      localFetch: () => _localDataSource.getExerciseHistory(userId),
      localSave: (data) => _localDataSource.cacheExerciseHistory(userId, data),
    );
  }
}
```

**Benefits**:
- ✅ Repository doesn't know about Firestore/Hive
- ✅ Automatic cache management with TTL
- ✅ Automatic offline support
- ✅ Optimistic updates handled
- ✅ Easy to test (mock DataSources, not Firebase)
- ✅ Consistent behavior across all repositories

---

## DataSource Layer Comparison

### Current: No DataSource (27/38 features) ❌

```dart
// Repository directly touches Firestore
class ChatRepositoryImpl {
  final FirebaseFirestore _firestore;

  Future<void> sendMessage(Message msg) async {
    await _firestore                      // ❌ Direct DB access
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg.toJson());
  }
}
```

**Problems**:
- ❌ Repository tightly coupled to Firestore
- ❌ Can't swap to different database
- ❌ Hard to test (must mock Firestore SDK)
- ❌ No separation of remote vs. local data

---

### Ideal: DataSource Separation ✅

```dart
// REMOTE DATA SOURCE
class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  Future<void> sendMessage(MessageModel model) async {
    await _firestore
        .collection('chats')
        .doc(model.chatId)
        .collection('messages')
        .add(model.toJson());
  }

  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }
}

// LOCAL DATA SOURCE
class ChatLocalDataSource {
  final HiveInterface _hive;

  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    final box = await _hive.openBox<MessageModel>('chat_cache');
    await box.put('messages_$chatId', messages);
  }

  Future<List<MessageModel>?> getCachedMessages(String chatId) async {
    final box = await _hive.openBox<MessageModel>('chat_cache');
    return box.get('messages_$chatId');
  }
}

// REPOSITORY (ORCHESTRATES DATA SOURCES)
class ChatRepositoryImpl extends BaseHybridRepository<Message> {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;

  @override
  Stream<Either<Failure, List<Message>>> watchMessages(String chatId) {
    return watchWithCache(
      cacheKey: 'messages_$chatId',
      remoteStream: () => _remoteDataSource
          .watchMessages(chatId)
          .map((models) => models.map((m) => m.toDomain()).toList()),
      localFetch: () async {
        final cached = await _localDataSource.getCachedMessages(chatId);
        return cached?.map((m) => m.toDomain()).toList();
      },
      localSave: (messages) => _localDataSource.cacheMessages(
        chatId,
        messages.map((m) => MessageModel.fromDomain(m)).toList(),
      ),
    );
  }
}
```

**Benefits**:
- ✅ Clear separation: remote = network, local = cache
- ✅ Easy to test (mock DataSources independently)
- ✅ Can swap Firestore for REST API without changing repository
- ✅ Can swap Hive for SQLite without changing repository
- ✅ Repository is pure orchestration logic

---

## Feature Structure Comparison

### Current: Inconsistent ❌

```
analytics/          ✅ Complete (domain + data + presentation)
auth/               ✅ Complete
workout/            ✅ Complete

admin/              ❌ Missing domain layer
premium/            ❌ Presentation only (no domain/data)
profile/            ❌ Presentation only
settings/           ❌ Presentation only
splash/             ❌ Presentation only
debug/              ❌ Presentation only

timer/              ❌ Missing data layer (iOS native handles storage)
progress/           ❌ Missing data layer
predictive_balance/ ❌ Missing data layer
```

---

### Ideal: Consistent Structure ✅

```
lib/features/{feature_name}/
├── domain/                    # ✅ Business logic (pure Dart)
│   ├── entities/              # ✅ Business objects
│   ├── repositories/          # ✅ Abstract interfaces
│   ├── usecases/              # ✅ Business operations
│   └── services/              # ✅ Domain services
├── data/                      # ✅ Data access layer
│   ├── models/                # ✅ DTOs for serialization
│   ├── repositories/          # ✅ Repository implementations
│   ├── datasources/           # ✅ Remote + Local data sources
│   │   ├── remote/
│   │   └── local/
│   └── mappers/               # ✅ Entity ↔ Model conversion
└── presentation/              # ✅ UI layer
    ├── providers/             # ✅ Riverpod state management
    ├── screens/               # ✅ Full page widgets
    └── widgets/               # ✅ Reusable components
```

**Exceptions Allowed**:
- **UI-only features** (splash, debug screens) can skip domain/data
- **Platform-specific features** (timer on iOS) documented in ADR
- **Wrapper features** (profile wraps auth) documented in CLAUDE.md

---

## Localization Pattern Comparison

### Current: AppLocalizations in Domain ❌

```dart
// ❌ WRONG: Domain service importing presentation layer
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class NotificationMessagePool {
  String getMotivationalMessage(AppLocalizations l10n) {
    return l10n.youreOnFire;  // ❌ Domain depends on UI localization
  }
}
```

**Problems**:
- ❌ Domain layer depends on presentation
- ❌ Domain can't be tested without BuildContext
- ❌ Violates Dependency Inversion Principle

---

### Ideal: Message Keys in Domain ✅

```dart
// ✅ CORRECT: Domain returns message keys
class NotificationMessagePool {
  /// Returns localization key for motivational message
  String getMotivationalMessageKey(int streakDays) {
    if (streakDays >= 7) return 'motivational_fire_week';
    if (streakDays >= 3) return 'motivational_fire_days';
    return 'motivational_fire_start';
  }
}

// Presentation layer handles localization
class NotificationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageKey = ref.watch(notificationProvider).messageKey;
    final localizedMessage = context.l10n[messageKey];  // ✅ Localize in UI

    return Text(localizedMessage);
  }
}
```

**Benefits**:
- ✅ Domain layer stays pure (no UI dependencies)
- ✅ Easy to test (strings, not BuildContext)
- ✅ Can change localization library without touching domain
- ✅ Follows Dependency Inversion Principle

---

## Migration Strategy

### Phase 1: Stop the Bleeding (Week 1-2)

**Goal**: Prevent new violations

1. ✅ Document violations in this file
2. ✅ Add architecture rules to CLAUDE.md
3. ⏳ Create pre-commit hook checking for violations
4. ⏳ Add CI checks for domain purity

---

### Phase 2: Critical Fixes (Week 3-4)

**Goal**: Fix critical domain violations

1. ⏳ Move `MuscleGroup` enum to domain/entities
2. ⏳ Create `ExerciseUsage` domain entity
3. ⏳ Move `muscle_abbreviation_mapper` to shared/domain/utils
4. ⏳ Remove `AppLocalizations` from domain services
5. ⏳ Create domain abstractions for provider dependencies

---

### Phase 3: Repository Modernization (Month 2-3)

**Goal**: Migrate to BaseHybridRepository pattern

**Priority Order**:
1. ⏳ Analytics (high traffic, complex caching)
2. ⏳ Workout (core feature)
3. ⏳ Auth (security critical)
4. ⏳ Progress tracking features
5. ⏳ Remaining features

**Per-Repository Checklist**:
- [ ] Create RemoteDataSource
- [ ] Create LocalDataSource
- [ ] Extend BaseHybridRepository
- [ ] Implement cache strategies
- [ ] Add tests
- [ ] Document exceptions (if any)

---

### Phase 4: DataSource Adoption (Month 3-4)

**Goal**: Separate data concerns

**Priority Order**:
1. ⏳ Analytics (complex data flows)
2. ⏳ Auth (security isolation)
3. ⏳ Exercise database (caching critical)
4. ⏳ Progress photos (file upload separation)
5. ⏳ Remaining features

---

### Phase 5: Architecture Testing (Ongoing)

**Goal**: Prevent regressions

1. ⏳ Add layer dependency tests
2. ⏳ Add repository pattern tests
3. ⏳ Add CI architecture checks
4. ⏳ Document test patterns
5. ⏳ Create violation detection tools

---

## Success Metrics

| Metric | Current | Target (1 month) | Target (3 months) |
|--------|---------|------------------|-------------------|
| **Domain Purity** | 20+ violations | 0 violations | 0 violations |
| **BaseHybridRepository** | 7.9% (3/38) | 30% (12/38) | 80% (30/38) |
| **DataSource Pattern** | 29% (11/38) | 50% (19/38) | 80% (30/38) |
| **Complete Features** | 72% (28/39) | 85% (33/39) | 95% (37/39) |
| **Architecture Tests** | 0 | 20+ tests | 50+ tests |

---

## References

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [FitLog Architecture Overview](/Users/michele/gymbro_flutter_new/docs/architecture/OVERVIEW.md)
- [Architecture Violations Report](/Users/michele/gymbro_flutter_new/ARCHITECTURE_VIOLATIONS.txt)
- [Full Audit Report](/Users/michele/gymbro_flutter_new/ARCHITECTURE_AUDIT_REPORT.md)

---

**Maintained By**: flutter-architect agent
**Last Updated**: 2026-01-02
