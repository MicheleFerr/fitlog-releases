"use strict";
/**
 * 🔐 SECURITY: Cloud Function for Template Library and Distribution
 *
 * This module keeps Library quota enforcement and distribution lifecycle on the
 * server so monetized editable slots cannot be bypassed by client writes.
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
exports.migrateTemplateQuotaToLibrary = exports.migrateTemplateMetadata = exports.hideTemplate = exports.reportTemplate = exports.createTemplateDraftFromShared = exports.forkTemplate = exports.shareTemplateUnlisted = exports.publishTemplate = exports.getTemplateQuota = exports.createTemplate = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const rateLimiterV1_1 = require("../security/rateLimiterV1");
const entitlements_1 = require("../premium/entitlements");
const TEMPLATE_QUOTAS = {
    free: {
        maxLibraryTemplates: 4,
    },
    premium: {
        maxLibraryTemplates: 999,
    },
};
const LEGACY_DISTRIBUTION_SOFT_CAP = 999;
const VALID_VISIBILITIES = ['private', 'unlisted', 'public'];
const VALID_LINEAGE_TYPES = ['original', 'fork'];
const VALID_DISTRIBUTION_STATUSES = ['active', 'superseded', 'hidden'];
const VALID_REPORT_REASONS = [
    'spam',
    'inappropriate',
    'misleading',
    'copyright',
    'other',
];
function isValidVisibility(value) {
    return typeof value === 'string' && VALID_VISIBILITIES.includes(value);
}
function isValidLineageType(value) {
    return typeof value === 'string' && VALID_LINEAGE_TYPES.includes(value);
}
function isValidDistributionStatus(value) {
    return typeof value === 'string' && VALID_DISTRIBUTION_STATUSES.includes(value);
}
function resolveRequestedVisibility(data) {
    if (isValidVisibility(data.visibility)) {
        return data.visibility;
    }
    return data.isPublic === true ? 'public' : 'private';
}
function normalizeTemplateData(raw, id) {
    const userId = typeof (raw === null || raw === void 0 ? void 0 : raw.userId) === 'string' ? raw.userId : '';
    const visibility = isValidVisibility(raw === null || raw === void 0 ? void 0 : raw.visibility)
        ? raw.visibility
        : (raw === null || raw === void 0 ? void 0 : raw.isPublic) === true
            ? 'public'
            : 'private';
    const lineageType = isValidLineageType(raw === null || raw === void 0 ? void 0 : raw.lineageType)
        ? raw.lineageType
        : typeof (raw === null || raw === void 0 ? void 0 : raw.forkedFromTemplateId) === 'string' && raw.forkedFromTemplateId.trim().length > 0
            ? 'fork'
            : 'original';
    const distributionStatus = isValidDistributionStatus(raw === null || raw === void 0 ? void 0 : raw.distributionStatus)
        ? raw.distributionStatus
        : 'active';
    const forkedFromTemplateId = typeof (raw === null || raw === void 0 ? void 0 : raw.forkedFromTemplateId) === 'string' && raw.forkedFromTemplateId.trim().length > 0
        ? raw.forkedFromTemplateId.trim()
        : null;
    const parentTemplateId = typeof (raw === null || raw === void 0 ? void 0 : raw.parentTemplateId) === 'string' && raw.parentTemplateId.trim().length > 0
        ? raw.parentTemplateId.trim()
        : lineageType === 'fork'
            ? forkedFromTemplateId
            : null;
    const rootTemplateId = typeof (raw === null || raw === void 0 ? void 0 : raw.rootTemplateId) === 'string' && raw.rootTemplateId.trim().length > 0
        ? raw.rootTemplateId.trim()
        : forkedFromTemplateId !== null && forkedFromTemplateId !== void 0 ? forkedFromTemplateId : id;
    return {
        id,
        userId,
        visibility,
        lineageType,
        distributionStatus,
        rootTemplateId,
        parentTemplateId,
        versionNumber: typeof (raw === null || raw === void 0 ? void 0 : raw.versionNumber) === 'number' && raw.versionNumber > 0 ? raw.versionNumber : 1,
        isPublic: visibility === 'public',
        isAnonymous: (raw === null || raw === void 0 ? void 0 : raw.isAnonymous) === true,
        authorName: typeof (raw === null || raw === void 0 ? void 0 : raw.authorName) === 'string' ? raw.authorName : null,
        authorPhotoUrl: typeof (raw === null || raw === void 0 ? void 0 : raw.authorPhotoUrl) === 'string' ? raw.authorPhotoUrl : null,
        forkedFromTemplateId,
        originalAuthorName: typeof (raw === null || raw === void 0 ? void 0 : raw.originalAuthorName) === 'string' ? raw.originalAuthorName : null,
    };
}
function isSharedTemplate(template) {
    return template.visibility !== 'private' && template.distributionStatus === 'active';
}
function isDiscoverablePublicTemplate(template) {
    return template.visibility === 'public'
        && template.lineageType === 'original'
        && template.distributionStatus === 'active';
}
function countTemplateBuckets(docs) {
    let libraryEditableCount = 0;
    let distributedCount = 0;
    for (const doc of docs) {
        const normalized = normalizeTemplateData(doc.data(), doc.id);
        if (normalized.visibility === 'private') {
            libraryEditableCount += 1;
        }
        if (isSharedTemplate(normalized)) {
            distributedCount += 1;
        }
    }
    return { libraryEditableCount, distributedCount };
}
function buildQuotaPayload(accountTier, counts) {
    const quotas = TEMPLATE_QUOTAS[accountTier];
    const libraryRemaining = Math.max(0, quotas.maxLibraryTemplates - counts.libraryEditableCount);
    const distributionRemaining = Math.max(0, LEGACY_DISTRIBUTION_SOFT_CAP - counts.distributedCount);
    return {
        accountTier,
        library: {
            used: counts.libraryEditableCount,
            max: quotas.maxLibraryTemplates,
            remaining: libraryRemaining,
        },
        distribution: {
            used: counts.distributedCount,
            max: LEGACY_DISTRIBUTION_SOFT_CAP,
            remaining: distributionRemaining,
            metered: false,
        },
        libraryUsed: counts.libraryEditableCount,
        libraryMax: quotas.maxLibraryTemplates,
        libraryRemaining,
        // Backward-compatible aliases for existing client consumers.
        private: {
            used: counts.libraryEditableCount,
            max: quotas.maxLibraryTemplates,
            remaining: libraryRemaining,
        },
        shared: {
            used: counts.distributedCount,
            max: LEGACY_DISTRIBUTION_SOFT_CAP,
            remaining: distributionRemaining,
            metered: false,
        },
        public: {
            used: counts.distributedCount,
            max: LEGACY_DISTRIBUTION_SOFT_CAP,
            remaining: distributionRemaining,
            metered: false,
        },
        privateUsed: counts.libraryEditableCount,
        privateMax: quotas.maxLibraryTemplates,
        sharedUsed: counts.distributedCount,
        sharedMax: LEGACY_DISTRIBUTION_SOFT_CAP,
        publicUsed: counts.distributedCount,
        publicMax: LEGACY_DISTRIBUTION_SOFT_CAP,
    };
}
function applyQuotaSnapshot(transaction, userRef, accountTier, counts, now, metadata = {}) {
    const quotas = TEMPLATE_QUOTAS[accountTier];
    transaction.set(userRef, {
        templateQuota: Object.assign({ maxLibraryTemplates: quotas.maxLibraryTemplates, usedLibraryTemplates: counts.libraryEditableCount, libraryEditableCount: counts.libraryEditableCount, maxPrivateTemplates: quotas.maxLibraryTemplates, usedPrivateTemplates: counts.libraryEditableCount, maxSharedTemplates: LEGACY_DISTRIBUTION_SOFT_CAP, maxPublicTemplates: LEGACY_DISTRIBUTION_SOFT_CAP, usedSharedTemplates: counts.distributedCount, usedPublicTemplates: counts.distributedCount, distributionMetered: false, distributedTemplateCount: counts.distributedCount, lastTemplateQuotaSyncAt: now }, metadata),
    }, { merge: true });
}
function assertLibraryQuotaAvailable(accountTier, counts, requiredAdditionalSlots) {
    if (requiredAdditionalSlots <= 0)
        return;
    const quotas = TEMPLATE_QUOTAS[accountTier];
    if (counts.libraryEditableCount + requiredAdditionalSlots > quotas.maxLibraryTemplates) {
        throw new https_1.HttpsError('resource-exhausted', `Library quota exceeded. You have ${counts.libraryEditableCount}/${quotas.maxLibraryTemplates} editable templates in your Library. ` +
            (accountTier === 'free'
                ? 'Upgrade to Premium for more Library slots.'
                : 'Delete existing Library templates to create new ones.'));
    }
}
function getMaxVersionForRoot(docs, rootTemplateId) {
    let maxVersion = 0;
    for (const doc of docs) {
        const normalized = normalizeTemplateData(doc.data(), doc.id);
        if (normalized.rootTemplateId === rootTemplateId) {
            maxVersion = Math.max(maxVersion, normalized.versionNumber);
        }
    }
    return Math.max(maxVersion, 1);
}
function getActiveSharedSiblings(docs, currentTemplateId, rootTemplateId) {
    return docs.filter((doc) => {
        if (doc.id === currentTemplateId)
            return false;
        const normalized = normalizeTemplateData(doc.data(), doc.id);
        return normalized.rootTemplateId === rootTemplateId && isSharedTemplate(normalized);
    });
}
function hasSharedHistoryForRoot(docs, rootTemplateId) {
    return docs.some((doc) => {
        const normalized = normalizeTemplateData(doc.data(), doc.id);
        return normalized.rootTemplateId === rootTemplateId && normalized.visibility !== 'private';
    });
}
function validateTemplateData(data) {
    if (!data.name || typeof data.name !== 'string') {
        return { valid: false, error: 'Template name is required and must be a string' };
    }
    if (data.name.trim().length === 0) {
        return { valid: false, error: 'Template name cannot be empty' };
    }
    if (data.name.length > 100) {
        return { valid: false, error: 'Template name must be 100 characters or less' };
    }
    if (data.description && typeof data.description !== 'string') {
        return { valid: false, error: 'Description must be a string' };
    }
    if (data.description && data.description.length > 500) {
        return { valid: false, error: 'Description must be 500 characters or less' };
    }
    if (!data.exercises || !Array.isArray(data.exercises)) {
        return { valid: false, error: 'Exercises are required and must be an array' };
    }
    if (data.exercises.length === 0) {
        return { valid: false, error: 'Template must have at least one exercise' };
    }
    if (data.exercises.length > 50) {
        return { valid: false, error: 'Template cannot have more than 50 exercises' };
    }
    if (data.tags && !Array.isArray(data.tags)) {
        return { valid: false, error: 'Tags must be an array' };
    }
    if (data.tags && data.tags.length > 10) {
        return { valid: false, error: 'Template cannot have more than 10 tags' };
    }
    if (data.visibility && !isValidVisibility(data.visibility)) {
        return { valid: false, error: 'Invalid visibility value' };
    }
    return { valid: true };
}
function validateTemplateId(templateId) {
    if (!templateId || typeof templateId !== 'string') {
        return { valid: false, error: 'Template ID is required and must be a string' };
    }
    if (templateId.trim().length === 0) {
        return { valid: false, error: 'Template ID cannot be empty' };
    }
    return { valid: true };
}
function validateReportTemplateData(data) {
    const templateValidation = validateTemplateId(data.templateId);
    if (!templateValidation.valid) {
        return templateValidation;
    }
    if (!VALID_REPORT_REASONS.includes(data.reason)) {
        return { valid: false, error: 'Invalid report reason' };
    }
    if (data.details && data.details.length > 500) {
        return { valid: false, error: 'Report details must be 500 characters or less' };
    }
    return { valid: true };
}
async function getUserAccountTier(userId) {
    return (0, entitlements_1.getEffectiveAccountTier)(userId);
}
async function getAuthorMetadata(userId, isAnonymous) {
    if (isAnonymous) {
        return {
            authorName: 'Utente Anonimo',
            authorPhotoUrl: null,
        };
    }
    try {
        const userRecord = await admin.auth().getUser(userId);
        return {
            authorName: userRecord.displayName || 'Anonymous',
            authorPhotoUrl: userRecord.photoURL || null,
        };
    }
    catch (error) {
        console.warn(`Failed to resolve author metadata for user ${userId}:`, error);
        return {
            authorName: 'Anonymous',
            authorPhotoUrl: null,
        };
    }
}
function generateTemplateId() {
    return admin.firestore().collection('workoutTemplates').doc().id;
}
async function countUserTemplates(userId) {
    const snapshot = await admin.firestore()
        .collection('workoutTemplates')
        .where('userId', '==', userId)
        .get();
    return countTemplateBuckets(snapshot.docs);
}
async function isAdmin(uid) {
    var _a;
    try {
        const user = await admin.auth().getUser(uid);
        return ((_a = user.customClaims) === null || _a === void 0 ? void 0 : _a.admin) === true;
    }
    catch (error) {
        console.error('Error checking admin status:', error);
        return false;
    }
}
async function recalculateAndPersistQuotaForUser(userId, now) {
    const accountTier = await getUserAccountTier(userId);
    const counts = await countUserTemplates(userId);
    await admin.firestore().collection('users').doc(userId).set({
        templateQuota: {
            maxLibraryTemplates: TEMPLATE_QUOTAS[accountTier].maxLibraryTemplates,
            usedLibraryTemplates: counts.libraryEditableCount,
            libraryEditableCount: counts.libraryEditableCount,
            maxPrivateTemplates: TEMPLATE_QUOTAS[accountTier].maxLibraryTemplates,
            usedPrivateTemplates: counts.libraryEditableCount,
            maxSharedTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
            maxPublicTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
            usedSharedTemplates: counts.distributedCount,
            usedPublicTemplates: counts.distributedCount,
            distributionMetered: false,
            distributedTemplateCount: counts.distributedCount,
            lastTemplateQuotaSyncAt: now,
        },
    }, { merge: true });
    return counts;
}
function toTemplateDocument(args) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q;
    return {
        id: args.templateId,
        userId: args.userId,
        name: args.name,
        description: args.description,
        exercises: args.exercises,
        tags: args.tags,
        isCustom: true,
        isPublic: args.visibility === 'public',
        visibility: args.visibility,
        lineageType: args.lineageType,
        parentTemplateId: (_a = args.parentTemplateId) !== null && _a !== void 0 ? _a : null,
        rootTemplateId: (_b = args.rootTemplateId) !== null && _b !== void 0 ? _b : args.templateId,
        distributionStatus: (_c = args.distributionStatus) !== null && _c !== void 0 ? _c : 'active',
        publishedAt: (_d = args.publishedAt) !== null && _d !== void 0 ? _d : (args.visibility === 'private' ? null : args.updatedAt),
        versionNumber: (_e = args.versionNumber) !== null && _e !== void 0 ? _e : 1,
        usageCount: (_f = args.usageCount) !== null && _f !== void 0 ? _f : 0,
        downloadCount: (_g = args.downloadCount) !== null && _g !== void 0 ? _g : 0,
        forkCount: (_h = args.forkCount) !== null && _h !== void 0 ? _h : 0,
        reviewCount: (_j = args.reviewCount) !== null && _j !== void 0 ? _j : 0,
        averageRating: (_k = args.averageRating) !== null && _k !== void 0 ? _k : 0,
        isAnonymous: args.isAnonymous === true,
        authorName: (_l = args.authorName) !== null && _l !== void 0 ? _l : null,
        authorPhotoUrl: (_m = args.authorPhotoUrl) !== null && _m !== void 0 ? _m : null,
        forkedFromTemplateId: (_o = args.forkedFromTemplateId) !== null && _o !== void 0 ? _o : null,
        originalAuthorName: (_p = args.originalAuthorName) !== null && _p !== void 0 ? _p : null,
        supersededByTemplateId: (_q = args.supersededByTemplateId) !== null && _q !== void 0 ? _q : null,
        createdAt: args.createdAt,
        updatedAt: args.updatedAt,
    };
}
exports.createTemplate = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to create templates');
    }
    const userId = request.auth.uid;
    const data = request.data;
    const validation = validateTemplateData(data);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template data');
    }
    const accountTier = await getUserAccountTier(userId);
    const requestedVisibility = resolveRequestedVisibility(data);
    const isAnonymous = data.isAnonymous === true;
    const now = admin.firestore.Timestamp.now();
    const templateId = generateTemplateId();
    const { authorName, authorPhotoUrl } = await getAuthorMetadata(userId, isAnonymous);
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    const templateDoc = toTemplateDocument({
        templateId,
        userId,
        name: data.name.trim(),
        description: ((_a = data.description) === null || _a === void 0 ? void 0 : _a.trim()) || '',
        exercises: data.exercises,
        tags: data.tags || [],
        visibility: requestedVisibility,
        lineageType: 'original',
        rootTemplateId: templateId,
        publishedAt: requestedVisibility === 'private' ? null : now,
        versionNumber: 1,
        isAnonymous,
        authorName: requestedVisibility === 'private' ? null : authorName,
        authorPhotoUrl: requestedVisibility === 'private' ? null : authorPhotoUrl,
        createdAt: now,
        updatedAt: now,
    });
    let nextCounts = { libraryEditableCount: 0, distributedCount: 0 };
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            const userTemplatesSnapshot = await transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId));
            const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
            if (requestedVisibility === 'private') {
                assertLibraryQuotaAvailable(accountTier, currentCounts, 1);
                nextCounts = {
                    libraryEditableCount: currentCounts.libraryEditableCount + 1,
                    distributedCount: currentCounts.distributedCount,
                };
            }
            else {
                nextCounts = {
                    libraryEditableCount: currentCounts.libraryEditableCount,
                    distributedCount: currentCounts.distributedCount + 1,
                };
            }
            transaction.set(templateRef, templateDoc);
            applyQuotaSnapshot(transaction, userRef, accountTier, nextCounts, now, {
                lastTemplateCreatedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'create_template',
            templateId,
            userId,
            visibility: requestedVisibility,
            lineageType: 'original',
            accountTier,
            timestamp: now,
            status: 'success',
        });
        return {
            success: true,
            templateId,
            template: {
                id: templateId,
                name: templateDoc.name,
                description: templateDoc.description,
                isPublic: templateDoc.isPublic,
                visibility: templateDoc.visibility,
                createdAt: now.toDate().toISOString(),
            },
            quota: buildQuotaPayload(accountTier, nextCounts),
        };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'create_template',
            userId,
            templateName: data.name,
            visibility: requestedVisibility,
            accountTier,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error creating template:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to create template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'createTemplate' }));
exports.getTemplateQuota = (0, https_1.onCall)({ enforceAppCheck: true }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated');
    }
    const userId = request.auth.uid;
    const accountTier = await getUserAccountTier(userId);
    const counts = await countUserTemplates(userId);
    return buildQuotaPayload(accountTier, counts);
});
exports.publishTemplate = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to publish templates');
    }
    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }
    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const isAnonymous = request.data.isAnonymous === true;
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);
    const { authorName, authorPhotoUrl } = await getAuthorMetadata(userId, isAnonymous);
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    let responseTemplateId = templateId;
    let nextCounts = { libraryEditableCount: 0, distributedCount: 0 };
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
                transaction.get(templateRef),
                transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
            ]);
            if (!templateSnapshot.exists) {
                throw new https_1.HttpsError('not-found', 'Template not found');
            }
            const current = normalizeTemplateData(templateSnapshot.data(), templateId);
            const sourceData = templateSnapshot.data();
            if (current.userId !== userId) {
                throw new https_1.HttpsError('permission-denied', 'Cannot publish a template you do not own');
            }
            if (current.lineageType !== 'original') {
                throw new https_1.HttpsError('permission-denied', 'Templates saved from the Store cannot be published in Store.');
            }
            if (current.distributionStatus !== 'active' && current.visibility !== 'private') {
                throw new https_1.HttpsError('failed-precondition', 'Only active templates can be published');
            }
            const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
            const activeSharedSiblings = getActiveSharedSiblings(userTemplatesSnapshot.docs, templateId, current.rootTemplateId);
            if (current.visibility === 'private') {
                responseTemplateId = generateTemplateId();
                const nextVersion = hasSharedHistoryForRoot(userTemplatesSnapshot.docs, current.rootTemplateId)
                    ? Math.max(current.versionNumber, getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1)
                    : current.versionNumber;
                for (const sibling of activeSharedSiblings) {
                    transaction.update(sibling.ref, {
                        distributionStatus: 'superseded',
                        supersededByTemplateId: responseTemplateId,
                        updatedAt: now,
                    });
                }
                const snapshotDoc = toTemplateDocument({
                    templateId: responseTemplateId,
                    userId,
                    name: typeof sourceData.name === 'string' ? sourceData.name : 'Published Template',
                    description: typeof sourceData.description === 'string' ? sourceData.description : '',
                    exercises: Array.isArray(sourceData.exercises) ? sourceData.exercises : [],
                    tags: Array.isArray(sourceData.tags) ? sourceData.tags : [],
                    visibility: 'public',
                    lineageType: 'original',
                    parentTemplateId: templateId,
                    rootTemplateId: current.rootTemplateId,
                    distributionStatus: 'active',
                    publishedAt: now,
                    versionNumber: nextVersion,
                    usageCount: 0,
                    downloadCount: 0,
                    forkCount: 0,
                    reviewCount: 0,
                    averageRating: 0,
                    isAnonymous,
                    authorName,
                    authorPhotoUrl,
                    forkedFromTemplateId: null,
                    originalAuthorName: null,
                    supersededByTemplateId: null,
                    createdAt: now,
                    updatedAt: now,
                });
                transaction.set(admin.firestore().collection('workoutTemplates').doc(responseTemplateId), snapshotDoc);
                nextCounts = {
                    libraryEditableCount: currentCounts.libraryEditableCount,
                    distributedCount: currentCounts.distributedCount - activeSharedSiblings.length + 1,
                };
            }
            else {
                for (const sibling of activeSharedSiblings) {
                    transaction.update(sibling.ref, {
                        distributionStatus: 'superseded',
                        supersededByTemplateId: templateId,
                        updatedAt: now,
                    });
                }
                transaction.update(templateRef, {
                    isPublic: true,
                    visibility: 'public',
                    distributionStatus: 'active',
                    publishedAt: now,
                    isAnonymous,
                    authorName,
                    authorPhotoUrl,
                    updatedAt: now,
                    supersededByTemplateId: null,
                });
                nextCounts = {
                    libraryEditableCount: currentCounts.libraryEditableCount,
                    distributedCount: currentCounts.distributedCount - activeSharedSiblings.length,
                };
            }
            applyQuotaSnapshot(transaction, userRef, accountTier, nextCounts, now, {
                lastTemplatePublishedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'publish_template',
            templateId,
            userId,
            isAnonymous,
            accountTier,
            timestamp: now,
            status: 'success',
        });
        return {
            success: true,
            templateId: responseTemplateId,
            quota: buildQuotaPayload(accountTier, nextCounts),
        };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'publish_template',
            templateId,
            userId,
            isAnonymous,
            accountTier,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error publishing template:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to publish template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'publishTemplate' }));
exports.shareTemplateUnlisted = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to share templates');
    }
    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }
    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const isAnonymous = request.data.isAnonymous === true;
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);
    const { authorName, authorPhotoUrl } = await getAuthorMetadata(userId, isAnonymous);
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    let responseTemplateId = templateId;
    let nextCounts = { libraryEditableCount: 0, distributedCount: 0 };
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            var _a, _b, _c, _d, _e, _f;
            const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
                transaction.get(templateRef),
                transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
            ]);
            if (!templateSnapshot.exists) {
                throw new https_1.HttpsError('not-found', 'Template not found');
            }
            const current = normalizeTemplateData(templateSnapshot.data(), templateId);
            const sourceData = templateSnapshot.data();
            if (current.userId !== userId) {
                throw new https_1.HttpsError('permission-denied', 'Cannot share a template you do not own');
            }
            if (current.visibility === 'public') {
                throw new https_1.HttpsError('failed-precondition', 'Use the existing public template instead of creating an unlisted copy');
            }
            const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
            if (current.lineageType === 'original') {
                const activeSharedSiblings = getActiveSharedSiblings(userTemplatesSnapshot.docs, templateId, current.rootTemplateId);
                if (current.visibility === 'private') {
                    responseTemplateId = generateTemplateId();
                    const nextVersion = hasSharedHistoryForRoot(userTemplatesSnapshot.docs, current.rootTemplateId)
                        ? Math.max(current.versionNumber, getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1)
                        : current.versionNumber;
                    for (const sibling of activeSharedSiblings) {
                        transaction.update(sibling.ref, {
                            distributionStatus: 'superseded',
                            supersededByTemplateId: responseTemplateId,
                            updatedAt: now,
                        });
                    }
                    const snapshotDoc = toTemplateDocument({
                        templateId: responseTemplateId,
                        userId,
                        name: typeof sourceData.name === 'string' ? sourceData.name : 'Shared Template',
                        description: typeof sourceData.description === 'string' ? sourceData.description : '',
                        exercises: Array.isArray(sourceData.exercises) ? sourceData.exercises : [],
                        tags: Array.isArray(sourceData.tags) ? sourceData.tags : [],
                        visibility: 'unlisted',
                        lineageType: 'original',
                        parentTemplateId: templateId,
                        rootTemplateId: current.rootTemplateId,
                        distributionStatus: 'active',
                        publishedAt: now,
                        versionNumber: nextVersion,
                        usageCount: 0,
                        downloadCount: 0,
                        forkCount: 0,
                        reviewCount: 0,
                        averageRating: 0,
                        isAnonymous,
                        authorName,
                        authorPhotoUrl,
                        forkedFromTemplateId: null,
                        originalAuthorName: null,
                        supersededByTemplateId: null,
                        createdAt: now,
                        updatedAt: now,
                    });
                    transaction.set(admin.firestore().collection('workoutTemplates').doc(responseTemplateId), snapshotDoc);
                    nextCounts = {
                        libraryEditableCount: currentCounts.libraryEditableCount,
                        distributedCount: currentCounts.distributedCount - activeSharedSiblings.length + 1,
                    };
                }
                else {
                    for (const sibling of activeSharedSiblings) {
                        transaction.update(sibling.ref, {
                            distributionStatus: 'superseded',
                            supersededByTemplateId: templateId,
                            updatedAt: now,
                        });
                    }
                    transaction.update(templateRef, {
                        isPublic: false,
                        visibility: 'unlisted',
                        distributionStatus: 'active',
                        publishedAt: now,
                        isAnonymous,
                        authorName,
                        authorPhotoUrl,
                        updatedAt: now,
                        supersededByTemplateId: null,
                    });
                    nextCounts = {
                        libraryEditableCount: currentCounts.libraryEditableCount,
                        distributedCount: currentCounts.distributedCount - activeSharedSiblings.length,
                    };
                }
            }
            else {
                if (current.visibility !== 'private') {
                    throw new https_1.HttpsError('failed-precondition', 'Only private Library copies can be shared with a code.');
                }
                const activeSnapshots = userTemplatesSnapshot.docs.filter((doc) => {
                    const normalized = normalizeTemplateData(doc.data(), doc.id);
                    return normalized.parentTemplateId === templateId && isSharedTemplate(normalized);
                });
                for (const sibling of activeSnapshots) {
                    transaction.update(sibling.ref, {
                        distributionStatus: 'superseded',
                        updatedAt: now,
                    });
                }
                responseTemplateId = generateTemplateId();
                const nextVersion = Math.max(current.versionNumber, getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1);
                const snapshotDoc = toTemplateDocument({
                    templateId: responseTemplateId,
                    userId,
                    name: typeof ((_a = templateSnapshot.data()) === null || _a === void 0 ? void 0 : _a.name) === 'string' ? templateSnapshot.data().name : 'Shared Template',
                    description: typeof ((_b = templateSnapshot.data()) === null || _b === void 0 ? void 0 : _b.description) === 'string'
                        ? templateSnapshot.data().description
                        : '',
                    exercises: Array.isArray((_c = templateSnapshot.data()) === null || _c === void 0 ? void 0 : _c.exercises)
                        ? templateSnapshot.data().exercises
                        : [],
                    tags: Array.isArray((_d = templateSnapshot.data()) === null || _d === void 0 ? void 0 : _d.tags)
                        ? templateSnapshot.data().tags
                        : [],
                    visibility: 'unlisted',
                    lineageType: 'fork',
                    parentTemplateId: templateId,
                    rootTemplateId: current.rootTemplateId,
                    distributionStatus: 'active',
                    publishedAt: now,
                    versionNumber: nextVersion,
                    usageCount: 0,
                    downloadCount: 0,
                    forkCount: 0,
                    reviewCount: 0,
                    averageRating: 0,
                    isAnonymous,
                    authorName,
                    authorPhotoUrl,
                    forkedFromTemplateId: (_f = (_e = current.forkedFromTemplateId) !== null && _e !== void 0 ? _e : current.parentTemplateId) !== null && _f !== void 0 ? _f : current.rootTemplateId,
                    originalAuthorName: current.originalAuthorName,
                    createdAt: now,
                    updatedAt: now,
                });
                transaction.set(admin.firestore().collection('workoutTemplates').doc(responseTemplateId), snapshotDoc);
                nextCounts = {
                    libraryEditableCount: currentCounts.libraryEditableCount,
                    distributedCount: currentCounts.distributedCount - activeSnapshots.length + 1,
                };
            }
            applyQuotaSnapshot(transaction, userRef, accountTier, nextCounts, now, {
                lastTemplateSharedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'share_template_unlisted',
            templateId,
            sharedTemplateId: responseTemplateId,
            userId,
            isAnonymous,
            accountTier,
            timestamp: now,
            status: 'success',
        });
        return {
            success: true,
            templateId: responseTemplateId,
            quota: buildQuotaPayload(accountTier, nextCounts),
        };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'share_template_unlisted',
            templateId,
            userId,
            isAnonymous,
            accountTier,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error sharing template unlisted:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to share template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'shareTemplateUnlisted' }));
exports.forkTemplate = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to save templates');
    }
    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }
    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);
    const sourceRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    const forkId = generateTemplateId();
    let nextCounts = { libraryEditableCount: 0, distributedCount: 0 };
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            var _a, _b;
            const [sourceSnapshot, userTemplatesSnapshot] = await Promise.all([
                transaction.get(sourceRef),
                transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
            ]);
            if (!sourceSnapshot.exists) {
                throw new https_1.HttpsError('not-found', 'Shared template not found');
            }
            const source = normalizeTemplateData(sourceSnapshot.data(), templateId);
            if (!isSharedTemplate(source)) {
                throw new https_1.HttpsError('failed-precondition', 'Only shared templates can be saved to your Library');
            }
            const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
            assertLibraryQuotaAvailable(accountTier, currentCounts, 1);
            const sourceData = sourceSnapshot.data();
            const forkDoc = toTemplateDocument({
                templateId: forkId,
                userId,
                name: typeof sourceData.name === 'string' ? sourceData.name : 'Forked Template',
                description: typeof sourceData.description === 'string' ? sourceData.description : '',
                exercises: Array.isArray(sourceData.exercises) ? sourceData.exercises : [],
                tags: Array.isArray(sourceData.tags) ? sourceData.tags : [],
                visibility: 'private',
                lineageType: 'fork',
                parentTemplateId: templateId,
                rootTemplateId: source.rootTemplateId,
                distributionStatus: 'active',
                publishedAt: null,
                versionNumber: 1,
                usageCount: 0,
                downloadCount: 0,
                forkCount: 0,
                reviewCount: 0,
                averageRating: 0,
                isAnonymous: false,
                authorName: null,
                authorPhotoUrl: null,
                forkedFromTemplateId: templateId,
                originalAuthorName: (_b = (_a = source.authorName) !== null && _a !== void 0 ? _a : source.originalAuthorName) !== null && _b !== void 0 ? _b : (source.isAnonymous ? 'Utente Anonimo' : null),
                createdAt: now,
                updatedAt: now,
            });
            transaction.set(admin.firestore().collection('workoutTemplates').doc(forkId), forkDoc);
            transaction.update(sourceRef, {
                downloadCount: admin.firestore.FieldValue.increment(1),
                forkCount: admin.firestore.FieldValue.increment(1),
                updatedAt: now,
            });
            nextCounts = {
                libraryEditableCount: currentCounts.libraryEditableCount + 1,
                distributedCount: currentCounts.distributedCount,
            };
            applyQuotaSnapshot(transaction, userRef, accountTier, nextCounts, now, {
                lastTemplateForkedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'fork_template',
            templateId,
            forkTemplateId: forkId,
            userId,
            accountTier,
            timestamp: now,
            status: 'success',
        });
        return {
            success: true,
            templateId: forkId,
            quota: buildQuotaPayload(accountTier, nextCounts),
        };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'fork_template',
            templateId,
            userId,
            accountTier,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error forking template:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to fork template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'forkTemplate' }));
exports.createTemplateDraftFromShared = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to create drafts');
    }
    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }
    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);
    const draftId = generateTemplateId();
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    let nextCounts = { libraryEditableCount: 0, distributedCount: 0 };
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
                transaction.get(templateRef),
                transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
            ]);
            if (!templateSnapshot.exists) {
                throw new https_1.HttpsError('not-found', 'Shared template not found');
            }
            const current = normalizeTemplateData(templateSnapshot.data(), templateId);
            if (current.userId !== userId) {
                throw new https_1.HttpsError('permission-denied', 'Cannot create a draft from a template you do not own');
            }
            if (current.visibility === 'private') {
                throw new https_1.HttpsError('failed-precondition', 'Template is already editable');
            }
            if (!isSharedTemplate(current)) {
                throw new https_1.HttpsError('failed-precondition', 'Only active shared templates can create drafts');
            }
            const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
            assertLibraryQuotaAvailable(accountTier, currentCounts, 1);
            const sourceData = templateSnapshot.data();
            const draftDoc = toTemplateDocument({
                templateId: draftId,
                userId,
                name: typeof sourceData.name === 'string' ? sourceData.name : 'Template Draft',
                description: typeof sourceData.description === 'string' ? sourceData.description : '',
                exercises: Array.isArray(sourceData.exercises) ? sourceData.exercises : [],
                tags: Array.isArray(sourceData.tags) ? sourceData.tags : [],
                visibility: 'private',
                lineageType: current.lineageType,
                parentTemplateId: templateId,
                rootTemplateId: current.rootTemplateId,
                distributionStatus: 'active',
                publishedAt: null,
                versionNumber: getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1,
                usageCount: 0,
                downloadCount: 0,
                forkCount: 0,
                reviewCount: 0,
                averageRating: 0,
                isAnonymous: current.isAnonymous,
                authorName: current.authorName,
                authorPhotoUrl: current.authorPhotoUrl,
                forkedFromTemplateId: current.forkedFromTemplateId,
                originalAuthorName: current.originalAuthorName,
                createdAt: now,
                updatedAt: now,
            });
            transaction.set(admin.firestore().collection('workoutTemplates').doc(draftId), draftDoc);
            nextCounts = {
                libraryEditableCount: currentCounts.libraryEditableCount + 1,
                distributedCount: currentCounts.distributedCount,
            };
            applyQuotaSnapshot(transaction, userRef, accountTier, nextCounts, now, {
                lastTemplateDraftCreatedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'create_template_draft_from_shared',
            templateId,
            draftTemplateId: draftId,
            userId,
            accountTier,
            timestamp: now,
            status: 'success',
        });
        return {
            success: true,
            templateId: draftId,
            quota: buildQuotaPayload(accountTier, nextCounts),
        };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'create_template_draft_from_shared',
            templateId,
            userId,
            accountTier,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error creating template draft:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to create draft. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'createTemplateDraftFromShared' }));
exports.reportTemplate = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to report templates');
    }
    const validation = validateReportTemplateData(request.data);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid report payload');
    }
    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const reportRef = admin.firestore().collection('template_reports').doc(`${templateId}_${userId}`);
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    try {
        await admin.firestore().runTransaction(async (transaction) => {
            var _a;
            const [templateSnapshot, existingReportSnapshot] = await Promise.all([
                transaction.get(templateRef),
                transaction.get(reportRef),
            ]);
            if (!templateSnapshot.exists) {
                throw new https_1.HttpsError('not-found', 'Template not found');
            }
            const template = normalizeTemplateData(templateSnapshot.data(), templateId);
            if (!isSharedTemplate(template)) {
                throw new https_1.HttpsError('failed-precondition', 'Only shared templates can be reported');
            }
            if (existingReportSnapshot.exists) {
                throw new https_1.HttpsError('already-exists', 'You have already reported this template');
            }
            transaction.set(reportRef, {
                templateId,
                reporterUserId: userId,
                ownerUserId: template.userId,
                reason: request.data.reason,
                details: ((_a = request.data.details) === null || _a === void 0 ? void 0 : _a.trim()) || '',
                status: 'pending',
                createdAt: now,
                updatedAt: now,
            });
        });
        await admin.firestore().collection('template_audit_logs').add({
            action: 'report_template',
            templateId,
            userId,
            reason: request.data.reason,
            timestamp: now,
            status: 'success',
        });
        return { success: true };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'report_template',
            templateId,
            userId,
            reason: request.data.reason,
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error reporting template:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to report template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'reportTemplate' }));
exports.hideTemplate = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a, _b, _c;
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to hide templates');
    }
    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
        throw new https_1.HttpsError('permission-denied', 'Only admins can hide templates');
    }
    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
        throw new https_1.HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    try {
        const snapshot = await templateRef.get();
        if (!snapshot.exists) {
            throw new https_1.HttpsError('not-found', 'Template not found');
        }
        const template = normalizeTemplateData(snapshot.data(), templateId);
        await templateRef.update({
            distributionStatus: 'hidden',
            hiddenAt: now,
            hiddenBy: adminUid,
            hideReason: ((_a = request.data.hideReason) === null || _a === void 0 ? void 0 : _a.trim()) || '',
            updatedAt: now,
        });
        if (template.userId) {
            await recalculateAndPersistQuotaForUser(template.userId, now);
        }
        await admin.firestore().collection('template_audit_logs').add({
            action: 'hide_template',
            templateId,
            ownerUserId: template.userId,
            adminUid,
            hideReason: ((_b = request.data.hideReason) === null || _b === void 0 ? void 0 : _b.trim()) || '',
            timestamp: now,
            status: 'success',
        });
        return { success: true };
    }
    catch (error) {
        await admin.firestore().collection('template_audit_logs').add({
            action: 'hide_template',
            templateId,
            adminUid,
            hideReason: ((_c = request.data.hideReason) === null || _c === void 0 ? void 0 : _c.trim()) || '',
            timestamp: admin.firestore.Timestamp.now(),
            status: 'error',
            error: String(error),
        });
        console.error('Error hiding template:', error);
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        throw new https_1.HttpsError('internal', 'Failed to hide template. Please try again.');
    }
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'hideTemplate' }));
exports.migrateTemplateMetadata = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to migrate templates');
    }
    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
        throw new https_1.HttpsError('permission-denied', 'Only admins can migrate template metadata');
    }
    const batchSize = Math.min(Math.max((_a = request.data.batchSize) !== null && _a !== void 0 ? _a : 100, 1), 250);
    const dryRun = request.data.dryRun === true;
    const startAfterId = typeof request.data.startAfterId === 'string'
        && request.data.startAfterId.trim().length > 0
        ? request.data.startAfterId.trim()
        : null;
    const now = admin.firestore.Timestamp.now();
    let query = admin.firestore()
        .collection('workoutTemplates')
        .orderBy(admin.firestore.FieldPath.documentId())
        .limit(batchSize);
    if (startAfterId) {
        query = query.startAfter(startAfterId);
    }
    const snapshot = await query.get();
    const batch = admin.firestore().batch();
    const updatedTemplateIds = [];
    const affectedOwners = new Set();
    for (const doc of snapshot.docs) {
        const normalized = normalizeTemplateData(doc.data(), doc.id);
        const visibility = normalized.lineageType === 'fork' && normalized.visibility === 'public'
            ? 'unlisted'
            : normalized.visibility;
        const shouldBePublic = visibility === 'public';
        const nextRootTemplateId = normalized.rootTemplateId || doc.id;
        const updates = {
            isPublic: shouldBePublic,
            visibility,
            lineageType: normalized.lineageType,
            parentTemplateId: normalized.parentTemplateId,
            rootTemplateId: nextRootTemplateId,
            distributionStatus: normalized.distributionStatus,
            versionNumber: normalized.versionNumber,
        };
        const data = doc.data();
        const hasChanges = data.isPublic !== shouldBePublic
            || data.visibility !== visibility
            || data.lineageType !== normalized.lineageType
            || data.parentTemplateId !== normalized.parentTemplateId
            || data.rootTemplateId !== nextRootTemplateId
            || data.distributionStatus !== normalized.distributionStatus
            || data.versionNumber !== normalized.versionNumber;
        if (hasChanges) {
            updatedTemplateIds.push(doc.id);
            if (!dryRun) {
                batch.set(doc.ref, Object.assign(Object.assign({}, updates), { updatedAt: now }), { merge: true });
            }
        }
        if (normalized.userId) {
            affectedOwners.add(normalized.userId);
        }
    }
    if (!dryRun && updatedTemplateIds.length > 0) {
        await batch.commit();
        for (const ownerId of affectedOwners) {
            await recalculateAndPersistQuotaForUser(ownerId, now);
        }
    }
    return {
        success: true,
        processed: snapshot.docs.length,
        updated: updatedTemplateIds.length,
        updatedTemplateIds,
        nextCursor: snapshot.docs.length > 0 ? snapshot.docs[snapshot.docs.length - 1].id : null,
        dryRun,
    };
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'migrateTemplateMetadata' }));
exports.migrateTemplateQuotaToLibrary = (0, rateLimiterV1_1.withRateLimit)(async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to migrate template quota');
    }
    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
        throw new https_1.HttpsError('permission-denied', 'Only admins can migrate template quota');
    }
    const batchSize = Math.min(Math.max((_a = request.data.batchSize) !== null && _a !== void 0 ? _a : 50, 1), 100);
    const dryRun = request.data.dryRun === true;
    const startAfterUserId = typeof request.data.startAfterUserId === 'string'
        && request.data.startAfterUserId.trim().length > 0
        ? request.data.startAfterUserId.trim()
        : null;
    const now = admin.firestore.Timestamp.now();
    let query = admin.firestore()
        .collection('users')
        .orderBy(admin.firestore.FieldPath.documentId())
        .limit(batchSize);
    if (startAfterUserId) {
        query = query.startAfter(startAfterUserId);
    }
    const snapshot = await query.get();
    const updatedUserIds = [];
    const userSummaries = [];
    for (const doc of snapshot.docs) {
        const userId = doc.id;
        const accountTier = await getUserAccountTier(userId);
        const counts = await countUserTemplates(userId);
        userSummaries.push({
            userId,
            accountTier,
            libraryEditableCount: counts.libraryEditableCount,
            distributedCount: counts.distributedCount,
        });
        updatedUserIds.push(userId);
        if (!dryRun) {
            await doc.ref.set({
                templateQuota: {
                    maxLibraryTemplates: TEMPLATE_QUOTAS[accountTier].maxLibraryTemplates,
                    usedLibraryTemplates: counts.libraryEditableCount,
                    libraryEditableCount: counts.libraryEditableCount,
                    maxPrivateTemplates: TEMPLATE_QUOTAS[accountTier].maxLibraryTemplates,
                    usedPrivateTemplates: counts.libraryEditableCount,
                    maxSharedTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
                    maxPublicTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
                    usedSharedTemplates: counts.distributedCount,
                    usedPublicTemplates: counts.distributedCount,
                    distributionMetered: false,
                    distributedTemplateCount: counts.distributedCount,
                    lastTemplateQuotaSyncAt: now,
                    lastTemplateQuotaMigrationAt: now,
                },
            }, { merge: true });
        }
    }
    await admin.firestore().collection('template_audit_logs').add({
        action: 'migrate_template_quota_to_library',
        adminUid,
        processedUsers: snapshot.docs.length,
        updatedUsers: updatedUserIds.length,
        timestamp: now,
        status: 'success',
        dryRun,
    });
    return {
        success: true,
        processedUsers: snapshot.docs.length,
        updatedUsers: updatedUserIds.length,
        users: userSummaries,
        nextCursor: snapshot.docs.length > 0 ? snapshot.docs[snapshot.docs.length - 1].id : null,
        dryRun,
    };
}, Object.assign(Object.assign({}, rateLimiterV1_1.RATE_LIMITS.STANDARD), { identifier: 'migrateTemplateQuotaToLibrary' }));
//# sourceMappingURL=createTemplate.js.map