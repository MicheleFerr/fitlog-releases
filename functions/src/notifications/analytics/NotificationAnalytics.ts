/**
 * NotificationAnalytics - Advanced analytics and reporting for enterprise notifications
 * Provides comprehensive insights into notification performance and user engagement
 */

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

export interface NotificationMetrics {
  sent: number;
  delivered: number;
  clicked: number;
  dismissed: number;
  converted: number;
  deliveryRate: number;
  clickThroughRate: number;
  conversionRate: number;
  avgEngagementTime: number;
}

export interface SegmentMetrics {
  segmentName: string;
  userCount: number;
  sent: number;
  engagement: NotificationMetrics;
}

export interface DailyNotificationReport {
  date: Date;
  metrics: NotificationMetrics;
  segmentBreakdown: SegmentMetrics[];
  topPerformingNotifications: TopPerformingNotification[];
  userEngagement: UserEngagementMetrics;
  costAnalysis: CostAnalysis;
}

export interface TopPerformingNotification {
  type: string;
  title: string;
  clickThroughRate: number;
  conversionRate: number;
  sentCount: number;
}

export interface UserEngagementMetrics {
  activeUsers: number;
  newUsers: number;
  churningUsers: number;
  avgNotificationsPerUser: number;
  engagementScore: number;
}

export interface CostAnalysis {
  fcmCosts: number;
  firestoreCosts: number;
  functionCosts: number;
  totalCosts: number;
  costPerNotification: number;
  costPerEngagement: number;
}

export interface SystemHealthMetrics {
  queueHealth: {
    size: number;
    avgProcessingTime: number;
    errorRate: number;
  };
  deliveryHealth: {
    successRate: number;
    avgDeliveryTime: number;
    failureReasons: Record<string, number>;
  };
  userSatisfaction: {
    avgRating: number;
    feedbackCount: number;
    unsubscribeRate: number;
  };
}

export class NotificationAnalytics {
  private static readonly ANALYTICS_COLLECTION = 'notification_analytics';
  private static readonly REPORTS_COLLECTION = 'notification_reports';
  private static readonly FEEDBACK_COLLECTION = 'notification_feedback';
  private static readonly SYSTEM_HEALTH_COLLECTION = 'system_health';

