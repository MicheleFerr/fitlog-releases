# Bottom Navigation con StatefulShellRoute - Design Document

**Generated**: 2025-01-25
**Source**: Brainstorming session con ricerche web
**Complexity Score**: HIGH
**Total Tasks**: 14
**Estimated Time**: ~8h
**Plan Version**: 1.1
**Last Validated**: 2025-01-25 (Best Practices 2024/2025 ✅)

---

## 1. Overview

### Problema
L'app FitLog Pro attualmente non ha bottom navigation. La navigazione avviene solo tramite push/pop, causando:
- 70% drop-off rate (benchmark fitness apps)
- UX confusa per raggiungere feature (es. notifiche)
- Nessuna state preservation tra schermate

### Soluzione
Implementare **bottom navigation persistente** con **GoRouter StatefulShellRoute** seguendo best practices 2024-2025.

### Impatto Atteso
- +50% discoverability feature ([NN/Group](https://www.nngroup.com/articles/mobile-navigation-patterns/))
- +86% utilizzo navigazione vs hamburger menu ([Smashing Magazine](https://www.smashingmagazine.com/2019/08/bottom-navigation-pattern-mobile-web-pages/))
- State preservation per ogni tab

---

## 2. Architettura

### 2.1 Struttura File

```
lib/app/
├── app.dart                      # Esistente (modifiche minime)
├── router/
│   ├── app_router.dart           # GoRouter con StatefulShellRoute
│   ├── route_names.dart          # Costanti nomi route
│   ├── navigator_keys.dart       # GlobalKey per branch
│   └── branches/
│       ├── home_branch.dart      # Routes Home tab
│       ├── workout_branch.dart   # Routes Workout tab
│       ├── analytics_branch.dart # Routes Analytics tab
│       └── settings_branch.dart  # Routes Settings tab
└── shell/
    └── main_shell.dart           # Scaffold + NavigationBar
```

### 2.2 Flusso Navigazione

```
GoRouter (rootNavigatorKey)
├── /login, /register (fuori shell)
├── /workout-active, /workout-completion (fullscreen, fuori shell)
└── StatefulShellRoute.indexedStack
    ├── Branch 0: Home (homeNavigatorKey)
    │   ├── / (HomeScreenOptimized)
    │   ├── /ai-coach
    │   └── /community
    ├── Branch 1: Workout (workoutNavigatorKey)
    │   ├── /workout (WorkoutHubScreen)
    │   ├── /workout/history
    │   └── /workout/exercises
    ├── Branch 2: Analytics (analyticsNavigatorKey)
    │   ├── /analytics
    │   ├── /analytics/overview
    │   ├── /analytics/exercise/:name
    │   └── /analytics/progress
    └── Branch 3: Settings (settingsNavigatorKey)
        ├── /settings
        ├── /settings/notifications  <-- FIX UX GAP
        ├── /settings/health-sync
        └── /settings/admin
```

---

## 3. Componenti

### 3.1 MainShell Widget

**Widget**: `NavigationBar` (Material 3, NON BottomNavigationBar)

**Configurazione**:
- 4 destinations: Home, Workout, Analytics, Settings
- Labels sempre visibili
- Icone filled/outline per stato
- Badge per notifiche non lette
- Height: 80dp (touch-friendly)

**Fonti**:
- [Flutter API - NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)
- [how.dev - Material 3 Bottom Navigation](https://how.dev/answers/how-to-create-a-material-3-bottom-navigation-bar-in-flutter)

### 3.2 Navigator Keys

```dart
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final workoutNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'workout');
final analyticsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');
```

### 3.3 Route Names

```dart
abstract class RouteNames {
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const aiCoach = 'ai-coach';
  static const community = 'community';
  static const workout = 'workout';
  static const workoutActive = 'workout-active';
  static const workoutHistory = 'workout-history';
  static const workoutCompletion = 'workout-completion';
  static const exercises = 'exercises';
  static const analytics = 'analytics';
  static const analyticsOverview = 'analytics-overview';
  static const exerciseDetail = 'exercise-detail';
  static const exerciseProgress = 'exercise-progress';
  static const settings = 'settings';
  static const notifications = 'notifications';
  static const healthSync = 'health-sync';
  static const admin = 'admin';
}
```

---

## 4. Best Practices Applicate

| Best Practice | Implementazione | Fonte |
|---------------|-----------------|-------|
| StatefulShellRoute.indexedStack | Default per bottom nav | [GoRouter Docs](https://pub.dev/packages/go_router) |
| NavigatorKey per branch | Evita rebuild | [Code with Andrea](https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/) |
| NoTransitionPage per tab | UX iOS-like | [DEV Community](https://dev.to/7twilight/mastering-nested-navigation-in-flutter-with-gorouter-and-a-bottom-nav-bar-555l) |
| parentNavigatorKey per fullscreen | Nasconde bottom nav | [Stack Overflow](https://stackoverflow.com/questions/76575211) |
| NavigationBar (M3) | Sostituisce BottomNavigationBar | [Flutter API](https://api.flutter.dev/flutter/material/NavigationBar-class.html) |
| Labels sempre visibili | UX best practice | [M3 Guidelines](https://m3.material.io/components/navigation-bar) |
| 4 destinations | 3-5 max raccomandato | [M3 Guidelines](https://m3.material.io/components/navigation-bar) |
| GoRouter come Provider | Evita hot reload crash | [Medium](https://medium.com/@dudek16/migration-to-go-router-devs-story-199f4ef6ed) |

---

## 5. Mappatura Route

| Route Attuale | Nuova Route | Branch | Modifica |
|---------------|-------------|--------|----------|
| `/` | `/` | Home | Invariata |
| `/workout` | `/workout` | Workout | Diventa Hub |
| - | `/workout-active` | Fullscreen | Nuova |
| `/workout-completion-summary` | `/workout-completion` | Fullscreen | Rinominata |
| `/analytics` | `/analytics` | Analytics | Invariata |
| `/settings` | `/settings` | Settings | Invariata |
| `/notifications-v2` | `/settings/notifications` | Settings | Spostata |
| `/health-sync` | `/settings/health-sync` | Settings | Spostata |
| `/workout-history` | `/workout/history` | Workout | Spostata |
| `/exercises` | `/workout/exercises` | Workout | Spostata |
| `/ai-coach` | `/ai-coach` | Home | Sub-route |
| `/community` | `/community` | Home | Sub-route |

---

## 6. Piano Implementazione

### Fase 0: Preparazione (30 min)
- [ ] Verifica go_router >= 7.1.0
- [ ] Crea branch: `feature/bottom-navigation`
- [ ] Leggi esempio ufficiale Flutter

### Fase 1: Struttura File (1h)
- [ ] Crea `lib/app/router/navigator_keys.dart`
- [ ] Crea `lib/app/router/route_names.dart`
- [ ] Crea `lib/app/router/branches/` folder
- [ ] Crea `lib/app/shell/main_shell.dart`

### Fase 2: MainShell Widget (1h)
- [ ] Implementa MainShell con NavigationBar
- [ ] Configura 4 destinations con icone
- [ ] Aggiungi localizzazione labels
- [ ] Aggiungi badge notifiche

### Fase 3: Branch Routes (2h)
- [ ] Implementa home_branch.dart
- [ ] Implementa workout_branch.dart
- [ ] Implementa analytics_branch.dart
- [ ] Implementa settings_branch.dart
- [ ] Implementa workoutFullscreenRoutes()

### Fase 4: Router Completo (1h)
- [ ] Implementa app_router.dart
- [ ] Configura StatefulShellRoute.indexedStack
- [ ] Configura auth redirect
- [ ] Aggiungi error builder

### Fase 5: Migrazione (1.5h)
- [ ] Update imports in app.dart
- [ ] Search/replace vecchie route paths
- [ ] Aggiorna context.go/push calls
- [ ] Rimuovi router inline da app.dart

### Fase 6: Testing (1h)
- [ ] Test navigazione tab
- [ ] Test deep linking
- [ ] Test state preservation
- [ ] Test fullscreen routes
- [ ] Test back button
- [ ] flutter analyze

---

## 7. Rischi e Mitigazioni

| Rischio | Probabilità | Mitigazione |
|---------|-------------|-------------|
| Hot reload crash | Media | GoRouter come Provider |
| Deep link broken | Bassa | Test ogni route |
| Back button issues | Media | initialLocation in goBranch |
| State loss | Bassa | indexedStack pattern |

---

## 8. Criteri di Successo

- [ ] Bottom navigation visibile su tutte le schermate (eccetto fullscreen)
- [ ] State preservation funzionante (scroll position, form inputs)
- [ ] Deep linking funzionante (`/analytics/exercise/bench-press`)
- [ ] Notifiche raggiungibili da Settings
- [ ] flutter analyze: 0 errori
- [ ] Test su iOS e Android

---

## 9. Validazione Best Practices 2024/2025

### ✅ Conferme da Ricerche Web

| Proposta | Validazione | Fonte |
|----------|-------------|-------|
| `StatefulShellRoute.indexedStack` | ✅ "Use for bottom-tabs, ensuring each tab has separate route branch and persistent state" | [Code With Andrea](https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/) |
| `NavigationBar` (M3) | ✅ "Introduced as replacement of BottomNavigationBar, preferred for Material 3 apps" | [Flutter API](https://api.flutter.dev/flutter/material/NavigationBar-class.html) |
| `parentNavigatorKey` per fullscreen | ✅ "To push route outside shell, assign parentNavigatorKey" | [Stack Overflow](https://stackoverflow.com/questions/76575211) |
| Navigator key per branch | ✅ "Each branch retains state and navigation history" | [DEV Community](https://dev.to/7twilight/mastering-nested-navigation-in-flutter-with-gorouter-and-a-bottom-nav-bar-555l) |
| State preservation | ✅ "Users can switch tabs without losing progress" | [Medium](https://medium.com/@mohitarora7272/stateful-nested-navigation-in-flutter-using-gorouters-statefulshellroute-and-statefulshellbranch-8bb91443edad) |

### ⚠️ Potenziali Issues (da monitorare)

| Issue | Mitigazione |
|-------|-------------|
| "Widget key conflicts or unexpected behavior with hot reloading" | GoRouter come Provider, test dopo ogni hot reload |
| "Some versions have bugs on Flutter Web" | Test cross-platform prima di deploy |

---

## 10. Riferimenti

### Documentazione Ufficiale
- [Flutter Official Example - StatefulShellRoute](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)
- [GoRouter Docs - StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
- [Material 3 Navigation Bar Guidelines](https://m3.material.io/components/navigation-bar)
- [Flutter API - NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)

### Tutorial e Guide (2024)
- [Code with Andrea - Bottom Navigation with GoRouter](https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/)
- [DEV Community - Mastering Nested Navigation](https://dev.to/7twilight/mastering-nested-navigation-in-flutter-with-gorouter-and-a-bottom-nav-bar-555l)
- [Medium - StatefulShellRoute and StatefulShellBranch](https://medium.com/@mohitarora7272/stateful-nested-navigation-in-flutter-using-gorouters-statefulshellroute-and-statefulshellbranch-8bb91443edad)
- [how.dev - Material 3 Bottom Navigation](https://how.dev/answers/how-to-create-a-material-3-bottom-navigation-bar-in-flutter)

### UX Research
- [NN/Group - Mobile Navigation Patterns](https://www.nngroup.com/articles/mobile-navigation-patterns/)
- [Smashing Magazine - Bottom Navigation Pattern](https://www.smashingmagazine.com/2019/08/bottom-navigation-pattern-mobile-web-pages/)
