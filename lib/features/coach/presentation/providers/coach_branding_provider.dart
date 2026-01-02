/// Coach Branding Provider
///
/// Manages coach branding state for PDF customization.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_branding.dart';

/// Provider for coach branding data
final coachBrandingProvider =
    AsyncNotifierProvider<CoachBrandingNotifier, CoachBranding?>(
  CoachBrandingNotifier.new,
);

/// Notifier for managing coach branding state
class CoachBrandingNotifier extends AsyncNotifier<CoachBranding?> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<CoachBranding?> build() async {
    if (_userId == null) return null;
    return _loadBranding();
  }

  /// Load branding from Firestore
  Future<CoachBranding?> _loadBranding() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('coach_settings')
          .doc('branding')
          .get();

      if (!doc.exists || doc.data() == null) {
        // Return default branding with user's ID
        return CoachBranding(
          id: 'branding_$_userId',
          coachId: _userId!,
          businessName: 'My Coaching',
          createdAt: DateTime.now(),
        );
      }

      return CoachBranding.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      // Return default on error
      return CoachBranding(
        id: 'branding_$_userId',
        coachId: _userId!,
        businessName: 'My Coaching',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Save branding to Firestore
  Future<void> saveBranding(CoachBranding branding) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();

    try {
      final data = branding.toJson();
      // Remove id from data (it's the document ID)
      data.remove('id');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('coach_settings')
          .doc('branding')
          .set(data, SetOptions(merge: true));

      state = AsyncValue.data(branding.copyWith(
        updatedAt: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reset branding to defaults
  Future<void> resetToDefaults() async {
    if (_userId == null) return;

    final defaultBranding = CoachBranding(
      id: 'branding_$_userId',
      coachId: _userId!,
      businessName: 'My Coaching',
      createdAt: DateTime.now(),
    );

    await saveBranding(defaultBranding);
  }
}
