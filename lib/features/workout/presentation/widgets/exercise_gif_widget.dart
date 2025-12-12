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
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/shared/data/services/gif_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget per mostrare thumbnail dell'esercizio nella lista.
/// Tap apre fullscreen con GIF animata più grande.
class ExerciseGifWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final icColor = iconColor ?? colorScheme.primary;

    // Se non c'è URL, mostra icona fallback
    if (gifUrl == null || gifUrl!.isEmpty) {
      return _buildFallbackIcon(bgColor, icColor);
    }

    // Mostra thumbnail reale dell'esercizio
    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: gifUrl!,
          cacheManager: GifCacheManager.instance,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Placeholder durante il caricamento
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(icColor),
              ),
            ),
          ),
          // Fallback se l'immagine non carica
          errorWidget: (context, url, error) => Icon(
            AppIcons.workout,
            color: icColor,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  /// Widget fallback con icona quando non c'è GIF
  Widget _buildFallbackIcon(Color bgColor, Color icColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.workout,
        color: icColor,
        size: size * 0.45,
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: context.colors.onSurface87,
      barrierDismissible: true,
      builder: (context) => ExerciseGifFullscreen(
        gifUrl: gifUrl!,
        exerciseName: exerciseName,
      ),
    );
  }
}