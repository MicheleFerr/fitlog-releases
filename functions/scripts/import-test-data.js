#!/usr/bin/env node

/**
 * Import Test Data to Firestore
 *
 * Uses Firebase emulator or production based on FIRESTORE_EMULATOR_HOST
 * Run with: node scripts/import-test-data.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const app = admin.initializeApp({
  projectId: 'gymprogressapp-184bc',
});

const db = admin.firestore();

async function importTestData() {
  console.log('📝 Importing test popularity data to Firestore...\n');

  // Read test data
  const testDataPath = path.join(__dirname, '..', 'test-data.json');
  const testDataRaw = fs.readFileSync(testDataPath, 'utf8');
  const testData = JSON.parse(testDataRaw);

  const batch = db.batch();
  let count = 0;

  for (const [exerciseId, data] of Object.entries(testData)) {
    const ref = db.collection('exercise_popularity').doc(exerciseId);

    batch.set(ref, {
      count: data.count,
      lastUpdated: admin.firestore.Timestamp.fromDate(new Date(data.lastUpdated)),
    });

    console.log(`   ➜ ${exerciseId}: ${data.count} uses`);
    count++;
  }

  try {
    await batch.commit();
    console.log(`\n✅ Successfully imported ${count} popularity documents`);

    // Verify
    const snapshot = await db.collection('exercise_popularity').get();
    console.log(`📊 Total documents in collection: ${snapshot.size}\n`);

    // Show sample
    console.log('Sample documents:');
    snapshot.docs.slice(0, 3).forEach(doc => {
      const data = doc.data();
      console.log(`   ${doc.id}: count=${data.count}, lastUpdated=${data.lastUpdated.toDate().toISOString()}`);
    });

  } catch (error) {
    console.error('\n❌ Import failed:', error.message);
    throw error;
  }
}

// Run
importTestData()
  .then(() => {
    console.log('\n🎉 Import completed successfully!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('\n💥 Import failed:', err);
    process.exit(1);
  });
