import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for initial deep link (set during cold-start from notifications).
/// This is overridden in main.dart ProviderScope.overrides.
///
/// Extracted from app.dart to avoid circular dependency with app_router.dart.
final initialDeepLinkProvider = Provider<String?>((ref) => null);
