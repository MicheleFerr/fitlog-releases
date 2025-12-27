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

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/shared/data/services/gif_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

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

class _ExerciseGifWidgetState extends State<ExerciseGifWidget> {
  Timer? _animationTimer;
  int _currentFrame = 0;
  bool _isAnimating = false;

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
    if (_isTwoFrameAnimation) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(ExerciseGifWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifUrl != widget.gifUrl) {
      _stopAnimation();
      if (_isTwoFrameAnimation) {
        _startAnimation();
      }
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    super.dispose();
  }

  void _startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    // Alternate every 800ms for a smooth flip-flop effect
    _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % 2;
        });
      }
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _isAnimating = false;
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

    // Determine which URL to show
    final currentUrl = _isTwoFrameAnimation && _currentFrame == 1
        ? _secondFrameUrl!
        : widget.gifUrl!;

    // Mostra thumbnail reale dell'esercizio
    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: CachedNetworkImage(
            key: ValueKey(currentUrl),
            imageUrl: currentUrl,
            cacheManager: GifCacheManager.instance,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            // Placeholder durante il caricamento
            placeholder: (context, url) => Center(
              child: LoadingIndicator(
                size: widget.size * 0.4,
                color: icColor,
              ),
            ),
            // Fallback se l'immagine non carica
            errorWidget: (context, url, error) => Icon(
              AppIcons.workout,
              color: icColor,
              size: widget.size * 0.45,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget fallback con icona quando non c'è GIF
  Widget _buildFallbackIcon(Color bgColor, Color icColor) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.workout,
        color: icColor,
        size: widget.size * 0.45,
      ),
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