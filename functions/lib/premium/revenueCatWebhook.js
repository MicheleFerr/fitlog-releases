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
exports.revenueCatWebhook = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const entitlements_1 = require("./entitlements");
const revenueCat_1 = require("./revenueCat");
const WEBHOOK_EVENTS_COLLECTION = 'revenuecat_webhook_events';
const USERS_COLLECTION = 'users';
const USER_ENTITLEMENTS_COLLECTION = 'user_entitlements';
exports.revenueCatWebhook = (0, https_1.onRequest)({
    secrets: ['REVENUECAT_SECRET_API_KEY', 'REVENUECAT_WEBHOOK_AUTH_TOKEN'],
    timeoutSeconds: 20,
}, async (req, res) => {
    var _a, _b;
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
    const eventType = (_a = asString(event['type'])) !== null && _a !== void 0 ? _a : 'unknown';
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
        const subscriber = await (0, revenueCat_1.fetchRevenueCatSubscriber)(targetUserId, secretApiKey);
        const entitlementId = (_b = process.env.REVENUECAT_PREMIUM_ENTITLEMENT_ID) !== null && _b !== void 0 ? _b : 'premium';
        const snapshot = (0, revenueCat_1.buildEntitlementSnapshotFromRevenueCat)(subscriber, entitlementId);
        const synced = await (0, entitlements_1.applyPremiumEntitlements)(targetUserId, {
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
    }
    catch (error) {
        console.error('RevenueCat webhook processing failed:', {
            eventId,
            eventType,
            error: error instanceof Error ? error.message : String(error),
        });
        res.status(500).json({ ok: false, error: 'Webhook processing failed' });
    }
});
async function hasProcessedWebhookEvent(eventId) {
    const snapshot = await admin
        .firestore()
        .collection(WEBHOOK_EVENTS_COLLECTION)
        .doc(eventId)
        .get();
    return snapshot.exists;
}
async function recordWebhookEvent(eventId, data) {
    await admin
        .firestore()
        .collection(WEBHOOK_EVENTS_COLLECTION)
        .doc(eventId)
        .set(Object.assign(Object.assign({}, data), { processedAt: admin.firestore.FieldValue.serverTimestamp() }));
}
async function resolveTargetUserId(event) {
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
function collectCandidateUserIds(event) {
    const aliasValues = event['aliases'];
    const aliases = Array.isArray(aliasValues)
        ? aliasValues.filter((alias) => typeof alias === 'string')
        : [];
    const candidates = [
        asString(event['app_user_id']),
        asString(event['original_app_user_id']),
        ...aliases,
    ]
        .filter((candidate) => Boolean(candidate))
        .map((candidate) => candidate.trim())
        .filter((candidate) => candidate.length > 0 && !candidate.startsWith('$RCAnonymousID:'));
    return Array.from(new Set(candidates));
}
function isAuthorized(authorizationHeader, expectedToken) {
    if (!authorizationHeader) {
        return false;
    }
    return authorizationHeader == expectedToken ||
        authorizationHeader == `Bearer ${expectedToken}`;
}
function parseWebhookPayload(body) {
    if (typeof body === 'string') {
        try {
            return JSON.parse(body);
        }
        catch (_a) {
            return {};
        }
    }
    if (body != null && typeof body === 'object' && !Array.isArray(body)) {
        return body;
    }
    return {};
}
function toRecord(value) {
    if (value != null && typeof value === 'object' && !Array.isArray(value)) {
        return value;
    }
    return null;
}
function asString(value) {
    return typeof value === 'string' && value.length > 0 ? value : null;
}
//# sourceMappingURL=revenueCatWebhook.js.map