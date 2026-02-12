/**
 * Create Test Popularity Data using Firebase CLI credentials
 *
 * Run with: node scripts/create-test-data-cli.js
 */

const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

const PROJECT_ID = 'gymprogressapp-184bc';
const COLLECTION = 'exercise_popularity';

const testData = {
  'squat_full_bilanciere': { count: 150 },
  'panca_piana_bilanciere': { count: 120 },
  'stacco_terra_bilanciere': { count: 100 },
  'military_press': { count: 80 },
  'trazioni_sbarra': { count: 60 },
};

async function getAccessToken() {
  try {
    // Try firebase login:ci first (non-interactive token)
    const { stdout } = await execPromise('firebase login:ci --no-localhost 2>&1 || echo ""');
    const match = stdout.match(/[\w-]+\.[\w-]+\.[\w-]+/); // JWT token pattern
    if (match) return match[0];

    // Fallback: use application default credentials
    const { stdout: tokenOut } = await execPromise('firebase login:use --token');
    return tokenOut.trim();
  } catch (error) {
    console.error('❌ Error getting access token. Make sure you are logged into Firebase CLI.');
    throw error;
  }
}

async function createDocument(exerciseId, data, token) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${exerciseId}`;

  const payload = {
    fields: {
      count: { integerValue: data.count.toString() },
      lastUpdated: { timestampValue: new Date().toISOString() },
    },
  };

  const curlCommand = `curl -s -X PATCH "${url}" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    -d '${JSON.stringify(payload)}'`;

  try {
    await execPromise(curlCommand);
    console.log(`   ✅ Created ${exerciseId}: ${data.count} uses`);
  } catch (error) {
    console.error(`   ❌ Failed to create ${exerciseId}:`, error.message);
  }
}

async function main() {
  console.log('📝 Creating test popularity data using Firebase REST API...\n');

  const token = await getAccessToken();

  for (const [exerciseId, data] of Object.entries(testData)) {
    await createDocument(exerciseId, data, token);
  }

  console.log('\n✅ Test data creation completed!');
  console.log('\n📊 Verify with: firebase firestore:get exercise_popularity');
}

main().catch((err) => {
  console.error('\n❌ Script failed:', err.message);
  process.exit(1);
});
