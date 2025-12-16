# 🚨 HiveBoxManager - Developer Checklist

> **Purpose**: Prevent memory leaks by ensuring all Hive operations use centralized HiveBoxManager
> **Applies to**: All new features, code reviews, refactoring
> **Enforcement**: Pre-commit hooks + Code review

---

## 📋 Quick Reference

### ❌ NEVER DO THIS
```dart
// ❌ Direct Hive.openBox() call
final box = await Hive.openBox('my_box');

// ❌ Creating service without HiveBoxManager
class MyService {
  Future<void> init() async {
    _box = await Hive.openBox('box');
  }
}

// ❌ Provider without BoxManager injection
final myProvider = Provider((ref) => MyService());
```

### ✅ ALWAYS DO THIS
```dart
// ✅ Use HiveBoxManager
final boxManager = ref.watch(hiveBoxManagerProvider);
final box = await boxManager.openBox('my_box');

// ✅ Inject BoxManager in constructor
class MyService {
  MyService(this._boxManager);
  final HiveBoxManager _boxManager;

  Future<void> init() async {
    _box = await _boxManager.openBox('box');
  }
}

// ✅ Provider with BoxManager injection
final myProvider = Provider((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return MyService(boxManager);
});
```

---

## 📝 Pre-Development Checklist

Before writing new code that uses Hive:

### Planning Phase
- [ ] **Identify storage needs**: What data needs to be persisted?
- [ ] **Choose box type**: Box vs LazyBox (use LazyBox for large datasets)
- [ ] **Name convention**: Use descriptive, unique box names (e.g., `workout_templates`, `exercise_cache`)
- [ ] **Determine pattern**: Which migration pattern applies? (Provider injection, Constructor, Singleton)

### Setup Phase
- [ ] **Import HiveBoxManager**: Add `import 'package:gymbro_flutter_new/core/data/hive_box_manager.dart';`
- [ ] **Import Provider** (if using Riverpod): Add `import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';`
- [ ] **Check existing usage**: Search codebase for similar patterns (`grep -r "boxManager.openBox" lib/`)

---

## 🏗️ Implementation Checklist

### For Riverpod Providers

```dart
// ✅ StateNotifierProvider Example
final myStateProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider); // ✅ Step 1
  return MyNotifier(boxManager); // ✅ Step 2
});

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier(this._boxManager) : super(initialState) { // ✅ Step 3
    _initialize();
  }

  final HiveBoxManager _boxManager; // ✅ Step 4
  late Box<MyData> _box;

  Future<void> _initialize() async {
    _box = await _boxManager.openBox<MyData>('my_data'); // ✅ Step 5
  }
}
```

**Checklist**:
- [ ] Step 1: Get boxManager from `ref.watch(hiveBoxManagerProvider)`
- [ ] Step 2: Pass boxManager to constructor
- [ ] Step 3: Accept boxManager in constructor
- [ ] Step 4: Store as `final HiveBoxManager _boxManager`
- [ ] Step 5: Use `_boxManager.openBox()` instead of `Hive.openBox()`
- [ ] Step 6: Add disposal if needed (usually handled by ref.onDispose)

---

### For Services/Repositories

```dart
// ✅ Service Example
class MyService {
  MyService({HiveBoxManager? boxManager}) // ✅ Step 1
      : _boxManager = boxManager ?? HiveBoxManager(); // ✅ Step 2

  final HiveBoxManager _boxManager; // ✅ Step 3
  late Box<MyData> _box;

  Future<void> initialize() async {
    _box = await _boxManager.openBox<MyData>('my_data'); // ✅ Step 4
  }

  Future<void> dispose() async {
    // Usually not needed - HiveBoxManager handles disposal
    // Only add if service has custom cleanup logic
  }
}
```

**Checklist**:
- [ ] Step 1: Add optional `HiveBoxManager? boxManager` parameter
- [ ] Step 2: Initialize with fallback: `boxManager ?? HiveBoxManager()`
- [ ] Step 3: Store as `final HiveBoxManager _boxManager`
- [ ] Step 4: Use `_boxManager.openBox()` in all methods
- [ ] Step 5: Test with mock HiveBoxManager for testability

---

### For Singleton Services

```dart
// ✅ Singleton Example
class MySingleton {
  static final MySingleton _instance = MySingleton._internal();
  factory MySingleton() => _instance;
  MySingleton._internal();

  HiveBoxManager? _boxManager; // ✅ Step 1
  late Box<MyData> _box;

  Future<void> initialize({HiveBoxManager? boxManager}) async { // ✅ Step 2
    _boxManager = boxManager ?? HiveBoxManager(); // ✅ Step 3
    _box = await _boxManager!.openBox<MyData>('my_data'); // ✅ Step 4
  }
}
```

