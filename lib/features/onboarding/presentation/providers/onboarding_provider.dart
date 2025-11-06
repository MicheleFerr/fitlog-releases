import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';

/// State for onboarding flow tracking all user consents.
///
/// GDPR Art. 7 compliance: All consent timestamps tracked in ConsentRepository.
class OnboardingState {
  const OnboardingState({
    this.disclaimerAccepted = false,
    this.privacyPolicyAccepted = false,
    this.tosAccepted = false,
    this.ageVerified = false,
    this.birthDate,
    this.isLoading = false,
    this.errorMessage,
    this.isOnboardingComplete = false,
  });

  final bool disclaimerAccepted;
  final bool privacyPolicyAccepted;
  final bool tosAccepted;
  final bool ageVerified;
  final DateTime? birthDate;
  final bool isLoading;
  final String? errorMessage;
  final bool isOnboardingComplete;

  OnboardingState copyWith({
    bool? disclaimerAccepted,
    bool? privacyPolicyAccepted,
    bool? tosAccepted,
    bool? ageVerified,
    DateTime? birthDate,
    bool? isLoading,
    String? errorMessage,
    bool? isOnboardingComplete,
  }) {
    return OnboardingState(
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      privacyPolicyAccepted:
          privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      tosAccepted: tosAccepted ?? this.tosAccepted,
      ageVerified: ageVerified ?? this.ageVerified,
      birthDate: birthDate ?? this.birthDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          disclaimerAccepted == other.disclaimerAccepted &&
          privacyPolicyAccepted == other.privacyPolicyAccepted &&
          tosAccepted == other.tosAccepted &&
          ageVerified == other.ageVerified &&
          birthDate == other.birthDate &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          isOnboardingComplete == other.isOnboardingComplete;

  @override
  int get hashCode =>
      disclaimerAccepted.hashCode ^
      privacyPolicyAccepted.hashCode ^
      tosAccepted.hashCode ^
      ageVerified.hashCode ^
      birthDate.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      isOnboardingComplete.hashCode;
}

/// Manages onboarding flow state and integrates with ConsentRepository.
///
/// Usage in onboarding screens:
/// ```dart
/// final onboardingState = ref.watch(onboardingProvider);
/// if (onboardingState.isOnboardingComplete) {
///   // Navigate to main app
/// }
/// ```
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._repository) : super(const OnboardingState());

  final ConsentRepository _repository;

  /// Check onboarding status on app start.
  ///
  /// Loads all existing consents from repository and updates state.
  Future<void> checkOnboardingStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final disclaimerConsent =
          await _repository.getConsent(ConsentType.disclaimer);
      final privacyConsent =
          await _repository.getConsent(ConsentType.privacyPolicy);
      final tosConsent = await _repository.getConsent(ConsentType.tosAccepted);
      final ageConsent = await _repository.getConsent(ConsentType.ageVerified);

      state = state.copyWith(
        disclaimerAccepted: disclaimerConsent?.accepted ?? false,
        privacyPolicyAccepted: privacyConsent?.accepted ?? false,
        tosAccepted: tosConsent?.accepted ?? false,
        ageVerified: ageConsent?.accepted ?? false,
        isLoading: false,
      );

      _checkCompletion();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Accept medical disclaimer (shown in LegalDisclaimerModal).
  Future<void> acceptDisclaimer() async {
    try {
      await _repository.saveConsent(LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      state = state.copyWith(disclaimerAccepted: true);
      _checkCompletion();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Accept privacy policy (GDPR Art. 13).
  Future<void> acceptPrivacyPolicy() async {
    try {
      await _repository.saveConsent(LegalConsent(
        type: ConsentType.privacyPolicy,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      state = state.copyWith(privacyPolicyAccepted: true);
      _checkCompletion();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Accept terms of service (liability protection).
  Future<void> acceptTermsOfService() async {
    try {
      await _repository.saveConsent(LegalConsent(
        type: ConsentType.tosAccepted,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      state = state.copyWith(tosAccepted: true);
      _checkCompletion();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Verify user age (GDPR Art. 8 - minors protection).
  ///
  /// [birthDate] must be validated BEFORE calling (age gate screen responsibility).
  Future<void> verifyAge(DateTime birthDate) async {
    try {
      await _repository.saveConsent(LegalConsent(
        type: ConsentType.ageVerified,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      state = state.copyWith(
        ageVerified: true,
        birthDate: birthDate,
      );
      _checkCompletion();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Internal: Check if all required consents are accepted.
  ///
  /// Required for onboarding completion:
  /// - Disclaimer
  /// - Privacy Policy
  /// - Terms of Service
  ///
  /// Note: ageVerified is NOT required here (checked separately in onboarding flow).
  void _checkCompletion() {
    final isComplete = state.disclaimerAccepted &&
        state.privacyPolicyAccepted &&
        state.tosAccepted;

    state = state.copyWith(isOnboardingComplete: isComplete);
  }
}

/// Provider for onboarding flow state management.
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final repository = ref.watch(consentRepositoryProvider);
  return OnboardingNotifier(repository);
});

/// Provider for consent repository (singleton).
final consentRepositoryProvider = Provider<ConsentRepository>((ref) {
  return ConsentRepository();
});
