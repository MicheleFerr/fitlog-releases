# 🏋️ Plate Calculator 2.0 - Design Document

**Versione**: 1.0
**Data**: 2026-02-09
**Status**: 📋 Ready for Implementation
**Priorità**: P1 - High Value Feature

---

## 📋 Executive Summary

Redesign completo del Plate Calculator per migliorare l'UX basandosi sulle User Personas. Le modifiche principali includono:

1. **Quick Barbell Selection** - Selezione bilanciere inline senza bottom sheet
2. **Gym Equipment Profiles** - Profili palestra configurabili
3. **Temporary Plate Exclusion** - Esclusione temporanea dischi non disponibili
4. **Smart Recalculation** - Suggerimenti alternativi intelligenti

---

## 🎯 Persona Impact Analysis

### Problemi Attuali

| Persona | Problema | Severità |
|---------|----------|----------|
| **Marco (Principiante)** | 18 tipi bilanciere = overwhelming, terminologia tecnica | `--` BLOCKER |
| **Chiara (Busy)** | Troppi tap per selezionare bilanciere (3-4 step) | `-` |
| **Luca (Powerlifter)** | Info sufficienti ma non ottimizzate | `0` |
| **Sofia (Estetica)** | Visual OK, potrebbe essere più premium | `+` |
| **Roberto (Busy)** | Troppi step, config dischi inutile per lui | `-` |

### Impatto Post-Redesign

| Persona | Impatto | Miglioramento |
|---------|---------|---------------|
| **Marco** | `++` | Solo 4-5 opzioni visibili, resto nascosto |
| **Chiara** | `++` | 1 tap per cambio bilanciere, quick switch profili |
| **Luca** | `++` | Profili multipli, esclusione temporanea dischi |
| **Sofia** | `+` | UI più pulita e moderna |
| **Roberto** | `++` | Setup una volta, poi zero friction |

---

## 🏗️ Architettura

### Nuove Entità

```dart
/// Profilo attrezzatura palestra
@HiveType(typeId: 110)
class GymEquipmentProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double? defaultBarbellWeight; // null = no barbell

  @HiveField(3)
  final List<double> availablePlates;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  const GymEquipmentProfile({
    required this.id,
    required this.name,
    this.defaultBarbellWeight = 20.0,
    this.availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

### Provider Structure

```
lib/features/workout/
├── domain/
│   └── entities/
│       └── gym_equipment_profile.dart       # Entity
├── data/
│   └── repositories/
│       └── gym_equipment_repository.dart    # Hive persistence
└── presentation/
    ├── providers/
    │   ├── gym_equipment_profiles_provider.dart
    │   └── plate_calculator_state_provider.dart
    └── widgets/
        ├── plate_calculator_widget.dart     # REFACTOR
        ├── barbell_quick_selector.dart      # NEW
        ├── gym_profile_selector.dart        # NEW
        └── plate_exclusion_chips.dart       # NEW
```

---

## 🖼️ UI Specifications

### 1. Quick Barbell Selection (Inline)

**Obiettivo**: Selezione bilanciere in 1 tap per casi comuni

```
┌─────────────────────────────────────────────────────────────┐
│ Bilanciere:                                                 │
│ [🏋️ 20kg] [⚖️ 15kg] [➖ No] [〰️ EZ 7.5] [⚙️ Altro]        │
│     ↑                                                       │
│  selected                                                   │
└─────────────────────────────────────────────────────────────┘
```

**Specifiche**:
- Chips orizzontali scrollabili
- Max 5 chips visibili (4 comuni + "Altro")
- "Altro" apre bottom sheet completo (esistente)
- Chip selezionato: `primaryContainer` background
- Haptic feedback on tap

**Chips Default**:
| Label | Peso | Icona |
|-------|------|-------|
| 20kg | 20.0 | `AppIcons.workout` |
| 15kg | 15.0 | `AppIcons.workout` |
| No | null | `AppIcons.block` |
| EZ 7.5 | 7.5 | `AppIcons.waves` |
| Altro | - | `AppIcons.settings` |

---

### 2. Gym Profile Selector

**Obiettivo**: Switch veloce tra profili palestra

```
┌─────────────────────────────────────────────────────────────┐
│ 📍 Profilo: [Home Gym ▼]                                    │
│             ┌─────────────────────────────┐                 │
│             │ 🏠 Home Gym            ✓    │                 │
│             │ 🏢 Office Gym               │                 │
│             │ ─────────────────────────── │                 │
│             │ ➕ Nuovo profilo...         │                 │
│             │ ⚙️ Gestisci profili         │                 │
│             └─────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

