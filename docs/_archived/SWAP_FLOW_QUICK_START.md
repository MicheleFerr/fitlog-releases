# SWAP FLOW - QUICK START GUIDE

## 30-Second Overview

**The Swap Flow detects when a user completes a workout on the wrong day and intelligently suggests swapping it to the correct scheduled day.**

- User completes "Leg Day" on Monday
- But "Leg Day" is scheduled for Friday
- App offers to move it to Friday automatically
- User confirms → Both days update atomically in database

---

## What to Read First

1. **THIS FILE** (5 min) - Quick overview
2. `SWAP_FLOW_SUMMARY.md` (15 min) - Visual flows + architecture
3. `SWAP_FLOW_CODE_GUIDE.md` (30 min) - Exact code to add/modify
4. `SWAP_FLOW_ARCHITECTURE.md` (45 min) - Deep technical details

---

## Implementation Checklist (6 Phases)

### Phase 1: Data Model (30 min)
```bash
# 1. Create new entity
touch lib/features/routine/domain/entities/day_swap_metadata.dart
# (Copy from SWAP_FLOW_CODE_GUIDE.md section 2)

# 2. Update flexible_routine.dart
# Add 2 fields to ScheduledDay:
#   - DateTime? swappedWithDate
#   - DaySwapMetadata? swapMetadata

# 3. Regenerate code
dart run build_runner build
```

### Phase 2: Service Layer (45 min)
```bash
# Create new service
touch lib/features/routine/application/services/routine_swap_service.dart
# (Copy complete code from SWAP_FLOW_CODE_GUIDE.md section 3)
```

### Phase 3: Business Logic (20 min)
```dart
// Update: lib/features/routine/application/services/routine_auto_completion_service.dart
// 1. Add import: routine_swap_service.dart
// 2. Add field to RoutineAutoCompletionResult: SwapOpportunity?
// 3. Add factory: swapDetected(SwapOpportunity swap)
// 4. Modify tryAutoCompleteRoutineDay() to call detectSwapOpportunity()
```

### Phase 4: UI Integration (30 min)
```dart
// Update: lib/features/workout/presentation/providers/workout_provider.dart
// 1. Add imports: routine_swap_service, routine_swap_service
// 2. Replace _autoCompleteRoutineDay() with new version (3 cases)
// 3. Add _showSwapDialog() method
// 4. Add _formatSwapDate() helper
```

### Phase 5: Repository (20 min)
```dart
// Update: lib/features/routine/domain/repositories/flexible_routine_repository.dart
// Add: Future<void> swapDays(...) method signature

// Update: lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart
// Implement swapDays() with atomic update
```

### Phase 6: Testing (1-2 hours)
```bash
# Create tests
touch test/features/routine/application/services/routine_swap_service_test.dart
touch test/features/routine/presentation/widgets/dialogs/swap_opportunity_dialog_test.dart

# Run tests
flutter test test/features/routine/application/services/routine_swap_service_test.dart
```

---

## File Changes at a Glance

| File | Action | Lines | Complexity |
|------|--------|-------|------------|
| day_swap_metadata.dart | CREATE | ~60 | Low |
| routine_swap_service.dart | CREATE | ~250 | Medium |
| flexible_routine.dart | MODIFY | 2 fields | Very Low |
| routine_auto_completion_service.dart | MODIFY | ~20 lines | Low |
| RoutineAutoCompletionResult | MODIFY | ~15 lines | Low |
| workout_provider.dart | MODIFY | ~80 lines | Medium |
| flexible_routine_repository.dart | MODIFY | 1 sig | Very Low |
| firebase_flexible_routine_repository.dart | MODIFY | ~30 lines | Medium |
| swap_opportunity_dialog.dart | CREATE | ~100 | Medium (optional) |

**Total new code:** ~500 lines
**Total modified code:** ~100 lines

---

## Core Concepts

### Detection Logic (detectSwapOpportunity)
```
IF multiple candidates found
  AND today != template scheduled
THEN swap opportunity exists
```

**Example:**
- Template: "Leg Day"
- Candidates: [Friday, Saturday]
- Today: Monday (rest day)
- Result: SWAP OPPORTUNITY!

### Execution Logic (executeSwap)
```
1. Get both days (fromDate=Monday, toDate=Friday)
2. Create metadata about the swap
3. Update both days atomically:
   - toDate marked completed with metadata
   - fromDate marked skipped with metadata
4. Save to Firestore in single transaction
5. Show success toast
```

### Data Structures

**SwapOpportunity** (in-memory service class):
```dart
class SwapOpportunity {
  final String templateId;
  final DateTime completedDate;
  final List<DateTime> originalScheduledDates;
  final DateTime recommendedSwapTarget;
}
```

**DaySwapMetadata** (Freezed entity stored in DB):
```dart
@freezed
class DaySwapMetadata {
  const factory DaySwapMetadata({
    required String originalDay,      // "2025-03-21"
    required String swappedDay,       // "2025-03-17"
    required String templateId,
    required DateTime swappedAt,
    String? reason,                   // "mismatch_detection"
    String? userId,
  });
}
```

---

## Integration Points

### In RoutineAutoCompletionService:
```
User completes workout
  ↓
tryAutoCompleteRoutineDay()
  ├─ Find candidates
  ├─ Single match → auto-complete (existing)
  ├─ Multiple matches?
  │   └─ NEW: detectSwapOpportunity()
  │       └─ Returns SwapOpportunity or null
  └─ Return appropriate result
```

### In workout_provider:
```
_autoCompleteRoutineDay() gets result
  ├─ result.completed → return true (existing)
  ├─ result.swapOpportunity → show dialog (NEW)
  │   ├─ User confirms
  │   │   └─ executeSwap() [NEW]
  │   └─ User cancels → do nothing
  └─ result.candidateDates → show picker (existing)
```

