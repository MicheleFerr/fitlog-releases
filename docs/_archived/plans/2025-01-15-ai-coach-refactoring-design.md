# 🤖 AI Coach Refactoring & Optimization - Design Document

**Generated**: 2025-01-15 17:45
**Author**: Claude Code (Brainstorming with Michele)
**Project**: GymBro TrackLog Flutter App
**Status**: 🎨 Design Phase - Ready for Implementation
**Estimated Timeline**: 3-4 weeks (phased implementation)

---

## 📋 Executive Summary

This document outlines a **comprehensive refactoring and optimization** of the AI Coach feature in GymBro TrackLog, addressing critical issues in **quality, architecture, UX/UI, and extensibility** while setting up infrastructure for future advanced insights.

### 🎯 Goals

1. **Improve Insight Quality** (Priority: CRITICAL)
   - Eliminate false positives through smarter thresholds
   - Make recommendations **actionable** (not generic)
   - Fill blind spots (asymmetry, CNS fatigue, periodization)
   - Add **user context personalization** (experience level, goals, availability)

2. **Refactor Architecture** (Priority: HIGH)
   - Split monolithic `ai_coach_service.dart` (1026 lines) into modular components
   - Implement **Strategy Pattern** for insight analyzers
   - Introduce **Domain-Driven Design** (entities, repositories, use cases)
   - Build **plugin architecture** for easy extensibility

3. **Enhance UX/UI** (Priority: HIGH)
   - Add **data visualizations** (charts, trend graphs)
   - Implement **visual prioritization** (critical = red pulse, info = discrete)
   - Create **actionable UI** ("Fix this" guided workflows)
   - Add **progressive disclosure** (summary → details → strategies)
   - Integrate **contextual help** (tooltips, educational content)
   - Implement **feedback loop** (user ratings improve future insights)

4. **Extend Capabilities** (Priority: MEDIUM)
   - **Phase 1**: Mobility warnings, CNS fatigue tracking, Periodization suggestions
   - **Future**: Asymmetry detection, Nutrition integration, Social comparison, Injury prediction

---

## 🔍 Current State Analysis

### 📊 Codebase Metrics

| File | Lines | Issues |
|------|-------|--------|
| `ai_coach_service.dart` | 1026 | ❌ Monolithic, hard to test, no separation of concerns |
| `ai_coach_card.dart` | 2382 | ❌ Overly complex UI, mixed presentation logic |
| `ai_volume_calculator.dart` | 231 | ✅ Good separation (keep this pattern) |
| `ai_coach_provider.dart` | 100 | ✅ Clean Riverpod integration |

### 🐛 Pain Points Identified

**A. Quality Issues**
1. **False Positives** (Examples):
   - "Plateau detected" after only 3 workouts (insufficient data)
   - "High frequency" warning at 4.5 workouts/week (actually optimal)
   - "Form warning" on 15% weight increase for beginners (normal progression)

2. **Generic Recommendations** (Examples):
   - ❌ "Increase volume for chest" → 🎯 "Add 2 sets of Incline Bench Press on Monday (Push Day)"
   - ❌ "Reduce frequency" → 🎯 "Consolidate 6 workouts into 4 full-body sessions (better recovery)"

3. **Blind Spots**:
   - No asymmetry detection (left vs right imbalance)
   - No CNS fatigue tracking (accumulated neurological stress)
   - No periodization guidance (when to deload, change phases)

4. **No Personalization**:
   - Ignores user experience level (beginner/intermediate/advanced)
   - Ignores user goals (hypertrophy vs strength vs endurance)
   - Ignores availability constraints (time, equipment)

