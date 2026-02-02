import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/providers/progress_photo_providers.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/screens/photo_comparison_screen.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/widgets/photo_capture_sheet.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/widgets/photo_detail_modal.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/widgets/photo_reminder_settings_sheet.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/widgets/photo_timeline_widget.dart';

/// MyPhotosScreen - Progress photos timeline view
///
/// Features:
/// - Grid/Timeline view of progress photos
/// - Filter by pose type
/// - Add new photo with camera/gallery
/// - Photo comparison mode
/// - Storage stats display
///
/// GDPR compliant:
/// - Photos stored with user consent
/// - Delete/export functionality
class MyPhotosScreen extends ConsumerStatefulWidget {
  const MyPhotosScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends ConsumerState<MyPhotosScreen> {
  bool _isGridView = true;
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(userPhotosStreamProvider(widget.userId));
    final uploadState = ref.watch(photoUploadProvider);
    final filterPose = ref.watch(photoFilterPoseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.progressPhotos),
        actions: [
          // Reminder settings button
          IconButton(
            icon: const Icon(AppIcons.notifications),
            onPressed: _showReminderSettings,
            tooltip: context.l10n.photoReminders,
          ),
          // Compare button
          IconButton(
            icon: const Icon(AppIcons.compare),
            onPressed: _openComparisonScreen,
            tooltip: 'Compare photos',
          ),
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? AppIcons.list : AppIcons.gridView),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Timeline view' : 'Grid view',
          ),
          // Filter menu
          PopupMenuButton<PhotoPose?>(
            icon: Icon(
              AppIcons.filter,
              color: filterPose != null ? context.colors.primary : null,
            ),
            tooltip: 'Filter by pose',
            onSelected: (pose) {
              ref.read(photoFilterPoseProvider.notifier).state = pose;
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(context.l10n.allPoses)),
              const PopupMenuDivider(),
              ...PhotoPose.values.map(
                (pose) => PopupMenuItem(
                  value: pose,
                  child: Row(
                    children: [
                      if (pose == filterPose)
                        Icon(
                          AppIcons.check,
                          size: 18,
                          color: context.colors.primary,
                        ),
                      if (pose != filterPose) const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(pose.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Upload progress indicator
          if (uploadState.isUploading)
            LinearProgressIndicator(
              value: uploadState.progress,
              backgroundColor: context.colors.surfaceContainer,
            ),

          // Storage stats header
          _buildStorageStatsHeader(),

          // Photos content
          Expanded(
            child: photosAsync.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.error, size: 48, color: context.colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load photos',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(
                        userPhotosStreamProvider(widget.userId),
                      ),
                      icon: const Icon(AppIcons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (photos) {
                // Apply filter
                final filteredPhotos = filterPose == null
                    ? photos
                    : photos.where((p) => p.pose == filterPose).toList();

                if (filteredPhotos.isEmpty) {
                  return _buildEmptyState(filterPose != null);
                }

                if (_isGridView) {
                  return _buildGridView(filteredPhotos);
                } else {
                  return PhotoTimelineWidget(
                    photos: filteredPhotos,
                    onPhotoTap: _showPhotoDetail,
                  );
                }
              },
            ),
          ),
        ],
      ),
      // Accessibility: Add photo button with tooltip
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCaptureSheet,
        icon: const Icon(AppIcons.camera),
        label: Text(context.l10n.addPhoto),
        tooltip: context.l10n.addPhoto,
      ),
    );
  }

