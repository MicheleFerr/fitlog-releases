import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Provides the singleton HiveBoxManagerEnhanced instance.
///
/// ✅ CRITICAL: This provider ensures proper Hive box lifecycle management
/// across the entire app:
/// - Single source of truth for all box opens
/// - Automatic cleanup on app termination
/// - Prevention of memory leaks from unclosed boxes
///
/// Usage in other providers:
/// ```dart
/// final myDataSourceProvider = Provider<MyDataSource>((ref) {
///   final boxManager = ref.watch(hiveBoxManagerProvider);
///   return MyDataSource(boxManager);
/// });
/// ```
///
/// Disposal:
/// When the app terminates or user logs out, all boxes are automatically
/// closed via ref.onDispose().
final hiveBoxManagerProvider = Provider<HiveBoxManagerEnhanced>((ref) {
  // FIX: keepAlive() previene disposal/ricreazione del manager Hive
  // che gestirebbe male la chiusura dei box aperti
  ref.keepAlive();

  final manager = HiveBoxManagerEnhanced();

  // ✅ CRITICAL: Close all boxes when provider is disposed
  // This happens on:
  // - App termination
  // - User logout (if ProviderScope is replaced)
  // - Hot reload in debug mode
  ref.onDispose(() async {
    if (kDebugMode) {
      debugPrint('🗑️ [HiveBoxManagerProvider] Disposing...');
    }

    await manager.closeAll();

    if (kDebugMode) {
      debugPrint('✅ [HiveBoxManagerProvider] All boxes closed');
    }
  });

  return manager;
});
