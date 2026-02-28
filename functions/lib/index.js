"use strict";
/**
 * GymBro Cloud Functions
 * Main entry point for all serverless functions
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiCoachChatCompletion = exports.onTemplateCreated = exports.generatePopularityBundle = exports.gdprCleanupAuditLogs = exports.gdprGetAuditLog = exports.gdprAuditUserData = exports.gdprLogAdminAccess = exports.gdprHardDeletePhotos = exports.gdprCheckInactiveUsers = exports.getTemplateQuota = exports.createTemplate = exports.enforceConsentRateLimit = exports.enforceMeasurementRateLimit = exports.cleanupExpiredRateLimits = exports.rejectContribution = exports.approveContribution = exports.checkExpiredSubscriptions = exports.verifyPremiumPurchase = exports.setAccountTier = exports.checkAdminStatus = exports.setInitialAdmin = exports.revokeAdminRole = exports.setAdminRole = void 0;
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase Admin
admin.initializeApp();
// ========================================
// 🔐 SECURITY: Admin Role Management
// ========================================
// Export admin role management functions (Custom Claims)
var manageAdminRole_1 = require("./admin/manageAdminRole");
Object.defineProperty(exports, "setAdminRole", { enumerable: true, get: function () { return manageAdminRole_1.setAdminRole; } });
Object.defineProperty(exports, "revokeAdminRole", { enumerable: true, get: function () { return manageAdminRole_1.revokeAdminRole; } });
Object.defineProperty(exports, "setInitialAdmin", { enumerable: true, get: function () { return manageAdminRole_1.setInitialAdmin; } });
Object.defineProperty(exports, "checkAdminStatus", { enumerable: true, get: function () { return manageAdminRole_1.checkAdminStatus; } });
// Admin account tier management (only admins can change accountTier)
var setAccountTier_1 = require("./admin/setAccountTier");
Object.defineProperty(exports, "setAccountTier", { enumerable: true, get: function () { return setAccountTier_1.setAccountTier; } });
// ========================================
// 💳 Premium Purchase Verification
// ========================================
// Export premium purchase verification functions
var verifyPremiumPurchase_1 = require("./premium/verifyPremiumPurchase");
Object.defineProperty(exports, "verifyPremiumPurchase", { enumerable: true, get: function () { return verifyPremiumPurchase_1.verifyPremiumPurchase; } });
Object.defineProperty(exports, "checkExpiredSubscriptions", { enumerable: true, get: function () { return verifyPremiumPurchase_1.checkExpiredSubscriptions; } });
// ========================================
// 🔐 SECURITY: Community Moderation (Server-Side Validation)
// ========================================
// Export community contribution moderation functions
var moderateContributions_1 = require("./community/moderateContributions");
Object.defineProperty(exports, "approveContribution", { enumerable: true, get: function () { return moderateContributions_1.approveContribution; } });
Object.defineProperty(exports, "rejectContribution", { enumerable: true, get: function () { return moderateContributions_1.rejectContribution; } });
// Export sync functions (if needed in future)
// export { processSync } from './sync/processSync';
// Export analytics functions (if needed in future)
// export { aggregateWorkoutStats } from './analytics/aggregateStats';
// ========================================
// 🔐 SECURITY: Rate Limit Cleanup (Scheduled)
// ========================================
// Export rate limit cleanup (runs daily to remove expired entries)
var rateLimiterV1_1 = require("./security/rateLimiterV1");
Object.defineProperty(exports, "cleanupExpiredRateLimits", { enumerable: true, get: function () { return rateLimiterV1_1.cleanupExpiredRateLimits; } });
// ========================================
// 🔐 SECURITY: Document Rate Limiting (Firestore Triggers)
// ========================================
// Enforces rate limits on document creation (2025-12-27 Security Audit)
// - Body measurements: Max 100/day per user
// - Consent changes: Max 10/day per user
var documentRateLimiter_1 = require("./security/documentRateLimiter");
Object.defineProperty(exports, "enforceMeasurementRateLimit", { enumerable: true, get: function () { return documentRateLimiter_1.enforceMeasurementRateLimit; } });
Object.defineProperty(exports, "enforceConsentRateLimit", { enumerable: true, get: function () { return documentRateLimiter_1.enforceConsentRateLimit; } });
// ========================================
// 📝 TEMPLATE QUOTA MANAGEMENT (Server-Side Enforcement)
// ========================================
// Export template creation with quota enforcement
// SECURITY: This is the ONLY secure way to enforce template limits
// Client-side validation is NOT sufficient for security
var createTemplate_1 = require("./templates/createTemplate");
Object.defineProperty(exports, "createTemplate", { enumerable: true, get: function () { return createTemplate_1.createTemplate; } });
Object.defineProperty(exports, "getTemplateQuota", { enumerable: true, get: function () { return createTemplate_1.getTemplateQuota; } });
// ========================================
// 🔐 GDPR: Data Retention & Cleanup (Scheduled)
// ========================================
// Export GDPR data retention functions:
// - checkInactiveUsers: Monthly check for 24-month retention (with 23-month warning)
// - hardDeleteProgressPhotos: Daily cleanup of soft-deleted photos after 30 days
var dataRetention_1 = require("./gdpr/dataRetention");
Object.defineProperty(exports, "gdprCheckInactiveUsers", { enumerable: true, get: function () { return dataRetention_1.gdprCheckInactiveUsers; } });
Object.defineProperty(exports, "gdprHardDeletePhotos", { enumerable: true, get: function () { return dataRetention_1.gdprHardDeletePhotos; } });
// ========================================
// 🔐 GDPR: Admin Access Audit Log (Art. 5(2) Accountability)
// ========================================
// Export admin audit log functions:
// - logAdminAccess: Callable function for admin panel to log access
// - auditUserDataAccess: Firestore trigger for user document changes
// - getAuditLogForUser: Get audit log for GDPR Art. 15 requests
// - cleanupOldAuditLogs: Monthly cleanup (2-year retention)
var adminAuditLog_1 = require("./gdpr/adminAuditLog");
Object.defineProperty(exports, "gdprLogAdminAccess", { enumerable: true, get: function () { return adminAuditLog_1.gdprLogAdminAccess; } });
Object.defineProperty(exports, "gdprAuditUserData", { enumerable: true, get: function () { return adminAuditLog_1.gdprAuditUserData; } });
Object.defineProperty(exports, "gdprGetAuditLog", { enumerable: true, get: function () { return adminAuditLog_1.gdprGetAuditLog; } });
Object.defineProperty(exports, "gdprCleanupAuditLogs", { enumerable: true, get: function () { return adminAuditLog_1.gdprCleanupAuditLogs; } });
// ========================================
// 📊 EXERCISE POPULARITY RANKING SYSTEM
// ========================================
// Export exercise popularity functions:
// - generatePopularityBundle: Scheduled daily (3am) - generates Data Bundle
// - onTemplateCreated: Firestore trigger - increments popularity on template save
var generatePopularityBundle_1 = require("./scheduled/generatePopularityBundle");
Object.defineProperty(exports, "generatePopularityBundle", { enumerable: true, get: function () { return generatePopularityBundle_1.generatePopularityBundle; } });
var onTemplateCreated_1 = require("./triggers/onTemplateCreated");
Object.defineProperty(exports, "onTemplateCreated", { enumerable: true, get: function () { return onTemplateCreated_1.onTemplateCreated; } });
// ========================================
// 🤖 AI Coach (Server-Side OpenRouter Proxy)
// ========================================
// Keeps OpenRouter key on backend and enforces App Check + rate limits.
var chatCompletion_1 = require("./ai_coach/chatCompletion");
Object.defineProperty(exports, "aiCoachChatCompletion", { enumerable: true, get: function () { return chatCompletion_1.aiCoachChatCompletion; } });
//# sourceMappingURL=index.js.map