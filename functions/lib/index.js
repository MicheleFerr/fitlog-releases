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
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTemplateQuota = exports.createTemplate = exports.cleanupExpiredRateLimits = exports.rejectContribution = exports.approveContribution = exports.checkExpiredSubscriptions = exports.verifyPremiumPurchase = exports.checkAdminStatus = exports.setInitialAdmin = exports.revokeAdminRole = exports.setAdminRole = void 0;
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
var rateLimiter_1 = require("./security/rateLimiter");
Object.defineProperty(exports, "cleanupExpiredRateLimits", { enumerable: true, get: function () { return rateLimiter_1.cleanupExpiredRateLimits; } });
// ========================================
// 📝 TEMPLATE QUOTA MANAGEMENT (Server-Side Enforcement)
// ========================================
// Export template creation with quota enforcement
// SECURITY: This is the ONLY secure way to enforce template limits
// Client-side validation is NOT sufficient for security
var createTemplate_1 = require("./templates/createTemplate");
Object.defineProperty(exports, "createTemplate", { enumerable: true, get: function () { return createTemplate_1.createTemplate; } });
Object.defineProperty(exports, "getTemplateQuota", { enumerable: true, get: function () { return createTemplate_1.getTemplateQuota; } });
//# sourceMappingURL=index.js.map