**B. Architecture Issues**
- Single 1026-line service file (all insights in one class)
- Tight coupling (can't test insights individually)
- No clear domain model (insights mixed with presentation logic)
- Hard to extend (adding new insight = modify giant file)

**C. UX/UI Issues**
- No visual data (users can't "see" their trends)
- Poor severity communication (all insights look similar)
- Not actionable (users see problems but don't know how to fix)
- Information overload (all details shown at once)
- No learning support (unfamiliar terms like MEV, MRV)

---

## 🏗️ Proposed Architecture

### 📐 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  AICoachCard (simplified, ~500 lines)                       │
│    ├─ InsightListView (data visualization)                  │
│    ├─ InsightDetailModal (progressive disclosure)           │
│    └─ ActionableWorkflows (guided fixes)                    │
│                                                              │
│  Providers:                                                  │
│    ├─ aiCoachInsightsProvider (orchestrates analyzers)      │
│    ├─ userContextProvider (experience, goals, constraints)  │
│    └─ insightHistoryProvider (track feedback, seen insights)│
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  Entities:                                                   │
│    ├─ AIInsight (immutable, freezed)                        │
│    ├─ UserContext (experience, goals, availability)         │
│    ├─ InsightRule (threshold configuration)                 │
│    └─ AnalyzerResult (confidence, anomalies, suggestions)   │
│                                                              │
│  Use Cases:                                                  │
│    ├─ GenerateInsightsUseCase (orchestrate analyzers)       │
│    ├─ PersonalizeInsightUseCase (apply user context)        │
│    ├─ RankInsightsUseCase (prioritize by urgency + impact)  │
│    └─ ValidateInsightUseCase (filter false positives)       │
│                                                              │
│  Repository Interfaces:                                      │
│    ├─ InsightHistoryRepository (feedback, seen status)      │
│    ├─ InsightRulesRepository (dynamic thresholds)           │
│    └─ UserPreferencesRepository (dismissed insights)        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    ANALYZERS LAYER                          │
│                  (Strategy Pattern + Plugin Architecture)   │
├─────────────────────────────────────────────────────────────┤
│  Abstract:                                                   │
│    └─ InsightAnalyzer<TData> (interface)                    │
│         ├─ analyze(data, context) → List<AIInsight>         │
│         ├─ canAnalyze(data) → bool (data quality gate)      │
│         ├─ priority: int (execution order)                  │
│         └─ enabled: bool (feature flag)                     │
│                                                              │
│  Concrete Analyzers (8 existing + 3 new):                   │
│    ├─ VolumeByMuscleGroupAnalyzer (MEV/MAV/MRV logic)       │
│    ├─ ProgressiveOverloadAnalyzer (plateau detection)       │
│    ├─ RecoveryPatternAnalyzer (rest days, fatigue)          │
│    ├─ FrequencyAnalyzer (optimal weekly sessions)           │
│    ├─ PlateauBreakerAnalyzer (stagnation detection)         │
│    ├─ FormWarningAnalyzer (injury risk from rapid load)     │
│    ├─ MotivationalAnalyzer (positive feedback)              │
│    ├─ 🆕 MobilityAnalyzer (flexibility warnings)            │
│    ├─ 🆕 CNSFatigueAnalyzer (neurological stress)           │
│    └─ 🆕 PeriodizationAnalyzer (deload, phase change)       │
│                                                              │
│  Future Analyzers (extensibility ready):                    │
│    ├─ AsymmetryAnalyzer (left/right imbalance)              │
│    ├─ NutritionAnalyzer (timing, macros)                    │
│    ├─ SocialComparisonAnalyzer (percentile ranking)         │
│    └─ InjuryPredictionAnalyzer (ML model integration)       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  Repositories (implementations):                             │
│    ├─ InsightHistoryRepositoryImpl (Firebase Firestore)     │
│    ├─ InsightRulesRepositoryImpl (Hive local cache)         │
│    └─ UserPreferencesRepositoryImpl (Hive local cache)      │
│                                                              │
│  Data Sources:                                               │
│    ├─ ExerciseActivityDataSource (existing)                 │
│    ├─ WorkoutDataSource (existing)                          │
│    ├─ ProgressDataSource (existing)                         │
│    └─ TemplateDataSource (existing)                         │
└─────────────────────────────────────────────────────────────┘
```

### 🔑 Key Design Patterns

1. **Strategy Pattern** (Analyzers)
   - Each insight type = separate analyzer class
   - Pluggable, testable, independently configurable
   - Easy to add/remove/disable analyzers

2. **Domain-Driven Design**
   - Rich domain entities (`AIInsight`, `UserContext`)
   - Use cases orchestrate business logic
   - Repositories abstract data access

3. **Plugin Architecture**
   - Analyzers register dynamically at runtime
   - Feature flags enable/disable analyzers
   - No core code changes to add new insights

4. **Repository Pattern**
   - Separate data access from business logic
   - Swap implementations (Firestore ↔ Hive ↔ In-memory)
   - Easier testing with mocks

---

## 🎨 Enhanced Insight Quality

### 1. Smarter Thresholds (Context-Aware)

**Problem**: Fixed thresholds ignore user context.

**Solution**: Dynamic thresholds based on `UserContext`.

```dart
class InsightRule {
  final String ruleId;
  final Map<ExperienceLevel, ThresholdConfig> thresholds;

  double getMEV(UserContext context) {
    switch (context.experienceLevel) {
      case ExperienceLevel.beginner:
        return 8.0;  // Lower threshold for beginners
      case ExperienceLevel.intermediate:
        return 10.0;
      case ExperienceLevel.advanced:
        return 12.0; // Higher threshold for advanced
    }
  }
}
```

**Examples**:
- **Beginner**: Plateau detection requires 6+ weeks (not 3)
- **Advanced**: High frequency threshold = 7 workouts/week (not 5)
- **Hypertrophy goal**: MAV = 15-20 sets, MRV = 25
- **Strength goal**: MAV = 10-15 sets, MRV = 20 (lower volume)

### 2. Actionable Recommendations (Not Generic)

**Problem**: "Increase volume" is vague.

**Solution**: Specific, templated recommendations.

```dart
class ActionableRecommendation {
  final String templateId;      // "add_sets_to_exercise"
  final Map<String, dynamic> params; // {exercise: "Bench Press", sets: 2, day: "Monday"}
  final List<ActionStep> steps; // Step-by-step guide

  // Generate user-friendly text
  String format(AppLocalizations l10n, UserContext context) {
    return l10n.recommendationAddSets(
      params['exercise'],
      params['sets'],
      params['day'],
    );
    // Output: "Add 2 sets of Bench Press on Monday (Push Day)"
  }
}
```

**Template Repository**:
- Volume deficit → "Add X sets of Y exercise on Z day"
- Plateau → "Try drop sets: 3 x 10 → 1 x 8 (reduce 20%, do 12 reps)"
- Overtraining → "Reduce chest volume from 22 to 18 sets (remove last 2 sets of Flyes)"

### 3. Fill Blind Spots (New Analyzers)

#### 🆕 A. Mobility Analyzer

**Detects**: Limited range of motion, skipped stretches

```dart
class MobilityAnalyzer extends InsightAnalyzer<ExerciseActivity> {
  @override
  List<AIInsight> analyze(data, context) {
    // Detect:
    // 1. Exercises skipped due to mobility (e.g., user never does overhead press)
    // 2. Reduced ROM (weight increased but reps decreased = compensating)
    // 3. Lack of dynamic stretching in warmups

    if (neverDoesOverheadPress && hasShoulderExercises) {
      return [AIInsight(
        type: InsightType.mobilityWarning,
        title: "Limited Shoulder Mobility Detected",
        description: "You avoid overhead pressing but do lateral raises. This suggests shoulder mobility restriction.",
        recommendation: "Add 5 min shoulder dislocations + band pull-aparts before Push days",
        severity: InsightSeverity.warning,
        strategies: [...mobilityProtocols],
      )];
    }
  }
}
```

#### 🆕 B. CNS Fatigue Analyzer

**Detects**: Accumulated nervous system stress

```dart
class CNSFatigueAnalyzer extends InsightAnalyzer<WorkoutPerformance> {
  @override
  List<AIInsight> analyze(data, context) {
    // Indicators:
    // 1. Performance drop across multiple exercises (not just one)
    // 2. Decreased explosive power (weight × reps × velocity proxy)
    // 3. Increased RPE for same weight (if tracked)

    final fatigueIndex = calculateCNSFatigueIndex(data);

    if (fatigueIndex > 0.7) {  // High CNS stress
      return [AIInsight(
        type: InsightType.cnsFatigue,
        title: "Central Nervous System Fatigue Detected",
        description: "Your performance dropped 15% across bench press, squat, and deadlift in 2 weeks.",
        recommendation: "Take a deload week: reduce weight by 40%, keep reps at 8-10 for all compounds",
        severity: InsightSeverity.critical,
        dataPoints: [
          "Bench: 100kg → 85kg (-15%)",
          "Squat: 120kg → 102kg (-15%)",
          "Deadlift: 140kg → 119kg (-15%)",
        ],
      )];
    }
  }

  double calculateCNSFatigueIndex(data) {
    // Multi-exercise performance correlation
    // Formula: Average % drop in (weight × reps) for compounds
  }
}
```

#### 🆕 C. Periodization Analyzer

**Detects**: When to switch training phases

```dart
class PeriodizationAnalyzer extends InsightAnalyzer<WorkoutHistory> {
  @override
  List<AIInsight> analyze(data, context) {
    // Triggers:
    // 1. After 6-8 weeks in same rep range (time for phase change)
    // 2. After 3 consecutive weeks of volume increase (deload needed)
    // 3. Performance plateau + optimal volume (switch stimulus)

    final weeksInCurrentPhase = calculatePhaseLength(data);

    if (weeksInCurrentPhase >= 8 && context.goal == Goal.hypertrophy) {
      return [AIInsight(
        type: InsightType.periodizationSuggestion,
        title: "Time to Switch Training Phase",
        description: "You've been in hypertrophy phase (8-12 reps) for 8 weeks. Muscle adaptation has plateaued.",
        recommendation: "Switch to strength phase for 4 weeks: 3-5 reps, 85-90% 1RM, 3-4 min rest",
        severity: InsightSeverity.info,
        strategies: [
          ScientificStrategy(
            title: "Undulating Periodization",
            description: "Alternate between strength (3-5 reps), hypertrophy (8-12 reps), and endurance (15-20 reps) every 4-6 weeks",
            scientificBasis: "Rhea et al. (2002) - Periodization enhances strength gains",
          ),
        ],
      )];
    }
  }
}
```

### 4. Personalization (User Context Integration)

```dart
class UserContext {
  final ExperienceLevel experienceLevel;  // beginner/intermediate/advanced
  final Goal primaryGoal;                 // hypertrophy/strength/endurance/recomp
  final int weeklyAvailability;           // How many days can they train
  final List<String> equipmentAccess;     // barbell/dumbbells/machines/bodyweight
  final List<String> injuries;            // Known limitations
  final DateTime startedTraining;         // Training age

  // Derived properties
  int get trainingAge => DateTime.now().difference(startedTraining).inDays ~/ 365;

  ExperienceLevel get derivedExperience {
    if (trainingAge < 1) return ExperienceLevel.beginner;
    if (trainingAge < 3) return ExperienceLevel.intermediate;
    return ExperienceLevel.advanced;
  }
}
```

**Personalization Rules**:

| Insight | Beginner | Intermediate | Advanced |
|---------|----------|-------------|----------|
| **Plateau Detection** | 6+ weeks same weight | 4+ weeks | 3+ weeks |
| **High Frequency** | >5 days/week | >6 days/week | >7 days/week |
| **Volume MEV** | 8 sets/muscle/week | 10 sets | 12 sets |
| **Weight Jump Warning** | >40% increase | >25% increase | >15% increase |

---

## 🎨 Enhanced UX/UI

### 1. Data Visualizations (Charts & Graphs)

**Integration**: Use `fl_chart` package (already in dependencies)

#### A. Volume Trend Chart (Line Graph)

```dart
class VolumeProgressChart extends ConsumerWidget {
  @override
  Widget build(context, ref) {
    final volumeHistory = ref.watch(volumeHistoryProvider);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: volumeHistory.map((v) =>
              FlSpot(v.weekNumber, v.totalVolume)
            ).toList(),
            colors: [context.colors.primary],
            dotData: FlDotData(show: true),
          ),
          // MEV threshold line
          LineChartBarData(
            spots: [FlSpot(0, 10), FlSpot(12, 10)],
            colors: [Colors.orange],
            dashArray: [5, 5],  // Dashed line
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => "Week ${value.toInt()}",
          ),
        ),
      ),
    );
  }
}
```

**Where Used**: Expand "Muscle Imbalance" insight → show 12-week volume trend

#### B. MEV/MAV/MRV Progress Bar (Enhanced)

**Current**: Simple horizontal bar
**Enhanced**: Color-coded zones with labels

```dart
Widget _buildVolumeZonesBar(int currentSets) {
  return CustomPaint(
    size: Size(double.infinity, 40),
    painter: VolumeZonesPainter(
      currentSets: currentSets,
      mev: 10,
      mav: 15,
      mrv: 25,
    ),
  );
}

class VolumeZonesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw 3 colored zones:
    // Orange: 0-10 (below MEV)
    // Green: 10-20 (optimal MAV)
    // Red: 20-25 (approaching MRV)
    // Dark Red: 25+ (overtraining)

    // Draw current position marker (animated)
    final markerX = (currentSets / 30) * size.width;
    canvas.drawCircle(Offset(markerX, 20), 8, markerPaint);
  }
}
```

#### C. Plateau Detection Chart (Scatter Plot)

**Shows**: Weight progression over time with plateau detection

```dart
class PlateauDetectionChart extends StatelessWidget {
  @override
  Widget build(context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: workouts.map((w) =>
          ScatterSpot(w.date, w.maxWeight,
            color: w.isPlateaued ? Colors.red : Colors.green,
          )
        ).toList(),
        // Add linear regression line
        lineBarsData: [
          LineChartBarData(
            spots: regressionLine,
            colors: [Colors.grey.withOpacity(0.5)],
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }
}
```

### 2. Visual Prioritization (Severity System)

**Current**: All insights look similar
**Enhanced**: Visual hierarchy by severity

```dart
Widget _buildInsightCard(AIInsight insight) {
  final severity = insight.effectiveSeverity;

  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    decoration: BoxDecoration(
      border: Border.all(
        color: _getSeverityColor(severity),
        width: severity == InsightSeverity.critical ? 3 : 1,  // Thicker border
      ),
      boxShadow: [
        if (severity == InsightSeverity.critical)
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),  // Red glow for critical
      ],
    ),
    child: Column(
      children: [
        // Animated attention-getter for critical
        if (severity == InsightSeverity.critical)
          _PulsingAttentionIcon(),

        // Rest of card content
      ],
    ),
  );
}

