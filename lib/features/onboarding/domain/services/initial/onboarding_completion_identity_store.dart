import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user id tied to a successful local initial onboarding completion.
///
/// This marker is used to disambiguate:
/// - same user with delayed remote sync (keep local completion),
/// - different user on the same device (force onboarding when needed).
abstract final class OnboardingCompletionIdentityStore {
  static const String _completedUserIdKey =
      'initial_onboarding_completed_user_id';

  static Future<String?> getCompletedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_completedUserIdKey);
  }

  static Future<void> setCompletedUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedUserIdKey, userId);
  }

  static Future<void> clearCompletedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedUserIdKey);
  }
}
