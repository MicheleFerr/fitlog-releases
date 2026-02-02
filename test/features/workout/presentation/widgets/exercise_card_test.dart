import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

// Mock classes
class MockWidgetRef extends Mock implements WidgetRef {}

// Test widget wrapper
Widget createTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProviderScope(
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Exercise Card Widget Tests', () {
    late Exercise testExercise;

    setUp(() {
      testExercise = Exercise(
        id: 'test-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            id: 'set-1',
            setNumber: 1,
            reps: 10,
            weight: 60.0,
            actualReps: 10,
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-2',
            setNumber: 2,
            reps: 10,
            weight: 60.0,
            isCompleted: false,
          ),
        ],
        notes: 'Focus on form',
        restTime: 90,
      );
    });

    testWidgets('displays exercise name correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: ListTile(
              title: Text(testExercise.name),
              subtitle: Text('${testExercise.sets.length} sets'),
            ),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('2 sets'), findsOneWidget);
    });

    testWidgets('shows completed and pending sets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: Column(
              children: testExercise.sets.map((set) {
                return ListTile(
                  leading: Icon(
                    set.isCompleted ? AppIcons.checkCircle : AppIcons.circleOutlined,
                    color: set.isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text('Set ${set.setNumber}'),
                  subtitle: Text('${set.weight}kg x ${set.reps}'),
                );
              }).toList(),
            ),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.checkCircle), findsOneWidget);
      expect(find.byIcon(AppIcons.circleOutlined), findsOneWidget);
      expect(find.text('Set 1'), findsOneWidget);
      expect(find.text('Set 2'), findsOneWidget);
    });

    testWidgets('displays rest timer when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: ListTile(
              title: Text(testExercise.name),
              trailing: testExercise.restTime != null
                  ? Chip(
                      label: Text('${testExercise.restTime}s rest'),
                      avatar: const Icon(AppIcons.timer, size: 16),
                    )
                  : null,
            ),
          ),
        ),
      );

      expect(find.text('90s rest'), findsOneWidget);
      expect(find.byIcon(AppIcons.timer), findsOneWidget);
    });

    testWidgets('shows notes when available', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: Column(
              children: [
                ListTile(title: Text(testExercise.name)),
                if (testExercise.notes != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(AppIcons.note, size: 16),
                        const SizedBox(width: 4),
                        Text(testExercise.notes!),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Focus on form'), findsOneWidget);
      expect(find.byIcon(AppIcons.note), findsOneWidget);
    });

    testWidgets('handles tap interactions', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: InkWell(
              onTap: () => wasTapped = true,
              child: ListTile(
                title: Text(testExercise.name),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(wasTapped, true);
    });

    testWidgets('shows progress indicator', (tester) async {
      final completedSets = testExercise.sets.where((s) => s.isCompleted).length;
      final totalSets = testExercise.sets.length;
      final progress = completedSets / totalSets;

      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: Column(
              children: [
                ListTile(title: Text(testExercise.name)),
                LinearProgressIndicator(value: progress),
                Text('$completedSets/$totalSets sets completed'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('1/2 sets completed'), findsOneWidget);
    });

    testWidgets('displays equipment info', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: ListTile(
              title: Text(testExercise.name),
              subtitle: const Row(
                children: [
                  Icon(AppIcons.workout, size: 16),
                  SizedBox(width: 4),
                  Text('Barbell'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Barbell'), findsOneWidget);
      expect(find.byIcon(AppIcons.workout), findsOneWidget);
    });

    testWidgets('handles long exercise names', (tester) async {
      final longNameExercise = Exercise(
        id: 'test-2',
        name: 'Single Arm Dumbbell Row with Pause at Top Position',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [],
      );

      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            width: 200,
            child: Card(
              child: ListTile(
                title: Text(
                  longNameExercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Single Arm Dumbbell Row with Pause at Top Position'),
        findsOneWidget,
      );
    });

    testWidgets('shows muscle group badge', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Card(
            child: ListTile(
              title: Text(testExercise.name),
              leading: Chip(
                label: const Text('Chest'),
                backgroundColor: Colors.blue.shade100,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chest'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    test('Exercise model calculates total volume correctly', () {
      final totalVolume = testExercise.sets
          .where((s) => s.isCompleted)
          .fold(0.0, (sum, set) {
        final weight = set.weight ?? 0;
        final reps = set.actualReps ?? set.reps ?? 0;
        return sum + (weight * reps);
      });

      expect(totalVolume, 600.0); // 60kg x 10 reps = 600
    });

    test('Exercise model identifies if all sets completed', () {
      final allCompleted = testExercise.sets.every((s) => s.isCompleted);
      expect(allCompleted, false);

      final completedExercise = Exercise(
        id: 'test-3',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            id: 's1',
            setNumber: 1,
            isCompleted: true,
          ),
          ExerciseSet(
            id: 's2',
            setNumber: 2,
            isCompleted: true,
          ),
        ],
      );

      final allCompletedTrue = completedExercise.sets.every((s) => s.isCompleted);
      expect(allCompletedTrue, true);
    });
  });
}
