# Rate Limiting Implementation Guide

## Overview

Rate limiting controls the frequency of API calls to prevent abuse, reduce costs, and improve system stability.

**OWASP Mobile Security**: M1 - Improper Platform Usage

## Why Rate Limiting?

Without rate limiting, your app is vulnerable to:

❌ **Brute Force Attacks** - Unlimited login attempts
❌ **Data Scraping** - Mass data extraction
❌ **DoS Attacks** - Overwhelming the API with requests
❌ **Cost Explosion** - Firebase charges per operation
❌ **Poor UX** - Server overload leads to slow responses

## Implementation Status

**Current State**: ✅ RateLimiter implemented with Token Bucket algorithm
**Presets Available**: ✅ Strict, Moderate, Lenient, Firebase-optimized
**Manager**: ✅ Multi-endpoint rate limiter manager

## Algorithm: Token Bucket

The Token Bucket algorithm works like this:

1. **Bucket Initialization**: Start with N tokens (e.g., 10)
2. **Consumption**: Each API call consumes 1 token
3. **Refill**: Tokens refill at a constant rate (e.g., 1/second)
4. **Limit**: If no tokens available, request is denied

**Visual Example:**
```
Bucket capacity: 10 tokens
Refill rate: 1 token/second

Time    Tokens  Action              Result
0s      10      -                   -
1s      10      API call (consume)  9 tokens left
2s      10      Refilled           10 tokens
5s      10      5 API calls        5 tokens left
6s      6       Refilled           6 tokens
7s      7       10 API calls       ❌ DENIED (only 7 available)
```

## Rate Limit Presets

### 1. Strict (Authentication)

**Use for**: Login, password reset, sensitive operations

```dart
final limiter = RateLimitPresets.strict();
// - 5 requests burst
// - 1 refill every 10 seconds
// - Max ~6 requests per minute
```

**Why Strict?**
- Prevents brute force attacks
- Each login attempt should be deliberate
- Users rarely need >5 login attempts

### 2. Moderate (General API)

**Use for**: Normal API calls, Firestore queries

```dart
final limiter = RateLimitPresets.moderate();
// - 10 requests burst
// - 1 refill per second
// - Max ~60 requests per minute
```

**Why Moderate?**
- Balances UX and protection
- Allows normal usage patterns
- Prevents spam/abuse

### 3. Lenient (Search/Autocomplete)

**Use for**: High-frequency operations, search as-you-type

```dart
final limiter = RateLimitPresets.lenient();
// - 30 requests burst
// - 2 refills per second
// - Max ~120 requests per minute
```

**Why Lenient?**
- Smooth user experience
- No noticeable delays
- Still prevents abuse

### 4. Firebase Optimized

**Use for**: Firestore reads/writes, Cloud Functions

```dart
final limiter = RateLimitPresets.firebaseOptimized();
// - 20 requests burst (for app load)
// - 2 refills per second
// - Cost-optimized for Firebase pricing
```

**Why Firebase Optimized?**
- Firebase charges per read/write
- Balances UX with cost control
- Prevents runaway costs

## Basic Usage

### Simple Rate Limiting

```dart
import 'package:gymbro_flutter_new/shared/domain/security/rate_limiter.dart';

// Create limiter
final limiter = RateLimitPresets.moderate();

// Before API call
if (await limiter.tryConsume()) {
  // Allowed - perform operation
  final workouts = await firestore.collection('workouts').get();
} else {
  // Rate limit exceeded
  SnackBarService.showWarning(
    context,
    context.l10n.tooManyRequests,
  );
}
```

### With Exponential Backoff

For non-critical operations that can tolerate delays:

```dart
final success = await limiter.consumeWithBackoff(
  maxAttempts: 3,
  initialDelay: Duration(seconds: 1),
);

if (success) {
  await performOperation();
} else {
  showError(context.l10n.serviceTemporarilyUnavailable);
}
```

### Wait for Tokens

For critical operations that MUST complete:

```dart
// This will wait until tokens are available
await limiter.waitAndConsume();

// Now perform critical operation
await saveCriticalData();
```

## Multi-Endpoint Management

### Setup Rate Limiter Manager

```dart
import 'package:gymbro_flutter_new/shared/domain/security/rate_limiter.dart';

// Create manager
final manager = RateLimiterManager();

// Register endpoints with different limits
manager.registerEndpoint('login', RateLimitPresets.strict());
manager.registerEndpoint('search', RateLimitPresets.lenient());
manager.registerEndpoint('firestore_read', RateLimitPresets.firebaseOptimized());
manager.registerEndpoint('firestore_write', RateLimitPresets.moderate());
```

