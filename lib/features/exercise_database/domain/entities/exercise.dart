import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2)
class Exercise extends Equatable { // Spiegazione del tempo di esecuzione

  const Exercise({
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
  });

  // Factory constructor per creare da JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
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

  // Metodo helper per parsare stringhe separate da virgole
  static List<String> _parseCommaSeparated(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // Metodo pubblico per il model
  static List<String> parseCommaSeparated(String? value) {
    return _parseCommaSeparated(value);
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
      ];
}