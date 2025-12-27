/**
 * 🔐 SECURITY: Firebase Custom Claims for Admin Role Management
 *
 * This Cloud Function implements server-side admin role assignment using
 * Firebase Custom Claims instead of client-side email checks.
 *
 * **Security Benefits**:
 * - Custom claims are server-side only (cannot be forged by client)
 * - Validated by Firebase Authentication tokens
 * - Accessible via context.auth.token.admin in security rules
 * - Revocable without password reset
 *
 * **Usage**:
 * 1. First-time setup: Manually call setInitialAdmin() via Firebase Console
 * 2. Subsequent admins: Call setAdminRole() from client (admin-only)
 * 3. Client reads from auth.currentUser.getIdTokenResult().claims.admin
 *
 * @see https://firebase.google.com/docs/auth/admin/custom-claims
 */

import { onCall, onRequest, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { withRateLimit, RATE_LIMITS } from '../security/rateLimiterV1';

/**
 * Whitelist of email addresses allowed to become admins
 *
 * **IMPORTANT**: Update this list via environment variables for production.
 * Set ADMIN_EMAILS in .env or via Firebase Console.
 *
 * Command: firebase functions:secrets:set ADMIN_EMAILS
 */
const ADMIN_EMAIL_WHITELIST = [
  'ferrara-michele@hotmail.it', // Primary admin
];

/**
 * Check if a user is already an admin via custom claims
 */
async function isAdmin(uid: string): Promise<boolean> {
  try {
    const user = await admin.auth().getUser(uid);
    return user.customClaims?.admin === true;
  } catch (error) {
    console.error('Error checking admin status:', error);
    return false;
  }
}

/**
 * Check if an email is in the admin whitelist
 */
function isEmailWhitelisted(email: string | undefined): boolean {
  if (!email) return false;

  // Check environment variable first (production)
  const configEmails = process.env.ADMIN_EMAILS;
  if (configEmails) {
    const whitelistFromConfig = configEmails.split(',').map((e: string) => e.trim());
    return whitelistFromConfig.includes(email);
  }

  // Fallback to hardcoded list (development)
  return ADMIN_EMAIL_WHITELIST.includes(email);
}

/**
 * 🔐 Cloud Function: Set Admin Role (Callable)
 *
 * Allows existing admins to grant admin role to other users.
 *
 * **Security**:
 * - Requires caller to be authenticated
 * - Requires caller to have admin custom claim
 * - Target email must be whitelisted
 * - Logs all operations for audit trail
 *
 * **Request**:
 * ```typescript
 * {
 *   targetEmail: string;  // Email of user to make admin
 * }
 * ```
 *
 * **Response**:
 * ```typescript
 * {
 *   success: boolean;
 *   message: string;
 *   targetUid?: string;  // UID of user granted admin
 * }
 * ```
 *
 * **Example Usage** (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('setAdminRole')
 *   .call({'targetEmail': 'newadmin@example.com'});
 *
 * if (result.data['success']) {
 *   print('Admin role granted to ${result.data['targetUid']}');
 * }
 * ```
 */
// 🔐 SECURITY: Rate limited (5 requests per minute)
export const setAdminRole = withRateLimit(
  async (request: CallableRequest<{ targetEmail: string }>) => {
    // ========================================
    // 1. Authentication Check
    // ========================================
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'User must be authenticated to manage admin roles'
      );
    }

    const callerUid = request.auth.uid;
    const callerEmail = request.auth.token.email;

    // ========================================
    // 2. Authorization Check (Caller must be admin)
    // ========================================
    const callerIsAdmin = await isAdmin(callerUid);

    if (!callerIsAdmin) {
      console.warn(`🚨 Unauthorized admin role assignment attempt by ${callerEmail} (${callerUid})`);
      throw new HttpsError(
        'permission-denied',
        'Only admins can grant admin roles'
      );
    }

    // ========================================
    // 3. Validate Request Data
    // ========================================
    const { targetEmail } = request.data;

    if (!targetEmail || typeof targetEmail !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        'targetEmail is required and must be a string'
      );
    }

    // ========================================
    // 4. Whitelist Check
    // ========================================
    if (!isEmailWhitelisted(targetEmail)) {
      console.warn(`🚨 Admin role denied for non-whitelisted email: ${targetEmail}`);
      throw new HttpsError(
        'permission-denied',
        `Email ${targetEmail} is not in the admin whitelist. Contact system administrator.`
      );
    }

    // ========================================
    // 5. Get Target User by Email
    // ========================================
    let targetUser;
    try {
      targetUser = await admin.auth().getUserByEmail(targetEmail);
    } catch (error) {
      throw new HttpsError(
        'not-found',
        `No user found with email: ${targetEmail}`
      );
    }

    const targetUid = targetUser.uid;

    // ========================================
    // 6. Check if Already Admin
    // ========================================
    if (targetUser.customClaims?.admin === true) {
      console.log(`ℹ️ User ${targetEmail} (${targetUid}) is already an admin`);
      return {
        success: true,
        message: `User ${targetEmail} is already an admin`,
        targetUid,
      };
    }

    // ========================================
    // 7. Set Custom Claims
    // ========================================
    try {
      await admin.auth().setCustomUserClaims(targetUid, {
        admin: true,
        adminGrantedAt: Date.now(),
        adminGrantedBy: callerUid,
      });

      console.log(`✅ Admin role granted to ${targetEmail} (${targetUid}) by ${callerEmail} (${callerUid})`);

      // ========================================
      // 8. Log to Firestore for Audit Trail
      // ========================================
      await admin.firestore().collection('admin_audit_logs').add({
        action: 'grant_admin_role',
        targetEmail,
        targetUid,
        callerEmail,
        callerUid,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: 'success',
      });

      return {
        success: true,
        message: `Admin role granted to ${targetEmail}`,
        targetUid,
      };
    } catch (error) {
      console.error('Error setting admin custom claims:', error);

      // Log failure to audit trail
      await admin.firestore().collection('admin_audit_logs').add({
        action: 'grant_admin_role',
        targetEmail,
        targetUid,
        callerEmail,
        callerUid,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: 'error',
        error: String(error),
      });

      throw new HttpsError(
        'internal',
        'Failed to set admin custom claims. Check server logs.'
      );
    }
  },
  { ...RATE_LIMITS.STRICT, identifier: 'setAdminRole' }
);

