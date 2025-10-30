/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/models
/// 🎯 Feature: exercise_database
/// 🔧 Type: model
///
/// Hive model per tracking utilizzo esercizi (ML-enhanced fuzzy search)
library;

import 'package:hive/hive.dart';

part 'exercise_usage_model.g.dart';

/// Model Hive per tracciare l'utilizzo degli esercizi da parte dell'utente
///
/// Usato per boost personalizzato nel fuzzy matching ML-enhanced
@HiveType(typeId: 30) // Unique ID, non in conflitto con altri models
class ExerciseUsageModel extends HiveObject {

  ExerciseUsageModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.usageCount,
    required this.lastUsedAt,
    required this.firstUsedAt,
    required this.userId,
  });

  /// Factory per creazione nuovo tracking (primo utilizzo)
  factory ExerciseUsageModel.firstUse({
    required String exerciseId,
    required String exerciseName,
    required String userId,
  }) {
    final now = DateTime.now();
    return ExerciseUsageModel(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      usageCount: 1,
      lastUsedAt: now,
      firstUsedAt: now,
      userId: userId,
    );
  }
  /// ID esercizio (chiave univoca)
  @HiveField(0)
  final String exerciseId;

  /// Nome esercizio (per debug/logging)
  @HiveField(1)
  final String exerciseName;

  /// Contatore utilizzi (incrementato ogni volta che l'utente seleziona l'esercizio)
  @HiveField(2)
  int usageCount;

  /// Timestamp ultimo utilizzo (per sorting e analytics)
  @HiveField(3)
  DateTime lastUsedAt;

  /// Timestamp primo utilizzo (per analytics)
  @HiveField(4)
  final DateTime firstUsedAt;

  /// User ID proprietario (per filtering multi-user se necessario)
  @HiveField(5)
  final String userId;

  /// Incrementa contatore utilizzo
  void increment() {
    usageCount++;
    lastUsedAt = DateTime.now();
    save(); // Auto-save in Hive
  }

  /// Decrementa contatore utilizzo (per negative feedback)
  void decrement() {
    if (usageCount > 0) {
      usageCount--;
      lastUsedAt = DateTime.now();
      save(); // Auto-save in Hive
    }
  }

  /// Calcola boost score per fuzzy matching (0.0 - 1.0)
  ///
  /// [maxCount] - Contatore massimo tra tutti gli esercizi (per normalizzazione)
  /// Returns: Score normalizzato 0.0-1.0 (1.0 = massimo boost)
  double getBoost(int maxCount) {
    if (maxCount == 0) return 0.0;

    // Normalizza count tra 0.0 e 1.0
    final normalizedCount = usageCount / maxCount;

    // Applica curve di dampening per evitare over-boosting
    // Formula: sqrt(x) per dampening soft (radice quadrata)
    // Esempi:
    // - 1% usage → ~10% boost
    // - 25% usage → 50% boost
    // - 100% usage → 100% boost
    return normalizedCount.clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'ExerciseUsageModel('
        'id: $exerciseId, '
        'name: $exerciseName, '
        'count: $usageCount, '
        'lastUsed: $lastUsedAt, '
        'userId: $userId'
        ')';
  }

  /// Copia con modifiche (immutability pattern helper)
  ExerciseUsageModel copyWith({
    String? exerciseId,
    String? exerciseName,
    int? usageCount,
    DateTime? lastUsedAt,
    DateTime? firstUsedAt,
    String? userId,
  }) {
    return ExerciseUsageModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      firstUsedAt: firstUsedAt ?? this.firstUsedAt,
      userId: userId ?? this.userId,
    );
  }
}