class _PulsingAttentionIcon extends StatefulWidget {
  @override
  State<_PulsingAttentionIcon> createState() => _PulsingAttentionIconState();
}

class _PulsingAttentionIconState extends State<_PulsingAttentionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(context) {
    return FadeTransition(
      opacity: _controller,
      child: Icon(AppIcons.warning, color: Colors.red, size: 32),
    );
  }
}
```

**Severity Visual Language**:
- 🔴 **Critical**: Red glow, pulsing icon, thick border, top of list
- 🟠 **Warning**: Orange border, bold title, high priority
- 🔵 **Info**: Blue subtle border, normal font
- 🟢 **Success**: Green background, celebration icon

### 3. Actionable UI (Guided Workflows)

**Current**: "Replace Exercise" button (good start)
**Enhanced**: Multi-step guided workflows for all fixable insights

```dart
class ActionableWorkflowButton extends StatelessWidget {
  final AIInsight insight;

  @override
  Widget build(context) {
    return FilledButton.icon(
      onPressed: () => _launchWorkflow(context),
      icon: Icon(_getWorkflowIcon(insight.actionType)),
      label: Text(_getWorkflowLabel(insight.actionType)),
    );
  }

  Future<void> _launchWorkflow(BuildContext context) async {
    switch (insight.actionType) {
      case InsightActionType.replaceExercise:
        await _showExerciseReplacementWizard(context);
      case InsightActionType.modifyVolume:
        await _showVolumeAdjustmentWizard(context);
      case InsightActionType.adjustRest:
        await _showRestDayPlanner(context);
      default:
        // No action available
    }
  }
}
```

**Example Workflows**:

1. **Volume Adjustment Wizard** (for "Muscle Imbalance" insight)
   ```
   Step 1: Select target muscle group ✅ (pre-filled from insight)
   Step 2: Choose solution
      ○ Add exercises to existing templates
      ○ Create new workout day
      ○ Increase sets in current exercises
   Step 3: Pick exercises (filtered by muscle group)
   Step 4: Select templates to modify
   Step 5: Preview changes
   Step 6: Apply & track
   ```

2. **Deload Week Planner** (for "CNS Fatigue" insight)
   ```
   Step 1: Review current performance drop (chart shown)
   Step 2: Choose deload strategy
      ○ Reduce weight by 40% (recommended)
      ○ Reduce volume by 50%
      ○ Active recovery (bodyweight only)
   Step 3: Generate deload templates (auto-modify existing)
   Step 4: Schedule 1 week in calendar
   Step 5: Apply & set reminder
   ```

### 4. Progressive Disclosure (Summary → Details)

**Current**: Everything shown at once (info overload)
**Enhanced**: 3-tier disclosure

```dart
class ProgressiveDisclosureInsightCard extends StatelessWidget {
  @override
  Widget build(context) {
    return Column(
      children: [
        // Tier 1: ALWAYS VISIBLE (collapsed state)
        _SummaryTile(
          icon: insight.icon,
          title: insight.title,
          keyMetric: insight.keyMetric,  // e.g., "12 sets/week"
          severityBadge: insight.severity,
        ),

        // Tier 2: EXPANDABLE (tap to show)
        if (isExpanded) ...[
          _DetailSection(
            description: insight.description,
            recommendation: insight.recommendation,
            dataChart: insight.hasChart ? VolumeChart(insight) : null,
          ),

          // Tier 3: NESTED EXPANDABLE (tap subsections)
          _ExpandableSubsection(
            title: "Why This Matters",
            child: Text(insight.detailedAnalysis),
          ),
          _ExpandableSubsection(
            title: "Your Data",
            child: DataPointsList(insight.dataPoints),
          ),
          _ExpandableSubsection(
            title: "Scientific Strategies",
            child: StrategiesList(insight.strategies),
          ),
        ],
      ],
    );
  }
}
```

### 5. Contextual Help (Educational Tooltips)

**Problem**: Users don't understand MEV, MAV, MRV, CNS fatigue, etc.

**Solution**: Inline educational tooltips with "Learn More" links

```dart
class EducationalTooltipIcon extends StatelessWidget {
  final String term;  // "MEV", "MRV", "CNS Fatigue"
  final String shortExplanation;
  final String? learnMoreUrl;

