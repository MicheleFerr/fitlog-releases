import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late MockStreakRepository mockRepository;

  setUp(() {
    mockRepository = MockStreakRepository();
  });

  test('should provide current streak from repository', () async {
    const expectedStreak = WorkoutStreak(
      currentStreak: 5,
      longestStreak: 10,
      isActive: true,
      lastWorkoutDate: null,
      totalWorkoutDays: 50,
    );

    when(() => mockRepository.getCurrentStreak())
        .thenAnswer((_) async => expectedStreak);

    final container = ProviderContainer(
      overrides: [
        streakRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    final streak = await container.read(currentStreakProvider.future);

    expect(streak.currentStreak, 5);
    expect(streak.isActive, true);
    expect(streak.longestStreak, 10);
    expect(streak.totalWorkoutDays, 50);
  });

  test('should handle repository returning empty streak', () async {
    const expectedStreak = WorkoutStreak(
      currentStreak: 0,
      longestStreak: 0,
      isActive: false,
      lastWorkoutDate: null,
      totalWorkoutDays: 0,
    );

    when(() => mockRepository.getCurrentStreak())
        .thenAnswer((_) async => expectedStreak);

    final container = ProviderContainer(
      overrides: [
        streakRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    final streak = await container.read(currentStreakProvider.future);

    expect(streak.currentStreak, 0);
    expect(streak.isActive, false);
  });
}
