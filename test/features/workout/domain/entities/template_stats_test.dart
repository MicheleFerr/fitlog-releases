import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';

void main() {
  group('TemplateStats', () {
    group('constructor', () {
      test('creates with defaults', () {
        const stats = TemplateStats();

        expect(stats.lastPerformed, isNull);
        expect(stats.totalCompletions, 0);
        expect(stats.avgDuration, isNull);
      });

      test('creates with all fields', () {
        final lastPerformed = DateTime(2026, 2, 20);
        const duration = Duration(minutes: 45);

        final stats = TemplateStats(
          lastPerformed: lastPerformed,
          totalCompletions: 10,
          avgDuration: duration,
        );

        expect(stats.lastPerformed, lastPerformed);
        expect(stats.totalCompletions, 10);
        expect(stats.avgDuration, duration);
      });
    });

    group('empty factory', () {
      test('creates with null lastPerformed', () {
        final stats = TemplateStats.empty();
        expect(stats.lastPerformed, isNull);
      });

      test('creates with 0 completions', () {
        final stats = TemplateStats.empty();
        expect(stats.totalCompletions, 0);
      });

      test('creates with null avgDuration', () {
        final stats = TemplateStats.empty();
        expect(stats.avgDuration, isNull);
      });
    });

    group('isFresh', () {
      test('true when lastPerformed is today', () {
        final stats = TemplateStats(lastPerformed: DateTime.now());
        expect(stats.isFresh, isTrue);
      });

      test('true when lastPerformed is 1 day ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(stats.isFresh, isTrue);
      });

      test('true when lastPerformed is 6 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 6)),
        );
        expect(stats.isFresh, isTrue);
      });

      test('false when lastPerformed is 7 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 7)),
        );
        expect(stats.isFresh, isFalse);
      });

      test('false when lastPerformed is 14 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(stats.isFresh, isFalse);
      });

      test('false when lastPerformed is null', () {
        const stats = TemplateStats();
        expect(stats.isFresh, isFalse);
      });
    });

    group('needsAttention', () {
      test('true when lastPerformed is 14 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(stats.needsAttention, isTrue);
      });

      test('true when lastPerformed is 30 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(stats.needsAttention, isTrue);
      });

      test('false when lastPerformed is 13 days ago', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 13)),
        );
        expect(stats.needsAttention, isFalse);
      });

      test('false when lastPerformed is today', () {
        final stats = TemplateStats(lastPerformed: DateTime.now());
        expect(stats.needsAttention, isFalse);
      });

      test('false when lastPerformed is null', () {
        const stats = TemplateStats();
        expect(stats.needsAttention, isFalse);
      });
    });

    group('isNew', () {
      test('true when lastPerformed is null', () {
        const stats = TemplateStats();
        expect(stats.isNew, isTrue);
      });

      test('true for empty factory', () {
        final stats = TemplateStats.empty();
        expect(stats.isNew, isTrue);
      });

      test('false when lastPerformed is set', () {
        final stats = TemplateStats(lastPerformed: DateTime.now());
        expect(stats.isNew, isFalse);
      });

      test('false even when lastPerformed is very old', () {
        final stats = TemplateStats(
          lastPerformed: DateTime(2020, 1, 1),
        );
        expect(stats.isNew, isFalse);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final date = DateTime(2026, 2, 15);
        const duration = Duration(minutes: 30);

        final a = TemplateStats(
          lastPerformed: date,
          totalCompletions: 5,
          avgDuration: duration,
        );
        final b = TemplateStats(
          lastPerformed: date,
          totalCompletions: 5,
          avgDuration: duration,
        );

        expect(a, equals(b));
      });

      test('not equal when lastPerformed differs', () {
        final a = TemplateStats(lastPerformed: DateTime(2026, 1, 1));
        final b = TemplateStats(lastPerformed: DateTime(2026, 2, 2));

        expect(a, isNot(equals(b)));
      });

      test('not equal when totalCompletions differs', () {
        const a = TemplateStats(totalCompletions: 5);
        const b = TemplateStats(totalCompletions: 10);

        expect(a, isNot(equals(b)));
      });

      test('not equal when avgDuration differs', () {
        const a = TemplateStats(avgDuration: Duration(minutes: 30));
        const b = TemplateStats(avgDuration: Duration(minutes: 60));

        expect(a, isNot(equals(b)));
      });

      test('equal when both have null lastPerformed and avgDuration', () {
        const a = TemplateStats(totalCompletions: 0);
        const b = TemplateStats(totalCompletions: 0);

        expect(a, equals(b));
      });

      test('identical instance is equal', () {
        final stats = TemplateStats(lastPerformed: DateTime.now());
        expect(stats, equals(stats));
      });

      test('not equal to non-TemplateStats', () {
        const stats = TemplateStats();
        expect(stats == 'not stats', isFalse);
      });
    });

    group('hashCode', () {
      test('same for equal instances', () {
        final date = DateTime(2026, 2, 15);
        final a = TemplateStats(
          lastPerformed: date,
          totalCompletions: 5,
          avgDuration: const Duration(minutes: 30),
        );
        final b = TemplateStats(
          lastPerformed: date,
          totalCompletions: 5,
          avgDuration: const Duration(minutes: 30),
        );

        expect(a.hashCode, equals(b.hashCode));
      });

      test('can be used in Set', () {
        final date = DateTime(2026, 2, 15);
        final a = TemplateStats(lastPerformed: date, totalCompletions: 5);
        final b = TemplateStats(lastPerformed: date, totalCompletions: 5);
        const c = TemplateStats(totalCompletions: 10);

        final set = {a, b, c};
        expect(set.length, 2);
      });
    });

    group('copyWith', () {
      test('copies with new lastPerformed', () {
        const original = TemplateStats(totalCompletions: 5);
        final newDate = DateTime(2026, 3, 1);
        final copied = original.copyWith(lastPerformed: () => newDate);

        expect(copied.lastPerformed, newDate);
        expect(copied.totalCompletions, 5);
        expect(copied.avgDuration, isNull);
      });

      test('copies with null lastPerformed to clear it', () {
        final original = TemplateStats(
          lastPerformed: DateTime(2026, 2, 15),
          totalCompletions: 5,
        );
        final copied = original.copyWith(lastPerformed: () => null);

        expect(copied.lastPerformed, isNull);
        expect(copied.totalCompletions, 5);
      });

      test('copies with new totalCompletions', () {
        const original = TemplateStats(totalCompletions: 5);
        final copied = original.copyWith(totalCompletions: 10);

        expect(copied.totalCompletions, 10);
      });

      test('copies with new avgDuration', () {
        const original = TemplateStats();
        final copied = original.copyWith(
          avgDuration: () => const Duration(minutes: 45),
        );

        expect(copied.avgDuration, const Duration(minutes: 45));
      });

      test('copies with null avgDuration to clear it', () {
        const original = TemplateStats(avgDuration: Duration(minutes: 30));
        final copied = original.copyWith(avgDuration: () => null);

        expect(copied.avgDuration, isNull);
      });

      test('preserves all fields when no arguments', () {
        final original = TemplateStats(
          lastPerformed: DateTime(2026, 2, 15),
          totalCompletions: 7,
          avgDuration: const Duration(minutes: 40),
        );
        final copied = original.copyWith();

        expect(copied.lastPerformed, original.lastPerformed);
        expect(copied.totalCompletions, original.totalCompletions);
        expect(copied.avgDuration, original.avgDuration);
      });

      test('preserves lastPerformed when not specified in copyWith', () {
        final original = TemplateStats(
          lastPerformed: DateTime(2026, 2, 15),
          totalCompletions: 5,
        );
        final copied = original.copyWith(totalCompletions: 10);

        expect(copied.lastPerformed, original.lastPerformed);
      });

      test('preserves avgDuration when not specified in copyWith', () {
        const original = TemplateStats(
          totalCompletions: 5,
          avgDuration: Duration(minutes: 30),
        );
        final copied = original.copyWith(totalCompletions: 10);

        expect(copied.avgDuration, const Duration(minutes: 30));
      });
    });

    group('toString', () {
      test('includes all fields', () {
        final stats = TemplateStats(
          lastPerformed: DateTime(2026, 2, 15),
          totalCompletions: 5,
          avgDuration: const Duration(minutes: 30),
        );

        final str = stats.toString();

        expect(str, contains('TemplateStats'));
        expect(str, contains('lastPerformed'));
        expect(str, contains('totalCompletions'));
        expect(str, contains('avgDuration'));
        expect(str, contains('5'));
      });
    });

    group('combined scenarios', () {
      test('new template: isNew true, isFresh false, needsAttention false', () {
        final stats = TemplateStats.empty();

        expect(stats.isNew, isTrue);
        expect(stats.isFresh, isFalse);
        expect(stats.needsAttention, isFalse);
      });

      test('recently used: isNew false, isFresh true, needsAttention false', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 2)),
          totalCompletions: 3,
        );

        expect(stats.isNew, isFalse);
        expect(stats.isFresh, isTrue);
        expect(stats.needsAttention, isFalse);
      });

      test('stale template: isNew false, isFresh false, needsAttention true', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 20)),
          totalCompletions: 10,
        );

        expect(stats.isNew, isFalse);
        expect(stats.isFresh, isFalse);
        expect(stats.needsAttention, isTrue);
      });

      test('moderately old: isNew false, isFresh false, needsAttention false', () {
        final stats = TemplateStats(
          lastPerformed: DateTime.now().subtract(const Duration(days: 10)),
          totalCompletions: 5,
        );

        expect(stats.isNew, isFalse);
        expect(stats.isFresh, isFalse);
        expect(stats.needsAttention, isFalse);
      });
    });
  });
}
