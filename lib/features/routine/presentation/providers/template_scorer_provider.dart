/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// TEMPLATE SCORER PROVIDER - Use Case Integration
///
/// Provides Riverpod provider for TemplateScorer UseCase.
/// Used to score workout templates against muscle group coverage (0.0-1.0).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/usecases/template_scorer.dart';

// ──────────────────────────────────────────────────────────────────────────
// TEMPLATE SCORER USE CASE PROVIDER
// ──────────────────────────────────────────────────────────────────────────

/// Template scorer use case provider (singleton)
///
/// Usage:
/// ```dart
/// final scorer = ref.read(templateScorerProvider);
/// final score = scorer.scoreTemplate(
///   template: myTemplate,
///   desiredMuscleGroups: {'Chest', 'Triceps', 'Shoulders'},
/// );
/// ```
final templateScorerProvider = Provider<TemplateScorer>((ref) {
  return TemplateScorer();
});
