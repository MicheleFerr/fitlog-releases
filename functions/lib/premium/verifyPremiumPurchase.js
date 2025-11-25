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
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkExpiredSubscriptions = exports.verifyPremiumPurchase = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const appleReceiptVerify = __importStar(require("node-apple-receipt-verify"));
const googleapis_1 = require("googleapis");
// Initialize Apple receipt verification
appleReceiptVerify.config({
    secret: ((_a = functions.config().apple) === null || _a === void 0 ? void 0 : _a.shared_secret) || '',
    environment: ['production', 'sandbox'],
    excludeOldTransactions: true,
    extended: true,
});
// Initialize Google Play API
const androidPublisher = googleapis_1.google.androidpublisher('v3');
/**
 * Verify premium purchase from iOS or Android
 */
exports.verifyPremiumPurchase = functions.https.onCall(async (data, context) => {
    // Verify authenticated user
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated to verify purchase');
    }
    const { userId, productId, purchaseToken, platform, purchaseId } = data;
    // Validate input
    if (!userId || !productId || !purchaseToken || !platform) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required purchase data');
    }
    // Verify the user matches the authenticated user
    if (userId !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', 'User ID mismatch');
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
            throw new functions.https.HttpsError('invalid-argument', 'Invalid platform specified');
        }
        if (!verified) {
            console.error('Purchase verification failed', { userId, productId, platform });
            return { success: false, error: 'Purchase verification failed' };
        }
        // Update user profile with premium status
        const userRef = admin.firestore().collection('users').doc(userId);
        const updateData = {
            accountTier: purchaseType === 'lifetime' ? 'pro' : 'premium',
            premiumActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
            lastPurchaseId: purchaseId,
            lastPurchasePlatform: platform,
            lastPurchaseProductId: productId,
        };
        if (expiryDate) {
            updateData.premiumExpiresAt = admin.firestore.Timestamp.fromDate(expiryDate);
        }
        else if (purchaseType === 'lifetime') {
            // Lifetime purchase - set expiry to far future
            const farFuture = new Date();
            farFuture.setFullYear(farFuture.getFullYear() + 100);
            updateData.premiumExpiresAt = admin.firestore.Timestamp.fromDate(farFuture);
        }
        await userRef.update(updateData);
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
            accountTier: updateData.accountTier,
            expiryDate: expiryDate === null || expiryDate === void 0 ? void 0 : expiryDate.toISOString(),
        };
    }
    catch (error) {
        console.error('Purchase verification error:', error);
        throw new functions.https.HttpsError('internal', 'Failed to verify purchase', error);
    }
});
/**
 * Verify Apple App Store purchase
 */
async function verifyApplePurchase(receiptData, productId) {
    try {
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
    var _a;
    try {
        // Authenticate with Google Play API
        const auth = new googleapis_1.google.auth.GoogleAuth({
            keyFile: 'path/to/service-account-key.json',
            scopes: ['https://www.googleapis.com/auth/androidpublisher'],
        });
        const authClient = await auth.getClient();
        androidPublisher.context._options.auth = authClient;
        const packageName = ((_a = functions.config().android) === null || _a === void 0 ? void 0 : _a.package_name) || 'com.gymbro.app';
        const isLifetime = productId.includes('lifetime');
        if (isLifetime) {
            // Verify one-time product purchase
            const response = await androidPublisher.purchases.products.get({
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
            const response = await androidPublisher.purchases.subscriptions.get({
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
exports.checkExpiredSubscriptions = functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    // Find users with expired premium
    const expiredUsers = await admin.firestore()
        .collection('users')
        .where('accountTier', 'in', ['premium', 'pro'])
        .where('premiumExpiresAt', '<', now)
        .get();
    console.log(`Found ${expiredUsers.size} expired subscriptions`);
    // Downgrade expired users
    const batch = admin.firestore().batch();
    expiredUsers.forEach((doc) => {
        batch.update(doc.ref, {
            accountTier: 'free',
            premiumExpiredAt: now,
        });
    });
    await batch.commit();
    console.log(`Downgraded ${expiredUsers.size} expired users to free tier`);
});
//# sourceMappingURL=verifyPremiumPurchase.js.map