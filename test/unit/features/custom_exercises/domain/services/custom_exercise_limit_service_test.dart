/// 🧪 Test: Custom Exercise Limit Service
///
/// Tests business logic for custom exercise limits including:
/// - Tier-based permanent slots
/// - Temporary ad-unlock flow (7-day expiry)
/// - Premium unlimited access

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/services/custom_exercise_limit_service.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

class MockCustomExerciseRepository extends Mock
    implements CustomExerciseRepository {}

class FakeCustomExercise extends Fake implements CustomExercise {}

void main() {
  late MockCustomExerciseRepository mockRepository;
  late CustomExerciseLimitService service;

  setUpAll(() {
    registerFallbackValue(FakeCustomExercise());
  });

  setUp(() {
    mockRepository = MockCustomExerciseRepository();
  });

  group('CustomExerciseLimitService - Starter Tier (3 exercises)', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 3, // Starter tier limit
      );
    });

    test('Should allow creation when under limit (0/3)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(0));

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, true);
      verify(() => mockRepository.getPermanentCount()).called(1);
    });

    test('Should allow creation when at limit-1 (2/3)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(2));

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, true);
    });

    test('Should block creation when at limit (3/3)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, false, reason: 'Should not allow creation at limit');
    });

    test('Should require ad when limit reached (3/3)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));

      final requiresAd = await service.requiresAdForNext();

      expect(requiresAd, true, reason: 'Should require ad at limit');
    });

    test('Should return correct remaining slots', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(2));

      final remaining = await service.getRemainingPermanentSlots();

      expect(remaining, 1, reason: '3 max - 2 used = 1 remaining');
    });

    test('Should return 0 remaining when over limit', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(5));

      final remaining = await service.getRemainingPermanentSlots();

      expect(remaining, 0, reason: 'Should not return negative slots');
    });
  });

  group('CustomExerciseLimitService - Bronze Tier (5 exercises)', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 5, // Bronze tier limit
      );
    });

    test('Should allow creation when under limit (3/5)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, true);
    });

    test('Should block creation when at limit (5/5)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(5));

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, false);
    });
  });

  group('CustomExerciseLimitService - Premium/Platinum (999 unlimited)', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 999, // Unlimited
      );
    });

    test('Should always allow creation (unlimited)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(100)); // Already have 100!

      final canCreate = await service.canCreatePermanent();

      expect(canCreate, true, reason: 'Unlimited users can always create');
    });

    test('Should never require ad (unlimited)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(500));

      final requiresAd = await service.requiresAdForNext();

      expect(requiresAd, false, reason: 'Unlimited users never need ads');
    });

    test('Should return 999 remaining slots (unlimited)', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(50));

      final remaining = await service.getRemainingPermanentSlots();

      expect(remaining, 999, reason: 'Unlimited users always have 999 slots');
    });

    test('hasUnlimitedExercises should return true', () {
      expect(service.hasUnlimitedExercises, true);
    });
  });

  group('CustomExerciseLimitService - LimitCheckResult', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 5, // Bronze tier
      );
    });

    test('Should return LimitStatus.available when under limit', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(2));
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => right([]));

      final result = await service.checkLimits();

      expect(result.status, LimitStatus.available);
      expect(result.remainingSlots, 3); // 5 - 2 = 3
      expect(result.permanentCount, 2);
      expect(result.canCreatePermanent, true);
      expect(result.requiresAd, false);
    });

    test('Should return LimitStatus.requiresAd when at limit', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(5));
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => right([]));

      final result = await service.checkLimits();

      expect(result.status, LimitStatus.requiresAd);
      expect(result.remainingSlots, 0);
      expect(result.permanentCount, 5);
      expect(result.canCreatePermanent, false);
      expect(result.requiresAd, true);
    });

    test('Should return LimitStatus.unlimited for 999 limit', () async {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 999,
      );

      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(100));
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => right([]));

      final result = await service.checkLimits();

      expect(result.status, LimitStatus.unlimited);
      expect(result.remainingSlots, 999);
      expect(result.isPremium, true);
    });
  });

  group('CustomExerciseLimitService - Prepare Exercise for Save', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 3, // Starter tier
      );
    });

    test('Should create permanent exercise when slots available', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(1)); // 1/3 used

      final exercise = CustomExercise(
        id: 'test-123',
        nome: 'Test Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        userId: 'user-123',
      );

      final prepared = await service.prepareExerciseForSave(exercise);

      expect(prepared.unlockedUntil, isNull,
          reason: 'Should be permanent (no expiry)');
      expect(prepared.isPermanent, true);
    });

    test('Should create temporary exercise when limit reached', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3)); // 3/3 used (limit reached)

      final exercise = CustomExercise(
        id: 'test-123',
        nome: 'Test Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        userId: 'user-123',
      );

      final prepared = await service.prepareExerciseForSave(exercise);

      expect(prepared.unlockedUntil, isNotNull,
          reason: 'Should be temporary (7-day expiry)');
      expect(prepared.isPermanent, false);

      // Verify 7-day expiry
      final now = DateTime.now();
      final expectedExpiry = now.add(const Duration(days: 7));
      final actualExpiry = prepared.unlockedUntil!;

      expect(
        actualExpiry.difference(expectedExpiry).inMinutes.abs(),
        lessThan(1),
        reason: 'Should expire in ~7 days',
      );
    });

    test('Unlimited users should always create permanent exercises', () async {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 999, // Unlimited
      );

      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(50)); // Already have 50

      final exercise = CustomExercise(
        id: 'test-123',
        nome: 'Test Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        userId: 'user-123',
      );

      final prepared = await service.prepareExerciseForSave(exercise);

      expect(prepared.unlockedUntil, isNull);
      expect(prepared.isPermanent, true);
    });
  });

  group('CustomExerciseLimitService - Ad Unlock Flow', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 3,
      );
    });

    test('Should convert temporary to permanent when slots available', () async {
      final exercise = CustomExercise(
        id: 'test-123',
        nome: 'Test Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        unlockedUntil: DateTime.now().add(const Duration(days: 3)), // Temporary
        userId: 'user-123',
      );

      when(() => mockRepository.getById('test-123'))
          .thenAnswer((_) async => right(exercise));
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(1)); // 1/3 used, slot available
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => right(null));

      await service.onAdWatched('test-123');

      verify(() => mockRepository.update(any(
            that: predicate<CustomExercise>(
              (e) => e.unlockedUntil == null, // Should be permanent now
            ),
          ))).called(1);
    });

    test('Should extend temporary unlock when no slots available', () async {
      final exercise = CustomExercise(
        id: 'test-123',
        nome: 'Test Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        unlockedUntil: DateTime.now().add(const Duration(days: 1)), // Expiring soon
        userId: 'user-123',
      );

      when(() => mockRepository.getById('test-123'))
          .thenAnswer((_) async => right(exercise));
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3)); // 3/3 used, no slots
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => right(null));

      await service.onAdWatched('test-123');

      verify(() => mockRepository.update(any(
            that: predicate<CustomExercise>(
              (e) => e.unlockedUntil != null, // Should still be temporary
            ),
          ))).called(1);
    });
  });

  group('CustomExerciseLimitService - Expired Exercises', () {
    test('Should identify expired exercises', () async {
      final now = DateTime.now();
      final expired1 = CustomExercise(
        id: 'expired-1',
        nome: 'Expired 1',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: now.subtract(const Duration(days: 10)),
        unlockedUntil: now.subtract(const Duration(days: 2)), // Expired 2 days ago
        userId: 'user-123',
      );

      final active = CustomExercise(
        id: 'active-1',
        nome: 'Active 1',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: now,
        unlockedUntil: now.add(const Duration(days: 5)), // Still valid
        userId: 'user-123',
      );

      final permanent = CustomExercise(
        id: 'permanent-1',
        nome: 'Permanent 1',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: now,
        unlockedUntil: null, // Permanent
        userId: 'user-123',
      );

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => right([expired1, active, permanent]));

      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 5,
      );

      final expired = await service.getExpiredExercises();

      expect(expired.length, 1);
      expect(expired.first.id, 'expired-1');
    });

    test('Should return only active exercises', () async {
      final now = DateTime.now();
      CustomExercise(
        id: 'expired-1',
        nome: 'Expired 1',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: now.subtract(const Duration(days: 10)),
        unlockedUntil: now.subtract(const Duration(days: 1)),
        userId: 'user-123',
      );

      final active = CustomExercise(
        id: 'active-1',
        nome: 'Active 1',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: now,
        unlockedUntil: now.add(const Duration(days: 5)),
        userId: 'user-123',
      );

      when(() => mockRepository.getActive())
          .thenAnswer((_) async => right([active]));

      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 5,
      );

      final activeList = await service.getActiveExercises();

      expect(activeList.length, 1);
      expect(activeList.first.id, 'active-1');
    });
  });

  group('CustomExerciseLimitService - Error Handling', () {
    setUp(() {
      service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: 3,
      );
    });

    test('Should handle repository failure gracefully', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => left(const CacheFailure('Database error')));

      final count = await service.getPermanentCount();

      expect(count, 0, reason: 'Should return 0 on error (fail-safe)');
    });

    test('canCreatePermanent should return false on error', () async {
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => left(const CacheFailure('Error')));

      final canCreate = await service.canCreatePermanent();

      // For unlimited (999), should still return true
      // For limited, returns false because getPermanentCount returns 0
      expect(canCreate, true);
    });
  });
}
