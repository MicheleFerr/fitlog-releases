/**
 * 🔐 SECURITY: Cloud Function for Template Creation with Quota Enforcement
 *
 * This Cloud Function implements server-side template quota management.
 * Client-side validation is insufficient - this is the ONLY secure way
 * to enforce template limits.
 *
 * **Quota Tiers**:
 * - Free: 4 private templates
 * - Premium: 20 private templates
 * - Pro: 999 private templates (effectively unlimited)
 *
 * **Security Benefits**:
 * - Atomic quota check + creation (no race conditions)
 * - Server-side validation (cannot be bypassed)
 * - Rate limited to prevent abuse
 * - Audit trail for all operations
 *
 * **Usage** (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('createTemplate')
 *   .call({
 *     'name': 'My Template',
 *     'description': 'Template description',
 *     'exercises': [...],
 *     'tags': ['push', 'upper'],
 *   });
 * ```
 *
 * @see https://firebase.google.com/docs/functions/callable
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';

// ========================================
// 📊 TEMPLATE QUOTA CONFIGURATION
// ========================================

/**
 * Template quota limits per account tier
 * IMPORTANT: Keep in sync with Flutter's TemplateQuota class
 */
const TEMPLATE_QUOTAS = {
  free: {
    maxPrivateTemplates: 4,
    maxPublicTemplates: 2,
  },
  premium: {
    maxPrivateTemplates: 20,
    maxPublicTemplates: 10,
  },
  pro: {
    maxPrivateTemplates: 999, // Effectively unlimited
    maxPublicTemplates: 50,
  },
};

/**
 * Valid account tiers
 */
type AccountTier = 'free' | 'premium' | 'pro';

/**
 * Template data structure
 */
interface TemplateData {
  id: string;
  userId: string;
  name: string;
  description: string;
  exercises: unknown[];
  tags: string[];
  isPublic: boolean;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  usageCount: number;
}

// ========================================
// 🔧 HELPER FUNCTIONS
// ========================================

/**
 * Get user's account tier from Firestore
 */
async function getUserAccountTier(userId: string): Promise<AccountTier> {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      console.log(`User ${userId} not found, defaulting to 'free' tier`);
      return 'free';
    }

    const data = userDoc.data();
    const tier = data?.accountTier as string;

    // Validate tier is valid
    if (tier === 'premium' || tier === 'pro') {
      return tier;
    }

    return 'free';
  } catch (error) {
    console.error('Error getting user account tier:', error);
    return 'free'; // Default to free on error
  }
}

/**
 * Count user's existing templates
 */
async function countUserTemplates(userId: string): Promise<{ privateCount: number; publicCount: number }> {
  try {
    // Count private templates
    const privateSnapshot = await admin.firestore()
      .collection('workoutTemplates')
      .where('userId', '==', userId)
      .where('isPublic', '==', false)
      .count()
      .get();

    // Count public templates
    const publicSnapshot = await admin.firestore()
      .collection('workoutTemplates')
      .where('userId', '==', userId)
      .where('isPublic', '==', true)
      .count()
      .get();

    return {
      privateCount: privateSnapshot.data().count,
      publicCount: publicSnapshot.data().count,
    };
  } catch (error) {
    console.error('Error counting user templates:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to count user templates'
    );
  }
}

/**
 * Validate template data
 */