---

## Key Lines to Remember

### In flexible_routine.dart (Lines 134-180)
```dart
// BEFORE ScheduledDay factory
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,
    String? templateId,
    String? workoutId,
    String? skipReason,
    DateTime? originalDate,
    String? notes,
    // ADD THESE 2 LINES:
    DateTime? swappedWithDate,
    DaySwapMetadata? swapMetadata,
  }) = _ScheduledDay;
```

### In routine_auto_completion_service.dart (Around line 168)
Replace the "multiple candidates" return with:
```dart
// NEW: Check for swap opportunity
if (context != null) {
  final swapService = _ref.read(routineSwapServiceProvider);
  final swapOp = await swapService.detectSwapOpportunity(
    completedWorkout: completedWorkout,
    activeRoutine: activeRoutine,
  );
  if (swapOp != null) {
    return RoutineAutoCompletionResult.swapDetected(swapOp);
  }
}
return RoutineAutoCompletionResult.needsUserSelection(candidateDays);
```

### In workout_provider._autoCompleteRoutineDay (Lines 643-663)
Replace entire method with version in CODE_GUIDE.md (handles 3 cases)

---

## Testing Scenarios

### Scenario 1: Single Match (Existing - No Change)
```
- Template: Leg Day
- Candidates: [Friday]
- Today: Monday (rest)
Result: Auto-complete Friday (existing behavior)
```

### Scenario 2: Swap Detected (New)
```
- Template: Leg Day
- Candidates: [Friday, Saturday]
- Today: Monday (rest)
Result: Show swap dialog
  User confirms → Execute swap
```

### Scenario 3: Today Matches (No Swap Needed)
```
- Template: Leg Day
- Candidates: [Friday, Saturday]
- Today: Friday (leg day)
Result: Auto-complete Friday (no swap needed)
```

### Scenario 4: No Candidates (Existing - No Change)
```
- Template: Leg Day
- Candidates: []
- Today: Monday (rest)
Result: Skip silently
```

---

## Before/After Example

### BEFORE Swap Flow
```
User completes "Leg Day" on Monday
  ↓
App finds multiple candidates: [Friday, Saturday]
  ↓
App doesn't know what to do
  ↓
Returns candidates but TODO says "not yet implemented"
  ↓
User has to manually mark Friday as complete
```

### AFTER Swap Flow
```
User completes "Leg Day" on Monday
  ↓
App finds multiple candidates: [Friday, Saturday]
  ↓
App detects: Today is rest day, not Leg Day
  ↓
App shows: "Swap Leg Day to Friday?"
  ↓
User confirms
  ↓
Friday marked complete with swap metadata
Monday marked skipped with swap reference
Toast: "Workout swapped to Friday ✓"
```

---

## Troubleshooting

### Build Error: "DaySwapMetadata not found"
- Make sure `dart run build_runner build` was run after creating day_swap_metadata.dart

### Swap Dialog Never Shows
- Check: Is `context` null? (needs context for dialog)
- Check: Does result.swapOpportunity exist?
- Check: Are multiple candidates found?

### Both Days Not Updating
- Check: Is transaction completing?
- Check: Are day keys correct (YYYY-MM-DD format)?
- Check: Firestore rules allowing update?

### Swap Never Detected
- Check: Does workout have templateId?
- Check: Are candidates found?
- Check: Is today's schedule different from template?
- Debug: Add debugPrint in detectSwapOpportunity()

---

## Deployment Checklist

Before deploying to production:

- [ ] Unit tests passing (routine_swap_service_test.dart)
- [ ] Widget tests passing (swap_dialog_test.dart)
- [ ] Manual testing: Scenario 1-4 all work
- [ ] No compilation errors (`flutter analyze`)
- [ ] Firestore rules updated (if needed)
- [ ] Backward compatibility verified (old routines still work)
- [ ] Analytics tracking added (swap events logged)
- [ ] Error handling tested (network failures, etc)
- [ ] Localization strings added (if custom dialog)
- [ ] Documentation updated (this file)

---

## Performance Impact

- **Detection:** +5-10ms per workout completion (negligible)
- **Swap Execution:** Same as existing updates (~100-200ms)
- **Memory:** +~1KB per swap in metadata
- **DB:** No new collections, just metadata in existing documents

---

## FAQ

**Q: Will this break existing routines?**
A: No! Fields are optional (DateTime?, DaySwapMetadata?). Existing routines continue to work.

**Q: Can I disable swap flow?**
A: Yes, check app config or add user preference setting.

**Q: What if user's internet is offline?**
A: Dialog won't show without context. Offline completion still works, sync queued.

**Q: Can I customize the dialog?**
A: Yes! Create custom `swap_opportunity_dialog.dart` widget and use in `_showSwapDialog()`.

**Q: How many swaps can happen?**
A: Unlimited. Each swap creates metadata. See analytics for frequency.

---

## Next Steps

1. Read `SWAP_FLOW_SUMMARY.md` for visual flows
2. Read `SWAP_FLOW_CODE_GUIDE.md` for exact code
3. Follow implementation checklist above
4. Create unit tests
5. Test all scenarios
6. Deploy!

**Estimated implementation time: 4-6 hours**

---

## Key Files for Reference

- Architecture: `SWAP_FLOW_ARCHITECTURE.md`
- Code Guide: `SWAP_FLOW_CODE_GUIDE.md`
- Summary: `SWAP_FLOW_SUMMARY.md`
- This file: `SWAP_FLOW_QUICK_START.md`

