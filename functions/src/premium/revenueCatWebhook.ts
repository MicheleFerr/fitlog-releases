import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  applyPremiumEntitlements,
} from './entitlements';
import {
  buildEntitlementSnapshotFromRevenueCat,
  fetchRevenueCatSubscriber,
} from './revenueCat';

const WEBHOOK_EVENTS_COLLECTION = 'revenuecat_webhook_events';
const USERS_COLLECTION = 'users';
const USER_ENTITLEMENTS_COLLECTION = 'user_entitlements';

export const revenueCatWebhook = onRequest(
  {
    secrets: ['REVENUECAT_SECRET_API_KEY', 'REVENUECAT_WEBHOOK_AUTH_TOKEN'],
    timeoutSeconds: 20,
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ ok: false, error: 'Method not allowed' });
      return;
    }

    const expectedToken = process.env.REVENUECAT_WEBHOOK_AUTH_TOKEN;
    if (!expectedToken) {
      console.error('REVENUECAT_WEBHOOK_AUTH_TOKEN is not configured.');
      res.status(503).json({ ok: false, error: 'Webhook not configured' });
      return;
    }

    const authorizationHeader = Array.isArray(req.headers.authorization)
      ? req.headers.authorization[0]
      : req.headers.authorization;

    if (!isAuthorized(authorizationHeader, expectedToken)) {
      console.warn('RevenueCat webhook rejected due to invalid auth header.', {
        ip: req.ip,
      });
      res.status(401).json({ ok: false, error: 'Unauthorized' });
      return;
    }

    const secretApiKey = process.env.REVENUECAT_SECRET_API_KEY;
    if (!secretApiKey) {
      console.error('REVENUECAT_SECRET_API_KEY is not configured.');
      res.status(503).json({ ok: false, error: 'RevenueCat API not configured' });
      return;
    }

    const payload = parseWebhookPayload(req.body);
    const event = toRecord(payload['event']);
    if (!event) {
      res.status(400).json({ ok: false, error: 'Missing event payload' });
      return;
    }

    const eventId = asString(event['id']);
    const eventType = asString(event['type']) ?? 'unknown';
    if (!eventId) {
      res.status(400).json({ ok: false, error: 'Missing event.id' });
      return;
    }

    const alreadyProcessed = await hasProcessedWebhookEvent(eventId);
    if (alreadyProcessed) {
      res.status(200).json({ ok: true, duplicate: true });
      return;
    }

    const targetUserId = await resolveTargetUserId(event);
    if (!targetUserId) {
      console.warn('RevenueCat webhook skipped: no mapped Firebase user ID.', {
        eventId,
        eventType,
      });
      await recordWebhookEvent(eventId, {
        eventType,
        status: 'skipped_unmapped_user',
      });
      res.status(202).json({ ok: true, skipped: 'unmapped_user' });
      return;
    }

    try {
      const subscriber = await fetchRevenueCatSubscriber(
        targetUserId,
        secretApiKey,
      );
      const entitlementId =
        process.env.REVENUECAT_PREMIUM_ENTITLEMENT_ID ?? 'premium';
      const snapshot = buildEntitlementSnapshotFromRevenueCat(
        subscriber,
        entitlementId,
      );

      const synced = await applyPremiumEntitlements(targetUserId, {
        accountTier: snapshot.accountTier,
        source: 'revenuecat',
        expiresAt: snapshot.expiresAt,
        willRenew: snapshot.willRenew,
        isLifetime: snapshot.isLifetime,
        productId: snapshot.productId,
        lastPurchasePlatform: snapshot.lastPurchasePlatform,
        lastPurchaseProductId: snapshot.productId,
      });

      await recordWebhookEvent(eventId, {
        eventType,
        status: 'processed',
        userId: targetUserId,
        accountTier: synced.accountTier,
      });

      res.status(200).json({
        ok: true,
        eventType,
        userId: targetUserId,
        accountTier: synced.accountTier,
      });
    } catch (error) {
      console.error('RevenueCat webhook processing failed:', {
        eventId,
        eventType,
        error: error instanceof Error ? error.message : String(error),
      });
      res.status(500).json({ ok: false, error: 'Webhook processing failed' });
    }
  },
);

async function hasProcessedWebhookEvent(eventId: string): Promise<boolean> {
  const snapshot = await admin
    .firestore()
    .collection(WEBHOOK_EVENTS_COLLECTION)
    .doc(eventId)
    .get();
  return snapshot.exists;
}

async function recordWebhookEvent(
  eventId: string,
  data: Record<string, unknown>,
): Promise<void> {
  await admin
    .firestore()
    .collection(WEBHOOK_EVENTS_COLLECTION)
    .doc(eventId)
    .set({
      ...data,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

async function resolveTargetUserId(
  event: Record<string, unknown>,
): Promise<string | null> {
  const candidateIds = collectCandidateUserIds(event);
  if (candidateIds.length === 0) {
    return null;
  }

  const db = admin.firestore();

  for (const candidateId of candidateIds) {
    const [userDoc, entitlementDoc] = await Promise.all([
      db.collection(USERS_COLLECTION).doc(candidateId).get(),
      db.collection(USER_ENTITLEMENTS_COLLECTION).doc(candidateId).get(),
    ]);
    if (userDoc.exists || entitlementDoc.exists) {
      return candidateId;
    }
  }

  return candidateIds.length === 1 ? candidateIds[0] : null;
}

function collectCandidateUserIds(
  event: Record<string, unknown>,
): string[] {
  const aliasValues = event['aliases'];
  const aliases = Array.isArray(aliasValues)
    ? aliasValues.filter((alias): alias is string => typeof alias === 'string')
    : [];

  const candidates = [
    asString(event['app_user_id']),
    asString(event['original_app_user_id']),
    ...aliases,
  ]
    .filter((candidate): candidate is string => Boolean(candidate))
    .map((candidate) => candidate.trim())
    .filter(
      (candidate) =>
        candidate.length > 0 && !candidate.startsWith('$RCAnonymousID:'),
    );

  return Array.from(new Set(candidates));
}

function isAuthorized(
  authorizationHeader: string | undefined,
  expectedToken: string,
): boolean {
  if (!authorizationHeader) {
    return false;
  }

  return authorizationHeader == expectedToken ||
    authorizationHeader == `Bearer ${expectedToken}`;
}

function parseWebhookPayload(body: unknown): Record<string, unknown> {
  if (typeof body === 'string') {
    try {
      return JSON.parse(body) as Record<string, unknown>;
    } catch {
      return {};
    }
  }

  if (body != null && typeof body === 'object' && !Array.isArray(body)) {
    return body as Record<string, unknown>;
  }

  return {};
}

function toRecord(value: unknown): Record<string, unknown> | null {
  if (value != null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }

  return null;
}

function asString(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 ? value : null;
}
