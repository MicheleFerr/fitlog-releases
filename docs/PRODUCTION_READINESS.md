# 🚀 Production Readiness Checklist

**Versione**: 2.0
**Ultima revisione**: 2026-02-02
**Applicabile a**: Flutter apps, FitLog Pro

> Guida completa per portare un'app da "funziona sul mio device" a "pronta per migliaia di utenti".
>
> **v2.0 Changes**: Aggiunto HealthKit/Health Connect compliance, accessibility estesa WCAG 2.1 AA, i18n verification, performance benchmarks realistici, disaster recovery.

---

## 📖 Indice

1. [Coerenza Codebase](#1-coerenza-codebase)
2. [Coerenza Design](#2-coerenza-design)
3. [Testing & Quality](#3-testing--quality)
4. [Performance](#4-performance)
5. [Security & Privacy](#5-security--privacy)
6. [DevOps & Release](#6-devops--release)
7. [Monitoring & Analytics](#7-monitoring--analytics)
8. [Documentazione](#8-documentazione)
9. [Internationalization](#9-internationalization) ⭐ NEW
10. [Legal & Compliance](#10-legal--compliance)
11. [Go-Live Checklist](#11-go-live-checklist)

---

## 1. Coerenza Codebase

### 1.1 Architettura

#### ✅ Checklist Strutturale

- [ ] **Architettura definita e documentata**
  - Clean Architecture / MVVM / MVC chiaramente applicata
  - Layer separation rispettata (presentation, domain, data)
  - Dependency flow unidirezionale (presentation → domain → data)

- [ ] **Feature organization coerente**
  ```
  lib/features/
  ├── auth/
  │   ├── domain/
  │   ├── data/
  │   └── presentation/
  ├── workout/
  │   ├── domain/
  │   ├── data/
  │   └── presentation/
  └── ...
  ```

- [ ] **Shared code ben organizzato**
  ```
  lib/shared/
  ├── domain/        # Entities, usecases comuni
  ├── data/          # Network, storage, repository base
  └── presentation/  # Widgets, themes, l10n
  ```

- [ ] **Zero circular dependencies**
  ```bash
  # Check con analyzer
  flutter analyze
  # Check manuale con import graph tools
  ```

#### 🎯 FitLog Specific

- [ ] Tutti i provider usano **Riverpod** (no Provider legacy)
- [ ] Repository estendono `BaseHybridRepository` (online/offline)
- [ ] DataSource pattern per accesso dati (no Firestore diretto in repository)

---

### 1.2 Code Standards

#### ✅ Naming Conventions

- [ ] **Classi**: `PascalCase`
  - Entities: `Workout`, `Exercise`, `UserProfile`
  - Providers: `workoutProvider`, `authProvider`
  - Services: `AnalyticsService`, `StorageService`

- [ ] **File**: `snake_case.dart`
  - Screens: `workout_screen.dart`
  - Widgets: `exercise_card.dart`
  - Providers: `workout_provider.dart`

- [ ] **Variabili/metodi**: `camelCase`
  ```dart
  final currentWorkout = ...;
  void saveWorkout() { }
  ```

- [ ] **Costanti**: `lowerCamelCase` (Dart convention)
  ```dart
  const maxRetries = 3;
  const apiBaseUrl = '...';
  ```

#### ✅ Code Quality

- [ ] **Analyzer passa senza errori**
  ```bash
  flutter analyze
  # 0 issues found
  ```

- [ ] **Linter configurato e rispettato**
  ```yaml
  # analysis_options.yaml
  include: package:flutter_lints/flutter.yaml
  linter:
    rules:
      - prefer_const_constructors
      - avoid_print
      - require_trailing_commas
  ```

- [ ] **Formatting automatico applicato**
  ```bash
  dart format lib/ test/
  ```

- [ ] **No codice commentato** (usa git history, non commenti)
  ```dart
  // ❌ BAD
  // final oldLogic = ...;
  // void deprecatedMethod() { }

  // ✅ GOOD
  // Se serve storico → git blame
  ```

- [ ] **TODO gestiti**
  - Zero `// TODO` in main branch
  - Oppure tracciati in issue tracker con link
  ```dart
  // TODO(#123): Implement offline sync
  ```

#### ✅ Error Handling

- [ ] **Try-catch appropriato**
  ```dart
  // ✅ GOOD
  try {
    await riskyOperation();
  } on SpecificException catch (e) {
    logger.error('Specific error', e);
    rethrow; // O gestisci
  } catch (e, stack) {
    logger.error('Unexpected error', e, stack);
    // Fallback behavior
  }
  ```

- [ ] **No silent failures**
  ```dart
  // ❌ BAD
  try {
    await save();
  } catch (e) {
    // Silenzio
  }

  // ✅ GOOD
  try {
    await save();
  } catch (e) {
    logger.error('Save failed', e);
    unawaited(analytics.logError(e));
    throw SaveException('Could not save', e);
  }
  ```

- [ ] **Logging strutturato**
  ```dart
  logger.info('Workout saved', extra: {
    'workoutId': workout.id,
    'exerciseCount': workout.exercises.length,
    'duration': workout.duration.inMinutes,
  });
  ```

---

### 1.3 Dependencies

#### ✅ Dependency Hygiene

- [ ] **Pubspec.yaml pulito**
  ```yaml
  dependencies:
    # Core
    flutter:
      sdk: flutter

    # State management
    flutter_riverpod: ^2.4.0

    # Backend
    cloud_firestore: ^4.13.0

    # NO versioni deprecate
    # NO dipendenze inutilizzate
  ```

- [ ] **Versioni pinnate per production**
  ```yaml
  # Development → range OK
  riverpod: ^2.4.0

  # Production → pin exact version
  riverpod: 2.4.0
  ```

- [ ] **Audit sicurezza**
  ```bash
  # Check vulnerabilità note
  dart pub outdated
  dart pub upgrade --dry-run
  ```

- [ ] **License compliance**
  ```bash
  # Verifica licenze compatibili (no GPL in app proprietarie)
  flutter pub deps --style=compact
  ```

---

### 1.4 Git Hygiene

#### ✅ Repository Health

- [ ] **Commit messages semantici**
  ```
  feat(workout): add weight suggestion service
  fix(auth): resolve token refresh loop
  docs: update production readiness guide
  chore: bump flutter to 3.16.0
  ```

- [ ] **Branch strategy definita**
  ```
  main       → produzione (protected)
  develop    → staging
  feature/*  → nuove feature
  hotfix/*   → fix urgenti
  ```

- [ ] **.gitignore completo**
  ```gitignore
  # Build
  build/
  .dart_tool/

  # Secrets
  .env
  firebase_options.dart  # Se contiene keys
  google-services.json   # Android
  GoogleService-Info.plist  # iOS

  # IDE
  .vscode/
  .idea/
  *.iml

  # OS
  .DS_Store
  Thumbs.db
  ```

- [ ] **No file sensibili in git history**
  ```bash
  # Check
  git log --all --full-history -- "*google-services.json"

  # Se trovati → remove from history
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch path/to/secret" \
    --prune-empty --tag-name-filter cat -- --all
  ```

---

## 2. Coerenza Design

### 2.1 Design System

#### ✅ Theme Consistency

- [ ] **Centralizzato in `ThemeData`**
  ```dart
  // lib/shared/presentation/theme/app_theme.dart
  class AppTheme {
    static ThemeData light() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: AppTextStyles.textTheme,
      // ...
    );

    static ThemeData dark() => ThemeData(
      // ...
    );
  }
  ```

- [ ] **Colori da palette definita**
  ```dart
  // ❌ BAD
  Container(color: Colors.blue)

  // ✅ GOOD
  Container(color: context.colors.primary)
  // Oppure
  Container(color: Theme.of(context).colorScheme.primary)
  ```

- [ ] **Typography system**
  ```dart
  class AppTextStyles {
    static const TextStyle headlineLarge = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );

    static const TextStyle bodyMedium = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );
  }
  ```

- [ ] **Spacing system**
  ```dart
  class AppSpacing {
    static const double xs = 4;
    static const double sm = 8;
    static const double md = 16;
    static const double lg = 24;
    static const double xl = 32;
  }

  // Uso
  Padding(padding: EdgeInsets.all(AppSpacing.md))
  ```

#### 🎯 FitLog Specific

- [ ] `context.colors.*` invece di `Colors.*`
- [ ] `AppIcons.*` invece di `Icons.*`
- [ ] `AppIconSize.*` invece di numeri hardcoded
- [ ] Dark mode supportato e testato

---

### 2.2 UI Components

#### ✅ Component Library

- [ ] **Atomic design structure**
  ```
  lib/shared/presentation/widgets/
  ├── atoms/           # Button, Icon, Text
  ├── molecules/       # Card, ListItem
  ├── organisms/       # AppBar, BottomSheet
  └── templates/       # ScreenLayout, ListLayout
  ```

- [ ] **Componenti riutilizzabili**
  ```dart
  // ❌ BAD - duplicato in 5 screen
  CircularProgressIndicator()

  // ✅ GOOD - centralizzato
  LoadingIndicator()  // lib/shared/presentation/widgets/atoms/
  ```

- [ ] **Props/API consistenti**
  ```dart
  // Tutti i bottoni condividono API simile
  PrimaryButton(
    label: 'Save',
    onPressed: () {},
    isLoading: false,
  )

  SecondaryButton(
    label: 'Cancel',
    onPressed: () {},
    isLoading: false,
  )
  ```

- [ ] **Storybook/Widget Catalog** (opzionale ma utile)
  ```dart
  // widgetbook/lib/main.dart
  // Mostra tutti i componenti con varianti
  ```

---

### 2.3 UX Consistency

#### ✅ Interaction Patterns

- [ ] **Navigation coerente**
  - Push/pop vs named routes
  - Transition animations uniformi
  - Back button behavior consistente

- [ ] **Loading states**
  ```dart
  // Shimmer per liste
  ListView.builder(
    itemBuilder: (_, i) => data == null
      ? ShimmerCard()
      : DataCard(data[i]),
  )

  // Spinner per azioni
  ElevatedButton(
    onPressed: isLoading ? null : onSave,
    child: isLoading
      ? LoadingIndicator()
      : Text('Save'),
  )
  ```

- [ ] **Error states**
  ```dart
  // Empty state
  if (items.isEmpty) {
    return EmptyStateWidget(
      icon: AppIcons.emptyBox,
      message: context.l10n.noWorkoutsYet,
      action: AddWorkoutButton(),
    );
  }

  // Error state
  if (error != null) {
    return ErrorStateWidget(
      message: context.l10n.loadFailed,
      onRetry: () => ref.refresh(provider),
    );
  }
  ```

- [ ] **Feedback immediato**
  - Touch ripple su tap
  - Snackbar per successo/errore
  - Haptic feedback (device.vibrate) per azioni importanti

#### ✅ Accessibility (WCAG 2.1 Level AA)

**CRITICAL**: FitLog deve rispettare WCAG 2.1 Level AA per garantire usabilità a utenti con disabilità visive e motorie.

- [ ] **Semantics completo**
  ```dart
  Semantics(
    label: 'Add workout button',
    hint: 'Tap to create a new workout',
    button: true,
    child: IconButton(...),
  )
  ```

- [ ] **Contrast ratio WCAG 2.1 AA** ⭐ NEW
  - **Testo normale** (< 18pt): minimo **4.5:1**
  - **Testo large** (≥ 18pt o 14pt bold): minimo **3:1**
  - **Elementi UI** (pulsanti, icone): minimo **3:1** vs background

  **Verifica**:
  ```dart
  // Check con DevTools Accessibility Inspector
  // O usa online tool: https://webaim.org/resources/contrastchecker/

  // ❌ BAD - Contrast ratio 2.5:1
  Text(
    'Workout completed',
    style: TextStyle(color: Colors.grey[400]),  // Su background bianco
  )

  // ✅ GOOD - Contrast ratio 7:1
  Text(
    'Workout completed',
    style: TextStyle(color: Colors.grey[800]),  // Su background bianco
  )
  ```

- [ ] **Touch targets minimi** ⭐ NEW
  - Minimo **44x44pt** (iOS) o **48x48dp** (Android)
  - Spacing minimo **8pt** tra target adiacenti

  ```dart
  // ❌ BAD - Icona troppo piccola
  IconButton(
    iconSize: 20,  // Solo 20x20
    icon: Icon(Icons.delete),
    onPressed: onDelete,
  )

  // ✅ GOOD - Touch target adeguato
  IconButton(
    iconSize: 24,
    padding: EdgeInsets.all(12),  // 24 + (12*2) = 48dp
    icon: Icon(Icons.delete),
    onPressed: onDelete,
  )
  ```

- [ ] **Font scaling supportato** (fino a 200%)
  ```dart
  // Test con accessibility settings
  MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaleFactor: 2.0,
    ),
    child: YourWidget(),
  )

  // Verifica che:
  // - Nessun testo tagliato
  // - Layout non rotto
  // - Tutto leggibile
  ```

- [ ] **Screen reader testato**
  - **iOS**: VoiceOver (Settings → Accessibility → VoiceOver)
  - **Android**: TalkBack (Settings → Accessibility → TalkBack)

  **Test checklist**:
  - [ ] Tutti gli elementi interattivi sono annunciati
  - [ ] Label descrittivi (no "button", "icon")
  - [ ] Ordine di navigazione logico
  - [ ] Immagini decorative hanno `excludeFromSemantics: true`

- [ ] **Keyboard navigation** (per tablet/desktop)
  - Tab order logico
  - Focus indicator visibile
  - Tutte le azioni accessibili da tastiera

- [ ] **Color contrast verification** automatica
  ```bash
  # Script custom per check automatico
  .claude/scripts/accessibility-check.sh
  # Oppure usa Flutter DevTools → Accessibility tab
  ```

**FitLog Specific**:
- [ ] Verificare contrast ratio su:
  - [ ] Exercise cards (testo su background colorato)
  - [ ] Timer display (numeri large)
  - [ ] Chart labels (testo su grafici)
  - [ ] Bottom navigation (icone attive vs inactive)

---

### 2.4 Visual Polish

#### ✅ Animation & Motion

- [ ] **Transizioni fluide 60fps**
  ```dart
  // Usa AnimatedContainer, AnimatedOpacity, etc.
  AnimatedContainer(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    color: isActive ? Colors.blue : Colors.grey,
  )
  ```

- [ ] **No jank** (usa DevTools Performance)
  - Build time < 16ms (60fps)
  - Nessun frame skipped

- [ ] **Animazioni cancellabili** (se utente naviga via)
  ```dart
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  ```

#### ✅ Visual Details

- [ ] **Iconografia coerente** (stesso style pack)
- [ ] **Border radius uniforme** (es. sempre 8, 12, o 16)
- [ ] **Shadows consistenti** (elevation system)
- [ ] **Immagini ottimizzate**
  - WebP/AVIF per asset
  - Lazy loading per remote images
  - Placeholder mentre carica

---

## 3. Testing & Quality

### 3.1 Test Coverage

#### ✅ Unit Tests

- [ ] **Business logic coperta ≥ 80%**
  ```dart
  // test/features/workout/domain/usecases/calculate_volume_test.dart
  void main() {
    group('CalculateVolumeUseCase', () {
      test('calculates total volume correctly', () {
        final usecase = CalculateVolumeUseCase();
        final volume = usecase([
          Set(reps: 10, weight: 100),
          Set(reps: 8, weight: 100),
        ]);
        expect(volume, 1800); // (10+8) * 100
      });
    });
  }
  ```

- [ ] **Edge cases testati**
  - Input nullo
  - Lista vuota
  - Valori estremi (0, negativo, infinito)

- [ ] **Mock per dipendenze esterne**
  ```dart
  @GenerateMocks([FirebaseFirestore, SharedPreferences])
  void main() {
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
    });

    test('fetches workouts from Firestore', () async {
      when(mockFirestore.collection('workouts').get())
        .thenAnswer((_) async => mockSnapshot);

      final repo = WorkoutRepository(mockFirestore);
      final workouts = await repo.getAll();

      expect(workouts, isNotEmpty);
    });
  }
  ```

#### ✅ Widget Tests

- [ ] **UI components testati**
  ```dart
  // test/shared/presentation/widgets/loading_indicator_test.dart
  void main() {
    testWidgets('LoadingIndicator shows spinner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LoadingIndicator()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  }
  ```

- [ ] **Interazioni testate**
  ```dart
  testWidgets('Button calls onPressed when tapped', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PrimaryButton(
          label: 'Test',
          onPressed: () => pressed = true,
        ),
      ),
    );

    await tester.tap(find.text('Test'));
    await tester.pump();

    expect(pressed, isTrue);
  });
  ```

- [ ] **Golden tests per UI regression** (opzionale)
  ```dart
  testWidgets('WorkoutCard matches golden', (tester) async {
    await tester.pumpWidget(WorkoutCard(workout: mockWorkout));
    await expectLater(
      find.byType(WorkoutCard),
      matchesGoldenFile('goldens/workout_card.png'),
    );
  });
  ```

#### ✅ Integration Tests

- [ ] **Critical flows end-to-end**
  ```dart
  // integration_test/workout_flow_test.dart
  void main() {
    testWidgets('User can create and complete workout', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Create workout
      await tester.tap(find.byIcon(Icons.add));
      await tester.enterText(find.byType(TextField), 'Bench Press');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify
      expect(find.text('Bench Press'), findsOneWidget);
    });
  }
  ```

- [ ] **Patrol tests** (se usato)
  ```dart
  patrolTest('Complete workout flow', ($) async {
    await $.pumpWidgetAndSettle(MyApp());
    await $(#loginButton).tap();
    await $(#createWorkout).tap();
    await $(TextField).enterText('Squats');
    await $(#saveButton).tap();
    expect($(#workoutList).$(Squats), findsOneWidget);
  });
  ```

#### ✅ Test Commands

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests
flutter test integration_test/

# Patrol (se usato)
patrol test
```

---

### 3.2 Manual Testing

#### ✅ Device Matrix

- [ ] **iOS**
  - iPhone SE (small screen)
  - iPhone 14 Pro (notch)
  - iPhone 14 Pro Max (large screen)
  - iPad (tablet layout)
  - iOS 15, 16, 17, 18

- [ ] **Android**
  - Pixel (stock Android)
  - Samsung (OneUI)
  - Small screen (5")
  - Large screen (6.7"+)
  - Android 10, 11, 12, 13, 14

- [ ] **Orientation**
  - Portrait
  - Landscape (tablet soprattutto)

#### ✅ Network Conditions

- [ ] **Offline mode**
  - App launch offline
  - Perdita connessione durante uso
  - Ritorno online → sync automatico

- [ ] **Slow network**
  ```bash
  # iOS Simulator → Network Link Conditioner
  # Android Emulator → Settings → Network → 3G/Edge
  ```

- [ ] **API failures**
  - 500 error → retry logic
  - 401 unauthorized → re-auth
  - Timeout → error message

#### ✅ Edge Cases

- [ ] **Permessi negati**
  - Fotocamera
  - Notifiche
  - Location (se usato)
  - HealthKit/Health Connect

- [ ] **Background/Foreground**
  - App in background → pausa timer
  - Return foreground → resume
  - OS kill app → stato salvato

- [ ] **Dati estremi**
  - 0 workout
  - 1000+ workout
  - Nome lungo 500 caratteri
  - Special characters (emoji, unicode)

---

## 4. Performance

> **v2.0**: Aggiunti target realistici per app Flutter con Firebase+Hive stack.

### 4.0 Performance Benchmarks ⭐ NEW

**Target realistici per FitLog** (app Flutter con Firebase, Hive, Health APIs):

| Metric | Target | Rationale |
|--------|--------|-----------|
| **Cold start** | < 4s | Firebase init + Hive open + auth check richiede 2-3s |
| **Warm start** | < 1.5s | App già in memoria |
| **Memory idle** | < 150MB | Flutter engine + Firebase SDKs + Hive |
| **Memory peak** | < 300MB | Durante caricamento workout list (1000+ items) |
| **Frame rate** | ≥ 58fps | 60fps ideale, 58fps accettabile |
| **Build time** | < 16ms | Per 60fps smooth |
| **API response** | < 2s | Firestore query con buona connessione |
| **Offline ready** | < 500ms | Hive read deve essere quasi istantaneo |

**Come misurare**:

```bash
# 1. Cold start time
flutter run --profile --trace-startup
# Leggi: lib/main.dart → first frame time

# 2. Memory usage
# DevTools → Memory → Take snapshot
# Verifica: Total heap < target

# 3. Frame rate
# DevTools → Performance → Record
# Check: Frame rendering time < 16ms

# 4. Firestore latency
# Firebase Console → Performance → Network requests
```

**FitLog Specific Checks**:

- [ ] **Workout list loading** (1000 workouts) < 3s
  ```dart
  final stopwatch = Stopwatch()..start();
  final workouts = await workoutRepository.getAll();
  stopwatch.stop();
  print('Loaded ${workouts.length} workouts in ${stopwatch.elapsedMilliseconds}ms');
  // Target: < 3000ms
  ```

- [ ] **Exercise search** (fuzzy, 500+ exercises) < 500ms
  ```dart
  // Isolate-based search deve essere fast
  final results = await exerciseSearchService.search('bench press');
  // Target: < 500ms
  ```

- [ ] **Chart rendering** (6 months data) < 1s
  ```dart
  // Volume chart con 180+ datapoints
  // Target: < 1000ms per render
  ```

- [ ] **Image caching** (exercise thumbnails) < 100ms per successive load
  ```dart
  // CachedNetworkImage deve essere veloce dopo first load
  ```

**Warning thresholds** (oltre questi → investigate):

| Metric | Warning | Critical |
|--------|---------|----------|
| Cold start | > 4s | > 6s |
| Memory idle | > 150MB | > 200MB |
| Frame drop | > 5% frames | > 10% frames |
| API timeout | > 5s | > 10s |

### 4.1 Build Performance

#### ✅ App Size

- [ ] **Bundle size ottimizzato**
  ```bash
  # Check size
  flutter build apk --analyze-size
  flutter build ios --analyze-size

  # Target: < 50MB per la maggior parte delle app
  ```

- [ ] **Tree shaking abilitato** (automatico in release)

- [ ] **Code splitting** (se web)
  ```dart
  // Deferred loading
  import 'package:my_app/admin_panel.dart' deferred as admin;

  void openAdmin() async {
    await admin.loadLibrary();
    admin.showPanel();
  }
  ```

- [ ] **Asset compression**
  ```yaml
  # pubspec.yaml
  flutter:
    assets:
      - assets/images/  # Usa WebP invece di PNG
  ```

#### ✅ Startup Time

- [ ] **Cold start < 3s** (misurato su device reale)
  ```dart
  // main.dart
  void main() {
    final startTime = DateTime.now();

    runApp(MyApp());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('App started in ${duration.inMilliseconds}ms');
    });
  }
  ```

- [ ] **Lazy initialization**
  ```dart
  // ❌ BAD - init tutto all'avvio
  void main() async {
    await Firebase.initializeApp();
    await Hive.initFlutter();
    await setupAnalytics();
    await loadConfig();
    runApp(MyApp());
  }

  // ✅ GOOD - init solo critical path
  void main() async {
    await Firebase.initializeApp();  // Necessario
    runApp(MyApp());  // Avvia UI

    // Background init
    unawaited(Hive.initFlutter());
    unawaited(setupAnalytics());
  }
  ```

- [ ] **Splash screen nativa** (no Flutter splash)
  ```xml
  <!-- Android: android/app/src/main/res/drawable/launch_background.xml -->
  <!-- iOS: ios/Runner/Assets.xcassets/LaunchImage.imageset/ -->
  ```

---

### 4.2 Runtime Performance

#### ✅ Frame Rate

- [ ] **60fps costanti** (DevTools → Performance)
  - Build < 16ms
  - Raster < 16ms
  - No frame drop durante scroll

- [ ] **Shader warmup** (evita jank al primo render)
  ```dart
  // Precompila shader complessi
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!kReleaseMode) return;

    precacheImage(AssetImage('assets/background.png'), context);
  });
  ```

- [ ] **RepaintBoundary** per widget costosi
  ```dart
  RepaintBoundary(
    child: ComplexChart(data: data),
  )
  ```

#### ✅ Memory

- [ ] **No memory leak** (DevTools → Memory)
  - Widget dispose correttamente
  - Stream subscription cancellate
  - Timer cancellati

- [ ] **Image caching**
  ```dart
  // Usa CachedNetworkImage
  CachedNetworkImage(
    imageUrl: url,
    maxWidthDiskCache: 800,
    memCacheWidth: 400,
  )
  ```

- [ ] **ListView lazy loading**
  ```dart
  // ❌ BAD
  ListView(children: List.generate(10000, (i) => Item(i)))

  // ✅ GOOD
  ListView.builder(
    itemCount: 10000,
    itemBuilder: (_, i) => Item(i),
  )
  ```

#### ✅ Network

- [ ] **Request batching**
  ```dart
  // ❌ BAD - 100 requests separate
  for (final id in workoutIds) {
    await fetchWorkout(id);
  }

  // ✅ GOOD - 1 batch request
  await fetchWorkouts(workoutIds);
  ```

- [ ] **Pagination**
  ```dart
  final workouts = await firestore
    .collection('workouts')
    .orderBy('date')
    .limit(20)  // Solo 20 per pagina
    .get();
  ```

- [ ] **Caching strategy**
  - Stale-while-revalidate
  - Cache-first per dati statici
  - Network-first per dati real-time

---

### 4.3 Battery & Data

#### ✅ Power Efficiency

- [ ] **Background task minimali**
  - No polling ogni 30s
  - Usa push notifications invece di background fetch

- [ ] **Location usage ottimizzato**
  ```dart
  // ❌ BAD
  Location().onLocationChanged.listen(...)  // Drain continuo

  // ✅ GOOD
  Location().getLocation()  // Solo quando serve
  ```

- [ ] **Sensori on-demand**
  - Accelerometro solo durante workout
  - GPS solo se feature location-based

#### ✅ Data Usage

- [ ] **Compressione abilitata** (Firestore/HTTP)
- [ ] **Immagini ridimensionate server-side**
- [ ] **Delta sync** (solo dati modificati)
  ```dart
  // ❌ BAD
  await fetchAllWorkouts();  // 10MB ogni volta

  // ✅ GOOD
  final lastSync = await getLastSyncTimestamp();
  await fetchWorkoutsSince(lastSync);  // Solo nuovi/modificati
  ```

---

## 5. Security & Privacy

### 5.1 Authentication

#### ✅ Auth Security

- [ ] **Password requirements** (se custom auth)
  - Minimo 8 caratteri
  - Mix uppercase/lowercase/numeri
  - No password comuni (use haveibeenpwned API)

- [ ] **Token management**
  ```dart
  // ✅ GOOD
  // - JWT in secure storage (flutter_secure_storage)
  // - Auto refresh prima di expire
  // - Logout on 401
  ```

- [ ] **Biometric auth** (opzionale ma consigliato)
  ```dart
  final auth = LocalAuthentication();
  final canAuth = await auth.canCheckBiometrics;
  if (canAuth) {
    final authenticated = await auth.authenticate(
      localizedReason: 'Login with fingerprint',
    );
  }
  ```

- [ ] **Session timeout** (dopo 30 giorni inattività)

---

### 5.2 Data Protection

#### ✅ Encryption

- [ ] **Data at rest encrypted**
  ```dart
  // Hive encryption
  final encryptionKey = await getEncryptionKey();
  await Hive.openBox('secure', encryptionCipher: HiveAesCipher(encryptionKey));
  ```

- [ ] **Data in transit encrypted** (HTTPS only)
  ```dart
  // Firestore/Firebase → TLS automatico
  // Custom API → enforce HTTPS
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => false;  // No self-signed
  ```

- [ ] **API keys protetti**
  ```dart
  // ❌ BAD
  const apiKey = 'sk_live_1234...';  // Hardcoded

  // ✅ GOOD
  // - Android: google-services.json (in .gitignore)
  // - iOS: GoogleService-Info.plist (in .gitignore)
  // - Custom: .env file + flutter_dotenv
  ```

#### ✅ User Data

- [ ] **Firestore security rules**
  ```javascript
  // firestore.rules
  match /users/{userId} {
    allow read, write: if request.auth.uid == userId;
  }

  match /workouts/{workoutId} {
    allow read: if request.auth.uid == resource.data.userId;
    allow create: if request.auth.uid == request.resource.data.userId;
  }
  ```

- [ ] **Rate limiting**
  ```javascript
  // Cloud Functions
  const rateLimit = require('express-rate-limit');

  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,  // 15 min
    max: 100  // Max 100 requests per IP
  });

  app.use('/api/', limiter);
  ```

- [ ] **Input validation**
  ```dart
  // ❌ BAD
  await firestore.collection('workouts').add(userInput);

  // ✅ GOOD
  final validated = WorkoutValidator.validate(userInput);
  if (validated.isValid) {
    await firestore.collection('workouts').add(validated.data);
  } else {
    throw ValidationException(validated.errors);
  }
  ```

---

### 5.3 Privacy Compliance

#### ✅ GDPR (EU)

- [ ] **Privacy Policy** (link in app + store listing)
- [ ] **Cookie consent** (se web)
- [ ] **Data export** (user può scaricare i propri dati)
  ```dart
  Future<File> exportUserData(String userId) async {
    final data = await fetchAllUserData(userId);
    final json = jsonEncode(data);
    final file = File('${userId}_data.json');
    await file.writeAsString(json);
    return file;
  }
  ```

- [ ] **Data deletion** (right to be forgotten)
  ```dart
  Future<void> deleteUserAccount(String userId) async {
    // Delete Firestore data
    await firestore.collection('users').doc(userId).delete();

    // Delete Storage files
    await storage.ref('users/$userId').listAll().then((result) async {
      for (final ref in result.items) {
        await ref.delete();
      }
    });

    // Delete Auth
    await FirebaseAuth.instance.currentUser?.delete();
  }
  ```

- [ ] **Consenso esplicito** per tracking analytics
  ```dart
  final consent = await showDialog<bool>(
    context: context,
    builder: (_) => ConsentDialog(),
  );

  if (consent == true) {
    await analytics.setAnalyticsCollectionEnabled(true);
  }
  ```

#### ✅ COPPA (US, se target <13 anni)

- [ ] Age gate all'onboarding
- [ ] No targeted ads per <13
- [ ] Parental consent per raccolta dati

#### ✅ App Store Requirements

- [ ] **iOS App Privacy Labels** (App Store Connect)
  - Data Types collected
  - Usage (tracking, analytics, personalization)
  - Linked to user / Not linked

- [ ] **Android Data Safety** (Play Console)
  - Similar a iOS privacy labels

---

### 5.4 HealthKit & Health Connect Compliance ⭐ NEW

**CRITICAL**: FitLog integra HealthKit (iOS) e Health Connect (Android) per body measurements. Questi API hanno **requisiti stringenti** che devono essere rispettati per evitare rejection da App Store / Play Store.

#### ✅ HealthKit Compliance (iOS)

**Apple Requirements**:
- ✅ Dati usati solo per health/fitness purposes
- ✅ NO advertising o marketing use
- ✅ NO vendita dati a terze parti
- ✅ NO condivisione senza explicit user consent
- ✅ Privacy Policy chiara su uso dati health

**Code verification**:

- [ ] **Purpose string chiaro** in `Info.plist`
  ```xml
  <!-- ios/Runner/Info.plist -->
  <key>NSHealthShareUsageDescription</key>
  <string>FitLog needs access to read your body measurements (weight, body fat) to track your fitness progress over time.</string>

  <key>NSHealthUpdateUsageDescription</key>
  <string>FitLog needs permission to save your body measurements to Apple Health.</string>
  ```

  **Verifica**:
  ```bash
  # Check che description sia presente e chiara
  grep -A1 "NSHealthShareUsageDescription" ios/Runner/Info.plist
  ```

- [ ] **Authorization flow corretto**
  ```dart
  // lib/features/body_measurements/data/services/health_kit_service.dart

  // ✅ GOOD - Richiede permission esplicita
  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.HEIGHT,
    ];

    return await health.requestAuthorization(types);
  }

  // ❌ BAD - No permission check
  final data = await health.getHealthDataFromTypes(...);  // Crash!
  ```

  **Verifica**:
  ```bash
  # Check che health_kit_service.dart richieda authorization
  grep -n "requestAuthorization" lib/features/body_measurements/data/services/health_kit_service.dart
  ```

- [ ] **NO uso dati per advertising**
  ```dart
  // ❌ BAD - Proibito da Apple
  final weight = await healthKit.getWeight();
  await analytics.logEvent('user_weight', {'weight': weight});  // NO!
  await adService.targetAd(userWeight: weight);  // REJECT GARANTITO!

  // ✅ GOOD - Solo fitness purposes
  final weight = await healthKit.getWeight();
  await measurementRepository.save(Measurement(weight: weight));
  // Usa solo per tracking progresso utente
  ```

  **Verifica manuale**:
  - [ ] Cerca tutti i punti dove HealthKit data è usato
  - [ ] Verifica che NON finisca in analytics events
  - [ ] Verifica che NON sia condiviso con servizi ads

- [ ] **Unit conversion corretta** (SI units from HealthKit)
  ```dart
  // HealthKit restituisce:
  // - Weight in KG
  // - Height in METERS
  // - Body fat in PERCENTAGE (0-100)

  // ✅ GOOD - Converti se utente usa Imperial
  Future<double> getWeight() async {
    final weightInKg = await health.getHealthDataFromTypes(
      startTime,
      endTime,
      [HealthDataType.WEIGHT],
    ).first.value;

    if (userPrefs.useImperialUnits) {
      return weightInKg * 2.20462;  // KG → LBS
    }
    return weightInKg;
  }
  ```

  **Verifica**:
  ```bash
  # Check che health_kit_service.dart faccia conversione
  grep -n "2.20462\|lbsToKg\|kgToLbs" lib/features/body_measurements/data/services/health_kit_service.dart
  ```

#### ✅ Health Connect Compliance (Android)

**Google Requirements**:
- ✅ Target Android 14+ (API 34+)
- ✅ Dichiarare permissions in AndroidManifest.xml
- ✅ Privacy Policy con sezione Health Connect
- ✅ Data Safety form su Play Console compilato
- ✅ NO uso dati per advertising (come iOS)

**Code verification**:

- [ ] **Permissions dichiarate**
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <uses-permission android:name="android.permission.health.READ_WEIGHT"/>
  <uses-permission android:name="android.permission.health.READ_HEIGHT"/>
  <uses-permission android:name="android.permission.health.READ_BODY_FAT"/>
  <uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
  <uses-permission android:name="android.permission.health.WRITE_HEIGHT"/>
  <uses-permission android:name="android.permission.health.WRITE_BODY_FAT"/>
  ```

  **Verifica**:
  ```bash
  # Check che permissions siano presenti
  grep "android.permission.health" android/app/src/main/AndroidManifest.xml
  ```

- [ ] **Package name corretto** per Health Connect
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <queries>
    <package android:name="com.google.android.apps.healthdata"/>
  </queries>
  ```

- [ ] **Authorization flow** (simile a iOS)
  ```dart
  // lib/features/body_measurements/data/services/health_connect_service.dart

  Future<bool> requestAuthorization() async {
    return await Health().requestAuthorization([
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
    ]);
  }
  ```

- [ ] **Data Safety form** compilato su Play Console
  - [ ] Specify: Weight, Height, Body Fat collected
  - [ ] Purpose: "App functionality" (fitness tracking)
  - [ ] Data encrypted in transit: YES
  - [ ] Data encrypted at rest: YES (Hive encryption)
  - [ ] User can request deletion: YES

#### 🎯 FitLog Specific Verification

**Check esistente implementazione**:

```bash
# 1. Verifica Info.plist (iOS)
cat ios/Runner/Info.plist | grep -A1 "NSHealth"

# 2. Verifica AndroidManifest.xml
cat android/app/src/main/AndroidManifest.xml | grep "health"

# 3. Verifica health_kit_service.dart
grep -n "requestAuthorization\|getHealthDataFromTypes" \
  lib/features/body_measurements/data/services/health_kit_service.dart

# 4. Verifica che NO advertising use
grep -rn "health\|HealthKit" lib/ | grep -i "analytics\|ads\|marketing"
# Output atteso: NESSUN match (altrimenti violation!)
```

**Manual test**:

- [ ] **iOS**: Launch app → Body Measurements → Tap "Sync with Apple Health"
  - [ ] Permission dialog appare con clear description
  - [ ] User può accept/deny
  - [ ] Se denied → fallback graceful (no crash)
  - [ ] Se accepted → dati synced correttamente

- [ ] **Android**: Launch app → Body Measurements → Tap "Sync with Health Connect"
  - [ ] Redirige a Health Connect app per permission
  - [ ] User può grant access per data types specifici
  - [ ] Dati synced correttamente dopo permission

**App Store / Play Store Review Notes**:

- [ ] Prepara nota per reviewer:
  ```
  HealthKit / Health Connect Usage:
  - FitLog uses health data ONLY to display user's body measurement
    progress (weight, body fat, height) in charts and analytics.
  - NO advertising use.
  - NO third-party sharing.
  - User can delete all data via Settings → Delete Account.
  - Privacy Policy: [link]
  ```

---

## 6. DevOps & Release

### 6.1 Build Pipeline

#### ✅ CI/CD

- [ ] **Automated builds** (GitHub Actions / Codemagic / etc.)
  ```yaml
  # .github/workflows/build.yml
  name: Build
  on: [push, pull_request]

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - uses: subosito/flutter-action@v2
        - run: flutter test
        - run: flutter analyze

    build-ios:
      runs-on: macos-latest
      steps:
        - run: flutter build ios --release --no-codesign

    build-android:
      runs-on: ubuntu-latest
      steps:
        - run: flutter build appbundle
  ```

- [ ] **Automated tests** in CI
- [ ] **Code signing** automatizzato (Fastlane)

#### ✅ Versioning

- [ ] **Semantic versioning** (MAJOR.MINOR.PATCH)
  ```yaml
  # pubspec.yaml
  version: 1.2.3+45
  # 1.2.3 = version name (user-facing)
  # 45 = build number (incrementale)
  ```

- [ ] **Changelog** mantenuto
  ```markdown
  # CHANGELOG.md

  ## [1.2.3] - 2024-02-02
  ### Added
  - Weight suggestion service
  - Health Connect support

  ### Fixed
  - Auth token refresh loop
  - Firestore permission denied on body measurements

  ### Changed
  - Onboarding flow now collects age and height
  ```

- [ ] **Git tags** per release
  ```bash
  git tag -a v1.2.3 -m "Release 1.2.3"
  git push origin v1.2.3
  ```

---

### 6.2 Release Process

#### ✅ Pre-Release Checklist

- [ ] **All tests pass**
  ```bash
  flutter test
  flutter analyze
  ```

- [ ] **Version bumped** in pubspec.yaml
- [ ] **Changelog updated**
- [ ] **Release notes drafted** (user-friendly)
  ```
  🎉 What's New in v1.2.3

  ✨ Smart weight suggestions based on your history
  💪 Android Health Connect integration
  📊 Redesigned onboarding with personalization

  🐛 Bug Fixes
  - Fixed workout timer not resuming after background
  - Resolved crash on exercise search
  ```

- [ ] **Firebase deployed**
  ```bash
  firebase deploy --only firestore:rules,functions
  ```

- [ ] **Feature flags** configurati (se usati)
  ```dart
  // Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(minutes: 1),
    minimumFetchInterval: Duration(hours: 1),
  ));

  final newFeatureEnabled = remoteConfig.getBool('new_feature_enabled');
  ```

#### ✅ Beta Testing

- [ ] **TestFlight** (iOS) o **Internal Testing** (Android)
- [ ] **Beta testers recruited** (10-100 persone)
- [ ] **Feedback form** integrato
  ```dart
  // In-app feedback
  showDialog(
    context: context,
    builder: (_) => FeedbackDialog(
      onSubmit: (feedback) async {
        await analytics.logEvent('beta_feedback', {
          'message': feedback,
          'version': packageInfo.version,
        });
      },
    ),
  );
  ```

- [ ] **Crash reporting attivo** (Crashlytics)
  ```dart
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
  ```

#### ✅ Production Release

- [ ] **Staged rollout** (iOS: phased release, Android: staged rollout 10% → 50% → 100%)
- [ ] **Monitor crash rate** (target: < 0.1%)
- [ ] **Monitor ANR rate** (target: < 0.5%)
- [ ] **Monitor performance** (Firebase Performance Monitoring)

---

### 6.3 Rollback Plan

- [ ] **Previous version APK/IPA** salvato
- [ ] **Rollback procedure** documentata
  ```bash
  # Se release 1.2.3 ha bug critico:
  # 1. Stop rollout in Play Console / App Store Connect
  # 2. Publish hotfix 1.2.4 con fix
  # 3. Oppure revert a 1.2.2
  ```

- [ ] **Feature kill switch** (Remote Config)
  ```dart
  if (remoteConfig.getBool('disable_new_feature')) {
    return OldWorkoutScreen();
  } else {
    return NewWorkoutScreen();
  }
  ```

---

### 6.4 Disaster Recovery ⭐ NEW

**Scope**: Piano semplificato per indie app (non enterprise). FitLog usa Firebase managed services, quindi infrastruttura è gestita da Google.

#### ✅ Backup Strategy

**Firebase Automatic Backups**:

- [ ] **Firestore automatic backups** abilitati
  ```bash
  # Firebase Console → Firestore → Settings → Backups
  # Enable automatic daily backups
  # Retention: 7 giorni (daily) + 4 settimane (weekly)
  ```

- [ ] **Authentication backup** (export users)
  ```bash
  # Ogni settimana, export Firebase Auth users
  firebase auth:export users.json --project fitlog-prod

  # Store in secure location:
  # - Google Drive (encrypted folder)
  # - AWS S3 (private bucket)
  ```

- [ ] **Cloud Functions backup** (già in git)
  ```bash
  # Cloud Functions code è già in git
  # Ensure git remote è up-to-date
  cd functions/
  git push origin main
  ```

- [ ] **Hive local data** backup educato all'utente
  ```dart
  // In Settings → Backup Data
  Future<File> exportUserData() async {
    final allData = {
      'workouts': await workoutRepository.getAll(),
      'exercises': await customExerciseRepository.getAll(),
      'measurements': await measurementRepository.getAll(),
    };

    final json = jsonEncode(allData);
    final file = File('${userId}_backup.json');
    await file.writeAsString(json);

    // Share via platform share sheet
    await Share.shareXFiles([XFile(file.path)]);
    return file;
  }
  ```

#### ✅ Recovery Procedures

**Scenario 1: Firestore data corruption**

1. Stop app deployment (App Store / Play Store)
2. Restore from Firestore backup:
   ```bash
   # Firebase Console → Firestore → Backups
   # Select backup point → Restore to new collection
   # Verify data integrity
   # Switch app to new collection (via Remote Config flag)
   ```
3. Monitor for 24h
4. Resume deployment

**Scenario 2: Cloud Functions failure**

1. Check Firebase Console → Functions → Logs
2. Identify failing function
3. Rollback to previous deployment:
   ```bash
   cd functions/
   git log --oneline  # Find last working commit
   git checkout <commit-hash>
   firebase deploy --only functions --project fitlog-prod
   ```
4. Fix issue in separate branch
5. Deploy fix after testing

**Scenario 3: Critical app bug in production**

1. Stop staged rollout (Play Store: 10% → pause)
2. Hotfix branch:
   ```bash
   git checkout -b hotfix/critical-bug-fix
   # Fix bug
   flutter test  # Verify fix
   git commit -m "hotfix: resolve critical workout crash"
   ```
3. Deploy hotfix 1.2.4
4. Resume rollout after 24h monitoring

**Scenario 4: User data lost** (user contacts support)

1. Check Firestore backup for user ID
2. If exists → restore specific user data:
   ```javascript
   // Cloud Function: restoreUserData
   const backup = await admin.firestore()
     .collection('backups')
     .doc('2024-02-01')
     .collection('users')
     .doc(userId)
     .get();

   await admin.firestore()
     .collection('users')
     .doc(userId)
     .set(backup.data());
   ```
3. Notify user via email
4. Investigate root cause (delete bug?)

#### ✅ Monitoring & Alerts

**Firebase Alerts** (no on-call rotation per indie app):

- [ ] **Crashlytics alerts** → Email quando crash rate > 1%
  ```bash
  # Firebase Console → Crashlytics → Settings → Alerts
  # Enable: "Crash rate threshold" → 1%
  # Send to: your-email@example.com
  ```

- [ ] **Performance alerts** → Email quando app start > 6s
  ```bash
  # Firebase Console → Performance → Alerts
  # Enable: "App start time" → threshold 6s
  ```

- [ ] **Firestore quota alerts** → Email quando > 80% quota
  ```bash
  # Firebase Console → Firestore → Usage → Set alert threshold 80%
  ```

**No Complex Monitoring** (indie app non ha budget per PagerDuty/on-call):

- ❌ NO on-call rotation (solo tu, check email daily)
- ❌ NO 24/7 monitoring (Firebase gestisce infra)
- ❌ NO status page (usa Firebase Status: https://status.firebase.google.com)

#### ✅ Communication Plan

**Se outage critico** (app inutilizzabile per tutti gli utenti):

1. **Acknowledge** entro 1 ora (email + social media)
   ```
   Subject: FitLog Service Issue - We're investigating

   Hi everyone,

   We're aware that FitLog is currently experiencing issues.
   Our team is investigating and working on a fix.

   Updates: https://twitter.com/fitlog_app

   Thanks for your patience!
   ```

2. **Update** ogni 2 ore fino a risoluzione

3. **Post-mortem** entro 48 ore (cosa è successo, cosa abbiamo fixato, come preveniamo in futuro)

**Se bug non critico** (es. chart non carica):

- Fix in next release (1-2 settimane)
- Comunica via in-app banner: "We're aware of chart loading issues. Fix coming in next update."

#### 🎯 FitLog Specific

**Recovery priorities** (in ordine di importanza):

1. **Auth service** → Utenti non possono fare login
2. **Workout save** → Utenti perdono allenamenti
3. **Sync service** → Dati non si sincronizzano (tollerabile 24h)
4. **Charts** → Visualizzazione dati (tollerabile 48h)

**Backup schedule**:

- **Daily**: Firestore automatic backup (Firebase managed)
- **Weekly**: Firebase Auth export (manual script)
- **On release**: Full git tag + Firebase deployment snapshot

**RTO (Recovery Time Objective)**:

- Critical bug: < 4 ore (hotfix deployment)
- Data restore: < 2 ore (Firestore restore)
- Function failure: < 1 ora (rollback deployment)

**RPO (Recovery Point Objective)**:

- Firestore: max 24h data loss (daily backups)
- Hive: user responsibility (export feature provided)

---

## 7. Monitoring & Analytics

### 7.1 Crash Reporting

#### ✅ Setup

- [ ] **Firebase Crashlytics** integrato
  ```dart
  // main.dart
  await Firebase.initializeApp();

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  ```

- [ ] **Custom keys** per debug
  ```dart
  FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
  FirebaseCrashlytics.instance.setCustomKey('workout_id', workoutId);

  // Nel crash log vedrai questi valori
  ```

- [ ] **Non-fatal errors** tracked
  ```dart
  try {
    await riskyOperation();
  } catch (e, stack) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stack,
      fatal: false,
      reason: 'Failed to sync workout',
    );
  }
  ```

---

### 7.2 Analytics

#### ✅ Event Tracking

- [ ] **Core events** definiti
  ```dart
  enum AnalyticsEvent {
    appOpened,
    workoutStarted,
    workoutCompleted,
    exerciseAdded,
    prAchieved,
    userSignedUp,
    subscriptionPurchased,
  }
  ```

- [ ] **Event properties** consistenti
  ```dart
  await analytics.logEvent(
    name: 'workout_completed',
    parameters: {
      'duration_minutes': workout.duration.inMinutes,
      'exercise_count': workout.exercises.length,
      'total_volume': workout.totalVolume,
      'workout_type': workout.type,  // 'strength', 'cardio', etc.
    },
  );
  ```

- [ ] **User properties** impostate
  ```dart
  await analytics.setUserProperty(
    name: 'tier',
    value: userTier.name,  // 'starter', 'bronze', etc.
  );

  await analytics.setUserProperty(
    name: 'workouts_completed',
    value: totalWorkouts.toString(),
  );
  ```

#### ✅ Business Metrics

- [ ] **Funnel tracking**
  ```
  Onboarding:
  1. app_opened
  2. onboarding_started
  3. onboarding_step_1_completed (age/height)
  4. onboarding_step_2_completed (goals)
  5. onboarding_completed
  6. first_workout_created
  ```

- [ ] **Retention metrics**
  - DAU (Daily Active Users)
  - WAU / MAU
  - D1, D7, D30 retention

- [ ] **Revenue metrics** (se premium)
  ```dart
  await analytics.logEvent(
    name: 'purchase',
    parameters: {
      'value': 9.99,
      'currency': 'USD',
      'item_id': 'premium_monthly',
    },
  );
  ```

---

### 7.3 Performance Monitoring

#### ✅ Firebase Performance

- [ ] **Automatic traces** (app start, network)
  ```dart
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  ```

- [ ] **Custom traces** per operazioni chiave
  ```dart
  final trace = FirebasePerformance.instance.newTrace('workout_save');
  await trace.start();

  try {
    await saveWorkout(workout);
    trace.setMetric('exercise_count', workout.exercises.length);
    trace.putAttribute('workout_type', workout.type);
  } finally {
    await trace.stop();
  }
  ```

- [ ] **HTTP metric** tracking
  ```dart
  // Automatico per HttpClient
  // Oppure custom:
  final metric = FirebasePerformance.instance.newHttpMetric(
    url,
    HttpMethod.Get,
  );
  await metric.start();

  final response = await http.get(url);
  metric.setHttpResponseCode(response.statusCode);
  metric.setResponseContentType(response.headers['content-type']);

  await metric.stop();
  ```

---

### 7.4 Logging

#### ✅ Structured Logging

- [ ] **Log levels** appropriati
  ```dart
  logger.debug('Cache hit for workout ${workout.id}');
  logger.info('User logged in: $userId');
  logger.warning('Sync delayed: offline mode');
  logger.error('Failed to save workout', error, stackTrace);
  ```

- [ ] **Remote logging** (Firebase/Sentry)
  ```dart
  // Production → no print(), usa logger che invia a remote
  if (kReleaseMode) {
    Logger.root.onRecord.listen((record) {
      if (record.level >= Level.WARNING) {
        FirebaseCrashlytics.instance.log(
          '${record.level.name}: ${record.message}',
        );
      }
    });
  }
  ```

- [ ] **PII redaction**
  ```dart
  // ❌ BAD
  logger.info('User email: $email');

  // ✅ GOOD
  logger.info('User logged in', extra: {'userId': userId});  // No email
  ```

---

## 8. Documentazione

### 8.1 Code Documentation

#### ✅ Inline Docs

- [ ] **DartDoc per API pubbliche**
  ```dart
  /// Calculates the total volume for a workout.
  ///
  /// Volume is computed as sum of (reps × weight) for all sets.
  ///
  /// Example:
  /// ```dart
  /// final volume = calculateVolume([
  ///   Set(reps: 10, weight: 100),
  ///   Set(reps: 8, weight: 100),
  /// ]);
  /// print(volume); // 1800
  /// ```
  ///
  /// Returns 0 if [sets] is empty.
  double calculateVolume(List<Set> sets) {
    return sets.fold(0, (sum, set) => sum + set.reps * set.weight);
  }
  ```

- [ ] **README files** per module complessi
  ```
  lib/features/workout/
  ├── README.md  # Spiega architettura workout feature
  ├── domain/
  ├── data/
  └── presentation/
  ```

---

### 8.2 User Documentation

#### ✅ End User

- [ ] **In-app help/tutorial**
  ```dart
  // Onboarding tooltips
  TutorialOverlay(
    steps: [
      TutorialStep(
        target: #addWorkoutButton,
        message: 'Tap here to create your first workout',
      ),
    ],
  )
  ```

- [ ] **FAQ** (in app o website)
- [ ] **Support email/chat** link

#### ✅ Developer

- [ ] **README.md** completo
  ```markdown
  # FitLog Pro

  ## Setup
  1. Clone repo
  2. `flutter pub get`
  3. Copy `.env.example` to `.env`
  4. `flutter run`

  ## Architecture
  - Clean Architecture
  - Riverpod for state
  - Firestore + Hive hybrid

  ## Testing
  `flutter test`

  ## Deploy
  See [DEPLOYMENT.md](DEPLOYMENT.md)
  ```

- [ ] **CONTRIBUTING.md** (se open source)
- [ ] **Architecture docs** (diagrams)

---

## 9. Internationalization ⭐ NEW

> FitLog supporta **Italiano (IT)** e **Inglese (EN)** completi. Questa sezione verifica che tutte le stringhe siano tradotte e coerenti.

### 9.1 Localization Verification

#### ✅ ARB Files Completeness

**FitLog usa Flutter l10n** con ARB files:

```
lib/shared/presentation/l10n/
├── app_en.arb  # Inglese (default)
└── app_it.arb  # Italiano
```

- [ ] **Tutte le chiavi presenti in entrambi i file**
  ```bash
  # Script per verificare chiavi mancanti
  .claude/scripts/l10n-check.sh

  # Output:
  # ✅ app_en.arb: 247 keys
  # ✅ app_it.arb: 247 keys
  # ✅ No missing keys
  ```

- [ ] **No placeholder "[...]" nelle traduzioni**
  ```bash
  # Check per placeholder non tradotti
  grep -n "\[\.\.\.\]" lib/shared/presentation/l10n/app_*.arb

  # ❌ BAD
  "exerciseDetail": "Exercise detail [...]"

  # ✅ GOOD
  "exerciseDetail": "Dettaglio esercizio"
  ```

- [ ] **Variabili placeholder consistenti**
  ```json
  // app_en.arb
  {
    "workoutCompleted": "Workout completed in {duration} minutes",
    "@workoutCompleted": {
      "placeholders": {
        "duration": {"type": "int"}
      }
    }
  }

  // app_it.arb - stessi placeholder
  {
    "workoutCompleted": "Allenamento completato in {duration} minuti",
    "@workoutCompleted": {
      "placeholders": {
        "duration": {"type": "int"}
      }
    }
  }
  ```

- [ ] **Plurals gestiti correttamente**
  ```json
  // app_en.arb
  {
    "exerciseCount": "{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}",
    "@exerciseCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    }
  }

  // app_it.arb
  {
    "exerciseCount": "{count, plural, =0{Nessun esercizio} =1{1 esercizio} other{{count} esercizi}}",
    "@exerciseCount": {
      "placeholders": {
        "count": {"type": "int"}
      }
    }
  }
  ```

#### ✅ Code Verification

- [ ] **NO hardcoded strings in UI**
  ```dart
  // ❌ BAD - Hardcoded
  Text('Workout completed')

  // ✅ GOOD - Localized
  Text(context.l10n.workoutCompleted)
  ```

  **Verifica automatica**:
  ```bash
  # Script che trova hardcoded strings
  .claude/scripts/find-hardcoded-strings.sh lib/

  # Output:
  # lib/features/workout/presentation/screens/workout_screen.dart:123
  #   Text('Start workout')  // ❌ Should use context.l10n.startWorkout
  ```

- [ ] **NO `const` con `context.l10n`** (causa iOS build error)
  ```dart
  // ❌ BAD - iOS build error
  const Text(context.l10n.title)

  // ✅ GOOD
  Text(context.l10n.title)
  ```

- [ ] **AppLocalizations importato correttamente**
  ```dart
  import 'package:flutter_gen/gen_l10n/app_localizations.dart';

  // Accesso
  final l10n = AppLocalizations.of(context)!;
  // Oppure extension
  context.l10n.workoutCompleted
  ```

- [ ] **Generated files up-to-date**
  ```bash
  # Rigenera localization files
  flutter gen-l10n

  # Verifica che non ci siano modifiche non committate
  git status lib/shared/presentation/l10n/generated/
  # Output: nothing to commit (se up-to-date)
  ```

#### ✅ Language-Specific Content

- [ ] **Date/Time formatting** locale-aware
  ```dart
  // ❌ BAD - Hard-coded US format
  '${date.month}/${date.day}/${date.year}'

  // ✅ GOOD - Locale-aware
  import 'package:intl/intl.dart';

  DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date)
  // EN: Jan 15, 2024
  // IT: 15 gen 2024
  ```

- [ ] **Number formatting** locale-aware
  ```dart
  // ❌ BAD
  '${weight.toStringAsFixed(1)} kg'

  // ✅ GOOD
  import 'package:intl/intl.dart';

  final formatter = NumberFormat.decimalPattern(
    Localizations.localeOf(context).toString(),
  );
  '${formatter.format(weight)} kg'
  // EN: 75.5 kg
  // IT: 75,5 kg (virgola invece di punto)
  ```

- [ ] **Currency** (se premium implementato)
  ```dart
  import 'package:intl/intl.dart';

  final formatter = NumberFormat.currency(
    locale: Localizations.localeOf(context).toString(),
    symbol: '€',
  );
  formatter.format(9.99)
  // EN: €9.99
  // IT: 9,99 €
  ```

#### ✅ Testing

- [ ] **Test both locales**
  ```dart
  // test/shared/presentation/l10n_test.dart

  void main() {
    testWidgets('Displays Italian text when locale is IT', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkoutScreen(),
        ),
      );

      expect(find.text('Allenamento'), findsOneWidget);
      expect(find.text('Workout'), findsNothing);
    });
  }
  ```

- [ ] **Device locale change test** (manual)
  - Change device to Italian → Launch app → Verify UI in Italian
  - Change device to English → Launch app → Verify UI in English
  - Change device to French (unsupported) → App defaults to English

#### ✅ Store Listings

- [ ] **App Store metadata** tradotto
  - **EN**: Name, Subtitle, Description, Keywords, Screenshots
  - **IT**: Nome, Sottotitolo, Descrizione, Parole chiave, Screenshot

- [ ] **Play Store metadata** tradotto
  - **EN**: Short description, Full description, Screenshots
  - **IT**: Descrizione breve, Descrizione completa, Screenshot

- [ ] **In-app purchase descriptions** tradotti (se premium)
  - Product names
  - Descriptions
  - Benefits list

#### 🎯 FitLog Specific Checks

**Exercise database**:

- [ ] Exercise names tradotti in `assets/exercises/`
  ```json
  // exercises_en.json
  {
    "name": "Bench Press",
    "description": "Horizontal pressing movement..."
  }

  // exercises_it.json
  {
    "name": "Panca Piana",
    "description": "Movimento di spinta orizzontale..."
  }
  ```

**Muscle groups**:

- [ ] Muscle names tradotti
  ```dart
  enum MuscleGroup {
    chest,     // EN: Chest,     IT: Petto
    back,      // EN: Back,      IT: Dorso
    shoulders, // EN: Shoulders, IT: Spalle
    legs,      // EN: Legs,      IT: Gambe
    arms,      // EN: Arms,      IT: Braccia
    core,      // EN: Core,      IT: Core
  }
  ```

**Achievements**:

- [ ] Achievement titles e descriptions tradotti
  ```json
  // app_en.arb
  "achievementFirstWorkout": "First Workout",
  "achievementFirstWorkoutDesc": "Complete your first workout"

  // app_it.arb
  "achievementFirstWorkout": "Primo Allenamento",
  "achievementFirstWorkoutDesc": "Completa il tuo primo allenamento"
  ```

---

## 10. Legal & Compliance

### 9.1 Legal Documents

- [ ] **Terms of Service**
  - User responsibilities
  - Acceptable use policy
  - Account termination conditions

- [ ] **Privacy Policy**
  - Data collected (personal, usage, device)
  - How data is used
  - Third-party sharing
  - User rights (access, deletion, export)
  - Contact info for privacy requests

- [ ] **EULA** (End User License Agreement)
  - License grant
  - Restrictions
  - Warranties disclaimer
  - Limitation of liability

- [ ] **Copyright notices** in code
  ```dart
  // Copyright (c) 2024 YourCompany. All rights reserved.
  ```

---

### 9.2 Third-Party Compliance

- [ ] **Open source licenses** rispettate
  ```bash
  # Generate licenses page
  flutter pub licenses

  # In app
  showLicensePage(
    context: context,
    applicationName: 'FitLog Pro',
    applicationVersion: '1.2.3',
  );
  ```

- [ ] **API terms** seguiti
  - Firebase terms
  - Apple HealthKit terms (no advertising use)
  - Google Fit / Health Connect terms

- [ ] **Trademark compliance**
  - No uso non autorizzato di loghi
  - Attribuzione corretta (es. "Powered by Firebase")

---

### 9.3 App Store Compliance

#### ✅ Apple App Store

- [ ] **Review Guidelines** rispettate
  - No bug/crash critici
  - No link a payment esterni (no Stripe web checkout)
  - Funzionalità complete (no placeholder)

- [ ] **Metadata completo**
  - App name (max 30 chars)
  - Subtitle (max 30 chars)
  - Description (max 4000 chars)
  - Keywords (max 100 chars, comma-separated)
  - Screenshots (6.7", 6.5", 5.5" + iPad)

- [ ] **Age rating** corretto
  - Questionario in App Store Connect

#### ✅ Google Play Store

- [ ] **Policy compliance**
  - No contenuto vietato
  - Data safety form compilato
  - Target API level aggiornato (Android 13+)

- [ ] **Metadata completo**
  - Short description (80 chars)
  - Full description (4000 chars)
  - Screenshots (phone + tablet + feature graphic)

---

## 11. Go-Live Checklist

### 🚀 Final Pre-Launch

#### ✅ 1 Week Before

- [ ] **Beta testing completato**
  - Feedback raccolto e implementato
  - Crash rate < 0.1%

- [ ] **Store listings** preparati
  - Screenshots finali
  - Description ottimizzata (SEO keywords)
  - Promo video (opzionale ma consigliato)

- [ ] **Support infrastructure**
  - Email support@ configurata
  - FAQ pubblicata
  - Status page (se backend custom)

- [ ] **Marketing ready**
  - Website/landing page
  - Social media accounts
  - Press kit (logo, screenshots, description)

#### ✅ 1 Day Before

- [ ] **Final smoke test**
  - Fresh install su device pulito
  - Test tutti i critical flows
  - Verify analytics/crashlytics funzionano

- [ ] **Backend health check**
  - Firebase quota OK (Firestore, Functions, Storage)
  - API rate limits configurati
  - CDN (se usato) funzionante

- [ ] **Team aligned**
  - On-call rotation (chi risponde a crash alerts)
  - Communication plan (chi annuncia launch)

#### ✅ Launch Day

- [ ] **Submit to stores**
  - iOS: Submit for review (1-3 giorni review)
  - Android: Publish (review 1-48 ore)

- [ ] **Monitor dashboards**
  - Firebase Console → Crashlytics
  - Firebase Console → Analytics
  - Firebase Console → Performance

- [ ] **Staged rollout** (Android)
  - Start 10% → wait 24h → 50% → 100%

- [ ] **Respond to reviews**
  - Reply to negative reviews entro 24h
  - Thank positive reviewers

---

### 📊 Post-Launch Monitoring

#### ✅ First 24 Hours

- [ ] **Crash rate** < 0.1%
  - Se > 0.5% → investigate immediately
  - Se > 1% → consider rollback

- [ ] **Performance**
  - App start time < 3s
  - Frame rate > 55 fps

- [ ] **Funnel metrics**
  - Onboarding completion rate > 60%
  - D1 retention > 40%

#### ✅ First Week

- [ ] **User feedback** review
  - Categorize issues (bug, feature request, confusion)
  - Prioritize fixes

- [ ] **Analytics review**
  - Top screens
  - Drop-off points
  - Feature usage

- [ ] **Plan hotfix** se necessario
  - Critical bugs → hotfix 1.2.4 entro 48h
  - Minor bugs → next release 1.3.0

---

## 🎯 Summary: Production-Ready = ?

Un'app è **production-ready** quando:

✅ **Codebase** è pulito, testato, e manutenibile
✅ **Design** è coerente, accessibile (WCAG 2.1 AA), e polished
✅ **Testing** copre almeno l'80% del business logic
✅ **Performance** raggiunge target realistici (< 4s cold start, < 150MB memory)
✅ **Security** protegge dati utente, rispetta GDPR, e compliance HealthKit/Health Connect ⭐
✅ **DevOps** ha CI/CD, versioning, rollback plan, e disaster recovery ⭐
✅ **Monitoring** traccia crash, analytics, e performance
✅ **Documentation** aiuta developer e utenti
✅ **Internationalization** supporta IT+EN completamente ⭐
✅ **Legal** ha ToS, Privacy Policy, e compliance store
✅ **Launch plan** ha beta testing, staged rollout, e support ready

---

## 🔗 Related Docs

- [Development Rules](DEVELOPMENT_RULES.md) - Regole specifiche FitLog
- [Code Patterns](CODE_PATTERNS.md) - Pattern architetturali
- [Design Guidelines](DESIGN_GUIDELINES.md) - Design system
- [Testing Strategy](testing/STRATEGY.md) - Approccio testing
- [Consultant Feedback Analysis](CONSULTANT_FEEDBACK_ANALYSIS.md) - Analisi pragmatica suggerimenti esterni

---

## 📝 Changelog

### v2.0 (2026-02-02)

**Aggiunte**:
- ✅ **Performance Benchmarks** (Sezione 4.0) - Target realistici per Firebase+Hive stack
- ✅ **HealthKit/Health Connect Compliance** (Sezione 5.4) - Verifiche compliance iOS/Android health APIs
- ✅ **Disaster Recovery** (Sezione 6.4) - Piano semplificato per indie app
- ✅ **Internationalization** (Sezione 9) - Verifica completezza traduzioni IT+EN
- ✅ **Extended Accessibility** (Sezione 2.3) - WCAG 2.1 Level AA dettagliato (contrast 4.5:1, touch targets 44x44pt)

**Motivazione**:
Integrare suggerimenti appropriati da consulente esterno, mantenendo focus su app wellness (non medical device) in testing phase con 1 utente.

### v1.0 (2026-02-02)

Release iniziale con 10 sezioni core.

---

**Mantenuto da**: Development Team
**Prossima revisione**: Dopo ogni major release
