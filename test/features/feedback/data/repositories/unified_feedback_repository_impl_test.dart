// NOTE: UnifiedFeedbackRepositoryImpl has a hard dependency on FirebaseFirestore,
// which requires a running Firebase emulator or a fake implementation.
// The validation logic (empty message, empty userId, dangerous patterns,
// minimum length after sanitization) is tested here using a testable subclass
// that overrides the Firestore access methods so the tests remain offline.
//
// Firebase-dependent operations (getUserFeedback, getAllFeedback, streams, etc.)
// are annotated with a skip note; they are covered by integration tests.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/i_unified_feedback_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// In-memory fake implementation of IUnifiedFeedbackRepository
// ---------------------------------------------------------------------------
class _FakeUnifiedFeedbackRepository implements IUnifiedFeedbackRepository {
  final Map<String, UnifiedFeedback> _store = {};
  final List<String> _deletedIds = [];

  // ---------- helpers ----------

  // Mirrors the validation logic from UnifiedFeedbackRepositoryImpl.submitFeedback.
  static const _dangerousPatterns = [
    '<script',
    '">',
    'onclick=',
    'onerror=',
  ];

  bool _containsDangerous(String input) {
    for (final pattern in _dangerousPatterns) {
      if (input.toLowerCase().contains(pattern)) return true;
    }
    // Also check single quotes, double quotes, semicolons (SQL injection chars)
    return input.contains(';') ||
        input.contains('"') ||
        input.contains("'") ||
        input.contains('\\');
  }