### Use With Riverpod

```dart
// Provider for rate limiter manager
final rateLimiterManagerProvider = Provider<RateLimiterManager>((ref) {
  final manager = RateLimiterManager();

  // Configure endpoints
  manager.registerEndpoint('login', RateLimitPresets.authentication());
  manager.registerEndpoint('workout_query', RateLimitPresets.firebaseOptimized());
  manager.registerEndpoint('search', RateLimitPresets.search());

  // Dispose when provider is disposed
  ref.onDispose(() => manager.dispose());

  return manager;
});

// Use in repository
class WorkoutRepository {
  final RateLimiterManager _rateLimiter;

  WorkoutRepository(this._rateLimiter);

  Future<List<Workout>> fetchWorkouts() async {
    // Check rate limit before query
    if (!await _rateLimiter.tryConsume('workout_query')) {
      throw RateLimitExceededException('Too many workout queries');
    }

    return await firestore.collection('workouts').get();
  }
}
```

## Firebase Integration

### Firestore Reads

```dart
class FirestoreRepository {
  final RateLimiter _readLimiter = RateLimitPresets.firebaseOptimized();

  Future<QuerySnapshot> query(String collection) async {
    // Rate limit before read
    if (!await _readLimiter.tryConsume()) {
      throw Exception('Query rate limit exceeded. Please wait.');
    }

    return await firestore.collection(collection).get();
  }

  void dispose() {
    _readLimiter.dispose();
  }
}
```

### Firestore Writes

```dart
class FirestoreRepository {
  final RateLimiter _writeLimiter = RateLimitPresets.moderate();

  Future<void> save(String collection, Map<String, dynamic> data) async {
    // Rate limit before write
    if (!await _writeLimiter.tryConsume()) {
      throw Exception('Write rate limit exceeded. Please wait.');
    }

    await firestore.collection(collection).add(data);
  }

  void dispose() {
    _writeLimiter.dispose();
  }
}
```

### Authentication

```dart
class AuthService {
  final RateLimiter _loginLimiter = RateLimitPresets.authentication();

  Future<void> login(String email, String password) async {
    // Strict rate limiting for login
    if (!await _loginLimiter.tryConsume()) {
      throw Exception('Too many login attempts. Please wait 30 seconds.');
    }

    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void dispose() {
    _loginLimiter.dispose();
  }
}
```

## User Feedback

### Show Remaining Tokens

```dart
final tokens = limiter.availableTokens;
final percentage = limiter.fillPercentage;

if (percentage < 0.3) {
  // Show warning when running low
  showWarning('API quota: ${(percentage * 100).round()}% remaining');
}
```

### Show Time Until Refill

```dart
if (!limiter.hasTokens) {
  final timeUntilRefill = limiter.timeUntilRefill;

  showError(
    'Rate limit exceeded. Try again in ${timeUntilRefill.inSeconds}s',
  );
}
```

### Progressive UI

```dart
Widget buildRateLimitIndicator() {
  return Consumer(
    builder: (context, ref, _) {
      final manager = ref.watch(rateLimiterManagerProvider);
      final percentage = manager.getLimiter('api_calls')?.fillPercentage ?? 1.0;

      return LinearProgressIndicator(
        value: percentage,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation(
          percentage > 0.5 ? Colors.green :
          percentage > 0.2 ? Colors.orange :
          Colors.red,
        ),
      );
    },
  );
}
```

## Best Practices

### ✅ DO:

1. **Use appropriate presets** - Match limiter to operation criticality
2. **Provide user feedback** - Show why request was denied
3. **Implement backoff** - Retry with increasing delays
4. **Monitor metrics** - Track rate limit hits
5. **Dispose properly** - Clean up timers when done

### ❌ DON'T:

1. **Don't use same limiter for all operations** - Different endpoints need different limits
2. **Don't hide errors** - User should know why request failed
3. **Don't be too strict** - Balance security with UX
4. **Don't forget disposal** - Memory leaks from timers
5. **Don't rely only on client-side** - Server-side validation is essential

## Cost Optimization (Firebase)

### Firestore Pricing (2024)

- **Reads**: $0.06 per 100k documents
- **Writes**: $0.18 per 100k documents
- **Deletes**: $0.02 per 100k documents

### Example Savings

**Without Rate Limiting:**
- User spams refresh button 100 times/min
- 100 reads/min × 60 min = 6,000 reads/hour
- 6,000 × 24 hours = 144,000 reads/day
- Cost: $0.0864/day per user

