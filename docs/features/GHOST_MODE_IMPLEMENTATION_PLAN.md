# Ghost Mode - Piano di Implementazione

> **Obiettivo**: Creare un'esperienza fitness app priva di elementi competitivi/sociali per utenti con alta neuroticism (25% mercato potenziale).

---

## 1. Executive Summary

### Il Problema
La ricerca psicologica ([PMC Meta-analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC2577457/)) dimostra che persone con alta **neuroticism** sono le meno propense ad allenarsi, ma sarebbero quelle che beneficerebbero di più dall'esercizio fisico. Le fitness app attuali, con XP, tier, leaderboard e confronti sociali, possono **aumentare l'ansia** invece di ridurla.

### La Soluzione
**Ghost Mode** nasconde tutti gli elementi competitivi e di confronto sociale, trasformando FitLog Pro in un "diario fitness privato" - solo tracking personale, zero pressione esterna.

### Impatto Stimato
- **Target**: 25% degli utenti potenziali (attualmente non serviti)
- **Retention**: +40% retention per utenti con alta neuroticism
- **Effort**: ~2-3 settimane di sviluppo (Medium effort)

---

## 2. Differenza tra Zen Mode (esistente) e Ghost Mode (nuovo)

| Aspetto | Zen Mode (esistente) | Ghost Mode (nuovo) |
|---------|---------------------|-------------------|
| **Scope** | Solo workout screen | Tutta l'app |
| **Focus** | Distraction-free workout | Zero confronto sociale |
| **Durata** | Durante workout | Sempre attivo |
| **File** | `zen_mode_provider.dart` | Nuovo `ghost_mode_provider.dart` |

**Strategia**: NON estendere ZenMode (scopi diversi). Creare GhostMode separato ma riutilizzare pattern simile.

---

## 3. Cosa Nasconde Ghost Mode

### TIER 1 - Elementi Competitivi (Nascosti sempre)

| Elemento | Posizione | File | Impatto Ansia |
|----------|-----------|------|---------------|
| **XP Progress Bar** | Home screen | `xp_progress_bar.dart` | Alto |
| **Tier Badge** | Profile, Home | `compact_profile_header.dart` | Alto |
| **Level Info Modal** | Profile tap | `level_info_modal.dart` | Alto |
| **Streak Counter** | Profile hub | `profile_hub_screen.dart` | Medio |
| **XP Animations** | Post-workout | workout completion | Medio |

### TIER 2 - Elementi Sociali (Nascosti sempre)

| Elemento | Posizione | File | Impatto Ansia |
|----------|-----------|------|---------------|
| **Community Hub** | Navigation | `community_hub_screen.dart` | Alto |
| **Exercise Wiki Card** | Home | `exercise_wiki_card_compact.dart` | Medio |
| **Community Suggestions** | Workout | via ZenConfig | Medio |
| **Voting/Kudos** | Community | `voting_card.dart` | Medio |

### TIER 3 - Elementi Analytics Comparativi (Nascosti/Semplificati)

| Elemento | Azione | File |
|----------|--------|------|
| **Strength Standards** | Nasconde confronto con altri | analytics |
| **Activity Rings** | Mostra solo trend personale | `activity_rings_widget.dart` |
| **Stress Prediction** | Semplifica (no numeri assoluti) | `stress_prediction_card.dart` |

### TIER 4 - Cosa RIMANE Visibile

| Elemento | Razionale |
|----------|-----------|
| **Workout tracking** | Core feature |
| **Personal history** | Utile, non competitivo |
| **Templates** | Struttura senza confronto |
| **Rest timer** | Funzionale |
| **Body measurements** | Tracking personale |
| **Progress photos** | Privato |

---

## 4. Architettura Tecnica

### 4.1 Nuovo Provider: `ghost_mode_provider.dart`

