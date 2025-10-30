/// 🏋️‍♂️ FitLog Pro - Flutter Fitness App
///
/// 📁 Layer: shared/domain/auth
/// 🎯 Feature: role_based_access_control
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// **CRITICAL SECURITY COMPONENT**
/// Role-Based Access Control (RBAC) for granular permissions
///
/// **Roles:**
/// - `guest`: Limited access (7-day trial)
/// - `user`: Standard access
/// - `coach`: Additional features (client management)
/// - `admin`: Full access (analytics, debug tools)
///
/// **Permissions:**
/// - `create_workout`: Can create new workouts
/// - `view_analytics`: Can view detailed analytics
/// - `export_data`: Can export workout data
/// - `manage_clients`: Can manage client accounts (coach only)
/// - `admin_panel`: Can access admin dashboard
///
/// **Example:**
/// ```dart
/// final rbacService = RBACService(currentUser: user);
///
/// if (rbacService.hasPermission(Permission.viewAnalytics)) {
///   // Show analytics screen
/// }
///
/// if (rbacService.hasRole(UserRole.admin)) {
///   // Show admin panel
/// }
/// ```
library;


/// User roles in the system
enum UserRole {
  /// Guest user (7-day trial, limited features)
  guest,

  /// Standard user (full workout features)
  user,

  /// Coach (+ client management)
  coach,

  /// Admin (+ analytics dashboard, debug tools)
  admin,
}

/// System permissions
enum Permission {
  // Workout permissions
  createWorkout,
  editWorkout,
  deleteWorkout,
  viewWorkoutHistory,

  // Analytics permissions
  viewBasicAnalytics,
  viewAdvancedAnalytics,
  exportData,

  // Social permissions
  shareWorkout,
  followUsers,
  createCommunityPost,

  // Coach permissions
  manageClients,
  viewClientProgress,
  createWorkoutTemplates,

  // Admin permissions
  adminPanel,
  viewSystemAnalytics,
  manageUsers,
  debugTools,
}

/// Service for Role-Based Access Control
///
/// **Thread-Safe:** All methods are synchronous and deterministic
/// **Performance:** O(1) lookup for permissions
class RBACService {
  const RBACService({required this.currentRole});

  final UserRole currentRole;

  /// Check if user has a specific permission
  ///
  /// **Usage:**
  /// ```dart
  /// if (rbacService.hasPermission(Permission.viewAnalytics)) {
  ///   // Show analytics
  /// }
  /// ```
  bool hasPermission(Permission permission) {
    final permissions = _rolePermissions[currentRole] ?? {};
    return permissions.contains(permission);
  }

  /// Check if user has a specific role
  ///
  /// **Usage:**
  /// ```dart
  /// if (rbacService.hasRole(UserRole.admin)) {
  ///   // Admin-only feature
  /// }
  /// ```
  bool hasRole(UserRole role) {
    return currentRole == role;
  }

  /// Check if user has at least the specified role
  ///
  /// **Example:**
  /// ```dart
  /// if (rbacService.hasMinRole(UserRole.coach)) {
  ///   // Available to coach AND admin
  /// }
  /// ```
  bool hasMinRole(UserRole minimumRole) {
    final currentLevel = _roleHierarchy[currentRole] ?? 0;
    final requiredLevel = _roleHierarchy[minimumRole] ?? 0;
    return currentLevel >= requiredLevel;
  }

  /// Get all permissions for current role
  Set<Permission> get allPermissions {
    return _rolePermissions[currentRole] ?? {};
  }

  /// Check if user can access a specific route
  ///
  /// **Usage:**
  /// ```dart
  /// if (!rbacService.canAccessRoute('/admin')) {
  ///   context.go('/home');
  /// }
  /// ```
  bool canAccessRoute(String route) {
    final requiredPermission = _routePermissions[route];

    if (requiredPermission == null) {
      // Route has no permission requirement (public)
      return true;
    }

    return hasPermission(requiredPermission);
  }

  /// Role hierarchy (for minimum role checks)
  static const Map<UserRole, int> _roleHierarchy = {
    UserRole.guest: 0,
    UserRole.user: 1,
    UserRole.coach: 2,
    UserRole.admin: 3,
  };

  /// Permissions for each role
  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.guest: {
      Permission.createWorkout,
      Permission.viewWorkoutHistory,
      Permission.viewBasicAnalytics,
    },
    UserRole.user: {
      // All guest permissions +
      Permission.createWorkout,
      Permission.editWorkout,
      Permission.deleteWorkout,
      Permission.viewWorkoutHistory,
      Permission.viewBasicAnalytics,
      Permission.viewAdvancedAnalytics,
      Permission.exportData,
      Permission.shareWorkout,
      Permission.followUsers,
      Permission.createCommunityPost,
    },
    UserRole.coach: {
      // All user permissions +
      Permission.createWorkout,
      Permission.editWorkout,
      Permission.deleteWorkout,
      Permission.viewWorkoutHistory,
      Permission.viewBasicAnalytics,
      Permission.viewAdvancedAnalytics,
      Permission.exportData,
      Permission.shareWorkout,
      Permission.followUsers,
      Permission.createCommunityPost,
      Permission.manageClients,
      Permission.viewClientProgress,
      Permission.createWorkoutTemplates,
    },
    UserRole.admin: {
      // All permissions
      Permission.createWorkout,
      Permission.editWorkout,
      Permission.deleteWorkout,
      Permission.viewWorkoutHistory,
      Permission.viewBasicAnalytics,
      Permission.viewAdvancedAnalytics,
      Permission.exportData,
      Permission.shareWorkout,
      Permission.followUsers,
      Permission.createCommunityPost,
      Permission.manageClients,
      Permission.viewClientProgress,
      Permission.createWorkoutTemplates,
      Permission.adminPanel,
      Permission.viewSystemAnalytics,
      Permission.manageUsers,
      Permission.debugTools,
    },
  };

  /// Route-to-permission mapping
  static const Map<String, Permission> _routePermissions = {
    '/admin': Permission.adminPanel,
    '/admin-analytics': Permission.viewSystemAnalytics,
    '/manage-clients': Permission.manageClients,
    '/export-data': Permission.exportData,
    '/debug': Permission.debugTools,
  };
}

/// Exception thrown when user lacks required permission
class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message, {this.requiredPermission});

  final String message;
  final Permission? requiredPermission;

  @override
  String toString() {
    if (requiredPermission != null) {
      return 'PermissionDeniedException: $message (required: $requiredPermission)';
    }
    return 'PermissionDeniedException: $message';
  }
}

/// Provider for RBAC service (integrate with Riverpod)
///
/// **Usage:**
/// ```dart
/// final rbacProvider = Provider<RBACService>((ref) {
///   final user = ref.watch(currentUserProvider);
///   final role = user?.role ?? UserRole.guest;
///   return RBACService(currentRole: role);
/// });
/// ```
