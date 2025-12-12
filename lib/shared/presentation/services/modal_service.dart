/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/services
/// 🎯 Feature: shared
/// 🔧 Type: service
///
/// Servizio centralizzato per modali (bottom sheets, dialog) in tutta l'app.
/// Sostituisce le 259 occorrenze sparse di showModalBottomSheet/showDialog.
///
/// Esempi di utilizzo:
///
/// // Bottom sheet semplice
/// final result = await ModalService.showBottomSheet(
///   context,
///   child: MyContentWidget(),
/// );
///
/// // Bottom sheet fullscreen
/// await ModalService.showFullScreenSheet(
///   context,
///   child: EditWorkoutScreen(),
/// );
///
/// // Dialog di conferma
/// final confirmed = await ModalService.showConfirmDialog(
///   context,
///   title: context.l10n.deleteWorkout,
///   message: context.l10n.deleteWorkoutConfirmation,
/// );
///
/// // Dialog con form
/// await ModalService.showDialog(
///   context,
///   child: AddExerciseForm(),
/// );
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

class ModalService {
  /// Calcola la dimensione massima sicura per DraggableScrollableSheet
  /// che evita notch/Dynamic Island.
  ///
  /// Uso:
  /// ```dart
  /// DraggableScrollableSheet(
  ///   maxChildSize: ModalService.safeMaxChildSize(context),
  ///   // ...
  /// )
  /// ```
  static double safeMaxChildSize(BuildContext context, {double preferredMax = 0.95}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    // Lascia almeno topPadding + 8px di clearance dal notch
    final maxSize = (screenHeight - topPadding - 8) / screenHeight;
    return maxSize.clamp(0.80, preferredMax);
  }

  /// Mostra bottom sheet standard (altezza ~50-90% schermo)
  ///
  /// ✅ Protetto automaticamente dal notch/Dynamic Island:
  /// L'altezza massima viene limitata per non andare sotto la safe area.
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    Color? backgroundColor,
  }) {
    // ✅ FIX: Calcola altezza massima sicura (evita notch/Dynamic Island)
    final screenHeight = context.screenHeight;
    final topPadding = context.mediaQuery.viewPadding.top;
    final maxSafeHeight = screenHeight - topPadding - 8; // 8px clearance

    // Se viene passata un'altezza, limitala al massimo sicuro
    final requestedHeight = height ?? screenHeight * 0.8;
    final safeHeight = requestedHeight.clamp(0.0, maxSafeHeight);

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        height: safeHeight,
        padding: EdgeInsets.only(
          bottom: context.mediaQuery.viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// Mostra bottom sheet fullscreen (100% altezza)
  static Future<T?> showFullScreenSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: false,
      backgroundColor: backgroundColor ?? context.colors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => child,
    );
  }

  /// Mostra dialog standard
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }

  /// Mostra dialog di conferma (Yes/No)
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelText ?? context.l10n.cancel,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDangerous
                ? FilledButton.styleFrom(
                    backgroundColor: context.colors.error,
                    foregroundColor: context.colors.onError,
                  )
                : null,
            child: Text(confirmText ?? context.l10n.confirm),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Mostra dialog informativo (solo OK)
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: icon != null ? Icon(icon, size: 48, color: context.colors.primary) : null,
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog di errore
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showInfoDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText ?? 'OK',
      icon: AppIcons.error,
    );
  }

  /// Mostra dialog con liste di opzioni
  static Future<T?> showListDialog<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T item) itemLabel,
    Widget Function(T item)? itemBuilder,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (listContext, index) {
              final item = items[index];
              if (itemBuilder != null) {
                return InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(item),
                  child: itemBuilder(item),
                );
              }
              return ListTile(
                title: Text(itemLabel(item)),
                onTap: () => Navigator.of(dialogContext).pop(item),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog con azioni multiple personalizzate
  ///
  /// Esempio:
  /// ```dart
  /// await ModalService.showActionDialog(
  ///   context,
  ///   title: 'Error',
  ///   message: 'Failed to save. Retry or export?',
  ///   icon: AppIcons.error,
  ///   actions: [
  ///     DialogAction(
  ///       label: 'RETRY',
  ///       onPressed: () => retry(),
  ///     ),
  ///     DialogAction(
  ///       label: 'EXPORT',
  ///       onPressed: () => export(),
  ///       isDangerous: true,
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<void> showActionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required List<DialogAction> actions,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        icon: icon != null
            ? Icon(icon, size: AppIconSize.xxlarge, color: context.colors.error)
            : null,
        title: Text(title),
        content: Text(message),
        actions: [
          // Cancel button (sempre presente)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              context.l10n.cancel,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          // Azioni custom
          ...actions.map((action) {
            if (action.isPrimary) {
              return FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  action.onPressed();
                },
                style: action.isDangerous
                    ? FilledButton.styleFrom(
                        backgroundColor: context.colors.error,
                        foregroundColor: context.colors.onError,
                      )
                    : null,
                child: Text(action.label),
              );
            } else {
              return TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  action.onPressed();
                },
                child: Text(
                  action.label,
                  style: action.isDangerous
                      ? context.textTheme.labelLarge?.copyWith(color: context.colors.error)
                      : null,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  /// Chiudi modale corrente
  static void dismiss(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }
}

/// Rappresenta un'azione in un dialog con azioni multiple
class DialogAction {

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isDangerous = false,
    this.isPrimary = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isDangerous;
  final bool isPrimary;
}

/// Mixin per aggiungere metodi helper di modali ai widget
mixin ModalMixin {
  Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    double? height,
  }) {
    return ModalService.showBottomSheet<T>(
      context,
      child: child,
      height: height,
    );
  }

  Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    bool isDangerous = false,
  }) {
    return ModalService.showConfirmDialog(
      context,
      title: title,
      message: message,
      isDangerous: isDangerous,
    );
  }

  Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return ModalService.showErrorDialog(
      context,
      title: title,
      message: message,
    );
  }
}