```dart
// lib/shared/presentation/providers/ghost_mode_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Configuration for Ghost Mode
/// Nasconde elementi competitivi e sociali per utenti con alta neuroticism
class GhostModeConfig {
  const GhostModeConfig({
    this.hideXPProgress = true,
    this.hideTierBadge = true,
    this.hideStreak = false,  // Opzionale - alcuni lo trovano motivante
    this.hideCommunity = true,
    this.hideLeaderboards = true,
    this.hideStrengthComparisons = true,
    this.simplifyAnalytics = true,
    this.hideXPAnimations = true,
  });

  final bool hideXPProgress;
  final bool hideTierBadge;
  final bool hideStreak;
  final bool hideCommunity;
  final bool hideLeaderboards;
  final bool hideStrengthComparisons;
  final bool simplifyAnalytics;
  final bool hideXPAnimations;

  GhostModeConfig copyWith({
    bool? hideXPProgress,
    bool? hideTierBadge,
    bool? hideStreak,
    bool? hideCommunity,
    bool? hideLeaderboards,
    bool? hideStrengthComparisons,
    bool? simplifyAnalytics,
    bool? hideXPAnimations,
  }) {
    return GhostModeConfig(
      hideXPProgress: hideXPProgress ?? this.hideXPProgress,
      hideTierBadge: hideTierBadge ?? this.hideTierBadge,
      hideStreak: hideStreak ?? this.hideStreak,
      hideCommunity: hideCommunity ?? this.hideCommunity,
      hideLeaderboards: hideLeaderboards ?? this.hideLeaderboards,
      hideStrengthComparisons: hideStrengthComparisons ?? this.hideStrengthComparisons,
      simplifyAnalytics: simplifyAnalytics ?? this.simplifyAnalytics,
      hideXPAnimations: hideXPAnimations ?? this.hideXPAnimations,
    );
  }

  Map<String, dynamic> toJson() => {
    'hideXPProgress': hideXPProgress,
    'hideTierBadge': hideTierBadge,
    'hideStreak': hideStreak,
    'hideCommunity': hideCommunity,
    'hideLeaderboards': hideLeaderboards,
    'hideStrengthComparisons': hideStrengthComparisons,
    'simplifyAnalytics': simplifyAnalytics,
    'hideXPAnimations': hideXPAnimations,
  };

  factory GhostModeConfig.fromJson(Map<String, dynamic> json) => GhostModeConfig(
    hideXPProgress: json['hideXPProgress'] ?? true,
    hideTierBadge: json['hideTierBadge'] ?? true,
    hideStreak: json['hideStreak'] ?? false,
    hideCommunity: json['hideCommunity'] ?? true,
    hideLeaderboards: json['hideLeaderboards'] ?? true,
    hideStrengthComparisons: json['hideStrengthComparisons'] ?? true,
    simplifyAnalytics: json['simplifyAnalytics'] ?? true,
    hideXPAnimations: json['hideXPAnimations'] ?? true,
  );
}

/// State for Ghost Mode
class GhostModeState {
  const GhostModeState({
    this.isEnabled = false,
    this.config = const GhostModeConfig(),
  });

  final bool isEnabled;
  final GhostModeConfig config;

  GhostModeState copyWith({
    bool? isEnabled,
    GhostModeConfig? config,
  }) {
    return GhostModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      config: config ?? this.config,
    );
  }
}

/// Notifier for Ghost Mode
class GhostModeNotifier extends Notifier<GhostModeState> {
  // User-scoped cache keys
  String get _ghostModeKey => userCacheKeys.userScopedKey('ghost_mode_enabled');
  String get _ghostConfigKey => userCacheKeys.userScopedKey('ghost_mode_config');

  @override
  GhostModeState build() {
    _loadPreferences();
    return const GhostModeState();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_ghostModeKey) ?? false;
    // Load config from JSON string
    final configJson = prefs.getString(_ghostConfigKey);
    final config = configJson != null
        ? GhostModeConfig.fromJson(_parseConfig(configJson))
        : const GhostModeConfig();

    state = GhostModeState(isEnabled: isEnabled, config: config);
  }

  Map<String, dynamic> _parseConfig(String configString) {
    return configString.split(',').fold({}, (map, item) {
      final parts = item.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1] == 'true';
      }
      return map;
    });
  }

  Future<void> toggleGhostMode() async {
    final newState = !state.isEnabled;
    state = state.copyWith(isEnabled: newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostModeKey, newState);
  }

  Future<void> setEnabled(bool enabled) async {
    if (state.isEnabled == enabled) return;

    state = state.copyWith(isEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostModeKey, enabled);
  }

  Future<void> updateConfig(GhostModeConfig newConfig) async {
    state = state.copyWith(config: newConfig);

    final prefs = await SharedPreferences.getInstance();
    final configString = newConfig.toJson().entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await prefs.setString(_ghostConfigKey, configString);
  }
}

/// Provider for Ghost Mode
final ghostModeProvider = NotifierProvider<GhostModeNotifier, GhostModeState>(
  GhostModeNotifier.new,
);

/// Convenience providers for quick access
final isGhostModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(ghostModeProvider).isEnabled;
});

final ghostModeConfigProvider = Provider<GhostModeConfig>((ref) {
  return ref.watch(ghostModeProvider).config;
});

/// Helper to check if specific element should be hidden
final shouldHideXPProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideXPProgress;
});

final shouldHideCommunityProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideCommunity;
});

final shouldHideTierProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideTierBadge;
});

final shouldHideStreakProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideStreak;
});
```

