import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';

/// Fornisce il peso corporeo piu' recente dell'utente.
/// Ritorna null se non disponibile (il chiamante decide il fallback).
final userBodyweightProvider = FutureProvider.autoDispose<double?>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return null;

  final repo = ref.read(measurementRepositoryProvider);
  final questionnaireWeight = ref
      .watch(userFitnessQuestionnaireProvider)
      ?.bodyweightKg;
  final result = await repo.getLatestMeasurementsByType(userId);
  return result.fold(
    (_) => questionnaireWeight,
    (map) => map[MetricType.weight]?.value ?? questionnaireWeight,
  );
});
