"use strict";
/**
 * 🔐 ADMIN: Cloud Function to set a user's account tier
 *
 * Only callable by authenticated admins (custom claim: admin=true).
 * Updates accountTier and templateQuota atomically.
 *
 * **Usage** (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('setAccountTier')
 *   .call({'targetUserId': uid, 'tier': 'premium'});
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
exports.setAccountTier = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const rateLimiterV1_1 = require("../security/rateLimiterV1");
const TEMPLATE_QUOTAS = {
    free: { maxPrivateTemplates: 4, maxPublicTemplates: 2 },
    premium: { maxPrivateTemplates: 999, maxPublicTemplates: 999 },
};
/**
 * Check if the caller has admin custom claims
 */
async function verifyAdmin(uid) {
    var _a;
    try {
        const user = await admin.auth().getUser(uid);
        return ((_a = user.customClaims) === null || _a === void 0 ? void 0 : _a.admin) === true;
    }
    catch (_b) {
        return false;
    }
}
exports.setAccountTier = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a, _b, _c, _d;
    // 1. Authentication
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be authenticated');
    }
    // 2. Admin authorization
    const callerUid = request.auth.uid;
    const callerIsAdmin = await verifyAdmin(callerUid);
    if (!callerIsAdmin) {
        console.warn(`Non-admin user ${callerUid} attempted to set account tier`);
        throw new https_1.HttpsError('permission-denied', 'Only admins can change account tiers');
    }
    // 3. Validate input
    const { targetUserId, tier } = request.data;
    if (!targetUserId || typeof targetUserId !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'targetUserId is required');
    }
    if (tier !== 'free' && tier !== 'premium') {
        throw new https_1.HttpsError('invalid-argument', 'tier must be "free" or "premium"');
    }
    const accountTier = tier;
    const quota = TEMPLATE_QUOTAS[accountTier];
    // 4. Verify target user exists
    const userRef = admin.firestore().collection('users').doc(targetUserId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
        throw new https_1.HttpsError('not-found', `User ${targetUserId} not found`);
    }
    const currentData = userDoc.data();
    const currentUsed = {
        private: (_b = (_a = currentData === null || currentData === void 0 ? void 0 : currentData.templateQuota) === null || _a === void 0 ? void 0 : _a.usedPrivateTemplates) !== null && _b !== void 0 ? _b : 0,
        public: (_d = (_c = currentData === null || currentData === void 0 ? void 0 : currentData.templateQuota) === null || _c === void 0 ? void 0 : _c.usedPublicTemplates) !== null && _d !== void 0 ? _d : 0,
    };
    // 5. Update atomically
    await userRef.update({
        accountTier: accountTier,
        templateQuota: {
            maxPrivateTemplates: quota.maxPrivateTemplates,
            maxPublicTemplates: quota.maxPublicTemplates,
            usedPrivateTemplates: currentUsed.private,
            usedPublicTemplates: currentUsed.public,
        },
    });
    console.log(`Admin ${callerUid} set account tier for ${targetUserId} to ${accountTier}`);
    return {
        success: true,
        targetUserId,
        tier: accountTier,
        quota: {
            maxPrivateTemplates: quota.maxPrivateTemplates,
            maxPublicTemplates: quota.maxPublicTemplates,
            usedPrivateTemplates: currentUsed.private,
            usedPublicTemplates: currentUsed.public,
        },
    };
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STRICT), { identifier: 'setAccountTier' }));
//# sourceMappingURL=setAccountTier.js.map