import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/progress_photo.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
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
      backgroundColor: Colors.black,
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
      return Container(color: Colors.black);
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
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
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
                    _showGhost ? context.colors.primary : Colors.black54,
                foregroundColor: Colors.white,
              ),
              tooltip: 'Toggle ghost overlay',
            ),

          const SizedBox(width: 8),

          // Switch camera
          IconButton.filled(
            onPressed: _switchCamera,
            icon: const Icon(AppIcons.cameraSwitch),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
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
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opacity slider (only if ghost visible)
            if (_showGhost && widget.previousPhoto != null) ...[
              Row(
                children: [
                  const Icon(
                    AppIcons.opacity,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ghost: ${(_ghostOpacity * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: context.colors.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
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
              const SizedBox(height: 16),
            ],

            // Capture button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery button (left placeholder)
                const SizedBox(width: 64),

                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isCapturing ? Colors.grey : Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing ? Colors.grey : Colors.white,
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
                const SizedBox(width: 64),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.person,
                size: 16,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                widget.pose.label,
                style: TextStyle(
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
