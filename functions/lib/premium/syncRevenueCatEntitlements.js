"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncRevenueCatEntitlements = void 0;
const https_1 = require("firebase-functions/v2/https");
const rateLimiterV1_1 = require("../security/rateLimiterV1");
const entitlements_1 = require("./entitlements");
const revenueCat_1 = require("./revenueCat");
exports.syncRevenueCatEntitlements = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required.');
    }
    const requestedUserId = request.data && typeof request.data === 'object'
        ? request.data['userId']
        : null;
    if (requestedUserId != null &&
        requestedUserId !== request.auth.uid) {
        throw new https_1.HttpsError('permission-denied', 'User ID mismatch.');
    }
    const secretApiKey = process.env.REVENUECAT_SECRET_API_KEY;
    if (!secretApiKey) {
        throw new https_1.HttpsError('failed-precondition', 'REVENUECAT_SECRET_API_KEY is not configured on backend.');
    }
    const entitlementId = (_a = process.env.REVENUECAT_PREMIUM_ENTITLEMENT_ID) !== null && _a !== void 0 ? _a : 'premium';
    let subscriberResponse;
    try {
        subscriberResponse = await (0, revenueCat_1.fetchRevenueCatSubscriber)(request.auth.uid, secretApiKey);
    }
    catch (error) {
        console.error('RevenueCat entitlement sync failed:', error);
        throw new https_1.HttpsError('unavailable', 'Unable to sync premium entitlements right now.');
    }
    const snapshot = (0, revenueCat_1.buildEntitlementSnapshotFromRevenueCat)(subscriberResponse, entitlementId);
    const syncedEntitlements = await (0, entitlements_1.applyPremiumEntitlements)(request.auth.uid, {
        accountTier: snapshot.accountTier,
        source: 'revenuecat',
        expiresAt: snapshot.expiresAt,
        willRenew: snapshot.willRenew,
        isLifetime: snapshot.isLifetime,
        productId: snapshot.productId,
        lastPurchasePlatform: snapshot.lastPurchasePlatform,
        lastPurchaseProductId: snapshot.productId,
    });
    return serializeSnapshot(syncedEntitlements);
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'syncRevenueCatEntitlements', trackBy: 'user', secrets: ['REVENUECAT_SECRET_API_KEY'], timeoutSeconds: 20 }));
function serializeSnapshot(snapshot) {
    var _a, _b;
    return {
        accountTier: snapshot.accountTier,
        premiumActive: snapshot.premiumActive,
        plan: snapshot.plan,
        expiresAt: (_b = (_a = snapshot.expiresAt) === null || _a === void 0 ? void 0 : _a.toISOString()) !== null && _b !== void 0 ? _b : null,
        willRenew: snapshot.willRenew,
        isLifetime: snapshot.isLifetime,
        productId: snapshot.productId,
        source: snapshot.source,
    };
}
//# sourceMappingURL=syncRevenueCatEntitlements.js.map