/**
 * Create Test Popularity Data
 *
 * Creates test documents in exercise_popularity collection
 * Run with: npx ts-node scripts/create-test-data.ts
 */

import * as admin from 'firebase-admin';

// Initialize with project ID
admin.initializeApp({
  projectId: 'gymprogressapp-184bc',
});

const db = admin.firestore();

const testData = {
  'squat_full_bilanciere': { count: 150 },
  'panca_piana_bilanciere': { count: 120 },
  'stacco_terra_bilanciere': { count: 100 },
  'military_press': { count: 80 },
  'trazioni_sbarra': { count: 60 },
};

async function createTestData() {
  console.log('📝 Creating test popularity data...');

  const batch = db.batch();

  Object.entries(testData).forEach(([exerciseId, data]) => {
    const ref = db.collection('exercise_popularity').doc(exerciseId);
    batch.set(ref, {
      count: data.count,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`   ➜ ${exerciseId}: ${data.count} uses`);
  });

  await batch.commit();
  console.log('✅ Created 5 test popularity documents in Firestore');

  // Verify
  const snapshot = await db.collection('exercise_popularity').get();
  console.log(`\n📊 Total popularity documents: ${snapshot.size}`);

  process.exit(0);
}

createTestData().catch((err) => {
  console.error('❌ Error creating test data:', err);
  process.exit(1);
});
