import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_auto_fill_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';

final weightAutoFillServiceProvider = Provider<WeightAutoFillService>((ref) {
  return WeightAutoFillService(
    historyService: ref.read(exerciseHistoryServiceProvider),
  );
});
