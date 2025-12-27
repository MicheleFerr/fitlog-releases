/**
 * GymBro Enterprise Notification System - Cloud Functions
 * Comprehensive notification processing with enterprise features
 *
 * Migrated to Firebase Functions v2 API (2025-12-27)
 */

import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';
import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { NotificationQueue } from './queue/NotificationQueue';
import { NotificationAnalytics } from './analytics/NotificationAnalytics';
import { NotificationPersonalization } from './personalization/NotificationPersonalization';
import { NotificationPrivacy } from './privacy/NotificationPrivacy';
import { SystemMonitor } from './monitoring/SystemMonitor';

// ============= TRIGGER FUNCTIONS =============

/**
 * Triggers when a workout is completed
 * Generates achievement and progress notifications
 */
export const onWorkoutCompleted = onDocumentCreated(
  'sessionWorkouts/{workoutId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn('No data in workout created event');
      return;
    }

    try {
      const workoutData = snapshot.data();
      const userId = workoutData.userId || workoutData.uid;
      const workoutId = event.params.workoutId;

      if (!userId) {
        logger.warn('Workout completed without userId', { workoutId });
        return;
      }

      logger.info('Processing workout completion', { userId, workoutId });

      // Queue achievement check notification
      await NotificationQueue.enqueue({
        type: 'achievement_check',
        userId,
        title: 'Checking for new achievements...',
        message: 'We\'re analyzing your workout for new milestones!',
        data: {
          workoutId,
          completedAt: workoutData.completedAt || admin.firestore.Timestamp.now(),
          exercises: workoutData.exercises || [],
          duration: workoutData.duration || 0
        },
        priority: 'normal',
        source: 'system'
      });

      // Queue progress update notification
      await NotificationQueue.enqueue({
        type: 'progress_update',
        userId,
        title: 'Progress Update',
        message: 'Your fitness journey continues! Check out your latest progress.',
        data: {
          workoutId,
          workoutType: workoutData.type || 'strength',
          volume: workoutData.totalVolume || 0
        },
        priority: 'low',
        source: 'system',
        scheduleFor: new Date(Date.now() + 300000) // 5 minutes delay
      });

      // Record analytics
      await NotificationAnalytics.recordTrigger('workout_completed', userId, { workoutId });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error processing workout completion', {
        error: errorMessage,
        workoutId: event.params.workoutId
      });
      throw error;
    }
  }
);

/**
 * Triggers when a personal record is achieved
 * Sends high-priority achievement notification
 */
export const onPersonalRecord = onDocumentCreated(
  'users/{userId}/personalRecords/{recordId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn('No data in personal record created event');
      return;
    }

    try {
      const recordData = snapshot.data();
      const { userId, recordId } = event.params;

      logger.info('Processing personal record', { userId, recordId });

      await NotificationQueue.enqueue({
        type: 'personal_record',
        userId,
        title: '🏆 New Personal Record!',
        message: `Amazing! You just hit a new PR: ${recordData.weight}kg on ${recordData.exerciseName}!`,
        data: {
          exercise: recordData.exerciseName,
          weight: recordData.weight,
          previousRecord: recordData.previousWeight || 0,
          improvement: recordData.weight - (recordData.previousWeight || 0)
        },
        priority: 'high',
        source: 'system'
      });

      // Record analytics with high importance
      await NotificationAnalytics.recordTrigger('personal_record', userId, {
        recordId,
        exercise: recordData.exerciseName,
        weight: recordData.weight
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error processing personal record', {
        error: errorMessage,
        userId: event.params.userId,
        recordId: event.params.recordId
      });
      throw error;
    }
  }
);

/**
 * Triggers when user achieves a workout streak
 * Sends motivational notifications
 */
export const onStreakMilestone = onDocumentUpdated(
  'users/{userId}',
  async (event) => {
    if (!event.data) {
      logger.warn('No data in user updated event');
      return;
    }

    try {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();
      const userId = event.params.userId;

      // Check if streak changed
      const beforeStreak = beforeData.currentStreak || 0;
      const afterStreak = afterData.currentStreak || 0;

      if (afterStreak > beforeStreak && afterStreak > 0) {
        logger.info('Processing streak milestone', { userId, streak: afterStreak });

        let notificationData: Record<string, unknown> = {
          type: 'streak_milestone',
          userId,
          data: {
            streak: afterStreak,
            previousStreak: beforeStreak
          },
          priority: 'normal',
          source: 'system'
        };

        // Custom messages for different streak milestones
        if (afterStreak === 3) {
          notificationData.title = '🔥 3-Day Streak!';
          notificationData.message = 'Great start! Keep the momentum going!';
          notificationData.priority = 'high';
        } else if (afterStreak === 7) {
          notificationData.title = '⚡ Weekly Warrior!';
          notificationData.message = 'One full week of dedication! You\'re building a strong habit.';
          notificationData.priority = 'high';
        } else if (afterStreak === 14) {
          notificationData.title = '💎 Two Week Champion!';
          notificationData.message = 'Incredible consistency! Your commitment is paying off.';
          notificationData.priority = 'high';
        } else if (afterStreak === 30) {
          notificationData.title = '🏆 Monthly Legend!';
          notificationData.message = '30 days straight! You\'ve officially entered the elite club!';
          notificationData.priority = 'urgent';
        } else if (afterStreak % 7 === 0 && afterStreak > 30) {
          notificationData.title = `🎯 ${afterStreak}-Day Streak!`;
          notificationData.message = `Unbelievable dedication! ${afterStreak} days of consistent training!`;
        } else {
          return; // Don't send notification for other streak numbers
        }

        await NotificationQueue.enqueue(notificationData);

        // Record analytics
        await NotificationAnalytics.recordTrigger('streak_milestone', userId, {
          streak: afterStreak,
          milestone: true
        });
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error processing streak milestone', {
        error: errorMessage,
        userId: event.params.userId
      });
    }
  }
);

