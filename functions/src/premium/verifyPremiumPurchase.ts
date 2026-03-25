/**
 * Cloud Function to verify and activate premium purchases
 * Handles both iOS (App Store) and Android (Google Play) purchases
 */

import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';
import * as appleReceiptVerify from 'node-apple-receipt-verify';
import { google } from 'googleapis';
import {
  applyPremiumEntitlements,
  downgradeExpiredEntitlements,
} from './entitlements';

// Lazy initialization flag for Apple receipt verification
let appleReceiptConfigured = false;

/**
 * Initialize Apple receipt verification lazily
 * This avoids validation errors when the module loads without config
 */
function ensureAppleReceiptConfigured(): void {
  if (appleReceiptConfigured) return;

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

// Google Play API will be initialized per-request with auth

interface PurchaseData {
  userId: string;
  productId: string;
  purchaseToken: string;
  platform: 'ios' | 'android';
  purchaseId?: string;
}

/**
 * Verify premium purchase from iOS or Android
 */
export const verifyPremiumPurchase = onCall<PurchaseData>({ enforceAppCheck: true }, async (request) => {
  // Verify authenticated user
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to verify purchase'
    );
  }

  const { userId, productId, purchaseToken, platform, purchaseId } = request.data;

  // Validate input
  if (!userId || !productId || !purchaseToken || !platform) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required purchase data'
    );
  }

  // Verify the user matches the authenticated user
  if (userId !== request.auth.uid) {
    throw new HttpsError(
      'permission-denied',
      'User ID mismatch'
    );
  }

  try {
    let verified = false;
    let expiryDate: Date | null = null;
    let purchaseType: 'subscription' | 'lifetime' = 'subscription';

    // Verify based on platform
    if (platform === 'ios') {
      const result = await verifyApplePurchase(purchaseToken, productId);
      verified = result.verified;
      expiryDate = result.expiryDate;
      purchaseType = result.purchaseType;
    } else if (platform === 'android') {
      const result = await verifyGooglePurchase(purchaseToken, productId);
      verified = result.verified;
      expiryDate = result.expiryDate;
      purchaseType = result.purchaseType;
    } else {
      throw new HttpsError(
        'invalid-argument',
        'Invalid platform specified'
      );
    }

    if (!verified) {
      console.error('Purchase verification failed', { userId, productId, platform });
      return { success: false, error: 'Purchase verification failed' };
    }

    const entitlementSnapshot = await applyPremiumEntitlements(userId, {
      accountTier: 'premium',
      source: 'store_verification',
      expiresAt: expiryDate,
      willRenew: purchaseType === 'subscription',
      isLifetime: purchaseType === 'lifetime',
      productId,
      lastPurchaseId: purchaseId ?? null,
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
      expiryDate: entitlementSnapshot.expiresAt?.toISOString(),
    };

  } catch (error) {
    console.error('Purchase verification error:', error);
    throw new HttpsError(
      'internal',
      'Failed to verify purchase',
      error
    );
  }
});

/**
 * Verify Apple App Store purchase
 */
async function verifyApplePurchase(
  receiptData: string,
  productId: string
): Promise<{ verified: boolean; expiryDate: Date | null; purchaseType: 'subscription' | 'lifetime' }> {
  try {
    // Ensure Apple receipt verification is configured
    ensureAppleReceiptConfigured();

    // Verify receipt with Apple
    const products = await appleReceiptVerify.validate({
      receipt: receiptData,
    });

    // Find the specific product
    const product = products.find((p: { productId: string }) => p.productId === productId);

    if (!product) {
      console.error('Product not found in receipt', { productId });
      return { verified: false, expiryDate: null, purchaseType: 'subscription' };
    }

    // Check if it's a lifetime purchase
    const isLifetime = productId.includes('lifetime');

    // For subscriptions, check expiry
    let expiryDate: Date | null = null;
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

  } catch (error) {
    console.error('Apple receipt verification error:', error);
    return { verified: false, expiryDate: null, purchaseType: 'subscription' };
  }
}

/**
 * Verify Google Play purchase
 */
async function verifyGooglePurchase(
  purchaseToken: string,
  productId: string
): Promise<{ verified: boolean; expiryDate: Date | null; purchaseType: 'subscription' | 'lifetime' }> {
  try {
    // Authenticate with Google Play API using Application Default Credentials
    const auth = new google.auth.GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });

    // Create authenticated androidpublisher client
    const authClient = await auth.getClient();
    const authenticatedPublisher = google.androidpublisher({
      version: 'v3',
      auth: authClient as Parameters<typeof google.androidpublisher>[0]['auth'],
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

    } else {
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

  } catch (error) {
    console.error('Google Play verification error:', error);
    return { verified: false, expiryDate: null, purchaseType: 'subscription' };
  }
}

/**
 * Scheduled function to check and update expired subscriptions
 */
export const checkExpiredSubscriptions = onSchedule('every 24 hours', async () => {
  const downgradedCount = await downgradeExpiredEntitlements();
  console.log(`Downgraded ${downgradedCount} expired users to free tier`);
});
