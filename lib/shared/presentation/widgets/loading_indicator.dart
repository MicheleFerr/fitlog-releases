/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Widget unificato per stati di caricamento in tutta l'app.
/// Sostituisce le 178 occorrenze sparse di CircularProgressIndicator.
///
/// Esempi di utilizzo:
///
/// // Loading semplice inline
/// LoadingIndicator()
///
/// // Loading con messaggio
/// LoadingIndicator(message: context.l10n.loadingWorkouts)
///
/// // Loading fullscreen overlay
/// LoadingIndicator.overlay(message: context.l10n.savingChanges)
///
/// // Loading lineare (progress bar)
/// LoadingIndicator.linear(progress: 0.75)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

enum LoadingStyle {
  circular, // Default circular spinner
  linear, // Progress bar
  adaptive, // Platform-specific (iOS: ActivityIndicator, Android: Circular)
}

class LoadingIndicator extends StatelessWidget { // Se true, copre schermo con semi-trasparenza

  const LoadingIndicator({
    super.key,
    this.message,
    this.style = LoadingStyle.circular,
    this.progress,
    this.color,
    this.size = 40,
    this.overlay = false,
  });

  /// Loading fullscreen con overlay semi-trasparente
  const LoadingIndicator.overlay({
    super.key,
    this.message,
    this.style = LoadingStyle.circular,
    this.color,
  })  : progress = null,
        size = 40,
        overlay = true;

  /// Progress bar lineare
  const LoadingIndicator.linear({
    super.key,
    this.message,
    this.progress,
    this.color,
  })  : style = LoadingStyle.linear,
        size = 40,
        overlay = false;

  /// Loading adattivo per piattaforma (iOS/Android)
  const LoadingIndicator.adaptive({
    super.key,
    this.message,
    this.color,
    this.size = 40,
  })  : style = LoadingStyle.adaptive,
        progress = null,
        overlay = false;
  final String? message;
  final LoadingStyle style;
  final double? progress; // Per progress bar (0.0 - 1.0)
  final Color? color;
  final double size;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    Widget indicator = _buildIndicator(context);

    // Aggiungi messaggio se presente
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: 16),
          Text(
            message!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: overlay
                  ? context.colors.onSurface
                  : context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Wrapper per centrare
    indicator = Center(child: indicator);

    // Se overlay, aggiungi sfondo semi-trasparente
    if (overlay) {
      return ColoredBox(
        color: context.colors.surface.withValues(alpha: 0.8),
        child: indicator,
      );
    }

    return indicator;
  }

  Widget _buildIndicator(BuildContext context) {
    final indicatorColor = color ?? context.colors.primary;

    switch (style) {
      case LoadingStyle.circular:
        return SizedBox(
          width: size,
          height: size,
          child: progress != null
              ? CircularProgressIndicator(
                  value: progress,
                  color: indicatorColor,
                  strokeWidth: 3,
                )
              : CircularProgressIndicator(
                  color: indicatorColor,
                  strokeWidth: 3,
                ),
        );

      case LoadingStyle.linear:
        return SizedBox(
          width: 200,
          child: progress != null
              ? LinearProgressIndicator(
                  value: progress,
                  color: indicatorColor,
                  backgroundColor:
                      context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                )
              : LinearProgressIndicator(
                  color: indicatorColor,
                  backgroundColor:
                      context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
        );

      case LoadingStyle.adaptive:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        );
    }
  }
}

/// Widget helper per mostrare loading al posto del contenuto
class LoadingWrapper extends StatelessWidget {

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.loadingStyle = LoadingStyle.circular,
  });
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final LoadingStyle loadingStyle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingIndicator(
        message: loadingMessage,
        style: loadingStyle,
      );
    }
    return child;
  }
}

/// Mixin per aggiungere metodi helper di loading ai widget
mixin LoadingMixin {
  /// Mostra loading overlay
  void showLoadingOverlay(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: LoadingIndicator.overlay(message: message),
      ),
    );
  }

  /// Chiudi loading overlay
  void hideLoadingOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Esegui operazione async con loading overlay
  Future<T> withLoading<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? message,
  }) async {
    showLoadingOverlay(context, message: message);
    try {
      return await operation();
    } finally {
      if (context.mounted) {
        hideLoadingOverlay(context);
      }
    }
  }
}
