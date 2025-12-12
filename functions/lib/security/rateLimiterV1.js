"use strict";
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
 *   async (data, context) => {
 *     // Your function logic here (NOT wrapped in functions.https.onCall)
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
exports.withRateLimit = exports.RATE_LIMITS = void 0;
const functions = __importStar(require("firebase-functions"));
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
};
/**
 * Wrap a Firebase Functions v1 onCall handler with rate limiting
 *
 * @param handler The handler function (NOT wrapped in functions.https.onCall)
 * @param config Rate limit configuration
 * @returns Wrapped CloudFunction
 *
 * @example
 * ```typescript
 * export const setAdminRole = withRateLimit(
 *   async (data, context) => {
 *     // ... your logic (NOT wrapped in functions.https.onCall)
 *   },
 *   { ...RATE_LIMITS.STRICT, identifier: 'setAdminRole' }
 * );
 * ```
 */
function withRateLimit(handler, config) {
    return functions.https.onCall(async (data, context) => {
        // Apply rate limiting BEFORE calling original handler
        await rateLimiter(data, context, config);
        // Call original handler if rate limit passed
        return handler(data, context);
    });
}
exports.withRateLimit = withRateLimit;
/**
 * Rate limiter implementation (v1 compatible)
 */
async function rateLimiter(data, context, config) {
    var _a;
    const { maxRequests, windowMs = 60000, identifier, trackBy = 'user', errorMessage = 'Too many requests. Please try again later.', } = config;
    // Get tracking key
    const userId = (_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid;
    const ip = context.rawRequest.ip || 'unknown';
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
                throw new functions.https.HttpsError('resource-exhausted', `${errorMessage} Retry after ${retryAfterSec} seconds.`);
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
//# sourceMappingURL=rateLimiterV1.js.map