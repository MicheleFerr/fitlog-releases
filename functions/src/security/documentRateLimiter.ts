/**
 * 🔐 SECURITY: Document-Level Rate Limiting (Firestore Triggers)
 *
 * Enforces rate limits on document creation via Firestore triggers.
 * This provides server-side enforcement that cannot be bypassed by clients.
 *
 * Rate Limits:
 * - Body measurements: Max 100/day per user
 * - Consent changes: Max 10/day per user
 *
 * **Why Firestore Triggers?**
 * - Security Rules CANNOT count documents efficiently
 * - Triggers run AFTER document creation, then delete if limit exceeded
 * - Provides audit logging for security monitoring
 *
 * Implemented: 2025-12-27 (Security Audit)
 */

import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions';

const db = admin.firestore();

// ============================================================================
// RATE LIMIT CONFIGURATION
// ============================================================================

interface RateLimitConfig {
  maxPerDay: number;
  collection: string;
  timestampField: string;
  errorMessage: string;
}

const DOCUMENT_RATE_LIMITS: Record<string, RateLimitConfig> = {
  measurements: {
    maxPerDay: 100,
    collection: 'body_measurements',
    timestampField: 'createdAt',
    errorMessage: 'Max 100 measurements per day',
  },
  consent: {
    maxPerDay: 10,
    collection: 'consent_history',
    timestampField: 'createdAt',
    errorMessage: 'Max 10 consent changes per day',
  },
};

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get start of today (UTC) as Firestore Timestamp
 */
function getStartOfDayUTC(): admin.firestore.Timestamp {
  const now = new Date();
  const startOfDay = new Date(Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate(),
    0, 0, 0, 0
  ));
  return admin.firestore.Timestamp.fromDate(startOfDay);
}

/**
 * Count documents created today for a user
 */
async function countTodayDocuments(
  userId: string,
  collection: string,
  timestampField: string
): Promise<number> {
  const startOfDay = getStartOfDayUTC();

  const snapshot = await db
    .collection('users')
    .doc(userId)
    .collection(collection)
    .where(timestampField, '>=', startOfDay)
    .count()
    .get();

  return snapshot.data().count;
}

/**
 * Log rate limit violation to security audit log
 */
async function logRateLimitViolation(
  userId: string,
  limitType: string,
  count: number,
  documentPath: string
): Promise<void> {
  await db.collection('security_audit_log').add({
    type: 'RATE_LIMIT_EXCEEDED',
    userId,
    limitType,
    count,
    limit: DOCUMENT_RATE_LIMITS[limitType]?.maxPerDay,
    documentPath,
    action: 'DOCUMENT_DELETED',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    severity: 'WARNING',
  });

  logger.warn('⚠️ Rate limit exceeded - document deleted', {
    userId: userId.substring(0, 8) + '...',
    limitType,
    count,
    documentPath,
  });
}

// ============================================================================
// FIRESTORE TRIGGERS
// ============================================================================

/**
 * Enforce rate limit on body measurements (Max 100/day)
 *
 * Triggers when a new body measurement is created.
 * Deletes the document if user has exceeded daily limit.
 */
export const enforceMeasurementRateLimit = onDocumentCreated(
  'users/{userId}/body_measurements/{measurementId}',
  async (event) => {
    const { userId, measurementId } = event.params;
    const config = DOCUMENT_RATE_LIMITS.measurements;

    try {
      const count = await countTodayDocuments(
        userId,
        config.collection,
        config.timestampField
      );

      // Note: count includes the just-created document
      if (count > config.maxPerDay) {
        // Delete the document
        await event.data?.ref.delete();

        // Log violation
        await logRateLimitViolation(
          userId,
          'measurements',
          count,
          `users/${userId}/body_measurements/${measurementId}`
        );

        logger.info(`🚫 Measurement deleted: Rate limit exceeded (${count}/${config.maxPerDay})`);
        return;
      }

      logger.debug(`✅ Measurement allowed: ${count}/${config.maxPerDay}`);
    } catch (error) {
      // Fail-open: Don't block on errors
      logger.error('❌ Error checking measurement rate limit', { error });
    }
  }
);

/**
 * Enforce rate limit on consent changes (Max 10/day)
 *
 * Prevents consent toggle abuse (potential GDPR gaming).
 */
export const enforceConsentRateLimit = onDocumentCreated(
  'users/{userId}/consent_history/{consentId}',
  async (event) => {
    const { userId, consentId } = event.params;
    const config = DOCUMENT_RATE_LIMITS.consent;

    try {
      const count = await countTodayDocuments(
        userId,
        config.collection,
        config.timestampField
      );

      if (count > config.maxPerDay) {
        await event.data?.ref.delete();

        await logRateLimitViolation(
          userId,
          'consent',
          count,
          `users/${userId}/consent_history/${consentId}`
        );

        logger.info(`🚫 Consent change deleted: Rate limit exceeded (${count}/${config.maxPerDay})`);
        return;
      }

      logger.debug(`✅ Consent change allowed: ${count}/${config.maxPerDay}`);
    } catch (error) {
      logger.error('❌ Error checking consent rate limit', { error });
    }
  }
);
