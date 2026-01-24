# Exercise Search Screen - Con Template Integrati

## 🔴 BEFORE (Current State)

```
┌─────────────────────────────────────┐
│  ← Exercise Search              [⋮] │
├─────────────────────────────────────┤
│  🔍 Search exercises...             │
│  ┌───────────────────────────────┐  │
│  │ 💪 Petto  🦵 Gambe  🏋️ Spalle │  │ ← Quick filters
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  ⏱ Recent Exercises                 │
│  ┌───────────────────────────────┐  │
│  │ [Bench] [Squat] [Row]        │  │ ← Recent chips
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  1,247 exercises found              │
│  ┌───────────────────────────────┐  │
│  │ Bench Press                  │  │
│  │ 💪 Petto | 🏋️ Bilanciere      │  │
│  ├───────────────────────────────┤  │
│  │ Squat                        │  │
│  │ 🦵 Gambe | 🏋️ Bilanciere      │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**PROBLEMI:**
- ❌ Nessun template visibile
- ❌ Utente deve creare superset manualmente (4+ taps)
- ❌ Nessuna guidance su pairing ottimali

---

## 🟢 AFTER (Con Template Integrati)

```
┌─────────────────────────────────────┐
│  ← Exercise Search              [⋮] │
├─────────────────────────────────────┤
│  🔍 Search exercises...             │
│  ┌───────────────────────────────┐  │
│  │ 💪 Petto  🦵 Gambe  🏋️ Spalle │  │ ← Quick filters
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  🎯 Recommended Templates           │ ← 🆕 NUOVO!
│  ┌───────────────────────────────┐  │
│  │ ┌─────┐ ┌─────┐ ┌─────┐      │  │
│  │ │ SS  │ │ SS  │ │ DS  │ →    │  │ ← Template cards (scroll)
│  │ │Bench│ │Squat│ │Arms│       │  │
│  │ │ Row │ │ Leg │ │Pump│       │  │
│  │ │15min│ │12min│ │8min│       │  │
│  │ └─────┘ └─────┘ └─────┘      │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  ⏱ Recent Exercises                 │
│  ┌───────────────────────────────┐  │
│  │ [Bench] [Squat] [Row]        │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  1,247 exercises found              │
│  ┌───────────────────────────────┐  │
│  │ Bench Press                  │  │
│  │ 💪 Petto | 🏋️ Bilanciere      │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**MIGLIORAMENTI:**
- ✅ Template visibili immediatamente (sopra recent exercises)
- ✅ Scroll orizzontale come recent exercises (UI familiare)
- ✅ Tap su template → Preview + "Use Template"
- ✅ Badge tipo template: SS (Superset), DS (Dropset), RP (Rest-Pause)

---

## 🎨 DESIGN SPECS

### Template Card Design

```
┌─────────────────┐
│ 🔗 SS           │ ← Badge tipo (SS, DS, RP)
│                 │
│ Bench + Row     │ ← Nome (max 2 righe)
│                 │
│ 💪 Petto·Back   │ ← Muscle groups
│                 │
│ ⏱ 15min         │ ← Estimated time
│ 🔰 Beginner     │ ← Difficulty badge (optional)
│ 🔬 Evidence     │ ← Evidence-based badge (optional)
└─────────────────┘
Size: 140w × 160h dp
```

**Colori Badge:**
- **SS (Superset)**: `context.colors.primary` (blu/viola)
- **DS (Dropset)**: `context.colors.secondary` (arancione)
- **RP (Rest-Pause)**: `context.colors.tertiary` (verde)

**Icons:**
- SS: `AppIcons.link`
- DS: `AppIcons.trendDown` (weight decreasing)
- RP: `AppIcons.pause` (pause between reps)

**Evidence Badge:**
- Background: `context.colors.primaryContainer`
- Icon: `AppIcons.science` (beaker icon se disponibile)
- Tooltip: "Based on scientific research"

**Difficulty Badge:**
- 🔰 Beginner (verde chiaro)
- ⚡ Intermediate (giallo)
- 🔥 Advanced (rosso)

### Sezione "Recommended Templates"

