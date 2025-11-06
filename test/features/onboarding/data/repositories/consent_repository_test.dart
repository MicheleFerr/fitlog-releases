import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';

void main() {
  late ConsentRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    // Create temporary directory for test Hive storage
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ConsentTypeAdapter());
    Hive.registerAdapter(LegalConsentAdapter());
  });

  tearDownAll(() async {
    // Clean up temporary directory
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk('legal_consents');
    repository = ConsentRepository();
    await repository.initialize();
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('ConsentRepository', () {
    test('saves disclaimer consent with timestamp', () async {
      final consent = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
        ipAddress: '192.168.1.1',
      );

      await repository.saveConsent(consent);

      final retrieved = await repository.getConsent(ConsentType.disclaimer);
      expect(retrieved, isNotNull);
      expect(retrieved!.accepted, true);
      expect(retrieved.type, ConsentType.disclaimer);
    });

    test('returns null if consent not found', () async {
      final retrieved = await repository.getConsent(ConsentType.tosAccepted);
      expect(retrieved, null);
    });

    test('updates existing consent', () async {
      final consent1 = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      );

      await repository.saveConsent(consent1);

      final consent2 = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: false,
        timestamp: DateTime.now().add(const Duration(hours: 1)),
      );

      await repository.saveConsent(consent2);

      final retrieved = await repository.getConsent(ConsentType.disclaimer);
      expect(retrieved!.accepted, false);
    });

    test('checks if user has accepted all required consents', () async {
      expect(await repository.hasAcceptedAllRequired(), false);

      await repository.saveConsent(LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.privacyPolicy,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.tosAccepted,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      expect(await repository.hasAcceptedAllRequired(), true);
    });
  });
}
