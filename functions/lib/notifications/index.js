"use strict";
/**
 * GymBro Enterprise Notification System - Cloud Functions
 * Comprehensive notification processing with enterprise features
 *
 * Migrated to Firebase Functions v2 API (2025-12-27)
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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSystemAnalytics = exports.sendMarketingCampaign = exports.deleteUserNotificationData = exports.exportUserNotificationData = exports.monitorSystemHealth = exports.cleanupOldData = exports.generateDailyAnalytics = exports.sendWeekendMotivation = exports.sendWorkoutReminders = exports.processNotificationQueue = exports.onStreakMilestone = exports.onPersonalRecord = exports.onWorkoutCompleted = void 0;
const admin = __importStar(require("firebase-admin"));
const firebase_functions_1 = require("firebase-functions");
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const NotificationQueue_1 = require("./queue/NotificationQueue");
const NotificationAnalytics_1 = require("./analytics/NotificationAnalytics");
const NotificationPersonalization_1 = require("./personalization/NotificationPersonalization");
const NotificationPrivacy_1 = require("./privacy/NotificationPrivacy");
const SystemMonitor_1 = require("./monitoring/SystemMonitor");
// ============= TRIGGER FUNCTIONS =============
/**
 * Triggers when a workout is completed
 * Generates achievement and progress notifications
 */
exports.onWorkoutCompleted = (0, firestore_1.onDocumentCreated)('users/{userId}/workouts/{workoutId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        firebase_functions_1.logger.warn('No data in workout created event');
        return;
    }
    try {
        const workoutData = snapshot.data();
        const { userId, workoutId } = event.params;
        if (!userId) {
            firebase_functions_1.logger.warn('Workout completed without userId', { workoutId });
            return;
        }
        firebase_functions_1.logger.info('Processing workout completion', { userId, workoutId });
        // Queue achievement check notification
        await NotificationQueue_1.NotificationQueue.enqueue({
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
        await NotificationQueue_1.NotificationQueue.enqueue({
            type: 'progress_update',
            userId,
            title: 'Progress Update',
            message: 'Your fitness journey continues! Check out your latest progress.',
            data: {
                workoutId,
                workoutType: workoutData.type || 'strength',
                volume: workoutData.totalVolume || workoutData.volume || 0
            },
            priority: 'low',
            source: 'system',
            scheduleFor: new Date(Date.now() + 300000) // 5 minutes delay
        });
        // Record analytics
        await NotificationAnalytics_1.NotificationAnalytics.recordTrigger('workout_completed', userId, { workoutId });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error processing workout completion', {
            error: errorMessage,
            workoutId: event.params.workoutId
        });
        throw error;
    }
});
/**
 * Triggers when a personal record is achieved
 * Sends high-priority achievement notification
 */
exports.onPersonalRecord = (0, firestore_1.onDocumentCreated)('personalRecords/{recordId}', async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        firebase_functions_1.logger.warn('No data in personal record created event');
        return;
    }
    const recordData = snapshot.data();
    const { recordId } = event.params;
    const userId = recordData.userId;
    try {
        if (!userId) {
            firebase_functions_1.logger.warn('Personal record created without userId', { recordId });
            return;
        }
        const currentValue = Number(recordData.value || 0);
        const previousValue = Number(recordData.previousValue || 0);
        const formattedValue = recordData.type === 'weight' || recordData.type === 'oneRM'
            ? `${currentValue}kg`
            : `${currentValue}`;
        firebase_functions_1.logger.info('Processing personal record', { userId, recordId });
        await NotificationQueue_1.NotificationQueue.enqueue({
            type: 'personal_record',
            userId,
            title: '🏆 New Personal Record!',
            message: `Amazing! You just hit a new PR: ${formattedValue} on ${recordData.exerciseName}!`,
            data: {
                exercise: recordData.exerciseName,
                value: currentValue,
                previousRecord: previousValue,
                improvement: currentValue - previousValue,
                type: recordData.type || 'weight'
            },
            priority: 'high',
            source: 'system'
        });
        // Record analytics with high importance
        await NotificationAnalytics_1.NotificationAnalytics.recordTrigger('personal_record', userId, {
            recordId,
            exercise: recordData.exerciseName,
            value: currentValue,
            type: recordData.type || 'weight'
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error processing personal record', {
            error: errorMessage,
            userId,
            recordId
        });
        throw error;
    }
});
/**
 * Triggers when user achieves a workout streak
 * Sends motivational notifications
 */
