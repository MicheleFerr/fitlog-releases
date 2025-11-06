# 🚀 New Onboarding System - Implementation Plan

**Created**: January 3, 2025
**Status**: Ready for Implementation
**Approach**: Phased Rollout (3 phases)
**Total Timeline**: 6+ weeks

---

## 📋 Executive Summary

**Goal**: Replace 8-step traditional onboarding with hybrid system combining:
- Quick Start (30 sec) for personalization
- Progressive Disclosure via LayerLink contextual overlays
- Guided First Workout for beginners (Fase 2)

**Expected Impact** (based on research):
- Retention: +40-50% via progressive disclosure
- Completion rate: 85%+ (vs 16% for 7-step tours)
- Time to value: <8 min in Fase 1, <5 min in Fase 2
- Support tickets: -30% via contextual help

**Key Principle**: "Learn by doing" - app itself is the tutorial, not fake screens.

---

## 🎯 Phase 1: MVP Foundation (Week 1-2)

### **Objectives**
- ✅ Remove current 8-step onboarding completely
- ✅ Implement Quick Start (beginner/expert choice)
- ✅ Build LayerLink contextual overlay system (reusable infrastructure)
- ✅ Redesign empty states (beginner vs expert differentiation)
- ✅ Integrate Firebase analytics for funnel tracking
- ✅ Test with 1 user (think-aloud protocol)

### **Success Criteria**
| Metric | Target |
|--------|--------|
| Quick Start completion | >90% |
| Empty State CTA click | 50-60% |
| Overlay engagement | >70% |
| Time to first workout | <8 min |
| First workout completion | >50% |
| User satisfaction | >7/10 |

---

## 📦 Phase 1: Technical Implementation

### **Task Breakdown (Week 1)**

#### **Day 1-2: Setup & Architecture**

**1. Create Feature Structure**
```bash
lib/features/onboarding/
├── domain/
│   ├── entities/
│   │   └── onboarding_state.dart (UPDATE - add new fields)
│   └── services/
│       └── contextual_overlay_manager.dart (NEW)
├── data/
│   └── repositories/
│       └── onboarding_repository.dart (UPDATE)
├── presentation/
│   ├── quick_start_screen.dart (NEW)
│   ├── widgets/
│   │   ├── contextual_overlay.dart (NEW)
│   │   └── home_empty_state_widget.dart (UPDATE)
│   └── providers/
│       ├── quick_start_provider.dart (NEW)
│       └── contextual_overlay_provider.dart (NEW)
```

**Files to Create:**
- `quick_start_screen.dart` - Single screen with 2 choices
- `contextual_overlay_manager.dart` - Service for overlay logic
- `contextual_overlay.dart` - Reusable widget with LayerLink + animation
- `quick_start_provider.dart` - Riverpod state for user choice

**Files to Update:**
- `onboarding_state.dart` - Add `userExperienceLevel`, `seenOverlays`, `overlayVersionSeen`
- `home_empty_state_widget.dart` - Differentiate beginner vs expert
- `app_router.dart` - Update routing to show QuickStartScreen on first launch

**Files to DELETE:**
- `global_onboarding_screen.dart` (old 8-step onboarding)
- All `widgets/steps/*.dart` (01-08 steps)

---

#### **2. Update OnboardingState Schema (Hive)**

**File**: `lib/features/onboarding/domain/entities/onboarding_state.dart`

```dart
@HiveType(typeId: 2)
class OnboardingState {
  // EXISTING FIELDS (keep)
  @HiveField(0)
  final bool hasSeenGlobalOnboarding;

  @HiveField(1)
  final bool hasStarted;

  // NEW FIELDS
  @HiveField(10)
  final String? userExperienceLevel; // 'beginner' | 'expert' | null

  @HiveField(11)
  final List<String> seenOverlays; // ['createWorkoutCTA', 'addExerciseHelp']

  @HiveField(12)
  final int overlayVersionSeen; // v1, v2 (for deprecation)

  @HiveField(13)
  final DateTime? quickStartCompletedAt;

  @HiveField(14)
  final bool hasCompletedFirstWorkout; // trigger for Phase 2

  OnboardingState({
    this.hasSeenGlobalOnboarding = false,
    this.hasStarted = false,
    this.userExperienceLevel,
    this.seenOverlays = const [],
    this.overlayVersionSeen = 1,
    this.quickStartCompletedAt,
    this.hasCompletedFirstWorkout = false,
  });

  // Add copyWith, fromJson, toJson methods
}
```

