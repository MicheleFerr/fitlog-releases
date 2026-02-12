/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ No text to localize
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Widget per mostrare thumbnail dell'esercizio nella lista.
/// Mostra l'immagine/GIF reale dell'esercizio con caching.
/// Tap apre fullscreen con GIF animata più grande.
///
/// ⚡ PERFORMANCE OPTIMIZATION:
/// - Immagini cachate per 30 giorni (GifCacheManager)
/// - Dimensioni ridotte (56x56) per minimo impatto CPU
/// - Fallback a icona se immagine non disponibile
/// - Animazione 2-frame per immagini da free-exercise-db
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/shared/data/services/gif_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Widget per mostrare thumbnail dell'esercizio nella lista.
/// Tap apre fullscreen con GIF animata più grande.
///
/// Supporta due modalità:
/// - GIF animate (exercisedb.dev) - mostra direttamente la GIF
/// - Immagini statiche (free-exercise-db) - alterna 0.jpg e 1.jpg
class ExerciseGifWidget extends StatefulWidget {
  const ExerciseGifWidget({
    required this.gifUrl,
    required this.exerciseName,
    this.size = 56.0,
    this.backgroundColor,
    this.iconColor,
    super.key,
  });

  final String? gifUrl;
  final String exerciseName;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<ExerciseGifWidget> createState() => _ExerciseGifWidgetState();
}

class _ExerciseGifWidgetState extends State<ExerciseGifWidget>
    with SingleTickerProviderStateMixin {
  // 🔧 PERF FIX: Use AnimationController instead of Timer.periodic
  late AnimationController _animationController;
  bool _isVisible = true;

  /// Check if URL is from free-exercise-db (needs 2-frame animation)
  bool get _isTwoFrameAnimation {
    final url = widget.gifUrl;
    if (url == null) return false;
    return url.contains('yuhonas/free-exercise-db') && url.endsWith('/0.jpg');
  }

  /// Get the second frame URL (1.jpg instead of 0.jpg)
  String? get _secondFrameUrl {
    final url = widget.gifUrl;
    if (url == null || !_isTwoFrameAnimation) return null;
    return url.replaceAll('/0.jpg', '/1.jpg');
  }

  @override
  void initState() {
    super.initState();
    // 🔧 PERF FIX: AnimationController for 60fps-synced animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (_isTwoFrameAnimation) {
      _animationController.repeat(); // Auto-loop
    }
  }

  @override
  void didUpdateWidget(ExerciseGifWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifUrl != widget.gifUrl) {
      _animationController.stop();
      if (_isTwoFrameAnimation && _isVisible) {
        _animationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 🔧 PERF FIX: Pause animation when scrolled out of viewport
  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    // Consider visible if at least 10% of widget is showing
    final isVisible = info.visibleFraction > 0.1;

    if (_isVisible != isVisible) {
      setState(() => _isVisible = isVisible);

      if (_isTwoFrameAnimation) {
        if (isVisible) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor =
        widget.backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final icColor = widget.iconColor ?? colorScheme.primary;

    // Se non c'è URL, mostra icona fallback
    if (widget.gifUrl == null || widget.gifUrl!.isEmpty) {
      return _buildFallbackIcon(bgColor, icColor);
    }

    // 🔧 PERF FIX: Wrap with VisibilityDetector to pause when off-screen
    return VisibilityDetector(
      key: Key('gif-${widget.gifUrl}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: () => _showFullscreen(context),
        child: RepaintBoundary(
          // 🔧 PERF FIX: Isolate repaints to this widget only
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: _isTwoFrameAnimation
                ? _buildAnimatedFrames(bgColor, icColor)
                : _buildStaticGif(bgColor, icColor),
          ),
        ),
      ),
    );
  }

  /// Build animated 2-frame flip-flop using AnimationController
  Widget _buildAnimatedFrames(Color bgColor, Color icColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Toggle between frame 0 and frame 1 based on animation value
        final showFrame2 = _animationController.value > 0.5;
        final currentUrl = showFrame2 ? _secondFrameUrl! : widget.gifUrl!;

        return CachedNetworkImage(
          key: ValueKey(currentUrl),
          imageUrl: currentUrl,
          cacheManager: GifCacheManager.instance,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: LoadingIndicator(size: widget.size * 0.4, color: icColor),
          ),
          errorWidget: (context, url, error) => Icon(
            AppIcons.workout,
            color: icColor,
            size: widget.size * 0.45,
          ),
        );
      },
    );
  }

  /// Build static GIF (exercisedb.dev - already animated)
  Widget _buildStaticGif(Color bgColor, Color icColor) {
    return CachedNetworkImage(
      imageUrl: widget.gifUrl!,
      cacheManager: GifCacheManager.instance,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: LoadingIndicator(size: widget.size * 0.4, color: icColor),
      ),
      errorWidget: (context, url, error) => Icon(
        AppIcons.workout,
        color: icColor,
        size: widget.size * 0.45,
      ),
    );
  }

  /// Widget fallback con icona quando non c'è GIF
  Widget _buildFallbackIcon(Color bgColor, Color icColor) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(AppIcons.workout, color: icColor, size: widget.size * 0.45),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: context.colors.onSurface87,
      barrierDismissible: true,
      builder: (context) => ExerciseGifFullscreen(
        gifUrl: widget.gifUrl!,
        exerciseName: widget.exerciseName,
      ),
    );
  }
}
