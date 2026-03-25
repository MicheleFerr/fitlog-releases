"use strict";
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
exports.NotificationPrivacy = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
class NotificationPrivacy {
    static async exportUserData(userId) {
        const db = admin.firestore();
        const [notificationsSnapshot, preferencesDoc, subscriptionsDoc, analyticsSnapshot, queueSnapshot] = await Promise.all([
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
            notifications: notificationsSnapshot.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data()))),
            preferences: preferencesDoc.exists ? preferencesDoc.data() : null,
            subscriptions: subscriptionsDoc.exists
                ? subscriptionsDoc.data()
                : null,
            analytics: analyticsSnapshot.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data()))),
            queueItems: queueSnapshot.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data()))),
            exportedAt: new Date().toISOString(),
        };
    }
    static async deleteUserData(userId) {
        const db = admin.firestore();
        const [notificationsDeleted, analyticsDeleted, queueItemsDeleted] = await Promise.all([
            this.deleteSubcollection(db.collection(this.USER_NOTIFICATIONS).doc(userId).collection('notifications')),
            this.deleteQuery(db.collection(this.ANALYTICS_COLLECTION).where('userId', '==', userId)),
            this.deleteQuery(db.collection(this.QUEUE_COLLECTION).where('userId', '==', userId)),
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
    static async logComplianceAction(userId, action, metadata) {
        try {
            await admin.firestore().collection(this.COMPLIANCE_LOGS).add({
                userId,
                action,
                metadata,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        catch (error) {
            functions.logger.error('Failed to log compliance action', {
                userId,
                action,
                error: error instanceof Error ? error.message : String(error),
            });
        }
    }
    static async deleteSubcollection(collection) {
        const snapshot = await collection.limit(1000).get();
        if (snapshot.empty)
            return 0;
        const batch = admin.firestore().batch();
        for (const doc of snapshot.docs) {
            batch.delete(doc.ref);
        }
        await batch.commit();
        return snapshot.size;
    }
    static async deleteQuery(query) {
        const snapshot = await query.get();
        if (snapshot.empty)
            return 0;
        const batch = admin.firestore().batch();
        for (const doc of snapshot.docs) {
            batch.delete(doc.ref);
        }
        await batch.commit();
        return snapshot.size;
    }
}
exports.NotificationPrivacy = NotificationPrivacy;
NotificationPrivacy.USER_NOTIFICATIONS = 'user_notifications';
NotificationPrivacy.NOTIFICATION_PREFERENCES = 'notification_preferences';
NotificationPrivacy.NOTIFICATION_SUBSCRIPTIONS = 'notification_subscriptions';
NotificationPrivacy.ANALYTICS_COLLECTION = 'notification_analytics';
NotificationPrivacy.QUEUE_COLLECTION = 'notifications_queue';
NotificationPrivacy.COMPLIANCE_LOGS = 'notification_compliance_logs';
//# sourceMappingURL=NotificationPrivacy.js.map