// ============= SCHEDULED FUNCTIONS =============

/**
 * Process notification queue every minute
 * High-frequency processing for real-time notifications
 */
export const processNotificationQueue = onSchedule(
  {
    schedule: 'every 1 minutes',
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async () => {
    try {
      const batchSize = 100;
      const processed = await NotificationQueue.processBatch(batchSize);

      logger.info('Processed notification batch', {
        processed: processed.length,
        successful: processed.filter((p: { status: string }) => p.status === 'sent').length,
        failed: processed.filter((p: { status: string }) => p.status === 'failed').length
      });

      // Update system health metrics
      await SystemMonitor.recordProcessingMetrics({
        processed: processed.length,
        timestamp: admin.firestore.Timestamp.now()
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error processing notification queue', { error: errorMessage });

      // Alert admin on critical errors
      await SystemMonitor.triggerAlert({
        type: 'queue_processing_error',
        message: errorMessage,
        severity: 'high'
      });
    }
  }
);

/**
 * Send personalized workout reminders
 * Runs twice daily at optimal times
 */
export const sendWorkoutReminders = onSchedule(
  {
    schedule: '0 9,18 * * *',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 300,
    memory: '512MiB',
  },
  async () => {
    try {
      const hour = new Date().getHours();
      const timeOfDay = hour === 9 ? 'morning' : 'evening';

      logger.info(`Sending ${timeOfDay} workout reminders`);

      const remindersSent = await NotificationPersonalization.sendTimedReminders(timeOfDay);

      logger.info('Sent workout reminders', { timeOfDay, count: remindersSent });

      // Record analytics
      await NotificationAnalytics.recordScheduledCampaign('workout_reminders', {
        timeOfDay,
        sent: remindersSent
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error sending workout reminders', { error: errorMessage });
    }
  }
);

/**
 * Send weekend motivation notifications
 * Encourages users to stay active on weekends
 */
export const sendWeekendMotivation = onSchedule(
  {
    schedule: '0 10 * * 6,0',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 300,
    memory: '512MiB',
  },
  async () => {
    try {
      logger.info('Sending weekend motivation notifications');

      const motivationsSent = await NotificationPersonalization.sendWeekendMotivation();

      logger.info('Sent weekend motivations', { count: motivationsSent });

      // Record analytics
      await NotificationAnalytics.recordScheduledCampaign('weekend_motivation', {
        sent: motivationsSent
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error sending weekend motivation', { error: errorMessage });
    }
  }
);

/**
 * Generate daily analytics report
 * Comprehensive analysis of notification performance
 */
export const generateDailyAnalytics = onSchedule(
  {
    schedule: '0 2 * * *',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async () => {
    try {
      logger.info('Generating daily analytics report');

      const report = await NotificationAnalytics.generateDailyReport();

      logger.info('Daily analytics generated', {
        date: report.date,
        totalSent: report.metrics.sent,
        deliveryRate: report.metrics.deliveryRate,
        clickThroughRate: report.metrics.clickThroughRate
      });

      // Alert on poor performance
      if (report.metrics.deliveryRate < 0.95 || report.metrics.clickThroughRate < 0.05) {
        await SystemMonitor.triggerAlert({
          type: 'poor_performance',
          message: 'Daily notification performance below threshold',
          data: report.metrics,
          severity: 'medium'
        });
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error generating daily analytics', { error: errorMessage });
    }
  }
);

/**
 * Clean up old notifications and analytics data
 * Maintains optimal database performance
 */
export const cleanupOldData = onSchedule(
  {
    schedule: '0 3 * * 0',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 540,
    memory: '512MiB',
  },
  async () => {
    try {
      logger.info('Starting data cleanup');

      const cleanup = await NotificationAnalytics.cleanupOldData();

      logger.info('Data cleanup completed', {
        notificationsDeleted: cleanup.notifications,
        analyticsDeleted: cleanup.analytics,
        queueItemsDeleted: cleanup.queueItems
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error during data cleanup', { error: errorMessage });
    }
  }
);

/**
 * System health monitoring
 * Runs every 5 minutes to ensure system stability
 */
export const monitorSystemHealth = onSchedule(
  {
    schedule: 'every 5 minutes',
    timeoutSeconds: 120,
    memory: '256MiB',
  },
  async () => {
    try {
      const healthReport = await SystemMonitor.checkSystemHealth();

      if (healthReport.status === 'critical' || healthReport.status === 'warning') {
        logger.warn('System health issue detected', healthReport);

        if (healthReport.status === 'critical') {
          await SystemMonitor.triggerAlert({
            type: 'system_health',
            message: 'Critical system health issue detected',
            data: healthReport,
            severity: 'critical'
          });
        }
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error monitoring system health', { error: errorMessage });

      // This is critical - if monitoring fails, we need immediate attention
      await SystemMonitor.triggerAlert({
        type: 'monitoring_failure',
        message: `System monitoring failed: ${errorMessage}`,
        severity: 'critical'
      });
    }
  }
);

// ============= GDPR COMPLIANCE FUNCTIONS =============

/**
 * Handle user data export requests
 * GDPR Article 15 - Right of access
 */
export const exportUserNotificationData = onCall(
  {
    timeoutSeconds: 300,
    memory: '512MiB',
  },
  async (request) => {
    try {
      // Authenticate user
      if (!request.auth?.uid) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const userId = request.auth.uid;
      logger.info('Processing data export request', { userId });

      const exportData = await NotificationPrivacy.exportUserData(userId);

      // Log compliance action
      await NotificationPrivacy.logComplianceAction(userId, 'data_exported', {
        requestTimestamp: admin.firestore.Timestamp.now(),
        dataTypes: ['notifications', 'preferences', 'analytics']
      });

      logger.info('Data export completed', {
        userId,
        notificationCount: exportData.notifications.length
      });

      return exportData;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error exporting user data', {
        error: errorMessage,
        userId: request.auth?.uid
      });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', 'Failed to export user data');
    }
  }
);

/**
 * Handle user data deletion requests
 * GDPR Article 17 - Right to erasure
 */
export const deleteUserNotificationData = onCall(
  {
    timeoutSeconds: 300,
    memory: '512MiB',
  },
  async (request) => {
    try {
      // Authenticate user
      if (!request.auth?.uid) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const userId = request.auth.uid;
      logger.info('Processing data deletion request', { userId });

      const deletionResult = await NotificationPrivacy.deleteUserData(userId);

      // Log compliance action
      await NotificationPrivacy.logComplianceAction(userId, 'data_deleted', {
        requestTimestamp: admin.firestore.Timestamp.now(),
        deletionResult
      });

      logger.info('Data deletion completed', { userId, result: deletionResult });

      return { success: true, deletionResult };

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error deleting user data', {
        error: errorMessage,
        userId: request.auth?.uid
      });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', 'Failed to delete user data');
    }
  }
);

// ============= ADMIN FUNCTIONS =============

interface MarketingCampaignData {
  campaignId: string;
  targetSegment: string;
  templateId: string;
}

/**
 * Send marketing campaign
 * Admin-only function for sending targeted campaigns
 */
export const sendMarketingCampaign = onCall<MarketingCampaignData>(
  {
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async (request) => {
    try {
      // Check admin authorization
      if (!request.auth?.token?.admin) {
        throw new HttpsError('permission-denied', 'Admin access required');
      }

      const { campaignId, targetSegment, templateId } = request.data;

      if (!campaignId || !targetSegment || !templateId) {
        throw new HttpsError('invalid-argument', 'Missing required parameters');
      }

      logger.info('Starting marketing campaign', { campaignId, targetSegment, templateId });

      const campaignResult = await NotificationPersonalization.sendMarketingCampaign(
        campaignId,
        targetSegment,
        templateId
      );

      logger.info('Marketing campaign completed', {
        campaignId,
        sent: campaignResult.sent,
        failed: campaignResult.failed
      });

      return campaignResult;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error sending marketing campaign', {
        error: errorMessage,
        data: request.data
      });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', 'Failed to send marketing campaign');
    }
  }
);

interface SystemAnalyticsData {
  startDate?: string;
  endDate?: string;
  metrics?: string[];
}

/**
 * Get system analytics dashboard
 * Admin-only function for monitoring system performance
 */
export const getSystemAnalytics = onCall<SystemAnalyticsData>(
  {
    timeoutSeconds: 120,
    memory: '512MiB',
  },
  async (request) => {
    try {
      // Check admin authorization
      if (!request.auth?.token?.admin) {
        throw new HttpsError('permission-denied', 'Admin access required');
      }

      const { startDate, endDate, metrics } = request.data;

      logger.info('Generating system analytics', { startDate, endDate, metrics });

      const analytics = await NotificationAnalytics.getSystemAnalytics(
        startDate ? new Date(startDate) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        endDate ? new Date(endDate) : new Date(),
        metrics || ['delivery', 'engagement', 'conversion']
      );

      return analytics;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error('Error getting system analytics', {
        error: errorMessage,
        data: request.data
      });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError('internal', 'Failed to get system analytics');
    }
  }
);

// Export helper modules
export * from './queue/NotificationQueue';
export * from './analytics/NotificationAnalytics';
export * from './personalization/NotificationPersonalization';
export * from './privacy/NotificationPrivacy';
export * from './monitoring/SystemMonitor';
