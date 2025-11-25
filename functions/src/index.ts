/**
 * GymBro Cloud Functions
 * Main entry point for all serverless functions
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// ========================================
// 🔐 SECURITY: Admin Role Management
// ========================================
// Export admin role management functions (Custom Claims)
export {
  setAdminRole,
  revokeAdminRole,
  setInitialAdmin,
  checkAdminStatus,
} from './admin/manageAdminRole';

// ========================================
// 💳 Premium Purchase Verification
// ========================================
// Export premium purchase verification functions
export {
  verifyPremiumPurchase,
  checkExpiredSubscriptions
} from './premium/verifyPremiumPurchase';

// ========================================
// 🔐 SECURITY: Community Moderation (Server-Side Validation)
// ========================================
// Export community contribution moderation functions
export {
  approveContribution,
  rejectContribution,
} from './community/moderateContributions';

// Export sync functions (if needed in future)
// export { processSync } from './sync/processSync';

// Export analytics functions (if needed in future)
// export { aggregateWorkoutStats } from './analytics/aggregateStats';

// ========================================
// 🔐 SECURITY: Rate Limit Cleanup (Scheduled)
// ========================================
// Export rate limit cleanup (runs daily to remove expired entries)
export { cleanupExpiredRateLimits } from './security/rateLimiter';