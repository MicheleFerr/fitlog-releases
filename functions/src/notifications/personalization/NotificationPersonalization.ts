import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { NotificationQueue } from '../queue/NotificationQueue';

interface NotificationPreferenceDoc {
  pushEnabled?: boolean;
  categories?: Record<string, boolean>;
  frequency?: {
    reminders?: 'daily' | 'weekly' | 'disabled';
    marketing?: 'enabled' | 'disabled';
  };
}

interface MarketingCampaignResult {
  campaignId: string;
  targetSegment: string;
  sent: number;
  failed: number;
}

export class NotificationPersonalization {
  private static readonly PREFERENCES_COLLECTION = 'notification_preferences';
  private static readonly MAX_RECIPIENTS = 500;

  static async sendTimedReminders(timeOfDay: string): Promise<number> {
    const preferences = await this.getEligiblePreferences({
      category: 'reminder',
      requireMarketingOptIn: false,
    });

    let sent = 0;
    for (const preference of preferences) {
      try {
        if (preference.data.frequency?.reminders === 'disabled') continue;

        await NotificationQueue.enqueue({
          type: 'workout_reminder',
          userId: preference.userId,
          title: timeOfDay === 'morning' ? 'Start strong today' : 'Still time to train',
          message:
            timeOfDay === 'morning'
              ? 'A short session today keeps your streak alive.'
              : 'Your next workout is waiting. Even a quick session counts.',
          data: { timeOfDay },
          priority: 'normal',
          source: 'system',
        });
        sent++;
      } catch (error) {
        functions.logger.error('Failed to enqueue timed reminder', {
          userId: preference.userId,
          timeOfDay,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    return sent;
  }

  static async sendWeekendMotivation(): Promise<number> {
    const preferences = await this.getEligiblePreferences({
      category: 'reminder',
      requireMarketingOptIn: false,
    });

    let sent = 0;
    for (const preference of preferences) {
      try {
        await NotificationQueue.enqueue({
          type: 'weekend_motivation',
          userId: preference.userId,
          title: 'Weekend momentum',
          message: 'Keep the habit alive this weekend with a light session or recovery work.',
          data: { campaign: 'weekend_motivation' },
          priority: 'low',
          source: 'system',
        });
        sent++;
      } catch (error) {
        functions.logger.error('Failed to enqueue weekend motivation', {
          userId: preference.userId,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    return sent;
  }

  static async sendMarketingCampaign(
    campaignId: string,
    targetSegment: string,
    templateId: string
  ): Promise<MarketingCampaignResult> {
    const preferences = await this.getEligiblePreferences({
      category: 'marketing',
      requireMarketingOptIn: true,
    });

    let sent = 0;
    let failed = 0;

    for (const preference of preferences) {
      try {
        await NotificationQueue.enqueue({
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
      } catch (error) {
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

  private static async getEligiblePreferences(options: {
    category: string;
    requireMarketingOptIn: boolean;
  }): Promise<Array<{ userId: string; data: NotificationPreferenceDoc }>> {
    const db = admin.firestore();
    const snapshot = await db
      .collection(this.PREFERENCES_COLLECTION)
      .limit(this.MAX_RECIPIENTS)
      .get();

    return snapshot.docs
      .map((doc) => ({
        userId: doc.id,
        data: doc.data() as NotificationPreferenceDoc,
      }))
      .filter(({ data }) => {
        if (data.pushEnabled === false) return false;
        if (data.categories?.[options.category] === false) return false;
        if (
          options.requireMarketingOptIn &&
          data.frequency?.marketing === 'disabled'
        ) {
          return false;
        }
        return true;
      });
  }
}
