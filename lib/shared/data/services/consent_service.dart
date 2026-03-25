import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GDPR Consent Service
///
/// Gestisce il consenso GDPR/CCPA usando Google User Messaging Platform (UMP).
///
/// Features:
/// - Mostra consent dialog automaticamente (solo EU/California)
/// - Salva preferenze utente
/// - Reset consent per testing
/// - Check stato consenso
/// - Circuit breaker per prevenire crash ripetuti
class ConsentService {
  factory ConsentService() => _instance;

  ConsentService._internal();
  static final ConsentService _instance = ConsentService._internal();

  // ============================================================================
  // STATE
  // ============================================================================

  ConsentStatus? _consentStatus;
  bool _isConsentFormAvailable = false;

  // ✅ Circuit breaker: disable UMP if it crashes repeatedly
  static const String _prefKeyUmpDisabled = 'ump_disabled';
  static const String _prefKeyUmpCrashCount = 'ump_crash_count';
  static const int _maxCrashCount = 3;
  bool _umpDisabled = false;

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Initialize consent system
  ///
  /// Da chiamare all'avvio dell'app, PRIMA di inizializzare le ads.
  /// Aggiorna sempre lo stato del consenso e, se richiesto, puo mostrare
  /// automaticamente il dialog.
  /// ✅ FIXED: Circuit breaker prevents repeated crashes
  Future<void> initialize({bool autoShowConsentForm = true}) async {
    debugPrint('📋 Initializing GDPR consent...');

    try {
      // ✅ Check circuit breaker first
      await _checkCircuitBreaker();

      if (_umpDisabled) {
        debugPrint(
          '⚠️ UMP SDK disabled due to repeated crashes. Skipping initialization.',
        );
        debugPrint('   App will continue without GDPR consent dialog.');
        return;
      }

      // Request consent information update (convert callback to Future)
      final params = ConsentRequestParameters();

      await _requestConsentInfoUpdate(params);

      // Check if form is available
      _isConsentFormAvailable = await ConsentInformation.instance
          .isConsentFormAvailable();

      _consentStatus = await ConsentInformation.instance.getConsentStatus();

      debugPrint('   - Form available: $_isConsentFormAvailable');
      debugPrint('   - Status: $_consentStatus');

      // On iOS we keep ATT as the only automatic tracking-related prompt.
      // Ad privacy options remain available from Settings.
      final shouldAutoShowConsentForm =
          autoShowConsentForm &&
          _consentStatus == ConsentStatus.required &&
          _isConsentFormAvailable;

      if (shouldAutoShowConsentForm) {
        await _loadAndShowConsentForm();
      } else if (_consentStatus == ConsentStatus.required &&
          _isConsentFormAvailable) {
        debugPrint(
          'ℹ️ Consent form available but not shown automatically. Users can review ad privacy choices from Settings.',
        );
      }

      // ✅ Success: reset crash counter
      await _resetCrashCounter();
    } catch (error) {
      debugPrint('❌ Error initializing consent: $error');

      // ✅ Increment crash counter
      await _incrementCrashCounter();

      // In caso di errore, procedi comunque (non bloccare l'app)
    }
  }

  /// Helper to convert callback-based consent info update to Future
  Future<void> _requestConsentInfoUpdate(
    ConsentRequestParameters params,
  ) async {
    final completer = Completer<void>();

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () {
          // onConsentInfoUpdateSuccess
          if (!completer.isCompleted) {
            debugPrint('✅ Consent info updated successfully');
            completer.complete();
          }
        },
        (error) {
          // onConsentInfoUpdateFailure
          if (!completer.isCompleted) {
            debugPrint('❌ Error updating consent info: ${error.message}');
            completer.completeError(error);
          }
        },
      );

