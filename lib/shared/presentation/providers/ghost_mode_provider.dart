import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Configuration for Ghost Mode
///
/// Nasconde elementi competitivi e sociali per utenti che preferiscono
/// un'esperienza fitness privata senza confronti o pressione sociale.
class GhostModeConfig {
  const GhostModeConfig({
    this.hideXPProgress = true,
    this.hideTierBadge = true,
    this.hideStreak = false, // Opzionale - alcuni lo trovano motivante
    this.hideCommunity = true,
    this.hideStrengthComparisons = true,
    this.hideXPAnimations = true,
  });

  /// Nasconde la barra XP e progressi livello nella Home
  final bool hideXPProgress;

  /// Nasconde il badge del tier (Bronze, Silver, Gold, etc.)
  final bool hideTierBadge;

  /// Nasconde il contatore streak (opzionale, default false)
  final bool hideStreak;

  /// Nasconde la sezione Community e relative card
  final bool hideCommunity;

  /// Nasconde i confronti con altri utenti negli analytics
  final bool hideStrengthComparisons;

  /// Nasconde le animazioni XP dopo il completamento workout
  final bool hideXPAnimations;

  GhostModeConfig copyWith({
    bool? hideXPProgress,
    bool? hideTierBadge,
    bool? hideStreak,
    bool? hideCommunity,
    bool? hideStrengthComparisons,
    bool? hideXPAnimations,
  }) {
    return GhostModeConfig(
      hideXPProgress: hideXPProgress ?? this.hideXPProgress,
      hideTierBadge: hideTierBadge ?? this.hideTierBadge,
      hideStreak: hideStreak ?? this.hideStreak,
      hideCommunity: hideCommunity ?? this.hideCommunity,
      hideStrengthComparisons:
          hideStrengthComparisons ?? this.hideStrengthComparisons,
      hideXPAnimations: hideXPAnimations ?? this.hideXPAnimations,
    );
  }

  Map<String, dynamic> toJson() => {
        'hideXPProgress': hideXPProgress,
        'hideTierBadge': hideTierBadge,
        'hideStreak': hideStreak,
        'hideCommunity': hideCommunity,
        'hideStrengthComparisons': hideStrengthComparisons,
        'hideXPAnimations': hideXPAnimations,
      };

  factory GhostModeConfig.fromJson(Map<String, dynamic> json) => GhostModeConfig(
        hideXPProgress: json['hideXPProgress'] as bool? ?? true,
        hideTierBadge: json['hideTierBadge'] as bool? ?? true,
        hideStreak: json['hideStreak'] as bool? ?? false,
        hideCommunity: json['hideCommunity'] as bool? ?? true,
        hideStrengthComparisons: json['hideStrengthComparisons'] as bool? ?? true,
        hideXPAnimations: json['hideXPAnimations'] as bool? ?? true,
      );
}

/// State for Ghost Mode
class GhostModeState {
  const GhostModeState({
    this.isEnabled = false,
    this.config = const GhostModeConfig(),
  });

  final bool isEnabled;
  final GhostModeConfig config;

  GhostModeState copyWith({
    bool? isEnabled,
    GhostModeConfig? config,
  }) {
    return GhostModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      config: config ?? this.config,
    );
  }
}

/// Notifier for Ghost Mode state management
class GhostModeNotifier extends Notifier<GhostModeState> {
  // User-scoped cache keys
  String get _ghostModeKey => userCacheKeys.userScopedKey('ghost_mode_enabled');
  String get _ghostConfigKey => userCacheKeys.userScopedKey('ghost_mode_config');

  @override
  GhostModeState build() {
    _loadPreferences();
    return const GhostModeState();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_ghostModeKey) ?? false;

    // Load config from serialized string
    final configString = prefs.getString(_ghostConfigKey);
    final config = configString != null
        ? GhostModeConfig.fromJson(_parseConfigString(configString))
        : const GhostModeConfig();

    state = GhostModeState(isEnabled: isEnabled, config: config);
  }

  Map<String, dynamic> _parseConfigString(String configString) {
    final map = <String, dynamic>{};
    for (final item in configString.split(',')) {
      final parts = item.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1] == 'true';
      }
    }
    return map;
  }

  String _serializeConfig(GhostModeConfig config) {
    return config
        .toJson()
        .entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
  }

  /// Toggle Ghost Mode on/off
  Future<void> toggleGhostMode() async {
    final newState = !state.isEnabled;
    state = state.copyWith(isEnabled: newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostModeKey, newState);
  }

  /// Set Ghost Mode enabled state directly
  Future<void> setEnabled(bool enabled) async {
    if (state.isEnabled == enabled) return;

    state = state.copyWith(isEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostModeKey, enabled);
  }

  /// Update entire config
  Future<void> updateConfig(GhostModeConfig newConfig) async {
    state = state.copyWith(config: newConfig);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ghostConfigKey, _serializeConfig(newConfig));
  }

  /// Update a single config field
  Future<void> updateConfigField(String field, {required bool value}) async {
    GhostModeConfig newConfig;

    switch (field) {
      case 'hideXPProgress':
        newConfig = state.config.copyWith(hideXPProgress: value);
      case 'hideTierBadge':
        newConfig = state.config.copyWith(hideTierBadge: value);
      case 'hideStreak':
        newConfig = state.config.copyWith(hideStreak: value);
      case 'hideCommunity':
        newConfig = state.config.copyWith(hideCommunity: value);
      case 'hideStrengthComparisons':
        newConfig = state.config.copyWith(hideStrengthComparisons: value);
      case 'hideXPAnimations':
        newConfig = state.config.copyWith(hideXPAnimations: value);
      default:
        return;
    }

    await updateConfig(newConfig);
  }
}

/// Main provider for Ghost Mode
final ghostModeProvider =
    NotifierProvider<GhostModeNotifier, GhostModeState>(GhostModeNotifier.new);

// ============================================================================
// Convenience Providers - Per accesso rapido nei widget
// ============================================================================

/// Whether Ghost Mode is currently enabled
final isGhostModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(ghostModeProvider).isEnabled;
});

/// Current Ghost Mode configuration
final ghostModeConfigProvider = Provider<GhostModeConfig>((ref) {
  return ref.watch(ghostModeProvider).config;
});

// ============================================================================
// Specific Hide Providers - Da usare nei singoli widget
// ============================================================================

/// Should hide XP Progress Bar (Home screen)
final shouldHideXPProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideXPProgress;
});

/// Should hide Community features
final shouldHideCommunityProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideCommunity;
});

/// Should hide Tier Badge
final shouldHideTierProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideTierBadge;
});

/// Should hide Streak counter
final shouldHideStreakProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideStreak;
});

/// Should hide Strength Comparisons in analytics
final shouldHideStrengthComparisonsProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideStrengthComparisons;
});

/// Should hide XP Animations after workout
final shouldHideXPAnimationsProvider = Provider<bool>((ref) {
  final state = ref.watch(ghostModeProvider);
  return state.isEnabled && state.config.hideXPAnimations;
});
