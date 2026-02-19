/**
 * Increment Exercise Popularity - Firestore Trigger
 *
 * Trigger: onCreate on /workoutTemplates/{templateId}
 * Purpose: Increment popularity count for each exercise in template
 *
 * When user saves a template, this increments the global usage counter
 * for each exercise in that template. Popular exercises get boosted
 * in search results.
 *
 * @see docs/design/EXERCISE_POPULARITY_RANKING.md
 */

import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Template exercise structure (from Firestore document)
 */
interface TemplateExercise {
  exerciseId: string;
  // ... other fields not needed for popularity
}

/**
 * Workout template structure (from Firestore document)
 */
interface WorkoutTemplate {
  exercises?: TemplateExercise[];
  // ... other fields not needed for popularity
}

/**
 * Increment popularity count for each exercise when template is created
 *
 * Execution:
 * - Triggered automatically when workout_templates/{templateId} is created
 * - Batch writes popularity increments (atomic operation)
 * - Graceful error handling (template save should not fail)
 *
 * Cost: ~$0.011/month (10k templates × avg 5 exercises × $0.108/100k writes)
 */
export const onTemplateCreated = onDocumentCreated(
  'workoutTemplates/{templateId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn('No data in snapshot');
      return;
    }

    const template = snapshot.data() as WorkoutTemplate;
    const exercises = template.exercises || [];

    if (exercises.length === 0) {
      logger.info('Template has no exercises, skipping popularity update');
      return;
    }

    const templateId = event.params.templateId;
    const db = admin.firestore();
    const batch = db.batch();

    logger.info(`📊 Incrementing popularity for template ${templateId} (${exercises.length} exercises)`);

    // Increment popularity for each exercise in template
    exercises.forEach((exercise) => {
      const popularityRef = db
        .collection('exercise_popularity')
        .doc(exercise.exerciseId);

      // Use merge: true to create document if it doesn't exist
      batch.set(
        popularityRef,
        {
          count: admin.firestore.FieldValue.increment(1),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    try {
      await batch.commit();
      logger.info(`✅ Popularity incremented for ${exercises.length} exercises`);

    } catch (error) {
      logger.error('❌ Popularity increment failed:', error);

      // Log error details for debugging
      if (error instanceof Error) {
        logger.error('   Error message:', error.message);
        logger.error('   Template ID:', templateId);
        logger.error('   Exercise count:', exercises.length);
      }

      // IMPORTANT: Don't throw error - template save should succeed
      // even if popularity increment fails (graceful degradation)
    }
  }
);
