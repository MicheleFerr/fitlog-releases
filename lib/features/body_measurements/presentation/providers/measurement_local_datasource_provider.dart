import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/hive_measurement_datasource.dart';

/// Provider for MeasurementLocalDatasource
///
/// Provides singleton instance of HiveMeasurementDatasource.
///
/// **Lifecycle**:
/// - Initialized once on app startup (via app initialization)
/// - Closed on app shutdown (via app dispose)
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class MeasurementListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final datasource = ref.read(measurementLocalDatasourceProvider);
///
///     return FutureBuilder(
///       future: datasource.getAllMeasurements('user-123'),
///       builder: (context, snapshot) {
///         if (snapshot.hasData) {
///           final result = snapshot.data!;
///           return result.fold(
///             (failure) => ErrorWidget('Failed to load'),
///             (measurements) => ListView.builder(
///               itemCount: measurements.length,
///               itemBuilder: (context, index) {
///                 return MeasurementCard(measurements[index]);
///               },
///             ),
///           );
///         }
///         return LoadingIndicator();
///       },
///     );
///   }
/// }
/// ```
final measurementLocalDatasourceProvider =
    Provider<MeasurementLocalDatasource>((ref) {
  return HiveMeasurementDatasource();
});
