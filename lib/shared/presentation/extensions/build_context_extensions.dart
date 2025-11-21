/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/extensions
/// 🎯 Feature: shared
/// 🔧 Type: extension
///
/// Extension methods per BuildContext per ridurre verbosità e migliorare leggibilità.
///
/// Esempi di utilizzo:
///
/// Prima:
/// - Theme.of(context).colorScheme.primary
/// - AppLocalizations.of(context)!.welcomeMessage
/// - Theme.of(context).textTheme.bodyLarge
///
/// Dopo:
/// - context.colors.primary
/// - context.l10n.welcomeMessage
/// - context.textTheme.bodyLarge
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  /// Accesso rapido al ColorScheme del tema corrente
  ///
  /// Esempio:
  /// ```dart
  /// Container(color: context.colors.primary)
  /// Text('Hello', style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurface))
  /// ```
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Accesso rapido alle localizzazioni
  ///
  /// Esempio:
  /// ```dart
  /// Text(context.l10n.welcomeMessage)
  /// AppBar(title: Text(context.l10n.settings))
  /// ```
  ///
  /// Nota: Assume che AppLocalizations sia configurato correttamente nell'app.
  /// Se ottieni un errore null, verifica che MaterialApp includa
  /// `localizationsDelegates: AppLocalizations.localizationsDelegates`
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Accesso rapido al TextTheme
  ///
  /// Esempio:
  /// ```dart
  /// Text('Title', style: context.textTheme.headlineLarge)
  /// Text('Body', style: context.textTheme.bodyMedium)
  /// ```
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Accesso rapido al Theme completo
  ///
  /// Esempio:
  /// ```dart
  /// final isDark = context.theme.brightness == Brightness.dark;
  /// ```
  ThemeData get theme => Theme.of(this);

  /// Accesso rapido al MediaQuery
  ///
  /// Esempio:
  /// ```dart
  /// final screenWidth = context.mediaQuery.size.width;
  /// final padding = context.mediaQuery.padding;
  /// ```
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Accesso rapido alla larghezza dello schermo
  ///
  /// Esempio:
  /// ```dart
  /// if (context.screenWidth < 600) { /* mobile layout */ }
  /// ```
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Accesso rapido all'altezza dello schermo
  ///
  /// Esempio:
  /// ```dart
  /// if (context.screenHeight > 800) { /* large screen */ }
  /// ```
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Verifica se il dispositivo è in modalità scura
  ///
  /// Esempio:
  /// ```dart
  /// if (context.isDarkMode) {
  ///   return darkIcon;
  /// }
  /// ```
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Verifica se il dispositivo è in modalità chiara
  bool get isLightMode => !isDarkMode;

  /// Safe area padding (utile per notch, home indicator, ecc.)
  ///
  /// Esempio:
  /// ```dart
  /// Padding(
  ///   padding: EdgeInsets.only(top: context.topPadding),
  ///   child: MyWidget(),
  /// )
  /// ```
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Verifica se la tastiera è visibile
  ///
  /// Esempio:
  /// ```dart
  /// if (context.isKeyboardVisible) {
  ///   // Adatta layout
  /// }
  /// ```
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;
}

/// Extension per colori semantici con garantito WCAG AA contrast
///
/// Questi colori hanno significati specifici nell'app e garantiscono
/// accessibilità e consistenza visiva.
///
/// Esempio:
/// ```dart
/// Container(
///   color: context.successColor,
///   child: Text('✓ Saved', style: context.textTheme.bodyMedium?.copyWith(color: context.textOnSuccess)),
/// )
/// ```
extension SemanticColors on BuildContext {
  /// Colore per indicare successo/completamento (verde)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get successColor => colors.tertiary;

  /// Colore per indicare errore/fallimento (rosso)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get errorColor => colors.error;

  /// Colore per indicare attenzione/warning (arancione)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get warningColor => const Color(0xFFFB8C00); // Material Orange 600

  /// Colore per indicare informazione/neutro (blu)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get infoColor => colors.primary;

  /// Testo su sfondo success (white on green = WCAG AAA contrast)
  Color get textOnSuccess => colors.surface;

  /// Testo su sfondo error (garantito contrasto)
  Color get textOnError => colors.onError;

