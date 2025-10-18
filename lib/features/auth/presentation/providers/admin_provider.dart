/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// ADMIN PROVIDER
/// Provides admin status checking and admin-only features
///
/// 🔒 SICUREZZA: Questo provider usa Firebase Custom Claims invece di email
/// hardcodate per determinare lo status admin. I custom claims sono gestiti
/// server-side tramite Firebase Admin SDK e non possono essere manipolati
/// dal client.
///
/// Per aggiungere/rimuovere admin, usa:
/// ```bash
/// node scripts/set_admin_custom_claims.js add email@example.com
/// node scripts/set_admin_custom_claims.js remove email@example.com
/// ```
///
/// Vedi: scripts/README_ADMIN_SETUP.md per documentazione completa
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider che verifica se l'utente corrente è admin.
///
/// 🔒 Usa Firebase custom claims invece di email hardcodate.
///
/// I custom claims sono inclusi nel JWT token e sono gestiti server-side
/// da Firebase Admin SDK, quindi non possono essere manipolati dal client.
///
/// ⚠️ IMPORTANTE: Dopo aver impostato/rimosso il claim admin tramite script,
/// l'utente DEVE fare logout e re-login per aggiornare il token JWT.
///
/// Vedi: scripts/README_ADMIN_SETUP.md per gestione admin
final isAdminProvider = StreamProvider<bool>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return false;

    try {
      // Ottieni token con custom claims
      final token = await user.getIdTokenResult();

      // Verifica claim admin
      final isAdmin = token.claims?['admin'] == true;

      if (kDebugMode && isAdmin) {
        debugPrint('✅ Admin access granted for: ${user.email}');
      }

      return isAdmin;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking admin status: $e');
      }
      return false;
    }
  });
});

/// Provider sincrono per verificare admin status (usa cache del token).
///
/// Usa questo quando hai bisogno di un valore sincrono invece di un AsyncValue.
///
/// Esempio:
/// ```dart
/// final isAdmin = ref.watch(isAdminCachedProvider);
/// if (isAdmin) {
///   // Mostra UI admin
/// }
/// ```
final isAdminCachedProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(isAdminProvider);
  return asyncValue.maybeWhen(
    data: (isAdmin) => isAdmin,
    orElse: () => false,
  );
});

/// Provider for debug mode visibility.
///
/// Solo gli admin possono vedere le sezioni debug nell'app.
final showDebugSectionsProvider = Provider<bool>((ref) {
  return ref.watch(isAdminCachedProvider);
});

/// Provider for debug section collapsed state
final debugSectionCollapsedProvider = StateProvider<bool>((ref) => true);

/// Provider for individual debug sections collapsed state
final debugSectionStatesProvider = StateNotifierProvider<DebugSectionStates, Map<String, bool>>((ref) {
  return DebugSectionStates();
});

class DebugSectionStates extends StateNotifier<Map<String, bool>> {
  DebugSectionStates() : super({});

  bool isCollapsed(String sectionId) {
    return state[sectionId] ?? true; // Default to collapsed
  }

  void toggle(String sectionId) {
    state = {
      ...state,
      sectionId: !(state[sectionId] ?? true),
    };
  }

  void expand(String sectionId) {
    state = {
      ...state,
      sectionId: false,
    };
  }

  void collapse(String sectionId) {
    state = {
      ...state,
      sectionId: true,
    };
  }

  void collapseAll() {
    state = state.map((key, value) => MapEntry(key, true));
  }

  void expandAll() {
    state = state.map((key, value) => MapEntry(key, false));
  }
}