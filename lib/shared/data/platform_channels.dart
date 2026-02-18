/// Centralized platform channel names shared between Dart and Swift.
/// Swift counterpart: ios/Runner/Config/ChannelNames.swift
///
/// IMPORTANT: Any change here MUST be mirrored in ChannelNames.swift.
abstract final class PlatformChannels {
  static const unified = 'com.gymbro.timer/unified';
  static const liveActivity = 'com.gymbro.timer/live_activity';
  static const workoutSession = 'com.gymbro.timer/workout_session';
  static const notifications = 'com.gymbro/notifications';
  static const featureFlags = 'com.gymbro.feature_flags';
  static const audioDebug = 'com.gymbro.fitlog/audio_debug';
  static const timerSoundFix = 'com.gymbro.timer_sound_fix';
  static const soundTest = 'com.gymbro.sound_test';
  static const backgroundAudio = 'com.gymbro.background_audio';
  static const healthkitActivity = 'com.gymbro/healthkit_activity';
  static const watchConnectivity = 'com.gymbro/watch_connectivity';
}
