/// ProgressPhoto entities tests - JSON round-trip, PhotoPose extensions,
/// PhotoReminderSettings computed properties, PhotoReminderRecord computed.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';

void main() {
  group('PhotoPose', () {
    test('has 7 values', () {
      expect(PhotoPose.values.length, 7);
    });

    test('label for all poses', () {
      expect(PhotoPose.frontRelaxed.label, 'Front (Relaxed)');
      expect(PhotoPose.frontFlexed.label, 'Front (Flexed)');
      expect(PhotoPose.sideLeft.label, 'Side (Left)');
      expect(PhotoPose.sideRight.label, 'Side (Right)');
      expect(PhotoPose.backRelaxed.label, 'Back (Relaxed)');
      expect(PhotoPose.backFlexed.label, 'Back (Flexed)');
      expect(PhotoPose.other.label, 'Other');
    });

    test('iconName for all poses', () {
      expect(PhotoPose.frontRelaxed.iconName, 'person');
      expect(PhotoPose.frontFlexed.iconName, 'person');
      expect(PhotoPose.sideLeft.iconName, 'person_outline');
      expect(PhotoPose.sideRight.iconName, 'person_outline');
      expect(PhotoPose.backRelaxed.iconName, 'person_off');
      expect(PhotoPose.backFlexed.iconName, 'person_off');
      expect(PhotoPose.other.iconName, 'photo_camera');
    });
  });

  group('SyncStatus', () {
    test('has 4 values', () {
      expect(SyncStatus.values.length, 4);
    });
  });

  group('UploadStatus', () {
    test('has 6 values', () {
      expect(UploadStatus.values.length, 6);
    });
  });

  group('ProgressPhoto JSON', () {
    ProgressPhoto buildPhoto({
      String id = 'p1',
      String userId = 'u1',
      PhotoPose pose = PhotoPose.frontRelaxed,
      bool isSharedWithCoach = false,
      bool isDeleted = false,
      SyncStatus syncStatus = SyncStatus.pending,
    }) {
      return ProgressPhoto(
        id: id,
        userId: userId,
        photoUrl: 'https://storage.example.com/photo.webp',
        thumbnailUrl: 'https://storage.example.com/thumb.webp',
        storagePath: 'users/u1/photos/photo.webp',
        thumbnailStoragePath: 'users/u1/photos/thumb.webp',
        pose: pose,
        takenAt: DateTime(2025, 3, 1, 10, 0),
        fileSizeBytes: 200000,
        isSharedWithCoach: isSharedWithCoach,
        isDeleted: isDeleted,
        syncStatus: syncStatus,
      );
    }

    test('round-trip with all fields', () {
      final photo = ProgressPhoto(
        id: 'p1',
        userId: 'u1',
        photoUrl: 'https://example.com/photo.webp',
        thumbnailUrl: 'https://example.com/thumb.webp',
        storagePath: 'users/u1/photos/photo.webp',
        thumbnailStoragePath: 'users/u1/photos/thumb.webp',
        pose: PhotoPose.frontFlexed,
        takenAt: DateTime(2025, 3, 1, 10, 0),
        fileSizeBytes: 200000,
        originalFileSizeBytes: 500000,
        notes: 'Week 4 progress',
        weightKg: 80.5,
        createdAt: DateTime(2025, 3, 1),
        updatedAt: DateTime(2025, 3, 2),
        isSharedWithCoach: true,
        sharedWithCoachId: 'coach1',
        sharedAt: DateTime(2025, 3, 1, 12, 0),
        isDeleted: false,
        syncStatus: SyncStatus.synced,
      );
      final json = photo.toJson();
      final restored = ProgressPhoto.fromJson(json);
      expect(restored.id, 'p1');
      expect(restored.userId, 'u1');
      expect(restored.pose, PhotoPose.frontFlexed);
      expect(restored.fileSizeBytes, 200000);
      expect(restored.originalFileSizeBytes, 500000);
      expect(restored.notes, 'Week 4 progress');
      expect(restored.weightKg, 80.5);
      expect(restored.isSharedWithCoach, isTrue);
      expect(restored.sharedWithCoachId, 'coach1');
      expect(restored.isDeleted, isFalse);
      expect(restored.syncStatus, SyncStatus.synced);
    });

    test('round-trip with defaults', () {
      final photo = buildPhoto();
      final restored = ProgressPhoto.fromJson(photo.toJson());
      expect(restored.originalFileSizeBytes, isNull);
      expect(restored.notes, isNull);
      expect(restored.weightKg, isNull);
      expect(restored.createdAt, isNull);
      expect(restored.updatedAt, isNull);
      expect(restored.isSharedWithCoach, isFalse);
      expect(restored.sharedWithCoachId, isNull);
      expect(restored.sharedAt, isNull);
      expect(restored.isDeleted, isFalse);
      expect(restored.deletedAt, isNull);
      expect(restored.syncStatus, SyncStatus.pending);
    });

    test('round-trip all PhotoPose values', () {
      for (final pose in PhotoPose.values) {
        final photo = buildPhoto(pose: pose);
        final restored = ProgressPhoto.fromJson(photo.toJson());
        expect(restored.pose, pose);
      }
    });

    test('round-trip all SyncStatus values', () {
      for (final status in SyncStatus.values) {
        final photo = buildPhoto(syncStatus: status);
        final restored = ProgressPhoto.fromJson(photo.toJson());
        expect(restored.syncStatus, status);
      }
    });
  });

  group('PhotoUploadProgress JSON', () {
    test('round-trip with all fields', () {
      final progress = PhotoUploadProgress(
        photoId: 'p1',
        progress: 0.75,
        status: UploadStatus.uploading,
        errorMessage: null,
        bytesUploaded: 150000,
        totalBytes: 200000,
      );
      final json = progress.toJson();
      final restored = PhotoUploadProgress.fromJson(json);
      expect(restored.photoId, 'p1');
      expect(restored.progress, 0.75);
      expect(restored.status, UploadStatus.uploading);
      expect(restored.bytesUploaded, 150000);
      expect(restored.totalBytes, 200000);
    });

    test('round-trip with defaults', () {
      final progress = PhotoUploadProgress(
        photoId: 'p2',
        progress: 0.0,
        status: UploadStatus.pending,
      );
      final restored = PhotoUploadProgress.fromJson(progress.toJson());
      expect(restored.errorMessage, isNull);
      expect(restored.bytesUploaded, 0);
      expect(restored.totalBytes, 0);
    });

    test('round-trip all UploadStatus values', () {
      for (final status in UploadStatus.values) {
        final p = PhotoUploadProgress(
          photoId: 'p', progress: 0, status: status,
        );
        final restored = PhotoUploadProgress.fromJson(p.toJson());
        expect(restored.status, status);
      }
    });
  });

  group('PhotoReminderFrequency', () {
    test('has 4 values', () {
      expect(PhotoReminderFrequency.values.length, 4);
    });

    test('days for all frequencies', () {
      expect(PhotoReminderFrequency.biweekly.days, 14);
      expect(PhotoReminderFrequency.monthly.days, 28);
      expect(PhotoReminderFrequency.sixWeeks.days, 42);
      expect(PhotoReminderFrequency.custom.days, 28);
    });

    test('labelKey for all frequencies', () {
      expect(PhotoReminderFrequency.biweekly.labelKey, 'everyTwoWeeks');
      expect(PhotoReminderFrequency.monthly.labelKey, 'everyFourWeeks');
      expect(PhotoReminderFrequency.sixWeeks.labelKey, 'everySixWeeks');
      expect(PhotoReminderFrequency.custom.labelKey, 'customInterval');
    });

    test('isRecommended only for monthly', () {
      expect(PhotoReminderFrequency.monthly.isRecommended, isTrue);
      expect(PhotoReminderFrequency.biweekly.isRecommended, isFalse);
      expect(PhotoReminderFrequency.sixWeeks.isRecommended, isFalse);
      expect(PhotoReminderFrequency.custom.isRecommended, isFalse);
    });
  });

  group('PhotoReminderSettings JSON', () {
    test('round-trip with all fields', () {
      final settings = PhotoReminderSettings(
        isEnabled: true,
        frequency: PhotoReminderFrequency.biweekly,
        customIntervalDays: 21,
        reminderHour: 8,
        reminderMinute: 30,
        suggestPose: false,
        lastReminderSent: DateTime(2025, 2, 15),
        nextReminderScheduled: DateTime(2025, 3, 1),
        notificationId: 42,
        consecutiveIgnores: 2,
        maxIgnoresBeforeDisable: 5,
        disabledByAntiSpam: false,
      );
      final json = settings.toJson();
      final restored = PhotoReminderSettings.fromJson(json);
      expect(restored.isEnabled, isTrue);
      expect(restored.frequency, PhotoReminderFrequency.biweekly);
      expect(restored.customIntervalDays, 21);
      expect(restored.reminderHour, 8);
      expect(restored.reminderMinute, 30);
      expect(restored.suggestPose, isFalse);
      expect(restored.lastReminderSent, DateTime(2025, 2, 15));
      expect(restored.nextReminderScheduled, DateTime(2025, 3, 1));
      expect(restored.notificationId, 42);
      expect(restored.consecutiveIgnores, 2);
      expect(restored.maxIgnoresBeforeDisable, 5);
    });

    test('defaults factory', () {
      final settings = PhotoReminderSettings.defaults();
      expect(settings.isEnabled, isFalse);
      expect(settings.frequency, PhotoReminderFrequency.monthly);
      expect(settings.customIntervalDays, 28);
      expect(settings.reminderHour, 9);
      expect(settings.reminderMinute, 0);
      expect(settings.suggestPose, isTrue);
      expect(settings.consecutiveIgnores, 0);
      expect(settings.maxIgnoresBeforeDisable, 3);
      expect(settings.disabledByAntiSpam, isFalse);
    });

    test('recommended factory', () {
      final settings = PhotoReminderSettings.recommended(hour: 7, minute: 30);
      expect(settings.isEnabled, isTrue);
      expect(settings.frequency, PhotoReminderFrequency.monthly);
      expect(settings.reminderHour, 7);
      expect(settings.reminderMinute, 30);
    });
  });

  group('PhotoReminderSettings computed', () {
    test('reminderTime returns correct TimeOfDay', () {
      final settings = PhotoReminderSettings(
        reminderHour: 8,
        reminderMinute: 45,
      );
      expect(settings.reminderTime, const TimeOfDay(hour: 8, minute: 45));
    });

    test('effectiveIntervalDays uses frequency days', () {
      final monthly = PhotoReminderSettings(
        frequency: PhotoReminderFrequency.monthly,
      );
      expect(monthly.effectiveIntervalDays, 28);
    });

    test('effectiveIntervalDays uses customIntervalDays for custom', () {
      final custom = PhotoReminderSettings(
        frequency: PhotoReminderFrequency.custom,
        customIntervalDays: 35,
      );
      expect(custom.effectiveIntervalDays, 35);
    });

    test('calculateNextReminder', () {
      final settings = PhotoReminderSettings(
        frequency: PhotoReminderFrequency.biweekly,
        reminderHour: 10,
        reminderMinute: 30,
      );
      final from = DateTime(2025, 3, 1);
      final next = settings.calculateNextReminder(from);
      expect(next, DateTime(2025, 3, 15, 10, 30));
    });

    test('shouldDisableForAntiSpam', () {
      final disabled = PhotoReminderSettings(
        consecutiveIgnores: 3,
        maxIgnoresBeforeDisable: 3,
      );
      expect(disabled.shouldDisableForAntiSpam, isTrue);

      final notYet = PhotoReminderSettings(
        consecutiveIgnores: 2,
        maxIgnoresBeforeDisable: 3,
      );
      expect(notYet.shouldDisableForAntiSpam, isFalse);

      final noLimit = PhotoReminderSettings(
        consecutiveIgnores: 100,
        maxIgnoresBeforeDisable: 0,
      );
      expect(noLimit.shouldDisableForAntiSpam, isFalse);
    });

    test('formattedReminderTime', () {
      expect(
        PhotoReminderSettings(reminderHour: 9, reminderMinute: 0).formattedReminderTime,
        '09:00',
      );
      expect(
        PhotoReminderSettings(reminderHour: 14, reminderMinute: 5).formattedReminderTime,
        '14:05',
      );
    });
  });

  group('PhotoReminderRecord JSON', () {
    test('round-trip with all fields', () {
      final record = PhotoReminderRecord(
        id: 'r1',
        sentAt: DateTime(2025, 3, 1, 9, 0),
        openedAt: DateTime(2025, 3, 1, 10, 0),
        photoTakenAt: DateTime(2025, 3, 1, 10, 15),
        messageVariation: 2,
        wasCanceled: false,
      );
      final json = record.toJson();
      final restored = PhotoReminderRecord.fromJson(json);
      expect(restored.id, 'r1');
      expect(restored.sentAt, DateTime(2025, 3, 1, 9, 0));
      expect(restored.openedAt, DateTime(2025, 3, 1, 10, 0));
      expect(restored.photoTakenAt, DateTime(2025, 3, 1, 10, 15));
      expect(restored.messageVariation, 2);
      expect(restored.wasCanceled, isFalse);
    });

    test('round-trip with defaults', () {
      final record = PhotoReminderRecord(
        id: 'r2',
        sentAt: DateTime(2025, 1, 1),
        messageVariation: 0,
      );
      final restored = PhotoReminderRecord.fromJson(record.toJson());
      expect(restored.openedAt, isNull);
      expect(restored.photoTakenAt, isNull);
      expect(restored.wasCanceled, isFalse);
    });
  });

  group('PhotoReminderRecord computed', () {
    test('wasOpened', () {
      final opened = PhotoReminderRecord(
        id: 'r1', sentAt: DateTime(2025, 1, 1),
        openedAt: DateTime(2025, 1, 1, 10, 0), messageVariation: 0,
      );
      expect(opened.wasOpened, isTrue);

      final notOpened = PhotoReminderRecord(
        id: 'r2', sentAt: DateTime(2025, 1, 1), messageVariation: 0,
      );
      expect(notOpened.wasOpened, isFalse);
    });

    test('photoWasTaken and wasSuccessful', () {
      final taken = PhotoReminderRecord(
        id: 'r1', sentAt: DateTime(2025, 1, 1),
        photoTakenAt: DateTime(2025, 1, 1, 11, 0), messageVariation: 0,
      );
      expect(taken.photoWasTaken, isTrue);
      expect(taken.wasSuccessful, isTrue);

      final notTaken = PhotoReminderRecord(
        id: 'r2', sentAt: DateTime(2025, 1, 1), messageVariation: 0,
      );
      expect(notTaken.photoWasTaken, isFalse);
      expect(notTaken.wasSuccessful, isFalse);
    });

    test('wasIgnored', () {
      final ignored = PhotoReminderRecord(
        id: 'r1', sentAt: DateTime(2025, 1, 1), messageVariation: 0,
      );
      expect(ignored.wasIgnored, isTrue);

      final canceled = PhotoReminderRecord(
        id: 'r2', sentAt: DateTime(2025, 1, 1), messageVariation: 0,
        wasCanceled: true,
      );
      expect(canceled.wasIgnored, isFalse);

      final opened = PhotoReminderRecord(
        id: 'r3', sentAt: DateTime(2025, 1, 1),
        openedAt: DateTime(2025, 1, 1, 10, 0), messageVariation: 0,
      );
      expect(opened.wasIgnored, isFalse);
    });
  });
}
