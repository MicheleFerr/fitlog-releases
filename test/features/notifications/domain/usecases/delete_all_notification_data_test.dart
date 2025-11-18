/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/notifications/domain/usecases
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: unit_test
///
/// DELETE ALL NOTIFICATION DATA USE CASE TESTS (GDPR Article 17)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/usecases/delete_all_notification_data.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';

@GenerateMocks([
  NotificationSettingsRepository,
  NotificationHistoryRepository,
  NotificationRepository,
])
import 'delete_all_notification_data_test.mocks.dart';

void main() {
  late DeleteAllNotificationData useCase;
  late MockNotificationSettingsRepository mockSettingsRepo;
  late MockNotificationHistoryRepository mockHistoryRepo;
  late MockNotificationRepository mockNotificationRepo;

  setUp(() {
    mockSettingsRepo = MockNotificationSettingsRepository();
    mockHistoryRepo = MockNotificationHistoryRepository();
    mockNotificationRepo = MockNotificationRepository();

    useCase = DeleteAllNotificationData(
      settingsRepository: mockSettingsRepo,
      historyRepository: mockHistoryRepo,
      notificationRepository: mockNotificationRepo,
    );
  });

  group('DeleteAllNotificationData - GDPR Article 17', () {
    test('execute() deletes all data in correct order', () async {
      // Arrange
      when(mockNotificationRepo.cancelAllNotifications())
          .thenAnswer((_) async => {});
      when(mockSettingsRepo.revokeConsentAndDeleteData())
          .thenAnswer((_) async => {});

      // Act
      await useCase.execute();

      // Assert
      verify(mockNotificationRepo.cancelAllNotifications()).called(1);
      verify(mockSettingsRepo.revokeConsentAndDeleteData()).called(1);
    });

    test('verifyDeletionComplete() checks all conditions', () async {
      // Arrange - All conditions pass
      when(mockNotificationRepo.getPendingNotificationIds())
          .thenAnswer((_) async => []);

      final optOutSettings = NotificationSettings.defaults().copyWith(
        consentTimestamp: null, // No consent
      );
      when(mockSettingsRepo.getSettings())
          .thenAnswer((_) async => optOutSettings);

      when(mockHistoryRepo.getUnreadCount()).thenAnswer((_) async => 0);

      // Act
      final result = await useCase.verifyDeletionComplete();

      // Assert
      expect(result, true);
    });

    test('verifyDeletionComplete() fails if pending notifications exist',
        () async {
      // Arrange - Pending notifications still exist
      when(mockNotificationRepo.getPendingNotificationIds())
          .thenAnswer((_) async => ['notif1', 'notif2']);

      // Act
      final result = await useCase.verifyDeletionComplete();

      // Assert
      expect(result, false);
    });

    test('verifyDeletionComplete() fails if consent still valid', () async {
      // Arrange - Consent still given
      when(mockNotificationRepo.getPendingNotificationIds())
          .thenAnswer((_) async => []);

      final withConsent = NotificationSettings.defaults().copyWith(
        consentTimestamp: DateTime.now(), // Consent still given
      );
      when(mockSettingsRepo.getSettings())
          .thenAnswer((_) async => withConsent);

      // Act
      final result = await useCase.verifyDeletionComplete();

      // Assert
      expect(result, false);
    });

    test('verifyDeletionComplete() fails if unread notifications exist',
        () async {
      // Arrange - Unread notifications still exist
      when(mockNotificationRepo.getPendingNotificationIds())
          .thenAnswer((_) async => []);

      final optOutSettings = NotificationSettings.defaults().copyWith(
        consentTimestamp: null,
      );
      when(mockSettingsRepo.getSettings())
          .thenAnswer((_) async => optOutSettings);

      when(mockHistoryRepo.getUnreadCount()).thenAnswer((_) async => 5);

      // Act
      final result = await useCase.verifyDeletionComplete();

      // Assert
      expect(result, false);
    });
  });
}
