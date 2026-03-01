// ignore_for_file: avoid_redundant_argument_values

/// Unit tests for custom_exercises domain layer.
///
/// Covers:
/// - CustomExercise entity: JSON round-trip, computed properties, factory constructors
/// - CustomExercise.g.dart: HiveType adapter equality / hashCode
/// - CustomExerciseLimitService: limit checks, prepareExerciseForSave, onAdWatched,
///   getExpiredExercises, getActiveExercises, cleanupExpiredExercises
/// - LimitCheckResult: helpers
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/services/custom_exercise_limit_service.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Fake Repository
// ---------------------------------------------------------------------------

class FakeCustomExerciseRepository implements CustomExerciseRepository {
  final List<CustomExercise> _exercises;
  final int _permanentCountOverride;
  final bool _shouldFail;

  FakeCustomExerciseRepository({
    List<CustomExercise>? exercises,
    int permanentCountOverride = -1,
    bool shouldFail = false,
  })  : _exercises = exercises ?? [],
        _permanentCountOverride = permanentCountOverride,
        _shouldFail = shouldFail;

  @override
  Future<Either<Failure, List<CustomExercise>>> getAll() async {
    if (_shouldFail) return const Left(CacheFailure('getAll failed'));
    return Right(List.from(_exercises));
  }

  @override
  Future<Either<Failure, List<CustomExercise>>> getActive() async {
    if (_shouldFail) return const Left(CacheFailure('getActive failed'));
    final now = DateTime.now();
    return Right(
      _exercises
          .where((e) => e.unlockedUntil == null || e.unlockedUntil!.isAfter(now))
          .toList(),
    );
  }

