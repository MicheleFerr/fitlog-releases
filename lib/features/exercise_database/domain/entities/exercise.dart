/// 🏋️ Exercise Definition Entity
///
/// Represents an exercise definition from the exercise database/catalog.
/// This is the DEFINITION of an exercise (name, muscles, equipment, etc.)
/// NOT an instance of an exercise in a workout.
///
/// For workout exercise instances, see:
/// `lib/features/workout/domain/entities/exercise.dart`
library;

import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';

part 'exercise.g.dart';

/// @deprecated Use [ExerciseDefinition] instead to avoid naming conflicts
/// with workout Exercise entity.
///
/// This typedef exists for backward compatibility during migration.
@Deprecated('Use ExerciseDefinition instead - avoids naming conflict with workout Exercise')
typedef Exercise = ExerciseDefinition;

/// Exercise definition from the database catalog
///
/// Contains static information about an exercise:
/// - Name, muscles targeted, equipment required
/// - Difficulty level, movement pattern
/// - Technical notes, warmup recommendations
///
/// This is stored in Hive and loaded from JSON exercise database.
@HiveType(typeId: 2)
class ExerciseDefinition extends Equatable {

  ExerciseDefinition({
    required this.id,
    required this.nome,
    required this.focus,
    this.imageUrl,
    required this.muscoliSecondari,
    required this.difficolta,
    required this.tipoEsercizio,
    required this.attrezzatura,
    required this.patternMovimento,
    required this.rangeRipetizioni,
    this.noteTecniche,
    this.mobilitaPre,
    this.attivazionePre,
    this.warmupSets,
    this.tempoWarmup,
    this.drillTecnico,
    this.prevenzioneInfortuni,
    this.cooldownConsigliato,
    this.spiegazioneTermini,
    this.tempoEsecuzione,
    this.tempoNote,
    // Fuzzy matching fields
    this.aliases = const [],
    String? normalizedNome,
    List<String>? searchableFields,
    this.warmupSuggestions,
  })  : normalizedNome = normalizedNome ?? _normalize(nome),
        searchableFields = searchableFields ?? _buildSearchableFields(nome, aliases);