**Specifiche**:
- Dropdown nativo Flutter (`DropdownButton2` o custom)
- Mostra icona + nome profilo
- Separatore prima delle azioni
- "Nuovo profilo" → Dialog quick create
- "Gestisci profili" → Naviga a Settings

---

### 3. Quick Create Profile Dialog

**Obiettivo**: Creare profilo direttamente dal workout

```
┌─────────────────────────────────────────────────────────────┐
│ 💾 Salva Profilo Attrezzatura                         [×]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Nome                                                        │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Virgin Active Centro                                    ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ Configurazione attuale:                                     │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 🏋️ Bilanciere: Olympic 20kg                            ││
│ │ 💿 Dischi: 25, 20, 15, 10, 5, 2.5, 1.25 kg             ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ☐ Imposta come profilo default                             │
│                                                             │
│                     [Annulla]  [💾 Salva]                   │
└─────────────────────────────────────────────────────────────┘
```

**Specifiche**:
- Modal dialog (non bottom sheet)
- Pre-compila con config attuale del plate calculator
- Validazione: nome required, min 2 caratteri
- Checkbox "default" opzionale

---

### 4. Temporary Plate Exclusion

**Obiettivo**: Escludere temporaneamente dischi non disponibili (in uso da altri)

```
┌─────────────────────────────────────────────────────────────┐
│ Dischi disponibili:                                         │
│ [✓25] [✓20] [🚫15] [✓10] [✓5] [✓2.5] [✓1.25]              │
│              ↑                                              │
│         excluded (grayed, strikethrough)                    │
│                                                             │
│ ⚠️ 15kg escluso temporaneamente                            │
│ [↩️ Ripristina tutti]                                       │
└─────────────────────────────────────────────────────────────┘
```

**Specifiche**:
- Tap su chip = toggle esclusione
- Esclusione = stato locale (non salvato nel profilo)
- Reset automatico a fine workout
- Bottone "Ripristina tutti" se almeno 1 escluso
- Ricalcolo automatico quando si esclude

**Stati Chip**:
| Stato | Background | Text | Icon |
|-------|------------|------|------|
| Disponibile | `plateColor.withOpacity(0.3)` | Normal | ✓ |
| Escluso | `surfaceVariant` | Strikethrough, gray | 🚫 |

---

### 5. Smart Recalculation

**Obiettivo**: Suggerire alternative quando non si può raggiungere il peso esatto

```
┌─────────────────────────────────────────────────────────────┐
│ ⚠️ Non posso raggiungere esattamente 100kg                 │
│                                                             │
│ Alternative disponibili:                                    │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 95kg                                                    ││
│ │ Per lato: 3×15kg + 1×2.5kg                             ││
│ │                                    [Usa questo peso]   ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 102.5kg                                                 ││
│ │ Per lato: 3×15kg + 1×5kg + 1×2.5kg                     ││
│ │                                    [Usa questo peso]   ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│                                          [Mantieni 100kg]  │
└─────────────────────────────────────────────────────────────┘
```

**Algoritmo**:
```dart
List<WeightAlternative> findAlternatives(
  double targetWeight,
  double barbellWeight,
  List<double> availablePlates,
  List<double> excludedPlates,
) {
  final activePlates = availablePlates
      .where((p) => !excludedPlates.contains(p))
      .toList();

  // Prova target esatto
  final exact = calculatePlates(targetWeight, barbellWeight, activePlates);
  if (exact.isExact) return [exact];

  // Trova alternative ±10kg
  final alternatives = <WeightAlternative>[];
  for (double delta = -10; delta <= 10; delta += 2.5) {
    final alt = calculatePlates(
      targetWeight + delta,
      barbellWeight,
      activePlates,
    );
    if (alt.isExact && alt.totalWeight != targetWeight) {
      alternatives.add(alt);
    }
  }

  // Ordina per vicinanza al target
  alternatives.sort((a, b) =>
    (a.totalWeight - targetWeight).abs()
        .compareTo((b.totalWeight - targetWeight).abs())
  );

  return alternatives.take(3).toList();
}
```