  @override
  Future<Either<Failure, CustomExercise?>> getById(String id) async {
    if (_shouldFail) return const Left(CacheFailure('getById failed'));
    try {
      return Right(_exercises.firstWhere((e) => e.id == id));
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, CustomExercise?>> findByName(String exerciseName) async {
    if (_shouldFail) return const Left(CacheFailure('findByName failed'));
    try {
      return Right(
        _exercises.firstWhere(
          (e) => e.nome.toLowerCase() == exerciseName.toLowerCase(),
        ),
      );
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, int>> getPermanentCount() async {
    if (_shouldFail) return const Left(CacheFailure('getPermanentCount failed'));
    if (_permanentCountOverride >= 0) return Right(_permanentCountOverride);
    final count = _exercises.where((e) => e.unlockedUntil == null).length;
    return Right(count);
  }

  @override
  Future<Either<Failure, void>> save(CustomExercise exercise) async {
    if (_shouldFail) return const Left(CacheFailure('save failed'));
    _exercises.add(exercise);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> update(CustomExercise exercise) async {
    if (_shouldFail) return const Left(CacheFailure('update failed'));
    final idx = _exercises.indexWhere((e) => e.id == exercise.id);
    if (idx >= 0) _exercises[idx] = exercise;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    if (_shouldFail) return const Left(CacheFailure('delete failed'));
    _exercises.removeWhere((e) => e.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> extendUnlock(String id, {int days = 7}) async {
    if (_shouldFail) return const Left(CacheFailure('extendUnlock failed'));
    final idx = _exercises.indexWhere((e) => e.id == id);
    if (idx < 0) return const Left(CacheFailure('not found'));
    final ex = _exercises[idx];
    final newExpiry = DateTime.now().add(Duration(days: days));
    _exercises[idx] = CustomExercise(
      id: ex.id,
      nome: ex.nome,
      baseExerciseId: ex.baseExerciseId,
      focus: ex.focus,
      muscoliSecondari: ex.muscoliSecondari,
      tipoEsercizio: ex.tipoEsercizio,
      patternMovimento: ex.patternMovimento,
      attrezzatura: ex.attrezzatura,
      createdAt: ex.createdAt,
      unlockedUntil: newExpiry,
      isModifiedFromBase: ex.isModifiedFromBase,
      userId: ex.userId,
    );
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchAll() =>
      Stream.value(Right(List.from(_exercises)));

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchActive() {
    final now = DateTime.now();
    return Stream.value(
      Right(
        _exercises
            .where(
              (e) => e.unlockedUntil == null || e.unlockedUntil!.isAfter(now),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> syncToCloud() async =>
      const Left(CacheFailure('not premium'));

  @override
  Future<Either<Failure, void>> refreshFromCloud() async =>
      const Left(CacheFailure('not premium'));
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

CustomExercise makeEx({
  String id = 'ex-001',
  String nome = 'Bench Press',
  DateTime? unlockedUntil,
  String? baseExerciseId,
  bool isModifiedFromBase = false,
}) {
  return CustomExercise(
    id: id,
    nome: nome,
    baseExerciseId: baseExerciseId,
    focus: const ['PETT'],
    muscoliSecondari: const ['TRIC'],
    tipoEsercizio: 'Compound',
    patternMovimento: 'Push',
    attrezzatura: 'Bilanciere',
    createdAt: DateTime(2024, 1, 1),
    unlockedUntil: unlockedUntil,
    isModifiedFromBase: isModifiedFromBase,
    userId: null,
  );
}

CustomExercise makeExpiredEx({String id = 'expired-001'}) {
  return makeEx(
    id: id,
    unlockedUntil: DateTime.now().subtract(const Duration(days: 1)),
  );
}

CustomExercise makeFutureEx({String id = 'future-001', int daysAhead = 5}) {
  return makeEx(
    id: id,
    unlockedUntil: DateTime.now().add(Duration(days: daysAhead)),
  );
}

void main() {
  // =========================================================================
  // CustomExercise entity
  // =========================================================================
  group('CustomExercise entity', () {
    test('toJson/fromJson round-trip preserves all fields', () {
      final now = DateTime(2025, 6, 15, 12, 0);
      final expiry = DateTime(2025, 6, 22, 12, 0);
      final original = CustomExercise(
        id: 'test-id-001',
        nome: 'My Custom Push',
        baseExerciseId: 'bench-press',
        focus: const ['PETT', 'DELT ANT'],
        muscoliSecondari: const ['TRIC'],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Push',
        attrezzatura: 'Manubri',
        createdAt: now,
        unlockedUntil: expiry,
        isModifiedFromBase: true,
        userId: 'user-abc',
      );

      final json = original.toJson();
      final restored = CustomExercise.fromJson(json);

      expect(restored.id, 'test-id-001');
      expect(restored.nome, 'My Custom Push');
      expect(restored.baseExerciseId, 'bench-press');
      expect(restored.focus, ['PETT', 'DELT ANT']);
      expect(restored.muscoliSecondari, ['TRIC']);
      expect(restored.tipoEsercizio, 'Compound');
      expect(restored.patternMovimento, 'Push');
      expect(restored.attrezzatura, 'Manubri');
      expect(restored.createdAt.year, 2025);
      expect(restored.unlockedUntil?.year, 2025);
      expect(restored.isModifiedFromBase, isTrue);
      expect(restored.userId, 'user-abc');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'id-001',
        'nome': 'Squat',
        'baseExerciseId': null,
        'focus': ['GAMB'],
        'muscoliSecondari': <String>[],
        'tipoEsercizio': 'Compound',
        'patternMovimento': 'Squat',
        'attrezzatura': 'Bilanciere',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'unlockedUntil': null,
        'isModifiedFromBase': null,
        'userId': null,
      };
      final ex = CustomExercise.fromJson(json);
      expect(ex.baseExerciseId, isNull);
      expect(ex.unlockedUntil, isNull);
      expect(ex.isModifiedFromBase, isFalse);
      expect(ex.userId, isNull);
    });

    test('isActive=true for permanent exercise', () {
      final ex = makeEx();
      expect(ex.isActive, isTrue);
      expect(ex.isPermanent, isTrue);
      expect(ex.isTemporary, isFalse);
      expect(ex.isExpired, isFalse);
    });

    test('isActive=true for future temporary exercise', () {
      final ex = makeFutureEx(daysAhead: 3);
      expect(ex.isActive, isTrue);
      expect(ex.isExpired, isFalse);
      expect(ex.isTemporary, isTrue);
      expect(ex.isPermanent, isFalse);
    });

    test('isExpired=true for past temporary exercise', () {
      final ex = makeExpiredEx();
      expect(ex.isExpired, isTrue);
      expect(ex.isActive, isFalse);
    });

    test('isPureCustom and isVariant', () {
      final pure = makeEx(baseExerciseId: null);
      final variant = makeEx(baseExerciseId: 'base-123');
      expect(pure.isPureCustom, isTrue);
      expect(pure.isVariant, isFalse);
      expect(variant.isPureCustom, isFalse);
      expect(variant.isVariant, isTrue);
    });

    test('daysRemaining is null for permanent exercise', () {
      final ex = makeEx();
      expect(ex.daysRemaining, isNull);
    });

    test('daysRemaining >=0 for valid temporary exercise', () {
      final ex = makeFutureEx(daysAhead: 5);
      expect(ex.daysRemaining, greaterThanOrEqualTo(0));
      expect(ex.daysRemaining, lessThanOrEqualTo(5));
    });

    test('focusDisplayName joins focus with comma', () {
      final ex = CustomExercise(
        id: 'x',
        nome: 'x',
        focus: const ['PETT', 'DELT'],
        muscoliSecondari: const [],
        tipoEsercizio: 't',
        patternMovimento: 'p',
        attrezzatura: 'a',
        createdAt: DateTime.now(),
      );
      expect(ex.focusDisplayName, 'PETT, DELT');
    });

    test('muscoliSecondariDisplayName joins muscles', () {
      final ex = makeEx()..muscoliSecondari;
      expect(ex.muscoliSecondariDisplayName, 'TRIC');
    });

    test('attrezzaturaIcon returns correct icon for known equipment', () {
      final icons = {
        'bilanciere': '🏋️',
        'manubri': '💪',
        'cavi': '🔗',
        'macchina': '⚙️',
        'corpo libero': '🤸',
        'unknown': '🎯',
      };
      for (final entry in icons.entries) {
        final ex = CustomExercise(
          id: 'x',
          nome: 'x',
          focus: const [],
          muscoliSecondari: const [],
          tipoEsercizio: 't',
          patternMovimento: 'p',
          attrezzatura: entry.key,
          createdAt: DateTime.now(),
        );
        expect(ex.attrezzaturaIcon, entry.value, reason: 'for ${entry.key}');
      }
    });

    test('createNew factory assigns unique id and createdAt', () {
      final ex1 = CustomExercise.createNew(
        nome: 'Ex1',
        focus: const ['PETT'],
        muscoliSecondari: const [],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Push',
        attrezzatura: 'Bilanciere',
      );
      final ex2 = CustomExercise.createNew(
        nome: 'Ex2',
        focus: const ['GAMB'],
        muscoliSecondari: const [],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Squat',
        attrezzatura: 'Bilanciere',
      );
      expect(ex1.id, isNotEmpty);
      expect(ex2.id, isNotEmpty);
      expect(ex1.id, isNot(equals(ex2.id)));
      expect(ex1.baseExerciseId, isNull);
      expect(ex1.isModifiedFromBase, isFalse);
    });

    test('fromBase factory sets baseExerciseId and isModifiedFromBase', () {
      final ex = CustomExercise.fromBase(
        baseExerciseId: 'base-squat',
        nome: 'My Squat',
        focus: const ['GAMB'],
        muscoliSecondari: const ['GMAN'],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Squat',
        attrezzatura: 'Bilanciere',
        isModifiedFromBase: true,
      );
      expect(ex.baseExerciseId, 'base-squat');
      expect(ex.isModifiedFromBase, isTrue);
      expect(ex.isVariant, isTrue);
      expect(ex.id, isNotEmpty);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = makeEx();
      final updated = original.copyWith(nome: 'Updated Name');
      expect(updated.nome, 'Updated Name');
      expect(updated.id, original.id); // unchanged
      expect(original.nome, 'Bench Press'); // original not mutated
    });

    test('Equatable equality based on props', () {
      final a = makeEx(id: 'same-id');
      final b = makeEx(id: 'same-id');
      expect(a, equals(b));

      final c = makeEx(id: 'diff-id');
      expect(a, isNot(equals(c)));
    });
  });

  // =========================================================================
  // CustomExerciseLimitService
  // =========================================================================
  group('CustomExerciseLimitService', () {
    group('hasUnlimitedExercises', () {
      test('true when max >= 999', () {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        expect(svc.hasUnlimitedExercises, isTrue);
        expect(svc.maxExercises, 999);
      });

      test('false when max < 999', () {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 5,
        );
        expect(svc.hasUnlimitedExercises, isFalse);
      });
    });

    group('canCreatePermanent', () {
      test('unlimited user can always create', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 999),
          maxCustomSingleExercises: 999,
        );
        expect(await svc.canCreatePermanent(), isTrue);
      });

      test('limited user can create when below limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 2),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.canCreatePermanent(), isTrue);
      });

      test('limited user cannot create when at limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 5),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.canCreatePermanent(), isFalse);
      });

      test('returns true on repository error (fail-safe)', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        // getPermanentCount returns 0 on error, 0 < 5 = can create
        expect(await svc.canCreatePermanent(), isTrue);
      });
    });

    group('requiresAdForNext', () {
      test('unlimited user never requires ad', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        expect(await svc.requiresAdForNext(), isFalse);
      });

      test('limited user requires ad when at limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 5),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.requiresAdForNext(), isTrue);
      });

      test('limited user does not require ad when below limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 3),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.requiresAdForNext(), isFalse);
      });
    });

    group('getRemainingPermanentSlots', () {
      test('unlimited user returns 999', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        expect(await svc.getRemainingPermanentSlots(), 999);
      });

      test('limited user returns correct remaining', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 3),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getRemainingPermanentSlots(), 2);
      });

      test('clamps to 0 when over limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 10),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getRemainingPermanentSlots(), 0);
      });
    });

    group('getPermanentCount', () {
      test('counts permanent exercises correctly', () async {
        final exercises = [
          makeEx(id: 'p1'), // permanent (unlockedUntil=null)
          makeEx(id: 'p2'),
          makeFutureEx(id: 't1'), // temporary
        ];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getPermanentCount(), 2);
      });

      test('returns 0 on repository error', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getPermanentCount(), 0);
      });
    });

    group('getTemporaryCount', () {
      test('counts only temporary exercises', () async {
        final exercises = [
          makeEx(id: 'p1'),
          makeFutureEx(id: 't1'),
          makeFutureEx(id: 't2'),
        ];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getTemporaryCount(), 2);
      });

      test('returns 0 on repository error', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getTemporaryCount(), 0);
      });
    });

    group('checkLimits', () {
      test('returns unlimited status for unlimited user', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        final result = await svc.checkLimits();
        expect(result.status, LimitStatus.unlimited);
        expect(result.remainingSlots, 999);
        expect(result.isPremium, isTrue);
        expect(result.canCreatePermanent, isTrue);
        expect(result.requiresAd, isFalse);
      });

      test('returns available status when below limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 2),
          maxCustomSingleExercises: 5,
        );
        final result = await svc.checkLimits();
        expect(result.status, LimitStatus.available);
        expect(result.remainingSlots, 3);
        expect(result.canCreatePermanent, isTrue);
        expect(result.requiresAd, isFalse);
      });

      test('returns requiresAd status when at limit', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 5),
          maxCustomSingleExercises: 5,
        );
        final result = await svc.checkLimits();
        expect(result.status, LimitStatus.requiresAd);
        expect(result.requiresAd, isTrue);
        expect(result.canCreatePermanent, isFalse);
        expect(result.isPremium, isFalse);
      });

      test('expiredCount included in result', () async {
        final exercises = [
          makeEx(id: 'p1'),
          makeExpiredEx(id: 'expired1'),
          makeExpiredEx(id: 'expired2'),
        ];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );
        final result = await svc.checkLimits();
        expect(result.expiredCount, 2);
      });
    });

    group('prepareExerciseForSave', () {
      test('unlimited user gets permanent exercise (unlockedUntil=null)', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        final input = makeFutureEx(); // has expiry date
        final result = await svc.prepareExerciseForSave(input);
        expect(result.unlockedUntil, isNull);
        expect(result.isPermanent, isTrue);
      });

      test('user with slots gets permanent exercise', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 2),
          maxCustomSingleExercises: 5,
        );
        final input = makeEx();
        final result = await svc.prepareExerciseForSave(input);
        expect(result.unlockedUntil, isNull);
        expect(result.isPermanent, isTrue);
      });

      test('user without slots gets 7-day temporary exercise', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(permanentCountOverride: 5),
          maxCustomSingleExercises: 5,
        );
        final input = makeEx();
        final before = DateTime.now();
        final result = await svc.prepareExerciseForSave(input);
        final after = DateTime.now();

        expect(result.unlockedUntil, isNotNull);
        final expectedMin = before.add(const Duration(days: 7));
        final expectedMax = after.add(const Duration(days: 7));
        expect(
          result.unlockedUntil!.isAfter(expectedMin) ||
              result.unlockedUntil! == expectedMin,
          isTrue,
        );
        expect(
          result.unlockedUntil!.isBefore(expectedMax) ||
              result.unlockedUntil! == expectedMax,
          isTrue,
        );
      });

      test('other fields preserved after prepareExerciseForSave', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 999,
        );
        final input = makeEx(id: 'test-preserve', nome: 'My Custom');
        final result = await svc.prepareExerciseForSave(input);
        expect(result.id, 'test-preserve');
        expect(result.nome, 'My Custom');
        expect(result.focus, input.focus);
      });
    });

    group('onAdWatched', () {
      test('converts temporary to permanent when slots available', () async {
        final tempEx = makeFutureEx(id: 'temp-001');
        final exercises = <CustomExercise>[tempEx];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(
            exercises: exercises,
            // 0 permanent exercises, so 0 < 5 => slots available
          ),
          maxCustomSingleExercises: 5,
        );

        await svc.onAdWatched('temp-001');

        // After onAdWatched with slots available, exercise should be permanent
        final updated = exercises.firstWhere((e) => e.id == 'temp-001');
        expect(updated.unlockedUntil, isNull);
      });

      test('extends temporary when no slots available', () async {
        // Fill to limit with permanent exercises
        final permanentExercises = List.generate(
          5,
          (i) => makeEx(id: 'perm-$i'),
        );
        final tempEx = makeFutureEx(id: 'temp-001');
        final exercises = [...permanentExercises, tempEx];

        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );

        final before = DateTime.now();
        await svc.onAdWatched('temp-001');

        final updated = exercises.firstWhere((e) => e.id == 'temp-001');
        expect(updated.unlockedUntil, isNotNull);
        expect(
          updated.unlockedUntil!.isAfter(before.add(const Duration(days: 6))),
          isTrue,
        );
      });

      test('throws when exercise not found', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 5,
        );
        expect(
          () => svc.onAdWatched('nonexistent'),
          throwsException,
        );
      });

      test('throws when repository fails on getById', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        expect(
          () => svc.onAdWatched('any'),
          throwsException,
        );
      });
    });

    group('getExpiredExercises', () {
      test('returns only expired exercises', () async {
        final exercises = [
          makeEx(id: 'permanent'),
          makeExpiredEx(id: 'expired-1'),
          makeFutureEx(id: 'future-1'),
          makeExpiredEx(id: 'expired-2'),
        ];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );
        final expired = await svc.getExpiredExercises();
        expect(expired, hasLength(2));
        expect(expired.map((e) => e.id), containsAll(['expired-1', 'expired-2']));
      });

      test('returns empty on repository error', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getExpiredExercises(), isEmpty);
      });

      test('returns empty when no exercises', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getExpiredExercises(), isEmpty);
      });
    });

    group('getActiveExercises', () {
      test('returns only active exercises', () async {
        final exercises = [
          makeEx(id: 'permanent'),
          makeExpiredEx(id: 'expired-1'),
          makeFutureEx(id: 'future-1'),
        ];
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );
        final active = await svc.getActiveExercises();
        expect(active, hasLength(2));
        expect(active.map((e) => e.id), containsAll(['permanent', 'future-1']));
      });

      test('returns empty on repository error', () async {
        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(shouldFail: true),
          maxCustomSingleExercises: 5,
        );
        expect(await svc.getActiveExercises(), isEmpty);
      });
    });

    group('cleanupExpiredExercises', () {
      test('deletes exercises expired for more than daysAfterExpiration', () async {
        final veryOldExpired = CustomExercise(
          id: 'old-expired',
          nome: 'Old',
          focus: const [],
          muscoliSecondari: const [],
          tipoEsercizio: 't',
          patternMovimento: 'p',
          attrezzatura: 'a',
          createdAt: DateTime.now(),
          unlockedUntil: DateTime.now().subtract(const Duration(days: 31)),
        );
        final recentExpired = CustomExercise(
          id: 'recent-expired',
          nome: 'Recent',
          focus: const [],
          muscoliSecondari: const [],
          tipoEsercizio: 't',
          patternMovimento: 'p',
          attrezzatura: 'a',
          createdAt: DateTime.now(),
          unlockedUntil: DateTime.now().subtract(const Duration(days: 1)),
        );
        final exercises = [veryOldExpired, recentExpired, makeEx()];

        final svc = CustomExerciseLimitService(
          repository: FakeCustomExerciseRepository(exercises: exercises),
          maxCustomSingleExercises: 5,
        );

        await svc.cleanupExpiredExercises(daysAfterExpiration: 30);

        // 'old-expired' should be deleted; 'recent-expired' kept; permanent kept
        final remaining = exercises.map((e) => e.id).toList();
        expect(remaining, isNot(contains('old-expired')));
        expect(remaining, contains('recent-expired'));
        expect(remaining, contains('ex-001'));
      });
    });
  });

  // =========================================================================
  // LimitCheckResult
  // =========================================================================
  group('LimitCheckResult', () {
    test('toString contains relevant info', () {
      const result = LimitCheckResult(
        status: LimitStatus.available,
        remainingSlots: 3,
        permanentCount: 2,
        expiredCount: 1,
      );
      expect(result.toString(), contains('LimitCheckResult'));
      expect(result.toString(), contains('available'));
    });

    test('canCreatePermanent=true for available and unlimited', () {
      const available = LimitCheckResult(
        status: LimitStatus.available,
        remainingSlots: 2,
        permanentCount: 3,
        expiredCount: 0,
      );
      const unlimited = LimitCheckResult(
        status: LimitStatus.unlimited,
        remainingSlots: 999,
        permanentCount: 0,
        expiredCount: 0,
      );
      expect(available.canCreatePermanent, isTrue);
      expect(unlimited.canCreatePermanent, isTrue);
    });

    test('canCreatePermanent=false for requiresAd', () {
      const result = LimitCheckResult(
        status: LimitStatus.requiresAd,
        remainingSlots: 0,
        permanentCount: 5,
        expiredCount: 0,
      );
      expect(result.canCreatePermanent, isFalse);
      expect(result.requiresAd, isTrue);
      expect(result.isPremium, isFalse);
    });
  });

  // =========================================================================
  // CustomExerciseAdapter (from .g.dart)
  // =========================================================================
  group('CustomExerciseAdapter', () {
    test('typeId is 75', () {
      final adapter = CustomExerciseAdapter();
      expect(adapter.typeId, 75);
    });

    test('equality based on typeId', () {
      final a = CustomExerciseAdapter();
      final b = CustomExerciseAdapter();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
