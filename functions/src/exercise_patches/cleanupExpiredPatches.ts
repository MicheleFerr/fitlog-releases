/**
 * GymBro Cloud Functions - Exercise Patches
 * Cleanup expired patches (30-day TTL)
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Cloud Function: Cleanup expired patches
 *
 * **Trigger**: Scheduled (runs daily at 02:00 UTC)
 * **Target**: Patches with status='pending' AND expiresAt < now
 *
 * **Workflow**:
 * 1. Query pending patches with expiresAt < now
 * 2. Update status to 'expired'
 * 3. Set autoExpired flag to true
 * 4. Log count of expired patches
 *
 * **Performance**:
 * - Batch updates (max 500 per run to avoid quota issues)
 * - Index required: collection(exercise_patches) where status=='pending' order by expiresAt
 *
 * **Audit Trail**:
 * - Soft delete only (status change, no document deletion)
 * - Preserves patch history for analytics
 */
export const cleanupExpiredPatches = functions.pubsub
  .schedule('0 2 * * *') // Daily at 02:00 UTC
  .timeZone('UTC')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const batch = admin.firestore().batch();
    let expiredCount = 0;

    console.log('Starting expired patches cleanup', { timestamp: now.toDate() });

    try {
      // Query pending patches that have expired
      const expiredPatches = await admin.firestore()
        .collection('exercise_patches')
        .where('status', '==', 'pending')
        .where('expiresAt', '<', now)
        .limit(500) // Batch limit to avoid quota issues
        .get();

      if (expiredPatches.empty) {
        console.log('No expired patches found');
        return { success: true, expiredCount: 0 };
      }

      console.log(`Found ${expiredPatches.size} expired patches`);

      // Update each expired patch
      expiredPatches.forEach((doc) => {
        const patchRef = doc.ref;
        const patchData = doc.data();

        batch.update(patchRef, {
          status: 'expired',
          autoExpired: true,
          expiredAt: now,
        });

        expiredCount++;

        console.log(`Expiring patch ${doc.id}`, {
          exerciseId: patchData.exerciseId,
          fieldName: patchData.fieldName,
          createdAt: patchData.createdAt?.toDate(),
          expiresAt: patchData.expiresAt?.toDate(),
        });
      });

      // Commit batch update
      await batch.commit();

      console.log(`Successfully expired ${expiredCount} patches`);

      return {
        success: true,
        expiredCount,
        timestamp: now.toDate(),
      };
    } catch (error) {
      console.error('Failed to cleanup expired patches', {
        error: error instanceof Error ? error.message : String(error),
        expiredCount,
      });

      return {
        success: false,
        error: error instanceof Error ? error.message : String(error),
        expiredCount,
      };
    }
  });

/**
 * Manual trigger for cleanup (HTTP endpoint for admin tools)
 *
 * **Usage**: POST /cleanupExpiredPatchesManual
 * **Auth**: Requires admin token
 */
export const cleanupExpiredPatchesManual = functions.https.onRequest(async (req, res) => {
  // Verify admin auth (simplified - enhance with proper admin verification)
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  // In production, verify the token is from an admin user
  // const token = authHeader.split('Bearer ')[1];
  // const decodedToken = await admin.auth().verifyIdToken(token);
  // if (!decodedToken.admin) { ... }

  const now = admin.firestore().Timestamp.now();
  const batch = admin.firestore().batch();
  let expiredCount = 0;

  try {
    const expiredPatches = await admin.firestore()
      .collection('exercise_patches')
      .where('status', '==', 'pending')
      .where('expiresAt', '<', now)
      .limit(500)
      .get();

    if (expiredPatches.empty) {
      res.json({ success: true, expiredCount: 0, message: 'No expired patches found' });
      return;
    }

    expiredPatches.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'expired',
        autoExpired: true,
        expiredAt: now,
      });
      expiredCount++;
    });

    await batch.commit();

    res.json({
      success: true,
      expiredCount,
      message: `Successfully expired ${expiredCount} patches`,
      timestamp: now.toDate(),
    });
  } catch (error) {
    console.error('Manual cleanup failed', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : String(error),
    });
  }
});
