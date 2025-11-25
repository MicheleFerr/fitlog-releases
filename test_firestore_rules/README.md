# 🔐 Firestore Security Rules Tests

Automated tests for Firestore security rules, validating that admin checks use **Firebase Custom Claims** instead of email-based whitelists.

## 📋 What We Test

### Admin Custom Claims Security
- ✅ Admin users (with `admin: true` custom claim) can access admin-only resources
- ✅ Non-admin users are denied access to admin-only operations
- ✅ Email-based checks NO LONGER work (security fix validation)

### Covered Rules
- `contribution_reports` read access (admin-only)
- `exercise_reports` status updates (admin-only)
- `exercise_reports` votes updates (all authenticated users)

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase emulators configured (already done in `firebase.json`)

### Installation

```bash
cd test_firestore_rules
npm install
```

### Run Tests

**Option 1: Start emulators manually, then run tests**

```bash
# Terminal 1: Start Firebase emulators
firebase emulators:start

# Terminal 2: Run tests
npm test
```

**Option 2: Run all at once**

```bash
firebase emulators:exec --only firestore,auth "npm test"
```

### Watch Mode (for development)

```bash
npm run test:watch
```

## 📊 Test Coverage

### Current Tests (6 tests)

| Test | Description | Validates |
|------|-------------|-----------|
| Test 1 | Admin can read contribution_reports | Custom claim `admin: true` grants access |
| Test 2 | Non-admin cannot read contribution_reports | Missing custom claim denies access |
| Test 3 | Email alone does NOT grant access | `admin@admin.com` email is NOT enough (security fix) |
| Test 4 | Admin can update exercise_reports status | Custom claim allows status changes |
| Test 5 | Non-admin cannot update status | Missing custom claim denies status changes |
| Test 6 | Non-admin can update votes | Votes are allowed for all authenticated users |

### Expected Output

```
PASS  test_firestore_rules/firestore.test.js
  Admin Custom Claims Tests
    ✓ Admin (custom claim) can read contribution_reports (245 ms)
    ✓ Non-admin user cannot read contribution_reports (182 ms)
    ✓ Email alone (admin@admin.com) does NOT grant admin access (195 ms)
    ✓ Admin (custom claim) can update exercise_reports status (210 ms)
    ✓ Non-admin user cannot update exercise_reports status (198 ms)
    ✓ Non-admin user can update exercise_reports votes (205 ms)

Test Suites: 1 passed, 1 total
Tests:       6 passed, 6 total
```

## 🔧 Configuration

### Firestore Emulator Ports (firebase.json)
- **Firestore**: localhost:8080
- **Auth**: localhost:9099
- **Emulator UI**: localhost:4000

### Test Environment
- Project ID: `gymbro-test`
- Rules file: `../firestore.rules`

## 🎯 Future Test Coverage

Additional tests to add:

### Admin-Only Collections
- [ ] `esercizi` collection (CRUD operations)
- [ ] `exercises` collection (CRUD operations)
- [ ] `exercise_patches` collection (approval/rejection)
- [ ] `exerciseFeedback` collection (admin read access)
- [ ] `userFeedbackStats` collection (admin CRUD)
- [ ] `feedback` collection (admin access)

### Community Features
- [ ] `community_contributions` moderation
- [ ] `community_corrections` approval/rejection
- [ ] `muscle_group_feedback` admin access

### Edge Cases
- [ ] Unauthenticated user access (all denied)
- [ ] User with expired token (denied)
- [ ] User with revoked admin claim (denied)
- [ ] Multiple admins can moderate concurrently

## 📚 References

- [Firebase Rules Unit Testing Docs](https://firebase.google.com/docs/rules/unit-tests)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Custom Claims Best Practices](https://firebase.google.com/docs/auth/admin/custom-claims)

## 🚨 Security Notes

### Why This Matters
Before the fix, admin checks used email whitelists:
```javascript
// ❌ BEFORE (INSECURE)
request.auth.token.email in ['admin@admin.com', 'ferrara-michele@hotmail.it']
```

This was vulnerable because:
- Emails can be changed by users
- APK decompilation could expose email list
- Client-side checks can be bypassed

After the fix, we use Firebase Custom Claims:
```javascript
// ✅ AFTER (SECURE)
request.auth.token.admin == true
```

Custom claims are:
- ✅ Server-side only (set via Admin SDK)
- ✅ Cannot be forged by clients
- ✅ Embedded in ID tokens (validated by Firebase)
- ✅ Refreshed automatically on token refresh

### What These Tests Validate
1. ✅ Custom claims work correctly (Test 1, 4)
2. ✅ Non-admin users are properly denied (Test 2, 5)
3. ✅ **Email alone is NOT enough** (Test 3) ← Most important security validation

## 🛠️ Troubleshooting

### "Connection refused to localhost:8080"
→ Firebase emulators not running. Start with: `firebase emulators:start`

### "Rules file not found"
→ Run tests from `test_firestore_rules/` directory (rules path is `../firestore.rules`)

### Tests fail with "permission denied"
→ Check if rules file has latest custom claims changes (`isAdmin()` helper uses `request.auth.token.admin == true`)

### Import errors (require not defined)
→ Make sure `package.json` has correct Jest configuration with `testEnvironment: node`

## 📝 Contributing

When adding new admin-restricted rules:
1. Update `firestore.rules` to use `isAdmin()` helper
2. Add corresponding test in `firestore.test.js`
3. Run tests to verify: `npm test`
4. Commit both rules and tests together

---

**Last Updated**: 2025-01-24
**Coverage**: 6 tests, 3 collections
**Status**: ✅ All tests passing
