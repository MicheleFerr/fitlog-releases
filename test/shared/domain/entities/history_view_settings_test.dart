/// HistoryViewSettings entity tests - HistoryViewMode, defaults, copyWith, equality.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';

void main() {
  group('HistoryViewMode', () {
    test('has 4 values', () {
      expect(HistoryViewMode.values.length, 4);
      expect(HistoryViewMode.values, contains(HistoryViewMode.list));
      expect(HistoryViewMode.values, contains(HistoryViewMode.compact));
      expect(HistoryViewMode.values, contains(HistoryViewMode.calendar));
      expect(HistoryViewMode.values, contains(HistoryViewMode.stats));
    });
  });

  group('HistoryViewSettings', () {
    test('defaults factory', () {
      final settings = HistoryViewSettings.defaults();
      expect(settings.viewMode, HistoryViewMode.list);
      expect(settings.showThumbnails, isTrue);
      expect(settings.showDuration, isTrue);
      expect(settings.showExerciseCount, isTrue);
    });

    test('copyWith changes single field', () {
      final settings = HistoryViewSettings.defaults();
      final updated = settings.copyWith(viewMode: HistoryViewMode.calendar);
      expect(updated.viewMode, HistoryViewMode.calendar);
      expect(updated.showThumbnails, isTrue);
      expect(updated.showDuration, isTrue);
      expect(updated.showExerciseCount, isTrue);
    });

    test('copyWith changes multiple fields', () {
      final settings = HistoryViewSettings.defaults();
      final updated = settings.copyWith(
        showThumbnails: false,
        showDuration: false,
      );
      expect(updated.showThumbnails, isFalse);
      expect(updated.showDuration, isFalse);
      expect(updated.showExerciseCount, isTrue);
    });

    test('equality', () {
      final a = HistoryViewSettings.defaults();
      final b = HistoryViewSettings.defaults();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality', () {
      final a = HistoryViewSettings.defaults();
      final b = a.copyWith(viewMode: HistoryViewMode.compact);
      expect(a, isNot(equals(b)));
    });

    test('toString', () {
      final settings = HistoryViewSettings.defaults();
      expect(settings.toString(), contains('HistoryViewSettings'));
      expect(settings.toString(), contains('list'));
    });
  });
}
