/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ Uses context.l10n for all text
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Dialog fullscreen per visualizzare GIF animate degli esercizi.
/// Supporta sia GIF (exercisedb.dev) che animazione 2-frame (free-exercise-db).
library;

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class ExerciseGifFullscreen extends StatefulWidget {
  const ExerciseGifFullscreen({
    super.key,
    required this.gifUrl,
    required this.exerciseName,
  });

  final String gifUrl;
  final String exerciseName;

  @override
  State<ExerciseGifFullscreen> createState() => _ExerciseGifFullscreenState();
}

class _ExerciseGifFullscreenState extends State<ExerciseGifFullscreen> {
  Timer? _animationTimer;
  int _currentFrame = 0;

  /// Check if URL is from free-exercise-db (needs 2-frame animation)
  bool get _isTwoFrameAnimation {
    return widget.gifUrl.contains('yuhonas/free-exercise-db') &&
        widget.gifUrl.endsWith('/0.jpg');
  }

  /// Get the second frame URL (1.jpg instead of 0.jpg)
  String get _secondFrameUrl => widget.gifUrl.replaceAll('/0.jpg', '/1.jpg');

  /// Get current URL based on animation frame
  String get _currentUrl => _isTwoFrameAnimation && _currentFrame == 1
      ? _secondFrameUrl
      : widget.gifUrl;

  @override
  void initState() {
    super.initState();
    if (_isTwoFrameAnimation) {
      // Alternate every 800ms for a smooth flip-flop effect
      _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
        if (mounted) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % 2;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog.fullscreen(
      backgroundColor: context.colors.onSurface.withValues(alpha: 0.87),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // GIF al centro
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 80,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: CachedNetworkImage(
                      key: ValueKey(_currentUrl),
                      imageUrl: _currentUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: LoadingIndicator(color: colorScheme.primary),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.error,
                              color: colorScheme.error,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.errorLoadingImage,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Header con nome esercizio e pulsante chiudi
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colors.onSurface.withValues(alpha: 0.5),
                        context.colors.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.exerciseName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: context.colors.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          AppIcons.close,
                          color: context.colors.surface,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colors.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer con hint "Tap to close"
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        context.colors.onSurface.withValues(alpha: 0.5),
                        context.colors.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.touchApp,
                        color: context.colors.surface.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.tapAnywhereToClose,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.colors.surface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
