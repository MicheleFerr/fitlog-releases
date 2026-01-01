"use strict";
/**
 * GDPR Data Retention Cloud Functions
 *
 * Implements automatic data retention as per privacy policy:
 * - 24-month inactivity = automatic deletion
 * - Warning email at 23 months
 * - Hard delete progress photos 30 days after soft delete
 *
 * GDPR References:
 * - Article 5(1)(e): Storage limitation
 * - Article 17: Right to erasure
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
exports.gdprHardDeletePhotos = exports.gdprCheckInactiveUsers = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const scheduler_1 = require("firebase-functions/v2/scheduler");
const db = admin.firestore();
const storage = admin.storage();
const auth = admin.auth();
// Retention periods (in days)
const INACTIVITY_WARNING_DAYS = 23 * 30; // ~23 months
const INACTIVITY_DELETION_DAYS = 24 * 30; // 24 months
const PHOTO_HARD_DELETE_DAYS = 30; // 30 days after soft delete
/**
 * Monthly check for inactive users (GDPR Art. 5(1)(e) Storage Limitation)
 *
 * Runs on the 1st of every month at 3:00 AM UTC
 *
 * Actions:
 * 1. Users inactive for 23 months: Send warning email
 * 2. Users inactive for 24 months: Delete all data
 */
exports.gdprCheckInactiveUsers = (0, scheduler_1.onSchedule)({
    schedule: '0 3 1 * *',
    timeZone: 'UTC',
}, async () => {
    var _a, _b;
    functions.logger.info('🔐 GDPR: Starting monthly inactive user check');
    const now = admin.firestore.Timestamp.now();
    const warningCutoff = new Date(now.toDate());
    warningCutoff.setDate(warningCutoff.getDate() - INACTIVITY_WARNING_DAYS);
    const deletionCutoff = new Date(now.toDate());
    deletionCutoff.setDate(deletionCutoff.getDate() - INACTIVITY_DELETION_DAYS);
    let warningsSent = 0;
    let accountsDeleted = 0;
    let errors = [];
    try {
        // Get all users
        const usersSnapshot = await db.collection('users').get();
        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;
            const userData = userDoc.data();
            const lastActivity = ((_a = userData.lastActivityAt) === null || _a === void 0 ? void 0 : _a.toDate()) || ((_b = userData.createdAt) === null || _b === void 0 ? void 0 : _b.toDate());
            if (!lastActivity) {
                console.log(`⚠️ User ${userId} has no activity timestamp, skipping`);
                continue;
            }
            try {
                // Check for deletion (24 months inactive)
                if (lastActivity < deletionCutoff) {
                    // Check if already warned
                    const alreadyWarned = userData.gdprWarningEmailSent;
                    if (!alreadyWarned) {
                        // Send warning first, delete next month
                        await sendRetentionWarningEmail(userId, userData.email);
                        await db.collection('users').doc(userId).update({
                            gdprWarningEmailSent: admin.firestore.Timestamp.now(),
                        });
                        warningsSent++;
                        console.log(`📧 Warning email sent to ${userId}`);
                    }
                    else {
                        // Already warned, proceed with deletion
                        await deleteUserData(userId);
                        accountsDeleted++;
                        console.log(`🗑️ Deleted user ${userId} (24+ months inactive)`);
                    }
                }
                // Check for warning (23 months inactive)
                else if (lastActivity < warningCutoff && !userData.gdprWarningEmailSent) {
                    await sendRetentionWarningEmail(userId, userData.email);
                    await db.collection('users').doc(userId).update({
                        gdprWarningEmailSent: admin.firestore.Timestamp.now(),
                    });
                    warningsSent++;
                    console.log(`📧 Warning email sent to ${userId}`);
                }
            }
            catch (error) {
                const errorMsg = `Error processing user ${userId}: ${error}`;
                console.error(errorMsg);
                errors.push(errorMsg);
            }
        }
        console.log(`✅ GDPR retention check complete:`);
        console.log(`   - Warnings sent: ${warningsSent}`);
        console.log(`   - Accounts deleted: ${accountsDeleted}`);
        console.log(`   - Errors: ${errors.length}`);
        // Log to audit collection
        await db.collection('gdpr_audit_log').add({
            type: 'retention_check',
            timestamp: admin.firestore.Timestamp.now(),
            warningsSent,
            accountsDeleted,
            errors: errors.length > 0 ? errors : null,
        });
    }
    catch (error) {
        console.error('❌ GDPR retention check failed:', error);
        throw error;
    }
});
/**
 * Daily cleanup of soft-deleted progress photos (GDPR Art. 17 Right to Erasure)
 *
 * Runs daily at 4:00 AM UTC
 *
 * Permanently deletes photos that have been soft-deleted for 30+ days
 */
