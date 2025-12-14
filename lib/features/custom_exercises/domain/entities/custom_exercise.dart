/// Custom Exercise Entity
/// Stores user-created exercise variants with optional categorization.
library;

import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'custom_exercise.g.dart';

/// Custom Exercise Entity
///
/// This entity represents custom exercises created by users, which can be:
/// - Pure custom exercises (baseExerciseId = null)
/// - Modified variants of base exercises (baseExerciseId != null)
///
/// Premium users can create unlimited custom exercises.
/// Free users can create limited custom exercises with temporary unlocks.
@HiveType(typeId: 75)
class CustomExercise extends Equatable {
  const CustomExercise({
    required this.id,
    required this.nome,
    this.baseExerciseId,
    required this.focus,
    required this.muscoliSecondari,
    required this.tipoEsercizio,
    required this.patternMovimento,
    required this.attrezzatura,
    required this.createdAt,
    this.unlockedUntil,
    this.isModifiedFromBase = false,
    this.userId,
  });

  // ========== Factory Constructors ==========

  /// Create a new pure custom exercise (not based on existing exercise)
  factory CustomExercise.createNew({
    required String nome,
    required List<String> focus,
    required List<String> muscoliSecondari,
    required String tipoEsercizio,
    required String patternMovimento,
    required String attrezzatura,
    DateTime? unlockedUntil,
    String? userId,
  }) {
    return CustomExercise(
      id: const Uuid().v4(),
      nome: nome,
      baseExerciseId: null,
      focus: focus,
      muscoliSecondari: muscoliSecondari,
      tipoEsercizio: tipoEsercizio,
      patternMovimento: patternMovimento,
      attrezzatura: attrezzatura,
      createdAt: DateTime.now(),
      unlockedUntil: unlockedUntil,
      isModifiedFromBase: false,
      userId: userId,
    );
  }

