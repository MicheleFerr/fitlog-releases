"use strict";
/**
 * Cloud Function to verify and activate premium purchases
 * Handles both iOS (App Store) and Android (Google Play) purchases
 */
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
exports.checkExpiredSubscriptions = exports.verifyPremiumPurchase = void 0;
const https_1 = require("firebase-functions/v2/https");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
const appleReceiptVerify = __importStar(require("node-apple-receipt-verify"));
const googleapis_1 = require("googleapis");
const entitlements_1 = require("./entitlements");
// Lazy initialization flag for Apple receipt verification
let appleReceiptConfigured = false;
/**
 * Initialize Apple receipt verification lazily
 * This avoids validation errors when the module loads without config
 */
function ensureAppleReceiptConfigured() {
    if (appleReceiptConfigured)
        return;
    const secret = process.env.APPLE_SHARED_SECRET;
    if (!secret) {
        console.warn('Apple shared_secret not configured. iOS purchase verification will fail.');
        return;
    }
    appleReceiptVerify.config({
        secret,
        environment: ['production', 'sandbox'], // Try both environments
        excludeOldTransactions: true,
        extended: true,
    });
    appleReceiptConfigured = true;
}
/**
 * Verify premium purchase from iOS or Android
 */
exports.verifyPremiumPurchase = (0, https_1.onCall)({ enforceAppCheck: true }, async (request) => {
    var _a;
    // Verify authenticated user
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to verify purchase');
    }
    const { userId, productId, purchaseToken, platform, purchaseId } = request.data;
    // Validate input
    if (!userId || !productId || !purchaseToken || !platform) {
        throw new https_1.HttpsError('invalid-argument', 'Missing required purchase data');
    }
    // Verify the user matches the authenticated user
    if (userId !== request.auth.uid) {
        throw new https_1.HttpsError('permission-denied', 'User ID mismatch');
    }
    try {
        let verified = false;
        let expiryDate = null;
        let purchaseType = 'subscription';
        // Verify based on platform
        if (platform === 'ios') {
            const result = await verifyApplePurchase(purchaseToken, productId);
            verified = result.verified;
            expiryDate = result.expiryDate;
            purchaseType = result.purchaseType;
        }
        else if (platform === 'android') {
            const result = await verifyGooglePurchase(purchaseToken, productId);
            verified = result.verified;
            expiryDate = result.expiryDate;
            purchaseType = result.purchaseType;
        }
        else {
            throw new https_1.HttpsError('invalid-argument', 'Invalid platform specified');
        }
        if (!verified) {
            console.error('Purchase verification failed', { userId, productId, platform });
            return { success: false, error: 'Purchase verification failed' };
        }
        const entitlementSnapshot = await (0, entitlements_1.applyPremiumEntitlements)(userId, {
            accountTier: 'premium',
            source: 'store_verification',
            expiresAt: expiryDate,
            willRenew: purchaseType === 'subscription',
            isLifetime: purchaseType === 'lifetime',
            productId,
            lastPurchaseId: purchaseId !== null && purchaseId !== void 0 ? purchaseId : null,
            lastPurchasePlatform: platform,
            lastPurchaseProductId: productId,
        });
        // Log purchase for analytics
        await admin.firestore().collection('purchases').add({
            userId,
            productId,
            platform,
            purchaseId,
            purchaseType,
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            expiryDate: expiryDate ? admin.firestore.Timestamp.fromDate(expiryDate) : null,
        });
        console.log('Premium activated successfully', { userId, productId, purchaseType });
        return {
            success: true,
            accountTier: entitlementSnapshot.accountTier,
            expiryDate: (_a = entitlementSnapshot.expiresAt) === null || _a === void 0 ? void 0 : _a.toISOString(),
        };
    }
    catch (error) {
        console.error('Purchase verification error:', error);
        throw new https_1.HttpsError('internal', 'Failed to verify purchase', error);
    }
});
/**
 * Verify Apple App Store purchase
 */
async function verifyApplePurchase(receiptData, productId) {
    try {
        // Ensure Apple receipt verification is configured
        ensureAppleReceiptConfigured();
        // Verify receipt with Apple
        const products = await appleReceiptVerify.validate({
            receipt: receiptData,
        });
        // Find the specific product
        const product = products.find((p) => p.productId === productId);
        if (!product) {
            console.error('Product not found in receipt', { productId });
            return { verified: false, expiryDate: null, purchaseType: 'subscription' };
        }
        // Check if it's a lifetime purchase
        const isLifetime = productId.includes('lifetime');
        // For subscriptions, check expiry
        let expiryDate = null;
        if (!isLifetime && product.expiresDate) {
            expiryDate = new Date(parseInt(product.expiresDate));
            // Check if subscription is still active
            if (expiryDate < new Date()) {
                console.error('Subscription expired', { expiryDate });
                return { verified: false, expiryDate: null, purchaseType: 'subscription' };
            }
        }
        return {
            verified: true,
            expiryDate,
            purchaseType: isLifetime ? 'lifetime' : 'subscription',
        };
    }
    catch (error) {
        console.error('Apple receipt verification error:', error);
        return { verified: false, expiryDate: null, purchaseType: 'subscription' };
    }
}
/**
 * Verify Google Play purchase
 */
async function verifyGooglePurchase(purchaseToken, productId) {
    try {
        // Authenticate with Google Play API using Application Default Credentials
        const auth = new googleapis_1.google.auth.GoogleAuth({
            scopes: ['https://www.googleapis.com/auth/androidpublisher'],
        });
        // Create authenticated androidpublisher client
        const authClient = await auth.getClient();
        const authenticatedPublisher = googleapis_1.google.androidpublisher({
            version: 'v3',
            auth: authClient,
        });
        const packageName = process.env.ANDROID_PACKAGE_NAME || 'com.gymbro.app';
        const isLifetime = productId.includes('lifetime');
        if (isLifetime) {
            // Verify one-time product purchase
            const response = await authenticatedPublisher.purchases.products.get({
                packageName,
                productId,
                token: purchaseToken,
            });
            const purchase = response.data;
            // Check purchase state (0 = purchased)
            if (purchase.purchaseState !== 0) {
                console.error('Invalid purchase state', { purchaseState: purchase.purchaseState });
                return { verified: false, expiryDate: null, purchaseType: 'lifetime' };
            }
            return {
                verified: true,
                expiryDate: null,
                purchaseType: 'lifetime',
            };
        }
        else {
            // Verify subscription
            const response = await authenticatedPublisher.purchases.subscriptions.get({
                packageName,
                subscriptionId: productId,
                token: purchaseToken,
            });
            const subscription = response.data;
            // Check if subscription is active
            const expiryTimeMillis = parseInt(subscription.expiryTimeMillis || '0');
            const expiryDate = new Date(expiryTimeMillis);
            if (expiryDate < new Date()) {
                console.error('Subscription expired', { expiryDate });
                return { verified: false, expiryDate: null, purchaseType: 'subscription' };
            }
            return {
                verified: true,
                expiryDate,
                purchaseType: 'subscription',
            };
        }
    }
    catch (error) {
        console.error('Google Play verification error:', error);
        return { verified: false, expiryDate: null, purchaseType: 'subscription' };
    }
}
/**
 * Scheduled function to check and update expired subscriptions
 */
exports.checkExpiredSubscriptions = (0, scheduler_1.onSchedule)('every 24 hours', async () => {
    const downgradedCount = await (0, entitlements_1.downgradeExpiredEntitlements)();
    console.log(`Downgraded ${downgradedCount} expired users to free tier`);
});
//# sourceMappingURL=verifyPremiumPurchase.js.map