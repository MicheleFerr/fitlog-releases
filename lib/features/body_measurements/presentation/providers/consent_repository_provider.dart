import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_impl.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';

/// Provider for ConsentRepository
///
/// Provides singleton instance of ConsentRepositoryImpl with Firebase Firestore.
///
/// **Dependency Injection Pattern**:
/// - Domain layer depends on ConsentRepository interface
/// - Data layer provides ConsentRepositoryImpl implementation
/// - Riverpod manages singleton lifecycle
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class ConsentScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final consentRepo = ref.read(consentRepositoryProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         final result = await consentRepo.grantConsent(
///           userId: 'user-123',
///           group: MetricGroup.essential,
///           ipAddress: '192.168.1.100',
///         );
///
///         result.fold(
///           (failure) => showError(failure),
///           (consent) => showSuccess('Consent granted!'),
///         );
///       },
///       child: Text('Grant Consent'),
///     );
///   }
/// }
/// ```
final consentRepositoryProvider = Provider<ConsentRepository>((ref) {
  return ConsentRepositoryImpl(FirebaseFirestore.instance);
});
