/**
 * GymBro Enterprise Notification System - Cloud Functions
 * Comprehensive notification processing with enterprise features
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
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
export const onWorkoutCompleted = functions.firestore
  .document('sessionWorkouts/{workoutId}')
  .onCreate(async (snapshot, context) => {
    try {
      const workoutData = snapshot.data();
      const userId = workoutData.userId || workoutData.uid;
      
      if (!userId) {
        functions.logger.warn('Workout completed without userId', { workoutId: context.params.workoutId });
        return;
      }

      functions.logger.info('Processing workout completion', { 
        userId, 
        workoutId: context.params.workoutId 
      });

      // Queue achievement check notification
      await NotificationQueue.enqueue({
        type: 'achievement_check',
        userId,
        title: 'Checking for new achievements...',
        message: 'We\'re analyzing your workout for new milestones!',
        data: { 
          workoutId: context.params.workoutId, 
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
          workoutId: context.params.workoutId,
          workoutType: workoutData.type || 'strength',
          volume: workoutData.totalVolume || 0
        },
        priority: 'low',
        source: 'system',
        scheduleFor: new Date(Date.now() + 300000) // 5 minutes delay
      });

      // Record analytics
      await NotificationAnalytics.recordTrigger('workout_completed', userId, {
        workoutId: context.params.workoutId
      });

    } catch (error) {
      functions.logger.error('Error processing workout completion', { 
        error: error.message,
        workoutId: context.params.workoutId 
      });
      throw error;
    }
  });

/**
 * Triggers when a personal record is achieved
 * Sends high-priority achievement notification
 */
export const onPersonalRecord = functions.firestore
  .document('users/{userId}/personalRecords/{recordId}')
  .onCreate(async (snapshot, context) => {
    try {
      const recordData = snapshot.data();
      const userId = context.params.userId;

      functions.logger.info('Processing personal record', { userId, recordId: context.params.recordId });

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
        recordId: context.params.recordId,
        exercise: recordData.exerciseName,
        weight: recordData.weight
      });

    } catch (error) {
      functions.logger.error('Error processing personal record', { 
        error: error.message,
        userId: context.params.userId,
        recordId: context.params.recordId 
      });
      throw error;
    }
  });

/**
 * Triggers when user achieves a workout streak
 * Sends motivational notifications
 */
export const onStreakMilestone = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      const userId = context.params.userId;

      // Check if streak changed
      const beforeStreak = beforeData.currentStreak || 0;
      const afterStreak = afterData.currentStreak || 0;

      if (afterStreak > beforeStreak && afterStreak > 0) {
        functions.logger.info('Processing streak milestone', { 
          userId, 
          streak: afterStreak 
        });

        let notificationData: any = {
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
      functions.logger.error('Error processing streak milestone', { 
        error: error.message,
        userId: context.params.userId 
      });
    }
  });

// ============= SCHEDULED FUNCTIONS =============

/**
 * Process notification queue every minute
 * High-frequency processing for real-time notifications
 */
export const processNotificationQueue = functions
  .runWith({
    timeoutSeconds: 540, // 9 minutes
    memory: '1GB'
  })
  .pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    try {
      const batchSize = 100;
      const processed = await NotificationQueue.processBatch(batchSize);
      
      functions.logger.info(`Processed notification batch`, { 
        processed: processed.length,
        successful: processed.filter(p => p.status === 'sent').length,
        failed: processed.filter(p => p.status === 'failed').length
      });

      // Update system health metrics
      await SystemMonitor.recordProcessingMetrics({
        processed: processed.length,
        timestamp: admin.firestore.Timestamp.now()
      });

    } catch (error) {
      functions.logger.error('Error processing notification queue', { error: error.message });
      
      // Alert admin on critical errors
      await SystemMonitor.triggerAlert({
        type: 'queue_processing_error',
        message: error.message,
        severity: 'high'
      });
    }
  });

/**
 * Send personalized workout reminders
 * Runs twice daily at optimal times
 */