  @override
  Widget build(context) {
    return Tooltip(
      message: shortExplanation,
      child: IconButton(
        icon: Icon(AppIcons.infoOutline, size: 16),
        onPressed: () => _showEducationalModal(context),
      ),
    );
  }

  void _showEducationalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => EducationalSheet(
        term: term,
        definition: shortExplanation,
        examples: _getExamples(term),
        visualAid: _getVisualAid(term),  // Diagram or chart
        learnMoreUrl: learnMoreUrl,
      ),
    );
  }
}

// Usage in insight card:
Text("MEV: 10 sets/week")
SizedBox(width: 4)
EducationalTooltipIcon(
  term: "MEV",
  shortExplanation: "Minimum Effective Volume: il volume minimo settimanale per stimolare crescita muscolare",
  learnMoreUrl: "https://renaissanceperiodization.com/mev-mav-mrv",
)
```

**Educational Content Database**:
```dart
class EducationalContent {
  static final Map<String, EducationalTopic> topics = {
    'MEV': EducationalTopic(
      definition: "Minimum Effective Volume...",
      examples: ["Chest: 10 sets/week", "Back: 12 sets/week"],
      visualAid: MEVDiagram(),
      references: ["Israetel et al. 2017"],
    ),
    'Progressive Overload': EducationalTopic(...),
    'CNS Fatigue': EducationalTopic(...),
  };
}
```

### 6. Feedback Loop (Improve with User Ratings)

**Current**: Thumbs up/down (good start)
**Enhanced**: Feedback influences future insights + dismissal system

```dart
class InsightFeedbackRepository {
  // Track feedback stats
  Future<void> recordFeedback(AIInsight insight, bool isHelpful) async {
    final insightHash = insight.generateHash();

    await _firestore.collection('insight_feedback').add({
      'insightHash': insightHash,
      'insightType': insight.type.toString(),
      'isHelpful': isHelpful,
      'userId': currentUser.id,
      'timestamp': DateTime.now(),
      'userContext': {
        'experienceLevel': context.experienceLevel,
        'goal': context.primaryGoal,
      },
    });

    // Adjust future thresholds based on feedback
    if (!isHelpful && insight.type == InsightType.progressOverload) {
      await _adjustPlateauThreshold(insight);
    }
  }

