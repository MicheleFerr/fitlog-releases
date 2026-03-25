import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/registry/hint_registry.dart';

/// Service singleton that manages discoverability hint scheduling.
///
/// Responsibilities:
/// - Determines which hints are eligible based on TutorialState
/// - Enforces session limits (new users: 3, existing users: 2)
/// - Enforces cooldown between consecutive hints (new: 20s, existing: 30s)
/// - Returns next hint from priority queue (P0 > P1 > P2)
///
/// Pattern: Singleton with Lock (as per CLAUDE.md performance rules).
/// This service is stateless regarding persistence - it reads from
/// [TutorialState] and delegates writes to [TutorialStateNotifier].
class DiscoverabilityHintService {
  factory DiscoverabilityHintService() =>
      _instance ??= DiscoverabilityHintService._();
  DiscoverabilityHintService._();
  static DiscoverabilityHintService? _instance;

  /// Lock for thread-safe operations.
  final _lock = Lock();

  /// Max hints per session for new users.
  static const int maxHintsPerSessionNewUser = 3;

  /// Max hints per session for existing users.
  static const int maxHintsPerSessionExistingUser = 2;

  /// Cooldown between hints for new users.
  static const Duration hintCooldownNewUser = Duration(seconds: 20);

  /// Cooldown between hints for existing users.
  static const Duration hintCooldownExistingUser = Duration(seconds: 30);

  /// Number of hints shown in this session.
  int _hintsShownThisSession = 0;

  /// Timestamp of the last hint shown.
  DateTime? _lastHintShownAt;

  /// Currently active hint (only one at a time).
  HintConfig? _activeHint;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PUBLIC API
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Whether there is a hint currently being displayed.
  HintConfig? get activeHint => _activeHint;

  /// Number of hints shown this session.
  int get hintsShownThisSession => _hintsShownThisSession;

  /// Timestamp of last hint shown.
  DateTime? get lastHintShownAt => _lastHintShownAt;

  /// Check if a specific hint should be shown given current state.
  ///
  /// Evaluates:
  /// 1. Tutorials globally enabled
  /// 2. Session limit not reached
  /// 3. Cooldown respected
  /// 4. No other hint currently active
  /// 5. Hint-specific conditions (workout count, seen/dismissed state)
  bool shouldShow(String hintId, TutorialState tutorialState) {
    if (!tutorialState.tutorialsEnabled) return false;
    if (_hintsShownThisSession >= _sessionLimitFor(tutorialState)) return false;
    if (_activeHint != null) return false;
    if (!_isCooldownRespected(tutorialState)) return false;

    final config = HintRegistry.findById(hintId);
    if (config == null) return false;

    return _isHintEligible(config, tutorialState);
  }

  /// Get the next best hint to show from the priority queue.
  ///
  /// Scans all hints in P0 > P1 > P2 order and returns the first
  /// eligible one. Returns null if no hint qualifies.
  Future<HintConfig?> getNextHint(TutorialState tutorialState) async {
    return _lock.synchronized(() {
      if (!tutorialState.tutorialsEnabled) return null;
      if (_hintsShownThisSession >= _sessionLimitFor(tutorialState)) return null;
      if (_activeHint != null) return null;
      if (!_isCooldownRespected(tutorialState)) return null;

      // HintRegistry.allHints is already sorted P0 > P1 > P2
      for (final hint in HintRegistry.allHints) {
        if (_isHintEligible(hint, tutorialState)) {
          return hint;
        }
      }

      return null;
    });
  }

  /// Mark a hint as currently being shown.
  ///
  /// Call this when the hint widget appears on screen.
  void markHintShown(HintConfig hint) {
    _activeHint = hint;
    _hintsShownThisSession++;
    _lastHintShownAt = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        'Hint shown: ${hint.hintId} '
        '(session: $_hintsShownThisSession)',
      );
    }
  }

  /// Mark the active hint as dismissed/completed.
  ///
  /// Call this when the hint is dismissed by user or auto-timeout.
  void markHintDismissed() {
    if (kDebugMode && _activeHint != null) {
      debugPrint('Hint dismissed: ${_activeHint!.hintId}');
    }
    _activeHint = null;
  }

  /// Reset session counters. Call on app restart or new session.
  void resetSession() {
    _hintsShownThisSession = 0;
    _lastHintShownAt = null;
    _activeHint = null;

    if (kDebugMode) {
      debugPrint('Hint session reset');
    }
  }

  /// Check if a specific hint is eligible given current context.
  ///
  /// Use this for targeted hint checks (e.g., when a specific screen loads).
  /// Unlike [getNextHint], this does NOT enforce session limits or cooldown,
  /// only hint-specific eligibility.
  bool isHintEligible(String hintId, TutorialState tutorialState) {
    final config = HintRegistry.findById(hintId);
    if (config == null) return false;
    return _isHintEligible(config, tutorialState);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIVATE HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check if the cooldown period has elapsed since last hint.
  bool _isCooldownRespected(TutorialState tutorialState) {
    if (_lastHintShownAt == null) return true;
    return DateTime.now().difference(_lastHintShownAt!) >=
        _cooldownFor(tutorialState);
  }

  int _sessionLimitFor(TutorialState tutorialState) {
    return tutorialState.isNewUser
        ? maxHintsPerSessionNewUser
        : maxHintsPerSessionExistingUser;
  }

  Duration _cooldownFor(TutorialState tutorialState) {
    return tutorialState.isNewUser
        ? hintCooldownNewUser
        : hintCooldownExistingUser;
  }

  /// Check hint-specific eligibility against TutorialState.
  bool _isHintEligible(HintConfig config, TutorialState tutorialState) {
    // Check workout requirement
    if (tutorialState.totalWorkouts < config.requiredWorkouts) {
      return false;
    }

    // For permanent hints: check if already seen via markTutorialSeen
    if (config.permanent) {
      return !tutorialState.hasSeen(config.hintId);
    }

    // For dismissable hints: check cooldown via canShowHint (24h cooldown)
    return tutorialState.canShowHint(config.hintId);
  }
}
