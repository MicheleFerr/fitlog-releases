"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.resetRateLimit = exports.cleanupExpiredRateLimits = exports.withRateLimit = exports.RATE_LIMITS = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
/**
 * Default rate limit configs
 */
exports.RATE_LIMITS = {
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
};
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
function withRateLimit(handler, config) {
    return (0, https_1.onCall)(async (request) => {
        // Apply rate limiting BEFORE calling original handler
        await rateLimiter(request, config);
        // Call original handler if rate limit passed
        return handler(request);
    });
}
exports.withRateLimit = withRateLimit;
/**
 * Rate limiter implementation (v2 compatible)
 */
async function rateLimiter(request, config) {
    var _a, _b;
    const { maxRequests, windowMs = 60000, identifier, trackBy = 'user', errorMessage = 'Too many requests. Please try again later.', } = config;
    // Get tracking key
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    const ip = ((_b = request.rawRequest) === null || _b === void 0 ? void 0 : _b.ip) || 'unknown';
    let trackingKey;
    if (trackBy === 'user' && userId) {
        trackingKey = `user_${userId}`;
    }
    else if (trackBy === 'ip') {
        trackingKey = `ip_${ip}`;
    }
    else if (trackBy === 'both') {
        // Check both (stricter)
        await checkRateLimit(`user_${userId}`, identifier, maxRequests, windowMs, errorMessage);
        await checkRateLimit(`ip_${ip}`, identifier, maxRequests, windowMs, errorMessage);
        return;
    }
    else {
        trackingKey = userId ? `user_${userId}` : `ip_${ip}`;
    }
    await checkRateLimit(trackingKey, identifier, maxRequests, windowMs, errorMessage);
}
/**
 * Check rate limit for a tracking key
 */
async function checkRateLimit(trackingKey, identifier, maxRequests, windowMs, errorMessage) {
    const db = admin.firestore();
    const rateLimitRef = db
        .collection('rateLimits')
        .doc(`${identifier}_${trackingKey}`);
    const now = Date.now();
    const windowStart = now - windowMs;
    try {
        await db.runTransaction(async (transaction) => {
            var _a;
            const doc = await transaction.get(rateLimitRef);
            let timestamps = [];
            if (doc.exists) {
                timestamps = (((_a = doc.data()) === null || _a === void 0 ? void 0 : _a.timestamps) || []);
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
                throw new https_1.HttpsError('resource-exhausted', `${errorMessage} Retry after ${retryAfterSec} seconds.`, {
                    retryAfter: retryAfterSec,
                    limit: maxRequests,
                    windowMs,
                });
            }
            // Add current timestamp
            timestamps.push(now);
            // Update Firestore
            transaction.set(rateLimitRef, {
                timestamps,
                lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                expiresAt: new Date(now + windowMs * 2), // TTL for cleanup
            }, { merge: true });
        });
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        // Fail-open: Log error but don't block request
        console.error('❌ Rate limit check failed (allowing request)', {
            identifier,
            error: error instanceof Error ? error.message : String(error),
        });
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
async function cleanupExpiredRateLimits() {
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
exports.cleanupExpiredRateLimits = cleanupExpiredRateLimits;
/**
 * Reset rate limit for a specific user (admin utility)
 *
 * Use for manual override in case of false positives
 */
async function resetRateLimit(userId, identifier) {
    const db = admin.firestore();
    const rateLimitRef = db.collection('rateLimits').doc(`${identifier}_user_${userId}`);
    await rateLimitRef.delete();
    console.log(`✅ Rate limit reset for user ${userId.substring(0, 8)}... on ${identifier}`);
}
exports.resetRateLimit = resetRateLimit;
//# sourceMappingURL=rateLimiterV1.js.map