  Future<void> _adjustPlateauThreshold(AIInsight insight) async {
    // If multiple users mark plateau detection as unhelpful,
    // increase the minimum weeks required before flagging
    final feedbackStats = await _getFeedbackStats(insight.type);

    if (feedbackStats.helpfulPercentage < 0.3) {  // <30% helpful
      // Increase threshold by 1 week
      await _rulesRepository.updateRule('plateau_detection', {
        'minWeeks': currentMinWeeks + 1,
      });
    }
  }
}
```

**Dismissal System**:
```dart
class DismissibleInsight extends StatelessWidget {
  @override
  Widget build(context) {
    return Dismissible(
      key: Key(insight.generateHash()),
      background: Container(color: Colors.orange, child: Icon(Icons.snooze)),
      secondaryBackground: Container(color: Colors.red, child: Icon(Icons.delete_forever)),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left = "Never show this again"
          await _neverShowAgain(insight);
          return true;
        } else {
          // Swipe right = "Snooze for 1 week"
          await _snoozeInsight(insight, Duration(days: 7));
          return true;
        }
      },
      child: InsightCard(insight),
    );
  }
}
```

---

## 🔌 Plugin Architecture (Future-Proof Extensibility)

### Analyzer Registration System

```dart
class InsightAnalyzerRegistry {
  static final List<InsightAnalyzer> _analyzers = [];

  // Register analyzer at app startup
  static void registerAnalyzer(InsightAnalyzer analyzer) {
    _analyzers.add(analyzer);
    _analyzers.sort((a, b) => a.priority.compareTo(b.priority));
  }

  // Get all enabled analyzers
  static List<InsightAnalyzer> getEnabledAnalyzers() {
    return _analyzers.where((a) => a.enabled).toList();
  }

  // Feature flags
  static void toggleAnalyzer(Type analyzerType, bool enabled) {
    final analyzer = _analyzers.firstWhere((a) => a.runtimeType == analyzerType);
    analyzer.enabled = enabled;
  }
}

// App initialization
void main() {
  // Core analyzers (always enabled)
  InsightAnalyzerRegistry.registerAnalyzer(VolumeByMuscleGroupAnalyzer());
  InsightAnalyzerRegistry.registerAnalyzer(ProgressiveOverloadAnalyzer());

  // New analyzers (can be feature-flagged)
  InsightAnalyzerRegistry.registerAnalyzer(MobilityAnalyzer());
  InsightAnalyzerRegistry.registerAnalyzer(CNSFatigueAnalyzer());
  InsightAnalyzerRegistry.registerAnalyzer(PeriodizationAnalyzer());

  // Future analyzers (disabled by default, enable via remote config)
  InsightAnalyzerRegistry.registerAnalyzer(AsymmetryAnalyzer()..enabled = false);
  InsightAnalyzerRegistry.registerAnalyzer(NutritionAnalyzer()..enabled = false);

  runApp(MyApp());
}
```

### How to Add New Insights (Future)

**Example**: Adding `AsymmetryAnalyzer` (left/right imbalance)

**Step 1**: Create analyzer class
```dart
class AsymmetryAnalyzer extends InsightAnalyzer<ExerciseActivity> {
  @override
  final int priority = 50;  // Run after volume analysis
  @override
  bool enabled = false;  // Feature flag (enable when ready)

