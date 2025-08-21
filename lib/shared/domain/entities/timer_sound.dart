enum TimerSound {
  classic('timer_complete', 'Classic'),
  yehBuddie('YehBuddie', 'Yeh Buddie'),
  lightWeight('LightWeight', 'Light Weight');

  const TimerSound(this.fileName, this.displayName);
  
  final String fileName;
  final String displayName;
  
  /// Get iOS sound file name (with .wav extension)
  String get iOSFileName => '$fileName.wav';
  
  /// Get Android resource name (without extension)
  String get androidResourceName => fileName;
  
  /// Get all available sounds as list for UI
  static List<TimerSound> get allSounds => TimerSound.values;
  
  /// Find sound by fileName
  static TimerSound fromFileName(String fileName) {
    return TimerSound.values.firstWhere(
      (sound) => sound.fileName == fileName,
      orElse: () => TimerSound.classic,
    );
  }
  
  /// Check if file exists in assets
  bool get isAssetSound => true;
  
  /// Get localized display name (placeholder for future localization)
  String getLocalizedName() {
    // TODO: Implement with AppLocalizations when needed
    return displayName;
  }
}