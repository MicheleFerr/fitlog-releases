/// Extended CoachRelationship tests - covering fromFirestore, toFirestore,
/// fromJson/toJson, legacy format parsing, and edge cases not covered by
/// coach_entities_test.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ---------------------------------------------------------------------------
  // CoachPermissions - JSON round-trip and edge cases
  // ---------------------------------------------------------------------------
  group('CoachPermissions JSON', () {
    test('fromJson uses defaults for missing fields', () {
      final permissions = CoachPermissions.fromJson({});
      expect(permissions.canViewDashboard, isTrue);
      expect(permissions.canEditWorkout, isTrue);
      expect(permissions.canViewHealth, isFalse);
      expect(permissions.canViewMeasurements, isFalse);
    });

    test('fromJson parses explicit values', () {
      final permissions = CoachPermissions.fromJson({
        'canViewDashboard': false,
        'canEditWorkout': false,
        'canViewHealth': true,
        'canViewMeasurements': true,
      });
      expect(permissions.canViewDashboard, isFalse);
      expect(permissions.canEditWorkout, isFalse);
      expect(permissions.canViewHealth, isTrue);
      expect(permissions.canViewMeasurements, isTrue);
    });

    test('toJson includes all fields', () {
      const permissions = CoachPermissions(
        canViewDashboard: true,
        canEditWorkout: false,
        canViewHealth: true,
        canViewMeasurements: false,
      );

      final json = permissions.toJson();

      expect(json['canViewDashboard'], true);
      expect(json['canEditWorkout'], false);
      expect(json['canViewHealth'], true);
      expect(json['canViewMeasurements'], false);
    });

    test('copyWith updates individual permissions', () {
      const original = CoachPermissions();
      final updated = original.copyWith(canViewHealth: true);

      expect(updated.canViewHealth, isTrue);
      expect(updated.canViewDashboard, isTrue); // unchanged
      expect(updated.canViewMeasurements, isFalse); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // CoachRelationship fromJson / toJson
  // ---------------------------------------------------------------------------
  group('CoachRelationship fromJson / toJson', () {
    test('round-trip with minimal required fields', () {
      final original = CoachRelationship(
        id: 'rel-1',
        athleteId: 'athlete-1',
        coachEmail: 'coach@example.com',
        createdAt: DateTime(2025, 1, 1),
      );

      final json = original.toJson();
      final restored = CoachRelationship.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.athleteId, original.athleteId);
      expect(restored.coachEmail, original.coachEmail);
      expect(restored.status, RelationshipStatus.pending);
      expect(restored.athleteHasApp, isTrue);
    });

    test('round-trip with all fields', () {
      final original = CoachRelationship(
        id: 'rel-2',
        athleteId: 'athlete-2',
        athleteEmail: 'athlete@example.com',
        athleteName: 'John Doe',
        coachId: 'coach-2',
        coachEmail: 'coach@example.com',
        coachName: 'Coach Sarah',
        status: RelationshipStatus.active,
        athleteHasApp: true,
        permissions: const CoachPermissions(
          canViewDashboard: true,
          canEditWorkout: true,
          canViewHealth: true,
          canViewMeasurements: true,
        ),
        createdAt: DateTime(2025, 1, 1),
        connectedAt: DateTime(2025, 1, 5),
        endedAt: null,
        coachNotes: 'Focus on legs this week',
      );

      final json = original.toJson();
      final restored = CoachRelationship.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.athleteId, original.athleteId);
      expect(restored.athleteEmail, original.athleteEmail);
      expect(restored.athleteName, original.athleteName);
      expect(restored.coachId, original.coachId);
      expect(restored.coachEmail, original.coachEmail);
      expect(restored.coachName, original.coachName);
      expect(restored.status, RelationshipStatus.active);
      expect(restored.permissions.canViewHealth, isTrue);
      expect(restored.coachNotes, 'Focus on legs this week');
    });
  });

  // ---------------------------------------------------------------------------
  // CoachRelationship toFirestore
  // ---------------------------------------------------------------------------
  group('CoachRelationship toFirestore', () {
    test('basic relationship contains required keys', () {
      final rel = CoachRelationship(
        id: 'rel-1',
        athleteId: 'athlete-1',
        coachEmail: 'coach@example.com',
        status: RelationshipStatus.pending,
        createdAt: DateTime(2025, 1, 1),
      );

      final data = rel.toFirestore();

      // Both legacy and new fields
      expect(data['userId'], 'athlete-1'); // legacy
      expect(data['athleteId'], 'athlete-1'); // new
      expect(data['coachEmail'], 'coach@example.com');
      expect(data['status'], 'pending');
      expect(data['athleteHasApp'], isTrue);
      expect(data['permissions'], isNotNull);
      expect(data['createdAt'], isA<Timestamp>());
      // Optional fields not set
      expect(data.containsKey('connectedAt'), isFalse);
      expect(data.containsKey('endedAt'), isFalse);
      expect(data.containsKey('coachNotes'), isFalse);
    });

    test('active relationship with all fields', () {
      final rel = CoachRelationship(
        id: 'rel-2',
        athleteId: 'athlete-2',
        athleteEmail: 'athlete@example.com',
        athleteName: 'John',
        coachId: 'coach-2',
        coachEmail: 'coach@example.com',
        coachName: 'Coach Sarah',
        status: RelationshipStatus.active,
        permissions: CoachPermissions.fullPermissions,
        createdAt: DateTime(2025, 1, 1),
        connectedAt: DateTime(2025, 1, 5),
        coachNotes: 'Great progress!',
      );

      final data = rel.toFirestore();

      expect(data['athleteId'], 'athlete-2');
      expect(data['athleteEmail'], 'athlete@example.com');
      expect(data['athleteName'], 'John');
      expect(data['coachId'], 'coach-2');
      expect(data['coachName'], 'Coach Sarah');
      expect(data['status'], 'active');
      expect(data['connectedAt'], isA<Timestamp>());
      expect(data['coachNotes'], 'Great progress!');
      expect(data.containsKey('endedAt'), isFalse); // endedAt is null
    });

    test('ended relationship includes endedAt', () {
      final rel = CoachRelationship(
        id: 'rel-3',
        athleteId: 'athlete-3',
        coachEmail: 'coach@example.com',
        status: RelationshipStatus.ended,
        createdAt: DateTime(2025, 1, 1),
        connectedAt: DateTime(2025, 1, 5),
        endedAt: DateTime(2025, 6, 1),
      );

      final data = rel.toFirestore();

      expect(data['status'], 'ended');
      expect(data['endedAt'], isA<Timestamp>());
    });

    test('permissions are serialized as nested map', () {
      final rel = CoachRelationship(
        id: 'rel-4',
        athleteId: 'athlete-4',
        coachEmail: 'coach@example.com',
        permissions: const CoachPermissions(
          canViewDashboard: true,
          canEditWorkout: true,
          canViewHealth: true,
          canViewMeasurements: false,
        ),
        createdAt: DateTime(2025, 1, 1),
      );

      final data = rel.toFirestore();
      final permissions = data['permissions'] as Map<String, dynamic>;

      expect(permissions['canViewDashboard'], true);
      expect(permissions['canEditWorkout'], true);
      expect(permissions['canViewHealth'], true);
      expect(permissions['canViewMeasurements'], false);
    });
  });

  // ---------------------------------------------------------------------------
  // CoachRelationship fromFirestore
  // ---------------------------------------------------------------------------
  group('CoachRelationship fromFirestore', () {
    test('parses full active relationship from Firestore', () async {
      final createdAt = DateTime(2025, 1, 1);
      final connectedAt = DateTime(2025, 1, 5);

      final ref = fakeFirestore.collection('coach_delegations').doc('rel-1');
      await ref.set({
        'athleteId': 'athlete-abc',
        'athleteEmail': 'athlete@example.com',
        'athleteName': 'Mike Jones',
        'coachId': 'coach-xyz',
        'coachEmail': 'coach@example.com',
        'coachName': 'Coach Sarah',
        'status': 'active',
        'athleteHasApp': true,
        'permissions': {
          'canViewDashboard': true,
          'canEditWorkout': true,
          'canViewHealth': true,
          'canViewMeasurements': false,
        },
        'createdAt': Timestamp.fromDate(createdAt),
        'connectedAt': Timestamp.fromDate(connectedAt),
        'coachNotes': 'Excellent athlete',
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.id, 'rel-1');
      expect(rel.athleteId, 'athlete-abc');
      expect(rel.athleteEmail, 'athlete@example.com');
      expect(rel.athleteName, 'Mike Jones');
      expect(rel.coachId, 'coach-xyz');
      expect(rel.coachEmail, 'coach@example.com');
      expect(rel.coachName, 'Coach Sarah');
      expect(rel.status, RelationshipStatus.active);
      expect(rel.athleteHasApp, isTrue);
      expect(rel.permissions.canViewHealth, isTrue);
      expect(rel.permissions.canViewMeasurements, isFalse);
      expect(rel.connectedAt, isNotNull);
      expect(rel.coachNotes, 'Excellent athlete');
      expect(rel.isActive, isTrue);
    });

    test('parses legacy format with userId field instead of athleteId', () async {
      final ref = fakeFirestore.collection('coach_delegations').doc('rel-2');
      await ref.set({
        'userId': 'legacy-athlete-id', // legacy field
        'coachEmail': 'coach@example.com',
        'status': 'pending',
        'athleteHasApp': true,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.athleteId, 'legacy-athlete-id');
    });

    test('parses legacy flat permissions format', () async {
      final ref = fakeFirestore.collection('coach_delegations').doc('rel-3');
      await ref.set({
        'athleteId': 'athlete-1',
        'coachEmail': 'coach@example.com',
        'status': 'active',
        // Legacy flat format (no nested permissions map)
        'canViewDashboard': true,
        'canEditWorkout': false,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.permissions.canViewDashboard, isTrue);
      expect(rel.permissions.canEditWorkout, isFalse);
    });

    test('parses ended relationship with endedAt', () async {
      final ref = fakeFirestore.collection('coach_delegations').doc('rel-4');
      await ref.set({
        'athleteId': 'athlete-1',
        'coachEmail': 'coach@example.com',
        'status': 'ended',
        'athleteHasApp': false,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'connectedAt': Timestamp.fromDate(DateTime(2025, 1, 5)),
        'endedAt': Timestamp.fromDate(DateTime(2025, 6, 1)),
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.status, RelationshipStatus.ended);
      expect(rel.isEnded, isTrue);
      expect(rel.endedAt, isNotNull);
      expect(rel.athleteHasApp, isFalse);
    });

    test('handles minimal document with defaults', () async {
      final ref = fakeFirestore.collection('coach_delegations').doc('rel-5');
      await ref.set({
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.athleteId, '');
      expect(rel.coachEmail, '');
      expect(rel.status, RelationshipStatus.pending);
      expect(rel.isPending, isTrue);
      expect(rel.athleteHasApp, isTrue);
    });

    test('handles unknown status string as pending', () async {
      final ref = fakeFirestore.collection('coach_delegations').doc('rel-6');
      await ref.set({
        'athleteId': 'athlete-1',
        'coachEmail': 'coach@example.com',
        'status': 'unknown_future_status',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final snap = await ref.get();
      final rel = CoachRelationship.fromFirestore(snap);

      expect(rel.status, RelationshipStatus.pending);
    });
  });

  // ---------------------------------------------------------------------------
  // CoachRelationship copyWith
  // ---------------------------------------------------------------------------
  group('CoachRelationship copyWith', () {
    test('updates status field', () {
      final original = CoachRelationship(
        id: 'rel-1',
        athleteId: 'athlete-1',
        coachEmail: 'coach@example.com',
        status: RelationshipStatus.pending,
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = original.copyWith(
        status: RelationshipStatus.active,
        connectedAt: DateTime(2025, 1, 5),
      );

      expect(updated.status, RelationshipStatus.active);
      expect(updated.isActive, isTrue);
      expect(updated.connectedAt, isNotNull);
      expect(updated.athleteId, 'athlete-1'); // unchanged
    });

    test('updates permissions', () {
      final original = CoachRelationship(
        id: 'rel-1',
        athleteId: 'athlete-1',
        coachEmail: 'coach@example.com',
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = original.copyWith(
        permissions: CoachPermissions.fullPermissions,
      );

      expect(updated.permissions.canViewHealth, isTrue);
      expect(updated.permissions.canViewMeasurements, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // RelationshipStatus.fromString additional cases
  // ---------------------------------------------------------------------------
  group('RelationshipStatus.fromString', () {
    test('parses paused status', () {
      expect(
        RelationshipStatus.fromString('paused'),
        RelationshipStatus.paused,
      );
    });

    test('empty string defaults to pending', () {
      expect(
        RelationshipStatus.fromString(''),
        RelationshipStatus.pending,
      );
    });
  });
}
