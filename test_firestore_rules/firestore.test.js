/**
 * 🔐 SECURITY: Firestore Rules Tests - Admin Custom Claims Validation
 *
 * Tests verify that admin checks use Firebase Custom Claims instead of email-based checks.
 *
 * **What We Test**:
 * 1. Admin users (with custom claim) can access admin-only resources
 * 2. Non-admin users (without custom claim) are denied access
 * 3. Email-based checks no longer work (security fix validation)
 *
 * **Setup**:
 * ```bash
 * cd test_firestore_rules
 * npm install
 * npm test
 * ```
 *
 * **Requirements**:
 * - Firebase Emulator running: `firebase emulators:start`
 * - Firestore emulator on port 8080
 * - Auth emulator on port 9099
 */

const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { setDoc, getDoc, doc, collection } = require('firebase/firestore');

const PROJECT_ID = 'gymbro-test';

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: 'localhost',
      port: 8080,
      rules: require('fs').readFileSync('../firestore.rules', 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

// ========================================
// 🔐 ADMIN CUSTOM CLAIMS TESTS
// ========================================

describe('Admin Custom Claims Tests', () => {

  // ========================================
  // Test 1: Admin with custom claim can read contribution_reports
  // ========================================
  test('Admin (custom claim) can read contribution_reports', async () => {
    const adminContext = testEnv.authenticatedContext('admin-user-id', {
      admin: true, // 🔐 Custom claim (server-validated)
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'contribution_reports/report1'), {
        reportedBy: 'user123',
        contributionId: 'contrib1',
        reason: 'spam',
        timestamp: new Date(),
      });
    });

    // Test: Admin can read
    const reportRef = doc(adminContext.firestore(), 'contribution_reports/report1');
    await assertSucceeds(getDoc(reportRef));
  });

  // ========================================
  // Test 2: Non-admin user cannot read contribution_reports
  // ========================================
  test('Non-admin user cannot read contribution_reports', async () => {
    const userContext = testEnv.authenticatedContext('regular-user-id', {
      admin: false, // Not admin
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'contribution_reports/report1'), {
        reportedBy: 'user123',
        contributionId: 'contrib1',
        reason: 'spam',
        timestamp: new Date(),
      });
    });

    // Test: Non-admin cannot read
    const reportRef = doc(userContext.firestore(), 'contribution_reports/report1');
    await assertFails(getDoc(reportRef));
  });

  // ========================================
  // Test 3: Admin email alone does NOT grant access (security fix validation)
  // ========================================
  test('Email alone (admin@admin.com) does NOT grant admin access', async () => {
    const userContext = testEnv.authenticatedContext('user-with-admin-email', {
      email: 'admin@admin.com', // Email matches old whitelist
      admin: false, // BUT no custom claim
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'contribution_reports/report1'), {
        reportedBy: 'user123',
        contributionId: 'contrib1',
        reason: 'spam',
        timestamp: new Date(),
      });
    });

    // Test: Email alone is NOT enough (must fail)
    const reportRef = doc(userContext.firestore(), 'contribution_reports/report1');
    await assertFails(getDoc(reportRef));
  });

  // ========================================
  // Test 4: Admin can update exercise_reports status
  // ========================================
  test('Admin (custom claim) can update exercise_reports status', async () => {
    const adminContext = testEnv.authenticatedContext('admin-user-id', {
      admin: true,
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'exercise_reports/report1'), {
        userId: 'user123',
        exerciseId: 'ex1',
        exerciseName: 'Bench Press',
        imageUrl: 'https://example.com/image.jpg',
        reportType: 'wrong_image',
        status: 'pending',
        timestamp: new Date(),
        votes: 0,
      });
    });

    // Test: Admin can update status
    const reportRef = doc(adminContext.firestore(), 'exercise_reports/report1');
    await assertSucceeds(setDoc(reportRef, {
      userId: 'user123',
      exerciseId: 'ex1',
      exerciseName: 'Bench Press',
      imageUrl: 'https://example.com/image.jpg',
      reportType: 'wrong_image',
      status: 'approved', // ✅ Admin changing status
      timestamp: new Date(),
      votes: 0,
    }));
  });

  // ========================================
  // Test 5: Non-admin cannot update exercise_reports status
  // ========================================
  test('Non-admin user cannot update exercise_reports status', async () => {
    const userContext = testEnv.authenticatedContext('regular-user-id', {
      admin: false,
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'exercise_reports/report1'), {
        userId: 'regular-user-id',
        exerciseId: 'ex1',
        exerciseName: 'Bench Press',
        imageUrl: 'https://example.com/image.jpg',
        reportType: 'wrong_image',
        status: 'pending',
        timestamp: new Date(),
        votes: 0,
      });
    });

    // Test: Non-admin cannot change status
    const reportRef = doc(userContext.firestore(), 'exercise_reports/report1');
    await assertFails(setDoc(reportRef, {
      userId: 'regular-user-id',
      exerciseId: 'ex1',
      exerciseName: 'Bench Press',
      imageUrl: 'https://example.com/image.jpg',
      reportType: 'wrong_image',
      status: 'approved', // ❌ Non-admin trying to change status
      timestamp: new Date(),
      votes: 0,
    }));
  });

  // ========================================
  // Test 6: Non-admin can update votes (allowed)
  // ========================================
  test('Non-admin user can update exercise_reports votes', async () => {
    const userContext = testEnv.authenticatedContext('regular-user-id', {
      admin: false,
    });

    // Seed test data
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'exercise_reports/report1'), {
        userId: 'user123',
        exerciseId: 'ex1',
        exerciseName: 'Bench Press',
        imageUrl: 'https://example.com/image.jpg',
        reportType: 'wrong_image',
        status: 'pending',
        timestamp: new Date(),
        votes: 0,
      });
    });

    // Test: Non-admin can update votes (allowed by rules)
    const reportRef = doc(userContext.firestore(), 'exercise_reports/report1');
    await assertSucceeds(setDoc(reportRef, {
      userId: 'user123',
      exerciseId: 'ex1',
      exerciseName: 'Bench Press',
      imageUrl: 'https://example.com/image.jpg',
      reportType: 'wrong_image',
      status: 'pending', // Status unchanged
      timestamp: new Date(),
      votes: 5, // ✅ Votes changed (allowed)
    }));
  });
});

// ========================================
// 📝 TEST COVERAGE SUMMARY
// ========================================
/**
 * COVERED RULES:
 * ✅ contribution_reports read (admin-only via isAdmin())
 * ✅ exercise_reports update status (admin-only via isAdmin())
 * ✅ exercise_reports update votes (allowed for all authenticated users)
 *
 * SECURITY VALIDATIONS:
 * ✅ Admin custom claims work correctly
 * ✅ Non-admin users are denied admin-only operations
 * ✅ Email-based admin checks NO LONGER work (security fix validated)
 *
 * TO ADD (future):
 * - Test other admin-only collections (esercizi, exercises, exercise_patches)
 * - Test community_contributions moderation
 * - Test feedback collections admin access
 */
