"use strict";
/**
 * 🔐 SECURITY: Community Contributions Moderation (Server-Side Validation)
 *
 * This Cloud Function enforces admin-only access to contribution moderation
 * using Firebase Custom Claims (server-side only, cannot be forged by client).
 *
 * **Security Benefits**:
 * - Admin status checked server-side via custom claims
 * - Cannot be bypassed by client-side tampering
 * - Audit logging for all moderation actions
 * - Prevents unauthorized contribution approval/rejection
 *
 * **Migration from Client-Side**:
 * - BEFORE: Client repository directly updated Firestore (insecure)
 * - AFTER: Client calls Cloud Function → validates admin → updates Firestore
 *
 * @see lib/features/community/data/repositories/community_repository.dart (old impl)
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
exports.rejectContribution = exports.approveContribution = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
/**
 * Check if a user is admin via custom claims
 */
async function isAdmin(uid) {
    var _a;
    try {
        const user = await admin.auth().getUser(uid);
        return ((_a = user.customClaims) === null || _a === void 0 ? void 0 : _a.admin) === true;
    }
    catch (error) {
        console.error('Error checking admin status:', error);
        return false;
    }
}
/**
 * Update user contribution stats and award XP
 */
async function updateUserStats(userId, status) {
    const userRef = admin.firestore().collection('users').doc(userId);
    if (status === 'approved') {
        // Award 50 XP for approved contribution
        await userRef.update({
            totalContributions: admin.firestore.FieldValue.increment(1),
            approvedContributions: admin.firestore.FieldValue.increment(1),
            xp: admin.firestore.FieldValue.increment(50),
            lastContributionAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    else {
        // No XP for rejected contributions, just increment count
        await userRef.update({
            totalContributions: admin.firestore.FieldValue.increment(1),
            rejectedContributions: admin.firestore.FieldValue.increment(1),
            lastContributionAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
}
/**
 * 🔐 Cloud Function: Approve Community Contribution (Callable)
 *
 * Allows admins to approve community contributions with server-side validation.
 *
 * **Security**:
 * - Requires caller to be authenticated
 * - Requires caller to have admin custom claim (server-validated)
 * - Logs all operations for audit trail
 * - Awards XP to contributor
 *
 * **Request**:
 * ```typescript
 * {
 *   contributionId: string;  // ID of contribution to approve
 * }
 * ```
 *
 * **Response**:
 * ```typescript
 * {
 *   success: boolean;
 *   message: string;
 *   contributionId: string;
 *   contributorUserId?: string;  // User who made the contribution
 * }
 * ```
 *
 * **Example Usage** (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('approveContribution')
 *   .call({'contributionId': 'contribution-123'});
 *
 * if (result.data['success']) {
 *   print('Contribution approved: ${result.data['contributionId']}');
 * }
 * ```
 */
exports.approveContribution = (0, https_1.onCall)(async (request) => {
    // ========================================
    // 1. Authentication Check
    // ========================================
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to moderate contributions');
    }
    const adminUid = request.auth.uid;
    const adminEmail = request.auth.token.email;
    // ========================================
    // 2. Authorization Check (Admin Only)
    // ========================================
    const callerIsAdmin = await isAdmin(adminUid);
    if (!callerIsAdmin) {
        console.warn(`🚨 Unauthorized contribution approval attempt by ${adminEmail} (${adminUid})`);
        throw new https_1.HttpsError('permission-denied', 'Only admins can approve contributions');
    }
    // ========================================
    // 3. Validate Request Data
    // ========================================
    const { contributionId } = request.data;
    if (!contributionId || typeof contributionId !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'contributionId is required and must be a string');
    }
    // ========================================
    // 4. Get Contribution Document
    // ========================================
    const contributionRef = admin.firestore()
        .collection('community_contributions')
        .doc(contributionId);
    try {
        const snapshot = await contributionRef.get();
        if (!snapshot.exists) {
            throw new https_1.HttpsError('not-found', `Contribution ${contributionId} not found`);
        }
        const contributionData = snapshot.data();
        const contributorUserId = contributionData.userId;
        // Check if already approved
        if (contributionData.status === 'approved') {
            console.log(`ℹ️ Contribution ${contributionId} already approved`);
            return {
                success: true,
                message: 'Contribution already approved',
                contributionId,
                contributorUserId,
            };
        }
        // ========================================
        // 5. Approve Contribution (Transaction)
        // ========================================
        await admin.firestore().runTransaction(async (transaction) => {
            transaction.update(contributionRef, {
                status: 'approved',
                reviewedBy: adminUid,
                reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        });
        console.log(`✅ Contribution approved: ${contributionId} by ${adminEmail} (${adminUid})`);
        // ========================================
        // 6. Award XP to Contributor
        // ========================================
        await updateUserStats(contributorUserId, 'approved');
        // ========================================
        // 7. Log to Audit Trail
        // ========================================
        await admin.firestore().collection('moderation_audit_logs').add({
            action: 'approve_contribution',
            contributionId,
            contributorUserId,
            adminEmail,
            adminUid,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: 'success',
        });
        return {
            success: true,
            message: `Contribution approved and 50 XP awarded to contributor`,
            contributionId,
            contributorUserId,
        };
    }
    catch (error) {
        console.error('Error approving contribution:', error);
        // Log failure to audit trail
        await admin.firestore().collection('moderation_audit_logs').add({
            action: 'approve_contribution',
            contributionId,
            adminEmail,
            adminUid,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: 'error',
            error: String(error),
        });
        throw new https_1.HttpsError('internal', 'Failed to approve contribution. Check server logs.');
    }
});
/**
 * 🔐 Cloud Function: Reject Community Contribution (Callable)
 *
 * Allows admins to reject community contributions with server-side validation.
 *
 * **Security**:
 * - Requires caller to be authenticated
 * - Requires caller to have admin custom claim (server-validated)
 * - Logs all operations for audit trail
 * - No XP awarded for rejected contributions
 *
 * **Request**:
 * ```typescript
 * {
 *   contributionId: string;  // ID of contribution to reject
 *   reason: string;          // Reason for rejection (required)
 * }
 * ```
 *
 * **Response**:
 * ```typescript
 * {
 *   success: boolean;
 *   message: string;
 *   contributionId: string;
 *   contributorUserId?: string;
 * }
 * ```
 */
exports.rejectContribution = (0, https_1.onCall)(async (request) => {
    // ========================================
    // 1. Authentication Check
    // ========================================
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to moderate contributions');
    }
    const adminUid = request.auth.uid;
    const adminEmail = request.auth.token.email;
    // ========================================
    // 2. Authorization Check (Admin Only)
    // ========================================
    const callerIsAdmin = await isAdmin(adminUid);
    if (!callerIsAdmin) {
        console.warn(`🚨 Unauthorized contribution rejection attempt by ${adminEmail} (${adminUid})`);
        throw new https_1.HttpsError('permission-denied', 'Only admins can reject contributions');
    }
    // ========================================
    // 3. Validate Request Data
    // ========================================
    const { contributionId, reason } = request.data;
    if (!contributionId || typeof contributionId !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'contributionId is required and must be a string');
    }
    if (!reason || typeof reason !== 'string' || reason.trim().length === 0) {
        throw new https_1.HttpsError('invalid-argument', 'reason is required and must be a non-empty string');
    }
    // ========================================
    // 4. Get Contribution Document
    // ========================================
    const contributionRef = admin.firestore()
        .collection('community_contributions')
        .doc(contributionId);
    try {
        const snapshot = await contributionRef.get();
        if (!snapshot.exists) {
            throw new https_1.HttpsError('not-found', `Contribution ${contributionId} not found`);
        }
        const contributionData = snapshot.data();
        const contributorUserId = contributionData.userId;
        // ========================================
        // 5. Reject Contribution
        // ========================================
        await contributionRef.update({
            status: 'rejected',
            reviewedBy: adminUid,
            reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
            reviewNote: reason,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`✅ Contribution rejected: ${contributionId} by ${adminEmail} (${adminUid})`);
        console.log(`📝 Rejection reason: ${reason}`);
        // ========================================
        // 6. Update Contributor Stats (No XP)
        // ========================================
        await updateUserStats(contributorUserId, 'rejected');
        // ========================================
        // 7. Log to Audit Trail
        // ========================================
        await admin.firestore().collection('moderation_audit_logs').add({
            action: 'reject_contribution',
            contributionId,
            contributorUserId,
            adminEmail,
            adminUid,
            reason,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: 'success',
        });
        return {
            success: true,
            message: `Contribution rejected`,
            contributionId,
            contributorUserId,
        };
    }
    catch (error) {
        console.error('Error rejecting contribution:', error);
        // Log failure to audit trail
        await admin.firestore().collection('moderation_audit_logs').add({
            action: 'reject_contribution',
            contributionId,
            adminEmail,
            adminUid,
            reason,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: 'error',
            error: String(error),
        });
        throw new https_1.HttpsError('internal', 'Failed to reject contribution. Check server logs.');
    }
});
//# sourceMappingURL=moderateContributions.js.map