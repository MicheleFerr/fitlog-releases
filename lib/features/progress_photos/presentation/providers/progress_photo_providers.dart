import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gymbro_flutter_new/features/progress_photos/data/repositories/firebase_photo_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/data/repositories/photo_reminder_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/data/services/photo_reminder_notification_service.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/repositories/progress_photo_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/services/photo_compression_service.dart';

/// Provider for PhotoCompressionService
final photoCompressionServiceProvider = Provider<PhotoCompressionService>((
  ref,
) {
  return PhotoCompressionService();
});

/// Provider for ProgressPhotoRepository
final progressPhotoRepositoryProvider = Provider<ProgressPhotoRepository>((
  ref,
) {
  final compressionService = ref.watch(photoCompressionServiceProvider);
  return FirebasePhotoRepository(compressionService: compressionService);
});

/// Provider for user's photos stream
///
/// Watches real-time updates to user's progress photos
final userPhotosStreamProvider =
    StreamProvider.family<List<ProgressPhoto>, String>((ref, userId) {
      final repository = ref.watch(progressPhotoRepositoryProvider);
      return repository.watchPhotos(userId: userId);
    });

/// Provider for photos filtered by pose
final photosByPoseProvider =
    FutureProvider.family<
      List<ProgressPhoto>,
      ({String userId, PhotoPose pose})
    >((ref, params) async {
      final repository = ref.watch(progressPhotoRepositoryProvider);
      final result = await repository.getPhotosByPose(
        userId: params.userId,
        pose: params.pose,
      );
      return result.fold(
        (failure) => throw Exception('Failed to load photos: $failure'),
        (photos) => photos,
      );
    });

/// Provider for storage stats
final photoStorageStatsProvider =
    FutureProvider.family<PhotoStorageStats, String>((ref, userId) async {
      final repository = ref.watch(progressPhotoRepositoryProvider);
      final result = await repository.getStorageStats(userId: userId);
      return result.fold(
        (failure) => throw Exception('Failed to get storage stats'),
        (stats) => stats,
      );
    });

/// State for photo upload
class PhotoUploadState {
  final bool isUploading;
  final double progress;
  final String? errorMessage;
  final ProgressPhoto? uploadedPhoto;

  const PhotoUploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.errorMessage,
    this.uploadedPhoto,
  });

  PhotoUploadState copyWith({
    bool? isUploading,
    double? progress,
    String? errorMessage,
    ProgressPhoto? uploadedPhoto,
  }) {
    return PhotoUploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      uploadedPhoto: uploadedPhoto ?? this.uploadedPhoto,
    );
  }
}

/// Notifier for photo upload operations
class PhotoUploadNotifier extends Notifier<PhotoUploadState> {
  late final ProgressPhotoRepository _repository;

  @override
  PhotoUploadState build() {
    _repository = ref.watch(progressPhotoRepositoryProvider);
    return const PhotoUploadState();
  }

  /// Upload a new photo
  Future<ProgressPhoto?> uploadPhoto({
    required String userId,
    required File imageFile,
    required PhotoPose pose,
    DateTime? takenAt,
    String? notes,
    double? weightKg,
  }) async {
    state = state.copyWith(
      isUploading: true,
      progress: 0.0,
      errorMessage: null,
    );

    final result = await _repository.uploadPhoto(
      userId: userId,
      imageFile: imageFile,
      pose: pose,
      takenAt: takenAt,
      notes: notes,
      weightKg: weightKg,
    );

    return result.fold(
      (failure) {
        final errorMessage = _getErrorMessage(failure);
        state = state.copyWith(
          isUploading: false,
          progress: 0.0,
          errorMessage: errorMessage,
        );
        return null;
      },
      (photo) {
        state = state.copyWith(
          isUploading: false,
          progress: 1.0,
          uploadedPhoto: photo,
        );
        return photo;
      },
    );
  }

  /// Delete a photo (soft delete)
  Future<bool> deletePhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await _repository.softDeletePhoto(
      userId: userId,
      photoId: photoId,
    );

    return result.fold((failure) {
      state = state.copyWith(errorMessage: _getErrorMessage(failure));
      return false;
    }, (_) => true);
  }

  /// Permanently delete a photo
  Future<bool> permanentlyDeletePhoto({
    required String userId,
    required String photoId,
  }) async {
    final result = await _repository.permanentlyDeletePhoto(
      userId: userId,
      photoId: photoId,
    );

    return result.fold((failure) {
      state = state.copyWith(errorMessage: _getErrorMessage(failure));
      return false;
    }, (_) => true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = const PhotoUploadState();
  }

  String _getErrorMessage(PhotoRepositoryFailure failure) {
    return switch (failure) {
      NetworkFailure(:final message) => 'Network error: $message',
      StorageFailure(:final message) => 'Storage error: $message',
      DatabaseFailure(:final message) => 'Database error: $message',
      NotFoundFailure(:final photoId) => 'Photo not found: $photoId',
      PermissionDeniedFailure() => 'Permission denied',
      CompressionFailure(:final message) => 'Compression failed: $message',
      QuotaExceededFailure() => 'Storage quota exceeded',
      UnknownFailure(:final message) => 'Unknown error: $message',
    };
  }
}

