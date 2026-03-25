"use strict";
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
exports.getEffectiveAccountTier = getEffectiveAccountTier;
exports.applyPremiumEntitlements = applyPremiumEntitlements;
exports.downgradeExpiredEntitlements = downgradeExpiredEntitlements;
exports.normalizeAccountTier = normalizeAccountTier;
const admin = __importStar(require("firebase-admin"));
const USERS_COLLECTION = 'users';
const USER_ENTITLEMENTS_COLLECTION = 'user_entitlements';
const LEGACY_DISTRIBUTION_SOFT_CAP = 999;
const TEMPLATE_QUOTAS = {
    free: { maxLibraryTemplates: 4 },
    premium: { maxLibraryTemplates: 999 },
};
async function getEffectiveAccountTier(userId) {
    var _a;
    try {
        const entitlementsDoc = await admin
            .firestore()
            .collection(USER_ENTITLEMENTS_COLLECTION)
            .doc(userId)
            .get();
        if (entitlementsDoc.exists) {
            const data = entitlementsDoc.data();
            if ((data === null || data === void 0 ? void 0 : data.premiumActive) === true || (data === null || data === void 0 ? void 0 : data.accountTier) === 'premium') {
                return 'premium';
            }
            return 'free';
        }
        const userDoc = await admin
            .firestore()
            .collection(USERS_COLLECTION)
            .doc(userId)
            .get();
        if (!userDoc.exists) {
            return 'free';
        }
        return normalizeAccountTier((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a['accountTier']);
    }
    catch (error) {
        console.error('Error resolving effective account tier:', error);
        return 'free';
    }
}
async function applyPremiumEntitlements(userId, input) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q, _r, _s;
    const db = admin.firestore();
    const userRef = db.collection(USERS_COLLECTION).doc(userId);
    const entitlementsRef = db
        .collection(USER_ENTITLEMENTS_COLLECTION)
        .doc(userId);
    const [userDoc, entitlementsDoc] = await Promise.all([
        userRef.get(),
        entitlementsRef.get(),
    ]);
    const userData = userDoc.data();
    const entitlementsData = entitlementsDoc.data();
    const quota = buildTemplateQuota(userData, input.accountTier);
    const premiumActive = input.accountTier === 'premium';
    const expiresAt = (_a = input.expiresAt) !== null && _a !== void 0 ? _a : null;
    const plan = inferEntitlementPlan(input.productId, (_b = input.isLifetime) !== null && _b !== void 0 ? _b : false);
    const willRenew = premiumActive && !((_c = input.isLifetime) !== null && _c !== void 0 ? _c : false) && ((_d = input.willRenew) !== null && _d !== void 0 ? _d : false);
    const activatedAt = (_e = readTimestamp(userData === null || userData === void 0 ? void 0 : userData['premiumActivatedAt'])) !== null && _e !== void 0 ? _e : readTimestamp(entitlementsData === null || entitlementsData === void 0 ? void 0 : entitlementsData['premiumActivatedAt']);
    const batch = db.batch();
    const expiresTimestamp = expiresAt
        ? admin.firestore.Timestamp.fromDate(expiresAt)
        : null;
    const entitlementUpdate = {
        accountTier: input.accountTier,
        premiumActive,
        plan,
        expiresAt: expiresTimestamp,
        willRenew,
        isLifetime: (_f = input.isLifetime) !== null && _f !== void 0 ? _f : false,
        productId: (_g = input.productId) !== null && _g !== void 0 ? _g : null,
        source: input.source,
        lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
        revenueCatAppUserId: userId,
        lastPurchaseId: (_h = input.lastPurchaseId) !== null && _h !== void 0 ? _h : null,
        lastPurchasePlatform: (_j = input.lastPurchasePlatform) !== null && _j !== void 0 ? _j : null,
        lastPurchaseProductId: (_l = (_k = input.lastPurchaseProductId) !== null && _k !== void 0 ? _k : input.productId) !== null && _l !== void 0 ? _l : null,
    };
    if (premiumActive) {
        entitlementUpdate.premiumActivatedAt =
            activatedAt !== null && activatedAt !== void 0 ? activatedAt : admin.firestore.FieldValue.serverTimestamp();
        entitlementUpdate.premiumExpiredAt = admin.firestore.FieldValue.delete();
    }
    else {
        entitlementUpdate.premiumExpiredAt =
            admin.firestore.FieldValue.serverTimestamp();
    }
    const userUpdate = {
        accountTier: input.accountTier,
        templateQuota: quota,
        premiumExpiresAt: expiresTimestamp,
        lastPurchaseId: (_m = input.lastPurchaseId) !== null && _m !== void 0 ? _m : null,
        lastPurchasePlatform: (_o = input.lastPurchasePlatform) !== null && _o !== void 0 ? _o : null,
        lastPurchaseProductId: (_q = (_p = input.lastPurchaseProductId) !== null && _p !== void 0 ? _p : input.productId) !== null && _q !== void 0 ? _q : null,
    };
    if (premiumActive) {
        userUpdate.premiumActivatedAt =
            activatedAt !== null && activatedAt !== void 0 ? activatedAt : admin.firestore.FieldValue.serverTimestamp();
        userUpdate.premiumExpiredAt = admin.firestore.FieldValue.delete();
    }
    else {
        userUpdate.premiumExpiredAt = admin.firestore.FieldValue.serverTimestamp();
    }
    batch.set(entitlementsRef, entitlementUpdate, { merge: true });
    batch.set(userRef, userUpdate, { merge: true });
    await batch.commit();
    return {
        accountTier: input.accountTier,
        premiumActive,
        plan,
        expiresAt,
        willRenew,
        isLifetime: (_r = input.isLifetime) !== null && _r !== void 0 ? _r : false,
        productId: (_s = input.productId) !== null && _s !== void 0 ? _s : null,
        source: input.source,
    };
}
async function downgradeExpiredEntitlements() {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const expiredSnapshots = await db
        .collection(USER_ENTITLEMENTS_COLLECTION)
        .where('premiumActive', '==', true)
        .where('expiresAt', '<', now)
        .get();
    if (expiredSnapshots.empty) {
        return 0;
    }
    const batch = db.batch();
    const userSnapshots = await Promise.all(expiredSnapshots.docs.map((doc) => db.collection(USERS_COLLECTION).doc(doc.id).get()));
    const userDataById = new Map(userSnapshots.map((snapshot) => [snapshot.id, snapshot.data()]));
    expiredSnapshots.forEach((doc) => {
        const userId = doc.id;
        batch.set(doc.ref, {
            accountTier: 'free',
            premiumActive: false,
            willRenew: false,
            premiumExpiredAt: now,
            lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        batch.set(db.collection(USERS_COLLECTION).doc(userId), {
            accountTier: 'free',
            templateQuota: buildTemplateQuota(userDataById.get(userId), 'free'),
            premiumExpiredAt: now,
        }, { merge: true });
    });
    await batch.commit();
    return expiredSnapshots.size;
}
function normalizeAccountTier(rawTier) {
    return rawTier === 'premium' || rawTier === 'pro' ? 'premium' : 'free';
}
function inferEntitlementPlan(productId, isLifetime) {
    if (isLifetime) {
        return 'lifetime';
    }
    if (!productId) {
        return null;
    }
    const normalized = productId.toLowerCase();
    if (normalized.includes('year') ||
        normalized.includes('annual') ||
        normalized.includes('annua')) {
        return 'yearly';
    }
    if (normalized.includes('month') || normalized.includes('mens')) {
        return 'monthly';
    }
    return null;
}
function buildTemplateQuota(userData, accountTier) {
    const currentUsed = readCurrentTemplateUsage(userData);
    const maxLibraryTemplates = TEMPLATE_QUOTAS[accountTier].maxLibraryTemplates;
    return {
        maxLibraryTemplates,
        usedLibraryTemplates: currentUsed.library,
        libraryEditableCount: currentUsed.library,
        maxPrivateTemplates: maxLibraryTemplates,
        usedPrivateTemplates: currentUsed.library,
        maxPublicTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
        maxSharedTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
        usedPublicTemplates: currentUsed.distribution,
        usedSharedTemplates: currentUsed.distribution,
        distributionMetered: false,
        distributedTemplateCount: currentUsed.distribution,
    };
}
function readCurrentTemplateUsage(userData) {
    var _a, _b, _c, _d;
    if (!userData) {
        return { library: 0, distribution: 0 };
    }
    const rawQuota = toRecord(userData['templateQuota']);
    if (rawQuota) {
        return {
            library: readCount((_b = (_a = rawQuota['usedLibraryTemplates']) !== null && _a !== void 0 ? _a : rawQuota['libraryEditableCount']) !== null && _b !== void 0 ? _b : rawQuota['usedPrivateTemplates']),
            distribution: readCount((_d = (_c = rawQuota['distributedTemplateCount']) !== null && _c !== void 0 ? _c : rawQuota['usedPublicTemplates']) !== null && _d !== void 0 ? _d : rawQuota['usedSharedTemplates']),
        };
    }
    const rawStats = toRecord(userData['stats']);
    return {
        library: readCount(rawStats === null || rawStats === void 0 ? void 0 : rawStats['privateTemplateCount']),
        distribution: readCount(rawStats === null || rawStats === void 0 ? void 0 : rawStats['publicTemplateCount']),
    };
}
function readCount(value) {
    if (typeof value === 'number') {
        return Math.trunc(value);
    }
    return 0;
}
function toRecord(value) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
        return undefined;
    }
    return value;
}
function readTimestamp(value) {
    if (value instanceof admin.firestore.Timestamp) {
        return value;
    }
    return null;
}
//# sourceMappingURL=entitlements.js.map