import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';

void main() {
  group('PaginatedResult', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final result = PaginatedResult<String>(
          items: ['a', 'b', 'c'],
          hasMore: true,
        );

        expect(result.items, ['a', 'b', 'c']);
        expect(result.hasMore, isTrue);
        expect(result.lastDocument, isNull);
        expect(result.totalCount, isNull);
      });

      test('creates instance with all fields', () {
        final result = PaginatedResult<int>(
          items: [1, 2, 3],
          hasMore: false,
          lastDocument: null,
          totalCount: 50,
        );

        expect(result.items, [1, 2, 3]);
        expect(result.hasMore, isFalse);
        expect(result.totalCount, 50);
      });
    });

    group('empty factory', () {
      test('creates empty result with no items', () {
        final result = PaginatedResult<String>.empty();

        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
        expect(result.lastDocument, isNull);
        expect(result.totalCount, isNull);
      });

      test('works with different types', () {
        final intResult = PaginatedResult<int>.empty();
        final stringResult = PaginatedResult<String>.empty();

        expect(intResult.items, isEmpty);
        expect(stringResult.items, isEmpty);
      });
    });

    group('fromList factory', () {
      test('sets hasMore to false when items <= pageSize', () {
        final result = PaginatedResult<String>.fromList(
          items: ['a', 'b', 'c'],
          requestedPageSize: 5,
        );

        expect(result.items, ['a', 'b', 'c']);
        expect(result.hasMore, isFalse);
      });

      test('sets hasMore to false when items == pageSize', () {
        final result = PaginatedResult<String>.fromList(
          items: ['a', 'b', 'c'],
          requestedPageSize: 3,
        );

        expect(result.items, ['a', 'b', 'c']);
        expect(result.hasMore, isFalse);
      });

      test('sets hasMore to true and trims when items > pageSize', () {
        final result = PaginatedResult<String>.fromList(
          items: ['a', 'b', 'c', 'd'],
          requestedPageSize: 3,
        );

        expect(result.items, ['a', 'b', 'c']);
        expect(result.items.length, 3);
        expect(result.hasMore, isTrue);
      });

      test('trims to exactly pageSize', () {
        final result = PaginatedResult<int>.fromList(
          items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
          requestedPageSize: 10,
        );

        expect(result.items.length, 10);
        expect(result.items.last, 10);
        expect(result.hasMore, isTrue);
      });

      test('handles empty list', () {
        final result = PaginatedResult<String>.fromList(
          items: [],
          requestedPageSize: 10,
        );

        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
      });

      test('passes lastDocument through', () {
        final result = PaginatedResult<String>.fromList(
          items: ['a'],
          requestedPageSize: 10,
          lastDocument: null,
        );

        expect(result.lastDocument, isNull);
      });
    });

    group('computed properties', () {
      test('itemCount returns number of items', () {
        final result = PaginatedResult<String>(
          items: ['a', 'b', 'c'],
          hasMore: false,
        );
        expect(result.itemCount, 3);
      });

      test('itemCount returns 0 for empty', () {
        final result = PaginatedResult<String>.empty();
        expect(result.itemCount, 0);
      });

      test('isEmpty is true when no items', () {
        final result = PaginatedResult<String>.empty();
        expect(result.isEmpty, isTrue);
      });

      test('isEmpty is false when has items', () {
        final result = PaginatedResult<String>(
          items: ['a'],
          hasMore: false,
        );
        expect(result.isEmpty, isFalse);
      });

      test('isNotEmpty is true when has items', () {
        final result = PaginatedResult<String>(
          items: ['a'],
          hasMore: false,
        );
        expect(result.isNotEmpty, isTrue);
      });

      test('isNotEmpty is false when empty', () {
        final result = PaginatedResult<String>.empty();
        expect(result.isNotEmpty, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with new items', () {
        final original = PaginatedResult<String>(
          items: ['a'],
          hasMore: true,
          totalCount: 10,
        );
        final copied = original.copyWith(items: ['x', 'y']);

        expect(copied.items, ['x', 'y']);
        expect(copied.hasMore, isTrue);
        expect(copied.totalCount, 10);
      });

      test('copies with new hasMore', () {
        final original = PaginatedResult<String>(
          items: ['a'],
          hasMore: true,
        );
        final copied = original.copyWith(hasMore: false);

        expect(copied.items, ['a']);
        expect(copied.hasMore, isFalse);
      });

      test('copies with new totalCount', () {
        final original = PaginatedResult<String>(
          items: ['a'],
          hasMore: false,
        );
        final copied = original.copyWith(totalCount: 100);

        expect(copied.totalCount, 100);
      });

      test('preserves all fields when no arguments', () {
        final original = PaginatedResult<String>(
          items: ['a', 'b'],
          hasMore: true,
          totalCount: 50,
        );
        final copied = original.copyWith();

        expect(copied.items, original.items);
        expect(copied.hasMore, original.hasMore);
        expect(copied.totalCount, original.totalCount);
      });
    });

    group('toString', () {
      test('includes item count, hasMore, and totalCount', () {
        final result = PaginatedResult<String>(
          items: ['a', 'b'],
          hasMore: true,
          totalCount: 50,
        );

        final str = result.toString();

        expect(str, contains('PaginatedResult'));
        expect(str, contains('2'));
        expect(str, contains('true'));
        expect(str, contains('50'));
      });
    });
  });

  group('PaginatedState', () {
    group('constructor', () {
      test('creates with defaults', () {
        final state = PaginatedState<String>();

        expect(state.items, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.isLoadingMore, isFalse);
        expect(state.hasMore, isTrue);
        expect(state.error, isNull);
        expect(state.lastDocument, isNull);
      });

      test('creates with custom values', () {
        final state = PaginatedState<String>(
          items: ['a', 'b'],
          isLoading: true,
          isLoadingMore: false,
          hasMore: false,
          error: 'Network error',
        );

        expect(state.items, ['a', 'b']);
        expect(state.isLoading, isTrue);
        expect(state.isLoadingMore, isFalse);
        expect(state.hasMore, isFalse);
        expect(state.error, 'Network error');
      });
    });

    group('initial factory', () {
      test('creates default state', () {
        final state = PaginatedState<String>.initial();

        expect(state.items, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.isLoadingMore, isFalse);
        expect(state.hasMore, isTrue);
        expect(state.error, isNull);
      });
    });

    group('loading factory', () {
      test('creates state with isLoading true', () {
        final state = PaginatedState<String>.loading();

        expect(state.isLoading, isTrue);
        expect(state.items, isEmpty);
        expect(state.isLoadingMore, isFalse);
        expect(state.hasMore, isTrue);
        expect(state.error, isNull);
      });
    });

    group('computed properties', () {
      test('isAnyLoading is true when isLoading', () {
        final state = PaginatedState<String>(isLoading: true);
        expect(state.isAnyLoading, isTrue);
      });

      test('isAnyLoading is true when isLoadingMore', () {
        final state = PaginatedState<String>(isLoadingMore: true);
        expect(state.isAnyLoading, isTrue);
      });

      test('isAnyLoading is true when both loading', () {
        final state = PaginatedState<String>(isLoading: true, isLoadingMore: true);
        expect(state.isAnyLoading, isTrue);
      });

      test('isAnyLoading is false when neither loading', () {
        final state = PaginatedState<String>();
        expect(state.isAnyLoading, isFalse);
      });

      test('hasError is true when error is set', () {
        final state = PaginatedState<String>(error: 'oops');
        expect(state.hasError, isTrue);
      });

      test('hasError is false when error is null', () {
        final state = PaginatedState<String>();
        expect(state.hasError, isFalse);
      });

      test('hasLoaded is true when items are present', () {
        final state = PaginatedState<String>(items: ['a']);
        expect(state.hasLoaded, isTrue);
      });

      test('hasLoaded is true when no more items and empty', () {
        final state = PaginatedState<String>(hasMore: false);
        expect(state.hasLoaded, isTrue);
      });

      test('hasLoaded is false when empty and hasMore', () {
        final state = PaginatedState<String>();
        expect(state.hasLoaded, isFalse);
      });

      test('itemCount returns number of items', () {
        final state = PaginatedState<String>(items: ['a', 'b', 'c']);
        expect(state.itemCount, 3);
      });

      test('itemCount returns 0 for initial', () {
        final state = PaginatedState<String>.initial();
        expect(state.itemCount, 0);
      });
    });

    group('copyWith', () {
      test('copies with new items', () {
        final state = PaginatedState<String>(items: ['a']);
        final copied = state.copyWith(items: ['x', 'y']);

        expect(copied.items, ['x', 'y']);
        expect(copied.isLoading, isFalse);
      });

      test('copies with new loading state', () {
        final state = PaginatedState<String>();
        final copied = state.copyWith(isLoading: true);

        expect(copied.isLoading, isTrue);
      });

      test('copies with new loadingMore state', () {
        final state = PaginatedState<String>();
        final copied = state.copyWith(isLoadingMore: true);

        expect(copied.isLoadingMore, isTrue);
      });

      test('copies with new error', () {
        final state = PaginatedState<String>();
        final copied = state.copyWith(error: 'Network failed');

        expect(copied.error, 'Network failed');
      });

      test('clearError removes existing error', () {
        final state = PaginatedState<String>(error: 'old error');
        final copied = state.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('clearError takes precedence over error parameter', () {
        final state = PaginatedState<String>(error: 'old error');
        final copied = state.copyWith(error: 'new error', clearError: true);

        expect(copied.error, isNull);
      });

      test('preserves error when clearError is false', () {
        final state = PaginatedState<String>(error: 'existing error');
        final copied = state.copyWith(isLoading: true);

        expect(copied.error, 'existing error');
      });

      test('copies with new hasMore', () {
        final state = PaginatedState<String>();
        final copied = state.copyWith(hasMore: false);

        expect(copied.hasMore, isFalse);
      });

      test('preserves all unmodified fields', () {
        final state = PaginatedState<String>(
          items: ['a', 'b'],
          isLoading: false,
          isLoadingMore: true,
          hasMore: false,
          error: 'test error',
        );
        final copied = state.copyWith(isLoading: true);

        expect(copied.items, ['a', 'b']);
        expect(copied.isLoading, isTrue);
        expect(copied.isLoadingMore, isTrue);
        expect(copied.hasMore, isFalse);
        expect(copied.error, 'test error');
      });
    });

    group('toString', () {
      test('includes relevant state info', () {
        final state = PaginatedState<String>(
          items: ['a', 'b'],
          isLoading: true,
          hasMore: false,
          error: 'err',
        );

        final str = state.toString();

        expect(str, contains('PaginatedState'));
        expect(str, contains('2'));
        expect(str, contains('true'));
        expect(str, contains('err'));
      });
    });
  });
}
