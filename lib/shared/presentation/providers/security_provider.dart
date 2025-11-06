import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/security/device_security_checker.dart';
import 'package:gymbro_flutter_new/shared/domain/security/rate_limiter.dart';

/// Device Security Provider
///
/// Provides access to device security checker throughout the app
final deviceSecurityProvider = FutureProvider<DeviceSecurityChecker>((ref) async {
  final checker = DeviceSecurityChecker();
  await checker.initialize();
  return checker;
});

/// Rate Limiter Manager Provider
///
/// Provides configured rate limiters for different API endpoints
final rateLimiterManagerProvider = Provider<RateLimiterManager>((ref) {
  final manager = RateLimiterManager();

  // Register limiters for common endpoints
  manager.registerEndpoint('firestore_read', RateLimitPresets.firebaseOptimized());
  manager.registerEndpoint('firestore_write', RateLimitPresets.moderate());
  manager.registerEndpoint('firestore_delete', RateLimitPresets.moderate());
  manager.registerEndpoint('login', RateLimitPresets.authentication());
  manager.registerEndpoint('search', RateLimitPresets.search());
  manager.registerEndpoint('workout_query', RateLimitPresets.firebaseOptimized());

  // Dispose when provider is disposed
  ref.onDispose(() => manager.dispose());

  return manager;
});

/// Check if device is compromised
///
/// Returns true if device is jailbroken/rooted
final isDeviceCompromisedProvider = FutureProvider<bool>((ref) async {
  final security = await ref.watch(deviceSecurityProvider.future);
  return security.isDeviceCompromised;
});

/// Get device security level
///
/// Returns security level from 0-100 (higher = more secure)
final deviceSecurityLevelProvider = FutureProvider<int>((ref) async {
  final security = await ref.watch(deviceSecurityProvider.future);
  return security.securityLevel;
});

/// Get device security status
///
/// Returns human-readable security status
final deviceSecurityStatusProvider = FutureProvider<String>((ref) async {
  final security = await ref.watch(deviceSecurityProvider.future);
  return security.securityStatus;
});

/// Get security recommendations
///
/// Returns list of security recommendations for user
final securityRecommendationsProvider = FutureProvider<List<String>>((ref) async {
  final security = await ref.watch(deviceSecurityProvider.future);
  return security.securityRecommendations;
});