/// Provider for photo upload notifier
final photoUploadProvider =
    NotifierProvider<PhotoUploadNotifier, PhotoUploadState>(
      PhotoUploadNotifier.new,
    );

/// Provider for selected photo (for detail view)
final selectedPhotoProvider = StateProvider<ProgressPhoto?>((ref) => null);

/// Provider for comparison mode
final comparisonModeProvider = StateProvider<bool>((ref) => false);

/// Provider for selected photos in comparison mode
final comparisonPhotosProvider = StateProvider<List<ProgressPhoto>>(
  (ref) => [],
);

/// Provider for photo filter (by pose)
final photoFilterPoseProvider = StateProvider<PhotoPose?>((ref) => null);

/// Filtered photos based on selected pose filter
final filteredPhotosProvider =
    Provider.family<AsyncValue<List<ProgressPhoto>>, String>((ref, userId) {
      final photosAsync = ref.watch(userPhotosStreamProvider(userId));
      final filterPose = ref.watch(photoFilterPoseProvider);

      return photosAsync.whenData((photos) {
        if (filterPose == null) return photos;
        return photos.where((p) => p.pose == filterPose).toList();
      });
    });

/// Provider for photo groups by date
final photosByDateProvider =
    Provider.family<AsyncValue<Map<DateTime, List<ProgressPhoto>>>, String>((
      ref,
      userId,
    ) {
      final photosAsync = ref.watch(userPhotosStreamProvider(userId));

      return photosAsync.whenData((photos) {
        final grouped = <DateTime, List<ProgressPhoto>>{};

        for (final photo in photos) {
          // Group by date only (ignore time)
          final dateKey = DateTime(
            photo.takenAt.year,
            photo.takenAt.month,
            photo.takenAt.day,
          );

          grouped.putIfAbsent(dateKey, () => []).add(photo);
        }

        return grouped;
      });
    });

/// Provider for comparison pairs (before/after)
final comparisonPairsProvider =
    Provider.family<
      AsyncValue<List<PhotoComparisonPair>>,
      ({String userId, PhotoPose pose})
    >((ref, params) {
      final photosAsync = ref.watch(photosByPoseProvider(params));

      return photosAsync.whenData((photos) {
        if (photos.length < 2) return [];

        // Sort by date ascending
        final sorted = [...photos]
          ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

        final pairs = <PhotoComparisonPair>[];
        for (var i = 0; i < sorted.length - 1; i++) {
          final before = sorted[i];
          final after = sorted[i + 1];

          final daysBetween = after.takenAt.difference(before.takenAt).inDays;

          double? weightChange;
          if (before.weightKg != null && after.weightKg != null) {
            weightChange = after.weightKg! - before.weightKg!;
          }

          pairs.add(
            PhotoComparisonPair(
              before: before,
              after: after,
              daysBetween: daysBetween,
              weightChangeKg: weightChange,
            ),
          );
        }

        return pairs;
      });
    });

// ============================================================================
// Photo Reminder Providers
// ============================================================================

/// Provider for PhotoReminderNotificationService
final photoReminderNotificationServiceProvider =
    Provider<PhotoReminderNotificationService>((ref) {
      return PhotoReminderNotificationService();
    });

/// Provider for PhotoReminderRepository (requires async initialization)
final photoReminderRepositoryProvider = FutureProvider<PhotoReminderRepository>(
  (ref) async {
    final prefs = await SharedPreferences.getInstance();
    return PhotoReminderRepository(prefs: prefs);
  },
);

/// Provider for current reminder settings
final photoReminderSettingsProvider = FutureProvider<PhotoReminderSettings>((
  ref,
) async {
  final repo = await ref.watch(photoReminderRepositoryProvider.future);
  return repo.getSettings();
});

/// State for photo reminder management
class PhotoReminderState {
  final PhotoReminderSettings settings;
  final bool isLoading;
  final String? errorMessage;
  final bool justEnabled;

  const PhotoReminderState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
    this.justEnabled = false,
  });

  PhotoReminderState copyWith({
    PhotoReminderSettings? settings,
    bool? isLoading,
    String? errorMessage,
    bool? justEnabled,
  }) {
    return PhotoReminderState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      justEnabled: justEnabled ?? false,
    );
  }
}

