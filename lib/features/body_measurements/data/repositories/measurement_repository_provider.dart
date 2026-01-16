import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_impl.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/providers/measurement_local_datasource_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/providers/encryption_key_manager_provider.dart';

/// Provider for MeasurementRepository
///
/// Provides singleton instance of MeasurementRepositoryImpl with dependencies.
///
/// **Features**:
/// - Measurement storage and retrieval (Firestore + Hive)
/// - End-to-end encryption (AES-256-GCM)
/// - Consent enforcement (only saves consented metrics)
/// - Offline-first architecture (local cache, background sync)
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class MeasurementInputScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final measurementRepo = ref.read(measurementRepositoryProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         final measurement = Measurement(
///           id: uuid.v4(),
///           userId: currentUser.uid,
///           metricType: MetricType.weight,
///           value: 75.5,
///           unit: 'kg',
///           timestamp: DateTime.now(),
///           source: MeasurementSource.manual,
///         );
///
///         final result = await measurementRepo.saveMeasurement(measurement);
///
///         result.fold(
///           (failure) => showError(failure.message),
///           (_) => showSuccess('Measurement saved successfully'),
///         );
///       },
///       child: Text('Save Measurement'),
///     );
///   }
/// }
/// ```
///
/// **Note**: Constructor matches MeasurementRepositoryImpl signature:
/// `MeasurementRepositoryImpl({required FirebaseFirestore, required ConsentRepository,
///   required MeasurementLocalDatasource, required EncryptionKeyManager, Uuid? uuid})`
final measurementRepositoryProvider = Provider<MeasurementRepositoryImpl>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione repository con Firestore+Hive
  return MeasurementRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    consentRepo: ref.read(consentRepositoryProvider),
    localDatasource: ref.read(measurementLocalDatasourceProvider),
    keyManager: ref.read(encryptionKeyManagerProvider),
    // uuid parameter is optional, uses default Uuid() if not provided
  );
});
