/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/providers
/// 🎯 Feature: firebase
/// 🔧 Type: provider
/// 📱 Platform: Universal
///
/// CANONICAL Firebase providers - Single Source of Truth
///
/// Consolidates duplicate providers from:
/// - features/notifications/presentation/providers/notification_settings_provider_v2.dart
/// - features/feedback/presentation/providers/unified_feedback_provider.dart
/// - features/admin/presentation/providers/exercise_review_provider.dart
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// CANONICAL Provider for FirebaseFirestore
///
/// Use this throughout the app instead of creating local providers.
/// This ensures a single source of truth for Firestore access.
///
/// Example usage:
/// ```dart
/// import 'package:gymbro_flutter_new/core/providers/firebase_providers.dart';
///
/// final myProvider = Provider((ref) {
///   final firestore = ref.watch(firestoreProvider);
///   return MyService(firestore);
/// });
/// ```
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