**With Rate Limiting (Moderate):**
- Max 60 reads/min (enforced)
- 60 × 60 min = 3,600 reads/hour
- 3,600 × 24 hours = 86,400 reads/day
- Cost: $0.0518/day per user
- **Savings: 40% reduction**

### Recommended Limits by Operation

| Operation | Preset | Max/Min | Cost Impact |
|-----------|--------|---------|-------------|
| Login | Strict | ~6 | Low (rare) |
| Firestore Read | Firebase | ~120 | **High** |
| Firestore Write | Moderate | ~60 | **Very High** |
| Search | Lenient | ~120 | Medium |
| Cloud Function | Moderate | ~60 | High |

## Testing

### Unit Tests

```dart
test('should allow requests within limit', () async {
  final limiter = RateLimiter(
    maxTokens: 5,
    refillRate: Duration(seconds: 1),
  );

  // Should allow 5 requests
  for (int i = 0; i < 5; i++) {
    final allowed = await limiter.tryConsume();
    expect(allowed, true);
  }

  // 6th request should be denied
  final denied = await limiter.tryConsume();
  expect(denied, false);

  limiter.dispose();
});

test('should refill tokens over time', () async {
  final limiter = RateLimiter(
    maxTokens: 1,
    refillRate: Duration(milliseconds: 100),
  );

  // Consume token
  await limiter.tryConsume();
  expect(limiter.hasTokens, false);

  // Wait for refill
  await Future.delayed(Duration(milliseconds: 150));
  expect(limiter.hasTokens, true);

  limiter.dispose();
});
```

### Integration Tests

```dart
testWidgets('should show rate limit error', (tester) async {
  final limiter = RateLimitPresets.strict();

  await tester.pumpWidget(MyApp(rateLimiter: limiter));

  // Spam button 10 times
  for (int i = 0; i < 10; i++) {
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  }

  // Should show rate limit error
  expect(find.text('Too many requests'), findsOneWidget);
});
```

## Monitoring & Analytics

### Track Rate Limit Violations

```dart
if (!await limiter.tryConsume()) {
  // Log rate limit hit (privacy-safe)
  await PrivacySafeAnalytics.trackEvent(
    name: 'rate_limit_exceeded',
    props: {
      'endpoint': 'workout_query',
      'tokens_available': limiter.availableTokens,
      // NO: user_id or device_id
    },
  );

  throw RateLimitException();
}
```

### Metrics to Track

- Rate limit hit rate (% of requests denied)
- Most rate-limited endpoints
- Average token consumption per user
- Cost savings vs no rate limiting

## Error Handling

### Custom Exception

```dart
class RateLimitExceededException implements Exception {
  final String message;
  final Duration retryAfter;

  RateLimitExceededException(
    this.message, {
    this.retryAfter = const Duration(seconds: 1),
  });

  @override
  String toString() => 'RateLimitExceededException: $message';
}
```

### Graceful Handling

```dart
try {
  if (!await limiter.tryConsume()) {
    throw RateLimitExceededException(
      'Too many requests',
      retryAfter: limiter.timeUntilRefill,
    );
  }

  await performOperation();
} on RateLimitExceededException catch (e) {
  SnackBarService.showWarning(
    context,
    '${e.message}. Retry in ${e.retryAfter.inSeconds}s',
  );
}
```

## Advanced: Adaptive Rate Limiting

### Adjust Based on Network Conditions

```dart
class AdaptiveRateLimiter {
  RateLimiter _limiter = RateLimitPresets.moderate();

  void adjustForNetwork(ConnectivityResult result) {
    if (result == ConnectivityResult.mobile) {
      // More restrictive on mobile data
      _limiter.dispose();
      _limiter = RateLimitPresets.strict();
    } else if (result == ConnectivityResult.wifi) {
      // More lenient on WiFi
      _limiter.dispose();
      _limiter = RateLimitPresets.lenient();
    }
  }
}
```

### User-Based Limits

```dart
RateLimiter createUserSpecificLimiter(User user) {
  if (user.isPremium) {
    // Premium users get higher limits
    return RateLimiter(
      maxTokens: 50,
      refillRate: Duration(milliseconds: 500),
    );
  } else {
    // Free users get standard limits
    return RateLimitPresets.moderate();
  }
}
```

## References

- [OWASP API Security - Rate Limiting](https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/)
- [Token Bucket Algorithm](https://en.wikipedia.org/wiki/Token_bucket)
- [Firebase Pricing](https://firebase.google.com/pricing)

## Support

For questions about rate limiting:
1. Check this guide first
2. Review `lib/shared/domain/security/rate_limiter.dart`
3. Test with different presets
4. Monitor Firebase usage in console