export const sendWorkoutReminders = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB'
  })
  .pubsub
  .schedule('0 9,18 * * *') // 9 AM and 6 PM
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    try {
      const hour = new Date().getHours();
      const timeOfDay = hour === 9 ? 'morning' : 'evening';
      
      functions.logger.info(`Sending ${timeOfDay} workout reminders`);

      const remindersSent = await NotificationPersonalization.sendTimedReminders(timeOfDay);
      
      functions.logger.info(`Sent workout reminders`, { 
        timeOfDay, 
        count: remindersSent 
      });

      // Record analytics
      await NotificationAnalytics.recordScheduledCampaign('workout_reminders', {
        timeOfDay,
        sent: remindersSent
      });

    } catch (error) {
      functions.logger.error('Error sending workout reminders', { error: error.message });
    }
  });

/**
 * Send weekend motivation notifications
 * Encourages users to stay active on weekends
 */
export const sendWeekendMotivation = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB'
  })
  .pubsub
  .schedule('0 10 * * 6,0') // 10 AM on weekends
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    try {
      functions.logger.info('Sending weekend motivation notifications');

      const motivationsSent = await NotificationPersonalization.sendWeekendMotivation();
      
      functions.logger.info('Sent weekend motivations', { count: motivationsSent });

      // Record analytics
      await NotificationAnalytics.recordScheduledCampaign('weekend_motivation', {
        sent: motivationsSent
      });

    } catch (error) {
      functions.logger.error('Error sending weekend motivation', { error: error.message });
    }
  });

/**
 * Generate daily analytics report
 * Comprehensive analysis of notification performance
 */
export const generateDailyAnalytics = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '1GB'
  })
  .pubsub
  .schedule('0 2 * * *') // 2 AM daily
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    try {
      functions.logger.info('Generating daily analytics report');

      const report = await NotificationAnalytics.generateDailyReport();
      
      functions.logger.info('Daily analytics generated', {
        date: report.date,
        totalSent: report.metrics.sent,
        deliveryRate: report.metrics.deliveryRate,
        clickThroughRate: report.metrics.clickThroughRate
      });

      // Alert on poor performance
      if (report.metrics.deliveryRate < 0.95 || report.metrics.clickThroughRate < 0.05) {
        await SystemMonitor.triggerAlert({
          type: 'poor_performance',
          message: `Daily notification performance below threshold`,
          data: report.metrics,
          severity: 'medium'
        });
      }

    } catch (error) {
      functions.logger.error('Error generating daily analytics', { error: error.message });
    }
  });

/**
 * Clean up old notifications and analytics data
 * Maintains optimal database performance
 */
export const cleanupOldData = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '512MB'
  })
  .pubsub
  .schedule('0 3 * * 0') // 3 AM every Sunday
  .timeZone('Europe/Rome')
  .onRun(async (context) => {
    try {
      functions.logger.info('Starting data cleanup');

      const cleanup = await NotificationAnalytics.cleanupOldData();
      
      functions.logger.info('Data cleanup completed', {
        notificationsDeleted: cleanup.notifications,
        analyticsDeleted: cleanup.analytics,
        queueItemsDeleted: cleanup.queueItems
      });

    } catch (error) {
      functions.logger.error('Error during data cleanup', { error: error.message });
    }
  });

/**
 * System health monitoring
 * Runs every 5 minutes to ensure system stability
 */
export const monitorSystemHealth = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '256MB'
  })
  .pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    try {
      const healthReport = await SystemMonitor.checkSystemHealth();
      
      if (healthReport.status === 'critical' || healthReport.status === 'warning') {
        functions.logger.warn('System health issue detected', healthReport);
        
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
      functions.logger.error('Error monitoring system health', { error: error.message });
      
      // This is critical - if monitoring fails, we need immediate attention
      await SystemMonitor.triggerAlert({
        type: 'monitoring_failure',
        message: `System monitoring failed: ${error.message}`,
        severity: 'critical'
      });
    }
  });

// ============= GDPR COMPLIANCE FUNCTIONS =============

/**
 * Handle user data export requests
 * GDPR Article 15 - Right of access
 */
