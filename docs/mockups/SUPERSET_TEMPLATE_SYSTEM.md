# Superset Template System - Evidenze Scientifiche + Persona-Specific

## 🔬 EVIDENZE SCIENTIFICHE

### Meta-Analysis Summary
**Fonte principale**: [PMC Systematic Review & Meta-analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC12011898/)

**Key Findings:**
- ✅ **36% time savings** vs traditional training
- ✅ **Stessi guadagni** in muscle thickness, strength, power, hypertrophy
- ⚠️ **Higher perceived exertion** (RPE +1-2 points)
- ✅ **Optimal pairing**: Agonist-antagonist (opposti)
- ⚠️ **Recovery**: Necessario 48-72h tra sessioni (vs 24-48h tradizionale)

### Agonist-Antagonist Pairs (Evidenza: PubMed, MDPI)

| Muscle Group A | Muscle Group B | Time Saved | Evidence |
|----------------|----------------|------------|----------|
| Chest (Push) | Back (Pull) | 36% | [PubMed 20733520](https://pubmed.ncbi.nlm.nih.gov/20733520/) |
| Quadriceps | Hamstrings | 32% | [MDPI 10.4.419](https://www.mdpi.com/2411-5142/10/4/419) |
| Biceps | Triceps | 30% | [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0765159725001406) |
| Anterior Delts | Posterior Delts | 28% | PMC Review |
| Hip Flexors | Glutes | 34% | PMC Review |

**Meccanismo Scientifico:**
- Mentre un muscolo lavora, l'antagonista si riposa attivamente (reciprocal inhibition)
- Mantiene volume di allenamento equivalente
- Blood flow alternato = meno affaticamento sistemico
- Riduce interferenza neuromuscolare

---

## 👥 TEMPLATE PER PERSONA

### 1. Marco (Principiante) - "Foundations Builder"

**Filosofia**: Movimenti semplici, bassa complexity, auto-didattici

```yaml
Marco_ChestBack_Foundation:
  name: "Petto + Schiena Base"
  exercises:
    - Bench Press (Macchina Chest Press se disponibile)
    - Cable Row (Seated Row)
  rounds: 2
  reps_range: "10-12"
  rest_after_round: 120s  # Recovery maggiore per principianti
  rest_between: 30s       # Breve pausa tra esercizi (non true superset)
  difficulty: beginner
  estimated_time: 12min
  notes: "Macchine preferibili per imparare il movimento senza rischio"
  scientific_basis: "Agonist-antagonist pairing, extended rest for motor learning"
```

```yaml
Marco_LegCore_Foundation:
  name: "Gambe + Core Base"
  exercises:
    - Leg Press
    - Plank (isometric hold)
  rounds: 2
  reps_range: "12-15 / 30s hold"
  rest_after_round: 120s
  rest_between: 30s
  difficulty: beginner
  estimated_time: 10min
  notes: "Plank isometrico = bassa complexity, alto ritorno"
```

**Razionale Marco:**
- ❌ NO free weights inizialmente (intimidazione)
- ✅ Macchine guidate = focus su movimento, non su stabilizzazione
- ✅ Rest più lunghi = recovery completo, apprendimento motorio
- ✅ Solo 2 rounds = non overwhelming

---

### 2. Chiara (Busy Mom) - "Time Efficient"

**Filosofia**: Massimo risultato, minimo tempo, equipment flessibile

```yaml
Chiara_FullBody_Express:
  name: "Total Body 15min"
  exercises:
    - Dumbbell Bench Press
    - Dumbbell Row
  rounds: 3
  reps_range: "10-12"
  rest_after_round: 60s   # Minimal rest per velocità
  rest_between: 0s        # True superset
  difficulty: intermediate
  estimated_time: 15min
  notes: "Funziona anche a casa con manubri. Può essere fatto durante pausa pranzo."
  scientific_basis: "Agonist-antagonist, optimized for time efficiency"
  equipment_alternatives:
    - "Resistance bands se no manubri"
    - "Push-ups + Inverted Rows (bodyweight)"
```

```yaml
Chiara_LowerPower_Express:
  name: "Gambe Potenti 12min"
  exercises:
    - Goblet Squat
    - Romanian Deadlift (or Single Leg RDL)
  rounds: 3
  reps_range: "8-10"
  rest_after_round: 60s
  rest_between: 0s
  difficulty: intermediate
  estimated_time: 12min
  notes: "Singolo manubrio/kettlebell per goblet squat = minimal equipment"
  scientific_basis: "Quad-dominant + Hip-dominant pairing"
```

**Razionale Chiara:**
- ✅ True superset (0s rest between) = massima efficienza
- ✅ Compound movements = più muscoli in meno tempo
- ✅ Equipment flessibile = adattabile a home/gym
- ✅ Target: <20min total

---

### 3. Luca (Powerlifter) - "Strength Focus"

**Filosofia**: Heavy compounds, volume elevato, precisione tecnica

```yaml
Luca_ChestBack_Strength:
  name: "Bench + Row Powerlifting"
  exercises:
    - Barbell Bench Press
    - Barbell Row (Pendlay or Bent-Over)
  rounds: 5
  reps_range: "5-6"       # Low reps, high intensity
  rest_after_round: 180s  # Full recovery per strength
  rest_between: 60s       # Partial rest tra antagonisti
  difficulty: advanced
  estimated_time: 35min
  notes: "Percentage-based: 80-85% 1RM. Track RPE per set. Focus on bar speed."
  scientific_basis: "Agonist-antagonist preserves strength output across sets"
  progression: "Add 2.5kg when RPE <8 su ultimo set"
```

```yaml
Luca_LegPower_Strength:
  name: "Squat + Hamstring Power"
  exercises:
    - Barbell Back Squat
    - Barbell Romanian Deadlift
  rounds: 4
  reps_range: "4-6"
  rest_after_round: 240s  # Powerlifting rest standard
  rest_between: 90s
  difficulty: advanced
  estimated_time: 40min
  notes: "Quad-dominant + Hip-dominant. Mantieni tensione costante su RDL."
  scientific_basis: "Hip flexor/extensor antagonism"
```

**Razionale Luca:**
- ✅ Barbell movements = standard powerlifting
- ✅ 4-5 rounds = volume elevato per forza
- ✅ Rest lunghi = recovery neurologico completo
- ✅ RPE tracking = autoregulation
- ✅ Percentage-based progression

---

### 4. Sofia (Estetica) - "Hypertrophy Sculpting"

**Filosofia**: Isolation + compound, mind-muscle connection, simmetria

```yaml
Sofia_ChestBack_Sculpt:
  name: "Petto + Schiena Definizione"
  exercises:
    - Incline Dumbbell Press
    - Cable Lat Pulldown (Wide Grip)
    - Cable Fly (optional 3rd exercise)
  rounds: 4
  reps_range: "10-15"     # Hypertrophy range
  rest_after_round: 90s
  rest_between: 15s       # Breve per pump
  difficulty: intermediate-advanced
  estimated_time: 25min
  notes: "Focus su contrazione picco. Tempo: 3-1-2 (eccentric-pause-concentric)"
  scientific_basis: "Volume accumulation for hypertrophy, antagonist pairing"
  tut: "3-1-2"            # Time Under Tension
  target_muscles: "Upper Pecs + Lats (V-taper aesthetic)"
```

```yaml
Sofia_ShoulderArms_Sculpt:
  name: "Spalle + Braccia Tonicità"
  exercises:
    - Lateral Raise
    - Face Pulls
    - Bicep Curl (optional)
  rounds: 3
  reps_range: "12-15"
  rest_after_round: 75s
  rest_between: 10s
  difficulty: intermediate
  estimated_time: 20min
  notes: "Anterior vs Posterior delts = bilanciamento spalle. Pump focus."
  scientific_basis: "Shoulder balance prevents injuries, aesthetic symmetry"
  target_muscles: "3D Delts (anterior + posterior)"
```

**Razionale Sofia:**
- ✅ Higher reps (10-15) = hypertrophy range
- ✅ TUT notation per mind-muscle connection
- ✅ 3-4 rounds = volume per crescita muscolare
- ✅ Cable/isolation = focus su singoli muscoli
- ✅ Muscle balance tracking

---

### 5. Roberto (Busy Professional) - "Minimal Equipment, Maximum ROI"

**Filosofia**: Functional, adattabile, zero excuses

```yaml
Roberto_TravelFriendly_HotelGym:
  name: "Hotel Gym Total Body"
  exercises:
    - Dumbbell Bench Press
    - Dumbbell Row
  rounds: 3
  reps_range: "10-12"
  rest_after_round: 75s
  rest_between: 0s
  difficulty: intermediate
  estimated_time: 18min
  notes: "Solo manubri richiesti. Funziona anche con pesi leggeri (high reps)."
  scientific_basis: "Agonist-antagonist, minimal equipment"
  equipment_required: "Dumbbells only"
  fallback_bodyweight: "Push-ups + Inverted Rows"
```

```yaml
Roberto_Bodyweight_NoGym:
  name: "Bodyweight Circuit"
  exercises:
    - Push-ups (o Archer Push-ups)
    - Pull-ups (o Australian Pull-ups)
  rounds: 4
  reps_range: "AMRAP -2" # As Many Reps As Possible, stop 2 before failure
  rest_after_round: 90s
  rest_between: 0s
  difficulty: intermediate-advanced
  estimated_time: 15min
  notes: "Zero equipment. Parco pubblico, camera hotel, ovunque."
  scientific_basis: "Push-pull antagonism, relative strength"
  equipment_required: "None (pull-up bar se disponibile)"
```

**Razionale Roberto:**
- ✅ Equipment-flexible = funziona ovunque
- ✅ Bodyweight fallback = zero excuses
- ✅ <20min = fits in busy schedule
- ✅ Functional movements = carry-over a vita quotidiana

---

## 🏗️ ARCHITETTURA TECNICA

### Domain Layer

```dart
// lib/features/workout/domain/entities/superset_template.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'superset_template.freezed.dart';
part 'superset_template.g.dart';

@freezed
class SupersetTemplate with _$SupersetTemplate {
  const factory SupersetTemplate({
    required String id,
    required String name,
    required List<String> exerciseNames, // Nomi esercizi (match con DB)
    required int rounds,
    required String repsRange,          // "10-12", "8-10", etc.
    required int restAfterRound,        // seconds
    required int restBetween,           // seconds tra esercizi
    required TemplateDifficulty difficulty,
    required int estimatedTimeMinutes,
    required String scientificBasis,
    String? notes,
    String? tut,                        // "3-1-2" se applicabile
    List<String>? equipmentRequired,
    List<String>? equipmentAlternatives,
    UserPersona? targetPersona,         // null = generic
    List<String>? targetMuscles,
    DateTime? createdAt,
    bool isCustom,                      // User-created vs predefined
  }) = _SupersetTemplate;

  factory SupersetTemplate.fromJson(Map<String, dynamic> json) =>
      _$SupersetTemplateFromJson(json);
}

enum TemplateDifficulty {
  beginner,
  intermediate,
  intermediateAdvanced,
  advanced,
}

enum UserPersona {
  marco,      // Principiante
  chiara,     // Busy Mom
  luca,       // Powerlifter
  sofia,      // Estetica
  roberto,    // Professional
  generic,    // Nessuna persona specifica
}
```

### Data Layer

```dart
// lib/features/workout/data/repositories/superset_template_repository.dart

class SupersetTemplateRepository extends BaseHybridRepository<SupersetTemplate> {
  SupersetTemplateRepository({
    required HiveDataSource<SupersetTemplate> hiveDataSource,
    required FirestoreDataSource<SupersetTemplate> firestoreDataSource,
  }) : super(
          hiveDataSource: hiveDataSource,
          firestoreDataSource: firestoreDataSource,
        );

  /// Get predefined templates (shipped with app)
  Future<List<SupersetTemplate>> getPredefinedTemplates() async {
    return _predefinedTemplates; // Static list from YAML configs
  }

  /// Get user's custom templates
  Future<List<SupersetTemplate>> getUserTemplates(String userId) async {
    return getAll(userId: userId);
  }

  /// Get templates for specific persona
  Future<List<SupersetTemplate>> getTemplatesForPersona(UserPersona persona) async {
    final all = await getPredefinedTemplates();
    return all.where((t) => t.targetPersona == persona || t.targetPersona == null).toList();
  }

  /// Save custom template
  Future<void> saveCustomTemplate(SupersetTemplate template) async {
    await create(template.copyWith(isCustom: true));
  }
}
```

### Presentation Layer - Template Browser

```dart
// lib/features/workout/presentation/screens/superset_template_browser.dart

class SupersetTemplateBrowser extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(supersetTemplateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.supersetTemplates),
        actions: [
          IconButton(
            icon: Icon(AppIcons.add),
            onPressed: () => _createCustomTemplate(context),
          ),
        ],
      ),
      body: templates.when(
        data: (templateList) => ListView(
          children: [
            // Section 1: Persona-based (if user has persona set)
            if (_currentPersona != null)
              _buildSection(
                context,
                title: context.l10n.recommendedForYou,
                templates: templateList.where((t) => t.targetPersona == _currentPersona),
              ),

            // Section 2: Scientific Evidence-Based
            _buildSection(
              context,
              title: context.l10n.evidenceBased,
              subtitle: context.l10n.basedOnResearch,
              templates: templateList.where((t) => t.scientificBasis.isNotEmpty),
            ),

            // Section 3: Custom Templates
            _buildSection(
              context,
              title: context.l10n.myTemplates,
              templates: templateList.where((t) => t.isCustom),
            ),

            // Section 4: All Templates (by difficulty)
            _buildSection(
              context,
              title: context.l10n.allTemplates,
              templates: templateList,
              groupBy: (t) => t.difficulty,
            ),
          ],
        ),
        loading: () => LoadingIndicator(),
        error: (e, st) => ErrorWidget(e),
      ),
    );
  }
}
```

### Integration with SupersetLinkModal

```dart
// In SupersetLinkModal, add 3rd tab:

enum SupersetSelectionTab {
  inWorkout,
  fromDatabase,
  fromTemplate,  // NEW!
}

// In _buildTabContent:
case SupersetSelectionTab.fromTemplate:
  return _buildTemplateTab();

Widget _buildTemplateTab() {
  return Column(
    children: [
      // Quick filter chips
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text('Marco (Beginner)'),
              selected: _selectedPersona == UserPersona.marco,
              onSelected: (selected) => _filterByPersona(UserPersona.marco),
            ),
            // ... other persona chips
            FilterChip(
              label: Text(context.l10n.evidenceBased),
              selected: _showOnlyEvidenceBased,
            ),
          ],
        ),
      ),

      // Template list
      Expanded(
        child: ref.watch(supersetTemplateProvider).when(
          data: (templates) => ListView.builder(
            itemCount: templates.length,
            itemBuilder: (ctx, idx) {
              final template = templates[idx];
              return TemplateCard(
                template: template,
                onTap: () => _applyTemplate(template),
              );
            },
          ),
          loading: () => LoadingIndicator(),
          error: (e, st) => ErrorWidget(e),
        ),
      ),
    ],
  );
}

/// Apply template to current superset configuration
void _applyTemplate(SupersetTemplate template) {
  // 1. Find exercises in workout OR database
  final exercises = template.exerciseNames
      .map((name) => _findExerciseByName(name))
      .whereType<Exercise>()
      .toList();

  // 2. Pre-fill configuration
  final config = SupersetConfiguration(
    exercises: exercises,
    rounds: List.generate(
      template.rounds,
      (i) => SupersetRound(
        roundNumber: i + 1,
        exerciseConfigs: {
          for (var ex in exercises)
            ex.id: SupersetExerciseConfig(
              exerciseId: ex.id,
              reps: _parseRepsRange(template.repsRange).first, // Take lower bound
              weight: ex.weight ?? 0,
              restAfter: i < template.rounds - 1 ? template.restBetween : 0,
            ),
        },
      ),
    ),
    restAfterRound: template.restAfterRound,
    name: template.name,
  );

  // 3. Update state
  setState(() {
    _selectedExercises = exercises;
    _prefilledConfig = config;
  });

  // 4. Navigate to config sheet
  _proceedToConfiguration();
}
```

---

## 📦 PREDEFINED TEMPLATES DATA

### Storage Strategy

**Option A**: YAML files in `assets/data/superset_templates/`
```
assets/data/superset_templates/
├── marco_templates.yaml
├── chiara_templates.yaml
├── luca_templates.yaml
├── sofia_templates.yaml
├── roberto_templates.yaml
└── evidence_based.yaml
```

**Option B**: JSON in `assets/data/superset_templates.json`
```json
{
  "templates": [
    {
      "id": "marco_chest_back_foundation",
      "name": "Petto + Schiena Base",
      "exerciseNames": ["Bench Press", "Cable Row"],
      "rounds": 2,
      "repsRange": "10-12",
      "restAfterRound": 120,
      "restBetween": 30,
      "difficulty": "beginner",
      "estimatedTimeMinutes": 12,
      "scientificBasis": "Agonist-antagonist pairing with extended rest for motor learning",
      "notes": "Usa macchine se disponibili per imparare il movimento",
      "targetPersona": "marco",
      "isCustom": false
    }
  ]
}
```

**Scelta consigliata**: JSON per facilità di parsing con Dart.

### Loading Service

```dart
// lib/features/workout/domain/services/superset_template_loader.dart

class SupersetTemplateLoader {
  static Future<List<SupersetTemplate>> loadPredefinedTemplates() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/superset_templates.json',
    );
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final templates = (json['templates'] as List)
        .map((t) => SupersetTemplate.fromJson(t as Map<String, dynamic>))
        .toList();

    return templates;
  }

  /// Load only templates for specific persona
  static Future<List<SupersetTemplate>> loadForPersona(UserPersona persona) async {
    final all = await loadPredefinedTemplates();
    return all.where((t) => t.targetPersona == persona || t.targetPersona == null).toList();
  }

  /// Load only evidence-based templates
  static Future<List<SupersetTemplate>> loadEvidenceBased() async {
    final all = await loadPredefinedTemplates();
    return all.where((t) => t.scientificBasis.isNotEmpty).toList();
  }
}
```

---

## 🎯 UX FLOW COMPLETO

### Scenario 1: Marco (Beginner) - First Superset

```
1. Marco apre workout screen
2. Vede "Bench Press" nel workout
3. Tap su menu (⋮)
4. Tap "Create Superset"
5. 🆕 VEDE 3 TAB: [In Workout] [From Database] [📋 Templates]
6. Tap "Templates" tab
7. VEDE sezione "Recommended for Beginners" in alto
8. VEDE "Petto + Schiena Base" con badge "🔰 Beginner"
9. Tap sulla card
10. VEDE preview:
    - "Bench Press + Cable Row"
    - "2 rounds × 10-12 reps"
    - "Rest: 120s dopo round"
    - "⏱ 12 min estimated"
    - "💡 Uses machines - easier to learn"
11. Tap "Use This Template"
12. ✅ SUPERSET CREATO automaticamente con config ottimale
```

**Impatto Marco:**
- ✅ Da 4+ taps a 3 taps
- ✅ Nessuna confusione su "quali esercizi abbinare"
- ✅ Guidance built-in ("uses machines")
- ✅ Confidence boost (vede che è per beginners)

### Scenario 2: Chiara (Busy Mom) - Quick Template

```
1. Chiara ha 20 minuti di pausa pranzo
2. Apre app, "Start Workout"
3. Invece di creare da zero, tap "⚡ Quick Start from Template"
4. VEDE filtro "Time-based" attivo
5. VEDE "Total Body 15min" (Chiara template)
6. Tap
7. WORKOUT CREATO con superset pre-configurato
8. Tap "Start" e inizia direttamente
```

**Impatto Chiara:**
- ✅ Zero configuration time
- ✅ Template ottimizzato per 15-20min
- ✅ Equipment-flexible (può fare a casa)

### Scenario 3: Luca (Powerlifter) - Evidence-Based

```
1. Luca vuole provare agonist-antagonist training
2. Tap "Templates" in SupersetLinkModal
3. APPLICA filtro "📚 Evidence-Based"
4. VEDE lista con badge "🔬 36% time savings"
5. Tap su "Bench + Row Powerlifting"
6. LEGGE scientific basis: "Agonist-antagonist preserves strength..."
7. VEDE link: "📄 Read Research (PubMed)"
8. Tap "Use Template"
9. MODIFICA rounds: 5 → 6 (perché vuole più volume)
10. Salva come "My Custom Powerlifting Superset"
```

**Impatto Luca:**
- ✅ Evidence-based = trustworthy
- ✅ Può leggere ricerca originale
- ✅ Può customizzare e salvare varianti

---

## 📊 A/B TEST PLAN

### Hypothesis

**H1**: Template system aumenta superset adoption rate del +150%
- **Measure**: % workouts con superset (current: 5% → target: 12.5%)
- **Segment**: Tutti gli utenti

**H2**: Persona-specific templates migliorano beginner retention
- **Measure**: 90-day retention rate per Marco persona
- **Current**: 35% → **Target**: 50%

**H3**: Evidence-based templates aumentano trust in advanced users
- **Measure**: NPS score da Luca persona
- **Current**: 7.5/10 → **Target**: 8.8/10

### Test Design

**Group A (Control)**: Current superset creation flow (manual selection)
**Group B (Test)**: SupersetLinkModal con tab "Templates" + predefined templates
**Group C (Test)**: Group B + onboarding tooltip "Try templates for guided superset creation"

**Duration**: 6 weeks
**Sample size**: 3,000 users (1,000 per group)

### Success Metrics

**Primary:**
- Superset adoption rate (+150%)
- Template usage rate (target: 60% of supersets created via templates)

**Secondary:**
- Time to create superset (-60%)
- Superset completion rate (+20%)
- Support tickets re: "how to pair exercises" (-70%)

**Qualitative:**
- User interviews (n=15 per persona)
- Heatmaps on template browser
- "Was this template helpful?" rating (target: 4.5/5)

---

## 🚀 IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Week 1-2)
- [ ] Create `SupersetTemplate` domain entity
- [ ] Create `SupersetTemplateRepository`
- [ ] Create JSON data file con 15 predefined templates (3 per persona)
- [ ] Create `SupersetTemplateLoader` service
- [ ] Unit tests per domain/data layers

### Phase 2: UI (Week 3)
- [ ] Create `SupersetTemplateBrowser` screen
- [ ] Create `TemplateCard` widget
- [ ] Integrate "Templates" tab in `SupersetLinkModal`
- [ ] Implement template application logic
- [ ] Widget tests per UI components

### Phase 3: Persona Integration (Week 4)
- [ ] Auto-detect user persona from `AppConfig`
- [ ] Filter templates by persona in browser
- [ ] Add "Recommended for You" section
- [ ] Create onboarding tooltip per first-time template usage

### Phase 4: Advanced Features (Week 5-6)
- [ ] Custom template creation UI
- [ ] Template sharing (export/import JSON)
- [ ] Template rating system ("Was this helpful?")
- [ ] In-app links to scientific research papers
- [ ] Analytics tracking per template usage

### Phase 5: A/B Testing (Week 7-12)
- [ ] Deploy to 33% users (Group B)
- [ ] Monitor metrics dashboard
- [ ] Collect user feedback
- [ ] Iterate based on data
- [ ] 100% rollout if success criteria met

---

## 📚 REFERENCES

### Scientific Research
1. [PubMed: Agonist-antagonist paired set resistance training](https://pubmed.ncbi.nlm.nih.gov/20733520/)
2. [MDPI: Effects of Varying Antagonist Exercise Volume](https://www.mdpi.com/2411-5142/10/4/419)
3. [ScienceDirect: Less time, same gains with supersets](https://www.sciencedirect.com/science/article/abs/pii/S0765159725001406)
4. [PMC: Systematic Review and Meta-analysis of Supersets](https://pmc.ncbi.nlm.nih.gov/articles/PMC12011898/)

### UX Best Practices
- Progressive disclosure for beginners
- Smart defaults to reduce decision fatigue
- Evidence-based trust signals for advanced users
- Persona-specific recommendations

### Design Patterns
- Template pattern (Gang of Four)
- Strategy pattern for persona-specific logic
- Repository pattern for data access
- Clean Architecture separation of concerns

---

## 💡 FUTURE ENHANCEMENTS

### AI-Powered Suggestions
- Analyze user's workout history
- Suggest optimal superset pairings based on:
  - Muscle groups trained recently (balance)
  - Equipment available in current workout
  - Time constraints (quick vs full session)
  - Fatigue level (from RPE tracking)

### Community Templates
- User-generated templates
- Voting/rating system
- "Most popular this week"
- Coach-verified badge

### Progressive Template System
- Template "graduation": Beginner → Intermediate → Advanced
- Auto-suggest next level when user consistently hits targets
- Progression tracking: "You've completed this template 12 times!"

### Integration with Analytics
- "Your best performing superset: Bench+Row (PR 3x in last month)"
- "This template saves you 18 minutes per workout"
- Volume tracking per template
