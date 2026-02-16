import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/share/workout_share_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Service for generating and sharing workout progress images.
///
/// Uses the screenshot package to capture a WorkoutShareCard widget
/// as a PNG image, then shares it via the native share sheet.
///
/// Example:
/// ```dart
/// await WorkoutShareService.shareWorkout(
///   context: context,
///   workout: currentWorkout,
///   userName: 'Michele',
///   elapsedDuration: Duration(minutes: 45),
/// );
/// ```
class WorkoutShareService {
  WorkoutShareService._();

  static final _screenshotController = ScreenshotController();

  /// Share workout progress as an image.
  ///
  /// [context] - BuildContext for share sheet positioning (iPad)
  /// [workout] - Current workout with exercises and sets
  /// [userName] - User's display name
  /// [elapsedDuration] - Time elapsed since workout started
  /// [shareButtonRect] - Optional rect for iPad share sheet positioning
  ///
  /// Returns true if sharing was initiated successfully.
  static Future<bool> shareWorkout({
    required BuildContext context,
    required Workout workout,
    required String userName,
    required Duration elapsedDuration,
    Rect? shareButtonRect,
  }) async {
    try {
      // 1. Generate image from widget
      final imageBytes = await _generateImage(
        workout: workout,
        userName: userName,
        elapsedDuration: elapsedDuration,
      );

      if (imageBytes == null) {
        debugPrint('❌ [WorkoutShare] Failed to generate image');
        return false;
      }

      // 2. Save to temporary file
      final tempFile = await _saveTempFile(imageBytes);

      // 3. Share via native share sheet
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          subject: workout.name,
          sharePositionOrigin: shareButtonRect,
        ),
      );

      // 4. Cleanup temp file after share completes
      _cleanupTempFile(tempFile);

      debugPrint(
        '✅ [WorkoutShare] Share completed with status: ${result.status}',
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (e, stackTrace) {
      debugPrint('❌ [WorkoutShare] Error: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  /// Generate PNG image from WorkoutShareCard widget.
  static Future<Uint8List?> _generateImage({
    required Workout workout,
    required String userName,
    required Duration elapsedDuration,
  }) async {
    try {
      // Use captureFromLongWidget for potentially tall content
      final imageBytes = await _screenshotController.captureFromLongWidget(
        WorkoutShareCard(
          workout: workout,
          userName: userName,
          elapsedDuration: elapsedDuration,
        ),
        pixelRatio: 3.0, // High quality for sharing
        delay: const Duration(milliseconds: 100),
      );

      return imageBytes;
    } catch (e) {
      debugPrint('❌ [WorkoutShare] Image generation error: $e');
      return null;
    }
  }

  /// Save image bytes to a temporary file.
  static Future<File> _saveTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/workout_share_$timestamp.png';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Cleanup temporary file after sharing.
  /// Fire-and-forget to avoid blocking the share flow.
  static void _cleanupTempFile(File file) {
    Future.delayed(const Duration(seconds: 30), () async {
      try {
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ [WorkoutShare] Temp file cleaned up');
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });
  }
}
