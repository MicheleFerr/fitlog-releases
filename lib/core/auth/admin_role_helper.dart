/// 🔐 SECURITY: Admin Role Helper (Custom Claims)
///
/// This helper provides secure admin role checking using Firebase Custom Claims
/// instead of client-side email checks (which can be bypassed).
///
/// **How It Works**:
/// 1. Admin roles are set server-side via Cloud Functions
/// 2. Custom claims are embedded in Firebase ID tokens
/// 3. Client reads from token (cannot forge)
/// 4. Security rules validate token server-side
///
/// **Migration from Email Check**:
/// - **OLD (INSECURE)**: `final isAdmin = email == 'ferrara-michele@hotmail.it'`
/// - **NEW (SECURE)**: `final isAdmin = await AdminRoleHelper.isCurrentUserAdmin()`
///
/// **Example Usage**:
/// ```dart
/// // Check if current user is admin
/// final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();
///
/// if (isAdmin) {
///   // Show admin features
/// }
///
/// // Grant admin role to another user (admin-only)
/// await AdminRoleHelper.grantAdminRole('newadmin@example.com');
/// ```
///
/// @see functions/src/admin/manageAdminRole.ts (Cloud Function)
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';

class AdminRoleHelper {
  // Private constructor (prevent instantiation - utility class)
  AdminRoleHelper._();

  // 🔐 SECURITY: Rate limit handler for Cloud Function calls
  static final _rateLimitHandler = RateLimitHandler(
    maxRetries: 2,
    retryMultiplier: 1.5,
  );