/**
 * 🔐 Cloud Function: Revoke Admin Role (Callable)
 *
 * Allows admins to revoke admin role from users.
 *
 * **Security**:
 * - Requires caller to be authenticated
 * - Requires caller to have admin custom claim
 * - Cannot revoke own admin role (prevent lockout)
 * - Logs all operations for audit trail
 *
 * **Request**:
 * ```typescript
 * {
 *   targetEmail: string;  // Email of user to revoke admin from
 * }
 * ```
 */
// 🔐 SECURITY: Rate limited (5 requests per minute)
export const revokeAdminRole = withRateLimit(
  async (request: CallableRequest<{ targetEmail: string }>) => {
    // ========================================
    // 1. Authentication Check
    // ========================================
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'User must be authenticated to revoke admin roles'
      );
    }

    const callerUid = request.auth.uid;
    const callerEmail = request.auth.token.email;

    // ========================================
    // 2. Authorization Check
    // ========================================
    const callerIsAdmin = await isAdmin(callerUid);

    if (!callerIsAdmin) {
      throw new HttpsError(
        'permission-denied',
        'Only admins can revoke admin roles'
      );
    }

    // ========================================
    // 3. Validate Request Data
    // ========================================
    const { targetEmail } = request.data;

    if (!targetEmail || typeof targetEmail !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        'targetEmail is required and must be a string'
      );
    }

    // ========================================
    // 4. Get Target User
    // ========================================
    let targetUser;
    try {
      targetUser = await admin.auth().getUserByEmail(targetEmail);
    } catch (error) {
      throw new HttpsError(
        'not-found',
        `No user found with email: ${targetEmail}`
      );
    }

    const targetUid = targetUser.uid;

    // ========================================
    // 5. Prevent Self-Revocation
    // ========================================
    if (targetUid === callerUid) {
      throw new HttpsError(
        'failed-precondition',
        'Cannot revoke your own admin role (prevents lockout)'
      );
    }

    // ========================================
    // 6. Revoke Custom Claims
    // ========================================
    try {
      await admin.auth().setCustomUserClaims(targetUid, {
        admin: false,
        adminRevokedAt: Date.now(),
        adminRevokedBy: callerUid,
      });

      console.log(`✅ Admin role revoked from ${targetEmail} (${targetUid}) by ${callerEmail} (${callerUid})`);

      // Log to audit trail
      await admin.firestore().collection('admin_audit_logs').add({
        action: 'revoke_admin_role',
        targetEmail,
        targetUid,
        callerEmail,
        callerUid,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: 'success',
      });

      return {
        success: true,
        message: `Admin role revoked from ${targetEmail}`,
        targetUid,
      };
    } catch (error) {
      console.error('Error revoking admin custom claims:', error);
      throw new HttpsError(
        'internal',
        'Failed to revoke admin custom claims. Check server logs.'
      );
    }
  },
  { ...RATE_LIMITS.STRICT, identifier: 'revokeAdminRole' }
);

