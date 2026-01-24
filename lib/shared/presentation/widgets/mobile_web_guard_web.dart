/// Web implementation for user agent detection
library;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

/// Returns the user agent string on web platforms
String getUserAgent() {
  try {
    return html.window.navigator.userAgent;
  } catch (_) {
    return '';
  }
}
