import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface ComplianceMetadata {
  [key: string]: unknown;
}

interface ExportedNotificationData {
  notifications: Array<Record<string, unknown>>;
  preferences: Record<string, unknown> | null;
  subscriptions: Record<string, unknown> | null;
  analytics: Array<Record<string, unknown>>;
  queueItems: Array<Record<string, unknown>>;
  exportedAt: string;
}

interface DeletedNotificationData {
  notifications: number;
  analytics: number;
  queueItems: number;
  preferencesDeleted: boolean;
  subscriptionsDeleted: boolean;
}

export class NotificationPrivacy {
  private static readonly USER_NOTIFICATIONS = 'user_notifications';
  private static readonly NOTIFICATION_PREFERENCES = 'notification_preferences';
  private static readonly NOTIFICATION_SUBSCRIPTIONS = 'notification_subscriptions';
  private static readonly ANALYTICS_COLLECTION = 'notification_analytics';
  private static readonly QUEUE_COLLECTION = 'notifications_queue';
  private static readonly COMPLIANCE_LOGS = 'notification_compliance_logs';

  static async exportUserData(userId: string): Promise<ExportedNotificationData> {
    const db = admin.firestore();

    const [notificationsSnapshot, preferencesDoc, subscriptionsDoc, analyticsSnapshot, queueSnapshot] =
      await Promise.all([
        db
          .collection(this.USER_NOTIFICATIONS)
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', 'desc')
          .limit(1000)
          .get(),
        db.collection(this.NOTIFICATION_PREFERENCES).doc(userId).get(),
        db.collection(this.NOTIFICATION_SUBSCRIPTIONS).doc(userId).get(),
        db
          .collection(this.ANALYTICS_COLLECTION)
          .where('userId', '==', userId)
          .limit(1000)
          .get(),
        db.collection(this.QUEUE_COLLECTION).where('userId', '==', userId).limit(500).get(),
      ]);

    return {
      notifications: notificationsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
      preferences: preferencesDoc.exists ? (preferencesDoc.data() as Record<string, unknown>) : null,
      subscriptions: subscriptionsDoc.exists
        ? (subscriptionsDoc.data() as Record<string, unknown>)
        : null,
      analytics: analyticsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
      queueItems: queueSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
      exportedAt: new Date().toISOString(),
    };
  }

  static async deleteUserData(userId: string): Promise<DeletedNotificationData> {
    const db = admin.firestore();

    const [notificationsDeleted, analyticsDeleted, queueItemsDeleted] =
      await Promise.all([
        this.deleteSubcollection(
          db.collection(this.USER_NOTIFICATIONS).doc(userId).collection('notifications')
        ),
        this.deleteQuery(
          db.collection(this.ANALYTICS_COLLECTION).where('userId', '==', userId)
        ),
        this.deleteQuery(
          db.collection(this.QUEUE_COLLECTION).where('userId', '==', userId)
        ),
      ]);

    const [preferencesResult, subscriptionsResult] = await Promise.allSettled([
      db.collection(this.NOTIFICATION_PREFERENCES).doc(userId).delete(),
      db.collection(this.NOTIFICATION_SUBSCRIPTIONS).doc(userId).delete(),
    ]);

    return {
      notifications: notificationsDeleted,
      analytics: analyticsDeleted,
      queueItems: queueItemsDeleted,
      preferencesDeleted: preferencesResult.status === 'fulfilled',
      subscriptionsDeleted: subscriptionsResult.status === 'fulfilled',
    };
  }

  static async logComplianceAction(
    userId: string,
    action: string,
    metadata: ComplianceMetadata
  ): Promise<void> {
    try {
      await admin.firestore().collection(this.COMPLIANCE_LOGS).add({
        userId,
        action,
        metadata,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      functions.logger.error('Failed to log compliance action', {
        userId,
        action,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  private static async deleteSubcollection(
    collection: admin.firestore.CollectionReference
  ): Promise<number> {
    const snapshot = await collection.limit(1000).get();
    if (snapshot.empty) return 0;

    const batch = admin.firestore().batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    return snapshot.size;
  }

  private static async deleteQuery(
    query: admin.firestore.Query
  ): Promise<number> {
    const snapshot = await query.get();
    if (snapshot.empty) return 0;

    const batch = admin.firestore().batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    return snapshot.size;
  }
}
