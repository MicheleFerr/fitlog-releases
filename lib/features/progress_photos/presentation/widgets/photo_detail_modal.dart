import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:intl/intl.dart';

import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/providers/progress_photo_providers.dart';

/// PhotoDetailModal - Full screen photo view with actions
///
/// Features:
/// - Full resolution photo display
/// - Photo metadata (date, weight, pose, notes)
/// - Edit notes/weight
/// - Delete with confirmation
/// - Share with coach (future)
///
/// GDPR: Soft delete with 30-day retention
class PhotoDetailModal extends ConsumerStatefulWidget {
  const PhotoDetailModal({
    super.key,
    required this.photo,
    required this.userId,
    required this.onDelete,
  });

  final ProgressPhoto photo;
  final String userId;
  final VoidCallback onDelete;

  @override
  ConsumerState<PhotoDetailModal> createState() => _PhotoDetailModalState();
}

class _PhotoDetailModalState extends ConsumerState<PhotoDetailModal> {
  bool _isDeleting = false;
  bool _showInfo = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with actions
          _buildHeader(),

          const Divider(height: 1),

          // Photo view
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showInfo = !_showInfo),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full resolution photo
                  Hero(
                    tag: 'photo_${widget.photo.id}',
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.photo.photoUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          color: context.colors.surfaceContainer,
                          child: const Center(child: LoadingIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: context.colors.errorContainer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                AppIcons.error,
                                size: 48,
                                color: context.colors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load photo',
                                style: context.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Info overlay
                  if (_showInfo)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildInfoOverlay(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(AppIcons.close),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.photo.pose.label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy • HH:mm').format(widget.photo.takenAt),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Edit button (future)
          // IconButton(
          //   onPressed: _editPhoto,
          //   icon: const Icon(AppIcons.edit),
          //   tooltip: 'Edit',
          // ),
          // Delete button
          IconButton(
            onPressed: _isDeleting ? null : _confirmDelete,
            icon: _isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.error,
                    ),
                  )
                : Icon(AppIcons.delete, color: context.colors.error),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stats row
            Row(
              children: [
                // Weight
                if (widget.photo.weightKg != null) ...[
                  _buildStatChip(
                    icon: AppIcons.scale,
                    label: '${widget.photo.weightKg!.toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(width: 12),
                ],
                // Pose
                _buildStatChip(
                  icon: AppIcons.person,
                  label: widget.photo.pose.label,
                ),
                const Spacer(),
                // File size
                _buildStatChip(
                  icon: AppIcons.storage,
                  label: _formatFileSize(widget.photo.fileSizeBytes),
                ),
              ],
            ),

            // Notes
            if (widget.photo.notes != null &&
                widget.photo.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      AppIcons.note,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.photo.notes!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Coach sharing status
            if (widget.photo.isSharedWithCoach) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.check,
                      size: 14,
                      color: Colors.green,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Shared with coach',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text(
          'This photo will be moved to trash and permanently deleted after 30 days. '
          'You can restore it from trash before then.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deletePhoto();
    }
  }

  Future<void> _deletePhoto() async {
    setState(() => _isDeleting = true);

    final success = await ref.read(photoUploadProvider.notifier).deletePhoto(
          userId: widget.userId,
          photoId: widget.photo.id,
        );

    if (mounted) {
      if (success) {
        SnackBarService.showSuccess(
          context,
          'Photo moved to trash',
        );
        widget.onDelete();
      } else {
        setState(() => _isDeleting = false);
        SnackBarService.showError(
          context,
          'Failed to delete photo',
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
