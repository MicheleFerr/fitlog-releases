import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/providers/progress_photo_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// PhotoComparisonScreen - Side-by-side before/after comparison
///
/// Features:
/// - Slider-based before/after reveal
/// - Stats overlay (weight change, days between)
/// - Photo selection mode
/// - Swipe between comparison pairs
///
/// UX Research findings:
/// - Users want easy comparison of same-pose photos
/// - Weight change visualization is highly valued
/// - Swipe slider is more intuitive than tap toggle
class PhotoComparisonScreen extends ConsumerStatefulWidget {
  const PhotoComparisonScreen({
    super.key,
    required this.userId,
    this.initialBeforePhoto,
    this.initialAfterPhoto,
  });

  final String userId;
  final ProgressPhoto? initialBeforePhoto;
  final ProgressPhoto? initialAfterPhoto;

  @override
  ConsumerState<PhotoComparisonScreen> createState() =>
      _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends ConsumerState<PhotoComparisonScreen> {
  ProgressPhoto? _beforePhoto;
  ProgressPhoto? _afterPhoto;
  double _sliderPosition = 0.5;
  bool _isSelectingBefore = true;
  bool _selectionMode = false;
  PhotoPose? _filterPose;

  @override
  void initState() {
    super.initState();
    _beforePhoto = widget.initialBeforePhoto;
    _afterPhoto = widget.initialAfterPhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode ? 'Select Photo' : 'Compare'),
        actions: [
          if (!_selectionMode && (_beforePhoto != null || _afterPhoto != null))
            IconButton(
              onPressed: _resetSelection,
              icon: const Icon(AppIcons.refresh),
              tooltip: 'Reset',
            ),
          if (!_selectionMode)
            PopupMenuButton<PhotoPose?>(
              icon: Icon(
                AppIcons.filter,
                color: _filterPose != null ? context.colors.primary : null,
              ),
              tooltip: 'Filter by pose',
              onSelected: (pose) => setState(() => _filterPose = pose),
              itemBuilder: (context) => [
                PopupMenuItem(value: null, child: Text(context.l10n.allPoses)),
                const PopupMenuDivider(),
                ...PhotoPose.values.map(
                  (pose) => PopupMenuItem(value: pose, child: Text(pose.label)),
                ),
              ],
            ),
        ],
      ),
      body: _selectionMode ? _buildSelectionGrid() : _buildComparisonView(),
    );
  }

  Widget _buildComparisonView() {
    if (_beforePhoto == null && _afterPhoto == null) {
      return _buildEmptyState();
    }

    if (_beforePhoto == null || _afterPhoto == null) {
      return _buildSinglePhotoPrompt();
    }

    return Column(
      children: [
        // Stats bar
        _buildStatsBar(),

        // Comparison slider
        Expanded(child: _buildSliderComparison()),

        // Slider control
        _buildSliderControl(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.compare,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Compare Your Progress',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select two photos to compare them side by side and see your transformation.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Accessibility: Select before photo button
            Semantics(
              label: context.l10n.selectBeforePhoto,
              button: true,
              child: FilledButton.icon(
                onPressed: () => _startSelection(isSelectingBefore: true),
                icon: const Icon(AppIcons.add),
                label: Text(context.l10n.selectBeforePhoto),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePhotoPrompt() {
    final hasPhoto = _beforePhoto ?? _afterPhoto;
    final needsBefore = _beforePhoto == null;

    return Column(
      children: [
        // Selected photo preview
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: hasPhoto!.photoUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(child: LoadingIndicator()),
              ),
              // Overlay label
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: needsBefore
                        ? context.colors.tertiary
                        : context.colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    needsBefore ? 'AFTER' : 'BEFORE',
                    style: TextStyle(
                      color: needsBefore
                          ? context.colors.onTertiary
                          : context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Prompt to select other photo
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            // Accessibility: Select photo button with dynamic label
            child: Semantics(
              label: 'Select ${needsBefore ? "Before" : "After"} Photo',
              button: true,
              child: FilledButton.icon(
                onPressed: () => _startSelection(isSelectingBefore: needsBefore),
                icon: const Icon(AppIcons.add),
                label: Text('Select ${needsBefore ? "Before" : "After"} Photo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final daysBetween = _afterPhoto!.takenAt
        .difference(_beforePhoto!.takenAt)
        .inDays;

    double? weightChange;
    if (_beforePhoto!.weightKg != null && _afterPhoto!.weightKg != null) {
      weightChange = _afterPhoto!.weightKg! - _beforePhoto!.weightKg!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colors.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Before date
          _buildStatItem(
            label: 'BEFORE',
            value: DateFormat('MMM d, y').format(_beforePhoto!.takenAt),
            icon: AppIcons.calendar,
            color: context.colors.primary,
          ),

          // Time difference
          _buildStatItem(
            label: 'PROGRESS',
            value: _formatDaysDiff(daysBetween),
            icon: AppIcons.timer,
            color: context.colors.tertiary,
          ),

          // Weight change (if available)
          if (weightChange != null)
            _buildStatItem(
              label: 'WEIGHT',
              value:
                  '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
              icon: AppIcons.scale,
              color: weightChange < 0
                  ? context.colors.success
                  : context.colors.error,
            ),

          // After date
          _buildStatItem(
            label: 'AFTER',
            value: DateFormat('MMM d, y').format(_afterPhoto!.takenAt),
            icon: AppIcons.calendar,
            color: context.colors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderComparison() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // After photo (full width behind)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: _afterPhoto!.photoUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(child: LoadingIndicator()),
              ),
            ),

            // Before photo (clipped by slider)
            Positioned.fill(
              child: ClipRect(
                clipper: _SliderClipper(_sliderPosition),
                child: CachedNetworkImage(
                  imageUrl: _beforePhoto!.photoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const Center(child: LoadingIndicator()),
                ),
              ),
            ),

            // Slider line
            Positioned(
              left: constraints.maxWidth * _sliderPosition - 2,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        AppIcons.swapHoriz,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Labels
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BEFORE',
                  style: TextStyle(
                    color: context.colors.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AFTER',
                  style: TextStyle(
                    color: context.colors.onTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Gesture detector for slider
            Positioned.fill(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sliderPosition =
                        (details.localPosition.dx / constraints.maxWidth).clamp(
                          0.0,
                          1.0,
                        );
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    _sliderPosition =
                        (details.localPosition.dx / constraints.maxWidth).clamp(
                          0.0,
                          1.0,
                        );
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliderControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Before button
          _buildPhotoButton(
            label: 'Before',
            photo: _beforePhoto,
            onTap: () => _startSelection(isSelectingBefore: true),
            color: context.colors.primary,
          ),

          // Slider
          Expanded(
            child: Slider(
              value: _sliderPosition,
              onChanged: (v) => setState(() => _sliderPosition = v),
            ),
          ),

          // After button
          _buildPhotoButton(
            label: 'After',
            photo: _afterPhoto,
            onTap: () => _startSelection(isSelectingBefore: false),
            color: context.colors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required String label,
    required ProgressPhoto? photo,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null
                ? CachedNetworkImage(
                    imageUrl: photo.thumbnailUrl,
                    fit: BoxFit.cover,
                  )
                : Icon(AppIcons.add, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionGrid() {
    final photosAsync = ref.watch(userPhotosStreamProvider(widget.userId));

    return photosAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (photos) {
        // Filter by pose if selected
        final filteredPhotos = _filterPose == null
            ? photos
            : photos.where((p) => p.pose == _filterPose).toList();

        if (filteredPhotos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.image,
                  size: 48,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text('No photos available', style: context.textTheme.bodyLarge),
                if (_filterPose != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _filterPose = null),
                    child: Text(context.l10n.clearFilter),
                  ),
                ],
              ],
            ),
          );
        }

        return Column(
          children: [
            // Selection mode header
            Container(
              padding: const EdgeInsets.all(16),
              color: _isSelectingBefore
                  ? context.colors.primaryContainer
                  : context.colors.tertiaryContainer,
              child: Row(
                children: [
                  Icon(
                    _isSelectingBefore ? AppIcons.history : AppIcons.update,
                    color: _isSelectingBefore
                        ? context.colors.onPrimaryContainer
                        : context.colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSelectingBefore
                              ? context.l10n.selectBeforePhoto
                              : context.l10n.selectAfterPhoto,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isSelectingBefore
                                ? context.colors.onPrimaryContainer
                                : context.colors.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          context.l10n.tapToSelectPhoto,
                          style: context.textTheme.bodySmall?.copyWith(
                            color:
                                (_isSelectingBefore
                                        ? context.colors.onPrimaryContainer
                                        : context.colors.onTertiaryContainer)
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectionMode = false),
                    child: Text(context.l10n.cancel),
                  ),
                ],
              ),
            ),

            // Photo grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: filteredPhotos.length,
                itemBuilder: (context, index) {
                  final photo = filteredPhotos[index];
                  final isSelected =
                      photo.id == _beforePhoto?.id ||
                      photo.id == _afterPhoto?.id;

                  return GestureDetector(
                    onTap: () => _selectPhoto(photo),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: photo.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: context.colors.surfaceContainer,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: photo.id == _beforePhoto?.id
                                    ? context.colors.primary
                                    : context.colors.tertiary,
                                width: 3,
                              ),
                            ),
                          ),
                        // Pose badge
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              photo.pose.label.split(' ').first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _startSelection({required bool isSelectingBefore}) {
    setState(() {
      _isSelectingBefore = isSelectingBefore;
      _selectionMode = true;
    });
  }

  void _selectPhoto(ProgressPhoto photo) {
    setState(() {
      if (_isSelectingBefore) {
        _beforePhoto = photo;
      } else {
        _afterPhoto = photo;
      }
      _selectionMode = false;
    });
  }

  void _resetSelection() {
    setState(() {
      _beforePhoto = null;
      _afterPhoto = null;
      _sliderPosition = 0.5;
    });
  }

  String _formatDaysDiff(int days) {
    if (days == 0) return 'Same day';
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    if (days < 30) return '${days ~/ 7} weeks';
    if (days < 365) return '${days ~/ 30} months';
    return '${days ~/ 365} years';
  }
}

/// Custom clipper for before/after slider effect
class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) =>
      position != oldClipper.position;
}