  Widget _buildStorageStatsHeader() {
    final statsAsync = ref.watch(photoStorageStatsProvider(widget.userId));

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: context.colors.surfaceContainer,
        child: Row(
          children: [
            Icon(
              AppIcons.image,
              size: 16,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '${stats.totalPhotos} photos',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Icon(
              AppIcons.storage,
              size: 16,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              stats.formattedSize,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.image,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No photos with this pose'
                  : context.l10n.noProgressPhotos,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try a different filter or add a new photo'
                  : context.l10n.noProgressPhotosDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(photoFilterPoseProvider.notifier).state = null;
                },
                child: Text(context.l10n.clearFilter),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<ProgressPhoto> photos) {
    // Group by date
    final grouped = <DateTime, List<ProgressPhoto>>{};
    for (final photo in photos) {
      final dateKey = DateTime(
        photo.takenAt.year,
        photo.takenAt.month,
        photo.takenAt.day,
      );
      grouped.putIfAbsent(dateKey, () => []).add(photo);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final datePhotos = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                _formatDate(date),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: datePhotos.length,
              itemBuilder: (context, photoIndex) {
                final photo = datePhotos[photoIndex];
                return _buildPhotoThumbnail(photo);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoThumbnail(ProgressPhoto photo) {
    return GestureDetector(
      onTap: () => _showPhotoDetail(photo),
      child: Hero(
        tag: 'photo_${photo.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: photo.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: context.colors.surfaceContainer,
                  child: const Center(child: LoadingIndicator(size: 20)),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: context.colors.errorContainer,
                  child: Icon(AppIcons.error, color: context.colors.error),
                ),
              ),
              // Pose indicator badge
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPoseShortLabel(photo.pose),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Weight badge if available
              if (photo.weightKg != null)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${photo.weightKg!.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDetail(ProgressPhoto photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoDetailModal(
        photo: photo,
        userId: widget.userId,
        onDelete: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openComparisonScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoComparisonScreen(userId: widget.userId),
      ),
    );
  }

  void _showReminderSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PhotoReminderSettingsSheet(),
    );
  }

  Future<void> _showCaptureSheet() async {
    // Get previous photos by pose for ghost overlay feature
    final photosAsync = ref.read(userPhotosStreamProvider(widget.userId));
    final previousPhotosByPose = <PhotoPose, ProgressPhoto>{};

    photosAsync.whenData((photos) {
      // Get most recent photo for each pose (photos are sorted newest first)
      for (final photo in photos) {
        if (!previousPhotosByPose.containsKey(photo.pose)) {
          previousPhotosByPose[photo.pose] = photo;
        }
      }
    });

    final result = await showModalBottomSheet<PhotoCaptureResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PhotoCaptureSheet(
        imagePicker: _imagePicker,
        previousPhotosByPose: previousPhotosByPose.isNotEmpty
            ? previousPhotosByPose
            : null,
      ),
    );

    if (result != null && mounted) {
      await _uploadPhoto(result);
    }
  }

  Future<void> _uploadPhoto(PhotoCaptureResult result) async {
    final uploader = ref.read(photoUploadProvider.notifier);

    final photo = await uploader.uploadPhoto(
      userId: widget.userId,
      imageFile: result.imageFile,
      pose: result.pose,
      takenAt: result.takenAt,
      notes: result.notes,
      weightKg: result.weightKg,
    );

    if (photo != null && mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.photoUploadedSuccessfully,
      );
    } else if (mounted) {
      final error = ref.read(photoUploadProvider).errorMessage;
      SnackBarService.showError(context, error ?? 'Failed to upload photo');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _getPoseShortLabel(PhotoPose pose) {
    return switch (pose) {
      PhotoPose.frontRelaxed => 'FR',
      PhotoPose.frontFlexed => 'FF',
      PhotoPose.sideLeft => 'SL',
      PhotoPose.sideRight => 'SR',
      PhotoPose.backRelaxed => 'BR',
      PhotoPose.backFlexed => 'BF',
      PhotoPose.other => '?',
    };
  }
}

/// Result from photo capture sheet
class PhotoCaptureResult {
  final File imageFile;
  final PhotoPose pose;
  final DateTime? takenAt;
  final String? notes;
  final double? weightKg;

  PhotoCaptureResult({
    required this.imageFile,
    required this.pose,
    this.takenAt,
    this.notes,
    this.weightKg,
  });
}