      // Add timeout to prevent hanging
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ Consent info update timed out');
          throw TimeoutException(
            'Consent info update timed out after 30 seconds',
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in consent info update: $e');
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    }
  }

  /// Show consent form manually
  ///
  /// Per permettere all'utente di modificare le preferenze da Settings
  Future<void> showConsentForm() async {
    if (!_isConsentFormAvailable) {
      debugPrint('⚠️ Consent form not available');
      return;
    }

    await _loadAndShowConsentForm();
  }

  /// Reset consent (for testing)
  ///
  /// ⚠️ Solo per testing! Non usare in production.
  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    _consentStatus = null;
    _isConsentFormAvailable = false;
    debugPrint('🔄 Consent reset');
  }

  /// Check if user can request ads
  ///
  /// Uses the official UMP gate so existing consent from previous sessions is
  /// respected after requestConsentInfoUpdate() runs.
  Future<bool> canRequestAds() async {
    return ConsentInformation.instance.canRequestAds();
  }

  /// Check if consent is required
  Future<bool> isConsentRequired() async {
    final status = await ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.required;
  }

  /// Get current consent status
  Future<ConsentStatus> getConsentStatus() async {
    return await ConsentInformation.instance.getConsentStatus();
  }

  /// Check if consent form is available
  bool get isConsentFormAvailable => _isConsentFormAvailable;

  /// Get privacy options requirement status.
  ///
  /// If this returns [PrivacyOptionsRequirementStatus.required], the app
  /// should expose a visible entry point that reopens the privacy options UI.
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async {
    await _checkCircuitBreaker();

    if (_umpDisabled) {
      return PrivacyOptionsRequirementStatus.unknown;
    }

    return ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
  }

  /// Show the UMP privacy options form.
  ///
  /// This lets users revisit and update ad privacy choices from Settings.
  Future<void> showPrivacyOptionsForm() async {
    await _checkCircuitBreaker();

    if (_umpDisabled) {
      throw StateError('UMP SDK is currently disabled.');
    }

    final completer = Completer<void>();

    try {
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          debugPrint(
            '❌ Error showing privacy options form: ${formError.message} (code: ${formError.errorCode})',
          );
          if (!completer.isCompleted) {
            completer.completeError(formError);
          }
          return;
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Privacy options form timed out after 30 seconds',
          );
        },
      );

      await completer.future;
      _isConsentFormAvailable = await ConsentInformation.instance
          .isConsentFormAvailable();
      _consentStatus = await ConsentInformation.instance.getConsentStatus();

      debugPrint(
        '✅ Privacy options form completed. New status: $_consentStatus',
      );
    } catch (error) {
      debugPrint('❌ Error opening privacy options form: $error');
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  Future<void> _loadAndShowConsentForm() async {
    debugPrint('📋 Loading consent form...');

    try {
      // Wrap in timeout to prevent WebView hangs
      await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
        // onConsentFormLoadFailure
        if (formError != null) {
          debugPrint(
            '❌ Error loading consent form: ${formError.message} (code: ${formError.errorCode})',
          );
        }
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ Consent form loading timed out');
          // Don't throw - allow app to continue
        },
      );

      // Update status after form is shown
      _consentStatus = await ConsentInformation.instance.getConsentStatus();

      debugPrint('✅ Consent form completed. New status: $_consentStatus');

      // Check if user can now request ads
      final canRequest = await canRequestAds();
      debugPrint('   Can request ads: $canRequest');
    } catch (error) {
      debugPrint('❌ Error showing consent form: $error');
      // Don't rethrow - allow app to continue even if consent form fails
      // User can still use the app without ads
    }
  }

  /// Check circuit breaker status
  Future<void> _checkCircuitBreaker() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if UMP is disabled
      _umpDisabled = prefs.getBool(_prefKeyUmpDisabled) ?? false;

      if (!_umpDisabled) {
        // Check crash count
        final crashCount = prefs.getInt(_prefKeyUmpCrashCount) ?? 0;
        if (crashCount >= _maxCrashCount) {
          debugPrint(
            '⚠️ UMP crash count ($crashCount) exceeded threshold ($_maxCrashCount)',
          );
          debugPrint('   Disabling UMP SDK to prevent repeated crashes');
          await prefs.setBool(_prefKeyUmpDisabled, true);
          _umpDisabled = true;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error checking circuit breaker: $e');
      // Continue anyway
    }
  }

  /// Increment crash counter
  Future<void> _incrementCrashCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final crashCount = (prefs.getInt(_prefKeyUmpCrashCount) ?? 0) + 1;
      await prefs.setInt(_prefKeyUmpCrashCount, crashCount);
      debugPrint(
        '⚠️ UMP crash count incremented to: $crashCount/$_maxCrashCount',
      );
    } catch (e) {
      debugPrint('⚠️ Error incrementing crash counter: $e');
    }
  }

  /// Reset crash counter after successful initialization
  Future<void> _resetCrashCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_prefKeyUmpCrashCount)) {
        await prefs.remove(_prefKeyUmpCrashCount);
        debugPrint('✅ UMP crash counter reset (successful initialization)');
      }
    } catch (e) {
      debugPrint('⚠️ Error resetting crash counter: $e');
    }
  }

  // ============================================================================
  // SOCIAL CONSENT (Profile visibility for public templates)
  // ============================================================================

  /// Check if user has granted social consent (profile visible on public templates)
  ///
  /// Reads from Firestore: users/{uid}/consents/social
  Future<bool> hasSocialConsent() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('consents')
          .doc('social')
          .get();

      if (!doc.exists) return false;
      return doc.data()?['granted'] == true;
    } catch (e) {
      debugPrint('Error checking social consent: $e');
      return false;
    }
  }

  /// Grant social consent (user agrees to show profile on public templates)
  Future<void> grantSocialConsent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('consents')
        .doc('social')
        .set({
          'granted': true,
          'grantedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Revoke social consent
  Future<void> revokeSocialConsent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('consents')
        .doc('social')
        .set({
          'granted': false,
          'revokedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Print current consent information (for debugging)
  Future<void> printConsentInfo() async {
    if (kDebugMode) {
      final status = await getConsentStatus();
      final canRequest = await canRequestAds();
      final privacyOptionsRequired = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 GDPR Consent Information:');
      debugPrint('   Status: $status');
      debugPrint('   Form available: $_isConsentFormAvailable');
      debugPrint('   Can request ads: $canRequest');
      debugPrint('   Privacy options required: $privacyOptionsRequired');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }
}
