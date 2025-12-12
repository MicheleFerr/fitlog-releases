# Debug Print Statement Cleanup Plan

**Updated**: 2025-12-06
**Status**: Phase 1 Complete - Ready for Phase 2

---

## Executive Summary

### Current State (as of 2025-12-06)
- **Total Active debugPrint()**: 3,034 statements
- **Files with debugPrint but NO kDebugMode import**: 62 files, 607 statements
- **Already Safe (with kDebugMode)**: ~2,427 statements (80%)

### Phase 1 Status: COMPLETE
The following critical files were already wrapped in a previous session:
- `environment_config.dart` - all wrapped
- `admob_config.dart` - all wrapped
- `unified_timer_provider.dart` - all wrapped

---

## Unsafe Files by Priority

### CRITICAL (1 statement in 1 file)
| File | Count | Action |
|------|-------|--------|
| `shared/data/repositories/hybrid_app_config_repository.dart` | 1 | WRAP |

### HIGH (313 statements in 27 files)
| File | Count | Action |
|------|-------|--------|
| `features/admin/data/services/firebase_init_service.dart` | 23 | WRAP |
| `features/exercise_database/data/services/exercise_migration_service.dart` | 22 | WRAP |
| `features/workout/data/repositories/hybrid_exercise_activity_repository.dart` | 22 | WRAP |
| `features/admin/data/services/database_manager_service.dart` | 21 | WRAP |
| `features/exercise_database/data/repositories/hybrid_exercise_repository.dart` | 21 | WRAP |
| `features/health_sync/data/datasources/health_remote_datasource.dart` | 19 | WRAP |
| `features/exercise_database/data/services/exercise_sync_service.dart` | 19 | WRAP |
| `features/onboarding/domain/services/onboarding_tour_manager.dart` | 16 | WRAP |
| `features/onboarding/domain/services/trigger_engine.dart` | 16 | WRAP |
| `features/admin/data/services/exercise_publish_service.dart` | 15 | WRAP |
| `features/scheduling/services/schedule_live_activity_service.dart` | 14 | WRAP |
| `features/stress_index/data/repositories/stress_index_repository.dart` | 13 | WRAP |
| `shared/data/services/rewarded_ad_service.dart` | 13 | WRAP |
| `shared/data/services/interstitial_ad_service.dart` | 12 | WRAP |
| `features/exercise_database/data/services/exercise_system_test_service.dart` | 11 | WRAP |

### MEDIUM (212 statements in 31 files)
| File | Count | Action |
|------|-------|--------|
| `features/workout/presentation/widgets/edit_exercise_modal.dart` | 37 | WRAP |
| `features/onboarding/presentation/providers/onboarding_state_provider.dart` | 37 | WRAP |
| `features/onboarding/presentation/providers/tutorial_state_notifier.dart` | 25 | WRAP |
| `features/settings/presentation/providers/cloud_sync_provider.dart` | 22 | WRAP |
| `features/admin/presentation/providers/community_corrections_provider.dart` | 11 | WRAP |
| `features/settings/presentation/widgets/premium_sync_card.dart` | 9 | WRAP |
| `features/workout/presentation/widgets/quick_start/context_gathering_bottom_sheet.dart` | 8 | WRAP |
| `features/admin/presentation/screens/community_corrections_screen.dart` | 7 | WRAP |
| `features/onboarding/presentation/providers/onboarding_tour_provider.dart` | 7 | WRAP |
| `features/workout/presentation/widgets/exercise_replacement_modal.dart` | 6 | WRAP |
| `shared/presentation/widgets/adaptive_banner_ad.dart` | 6 | WRAP |

### LOW (81 statements in 3 files)
| File | Count | Action |
|------|-------|--------|
| `debug/exercise_history_debug.dart` | 69 | REMOVE (debug only) |
| `features/migration/data_migration_script.dart` | 10 | KEEP (runs once) |
| `features/onboarding/domain/utils/spotlight_positioning.dart` | 2 | WRAP |

---

## Phase 2: Data Layer Cleanup (NEXT)

### Goal
Wrap all debugPrint in HIGH priority data layer files.

### Files to Process (Top 10)
1. `firebase_init_service.dart` (23)
2. `exercise_migration_service.dart` (22)
3. `hybrid_exercise_activity_repository.dart` (22)
4. `database_manager_service.dart` (21)
5. `hybrid_exercise_repository.dart` (21)
6. `health_remote_datasource.dart` (19)
7. `exercise_sync_service.dart` (19)
8. `rewarded_ad_service.dart` (13)
9. `interstitial_ad_service.dart` (12)
10. `stress_index_repository.dart` (13)

**Estimated Time**: 2-3 hours
**Total Statements**: 185

### Wrapping Pattern
```dart
// BEFORE (unsafe)
debugPrint('Loading data...');

// AFTER (safe)
if (kDebugMode) {
  debugPrint('Loading data...');
}
```

---

## Phase 3: Presentation Layer Cleanup

### Goal
Wrap all debugPrint in MEDIUM priority presentation files.

### Files to Process (Top 5)
1. `edit_exercise_modal.dart` (37)
2. `onboarding_state_provider.dart` (37)
3. `tutorial_state_notifier.dart` (25)
4. `cloud_sync_provider.dart` (22)
5. `community_corrections_provider.dart` (11)

**Estimated Time**: 1-2 hours
**Total Statements**: 132

---

## Phase 4: Debug File Cleanup

### Goal
Remove or isolate debug-only files.

### Files
1. `debug/exercise_history_debug.dart` - Consider deleting (69 statements)

---

## Quick Commands

### Count Current Unsafe
```bash
python3 << 'EOF'
import os, re
total = 0
for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r') as file:
                content = file.read()
            if 'debugPrint(' in content and 'kDebugMode' not in content:
                count = len(re.findall(r'debugPrint\(', content))
                total += count
                print(f'{count:3d}  {path[4:]}')
print(f'\nTotal unsafe: {total}')
EOF
```

### Verify File is Safe
```bash
grep -c "kDebugMode" lib/path/to/file.dart  # Should be > 0
grep -c "debugPrint" lib/path/to/file.dart  # Compare counts
```

---

## Success Criteria

- [ ] All data layer files have kDebugMode import
- [ ] All presentation files have kDebugMode import
- [ ] flutter analyze passes
- [ ] No debugPrint in production builds (verify with Release mode)

---

## Changelog

### 2025-12-06
- Updated with accurate scan data
- Phase 1 marked complete (was already done)
- Reorganized priorities based on actual file analysis
- Removed outdated file references
