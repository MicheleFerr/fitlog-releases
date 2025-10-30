import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/security/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('should allow requests within token limit', () async {
      final limiter = RateLimiter(
        maxTokens: 5,
        refillRate: const Duration(seconds: 1),
      );

      // Should allow 5 requests
      for (int i = 0; i < 5; i++) {
        final allowed = await limiter.tryConsume();
        expect(allowed, true, reason: 'Request $i should be allowed');
      }

      // 6th request should be denied
      final denied = await limiter.tryConsume();
      expect(denied, false, reason: '6th request should be denied');

      limiter.dispose();
    });

    test('should deny requests when no tokens available', () async {
      final limiter = RateLimiter(
        maxTokens: 1,
        refillRate: const Duration(seconds: 10),
      );

      // First request should succeed
      final first = await limiter.tryConsume();
      expect(first, true);

      // Second request should fail (no tokens)
      final second = await limiter.tryConsume();
      expect(second, false);

      limiter.dispose();
    });

    test('should refill tokens over time', () async {
      final limiter = RateLimiter(
        maxTokens: 2,
        refillRate: const Duration(milliseconds: 100),
      );

      // Consume all tokens
      await limiter.tryConsume();
      await limiter.tryConsume();
      expect(limiter.hasTokens, false);

      // Wait for refill
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have tokens again
      expect(limiter.hasTokens, true);
      final allowed = await limiter.tryConsume();
      expect(allowed, true);

      limiter.dispose();
    });

    test('should not exceed maximum tokens', () async {
      final limiter = RateLimiter(
        maxTokens: 5,
        refillRate: const Duration(milliseconds: 50),
      );

      // Wait for multiple refills
      await Future.delayed(const Duration(milliseconds: 500));

      // Should still have max 5 tokens
      expect(limiter.availableTokens, lessThanOrEqualTo(5));

      limiter.dispose();
    });

    test('should handle multi-token consumption', () async {
      final limiter = RateLimiter(
        maxTokens: 10,
        refillRate: const Duration(seconds: 1),
      );

      // Consume 3 tokens
      final allowed = await limiter.tryConsume(tokens: 3);
      expect(allowed, true);
      expect(limiter.availableTokens, 7);

      // Try to consume 10 tokens (should fail)
      final denied = await limiter.tryConsume(tokens: 10);
      expect(denied, false);
      expect(limiter.availableTokens, 7); // Tokens unchanged

      limiter.dispose();
    });

    test('should wait and consume when using waitAndConsume', () async {
      final limiter = RateLimiter(
        maxTokens: 1,
        refillRate: const Duration(milliseconds: 100),
      );

      // Consume initial token
      await limiter.tryConsume();
      expect(limiter.hasTokens, false);

      // This should wait for refill
      final start = DateTime.now();
      await limiter.waitAndConsume();
      final elapsed = DateTime.now().difference(start);

      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(50));
      expect(limiter.availableTokens, 0); // Token was consumed

      limiter.dispose();
    });

    test('should implement exponential backoff', () async {
      final limiter = RateLimiter(
        maxTokens: 0, // No tokens available
        refillRate: const Duration(seconds: 10),
      );

      final start = DateTime.now();
      final success = await limiter.consumeWithBackoff(
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 100),
      );
      final elapsed = DateTime.now().difference(start);

      expect(success, false); // Should fail after 3 attempts
      // Should have waited: 100ms + 200ms + 400ms = ~700ms
      // Use lower threshold for timing variability
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(250));

      limiter.dispose();
    });

    test('should calculate fill percentage correctly', () async {
      final limiter = RateLimiter(
        maxTokens: 10,
        refillRate: const Duration(seconds: 1),
      );

      // Initially at 100%
      expect(limiter.fillPercentage, 1.0);

      // Consume 5 tokens
      for (int i = 0; i < 5; i++) {
        await limiter.tryConsume();
      }

      // Should be at 50%
      expect(limiter.fillPercentage, closeTo(0.5, 0.01));

      limiter.dispose();
    });

    test('should reset to max tokens', () async {
      final limiter = RateLimiter(
        maxTokens: 10,
        refillRate: const Duration(seconds: 1),
      );

      // Consume all tokens
      for (int i = 0; i < 10; i++) {
        await limiter.tryConsume();
      }
      expect(limiter.availableTokens, 0);

      // Reset
      limiter.reset();

      // Should have max tokens again
      expect(limiter.availableTokens, 10);
      expect(limiter.fillPercentage, 1.0);

      limiter.dispose();
    });

    test('should calculate time until refill', () async {
      final limiter = RateLimiter(
        maxTokens: 1,
        refillRate: const Duration(milliseconds: 100),
      );

      // Consume token
      await limiter.tryConsume();

      // Should have time until refill
      final timeUntilRefill = limiter.timeUntilRefill;
      expect(timeUntilRefill.inMilliseconds, greaterThan(0));
      expect(timeUntilRefill.inMilliseconds, lessThanOrEqualTo(100));

      limiter.dispose();
    });
  });

  group('RateLimitPresets', () {
    test('strict preset should have correct configuration', () {
      final limiter = RateLimitPresets.strict();
      expect(limiter.maxTokens, 5);
      expect(limiter.refillRate, const Duration(seconds: 10));
      limiter.dispose();
    });

    test('moderate preset should have correct configuration', () {
      final limiter = RateLimitPresets.moderate();
      expect(limiter.maxTokens, 10);
      expect(limiter.refillRate, const Duration(seconds: 1));
      limiter.dispose();
    });

    test('lenient preset should have correct configuration', () {
      final limiter = RateLimitPresets.lenient();
      expect(limiter.maxTokens, 30);
      expect(limiter.refillRate, const Duration(milliseconds: 500));
      limiter.dispose();
    });

    test('firebase optimized preset should have correct configuration', () {
      final limiter = RateLimitPresets.firebaseOptimized();
      expect(limiter.maxTokens, 20);
      expect(limiter.refillRate, const Duration(milliseconds: 500));
      limiter.dispose();
    });

    test('authentication preset should have correct configuration', () {
      final limiter = RateLimitPresets.authentication();
      expect(limiter.maxTokens, 3);
      expect(limiter.refillRate, const Duration(seconds: 30));
      limiter.dispose();
    });

    test('search preset should have correct configuration', () {
      final limiter = RateLimitPresets.search();
      expect(limiter.maxTokens, 50);
      expect(limiter.refillRate, const Duration(milliseconds: 200));
      limiter.dispose();
    });
  });

  group('RateLimiterManager', () {
    test('should register and use endpoint limiters', () async {
      final manager = RateLimiterManager();

      final loginLimiter = RateLimiter(
        maxTokens: 3,
        refillRate: const Duration(seconds: 1),
      );

      manager.registerEndpoint('login', loginLimiter);

      // Should allow 3 login attempts
      for (int i = 0; i < 3; i++) {
        final allowed = await manager.tryConsume('login');
        expect(allowed, true);
      }

      // 4th attempt should be denied
      final denied = await manager.tryConsume('login');
      expect(denied, false);

      manager.dispose();
    });

    test('should allow unknown endpoints by default', () async {
      final manager = RateLimiterManager();

      // Unknown endpoint should be allowed
      final allowed = await manager.tryConsume('unknown_endpoint');
      expect(allowed, true);

      manager.dispose();
    });

    test('should manage multiple endpoints independently', () async {
      final manager = RateLimiterManager();

      manager.registerEndpoint(
        'api1',
        RateLimiter(maxTokens: 5, refillRate: const Duration(seconds: 1)),
      );
      manager.registerEndpoint(
        'api2',
        RateLimiter(maxTokens: 10, refillRate: const Duration(seconds: 1)),
      );

      // Consume all tokens from api1
      for (int i = 0; i < 5; i++) {
        await manager.tryConsume('api1');
      }

      // api1 should be blocked
      expect(await manager.tryConsume('api1'), false);

      // api2 should still work
      expect(await manager.tryConsume('api2'), true);

      manager.dispose();
    });

    test('should get limiter for endpoint', () {
      final manager = RateLimiterManager();

      final limiter = RateLimiter(
        maxTokens: 10,
        refillRate: const Duration(seconds: 1),
      );

      manager.registerEndpoint('test', limiter);

      final retrieved = manager.getLimiter('test');
      expect(retrieved, isNotNull);
      expect(retrieved, same(limiter));

      manager.dispose();
    });

    test('should check if endpoint has tokens', () async {
      final manager = RateLimiterManager();

      manager.registerEndpoint(
        'test',
        RateLimiter(maxTokens: 1, refillRate: const Duration(seconds: 1)),
      );

      expect(manager.hasTokens('test'), true);

      await manager.tryConsume('test');

      expect(manager.hasTokens('test'), false);

      manager.dispose();
    });

    test('should get available tokens for endpoint', () async {
      final manager = RateLimiterManager();

      manager.registerEndpoint(
        'test',
        RateLimiter(maxTokens: 10, refillRate: const Duration(seconds: 1)),
      );

      expect(manager.availableTokens('test'), 10);

      await manager.tryConsume('test', tokens: 3);

      expect(manager.availableTokens('test'), 7);

      manager.dispose();
    });

    test('should reset all limiters', () async {
      final manager = RateLimiterManager();

      manager.registerEndpoint(
        'api1',
        RateLimiter(maxTokens: 5, refillRate: const Duration(seconds: 1)),
      );
      manager.registerEndpoint(
        'api2',
        RateLimiter(maxTokens: 10, refillRate: const Duration(seconds: 1)),
      );

      // Consume tokens
      await manager.tryConsume('api1', tokens: 5);
      await manager.tryConsume('api2', tokens: 10);

      expect(manager.hasTokens('api1'), false);
      expect(manager.hasTokens('api2'), false);

      // Reset all
      manager.resetAll();

      expect(manager.hasTokens('api1'), true);
      expect(manager.hasTokens('api2'), true);

      manager.dispose();
    });
  });
}