**Command to run:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

#### **3. Create Quick Start Screen**

**File**: `lib/features/onboarding/presentation/quick_start_screen.dart`

**UI Design:**
```
┌─────────────────────────────────────┐
│  👋 Benvenuto in GymBro!            │
│                                     │
│  Hai già esperienza in palestra?   │
│                                     │
│  ┌─────────────┐  ┌──────────────┐ │
│  │ Sì, sono    │  │ No, sono     │ │
│  │ esperto 💪  │  │ nuovo 🌱     │ │
│  └─────────────┘  └──────────────┘ │
│                                     │
│  [Salta per ora →]                  │
└─────────────────────────────────────┘
```

**Implementation:**
```dart
class QuickStartScreen extends ConsumerStatefulWidget {
  const QuickStartScreen({super.key});

  @override
  ConsumerState<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends ConsumerState<QuickStartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero icon with animation
              FadeTransition(
                opacity: _animController,
                child: Icon(
                  AppIcons.workout,
                  size: AppIconSize.xxlarge,
                  color: context.iconPrimary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                context.l10n.quickStartTitle,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Question
              Text(
                context.l10n.quickStartQuestion,
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Beginner button
              _ChoiceButton(
                label: context.l10n.quickStartBeginner,
                icon: AppIcons.beginnerflag,
                onTap: () => _selectPath('beginner'),
              ),

              const SizedBox(height: 16),

              // Expert button
              _ChoiceButton(
                label: context.l10n.quickStartExpert,
                icon: AppIcons.trophy,
                onTap: () => _selectPath('expert'),
              ),

              const SizedBox(height: 32),

              // Skip button
              TextButton(
                onPressed: _skip,
                child: Text(context.l10n.quickStartSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectPath(String path) async {
    // Haptic feedback
    HapticFeedback.selectionClick();

    // Save choice
    await ref.read(onboardingStateProvider.notifier).setUserExperienceLevel(path);

    // Track analytics
    ref.read(analyticsServiceProvider).logEvent(
      name: 'quick_start_completed',
      parameters: {
        'user_path': path,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Navigate to Home
    if (mounted) {
      context.goNamed('home');
    }
  }

  void _skip() {
    // Track skip
    ref.read(analyticsServiceProvider).logEvent(
      name: 'quick_start_skipped',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );

    context.goNamed('home');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: AppIconSize.large, color: context.iconPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.titleMedium,
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppIconSize.medium,
              color: context.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Localization (add to app_en.arb & app_it.arb):**
```json
{
  "quickStartTitle": "Welcome to GymBro!",
  "quickStartQuestion": "Do you have gym experience?",
  "quickStartBeginner": "No, I'm new 🌱",
  "quickStartExpert": "Yes, I'm experienced 💪",
  "quickStartSkip": "Skip for now"
}
```

---

#### **4. Create ContextualOverlayManager Service**

**File**: `lib/features/onboarding/domain/services/contextual_overlay_manager.dart`

```dart
class ContextualOverlayManager {
  final OnboardingRepository _repository;
  final AnalyticsService _analytics;

  ContextualOverlayManager(this._repository, this._analytics);

  /// Check if overlay should be shown
  Future<bool> shouldShowOverlay(String overlayId) async {
    final state = await _repository.getOnboardingState();

    // Already seen
    if (state.seenOverlays.contains(overlayId)) {
      return false;
    }

    // Check user path
    if (state.userExperienceLevel == 'expert' &&
        overlayId.contains('beginner')) {
      return false;
    }

    // Context-specific conditions
    switch (overlayId) {
      case 'createWorkoutCTA':
        return !state.hasCompletedFirstWorkout;

      case 'addExerciseHelp':
        // Show only if clicked create workout but hasn't added exercise
        return true; // implement custom logic

      default:
        return true;
    }
  }

