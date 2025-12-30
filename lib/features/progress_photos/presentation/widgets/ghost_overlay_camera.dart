import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// GhostOverlayCamera - Camera with semi-transparent previous photo overlay
///
/// Key UX Feature (from competitor analysis):
/// - Shows previous photo as ghost overlay for consistent pose alignment
/// - Adjustable opacity slider (20%-80%)
/// - Pose-specific: shows last photo of same pose type
/// - Helps users maintain consistent framing across progress photos
///
/// This is the #1 missing feature vs competitors (Strong, Hevy, BodyShapr)
class GhostOverlayCamera extends StatefulWidget {
  const GhostOverlayCamera({
    super.key,
    this.previousPhoto,
    required this.pose,
    required this.onCapture,
    required this.onCancel,
  });

  /// Previous photo to show as ghost overlay (null if first photo of this pose)
  final ProgressPhoto? previousPhoto;

  /// Current pose being captured (for consistent experience)
  final PhotoPose pose;

  /// Callback when photo is captured successfully
  final void Function(File capturedPhoto) onCapture;

  /// Callback when user cancels
  final VoidCallback onCancel;

  @override
  State<GhostOverlayCamera> createState() => _GhostOverlayCameraState();
}

class _GhostOverlayCameraState extends State<GhostOverlayCamera>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isFrontCamera = true;
  String? _errorMessage;

  /// Ghost overlay opacity (0.2 to 0.8)
  double _ghostOpacity = 0.4;

  /// Whether to show ghost overlay
  bool _showGhost = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

    // Lock to portrait for consistent photos
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();

    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _errorMessage = 'No cameras available');
        return;
      }

      // Prefer front camera for selfies/progress photos
      final cameraIndex = _cameras!.indexWhere(
        (c) =>
            c.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
      );

      final camera = cameraIndex >= 0 ? _cameras![cameraIndex] : _cameras![0];

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to initialize camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });

    await _controller?.dispose();
    await _initCamera();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // Flash animation feedback
      await HapticFeedback.mediumImpact();

      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);

      widget.onCapture(file);
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Failed to capture: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scrim,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            _buildCameraPreview(),

            // Ghost overlay (previous photo)
            if (_showGhost && widget.previousPhoto != null)
              _buildGhostOverlay(),

            // Top controls
            _buildTopControls(),

            // Bottom controls
            _buildBottomControls(),

            // Pose guide label
            _buildPoseGuide(),

            // Loading/Error overlay
            if (!_isInitialized && _errorMessage == null)
              const Center(child: LoadingIndicator(size: 48)),
            if (_errorMessage != null) _buildErrorView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(color: context.colors.scrim);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4, // Portrait standard
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildGhostOverlay() {
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: IgnorePointer(
          child: Opacity(
            opacity: _ghostOpacity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.previousPhoto!.photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Cancel button
          IconButton.filled(
            onPressed: widget.onCancel,
            icon: const Icon(AppIcons.close),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.scrim.withValues(alpha: 0.54),
              foregroundColor: context.colors.onPrimary,
            ),
          ),

          const Spacer(),

          // Ghost toggle
          if (widget.previousPhoto != null)
            IconButton.filled(
              onPressed: () => setState(() => _showGhost = !_showGhost),
              icon: Icon(_showGhost ? AppIcons.visibility : AppIcons.visibilityOff),
              style: IconButton.styleFrom(
                backgroundColor:
                    _showGhost ? context.colors.primary : context.colors.scrim.withValues(alpha: 0.54),
                foregroundColor: context.colors.onPrimary,
              ),
              tooltip: 'Toggle ghost overlay',
            ),

          const SizedBox(width: AppSpacing.xs),

          // Switch camera
          IconButton.filled(
            onPressed: _switchCamera,
            icon: const Icon(AppIcons.cameraSwitch),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.scrim.withValues(alpha: 0.54),
              foregroundColor: context.colors.onPrimary,
            ),
            tooltip: 'Switch camera',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, context.colors.scrim.withValues(alpha: 0.87)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opacity slider (only if ghost visible)
            if (_showGhost && widget.previousPhoto != null) ...[
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.opacity,
                    semanticLabel: 'Ghost opacity',
                    color: context.colors.onPrimary.withValues(alpha: 0.7),
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Ghost: ${(_ghostOpacity * 100).round()}%',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: context.colors.primary,
                        inactiveTrackColor: context.colors.onPrimary.withValues(alpha: 0.24),
                        thumbColor: context.colors.onPrimary,
                        overlayColor: context.colors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _ghostOpacity,
                        min: 0.2,
                        max: 0.8,
                        onChanged: (v) => setState(() => _ghostOpacity = v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Capture button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery button (left placeholder)
                const SizedBox(width: AppSpacing.xxxxl),

                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.onPrimary, width: 4),
                      color: _isCapturing ? context.colors.outline : Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing ? context.colors.outline : context.colors.onPrimary,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: LoadingIndicator(size: 24),
                            )
                          : null,
                    ),
                  ),
                ),

                // Right placeholder
                const SizedBox(width: AppSpacing.xxxxl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoseGuide() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: AppIcons.person,
                semanticLabel: 'Pose',
                size: AppIconSize.small,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.pose.label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: 'Error',
              size: AppIconSize.xxlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _initCamera,
              icon: const Icon(AppIcons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