/**
 * 🔧 Cloud Function: Set Initial Admin (HTTP Trigger - Manual)
 *
 * **ONE-TIME USE ONLY**: Sets up the first admin user via HTTP request.
 *
 * **Security**:
 * - 🔐 Requires ADMIN_SETUP_TOKEN secret (set via Firebase Console or .env)
 * - Rate limited to 3 requests per hour
 * - Should be called ONCE during initial setup
 * - Disable/delete after first admin is created
 *
 * **Setup**:
 * ```bash
 * # Set the secret token in Firebase
 * firebase functions:secrets:set ADMIN_SETUP_TOKEN
 * # Enter a strong random token (e.g., from: openssl rand -hex 32)
 * ```
 *
 * **Usage**:
 * ```bash
 * curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/setInitialAdmin \
 *   -H "Content-Type: application/json" \
 *   -H "X-Admin-Setup-Token: YOUR_SECRET_TOKEN" \
 *   -d '{"email":"ferrara-michele@hotmail.it"}'
 * ```
 *
 * **IMPORTANT**: After creating first admin, delete this function from index.ts export
 */
export const setInitialAdmin = onRequest(
  { secrets: ['ADMIN_SETUP_TOKEN'] },
  async (req, res) => {
  // ========================================
  // 1. Validate Request Method
  // ========================================
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed. Use POST.');
    return;
  }

  // ========================================
  // 2. 🔐 SECURITY: Verify Setup Token
  // ========================================
  const setupToken = req.headers['x-admin-setup-token'];
  const expectedToken = process.env.ADMIN_SETUP_TOKEN;

  // If no token is configured, block all requests (fail-secure)
  if (!expectedToken) {
    console.error('🚨 SECURITY: ADMIN_SETUP_TOKEN not configured. Blocking request.');
    res.status(503).json({
      success: false,
      error: 'Admin setup not configured. Set ADMIN_SETUP_TOKEN secret first.',
    });
    return;
  }

  // Validate token
  if (!setupToken || setupToken !== expectedToken) {
    console.warn('🚨 SECURITY: Invalid admin setup token attempt', {
      ip: req.ip,
      hasToken: !!setupToken,
    });
    res.status(401).json({
      success: false,
      error: 'Invalid or missing X-Admin-Setup-Token header',
    });
    return;
  }

  // ========================================
  // 3. Get Email or UID from Request
  // ========================================
  const { email, uid } = req.body;

  if ((!email || typeof email !== 'string') && (!uid || typeof uid !== 'string')) {
    res.status(400).json({
      success: false,
      error: 'Either email or uid is required in request body',
    });
    return;
  }

  // ========================================
  // 4. Get User by Email or UID
  // ========================================
  let user;
  try {
    if (uid) {
      // Get user by UID directly
      user = await admin.auth().getUser(uid);
    } else {
      // Get user by email
      user = await admin.auth().getUserByEmail(email);
    }
  } catch (error) {
    res.status(404).json({
      success: false,
      error: uid ? `No user found with UID: ${uid}` : `No user found with email: ${email}`,
    });
    return;
  }

  // ========================================
  // 5. Whitelist Check (verify user's email is whitelisted)
  // ========================================
  if (!isEmailWhitelisted(user.email)) {
    res.status(403).json({
      success: false,
      error: `Email ${user.email} is not in admin whitelist`,
    });
    return;
  }

  // ========================================
  // 6. Set Custom Claims
  // ========================================
  try {
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: true,
      adminGrantedAt: Date.now(),
      adminGrantedBy: 'system',
    });

    console.log(`✅ Initial admin role granted to ${user.email} (${user.uid})`);

    // Log to audit trail
    await admin.firestore().collection('admin_audit_logs').add({
      action: 'grant_initial_admin',
      targetEmail: user.email,
      targetUid: user.uid,
      callerEmail: 'system',
      callerUid: 'system',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      status: 'success',
    });

    res.status(200).json({
      success: true,
      message: `Initial admin role granted to ${user.email}`,
      uid: user.uid,
      email: user.email,
    });
  } catch (error) {
    console.error('Error setting initial admin:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to set initial admin. Check server logs.',
    });
  }
});

/**
 * 🔍 Cloud Function: Check Admin Status (Callable)
 *
 * Allows authenticated users to check their own admin status.
 *
 * **Returns**:
 * ```typescript
 * {
 *   isAdmin: boolean;
 *   customClaims?: Record<string, any>;
 * }
 * ```
 */
export const checkAdminStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const uid = request.auth.uid;
  const userIsAdmin = await isAdmin(uid);

  return {
    isAdmin: userIsAdmin,
    customClaims: request.auth.token,
  };
});
