/// Example usage of BaseHiveTypeAdapterDatasource
///
/// This file demonstrates how to create a datasource using the TypeAdapter pattern.
/// DO NOT USE THIS FILE IN PRODUCTION - it's for reference only.
library;

import 'package:gymbro_flutter_new/core/data/datasources/base_hive_type_adapter_datasource.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';

/// Example datasource for ExerciseUsageModel
///
/// This demonstrates the minimal implementation required:
/// 1. Extend BaseHiveTypeAdapterDatasource<YourModel>
/// 2. Pass boxName to super constructor
/// 3. Implement getKey() to extract the unique key
class ExerciseUsageDatasource
    extends BaseHiveTypeAdapterDatasource<ExerciseUsageModel> {
  ExerciseUsageDatasource() : super(boxName: 'exercise_usage');

  @override
  String getKey(ExerciseUsageModel item) => item.exerciseId;

  // Optional: implement isActive() for soft-delete filtering
  @override
  bool isActive(ExerciseUsageModel item) {
    // Example: filter out items with zero usage count
    return item.usageCount > 0;
  }
}

/// Usage example:
///
/// ```dart
/// // 1. Initialize datasource
/// final datasource = ExerciseUsageDatasource();
/// await datasource.initialize();
///
/// // 2. Save item
/// final usage = ExerciseUsageModel.firstUse(
///   exerciseId: 'bench_press',
///   exerciseName: 'Bench Press',
///   userId: 'user123',
/// );
/// await datasource.save(usage);
///
/// // 3. Get item
/// final result = await datasource.get('bench_press');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (item) => print('Found: ${item?.exerciseName}'),
/// );
///
/// // 4. Get all items with filter
/// final allResult = await datasource.getAll(
///   filter: (item) => item.usageCount > 5,
/// );
/// allResult.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (items) => print('Found ${items.length} frequently used exercises'),
/// );
///
/// // 5. Delete items matching condition
/// final deleteResult = await datasource.deleteWhere(
///   (item) => item.usageCount == 0,
/// );
/// deleteResult.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (count) => print('Deleted $count unused items'),
/// );
///
/// // 6. Clean up
/// await datasource.close();
/// ```
///
/// ## Key Differences from BaseHiveLocalDatasource
///
/// ### TypeAdapter (this class)
/// - Works with `Box<T>` where T extends HiveObject
/// - No need for toJson/fromJson methods
/// - Model uses @HiveType and @HiveField annotations
/// - Hive handles serialization automatically
/// - Items can call .save() directly on themselves
///
/// ### Map-based (BaseHiveLocalDatasource)
/// - Works with `Box<Map<String, dynamic>>`
/// - Requires toJson/fromJson implementations
/// - More flexible for non-Hive models
/// - Manual serialization control
///
/// Choose TypeAdapter when:
/// - You control the model definition
/// - Model is simple/flat structure
/// - You want auto-save capability
/// - You prefer type safety
///
/// Choose Map-based when:
/// - Working with external models
/// - Complex nested structures
/// - Need full serialization control
/// - Model shouldn't depend on Hive
