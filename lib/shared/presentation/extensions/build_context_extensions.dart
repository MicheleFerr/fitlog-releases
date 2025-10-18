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
  /// Text(style: TextStyle(color: context.colors.onSurface))
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
