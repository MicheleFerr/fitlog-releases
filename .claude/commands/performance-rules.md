# Performance Rules - FitLog Pro

## Post-feature check (OBBLIGATORIO)

```bash
.claude/scripts/performance-check.sh lib/features/<feature>/
```

## Anti-pattern

| Pattern | Sbagliato | Corretto |
|---------|-----------|----------|
| **Risorse in loop** | `for (x) { await openBox() }` | `box = await openBox(); for (x) { box.get() }` |
| **Batch ops** | `for (x) { await box.put() }` | `await box.putAll(entries)` |
| **Log in loop** | `for (x) { debugPrint(x) }` | `debugPrint('${items.length} items')` |
| **Manager/Limiter** | `RateLimiter()` ogni chiamata | `static final _limiter = RateLimiter()` |
| **Async init** | `service.init()` fire-and-forget | Lock interno + `ref.onDispose()` |
| **Risorse costose** | Provider senza `keepAlive` | `ref.keepAlive()` se Hive/Firebase |
| **Sequenziale** | `await a(); await b();` | `await Future.wait([a(), b()])` |
| **Eventi rapidi** | Handler diretto | `Timer` debounce 100ms |

## Template Service Singleton

```dart
class MyService {
  static MyService? _instance;
  factory MyService() => _instance ??= MyService._();
  MyService._();

  bool _initialized = false;
  final _initLock = Lock();

  Future<void> initialize() async {
    await _initLock.synchronized(() async {
      if (_initialized) return;
      // ... init ...
      _initialized = true;
    });
  }
}
```
