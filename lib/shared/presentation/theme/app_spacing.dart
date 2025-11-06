/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/theme
/// 🎯 Feature: shared
/// 🔧 Type: theme
///
/// Spacing System - Base 4 Scale
///
/// Sistema di spacing consistente basato su multipli di 4.
/// Tutti gli spacing nell'app DEVONO usare questi valori.
///
/// ## Filosofia
///
/// - **Base Unit**: 4px
/// - **Scale**: Raddoppia progressivamente (4, 8, 12, 16, 20, 24, 32, 48, 64)
/// - **Semantic Names**: Usa nomi descrittivi invece di numeri
///
/// ## Utilizzo
///
/// ```dart
/// // ✅ CORRETTO - Usa AppSpacing
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.cardPadding),
///   child: Column(
///     children: [
///       Text('Title'),
///       SizedBox(height: AppSpacing.xs),
///       Text('Subtitle'),
///     ],
///   ),
/// )
///
/// // ❌ SBAGLIATO - Hardcoded spacing
/// Padding(
///   padding: EdgeInsets.all(15),  // ❌ Non multiplo di 4!
///   child: ...
/// )
/// ```
library;

import 'package:flutter/widgets.dart';

/// Spacing System - Base 4 Scale
///
/// Tutti i valori sono multipli di 4 per garantire consistenza visiva
/// e allineamento pixel-perfect su tutti i dispositivi.
class AppSpacing {
  AppSpacing._(); // Private constructor - questa è una utility class

  // ========================================
  // BASE SCALE (T-shirt sizing)
  // ========================================

  /// 4px - Micro spacing (interno componenti piccoli)
  ///
  /// Esempi:
  /// - Padding interno chip
  /// - Gap tra icon e text in button piccolo
  /// - Spacing in badge
  static const double xxs = 4.0;

  /// 8px - Extra small spacing
  ///
  /// Esempi:
  /// - Gap tra elementi strettamente correlati
  /// - Padding interno list tile
  /// - Spacing tra label e value
  static const double xs = 8.0;

  /// 12px - Small spacing
  ///
  /// Esempi:
  /// - Gap tra elementi in un gruppo
  /// - Padding interno card sezione
  /// - Spacing tra icon e text in button standard
  static const double sm = 12.0;

  /// 16px - Medium spacing (default)
  ///
  /// Esempi:
  /// - Padding standard card
  /// - Gap tra sezioni dentro card
  /// - Margin tra list items
  static const double md = 16.0;

  /// 20px - Large spacing
  ///
  /// Esempi:
  /// - Gap tra sezioni diverse
  /// - Padding orizzontale screen
  /// - Spacing tra card groups
  static const double lg = 20.0;

  /// 24px - Extra large spacing
  ///
  /// Esempi:
  /// - Padding dialog
  /// - Gap tra major sections
  /// - Margin top/bottom screen content
  static const double xl = 24.0;

  /// 32px - Double extra large spacing
  ///
  /// Esempi:
  /// - Spacing tra feature sections
  /// - Padding dialog large
  /// - Gap tra major UI blocks
  static const double xxl = 32.0;

  // ========================================
  // EXTENDED SCALE (Edge cases)
  // ========================================

  /// 48px - Triple extra large spacing
  ///
  /// Esempi:
  /// - Full-screen modal padding
  /// - Hero section spacing
  /// - Large empty state padding
  static const double xxxl = 48.0;

  /// 64px - Quadruple extra large spacing
  ///
  /// Esempi:
  /// - Onboarding screen spacing
  /// - Full-screen splash padding
  /// - Major section separator
  static const double xxxxl = 64.0;

  // ========================================
  // SEMANTIC ALIASES (Self-documenting)
  // ========================================

  /// Padding interno card standard (16px)
  static const double cardPadding = md;

  /// Padding interno card compatta (12px)
  static const double cardPaddingCompact = sm;

  /// Padding interno dialog (24px)
  static const double dialogPadding = xl;

  /// Padding interno bottom sheet (24px)
  static const double bottomSheetPadding = xl;

  /// Spacing tra sezioni principali (32px)
  static const double sectionSpacing = xxl;

  /// Margin orizzontale screen (20px)
  static const double screenMarginHorizontal = lg;