  /// Check if the current authenticated user is an admin
  ///
  /// **How it works**:
  /// 1. Gets current user from FirebaseAuth
  /// 2. Retrieves ID token result (contains custom claims)
  /// 3. Checks if `admin` claim is true
  ///
  /// **Returns**: `true` if user is admin, `false` otherwise
  ///
  /// **Example**:
  /// ```dart
  /// final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();
  ///
  /// if (isAdmin) {
  ///   // Show admin dashboard
  ///   Navigator.pushNamed(context, '/admin');
  /// }
  /// ```
  ///
  /// **Performance**: This is cached by Firebase Auth SDK. Refreshes every hour
  /// or on manual token refresh.
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // No user authenticated → not admin
        return false;
      }

      // Get ID token result (includes custom claims)
      final idTokenResult = await user.getIdTokenResult();

      // Check if 'admin' custom claim exists and is true
      final adminClaim = idTokenResult.claims?['admin'];

      return adminClaim == true;
    } catch (e) {
      AppLogger.error('Error checking admin status: $e', tag: 'AdminRoleHelper', error: e);
      // Fail-safe: If error, assume not admin (secure default)
      return false;
    }
  }

  /// Check if a specific user ID is an admin
  ///
  /// **Use Case**: When you have a user ID but not the current user
  ///
  /// **Note**: This calls a Cloud Function, so it's slower than
  /// `isCurrentUserAdmin()`. Use sparingly.
  ///
  /// **Returns**: `true` if user is admin, `false` otherwise
  static Future<bool> isUserAdmin(String uid) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('checkAdminStatus')
          .call<Map<String, dynamic>>();

      return result.data['isAdmin'] == true;
    } catch (e) {
      AppLogger.error('Error checking admin status for UID $uid: $e', tag: 'AdminRoleHelper', error: e);
      return false;
    }
  }

  /// Grant admin role to a user (requires caller to be admin)
  ///
  /// **Security**:
  /// - Server-side validates caller is admin
  /// - Target email must be whitelisted in Cloud Function
  /// - All operations logged to Firestore audit trail
  ///
  /// **Parameters**:
  /// - `targetEmail`: Email of user to grant admin role to
  ///
  /// **Returns**: Success message if granted, throws exception if failed
  ///
  /// **Example**:
  /// ```dart
  /// try {
  ///   await AdminRoleHelper.grantAdminRole('newadmin@example.com');
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Admin role granted successfully')),
  ///   );
  /// } catch (e) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Failed to grant admin: $e')),
  ///   );
  /// }
  /// ```
  ///
  /// **Throws**: `FirebaseFunctionsException` if:
  /// - Caller is not admin
  /// - Target email not whitelisted
  /// - User not found
  /// - Server error
  static Future<String> grantAdminRole(String targetEmail) async {
    try {
      // 🔐 SECURITY: Wrap with rate limit handler (auto-retry on 429)
      final result = await _rateLimitHandler.executeWithRetry<
          HttpsCallableResult<Map<String, dynamic>>>(
        () => FirebaseFunctions.instance
            .httpsCallable('setAdminRole')
            .call<Map<String, dynamic>>({
          'targetEmail': targetEmail,
        }),
        onRateLimited: (retryAfter) {
          AppLogger.warning('Rate limited. Retrying grant admin in $retryAfter seconds...', tag: 'AdminRoleHelper');
        },
        maxDelay: const Duration(minutes: 2), // Cap max retry delay
      );

      AppLogger.security('Admin role granted to $targetEmail (UID: ${result.data['targetUid']})', tag: 'AdminRoleHelper');

      return result.data['message'] as String;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('Failed to grant admin role: ${e.code} - ${e.message}', tag: 'AdminRoleHelper', error: e);
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected error granting admin role: $e', tag: 'AdminRoleHelper', error: e);
      rethrow;
    }
  }

  /// Revoke admin role from a user (requires caller to be admin)
  ///
  /// **Security**:
  /// - Server-side validates caller is admin
  /// - Cannot revoke own admin role (prevents lockout)
  /// - All operations logged to Firestore audit trail
  ///
  /// **Parameters**:
  /// - `targetEmail`: Email of user to revoke admin role from
  ///
  /// **Returns**: Success message if revoked, throws exception if failed
  ///
  /// **Example**:
  /// ```dart
  /// try {
  ///   await AdminRoleHelper.revokeAdminRole('oldadmin@example.com');
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Admin role revoked successfully')),
  ///   );
  /// } catch (e) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Failed to revoke admin: $e')),
  ///   );
  /// }
  /// ```
  ///
  /// **Throws**: `FirebaseFunctionsException` if:
  /// - Caller is not admin
  /// - Trying to revoke own role
  /// - User not found
  /// - Server error
  static Future<String> revokeAdminRole(String targetEmail) async {
    try {
      // 🔐 SECURITY: Wrap with rate limit handler (auto-retry on 429)
      final result = await _rateLimitHandler.executeWithRetry<
          HttpsCallableResult<Map<String, dynamic>>>(
        () => FirebaseFunctions.instance
            .httpsCallable('revokeAdminRole')
            .call<Map<String, dynamic>>({
          'targetEmail': targetEmail,
        }),
        onRateLimited: (retryAfter) {
          AppLogger.warning('Rate limited. Retrying revoke admin in $retryAfter seconds...', tag: 'AdminRoleHelper');
        },
        maxDelay: const Duration(minutes: 2), // Cap max retry delay
      );

      AppLogger.security('Admin role revoked from $targetEmail (UID: ${result.data['targetUid']})', tag: 'AdminRoleHelper');

      return result.data['message'] as String;
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('Failed to revoke admin role: ${e.code} - ${e.message}', tag: 'AdminRoleHelper', error: e);
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected error revoking admin role: $e', tag: 'AdminRoleHelper', error: e);
      rethrow;
    }
  }

  /// Force refresh the ID token to get latest custom claims
  ///
  /// **When to use**:
  /// - After granting/revoking admin role
  /// - When admin status changes server-side
  /// - Before checking admin status after a known change
  ///
  /// **Example**:
  /// ```dart
  /// // Grant admin to user
  /// await AdminRoleHelper.grantAdminRole('newadmin@example.com');
  ///
  /// // If the new admin is the current user, refresh token
  /// if (currentUserEmail == 'newadmin@example.com') {
  ///   await AdminRoleHelper.forceTokenRefresh();
  ///
  ///   // Now isCurrentUserAdmin() will return true
  ///   final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();
  /// }
  /// ```
  static Future<void> forceTokenRefresh() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        AppLogger.warning('Cannot refresh token: No user authenticated', tag: 'AdminRoleHelper');
        return;
      }

      // Force token refresh (true = forceRefresh parameter)
      await user.getIdToken(true);

      AppLogger.security('ID token refreshed successfully', tag: 'AdminRoleHelper');
    } catch (e) {
      AppLogger.error('Error refreshing ID token: $e', tag: 'AdminRoleHelper', error: e);
      rethrow;
    }
  }

  /// Get all custom claims for the current user (for debugging)
  ///
  /// **Use Case**: Debugging admin role issues
  ///
  /// **Returns**: Map of all custom claims, or null if no user
  ///
  /// **Example**:
  /// ```dart
  /// final claims = await AdminRoleHelper.getCustomClaims();
  ///
  /// if (kDebugMode) {
  ///   debugPrint('Custom claims: $claims');
  ///   // Output: {admin: true, adminGrantedAt: 1699999999999, adminGrantedBy: 'xxx'}
  /// }
  /// ```
  static Future<Map<String, dynamic>?> getCustomClaims() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      final idTokenResult = await user.getIdTokenResult();

      return idTokenResult.claims;
    } catch (e) {
      AppLogger.error('Error getting custom claims: $e', tag: 'AdminRoleHelper', error: e);
      return null;
    }
  }

  /// Get admin metadata (when admin was granted, by whom)
  ///
  /// **Use Case**: Admin dashboard showing admin grant history
  ///
  /// **Returns**: Map with admin metadata, or null if not admin
  ///
  /// **Example**:
  /// ```dart
  /// final metadata = await AdminRoleHelper.getAdminMetadata();
  ///
  /// if (metadata != null) {
  ///   final grantedAt = DateTime.fromMillisecondsSinceEpoch(metadata['adminGrantedAt']);
  ///   final grantedBy = metadata['adminGrantedBy'];
  ///
  ///   print('Admin role granted on $grantedAt by $grantedBy');
  /// }
  /// ```
  static Future<Map<String, dynamic>?> getAdminMetadata() async {
    try {
      final claims = await getCustomClaims();

      if (claims == null || claims['admin'] != true) {
        return null;
      }

      return {
        'adminGrantedAt': claims['adminGrantedAt'],
        'adminGrantedBy': claims['adminGrantedBy'],
        'adminRevokedAt': claims['adminRevokedAt'],
        'adminRevokedBy': claims['adminRevokedBy'],
      };
    } catch (e) {
      AppLogger.error('Error getting admin metadata: $e', tag: 'AdminRoleHelper', error: e);
      return null;
    }
  }
}
