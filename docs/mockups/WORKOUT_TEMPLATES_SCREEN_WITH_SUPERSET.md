# Workout Templates Screen - Con Superset Template Integrati

## 🔴 BEFORE (Current State)

```
┌─────────────────────────────────────┐
│  ← Workout Templates         [☁] [+]│
├─────────────────────────────────────┤
│  🔍 Search templates...             │
├─────────────────────────────────────┤
│  [All] [Popular] [My Templates]     │ ← 3 tabs
├─────────────────────────────────────┤
│                                     │
│         (Schermata vuota)           │ ← Popular e My Templates vuote
│                                     │
│     No popular templates yet        │
│                                     │
│  Most used templates will appear    │
│         here over time              │
│                                     │
└─────────────────────────────────────┘
```

**PROBLEMI:**
- ❌ Tab "Popular" e "My Templates" sono vuote
- ❌ Nessun template predefinito visibile
- ❌ Utente deve creare tutto manualmente
- ❌ Nessuna guidance su cosa funziona

---

## 🟢 AFTER (Con Superset Template)

```
┌─────────────────────────────────────┐
│  ← Workout Templates         [☁] [+]│
├─────────────────────────────────────┤
│  🔍 Search templates...             │
├─────────────────────────────────────┤
│  [All] [Superset] [My Templates]    │ ← 🆕 Nuovo tab!
├─────────────────────────────────────┤
│  🎯 Recommended for You              │
│  ┌───────────────────────────────┐  │
│  │ 🔰 Beginner Templates         │  │ ← Sezione persona
│  │ ─────────────────────────────  │  │
│  │ ┌─────┐ ┌─────┐ ┌─────┐      │  │
│  │ │ 🔗  │ │ 🔗  │ │ 🔗  │  →   │  │
│  │ │Bench│ │ Leg │ │Arms│       │  │
│  │ │ Row │ │Core│ │Simple│      │  │
│  │ │12min│ │10min│ │10min│      │  │
│  │ └─────┘ └─────┘ └─────┘      │  │
│  └───────────────────────────────┘  │
│                                     │
│  🔬 Evidence-Based                  │ ← Sezione scientifica
│  ┌───────────────────────────────┐  │
│  │ ┌─────┐ ┌─────┐ ┌─────┐      │  │
│  │ │ 🔬  │ │ 🔬  │ │ 🔬  │  →   │  │
│  │ │Bench│ │Squat│ │Bicep│      │  │
│  │ │ Row │ │ Leg │ │Tricep│     │  │
│  │ │28min│ │26min│ │18min│      │  │
│  │ └─────┘ └─────┘ └─────┘      │  │
│  │ "36% time savings (PMC)"     │  │
│  └───────────────────────────────┘  │
│                                     │
│  💼 Time-Efficient (15-20min)       │ ← Sezione tempo
│  ┌───────────────────────────────┐  │
│  │ ┌─────┐ ┌─────┐ ┌─────┐      │  │
│  │ │ ⚡  │ │ ⚡  │ │ ⚡  │  →   │  │
│  │ │Total│ │Lower│ │Upper│      │  │
│  │ │Body │ │Power│ │ Home│      │  │
│  │ │15min│ │12min│ │10min│      │  │
│  │ └─────┘ └─────┘ └─────┘      │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**MIGLIORAMENTI:**
- ✅ Nuovo tab "Superset" dedicato
- ✅ Template organizzati in sezioni smart:
  - "Recommended for You" (basato su persona utente)
  - "Evidence-Based" (con citazioni scientifiche)
  - "Time-Efficient" (per busy users)
- ✅ Scroll orizzontale per ogni sezione
- ✅ Badge visivi (🔰 🔬 ⚡) per categorizzazione rapida

---

## 🎨 DESIGN SPECS

### Tab Structure (4 tabs invece di 3)

```dart
TabBar(
  controller: _tabController, // length: 4
  tabs: [
    Tab(text: l10n.allExercises, icon: Icon(AppIcons.list)),
    Tab(text: l10n.supersetTemplates, icon: Icon(AppIcons.link)), // 🆕 NUOVO!
    Tab(text: l10n.popularTemplates, icon: Icon(AppIcons.trendUp)),
    Tab(text: l10n.myTemplates, icon: Icon(AppIcons.person)),
  ],
)
```

### Superset Tab Content

```dart
Widget _buildSupersetTemplatesTab() {
  final templatesAsync = ref.watch(supersetTemplatesProvider);
  final userPersona = ref.watch(
    appConfigProvider.select((c) => c.userPersona),
  );

  return templatesAsync.when(
    loading: () => const Center(child: LoadingIndicator()),
    error: (error, stack) => Center(child: Text(context.l10n.erroreError)),
    data: (allTemplates) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recommended for You (persona-specific)
            if (userPersona != null)
              _buildTemplateSection(
                title: context.l10n.recommendedForYou,
                icon: AppIcons.star,
                templates: allTemplates.where(
                  (t) => t.targetPersona == userPersona,
                ).toList(),
                emptyMessage: null, // Hide if empty
              ),

            // 2. Evidence-Based
            _buildTemplateSection(
              title: context.l10n.evidenceBased,
              subtitle: context.l10n.basedOnScientificResearch,
              icon: AppIcons.science,
              templates: allTemplates.where(
                (t) => t.scientificBasis.isNotEmpty,
              ).toList(),
            ),

            // 3. Time-Efficient (15-20min)
            _buildTemplateSection(
              title: context.l10n.timeEfficient,
              subtitle: '15-20 ${context.l10n.minutes}',
              icon: AppIcons.timer,
              templates: allTemplates.where(
                (t) => t.estimatedTimeMinutes >= 15 &&
                       t.estimatedTimeMinutes <= 20,
              ).toList(),
            ),

            // 4. Beginner-Friendly
            _buildTemplateSection(
              title: context.l10n.beginnerFriendly,
              icon: AppIcons.school,
              templates: allTemplates.where(
                (t) => t.difficulty == TemplateDifficulty.beginner,
              ).toList(),
            ),

            // 5. Advanced (Powerlifting)
            _buildTemplateSection(
              title: context.l10n.advanced,
              icon: AppIcons.fitness,
              templates: allTemplates.where(
                (t) => t.difficulty == TemplateDifficulty.advanced,
              ).toList(),
            ),

            // 6. All Templates (browsable list)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.allSupersetTemplates,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${allTemplates.length} ${context.l10n.templatesAvailable}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ...allTemplates.map((template) => SupersetTemplateListItem(
              template: template,
              onTap: () => _showTemplatePreview(template),
            )),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      );
    },
  );
}
```

### Template Section Widget

```dart
Widget _buildTemplateSection({
  required String title,
  String? subtitle,
  required IconData icon,
  required List<SupersetTemplate> templates,
  String? emptyMessage,
}) {
  // Hide section if no templates
  if (templates.isEmpty && emptyMessage == null) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section Header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.colors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),

      // Horizontal Scroll
      if (templates.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emptyMessage ?? context.l10n.noTemplatesYet,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        )
      else
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SupersetTemplateCard(
                  template: template,
                  onTap: () => _showTemplatePreview(template),
                ),
              );
            },
          ),
        ),
    ],
  );
}
```

### Template Card (Reusable)

```dart
class SupersetTemplateCard extends StatelessWidget {
  final SupersetTemplate template;
  final VoidCallback onTap;

