/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/providers
/// Feature: analytics
/// Type: provider
///
/// Last Used Template Provider - Persists the last selected template ID
/// for the inline add-to-template flow in muscle balance cards.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory provider that stores the last template ID selected by the user
/// when adding exercises from muscle balance suggestions.
///
/// Preselects the same template across multiple MusclePriorityCard instances
/// during the same session, reducing friction for batch operations.
final lastUsedTemplateIdProvider = StateProvider<String?>((ref) => null);
