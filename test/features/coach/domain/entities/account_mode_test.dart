/// AccountMode entity tests - enum values, fromString, computed properties,
/// AccountModePreferences extension.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/account_mode.dart';

void main() {
  group('AccountMode', () {
    test('has 3 values', () {
      expect(AccountMode.values.length, 3);
    });

    test('value strings', () {
      expect(AccountMode.solo.value, 'solo');
      expect(AccountMode.coached.value, 'coached');
      expect(AccountMode.coach.value, 'coach');
    });

    test('fromString parses all values', () {
      expect(AccountMode.fromString('solo'), AccountMode.solo);
      expect(AccountMode.fromString('coached'), AccountMode.coached);
      expect(AccountMode.fromString('coach'), AccountMode.coach);
    });

    test('fromString defaults to solo for null', () {
      expect(AccountMode.fromString(null), AccountMode.solo);
    });

    test('fromString defaults to solo for unknown', () {
      expect(AccountMode.fromString('unknown'), AccountMode.solo);
      expect(AccountMode.fromString(''), AccountMode.solo);
    });

    test('canCreateTemplates', () {
      expect(AccountMode.solo.canCreateTemplates, isTrue);
      expect(AccountMode.coach.canCreateTemplates, isTrue);
      expect(AccountMode.coached.canCreateTemplates, isFalse);
    });

    test('isCoach', () {
      expect(AccountMode.coach.isCoach, isTrue);
      expect(AccountMode.solo.isCoach, isFalse);
      expect(AccountMode.coached.isCoach, isFalse);
    });

    test('isCoached', () {
      expect(AccountMode.coached.isCoached, isTrue);
      expect(AccountMode.solo.isCoached, isFalse);
      expect(AccountMode.coach.isCoached, isFalse);
    });

    test('isSolo', () {
      expect(AccountMode.solo.isSolo, isTrue);
      expect(AccountMode.coached.isSolo, isFalse);
      expect(AccountMode.coach.isSolo, isFalse);
    });

    test('displayKey unique for each mode', () {
      final keys = AccountMode.values.map((m) => m.displayKey).toSet();
      expect(keys.length, 3);
    });
  });

  group('AccountModePreferences', () {
    test('accountMode from map', () {
      final map = <String, dynamic>{'accountMode': 'coach'};
      expect(map.accountMode, AccountMode.coach);
    });

    test('accountMode defaults to solo when missing', () {
      final map = <String, dynamic>{};
      expect(map.accountMode, AccountMode.solo);
    });

    test('coachCode', () {
      final map = <String, dynamic>{'coachCode': 'ABC123'};
      expect(map.coachCode, 'ABC123');
    });

    test('coachCode null when missing', () {
      final map = <String, dynamic>{};
      expect(map.coachCode, isNull);
    });

    test('linkedCoachId', () {
      final map = <String, dynamic>{'linkedCoachId': 'uid123'};
      expect(map.linkedCoachId, 'uid123');
    });

    test('linkedCoachEmail', () {
      final map = <String, dynamic>{'linkedCoachEmail': 'coach@test.com'};
      expect(map.linkedCoachEmail, 'coach@test.com');
    });

    test('hasCompletedCoachOnboarding defaults to false', () {
      final map = <String, dynamic>{};
      expect(map.hasCompletedCoachOnboarding, isFalse);
    });

    test('hasCompletedCoachOnboarding when true', () {
      final map = <String, dynamic>{'hasCompletedCoachOnboarding': true};
      expect(map.hasCompletedCoachOnboarding, isTrue);
    });
  });
}
