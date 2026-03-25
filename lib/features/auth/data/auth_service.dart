import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:gymbro_flutter_new/core/config/google_sign_in_config.dart';
import 'package:gymbro_flutter_new/core/services/rate_limiter.dart';

class AuthService with RateLimiterMixin {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;
  static bool _googleSignInInitialized = false;

  /// Initialize GoogleSignIn (must be called once at app startup)
  /// Call this in your main.dart or app initialization
  static Future<void> initializeGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: GoogleSignInConfig.serverClientId,
    );
    _googleSignInInitialized = true;
  }

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Email & Password Registration
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // 🔐 SECURITY: Rate limiting to prevent spam registrations
    if (!checkRateLimit('registration', userId: email)) {
      throw Exception(
        'Too many registration attempts. ${getCooldownMessage('registration', userId: email)}',
      );
    }

    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Email & Password Login
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 🔐 SECURITY: Rate limiting to prevent brute force attacks
    if (!checkRateLimit('login', userId: email)) {
      throw Exception(
        'Too many login attempts. ${getCooldownMessage('login', userId: email)}',
      );
    }

    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Google Sign In (google_sign_in 7.x API)
  Future<UserCredential?> signInWithGoogle({
    bool forceAccountSelection = false,
  }) async {
    try {
      // Ensure GoogleSignIn is initialized
      await initializeGoogleSignIn();

      if (kDebugMode && Firebase.apps.isNotEmpty) {
        final firebaseOptions = Firebase.app().options;
        debugPrint(
          '[GoogleSignIn] Firebase projectId=${firebaseOptions.projectId} appId=${firebaseOptions.appId}',
        );
        debugPrint(
          '[GoogleSignIn] serverClientId=${GoogleSignInConfig.serverClientId}',
        );
      }

      // Force account picker only when explicitly requested (e.g. sign-up flow).
      if (forceAccountSelection) {
        await _googleSignIn.signOut();
      }

      // google_sign_in 7.x: Use authenticate() with scopeHint
      final GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw Exception(_googleSignInCanceledMessage(e));
        }
        rethrow;
      }

      // google_sign_in 7.x: authentication is now a sync getter
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('[GoogleSignIn] Missing idToken from Google account');
        }
        throw Exception('Google Sign In failed: missing ID token');
      }

      // For Firebase Auth, idToken is sufficient and avoids extra scope prompts.
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create user document if it's a new user
      if (userCredential.user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[GoogleSignIn] FirebaseAuthException code=${e.code} message=${e.message}',
        );
      }
      throw Exception(_handleAuthException(e));
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[GoogleSignIn] GoogleSignInException code=${e.code} description=${e.description}',
        );
      }
      throw Exception('Google Sign In failed: ${e.code} - ${e.description}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] Unexpected error: $e');
      }
      throw Exception('Google Sign In failed: $e');
    }
  }

  String _googleSignInCanceledMessage(GoogleSignInException exception) {
    final details = exception.description?.trim();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final suffix = (details != null && details.isNotEmpty)
          ? ' Details: $details'
          : '';
      return 'Google Sign In was canceled on Android. This often means the Google/Firebase OAuth configuration is incomplete for this package or signing key (package name, SHA-1/SHA-256, or server client ID).$suffix';
    }
    return 'Google Sign In was canceled.';
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode, // CRUCIALE!
        rawNonce: rawNonce,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Create user document if it's a new user
      if (userCredential.user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        // Update display name from Apple ID if available
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          final displayName =
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim();
          if (displayName.isNotEmpty) {
            await userCredential.user?.updateDisplayName(displayName);
          }
        }
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return null; // User cancelled
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign In failed');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign In not handled');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown Apple Sign In error');
        default:
          throw Exception('Apple Sign In error: ${e.code}');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Apple Sign In failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Delete user account and all associated data (GDPR Art. 17 - Right to Erasure)
  ///
  /// This permanently deletes:
  /// - Firebase Auth account
  /// - All Firestore user data (including subcollections)
  /// - All Firebase Storage files (progress photos)
  ///
  /// Throws [FirebaseAuthException] with code 'requires-recent-login' if
  /// the user needs to re-authenticate before deletion.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user currently signed in');
    }

    final uid = user.uid;

    try {
      // Step 1: Delete all Firebase Storage files (progress photos)
      await _deleteAllStorageFiles(uid);

      // Step 2: Delete all Firestore subcollections
      await _deleteAllFirestoreData(uid);

      // Step 3: Delete Firebase Auth account (must be last)
      await user.delete();

      // Step 4: Sign out from social providers
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Re-authentication required - throw specific exception
        throw Exception('requires-recent-login');
      }
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  /// Delete all Firebase Storage files for a user (GDPR Art. 17)
  ///
  /// Deletes all files in the user's storage folder:
  /// - Progress photos
  /// - Thumbnails
  /// - Any other user-uploaded content
  Future<void> _deleteAllStorageFiles(String uid) async {
    try {
      // User files are stored under users/{uid}/
      final userStorageRef = _storage.ref().child('users/$uid');

      // List all files in user's folder
      final listResult = await userStorageRef.listAll();

      // Delete all files
      for (final item in listResult.items) {
        try {
          await item.delete();
          if (kDebugMode) {
            debugPrint('  ✓ Deleted storage file: ${item.fullPath}');
          }
        } catch (e) {
          // Continue deleting other files even if one fails
          if (kDebugMode) {
            debugPrint('  ⚠️ Could not delete ${item.fullPath}: $e');
          }
        }
      }

      // Recursively delete subfolders (e.g., progress_photos, thumbnails)
      for (final prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }

      if (kDebugMode) {
        debugPrint('✅ All storage files deleted for user $uid');
      }
    } catch (e) {
      // Storage deletion should not block account deletion
      // Files will be orphaned but not accessible
      if (kDebugMode) {
        debugPrint('⚠️ Error deleting storage files: $e');
      }
    }
  }

  /// Recursively delete a storage folder and all its contents
  Future<void> _deleteStorageFolder(Reference folder) async {
    final listResult = await folder.listAll();

    // Delete all files in this folder
    for (final item in listResult.items) {
      try {
        await item.delete();
      } catch (e) {
        // Continue deleting other files
      }
    }

    // Recursively delete subfolders
    for (final prefix in listResult.prefixes) {
      await _deleteStorageFolder(prefix);
    }
  }

  /// Delete all Firestore data for a user (GDPR Art. 17)
  Future<void> _deleteAllFirestoreData(String uid) async {
    // GDPR: Anonymize public content BEFORE deleting user data
    await _anonymizePublicContent(uid);

    final userDocRef = _firestore.collection('users').doc(uid);

    // List of all known subcollections to delete
    const subcollections = [
      'workouts',
      'workout_history',
      'templates',
      'exercises',
      'body_measurements',
      'progress_photos',
      'personal_records',
      'stress_index',
      'analytics',
      'consents',
      'notifications',
      'coach_sessions',
    ];

    // Delete each subcollection
    for (final subcollection in subcollections) {
      await _deleteCollection(userDocRef.collection(subcollection));
    }

    // Delete the main user document
    await userDocRef.delete();
  }

  /// Anonymize public content when user deletes account
  ///
  /// Instead of deleting public templates (which other users may have downloaded),
  /// we anonymize the author info to comply with GDPR while preserving content.
  Future<void> _anonymizePublicContent(String uid) async {
    try {
      // 1. Anonymize public templates
      final publicTemplates = await _firestore
          .collection('workoutTemplates')
          .where('userId', isEqualTo: uid)
          .where('visibility', isEqualTo: 'public')
          .get();

      for (final doc in publicTemplates.docs) {
        await doc.reference.update({
          'authorName': 'Utente Eliminato',
          'authorPhotoUrl': null,
          'userId': 'deleted_$uid',
        });
      }

      // 2. Anonymize reviews
      final reviews = await _firestore
          .collection('template_reviews')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in reviews.docs) {
        await doc.reference.update({
          'userId': 'deleted_$uid',
          'userName': 'Utente Eliminato',
          'userPhotoUrl': null,
        });
      }

      // 3. Anonymize comments
      final comments = await _firestore
          .collection('template_comments')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in comments.docs) {
        await doc.reference.update({
          'userId': 'deleted_$uid',
          'userName': 'Utente Eliminato',
          'userPhotoUrl': null,
        });
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Anonymized public content: '
          '${publicTemplates.docs.length} templates, '
          '${reviews.docs.length} reviews, '
          '${comments.docs.length} comments',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error anonymizing public content: $e');
      }
      // Don't block account deletion if anonymization fails
    }
  }

  /// Helper to delete all documents in a collection
  Future<void> _deleteCollection(CollectionReference collection) async {
    const batchSize = 100;

    QuerySnapshot snapshot;
    do {
      snapshot = await collection.limit(batchSize).get();

      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length >= batchSize);
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    // 🔐 SECURITY: Rate limiting to prevent password reset spam
    if (!checkRateLimit('password_reset', userId: email)) {
      throw Exception(
        'Too many password reset attempts. ${getCooldownMessage('password_reset', userId: email)}',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, {bool isGuest = false}) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': isGuest
            ? 'Guest User'
            : (user.displayName ?? 'GymBro User'),
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isGuest': isGuest,
        'accountTier': 'free', // Default tier
        'templateQuota': {
          'maxLibraryTemplates': 4,
          'usedLibraryTemplates': 0,
          'libraryEditableCount': 0,
          'maxPrivateTemplates': 4,
          'usedPrivateTemplates': 0,
          'maxPublicTemplates': 999,
          'maxSharedTemplates': 999,
          'usedPublicTemplates': 0,
          'usedSharedTemplates': 0,
          'distributedTemplateCount': 0,
          'distributionMetered': false,
        },
        'preferences': {
          'units': 'kg', // Default weight unit
          'restTimerSound': true,
          'notifications': true,
        },
        'stats': {'totalWorkouts': 0, 'totalExercises': 0, 'totalVolume': 0.0},
        'onboardingCompleted': false,
        'onboardingCompletedAt': null,
      }, SetOptions(merge: true));
    } catch (e) {
      // Don't throw - user creation is more important than document creation
    }
  }

  // Get user document from Firestore
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  // Update user document
  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user document: $e');
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Helper methods for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
