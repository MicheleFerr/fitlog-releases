/**
 * 🔐 SECURITY: Rate Limiting Middleware
 *
 * Prevents API abuse by limiting requests per user/IP
 *
 * **Storage**: Firestore (no additional dependencies)
 * **Tracking**: Per-user (authenticated) OR per-IP (anonymous)
 * **Window**: Configurable sliding window (default: 1 minute, 1 hour, 1 day)
 * **Cleanup**: Automatic cleanup of expired entries
 *
 * **Usage**:
 * ```typescript
 * import { rateLimiter, RateLimitConfig } from './security/rateLimiter';
 *
 * export const myFunction = onCall(async (request) => {
 *   // Check rate limit BEFORE processing
 *   await rateLimiter(request, {
 *     maxRequests: 10,
 *     windowMs: 60000, // 1 minute
 *     identifier: 'myFunction',
 *   });
 *
 *   // Process request...
 * });
 * ```
 */

import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';

/**
 * Rate limit configuration
 */
export interface RateLimitConfig {
  /** Maximum requests allowed in time window */
  maxRequests: number;

  /** Time window in milliseconds (default: 60000 = 1 minute) */
  windowMs?: number;

  /** Unique identifier for this endpoint (for separate limits) */
  identifier: string;

  /** Track by userId (if authenticated) or IP (if anonymous) */
  trackBy?: 'user' | 'ip' | 'both';

  /** Custom error message */
  errorMessage?: string;
}

/**
 * Default rate limit configs for common use cases
 */
export const RATE_LIMITS = {
  /** Strict: 5 requests per minute (auth endpoints, admin actions) */
  STRICT: {
    maxRequests: 5,
    windowMs: 60 * 1000, // 1 minute
  },

  /** Standard: 30 requests per minute (normal API calls) */
  STANDARD: {
    maxRequests: 30,
    windowMs: 60 * 1000, // 1 minute
  },

  /** Generous: 100 requests per minute (read-only operations) */
  GENEROUS: {
    maxRequests: 100,
    windowMs: 60 * 1000, // 1 minute
  },

  /** Hourly: 500 requests per hour (heavy operations) */
  HOURLY: {
    maxRequests: 500,
    windowMs: 60 * 60 * 1000, // 1 hour
  },

  /** Daily: 1000 requests per day (bulk operations) */
  DAILY: {
    maxRequests: 1000,
    windowMs: 24 * 60 * 60 * 1000, // 24 hours
  },
} as const;

/**
 * Rate limiter middleware
 *
 * @throws HttpsError with code 'resource-exhausted' if limit exceeded
 */
export async function rateLimiter(
  request: CallableRequest,
  config: RateLimitConfig
): Promise<void> {
  const {
    maxRequests,
    windowMs = 60000, // Default: 1 minute
    identifier,
    trackBy = 'user', // Default: track by user
    errorMessage = 'Too many requests. Please try again later.',
  } = config;

  // Get tracking key (userId or IP)
  const userId = request.auth?.uid;
  const ip = request.rawRequest.ip || 'unknown';

  let trackingKey: string;
  if (trackBy === 'user' && userId) {
    trackingKey = `user_${userId}`;
  } else if (trackBy === 'ip') {
    trackingKey = `ip_${ip}`;
  } else if (trackBy === 'both') {
    // Check both (stricter - if either exceeds, reject)
    await checkRateLimit(`user_${userId}`, identifier, maxRequests, windowMs, errorMessage);
    await checkRateLimit(`ip_${ip}`, identifier, maxRequests, windowMs, errorMessage);
    return;
  } else {
    // Fallback: track by IP if not authenticated
    trackingKey = userId ? `user_${userId}` : `ip_${ip}`;
  }

  await checkRateLimit(trackingKey, identifier, maxRequests, windowMs, errorMessage);
}

/**
 * Check rate limit for a specific tracking key
 *
 * @throws HttpsError if limit exceeded
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
    // Use Firestore transaction for atomic read-modify-write
    await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(rateLimitRef);

      let timestamps: number[] = [];
      if (doc.exists) {
        timestamps = (doc.data()?.timestamps || []) as number[];
      }

      // Remove expired timestamps (outside window)
      timestamps = timestamps.filter((ts) => ts > windowStart);

      // Check if limit exceeded
      if (timestamps.length >= maxRequests) {
        const oldestTimestamp = timestamps[0];
        const retryAfterMs = oldestTimestamp + windowMs - now;
        const retryAfterSec = Math.ceil(retryAfterMs / 1000);

        // 🔐 SECURITY: Log rate limit violation (but redact sensitive data)
        console.warn('⚠️ Rate limit exceeded', {
          identifier,
          trackingKey: trackingKey.substring(0, 15) + '...', // Redact full key
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

      // Update Firestore (with TTL for automatic cleanup)
      transaction.set(
        rateLimitRef,
        {
          timestamps,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          // Set TTL expiration (cleanup after 2x window duration)
          expiresAt: new Date(now + windowMs * 2),
        },
        { merge: true }
      );
    });
  } catch (error) {
    // If error is already HttpsError (rate limit exceeded), rethrow
    if (error instanceof HttpsError) {
      throw error;
    }

    // Otherwise, log unexpected error and allow request (fail-open)
    console.error('❌ Rate limit check failed (allowing request)', {
      identifier,
      error: error instanceof Error ? error.message : String(error),
    });
    // Fail-open: Don't block requests if rate limiter is broken
  }
}

/**
 * Clean up expired rate limit entries (scheduled function)
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
