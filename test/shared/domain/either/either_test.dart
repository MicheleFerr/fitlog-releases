/// Either type tests - Left, Right, map, flatMap, fold, helpers.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';

void main() {
  group('Left', () {
    test('isLeft true, isRight false', () {
      const result = Left<String, int>('error');
      expect(result.isLeft, isTrue);
      expect(result.isRight, isFalse);
    });

    test('leftOrNull returns value', () {
      const result = Left<String, int>('error');
      expect(result.leftOrNull, 'error');
    });

    test('rightOrNull returns null', () {
      const result = Left<String, int>('error');
      expect(result.rightOrNull, isNull);
    });

    test('fold calls onLeft', () {
      const result = Left<String, int>('error');
      final folded = result.fold(
        (l) => 'left: $l',
        (r) => 'right: $r',
      );
      expect(folded, 'left: error');
    });

    test('getOrThrow throws', () {
      const result = Left<String, int>('error');
      expect(() => result.getOrThrow(), throwsException);
    });

    test('getOrElse returns default', () {
      const result = Left<String, int>('error');
      expect(result.getOrElse(() => 42), 42);
    });

    test('map returns Left unchanged', () {
      const result = Left<String, int>('error');
      final mapped = result.map((r) => r * 2);
      expect(mapped.isLeft, isTrue);
      expect(mapped.leftOrNull, 'error');
    });

    test('mapLeft transforms value', () {
      const result = Left<String, int>('error');
      final mapped = result.mapLeft((l) => l.toUpperCase());
      expect(mapped.leftOrNull, 'ERROR');
    });

    test('flatMap returns Left unchanged', () {
      const result = Left<String, int>('error');
      final chained = result.flatMap((r) => Right<String, String>('$r'));
      expect(chained.isLeft, isTrue);
    });

    test('toString', () {
      const result = Left<String, int>('error');
      expect(result.toString(), 'Left(error)');
    });

    test('equality', () {
      const a = Left<String, int>('error');
      const b = Left<String, int>('error');
      expect(a, equals(b));
    });
  });

  group('Right', () {
    test('isRight true, isLeft false', () {
      const result = Right<String, int>(42);
      expect(result.isRight, isTrue);
      expect(result.isLeft, isFalse);
    });

    test('rightOrNull returns value', () {
      const result = Right<String, int>(42);
      expect(result.rightOrNull, 42);
    });

    test('leftOrNull returns null', () {
      const result = Right<String, int>(42);
      expect(result.leftOrNull, isNull);
    });

    test('fold calls onRight', () {
      const result = Right<String, int>(42);
      final folded = result.fold(
        (l) => 'left: $l',
        (r) => 'right: $r',
      );
      expect(folded, 'right: 42');
    });

    test('getOrThrow returns value', () {
      const result = Right<String, int>(42);
      expect(result.getOrThrow(), 42);
    });

    test('getOrElse returns value', () {
      const result = Right<String, int>(42);
      expect(result.getOrElse(() => 0), 42);
    });

    test('map transforms value', () {
      const result = Right<String, int>(21);
      final mapped = result.map((r) => r * 2);
      expect(mapped.rightOrNull, 42);
    });

    test('mapLeft returns Right unchanged', () {
      const result = Right<String, int>(42);
      final mapped = result.mapLeft((l) => l.toUpperCase());
      expect(mapped.isRight, isTrue);
      expect(mapped.rightOrNull, 42);
    });

    test('flatMap chains operations', () {
      const result = Right<String, int>(21);
      final chained = result.flatMap((r) => Right<String, int>(r * 2));
      expect(chained.rightOrNull, 42);
    });

    test('flatMap can return Left', () {
      const result = Right<String, int>(21);
      final chained =
          result.flatMap<int>((r) => const Left<String, int>('failed'));
      expect(chained.isLeft, isTrue);
    });

    test('toString', () {
      const result = Right<String, int>(42);
      expect(result.toString(), 'Right(42)');
    });

    test('equality', () {
      const a = Right<String, int>(42);
      const b = Right<String, int>(42);
      expect(a, equals(b));
    });
  });

  group('Helper functions', () {
    test('left() creates Left', () {
      final result = left<String, int>('error');
      expect(result.isLeft, isTrue);
    });

    test('right() creates Right', () {
      final result = right<String, int>(42);
      expect(result.isRight, isTrue);
    });
  });

  group('EitherAsync', () {
    test('mapAsync on Right', () async {
      final future = Future.value(right<String, int>(21));
      final result = await future.mapAsync((r) async => r * 2);
      expect(result.rightOrNull, 42);
    });

    test('mapAsync on Left', () async {
      final future = Future.value(left<String, int>('error'));
      final result = await future.mapAsync((r) async => r * 2);
      expect(result.isLeft, isTrue);
    });

    test('flatMapAsync on Right', () async {
      final future = Future.value(right<String, int>(21));
      final result = await future.flatMapAsync(
        (r) async => right<String, int>(r * 2),
      );
      expect(result.rightOrNull, 42);
    });

    test('flatMapAsync on Left', () async {
      final future = Future.value(left<String, int>('error'));
      final result = await future.flatMapAsync(
        (r) async => right<String, int>(r * 2),
      );
      expect(result.isLeft, isTrue);
    });
  });
}
