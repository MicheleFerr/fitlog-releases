# Piano Refactoring: Rinomina File Exercise Database

**Data**: 2024-12-16
**Obiettivo**: Eliminare confusione da file con nomi duplicati
**Rischio**: BASSO (solo rinomina file + update import)

---

## Sommario Modifiche

| File Attuale | Nuovo Nome | Import da aggiornare |
|--------------|------------|---------------------|
| `exercise_database/.../exercise.dart` | `exercise_definition.dart` | 59 file |
| `exercise_database/.../exercise_template.dart` | `exercise_definition_template.dart` | 3 file |
| `exercise.freezed.dart` | `exercise_definition.freezed.dart` | auto |
| `exercise.g.dart` | `exercise_definition.g.dart` | auto |

---

## File da Rinominare

### 1. exercise.dart → exercise_definition.dart

**Path**: `lib/features/exercise_database/domain/entities/`

**File correlati da rinominare**:
- `exercise.dart` → `exercise_definition.dart`
- `exercise.freezed.dart` → `exercise_definition.freezed.dart` (se esiste)
- `exercise.g.dart` → `exercise_definition.g.dart` (se esiste)

### 2. exercise_template.dart → exercise_definition_template.dart

**Path**: `lib/features/exercise_database/domain/entities/`

**File correlati da rinominare**:
- `exercise_template.dart` → `exercise_definition_template.dart`
- `exercise_template.freezed.dart` → `exercise_definition_template.freezed.dart`
- `exercise_template.g.dart` → `exercise_definition_template.g.dart`

---

## File con Import da Aggiornare (59 + 3 = 62 totali)

### Per exercise.dart (59 file)

#### Admin Feature (8 file)
```
lib/features/admin/data/services/database_manager_service.dart
lib/features/admin/data/services/firebase_init_service.dart
lib/features/admin/domain/services/exercise_statistics_service.dart
lib/features/admin/presentation/providers/database_manager_provider.dart
lib/features/admin/presentation/providers/database_manager_tab_provider.dart
lib/features/admin/presentation/screens/database_manager_screen.dart
lib/features/admin/presentation/screens/exercise_editor_screen.dart
lib/features/admin/presentation/widgets/exercise_quick_edit_card.dart
```

#### AI Coach Feature (2 file)
```
lib/features/ai_coach/data/analyzers/volume_balance_analyzer.dart
lib/features/ai_coach/presentation/providers/ai_insights_provider.dart
```

#### Analytics Feature (3 file)
```
lib/features/analytics/domain/services/chart_data_service.dart
lib/features/analytics/domain/services/exercise_suggestion_engine.dart
lib/features/analytics/domain/services/rep_zone_suggestion_engine.dart
```

#### Custom Exercises Feature (1 file)
```
lib/features/custom_exercises/presentation/widgets/custom_exercise_form_sheet.dart
```

#### Debug Feature (1 file)
```
lib/features/debug/presentation/data/demo_modal_data.dart
```

#### Exercise Database Feature (15 file)
```
lib/features/exercise_database/data/models/exercise_model.dart
lib/features/exercise_database/data/repositories/hybrid_exercise_repository.dart
lib/features/exercise_database/data/repositories/json_exercise_repository.dart
lib/features/exercise_database/data/services/exercise_cache_manager.dart
lib/features/exercise_database/data/services/exercise_migration_service.dart
lib/features/exercise_database/data/services/exercise_search_service_optimized.dart
lib/features/exercise_database/data/services/ml_exercise_search_service.dart
lib/features/exercise_database/data/services/patch_manager_service.dart
lib/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart
lib/features/exercise_database/domain/services/exercise_fuzzy_search_isolate.dart
lib/features/exercise_database/domain/services/i_exercise_search_service.dart
lib/features/exercise_database/domain/services/patch_conflict_detector.dart
lib/features/exercise_database/presentation/exercise_search_screen.dart
lib/features/exercise_database/presentation/providers/exercise_database_provider.dart
lib/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart
lib/features/exercise_database/presentation/providers/patch_conflict_provider.dart
lib/features/exercise_database/presentation/widgets/exercise_customization_screen.dart
lib/features/exercise_database/presentation/widgets/exercise_details_modal.dart
lib/features/exercise_database/presentation/widgets/patch_submission_dialog.dart
```

#### Home Feature (6 file)
```
lib/features/home/domain/services/ai_coach_service.dart
lib/features/home/domain/services/ai_volume_calculator.dart
lib/features/home/domain/services/data_validation_service.dart
lib/features/home/domain/services/exercise_replacement_service.dart
lib/features/home/presentation/widgets/ai_coach_card.dart
lib/features/home/presentation/widgets/exercise_replacement_dialog.dart
```