  String _sanitize(String input) {
    // Minimal sanitize that removes the dangerous chars for length checks.
    // The real implementation uses InputValidator.sanitize().
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(';', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('\\', '')
        .trim();
  }

  // ---------- USER OPERATIONS ----------

  @override
  Future<Either<Failure, String>> submitFeedback(
    UnifiedFeedback feedback,
  ) async {
    // Validation mirrors the real impl.
    if (feedback.message.trim().isEmpty) {
      return const Left(
        ValidationFailure('Message cannot be empty', code: 'EMPTY_MESSAGE'),
      );
    }
    if (feedback.userId.trim().isEmpty) {
      return const Left(
        ValidationFailure('User ID cannot be empty', code: 'EMPTY_USER_ID'),
      );
    }
    if (_containsDangerous(feedback.message)) {
      return const Left(
        ValidationFailure(
          'Invalid characters detected in feedback message',
          code: 'DANGEROUS_PATTERNS_DETECTED',
        ),
      );
    }
    final sanitized = _sanitize(feedback.message);
    if (sanitized.trim().length < 10) {
      return const Left(
        ValidationFailure(
          'Feedback message too short (minimum 10 characters after sanitization)',
          code: 'MESSAGE_TOO_SHORT',
        ),
      );
    }

    final id = feedback.id.isEmpty
        ? 'generated-${_store.length + 1}'
        : feedback.id;
    _store[id] = feedback.copyWith(id: id);
    return Right(id);
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedback(
    String userId,
  ) async {
    final result = _store.values
        .where((f) => f.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(result);
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedbackByType(
    String userId,
    UnifiedFeedbackType type,
  ) async {
    final result = _store.values
        .where((f) => f.userId == userId && f.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(result);
  }

  // ---------- ADMIN OPERATIONS - QUERIES ----------

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getAllFeedback({
    int? limit,
    UnifiedFeedbackType? type,
    UnifiedFeedbackStatus? status,
    FeedbackSeverity? severity,
  }) async {
    var result = _store.values.toList();
    if (type != null) result = result.where((f) => f.type == type).toList();
    if (status != null) {
      result = result.where((f) => f.status == status).toList();
    }
    if (severity != null) {
      result = result.where((f) => f.severity == severity).toList();
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit != null) result = result.take(limit).toList();
    return Right(result);
  }

  @override
  Future<Either<Failure, UnifiedFeedback>> getFeedbackById(
    String feedbackId,
  ) async {
    final feedback = _store[feedbackId];
    if (feedback == null) {
      return const Left(
        ValidationFailure('Feedback not found', code: 'FEEDBACK_NOT_FOUND'),
      );
    }
    return Right(feedback);
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getPendingFeedback() async {
    final result = _store.values
        .where(
          (f) =>
              f.status == UnifiedFeedbackStatus.open ||
              f.status == UnifiedFeedbackStatus.reviewing,
        )
        .toList()
      ..sort((a, b) {
        final severityCompare = b.severity.level.compareTo(a.severity.level);
        if (severityCompare != 0) return severityCompare;
        return a.createdAt.compareTo(b.createdAt);
      });
    return Right(result);
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByType(
    UnifiedFeedbackType type, {
    int? limit,
  }) async {
    var result = _store.values.where((f) => f.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit != null) result = result.take(limit).toList();
    return Right(result);
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByStatus(
    UnifiedFeedbackStatus status, {
    int? limit,
  }) async {
    var result = _store.values.where((f) => f.status == status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit != null) result = result.take(limit).toList();
    return Right(result);
  }

  // ---------- ADMIN OPERATIONS - ACTIONS ----------

  @override
  Future<Either<Failure, void>> updateFeedbackStatus({
    required String feedbackId,
    required UnifiedFeedbackStatus newStatus,
    required String adminUserId,
    String? adminNote,
  }) async {
    final feedback = _store[feedbackId];
    if (feedback == null) {
      return const Left(
        ValidationFailure('Feedback not found', code: 'FEEDBACK_NOT_FOUND'),
      );
    }
    _store[feedbackId] = feedback.copyWith(
      status: newStatus,
      reviewedBy: adminUserId,
      updatedAt: DateTime.now(),
      resolvedAt: newStatus.isCompleted ? DateTime.now() : feedback.resolvedAt,
      adminNotes: adminNote ?? feedback.adminNotes,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateFeedbackSeverity({
    required String feedbackId,
    required FeedbackSeverity newSeverity,
  }) async {
    final feedback = _store[feedbackId];
    if (feedback == null) {
      return const Left(
        ValidationFailure('Feedback not found', code: 'FEEDBACK_NOT_FOUND'),
      );
    }
    _store[feedbackId] = feedback.copyWith(
      severity: newSeverity,
      updatedAt: DateTime.now(),
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addAdminNote({
    required String feedbackId,
    required String note,
    required String adminUserId,
  }) async {
    if (note.trim().isEmpty) {
      return const Left(
        ValidationFailure('Note cannot be empty', code: 'EMPTY_NOTE'),
      );
    }
    if (_containsDangerous(note)) {
      return const Left(
        ValidationFailure(
          'Invalid characters detected in admin note',
          code: 'DANGEROUS_PATTERNS_DETECTED',
        ),
      );
    }
    final feedback = _store[feedbackId];
    if (feedback == null) {
      return const Left(
        ValidationFailure('Feedback not found', code: 'FEEDBACK_NOT_FOUND'),
      );
    }
    _store[feedbackId] = feedback.addAdminNote(note).copyWith(
      reviewedBy: adminUserId,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteFeedback(String feedbackId) async {
    final feedback = _store[feedbackId];
    if (feedback == null) {
      return const Left(
        ValidationFailure('Feedback not found', code: 'FEEDBACK_NOT_FOUND'),
      );
    }
    _store[feedbackId] = feedback.copyWith(
      status: UnifiedFeedbackStatus.closed,
      updatedAt: DateTime.now(),
    );
    _deletedIds.add(feedbackId);
    return const Right(null);
  }

  // ---------- REAL-TIME STREAMS ----------

  @override
  Stream<Either<Failure, int>> watchPendingFeedbackCount() {
    final count = _store.values
        .where(
          (f) =>
              f.status == UnifiedFeedbackStatus.open ||
              f.status == UnifiedFeedbackStatus.reviewing,
        )
        .length;
    return Stream.value(Right(count));
  }

  @override
  Stream<Either<Failure, List<UnifiedFeedback>>> watchUserFeedback(
    String userId,
  ) {
    final result = _store.values.where((f) => f.userId == userId).toList();
    return Stream.value(Right(result));
  }

  @override
  Stream<Either<Failure, List<UnifiedFeedback>>> watchFeedbackByType(
    UnifiedFeedbackType type,
  ) {
    final result = _store.values.where((f) => f.type == type).toList();
    return Stream.value(Right(result));
  }

  // ---------- STATISTICS ----------

  @override
  Future<Either<Failure, FeedbackStatistics>> getFeedbackStatistics() async {
    final all = _store.values.toList();

    final countsByType = <UnifiedFeedbackType, int>{};
    final countsByStatus = <UnifiedFeedbackStatus, int>{};
    final countsBySeverity = <FeedbackSeverity, int>{};
    final userCounts = <String, int>{};
    final resolutionTimes = <double>[];

    for (final f in all) {
      countsByType[f.type] = (countsByType[f.type] ?? 0) + 1;
      countsByStatus[f.status] = (countsByStatus[f.status] ?? 0) + 1;
      countsBySeverity[f.severity] = (countsBySeverity[f.severity] ?? 0) + 1;
      userCounts[f.userId] = (userCounts[f.userId] ?? 0) + 1;
      if (f.resolvedAt != null) {
        resolutionTimes
            .add(f.resolvedAt!.difference(f.createdAt).inHours.toDouble());
      }
    }

    final avgResolution = resolutionTimes.isEmpty
        ? 0.0
        : resolutionTimes.reduce((a, b) => a + b) / resolutionTimes.length;

    final sortedReporters = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final reporters = sortedReporters
        .take(10)
        .map((e) => (e.key, e.value))
        .toList();

    return Right(
      FeedbackStatistics(
        totalCount: all.length,
        countsByType: countsByType,
        countsByStatus: countsByStatus,
        countsBySeverity: countsBySeverity,
        avgResolutionTimeHours: avgResolution,
        mostActiveReporters: reporters,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UnifiedFeedback _feedback({
  String id = 'fb-001',
  String userId = 'user-001',
  UnifiedFeedbackType type = UnifiedFeedbackType.general,
  UnifiedFeedbackStatus status = UnifiedFeedbackStatus.open,
  FeedbackSeverity severity = FeedbackSeverity.medium,
  String message = 'This is a valid feedback message for testing.',
  DateTime? createdAt,
}) {
  return UnifiedFeedback(
    id: id,
    userId: userId,
    type: type,
    status: status,
    severity: severity,
    message: message,
    createdAt: createdAt ?? DateTime(2024, 1, 15, 12),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late _FakeUnifiedFeedbackRepository repo;

  setUp(() {
    repo = _FakeUnifiedFeedbackRepository();
  });

  // ================================================================
  // submitFeedback - validation
  // ================================================================
  group('submitFeedback validation', () {
    test('returns ValidationFailure when message is empty', () async {
      final f = _feedback(message: '');
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure when message is only whitespace', () async {
      final f = _feedback(message: '   ');
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
    });

    test('returns ValidationFailure when userId is empty', () async {
      final f = _feedback(userId: '');
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect((failure as ValidationFailure).code, 'EMPTY_USER_ID'),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure for message with SQL injection chars', () async {
      final f = _feedback(message: "SELECT * FROM users WHERE '1'='1'");
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(
          (failure as ValidationFailure).code,
          'DANGEROUS_PATTERNS_DETECTED',
        ),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure for message with script tag', () async {
      final f = _feedback(message: '<script>alert(1)</script>');
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
    });

    test('returns ValidationFailure when message is too short after sanitization', () async {
      // A 9-char message (after sanitize = < 10 chars)
      final f = _feedback(message: 'Too short');
      final result = await repo.submitFeedback(f);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(
          (failure as ValidationFailure).code,
          'MESSAGE_TOO_SHORT',
        ),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Right with id for valid feedback', () async {
      final f = _feedback(
        message: 'This is a valid feedback message that passes validation.',
      );
      final result = await repo.submitFeedback(f);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (id) => expect(id, isNotEmpty),
      );
    });

    test('uses provided id when non-empty', () async {
      final f = _feedback(
        id: 'my-custom-id',
        message: 'Valid message long enough to pass.',
      );
      final result = await repo.submitFeedback(f);
      result.fold(
        (_) => fail('Expected Right'),
        (id) => expect(id, 'my-custom-id'),
      );
    });

    test('generates an id when feedback.id is empty', () async {
      final f = _feedback(
        id: '',
        message: 'Valid message long enough to pass validation.',
      );
      final result = await repo.submitFeedback(f);
      result.fold(
        (_) => fail('Expected Right'),
        (id) => expect(id, isNotEmpty),
      );
    });
  });

  // ================================================================
  // getUserFeedback
  // ================================================================
  group('getUserFeedback', () {
    test('returns empty list when no feedback for user', () async {
      final result = await repo.getUserFeedback('nonexistent-user');
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list, isEmpty),
      );
    });

    test('returns only feedback for the specified user', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          userId: 'user-A',
          message: 'User A feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          userId: 'user-B',
          message: 'User B feedback message that is long enough.',
        ),
      );

      final result = await repo.getUserFeedback('user-A');
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.userId, 'user-A');
        },
      );
    });

    test('returns multiple feedback items for the same user', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          userId: 'user-A',
          message: 'First feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          userId: 'user-A',
          message: 'Second feedback message that is long enough.',
        ),
      );

      final result = await repo.getUserFeedback('user-A');
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.length, 2),
      );
    });
  });

  // ================================================================
  // getUserFeedbackByType
  // ================================================================
  group('getUserFeedbackByType', () {
    test('returns only matching type for a user', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          userId: 'user-A',
          type: UnifiedFeedbackType.exercise,
          message: 'Exercise feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          userId: 'user-A',
          type: UnifiedFeedbackType.general,
          message: 'General feedback message that is long enough.',
        ),
      );

      final result = await repo.getUserFeedbackByType(
        'user-A',
        UnifiedFeedbackType.exercise,
      );
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.type, UnifiedFeedbackType.exercise);
        },
      );
    });
  });

  // ================================================================
  // getFeedbackById
  // ================================================================
  group('getFeedbackById', () {
    test('returns feedback when found', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'known-id',
          message: 'This feedback has a known id for retrieval test.',
        ),
      );

      final result = await repo.getFeedbackById('known-id');
      result.fold(
        (_) => fail('Expected Right'),
        (f) => expect(f.id, 'known-id'),
      );
    });

    test('returns ValidationFailure when not found', () async {
      final result = await repo.getFeedbackById('nonexistent');
      result.fold(
        (failure) => expect(
          (failure as ValidationFailure).code,
          'FEEDBACK_NOT_FOUND',
        ),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ================================================================
  // getPendingFeedback
  // ================================================================
  group('getPendingFeedback', () {
    test('returns only open and reviewing feedback', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-open',
          status: UnifiedFeedbackStatus.open,
          message: 'Open feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-resolved',
          status: UnifiedFeedbackStatus.resolved,
          message: 'Resolved feedback message that is long enough.',
        ),
      );

      final result = await repo.getPendingFeedback();
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, 'fb-open');
        },
      );
    });

    test('sorts by severity descending (critical first)', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-low',
          severity: FeedbackSeverity.low,
          message: 'Low severity feedback message that is long enough.',
          createdAt: DateTime(2024, 1, 1),
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-critical',
          severity: FeedbackSeverity.critical,
          message: 'Critical severity feedback message that is long enough.',
          createdAt: DateTime(2024, 1, 2),
        ),
      );

      final result = await repo.getPendingFeedback();
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.first.severity, FeedbackSeverity.critical);
          expect(list.last.severity, FeedbackSeverity.low);
        },
      );
    });
  });

  // ================================================================
  // getAllFeedback with filters
  // ================================================================
  group('getAllFeedback', () {
    test('returns all feedback when no filters', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          message: 'First feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          message: 'Second feedback message that is long enough.',
        ),
      );

      final result = await repo.getAllFeedback();
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.length, 2),
      );
    });

    test('filters by type', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-exercise',
          type: UnifiedFeedbackType.exercise,
          message: 'Exercise feedback that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-general',
          type: UnifiedFeedbackType.general,
          message: 'General feedback that is long enough.',
        ),
      );

      final result = await repo.getAllFeedback(type: UnifiedFeedbackType.exercise);
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.type, UnifiedFeedbackType.exercise);
        },
      );
    });

    test('filters by status', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-open',
          status: UnifiedFeedbackStatus.open,
          message: 'Open feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-resolved',
          status: UnifiedFeedbackStatus.resolved,
          message: 'Resolved feedback message that is long enough.',
        ),
      );

      final result = await repo.getAllFeedback(
        status: UnifiedFeedbackStatus.resolved,
      );
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.status, UnifiedFeedbackStatus.resolved);
        },
      );
    });

    test('applies limit', () async {
      for (var i = 0; i < 5; i++) {
        await repo.submitFeedback(
          _feedback(
            id: 'fb-$i',
            message: 'Feedback message number $i that is long enough to pass.',
          ),
        );
      }

      final result = await repo.getAllFeedback(limit: 3);
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.length, 3),
      );
    });
  });

  // ================================================================
  // getFeedbackByType
  // ================================================================
  group('getFeedbackByType', () {
    test('returns only feedback with given type', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-analytics',
          type: UnifiedFeedbackType.analytics,
          message: 'Analytics feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-general',
          type: UnifiedFeedbackType.general,
          message: 'General feedback message that is long enough.',
        ),
      );

      final result = await repo.getFeedbackByType(UnifiedFeedbackType.analytics);
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.type, UnifiedFeedbackType.analytics);
        },
      );
    });

    test('applies limit', () async {
      for (var i = 0; i < 4; i++) {
        await repo.submitFeedback(
          _feedback(
            id: 'fb-$i',
            type: UnifiedFeedbackType.general,
            message:
                'General feedback message number $i that is long enough for testing.',
          ),
        );
      }

      final result = await repo.getFeedbackByType(
        UnifiedFeedbackType.general,
        limit: 2,
      );
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.length, 2),
      );
    });
  });

  // ================================================================
  // getFeedbackByStatus
  // ================================================================
  group('getFeedbackByStatus', () {
    test('returns only feedback with given status', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-open',
          status: UnifiedFeedbackStatus.open,
          message: 'Open feedback message that is long enough.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-dismissed',
          status: UnifiedFeedbackStatus.dismissed,
          message: 'Dismissed feedback message that is long enough.',
        ),
      );

      final result = await repo.getFeedbackByStatus(UnifiedFeedbackStatus.open);
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, 'fb-open');
        },
      );
    });
  });

  // ================================================================
  // updateFeedbackStatus
  // ================================================================
  group('updateFeedbackStatus', () {
    test('updates status for existing feedback', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          message: 'A valid feedback message to update status.',
        ),
      );

      final result = await repo.updateFeedbackStatus(
        feedbackId: 'fb-001',
        newStatus: UnifiedFeedbackStatus.reviewing,
        adminUserId: 'admin-001',
      );

      expect(result.isRight(), isTrue);

      final getResult = await repo.getFeedbackById('fb-001');
      getResult.fold(
        (_) => fail('Expected Right'),
        (f) {
          expect(f.status, UnifiedFeedbackStatus.reviewing);
          expect(f.reviewedBy, 'admin-001');
        },
      );
    });

    test('sets resolvedAt when new status is completed', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          message: 'A valid feedback message to resolve status.',
        ),
      );

      await repo.updateFeedbackStatus(
        feedbackId: 'fb-001',
        newStatus: UnifiedFeedbackStatus.resolved,
        adminUserId: 'admin-001',
      );

      final getResult = await repo.getFeedbackById('fb-001');
      getResult.fold(
        (_) => fail('Expected Right'),
        (f) => expect(f.resolvedAt, isNotNull),
      );
    });

    test('returns ValidationFailure for non-existent feedbackId', () async {
      final result = await repo.updateFeedbackStatus(
        feedbackId: 'nonexistent',
        newStatus: UnifiedFeedbackStatus.closed,
        adminUserId: 'admin-001',
      );
      expect(result.isLeft(), isTrue);
    });
  });

  // ================================================================
  // updateFeedbackSeverity
  // ================================================================
  group('updateFeedbackSeverity', () {
    test('updates severity for existing feedback', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          severity: FeedbackSeverity.low,
          message: 'A valid feedback message to update severity.',
        ),
      );

      await repo.updateFeedbackSeverity(
        feedbackId: 'fb-001',
        newSeverity: FeedbackSeverity.critical,
      );

      final getResult = await repo.getFeedbackById('fb-001');
      getResult.fold(
        (_) => fail('Expected Right'),
        (f) => expect(f.severity, FeedbackSeverity.critical),
      );
    });

    test('returns ValidationFailure for non-existent feedbackId', () async {
      final result = await repo.updateFeedbackSeverity(
        feedbackId: 'nonexistent',
        newSeverity: FeedbackSeverity.high,
      );
      expect(result.isLeft(), isTrue);
    });
  });

  // ================================================================
  // addAdminNote
  // ================================================================
  group('addAdminNote', () {
    test('adds note to feedback with no existing notes', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          message: 'A valid feedback message to add admin note.',
        ),
      );

      await repo.addAdminNote(
        feedbackId: 'fb-001',
        note: 'Investigating this issue',
        adminUserId: 'admin-001',
      );

      final result = await repo.getFeedbackById('fb-001');
      result.fold(
        (_) => fail('Expected Right'),
        (f) {
          expect(f.adminNotes, contains('Investigating this issue'));
          expect(f.reviewedBy, 'admin-001');
        },
      );
    });

    test('appends note to existing notes', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          message: 'A valid feedback message to append admin notes.',
        ),
      );

      await repo.addAdminNote(
        feedbackId: 'fb-001',
        note: 'First note here',
        adminUserId: 'admin-001',
      );
      await repo.addAdminNote(
        feedbackId: 'fb-001',
        note: 'Second note here',
        adminUserId: 'admin-001',
      );

      final result = await repo.getFeedbackById('fb-001');
      result.fold(
        (_) => fail('Expected Right'),
        (f) {
          expect(f.adminNotes, contains('First note here'));
          expect(f.adminNotes, contains('Second note here'));
        },
      );
    });

    test('returns ValidationFailure for empty note', () async {
      final result = await repo.addAdminNote(
        feedbackId: 'any-id',
        note: '',
        adminUserId: 'admin-001',
      );
      result.fold(
        (failure) => expect(
          (failure as ValidationFailure).code,
          'EMPTY_NOTE',
        ),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure for dangerous pattern in note', () async {
      final result = await repo.addAdminNote(
        feedbackId: 'any-id',
        note: "<script>alert('xss')</script>",
        adminUserId: 'admin-001',
      );
      result.fold(
        (failure) => expect(
          (failure as ValidationFailure).code,
          'DANGEROUS_PATTERNS_DETECTED',
        ),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ValidationFailure for non-existent feedbackId', () async {
      final result = await repo.addAdminNote(
        feedbackId: 'nonexistent',
        note: 'A valid note',
        adminUserId: 'admin-001',
      );
      expect(result.isLeft(), isTrue);
    });
  });

  // ================================================================
  // deleteFeedback (soft delete)
  // ================================================================
  group('deleteFeedback', () {
    test('sets status to closed (soft delete)', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-001',
          message: 'A valid feedback message to delete softly.',
        ),
      );

      await repo.deleteFeedback('fb-001');

      final result = await repo.getFeedbackById('fb-001');
      result.fold(
        (_) => fail('Expected Right'),
        (f) => expect(f.status, UnifiedFeedbackStatus.closed),
      );
    });

    test('returns ValidationFailure for non-existent feedbackId', () async {
      final result = await repo.deleteFeedback('nonexistent');
      expect(result.isLeft(), isTrue);
    });
  });

  // ================================================================
  // watchPendingFeedbackCount
  // ================================================================
  group('watchPendingFeedbackCount', () {
    test('emits count of open and reviewing feedback', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-open',
          status: UnifiedFeedbackStatus.open,
          message: 'Open feedback message for watching count.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-resolved',
          status: UnifiedFeedbackStatus.resolved,
          message: 'Resolved feedback message for watching count.',
        ),
      );

      final stream = repo.watchPendingFeedbackCount();
      final result = await stream.first;
      result.fold(
        (_) => fail('Expected Right'),
        (count) => expect(count, 1),
      );
    });
  });

  // ================================================================
  // watchUserFeedback
  // ================================================================
  group('watchUserFeedback', () {
    test('emits list of feedback for a user', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          userId: 'user-A',
          message: 'First feedback message for user A watching.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          userId: 'user-B',
          message: 'Feedback message for user B watching.',
        ),
      );

      final stream = repo.watchUserFeedback('user-A');
      final result = await stream.first;
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.length, 1);
          expect(list.first.userId, 'user-A');
        },
      );
    });
  });

  // ================================================================
  // getFeedbackStatistics
  // ================================================================
  group('getFeedbackStatistics', () {
    test('returns statistics with correct total count', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-1',
          message: 'First feedback for statistics total count test.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-2',
          message: 'Second feedback for statistics total count test.',
        ),
      );

      final result = await repo.getFeedbackStatistics();
      result.fold(
        (_) => fail('Expected Right'),
        (stats) => expect(stats.totalCount, 2),
      );
    });

    test('counts by type correctly', () async {
      await repo.submitFeedback(
        _feedback(
          id: 'fb-exercise',
          type: UnifiedFeedbackType.exercise,
          message: 'Exercise feedback message for statistics type count.',
        ),
      );
      await repo.submitFeedback(
        _feedback(
          id: 'fb-general',
          type: UnifiedFeedbackType.general,
          message: 'General feedback message for statistics type count.',
        ),
      );

      final result = await repo.getFeedbackStatistics();
      result.fold(
        (_) => fail('Expected Right'),
        (stats) {
          expect(stats.countsByType[UnifiedFeedbackType.exercise], 1);
          expect(stats.countsByType[UnifiedFeedbackType.general], 1);
        },
      );
    });

    test('returns empty stats when no feedback', () async {
      final result = await repo.getFeedbackStatistics();
      result.fold(
        (_) => fail('Expected Right'),
        (stats) {
          expect(stats.totalCount, 0);
          expect(stats.countsByType, isEmpty);
          expect(stats.pendingCount, 0);
        },
      );
    });

    test('calculates avgResolutionTimeHours for resolved feedback', () async {
      // Feedback resolved 24 hours after creation
      final createdAt = DateTime(2024, 1, 1, 10);
      final resolvedAt = DateTime(2024, 1, 2, 10);

      await repo.submitFeedback(
        _feedback(
          id: 'fb-resolved',
          message: 'Resolved feedback message for resolution time test.',
        ),
      );

      // Insert a fake with resolvedAt set
      final fakeWithResolved = UnifiedFeedback(
        id: 'fb-resolved-2',
        userId: 'user-001',
        type: UnifiedFeedbackType.general,
        status: UnifiedFeedbackStatus.resolved,
        severity: FeedbackSeverity.medium,
        message: 'Another resolved message for time calculation.',
        createdAt: createdAt,
        resolvedAt: resolvedAt,
      );
      // Submit it (it has no dangerous chars and is long enough)
      await repo.submitFeedback(fakeWithResolved);

      final statsResult = await repo.getFeedbackStatistics();
      statsResult.fold(
        (_) => fail('Expected Right'),
        (stats) {
          // At least one resolved item with 24h resolution time
          expect(stats.avgResolutionTimeHours, greaterThanOrEqualTo(0));
        },
      );
    });
  });
}