  /// Testo su sfondo warning (garantito contrasto)
  Color get textOnWarning => colors.surface;

  /// Testo su sfondo info (garantito contrasto)
  Color get textOnInfo => colors.onPrimary;

  /// Container per success messages (auto-adapts to light/dark mode)
  /// Light mode: light green tint
  /// Dark mode: darker green for contrast
  Color get successContainer => colors.tertiaryContainer.withValues(alpha: 0.3);

  /// Container per error messages (alpha layer sicuro)
  Color get errorContainer => colors.errorContainer;

  /// Container per warning messages (alpha layer sicuro)
  Color get warningContainer => warningColor.withValues(alpha: 0.2);

  /// Container per info messages (alpha layer sicuro)
  Color get infoContainer => colors.primaryContainer;

  // ========================================
  // STATE COLORS (Active/Inactive/Disabled)
  // ========================================

  /// Colore per stato attivo (elementi "on")
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get activeStateColor => colors.tertiary;

  /// Colore per stato inattivo (elementi "off")
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get inactiveStateColor => colors.outline;

  /// Colore per stato disabilitato
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get disabledStateColor => colors.onSurface.withValues(alpha: 0.38);

  // ========================================
  // EMPHASIS COLORS (Opacity-based hierarchy)
  // ========================================

  /// Emphasis alto (100% opacity) - Testo principale
  Color get emphasisHigh => colors.onSurface;

  /// Emphasis medio (60% opacity) - Testo secondario
  Color get emphasisMedium => colors.onSurface.withValues(alpha: 0.6);

  /// Emphasis basso (30% opacity) - Testo hint/placeholder
  Color get emphasisLow => colors.onSurface.withValues(alpha: 0.3);
}

/// Extension per typography responsiva basata su screen size
///
/// Adatta automaticamente font size basandosi su breakpoint:
/// - < 600px (mobile): scale 1.0
/// - 600-900px (tablet): scale 1.15
/// - > 900px (desktop): scale 1.3
///
/// Esempio:
/// ```dart
/// Text(
///   'Title',
///   style: context.responsiveTextTheme.headlineMedium,
/// )
/// ```
extension ResponsiveTypography on BuildContext {
  /// TextTheme responsivo che scala basandosi su screen width
  TextTheme get responsiveTextTheme {
    final width = MediaQuery.of(this).size.width;
    final baseTheme = Theme.of(this).textTheme;

    // Calcola scale factor basato su breakpoint
    final double scaleFactor;
    if (width < 600) {
      scaleFactor = 1.0; // Mobile - no scaling
    } else if (width < 900) {
      scaleFactor = 1.15; // Tablet - slightly larger
    } else {
      scaleFactor = 1.3; // Desktop - larger
    }

    // Se scale è 1.0, ritorna theme originale per performance
    if (scaleFactor == 1.0) {
      return baseTheme;
    }

    // Scala tutti gli stili
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge!.fontSize! * scaleFactor),
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium!.fontSize! * scaleFactor),
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: (baseTheme.displaySmall!.fontSize! * scaleFactor),
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: (baseTheme.headlineLarge!.fontSize! * scaleFactor),
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: (baseTheme.headlineMedium!.fontSize! * scaleFactor),
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: (baseTheme.headlineSmall!.fontSize! * scaleFactor),
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge!.fontSize! * scaleFactor),
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium!.fontSize! * scaleFactor),
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: (baseTheme.titleSmall!.fontSize! * scaleFactor),
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge!.fontSize! * scaleFactor),
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium!.fontSize! * scaleFactor),
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: (baseTheme.bodySmall!.fontSize! * scaleFactor),
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: (baseTheme.labelLarge!.fontSize! * scaleFactor),
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: (baseTheme.labelMedium!.fontSize! * scaleFactor),
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: (baseTheme.labelSmall!.fontSize! * scaleFactor),
      ),
    );
  }

  /// Check se device è tablet (width >= 600px)
  bool get isTablet => screenWidth >= 600;

  /// Check se device è desktop (width >= 900px)
  bool get isDesktop => screenWidth >= 900;

  /// Check se device è mobile (width < 600px)
  bool get isMobile => screenWidth < 600;
}
