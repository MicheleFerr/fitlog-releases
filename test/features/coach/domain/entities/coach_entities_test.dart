/// Coach domain entities tests - RelationshipStatus, CoachPermissions,
/// CoachRelationship, CoachBranding, AssignedTemplate, CoachTemplate.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_branding.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/assigned_template.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';

void main() {
  group('RelationshipStatus', () {
    test('has 4 values', () {
      expect(RelationshipStatus.values.length, 4);
    });

    test('value strings', () {
      expect(RelationshipStatus.pending.value, 'pending');
      expect(RelationshipStatus.active.value, 'active');
      expect(RelationshipStatus.paused.value, 'paused');
      expect(RelationshipStatus.ended.value, 'ended');
    });

    test('fromString parses all values', () {
      expect(RelationshipStatus.fromString('pending'), RelationshipStatus.pending);
      expect(RelationshipStatus.fromString('active'), RelationshipStatus.active);
      expect(RelationshipStatus.fromString('paused'), RelationshipStatus.paused);
      expect(RelationshipStatus.fromString('ended'), RelationshipStatus.ended);
    });

    test('fromString defaults to pending for null/unknown', () {
      expect(RelationshipStatus.fromString(null), RelationshipStatus.pending);
      expect(RelationshipStatus.fromString('unknown'), RelationshipStatus.pending);
    });
  });

  group('CoachPermissions', () {
    test('default values', () {
      const p = CoachPermissions();
      expect(p.canViewDashboard, isTrue);
      expect(p.canEditWorkout, isTrue);
      expect(p.canViewHealth, isFalse);
      expect(p.canViewMeasurements, isFalse);
    });

    test('defaultPermissions static', () {
      final p = CoachPermissions.defaultPermissions;
      expect(p.canViewDashboard, isTrue);
      expect(p.canEditWorkout, isTrue);
      expect(p.canViewHealth, isFalse);
    });

    test('fullPermissions static', () {
      final p = CoachPermissions.fullPermissions;
      expect(p.canViewDashboard, isTrue);
      expect(p.canEditWorkout, isTrue);
      expect(p.canViewHealth, isTrue);
      expect(p.canViewMeasurements, isTrue);
    });

    test('JSON round-trip', () {
      const p = CoachPermissions(
        canViewDashboard: true,
        canEditWorkout: false,
        canViewHealth: true,
        canViewMeasurements: false,
      );
      final json = p.toJson();
      final restored = CoachPermissions.fromJson(json);
      expect(restored, equals(p));
    });
  });

  group('CoachRelationship', () {
    test('computed properties', () {
      final r = CoachRelationship(
        id: 'r1',
        athleteId: 'a1',
        coachEmail: 'coach@test.com',
        status: RelationshipStatus.active,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(r.isActive, isTrue);
      expect(r.isPending, isFalse);
      expect(r.isEnded, isFalse);
    });

    test('isPending', () {
      final r = CoachRelationship(
        id: 'r2',
        athleteId: 'a2',
        coachEmail: 'coach@test.com',
        status: RelationshipStatus.pending,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(r.isPending, isTrue);
      expect(r.isActive, isFalse);
    });

    test('isEnded', () {
      final r = CoachRelationship(
        id: 'r3',
        athleteId: 'a3',
        coachEmail: 'coach@test.com',
        status: RelationshipStatus.ended,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(r.isEnded, isTrue);
    });

    test('generateId', () {
      expect(
        CoachRelationship.generateId('coach1', 'athlete1'),
        'coach1_athlete1',
      );
    });

    test('generateLegacyId', () {
      expect(
        CoachRelationship.generateLegacyId('coach@x.com', 'a@x.com'),
        'coach@x.com_a@x.com',
      );
    });
  });

  group('CoachBranding', () {
    test('default colors', () {
      expect(kDefaultPrimaryColor, '2196F3');
      expect(kDefaultAccentColor, 'FF9800');
    });

    test('hasLogo', () {
      final b = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        logoUrl: 'https://example.com/logo.png',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(b.hasLogo, isTrue);

      final noLogo = CoachBranding(
        id: '2',
        coachId: 'c1',
        businessName: 'Test',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(noLogo.hasLogo, isFalse);
    });

    test('hasContactInfo', () {
      final withEmail = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        email: 'coach@test.com',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(withEmail.hasContactInfo, isTrue);

      final noContact = CoachBranding(
        id: '2',
        coachId: 'c1',
        businessName: 'Test',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(noContact.hasContactInfo, isFalse);
    });

    test('hasSocialLinks', () {
      final withSocial = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        instagram: 'coachtest',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(withSocial.hasSocialLinks, isTrue);
    });

    test('contactLine', () {
      final b = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        email: 'a@b.com',
        phone: '123',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(b.contactLine, 'a@b.com | 123');
    });

    test('contactLine null when empty', () {
      final b = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(b.contactLine, isNull);
    });

    test('socialLine', () {
      final b = CoachBranding(
        id: '1',
        coachId: 'c1',
        businessName: 'Test',
        website: 'https://coach.com',
        instagram: 'coachtest',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(b.socialLine, 'https://coach.com | @coachtest');
    });

    test('defaultBranding', () {
      final d = CoachBranding.defaultBranding;
      expect(d.businessName, 'FitLog Pro');
      expect(d.coachId, 'system');
    });
  });

  group('AssignedTemplate', () {
    test('hasAthleteNotes', () {
      final withNotes = AssignedTemplate(
        id: '1',
        coachTemplateId: 'ct1',
        coachId: 'c1',
        assignedAt: DateTime(2025, 1, 1),
        lastSyncedAt: DateTime(2025, 1, 1),
        athleteNotes: 'Great workout!',
      );
      expect(withNotes.hasAthleteNotes, isTrue);

      final noNotes = AssignedTemplate(
        id: '2',
        coachTemplateId: 'ct1',
        coachId: 'c1',
        assignedAt: DateTime(2025, 1, 1),
        lastSyncedAt: DateTime(2025, 1, 1),
      );
      expect(noNotes.hasAthleteNotes, isFalse);
    });
  });

  group('CoachTemplate', () {
    test('assignedCount', () {
      final t = CoachTemplate(
        id: 't1',
        coachId: 'c1',
        name: 'Push Day',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        assignedTo: ['a1', 'a2', 'a3'],
      );
      expect(t.assignedCount, 3);
    });

    test('hasAssignments', () {
      final t = CoachTemplate(
        id: 't1',
        coachId: 'c1',
        name: 'Push Day',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        assignedTo: ['a1'],
      );
      expect(t.hasAssignments, isTrue);

      final empty = CoachTemplate(
        id: 't2',
        coachId: 'c1',
        name: 'Pull Day',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(empty.hasAssignments, isFalse);
    });

    test('isAssignedTo', () {
      final t = CoachTemplate(
        id: 't1',
        coachId: 'c1',
        name: 'Push Day',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        assignedTo: ['a1', 'a2'],
      );
      expect(t.isAssignedTo('a1'), isTrue);
      expect(t.isAssignedTo('a3'), isFalse);
    });
  });
}
