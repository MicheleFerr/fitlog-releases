"use strict";
/**
 * 🔐 SECURITY: Document-Level Rate Limiting (Firestore Triggers)
 *
 * Enforces rate limits on document creation via Firestore triggers.
 * This provides server-side enforcement that cannot be bypassed by clients.
 *
 * Rate Limits:
 * - Body measurements: Max 100/day per user
 * - Consent changes: Max 10/day per user
 *
 * **Why Firestore Triggers?**
 * - Security Rules CANNOT count documents efficiently
 * - Triggers run AFTER document creation, then delete if limit exceeded
 * - Provides audit logging for security monitoring
 *
 * Implemented: 2025-12-27 (Security Audit)
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
exports.enforceConsentRateLimit = exports.enforceMeasurementRateLimit = void 0;
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
const db = admin.firestore();
const DOCUMENT_RATE_LIMITS = {
    measurements: {
        maxPerDay: 100,
        collection: 'body_measurements',
        timestampField: 'createdAt',
        errorMessage: 'Max 100 measurements per day',
    },
    consent: {
        maxPerDay: 10,
        collection: 'consent_history',
        timestampField: 'createdAt',
        errorMessage: 'Max 10 consent changes per day',
    },
};
// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
/**
 * Get start of today (UTC) as Firestore Timestamp
 */
function getStartOfDayUTC() {
    const now = new Date();
    const startOfDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0, 0));
    return admin.firestore.Timestamp.fromDate(startOfDay);
}
/**
 * Count documents created today for a user
 */
async function countTodayDocuments(userId, collection, timestampField) {
    const startOfDay = getStartOfDayUTC();
    const snapshot = await db
        .collection('users')
        .doc(userId)
        .collection(collection)
        .where(timestampField, '>=', startOfDay)
        .count()
        .get();
    return snapshot.data().count;
}
/**
 * Log rate limit violation to security audit log
 */
async function logRateLimitViolation(userId, limitType, count, documentPath) {
    var _a;
    await db.collection('security_audit_log').add({
        type: 'RATE_LIMIT_EXCEEDED',
        userId,
        limitType,
        count,
        limit: (_a = DOCUMENT_RATE_LIMITS[limitType]) === null || _a === void 0 ? void 0 : _a.maxPerDay,
        documentPath,
        action: 'DOCUMENT_DELETED',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        severity: 'WARNING',
    });
    firebase_functions_1.logger.warn('⚠️ Rate limit exceeded - document deleted', {
        userId: userId.substring(0, 8) + '...',
        limitType,
        count,
        documentPath,
    });
}
// ============================================================================
// FIRESTORE TRIGGERS
// ============================================================================
/**
 * Enforce rate limit on body measurements (Max 100/day)
 *
 * Triggers when a new body measurement is created.
 * Deletes the document if user has exceeded daily limit.
 */
exports.enforceMeasurementRateLimit = (0, firestore_1.onDocumentCreated)('users/{userId}/body_measurements/{measurementId}', async (event) => {
    var _a;
    const { userId, measurementId } = event.params;
    const config = DOCUMENT_RATE_LIMITS.measurements;
    try {
        const count = await countTodayDocuments(userId, config.collection, config.timestampField);
        // Note: count includes the just-created document
        if (count > config.maxPerDay) {
            // Delete the document
            await ((_a = event.data) === null || _a === void 0 ? void 0 : _a.ref.delete());
            // Log violation
            await logRateLimitViolation(userId, 'measurements', count, `users/${userId}/body_measurements/${measurementId}`);
            firebase_functions_1.logger.info(`🚫 Measurement deleted: Rate limit exceeded (${count}/${config.maxPerDay})`);
            return;
        }
        firebase_functions_1.logger.debug(`✅ Measurement allowed: ${count}/${config.maxPerDay}`);
    }
    catch (error) {
        // Fail-open: Don't block on errors
        firebase_functions_1.logger.error('❌ Error checking measurement rate limit', { error });
    }
});
/**
 * Enforce rate limit on consent changes (Max 10/day)
 *
 * Prevents consent toggle abuse (potential GDPR gaming).
 */
exports.enforceConsentRateLimit = (0, firestore_1.onDocumentCreated)('users/{userId}/consent_history/{consentId}', async (event) => {
    var _a;
    const { userId, consentId } = event.params;
    const config = DOCUMENT_RATE_LIMITS.consent;
    try {
        const count = await countTodayDocuments(userId, config.collection, config.timestampField);
        if (count > config.maxPerDay) {
            await ((_a = event.data) === null || _a === void 0 ? void 0 : _a.ref.delete());
            await logRateLimitViolation(userId, 'consent', count, `users/${userId}/consent_history/${consentId}`);
            firebase_functions_1.logger.info(`🚫 Consent change deleted: Rate limit exceeded (${count}/${config.maxPerDay})`);
            return;
        }
        firebase_functions_1.logger.debug(`✅ Consent change allowed: ${count}/${config.maxPerDay}`);
    }
    catch (error) {
        firebase_functions_1.logger.error('❌ Error checking consent rate limit', { error });
    }
});
//# sourceMappingURL=documentRateLimiter.js.map