```dart
// Position: Dopo quick filters, prima di recent exercises
// Visibilità: SEMPRE (non dipende da search query)
// Logica raccomandazione:
//   1. Persona-specific se utente ha persona impostata
//   2. Evidence-based templates (top 3)
//   3. Most popular (da usage stats)

Widget _buildRecommendedTemplates() {
  // Watch user persona from AppConfig
  final userPersona = ref.watch(
    appConfigProvider.select((c) => c.userPersona),
  );

  // Load templates
  final templatesAsync = ref.watch(supersetTemplatesProvider);

  return templatesAsync.when(
    data: (templates) {
      // Filter logic
      final recommended = _getRecommendedTemplates(
        templates,
        userPersona: userPersona,
        limit: 5,
      );

      if (recommended.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(AppIcons.star, size: 16, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.recommendedTemplates,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal scroll
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final template = recommended[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TemplateCard(
                    template: template,
                    onTap: () => _showTemplatePreview(template),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 16),
        ],
      );
    },
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  );
}
```

### Template Card Widget

```dart
class TemplateCard extends StatelessWidget {
  final SupersetTemplate template; // or ExerciseTemplate (generic)
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge tipo template
            Row(
              children: [
                _buildTypeBadge(context),
                const Spacer(),
                if (template.scientificBasis.isNotEmpty)
                  Icon(
                    AppIcons.science,
                    size: 14,
                    color: context.colors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Nome template (max 2 righe)
            Expanded(
              child: Text(
                template.name,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Muscle groups
            Text(
              _getMuscleGroupsText(template),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Bottom info
            Row(
              children: [
                Icon(AppIcons.timer, size: 12, color: context.colors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${template.estimatedTimeMinutes}min',
                  style: context.textTheme.bodySmall,
                ),
                const Spacer(),
                _buildDifficultyBadge(context, template.difficulty),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final icon = _getTypeIcon();
    final label = _getTypeLabel();
    final color = _getTypeColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    // Superset, Dropset, Rest-Pause
    return AppIcons.link; // TODO: add AppIcons.dropset, AppIcons.restPause
  }

  String _getTypeLabel() {
    return 'SS'; // or 'DS', 'RP'
  }

  Color _getTypeColor(BuildContext context) {
    return context.colors.primary; // or secondary, tertiary
  }

  Widget _buildDifficultyBadge(BuildContext context, TemplateDifficulty difficulty) {
    final emoji = switch (difficulty) {
      TemplateDifficulty.beginner => '🔰',
      TemplateDifficulty.intermediate => '⚡',
      TemplateDifficulty.intermediateAdvanced => '⚡',
      TemplateDifficulty.advanced => '🔥',
    };

    return Text(emoji, style: const TextStyle(fontSize: 12));
  }

  String _getMuscleGroupsText(SupersetTemplate template) {
    // Extract muscle groups from targetMuscles
    if (template.targetMuscles == null || template.targetMuscles!.isEmpty) {
      return '';
    }

    // Abbreviate muscle names
    final abbreviated = template.targetMuscles!.map((m) {
      if (m == 'Petto') return '💪';
      if (m == 'Dorsali') return '🔙';
      if (m == 'Gambe') return '🦵';
      if (m == 'Spalle') return '🏋️';
      return m.substring(0, 3); // Fallback: first 3 chars
    });

    return abbreviated.join(' · ');
  }
}
```

---

## 📊 TEMPLATE PREVIEW MODAL

Quando utente tappa su template card:

```
┌─────────────────────────────────────┐
│  ← Bench + Row Superset             │
│                                     │
│  ⚡ 15min  🔰 Beginner               │
│  🔬 Evidence-Based                  │
├─────────────────────────────────────┤
│  Exercises:                         │
│  ┌───────────────────────────────┐  │
│  │ 1. Bench Press                │  │
│  │    80kg × 10 reps             │  │
│  │                               │  │
│  │ 2. Dumbbell Row               │  │
│  │    35kg × 12 reps             │  │
│  └───────────────────────────────┘  │
│                                     │
│  Rounds: 3                          │
│  Rest after round: 90s              │
│  Rest between exercises: 0s (true SS)│
│                                     │
│  💡 Why this works:                 │
│  Agonist-antagonist pairing saves   │
│  36% time with same muscle gains.   │
│  Research: PMC 12011898             │ ← Link to paper
│                                     │
│  [📄 Read Research]  [Use Template] │
└─────────────────────────────────────┘
```

**Implementation:**

```dart
void _showTemplatePreview(SupersetTemplate template) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => TemplatePreviewSheet(
        template: template,
        scrollController: scrollController,
        onUseTemplate: () => _useTemplate(template),
      ),
    ),
  );
}

void _useTemplate(SupersetTemplate template) {
  // Close preview
  Navigator.of(context).pop();

  // Convert template to SupersetConfiguration
  final config = _templateToConfiguration(template);

  // Navigate back to workout screen
  if (widget.onExerciseAdded != null) {
    // If callback provided (called from workout screen)
    // Create superset exercise and pass back
    final supersetExercise = _createSupersetFromTemplate(template);
    widget.onExerciseAdded!(supersetExercise);
    Navigator.of(context).pop();
  } else {
    // Navigate to workout screen with template
    context.go('/workout', extra: {'supersetTemplate': template});
  }
}
```

