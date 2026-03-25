import { HttpsError } from 'firebase-functions/v2/https';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';
import {
  applyPremiumEntitlements,
  PremiumEntitlementSnapshot,
} from './entitlements';
import {
  buildEntitlementSnapshotFromRevenueCat,
  fetchRevenueCatSubscriber,
  RevenueCatSubscriberResponse,
} from './revenueCat';

export const syncRevenueCatEntitlements = withRateLimit(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const requestedUserId =
      request.data && typeof request.data === 'object'
        ? (request.data as Record<string, unknown>)['userId']
        : null;
    if (
      requestedUserId != null &&
      requestedUserId !== request.auth.uid
    ) {
      throw new HttpsError('permission-denied', 'User ID mismatch.');
    }

    const secretApiKey = process.env.REVENUECAT_SECRET_API_KEY;
    if (!secretApiKey) {
      throw new HttpsError(
        'failed-precondition',
        'REVENUECAT_SECRET_API_KEY is not configured on backend.',
      );
    }

    const entitlementId =
      process.env.REVENUECAT_PREMIUM_ENTITLEMENT_ID ?? 'premium';

    let subscriberResponse: RevenueCatSubscriberResponse;
    try {
      subscriberResponse = await fetchRevenueCatSubscriber(
        request.auth.uid,
        secretApiKey,
      );
    } catch (error) {
      console.error('RevenueCat entitlement sync failed:', error);
      throw new HttpsError(
        'unavailable',
        'Unable to sync premium entitlements right now.',
      );
    }

    const snapshot = buildEntitlementSnapshotFromRevenueCat(
      subscriberResponse,
      entitlementId,
    );
    const syncedEntitlements = await applyPremiumEntitlements(
      request.auth.uid,
      {
        accountTier: snapshot.accountTier,
        source: 'revenuecat',
        expiresAt: snapshot.expiresAt,
        willRenew: snapshot.willRenew,
        isLifetime: snapshot.isLifetime,
        productId: snapshot.productId,
        lastPurchasePlatform: snapshot.lastPurchasePlatform,
        lastPurchaseProductId: snapshot.productId,
      },
    );

    return serializeSnapshot(syncedEntitlements);
  },
  {
    ...RATE_LIMITS.STANDARD,
    identifier: 'syncRevenueCatEntitlements',
    trackBy: 'user',
    secrets: ['REVENUECAT_SECRET_API_KEY'],
    timeoutSeconds: 20,
  },
);

function serializeSnapshot(snapshot: PremiumEntitlementSnapshot) {
  return {
    accountTier: snapshot.accountTier,
    premiumActive: snapshot.premiumActive,
    plan: snapshot.plan,
    expiresAt: snapshot.expiresAt?.toISOString() ?? null,
    willRenew: snapshot.willRenew,
    isLifetime: snapshot.isLifetime,
    productId: snapshot.productId,
    source: snapshot.source,
  };
}