---

### 6. Settings: Equipment Profiles Screen

**Path**: Settings → Equipment Profiles

```
┌─────────────────────────────────────────────────────────────┐
│ ← Profili Attrezzatura                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ I tuoi profili                                              │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 🏠 Home Gym                                  [★ Default]││
│ │    Olympic 20kg • 8 tipi dischi                      > ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 🏢 Office Gym                                          ││
│ │    Standard 15kg • 4 tipi dischi                     > ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ [+ Aggiungi nuovo profilo]                                 │
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│ 💡 Puoi creare profili anche direttamente dal              │
│    calcolatore pesi durante l'allenamento                  │
└─────────────────────────────────────────────────────────────┘
```

---

### 7. Profile Detail/Edit Screen

```
┌─────────────────────────────────────────────────────────────┐
│ ← 🏠 Home Gym                                        [🗑️]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ NOME PROFILO                                                │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Home Gym                                                ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ BILANCIERE DEFAULT                                          │
│ [🏋️ 20kg] [⚖️ 15kg] [➖ No] [〰️ EZ] [⚙️ Altro]            │
│                                                             │
│ DISCHI DISPONIBILI                                          │
│ Seleziona i dischi presenti in questa palestra             │
│                                                             │
│ [✓ 25kg] [✓ 20kg] [✓ 15kg] [✓ 10kg]                       │
│ [✓ 5kg]  [✓ 2.5kg] [✓ 1.25kg] [○ 0.5kg]                   │
│                                                             │
│ [Seleziona tutti]  [Set standard]  [Deseleziona]           │
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│ [★ Imposta come profilo default]                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Implementation Tasks

### Phase 1: Core Infrastructure (P0)

| Task | File | Effort |
|------|------|--------|
| 1.1 | Creare `GymEquipmentProfile` entity | Low |
| 1.2 | Creare Hive adapter e registrare | Low |
| 1.3 | Creare `GymEquipmentRepository` | Medium |
| 1.4 | Creare `gymEquipmentProfilesProvider` | Medium |
| 1.5 | Migrare config esistente (availablePlates) a profilo default | Medium |

### Phase 2: Quick Barbell Selection (P0)

| Task | File | Effort |
|------|------|--------|
| 2.1 | Creare `BarbellQuickSelector` widget | Medium |
| 2.2 | Integrare in `PlateCalculatorWidget` | Low |
| 2.3 | Mantenere compatibilità con "Altro" → bottom sheet | Low |

### Phase 3: Profile Management (P1)

| Task | File | Effort |
|------|------|--------|
| 3.1 | Creare `GymProfileSelector` dropdown | Medium |
| 3.2 | Creare `QuickCreateProfileDialog` | Medium |
| 3.3 | Creare `EquipmentProfilesScreen` (settings) | Medium |
| 3.4 | Creare `ProfileDetailScreen` (edit) | Medium |
| 3.5 | Aggiungere entry point in Settings | Low |

### Phase 4: Temporary Exclusion (P1)

| Task | File | Effort |
|------|------|--------|
| 4.1 | Creare `PlateExclusionChips` widget | Medium |
| 4.2 | Aggiungere stato esclusioni a provider | Low |
| 4.3 | Implementare ricalcolo con esclusioni | Medium |
| 4.4 | Reset esclusioni a fine workout | Low |

### Phase 5: Smart Alternatives (P2)

| Task | File | Effort |
|------|------|--------|
| 5.1 | Implementare algoritmo `findAlternatives` | Medium |
| 5.2 | Creare UI suggerimenti alternativi | Medium |
| 5.3 | Callback per applicare alternativa | Low |

### Phase 6: Localization (P1)

| Task | File | Effort |
|------|------|--------|
| 6.1 | Aggiungere tutte le nuove stringhe EN | Low |
| 6.2 | Aggiungere tutte le nuove stringhe IT | Low |

---

## 📝 Localization Keys

```json
{
  "equipmentProfiles": "Equipment Profiles",
  "equipmentProfilesDescription": "Manage gym equipment configurations",
  "createProfile": "Create Profile",
  "editProfile": "Edit Profile",
  "deleteProfile": "Delete Profile",
  "deleteProfileConfirm": "Are you sure you want to delete this profile?",
  "profileName": "Profile Name",
  "profileNameHint": "e.g. Home Gym, Office Gym",
  "defaultBarbell": "Default Barbell",
  "availablePlatesTitle": "Available Plates",
  "availablePlatesDescription": "Select plates available at this gym",
  "setAsDefault": "Set as default profile",
  "currentConfiguration": "Current configuration",
  "saveProfile": "Save Profile",
  "manageProfiles": "Manage Profiles",
  "newProfile": "New Profile...",
  "selectAll": "Select All",
  "standardSet": "Standard Set",
  "deselectAll": "Deselect All",
  "plateExcluded": "{plate}kg excluded temporarily",
  "restoreAllPlates": "Restore all plates",
  "cannotReachWeight": "Cannot reach exactly {weight}kg",
  "availableAlternatives": "Available alternatives",
  "useThisWeight": "Use this weight",
  "keepOriginal": "Keep {weight}kg",
  "perSideBreakdown": "Per side: {breakdown}",
  "profileCreated": "Profile \"{name}\" created",
  "profileUpdated": "Profile updated",
  "profileDeleted": "Profile deleted",
  "quickCreateTip": "Tip: You can also create profiles directly from the plate calculator"
}
```

---

## 🧪 Test Scenarios

### Unit Tests

```dart
group('PlateCalculator', () {
  test('calculates plates correctly with exclusions', () {
    final result = calculatePlates(
      targetWeight: 100,
      barbellWeight: 20,
      availablePlates: [25, 20, 15, 10, 5, 2.5],
      excludedPlates: [25],
    );

    expect(result.perSide, {20: 2}); // 2×20 instead of 1×25+1×15
  });

  test('finds alternatives when exact not possible', () {
    final alternatives = findAlternatives(
      targetWeight: 100,
      barbellWeight: 20,
      availablePlates: [15, 10, 5],
      excludedPlates: [],
    );

    expect(alternatives.length, greaterThan(0));
    expect(alternatives.first.isExact, true);
  });
});

