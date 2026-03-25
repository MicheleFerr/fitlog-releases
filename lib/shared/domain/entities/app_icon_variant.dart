/// App icon variants available for iOS home screen.
enum AppIconVariant {
  defaultIcon,
  pink;

  /// iOS alternate icon asset name configured in Info.plist.
  /// `null` means the primary app icon.
  String? get iosIconName {
    switch (this) {
      case AppIconVariant.defaultIcon:
        return null;
      case AppIconVariant.pink:
        return 'AppIconPink';
    }
  }

  static AppIconVariant fromString(String? value) {
    if (value == null) return AppIconVariant.defaultIcon;
    return AppIconVariant.values.firstWhere(
      (variant) => variant.name == value,
      orElse: () => AppIconVariant.defaultIcon,
    );
  }

  static AppIconVariant fromNativeName(String? nativeName) {
    switch (nativeName) {
      case null:
      case 'default':
      case 'defaultIcon':
      case 'AppIcon':
        return AppIconVariant.defaultIcon;
      case 'pink':
      case 'AppIconPink':
        return AppIconVariant.pink;
      default:
        return AppIconVariant.defaultIcon;
    }
  }
}
