/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/services
/// 🎯 Feature: shared
/// 🔧 Type: service
///
/// Servizio centralizzato per snackbar in tutta l'app.
/// Sostituisce le 258 occorrenze sparse di ScaffoldMessenger.showSnackBar.
///
/// Esempi di utilizzo:
///
/// // Success message
/// SnackBarService.showSuccess(context, context.l10n.workoutSaved)
///
/// // Error message
/// SnackBarService.showError(context, context.l10n.errorSavingWorkout)
///
/// // Warning message
/// SnackBarService.showWarning(context, context.l10n.unsavedChanges)
///
/// // Info message
/// SnackBarService.showInfo(context, context.l10n.tipOfTheDay)
///
/// // Custom snackbar con azione
/// SnackBarService.showCustom(
///   context,
///   message: 'Exercise deleted',
///   actionLabel: 'UNDO',
///   onAction: () => undoDelete(),
/// )
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
  custom,
}

class SnackBarService {
  // Durate predefinite
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _mediumDuration = Duration(seconds: 4);
  static const Duration _longDuration = Duration(seconds: 6);

  /// Mostra snackbar di successo (verde)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration ?? _mediumDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostra snackbar di errore (rosso)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration ?? _longDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostra snackbar di warning (arancione)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration ?? _mediumDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostra snackbar informativo (blu)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration ?? _shortDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostra snackbar personalizzato
  static void showCustom(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    SnackBarBehavior? behavior,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.custom,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      duration: duration ?? _mediumDuration,
      actionLabel: actionLabel,
      onAction: onAction,
      behavior: behavior,
    );
  }

  /// Chiudi snackbar corrente
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Implementazione interna
  static void _show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
    SnackBarBehavior? behavior,
  }) {
    // Determina colori in base al tipo
    final colors = _getColorsForType(context, type);
    final bgColor = backgroundColor ?? colors.background;
    final fgColor = textColor ?? colors.foreground;
    final iconData = icon ?? _getIconForType(type);

    // Costruisci contenuto
    final content = Row(
      children: [
        if (iconData != null) ...[
          Icon(iconData, color: fgColor, size: 20),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: fgColor),
          ),
        ),
      ],
    );

    // Crea snackbar
    final snackBar = SnackBar(
      content: content,
      backgroundColor: bgColor,
      duration: duration,
      behavior: behavior ?? SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: fgColor,
              onPressed: onAction,
            )
          : null,
    );

    // Mostra snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Determina colori in base al tipo
  static ({Color background, Color foreground}) _getColorsForType(
    BuildContext context,
    SnackBarType type,
  ) {
    switch (type) {
      case SnackBarType.success:
        return (
          background: const Color(0xFF4CAF50), // Verde
          foreground: context.colors.surface,
        );

      case SnackBarType.error:
        return (
          background: context.colors.error,
          foreground: context.colors.onError,
        );

      case SnackBarType.warning:
        return (
          background: const Color(0xFFFF9800), // Arancione
          foreground: context.colors.surface,
        );

      case SnackBarType.info:
        return (
          background: context.colors.primaryContainer,
          foreground: context.colors.onPrimaryContainer,
        );

      case SnackBarType.custom:
        return (
          background: context.colors.surfaceContainerHighest,
          foreground: context.colors.onSurface,
        );
    }
  }

  /// Determina icona in base al tipo
  static IconData? _getIconForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
      case SnackBarType.custom:
        return null;
    }
  }
}

/// Mixin per aggiungere metodi helper di snackbar ai widget
mixin SnackBarMixin {
  void showSuccess(BuildContext context, String message) {
    SnackBarService.showSuccess(context, message);
  }

  void showError(BuildContext context, String message) {
    SnackBarService.showError(context, message);
  }

  void showWarning(BuildContext context, String message) {
    SnackBarService.showWarning(context, message);
  }

  void showInfo(BuildContext context, String message) {
    SnackBarService.showInfo(context, message);
  }
}
