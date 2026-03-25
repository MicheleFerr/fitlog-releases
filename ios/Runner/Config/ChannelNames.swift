import Foundation

/// Centralized FlutterMethodChannel names shared between Swift and Dart.
/// Dart counterpart: lib/shared/infrastructure/platform_channels.dart
///
/// IMPORTANT: Any change here MUST be mirrored in PlatformChannels.dart.
enum ChannelNames {
    static let unified            = "com.gymbro.timer/unified"
    static let liveActivity       = "com.gymbro.timer/live_activity"
    static let workoutSession     = "com.gymbro.timer/workout_session"
    static let notifications      = "com.gymbro/notifications"
    static let trackingAuthorization = "com.gymbro/tracking_authorization"
    static let featureFlags       = "com.gymbro.feature_flags"
    static let audioDebug         = "com.gymbro.fitlog/audio_debug"
    static let timerSoundFix      = "com.gymbro.timer_sound_fix"
    static let healthkitActivity  = "com.gymbro/healthkit_activity"
    static let watchConnectivity  = "com.gymbro/watch_connectivity"
    static let appIcon            = "com.gymbro/app_icon"
}
