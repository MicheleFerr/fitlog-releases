import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// BuildContext extensions for easier access to common properties
extension BuildContextExtensions on BuildContext {
  /// Access to AppLocalizations
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Access to Theme
  ThemeData get theme => Theme.of(this);

  /// Access to ColorScheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Access to TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access to MediaQuery size
  Size get screenSize => MediaQuery.of(this).size;

  /// Access to screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Access to screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Access to padding
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Access to view insets
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}
