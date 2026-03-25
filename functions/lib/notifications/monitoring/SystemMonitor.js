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
exports.SystemMonitor = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
class SystemMonitor {
    static async recordProcessingMetrics(metrics) {
        await admin.firestore().collection(this.METRICS_COLLECTION).add(Object.assign(Object.assign({}, metrics), { recordedAt: admin.firestore.FieldValue.serverTimestamp() }));
    }
    static async triggerAlert(payload) {
        await admin.firestore().collection(this.ALERTS_COLLECTION).add(Object.assign(Object.assign({}, payload), { triggeredAt: admin.firestore.FieldValue.serverTimestamp(), acknowledged: false }));
        functions.logger.warn('Notification system alert', payload);
    }
    static async checkSystemHealth() {
        const db = admin.firestore();
        const now = new Date();
        const fifteenMinutesAgo = new Date(now.getTime() - 15 * 60 * 1000);
        const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
        const [queueSnapshot, staleQueueSnapshot, failuresSnapshot, alertsSnapshot] = await Promise.all([
            db.collection(this.QUEUE_COLLECTION).where('status', '==', 'queued').get(),
            db
                .collection(this.QUEUE_COLLECTION)
                .where('status', '==', 'queued')
                .where('queuedAt', '<=', admin.firestore.Timestamp.fromDate(fifteenMinutesAgo))
                .get(),
            db
                .collection(this.ANALYTICS_COLLECTION)
                .where('action', '==', 'failed')
                .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(oneHourAgo))
                .get(),
            db
                .collection(this.ALERTS_COLLECTION)
                .where('triggeredAt', '>=', admin.firestore.Timestamp.fromDate(oneHourAgo))
                .get(),
        ]);
        let status = 'healthy';
        if (staleQueueSnapshot.size > 25 || failuresSnapshot.size > 25) {
            status = 'critical';
        }
        else if (staleQueueSnapshot.size > 0 || failuresSnapshot.size > 5) {
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
exports.SystemMonitor = SystemMonitor;
SystemMonitor.METRICS_COLLECTION = 'notification_system_metrics';
SystemMonitor.ALERTS_COLLECTION = 'notification_system_alerts';
SystemMonitor.QUEUE_COLLECTION = 'notifications_queue';
SystemMonitor.ANALYTICS_COLLECTION = 'notification_analytics';
//# sourceMappingURL=SystemMonitor.js.map