---

## 🧩 ARCHITETTURA - GENERIC TEMPLATE SYSTEM

Per supportare Superset, Dropset, Rest-Pause in futuro:

```dart
// Base template interface
abstract class ExerciseTemplate {
  String get id;
  String get name;
  TemplateType get type;
  TemplateDifficulty get difficulty;
  int get estimatedTimeMinutes;
  UserPersona? get targetPersona;
  String get scientificBasis;
}

enum TemplateType {
  superset,
  dropset,
  restPause,
  circuit,
  // Future: AMRAP, EMOM, etc.
}

// Superset template (già implementato)
class SupersetTemplate implements ExerciseTemplate {
  @override
  final TemplateType type = TemplateType.superset;
  // ... existing fields
}

// Dropset template (futuro)
class DropsetTemplate implements ExerciseTemplate {
  @override
  final TemplateType type = TemplateType.dropset;

  final String exerciseName;
  final List<DropsetStep> steps; // e.g., [80kg×8, 60kg×10, 40kg×12]
  final int restBetweenSteps;
  // ...
}

// Rest-Pause template (futuro)
class RestPauseTemplate implements ExerciseTemplate {
  @override
  final TemplateType type = TemplateType.restPause;

  final String exerciseName;
  final int targetReps; // e.g., 20 reps total
  final int pauseDuration; // e.g., 15s between mini-sets
  final List<int> miniSetReps; // e.g., [6, 5, 4, 3, 2]
  // ...
}
```

### Generic Template Provider

```dart
// Provider che unisce tutti i tipi di template
final allExerciseTemplatesProvider = FutureProvider<List<ExerciseTemplate>>((ref) async {
  final supersets = await ref.watch(supersetTemplatesProvider.future);
  // Future:
  // final dropsets = await ref.watch(dropsetTemplatesProvider.future);
  // final restPause = await ref.watch(restPauseTemplatesProvider.future);

  return [
    ...supersets,
    // ...dropsets,
    // ...restPause,
  ];
});

// Recommended templates (smart filtering)
List<ExerciseTemplate> _getRecommendedTemplates(
  List<ExerciseTemplate> templates, {
  UserPersona? userPersona,
  int limit = 5,
}) {
  // 1. Filter by persona if set
  var filtered = templates;
  if (userPersona != null) {
    final personaMatches = templates
        .where((t) => t.targetPersona == userPersona)
        .toList();

    if (personaMatches.isNotEmpty) {
      filtered = personaMatches;
    }
  }

  // 2. Prioritize evidence-based
  filtered.sort((a, b) {
    final aHasEvidence = a.scientificBasis.isNotEmpty;
    final bHasEvidence = b.scientificBasis.isNotEmpty;

    if (aHasEvidence && !bHasEvidence) return -1;
    if (!aHasEvidence && bHasEvidence) return 1;

    // Fallback: by estimated time (shorter first)
    return a.estimatedTimeMinutes.compareTo(b.estimatedTimeMinutes);
  });

  return filtered.take(limit).toList();
}
```

---

## 🎯 USER FLOW COMPLETO

### Scenario 1: Marco (Beginner) cerca esercizio

```
1. Marco apre ExerciseSearchScreen (da workout screen)
2. VEDE sezione "Recommended Templates" in alto
3. VEDE template "Petto + Schiena Base" 🔰 Beginner
4. Tap sulla card
5. LEGGE preview:
   - "Bench Press + Cable Row"
   - "2 rounds × 10-12 reps"
   - "120s rest dopo round"
   - "💡 Usa macchine per imparare il movimento"
6. Tap "Use Template"
7. ✅ SUPERSET CREATO automaticamente nel workout
8. Screen chiude, torna a workout screen con superset già pronto
```

**Impatto Marco:**
- ✅ Da "non so cosa fare" a "template guidato" in 3 taps
- ✅ Vede badge "Beginner" = confidence boost
- ✅ Nota esplicativa = educational

### Scenario 2: Chiara (Busy Mom) cerca quick workout

```
1. Chiara ha 20min di pausa pranzo
2. Apre ExerciseSearchScreen
3. VEDE "Total Body 15min" ⚡ 15min
4. Tap → Preview
5. LEGGE: "Dumbbell Bench + Row, true superset (0s rest)"
6. Tap "Use Template"
7. ✅ SUPERSET PRONTO in 2 taps
8. Inizia workout immediatamente
```

