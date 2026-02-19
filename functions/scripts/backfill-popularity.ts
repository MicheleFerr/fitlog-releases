/**
 * Backfill Exercise Popularity Data
 *
 * One-time script to populate exercise_popularity collection
 * from existing workoutTemplates documents.
 *
 * Run with: npx ts-node scripts/backfill-popularity.ts
 *
 * Why: The onTemplateCreated trigger was listening to wrong collection
 * name (workout_templates vs workoutTemplates), so popularity data
 * was never generated. This script backfills from existing templates.
 */

import * as admin from 'firebase-admin';

// Initialize with service account (uses GOOGLE_APPLICATION_CREDENTIALS or default)
admin.initializeApp({
  projectId: 'gymprogressapp-184bc',
});

const db = admin.firestore();

interface ExerciseCounts {
  [exerciseId: string]: number;
}

async function backfillPopularity() {
  console.log('📊 Starting popularity backfill from workoutTemplates...\n');

  // 1. Fetch all templates
  const templatesSnapshot = await db.collection('workoutTemplates').get();
  console.log(`📝 Found ${templatesSnapshot.size} templates\n`);

  if (templatesSnapshot.empty) {
    console.log('No templates found. Nothing to backfill.');
    process.exit(0);
  }

  // 2. Count exercise usage across all templates
  const exerciseCounts: ExerciseCounts = {};
  let totalExercises = 0;

  for (const doc of templatesSnapshot.docs) {
    const data = doc.data();
    const exercises = data.exercises || [];

    for (const exercise of exercises) {
      const exerciseId = exercise.exerciseId;
      if (exerciseId && typeof exerciseId === 'string') {
        exerciseCounts[exerciseId] = (exerciseCounts[exerciseId] || 0) + 1;
        totalExercises++;
      }
    }
  }

  const uniqueExercises = Object.keys(exerciseCounts).length;
  console.log(`📈 Found ${uniqueExercises} unique exercises (${totalExercises} total uses)\n`);

  // 3. Write to exercise_popularity collection in batches (max 500 per batch)
  const entries = Object.entries(exerciseCounts);
  const BATCH_SIZE = 500;
  let written = 0;

  for (let i = 0; i < entries.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const chunk = entries.slice(i, i + BATCH_SIZE);

    for (const [exerciseId, count] of chunk) {
      const ref = db.collection('exercise_popularity').doc(exerciseId);
      batch.set(ref, {
        count: count,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    written += chunk.length;
    console.log(`   ✅ Written ${written}/${uniqueExercises} documents`);
  }

  // 4. Print top 10 most popular
  console.log('\n📊 Top 10 most popular exercises:');
  const sorted = entries.sort((a, b) => b[1] - a[1]);
  for (const [exerciseId, count] of sorted.slice(0, 10)) {
    console.log(`   ${count}x  ${exerciseId}`);
  }

  // 5. Verify
  const verifySnapshot = await db.collection('exercise_popularity').get();
  console.log(`\n✅ Backfill complete! ${verifySnapshot.size} documents in exercise_popularity`);

  process.exit(0);
}

backfillPopularity().catch((err) => {
  console.error('❌ Backfill failed:', err);
  process.exit(1);
});
