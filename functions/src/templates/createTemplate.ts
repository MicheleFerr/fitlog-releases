/**
 * 🔐 SECURITY: Cloud Function for Template Library and Distribution
 *
 * This module keeps Library quota enforcement and distribution lifecycle on the
 * server so monetized editable slots cannot be bypassed by client writes.
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';
import { getEffectiveAccountTier } from '../premium/entitlements';

const TEMPLATE_QUOTAS = {
  free: {
    maxLibraryTemplates: 4,
  },
  premium: {
    maxLibraryTemplates: 999,
  },
} as const;

const LEGACY_DISTRIBUTION_SOFT_CAP = 999;

const VALID_VISIBILITIES = ['private', 'unlisted', 'public'] as const;
const VALID_LINEAGE_TYPES = ['original', 'fork'] as const;
const VALID_DISTRIBUTION_STATUSES = ['active', 'superseded', 'hidden'] as const;
const VALID_REPORT_REASONS = [
  'spam',
  'inappropriate',
  'misleading',
  'copyright',
  'other',
] as const;

type AccountTier = 'free' | 'premium';
type TemplateVisibility = typeof VALID_VISIBILITIES[number];
type TemplateLineageType = typeof VALID_LINEAGE_TYPES[number];
type TemplateDistributionStatus = typeof VALID_DISTRIBUTION_STATUSES[number];
type TemplateReportReason = typeof VALID_REPORT_REASONS[number];

interface TemplateData {
  id: string;
  userId: string;
  name: string;
  description: string;
  exercises: unknown[];
  tags: string[];
  isCustom: boolean;
  isPublic: boolean;
  visibility: TemplateVisibility;
  lineageType: TemplateLineageType;
  parentTemplateId: string | null;
  rootTemplateId: string;
  distributionStatus: TemplateDistributionStatus;
  publishedAt: admin.firestore.Timestamp | null;
  versionNumber: number;
  usageCount: number;
  downloadCount: number;
  forkCount: number;
  reviewCount: number;
  averageRating: number;
  isAnonymous: boolean;
  authorName: string | null;
  authorPhotoUrl: string | null;
  forkedFromTemplateId: string | null;
  originalAuthorName: string | null;
  supersededByTemplateId: string | null;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

interface NormalizedTemplateData {
  id: string;
  userId: string;
  visibility: TemplateVisibility;
  lineageType: TemplateLineageType;
  distributionStatus: TemplateDistributionStatus;
  rootTemplateId: string;
  parentTemplateId: string | null;
  versionNumber: number;
  isPublic: boolean;
  isAnonymous: boolean;
  authorName: string | null;
  authorPhotoUrl: string | null;
  forkedFromTemplateId: string | null;
  originalAuthorName: string | null;
}

interface TemplateCounts {
  libraryEditableCount: number;
  distributedCount: number;
}

interface CreateTemplateData {
  name: string;
  description?: string;
  exercises: unknown[];
  tags?: string[];
  isPublic?: boolean;
  visibility?: TemplateVisibility;
  isAnonymous?: boolean;
}

interface PublishTemplateData {
  templateId: string;
  isAnonymous?: boolean;
}

interface ShareTemplateUnlistedData {
  templateId: string;
  isAnonymous?: boolean;
}

interface ForkTemplateData {
  templateId: string;
}

interface CreateTemplateDraftFromSharedData {
  templateId: string;
}

interface ReportTemplateData {
  templateId: string;
  reason: TemplateReportReason;
  details?: string;
}

interface HideTemplateData {
  templateId: string;
  hideReason?: string;
}

interface MigrateTemplateMetadataData {
  batchSize?: number;
  startAfterId?: string;
  dryRun?: boolean;
}

interface MigrateTemplateQuotaToLibraryData {
  batchSize?: number;
  startAfterUserId?: string;
  dryRun?: boolean;
}

function isValidVisibility(value: unknown): value is TemplateVisibility {
  return typeof value === 'string' && (VALID_VISIBILITIES as readonly string[]).includes(value);
}

function isValidLineageType(value: unknown): value is TemplateLineageType {
  return typeof value === 'string' && (VALID_LINEAGE_TYPES as readonly string[]).includes(value);
}

function isValidDistributionStatus(value: unknown): value is TemplateDistributionStatus {
  return typeof value === 'string' && (VALID_DISTRIBUTION_STATUSES as readonly string[]).includes(value);
}

function resolveRequestedVisibility(data: CreateTemplateData): TemplateVisibility {
  if (isValidVisibility(data.visibility)) {
    return data.visibility;
  }
  return data.isPublic === true ? 'public' : 'private';
}

function normalizeTemplateData(
  raw: FirebaseFirestore.DocumentData | undefined,
  id: string
): NormalizedTemplateData {
  const userId = typeof raw?.userId === 'string' ? raw.userId : '';
  const visibility = isValidVisibility(raw?.visibility)
    ? raw.visibility
    : raw?.isPublic === true
    ? 'public'
    : 'private';
  const lineageType = isValidLineageType(raw?.lineageType)
    ? raw.lineageType
    : typeof raw?.forkedFromTemplateId === 'string' && raw.forkedFromTemplateId.trim().length > 0
    ? 'fork'
    : 'original';
  const distributionStatus = isValidDistributionStatus(raw?.distributionStatus)
    ? raw.distributionStatus
    : 'active';
  const forkedFromTemplateId =
    typeof raw?.forkedFromTemplateId === 'string' && raw.forkedFromTemplateId.trim().length > 0
      ? raw.forkedFromTemplateId.trim()
      : null;
  const parentTemplateId =
    typeof raw?.parentTemplateId === 'string' && raw.parentTemplateId.trim().length > 0
      ? raw.parentTemplateId.trim()
      : lineageType === 'fork'
      ? forkedFromTemplateId
      : null;
  const rootTemplateId =
    typeof raw?.rootTemplateId === 'string' && raw.rootTemplateId.trim().length > 0
      ? raw.rootTemplateId.trim()
      : forkedFromTemplateId ?? id;

  return {
    id,
    userId,
    visibility,
    lineageType,
    distributionStatus,
    rootTemplateId,
    parentTemplateId,
    versionNumber: typeof raw?.versionNumber === 'number' && raw.versionNumber > 0 ? raw.versionNumber : 1,
    isPublic: visibility === 'public',
    isAnonymous: raw?.isAnonymous === true,
    authorName: typeof raw?.authorName === 'string' ? raw.authorName : null,
    authorPhotoUrl: typeof raw?.authorPhotoUrl === 'string' ? raw.authorPhotoUrl : null,
    forkedFromTemplateId,
    originalAuthorName: typeof raw?.originalAuthorName === 'string' ? raw.originalAuthorName : null,
  };
}

function isSharedTemplate(template: NormalizedTemplateData): boolean {
  return template.visibility !== 'private' && template.distributionStatus === 'active';
}

function isDiscoverablePublicTemplate(template: NormalizedTemplateData): boolean {
  return template.visibility === 'public'
    && template.lineageType === 'original'
    && template.distributionStatus === 'active';
}

function countTemplateBuckets(
  docs: Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>>
): TemplateCounts {
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

function buildQuotaPayload(accountTier: AccountTier, counts: TemplateCounts) {
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

function applyQuotaSnapshot(
  transaction: FirebaseFirestore.Transaction,
  userRef: FirebaseFirestore.DocumentReference,
  accountTier: AccountTier,
  counts: TemplateCounts,
  now: admin.firestore.Timestamp,
  metadata: Record<string, unknown> = {}
): void {
  const quotas = TEMPLATE_QUOTAS[accountTier];
  transaction.set(
    userRef,
    {
      templateQuota: {
        maxLibraryTemplates: quotas.maxLibraryTemplates,
        usedLibraryTemplates: counts.libraryEditableCount,
        libraryEditableCount: counts.libraryEditableCount,
        maxPrivateTemplates: quotas.maxLibraryTemplates,
        usedPrivateTemplates: counts.libraryEditableCount,
        maxSharedTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
        maxPublicTemplates: LEGACY_DISTRIBUTION_SOFT_CAP,
        usedSharedTemplates: counts.distributedCount,
        usedPublicTemplates: counts.distributedCount,
        distributionMetered: false,
        distributedTemplateCount: counts.distributedCount,
        lastTemplateQuotaSyncAt: now,
        ...metadata,
      },
    },
    { merge: true }
  );
}

function assertLibraryQuotaAvailable(
  accountTier: AccountTier,
  counts: TemplateCounts,
  requiredAdditionalSlots: number
): void {
  if (requiredAdditionalSlots <= 0) return;
  const quotas = TEMPLATE_QUOTAS[accountTier];
  if (counts.libraryEditableCount + requiredAdditionalSlots > quotas.maxLibraryTemplates) {
    throw new HttpsError(
      'resource-exhausted',
      `Library quota exceeded. You have ${counts.libraryEditableCount}/${quotas.maxLibraryTemplates} editable templates in your Library. ` +
        (accountTier === 'free'
          ? 'Upgrade to Premium for more Library slots.'
          : 'Delete existing Library templates to create new ones.')
    );
  }
}

function getMaxVersionForRoot(
  docs: Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>>,
  rootTemplateId: string
): number {
  let maxVersion = 0;
  for (const doc of docs) {
    const normalized = normalizeTemplateData(doc.data(), doc.id);
    if (normalized.rootTemplateId === rootTemplateId) {
      maxVersion = Math.max(maxVersion, normalized.versionNumber);
    }
  }
  return Math.max(maxVersion, 1);
}

function getActiveSharedSiblings(
  docs: Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>>,
  currentTemplateId: string,
  rootTemplateId: string
): Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>> {
  return docs.filter((doc) => {
    if (doc.id === currentTemplateId) return false;
    const normalized = normalizeTemplateData(doc.data(), doc.id);
    return normalized.rootTemplateId === rootTemplateId && isSharedTemplate(normalized);
  });
}

function hasSharedHistoryForRoot(
  docs: Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>>,
  rootTemplateId: string
): boolean {
  return docs.some((doc) => {
    const normalized = normalizeTemplateData(doc.data(), doc.id);
    return normalized.rootTemplateId === rootTemplateId && normalized.visibility !== 'private';
  });
}

function validateTemplateData(data: CreateTemplateData): { valid: boolean; error?: string } {
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

function validateTemplateId(templateId: unknown): { valid: boolean; error?: string } {
  if (!templateId || typeof templateId !== 'string') {
    return { valid: false, error: 'Template ID is required and must be a string' };
  }
  if (templateId.trim().length === 0) {
    return { valid: false, error: 'Template ID cannot be empty' };
  }
  return { valid: true };
}

function validateReportTemplateData(data: ReportTemplateData): { valid: boolean; error?: string } {
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

async function getUserAccountTier(userId: string): Promise<AccountTier> {
  return getEffectiveAccountTier(userId);
}

async function getAuthorMetadata(
  userId: string,
  isAnonymous: boolean
): Promise<{ authorName: string; authorPhotoUrl: string | null }> {
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
  } catch (error) {
    console.warn(`Failed to resolve author metadata for user ${userId}:`, error);
    return {
      authorName: 'Anonymous',
      authorPhotoUrl: null,
    };
  }
}

function generateTemplateId(): string {
  return admin.firestore().collection('workoutTemplates').doc().id;
}

async function countUserTemplates(userId: string): Promise<TemplateCounts> {
  const snapshot = await admin.firestore()
    .collection('workoutTemplates')
    .where('userId', '==', userId)
    .get();
  return countTemplateBuckets(snapshot.docs);
}

async function isAdmin(uid: string): Promise<boolean> {
  try {
    const user = await admin.auth().getUser(uid);
    return user.customClaims?.admin === true;
  } catch (error) {
    console.error('Error checking admin status:', error);
    return false;
  }
}

async function recalculateAndPersistQuotaForUser(
  userId: string,
  now: admin.firestore.Timestamp
): Promise<TemplateCounts> {
  const accountTier = await getUserAccountTier(userId);
  const counts = await countUserTemplates(userId);
  await admin.firestore().collection('users').doc(userId).set(
    {
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
    },
    { merge: true }
  );
  return counts;
}

function toTemplateDocument(args: {
  templateId: string;
  userId: string;
  name: string;
  description: string;
  exercises: unknown[];
  tags: string[];
  visibility: TemplateVisibility;
  lineageType: TemplateLineageType;
  parentTemplateId?: string | null;
  rootTemplateId?: string;
  distributionStatus?: TemplateDistributionStatus;
  publishedAt?: admin.firestore.Timestamp | null;
  versionNumber?: number;
  usageCount?: number;
  downloadCount?: number;
  forkCount?: number;
  reviewCount?: number;
  averageRating?: number;
  isAnonymous?: boolean;
  authorName?: string | null;
  authorPhotoUrl?: string | null;
  forkedFromTemplateId?: string | null;
  originalAuthorName?: string | null;
  supersededByTemplateId?: string | null;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}): TemplateData {
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
    parentTemplateId: args.parentTemplateId ?? null,
    rootTemplateId: args.rootTemplateId ?? args.templateId,
    distributionStatus: args.distributionStatus ?? 'active',
    publishedAt: args.publishedAt ?? (args.visibility === 'private' ? null : args.updatedAt),
    versionNumber: args.versionNumber ?? 1,
    usageCount: args.usageCount ?? 0,
    downloadCount: args.downloadCount ?? 0,
    forkCount: args.forkCount ?? 0,
    reviewCount: args.reviewCount ?? 0,
    averageRating: args.averageRating ?? 0,
    isAnonymous: args.isAnonymous === true,
    authorName: args.authorName ?? null,
    authorPhotoUrl: args.authorPhotoUrl ?? null,
    forkedFromTemplateId: args.forkedFromTemplateId ?? null,
    originalAuthorName: args.originalAuthorName ?? null,
    supersededByTemplateId: args.supersededByTemplateId ?? null,
    createdAt: args.createdAt,
    updatedAt: args.updatedAt,
  };
}

export const createTemplate = withRateLimit<CreateTemplateData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to create templates');
    }

    const userId = request.auth.uid;
    const data = request.data;
    const validation = validateTemplateData(data);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template data');
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
      description: data.description?.trim() || '',
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

    let nextCounts: TemplateCounts = { libraryEditableCount: 0, distributedCount: 0 };

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const userTemplatesSnapshot = await transaction.get(
          admin.firestore().collection('workoutTemplates').where('userId', '==', userId)
        );

        const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);

        if (requestedVisibility === 'private') {
          assertLibraryQuotaAvailable(accountTier, currentCounts, 1);
          nextCounts = {
            libraryEditableCount: currentCounts.libraryEditableCount + 1,
            distributedCount: currentCounts.distributedCount,
          };
        } else {
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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to create template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'createTemplate' }
);

export const getTemplateQuota = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = request.auth.uid;
  const accountTier = await getUserAccountTier(userId);
  const counts = await countUserTemplates(userId);
  return buildQuotaPayload(accountTier, counts);
});

export const publishTemplate = withRateLimit<PublishTemplateData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to publish templates');
    }

    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template ID');
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
    let nextCounts: TemplateCounts = { libraryEditableCount: 0, distributedCount: 0 };

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
          transaction.get(templateRef),
          transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
        ]);

        if (!templateSnapshot.exists) {
          throw new HttpsError('not-found', 'Template not found');
        }

        const current = normalizeTemplateData(templateSnapshot.data(), templateId);
        const sourceData = templateSnapshot.data()!;
        if (current.userId !== userId) {
          throw new HttpsError('permission-denied', 'Cannot publish a template you do not own');
        }
        if (current.lineageType !== 'original') {
          throw new HttpsError(
            'permission-denied',
            'Templates saved from the Store cannot be published in Store.'
          );
        }
        if (current.distributionStatus !== 'active' && current.visibility !== 'private') {
          throw new HttpsError('failed-precondition', 'Only active templates can be published');
        }

        const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
        const activeSharedSiblings = getActiveSharedSiblings(
          userTemplatesSnapshot.docs,
          templateId,
          current.rootTemplateId
        );

        if (current.visibility === 'private') {
          responseTemplateId = generateTemplateId();
          const nextVersion = hasSharedHistoryForRoot(
            userTemplatesSnapshot.docs,
            current.rootTemplateId
          )
            ? Math.max(
                current.versionNumber,
                getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1
              )
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

          transaction.set(
            admin.firestore().collection('workoutTemplates').doc(responseTemplateId),
            snapshotDoc
          );

          nextCounts = {
            libraryEditableCount: currentCounts.libraryEditableCount,
            distributedCount: currentCounts.distributedCount - activeSharedSiblings.length + 1,
          };
        } else {
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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to publish template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'publishTemplate' }
);

export const shareTemplateUnlisted = withRateLimit<ShareTemplateUnlistedData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to share templates');
    }

    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template ID');
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
    let nextCounts: TemplateCounts = { libraryEditableCount: 0, distributedCount: 0 };

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
          transaction.get(templateRef),
          transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
        ]);

        if (!templateSnapshot.exists) {
          throw new HttpsError('not-found', 'Template not found');
        }

        const current = normalizeTemplateData(templateSnapshot.data(), templateId);
        const sourceData = templateSnapshot.data()!;
        if (current.userId !== userId) {
          throw new HttpsError('permission-denied', 'Cannot share a template you do not own');
        }
        if (current.visibility === 'public') {
          throw new HttpsError('failed-precondition', 'Use the existing public template instead of creating an unlisted copy');
        }

        const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);

        if (current.lineageType === 'original') {
          const activeSharedSiblings = getActiveSharedSiblings(
            userTemplatesSnapshot.docs,
            templateId,
            current.rootTemplateId
          );

          if (current.visibility === 'private') {
            responseTemplateId = generateTemplateId();
            const nextVersion = hasSharedHistoryForRoot(
              userTemplatesSnapshot.docs,
              current.rootTemplateId
            )
              ? Math.max(
                  current.versionNumber,
                  getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1
                )
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

            transaction.set(
              admin.firestore().collection('workoutTemplates').doc(responseTemplateId),
              snapshotDoc
            );

            nextCounts = {
              libraryEditableCount: currentCounts.libraryEditableCount,
              distributedCount: currentCounts.distributedCount - activeSharedSiblings.length + 1,
            };
          } else {
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
        } else {
          if (current.visibility !== 'private') {
            throw new HttpsError(
              'failed-precondition',
              'Only private Library copies can be shared with a code.'
            );
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
          const nextVersion = Math.max(
            current.versionNumber,
            getMaxVersionForRoot(userTemplatesSnapshot.docs, current.rootTemplateId) + 1
          );

          const snapshotDoc = toTemplateDocument({
            templateId: responseTemplateId,
            userId,
            name: typeof templateSnapshot.data()?.name === 'string' ? templateSnapshot.data()!.name : 'Shared Template',
            description:
              typeof templateSnapshot.data()?.description === 'string'
                ? templateSnapshot.data()!.description
                : '',
            exercises: Array.isArray(templateSnapshot.data()?.exercises)
              ? templateSnapshot.data()!.exercises
              : [],
            tags: Array.isArray(templateSnapshot.data()?.tags)
              ? templateSnapshot.data()!.tags
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
            forkedFromTemplateId: current.forkedFromTemplateId ?? current.parentTemplateId ?? current.rootTemplateId,
            originalAuthorName: current.originalAuthorName,
            createdAt: now,
            updatedAt: now,
          });

          transaction.set(
            admin.firestore().collection('workoutTemplates').doc(responseTemplateId),
            snapshotDoc
          );

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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to share template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'shareTemplateUnlisted' }
);

export const forkTemplate = withRateLimit<ForkTemplateData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to save templates');
    }

    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }

    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);

    const sourceRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    const forkId = generateTemplateId();
    let nextCounts: TemplateCounts = { libraryEditableCount: 0, distributedCount: 0 };

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const [sourceSnapshot, userTemplatesSnapshot] = await Promise.all([
          transaction.get(sourceRef),
          transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
        ]);

        if (!sourceSnapshot.exists) {
          throw new HttpsError('not-found', 'Shared template not found');
        }

        const source = normalizeTemplateData(sourceSnapshot.data(), templateId);
        if (!isSharedTemplate(source)) {
          throw new HttpsError('failed-precondition', 'Only shared templates can be saved to your Library');
        }

        const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
        assertLibraryQuotaAvailable(accountTier, currentCounts, 1);

        const sourceData = sourceSnapshot.data()!;
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
          originalAuthorName:
            source.authorName ?? source.originalAuthorName ?? (source.isAnonymous ? 'Utente Anonimo' : null),
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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to fork template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'forkTemplate' }
);

export const createTemplateDraftFromShared = withRateLimit<CreateTemplateDraftFromSharedData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to create drafts');
    }

    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }

    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const accountTier = await getUserAccountTier(userId);
    const draftId = generateTemplateId();
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);
    const userRef = admin.firestore().collection('users').doc(userId);
    let nextCounts: TemplateCounts = { libraryEditableCount: 0, distributedCount: 0 };

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const [templateSnapshot, userTemplatesSnapshot] = await Promise.all([
          transaction.get(templateRef),
          transaction.get(admin.firestore().collection('workoutTemplates').where('userId', '==', userId)),
        ]);

        if (!templateSnapshot.exists) {
          throw new HttpsError('not-found', 'Shared template not found');
        }

        const current = normalizeTemplateData(templateSnapshot.data(), templateId);
        if (current.userId !== userId) {
          throw new HttpsError('permission-denied', 'Cannot create a draft from a template you do not own');
        }
        if (current.visibility === 'private') {
          throw new HttpsError('failed-precondition', 'Template is already editable');
        }
        if (!isSharedTemplate(current)) {
          throw new HttpsError('failed-precondition', 'Only active shared templates can create drafts');
        }

        const currentCounts = countTemplateBuckets(userTemplatesSnapshot.docs);
        assertLibraryQuotaAvailable(accountTier, currentCounts, 1);

        const sourceData = templateSnapshot.data()!;
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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to create draft. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'createTemplateDraftFromShared' }
);

export const reportTemplate = withRateLimit<ReportTemplateData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to report templates');
    }

    const validation = validateReportTemplateData(request.data);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid report payload');
    }

    const userId = request.auth.uid;
    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const reportRef = admin.firestore().collection('template_reports').doc(`${templateId}_${userId}`);
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const [templateSnapshot, existingReportSnapshot] = await Promise.all([
          transaction.get(templateRef),
          transaction.get(reportRef),
        ]);

        if (!templateSnapshot.exists) {
          throw new HttpsError('not-found', 'Template not found');
        }

        const template = normalizeTemplateData(templateSnapshot.data(), templateId);
        if (!isSharedTemplate(template)) {
          throw new HttpsError('failed-precondition', 'Only shared templates can be reported');
        }

        if (existingReportSnapshot.exists) {
          throw new HttpsError('already-exists', 'You have already reported this template');
        }

        transaction.set(reportRef, {
          templateId,
          reporterUserId: userId,
          ownerUserId: template.userId,
          reason: request.data.reason,
          details: request.data.details?.trim() || '',
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
    } catch (error) {
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
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to report template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'reportTemplate' }
);

export const hideTemplate = withRateLimit<HideTemplateData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to hide templates');
    }

    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
      throw new HttpsError('permission-denied', 'Only admins can hide templates');
    }

    const validation = validateTemplateId(request.data.templateId);
    if (!validation.valid) {
      throw new HttpsError('invalid-argument', validation.error || 'Invalid template ID');
    }

    const templateId = request.data.templateId.trim();
    const now = admin.firestore.Timestamp.now();
    const templateRef = admin.firestore().collection('workoutTemplates').doc(templateId);

    try {
      const snapshot = await templateRef.get();
      if (!snapshot.exists) {
        throw new HttpsError('not-found', 'Template not found');
      }

      const template = normalizeTemplateData(snapshot.data(), templateId);
      await templateRef.update({
        distributionStatus: 'hidden',
        hiddenAt: now,
        hiddenBy: adminUid,
        hideReason: request.data.hideReason?.trim() || '',
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
        hideReason: request.data.hideReason?.trim() || '',
        timestamp: now,
        status: 'success',
      });

      return { success: true };
    } catch (error) {
      await admin.firestore().collection('template_audit_logs').add({
        action: 'hide_template',
        templateId,
        adminUid,
        hideReason: request.data.hideReason?.trim() || '',
        timestamp: admin.firestore.Timestamp.now(),
        status: 'error',
        error: String(error),
      });

      console.error('Error hiding template:', error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to hide template. Please try again.');
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'hideTemplate' }
);

export const migrateTemplateMetadata = withRateLimit<MigrateTemplateMetadataData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to migrate templates');
    }

    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
      throw new HttpsError('permission-denied', 'Only admins can migrate template metadata');
    }

    const batchSize = Math.min(Math.max(request.data.batchSize ?? 100, 1), 250);
    const dryRun = request.data.dryRun === true;
    const startAfterId = typeof request.data.startAfterId === 'string'
      && request.data.startAfterId.trim().length > 0
      ? request.data.startAfterId.trim()
      : null;
    const now = admin.firestore.Timestamp.now();

    let query: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> = admin.firestore()
      .collection('workoutTemplates')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(batchSize);

    if (startAfterId) {
      query = query.startAfter(startAfterId);
    }

    const snapshot = await query.get();
    const batch = admin.firestore().batch();
    const updatedTemplateIds: string[] = [];
    const affectedOwners = new Set<string>();

    for (const doc of snapshot.docs) {
      const normalized = normalizeTemplateData(doc.data(), doc.id);
      const visibility = normalized.lineageType === 'fork' && normalized.visibility === 'public'
        ? 'unlisted'
        : normalized.visibility;
      const shouldBePublic = visibility === 'public';
      const nextRootTemplateId = normalized.rootTemplateId || doc.id;
      const updates: Record<string, unknown> = {
        isPublic: shouldBePublic,
        visibility,
        lineageType: normalized.lineageType,
        parentTemplateId: normalized.parentTemplateId,
        rootTemplateId: nextRootTemplateId,
        distributionStatus: normalized.distributionStatus,
        versionNumber: normalized.versionNumber,
      };

      const data = doc.data();
      const hasChanges =
        data.isPublic !== shouldBePublic
        || data.visibility !== visibility
        || data.lineageType !== normalized.lineageType
        || data.parentTemplateId !== normalized.parentTemplateId
        || data.rootTemplateId !== nextRootTemplateId
        || data.distributionStatus !== normalized.distributionStatus
        || data.versionNumber !== normalized.versionNumber;

      if (hasChanges) {
        updatedTemplateIds.push(doc.id);
        if (!dryRun) {
          batch.set(doc.ref, { ...updates, updatedAt: now }, { merge: true });
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
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'migrateTemplateMetadata' }
);

export const migrateTemplateQuotaToLibrary = withRateLimit<MigrateTemplateQuotaToLibraryData>(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to migrate template quota');
    }

    const adminUid = request.auth.uid;
    if (!(await isAdmin(adminUid))) {
      throw new HttpsError('permission-denied', 'Only admins can migrate template quota');
    }

    const batchSize = Math.min(Math.max(request.data.batchSize ?? 50, 1), 100);
    const dryRun = request.data.dryRun === true;
    const startAfterUserId = typeof request.data.startAfterUserId === 'string'
      && request.data.startAfterUserId.trim().length > 0
      ? request.data.startAfterUserId.trim()
      : null;
    const now = admin.firestore.Timestamp.now();

    let query: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> = admin.firestore()
      .collection('users')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(batchSize);

    if (startAfterUserId) {
      query = query.startAfter(startAfterUserId);
    }

    const snapshot = await query.get();
    const updatedUserIds: string[] = [];
    const userSummaries: Array<{
      userId: string;
      accountTier: AccountTier;
      libraryEditableCount: number;
      distributedCount: number;
    }> = [];

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
        await doc.ref.set(
          {
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
          },
          { merge: true }
        );
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
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'migrateTemplateQuotaToLibrary' }
);