/// Notifier for photo reminder management
class PhotoReminderNotifier extends Notifier<PhotoReminderState> {
  PhotoReminderRepository? _repository;
  PhotoReminderNotificationService? _notificationService;

  @override
  PhotoReminderState build() {
    // Note: This notifier should be created via photoReminderProviderAsync
    // This build() is called by the NotifierProvider which throws
    throw UnimplementedError('Use photoReminderProviderAsync for initialization');
  }

  // Manual initialization (used by FutureProvider)
  void initialize({
    required PhotoReminderRepository repository,
    required PhotoReminderNotificationService notificationService,
    required PhotoReminderSettings initialSettings,
  }) {
    _repository = repository;
    _notificationService = notificationService;
    state = PhotoReminderState(settings: initialSettings);
  }

  /// Enable reminders
  Future<void> enableReminders({
    PhotoReminderFrequency frequency = PhotoReminderFrequency.monthly,
    int hour = 9,
    int minute = 0,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updated = await _repository.enableReminders(
        frequency: frequency,
        hour: hour,
        minute: minute,
      );

      // Schedule the notification
      final nextReminder = updated.calculateNextReminder(DateTime.now());
      final notificationId = await _notificationService.schedulePhotoReminder(
        settings: updated.copyWith(nextReminderScheduled: nextReminder),
      );

      // Save notification ID and next reminder
      final finalSettings = await _repository.updateSettings(
        (current) => current.copyWith(
          nextReminderScheduled: nextReminder,
          notificationId: notificationId,
        ),
      );

      state = state.copyWith(
        settings: finalSettings,
        isLoading: false,
        justEnabled: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to enable reminders: $e',
      );
    }
  }

  /// Disable reminders
  Future<void> disableReminders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cancel any scheduled notification
      await _notificationService.cancelReminder();

      final updated = await _repository.disableReminders();

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to disable reminders: $e',
      );
    }
  }

  /// Update reminder frequency
  Future<void> updateFrequency(PhotoReminderFrequency frequency) async {
    if (!state.settings.isEnabled) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cancel existing notification
      await _notificationService.cancelReminder();

      // Update settings
      var updated = await _repository.updateSettings(
        (current) => current.copyWith(frequency: frequency),
      );

      // Schedule new notification
      final nextReminder = updated.calculateNextReminder(
        updated.lastReminderSent ?? DateTime.now(),
      );
      final notificationId = await _notificationService.schedulePhotoReminder(
        settings: updated.copyWith(nextReminderScheduled: nextReminder),
      );

      // Save notification ID and next reminder
      updated = await _repository.updateSettings(
        (current) => current.copyWith(
          nextReminderScheduled: nextReminder,
          notificationId: notificationId,
        ),
      );

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update frequency: $e',
      );
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime(int hour, int minute) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Cancel existing notification if enabled
      if (state.settings.isEnabled) {
        await _notificationService.cancelReminder();
      }

      // Update settings
      var updated = await _repository.updateSettings(
        (current) =>
            current.copyWith(reminderHour: hour, reminderMinute: minute),
      );

      // Reschedule if enabled
      if (updated.isEnabled) {
        final nextReminder = updated.calculateNextReminder(
          updated.lastReminderSent ?? DateTime.now(),
        );
        final notificationId = await _notificationService.schedulePhotoReminder(
          settings: updated.copyWith(nextReminderScheduled: nextReminder),
        );

        updated = await _repository.updateSettings(
          (current) => current.copyWith(
            nextReminderScheduled: nextReminder,
            notificationId: notificationId,
          ),
        );
      }

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update time: $e',
      );
    }
  }

  /// Record that the user took a photo (for anti-spam tracking)
  Future<void> recordPhotoTaken() async {
    // Reset ignore counter and potentially reschedule
    await _repository.recordReminderOpened();
    final updated = _repository.getSettings();
    state = state.copyWith(settings: updated);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for photo reminder notifier
final photoReminderProvider =
    NotifierProvider<PhotoReminderNotifier, PhotoReminderState>(
      PhotoReminderNotifier.new,
    );

/// Async provider for photo reminder notifier (handles initialization)
final photoReminderProviderAsync = FutureProvider<PhotoReminderNotifier>((
  ref,
) async {
  final repository = await ref.watch(photoReminderRepositoryProvider.future);
  final notificationService = ref.watch(
    photoReminderNotificationServiceProvider,
  );
  final settings = repository.getSettings();

  final notifier = PhotoReminderNotifier();
  notifier.initialize(
    repository: repository,
    notificationService: notificationService,
    initialSettings: settings,
  );
  return notifier;
});