  // Factory constructor per creare da JSON
  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return ExerciseDefinition(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      focus: _parseCommaSeparated(json['focus']),
      imageUrl: json['imageUrl']?.isEmpty == true ? null : json['imageUrl'],
      muscoliSecondari: _parseCommaSeparated(json['muscoliSecondari']),
      difficolta: json['difficolta'] ?? '',
      tipoEsercizio: json['tipoEsercizio'] ?? '',
      attrezzatura: json['attrezzatura'] ?? '',
      patternMovimento: json['patternMovimento'] ?? '',
      rangeRipetizioni: json['rangeRipetizioni'] ?? '',
      noteTecniche: json['noteTecniche']?.isEmpty == true ? null : json['noteTecniche'],
      mobilitaPre: json['mobilitaPre']?.isEmpty == true ? null : json['mobilitaPre'],
      attivazionePre: json['attivazionePre']?.isEmpty == true ? null : json['attivazionePre'],
      warmupSets: json['warmupSets']?.isEmpty == true ? null : json['warmupSets'],
      tempoWarmup: json['tempoWarmup']?.isEmpty == true ? null : json['tempoWarmup'],
      drillTecnico: json['drillTecnico']?.isEmpty == true ? null : json['drillTecnico'],
      prevenzioneInfortuni: json['prevenzioneInfortuni']?.isEmpty == true ? null : json['prevenzioneInfortuni'],
      cooldownConsigliato: json['cooldownConsigliato']?.isEmpty == true ? null : json['cooldownConsigliato'],
      spiegazioneTermini: json['spiegazioneTermini']?.isEmpty == true ? null : json['spiegazioneTermini'],
      tempoEsecuzione: json['tempoEsecuzione']?.isEmpty == true ? null : json['tempoEsecuzione'],
      tempoNote: json['tempoNote']?.isEmpty == true ? null : json['tempoNote'],
      // Fuzzy matching fields
      aliases: (json['aliases'] as List<dynamic>?)?.cast<String>() ?? [],
      warmupSuggestions: (json['warmupSuggestions'] as List<dynamic>?)
          ?.map((e) => WarmupSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String nome;
  
  @HiveField(2)
  final List<String> focus; // Es: ["QUAD", "GLUT"]
  
  @HiveField(3)
  final String? imageUrl;
  
  @HiveField(4)
  final List<String> muscoliSecondari; // Es: ["CORE", "POLP"]
  
  @HiveField(5)
  final String difficolta; // Principiante, Intermedio, Avanzato
  
  @HiveField(6)
  final String tipoEsercizio; // Compound, Isolamento
  
  @HiveField(7)
  final String attrezzatura; // Bilanciere, Manubri, Cavi, etc.
  
  @HiveField(8)
  final String patternMovimento; // Lunge Pattern, Squat Pattern, etc.
  
  @HiveField(9)
  final String rangeRipetizioni; // 8-15, 1-5 (forza), etc.
  
  @HiveField(10)
  final String? noteTecniche;
  
  @HiveField(11)
  final String? mobilitaPre;
  
  @HiveField(12)
  final String? attivazionePre;
  
  @HiveField(13)
  final String? warmupSets;
  
  @HiveField(14)
  final String? tempoWarmup;
  
  @HiveField(15)
  final String? drillTecnico;
  
  @HiveField(16)
  final String? prevenzioneInfortuni;
  
  @HiveField(17)
  final String? cooldownConsigliato;
  
  @HiveField(18)
  final String? spiegazioneTermini;

  @HiveField(19)
  final String? tempoEsecuzione; // Time Under Tension (e.g., "3-1-2-0")

  @HiveField(20)
  final String? tempoNote;

  // Fuzzy matching fields
  @HiveField(21)
  final List<String> aliases; // Varianti del nome (es: ["panca", "bench press", "BP"])

  @HiveField(22)
  final String normalizedNome; // Nome normalizzato (lowercase, no accenti)

  @HiveField(23)
  final List<String> searchableFields; // Campi pre-calcolati per fuzzy search

  @HiveField(24)
  final List<WarmupSuggestion>? warmupSuggestions;

  // Metodo helper per parsare stringhe separate da virgole
  static List<String> _parseCommaSeparated(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // Metodo pubblico per il model
  static List<String> parseCommaSeparated(String? value) {
    return _parseCommaSeparated(value);
  }

  // Normalizza stringhe (lowercase + rimuovi accenti)
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }

  // Pre-calcola tutti i campi searchabili
  static List<String> _buildSearchableFields(String nome, List<String> aliases) {
    final fields = <String>{
      _normalize(nome),
      ...aliases.map((a) => _normalize(a)),
    };
    return fields.toList();
  }

  // Getters utili per UI
  String get focusDisplayName => focus.join(', ');
  String get muscoliSecondariDisplayName => muscoliSecondari.join(', ');
  
  // Getter per determinare il colore della difficoltà
  int get difficoltaLevel {
    switch (difficolta.toLowerCase()) {
      case 'principiante':
        return 1;
      case 'intermedio':
        return 2;
      case 'avanzato':
        return 3;
      default:
        return 2;
    }
  }

  // Getter per icona attrezzatura
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
      case 'vario':
        return '🎯';
      default:
        return '❓';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'focus': focus.join(', '),
      'imageUrl': imageUrl,
      'muscoliSecondari': muscoliSecondari.join(', '),
      'difficolta': difficolta,
      'tipoEsercizio': tipoEsercizio,
      'attrezzatura': attrezzatura,
      'patternMovimento': patternMovimento,
      'rangeRipetizioni': rangeRipetizioni,
      'noteTecniche': noteTecniche,
      'mobilitaPre': mobilitaPre,
      'attivazionePre': attivazionePre,
      'warmupSets': warmupSets,
      'tempoWarmup': tempoWarmup,
      'drillTecnico': drillTecnico,
      'prevenzioneInfortuni': prevenzioneInfortuni,
      'cooldownConsigliato': cooldownConsigliato,
      'spiegazioneTermini': spiegazioneTermini,
      'tempoEsecuzione': tempoEsecuzione,
      'tempoNote': tempoNote,
      // Fuzzy matching fields
      'aliases': aliases,
      'normalizedNome': normalizedNome,
      'warmupSuggestions': warmupSuggestions?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        focus,
        imageUrl,
        muscoliSecondari,
        difficolta,
        tipoEsercizio,
        attrezzatura,
        patternMovimento,
        rangeRipetizioni,
        noteTecniche,
        mobilitaPre,
        attivazionePre,
        warmupSets,
        tempoWarmup,
        drillTecnico,
        prevenzioneInfortuni,
        cooldownConsigliato,
        spiegazioneTermini,
        tempoEsecuzione,
        tempoNote,
        // Fuzzy matching fields
        aliases,
        normalizedNome,
        searchableFields,
        warmupSuggestions,
      ];
}