  /// Create a variant from existing base exercise
  factory CustomExercise.fromBase({
    required String baseExerciseId,
    required String nome,
    required List<String> focus,
    required List<String> muscoliSecondari,
    required String tipoEsercizio,
    required String patternMovimento,
    required String attrezzatura,
    required bool isModifiedFromBase,
    DateTime? unlockedUntil,
    String? userId,
  }) {
    return CustomExercise(
      id: const Uuid().v4(),
      nome: nome,
      baseExerciseId: baseExerciseId,
      focus: focus,
      muscoliSecondari: muscoliSecondari,
      tipoEsercizio: tipoEsercizio,
      patternMovimento: patternMovimento,
      attrezzatura: attrezzatura,
      createdAt: DateTime.now(),
      unlockedUntil: unlockedUntil,
      isModifiedFromBase: isModifiedFromBase,
      userId: userId,
    );
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    return CustomExercise(
      id: json['id'] as String,
      nome: json['nome'] as String,
      baseExerciseId: json['baseExerciseId'] as String?,
      focus: (json['focus'] as List<dynamic>).cast<String>(),
      muscoliSecondari: (json['muscoliSecondari'] as List<dynamic>).cast<String>(),
      tipoEsercizio: json['tipoEsercizio'] as String,
      patternMovimento: json['patternMovimento'] as String,
      attrezzatura: json['attrezzatura'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      unlockedUntil: json['unlockedUntil'] != null
          ? DateTime.parse(json['unlockedUntil'] as String)
          : null,
      isModifiedFromBase: json['isModifiedFromBase'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }

  /// Unique identifier for this custom exercise
  @HiveField(0)
  final String id;

  /// Exercise name (e.g., "Panca Piana Variante Stretta")
  @HiveField(1)
  final String nome;

  /// Reference to base exercise if this is a variant (null if pure custom)
  @HiveField(2)
  final String? baseExerciseId;

  /// Primary muscles targeted (e.g., ["PETT", "DELT ANT"])
  @HiveField(3)
  final List<String> focus;

  /// Secondary muscles targeted (e.g., ["TRIC"])
  @HiveField(4)
  final List<String> muscoliSecondari;

  /// Exercise type: "Compound" | "Isolamento"
  @HiveField(5)
  final String tipoEsercizio;

  /// Movement pattern: "Push" | "Pull" | "Hinge" | "Squat" | "Accessory"
  @HiveField(6)
  final String patternMovimento;

  /// Equipment: "Bilanciere" | "Manubri" | "Cavi" | "Macchina" | "Corpo Libero"
  @HiveField(7)
  final String attrezzatura;

  /// When this custom exercise was created
  @HiveField(8)
  final DateTime createdAt;

  /// Expiration date for temporary unlocks
  /// - null = permanent (free slot or Premium user)
  /// - DateTime = temporary unlock expiration
  @HiveField(9)
  final DateTime? unlockedUntil;

  /// True if user changed focus/pattern/muscles from base exercise
  @HiveField(10)
  final bool isModifiedFromBase;

  /// User ID for cloud sync (Premium users only)
  @HiveField(11)
  final String? userId;

  // ========== JSON Serialization ==========

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'baseExerciseId': baseExerciseId,
      'focus': focus,
      'muscoliSecondari': muscoliSecondari,
      'tipoEsercizio': tipoEsercizio,
      'patternMovimento': patternMovimento,
      'attrezzatura': attrezzatura,
      'createdAt': createdAt.toIso8601String(),
      'unlockedUntil': unlockedUntil?.toIso8601String(),
      'isModifiedFromBase': isModifiedFromBase,
      'userId': userId,
    };
  }

  // ========== Computed Properties ==========

  /// True if this custom exercise is currently active (not expired)
  bool get isActive => unlockedUntil == null || DateTime.now().isBefore(unlockedUntil!);

  /// True if this custom exercise has expired (temporary unlock)
  bool get isExpired => unlockedUntil != null && DateTime.now().isAfter(unlockedUntil!);

  /// True if this is a permanent custom exercise (free slot or Premium)
  bool get isPermanent => unlockedUntil == null;

  /// True if this is a temporary unlock
  bool get isTemporary => unlockedUntil != null;

  /// True if this is a pure custom exercise (not based on existing)
  bool get isPureCustom => baseExerciseId == null;

  /// True if this is a variant of a base exercise
  bool get isVariant => baseExerciseId != null;

  /// Days remaining before expiration (null if permanent)
  int? get daysRemaining {
    if (unlockedUntil == null) return null;
    final difference = unlockedUntil!.difference(DateTime.now());
    return difference.inDays.clamp(0, double.infinity).toInt();
  }

  /// Display string for primary muscles
  String get focusDisplayName => focus.join(', ');

  /// Display string for secondary muscles
  String get muscoliSecondariDisplayName => muscoliSecondari.join(', ');

  /// Icon for equipment type
  String get attrezzaturaIcon {
    switch (attrezzatura.toLowerCase()) {
      case 'bilanciere':
        return '🏋️';
      case 'manubri':
        return '💪';
      case 'cavi':
        return '🔗';
      case 'macchina':
        return '⚙️';
      case 'corpo libero':
        return '🤸';
      default:
        return '🎯';
    }
  }

  // ========== CopyWith ==========

  CustomExercise copyWith({
    String? id,
    String? nome,
    String? baseExerciseId,
    List<String>? focus,
    List<String>? muscoliSecondari,
    String? tipoEsercizio,
    String? patternMovimento,
    String? attrezzatura,
    DateTime? createdAt,
    DateTime? unlockedUntil,
    bool? isModifiedFromBase,
    String? userId,
  }) {
    return CustomExercise(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      baseExerciseId: baseExerciseId ?? this.baseExerciseId,
      focus: focus ?? this.focus,
      muscoliSecondari: muscoliSecondari ?? this.muscoliSecondari,
      tipoEsercizio: tipoEsercizio ?? this.tipoEsercizio,
      patternMovimento: patternMovimento ?? this.patternMovimento,
      attrezzatura: attrezzatura ?? this.attrezzatura,
      createdAt: createdAt ?? this.createdAt,
      unlockedUntil: unlockedUntil ?? this.unlockedUntil,
      isModifiedFromBase: isModifiedFromBase ?? this.isModifiedFromBase,
      userId: userId ?? this.userId,
    );
  }

  // ========== Equatable ==========

  @override
  List<Object?> get props => [
        id,
        nome,
        baseExerciseId,
        focus,
        muscoliSecondari,
        tipoEsercizio,
        patternMovimento,
        attrezzatura,
        createdAt,
        unlockedUntil,
        isModifiedFromBase,
        userId,
      ];
}