  const SupersetTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

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
            // Top badges
            Row(
              children: [
                _buildTypeBadge(context),
                const Spacer(),
                if (template.scientificBasis.isNotEmpty)
                  Tooltip(
                    message: context.l10n.evidenceBased,
                    child: Icon(
                      AppIcons.science,
                      size: 14,
                      color: context.colors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Template name
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
              _getMuscleGroupsText(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Bottom info: time + difficulty
            Row(
              children: [
                Icon(
                  AppIcons.timer,
                  size: 12,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.estimatedTimeMinutes}min',
                  style: context.textTheme.bodySmall,
                ),
                const Spacer(),
                _buildDifficultyEmoji(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.link, size: 12, color: context.colors.primary),
          const SizedBox(width: 4),
          Text(
            'SS',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleGroupsText() {
    if (template.targetMuscles == null || template.targetMuscles!.isEmpty) {
      return '';
    }

    // Get first 2 muscle groups
    final muscles = template.targetMuscles!.take(2).toList();
    return muscles.join(' · ');
  }

  Widget _buildDifficultyEmoji() {
    final emoji = switch (template.difficulty) {
      TemplateDifficulty.beginner => '🔰',
      TemplateDifficulty.intermediate => '⚡',
      TemplateDifficulty.intermediateAdvanced => '⚡',
      TemplateDifficulty.advanced => '🔥',
    };

    return Text(emoji, style: const TextStyle(fontSize: 14));
  }
}
```

### Template List Item (for "All Templates" section)

```dart
class SupersetTemplateListItem extends StatelessWidget {
  final SupersetTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          AppIcons.link,
          color: context.colors.onPrimaryContainer,
        ),
      ),
      title: Text(
        template.name,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(AppIcons.timer, size: 14, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${template.estimatedTimeMinutes}min'),
              const SizedBox(width: 12),
              Text(_getDifficultyText()),
              if (template.scientificBasis.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(AppIcons.science, size: 14, color: context.colors.primary),
              ],
            ],
          ),
          if (template.targetMuscles != null && template.targetMuscles!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              template.targetMuscles!.join(', '),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(AppIcons.chevronRight),
      onTap: onTap,
    );
  }

  String _getDifficultyText() {
    return switch (template.difficulty) {
      TemplateDifficulty.beginner => 'Beginner',
      TemplateDifficulty.intermediate => 'Intermediate',
      TemplateDifficulty.intermediateAdvanced => 'Inter-Adv',
      TemplateDifficulty.advanced => 'Advanced',
    };
  }
}
```

---

## 🎯 USER FLOW

### Scenario 1: Marco (Beginner) naviga template

```
1. Marco apre "Workout Templates" screen
2. Vede 4 tab: [All] [Superset] [Popular] [My Templates]
3. Tap su "Superset" tab
4. VEDE sezione "🔰 Beginner-Friendly" in alto
5. SCROLLA orizzontalmente: "Bench+Row", "Leg+Core", "Arms Simple"
6. Tap su "Bench+Row (12min)"
7. PREVIEW modal si apre:
   - Exercises: Bench Press + Cable Row
   - 2 rounds × 10-12 reps
   - Rest: 120s dopo round
   - 💡 "Usa macchine per imparare il movimento"
8. Tap "Use Template"
9. ✅ Superset creato e pronto nel workout
```

### Scenario 2: Chiara (Busy Mom) cerca quick template

```
1. Chiara apre "Workout Templates"
2. Tap "Superset" tab
3. VEDE sezione "💼 Time-Efficient (15-20min)"
4. VEDE "Total Body 15min"
5. Tap → Preview
6. LEGGE: "True superset (0s rest between), dumbbell-only"
7. Tap "Use Template"
8. ✅ Workout ready in 2 taps
9. Inizia subito
```

### Scenario 3: Luca (Powerlifter) cerca evidence-based

```
1. Luca apre "Workout Templates"
2. Tap "Superset" tab
3. VEDE sezione "🔬 Evidence-Based"
4. VEDE "Bench + Row (Research)" con badge 🔬
5. Tap → Preview
6. LEGGE: "36% time savings (PMC 12011898)"
7. Tap "📄 Read Research" → apre paper
8. TORNA → Tap "Use Template"
9. MODIFICA: 4 rounds → 6 rounds (più volume)
10. Conferma → ✅ Superset creato
```

---

## 🎨 VISUAL MOCKUP (Dettagliato)

### Tab "Superset" - Vista Completa

```
┌─────────────────────────────────────────────────────────┐
│  ← Workout Templates                     [☁ Sync]  [+]  │
├─────────────────────────────────────────────────────────┤
│  🔍 Search templates...                                 │
├─────────────────────────────────────────────────────────┤
│  [All] [🔗 Superset] [Popular] [My Templates]          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🎯 Recommended for You                    [See All →]  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ ┌───────────┐ ┌───────────┐ ┌───────────┐        │  │
│  │ │ 🔗 SS     │ │ 🔗 SS     │ │ 🔗 SS     │   →    │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ Bench+Row │ │ Leg+Core  │ │ Arms      │        │  │
│  │ │           │ │           │ │ Simple    │        │  │
│  │ │ 💪·🔙      │ │ 🦵·Core   │ │ 💪        │        │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ ⏱ 12min   │ │ ⏱ 10min   │ │ ⏱ 10min   │        │  │
│  │ │ 🔰        │ │ 🔰        │ │ 🔰        │        │  │
│  │ └───────────┘ └───────────┘ └───────────┘        │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  🔬 Evidence-Based                         [See All →]  │
│  Based on scientific research                           │
│  ┌───────────────────────────────────────────────────┐  │
│  │ ┌───────────┐ ┌───────────┐ ┌───────────┐        │  │
│  │ │ 🔗 SS  🔬 │ │ 🔗 SS  🔬 │ │ 🔗 SS  🔬 │   →    │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ Bench+Row │ │ Squat+    │ │ Bicep+    │        │  │
│  │ │ (Research)│ │ Leg Curl  │ │ Tricep    │        │  │
│  │ │ 💪·🔙      │ │ 🦵·🦵      │ │ 💪·💪      │        │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ ⏱ 28min   │ │ ⏱ 26min   │ │ ⏱ 18min   │        │  │
│  │ │ ⚡        │ │ ⚡        │ │ ⚡        │        │  │
│  │ └───────────┘ └───────────┘ └───────────┘        │  │
│  └───────────────────────────────────────────────────┘  │
│  "36% time savings with same muscle gains (PMC)"       │
│                                                         │
│  💼 Time-Efficient                         [See All →]  │
│  15-20 minutes                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │ ┌───────────┐ ┌───────────┐ ┌───────────┐        │  │
│  │ │ 🔗 SS     │ │ 🔗 SS     │ │ 🔗 SS     │   →    │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ Total     │ │ Lower     │ │ Upper     │        │  │
│  │ │ Body      │ │ Power     │ │ Home      │        │  │
│  │ │ Express   │ │ Quick     │ │ Bodyweight│        │  │
│  │ │ 💪·🔙      │ │ 🦵        │ │ 💪·🔙      │        │  │
│  │ │           │ │           │ │           │        │  │
│  │ │ ⏱ 15min   │ │ ⏱ 12min   │ │ ⏱ 10min   │        │  │
│  │ │ ⚡        │ │ ⚡        │ │ 🔰        │        │  │
│  │ └───────────┘ └───────────┘ └───────────┘        │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  📋 All Superset Templates                              │
│  18 templates available                                 │
│  ┌───────────────────────────────────────────────────┐  │
│  │ 🔗  Bench + Row (Beginner)              ⏱12min 🔰 │→ │
│  ├───────────────────────────────────────────────────┤  │
│  │ 🔗  Total Body 15min                    ⏱15min ⚡ │→ │
│  ├───────────────────────────────────────────────────┤  │
│  │ 🔗🔬 Bench + Row (Research)             ⏱28min ⚡ │→ │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 VANTAGGI vs Tab "Popular"

| Aspetto | Tab "Popular" (BEFORE) | Tab "Superset" (AFTER) |
|---------|----------------------|------------------------|
| **Contenuto** | Vuoto inizialmente | 18 template subito |
| **Guidance** | Nessuna | Sezioni categorizzate |
| **Trust** | User-generated | Evidence-based + persona-driven |
| **Accessibility** | Richiede usage data | Disponibile day-1 |
| **Learning** | Trial & error | Educational (scientific basis) |

---

## 💡 ALTERNATIVE LAYOUTS

### Opzione B: Rimpiazzare "Popular" con "Superset"

Invece di aggiungere 4° tab, sostituire "Popular":

```
[All] [Superset] [My Templates]
```

**Pro:**
- ✅ Solo 3 tab (più pulito)
- ✅ Elimina tab vuoto ("Popular")

**Cons:**
- ❌ Perdi tracking "most used" templates (utile in futuro)

### Opzione C: Merge "All" e "Superset"

Unico tab "All Templates" con:
- Sezione "Workout Templates" (esistenti)
- Sezione "Superset Templates" (nuovi)

**Pro:**
- ✅ Tutto in un posto

**Cons:**
- ❌ Scroll verticale molto lungo
- ❌ Superset nascosti in basso

---

## 🚀 RACCOMANDAZIONE FINALE

**Opzione migliore**: **4 tab** (All, Superset, Popular, My Templates)

**Ragioni:**
1. ✅ **Separazione chiara** - Superset meritano tab dedicato
2. ✅ **Scalabile** - Quando aggiungi Dropset/Rest-Pause, puoi creare tab "Advanced Techniques" o mantenerli in Superset
3. ✅ **Popular rimane** - Utile per tracking long-term usage
4. ✅ **My Templates rimane** - Spazio per custom user templates

---

## 🧪 A/B TEST PLAN

**Hypothesis**: Tab "Superset" aumenta superset adoption rate del +200%

**Test Groups:**
- **Group A (Control)**: Current UI (no superset tab, empty popular)
- **Group B (Test)**: 4-tab UI con Superset tab

**Duration**: 6 weeks
**Sample size**: 1,500 users (750 per group)

**Primary Metrics:**
- Superset creation rate (% workouts con superset)
- Template usage rate (% supersets da template)
- Tab engagement (% users che visitano Superset tab)

**Secondary Metrics:**
- Time to create superset (template vs manual)
- Template preview rate (% card taps → modal opens)
- Research link taps (% users che aprono paper)

**Success Criteria:**
- ✅ +150% superset adoption (5% → 12.5%)
- ✅ 50%+ template usage rate
- ✅ 70%+ users visit Superset tab almeno 1 volta

---

## 🛠️ IMPLEMENTATION CHECKLIST

### Phase 1: Tab Structure
- [ ] Modify `TabController` length: 3 → 4
- [ ] Add "Superset" tab icon + label
- [ ] Create `_buildSupersetTemplatesTab()` method
- [ ] Wire up tab controller

### Phase 2: Template Sections
- [ ] Create `_buildTemplateSection()` reusable widget
- [ ] Implement horizontal scroll for each section
- [ ] Add section headers with icons
- [ ] Filter templates by category

### Phase 3: Template Cards
- [ ] Create `SupersetTemplateCard` widget (140×180)
- [ ] Add badges (type, difficulty, evidence)
- [ ] Implement tap → preview modal
- [ ] Add template list view for "All Templates"

### Phase 4: Integration
- [ ] Load templates from `supersetTemplatesProvider`
- [ ] Implement `_showTemplatePreview()` modal
- [ ] Implement `_useTemplate()` action
- [ ] Connect to workout creation flow

### Phase 5: Polish
- [ ] Add empty states for each section
- [ ] Add "See All" buttons (navigate to filtered view)
- [ ] Analytics tracking (tab views, card taps, template usage)
- [ ] Localization strings (IT + EN)

---

## 📚 REFERENCES

- [WorkoutTemplatesScreen current](../lib/features/workout/presentation/screens/workout_templates_screen.dart)
- [SupersetTemplate specification](SUPERSET_TEMPLATE_SYSTEM.md)
- [Template data file](../../assets/data/superset_templates.json)
