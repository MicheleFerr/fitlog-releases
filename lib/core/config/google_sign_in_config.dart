library;

import 'package:gymbro_flutter_new/core/config/environment_config.dart';

class GoogleSignInConfig {
  GoogleSignInConfig._();

  // Matches the web OAuth client in android/app/google-services.json.
  static const String defaultServerClientId =
      '206648824958-49vgd2ffc9u7a6g1gmd8pr90noeecgcp.apps.googleusercontent.com';

  static String resolveServerClientId({String? configuredValue}) {
    final normalized = configuredValue?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return defaultServerClientId;
  }

  static String get serverClientId => resolveServerClientId(
    configuredValue: EnvironmentConfig.googleServerClientId,
  );
}
