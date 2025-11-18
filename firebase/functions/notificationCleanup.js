/**
 * 🏋️‍♂️ GymBro TrackLog - Firebase Cloud Functions
 *
 * NOTIFICATION DATA CLEANUP FUNCTION (GDPR Article 5.1.e - Data Retention)
 *
 * Runs daily at 2:00 AM UTC to delete old notification history entries
 * based on each user's dataRetentionDays preference (30-365 days).
 *
 * Deploy: firebase deploy --only functions:notificationCleanup
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK (only once)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Scheduled function: Runs daily at 2:00 AM UTC
 *
 * Cloud Scheduler cron syntax: '0 2 * * *'
 * - Minute: 0
 * - Hour: 2 (UTC)
 * - Day of month: * (every day)
 * - Month: * (every month)
 * - Day of week: * (every day of week)
 */
exports.notificationCleanup = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    console.log('🧹 Starting notification cleanup job...');

    try {
      // Step 1: Get all users
      const usersSnapshot = await db.collection('users').get();

      let totalUsersProcessed = 0;
      let totalEntriesDeleted = 0;
      let totalErrors = 0;

      // Step 2: Process each user
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;

        try {
          // Step 3: Get user's notification settings (v2.0)
          const settingsDoc = await db
            .collection('users')
            .doc(userId)
            .collection('notificationSettings')
            .get();

          if (settingsDoc.empty) {
            console.log(`⏭️  User ${userId}: No settings found, skipping`);
            continue;
          }

          const settings = settingsDoc.docs[0].data();
          const retentionDays = settings.dataRetentionDays || 90; // Default 90 days

          // Step 4: Calculate cutoff date (GDPR Article 5.1.e)
          const cutoffDate = new Date();
          cutoffDate.setDate(cutoffDate.setDate(-retentionDays));
          const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);

          console.log(`👤 User ${userId}: Retention=${retentionDays} days, Cutoff=${cutoffDate.toISOString()}`);

          // Step 5: Query old notification history entries
          const oldEntriesSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('notificationHistory')
            .where('timestamp', '<', cutoffTimestamp)
            .get();

          if (oldEntriesSnapshot.empty) {
            console.log(`  ✅ User ${userId}: No old entries to delete`);
            totalUsersProcessed++;
            continue;
          }

          // Step 6: Batch delete old entries (Firestore batch limit: 500)
          const batchSize = 500;
          const batches = [];
          let currentBatch = db.batch();
          let batchCount = 0;

          oldEntriesSnapshot.docs.forEach((doc, index) => {
            currentBatch.delete(doc.ref);
            batchCount++;

            if ((index + 1) % batchSize === 0) {
              batches.push(currentBatch.commit());
              currentBatch = db.batch();
              batchCount = 0;
            }
          });

          // Commit remaining batch
          if (batchCount > 0) {
            batches.push(currentBatch.commit());
          }

          // Execute all batches
          await Promise.all(batches);

          const deletedCount = oldEntriesSnapshot.size;
          totalEntriesDeleted += deletedCount;
          totalUsersProcessed++;

          console.log(`  🗑️  User ${userId}: Deleted ${deletedCount} old entries`);

        } catch (userError) {
          console.error(`❌ Error processing user ${userId}:`, userError);
          totalErrors++;
        }
      }

      // Step 7: Log summary
      console.log('✅ Notification cleanup job completed!');
      console.log(`📊 Summary:`);
      console.log(`   - Users processed: ${totalUsersProcessed}`);
      console.log(`   - Entries deleted: ${totalEntriesDeleted}`);
      console.log(`   - Errors: ${totalErrors}`);

      return {
        success: true,
        usersProcessed: totalUsersProcessed,
        entriesDeleted: totalEntriesDeleted,
        errors: totalErrors,
      };

    } catch (error) {
      console.error('❌ Fatal error in notification cleanup job:', error);
      throw error; // Cloud Scheduler will retry
    }
  });

/**
 * Manual trigger for testing cleanup logic
 *
 * Test with:
 * curl -X POST https://us-central1-{project-id}.cloudfunctions.net/testNotificationCleanup \
 *   -H "Content-Type: application/json" \
 *   -d '{"userId": "test-user-id"}'
 */
exports.testNotificationCleanup = functions.https.onRequest(async (req, res) => {
  console.log('🧪 Manual cleanup test triggered');

  try {
    const userId = req.body.userId || req.query.userId;

    if (!userId) {
      res.status(400).send({ error: 'userId parameter required' });
      return;
    }

    // Get user's settings
    const settingsDoc = await db
      .collection('users')
      .doc(userId)
      .collection('notificationSettings')
      .get();

    if (settingsDoc.empty) {
      res.status(404).send({ error: 'User settings not found' });
      return;
    }

    const settings = settingsDoc.docs[0].data();
    const retentionDays = settings.dataRetentionDays || 90;

    // Calculate cutoff date
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);
    const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);

    // Query old entries
    const oldEntriesSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('notificationHistory')
      .where('timestamp', '<', cutoffTimestamp)
      .get();

    console.log(`Found ${oldEntriesSnapshot.size} old entries for user ${userId}`);

    res.status(200).send({
      success: true,
      userId,
      retentionDays,
      cutoffDate: cutoffDate.toISOString(),
      oldEntriesCount: oldEntriesSnapshot.size,
      message: 'Test completed (no data deleted)',
    });

  } catch (error) {
    console.error('Error in test cleanup:', error);
    res.status(500).send({ error: error.message });
  }
});

/**
 * HTTP-triggered cleanup for specific user (GDPR Article 17: Right to Erasure)
 *
 * Immediately deletes ALL notification data for a user when they revoke consent.
 *
 * Triggered by: DeleteAllNotificationData use case
 */
exports.deleteUserNotificationData = functions.https.onCall(async (data, context) => {
  console.log('🗑️  GDPR deletion request triggered');

  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to delete data'
    );
  }

  const userId = context.auth.uid;

  try {
    // Step 1: Delete notification settings
    const settingsSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('notificationSettings')
      .get();

    const batch1 = db.batch();
    settingsSnapshot.docs.forEach(doc => {
      batch1.delete(doc.ref);
    });
    await batch1.commit();

    // Step 2: Delete notification history (all entries, regardless of age)
    const historySnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('notificationHistory')
      .get();

    // Batch delete history (500 per batch)
    const batchSize = 500;
    const batches = [];
    let currentBatch = db.batch();
    let count = 0;

    historySnapshot.docs.forEach((doc, index) => {
      currentBatch.delete(doc.ref);
      count++;

      if ((index + 1) % batchSize === 0) {
        batches.push(currentBatch.commit());
        currentBatch = db.batch();
        count = 0;
      }
    });

    if (count > 0) {
      batches.push(currentBatch.commit());
    }

    await Promise.all(batches);

    console.log(`✅ GDPR deletion complete for user ${userId}`);
    console.log(`   - Settings deleted: ${settingsSnapshot.size}`);
    console.log(`   - History deleted: ${historySnapshot.size}`);

    return {
      success: true,
      settingsDeleted: settingsSnapshot.size,
      historyDeleted: historySnapshot.size,
      message: 'All notification data deleted successfully',
    };

  } catch (error) {
    console.error(`❌ Error deleting data for user ${userId}:`, error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
