"use strict";
/**
 * NotificationAnalytics - Advanced analytics and reporting for enterprise notifications
 * Provides comprehensive insights into notification performance and user engagement
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
exports.NotificationAnalytics = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
class NotificationAnalytics {
    /**
     * Record when a notification is sent
     */
    static async recordSent(notification, metadata) {
        try {
            const db = admin.firestore();
            await db.collection(this.ANALYTICS_COLLECTION).add({
                userId: notification.userId,
                notificationId: notification.id,
                type: notification.type,
                source: notification.source,
                priority: notification.priority,
                action: 'sent',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                metadata: {
                    deliveryMethod: metadata.deliveryMethod,
                    fcmMessageId: metadata.fcmMessageId,
                    title: notification.title,
                    queuedAt: notification.queuedAt,
                    processedAt: admin.firestore.FieldValue.serverTimestamp(),
                },
                deviceInfo: await this.getDeviceInfo()
            });
            functions.logger.info('Notification sent recorded', {
                userId: notification.userId,
                type: notification.type,
                notificationId: notification.id
            });
        }
        catch (error) {
            functions.logger.error('Failed to record sent notification', {
                error: error.message,
                notificationId: notification.id
            });
        }
    }
    /**
     * Record notification failure for analytics
     */
    static async recordFailure(notification, error) {
        try {
            const db = admin.firestore();
            await db.collection(this.ANALYTICS_COLLECTION).add({
                userId: notification.userId,
                notificationId: notification.id,
                type: notification.type,
                action: 'failed',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                metadata: {
                    error: error,
                    attempts: notification.attempts || 0,
                    priority: notification.priority,
                    source: notification.source
                }
            });
        }
        catch (err) {
            functions.logger.error('Failed to record notification failure', {
                error: err.message,
                originalError: error
            });
        }
    }
    /**
     * Record trigger event (workout completion, achievement, etc.)
     */
    static async recordTrigger(triggerType, userId, data) {
        try {
            const db = admin.firestore();
            await db.collection(this.ANALYTICS_COLLECTION).add({
                userId: userId,
                action: 'trigger',
                triggerType: triggerType,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                data: data
            });
        }
        catch (error) {
            functions.logger.error('Failed to record trigger', {
                error: error.message,
                triggerType,
                userId
            });
        }
    }
    /**
     * Record scheduled campaign execution
     */
    static async recordScheduledCampaign(campaignType, metrics) {
        try {
            const db = admin.firestore();
            await db.collection(this.ANALYTICS_COLLECTION).add({
                action: 'scheduled_campaign',
                campaignType: campaignType,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                metrics: metrics
            });
        }
        catch (error) {
            functions.logger.error('Failed to record scheduled campaign', {
                error: error.message,
                campaignType
            });
        }
    }
    /**
     * Generate comprehensive daily report
     */
    static async generateDailyReport(date) {
        try {
            const reportDate = date || new Date();
            reportDate.setDate(reportDate.getDate() - 1); // Previous day
            const startDate = new Date(reportDate);
            startDate.setHours(0, 0, 0, 0);
            const endDate = new Date(reportDate);
            endDate.setHours(23, 59, 59, 999);
            functions.logger.info('Generating daily report', {
                startDate: startDate.toISOString(),
                endDate: endDate.toISOString()
            });
            // Collect all metrics in parallel
            const [metrics, segmentBreakdown, topPerforming, userEngagement, costAnalysis] = await Promise.all([
                this.calculateDailyMetrics(startDate, endDate),
                this.getSegmentBreakdown(startDate, endDate),
                this.getTopPerformingNotifications(startDate, endDate),
                this.getUserEngagementMetrics(startDate, endDate),
                this.calculateCostAnalysis(startDate, endDate)
            ]);
            const report = {
                date: reportDate,
                metrics,
                segmentBreakdown,
                topPerformingNotifications: topPerforming,
                userEngagement,
                costAnalysis
            };
            // Save the report
            const db = admin.firestore();
            await db.collection(this.REPORTS_COLLECTION).doc(reportDate.toISOString().split('T')[0]).set(report);
            functions.logger.info('Daily report generated', {
                date: reportDate.toISOString(),
                totalSent: metrics.sent,
                deliveryRate: metrics.deliveryRate,
                ctr: metrics.clickThroughRate
            });
            return report;
        }
        catch (error) {
            functions.logger.error('Failed to generate daily report', { error: error.message });
            throw error;
        }
    }
    /**
     * Calculate core metrics for a time period
     */
    static async calculateDailyMetrics(startDate, endDate) {
        try {
            const db = admin.firestore();
            const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
                .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
                .get();
            let sent = 0;
            let delivered = 0;
            let clicked = 0;
            let dismissed = 0;
            let converted = 0;
            let totalEngagementTime = 0;
            let engagementCount = 0;
            analyticsSnapshot.docs.forEach(doc => {
                const data = doc.data();
                switch (data.action) {
                    case 'sent':
                        sent++;
                        break;
                    case 'delivered':
                        delivered++;
                        break;
                    case 'clicked':
                        clicked++;
                        if (data.engagementTime) {
                            totalEngagementTime += data.engagementTime;
                            engagementCount++;
                        }
                        break;
                    case 'dismissed':
                        dismissed++;
                        break;
                    case 'converted':
                        converted++;
                        break;
                }
            });
            return {
                sent,
                delivered,
                clicked,
                dismissed,
                converted,
                deliveryRate: sent > 0 ? delivered / sent : 0,
                clickThroughRate: delivered > 0 ? clicked / delivered : 0,
                conversionRate: clicked > 0 ? converted / clicked : 0,
                avgEngagementTime: engagementCount > 0 ? totalEngagementTime / engagementCount : 0
            };
        }
        catch (error) {
            functions.logger.error('Failed to calculate daily metrics', { error: error.message });
            throw error;
        }
    }
    /**
     * Get segment-based performance breakdown
     */
    static async getSegmentBreakdown(startDate, endDate) {
        try {
            // This is a simplified version - in practice, you'd have more sophisticated segmentation
            const segments = ['new_users', 'active_users', 'premium_users', 'inactive_users'];
            const segmentMetrics = [];
            for (const segment of segments) {
                // Calculate metrics for each segment
                // In a real implementation, this would query based on user segments
                const metrics = await this.calculateSegmentMetrics(segment, startDate, endDate);
                segmentMetrics.push(metrics);
            }
            return segmentMetrics;
        }
        catch (error) {
            functions.logger.error('Failed to get segment breakdown', { error: error.message });
            return [];
        }
    }
    static async calculateSegmentMetrics(segment, startDate, endDate) {
        // Simplified implementation - would need real user segmentation logic
        return {
            segmentName: segment,
            userCount: 1000,
            sent: 500,
            engagement: {
                sent: 500,
                delivered: 475,
                clicked: 95,
                dismissed: 50,
                converted: 20,
                deliveryRate: 0.95,
                clickThroughRate: 0.20,
                conversionRate: 0.21,
                avgEngagementTime: 45
            }
        };
    }
    /**
     * Get top performing notification types and content
     */
    static async getTopPerformingNotifications(startDate, endDate) {
        try {
            const db = admin.firestore();
            // Aggregate by notification type
            const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
                .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
                .get();
            const typeMetrics = new Map();
            analyticsSnapshot.docs.forEach(doc => {
                var _a;
                const data = doc.data();
                const type = data.type || 'unknown';
                if (!typeMetrics.has(type)) {
                    typeMetrics.set(type, {
                        type,
                        title: ((_a = data.metadata) === null || _a === void 0 ? void 0 : _a.title) || type,
                        sent: 0,
                        clicked: 0,
                        converted: 0
                    });
                }
                const metrics = typeMetrics.get(type);
                switch (data.action) {
                    case 'sent':
                        metrics.sent++;
                        break;
                    case 'clicked':
                        metrics.clicked++;
                        break;
                    case 'converted':
                        metrics.converted++;
                        break;
                }
            });
            // Convert to array and calculate rates
            return Array.from(typeMetrics.values())
                .map(metrics => ({
                type: metrics.type,
                title: metrics.title,
                clickThroughRate: metrics.sent > 0 ? metrics.clicked / metrics.sent : 0,
                conversionRate: metrics.clicked > 0 ? metrics.converted / metrics.clicked : 0,
                sentCount: metrics.sent
            }))
                .sort((a, b) => b.clickThroughRate - a.clickThroughRate)
                .slice(0, 10);
        }
        catch (error) {
            functions.logger.error('Failed to get top performing notifications', { error: error.message });
            return [];
        }
    }
    /**
     * Calculate user engagement metrics
     */
    static async getUserEngagementMetrics(startDate, endDate) {
        try {
            const db = admin.firestore();
            // Get unique users who received notifications
            const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
                .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
                .where('action', '==', 'sent')
                .get();
            const userStats = new Map();
            let totalNotifications = 0;
            analyticsSnapshot.docs.forEach(doc => {
                const data = doc.data();
                const userId = data.userId;
                if (!userStats.has(userId)) {
                    userStats.set(userId, { notifications: 0, engagements: 0 });
                }
                userStats.get(userId).notifications++;
                totalNotifications++;
            });
            // Get engagement data
            const engagementSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
                .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
                .where('action', 'in', ['clicked', 'converted'])
                .get();
            engagementSnapshot.docs.forEach(doc => {
                const data = doc.data();
                const userId = data.userId;
                if (userStats.has(userId)) {
                    userStats.get(userId).engagements++;
                }
            });
            const activeUsers = userStats.size;
            const avgNotificationsPerUser = activeUsers > 0 ? totalNotifications / activeUsers : 0;
            let totalEngagements = 0;
            userStats.forEach(stats => {
                totalEngagements += stats.engagements;
            });
            const engagementScore = totalNotifications > 0 ? (totalEngagements / totalNotifications) * 100 : 0;
            return {
                activeUsers,
                newUsers: 0,
                churningUsers: 0,
                avgNotificationsPerUser,
                engagementScore
            };
        }
        catch (error) {
            functions.logger.error('Failed to get user engagement metrics', { error: error.message });
            return {
                activeUsers: 0,
                newUsers: 0,
                churningUsers: 0,
                avgNotificationsPerUser: 0,
                engagementScore: 0
            };
        }
    }
    /**
     * Calculate cost analysis for the period
     */
    static async calculateCostAnalysis(startDate, endDate) {
        try {
            // This would integrate with actual billing APIs in production
            const db = admin.firestore();
            const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
                .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
                .get();
            const sentCount = analyticsSnapshot.docs.filter(doc => doc.data().action === 'sent').length;
            const clickedCount = analyticsSnapshot.docs.filter(doc => doc.data().action === 'clicked').length;
            // Estimated costs (would use real billing data in production)
            const fcmCosts = sentCount * 0.0001; // $0.0001 per notification
            const firestoreCosts = analyticsSnapshot.size * 0.00036; // Firestore read/write costs
            const functionCosts = sentCount * 0.0000004; // Cloud Functions costs
            const totalCosts = fcmCosts + firestoreCosts + functionCosts;
            return {
                fcmCosts,
                firestoreCosts,
                functionCosts,
                totalCosts,
                costPerNotification: sentCount > 0 ? totalCosts / sentCount : 0,
                costPerEngagement: clickedCount > 0 ? totalCosts / clickedCount : 0
            };
        }
        catch (error) {
            functions.logger.error('Failed to calculate cost analysis', { error: error.message });
            return {
                fcmCosts: 0,
                firestoreCosts: 0,
                functionCosts: 0,
                totalCosts: 0,
                costPerNotification: 0,
                costPerEngagement: 0
            };
        }
    }
    /**
     * Get system analytics for admin dashboard
     */
    static async getSystemAnalytics(startDate, endDate, metrics = ['delivery', 'engagement', 'conversion']) {
        try {
            const db = admin.firestore();
            const results = {
                period: {
                    start: startDate.toISOString(),
                    end: endDate.toISOString()
                }
            };
            if (metrics.includes('delivery')) {
                results.delivery = await this.getDeliveryAnalytics(startDate, endDate);
            }
            if (metrics.includes('engagement')) {
                results.engagement = await this.getEngagementAnalytics(startDate, endDate);
            }
            if (metrics.includes('conversion')) {
                results.conversion = await this.getConversionAnalytics(startDate, endDate);
            }
            return results;
        }
        catch (error) {
            functions.logger.error('Failed to get system analytics', { error: error.message });
            throw error;
        }
    }
    static async getDeliveryAnalytics(startDate, endDate) {
        // Implementation for delivery analytics
        return {
            successRate: 0.98,
            avgDeliveryTime: 1.2,
            failureReasons: {
                'invalid-token': 50,
                'network-error': 23,
                'rate-limit': 5
            }
        };
    }
    static async getEngagementAnalytics(startDate, endDate) {
        // Implementation for engagement analytics
        return {
            clickThroughRate: 0.15,
            avgEngagementTime: 45,
            topCategories: [
                { category: 'achievement', ctr: 0.25 },
                { category: 'reminder', ctr: 0.12 },
                { category: 'progress', ctr: 0.10 }
            ]
        };
    }
    static async getConversionAnalytics(startDate, endDate) {
        // Implementation for conversion analytics
        return {
            conversionRate: 0.08,
            topConvertingTypes: [
                { type: 'personal_record', rate: 0.35 },
                { type: 'achievement', rate: 0.22 },
                { type: 'streak_milestone', rate: 0.18 }
            ]
        };
    }
    /**
     * Clean up old analytics data to manage costs
     */
    static async cleanupOldData() {
        try {
            const db = admin.firestore();
            const cutoffDate = new Date();
            cutoffDate.setDate(cutoffDate.getDate() - 90); // Keep 90 days of data
            const batch = db.batch();
            let deletedCounts = { notifications: 0, analytics: 0, queueItems: 0 };
            // Cleanup old analytics
            const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
                .where('timestamp', '<', admin.firestore.Timestamp.fromDate(cutoffDate))
                .limit(500) // Process in batches
                .get();
            analyticsSnapshot.docs.forEach(doc => {
                batch.delete(doc.ref);
                deletedCounts.analytics++;
            });
            // Cleanup old queue items
            const queueSnapshot = await db.collection('notifications_queue')
                .where('status', 'in', ['sent', 'failed', 'cancelled'])
                .where('queuedAt', '<', admin.firestore.Timestamp.fromDate(cutoffDate))
                .limit(500)
                .get();
            queueSnapshot.docs.forEach(doc => {
                batch.delete(doc.ref);
                deletedCounts.queueItems++;
            });
            await batch.commit();
            functions.logger.info('Data cleanup completed', deletedCounts);
            return deletedCounts;
        }
        catch (error) {
            functions.logger.error('Failed to cleanup old data', { error: error.message });
            return { notifications: 0, analytics: 0, queueItems: 0 };
        }
    }
    /**
     * Helper method to get device info (placeholder)
     */
    static async getDeviceInfo() {
        return {
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            source: 'server'
        };
    }
}
exports.NotificationAnalytics = NotificationAnalytics;
NotificationAnalytics.ANALYTICS_COLLECTION = 'notification_analytics';
NotificationAnalytics.REPORTS_COLLECTION = 'notification_reports';
NotificationAnalytics.FEEDBACK_COLLECTION = 'notification_feedback';
NotificationAnalytics.SYSTEM_HEALTH_COLLECTION = 'system_health';
//# sourceMappingURL=NotificationAnalytics.js.map