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

// Admin account tier management (only admins can change accountTier)
export { setAccountTier } from './admin/setAccountTier';

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

// ========================================
// 🔐 GDPR: Data Retention & Cleanup (Scheduled)
// ========================================
// Export GDPR data retention functions:
// - checkInactiveUsers: Monthly check for 24-month retention (with 23-month warning)
// - hardDeleteProgressPhotos: Daily cleanup of soft-deleted photos after 30 days
export {
  gdprCheckInactiveUsers,
  gdprHardDeletePhotos,
} from './gdpr/dataRetention';

// ========================================
// 🔐 GDPR: Admin Access Audit Log (Art. 5(2) Accountability)
// ========================================
// Export admin audit log functions:
// - logAdminAccess: Callable function for admin panel to log access
// - auditUserDataAccess: Firestore trigger for user document changes
// - getAuditLogForUser: Get audit log for GDPR Art. 15 requests
// - cleanupOldAuditLogs: Monthly cleanup (2-year retention)
export {
  gdprLogAdminAccess,
  gdprAuditUserData,
  gdprGetAuditLog,
  gdprCleanupAuditLogs,
} from './gdpr/adminAuditLog';

// ========================================
// 📊 EXERCISE POPULARITY RANKING SYSTEM
// ========================================
// Export exercise popularity functions:
// - generatePopularityBundle: Scheduled daily (3am) - generates Data Bundle
// - onTemplateCreated: Firestore trigger - increments popularity on template save
export {
  generatePopularityBundle,
} from './scheduled/generatePopularityBundle';
export {
  onTemplateCreated,
} from './triggers/onTemplateCreated';