**Impatto Chiara:**
- ✅ Template ottimizzato per tempo (15min visibile subito)
- ✅ Equipment-flexible (manubri = può fare a casa)
- ✅ Zero configurazione = massima efficienza

### Scenario 3: Luca (Powerlifter) cerca evidence-based

```
1. Luca apre ExerciseSearchScreen
2. VEDE template con badge 🔬 Evidence
3. Tap → Preview
4. LEGGE scientific basis: "36% time savings (PMC 12011898)"
5. Tap "📄 Read Research" → apre paper in browser
6. TORNA → Tap "Use Template"
7. MODIFICA rounds: 5 → 6 (più volume)
8. Conferma → SUPERSET CREATO
```

**Impatto Luca:**
- ✅ Evidence-based = trust
- ✅ Link diretto al paper = transparency
- ✅ Può customizzare prima di usare

---

## 🚀 IMPLEMENTATION ROADMAP

### Phase 1: Foundation (Week 1)
- [ ] Create generic `ExerciseTemplate` interface
- [ ] Migrate `SupersetTemplate` to implement interface
- [ ] Create `allExerciseTemplatesProvider`
- [ ] Create `TemplateCard` widget
- [ ] Unit tests

### Phase 2: UI Integration (Week 2)
- [ ] Add `_buildRecommendedTemplates()` in ExerciseSearchScreen
- [ ] Implement template filtering logic (persona-specific)
- [ ] Create `TemplatePreviewSheet` modal
- [ ] Integration tests

### Phase 3: Template Usage Flow (Week 3)
- [ ] Implement `_useTemplate()` callback
- [ ] Convert template → SupersetConfiguration
- [ ] Pass back to workout screen via callback
- [ ] Analytics tracking (template usage)

### Phase 4: Evidence Links (Week 4)
- [ ] Add "Read Research" button in preview
- [ ] Open paper URL in in-app browser
- [ ] Analytics tracking (research link taps)

### Phase 5: Future Templates (Week 5+)
- [ ] Create `DropsetTemplate` class
- [ ] Create `RestPauseTemplate` class
- [ ] Implement template JSON files
- [ ] Add to `allExerciseTemplatesProvider`

---

## 📊 EXPECTED IMPACT

### User Adoption

**Superset adoption rate:**
- Current: 5% of workouts contain supersets
- Target: 20% (+300% increase)
- Reason: Templates visibili nella schermata più usata

**Template usage rate:**
- Target: 40% of supersets created via templates
- Reason: Convenience + guidance + evidence-based trust

### Persona Impact

| Persona | Current Pain | After Templates | Impact |
|---------|-------------|-----------------|--------|
| Marco | "Non so come creare superset" | Vede template beginner-friendly | +500% adoption |
| Chiara | "Troppi taps, troppo tempo" | Template 15min ready-to-use | +300% adoption |
| Luca | "Voglio scientific backing" | Evidence-based templates con link paper | +150% adoption |

### Metrics

**Primary:**
- Template visibility rate (% users che vedono sezione)
- Template tap rate (% users che tappano su card)
- Template usage rate (% che fanno "Use Template")

**Secondary:**
- Research link taps (% che leggono paper)
- Time to create superset (target: <10s con template vs 45s manual)
- User satisfaction (NPS improvement)

---

## 🎨 VISUAL MOCKUP (ASCII Art)