**Checklist**:
- [ ] Step 1: Add nullable `HiveBoxManager? _boxManager` field
- [ ] Step 2: Add optional `{HiveBoxManager? boxManager}` to initialize()
- [ ] Step 3: Assign with fallback: `boxManager ?? HiveBoxManager()`
- [ ] Step 4: Use `_boxManager!.openBox()` (safe because initialized)
- [ ] Step 5: Test by passing mock HiveBoxManager to initialize()

---

### For BaseHybridRepository Children

```dart
// ✅ Repository Example
class MyRepository extends BaseHybridRepository<MyEntity> {
  MyRepository({
    HiveBoxManager? boxManager, // ✅ Step 1
    super.firestore,
    super.auth,
  }) : _boxManager = boxManager ?? HiveBoxManager(), // ✅ Step 2
       super(
     featureName: 'my_feature',
     boxManager: boxManager, // ✅ Step 3 - Pass to parent
   );

  final HiveBoxManager _boxManager; // ✅ Step 4 - Own field (parent's is private)
  late Box<Map> _additionalBox;

  Future<void> _initializeAdditionalBoxes() async {
    _additionalBox = await _boxManager.openBox<Map>('my_additional'); // ✅ Step 5
  }
}
```

**Checklist**:
- [ ] Step 1: Add `HiveBoxManager? boxManager` parameter
- [ ] Step 2: Initialize own field: `_boxManager = boxManager ?? HiveBoxManager()`
- [ ] Step 3: Pass to parent: `super(boxManager: boxManager)`
- [ ] Step 4: Declare own `final HiveBoxManager _boxManager` (parent's is private!)
- [ ] Step 5: Use `_boxManager.openBox()` for additional boxes
- [ ] Step 6: Understand parent already handles main box via `super.boxManager`

---

## 🧪 Testing Checklist

### Unit Tests

```dart
test('should use injected HiveBoxManager', () async {
  // ✅ Step 1: Create mock/real HiveBoxManager
  final mockBoxManager = MockHiveBoxManager();

  // ✅ Step 2: Inject into service
  final service = MyService(boxManager: mockBoxManager);

  // ✅ Step 3: Verify openBox called
  await service.initialize();
  verify(() => mockBoxManager.openBox('my_data')).called(1);
});
```

**Checklist**:
- [ ] Create mock or test instance of HiveBoxManager
- [ ] Pass to constructor/initialize method
- [ ] Verify `openBox()` called with correct box name
- [ ] Test disposal if custom cleanup exists
- [ ] Mock box operations (get, put, delete)

---

### Widget Tests

```dart
testWidgets('provider should inject HiveBoxManager', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MyWidget(),
    ),
  );

  // ✅ Provider automatically gets HiveBoxManager
  // No manual injection needed in widget tests
});
```

**Checklist**:
- [ ] Use `ProviderScope` wrapper
- [ ] Provider gets HiveBoxManager automatically
- [ ] Test UI behavior, not HiveBoxManager internals
- [ ] Override provider if custom behavior needed

---

### Integration Tests

```dart
testWidgets('should dispose HiveBoxManager on app close', (tester) async {
  final container = ProviderContainer();

  // ✅ Create provider
  final service = container.read(myServiceProvider);
  await service.initialize();

  // ✅ Dispose container
  container.dispose();

  // ✅ Verify boxes closed
  await Future.delayed(Duration(milliseconds: 100));
  expect(Hive.isBoxOpen('my_data'), false);
});
```

**Checklist**:
- [ ] Test full lifecycle: create → use → dispose
- [ ] Verify boxes closed after disposal
- [ ] Test multiple services don't interfere
- [ ] Test box reuse (same box opened twice returns same instance)

---

## 🔍 Code Review Checklist

### For Reviewers

When reviewing PRs that touch Hive storage:

#### Critical Checks (MUST PASS)
- [ ] **No direct Hive.openBox()**: Search PR for `Hive.openBox` or `await openBox` (exclude HiveBoxManager itself)
- [ ] **HiveBoxManager imported**: Check imports include HiveBoxManager or provider
- [ ] **Correct pattern used**: Verify one of the 4 migration patterns is followed
- [ ] **Constructor receives BoxManager**: Services/repositories have `HiveBoxManager` parameter
- [ ] **Provider injects BoxManager**: Providers use `ref.watch(hiveBoxManagerProvider)`

#### Quality Checks (SHOULD PASS)
- [ ] **Disposal handled**: Provider has `ref.onDispose()` or service has `dispose()` method
- [ ] **Box name is descriptive**: Not `'box'` or `'data'`, but `'workout_templates'` etc.
- [ ] **Tests updated**: Tests pass mock/real HiveBoxManager
- [ ] **Comments added**: Document box purpose and data structure
- [ ] **No duplicate boxes**: Check if box already exists elsewhere

#### Documentation Checks (NICE TO HAVE)
- [ ] **Box documented**: Add comment explaining box contents
- [ ] **Migration pattern noted**: If novel pattern, document why
- [ ] **Breaking changes**: If box structure changes, note migration path

---

### Common Review Findings

**❌ Reject if found**:
```dart
// ❌ Direct call without BoxManager
final box = await Hive.openBox('data');

// ❌ Service without BoxManager parameter
class MyService {
  Future<void> init() async {
    _box = await Hive.openBox('box');
  }
}

// ❌ Provider without injection
final provider = Provider((ref) => MyService());
```

**⚠️ Request changes if found**:
```dart
// ⚠️ Non-descriptive box name
await boxManager.openBox('data'); // What data?

// ⚠️ Missing disposal
class MyService {
  // No dispose() method, no ref.onDispose()
}

// ⚠️ Missing tests
// No test file for new service
```

**✅ Approve if found**:
```dart
// ✅ Proper injection
final provider = Provider((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return MyService(boxManager);
});

// ✅ Descriptive box name + comment
/// Cache for workout template metadata (ID, name, last modified)
await boxManager.openBox<Map>('workout_template_cache');

// ✅ Tests included
test('should use HiveBoxManager', () async {
  final service = MyService(boxManager: mockBoxManager);
  // ...
});
```

---

## 🛠️ Pre-Commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Check for direct Hive.openBox() calls
VIOLATIONS=$(grep -r "Hive\.openBox\|await openBox" lib/ --include="*.dart" | \
  grep -v "hive_box_manager.dart" | \
  grep -v "^\s*//" | \
  grep -v "boxManager.openBox\|_boxManager.openBox" | \
  wc -l)

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌ ERROR: Found direct Hive.openBox() calls!"
  echo "Use HiveBoxManager instead. See docs/TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_CHECKLIST.md"
  grep -r "Hive\.openBox\|await openBox" lib/ --include="*.dart" -n | \
    grep -v "hive_box_manager.dart" | \
    grep -v "^\s*//" | \
    grep -v "boxManager.openBox\|_boxManager.openBox"
  exit 1
fi

echo "✅ No direct Hive.openBox() calls found"
```

**Setup**:
```bash
chmod +x .git/hooks/pre-commit
```

---

## 📖 Reference Examples

**Good Examples in Codebase**:
- `lib/features/onboarding/presentation/providers/onboarding_state_provider.dart` - Provider injection
- `lib/features/workout/domain/services/workout_template_cache_service.dart` - Constructor parameter
- `lib/features/exercise_database/domain/services/exercise_usage_tracker.dart` - Singleton pattern
- `lib/features/community/data/repositories/hybrid_community_repository.dart` - BaseHybridRepository child

**Search Commands**:
```bash
# Find all HiveBoxManager usages
grep -r "boxManager.openBox\|_boxManager.openBox" lib/ -n

# Find provider injection examples
grep -r "hiveBoxManagerProvider" lib/ -n

# Check for violations
grep -r "Hive\.openBox" lib/ --include="*.dart" | grep -v "hive_box_manager.dart"
```

---

## 🚨 Enforcement Policy

### Build Time
- ❌ **Build fails** if direct `Hive.openBox()` found (pre-commit hook)
- ⚠️ **Warning** if box name is generic (`'data'`, `'box'`, `'cache'`)

### Code Review
- ❌ **Reject PR** if direct Hive calls found
- ⚠️ **Request changes** if tests missing
- ⚠️ **Request changes** if disposal not handled

### CI/CD
- ✅ Run `flutter analyze` to catch missing imports
- ✅ Run grep check for Hive.openBox violations
- ✅ Run tests to verify HiveBoxManager injection

---

## 📚 Additional Resources

- **Full Report**: `docs/TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_MIGRATION_REPORT.md`
- **HiveBoxManager Source**: `lib/core/data/hive_box_manager.dart`
- **Provider**: `lib/core/data/providers/hive_box_manager_provider.dart`
- **Code Quality Rules**: `CODE_QUALITY_RULES.md`

---

**Last Updated**: October 21, 2025
**Status**: ✅ Enforced
**Violations**: Report to tech lead

