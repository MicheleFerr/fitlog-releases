import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/screens/my_photos_screen.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/widgets/ghost_overlay_camera.dart';

/// PhotoCaptureSheet - Bottom sheet for capturing/selecting progress photos
///
/// Features:
/// - Camera or gallery selection
/// - Ghost overlay camera for consistent pose alignment
/// - Pose type selection
/// - Optional weight input
/// - Optional notes
/// - Date picker for backdating photos
///
/// GDPR: User explicitly chooses to add each photo
class PhotoCaptureSheet extends StatefulWidget {
  const PhotoCaptureSheet({
    super.key,
    required this.imagePicker,
    this.previousPhotosByPose,
  });

  final ImagePicker imagePicker;

  /// Map of previous photos by pose type for ghost overlay feature
  /// Key: PhotoPose, Value: Most recent photo of that pose
  final Map<PhotoPose, ProgressPhoto>? previousPhotosByPose;

  @override
  State<PhotoCaptureSheet> createState() => _PhotoCaptureSheetState();
}

class _PhotoCaptureSheetState extends State<PhotoCaptureSheet> {
  File? _selectedImage;
  PhotoPose _selectedPose = PhotoPose.frontRelaxed;
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
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
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      context.l10n.addPhoto,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image selection area
                      _buildImageSelection(),

                      const SizedBox(height: AppSpacing.xl),

                      // Pose selection
                      _buildPoseSelection(),

                      const SizedBox(height: AppSpacing.xl),

                      // Date picker
                      _buildDatePicker(),

                      const SizedBox(height: AppSpacing.md),

                      // Weight input
                      _buildWeightInput(),

                      const SizedBox(height: AppSpacing.md),

                      // Notes input
                      _buildNotesInput(),

                      const SizedBox(height: AppSpacing.xl),

                      // Submit button
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSelection() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              onPressed: () => setState(() => _selectedImage = null),
              icon: const Icon(AppIcons.close),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.scrim.withValues(alpha: 0.54),
                foregroundColor: context.colors.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    // Check if ghost overlay is available for selected pose
    final hasGhostPhoto = widget.previousPhotosByPose?[_selectedPose] != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildImageSourceCard(
                icon: AppIcons.camera,
                iconLabel: 'Camera',
                label: context.l10n.camera,
                onTap: () => _showCameraOptions(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildImageSourceCard(
                icon: AppIcons.photoLibrary,
                iconLabel: 'Gallery',
                label: context.l10n.gallery,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        // Ghost overlay hint
        if (hasGhostPhoto) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.lightbulb,
                  semanticLabel: 'Tip',
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Ghost Overlay available! Align with your previous ${_selectedPose.label} photo.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Show camera options: standard or ghost overlay
  Future<void> _showCameraOptions() async {
    final previousPhoto = widget.previousPhotosByPose?[_selectedPose];

    // If no previous photo, go straight to standard camera
    if (previousPhoto == null) {
      await _pickImage(ImageSource.camera);
      return;
    }

    // Show options dialog
    final useGhost = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Camera Mode',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You have a previous ${_selectedPose.label} photo. Use Ghost Overlay to align your new photo perfectly!',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Ghost Overlay option (recommended)
              _buildCameraOptionCard(
                icon: AppIcons.layers,
                iconLabel: 'Layers',
                title: 'Ghost Overlay Camera',
                subtitle: 'See previous photo while capturing (Recommended)',
                isRecommended: true,
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Standard camera option
              _buildCameraOptionCard(
                icon: AppIcons.camera,
                iconLabel: 'Camera',
                title: 'Standard Camera',
                subtitle: 'Capture without overlay',
                isRecommended: false,
                onTap: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );

    if (useGhost == true && mounted) {
      await _launchGhostCamera(previousPhoto);
    } else if (useGhost == false && mounted) {
      await _pickImage(ImageSource.camera);
    }
  }

  Widget _buildCameraOptionCard({
    required IconData icon,
    required String iconLabel,
    required String title,
    required String subtitle,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isRecommended
                ? context.colors.primary
                : context.colors.outline,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isRecommended
              ? context.colors.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isRecommended
                    ? context.colors.primary
                    : context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SemanticIcon(
                icon: icon,
                semanticLabel: iconLabel,
                color: isRecommended
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SemanticIcon(
              icon: AppIcons.chevronRight,
              semanticLabel: 'Navigate',
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Launch the ghost overlay camera
  Future<void> _launchGhostCamera(ProgressPhoto previousPhoto) async {
    final capturedFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => GhostOverlayCamera(
          previousPhoto: previousPhoto,
          pose: _selectedPose,
          onCapture: (file) => Navigator.of(context).pop(file),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (capturedFile != null && mounted) {
      setState(() {
        _selectedImage = capturedFile;
      });
    }
  }

  Widget _buildImageSourceCard({
    required IconData icon,
    required String iconLabel,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: iconLabel,
              size: AppIconSize.xlarge,
              color: context.colors.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Pose',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PhotoPose.values.map((pose) {
            final isSelected = _selectedPose == pose;
            return ChoiceChip(
              label: Text(pose.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPose = pose);
                }
              },
              selectedColor: context.colors.primaryContainer,
              labelStyle: context.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? context.colors.onPrimaryContainer
                    : context.colors.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: 'Calendar',
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo Date',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
            const Spacer(),
            SemanticIcon(
              icon: AppIcons.chevronRight,
              semanticLabel: 'Navigate',
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return TextField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Weight (optional)',
        hintText: 'e.g., 75.5',
        suffixText: 'kg',
        prefixIcon: const Icon(AppIcons.scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      maxLength: 200,
      decoration: InputDecoration(
        labelText: 'Notes (optional)',
        hintText: 'How are you feeling? Any changes noticed?',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          child: SemanticIcon(
            icon: AppIcons.note,
            semanticLabel: 'Notes',
            color: context.colors.onSurfaceVariant,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedImage != null && !_isProcessing;

    return FilledButton.icon(
      onPressed: canSubmit ? _submit : null,
      icon: _isProcessing
          ? LoadingIndicator(
              size: 20,
              color: context.colors.onPrimary,
            )
          : const Icon(AppIcons.upload),
      label: Text(_isProcessing ? 'Processing...' : context.l10n.save),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await widget.imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Failed to pick image: $e',
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Also pick time
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDate),
        );

        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time?.hour ?? DateTime.now().hour,
            time?.minute ?? DateTime.now().minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    double? weight;
    if (_weightController.text.isNotEmpty) {
      weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    }

    final result = PhotoCaptureResult(
      imageFile: _selectedImage!,
      pose: _selectedPose,
      takenAt: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      weightKg: weight,
    );

    Navigator.of(context).pop(result);
  }
}
