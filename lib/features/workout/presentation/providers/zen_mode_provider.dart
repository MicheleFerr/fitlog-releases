import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Configuration for Zen Mode
class ZenConfig {

  const ZenConfig({
    this.hideCommunitySuggestions = true,
    this.hideWarmupCards = true,
    this.hideExerciseChips = false, // Manteniamo i chips muscoli per default
    this.hideXPAnimations = true,
    this.hideTutorials = true,
    this.hideSmartSuggestions = true,
    this.keepScreenOn = true,
    this.showTUT = false,
    this.showVelocity = false,
    this.showVolume = true,
  });

  factory ZenConfig.fromJson(Map<String, dynamic> json) => ZenConfig(
    hideCommunitySuggestions: json['hideCommunitySuggestions'] ?? true,
    hideWarmupCards: json['hideWarmupCards'] ?? true,
    hideExerciseChips: json['hideExerciseChips'] ?? false,
    hideXPAnimations: json['hideXPAnimations'] ?? true,
    hideTutorials: json['hideTutorials'] ?? true,
    hideSmartSuggestions: json['hideSmartSuggestions'] ?? true,
    keepScreenOn: json['keepScreenOn'] ?? true,
    showTUT: json['showTUT'] ?? false,
    showVelocity: json['showVelocity'] ?? false,
    showVolume: json['showVolume'] ?? true,
  );
  final bool hideCommunitySuggestions;
  final bool hideWarmupCards;
  final bool hideExerciseChips;
  final bool hideXPAnimations;
  final bool hideTutorials;
  final bool hideSmartSuggestions;
  final bool keepScreenOn;
  final bool showTUT; // Time Under Tension
  final bool showVelocity;
  final bool showVolume;

  ZenConfig copyWith({
    bool? hideCommunitySuggestions,
    bool? hideWarmupCards,
    bool? hideExerciseChips,
    bool? hideXPAnimations,
    bool? hideTutorials,
    bool? hideSmartSuggestions,
    bool? keepScreenOn,
    bool? showTUT,
    bool? showVelocity,
    bool? showVolume,
  }) {
    return ZenConfig(
      hideCommunitySuggestions: hideCommunitySuggestions ?? this.hideCommunitySuggestions,
      hideWarmupCards: hideWarmupCards ?? this.hideWarmupCards,
      hideExerciseChips: hideExerciseChips ?? this.hideExerciseChips,
      hideXPAnimations: hideXPAnimations ?? this.hideXPAnimations,
      hideTutorials: hideTutorials ?? this.hideTutorials,
      hideSmartSuggestions: hideSmartSuggestions ?? this.hideSmartSuggestions,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showTUT: showTUT ?? this.showTUT,
      showVelocity: showVelocity ?? this.showVelocity,
      showVolume: showVolume ?? this.showVolume,
    );
  }

  Map<String, dynamic> toJson() => {
    'hideCommunitySuggestions': hideCommunitySuggestions,
    'hideWarmupCards': hideWarmupCards,
    'hideExerciseChips': hideExerciseChips,
    'hideXPAnimations': hideXPAnimations,
    'hideTutorials': hideTutorials,
    'hideSmartSuggestions': hideSmartSuggestions,
    'keepScreenOn': keepScreenOn,
    'showTUT': showTUT,
    'showVelocity': showVelocity,
    'showVolume': showVolume,
  };
}

/// State for Zen Mode
class ZenModeState {

  const ZenModeState({
    this.isEnabled = false,
    this.config = const ZenConfig(),
    this.isKeepScreenOnActive = false,
  });
  final bool isEnabled;
  final ZenConfig config;
  final bool isKeepScreenOnActive;

  ZenModeState copyWith({
    bool? isEnabled,
    ZenConfig? config,
    bool? isKeepScreenOnActive,
  }) {
    return ZenModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      config: config ?? this.config,
      isKeepScreenOnActive: isKeepScreenOnActive ?? this.isKeepScreenOnActive,
    );
  }
}

/// Notifier for Zen Mode state management
class ZenModeNotifier extends StateNotifier<ZenModeState> {