  @override
  List<AIInsight> analyze(List<ExerciseActivity> activities, UserContext context) {
    // Detection logic:
    // - Compare unilateral exercise performance (left vs right)
    // - Flag if >10% difference consistently

    final asymmetries = _detectAsymmetries(activities);

    return asymmetries.map((asym) => AIInsight(
      type: InsightType.asymmetryWarning,
      title: "Left/Right Imbalance Detected",
      description: "Your ${asym.side} ${asym.muscleGroup} is ${asym.difference}% weaker",
      recommendation: "Add 2 extra sets of ${asym.exercise} on ${asym.weakSide} side",
      severity: InsightSeverity.warning,
    )).toList();
  }
}
```

**Step 2**: Register analyzer
```dart
// In main.dart
InsightAnalyzerRegistry.registerAnalyzer(AsymmetryAnalyzer());
```

**Step 3**: Enable via feature flag
```dart
// Remote config or settings screen
await InsightAnalyzerRegistry.toggleAnalyzer(AsymmetryAnalyzer, true);
```

**That's it!** No core service modifications needed.

---

## 📦 Implementation Phases

### Phase 1: Architecture Refactoring (Week 1-2)

**Priority**: CRITICAL (foundation for all other work)

**Tasks**:
1. ✅ Create domain layer
   - [ ] Define `AIInsight` entity (freezed, immutable)
   - [ ] Define `UserContext` entity
   - [ ] Create `InsightAnalyzer` abstract class
   - [ ] Create repository interfaces

2. ✅ Refactor existing service
   - [ ] Extract `VolumeByMuscleGroupAnalyzer` from service
   - [ ] Extract `ProgressiveOverloadAnalyzer`
   - [ ] Extract `RecoveryPatternAnalyzer`
   - [ ] Extract `FrequencyAnalyzer`
   - [ ] Extract `PlateauBreakerAnalyzer`
   - [ ] Extract `FormWarningAnalyzer`
   - [ ] Extract `MotivationalAnalyzer`

3. ✅ Implement plugin registry
   - [ ] Create `InsightAnalyzerRegistry`
   - [ ] Wire up analyzers in `main.dart`
   - [ ] Implement feature flags (Hive storage)

4. ✅ Create use cases
   - [ ] `GenerateInsightsUseCase` (orchestrate analyzers)
   - [ ] `RankInsightsUseCase` (prioritize)
   - [ ] `ValidateInsightUseCase` (filter false positives)

5. ✅ Update providers
   - [ ] Modify `aiCoachInsightsProvider` to use use cases
   - [ ] Add `userContextProvider`

**Deliverable**: Clean architecture with 7 separate analyzer files, plugin system working

**Testing**: Unit tests for each analyzer, integration tests for orchestration

---

### Phase 2: Quality Improvements (Week 2)

**Priority**: HIGH (immediate user value)

**Tasks**:
1. ✅ Implement smart thresholds
   - [ ] Create `InsightRulesRepository`
   - [ ] Define context-aware rules (experience level, goal)
   - [ ] Update analyzers to use dynamic thresholds

2. ✅ Improve recommendations
   - [ ] Create recommendation templates
   - [ ] Implement `ActionableRecommendation` class
   - [ ] Update all analyzers with actionable text

3. ✅ Add user context collection
   - [ ] Create onboarding flow for `UserContext`
   - [ ] Persist to Hive
   - [ ] Wire up to analyzers

**Deliverable**: Significantly reduced false positives, actionable recommendations

**Testing**: A/B test with 10 beta users (compare old vs new insight quality)

---

### Phase 3: New Analyzers (Week 3)

**Priority**: MEDIUM (extend capabilities)

**Tasks**:
1. ✅ Implement `MobilityAnalyzer`
   - [ ] Define detection logic (skipped exercises, reduced ROM)
   - [ ] Add mobility protocols to strategies
   - [ ] Register in plugin system

2. ✅ Implement `CNSFatigueAnalyzer`
   - [ ] Define CNS fatigue index calculation
   - [ ] Detect multi-exercise performance drops
   - [ ] Add deload recommendations

3. ✅ Implement `PeriodizationAnalyzer`
   - [ ] Track training phase length
   - [ ] Detect plateau + phase change triggers
   - [ ] Add periodization strategies

**Deliverable**: 3 new insight types, addressing major blind spots

**Testing**: Unit tests for each analyzer, manual QA with real workout data

---

### Phase 4: UX/UI Enhancements (Week 3-4)

**Priority**: HIGH (user engagement)

**Tasks**:
1. ✅ Add data visualizations
   - [ ] Integrate `fl_chart` package
   - [ ] Implement `VolumeProgressChart` (line graph)
   - [ ] Implement `PlateauDetectionChart` (scatter plot)
   - [ ] Add enhanced MEV/MAV/MRV progress bar

2. ✅ Implement visual prioritization
   - [ ] Add severity-based card styling
   - [ ] Implement pulsing animation for critical insights
   - [ ] Reorder insights by severity + impact

3. ✅ Build actionable workflows
   - [ ] Create `VolumeAdjustmentWizard`
   - [ ] Create `DeloadWeekPlanner`
   - [ ] Update `ExerciseReplacementDialog` (existing)

4. ✅ Add progressive disclosure
   - [ ] Refactor `AICoachCard` to 3-tier disclosure
   - [ ] Implement expandable subsections
   - [ ] Add loading states and animations

5. ✅ Integrate contextual help
   - [ ] Create `EducationalContent` database
   - [ ] Implement `EducationalTooltipIcon`
   - [ ] Add educational modals

6. ✅ Enhance feedback system
   - [ ] Implement feedback analytics (Firestore)
   - [ ] Add dismissal system (snooze/never show)
   - [ ] Create feedback-driven threshold adjustment

**Deliverable**: Rich, engaging UI with charts, guided workflows, and education

**Testing**: Usability testing with 5 users (record session, measure engagement)

---

### Phase 5: Testing & Optimization (Week 4)

**Priority**: CRITICAL (stability)

**Tasks**:
1. ✅ Unit tests
   - [ ] Test all 10 analyzers independently
   - [ ] Test use cases
   - [ ] Test repository implementations

2. ✅ Integration tests
   - [ ] Test full insight generation flow
   - [ ] Test user context personalization
   - [ ] Test feedback loop

3. ✅ Widget tests
   - [ ] Test `AICoachCard` rendering
   - [ ] Test expandable sections
   - [ ] Test actionable workflows

4. ✅ Performance optimization
   - [ ] Profile insight generation (target: <500ms)
   - [ ] Add caching for expensive calculations
   - [ ] Implement incremental analysis (only new data)

5. ✅ Documentation
   - [ ] Update `docs/NAVIGATION/INDEX.md`
   - [ ] Create `AI_COACH_ARCHITECTURE.md`
   - [ ] Write analyzer plugin guide

**Deliverable**: 90%+ test coverage, <500ms insight generation, complete docs

---

## 📊 Success Metrics

**Before Refactoring**:
- False positive rate: ~40% (estimated from user feedback)
- Average insights per session: 3.5
- User engagement (insight tap): ~20%
- Actionable insights: ~30%

**After Refactoring (Target)**:
- False positive rate: <10% (4x improvement)
- Average insights per session: 2-3 (higher quality, less noise)
- User engagement: >50% (charts + guided workflows)
- Actionable insights: >80% (all fixable insights have workflows)

**How to Measure**:
1. **False Positive Rate**: % of insights marked "Not Helpful" (Firestore analytics)
2. **Engagement**: % of users who expand insight details (Firebase Analytics)
3. **Actionability**: % of insights that lead to template/workout changes (track button clicks)

---

## 🔮 Future Roadmap (Post-Phase 5)

### Short-Term (1-3 months)
- **Asymmetry Analyzer**: Left/right imbalance detection (requires unilateral exercise tracking)
- **Nutrition Analyzer**: Timing, macros integration (requires nutrition feature)
- **ML-based Plateau Prediction**: Train model on user workout history (data collection phase)

### Medium-Term (3-6 months)
- **Social Comparison Analyzer**: "You're in top 10% for squat" (requires user opt-in)
- **Injury Prediction Analyzer**: ML model trained on injury patterns (research phase)
- **Voice AI Coach**: Audio feedback during workouts (iOS/Android TTS integration)

### Long-Term (6-12 months)
- **Computer Vision Form Analysis**: Film exercises, get form feedback (OpenCV + ML)
- **Biometric Integration**: HRV, sleep quality → recovery insights (HealthKit/Google Fit)
- **AI-Generated Workout Programs**: Fully personalized plans (GPT-4 integration)

---

## 🚨 Risks & Mitigation

### Risk 1: Over-Engineering

**Risk**: Plugin architecture adds complexity for limited benefit
**Mitigation**: Keep plugin system simple (just a list of analyzers), defer advanced features (dynamic loading, hot reload) until needed

### Risk 2: Performance Regression

**Risk**: 10 analyzers = 10x slower insight generation
**Mitigation**:
- Profile early and often (target: <500ms)
- Implement parallel analysis (run analyzers concurrently)
- Add caching (don't recompute on every rebuild)

### Risk 3: User Confusion

**Risk**: More insights + complex UI = overwhelmed users
**Mitigation**:
- Limit to top 3 insights (not all 10)
- Progressive disclosure (hide details by default)
- Educational tooltips (teach users what MEV/MRV means)

### Risk 4: False Negatives

**Risk**: Stricter thresholds = miss real issues
**Mitigation**:
- A/B test threshold changes with beta users
- Monitor "Missed Opportunity" metrics (user reports issue that AI didn't catch)
- Feedback loop: let users request "Show me everything" mode

---

## 📚 References

### Scientific Papers (AI Coach Logic)
1. Israetel et al. (2017) - "Volume Landmarks for Muscle Growth"
2. Schoenfeld & Grgic (2018) - "Evidence-based guidelines for resistance training volume"
3. Rhea et al. (2002) - "Periodization and strength training: A meta-analysis"
4. Fry & Kraemer (1997) - "Resistance exercise overtraining and overreaching"
5. Kellmann et al. (2018) - "Recovery and Performance in Sport"

### Architecture Patterns
- Martin Fowler - "Domain-Driven Design"
- Eric Evans - "Strategic Design"
- Uncle Bob - "Clean Architecture"
- Gang of Four - "Strategy Pattern"

### Flutter/Dart Resources
- Riverpod 2.x Documentation
- `fl_chart` Package (data visualization)
- `freezed` Package (immutable entities)

---

## 🎯 Conclusion

This refactoring transforms the AI Coach from a **monolithic, generic insight generator** into a **modular, personalized, actionable coaching system** that:

✅ **Reduces false positives** through context-aware thresholds
✅ **Provides actionable guidance** with step-by-step workflows
✅ **Fills blind spots** (mobility, CNS fatigue, periodization)
✅ **Engages users** with charts, animations, and education
✅ **Scales effortlessly** via plugin architecture

**Ready to implement?** Share this document with your consultant to validate the approach, then proceed with Phase 1 (Architecture Refactoring).

---

**Questions for Consultant Review**:

1. **Architecture**: Is the plugin architecture overkill, or is it future-proof enough?
2. **Thresholds**: Should we use ML to learn optimal thresholds, or keep rule-based?
3. **Data Viz**: Is `fl_chart` sufficient, or should we consider custom painters?
4. **Personalization**: Should we collect more user context (sleep, stress, nutrition)?
5. **Extensibility**: Which future analyzers (asymmetry, nutrition, injury) should we prioritize?

---

**Document Version**: 1.0
**Last Updated**: 2025-01-15
**Next Review**: After consultant feedback
