/// 🔄 DEPRECATED: Use HiveBoxManagerEnhanced instead
///
/// This file re-exports HiveBoxManagerEnhanced for backward compatibility.
///
/// **Migration Guide**:
/// ```dart
/// // OLD (deprecated)
/// import 'package:gymbro_flutter_new/core/data/hive_box_manager.dart';
/// final manager = HiveBoxManager();
///
/// // NEW (recommended)
/// import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
/// final manager = HiveBoxManagerEnhanced();
/// ```
///
/// **Why HiveBoxManagerEnhanced?**
/// - Retry logic with exponential backoff
/// - Corruption recovery (deletes and recreates corrupted boxes)
/// - Thread-safe transactions with locks
/// - Batch operations (putAll, deleteAll)
/// - Custom exceptions (BoxOpenException, BoxCorruptedException)
/// - Testing utilities
///
/// @deprecated Use [HiveBoxManagerEnhanced] instead
library;

import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

// Re-export everything from enhanced version
export 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// @deprecated Use [HiveBoxManagerEnhanced] instead
///
/// This typedef exists for backward compatibility during migration.
/// All new code should use HiveBoxManagerEnhanced directly.
@Deprecated('Use HiveBoxManagerEnhanced instead - same API, better error handling')
typedef HiveBoxManager = HiveBoxManagerEnhanced;
