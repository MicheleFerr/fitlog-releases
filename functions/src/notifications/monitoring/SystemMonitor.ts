import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

interface ProcessingMetrics {
  processed: number;
  timestamp: admin.firestore.Timestamp;
}

interface AlertPayload {
  type: string;
  message: string;
  severity: 'medium' | 'high' | 'critical';
  data?: unknown;
}

interface SystemHealthReport {
  status: 'healthy' | 'warning' | 'critical';
  queueSize: number;
  queuedOver15Minutes: number;
  recentFailures: number;
  alertsLastHour: number;
}

export class SystemMonitor {
  private static readonly METRICS_COLLECTION = 'notification_system_metrics';
  private static readonly ALERTS_COLLECTION = 'notification_system_alerts';
  private static readonly QUEUE_COLLECTION = 'notifications_queue';
  private static readonly ANALYTICS_COLLECTION = 'notification_analytics';

  static async recordProcessingMetrics(metrics: ProcessingMetrics): Promise<void> {
    await admin.firestore().collection(this.METRICS_COLLECTION).add({
      ...metrics,
      recordedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  static async triggerAlert(payload: AlertPayload): Promise<void> {
    await admin.firestore().collection(this.ALERTS_COLLECTION).add({
      ...payload,
      triggeredAt: admin.firestore.FieldValue.serverTimestamp(),
      acknowledged: false,
    });

    functions.logger.warn('Notification system alert', payload);
  }

  static async checkSystemHealth(): Promise<SystemHealthReport> {
    const db = admin.firestore();
    const now = new Date();
    const fifteenMinutesAgo = new Date(now.getTime() - 15 * 60 * 1000);
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

    const [queueSnapshot, staleQueueSnapshot, failuresSnapshot, alertsSnapshot] =
      await Promise.all([
        db.collection(this.QUEUE_COLLECTION).where('status', '==', 'queued').get(),
        db
          .collection(this.QUEUE_COLLECTION)
          .where('status', '==', 'queued')
          .where(
            'queuedAt',
            '<=',
            admin.firestore.Timestamp.fromDate(fifteenMinutesAgo)
          )
          .get(),
        db
          .collection(this.ANALYTICS_COLLECTION)
          .where('action', '==', 'failed')
          .where(
            'timestamp',
            '>=',
            admin.firestore.Timestamp.fromDate(oneHourAgo)
          )
          .get(),
        db
          .collection(this.ALERTS_COLLECTION)
          .where(
            'triggeredAt',
            '>=',
            admin.firestore.Timestamp.fromDate(oneHourAgo)
          )
          .get(),
      ]);

    let status: SystemHealthReport['status'] = 'healthy';
    if (staleQueueSnapshot.size > 25 || failuresSnapshot.size > 25) {
      status = 'critical';
    } else if (staleQueueSnapshot.size > 0 || failuresSnapshot.size > 5) {
      status = 'warning';
    }

    return {
      status,
      queueSize: queueSnapshot.size,
      queuedOver15Minutes: staleQueueSnapshot.size,
      recentFailures: failuresSnapshot.size,
      alertsLastHour: alertsSnapshot.size,
    };
  }
}
