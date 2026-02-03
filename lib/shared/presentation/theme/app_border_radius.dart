/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/theme
/// 🎯 Feature: shared
/// 🔧 Type: theme
///
/// Border Radius System - Base 4 Scale
///
/// Sistema di border radius consistente basato su multipli di 4.
/// Tutti i border radius nell'app DEVONO usare questi valori.
///
/// ## Filosofia
///
/// - **Base Unit**: 4px
/// - **Scale**: Progressiva (2, 4, 8, 12, 16, 24, 32)
/// - **Semantic Names**: Usa nomi descrittivi invece di numeri
///
/// ## Utilizzo
///
/// ```dart
/// // ✅ CORRETTO - Usa AppBorderRadius
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppBorderRadius.md,
///     color: Colors.blue,
///   ),
/// )
///
/// // ❌ SBAGLIATO - Hardcoded border radius
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(15), // ❌ Non standardizzato!
///     color: Colors.blue,
///   ),
/// )
/// ```
library;

import 'package:flutter/widgets.dart';

/// Border Radius System - Base 4 Scale
///
/// Tutti i valori sono multipli di 4 (tranne xxs=2 per UI elements molto piccoli)
/// per garantire consistenza visiva e allineamento pixel-perfect.
class AppBorderRadius {
  AppBorderRadius._(); // Private constructor - questa è una utility class

  // ========================================
  // BASE SCALE (T-shirt sizing)
  // ========================================

  /// 2px - Micro border radius (progress bars, handle bars)
  ///
  /// Esempi:
  /// - Progress indicator bar
  /// - Slider thumb
  /// - Bottom sheet handle
  static const double xxs = 2.0;
  static final BorderRadius xxsRadius = BorderRadius.circular(xxs);

  /// 4px - Extra extra small border radius
  ///
  /// Esempi:
  /// - Chip interno
  /// - Badge piccolo
  /// - Tag compatto
  static const double xxs2 = 4.0;
  static final BorderRadius xxs2Radius = BorderRadius.circular(xxs2);

  /// 8px - Extra small border radius
  ///
  /// Esempi:
  /// - Button secondario compatto
  /// - Input field piccolo
  /// - Tooltip
  static const double xs = 8.0;
  static final BorderRadius xsRadius = BorderRadius.circular(xs);

  /// 12px - Small border radius
  ///
  /// Esempi:
  /// - Button standard
  /// - Input field standard
  /// - Card compatta
  /// - List item
  static const double sm = 12.0;
  static final BorderRadius smRadius = BorderRadius.circular(sm);

  /// 16px - Medium border radius (default)
  ///
  /// Esempi:
  /// - Card standard
  /// - Modal bottom sheet
  /// - Container principale
  static const double md = 16.0;
  static final BorderRadius mdRadius = BorderRadius.circular(md);

  /// 20px - Large border radius
  ///
  /// Esempi:
  /// - Card con enfasi
  /// - Hero container
  /// - Feature section
  static const double lg = 20.0;
  static final BorderRadius lgRadius = BorderRadius.circular(lg);

  /// 24px - Extra large border radius
  ///
  /// Esempi:
  /// - Dialog
  /// - Full-screen modal
  /// - Prominent card
  static const double xl = 24.0;
  static final BorderRadius xlRadius = BorderRadius.circular(xl);

  /// 32px - Double extra large border radius
  ///
  /// Esempi:
  /// - Hero section
  /// - Full-width card
  /// - Onboarding screen card
  static const double xxl = 32.0;
  static final BorderRadius xxlRadius = BorderRadius.circular(xxl);

  // ========================================
  // SEMANTIC ALIASES (Self-documenting)
  // ========================================

  /// Border radius standard per card (16px)
  static const double card = md;
  static final BorderRadius cardRadius = mdRadius;

  /// Border radius per card compatta (12px)
  static const double cardCompact = sm;
  static final BorderRadius cardCompactRadius = smRadius;

  /// Border radius per button standard (12px)
  static const double button = sm;
  static final BorderRadius buttonRadius = smRadius;

  /// Border radius per input field (12px)
  static const double input = sm;
  static final BorderRadius inputRadius = smRadius;

  /// Border radius per dialog (24px)
  static const double dialog = xl;
  static final BorderRadius dialogRadius = xlRadius;

  /// Border radius per bottom sheet (16px)
  static const double bottomSheet = md;
  static final BorderRadius bottomSheetRadius = mdRadius;

  /// Border radius per chip (8px)
  static const double chip = xs;
  static final BorderRadius chipRadius = xsRadius;

  /// Border radius per badge (8px)
  static const double badge = xs;
  static final BorderRadius badgeRadius = xsRadius;

  /// Border radius per progress bar (2px)
  static const double progressBar = xxs;
  static final BorderRadius progressBarRadius = xxsRadius;

  // ========================================
  // SPECIAL CASES
  // ========================================

  /// Border radius circolare completo (9999px)
  ///
  /// Usato per elementi circolari come avatar, fab, badge rotondi
  static const double circular = 9999.0;
  static final BorderRadius circularRadius = BorderRadius.circular(circular);

  /// Nessun border radius (0px)
  static const double none = 0.0;
  static final BorderRadius noneRadius = BorderRadius.circular(none);

  // ========================================
  // ASYMMETRIC HELPERS
  // ========================================

  /// Border radius solo top (utile per bottom sheets, modals)
  ///
  /// Esempio:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppBorderRadius.onlyTop(AppBorderRadius.xl),
  ///   ),
  /// )
  /// ```
  static BorderRadius onlyTop(double radius) {
    return BorderRadius.vertical(top: Radius.circular(radius));
  }

  /// Border radius solo bottom
  static BorderRadius onlyBottom(double radius) {
    return BorderRadius.vertical(bottom: Radius.circular(radius));
  }

  /// Border radius solo left
  static BorderRadius onlyLeft(double radius) {
    return BorderRadius.horizontal(left: Radius.circular(radius));
  }

  /// Border radius solo right
  static BorderRadius onlyRight(double radius) {
    return BorderRadius.horizontal(right: Radius.circular(radius));
  }

  /// Border radius custom per ogni angolo
  ///
  /// Esempio:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppBorderRadius.only(
  ///       topLeft: AppBorderRadius.xl,
  ///       topRight: AppBorderRadius.xl,
  ///       bottomLeft: AppBorderRadius.sm,
  ///       bottomRight: AppBorderRadius.sm,
  ///     ),
  ///   ),
  /// )
  /// ```
  static BorderRadius only({
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  // ========================================
  // VALIDATION (Debug only)
  // ========================================

  /// Verifica se un valore è un multiplo di 4 valido (o 2 per xxs)
  ///
  /// Usato solo in debug per validare border radius custom.
  ///
  /// ```dart
  /// assert(AppBorderRadius.isValid(16)); // true
  /// assert(AppBorderRadius.isValid(2));  // true (eccezione per xxs)
  /// assert(AppBorderRadius.isValid(15)); // false
  /// ```
  static bool isValid(double value) {
    return value == 2.0 || value % 4 == 0;
  }

  /// Assert che il border radius sia valido (solo debug)
  ///
  /// ```dart
  /// AppBorderRadius.assertValid(myCustomRadius);
  /// ```
  static void assertValid(double value, [String? message]) {
    assert(
      isValid(value),
      message ?? 'Invalid border radius: $value. Must be 2 or multiple of 4.',
    );
  }
}
