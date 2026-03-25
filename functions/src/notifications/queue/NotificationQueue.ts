/**
 * NotificationQueue - Enterprise notification queuing system
 * Handles high-throughput notification processing with retry logic
 */

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { NotificationAnalytics } from '../analytics/NotificationAnalytics';

export interface QueuedNotification {
  id?: string;
  type: string;
  userId: string;
  title: string;
  message: string;
  data?: Record<string, any>;
  priority: 'urgent' | 'high' | 'normal' | 'low';
  source: 'system' | 'user' | 'cloud_function' | 'marketing';
  scheduleFor?: Date;
  attempts?: number;
  status?: 'queued' | 'processing' | 'sent' | 'failed' | 'cancelled';
  queuedAt?: admin.firestore.Timestamp;
  processedAt?: admin.firestore.Timestamp;
  failedAt?: admin.firestore.Timestamp;
  error?: string;
  fcmMessageId?: string;
}

export interface ProcessedNotification {
  status: 'sent' | 'failed' | 'skipped';
  notificationId?: string;
  reason?: string;
  fcmResponse?: any;
  error?: string;
}

export interface NotificationPreferences {
  pushEnabled: boolean;
  emailEnabled: boolean;
  categories: Record<string, boolean>;
  quietHours: {
    enabled: boolean;
    start: string; // "22:00"
    end: string;   // "08:00"
  };
  frequency: {
    achievements: 'instant' | 'daily' | 'weekly' | 'disabled';
    reminders: 'daily' | 'weekly' | 'disabled';
    marketing: 'enabled' | 'disabled';
  };
}

export class NotificationQueue {
  private static readonly COLLECTION = 'notifications_queue';
  private static readonly USER_NOTIFICATIONS = 'user_notifications';
  private static readonly NOTIFICATION_SUBSCRIPTIONS = 'notification_subscriptions';
  private static readonly NOTIFICATION_PREFERENCES = 'notification_preferences';
  
  private static readonly MAX_RETRIES = 3;
  private static readonly RETRY_DELAYS = [60000, 300000, 900000]; // 1min, 5min, 15min

  /**
   * Enqueue a notification for processing
   */
  static async enqueue(notification: Omit<QueuedNotification, 'id' | 'queuedAt' | 'status' | 'attempts'>): Promise<string> {
    try {
      const db = admin.firestore();
      
      const queuedNotification: QueuedNotification = {
        ...notification,
        status: 'queued',
        attempts: 0,
        queuedAt: admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
        scheduleFor: notification.scheduleFor || new Date(),
      };

      // Add to queue with automatic ID generation
      const docRef = await db.collection(this.COLLECTION).add(queuedNotification);
      
      functions.logger.info('Notification queued', {
        id: docRef.id,
        type: notification.type,
        userId: notification.userId,
        priority: notification.priority
      });

      return docRef.id;

    } catch (error) {
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
  static async processBatch(batchSize: number = 100): Promise<ProcessedNotification[]> {
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
      const processed: ProcessedNotification[] = [];

      // Process each notification
      for (const doc of snapshot.docs) {
        const notification = { id: doc.id, ...doc.data() } as QueuedNotification;
        
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
              fcmMessageId: result.fcmResponse?.messageId
            });
          } else if (result.status === 'skipped') {
            batch.update(doc.ref, {
              status: 'cancelled',
              error: result.reason
            });
          } else {
            // Failed - handle retry logic
            await this.handleFailedNotification(
              doc.ref,
              notification,
              result.error || 'unknown_processing_error',
              batch
            );
          }

        } catch (error) {
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

    } catch (error) {
      functions.logger.error('Error processing notification batch', { error: error.message });
      throw error;
    }
  }

  /**
   * Process a single notification
   */
  private static async processNotification(notification: QueuedNotification): Promise<ProcessedNotification> {
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
      let fcmResponse: any = null;
      if (preferences.pushEnabled) {
        fcmResponse = await this.sendPushNotification(notification, userNotification.id);
      }

      // Update analytics
      await NotificationAnalytics.recordSent(notification, {
        deliveryMethod: preferences.pushEnabled ? 'push' : 'in_app_only',
        fcmMessageId: fcmResponse?.messageId
      });

      return { 
        status: 'sent', 
        notificationId: userNotification.id,
        fcmResponse 
      };

    } catch (error) {
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
  private static async createUserNotification(notification: QueuedNotification): Promise<admin.firestore.DocumentReference> {
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
  private static async sendPushNotification(
    notification: QueuedNotification,
    userNotificationId: string
  ): Promise<any> {
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
        data: {
          notificationId: userNotificationId,
          type: notification.type,
          userId: notification.userId,
          ...(notification.data ? this.stringifyData(notification.data) : {})
        },
        android: {
          priority: 'high' as const,
          notification: {
            channelId: this.getNotificationChannel(notification.type),
            priority: 'high' as const,
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

      const response = await messaging.sendEachForMulticast(message);

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

    } catch (error) {
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
  private static async getUserFCMTokens(userId: string): Promise<string[]> {
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
      return data?.fcmTokens || [];

    } catch (error) {
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
  private static async getUserPreferences(userId: string): Promise<NotificationPreferences> {
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

      return preferencesDoc.data() as NotificationPreferences;

    } catch (error) {
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
  private static shouldSendNotification(
    notification: QueuedNotification,
    preferences: NotificationPreferences
  ): boolean {
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
  private static isInQuietHours(preferences: NotificationPreferences): boolean {
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
    } else {
      return currentTime >= startTime && currentTime <= endTime;
    }
  }

  /**
   * Parse time string to minutes since midnight
   */
  private static parseTime(timeStr: string): number {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
  }

  /**
   * Get next allowed time after quiet hours
   */
  private static getNextAllowedTime(preferences: NotificationPreferences): Date {
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
  private static async rescheduleNotification(notification: QueuedNotification, newTime: Date): Promise<void> {
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
  private static async handleFailedNotification(
    docRef: admin.firestore.DocumentReference,
    notification: QueuedNotification,
    error: string,
    batch: admin.firestore.WriteBatch
  ): Promise<void> {
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
      await NotificationAnalytics.recordFailure(notification, error);
    } else {
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
  private static async handleFailedTokens(
    userId: string,
    tokens: string[],
    responses: admin.messaging.SendResponse[]
  ): Promise<void> {
    try {
      const db = admin.firestore();
      const failedTokens: string[] = [];

      responses.forEach((response, index) => {
        if (!response.success) {
          const errorCode = response.error?.code;
          
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

    } catch (error) {
      functions.logger.error('Failed to handle failed tokens', {
        userId,
        error: error.message
      });
    }
  }

  /**
   * Get appropriate notification channel for Android
   */
  private static getNotificationChannel(type: string): string {
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
  private static stringifyData(data: Record<string, any>): Record<string, string> {
    const stringified: Record<string, string> = {};
    
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
  static async getQueueStats(): Promise<{
    queued: number;
    processing: number;
    failed: number;
    oldestQueued: Date | null;
  }> {
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
        oldestQueued: oldestQueued.empty ? null : oldestQueued.docs[0].data().queuedAt?.toDate() || null
      };

    } catch (error) {
      functions.logger.error('Failed to get queue stats', { error: error.message });
      return { queued: 0, processing: 0, failed: 0, oldestQueued: null };
    }
  }
}