exports.gdprHardDeletePhotos = (0, scheduler_1.onSchedule)({
    schedule: '0 4 * * *',
    timeZone: 'UTC',
}, async () => {
    var _a;
    functions.logger.info('🔐 GDPR: Starting progress photos hard delete');
    const now = admin.firestore.Timestamp.now();
    const cutoffDate = new Date(now.toDate());
    cutoffDate.setDate(cutoffDate.getDate() - PHOTO_HARD_DELETE_DAYS);
    const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);
    let photosDeleted = 0;
    let errors = [];
    try {
        // Find all soft-deleted photos older than 30 days
        const photosSnapshot = await db.collectionGroup('progress_photos')
            .where('deletedAt', '<=', cutoffTimestamp)
            .where('deletedAt', '!=', null)
            .get();
        for (const photoDoc of photosSnapshot.docs) {
            const photoData = photoDoc.data();
            const userId = (_a = photoDoc.ref.parent.parent) === null || _a === void 0 ? void 0 : _a.id;
            if (!userId) {
                console.warn(`⚠️ Could not determine userId for photo ${photoDoc.id}`);
                continue;
            }
            try {
                // Delete from Firebase Storage
                if (photoData.storagePath) {
                    const bucket = storage.bucket();
                    const file = bucket.file(photoData.storagePath);
                    try {
                        await file.delete();
                        console.log(`🗑️ Deleted storage file: ${photoData.storagePath}`);
                    }
                    catch (storageError) {
                        if (storageError.code !== 404) {
                            throw storageError;
                        }
                        // File already deleted, continue
                    }
                    // Also delete thumbnail if exists
                    if (photoData.thumbnailPath) {
                        const thumbFile = bucket.file(photoData.thumbnailPath);
                        try {
                            await thumbFile.delete();
                        }
                        catch (e) {
                            // Ignore thumbnail deletion errors
                        }
                    }
                }
                // Delete Firestore document
                await photoDoc.ref.delete();
                photosDeleted++;
            }
            catch (error) {
                const errorMsg = `Error deleting photo ${photoDoc.id}: ${error}`;
                console.error(errorMsg);
                errors.push(errorMsg);
            }
        }
        console.log(`✅ Progress photos cleanup complete:`);
        console.log(`   - Photos hard-deleted: ${photosDeleted}`);
        console.log(`   - Errors: ${errors.length}`);
        // Log to audit collection
        if (photosDeleted > 0 || errors.length > 0) {
            await db.collection('gdpr_audit_log').add({
                type: 'photo_hard_delete',
                timestamp: admin.firestore.Timestamp.now(),
                photosDeleted,
                errors: errors.length > 0 ? errors : null,
            });
        }
    }
    catch (error) {
        console.error('❌ Progress photos cleanup failed:', error);
        throw error;
    }
});
/**
 * Send retention warning email
 *
 * Notifies user their account will be deleted due to inactivity
 */
async function sendRetentionWarningEmail(userId, email) {
    if (!email) {
        console.warn(`⚠️ No email for user ${userId}, cannot send warning`);
        return;
    }
    // In production, integrate with email service (SendGrid, Mailgun, etc.)
    // For now, log to a collection that can be processed by external service
    await db.collection('email_queue').add({
        to: email,
        template: 'gdpr_retention_warning',
        data: {
            userId,
            daysUntilDeletion: 30,
            loginUrl: 'https://fitlogpro.app/login',
        },
        status: 'pending',
        createdAt: admin.firestore.Timestamp.now(),
    });
    console.log(`📧 Queued retention warning email for ${email}`);
}
/**
 * Delete all user data (GDPR Art. 17 implementation)
 *
 * Completely removes:
 * - Firestore documents (all subcollections)
 * - Storage files (progress photos)
 * - Firebase Auth account
 */
async function deleteUserData(userId) {
    console.log(`🗑️ Starting complete data deletion for user ${userId}`);
    // 1. Delete all subcollections
    const subcollections = [
        'workouts',
        'templates',
        'progress_photos',
        'body_measurements',
        'personal_records',
        'consents',
        'stress_index',
    ];
    for (const subcollection of subcollections) {
        const docs = await db.collection(`users/${userId}/${subcollection}`).get();
        const batch = db.batch();
        docs.forEach((doc) => {
            batch.delete(doc.ref);
        });
        if (!docs.empty) {
            await batch.commit();
            console.log(`  ✓ Deleted ${docs.size} docs from ${subcollection}`);
        }
    }
    // 2. Delete Storage files
    const bucket = storage.bucket();
    const [files] = await bucket.getFiles({ prefix: `users/${userId}/` });
    for (const file of files) {
        await file.delete();
    }
    console.log(`  ✓ Deleted ${files.length} storage files`);
    // 3. Delete user document
    await db.collection('users').doc(userId).delete();
    console.log(`  ✓ Deleted user document`);
    // 4. Delete Firebase Auth account
    try {
        await auth.deleteUser(userId);
        console.log(`  ✓ Deleted Firebase Auth account`);
    }
    catch (authError) {
        if (authError.code !== 'auth/user-not-found') {
            throw authError;
        }
        console.log(`  ⚠️ Auth account not found (already deleted)`);
    }
    // 5. Log to audit
    await db.collection('gdpr_audit_log').add({
        type: 'user_deletion',
        userId,
        timestamp: admin.firestore.Timestamp.now(),
        reason: 'inactivity_retention',
        subcollectionsDeleted: subcollections,
        storageFilesDeleted: files.length,
    });
    console.log(`✅ Complete data deletion finished for user ${userId}`);
}
//# sourceMappingURL=dataRetention.js.map