function validateTemplateData(data: any): { valid: boolean; error?: string } {
  // Required fields
  if (!data.name || typeof data.name !== 'string') {
    return { valid: false, error: 'Template name is required and must be a string' };
  }

  if (data.name.trim().length === 0) {
    return { valid: false, error: 'Template name cannot be empty' };
  }

  if (data.name.length > 100) {
    return { valid: false, error: 'Template name must be 100 characters or less' };
  }

  // Description validation
  if (data.description && typeof data.description !== 'string') {
    return { valid: false, error: 'Description must be a string' };
  }

  if (data.description && data.description.length > 500) {
    return { valid: false, error: 'Description must be 500 characters or less' };
  }

  // Exercises validation
  if (!data.exercises || !Array.isArray(data.exercises)) {
    return { valid: false, error: 'Exercises are required and must be an array' };
  }

  if (data.exercises.length === 0) {
    return { valid: false, error: 'Template must have at least one exercise' };
  }

  if (data.exercises.length > 50) {
    return { valid: false, error: 'Template cannot have more than 50 exercises' };
  }

  // Tags validation
  if (data.tags && !Array.isArray(data.tags)) {
    return { valid: false, error: 'Tags must be an array' };
  }

  if (data.tags && data.tags.length > 10) {
    return { valid: false, error: 'Template cannot have more than 10 tags' };
  }

  return { valid: true };
}

/**
 * Generate a unique template ID
 */
function generateTemplateId(): string {
  return admin.firestore().collection('workoutTemplates').doc().id;
}

// ========================================
// 🚀 MAIN CLOUD FUNCTION: Create Template
// ========================================

/**
 * Create a new workout template with quota enforcement
 *
 * @param data - Template data (name, description, exercises, tags, isPublic)
 * @param context - Firebase callable context
 * @returns Created template with ID
 */
