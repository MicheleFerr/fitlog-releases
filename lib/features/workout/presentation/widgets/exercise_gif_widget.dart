/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ No text to localize
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Widget per mostrare GIF animate degli esercizi con fallback e espansione
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/shared/data/services/gif_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseGifWidget extends StatefulWidget {
  ExerciseGifWidget({
    required this.gifUrl,
    required this.exerciseName,
    this.size = 56.0,
    this.backgroundColor,
    this.iconColor,
    // ✅ CRITICAL FIX: Use ValueKey based on gifUrl to prevent infinite reloads
    // This ensures Flutter recognizes the same GIF URL as the same widget
    // preventing unnecessary rebuilds that trigger new HTTP requests
  }) : super(key: ValueKey(gifUrl));
  final String? gifUrl;
  final String exerciseName;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<ExerciseGifWidget> createState() => _ExerciseGifWidgetState();
}

class _ExerciseGifWidgetState extends State<ExerciseGifWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor =
        widget.backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final icColor = widget.iconColor ?? colorScheme.primary;

    // Debug: log URL
    if (kDebugMode) {
      debugPrint('🎬 ExerciseGifWidget: ${widget.exerciseName} -> URL: ${widget.gifUrl}');
    }

    // Se non c'è URL, mostra icona fallback
    if (widget.gifUrl == null || widget.gifUrl!.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No GIF URL for ${widget.exerciseName}, showing fallback icon');
      }
      return _buildFallbackIcon(bgColor, icColor);
    }

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: CircleAvatar(
        backgroundColor: bgColor,
        radius: widget.size / 2,
        child: ClipOval(
          child: CachedNetworkImage(
            // ✅ CRITICAL FIX: Use global GifCacheManager to prevent reload loops
            // This centralizes cache configuration and prevents duplicate requests
            cacheManager: GifCacheManager.instance,
            imageUrl: widget.gifUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            // ✅ OPTIMIZATION: Memory cache limits to prevent excessive memory usage
            // Cache at 2x size to handle higher DPI displays
            memCacheHeight: (widget.size * 2).toInt(),
            memCacheWidth: (widget.size * 2).toInt(),
            // ✅ OPTIMIZATION: Stable cache key prevents re-downloading same GIF
            // Uses only URL-based key since size shouldn't vary for same exercise
            cacheKey: 'exercise_gif_${widget.exerciseName.replaceAll(' ', '_')}',
            // ✅ OPTIMIZATION: Disk cache limits (3x size for storing high-res versions)
            maxHeightDiskCache: (widget.size * 3).toInt(),
            maxWidthDiskCache: (widget.size * 3).toInt(),
            // Loading placeholder
            placeholder: (context, url) {
              if (kDebugMode) {
                debugPrint('⏳ Loading GIF for ${widget.exerciseName} from $url');
              }
              return Container(
                width: widget.size,
                height: widget.size,
                color: bgColor,
                child: Center(
                  child: SizedBox(
                    width: widget.size * 0.4,
                    height: widget.size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(icColor),
                    ),
                  ),
                ),
              );
            },
            // ✅ OPTIMIZATION: Better error handling for 404s and network errors
            errorWidget: (context, url, error) {
              final is404 = error.toString().contains('404');
              if (kDebugMode) {
                debugPrint('❌ Error loading GIF for ${widget.exerciseName}: $error');
                if (is404) {
                  debugPrint('   → GIF not available (404): $url');
                }
              }

              return Container(
                width: widget.size,
                height: widget.size,
                color: bgColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        is404
                            ? AppIcons.imageNotSupported
                            : AppIcons.fitnessCenter,
                        color: icColor,
                        size: widget.size * 0.4,
                      ),
                      if (widget.size > 40)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            is404 ? 'No GIF' : 'Error',
                            style: TextStyle(
                              fontSize: 8,
                              color: icColor.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color bgColor, Color iconColor) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(AppIcons.fitnessCenter, color: iconColor, size: widget.size * 0.5),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: context.colors.onSurface.withValues(alpha: 0.87),
      barrierDismissible: true,
      builder: (context) =>
          ExerciseGifFullscreen(gifUrl: widget.gifUrl!, exerciseName: widget.exerciseName),
    );
  }
}