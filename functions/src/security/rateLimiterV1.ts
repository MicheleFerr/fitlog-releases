/**
 * 🔐 SECURITY: Rate Limiting for Firebase Functions v2
 *
 * Wrapper for onCall functions with rate limiting
 *
 * **Usage**:
 * ```typescript
 * import { withRateLimit, RATE_LIMITS } from './security/rateLimiterV1';
 *
 * export const myFunction = withRateLimit(
 *   async (request) => {
 *     // Your function logic here
 *     const { data, auth } = request;
 *   },
 *   {
 *     ...RATE_LIMITS.STRICT,
 *     identifier: 'myFunction',
 *   }
 * );
 * ```
 */

import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

/**
 * Rate limit configuration
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

  /** Enforce Firebase App Check token validation (secure-by-default) */
  enforceAppCheck?: boolean;

  /** Optional runtime secrets to inject in Cloud Function environment */
  secrets?: string[];

  /** Optional Cloud Function timeout (seconds) */
  timeoutSeconds?: number;
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

  /** Hourly: 500 requests per hour (heavy operations) */
  HOURLY: {
    maxRequests: 500,
    windowMs: 60 * 60 * 1000,
  },

  /** Daily: 1000 requests per day (bulk operations) */
  DAILY: {
    maxRequests: 1000,
    windowMs: 24 * 60 * 60 * 1000,
  },
} as const;

/**
 * Type for onCall handler function (v2 API)
 */
type OnCallHandler<T = any, R = any> = (
  request: CallableRequest<T>
) => Promise<R> | R;

/**
 * Wrap a Firebase Functions v2 onCall handler with rate limiting
 *
 * @param handler The handler function
 * @param config Rate limit configuration
 * @returns Wrapped CloudFunction
 *
 * @example
 * ```typescript
 * export const setAdminRole = withRateLimit(
 *   async (request) => {
 *     const { data, auth } = request;
 *     // ... your logic
 *   },
 *   { ...RATE_LIMITS.STRICT, identifier: 'setAdminRole' }
 * );
 * ```
 */
export function withRateLimit<T = any, R = any>(
  handler: OnCallHandler<T, R>,
  config: RateLimitConfig
) {
  return onCall<T>(
    {
      enforceAppCheck: config.enforceAppCheck ?? true,
      ...(config.secrets ? { secrets: config.secrets } : {}),
      ...(config.timeoutSeconds ? { timeoutSeconds: config.timeoutSeconds } : {}),
    },
    async (request) => {
      // Apply rate limiting BEFORE calling original handler
      await rateLimiter(request, config);

      // Call original handler if rate limit passed
      return handler(request);
    }
  );
}

/**
 * Rate limiter implementation (v2 compatible)
 */
async function rateLimiter<T>(
  request: CallableRequest<T>,
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
  const userId = request.auth?.uid;
  const ip = request.rawRequest?.ip || 'unknown';

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

        throw new HttpsError(
          'resource-exhausted',
          `${errorMessage} Retry after ${retryAfterSec} seconds.`,
          {
            retryAfter: retryAfterSec,
            limit: maxRequests,
            windowMs,
          }
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
    if (error instanceof HttpsError) {
      throw error;
    }

    // Fail-closed on infrastructure issues (secure-by-default).
    console.error('❌ Rate limit check failed (blocking request)', {
      identifier,
      error: error instanceof Error ? error.message : String(error),
    });

    throw new HttpsError(
      'unavailable',
      'Request temporarily blocked: security throttling service unavailable.'
    );
  }
}

// ========================================
// 🧹 Utility Functions
// ========================================

/**
 * Clean up expired rate limit entries (for scheduled function)
 *
 * Run this daily to remove old rate limit data
 *
 * **Usage**:
 * ```typescript
 * export const cleanupRateLimits = onSchedule('every 24 hours', cleanupExpiredRateLimits);
 * ```
 */
export async function cleanupExpiredRateLimits(): Promise<void> {
  const db = admin.firestore();
  const now = new Date();

  const expiredDocs = await db
    .collection('rateLimits')
    .where('expiresAt', '<', now)
    .limit(500) // Batch limit
    .get();

  if (expiredDocs.empty) {
    console.log('✅ No expired rate limit entries to clean up');
    return;
  }

  const batch = db.batch();
  expiredDocs.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();

  console.log(`🗑️ Cleaned up ${expiredDocs.size} expired rate limit entries`);
}

/**
 * Reset rate limit for a specific user (admin utility)
 *
 * Use for manual override in case of false positives
 */
export async function resetRateLimit(
  userId: string,
  identifier: string
): Promise<void> {
  const db = admin.firestore();
  const rateLimitRef = db.collection('rateLimits').doc(`${identifier}_user_${userId}`);

  await rateLimitRef.delete();

  console.log(`✅ Rate limit reset for user ${userId.substring(0, 8)}... on ${identifier}`);
}
