import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

class ExerciseModel {
  const ExerciseModel({
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
  });

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      nome: exercise.nome,
      focus: exercise.focus.join(', '),
      imageUrl: exercise.imageUrl,
      muscoliSecondari: exercise.muscoliSecondari.join(', '),
      difficolta: exercise.difficolta,
      tipoEsercizio: exercise.tipoEsercizio,
      attrezzatura: exercise.attrezzatura,
      patternMovimento: exercise.patternMovimento,
      rangeRipetizioni: exercise.rangeRipetizioni,
      noteTecniche: exercise.noteTecniche,
      mobilitaPre: exercise.mobilitaPre,
      attivazionePre: exercise.attivazionePre,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      focus: _toCommaSeparatedString(json['focus']),
      imageUrl: json['imageUrl']?.isEmpty == true ? null : json['imageUrl'],
      muscoliSecondari: _toCommaSeparatedString(json['muscoliSecondari']),
      difficolta: json['difficolta'] ?? '',
      tipoEsercizio: json['tipoEsercizio'] ?? '',
      attrezzatura: json['attrezzatura'] ?? '',
      patternMovimento: json['patternMovimento'] ?? '',
      rangeRipetizioni: json['rangeRipetizioni'] ?? '',
      noteTecniche: json['noteTecniche']?.isEmpty == true
          ? null
          : json['noteTecniche'],
      mobilitaPre: json['mobilitaPre']?.isEmpty == true
          ? null
          : json['mobilitaPre'],
      attivazionePre: json['attivazionePre']?.isEmpty == true
          ? null
          : json['attivazionePre'],
    );
  }

  /// Converts a field that may be String or List to comma-separated String.
  /// Handles JSON format migration from List to String format.
  static String _toCommaSeparatedString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }
  final String id;
  final String nome;
  final String focus;
  final String? imageUrl;
  final String muscoliSecondari;
  final String difficolta;
  final String tipoEsercizio;
  final String attrezzatura;
  final String patternMovimento;
  final String rangeRipetizioni;
  final String? noteTecniche;
  final String? mobilitaPre;
  final String? attivazionePre;

  Exercise toEntity() {
    return Exercise(
      id: id,
      nome: nome,
      focus: Exercise.parseCommaSeparated(focus),
      imageUrl: imageUrl,
      muscoliSecondari: Exercise.parseCommaSeparated(muscoliSecondari),
      difficolta: difficolta,
      tipoEsercizio: tipoEsercizio,
      attrezzatura: attrezzatura,
      patternMovimento: patternMovimento,
      rangeRipetizioni: rangeRipetizioni,
      noteTecniche: noteTecniche,
      mobilitaPre: mobilitaPre,
      attivazionePre: attivazionePre,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'focus': focus,
      'imageUrl': imageUrl,
      'muscoliSecondari': muscoliSecondari,
      'difficolta': difficolta,
      'tipoEsercizio': tipoEsercizio,
      'attrezzatura': attrezzatura,
      'patternMovimento': patternMovimento,
      'rangeRipetizioni': rangeRipetizioni,
      'noteTecniche': noteTecniche,
      'mobilitaPre': mobilitaPre,
      'attivazionePre': attivazionePre,
    };
  }
}
