"use strict";
/**
 * NotificationQueue - Enterprise notification queuing system
 * Handles high-throughput notification processing with retry logic
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
exports.NotificationQueue = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const NotificationAnalytics_1 = require("../analytics/NotificationAnalytics");
class NotificationQueue {
    /**
     * Enqueue a notification for processing
     */
    static async enqueue(notification) {
        try {
            const db = admin.firestore();
            const queuedNotification = Object.assign(Object.assign({}, notification), { status: 'queued', attempts: 0, queuedAt: admin.firestore.FieldValue.serverTimestamp(), scheduleFor: notification.scheduleFor || new Date() });
            // Add to queue with automatic ID generation
            const docRef = await db.collection(this.COLLECTION).add(queuedNotification);
            functions.logger.info('Notification queued', {
                id: docRef.id,
                type: notification.type,
                userId: notification.userId,
                priority: notification.priority
            });
            return docRef.id;
        }
        catch (error) {
            functions.logger.error('Failed to enqueue notification', {
                error: error.message,
                notification: {
                    type: notification.type,
                    userId: notification.userId,
                    priority: notification.priority
                }
            });
            throw error;
        }
    }
    /**
     * Process a batch of queued notifications
     */
    static async processBatch(batchSize = 100) {
        var _a;
        try {
            const db = admin.firestore();
            const now = new Date();
            // Get queued notifications ready for processing
            const snapshot = await db.collection(this.COLLECTION)
                .where('status', '==', 'queued')
                .where('scheduleFor', '<=', admin.firestore.Timestamp.fromDate(now))
                .orderBy('scheduleFor', 'asc')
                .orderBy('priority', 'desc') // Process high priority first
                .limit(batchSize)
                .get();
            if (snapshot.empty) {
                return [];
            }
            const batch = db.batch();
            const processed = [];
            // Process each notification
            for (const doc of snapshot.docs) {
                const notification = Object.assign({ id: doc.id }, doc.data());
                try {
                    // Mark as processing
                    batch.update(doc.ref, {
                        status: 'processing',
                        processedAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                    // Process the notification
                    const result = await this.processNotification(notification);
                    processed.push(result);
                    // Update status based on result
                    if (result.status === 'sent') {
                        batch.update(doc.ref, {
                            status: 'sent',
                            fcmMessageId: (_a = result.fcmResponse) === null || _a === void 0 ? void 0 : _a.messageId
                        });
                    }
                    else if (result.status === 'skipped') {
                        batch.update(doc.ref, {
                            status: 'cancelled',
                            error: result.reason
                        });
                    }
                    else {
                        // Failed - handle retry logic
                        await this.handleFailedNotification(doc.ref, notification, result.error, batch);
                    }
                }
                catch (error) {
                    functions.logger.error('Error processing individual notification', {
                        notificationId: doc.id,
                        error: error.message
                    });
                    await this.handleFailedNotification(doc.ref, notification, error.message, batch);
                    processed.push({ status: 'failed', error: error.message });
                }
            }
            // Commit all updates
            await batch.commit();
            functions.logger.info('Batch processing completed', {
                total: snapshot.size,
                processed: processed.length,
                sent: processed.filter(p => p.status === 'sent').length,
                failed: processed.filter(p => p.status === 'failed').length,
                skipped: processed.filter(p => p.status === 'skipped').length
            });
            return processed;
        }
        catch (error) {
            functions.logger.error('Error processing notification batch', { error: error.message });
            throw error;
        }
    }
    /**
     * Process a single notification
     */
    static async processNotification(notification) {
        try {
            // Check user preferences
            const preferences = await this.getUserPreferences(notification.userId);
            if (!this.shouldSendNotification(notification, preferences)) {
                return {
                    status: 'skipped',
                    reason: 'user_preferences'
                };
            }
            // Check quiet hours
            if (this.isInQuietHours(preferences)) {
                // Reschedule for later
                await this.rescheduleNotification(notification, this.getNextAllowedTime(preferences));
                return {
                    status: 'skipped',
                    reason: 'quiet_hours'
                };
            }
            // Create user notification record
            const userNotification = await this.createUserNotification(notification);
            // Send push notification if enabled and tokens available
            let fcmResponse = null;
            if (preferences.pushEnabled) {
                fcmResponse = await this.sendPushNotification(notification, userNotification.id);
            }
            // Update analytics
            await NotificationAnalytics_1.NotificationAnalytics.recordSent(notification, {
                deliveryMethod: preferences.pushEnabled ? 'push' : 'in_app_only',
                fcmMessageId: fcmResponse === null || fcmResponse === void 0 ? void 0 : fcmResponse.messageId
            });
            return {
                status: 'sent',
                notificationId: userNotification.id,
                fcmResponse
            };
        }
        catch (error) {
            functions.logger.error('Error processing notification', {
                notificationId: notification.id,
                userId: notification.userId,
                error: error.message
            });
            return {
                status: 'failed',
                error: error.message
            };
        }
    }
    /**
     * Create user notification record in Firestore
     */
    static async createUserNotification(notification) {
        const db = admin.firestore();
        const userNotificationData = {
            type: notification.type,
            title: notification.title,
            message: notification.message,
            data: notification.data || {},
            source: notification.source,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isRead: false,
            priority: notification.priority,
            queueId: notification.id
        };
        const docRef = await db
            .collection(this.USER_NOTIFICATIONS)
            .doc(notification.userId)
            .collection('notifications')
            .add(userNotificationData);
        functions.logger.info('User notification created', {
            userId: notification.userId,
            notificationId: docRef.id,
            type: notification.type
        });
        return docRef;
    }
    /**
     * Send push notification via FCM
     */
    static async sendPushNotification(notification, userNotificationId) {
        try {
            const messaging = admin.messaging();
            const tokens = await this.getUserFCMTokens(notification.userId);
            if (tokens.length === 0) {
                functions.logger.info('No FCM tokens available for user', { userId: notification.userId });
                return null;
            }
            const message = {
                notification: {
                    title: notification.title,
                    body: notification.message,
                },
                data: Object.assign({ notificationId: userNotificationId, type: notification.type, userId: notification.userId }, (notification.data ? this.stringifyData(notification.data) : {})),
                android: {
                    priority: 'high',
                    notification: {
                        channelId: this.getNotificationChannel(notification.type),
                        priority: 'high',
                        sound: 'default',
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                },
                apns: {
                    headers: {
                        'apns-priority': '10'
                    },
                    payload: {
                        aps: {
                            alert: {
                                title: notification.title,
                                body: notification.message
                            },
                            badge: 1,
                            sound: 'default',
                            category: notification.type
                        }
                    }
                },
                tokens: tokens
            };
            const response = await messaging.sendMulticast(message);
            functions.logger.info('FCM message sent', {
                userId: notification.userId,
                tokensCount: tokens.length,
                successCount: response.successCount,
                failureCount: response.failureCount
            });
            // Handle failed tokens
            if (response.failureCount > 0) {
                await this.handleFailedTokens(notification.userId, tokens, response.responses);
            }
            return {
                messageId: `multicast_${Date.now()}`,
                successCount: response.successCount,
                failureCount: response.failureCount
            };
        }
        catch (error) {
            functions.logger.error('Failed to send FCM message', {
                userId: notification.userId,
                error: error.message
            });
            throw error;
        }
    }
    /**
     * Get user's FCM tokens
     */
    static async getUserFCMTokens(userId) {
        try {
            const db = admin.firestore();
            const subscriptionDoc = await db
                .collection(this.NOTIFICATION_SUBSCRIPTIONS)
                .doc(userId)
                .get();
            if (!subscriptionDoc.exists) {
                return [];
            }
            const data = subscriptionDoc.data();
            return (data === null || data === void 0 ? void 0 : data.fcmTokens) || [];
        }
        catch (error) {
            functions.logger.error('Failed to get FCM tokens', {
                userId,
                error: error.message
            });
            return [];
        }
    }
    /**
     * Get user notification preferences
     */
    static async getUserPreferences(userId) {
        try {
            const db = admin.firestore();
            const preferencesDoc = await db
                .collection(this.NOTIFICATION_PREFERENCES)
                .doc(userId)
                .get();
            if (!preferencesDoc.exists) {
                // Return default preferences
                return {
                    pushEnabled: true,
                    emailEnabled: true,
                    categories: {
                        achievement: true,
                        milestone: true,
                        reminder: true,
                        progress: true,
                        social: true,
                        system: true,
                        marketing: false
                    },
                    quietHours: {
                        enabled: true,
                        start: '22:00',
                        end: '08:00'
                    },
                    frequency: {
                        achievements: 'instant',
                        reminders: 'daily',
                        marketing: 'disabled'
                    }
                };
            }
            return preferencesDoc.data();
        }
        catch (error) {
            functions.logger.error('Failed to get user preferences', {
                userId,
                error: error.message
            });
            // Return restrictive defaults on error
            return {
                pushEnabled: false,
                emailEnabled: false,
                categories: {},
                quietHours: { enabled: false, start: '00:00', end: '00:00' },
                frequency: { achievements: 'disabled', reminders: 'disabled', marketing: 'disabled' }
            };
        }
    }
    /**
     * Check if notification should be sent based on preferences
     */
    static shouldSendNotification(notification, preferences) {
        // Always allow urgent system notifications
        if (notification.priority === 'urgent' && notification.source === 'system') {
            return true;
        }
        // Check if push notifications are enabled
        if (!preferences.pushEnabled) {
            return false;
        }
        // Check category preferences
        const categoryEnabled = preferences.categories[notification.type];
        if (categoryEnabled === false) {
            return false;
        }
        // Check frequency preferences
        if (notification.type === 'achievement' && preferences.frequency.achievements === 'disabled') {
            return false;
        }
        if (notification.source === 'marketing' && preferences.frequency.marketing === 'disabled') {
            return false;
        }
        return true;
    }
    /**
     * Check if current time is within user's quiet hours
     */
    static isInQuietHours(preferences) {
        if (!preferences.quietHours.enabled) {
            return false;
        }
        const now = new Date();
        const currentHour = now.getHours();
        const currentMinute = now.getMinutes();
        const currentTime = currentHour * 60 + currentMinute;
        const startTime = this.parseTime(preferences.quietHours.start);
        const endTime = this.parseTime(preferences.quietHours.end);
        // Handle overnight quiet hours (e.g., 22:00 to 08:00)
        if (startTime > endTime) {
            return currentTime >= startTime || currentTime <= endTime;
        }
        else {
            return currentTime >= startTime && currentTime <= endTime;
        }
    }
    /**
     * Parse time string to minutes since midnight
     */
    static parseTime(timeStr) {
        const [hours, minutes] = timeStr.split(':').map(Number);
        return hours * 60 + minutes;
    }
    /**
     * Get next allowed time after quiet hours
     */
    static getNextAllowedTime(preferences) {
        const now = new Date();
        const endTime = this.parseTime(preferences.quietHours.end);
        const nextAllowed = new Date(now);
        nextAllowed.setHours(Math.floor(endTime / 60), endTime % 60, 0, 0);
        // If end time is tomorrow (overnight quiet hours)
        if (endTime < this.parseTime(preferences.quietHours.start)) {
            nextAllowed.setDate(nextAllowed.getDate() + 1);
        }
        return nextAllowed;
    }
    /**
     * Reschedule notification for later
     */
    static async rescheduleNotification(notification, newTime) {
        const db = admin.firestore();
        if (notification.id) {
            await db.collection(this.COLLECTION).doc(notification.id).update({
                scheduleFor: admin.firestore.Timestamp.fromDate(newTime),
                status: 'queued'
            });
        }
    }
    /**
     * Handle failed notification with retry logic
     */
    static async handleFailedNotification(docRef, notification, error, batch) {
        const attempts = (notification.attempts || 0) + 1;
        if (attempts >= this.MAX_RETRIES) {
            // Max retries reached - mark as failed
            batch.update(docRef, {
                status: 'failed',
                failedAt: admin.firestore.FieldValue.serverTimestamp(),
                error: error,
                attempts: attempts
            });
            // Record failure analytics
            await NotificationAnalytics_1.NotificationAnalytics.recordFailure(notification, error);
        }
        else {
            // Schedule retry with exponential backoff
            const retryDelay = this.RETRY_DELAYS[Math.min(attempts - 1, this.RETRY_DELAYS.length - 1)];
            const retryTime = new Date(Date.now() + retryDelay);
            batch.update(docRef, {
                status: 'queued',
                attempts: attempts,
                scheduleFor: admin.firestore.Timestamp.fromDate(retryTime),
                error: error
            });
        }
    }
    /**
     * Handle failed FCM tokens by removing them
     */
    static async handleFailedTokens(userId, tokens, responses) {
        try {
            const db = admin.firestore();
            const failedTokens = [];
            responses.forEach((response, index) => {
                var _a;
                if (!response.success) {
                    const errorCode = (_a = response.error) === null || _a === void 0 ? void 0 : _a.code;
                    // Remove tokens that are invalid or unregistered
                    if (errorCode === 'messaging/invalid-registration-token' ||
                        errorCode === 'messaging/registration-token-not-registered') {
                        failedTokens.push(tokens[index]);
                    }
                }
            });
            if (failedTokens.length > 0) {
                await db.collection(this.NOTIFICATION_SUBSCRIPTIONS).doc(userId).update({
                    fcmTokens: admin.firestore.FieldValue.arrayRemove(...failedTokens)
                });
                functions.logger.info('Removed failed FCM tokens', {
                    userId,
                    removedCount: failedTokens.length
                });
            }
        }
        catch (error) {
            functions.logger.error('Failed to handle failed tokens', {
                userId,
                error: error.message
            });
        }
    }
    /**
     * Get appropriate notification channel for Android
     */
    static getNotificationChannel(type) {
        switch (type) {
            case 'achievement':
            case 'personal_record':
                return 'achievements';
            case 'reminder':
                return 'reminders';
            case 'progress':
                return 'progress';
            case 'social':
                return 'social';
            case 'system':
                return 'system';
            case 'marketing':
                return 'marketing';
            default:
                return 'default';
        }
    }
    /**
     * Convert data object to string values (required for FCM)
     */
    static stringifyData(data) {
        const stringified = {};
        for (const [key, value] of Object.entries(data)) {
            if (value !== null && value !== undefined) {
                stringified[key] = typeof value === 'string' ? value : JSON.stringify(value);
            }
        }
        return stringified;
    }
    /**
     * Get queue statistics for monitoring
     */
    static async getQueueStats() {
        var _a;
        try {
            const db = admin.firestore();
            const [queuedSnap, processingSnap, failedSnap] = await Promise.all([
                db.collection(this.COLLECTION).where('status', '==', 'queued').count().get(),
                db.collection(this.COLLECTION).where('status', '==', 'processing').count().get(),
                db.collection(this.COLLECTION).where('status', '==', 'failed').count().get()
            ]);
            // Get oldest queued notification
            const oldestQueued = await db.collection(this.COLLECTION)
                .where('status', '==', 'queued')
                .orderBy('queuedAt', 'asc')
                .limit(1)
                .get();
            return {
                queued: queuedSnap.data().count,
                processing: processingSnap.data().count,
                failed: failedSnap.data().count,
                oldestQueued: oldestQueued.empty ? null : ((_a = oldestQueued.docs[0].data().queuedAt) === null || _a === void 0 ? void 0 : _a.toDate()) || null
            };
        }
        catch (error) {
            functions.logger.error('Failed to get queue stats', { error: error.message });
            return { queued: 0, processing: 0, failed: 0, oldestQueued: null };
        }
    }
}
exports.NotificationQueue = NotificationQueue;
NotificationQueue.COLLECTION = 'notifications_queue';
NotificationQueue.USER_NOTIFICATIONS = 'user_notifications';
NotificationQueue.NOTIFICATION_SUBSCRIPTIONS = 'notification_subscriptions';
NotificationQueue.NOTIFICATION_PREFERENCES = 'notification_preferences';
NotificationQueue.MAX_RETRIES = 3;
NotificationQueue.RETRY_DELAYS = [60000, 300000, 900000]; // 1min, 5min, 15min
//# sourceMappingURL=NotificationQueue.js.map