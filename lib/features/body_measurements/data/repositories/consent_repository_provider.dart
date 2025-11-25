import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_impl.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_provider.dart';

/// Provider for ConsentRepository
///
/// Provides singleton instance of ConsentRepositoryImpl with dependencies.
///
/// **GDPR CRITICAL**: Article 7 - Conditions for Consent
///
/// **Features**:
/// - Consent storage and retrieval (Firestore + Hive)
/// - Consent version tracking
/// - Consent revocation
/// - Audit logging of consent changes
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class ConsentButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final consentRepo = ref.read(consentRepositoryProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         final consent = UserConsent(
///           id: uuid.v4(),
///           userId: currentUser.uid,
///           groupConsents: {
///             MetricGroup.essential: ConsentState.granted,
///           },
///           consentVersion: 1,
///           acceptedAt: DateTime.now(),
///           ipAddress: await getIpAddress(),
///         );
///
///         final result = await consentRepo.saveConsent(consent);
///
///         result.fold(
///           (failure) => showError(failure.message),
///           (_) => showSuccess('Consent saved successfully'),
///         );
///       },
///       child: Text('Grant Consent'),
///     );
///   }
/// }
/// ```
final consentRepositoryProvider = Provider<ConsentRepositoryImpl>((ref) {
  return ConsentRepositoryImpl(
    auditLogger: ref.read(auditLoggerProvider),
  );
});