  /// Mark overlay as seen
  Future<void> markAsSeen(String overlayId) async {
    await _repository.addSeenOverlay(overlayId);

    // Track analytics
    await _analytics.logEvent(
      name: 'contextual_overlay_seen',
      parameters: {
        'overlay_id': overlayId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track user action on overlay
  Future<void> trackAction(String overlayId, String action) async {
    await _analytics.logEvent(
      name: 'contextual_overlay_action',
      parameters: {
        'overlay_id': overlayId,
        'action': action, // 'gotIt', 'skip', 'snooze'
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

// Provider
final contextualOverlayManagerProvider = Provider<ContextualOverlayManager>((ref) {
  return ContextualOverlayManager(
    ref.watch(onboardingRepositoryProvider),
    ref.watch(analyticsServiceProvider),
  );
});
```

---

#### **5. Create ContextualOverlay Widget (LayerLink)**

**File**: `lib/features/onboarding/presentation/widgets/contextual_overlay.dart`

```dart
class ContextualOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String message;
  final String overlayId;
  final VoidCallback? onGotIt;
  final VoidCallback? onSkip;

  const ContextualOverlay({
    super.key,
    required this.targetKey,
    required this.message,
    required this.overlayId,
    this.onGotIt,
    this.onSkip,
  });

  @override
  State<ContextualOverlay> createState() => _ContextualOverlayState();

  /// Show overlay using Overlay.of(context)
  static void show(
    BuildContext context, {
    required GlobalKey targetKey,
    required String message,
    required String overlayId,
    VoidCallback? onGotIt,
    VoidCallback? onSkip,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ContextualOverlay(
        targetKey: targetKey,
        message: message,
        overlayId: overlayId,
        onGotIt: () {
          entry.remove();
          onGotIt?.call();
        },
        onSkip: () {
          entry.remove();
          onSkip?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ContextualOverlayState extends State<ContextualOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final renderBox = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Backdrop blur
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onSkip,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Highlight target (spotlight effect)
          Positioned(
            left: position.dx - 8,
            top: position.dy - 8,
            child: Container(
              width: size.width + 16,
              height: size.height + 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Overlay card
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 12,
            width: MediaQuery.of(context).size.width - 48,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.lightbulb,
                          size: AppIconSize.medium,
                          color: context.iconPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.onSkip,
                          child: Text(context.l10n.skip),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: widget.onGotIt,
                          child: Text(context.l10n.gotIt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
```

---

#### **6. Update Home Empty State**

**File**: `lib/features/home/presentation/widgets/home_empty_state_widget.dart` (UPDATE)

```dart
class HomeEmptyStateWidget extends ConsumerWidget {
  final GlobalKey createWorkoutKey = GlobalKey();

  const HomeEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPath = ref.watch(
      onboardingStateProvider.select((s) => s.userExperienceLevel)
    );

    final isBeginner = userPath == 'beginner';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              AppIcons.workout,
              size: AppIconSize.xxlarge,
              color: context.iconPrimary.withValues(alpha: 0.5),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              isBeginner
                ? context.l10n.emptyStateBeginnerTitle
                : context.l10n.emptyStateExpertTitle,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description (only for beginner)
            if (isBeginner) ...[
              Text(
                context.l10n.emptyStateBeginnerDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],

            // CTA Button
            ElevatedButton.icon(
              key: createWorkoutKey,
              onPressed: () => _handleCreateWorkout(context, ref),
              icon: Icon(AppIcons.add, size: AppIconSize.medium),
              label: Text(
                isBeginner
                  ? context.l10n.createFirstWorkout
                  : context.l10n.newWorkout,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateWorkout(BuildContext context, WidgetRef ref) async {
    final manager = ref.read(contextualOverlayManagerProvider);
    final isBeginner = ref.read(
      onboardingStateProvider.select((s) => s.userExperienceLevel)
    ) == 'beginner';

    // Show overlay for beginner (just-in-time)
    if (isBeginner && await manager.shouldShowOverlay('createWorkoutCTA')) {
      ContextualOverlay.show(
        context,
        targetKey: createWorkoutKey,
        message: context.l10n.overlayCreateWorkoutMessage,
        overlayId: 'createWorkoutCTA',
        onGotIt: () {
          manager.markAsSeen('createWorkoutCTA');
          manager.trackAction('createWorkoutCTA', 'gotIt');
          _navigateToCreateWorkout(context);
        },
        onSkip: () {
          manager.trackAction('createWorkoutCTA', 'skip');
          _navigateToCreateWorkout(context);
        },
      );
    } else {
      _navigateToCreateWorkout(context);
    }
  }

  void _navigateToCreateWorkout(BuildContext context) {
    context.pushNamed('createWorkout');
  }
}
```

**Localization:**
```json
{
  "emptyStateBeginnerTitle": "Il Tuo Primo Allenamento",
  "emptyStateBeginnerDescription": "Crea il tuo primo workout per iniziare il tuo viaggio fitness",
  "emptyStateExpertTitle": "GymBro",
  "emptyStateExpertDescription": "",
  "createFirstWorkout": "+ Crea il Tuo Primo Workout",
  "newWorkout": "+ Nuovo Workout",
  "overlayCreateWorkoutMessage": "Perfetto! Scegli 2-3 esercizi per il tuo primo allenamento",
  "skip": "Salta",
  "gotIt": "Ho capito"
}
```

---

#### **Day 3: Routing & Cleanup**

**7. Update App Router**

**File**: `lib/core/router/app_router.dart` (UPDATE)

```dart
// Add Quick Start route
GoRoute(
  path: '/quick-start',
  name: 'quickStart',
  builder: (context, state) => const QuickStartScreen(),
),

// Update home route to check onboarding
GoRoute(
  path: '/home',
  name: 'home',
  builder: (context, state) {
    // Check if user needs Quick Start
    final container = ProviderContainer();
    final onboardingState = container.read(onboardingStateProvider);

    if (onboardingState.userExperienceLevel == null &&
        !onboardingState.hasSeenGlobalOnboarding) {
      // First time user, redirect to Quick Start
      return const QuickStartScreen();
    }

    return const HomeScreen();
  },
),
```

**8. Delete Old Onboarding Files**

```bash
# Delete old onboarding screens
rm lib/features/onboarding/presentation/global_onboarding_screen.dart

# Delete old steps
rm -rf lib/features/onboarding/presentation/widgets/steps/
```

**9. Run Build & Test**

```bash
# Generate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate localizations
flutter gen-l10n

# Run analyzer
flutter analyze

# Hot restart app
```

---

### **Week 1: Day 4-6 - Testing**

**10. Testing Session (Think-Aloud Protocol)**

See Section 4.2 of design document for detailed testing script.

**Prepare:**
- Clean Hive storage
- Install build on device
- Setup screen recorder
- Prepare notebook

**Execute:**
- Session 1A: Beginner path (25 min)
- Session 1B: Post-task interview (10 min)
- Session 2A: Expert path (20 min)
- Session 2B: Cognitive walkthrough (30 min bonus)

**Collect:**
- Video recordings
- Firebase analytics (DebugView)
- TestingNotes (quantitative + qualitative)

---

### **Week 1: Day 7-10 - Iteration**

**11. Analyze & Fix**

```
Day 7: Review videos + Firebase data
       Compile top 3 issues

Day 8: Prioritize fixes

Day 9: Implement fixes + deploy

Day 10: Re-test (15 min rapid validation)
```

**Decision Gate:**
- ✅ ALL metrics met → GO to Phase 2
- ⚠️ Some metrics missed → ITERATE (1 more week)
- ❌ Critical issues → PIVOT (reassess approach)

---

## 🎯 Phase 2: Guided First Workout (Week 3-4)

### **Objectives**
- ✅ Implement Guided Wizard (ONLY for beginner path)
- ✅ 3-step flow: Name → Select Exercises → Celebrate
- ✅ Expand LayerLink system for wizard
- ✅ Optimize time to first workout to <5 min
- ✅ Test retention improvement vs Phase 1

### **Success Criteria**
| Metric | Target |
|--------|--------|
| Wizard completion (beginner) | >80% |
| Time to first workout | <5 min |
| Retention improvement | +20% vs Phase 1 |
| User satisfaction | >8/10 |

### **Implementation Tasks**

**1. Create Guided Wizard Widget**

**File**: `lib/features/onboarding/presentation/widgets/guided_first_workout_wizard.dart` (NEW)

```dart
class GuidedFirstWorkoutWizard extends StatefulWidget {
  const GuidedFirstWorkoutWizard({super.key});

  @override
  State<GuidedFirstWorkoutWizard> createState() => _GuidedFirstWorkoutWizardState();
}

class _GuidedFirstWorkoutWizardState extends State<GuidedFirstWorkoutWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  String? _workoutName;
  List<Exercise> _selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentStep + 1}/3'),
        leading: _currentStep > 0
          ? IconButton(
              icon: Icon(AppIcons.arrowBack),
              onPressed: _previousStep,
            )
          : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1NameWorkout(
            onNext: (name) {
              setState(() => _workoutName = name);
              _nextStep();
            },
          ),

          _Step2SelectExercises(
            onNext: (exercises) {
              setState(() => _selectedExercises = exercises);
              _nextStep();
            },
          ),

          _Step3Celebration(
            workoutName: _workoutName!,
            exercises: _selectedExercises,
            onStartWorkout: _startWorkout,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _startWorkout() async {
    // Save workout
    // Mark hasCompletedFirstWorkout = true
    // Navigate to workout screen
  }
}
```

**2. Update Routing Logic**

When beginner user clicks "+ Crea Workout" in Home:
```dart
if (isBeginner && !hasCompletedFirstWorkout) {
  // Show Guided Wizard
  context.pushNamed('guidedFirstWorkout');
} else {
  // Normal flow
  context.pushNamed('createWorkout');
}
```

**3. Testing (Week 4)**

Same protocol as Phase 1, but focus on:
- Wizard completion rate
- Time savings vs Phase 1
- User confusion points in wizard

---

## 🚀 Phase 3: Progressive Disclosure (Week 5+)

### **Objectives**
- ✅ Implement unlock triggers for advanced features
- ✅ Supersets tutorial (after 3 workouts)
- ✅ Analytics unlock (after 10 workouts)
- ✅ Routine Center tutorial (after 14 days)
- ✅ Achievement system

### **Implementation Tasks**

**1. Add Trigger Logic to ContextualOverlayManager**

```dart
class ProgressiveDisclosureTriggers {
  static bool shouldShowSupersetTutorial(UserStats stats, List<String> seen) {
    return stats.totalWorkouts >= 3 &&
           !seen.contains('superset_intro');
  }

  static bool shouldShowAnalyticsUnlock(UserStats stats, List<String> seen) {
    return stats.totalWorkouts >= 10 &&
           !seen.contains('analytics_unlocked');
  }

  static bool shouldShowRoutineCenterTutorial(UserStats stats, List<String> seen) {
    return stats.daysSinceFirstWorkout >= 14 &&
           !seen.contains('routine_center_intro');
  }
}
```

**2. Integrate Overlays in Feature Screens**

Example for Superset:
```dart
// In workout screen, after user completes 3rd workout
if (await manager.shouldShowOverlay('superset_intro')) {
  ContextualOverlay.show(
    context,
    targetKey: supersetButtonKey,
    message: context.l10n.overlaySupersetMessage,
    overlayId: 'superset_intro',
    onGotIt: () {
      manager.markAsSeen('superset_intro');
      // Navigate to superset tutorial
    },
  );
}
```

**3. Achievement System**

```dart
// After milestone
if (totalWorkouts == 10) {
  showDialog(
    context: context,
    builder: (_) => AchievementDialog(
      title: context.l10n.achievement10Workouts,
      message: context.l10n.achievementUnlockAnalytics,
      icon: AppIcons.trophy,
      onDismiss: () => context.pushNamed('analytics'),
    ),
  );
}
```

---

## 📊 Analytics Events (All Phases)

### **Firebase Events to Track**

```dart
// Phase 1
'quick_start_completed' - {user_path, timestamp}
'quick_start_skipped' - {timestamp}
'contextual_overlay_shown' - {overlay_id, user_path}
'contextual_overlay_action' - {overlay_id, action, time_since_quick_start}
'onboarding_funnel' - {step, completion}
'first_workout_created' - {time_since_quick_start, user_path}
'testing_satisfaction' - {score, comments, would_recommend}

// Phase 2
'guided_wizard_started' - {timestamp}
'guided_wizard_step_completed' - {step, timestamp}
'guided_wizard_completed' - {total_time, timestamp}
'guided_wizard_abandoned' - {step, timestamp}

// Phase 3
'advanced_feature_unlocked' - {feature, total_workouts}
'achievement_earned' - {achievement_id, timestamp}
```

---

## 📋 Pre-Implementation Checklist

**Before starting Phase 1:**
- [ ] Read CLAUDE.md (mandatory AI assistant rules)
- [ ] Read DESIGN_GUIDELINES.md (UI patterns)
- [ ] Backup current branch
- [ ] Create feature branch: `git checkout -b feature/new-onboarding-phase1`
- [ ] Install dependencies (none new needed)
- [ ] Verify Firebase is configured

**During implementation:**
- [ ] Follow Icon Design System (AppIcons.*, AppIconSize.*, context.icon*)
- [ ] Use context.l10n.* (NO hardcoded strings)
- [ ] Use context.colors.* (NO hardcoded colors)
- [ ] Test in Light AND Dark theme
- [ ] Add translations (EN + IT)
- [ ] Run `flutter analyze` (0 errors required)
- [ ] Run `flutter gen-l10n` after adding translations

**After each phase:**
- [ ] Testing session completed
- [ ] Metrics collected
- [ ] Decision gate passed (GO/ITERATE/PIVOT)
- [ ] Documentation updated
- [ ] Git commit with descriptive message

---

## 🎯 Success Definition

**Phase 1 Success:**
- All 6 metrics meet targets
- User feedback >7/10
- Zero critical bugs

**Phase 2 Success:**
- Wizard completion >80%
- Time to first workout <5 min
- Retention improvement measurable

**Phase 3 Success:**
- Feature adoption >40%
- 30-day retention >70%
- Support tickets reduced by 30%

**Overall Success:**
- App retention increased by 40-50%
- User satisfaction consistently >8/10
- Onboarding is invisible yet effective

---

## 🆘 Troubleshooting

**Common Issues:**

1. **LayerLink not positioning correctly**
   - Ensure target widget has been rendered
   - Use `addPostFrameCallback` to delay overlay show
   - Check `renderBox.hasSize` before positioning

2. **Hive schema changes not reflecting**
   - Run: `flutter packages pub run build_runner build --delete-conflicting-outputs`
   - Delete `*.g.dart` files manually if needed
   - Clean build: `flutter clean && flutter pub get`

3. **Analytics events not appearing in Firebase**
   - Check Firebase DebugView (real-time)
   - Verify `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Wait 24h for standard analytics dashboard

4. **Localization not working**
   - Run: `flutter gen-l10n`
   - Verify `l10n.yaml` configuration
   - Import: `import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';`
   - Use: `context.l10n.*`

---

## 📚 Resources

**Design Document:**
- `docs/plans/2025-01-03-new-onboarding-design.md`

**Related Documentation:**
- `CLAUDE.md` - AI assistant mandatory rules
- `docs/DESIGN_GUIDELINES.md` - UI patterns & spacing
- `docs/NAVIGATION/INDEX.md` - Documentation map

**Flutter Resources:**
- LayerLink: https://api.flutter.dev/flutter/widgets/LayerLink-class.html
- Overlay: https://api.flutter.dev/flutter/widgets/Overlay-class.html
- Riverpod: https://riverpod.dev/docs/introduction/getting_started

**Research Citations:**
- Progressive Disclosure: https://userpilot.com/blog/progressive-disclosure-examples/
- Contextual Help: https://document360.com/blog/contextual-help/
- Think-Aloud Protocol: https://pmc.ncbi.nlm.nih.gov/articles/PMC6369913/

---

**Last Updated**: January 3, 2025
**Version**: 1.0
**Status**: ✅ Ready for Implementation
