/// 🧪 Integration Test: Tier Limits End-to-End Flow
///
/// Tests complete flow: TierEntitlementsProvider → Service → Repository
/// Verifies that tier limits work correctly in realistic scenarios.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/services/custom_exercise_limit_service.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomExerciseRepository extends Mock
    implements CustomExerciseRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CustomExercise(
      id: 'test',
      nome: 'Test',
      baseExerciseId: null,
      focus: [],
      muscoliSecondari: [],
      tipoEsercizio: 'compound',
      patternMovimento: 'push',
      attrezzatura: 'barbell',
      createdAt: DateTime.now(),
      userId: 'user-123',
    ));
  });

  group('Integration: Free User Tier Progression', () {
    test('Starter (0 XP) → Bronze (100 XP) should increase limits', () {
      // STEP 1: User starts with Starter tier (0 XP)
      var container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      var entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 3);
      expect(entitlements.maxTemplates, 4);

      container.dispose();

      // STEP 2: User gains XP and reaches Bronze tier (100 XP)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.bronze),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 5,
          reason: 'Bronze tier should increase custom exercises from 3 to 5');
      expect(entitlements.maxTemplates, 4,
          reason: 'Templates remain at 4 for Bronze');

      container.dispose();
    });

    test('Bronze → Silver → Gold → Platinum progression', () {
      final tiers = [
        UserTier.bronze,
        UserTier.silver,
        UserTier.gold,
        UserTier.platinum
      ];
      final expectedExercises = [5, 7, 10, 999];
      final expectedTemplates = [4, 5, 5, 7];

      for (var i = 0; i < tiers.length; i++) {
        final container = ProviderContainer(
          overrides: [
            userTierProvider.overrideWithValue(tiers[i]),
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()
              ..state = AsyncValue.data(
                UserProfile(
                  uid: 'test-user',
                  email: 'test@example.com',
                  displayName: 'Test User',
                  accountTier: AccountTier.free,
                  createdAt: DateTime.now(),
                ),
              )),
          ],
        );

        final entitlements = container.read(tierEntitlementsProvider);

        expect(
          entitlements.maxCustomSingleExercises,
          expectedExercises[i],
          reason: '${tiers[i].name} should have ${expectedExercises[i]} exercises',
        );

        expect(
          entitlements.maxTemplates,
          expectedTemplates[i],
          reason: '${tiers[i].name} should have ${expectedTemplates[i]} templates',
        );

        container.dispose();
      }
    });
  });

  group('Integration: Premium Upgrade Flow', () {
    test('Free Starter → Premium should unlock unlimited', () {
      // STEP 1: User with Starter tier + Free account
      var container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free, // FREE
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      var entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 3);
      expect(entitlements.maxTemplates, 4);

      container.dispose();

      // STEP 2: User purchases Premium (XP tier stays Starter)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter), // Same XP
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.premium, // PREMIUM!
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 999,
          reason: 'Premium should unlock unlimited exercises');
      expect(entitlements.maxTemplates, 999,
          reason: 'Premium should unlock unlimited templates');

      container.dispose();
    });

    test('Free Platinum → Premium should keep 999 unlimited', () {
      // User with high XP (Platinum) decides to buy Premium anyway
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.platinum),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.premium,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Both Platinum AND Premium give 999, should be 999 (not double!)
      expect(entitlements.maxCustomSingleExercises, 999);
      expect(entitlements.maxTemplates, 999);

      container.dispose();
    });
  });

  group('Integration: Custom Exercise Creation Flow', () {
    late MockCustomExerciseRepository mockRepository;

    setUp(() {
      mockRepository = MockCustomExerciseRepository();
    });

    test('Starter user can create 3 exercises, then blocked', () async {
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
          customExerciseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);
      final service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: entitlements.maxCustomSingleExercises,
      );

      // Simulate creating 3 exercises
      for (var i = 0; i < 3; i++) {
        when(() => mockRepository.getPermanentCount())
            .thenAnswer((_) async => right(i));

        final canCreate = await service.canCreatePermanent();
        expect(canCreate, true, reason: 'Should allow exercise ${i + 1}/3');
      }

      // After 3 exercises, should be blocked
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));

      final canCreateMore = await service.canCreatePermanent();
      expect(canCreateMore, false, reason: 'Should block at 3/3 limit');

      final requiresAd = await service.requiresAdForNext();
      expect(requiresAd, true, reason: 'Should require ad at limit');

      container.dispose();
    });

    test('Premium user can create unlimited exercises', () async {
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter), // Low XP
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.premium, // Premium!
                createdAt: DateTime.now(),
              ),
            )),
          customExerciseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);
      final service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: entitlements.maxCustomSingleExercises,
      );

      // Simulate already having 100 exercises
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(100));

      final canCreate = await service.canCreatePermanent();
      expect(canCreate, true, reason: 'Premium can create unlimited');

      final requiresAd = await service.requiresAdForNext();
      expect(requiresAd, false, reason: 'Premium never needs ads');

      container.dispose();
    });
  });

  group('Integration: Ad-Unlock Flow', () {
    late MockCustomExerciseRepository mockRepository;

    setUp(() {
      mockRepository = MockCustomExerciseRepository();
    });

    test('Starter user at limit creates temporary exercise after ad', () async {
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
          customExerciseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);
      final service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: entitlements.maxCustomSingleExercises,
      );

      // User at limit (3/3)
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));

      final newExercise = CustomExercise(
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

      // Prepare exercise (should be temporary because limit reached)
      final prepared = await service.prepareExerciseForSave(newExercise);

      expect(prepared.isPermanent, false);
      expect(prepared.unlockedUntil, isNotNull);

      // Verify 7-day expiry
      final daysUntilExpiry =
          prepared.unlockedUntil!.difference(DateTime.now()).inDays;
      expect(daysUntilExpiry, equals(7));

      container.dispose();
    });

    test('User deletes permanent exercise, then temporary becomes permanent', () async {
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
          customExerciseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);
      final service = CustomExerciseLimitService(
        repository: mockRepository,
        maxCustomSingleExercises: entitlements.maxCustomSingleExercises,
      );

      final temporaryExercise = CustomExercise(
        id: 'temp-123',
        nome: 'Temporary Exercise',
        baseExerciseId: null,
        focus: [],
        muscoliSecondari: [],
        tipoEsercizio: 'compound',
        patternMovimento: 'push',
        attrezzatura: 'barbell',
        createdAt: DateTime.now(),
        unlockedUntil: DateTime.now().add(const Duration(days: 5)),
        userId: 'user-123',
      );

      // STEP 1: User at limit (3/3 permanent)
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(3));
      when(() => mockRepository.getById('temp-123'))
          .thenAnswer((_) async => right(temporaryExercise));

      var canCreate = await service.canCreatePermanent();
      expect(canCreate, false, reason: 'At limit, cannot create permanent');

      // STEP 2: User deletes one permanent exercise (now 2/3)
      when(() => mockRepository.getPermanentCount())
          .thenAnswer((_) async => right(2));

      canCreate = await service.canCreatePermanent();
      expect(canCreate, true, reason: 'Slot freed, can create permanent');

      // STEP 3: User watches ad for temporary exercise → converts to permanent
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => right(null));

      await service.onAdWatched('temp-123');

      // Verify it was converted to permanent
      verify(() => mockRepository.update(any(
            that: predicate<CustomExercise>(
              (e) => e.id == 'temp-123' && e.unlockedUntil == null,
            ),
          ))).called(1);

      container.dispose();
    });
  });

  group('Integration: Realistic User Journeys', () {
    test('Journey: New user → grind XP → buy Premium', () async {
      late ProviderContainer container;
      late TierEntitlements entitlements;

      // DAY 1: New user (Starter tier, 0 XP)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 3);
      expect(entitlements.maxTemplates, 4);
      container.dispose();

      // WEEK 2: User grinds to Bronze (100 XP)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.bronze),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 5);
      container.dispose();

      // MONTH 1: User grinds to Silver (500 XP)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.silver),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.free,
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 7);
      container.dispose();

      // MONTH 2: User loves the app, buys Premium (still Silver XP)
      container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.silver),
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.premium, // Premium!
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      entitlements = container.read(tierEntitlementsProvider);
      expect(entitlements.maxCustomSingleExercises, 999,
          reason: 'Premium unlocks unlimited');
      expect(entitlements.maxTemplates, 999);
      container.dispose();
    });

    test('Journey: Impatient user buys Premium immediately', () {
      // DAY 1: New user immediately buys Premium (Starter XP)
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter), // 0 XP
          userProfileProvider.overrideWith((ref) => UserProfileNotifier()
            ..state = AsyncValue.data(
              UserProfile(
                uid: 'test-user',
                email: 'test@example.com',
                displayName: 'Test User',
                accountTier: AccountTier.premium, // Premium from day 1
                createdAt: DateTime.now(),
              ),
            )),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Should get unlimited immediately
      expect(entitlements.maxCustomSingleExercises, 999);
      expect(entitlements.maxTemplates, 999);

      container.dispose();
    });
  });
}
