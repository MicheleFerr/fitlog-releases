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
export { cleanupExpiredRateLimits } from './security/rateLimiterV1';

// ========================================
// 🔐 SECURITY: Document Rate Limiting (Firestore Triggers)
// ========================================
// Enforces rate limits on document creation (2025-12-27 Security Audit)
// - Body measurements: Max 100/day per user
// - Consent changes: Max 10/day per user
export {
  enforceMeasurementRateLimit,
  enforceConsentRateLimit,
} from './security/documentRateLimiter';

// ========================================
// 📝 TEMPLATE QUOTA MANAGEMENT (Server-Side Enforcement)
// ========================================
// Export template creation with quota enforcement
// SECURITY: This is the ONLY secure way to enforce template limits
// Client-side validation is NOT sufficient for security
export {
  createTemplate,
  getTemplateQuota,
} from './templates/createTemplate';