### 4.2 Integrazione UI - Pattern di Implementazione

```dart
// Pattern da usare in ogni widget che deve rispettare Ghost Mode

class XPProgressBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CHECK: Ghost Mode nasconde questo widget?
    final shouldHide = ref.watch(shouldHideXPProvider);
    if (shouldHide) return const SizedBox.shrink();

    // ... resto del widget normale
  }
}
```

### 4.3 Settings UI - Nuova Sezione

```dart
// In settings_screen.dart - Nuova sezione "Privacy & Focus"

Widget _buildPrivacyFocusSection(BuildContext context, WidgetRef ref) {
  final ghostModeState = ref.watch(ghostModeProvider);

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.visibility_off,  // Ghost icon
                semanticLabel: context.l10n.privacyFocus,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.privacyFocus,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ghost Mode Toggle
          SwitchListTile(
            title: Text(context.l10n.ghostModeTitle),
            subtitle: Text(context.l10n.ghostModeDescription),
            value: ghostModeState.isEnabled,
            onChanged: (value) {
              ref.read(ghostModeProvider.notifier).setEnabled(value);
              SnackBarService.showSuccess(
                context,
                value
                    ? context.l10n.ghostModeEnabled
                    : context.l10n.ghostModeDisabled,
              );
            },
            secondary: SemanticIcon(
              icon: AppIcons.ghost,
              semanticLabel: context.l10n.ghostModeTitle,
              color: ghostModeState.isEnabled
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          // Configurazione dettagliata (espandibile)
          if (ghostModeState.isEnabled) ...[
            const Divider(),
            ExpansionTile(
              title: Text(context.l10n.ghostModeCustomize),
              children: [
                _buildGhostModeOption(
                  context, ref,
                  title: context.l10n.hideXPProgress,
                  value: ghostModeState.config.hideXPProgress,
                  onChanged: (v) => _updateGhostConfig(ref, hideXPProgress: v),
                ),
                _buildGhostModeOption(
                  context, ref,
                  title: context.l10n.hideTierBadge,
                  value: ghostModeState.config.hideTierBadge,
                  onChanged: (v) => _updateGhostConfig(ref, hideTierBadge: v),
                ),
                _buildGhostModeOption(
                  context, ref,
                  title: context.l10n.hideStreak,
                  value: ghostModeState.config.hideStreak,
                  onChanged: (v) => _updateGhostConfig(ref, hideStreak: v),
                ),
                _buildGhostModeOption(
                  context, ref,
                  title: context.l10n.hideCommunity,
                  value: ghostModeState.config.hideCommunity,
                  onChanged: (v) => _updateGhostConfig(ref, hideCommunity: v),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

## 5. File da Modificare

### Fase 1 - Core (Provider + Settings)

| File | Azione | Effort |
|------|--------|--------|
| `lib/shared/presentation/providers/ghost_mode_provider.dart` | **NUOVO** | 2h |
| `lib/features/settings/presentation/settings_screen.dart` | Aggiungere sezione | 1h |
| `lib/shared/presentation/l10n/app_en.arb` | Aggiungere stringhe | 30min |
| `lib/shared/presentation/l10n/app_it.arb` | Aggiungere stringhe | 30min |

### Fase 2 - Home Screen

| File | Azione | Effort |
|------|--------|--------|
| `lib/features/home/presentation/widgets/xp_progress_bar.dart` | Check `shouldHideXPProvider` | 30min |
| `lib/features/home/presentation/widgets/exercise_wiki_card_compact.dart` | Check `shouldHideCommunityProvider` | 30min |
| `lib/features/home/presentation/minimal_home_screen.dart` | Condizionale su community elements | 1h |

### Fase 3 - Profile

| File | Azione | Effort |
|------|--------|--------|
| `lib/features/profile/presentation/widgets/compact_profile_header.dart` | Nascondere tier badge | 30min |
| `lib/features/profile/presentation/widgets/level_info_modal.dart` | Non aprire se ghost mode | 30min |
| `lib/features/profile/presentation/screens/streak_calendar_screen.dart` | Condizionale | 30min |

### Fase 4 - Navigation

| File | Azione | Effort |
|------|--------|--------|
| `lib/core/navigation/app_router.dart` | Nascondere route community | 1h |
| `lib/shared/presentation/widgets/bottom_navigation_bar.dart` | Condizionale community tab | 30min |

### Fase 5 - Analytics

| File | Azione | Effort |
|------|--------|--------|
| `lib/features/analytics/presentation/screens/*` | Semplificare comparisons | 2h |
| `lib/features/strength_standards/**` | Opzione nascondere | 1h |

---

## 6. Piano di Implementazione

### FASE 1: Foundation (Giorno 1-2)
```
□ Creare ghost_mode_provider.dart
□ Aggiungere stringhe localizzazione (EN + IT)
□ Aggiungere sezione in Settings
□ Test toggle funziona
```

### FASE 2: Home Screen (Giorno 3-4)
```
□ Nascondere XP Progress Bar
□ Nascondere Exercise Wiki Card
□ Nascondere Community-related suggestions
□ Test visual regression
```

### FASE 3: Profile (Giorno 5-6)
```
□ Nascondere Tier Badge
□ Disabilitare Level Info Modal tap
□ Opzione nascondere Streak (configurabile)
□ Test profile flows
```

### FASE 4: Navigation (Giorno 7)
```
□ Nascondere Community tab se ghost mode
□ Redirect se utente prova ad accedere via deep link
□ Test navigation integrity
```

### FASE 5: Analytics (Giorno 8-10)
```
□ Semplificare Strength Standards (no comparisons)
□ Analytics focus su "trend personale" non "vs others"
□ Test analytics views
```

### FASE 6: Polish & QA (Giorno 11-14)
```
□ Edge cases (cosa succede se ghost mode attivato durante workout?)
□ Onboarding mention (suggerire ghost mode a chi seleziona "beginner"?)
□ A/B test setup
□ Documentation
```

---

## 7. UX Copy Suggerita

### Localizzazione EN

```json
{
  "privacyFocus": "Privacy & Focus",
  "ghostModeTitle": "Ghost Mode",
  "ghostModeDescription": "Hide competitive elements. Just you and your workout.",
  "ghostModeEnabled": "Ghost Mode enabled. Enjoy your private fitness journey!",
  "ghostModeDisabled": "Ghost Mode disabled. Welcome back to the community!",
  "ghostModeCustomize": "Customize what's hidden",
  "hideXPProgress": "Hide XP & Level progress",
  "hideTierBadge": "Hide tier badges",
  "hideStreak": "Hide streak counter",
  "hideCommunity": "Hide community features",
  "ghostModeTooltip": "Perfect for when you want to focus on your workout without distractions or comparisons"
}
```

### Localizzazione IT

```json
{
  "privacyFocus": "Privacy & Concentrazione",
  "ghostModeTitle": "Modalita Fantasma",
  "ghostModeDescription": "Nascondi elementi competitivi. Solo tu e il tuo allenamento.",
  "ghostModeEnabled": "Modalita Fantasma attivata. Goditi il tuo percorso fitness privato!",
  "ghostModeDisabled": "Modalita Fantasma disattivata. Bentornato nella community!",
  "ghostModeCustomize": "Personalizza cosa nascondere",
  "hideXPProgress": "Nascondi XP e progressi livello",
  "hideTierBadge": "Nascondi badge tier",
  "hideStreak": "Nascondi contatore streak",
  "hideCommunity": "Nascondi funzioni community",
  "ghostModeTooltip": "Perfetto quando vuoi concentrarti sul tuo allenamento senza distrazioni o confronti"
}
```

---

## 8. Metriche di Successo

### KPIs Primari

| Metrica | Baseline | Target | Come misurare |
|---------|----------|--------|---------------|
| **Adoption rate** | 0% | 10-15% | `ghost_mode_enabled` events |
| **Retention D7 (ghost users)** | ~40% | 55% | Cohort analysis |
| **Session duration** | 5min | 7min | Firebase Analytics |
| **Workout completion rate** | 70% | 80% | Completed workouts / started |

### KPIs Secondari

| Metrica | Target |
|---------|--------|
| Settings page views +10% | Utenti esplorano nuove opzioni |
| Churn reduction -15% | Meno abbandoni early stage |
| NPS improvement | Feedback positivo su "non mi sento giudicato" |

### Eventi Analytics da Tracciare

```dart
// Eventi da aggiungere
AnalyticsService.logEvent('ghost_mode_enabled', {
  'config': ghostModeState.config.toJson(),
});

AnalyticsService.logEvent('ghost_mode_disabled', {
  'days_active': daysSinceEnabled,
});

AnalyticsService.logEvent('ghost_mode_config_changed', {
  'field': changedField,
  'new_value': newValue,
});
```

---

## 9. Rischi e Mitigazioni

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| Utenti non trovano l'opzione | Media | Alto | Suggerire in onboarding a beginners |
| Confusione con Zen Mode | Bassa | Medio | Copy chiara che differenzia |
| Feature creep | Media | Medio | Scope fisso, no customization eccessiva |
| Performance overhead | Bassa | Basso | Provider efficienti, no rebuild eccessivi |

---

## 10. Future Enhancements (Post-MVP)

- **Smart suggestion**: Auto-attivare ghost mode se utente mostra pattern di ansia (es. apre app ma non fa workout, skip community)
- **Scheduled ghost mode**: "Attiva ghost mode solo la sera" per chi vuole community di giorno
- **Ghost mode onboarding**: Flow dedicato per utenti che selezionano "I'm nervous about starting"
- **Integration con ZenMode**: Quando attivo Zen Mode durante workout, usa anche config Ghost Mode

---

## 11. Checklist Pre-Implementazione

```
□ Review con product team
□ Approvazione UX copy
□ Design mockup (se necessario)
□ Setup feature flag (per rollout graduale)
□ Aggiornare CLAUDE.md con nuova feature
□ Creare branch feature/ghost-mode
```

---

## Appendice A: Codice di Esempio Completo

### Widget con Ghost Mode Check

```dart
// lib/features/home/presentation/widgets/xp_progress_bar.dart

class XPProgressBar extends ConsumerWidget {
  const XPProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👻 Ghost Mode: nasconde XP progress
    final shouldHide = ref.watch(shouldHideXPProvider);
    if (shouldHide) {
      return const SizedBox.shrink();
    }

    // ... resto del widget esistente
    final xpState = ref.watch(userXPProvider);

    return Container(
      // ... existing implementation
    );
  }
}
```

### Navigation Guard

```dart
// In app_router.dart

GoRoute(
  path: '/community',
  name: 'community',
  builder: (context, state) {
    // 👻 Ghost Mode: redirect se community nascosta
    final container = ProviderScope.containerOf(context);
    final shouldHide = container.read(shouldHideCommunityProvider);

    if (shouldHide) {
      // Redirect silenzioso a home
      return const MinimalHomeScreen();
    }

    return const CommunityHubScreen();
  },
),
```

---

**Autore**: Claude AI
**Data**: 2025-01-14
**Versione**: 1.0
**Status**: Draft - In attesa di review
