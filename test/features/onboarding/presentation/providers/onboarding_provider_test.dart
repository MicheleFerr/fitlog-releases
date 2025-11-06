import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Create temporary directory for test Hive storage
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(LegalConsentAdapter());
    Hive.registerAdapter(ConsentTypeAdapter());
  });

  tearDownAll(() async {
    // Clean up temporary directory
    await tempDir.delete(recursive: true);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('legal_consents');
  });

  group('OnboardingProvider', () {
    test('initial state should have all flags false', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = ConsentRepository();
      await repository.initialize();

      final notifier = OnboardingNotifier(repository);

      expect(notifier.state.disclaimerAccepted, false);
      expect(notifier.state.privacyPolicyAccepted, false);
      expect(notifier.state.tosAccepted, false);
      expect(notifier.state.ageVerified, false);
      expect(notifier.state.isOnboardingComplete, false);
    });

    test('checkOnboardingStatus should load existing consents', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      // Pre-save some consents
      await repository.saveConsent(LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      final notifier = OnboardingNotifier(repository);
      await notifier.checkOnboardingStatus();

      expect(notifier.state.disclaimerAccepted, true);
      expect(notifier.state.privacyPolicyAccepted, false);
    });

    test('acceptDisclaimer should save consent and update state', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      final notifier = OnboardingNotifier(repository);
      await notifier.acceptDisclaimer();

      expect(notifier.state.disclaimerAccepted, true);

      // Verify saved to repository
      final consent = await repository.getConsent(ConsentType.disclaimer);
      expect(consent, isNotNull);
      expect(consent!.accepted, true);
    });

    test('acceptPrivacyPolicy should save consent and update state', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      final notifier = OnboardingNotifier(repository);
      await notifier.acceptPrivacyPolicy();

      expect(notifier.state.privacyPolicyAccepted, true);

      final consent = await repository.getConsent(ConsentType.privacyPolicy);
      expect(consent!.accepted, true);
    });

    test('acceptTermsOfService should save consent and update state', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      final notifier = OnboardingNotifier(repository);
      await notifier.acceptTermsOfService();

      expect(notifier.state.tosAccepted, true);

      final consent = await repository.getConsent(ConsentType.tosAccepted);
      expect(consent!.accepted, true);
    });

    test('verifyAge should save consent with birthDate and update state', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      final birthDate = DateTime(2000, 1, 1);
      final notifier = OnboardingNotifier(repository);
      await notifier.verifyAge(birthDate);

      expect(notifier.state.ageVerified, true);
      expect(notifier.state.birthDate, birthDate);

      final consent = await repository.getConsent(ConsentType.ageVerified);
      expect(consent!.accepted, true);
    });

    test('isOnboardingComplete should be true when all required consents accepted', () async {
      final repository = ConsentRepository();
      await repository.initialize();

      final notifier = OnboardingNotifier(repository);

      expect(notifier.state.isOnboardingComplete, false);

      await notifier.acceptDisclaimer();
      expect(notifier.state.isOnboardingComplete, false); // Not yet

      await notifier.acceptPrivacyPolicy();
      expect(notifier.state.isOnboardingComplete, false); // Still not yet

      await notifier.acceptTermsOfService();
      expect(notifier.state.isOnboardingComplete, true); // NOW complete!
    });
  });
}
