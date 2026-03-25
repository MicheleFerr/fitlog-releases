export interface RevenueCatSubscriberResponse {
  subscriber?: {
    entitlements?: Record<string, RevenueCatEntitlement | undefined>;
    subscriptions?: Record<string, RevenueCatSubscription | undefined>;
  };
}

export interface RevenueCatEntitlement {
  expires_date?: string | null;
  product_identifier?: string | null;
}

export interface RevenueCatSubscription {
  store?: string | null;
  unsubscribe_detected_at?: string | null;
  billing_issues_detected_at?: string | null;
}

export interface RevenueCatEntitlementSyncResult {
  accountTier: 'free' | 'premium';
  expiresAt: Date | null;
  isLifetime: boolean;
  willRenew: boolean;
  productId: string | null;
  lastPurchasePlatform: string | null;
}

export async function fetchRevenueCatSubscriber(
  userId: string,
  secretApiKey: string,
): Promise<RevenueCatSubscriberResponse> {
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`,
    {
      headers: {
        Authorization: `Bearer ${secretApiKey}`,
        'Content-Type': 'application/json',
      },
      signal: AbortSignal.timeout(15000),
    },
  );

  if (!response.ok) {
    const responseText = await response.text();
    throw new Error(
      `RevenueCat returned ${response.status}: ${responseText.slice(0, 500)}`,
    );
  }

  return (await response.json()) as RevenueCatSubscriberResponse;
}

export function buildEntitlementSnapshotFromRevenueCat(
  payload: RevenueCatSubscriberResponse,
  entitlementId: string,
): RevenueCatEntitlementSyncResult {
  const entitlement = payload.subscriber?.entitlements?.[entitlementId];

  if (!entitlement) {
    return {
      accountTier: 'free',
      expiresAt: null,
      isLifetime: false,
      willRenew: false,
      productId: null,
      lastPurchasePlatform: null,
    };
  }

  const expiresAt = parseDate(entitlement.expires_date);
  const isLifetime = expiresAt == null;
  const isActive = isLifetime || expiresAt.getTime() > Date.now();
  const productId = entitlement.product_identifier ?? null;
  const subscription = productId
    ? payload.subscriber?.subscriptions?.[productId]
    : undefined;

  return {
    accountTier: isActive ? 'premium' : 'free',
    expiresAt,
    isLifetime,
    willRenew:
      isActive &&
      !isLifetime &&
      !subscription?.unsubscribe_detected_at &&
      !subscription?.billing_issues_detected_at,
    productId,
    lastPurchasePlatform: subscription?.store ?? null,
  };
}

function parseDate(value: string | null | undefined): Date | null {
  if (!value) {
    return null;
  }

  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}