exports.onStreakMilestone = (0, firestore_1.onDocumentUpdated)('users/{userId}', async (event) => {
    if (!event.data) {
        firebase_functions_1.logger.warn('No data in user updated event');
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
            firebase_functions_1.logger.info('Processing streak milestone', { userId, streak: afterStreak });
            let notificationData = {
                type: 'streak_milestone',
                userId,
                title: '',
                message: '',
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
            }
            else if (afterStreak === 7) {
                notificationData.title = '⚡ Weekly Warrior!';
                notificationData.message = 'One full week of dedication! You\'re building a strong habit.';
                notificationData.priority = 'high';
            }
            else if (afterStreak === 14) {
                notificationData.title = '💎 Two Week Champion!';
                notificationData.message = 'Incredible consistency! Your commitment is paying off.';
                notificationData.priority = 'high';
            }
            else if (afterStreak === 30) {
                notificationData.title = '🏆 Monthly Legend!';
                notificationData.message = '30 days straight! You\'ve officially entered the elite club!';
                notificationData.priority = 'urgent';
            }
            else if (afterStreak % 7 === 0 && afterStreak > 30) {
                notificationData.title = `🎯 ${afterStreak}-Day Streak!`;
                notificationData.message = `Unbelievable dedication! ${afterStreak} days of consistent training!`;
            }
            else {
                return; // Don't send notification for other streak numbers
            }
            await NotificationQueue_1.NotificationQueue.enqueue(notificationData);
            // Record analytics
            await NotificationAnalytics_1.NotificationAnalytics.recordTrigger('streak_milestone', userId, {
                streak: afterStreak,
                milestone: true
            });
        }
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error processing streak milestone', {
            error: errorMessage,
            userId: event.params.userId
        });
    }
});
// ============= SCHEDULED FUNCTIONS =============
/**
 * Process notification queue every minute
 * High-frequency processing for real-time notifications
 */
