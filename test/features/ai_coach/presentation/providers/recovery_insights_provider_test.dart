/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: test
///
/// Unit tests for Recovery Insights Riverpod Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/recovery_insights_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/recovery_insights_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recovery_insights_provider_test.mocks.dart';

/// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([RecoveryInsightsRepository])
void main() {
  late MockRecoveryInsightsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockRecoveryInsightsRepository();

    container = ProviderContainer(
      overrides: [
        recoveryInsightsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('tierStatusesProvider', () {
    test('should call repository getTierStatuses', () async {
      // Arrange
      final mockStatuses = [
        const RecoveryTierStatus(
          tier: RecoveryTier.basic,
          isUnlocked: true,
          currentWorkouts: 10,
          currentDays: 20,
          config: RecoveryTierConfig.basic,
        ),
      ];
      when(mockRepository.getTierStatuses())
          .thenAnswer((_) async => Right(mockStatuses));

      // Act
      final result = await container.read(tierStatusesProvider.future);

      // Assert
      expect(result, mockStatuses);
      verify(mockRepository.getTierStatuses()).called(1);
    });

    test('should throw exception on repository failure', () async {
      // Arrange
      when(mockRepository.getTierStatuses()).thenAnswer(
        (_) async => const Left(CacheFailure('Failed to load tier statuses')),
      );

      // Act & Assert
      expect(
        () => container.read(tierStatusesProvider.future),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.getTierStatuses()).called(1);
    });
  });

  group('tierStatusProvider', () {
    test('should call repository getTierStatus with correct tier', () async {
      // Arrange
      const mockStatus = RecoveryTierStatus(
        tier: RecoveryTier.basic,
        isUnlocked: true,
        currentWorkouts: 10,
        currentDays: 20,
        config: RecoveryTierConfig.basic,
      );
      when(mockRepository.getTierStatus(RecoveryTier.basic))
          .thenAnswer((_) async => const Right(mockStatus));

      // Act
      final result =
          await container.read(tierStatusProvider(RecoveryTier.basic).future);

      // Assert
      expect(result.tier, RecoveryTier.basic);
      verify(mockRepository.getTierStatus(RecoveryTier.basic)).called(1);
    });

    test('should throw exception on repository failure', () async {
      // Arrange
      when(mockRepository.getTierStatus(RecoveryTier.basic)).thenAnswer(
        (_) async => const Left(CacheFailure('Failed to load tier status')),
      );

      // Act & Assert
      expect(
        () => container.read(tierStatusProvider(RecoveryTier.basic).future),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.getTierStatus(RecoveryTier.basic)).called(1);
    });
  });

  group('cacheValidProvider', () {
    test('should return true when cache is valid', () async {
      // Arrange
      when(mockRepository.isCacheValid(RecoveryTier.basic))
          .thenAnswer((_) async => true);

      // Act
      final result =
          await container.read(cacheValidProvider(RecoveryTier.basic).future);

      // Assert
      expect(result, true);
      verify(mockRepository.isCacheValid(RecoveryTier.basic)).called(1);
    });

    test('should return false when cache is invalid', () async {
      // Arrange
      when(mockRepository.isCacheValid(RecoveryTier.basic))
          .thenAnswer((_) async => false);

      // Act
      final result =
          await container.read(cacheValidProvider(RecoveryTier.basic).future);

      // Assert
      expect(result, false);
      verify(mockRepository.isCacheValid(RecoveryTier.basic)).called(1);
    });
  });

  group('clearCacheProvider', () {
    test('should call repository clearCache', () async {
      // Arrange
      when(mockRepository.clearCache())
          .thenAnswer((_) async => const Right(null));

      // Act
      await container.read(clearCacheProvider.future);

      // Assert
      verify(mockRepository.clearCache()).called(1);
    });

    test('should throw exception on repository failure', () async {
      // Arrange
      when(mockRepository.clearCache()).thenAnswer(
        (_) async => const Left(CacheFailure('Failed to clear cache')),
      );

      // Act & Assert
      expect(
        () => container.read(clearCacheProvider.future),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.clearCache()).called(1);
    });
  });

  group('clearTierCacheProvider', () {
    test('should call repository clearTierCache with correct tier', () async {
      // Arrange
      when(mockRepository.clearTierCache(RecoveryTier.basic))
          .thenAnswer((_) async => const Right(null));

      // Act
      await container.read(clearTierCacheProvider(RecoveryTier.basic).future);

      // Assert
      verify(mockRepository.clearTierCache(RecoveryTier.basic)).called(1);
    });

    test('should throw exception on repository failure', () async {
      // Arrange
      when(mockRepository.clearTierCache(RecoveryTier.basic)).thenAnswer(
        (_) async => const Left(CacheFailure('Failed to clear tier cache')),
      );

      // Act & Assert
      expect(
        () => container.read(clearTierCacheProvider(RecoveryTier.basic).future),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.clearTierCache(RecoveryTier.basic)).called(1);
    });
  });
}
