/**
 * GymBro Cloud Functions - Exercise Patches
 * Automatically apply approved patches to exercise database
 *
 * Migrated to Firebase Functions v2 API (2025-12-27)
 */

import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';

/**
 * Cloud Function: Apply approved patches to exercises
 *
 * **Trigger**: Firestore onUpdate for exercise_patches collection
 * **Condition**: status changes from 'pending' to 'approved'
 *
 * **Workflow**:
 * 1. Detect status change to 'approved'
 * 2. Get exercise document from appropriate collection (exercises_en or exercises_it)
 * 3. Apply patch field update
 * 4. Verify update succeeded
 * 5. Log success/failure
 *
 * **Error Handling**:
 * - If exercise not found: Log warning, patch remains approved (orphaned)
 * - If update fails: Log error, patch status unchanged
 * - If field invalid: Log error, skip update
 */
export const applyApprovedPatches = onDocumentUpdated(
  'exercise_patches/{patchId}',
  async (event) => {
    if (!event.data) {
      logger.warn('No data in patch updated event');
      return null;
    }

    const before = event.data.before.data();
    const after = event.data.after.data();
    const patchId = event.params.patchId;

    // Only process if status changed to 'approved'
    if (before.status === 'approved' || after.status !== 'approved') {
      logger.debug(`Patch ${patchId}: Status is ${after.status}, skipping auto-apply`);
      return null;
    }

    logger.info(`Patch ${patchId}: Status changed to 'approved', applying patch`);

    const {
      exerciseId,
      fieldName,
      newValue,
      language,
    } = after;

    // Validate required fields
    if (!exerciseId || !fieldName || !language) {
      logger.error(`Patch ${patchId}: Missing required fields`, {
        exerciseId,
        fieldName,
        language,
      });
      return null;
    }

    // Determine collection based on language
    const collectionName = language === 'it' ? 'exercises_it' : 'exercises_en';
    const exerciseRef = admin.firestore()
      .collection(collectionName)
      .doc(exerciseId);

    try {
      // Get exercise document
      const exerciseDoc = await exerciseRef.get();

      if (!exerciseDoc.exists) {
        logger.warn(`Patch ${patchId}: Exercise ${exerciseId} not found in ${collectionName}`);
        return null;
      }

      // Apply patch: Update single field
      await exerciseRef.update({
        [fieldName]: newValue,
        lastModified: admin.firestore.FieldValue.serverTimestamp(),
        lastModifiedBy: 'patch_system',
      });

      logger.info(`Patch ${patchId}: Successfully applied to ${exerciseId}.${fieldName}`, {
        collection: collectionName,
        oldValue: exerciseDoc.data()?.[fieldName],
        newValue,
      });

      return { success: true, patchId, exerciseId, fieldName };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.error(`Patch ${patchId}: Failed to apply patch`, {
        error: errorMessage,
        exerciseId,
        fieldName,
        collection: collectionName,
      });

      // Don't throw - let patch remain approved for manual investigation
      return { success: false, patchId, error: errorMessage };
    }
  }
);