#### Import Feature (2 file)
```
lib/features/import/data/mappers/exercise_name_mapper.dart
lib/features/import/data/repositories/import_repository.dart
```

#### Workout Feature (13 file)
```
lib/features/workout/domain/entities/superset_configuration.dart
lib/features/workout/presentation/tabs/exercise_alternatives_tab.dart
lib/features/workout/presentation/widgets/add_exercise_modal.dart
lib/features/workout/presentation/widgets/dropset_builder_widget.dart
lib/features/workout/presentation/widgets/dropset_weight_picker_modal.dart
lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart
lib/features/workout/presentation/widgets/exercise_name_autocomplete.dart
lib/features/workout/presentation/widgets/exercise_replacement_modal.dart
lib/features/workout/presentation/widgets/restpause_builder_widget.dart
lib/features/workout/presentation/widgets/superset_builder_widget.dart
lib/features/workout/presentation/widgets/superset_config_sheet.dart
lib/features/workout/presentation/widgets/superset_link_modal.dart
lib/features/workout/presentation/widgets/superset_round_config_sheet.dart
```

#### Shared (4 file)
```
lib/shared/domain/converters/exercise_converter.dart
lib/shared/presentation/widgets/exercise_picker/exercise_list_widget.dart
lib/shared/presentation/widgets/exercise_picker/exercise_picker_config.dart
lib/shared/presentation/widgets/exercise_picker/quick_exercise_picker.dart
```

### Per exercise_template.dart (3 file)
```
lib/features/exercise_database/data/repositories/exercise_repository.dart
lib/features/exercise_database/domain/services/exercise_search_service.dart
lib/features/exercise_database/presentation/providers/exercise_search_provider.dart
```

---

## Passi di Implementazione

### Fase 1: Preparazione
1. [ ] Creare branch: `git checkout -b refactor/rename-exercise-files`
2. [ ] Assicurarsi che tutti i test passino: `flutter test`
3. [ ] Assicurarsi che analyze passi: `flutter analyze`

### Fase 2: Rinomina File
4. [ ] Rinominare `exercise.dart` → `exercise_definition.dart`
5. [ ] Rinominare `exercise.freezed.dart` → `exercise_definition.freezed.dart` (se esiste)
6. [ ] Rinominare `exercise.g.dart` → `exercise_definition.g.dart` (se esiste)
7. [ ] Rinominare `exercise_template.dart` → `exercise_definition_template.dart`
8. [ ] Rinominare `exercise_template.freezed.dart` → `exercise_definition_template.freezed.dart`
9. [ ] Rinominare `exercise_template.g.dart` → `exercise_definition_template.g.dart`

### Fase 3: Aggiorna Import (search & replace)
10. [ ] Replace in all files:
    ```
    OLD: import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    NEW: import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_definition.dart'
    ```
11. [ ] Replace in all files:
    ```
    OLD: import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart'
    NEW: import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_definition_template.dart'
    ```

### Fase 4: Rigenera Codice
12. [ ] Rigenerare freezed/json_serializable: `flutter pub run build_runner build --delete-conflicting-outputs`

### Fase 5: Verifica
13. [ ] `flutter analyze` - deve passare senza errori
14. [ ] `flutter test` - deve passare
15. [ ] Test manuale nell'app

### Fase 6: Commit
16. [ ] Commit: `git commit -m "refactor: rename exercise files to exercise_definition for clarity"`
17. [ ] Merge in main

---

## Comando per Search & Replace Automatico

```bash
# Rinomina file
cd lib/features/exercise_database/domain/entities/
mv exercise.dart exercise_definition.dart
mv exercise_template.dart exercise_definition_template.dart
# I file .freezed.dart e .g.dart verranno rigenerati

# Search & replace imports (da eseguire dalla root)
find lib -name "*.dart" -exec sed -i '' \
  's|exercise_database/domain/entities/exercise.dart|exercise_database/domain/entities/exercise_definition.dart|g' {} \;

find lib -name "*.dart" -exec sed -i '' \
  's|exercise_database/domain/entities/exercise_template.dart|exercise_database/domain/entities/exercise_definition_template.dart|g' {} \;
```

---

## Rischi e Mitigazioni

| Rischio | Mitigazione |
|---------|-------------|
| Import mancato | `flutter analyze` catturerà errori |
| Test falliti | Test suite completa prima di merge |
| Generated files inconsistenti | Rigenerare con build_runner |

---

## Note

- Le classi (`ExerciseDefinition`, `ExerciseDefinitionTemplate`) **NON cambiano nome**
- I typedef per backward compatibility (`typedef Exercise = ExerciseDefinition`) restano
- Solo i **nomi dei file** cambiano
- Impatto: ~62 file da aggiornare (automatizzabile con sed)