  ZenModeNotifier(Ref ref) : super(const ZenModeState()) {
    _loadPreferences();
  }
  static const String _zenModeKey = 'zen_mode_enabled';
  static const String _zenConfigKey = 'zen_mode_config';
  static const String _keepScreenOnKey = 'keep_screen_on';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Zen Mode enabled state
    final isEnabled = prefs.getBool(_zenModeKey) ?? false;
    
    // Load Zen Config
    final configJson = prefs.getString(_zenConfigKey);
    final config = configJson != null 
      ? ZenConfig.fromJson(Map<String, dynamic>.from(
          configJson.split(',').fold({}, (map, item) {
            final parts = item.split(':');
            if (parts.length == 2) {
              map[parts[0]] = parts[1] == 'true';
            }
            return map;
          })
        ))
      : const ZenConfig();
    
    // Load Keep Screen On state
    final keepScreenOn = prefs.getBool(_keepScreenOnKey) ?? false;
    
    state = ZenModeState(
      isEnabled: isEnabled,
      config: config,
      isKeepScreenOnActive: keepScreenOn,
    );
    
    // Apply keep screen on if active
    if (keepScreenOn) {
      await WakelockPlus.enable();
    }
  }

  Future<void> toggleZenMode() async {
    final newState = !state.isEnabled;
    state = state.copyWith(isEnabled: newState);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_zenModeKey, newState);
    
    // Se Zen Mode è attivata e keepScreenOn è configurato, attiva wakelock
    if (newState && state.config.keepScreenOn) {
      await toggleKeepScreenOn(true);
    }
  }

  Future<void> toggleKeepScreenOn([bool? value]) async {
    final newValue = value ?? !state.isKeepScreenOnActive;
    
    if (newValue) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
    
    state = state.copyWith(isKeepScreenOnActive: newValue);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keepScreenOnKey, newValue);
  }

  Future<void> updateConfig(ZenConfig newConfig) async {
    state = state.copyWith(config: newConfig);
    
    final prefs = await SharedPreferences.getInstance();
    // Simple serialization for SharedPreferences
    final configString = newConfig.toJson().entries
      .map((e) => '${e.key}:${e.value}')
      .join(',');
    await prefs.setString(_zenConfigKey, configString);
    
    // Update keep screen on based on config
    if (state.isEnabled && newConfig.keepScreenOn != state.isKeepScreenOnActive) {
      await toggleKeepScreenOn(newConfig.keepScreenOn);
    }
  }

  Future<void> updateConfigField(String field, bool value) async {
    ZenConfig newConfig;
    
    switch (field) {
      case 'hideCommunitySuggestions':
        newConfig = state.config.copyWith(hideCommunitySuggestions: value);
        break;
      case 'hideWarmupCards':
        newConfig = state.config.copyWith(hideWarmupCards: value);
        break;
      case 'hideExerciseChips':
        newConfig = state.config.copyWith(hideExerciseChips: value);
        break;
      case 'hideXPAnimations':
        newConfig = state.config.copyWith(hideXPAnimations: value);
        break;
      case 'hideTutorials':
        newConfig = state.config.copyWith(hideTutorials: value);
        break;
      case 'hideSmartSuggestions':
        newConfig = state.config.copyWith(hideSmartSuggestions: value);
        break;
      case 'keepScreenOn':
        newConfig = state.config.copyWith(keepScreenOn: value);
        if (state.isEnabled) {
          await toggleKeepScreenOn(value);
        }
        break;
      case 'showTUT':
        newConfig = state.config.copyWith(showTUT: value);
        break;
      case 'showVelocity':
        newConfig = state.config.copyWith(showVelocity: value);
        break;
      case 'showVolume':
        newConfig = state.config.copyWith(showVolume: value);
        break;
      default:
        return;
    }
    
    await updateConfig(newConfig);
  }

  @override
  void dispose() {
    // Disabilita wakelock quando il provider viene dismesso
    if (state.isKeepScreenOnActive) {
      WakelockPlus.disable();
    }
    super.dispose();
  }
}

/// Provider for Zen Mode
final zenModeProvider = StateNotifierProvider<ZenModeNotifier, ZenModeState>((ref) {
  return ZenModeNotifier(ref);
});