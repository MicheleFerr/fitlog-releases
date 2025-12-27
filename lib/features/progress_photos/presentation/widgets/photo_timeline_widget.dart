import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';

/// PhotoTimelineWidget - Vertical timeline view of progress photos
///
/// Features:
/// - Chronological timeline with date markers
/// - Weight change indicators between photos
/// - Pose badges on thumbnails
/// - Smooth animations
class PhotoTimelineWidget extends StatelessWidget {
  const PhotoTimelineWidget({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  final List<ProgressPhoto> photos;
  final void Function(ProgressPhoto photo) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by date descending (newest first)
    final sortedPhotos = [...photos]
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedPhotos.length,
      itemBuilder: (context, index) {
        final photo = sortedPhotos[index];
        final previousPhoto =
            index < sortedPhotos.length - 1 ? sortedPhotos[index + 1] : null;

        return _TimelineItem(
          photo: photo,
          previousPhoto: previousPhoto,
          isFirst: index == 0,
          isLast: index == sortedPhotos.length - 1,
          onTap: () => onPhotoTap(photo),
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.photo,
    required this.previousPhoto,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final ProgressPhoto photo;
  final ProgressPhoto? previousPhoto;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final weightChange = _calculateWeightChange();
    final daysSincePrevious = _calculateDaysSincePrevious();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line with dot
          _buildTimelineIndicator(context),
          const SizedBox(width: 16),
          // Content card
          Expanded(
            child: _buildContentCard(
              context,
              weightChange: weightChange,
              daysSincePrevious: daysSincePrevious,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // Top line (if not first)
          if (!isFirst)
            Container(
              width: 2,
              height: 16,
              color: context.colors.outlineVariant,
            ),
          // Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFirst ? context.colors.primary : context.colors.outline,
              border: Border.all(
                color: context.colors.surface,
                width: 2,
              ),
            ),
          ),
          // Bottom line (if not last)
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: context.colors.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context, {
    double? weightChange,
    int? daysSincePrevious,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: context.colors.surfaceContainer,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.calendar,
                      size: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(photo.takenAt),
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Pose badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        photo.pose.label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Photo thumbnail
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Hero(
                  tag: 'photo_${photo.id}',
                  child: CachedNetworkImage(
                    imageUrl: photo.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: context.colors.surfaceContainer,
                      child: const Center(child: LoadingIndicator(size: 24)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: context.colors.errorContainer,
                      child: Icon(
                        AppIcons.error,
                        color: context.colors.error,
                      ),
                    ),
                  ),
                ),
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Weight (if available)
                    if (photo.weightKg != null) ...[
                      Icon(
                        AppIcons.scale,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${photo.weightKg!.toStringAsFixed(1)} kg',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    // Weight change indicator
                    if (weightChange != null) ...[
                      const SizedBox(width: 8),
                      _buildWeightChangeChip(context, weightChange),
                    ],

                    const Spacer(),

                    // Days since previous
                    if (daysSincePrevious != null)
                      Text(
                        _formatDaysDiff(daysSincePrevious),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // Notes (if available)
              if (photo.notes != null && photo.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text(
                    photo.notes!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChangeChip(BuildContext context, double change) {
    final isPositive = change > 0;
    final color = isPositive
        ? context.colors.error // Weight gain (red)
        : context.colors.success; // Weight loss (green)

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? AppIcons.arrowUpward : AppIcons.arrowDown,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${change.abs().toStringAsFixed(1)} kg',
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double? _calculateWeightChange() {
    if (photo.weightKg == null || previousPhoto?.weightKg == null) {
      return null;
    }
    return photo.weightKg! - previousPhoto!.weightKg!;
  }

  int? _calculateDaysSincePrevious() {
    if (previousPhoto == null) return null;
    return photo.takenAt.difference(previousPhoto!.takenAt).inDays;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today ${DateFormat.jm().format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday ${DateFormat.jm().format(date)}';
    } else if (date.year == now.year) {
      return DateFormat('MMM d, HH:mm').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatDaysDiff(int days) {
    if (days == 0) return 'Same day';
    if (days == 1) return '1 day later';
    if (days < 7) return '$days days later';
    if (days < 30) return '${days ~/ 7} weeks later';
    return '${days ~/ 30} months later';
  }
}
