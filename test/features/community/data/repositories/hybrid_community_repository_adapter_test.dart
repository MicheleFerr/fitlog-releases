import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/hybrid_community_repository_adapter.dart';

void main() {
  late HybridCommunityRepositoryAdapter adapter;

  setUp(() {
    adapter = HybridCommunityRepositoryAdapter();
  });

  group('HybridCommunityRepositoryAdapter', () {
    test('should be instantiated successfully', () {
      expect(adapter, isA<HybridCommunityRepositoryAdapter>());
    });

    test('should have getTrendingContributions method', () {
      expect(() => adapter.getTrendingContributions(), returnsNormally);
    });

    test('should have getContributionsForReview method', () {
      expect(() => adapter.getContributionsForReview('user123'), returnsNormally);
    });

    test('should have getUserStats method', () {
      expect(() => adapter.getUserStats('user123'), returnsNormally);
    });

    test('should have searchContributions method', () {
      expect(() => adapter.searchContributions('query'), returnsNormally);
    });

    test('should have calculateUserStats method', () {
      expect(() => adapter.calculateUserStats('user123'), returnsNormally);
    });

    test('should throw UnimplementedError for approveContribution', () async {
      expect(
        () async => await adapter.approveContribution('contrib123', 'admin123'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('should throw UnimplementedError for rejectContribution', () async {
      expect(
        () async => await adapter.rejectContribution('contrib123', 'admin123', 'reason'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('UnimplementedError for approveContribution should have correct message', () async {
      try {
        await adapter.approveContribution('test', 'admin');
        fail('Should have thrown UnimplementedError');
      } catch (e) {
        expect(e, isA<UnimplementedError>());
        expect(e.toString(), contains('Admin moderation not implemented'));
      }
    });

    test('UnimplementedError for rejectContribution should have correct message', () async {
      try {
        await adapter.rejectContribution('test', 'admin', 'spam');
        fail('Should have thrown UnimplementedError');
      } catch (e) {
        expect(e, isA<UnimplementedError>());
        expect(e.toString(), contains('Admin moderation not implemented'));
      }
    });
  });
}