export const exportUserNotificationData = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB'
  })
  .https
  .onCall(async (data, context) => {
    try {
      // Authenticate user
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
      }

      const userId = context.auth.uid;
      functions.logger.info('Processing data export request', { userId });

      const exportData = await NotificationPrivacy.exportUserData(userId);
      
      // Log compliance action
      await NotificationPrivacy.logComplianceAction(userId, 'data_exported', {
        requestTimestamp: admin.firestore.Timestamp.now(),
        dataTypes: ['notifications', 'preferences', 'analytics']
      });

      functions.logger.info('Data export completed', { 
        userId, 
        notificationCount: exportData.notifications.length 
      });

      return exportData;

    } catch (error) {
      functions.logger.error('Error exporting user data', { 
        error: error.message,
        userId: context.auth?.uid 
      });
      throw new functions.https.HttpsError('internal', 'Failed to export user data');
    }
  });

/**
 * Handle user data deletion requests
 * GDPR Article 17 - Right to erasure
 */
export const deleteUserNotificationData = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB'
  })
  .https
  .onCall(async (data, context) => {
    try {
      // Authenticate user
      if (!context.auth?.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
      }

      const userId = context.auth.uid;
      functions.logger.info('Processing data deletion request', { userId });

      const deletionResult = await NotificationPrivacy.deleteUserData(userId);
      
      // Log compliance action
      await NotificationPrivacy.logComplianceAction(userId, 'data_deleted', {
        requestTimestamp: admin.firestore.Timestamp.now(),
        deletionResult
      });

      functions.logger.info('Data deletion completed', { 
        userId, 
        result: deletionResult 
      });

      return { success: true, deletionResult };

    } catch (error) {
      functions.logger.error('Error deleting user data', { 
        error: error.message,
        userId: context.auth?.uid 
      });
      throw new functions.https.HttpsError('internal', 'Failed to delete user data');
    }
  });

// ============= ADMIN FUNCTIONS =============

/**
 * Send marketing campaign
 * Admin-only function for sending targeted campaigns
 */
export const sendMarketingCampaign = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '1GB'
  })
  .https
  .onCall(async (data, context) => {
    try {
      // Check admin authorization
      if (!context.auth?.token?.admin) {
        throw new functions.https.HttpsError('permission-denied', 'Admin access required');
      }

      const { campaignId, targetSegment, templateId } = data;
      
      if (!campaignId || !targetSegment || !templateId) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
      }

      functions.logger.info('Starting marketing campaign', { 
        campaignId, 
        targetSegment, 
        templateId 
      });

      const campaignResult = await NotificationPersonalization.sendMarketingCampaign(
        campaignId,
        targetSegment,
        templateId
      );

      functions.logger.info('Marketing campaign completed', {
        campaignId,
        sent: campaignResult.sent,
        failed: campaignResult.failed
      });

      return campaignResult;

    } catch (error) {
      functions.logger.error('Error sending marketing campaign', { 
        error: error.message,
        data 
      });
      throw new functions.https.HttpsError('internal', 'Failed to send marketing campaign');
    }
  });

/**
 * Get system analytics dashboard
 * Admin-only function for monitoring system performance
 */
export const getSystemAnalytics = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '512MB'
  })
  .https
  .onCall(async (data, context) => {
    try {
      // Check admin authorization
      if (!context.auth?.token?.admin) {
        throw new functions.https.HttpsError('permission-denied', 'Admin access required');
      }

      const { startDate, endDate, metrics } = data;
      
      functions.logger.info('Generating system analytics', { 
        startDate, 
        endDate, 
        metrics 
      });

      const analytics = await NotificationAnalytics.getSystemAnalytics(
        startDate ? new Date(startDate) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
        endDate ? new Date(endDate) : new Date(),
        metrics || ['delivery', 'engagement', 'conversion']
      );

      return analytics;

    } catch (error) {
      functions.logger.error('Error getting system analytics', { 
        error: error.message,
        data 
      });
      throw new functions.https.HttpsError('internal', 'Failed to get system analytics');
    }
  });

// Export all functions
export * from './queue/NotificationQueue';
export * from './analytics/NotificationAnalytics';
export * from './personalization/NotificationPersonalization';
export * from './privacy/NotificationPrivacy';
export * from './monitoring/SystemMonitor';