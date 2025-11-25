/// 🔐 SECURITY: Admin Status Provider (Custom Claims)
///
/// Riverpod provider for checking admin status using Firebase Custom Claims
/// instead of client-side email checks.
///
/// **Migration from Insecure Pattern**:
/// - **OLD (VULNERABLE)**:
///   ```dart
///   final isAdmin = userEmail == 'ferrara-michele@hotmail.it' ||
///                   userEmail.contains('admin@');
///   ```
/// - **NEW (SECURE)**:
///   ```dart
///   final adminStatus = ref.watch(adminStatusProvider);
///   final isAdmin = adminStatus.value ?? false;
///   ```
///
/// **Benefits**:
/// - Server-side validation (cannot be forged)
/// - Automatic refresh when auth state changes
/// - Cached for performance
/// - Reactive updates when admin role changes
///
/// **Example Usage**:
/// ```dart
/// // In a ConsumerWidget
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final adminStatus = ref.watch(adminStatusProvider);
///
///   return adminStatus.when(
///     data: (isAdmin) => isAdmin ? AdminDashboard() : UserDashboard(),
///     loading: () => CircularProgressIndicator(),
///     error: (err, stack) => Text('Error: $err'),
///   );
/// }
/// ```
///
/// @see lib/core/auth/admin_role_helper.dart
/// @see functions/src/admin/manageAdminRole.ts
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/auth/admin_role_helper.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

/// Provider for admin status (based on Firebase Custom Claims)
///
/// **How it works**:
/// 1. Listens to Firebase auth state changes via unifiedFirebaseUserProvider
/// 2. When user changes, calls AdminRoleHelper.isCurrentUserAdmin()
/// 3. Returns AsyncValue<bool> (true if admin, false otherwise)
///
/// **Auto-refresh**:
/// - Refreshes when user logs in/out
/// - Refreshes when token expires (every ~1 hour)
/// - Can be manually refreshed via ref.invalidate(adminStatusProvider)
///
/// **Performance**:
/// - Result is cached by Riverpod
/// - Firebase Auth caches ID token locally
/// - No unnecessary re-checks unless auth state changes
final adminStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  // Watch Firebase auth state to automatically refresh when user changes
  final firebaseUser = ref.watch(unifiedFirebaseUserProvider);

  // If no user authenticated, definitely not admin
  if (firebaseUser.value == null) {
    return false;
  }

  // Check admin status via custom claims (secure)
  final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();

  return isAdmin;
});

/// Provider for admin status (synchronous fallback)
///
/// **Use Case**: When you need a non-nullable bool immediately
///
/// **Returns**: `true` if admin, `false` if not admin or loading/error
///
/// **Example**:
/// ```dart
/// final isAdmin = ref.watch(isAdminProvider);
///
/// if (isAdmin) {
///   // Show admin features
/// }
/// ```
final isAdminProvider = Provider.autoDispose<bool>((ref) {
  final adminStatus = ref.watch(adminStatusProvider);

  return adminStatus.value ?? false;
});

/// Provider for admin metadata (grant time, granted by, etc.)
///
/// **Use Case**: Admin dashboard showing when/by whom admin was granted
///
/// **Returns**: AsyncValue<Map<String, dynamic>?> with metadata, or null if not admin
///
/// **Example**:
/// ```dart
/// final metadata = ref.watch(adminMetadataProvider);
///
/// metadata.when(
///   data: (data) {
///     if (data != null) {
///       final grantedAt = DateTime.fromMillisecondsSinceEpoch(data['adminGrantedAt']);
///       return Text('Admin since: ${DateFormat.yMd().format(grantedAt)}');
///     }
///     return Text('Not an admin');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final adminMetadataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  // Watch admin status to only fetch metadata if admin
  final isAdmin = await ref.watch(adminStatusProvider.future);

  if (!isAdmin) {
    return null;
  }

  final metadata = await AdminRoleHelper.getAdminMetadata();

  return metadata;
});

/// Provider for all custom claims (debug/admin use)
///
/// **Use Case**: Debugging authentication issues, admin panel showing all claims
///
/// **Returns**: AsyncValue<Map<String, dynamic>?> with all custom claims
///
/// **Example**:
/// ```dart
/// final claims = ref.watch(customClaimsProvider);
///
/// claims.when(
///   data: (data) => Text('Claims: ${data?.keys.join(', ')}'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final customClaimsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  // Watch Firebase auth state
  final firebaseUser = ref.watch(unifiedFirebaseUserProvider);

  if (firebaseUser.value == null) {
    return null;
  }

  final claims = await AdminRoleHelper.getCustomClaims();

  return claims;
});
