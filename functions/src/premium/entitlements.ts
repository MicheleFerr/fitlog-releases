import * as admin from 'firebase-admin';

export type AccountTier = 'free' | 'premium';
export type EntitlementPlan = 'monthly' | 'yearly' | 'lifetime' | null;

export interface ApplyPremiumEntitlementsInput {
  accountTier: AccountTier;
  source: 'revenuecat' | 'store_verification' | 'admin';
  expiresAt?: Date | null;
  willRenew?: boolean;
  isLifetime?: boolean;
  productId?: string | null;
  lastPurchaseId?: string | null;
  lastPurchasePlatform?: string | null;
  lastPurchaseProductId?: string | null;
}

export interface PremiumEntitlementSnapshot {
  accountTier: AccountTier;
  premiumActive: boolean;
  plan: EntitlementPlan;
  expiresAt: Date | null;
  willRenew: boolean;
  isLifetime: boolean;
  productId: string | null;
  source: ApplyPremiumEntitlementsInput['source'];
}

const USERS_COLLECTION = 'users';
const USER_ENTITLEMENTS_COLLECTION = 'user_entitlements';
const LEGACY_DISTRIBUTION_SOFT_CAP = 999;

const TEMPLATE_QUOTAS: Record<AccountTier, { maxLibraryTemplates: number }> = {
  free: { maxLibraryTemplates: 4 },
  premium: { maxLibraryTemplates: 999 },
};

export async function getEffectiveAccountTier(
  userId: string,
): Promise<AccountTier> {
  try {
    const entitlementsDoc = await admin
      .firestore()
      .collection(USER_ENTITLEMENTS_COLLECTION)
      .doc(userId)
      .get();

    if (entitlementsDoc.exists) {
      const data = entitlementsDoc.data();
      if (data?.premiumActive === true || data?.accountTier === 'premium') {
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

    return normalizeAccountTier(userDoc.data()?.['accountTier']);
  } catch (error) {
    console.error('Error resolving effective account tier:', error);
    return 'free';
  }
}

export async function applyPremiumEntitlements(
  userId: string,
  input: ApplyPremiumEntitlementsInput,
): Promise<PremiumEntitlementSnapshot> {
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
  const expiresAt = input.expiresAt ?? null;
  const plan = inferEntitlementPlan(input.productId, input.isLifetime ?? false);
  const willRenew = premiumActive && !(input.isLifetime ?? false) && (input.willRenew ?? false);
  const activatedAt =
    readTimestamp(userData?.['premiumActivatedAt']) ??
    readTimestamp(entitlementsData?.['premiumActivatedAt']);

  const batch = db.batch();
  const expiresTimestamp = expiresAt
    ? admin.firestore.Timestamp.fromDate(expiresAt)
    : null;

  const entitlementUpdate: Record<string, unknown> = {
    accountTier: input.accountTier,
    premiumActive,
    plan,
    expiresAt: expiresTimestamp,
    willRenew,
    isLifetime: input.isLifetime ?? false,
    productId: input.productId ?? null,
    source: input.source,
    lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
    revenueCatAppUserId: userId,
    lastPurchaseId: input.lastPurchaseId ?? null,
    lastPurchasePlatform: input.lastPurchasePlatform ?? null,
    lastPurchaseProductId: input.lastPurchaseProductId ?? input.productId ?? null,
  };

  if (premiumActive) {
    entitlementUpdate.premiumActivatedAt =
      activatedAt ?? admin.firestore.FieldValue.serverTimestamp();
    entitlementUpdate.premiumExpiredAt = admin.firestore.FieldValue.delete();
  } else {
    entitlementUpdate.premiumExpiredAt =
      admin.firestore.FieldValue.serverTimestamp();
  }

  const userUpdate: Record<string, unknown> = {
    accountTier: input.accountTier,
    templateQuota: quota,
    premiumExpiresAt: expiresTimestamp,
    lastPurchaseId: input.lastPurchaseId ?? null,
    lastPurchasePlatform: input.lastPurchasePlatform ?? null,
    lastPurchaseProductId: input.lastPurchaseProductId ?? input.productId ?? null,
  };

  if (premiumActive) {
    userUpdate.premiumActivatedAt =
      activatedAt ?? admin.firestore.FieldValue.serverTimestamp();
    userUpdate.premiumExpiredAt = admin.firestore.FieldValue.delete();
  } else {
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
    isLifetime: input.isLifetime ?? false,
    productId: input.productId ?? null,
    source: input.source,
  };
}

export async function downgradeExpiredEntitlements(): Promise<number> {
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
  const userSnapshots = await Promise.all(
    expiredSnapshots.docs.map((doc) =>
      db.collection(USERS_COLLECTION).doc(doc.id).get(),
    ),
  );
  const userDataById = new Map(
    userSnapshots.map((snapshot) => [snapshot.id, snapshot.data()]),
  );

  expiredSnapshots.forEach((doc) => {
    const userId = doc.id;
    batch.set(
      doc.ref,
      {
        accountTier: 'free',
        premiumActive: false,
        willRenew: false,
        premiumExpiredAt: now,
        lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    batch.set(
      db.collection(USERS_COLLECTION).doc(userId),
      {
        accountTier: 'free',
        templateQuota: buildTemplateQuota(userDataById.get(userId), 'free'),
        premiumExpiredAt: now,
      },
      { merge: true },
    );
  });

  await batch.commit();
  return expiredSnapshots.size;
}

export function normalizeAccountTier(rawTier: unknown): AccountTier {
  return rawTier === 'premium' || rawTier === 'pro' ? 'premium' : 'free';
}

function inferEntitlementPlan(
  productId: string | null | undefined,
  isLifetime: boolean,
): EntitlementPlan {
  if (isLifetime) {
    return 'lifetime';
  }

  if (!productId) {
    return null;
  }

  const normalized = productId.toLowerCase();
  if (
    normalized.includes('year') ||
    normalized.includes('annual') ||
    normalized.includes('annua')
  ) {
    return 'yearly';
  }

  if (normalized.includes('month') || normalized.includes('mens')) {
    return 'monthly';
  }

  return null;
}

function buildTemplateQuota(
  userData: Record<string, unknown> | undefined,
  accountTier: AccountTier,
): Record<string, unknown> {
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

function readCurrentTemplateUsage(
  userData: Record<string, unknown> | undefined,
): { library: number; distribution: number } {
  if (!userData) {
    return { library: 0, distribution: 0 };
  }

  const rawQuota = toRecord(userData['templateQuota']);
  if (rawQuota) {
    return {
      library: readCount(
        rawQuota['usedLibraryTemplates'] ??
          rawQuota['libraryEditableCount'] ??
          rawQuota['usedPrivateTemplates'],
      ),
      distribution: readCount(
        rawQuota['distributedTemplateCount'] ??
          rawQuota['usedPublicTemplates'] ??
          rawQuota['usedSharedTemplates'],
      ),
    };
  }

  const rawStats = toRecord(userData['stats']);
  return {
    library: readCount(rawStats?.['privateTemplateCount']),
    distribution: readCount(rawStats?.['publicTemplateCount']),
  };
}

function readCount(value: unknown): number {
  if (typeof value === 'number') {
    return Math.trunc(value);
  }
  return 0;
}

function toRecord(
  value: unknown,
): Record<string, unknown> | undefined {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return undefined;
  }
  return value as Record<string, unknown>;
}

function readTimestamp(
  value: unknown,
): admin.firestore.Timestamp | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }
  return null;
}