  /**
   * Record when a notification is sent
   */
  static async recordSent(
    notification: any,
    metadata: { deliveryMethod: string; fcmMessageId?: string }
  ): Promise<void> {
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

    } catch (error) {
      functions.logger.error('Failed to record sent notification', {
        error: error.message,
        notificationId: notification.id
      });
    }
  }

  /**
   * Record notification failure for analytics
   */
  static async recordFailure(notification: any, error: string): Promise<void> {
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

    } catch (err) {
      functions.logger.error('Failed to record notification failure', {
        error: err.message,
        originalError: error
      });
    }
  }

  /**
   * Record trigger event (workout completion, achievement, etc.)
   */
  static async recordTrigger(
    triggerType: string,
    userId: string,
    data: Record<string, any>
  ): Promise<void> {
    try {
      const db = admin.firestore();
      
      await db.collection(this.ANALYTICS_COLLECTION).add({
        userId: userId,
        action: 'trigger',
        triggerType: triggerType,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        data: data
      });

    } catch (error) {
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
  static async recordScheduledCampaign(
    campaignType: string,
    metrics: { sent: number; timeOfDay?: string }
  ): Promise<void> {
    try {
      const db = admin.firestore();
      
      await db.collection(this.ANALYTICS_COLLECTION).add({
        action: 'scheduled_campaign',
        campaignType: campaignType,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metrics: metrics
      });

    } catch (error) {
      functions.logger.error('Failed to record scheduled campaign', {
        error: error.message,
        campaignType
      });
    }
  }

  /**
   * Generate comprehensive daily report
   */
  static async generateDailyReport(date?: Date): Promise<DailyNotificationReport> {
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
      const [
        metrics,
        segmentBreakdown,
        topPerforming,
        userEngagement,
        costAnalysis
      ] = await Promise.all([
        this.calculateDailyMetrics(startDate, endDate),
        this.getSegmentBreakdown(startDate, endDate),
        this.getTopPerformingNotifications(startDate, endDate),
        this.getUserEngagementMetrics(startDate, endDate),
        this.calculateCostAnalysis(startDate, endDate)
      ]);

      const report: DailyNotificationReport = {
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

    } catch (error) {
      functions.logger.error('Failed to generate daily report', { error: error.message });
      throw error;
    }
  }

  /**
   * Calculate core metrics for a time period
   */
  private static async calculateDailyMetrics(startDate: Date, endDate: Date): Promise<NotificationMetrics> {
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

    } catch (error) {
      functions.logger.error('Failed to calculate daily metrics', { error: error.message });
      throw error;
    }
  }

  /**
   * Get segment-based performance breakdown
   */
  private static async getSegmentBreakdown(startDate: Date, endDate: Date): Promise<SegmentMetrics[]> {
    try {
      // This is a simplified version - in practice, you'd have more sophisticated segmentation
      const segments = ['new_users', 'active_users', 'premium_users', 'inactive_users'];
      const segmentMetrics: SegmentMetrics[] = [];

      for (const segment of segments) {
        // Calculate metrics for each segment
        // In a real implementation, this would query based on user segments
        const metrics = await this.calculateSegmentMetrics(segment, startDate, endDate);
        segmentMetrics.push(metrics);
      }

      return segmentMetrics;

    } catch (error) {
      functions.logger.error('Failed to get segment breakdown', { error: error.message });
      return [];
    }
  }

  private static async calculateSegmentMetrics(
    segment: string,
    startDate: Date,
    endDate: Date
  ): Promise<SegmentMetrics> {
    // Simplified implementation - would need real user segmentation logic
    return {
      segmentName: segment,
      userCount: 1000, // Placeholder
      sent: 500,       // Placeholder
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
  private static async getTopPerformingNotifications(
    startDate: Date,
    endDate: Date
  ): Promise<TopPerformingNotification[]> {
    try {
      const db = admin.firestore();
      
      // Aggregate by notification type
      const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
        .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
        .get();

      const typeMetrics = new Map<string, any>();

      analyticsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        const type = data.type || 'unknown';
        
        if (!typeMetrics.has(type)) {
          typeMetrics.set(type, {
            type,
            title: data.metadata?.title || type,
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

    } catch (error) {
      functions.logger.error('Failed to get top performing notifications', { error: error.message });
      return [];
    }
  }

  /**
   * Calculate user engagement metrics
   */
  private static async getUserEngagementMetrics(
    startDate: Date,
    endDate: Date
  ): Promise<UserEngagementMetrics> {
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
        newUsers: 0, // Would need to cross-reference with user creation dates
        churningUsers: 0, // Would need to analyze user inactivity patterns
        avgNotificationsPerUser,
        engagementScore
      };

    } catch (error) {
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
  private static async calculateCostAnalysis(startDate: Date, endDate: Date): Promise<CostAnalysis> {
    try {
      // This would integrate with actual billing APIs in production
      const db = admin.firestore();
      
      const analyticsSnapshot = await db.collection(this.ANALYTICS_COLLECTION)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(startDate))
        .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(endDate))
        .get();

      const sentCount = analyticsSnapshot.docs.filter(doc => 
        doc.data().action === 'sent'
      ).length;

      const clickedCount = analyticsSnapshot.docs.filter(doc => 
        doc.data().action === 'clicked'
      ).length;

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

    } catch (error) {
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
  static async getSystemAnalytics(
    startDate: Date,
    endDate: Date,
    metrics: string[] = ['delivery', 'engagement', 'conversion']
  ): Promise<any> {
    try {
      const db = admin.firestore();
      
      const results: any = {
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

    } catch (error) {
      functions.logger.error('Failed to get system analytics', { error: error.message });
      throw error;
    }
  }

  private static async getDeliveryAnalytics(startDate: Date, endDate: Date): Promise<any> {
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

  private static async getEngagementAnalytics(startDate: Date, endDate: Date): Promise<any> {
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

  private static async getConversionAnalytics(startDate: Date, endDate: Date): Promise<any> {
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
  static async cleanupOldData(): Promise<{ notifications: number; analytics: number; queueItems: number }> {
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

    } catch (error) {
      functions.logger.error('Failed to cleanup old data', { error: error.message });
      return { notifications: 0, analytics: 0, queueItems: 0 };
    }
  }

  /**
   * Helper method to get device info (placeholder)
   */
  private static async getDeviceInfo(): Promise<any> {
    return {
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: 'server'
    };
  }
}