exports.processNotificationQueue = (0, scheduler_1.onSchedule)({
    schedule: 'every 1 minutes',
    timeoutSeconds: 540,
    memory: '1GiB',
}, async () => {
    try {
        const batchSize = 100;
        const processed = await NotificationQueue_1.NotificationQueue.processBatch(batchSize);
        firebase_functions_1.logger.info('Processed notification batch', {
            processed: processed.length,
            successful: processed.filter((p) => p.status === 'sent').length,
            failed: processed.filter((p) => p.status === 'failed').length
        });
        // Update system health metrics
        await SystemMonitor_1.SystemMonitor.recordProcessingMetrics({
            processed: processed.length,
            timestamp: admin.firestore.Timestamp.now()
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error processing notification queue', { error: errorMessage });
        // Alert admin on critical errors
        await SystemMonitor_1.SystemMonitor.triggerAlert({
            type: 'queue_processing_error',
            message: errorMessage,
            severity: 'high'
        });
    }
});
/**
 * Send personalized workout reminders
 * Runs twice daily at optimal times
 */
exports.sendWorkoutReminders = (0, scheduler_1.onSchedule)({
    schedule: '0 9,18 * * *',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 300,
    memory: '512MiB',
}, async () => {
    try {
        const hour = new Date().getHours();
        const timeOfDay = hour === 9 ? 'morning' : 'evening';
        firebase_functions_1.logger.info(`Sending ${timeOfDay} workout reminders`);
        const remindersSent = await NotificationPersonalization_1.NotificationPersonalization.sendTimedReminders(timeOfDay);
        firebase_functions_1.logger.info('Sent workout reminders', { timeOfDay, count: remindersSent });
        // Record analytics
        await NotificationAnalytics_1.NotificationAnalytics.recordScheduledCampaign('workout_reminders', {
            timeOfDay,
            sent: remindersSent
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error sending workout reminders', { error: errorMessage });
    }
});
/**
 * Send weekend motivation notifications
 * Encourages users to stay active on weekends
 */
exports.sendWeekendMotivation = (0, scheduler_1.onSchedule)({
    schedule: '0 10 * * 6,0',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 300,
    memory: '512MiB',
}, async () => {
    try {
        firebase_functions_1.logger.info('Sending weekend motivation notifications');
        const motivationsSent = await NotificationPersonalization_1.NotificationPersonalization.sendWeekendMotivation();
        firebase_functions_1.logger.info('Sent weekend motivations', { count: motivationsSent });
        // Record analytics
        await NotificationAnalytics_1.NotificationAnalytics.recordScheduledCampaign('weekend_motivation', {
            sent: motivationsSent
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error sending weekend motivation', { error: errorMessage });
    }
});
/**
 * Generate daily analytics report
 * Comprehensive analysis of notification performance
 */
exports.generateDailyAnalytics = (0, scheduler_1.onSchedule)({
    schedule: '0 2 * * *',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 540,
    memory: '1GiB',
}, async () => {
    try {
        firebase_functions_1.logger.info('Generating daily analytics report');
        const report = await NotificationAnalytics_1.NotificationAnalytics.generateDailyReport();
        firebase_functions_1.logger.info('Daily analytics generated', {
            date: report.date,
            totalSent: report.metrics.sent,
            deliveryRate: report.metrics.deliveryRate,
            clickThroughRate: report.metrics.clickThroughRate
        });
        // Alert on poor performance
        if (report.metrics.deliveryRate < 0.95 || report.metrics.clickThroughRate < 0.05) {
            await SystemMonitor_1.SystemMonitor.triggerAlert({
                type: 'poor_performance',
                message: 'Daily notification performance below threshold',
                data: report.metrics,
                severity: 'medium'
            });
        }
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error generating daily analytics', { error: errorMessage });
    }
});
/**
 * Clean up old notifications and analytics data
 * Maintains optimal database performance
 */
exports.cleanupOldData = (0, scheduler_1.onSchedule)({
    schedule: '0 3 * * 0',
    timeZone: 'Europe/Rome',
    timeoutSeconds: 540,
    memory: '512MiB',
}, async () => {
    try {
        firebase_functions_1.logger.info('Starting data cleanup');
        const cleanup = await NotificationAnalytics_1.NotificationAnalytics.cleanupOldData();
        firebase_functions_1.logger.info('Data cleanup completed', {
            notificationsDeleted: cleanup.notifications,
            analyticsDeleted: cleanup.analytics,
            queueItemsDeleted: cleanup.queueItems
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error during data cleanup', { error: errorMessage });
    }
});
/**
 * System health monitoring
 * Runs every 5 minutes to ensure system stability
 */
exports.monitorSystemHealth = (0, scheduler_1.onSchedule)({
    schedule: 'every 5 minutes',
    timeoutSeconds: 120,
    memory: '256MiB',
}, async () => {
    try {
        const healthReport = await SystemMonitor_1.SystemMonitor.checkSystemHealth();
        if (healthReport.status === 'critical' || healthReport.status === 'warning') {
            firebase_functions_1.logger.warn('System health issue detected', healthReport);
            if (healthReport.status === 'critical') {
                await SystemMonitor_1.SystemMonitor.triggerAlert({
                    type: 'system_health',
                    message: 'Critical system health issue detected',
                    data: healthReport,
                    severity: 'critical'
                });
            }
        }
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error monitoring system health', { error: errorMessage });
        // This is critical - if monitoring fails, we need immediate attention
        await SystemMonitor_1.SystemMonitor.triggerAlert({
            type: 'monitoring_failure',
            message: `System monitoring failed: ${errorMessage}`,
            severity: 'critical'
        });
    }
});
// ============= GDPR COMPLIANCE FUNCTIONS =============
/**
 * Handle user data export requests
 * GDPR Article 15 - Right of access
 */
exports.exportUserNotificationData = (0, https_1.onCall)({
    enforceAppCheck: true,
    timeoutSeconds: 300,
    memory: '512MiB',
}, async (request) => {
    var _a, _b;
    try {
        // Authenticate user
        if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
            throw new https_1.HttpsError('unauthenticated', 'User must be authenticated');
        }
        const userId = request.auth.uid;
        firebase_functions_1.logger.info('Processing data export request', { userId });
        const exportData = await NotificationPrivacy_1.NotificationPrivacy.exportUserData(userId);
        // Log compliance action
        await NotificationPrivacy_1.NotificationPrivacy.logComplianceAction(userId, 'data_exported', {
            requestTimestamp: admin.firestore.Timestamp.now(),
            dataTypes: ['notifications', 'preferences', 'analytics']
        });
        firebase_functions_1.logger.info('Data export completed', {
            userId,
            notificationCount: exportData.notifications.length
        });
        return exportData;
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error exporting user data', {
            error: errorMessage,
            userId: (_b = request.auth) === null || _b === void 0 ? void 0 : _b.uid
        });
        if (error instanceof https_1.HttpsError)
            throw error;
        throw new https_1.HttpsError('internal', 'Failed to export user data');
    }
});
/**
 * Handle user data deletion requests
 * GDPR Article 17 - Right to erasure
 */
exports.deleteUserNotificationData = (0, https_1.onCall)({
    enforceAppCheck: true,
    timeoutSeconds: 300,
    memory: '512MiB',
}, async (request) => {
    var _a, _b;
    try {
        // Authenticate user
        if (!((_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid)) {
            throw new https_1.HttpsError('unauthenticated', 'User must be authenticated');
        }
        const userId = request.auth.uid;
        firebase_functions_1.logger.info('Processing data deletion request', { userId });
        const deletionResult = await NotificationPrivacy_1.NotificationPrivacy.deleteUserData(userId);
        // Log compliance action
        await NotificationPrivacy_1.NotificationPrivacy.logComplianceAction(userId, 'data_deleted', {
            requestTimestamp: admin.firestore.Timestamp.now(),
            deletionResult
        });
        firebase_functions_1.logger.info('Data deletion completed', { userId, result: deletionResult });
        return { success: true, deletionResult };
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error deleting user data', {
            error: errorMessage,
            userId: (_b = request.auth) === null || _b === void 0 ? void 0 : _b.uid
        });
        if (error instanceof https_1.HttpsError)
            throw error;
        throw new https_1.HttpsError('internal', 'Failed to delete user data');
    }
});
/**
 * Send marketing campaign
 * Admin-only function for sending targeted campaigns
 */
exports.sendMarketingCampaign = (0, https_1.onCall)({
    enforceAppCheck: true,
    timeoutSeconds: 540,
    memory: '1GiB',
}, async (request) => {
    var _a, _b;
    try {
        // Check admin authorization
        if (!((_b = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.token) === null || _b === void 0 ? void 0 : _b.admin)) {
            throw new https_1.HttpsError('permission-denied', 'Admin access required');
        }
        const { campaignId, targetSegment, templateId } = request.data;
        if (!campaignId || !targetSegment || !templateId) {
            throw new https_1.HttpsError('invalid-argument', 'Missing required parameters');
        }
        firebase_functions_1.logger.info('Starting marketing campaign', { campaignId, targetSegment, templateId });
        const campaignResult = await NotificationPersonalization_1.NotificationPersonalization.sendMarketingCampaign(campaignId, targetSegment, templateId);
        firebase_functions_1.logger.info('Marketing campaign completed', {
            campaignId,
            sent: campaignResult.sent,
            failed: campaignResult.failed
        });
        return campaignResult;
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error sending marketing campaign', {
            error: errorMessage,
            data: request.data
        });
        if (error instanceof https_1.HttpsError)
            throw error;
        throw new https_1.HttpsError('internal', 'Failed to send marketing campaign');
    }
});
/**
 * Get system analytics dashboard
 * Admin-only function for monitoring system performance
 */
exports.getSystemAnalytics = (0, https_1.onCall)({
    enforceAppCheck: true,
    timeoutSeconds: 120,
    memory: '512MiB',
}, async (request) => {
    var _a, _b;
    try {
        // Check admin authorization
        if (!((_b = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.token) === null || _b === void 0 ? void 0 : _b.admin)) {
            throw new https_1.HttpsError('permission-denied', 'Admin access required');
        }
        const { startDate, endDate, metrics } = request.data;
        firebase_functions_1.logger.info('Generating system analytics', { startDate, endDate, metrics });
        const analytics = await NotificationAnalytics_1.NotificationAnalytics.getSystemAnalytics(startDate ? new Date(startDate) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), endDate ? new Date(endDate) : new Date(), metrics || ['delivery', 'engagement', 'conversion']);
        return analytics;
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        firebase_functions_1.logger.error('Error getting system analytics', {
            error: errorMessage,
            data: request.data
        });
        if (error instanceof https_1.HttpsError)
            throw error;
        throw new https_1.HttpsError('internal', 'Failed to get system analytics');
    }
});
// Export helper modules
__exportStar(require("./queue/NotificationQueue"), exports);
__exportStar(require("./analytics/NotificationAnalytics"), exports);
__exportStar(require("./personalization/NotificationPersonalization"), exports);
__exportStar(require("./privacy/NotificationPrivacy"), exports);
__exportStar(require("./monitoring/SystemMonitor"), exports);
//# sourceMappingURL=index.js.map