```
┌─────────────────────────────────────────────────────────┐
│  ← Exercise Search                               [🔍]   │
├─────────────────────────────────────────────────────────┤
│  🔍 Search exercises, templates, programs...            │
├─────────────────────────────────────────────────────────┤
│  💪 Petto  🦵 Gambe  🏋️ Spalle  🔙 Schiena  [More →]   │ ← Quick filters
├─────────────────────────────────────────────────────────┤
│  🎯 Recommended Templates                  [See All →]  │
│  ┌─────────────┬─────────────┬─────────────┬──────┐    │
│  │ 🔗 SS       │ 🔗 SS       │ 📉 DS       │      │    │
│  │             │             │             │  →   │    │
│  │ Bench+Row   │ Squat+Leg   │ Bicep Pump  │      │    │
│  │             │  Curl       │             │      │    │
│  │ 💪🔙         │ 🦵          │ 💪          │      │    │
│  │             │             │             │      │    │
│  │ ⏱ 15min     │ ⏱ 12min     │ ⏱ 8min      │      │    │
│  │ 🔰 Begin    │ ⚡ Inter     │ 🔥 Adv      │      │    │
│  │ 🔬          │             │             │      │    │
│  └─────────────┴─────────────┴─────────────┴──────┘    │
├─────────────────────────────────────────────────────────┤
│  ⏱ Recent Exercises                                     │
│  [Bench Press] [Squat] [Dumbbell Row] [...]            │
├─────────────────────────────────────────────────────────┤
│  1,247 exercises found                                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Bench Press                                   [+] │  │
│  │ 💪 Petto | 🏋️ Bilanciere | ⚡ Intermediate        │  │
│  ├───────────────────────────────────────────────────┤  │
│  │ Squat                                         [+] │  │
│  │ 🦵 Gambe | 🏋️ Bilanciere | 🔥 Advanced           │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Badge Legend:**
- 🔗 SS = Superset
- 📉 DS = Dropset (futuro)
- ⏸ RP = Rest-Pause (futuro)
- 🔰 = Beginner
- ⚡ = Intermediate
- 🔥 = Advanced
- 🔬 = Evidence-based

---

## 💡 FUTURE ENHANCEMENTS

### Smart Recommendations (AI)

```dart
// Analyze user's current workout and suggest relevant templates
Future<List<ExerciseTemplate>> getSmartTemplates({
  required Workout currentWorkout,
  required List<Exercise> recentExercises,
}) async {
  // 1. Analyze muscle groups already trained
  final trainedMuscles = _extractTrainedMuscles(currentWorkout);

  // 2. Suggest antagonist pairings
  // If user did Chest → suggest Back template
  // If user did Quads → suggest Hamstring template

  // 3. Consider time remaining
  // If workout is already 45min → suggest quick templates (<15min)

  // 4. Consider equipment used
  // If using dumbbells → suggest dumbbell templates

  return filteredTemplates;
}
```

### Custom Template Creation

```dart
// Allow users to save their own combinations as templates
void _saveAsCustomTemplate(SupersetExercise superset) {
  final template = SupersetTemplate(
    id: uuid.v4(),
    name: _generateTemplateName(superset), // "Bench + Row (My Custom)"
    exerciseNames: superset.exercises.map((e) => e.name).toList(),
    rounds: superset.supersetSets.length,
    repsRange: _inferRepsRange(superset),
    restAfterRound: superset.restAfterRound,
    restBetween: 0,
    difficulty: TemplateDifficulty.intermediate,
    estimatedTimeMinutes: _estimateTime(superset),
    scientificBasis: '', // User template, no research
    isCustom: true,
    targetPersona: null, // Generic
  );

  // Save to repository
  ref.read(supersetTemplateRepositoryProvider).saveCustomTemplate(template);
}
```

### Template Sharing

```dart
// Share template with friends via JSON export
Future<void> shareTemplate(SupersetTemplate template) async {
  final json = template.toJson();
  final jsonString = jsonEncode(json);

  // Share via platform share sheet
  await Share.share(
    jsonString,
    subject: 'FitLog Template: ${template.name}',
  );
}

// Import template from JSON
Future<void> importTemplate(String jsonString) async {
  final json = jsonDecode(jsonString);
  final template = SupersetTemplate.fromJson(json);

  // Save as custom template
  await ref.read(supersetTemplateRepositoryProvider).saveCustomTemplate(template);

  SnackBarService.showSuccess(
    context,
    'Template "${template.name}" imported!',
  );
}
```

---

## 🧪 A/B TEST PLAN

**Hypothesis**: Template visibility in Exercise Search aumenta superset adoption del +300%

**Test Design:**
- **Group A (Control)**: Current UI (no template section)
- **Group B (Test)**: Recommended Templates section visible

**Duration**: 4 weeks
**Sample size**: 2,000 users (1,000 per group)

**Primary Metrics:**
- Superset creation rate (% workouts con superset)
- Template usage rate (% supersets creati via template)

**Secondary Metrics:**
- Template visibility (% users che vedono sezione)
- Template engagement (% users che tappano su card)
- Research link taps (% che aprono paper)

**Success Criteria:**
- ✅ +200% superset adoption (5% → 15%)
- ✅ 40%+ template usage rate
- ✅ +2 points NPS improvement

---

## 📚 REFERENCES

- [ExerciseSearchScreen current implementation](../lib/features/exercise_database/presentation/exercise_search_screen.dart)
- [SupersetTemplate specification](SUPERSET_TEMPLATE_SYSTEM.md)
- [Superset UX mockups](SUPERSET_QUICK_ACTION_MOCKUP.md)
- [User Personas](../USER_PERSONAS.md)
