/**
 * 🔐 ADMIN: Cloud Function to set a user's account tier
 *
 * Only callable by authenticated admins (custom claim: admin=true).
 * Updates accountTier and Library quota atomically.
 *
 * **Usage** (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('setAccountTier')
 *   .call({'targetUserId': uid, 'tier': 'premium'});
 * ```
 */

import { HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';
import { applyPremiumEntitlements } from '../premium/entitlements';

type AccountTier = 'free' | 'premium';

/**
 * Check if the caller has admin custom claims
 */
async function verifyAdmin(uid: string): Promise<boolean> {
  try {
    const user = await admin.auth().getUser(uid);
    return user.customClaims?.admin === true;
  } catch {
    return false;
  }
}

interface SetAccountTierData {
  targetUserId: string;
  tier: string;
}

export const setAccountTier = withRateLimit<SetAccountTierData>(
  async (request) => {
    // 1. Authentication
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be authenticated');
    }

    // 2. Admin authorization
    const callerUid = request.auth.uid;
    const callerIsAdmin = await verifyAdmin(callerUid);
    if (!callerIsAdmin) {
      console.warn(`Non-admin user ${callerUid} attempted to set account tier`);
      throw new HttpsError('permission-denied', 'Only admins can change account tiers');
    }

    // 3. Validate input
    const { targetUserId, tier } = request.data;

    if (!targetUserId || typeof targetUserId !== 'string') {
      throw new HttpsError('invalid-argument', 'targetUserId is required');
    }

    if (tier !== 'free' && tier !== 'premium') {
      throw new HttpsError('invalid-argument', 'tier must be "free" or "premium"');
    }

    const accountTier = tier as AccountTier;

    // 4. Verify target user exists
    const userRef = admin.firestore().collection('users').doc(targetUserId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new HttpsError('not-found', `User ${targetUserId} not found`);
    }

    // 5. Update atomically
    const snapshot = await applyPremiumEntitlements(targetUserId, {
      accountTier,
      source: 'admin',
      isLifetime: false,
      willRenew: false,
    });

    console.log(`Admin ${callerUid} set account tier for ${targetUserId} to ${accountTier}`);

    return {
      success: true,
      targetUserId,
      tier: accountTier,
      premiumActive: snapshot.premiumActive,
      plan: snapshot.plan,
      expiresAt: snapshot.expiresAt?.toISOString() ?? null,
    };
  },
  { ...RATE_LIMITS.STRICT, identifier: 'setAccountTier' }
);
