"use strict";
/**
 * GDPR Admin Access Audit Log
 *
 * Logs all admin access to user data for accountability (GDPR Art. 5(2))
 *
 * This provides:
 * - Audit trail for data access
 * - Accountability for admin actions
 * - Evidence for data protection authorities
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
exports.gdprCleanupAuditLogs = exports.gdprGetAuditLog = exports.gdprAuditUserData = exports.gdprLogAdminAccess = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_1 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
const db = admin.firestore();
/**
 * Log admin access to user data
 *
 * Callable function for admin panel to log access
 *
 * @param action - Type of action (view, export, modify, delete)
 * @param targetUserId - User ID being accessed
 * @param details - Additional details about the access
 */
exports.gdprLogAdminAccess = (0, https_1.onCall)(async (request) => {
    var _a, _b;
    const data = request.data;
    // Verify admin authentication
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be authenticated to log admin access');
    }
    // Verify admin role
    const isAdmin = request.auth.token.admin === true;
    if (!isAdmin) {
        throw new https_1.HttpsError('permission-denied', 'Must be admin to log admin access');
    }
    const entry = {
        adminUid: request.auth.uid,
        adminEmail: request.auth.token.email || 'unknown',
        action: data.action,
        targetUserId: data.targetUserId,
        targetCollection: data.targetCollection,
        details: data.details,
        ipAddress: (_a = request.rawRequest) === null || _a === void 0 ? void 0 : _a.ip,
        userAgent: (_b = request.rawRequest) === null || _b === void 0 ? void 0 : _b.headers['user-agent'],
        timestamp: admin.firestore.Timestamp.now(),
    };
    try {
        await db.collection('admin_audit_log').add(entry);
        functions.logger.info(`📋 [AUDIT] Admin ${entry.adminEmail} performed ${data.action}`);
        if (data.targetUserId) {
            functions.logger.info(`   Target user: ${data.targetUserId}`);
        }
        return { success: true };
    }
    catch (error) {
        functions.logger.error('❌ [AUDIT] Error logging admin access:', error);
        throw new https_1.HttpsError('internal', 'Failed to log admin access');
    }
});
/**
 * Firestore trigger to auto-log admin reads of user documents
 *
 * This is a more aggressive audit that logs ALL access to sensitive collections
 */
exports.gdprAuditUserData = (0, firestore_1.onDocumentWritten)('users/{userId}', async (event) => {
    // Only log if document was read (not created or deleted)
    // Note: Firestore triggers don't fire on reads, only writes
    // This logs modifications instead
    var _a, _b;
    const userId = event.params.userId;
    const before = ((_a = event.data) === null || _a === void 0 ? void 0 : _a.before.exists) ? event.data.before.data() : null;
    const after = ((_b = event.data) === null || _b === void 0 ? void 0 : _b.after.exists) ? event.data.after.data() : null;
    // Determine action type
    let action = 'unknown';
    if (!before && after) {
        action = 'create';
    }
    else if (before && !after) {
        action = 'delete';
    }
    else if (before && after) {
        action = 'update';
    }
    // Get the user who made the change (if available from security rules context)
    // Note: In Cloud Functions, we don't have direct access to who triggered the write
    // This would need to be passed via the app or logged separately
    try {
        await db.collection('gdpr_audit_log').add({
            type: 'user_document_change',
            userId,
            action,
            timestamp: admin.firestore.Timestamp.now(),
            // Fields changed (for update)
            changedFields: before && after
                ? Object.keys(after).filter((key) => JSON.stringify(before[key]) !== JSON.stringify(after[key]))
                : null,
        });
    }
    catch (error) {
        functions.logger.error('❌ [AUDIT] Error logging user data change:', error);
        // Don't throw - audit logging should not block the operation
    }
});
/**
 * Get audit log entries for a specific user
 *
 * For GDPR Art. 15 (Right of Access) - users can request info about who accessed their data
 */
exports.gdprGetAuditLog = (0, https_1.onCall)(async (request) => {
    const data = request.data;
    // Verify authentication
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be authenticated');
    }
    // User can only access their own audit log, or admin can access any
    const isAdmin = request.auth.token.admin === true;
    const isOwnData = request.auth.uid === data.userId;
    if (!isAdmin && !isOwnData) {
        throw new https_1.HttpsError('permission-denied', 'Cannot access other users\' audit log');
    }
    try {
        // Get admin access logs for this user
        const adminLogsSnapshot = await db
            .collection('admin_audit_log')
            .where('targetUserId', '==', data.userId)
            .orderBy('timestamp', 'desc')
            .limit(100)
            .get();
        // Get user document change logs
        const changeLogsSnapshot = await db
            .collection('gdpr_audit_log')
            .where('userId', '==', data.userId)
            .orderBy('timestamp', 'desc')
            .limit(100)
            .get();
        return {
            adminAccess: adminLogsSnapshot.docs.map((doc) => {
                var _a, _b;
                return (Object.assign(Object.assign({ id: doc.id }, doc.data()), { timestamp: (_b = (_a = doc.data().timestamp) === null || _a === void 0 ? void 0 : _a.toDate()) === null || _b === void 0 ? void 0 : _b.toISOString() }));
            }),
            dataChanges: changeLogsSnapshot.docs.map((doc) => {
                var _a, _b;
                return (Object.assign(Object.assign({ id: doc.id }, doc.data()), { timestamp: (_b = (_a = doc.data().timestamp) === null || _a === void 0 ? void 0 : _a.toDate()) === null || _b === void 0 ? void 0 : _b.toISOString() }));
            }),
        };
    }
    catch (error) {
        functions.logger.error('❌ [AUDIT] Error getting audit log:', error);
        throw new https_1.HttpsError('internal', 'Failed to get audit log');
    }
});
/**
 * Cleanup old audit logs (retain for 2 years as per GDPR best practice)
 *
 * Runs monthly on the 15th
 */
exports.gdprCleanupAuditLogs = (0, scheduler_1.onSchedule)({
    schedule: '0 2 15 * *', // 15th of every month at 2:00 AM UTC
    timeZone: 'UTC',
}, async () => {
    functions.logger.info('🧹 [AUDIT] Starting audit log cleanup (2-year retention)');
    const cutoffDate = new Date();
    cutoffDate.setFullYear(cutoffDate.getFullYear() - 2);
    const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);
    const collections = ['admin_audit_log', 'gdpr_audit_log'];
    let totalDeleted = 0;
    for (const collectionName of collections) {
        try {
            const oldLogsSnapshot = await db
                .collection(collectionName)
                .where('timestamp', '<', cutoffTimestamp)
                .limit(500) // Process in batches
                .get();
            if (oldLogsSnapshot.empty) {
                console.log(`  ✓ No old logs in ${collectionName}`);
                continue;
            }
            const batch = db.batch();
            oldLogsSnapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            totalDeleted += oldLogsSnapshot.size;
            console.log(`  ✓ Deleted ${oldLogsSnapshot.size} old logs from ${collectionName}`);
        }
        catch (error) {
            console.error(`  ❌ Error cleaning ${collectionName}:`, error);
        }
    }
    functions.logger.info(`✅ [AUDIT] Cleanup complete. Total deleted: ${totalDeleted}`);
});
//# sourceMappingURL=adminAuditLog.js.map