group('GymEquipmentProfile', () {
  test('creates profile with defaults', () {
    final profile = GymEquipmentProfile(
      id: 'test',
      name: 'Home Gym',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(profile.defaultBarbellWeight, 20.0);
    expect(profile.availablePlates, contains(25));
  });

  test('migrates legacy availablePlates to profile', () {
    // Test migration from old config
  });
});
```

### Integration Tests

```dart
testWidgets('can create profile from plate calculator', (tester) async {
  // 1. Open plate calculator
  // 2. Configure barbell and plates
  // 3. Tap "New profile..."
  // 4. Enter name
  // 5. Save
  // 6. Verify profile appears in dropdown
});

testWidgets('temporary exclusion recalculates correctly', (tester) async {
  // 1. Set target weight 100kg
  // 2. Tap on 25kg chip to exclude
  // 3. Verify recalculation shows 2×20kg
  // 4. Tap "Restore all"
  // 5. Verify back to 1×25kg + 1×15kg
});
```

---

## 📊 Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Taps to change barbell | 3-4 | 1 |
| Time to configure for new gym | ~2 min | <30 sec (after first setup) |
| User confusion (Marco persona) | High | Low |

---

## 🔗 Related Documents

- [`USER_PERSONAS.md`](../USER_PERSONAS.md) - Personas reference
- [`DESIGN_GUIDELINES.md`](../DESIGN_GUIDELINES.md) - Design system
- [`CODE_PATTERNS.md`](../CODE_PATTERNS.md) - Implementation patterns

---

## 📅 Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-09 | Initial design document |
