"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchRevenueCatSubscriber = fetchRevenueCatSubscriber;
exports.buildEntitlementSnapshotFromRevenueCat = buildEntitlementSnapshotFromRevenueCat;
async function fetchRevenueCatSubscriber(userId, secretApiKey) {
    const response = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`, {
        headers: {
            Authorization: `Bearer ${secretApiKey}`,
            'Content-Type': 'application/json',
        },
        signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) {
        const responseText = await response.text();
        throw new Error(`RevenueCat returned ${response.status}: ${responseText.slice(0, 500)}`);
    }
    return (await response.json());
}
function buildEntitlementSnapshotFromRevenueCat(payload, entitlementId) {
    var _a, _b, _c, _d, _e, _f;
    const entitlement = (_b = (_a = payload.subscriber) === null || _a === void 0 ? void 0 : _a.entitlements) === null || _b === void 0 ? void 0 : _b[entitlementId];
    if (!entitlement) {
        return {
            accountTier: 'free',
            expiresAt: null,
            isLifetime: false,
            willRenew: false,
            productId: null,
            lastPurchasePlatform: null,
        };
    }
    const expiresAt = parseDate(entitlement.expires_date);
    const isLifetime = expiresAt == null;
    const isActive = isLifetime || expiresAt.getTime() > Date.now();
    const productId = (_c = entitlement.product_identifier) !== null && _c !== void 0 ? _c : null;
    const subscription = productId
        ? (_e = (_d = payload.subscriber) === null || _d === void 0 ? void 0 : _d.subscriptions) === null || _e === void 0 ? void 0 : _e[productId]
        : undefined;
    return {
        accountTier: isActive ? 'premium' : 'free',
        expiresAt,
        isLifetime,
        willRenew: isActive &&
            !isLifetime &&
            !(subscription === null || subscription === void 0 ? void 0 : subscription.unsubscribe_detected_at) &&
            !(subscription === null || subscription === void 0 ? void 0 : subscription.billing_issues_detected_at),
        productId,
        lastPurchasePlatform: (_f = subscription === null || subscription === void 0 ? void 0 : subscription.store) !== null && _f !== void 0 ? _f : null,
    };
}
function parseDate(value) {
    if (!value) {
        return null;
    }
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
}
//# sourceMappingURL=revenueCat.js.map