  /// Margin verticale screen (24px)
  static const double screenMarginVertical = xl;

  /// Gap tra list items (16px)
  static const double listItemGap = md;

  /// Padding interno list item (12px)
  static const double listItemPadding = sm;

  /// Gap tra button in row (12px)
  static const double buttonGap = sm;

  /// Padding interno button standard (16px horizontal, 12px vertical)
  static const double buttonPaddingHorizontal = md;
  static const double buttonPaddingVertical = sm;

  /// Gap tra icon e text (8px)
  static const double iconTextGap = xs;

  /// Padding interno chip (8px horizontal, 4px vertical)
  static const double chipPaddingHorizontal = xs;
  static const double chipPaddingVertical = xxs;

  /// Spacing tra form fields (16px)
  static const double formFieldGap = md;

  /// Padding interno input field (16px)
  static const double inputPadding = md;

  /// Bottom padding per floating action button (16px + safe area)
  static const double fabBottomPadding = md;

  /// Padding per empty state (48px)
  static const double emptyStatePadding = xxxl;

  // ========================================
  // HELPER GETTERS (EdgeInsets preconfigurati)
  // ========================================

  /// Padding standard card: all(16)
  static EdgeInsets get card => const EdgeInsets.all(md);

  /// Padding card compatta: all(12)
  static EdgeInsets get cardCompact => const EdgeInsets.all(sm);

  /// Padding dialog: all(24)
  static EdgeInsets get dialog => const EdgeInsets.all(xl);

  /// Padding screen standard: horizontal(20), vertical(24)
  static EdgeInsets get screen => const EdgeInsets.symmetric(
    horizontal: screenMarginHorizontal,
    vertical: screenMarginVertical,
  );

  /// Padding screen solo orizzontale: horizontal(20)
  static EdgeInsets get screenHorizontal => const EdgeInsets.symmetric(
    horizontal: screenMarginHorizontal,
  );

  /// Padding screen solo verticale: vertical(24)
  static EdgeInsets get screenVertical => const EdgeInsets.symmetric(
    vertical: screenMarginVertical,
  );

  /// Padding list item: all(12)
  static EdgeInsets get listItem => const EdgeInsets.all(listItemPadding);

  /// Padding button standard: horizontal(16), vertical(12)
  static EdgeInsets get button => const EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  /// Padding chip: horizontal(8), vertical(4)
  static EdgeInsets get chip => const EdgeInsets.symmetric(
    horizontal: chipPaddingHorizontal,
    vertical: chipPaddingVertical,
  );

  /// Padding input field: all(16)
  static EdgeInsets get input => const EdgeInsets.all(inputPadding);

  // ========================================
  // RESPONSIVE HELPERS
  // ========================================

  /// Ritorna spacing responsivo basato su larghezza schermo
  ///
  /// - < 600px (mobile): scale 1.0
  /// - 600-900px (tablet): scale 1.25
  /// - > 900px (desktop): scale 1.5
  ///
  /// Esempio:
  /// ```dart
  /// Padding(
  ///   padding: EdgeInsets.all(
  ///     AppSpacing.responsive(context, AppSpacing.md),
  ///   ),
  /// )
  /// ```
  static double responsive(double screenWidth, double baseSpacing) {
    if (screenWidth < 600) {
      return baseSpacing; // Mobile - 1.0x
    } else if (screenWidth < 900) {
      return baseSpacing * 1.25; // Tablet - 1.25x
    } else {
      return baseSpacing * 1.5; // Desktop - 1.5x
    }
  }

  // ========================================
  // VALIDATION (Debug only)
  // ========================================

  /// Verifica se un valore è un multiplo di 4 valido
  ///
  /// Usato solo in debug per validare spacing custom.
  ///
  /// ```dart
  /// assert(AppSpacing.isValid(16)); // true
  /// assert(AppSpacing.isValid(15)); // false
  /// ```
  static bool isValid(double value) {
    return value % 4 == 0;
  }

  /// Assert che lo spacing sia valido (solo debug)
  ///
  /// ```dart
  /// AppSpacing.assertValid(myCustomSpacing);
  /// ```
  static void assertValid(double value, [String? message]) {
    assert(
      isValid(value),
      message ?? 'Invalid spacing: $value. Must be multiple of 4.',
    );
  }
}
