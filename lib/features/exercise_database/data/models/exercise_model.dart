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
    this.warmupSets,
    this.tempoWarmup,
    this.drillTecnico,
    this.prevenzioneInfortuni,
    this.cooldownConsigliato,
    this.spiegazioneTermini,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      focus: json['focus'] ?? '',
      imageUrl: json['imageUrl']?.isEmpty == true ? null : json['imageUrl'],
      muscoliSecondari: json['muscoliSecondari'] ?? '',
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
    );
  }

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
      warmupSets: exercise.warmupSets,
      tempoWarmup: exercise.tempoWarmup,
      drillTecnico: exercise.drillTecnico,
      prevenzioneInfortuni: exercise.prevenzioneInfortuni,
      cooldownConsigliato: exercise.cooldownConsigliato,
      spiegazioneTermini: exercise.spiegazioneTermini,
    );
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
  final String? warmupSets;
  final String? tempoWarmup;
  final String? drillTecnico;
  final String? prevenzioneInfortuni;
  final String? cooldownConsigliato;
  final String? spiegazioneTermini;

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
      warmupSets: warmupSets,
      tempoWarmup: tempoWarmup,
      drillTecnico: drillTecnico,
      prevenzioneInfortuni: prevenzioneInfortuni,
      cooldownConsigliato: cooldownConsigliato,
      spiegazioneTermini: spiegazioneTermini,
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
      'warmupSets': warmupSets,
      'tempoWarmup': tempoWarmup,
      'drillTecnico': drillTecnico,
      'prevenzioneInfortuni': prevenzioneInfortuni,
      'cooldownConsigliato': cooldownConsigliato,
      'spiegazioneTermini': spiegazioneTermini,
    };
  }
}