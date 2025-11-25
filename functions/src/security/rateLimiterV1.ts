/**
 * 🔐 SECURITY: Rate Limiting for Firebase Functions v1
 *
 * Wrapper for existing v1 onCall functions (backward compatible)
 *
 * **Usage**:
 * ```typescript
 * import { withRateLimit, RATE_LIMITS } from './security/rateLimiterV1';
 *
 * export const myFunction = withRateLimit(
 *   functions.https.onCall(async (data, context) => {
 *     // Your function logic here
 *   }),
 *   {
 *     ...RATE_LIMITS.STRICT,
 *     identifier: 'myFunction',
 *   }
 * );
 * ```
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Rate limit configuration (v1 compatible)
 */
export interface RateLimitConfig {
  /** Maximum requests allowed in time window */
  maxRequests: number;

  /** Time window in milliseconds (default: 60000 = 1 minute) */
  windowMs?: number;

  /** Unique identifier for this endpoint */
  identifier: string;

  /** Track by userId (if authenticated) or IP (if anonymous) */
  trackBy?: 'user' | 'ip' | 'both';

  /** Custom error message */
  errorMessage?: string;
}

/**
 * Default rate limit configs
 */
export const RATE_LIMITS = {
  /** Strict: 5 requests per minute (auth endpoints, admin actions) */
  STRICT: {
    maxRequests: 5,
    windowMs: 60 * 1000,
  },

  /** Standard: 30 requests per minute (normal API calls) */
  STANDARD: {
    maxRequests: 30,
    windowMs: 60 * 1000,
  },

  /** Generous: 100 requests per minute (read-only operations) */
  GENEROUS: {
    maxRequests: 100,
    windowMs: 60 * 1000,
  },
} as const;

/**
 * Wrap a Firebase Functions v1 onCall handler with rate limiting
 *
 * @param handler Original onCall handler (as callback)
 * @param config Rate limit configuration
 * @returns Wrapped CloudFunction
 *
 * @example
 * ```typescript
 * export const setAdminRole = withRateLimit(
 *   functions.https.onCall(async (data, context) => {
 *     // ... your logic
 *   }),
 *   { ...RATE_LIMITS.STRICT, identifier: 'setAdminRole' }
 * );
 * ```
 */
export function withRateLimit(
  handler: any, // CloudFunction<any, any> from firebase-functions
  config: RateLimitConfig
) {
  return functions.https.onCall(async (data, context) => {
    // Apply rate limiting BEFORE calling original handler
    await rateLimiter(data, context, config);

    // Call original handler if rate limit passed
    return handler(data, context);
  });
}

/**
 * Rate limiter implementation (v1 compatible)
 */
async function rateLimiter(
  data: any,
  context: functions.https.CallableContext,
  config: RateLimitConfig
): Promise<void> {
  const {
    maxRequests,
    windowMs = 60000,
    identifier,
    trackBy = 'user',
    errorMessage = 'Too many requests. Please try again later.',
  } = config;

  // Get tracking key
  const userId = context.auth?.uid;
  const ip = context.rawRequest.ip || 'unknown';

  let trackingKey: string;
  if (trackBy === 'user' && userId) {
    trackingKey = `user_${userId}`;
  } else if (trackBy === 'ip') {
    trackingKey = `ip_${ip}`;
  } else if (trackBy === 'both') {
    // Check both (stricter)
    await checkRateLimit(`user_${userId}`, identifier, maxRequests, windowMs, errorMessage);
    await checkRateLimit(`ip_${ip}`, identifier, maxRequests, windowMs, errorMessage);
    return;
  } else {
    trackingKey = userId ? `user_${userId}` : `ip_${ip}`;
  }

  await checkRateLimit(trackingKey, identifier, maxRequests, windowMs, errorMessage);
}

/**
 * Check rate limit for a tracking key
 */
async function checkRateLimit(
  trackingKey: string,
  identifier: string,
  maxRequests: number,
  windowMs: number,
  errorMessage: string
): Promise<void> {
  const db = admin.firestore();
  const rateLimitRef = db
    .collection('rateLimits')
    .doc(`${identifier}_${trackingKey}`);

  const now = Date.now();
  const windowStart = now - windowMs;

  try {
    await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(rateLimitRef);

      let timestamps: number[] = [];
      if (doc.exists) {
        timestamps = (doc.data()?.timestamps || []) as number[];
      }

      // Remove expired timestamps
      timestamps = timestamps.filter((ts) => ts > windowStart);

      // Check if limit exceeded
      if (timestamps.length >= maxRequests) {
        const oldestTimestamp = timestamps[0];
        const retryAfterMs = oldestTimestamp + windowMs - now;
        const retryAfterSec = Math.ceil(retryAfterMs / 1000);

        console.warn('⚠️ Rate limit exceeded', {
          identifier,
          trackingKey: trackingKey.substring(0, 15) + '...',
          currentRequests: timestamps.length,
          maxRequests,
          windowMs,
          retryAfterSec,
        });

        throw new functions.https.HttpsError(
          'resource-exhausted',
          `${errorMessage} Retry after ${retryAfterSec} seconds.`
        );
      }

      // Add current timestamp
      timestamps.push(now);

      // Update Firestore
      transaction.set(
        rateLimitRef,
        {
          timestamps,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          expiresAt: new Date(now + windowMs * 2), // TTL for cleanup
        },
        { merge: true }
      );
    });
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Fail-open: Log error but don't block request
    console.error('❌ Rate limit check failed (allowing request)', {
      identifier,
      error: error instanceof Error ? error.message : String(error),
    });
  }
}
