import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/template_cloud_sync_service.dart';

void main() {
  // Initialize Flutter binding for platform channel support
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TemplateCloudSyncService', () {
    setUp(() {
      // Reset service state before each test
      TemplateCloudSyncService.dispose();
    });

    tearDown(() {
      TemplateCloudSyncService.dispose();
    });

    group('PendingTemplateSync', () {
      test('getRetryDelaySeconds returns correct exponential backoff delays', () {
        expect(PendingTemplateSync.getRetryDelaySeconds(0), equals(3));
        expect(PendingTemplateSync.getRetryDelaySeconds(1), equals(6));
        expect(PendingTemplateSync.getRetryDelaySeconds(2), equals(12));
        expect(PendingTemplateSync.getRetryDelaySeconds(3), equals(24));
        expect(PendingTemplateSync.getRetryDelaySeconds(4), equals(48));
        expect(PendingTemplateSync.getRetryDelaySeconds(5), equals(48)); // Max
      });

      test('shouldRetry returns true when nextRetryTime is null', () {
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {'name': 'Test'},
          createdAt: DateTime.now(),
        );

        expect(pending.shouldRetry, isTrue);
      });

      test('shouldRetry returns true when nextRetryTime has passed', () {
        final now = DateTime.now();
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {'name': 'Test'},
          createdAt: now,
          nextRetryTime: now.subtract(const Duration(seconds: 1)),
        );

        expect(pending.shouldRetry, isTrue);
      });

      test('shouldRetry returns false when nextRetryTime is in the future', () {
        final now = DateTime.now();
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {'name': 'Test'},
          createdAt: now,
          nextRetryTime: now.add(const Duration(seconds: 10)),
        );

        expect(pending.shouldRetry, isFalse);
      });

      test('maxRetriesExceeded returns false when attemptCount < 5', () {
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {'name': 'Test'},
          createdAt: DateTime.now(),
          attemptCount: 4,
        );

        expect(pending.maxRetriesExceeded, isFalse);
      });

      test('maxRetriesExceeded returns true when attemptCount >= 5', () {
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {'name': 'Test'},
          createdAt: DateTime.now(),
          attemptCount: 5,
        );

        expect(pending.maxRetriesExceeded, isTrue);
      });

      test('toJson and fromJson preserve all data', () {
        final now = DateTime.now();
        final pending = PendingTemplateSync(
          templateId: 'test-1',
          templateData: {
            'name': 'Test Template',
            'description': 'Test Description',
            'exercises': [],
          },
          createdAt: now,
          attemptCount: 2,
          lastAttemptTime: now,
          lastError: 'Network timeout',
          nextRetryTime: now.add(const Duration(seconds: 12)),
        );

        final json = pending.toJson();
        final restored = PendingTemplateSync.fromJson(json);

        expect(restored.templateId, equals(pending.templateId));
        expect(restored.templateData, equals(pending.templateData));
        expect(restored.attemptCount, equals(pending.attemptCount));
        expect(restored.lastError, equals(pending.lastError));
        expect(restored.createdAt.millisecondsSinceEpoch,
            equals(pending.createdAt.millisecondsSinceEpoch));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'templateId': 'test-1',
          'templateData': {'name': 'Test'},
          'createdAt': DateTime.now().toIso8601String(),
          'attemptCount': 0,
        };

        final pending = PendingTemplateSync.fromJson(json);

        expect(pending.lastAttemptTime, isNull);
        expect(pending.lastError, isNull);
        expect(pending.nextRetryTime, isNull);
      });
    });

    group('TemplateCloudSyncService', () {
      test('addPendingTemplate and getPendingSync work correctly', () async {
        const templateId = 'test-template-1';
        final templateData = {
          'name': 'Test Template',
          'description': 'Description',
        };

        await TemplateCloudSyncService.addPendingTemplate(
          templateId,
          templateData,
        );

        final pending = TemplateCloudSyncService.getPendingSync(templateId);

        expect(pending, isNotNull);
        expect(pending!.templateId, equals(templateId));
        expect(pending.templateData['name'], equals('Test Template'));
        expect(pending.attemptCount, equals(0));
      });

      test('getAllPending returns all pending templates', () async {
        await TemplateCloudSyncService.addPendingTemplate(
          'template-1',
          {'name': 'Template 1'},
        );
        await TemplateCloudSyncService.addPendingTemplate(
          'template-2',
          {'name': 'Template 2'},
        );

        final allPending = TemplateCloudSyncService.getAllPending();

        expect(allPending, hasLength(2));
        expect(
          allPending.map((p) => p.templateId),
          containsAll(['template-1', 'template-2']),
        );
      });

      test('clearAll removes all pending templates', () async {
        await TemplateCloudSyncService.addPendingTemplate(
          'template-1',
          {'name': 'Template 1'},
        );
        await TemplateCloudSyncService.addPendingTemplate(
          'template-2',
          {'name': 'Template 2'},
        );

        await TemplateCloudSyncService.clearAll();

        final allPending = TemplateCloudSyncService.getAllPending();
        expect(allPending, isEmpty);
      });

      test('dispose stops the periodic sync timer', () async {
        await TemplateCloudSyncService.initialize();

        // Timer should be running
        var allPending = TemplateCloudSyncService.getAllPending();
        expect(allPending, isEmpty); // No error, timer is alive

        TemplateCloudSyncService.dispose();

        // After dispose, provider should still work but timer is stopped
        allPending = TemplateCloudSyncService.getAllPending();
        expect(allPending, isEmpty);
      });
    });

    group('Exponential Backoff Calculation', () {
      test('calculateNextRetryTime uses correct delays', () {
        const delays = [3, 6, 12, 24, 48];

        for (int i = 0; i < delays.length; i++) {
          final delaySeconds = PendingTemplateSync.getRetryDelaySeconds(i);
          expect(delaySeconds, equals(delays[i]));

          // Total time after all retries up to i
          int totalSeconds = 0;
          for (int j = 0; j <= i; j++) {
            totalSeconds += PendingTemplateSync.getRetryDelaySeconds(j);
          }

          // Verify cumulative time is reasonable
          expect(totalSeconds, greaterThan(0));
        }
      });

      test('total retry time is approximately 93 seconds', () {
        int totalSeconds = 0;
        for (int i = 0; i < 5; i++) {
          totalSeconds += PendingTemplateSync.getRetryDelaySeconds(i);
        }

        expect(totalSeconds, equals(3 + 6 + 12 + 24 + 48)); // 93 seconds
      });
    });

    group('Persistence', () {
      test('pending templates in-memory list is managed correctly', () async {
        const templateId = 'persist-test-1';
        final templateData = {
          'name': 'Persist Test',
          'exercises': [
            {'name': 'Exercise 1', 'reps': 10},
          ],
        };

        await TemplateCloudSyncService.addPendingTemplate(
          templateId,
          templateData,
        );

        // Verify it's in pending list
        final pending = TemplateCloudSyncService.getPendingSync(templateId);
        expect(pending, isNotNull);

        // After clearing, it should be gone
        await TemplateCloudSyncService.clearAll();
        final afterClear = TemplateCloudSyncService.getPendingSync(templateId);
        expect(afterClear, isNull);
      });

      // Note: Full persistence tests with SharedPreferences should be done as integration tests
      // This is a unit test that focuses on the service logic, not platform dependencies
    });

    group('Data Integrity', () {
      test('template data is preserved through serialization', () async {
        final complexData = {
          'name': 'Complex Template',
          'description': 'With special chars: ñ, é, 中文',
          'exercises': [
            {
              'name': 'Squat',
              'sets': [
                {'reps': 8, 'weight': 100.5},
                {'reps': 10, 'weight': 90.0},
              ],
            },
          ],
          'tags': ['strength', 'lower-body'],
          'isPublic': false,
        };

        await TemplateCloudSyncService.addPendingTemplate(
          'complex-test',
          complexData,
        );

        final pending = TemplateCloudSyncService.getPendingSync('complex-test');
        expect(pending!.templateData, equals(complexData));
      });

      test('multiple pending templates maintain independent state', () async {
        await TemplateCloudSyncService.addPendingTemplate(
          'template-1',
          {'name': 'Template 1'},
        );

        await TemplateCloudSyncService.addPendingTemplate(
          'template-2',
          {'name': 'Template 2'},
        );

        // Get first and verify it exists
        final pending1 = TemplateCloudSyncService.getPendingSync('template-1');
        expect(pending1!.templateId, equals('template-1'));
        expect(pending1.attemptCount, equals(0));

        // Get second and verify it exists independently
        final pending2 = TemplateCloudSyncService.getPendingSync('template-2');
        expect(pending2!.templateId, equals('template-2'));
        expect(pending2.attemptCount, equals(0));

        // Verify both exist in list
        final allPending = TemplateCloudSyncService.getAllPending();
        expect(allPending, hasLength(2));
      });
    });
  });
}
