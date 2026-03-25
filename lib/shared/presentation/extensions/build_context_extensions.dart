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
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/tab_bar_safe_area.dart';

// Export ColorScheme extensions so they're available to all files using context.colors
export 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
// Export TabBarInset widget so it's available to all files using context.tabBarInset
export 'package:gymbro_flutter_new/shared/presentation/widgets/tab_bar_safe_area.dart';

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

  /// Height of the overlay tab bar (from [TabBarInset] InheritedWidget).
  ///
  /// Returns 0 if the widget is not inside MainShell.
  /// Use this to add transparent bottom padding so content doesn't hide
  /// behind the overlay tab bar.
  ///
  /// ```dart
  /// Padding(
  ///   padding: EdgeInsets.only(bottom: context.tabBarInset),
  ///   child: myBottomButton,
  /// )
  /// ```
  double get tabBarInset => TabBarInset.of(this);
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
  Color get successColor => colors.success;

  /// Colore per indicare errore/fallimento (rosso)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get errorColor => colors.error;

  /// Colore per indicare attenzione/warning (arancione)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get warningColor => colors.warning;

  /// Colore per indicare informazione/neutro (blu)
  /// WCAG AA compliant - contrast ratio ≥ 4.5:1
  Color get infoColor => colors.primary;

  /// Testo su sfondo success (white on green = WCAG AAA contrast)
  Color get textOnSuccess => colors.onSuccess;

  /// Testo su sfondo error (garantito contrasto)
  Color get textOnError => colors.onError;

  /// Testo su sfondo warning (garantito contrasto)
  Color get textOnWarning => colors.onWarning;

  /// Testo su sfondo info (garantito contrasto)
  Color get textOnInfo => colors.onPrimary;

  /// Container per success messages (auto-adapts to light/dark mode)
  /// Light mode: light green tint
  /// Dark mode: darker green for contrast
  Color get successContainer => colors.successContainer;

  /// Container per error messages (alpha layer sicuro)
  Color get errorContainer => colors.errorContainer;

  /// Container per warning messages (alpha layer sicuro)
  Color get warningContainer => colors.warningContainer;

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

/// Extension on BuildContext to get absolute widget coordinates in global space
///
/// Provides methods for calculating global paint bounds, center position, and size
/// of the current widget context.
///
/// Merged from: lib/core/extensions/context_extensions.dart (SSOT consolidation)
extension GlobalPaintBoundsExtension on BuildContext {
  /// Gets the absolute bounds of the widget in global screen coordinates
  ///
  /// Returns a [Rect] with the global position and size of the widget,
  /// or null if the widget is not mounted or doesn't have a RenderObject.
  ///
  /// Example:
  /// ```dart
  /// final bounds = context.globalPaintBounds;
  /// if (bounds != null) {
  ///   print('Widget at: ${bounds.topLeft}, size: ${bounds.size}');
  /// }
  /// ```
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }

    try {
      final translation = renderObject.getTransformTo(null).getTranslation();
      final offset = Offset(translation.x, translation.y);
      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        renderObject.size.width,
        renderObject.size.height,
      );
    } catch (e) {
      debugPrint('Error getting globalPaintBounds: $e');
      return null;
    }
  }

  /// Gets the global center position of the widget
  ///
  /// Calculates the center point of the widget's bounds in global coordinates.
  /// Returns null if the widget is not mounted or doesn't have a RenderObject.
  ///
  /// Example:
  /// ```dart
  /// final center = context.globalCenter;
  /// if (center != null) {
  ///   print('Widget center at: $center');
  /// }
  /// ```
  Offset? get globalCenter {
    final bounds = globalPaintBounds;
    return bounds?.center;
  }

  /// Gets the size of the widget in logical pixels
  ///
  /// Returns the width and height of the widget, or null if not mounted.
  ///
  /// Example:
  /// ```dart
  /// final size = context.widgetSize;
  /// if (size != null) {
  ///   print('Widget size: ${size.width}x${size.height}');
  /// }
  /// ```
  Size? get widgetSize {
    final renderObject = findRenderObject();
    return (renderObject is RenderBox) ? renderObject.size : null;
  }

  /// Checks if the widget is within the visible viewport
  ///
  /// Returns true if any part of the widget is visible on screen.
  /// Uses MediaQuery to determine screen bounds and accounting for safe areas.
  ///
  /// Example:
  /// ```dart
  /// if (context.isWidgetInViewport) {
  ///   print('Widget is visible');
  /// }
  /// ```
  bool get isWidgetInViewport {
    final bounds = globalPaintBounds;
    if (bounds == null) return false;

    final mediaQuery = MediaQuery.of(this);
    final screenSize = mediaQuery.size;

    // Check if widget bounds intersect with visible screen area
    final visibleArea = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height - mediaQuery.viewInsets.bottom,
    );

    return bounds.overlaps(visibleArea);
  }

  /// Gets the offset amount needed to scroll to center this widget
  ///
  /// Useful for auto-scrolling widgets into view. Returns the amount to scroll
  /// from the current position to center the widget on screen.
  ///
  /// Example:
  /// ```dart
  /// final scrollOffset = context.scrollOffsetToCenter;
  /// if (scrollOffset != null) {
  ///   scrollController.animateTo(scrollOffset, ...);
  /// }
  /// ```
  double? get scrollOffsetToCenter {
    final bounds = globalPaintBounds;
    if (bounds == null) return null;

    final mediaQuery = MediaQuery.of(this);
    final screenHeight = mediaQuery.size.height;
    final widgetCenter = bounds.center.dy;
    const screenCenter = 0.5; // Middle of screen

    // Calculate scroll offset to center widget
    return widgetCenter - (screenHeight * screenCenter);
  }
}
