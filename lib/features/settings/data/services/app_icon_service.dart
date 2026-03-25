import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_icon_variant.dart';

/// Native bridge for alternate app icon switching.
class AppIconService {
  AppIconService._();

  static const MethodChannel _channel = MethodChannel(PlatformChannels.appIcon);

  static Future<bool> isSupported() async {
    if (!_isSupportedRuntime) return false;

    final supported = await _channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  static Future<AppIconVariant> getCurrentIcon() async {
    if (!_isSupportedRuntime) return AppIconVariant.defaultIcon;

    final currentIcon = await _channel.invokeMethod<String>('getCurrentIcon');
    return AppIconVariant.fromNativeName(currentIcon);
  }

  static Future<void> setIcon(AppIconVariant variant) async {
    if (!_isSupportedRuntime) return;

    await _channel.invokeMethod<void>('setIcon', {
      'iconName': variant.iosIconName ?? 'default',
    });
  }

  static bool get _isSupportedRuntime =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.android => true,
        _ => false,
      };
}
