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
exports.NotificationPersonalization = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const NotificationQueue_1 = require("../queue/NotificationQueue");
class NotificationPersonalization {
    static async sendTimedReminders(timeOfDay) {
        var _a;
        const preferences = await this.getEligiblePreferences({
            category: 'reminder',
            requireMarketingOptIn: false,
        });
        let sent = 0;
        for (const preference of preferences) {
            try {
                if (((_a = preference.data.frequency) === null || _a === void 0 ? void 0 : _a.reminders) === 'disabled')
                    continue;
                await NotificationQueue_1.NotificationQueue.enqueue({
                    type: 'workout_reminder',
                    userId: preference.userId,
                    title: timeOfDay === 'morning' ? 'Start strong today' : 'Still time to train',
                    message: timeOfDay === 'morning'
                        ? 'A short session today keeps your streak alive.'
                        : 'Your next workout is waiting. Even a quick session counts.',
                    data: { timeOfDay },
                    priority: 'normal',
                    source: 'system',
                });
                sent++;
            }
            catch (error) {
                functions.logger.error('Failed to enqueue timed reminder', {
                    userId: preference.userId,
                    timeOfDay,
                    error: error instanceof Error ? error.message : String(error),
                });
            }
        }
        return sent;
    }
    static async sendWeekendMotivation() {
        const preferences = await this.getEligiblePreferences({
            category: 'reminder',
            requireMarketingOptIn: false,
        });
        let sent = 0;
        for (const preference of preferences) {
            try {
                await NotificationQueue_1.NotificationQueue.enqueue({
                    type: 'weekend_motivation',
                    userId: preference.userId,
                    title: 'Weekend momentum',
                    message: 'Keep the habit alive this weekend with a light session or recovery work.',
                    data: { campaign: 'weekend_motivation' },
                    priority: 'low',
                    source: 'system',
                });
                sent++;
            }
            catch (error) {
                functions.logger.error('Failed to enqueue weekend motivation', {
                    userId: preference.userId,
                    error: error instanceof Error ? error.message : String(error),
                });
            }
        }
        return sent;
    }
    static async sendMarketingCampaign(campaignId, targetSegment, templateId) {
        const preferences = await this.getEligiblePreferences({
            category: 'marketing',
            requireMarketingOptIn: true,
        });
        let sent = 0;
        let failed = 0;
        for (const preference of preferences) {
            try {
                await NotificationQueue_1.NotificationQueue.enqueue({
                    type: 'marketing_campaign',
                    userId: preference.userId,
                    title: 'New in GymBro',
                    message: 'There is new content available for your training journey.',
                    data: {
                        campaignId,
                        targetSegment,
                        templateId,
                    },
                    priority: 'low',
                    source: 'marketing',
                });
                sent++;
            }
            catch (error) {
                failed++;
                functions.logger.error('Failed to enqueue marketing campaign item', {
                    campaignId,
                    userId: preference.userId,
                    error: error instanceof Error ? error.message : String(error),
                });
            }
        }
        return {
            campaignId,
            targetSegment,
            sent,
            failed,
        };
    }
    static async getEligiblePreferences(options) {
        const db = admin.firestore();
        const snapshot = await db
            .collection(this.PREFERENCES_COLLECTION)
            .limit(this.MAX_RECIPIENTS)
            .get();
        return snapshot.docs
            .map((doc) => ({
            userId: doc.id,
            data: doc.data(),
        }))
            .filter(({ data }) => {
            var _a, _b;
            if (data.pushEnabled === false)
                return false;
            if (((_a = data.categories) === null || _a === void 0 ? void 0 : _a[options.category]) === false)
                return false;
            if (options.requireMarketingOptIn &&
                ((_b = data.frequency) === null || _b === void 0 ? void 0 : _b.marketing) === 'disabled') {
                return false;
            }
            return true;
        });
    }
}
exports.NotificationPersonalization = NotificationPersonalization;
NotificationPersonalization.PREFERENCES_COLLECTION = 'notification_preferences';
NotificationPersonalization.MAX_RECIPIENTS = 500;
//# sourceMappingURL=NotificationPersonalization.js.map