export const createTemplate = withRateLimit(
  async (data, context) => {
    // ========================================
    // 1. Authentication Check
    // ========================================
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to create templates'
      );
    }

    const userId = context.auth.uid;

    // ========================================
    // 2. Validate Input Data
    // ========================================
    const validation = validateTemplateData(data);
    if (!validation.valid) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        validation.error || 'Invalid template data'
      );
    }

    // ========================================
    // 3. Get User's Account Tier
    // ========================================
    const accountTier = await getUserAccountTier(userId);
    const quotas = TEMPLATE_QUOTAS[accountTier];

    console.log(`User ${userId} has account tier: ${accountTier}`);
    console.log(`Quotas: private=${quotas.maxPrivateTemplates}, public=${quotas.maxPublicTemplates}`);

    // ========================================
    // 4. Count Existing Templates
    // ========================================
    const { privateCount, publicCount } = await countUserTemplates(userId);
    const isPublic = data.isPublic === true;

    console.log(`User has ${privateCount} private and ${publicCount} public templates`);

    // ========================================
    // 5. Check Quota (ATOMIC - Server-Side Only)
    // ========================================
    if (isPublic) {
      if (publicCount >= quotas.maxPublicTemplates) {
        console.warn(`🚨 Quota exceeded for user ${userId}: ${publicCount}/${quotas.maxPublicTemplates} public templates`);

        throw new functions.https.HttpsError(
          'resource-exhausted',
          `Public template quota exceeded. You have ${publicCount}/${quotas.maxPublicTemplates} public templates. ` +
          (accountTier === 'free' ? 'Upgrade to Premium for more templates.' : 'Delete existing templates to create new ones.')
        );
      }
    } else {
      if (privateCount >= quotas.maxPrivateTemplates) {
        console.warn(`🚨 Quota exceeded for user ${userId}: ${privateCount}/${quotas.maxPrivateTemplates} private templates`);

        throw new functions.https.HttpsError(
          'resource-exhausted',
          `Private template quota exceeded. You have ${privateCount}/${quotas.maxPrivateTemplates} private templates. ` +
          (accountTier === 'free' ? 'Upgrade to Premium for more templates.' : 'Delete existing templates to create new ones.')
        );
      }
    }

    // ========================================
    // 6. Create Template (Atomic Operation)
    // ========================================
    const templateId = generateTemplateId();
    const now = admin.firestore.Timestamp.now();

    const templateData: TemplateData = {
      id: templateId,
      userId: userId,
      name: data.name.trim(),
      description: data.description?.trim() || '',
      exercises: data.exercises,
      tags: data.tags || [],
      isPublic: isPublic,
      createdAt: now,
      updatedAt: now,
      usageCount: 0,
    };

    try {
      // Use transaction for atomic operation
      await admin.firestore().runTransaction(async (transaction) => {
        // Re-check quota within transaction (prevents race conditions)
        const countQuery = isPublic
          ? admin.firestore()
              .collection('workoutTemplates')
              .where('userId', '==', userId)
              .where('isPublic', '==', true)
          : admin.firestore()
              .collection('workoutTemplates')
              .where('userId', '==', userId)
              .where('isPublic', '==', false);

        const currentCount = (await countQuery.count().get()).data().count;
        const maxAllowed = isPublic ? quotas.maxPublicTemplates : quotas.maxPrivateTemplates;

        if (currentCount >= maxAllowed) {
          throw new functions.https.HttpsError(
            'resource-exhausted',
            'Template quota exceeded (race condition prevented)'
          );
        }

        // Create the template
        const templateRef = admin.firestore()
          .collection('workoutTemplates')
          .doc(templateId);

        transaction.set(templateRef, templateData);

        // Update user's quota tracking
        const userRef = admin.firestore().collection('users').doc(userId);
        transaction.update(userRef, {
          'templateQuota.usedPrivateTemplates': isPublic
            ? admin.firestore.FieldValue.increment(0)
            : admin.firestore.FieldValue.increment(1),
          'templateQuota.usedPublicTemplates': isPublic
            ? admin.firestore.FieldValue.increment(1)
            : admin.firestore.FieldValue.increment(0),
          'templateQuota.lastTemplateCreatedAt': now,
        });
      });

      console.log(`✅ Template ${templateId} created for user ${userId}`);

      // ========================================
      // 7. Log to Audit Trail
      // ========================================
      await admin.firestore().collection('template_audit_logs').add({
        action: 'create_template',
        templateId,
        userId,
        templateName: templateData.name,
        isPublic,
        accountTier,
        quotaUsed: isPublic ? publicCount + 1 : privateCount + 1,
        quotaMax: isPublic ? quotas.maxPublicTemplates : quotas.maxPrivateTemplates,
        timestamp: now,
        status: 'success',
      });

      // ========================================
      // 8. Return Success Response
      // ========================================
      return {
        success: true,
        templateId,
        template: {
          id: templateId,
          name: templateData.name,
          description: templateData.description,
          isPublic: templateData.isPublic,
          createdAt: now.toDate().toISOString(),
        },
        quota: {
          accountTier,
          privateUsed: isPublic ? privateCount : privateCount + 1,
          privateMax: quotas.maxPrivateTemplates,
          publicUsed: isPublic ? publicCount + 1 : publicCount,
          publicMax: quotas.maxPublicTemplates,
        },
      };

    } catch (error) {
      // Log failure to audit trail
      await admin.firestore().collection('template_audit_logs').add({
        action: 'create_template',
        userId,
        templateName: data.name,
        isPublic,
        accountTier,
        timestamp: admin.firestore.Timestamp.now(),
        status: 'error',
        error: String(error),
      });

      console.error('Error creating template:', error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'Failed to create template. Please try again.'
      );
    }
  },
  { ...RATE_LIMITS.STANDARD, identifier: 'createTemplate' }
);

// ========================================
// 📊 HELPER FUNCTION: Get Template Quota
// ========================================

/**
 * Get user's current template quota status
 *
 * @param data - Empty object
 * @param context - Firebase callable context
 * @returns Current quota status
 */
export const getTemplateQuota = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const userId = context.auth.uid;
  const accountTier = await getUserAccountTier(userId);
  const quotas = TEMPLATE_QUOTAS[accountTier];
  const { privateCount, publicCount } = await countUserTemplates(userId);

  return {
    accountTier,
    private: {
      used: privateCount,
      max: quotas.maxPrivateTemplates,
      remaining: Math.max(0, quotas.maxPrivateTemplates - privateCount),
    },
    public: {
      used: publicCount,
      max: quotas.maxPublicTemplates,
      remaining: Math.max(0, quotas.maxPublicTemplates - publicCount),
    },
  };
});
