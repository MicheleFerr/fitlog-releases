/// TUT (Time Under Tension) Decoder Service
///
/// Decodifica i codici TUT in descrizioni leggibili.
/// Formato standard: "X-Y-Z-W" = eccentrica-pausa_basso-concentrica-pausa_alto
///
/// Esempi:
/// - "2-1-2-0" → "2s discesa, 1s pausa in basso, 2s salita"
/// - "2-0-1-0" → "2s discesa, esplosivo su"
/// - "EXP" → "Movimento esplosivo"
/// - "ISO" → "Mantieni posizione isometrica"
library;

/// Rappresenta una singola fase del TUT
class TutPhase {
  const TutPhase({
    required this.name,
    required this.seconds,
    required this.isExplosive,
  });

  final String name;
  final int seconds;
  final bool isExplosive;

  String get displayText {
    if (isExplosive) return 'Esplosivo';
    if (seconds == 0) return '-';
    return '${seconds}s';
  }
}

/// Risultato della decodifica TUT completa
class TutDecoded {
  const TutDecoded({
    required this.code,
    required this.description,
    required this.shortDescription,
    required this.phases,
    required this.totalSeconds,
  });

  /// Codice originale (es. "2-1-2-0")
  final String code;

  /// Descrizione completa (es. "2s discesa, 1s pausa in basso, 2s salita")
  final String description;

  /// Descrizione breve (es. "2↓ 1⏸ 2↑")
  final String shortDescription;

  /// Fasi individuali per visualizzazione grafica
  final List<TutPhase> phases;

  /// Tempo totale di una ripetizione in secondi
  final int totalSeconds;
}

/// Service per decodificare TUT
class TutDecoderService {
  TutDecoderService._();

  /// Decodifica TUT in descrizione leggibile completa
  ///
  /// ```dart
  /// TutDecoderService.decode("2-1-2-0")
  /// // → "2s discesa, 1s pausa in basso, 2s salita"
  /// ```
  static String decode(String? tut) {
    if (tut == null || tut.isEmpty) return '';

    // Casi speciali
    if (tut.toUpperCase() == 'EXP') return 'Movimento esplosivo';
    if (tut.toUpperCase() == 'ISO') return 'Mantieni posizione isometrica';

    final parts = tut.split('-');
    if (parts.length != 4) return tut; // Fallback al codice originale

    final eccentric = int.tryParse(parts[0]) ?? 0;
    final pauseBottom = int.tryParse(parts[1]) ?? 0;
    final concentric = int.tryParse(parts[2]) ?? 0;
    final pauseTop = int.tryParse(parts[3]) ?? 0;

    final segments = <String>[];

    // Eccentrica (discesa)
    if (eccentric > 0) segments.add('${eccentric}s discesa');

    // Pausa in basso
    if (pauseBottom > 0) segments.add('${pauseBottom}s pausa in basso');

    // Concentrica (salita)
    if (concentric <= 1) {
      segments.add('esplosivo su');
    } else {
      segments.add('${concentric}s salita');
    }

    // Pausa in alto
    if (pauseTop > 0) segments.add('${pauseTop}s pausa in alto');

    return segments.join(', ');
  }

  /// Decodifica TUT in formato breve con icone
  ///
  /// ```dart
  /// TutDecoderService.decodeShort("2-1-2-0")
  /// // → "2↓ 1⏸ 2↑"
  /// ```
  static String decodeShort(String? tut) {
    if (tut == null || tut.isEmpty) return '';

    // Casi speciali
    if (tut.toUpperCase() == 'EXP') return 'EXP';
    if (tut.toUpperCase() == 'ISO') return 'ISO';

    final parts = tut.split('-');
    if (parts.length != 4) return tut;

    final eccentric = int.tryParse(parts[0]) ?? 0;
    final pauseBottom = int.tryParse(parts[1]) ?? 0;
    final concentric = int.tryParse(parts[2]) ?? 0;
    final pauseTop = int.tryParse(parts[3]) ?? 0;

    final segments = <String>[];

    if (eccentric > 0) segments.add('$eccentric↓');
    if (pauseBottom > 0) segments.add('$pauseBottom⏸');
    if (concentric <= 1) {
      segments.add('⚡');
    } else {
      segments.add('$concentric↑');
    }
    if (pauseTop > 0) segments.add('$pauseTop⏸');

    return segments.join(' ');
  }

  /// Decodifica completa con tutte le informazioni
  ///
  /// Utile per UI avanzate che mostrano ogni fase separatamente
  static TutDecoded? decodeComplete(String? tut) {
    if (tut == null || tut.isEmpty) return null;

    // Casi speciali
    if (tut.toUpperCase() == 'EXP') {
      return TutDecoded(
        code: tut,
        description: 'Movimento esplosivo',
        shortDescription: 'EXP',
        phases: [
          const TutPhase(name: 'Esplosivo', seconds: 0, isExplosive: true),
        ],
        totalSeconds: 1,
      );
    }

    if (tut.toUpperCase() == 'ISO') {
      return TutDecoded(
        code: tut,
        description: 'Mantieni posizione isometrica',
        shortDescription: 'ISO',
        phases: [
          const TutPhase(name: 'Isometrico', seconds: 0, isExplosive: false),
        ],
        totalSeconds: 0,
      );
    }

    final parts = tut.split('-');
    if (parts.length != 4) return null;

    final eccentric = int.tryParse(parts[0]) ?? 0;
    final pauseBottom = int.tryParse(parts[1]) ?? 0;
    final concentric = int.tryParse(parts[2]) ?? 0;
    final pauseTop = int.tryParse(parts[3]) ?? 0;

    final phases = <TutPhase>[
      TutPhase(
        name: 'Discesa',
        seconds: eccentric,
        isExplosive: false,
      ),
      TutPhase(
        name: 'Pausa basso',
        seconds: pauseBottom,
        isExplosive: false,
      ),
      TutPhase(
        name: 'Salita',
        seconds: concentric,
        isExplosive: concentric <= 1,
      ),
      TutPhase(
        name: 'Pausa alto',
        seconds: pauseTop,
        isExplosive: false,
      ),
    ];

    return TutDecoded(
      code: tut,
      description: decode(tut),
      shortDescription: decodeShort(tut),
      phases: phases,
      totalSeconds: eccentric + pauseBottom + concentric + pauseTop,
    );
  }

  /// Calcola il tempo totale per una ripetizione
  static int calculateRepTime(String? tut) {
    if (tut == null || tut.isEmpty) return 0;
    if (tut.toUpperCase() == 'EXP') return 1;
    if (tut.toUpperCase() == 'ISO') return 0;

    final parts = tut.split('-');
    if (parts.length != 4) return 0;

    return parts.fold<int>(0, (sum, p) => sum + (int.tryParse(p) ?? 0));
  }

  /// Calcola il tempo totale per un set
  static int calculateSetTime(String? tut, int reps) {
    return calculateRepTime(tut) * reps;
  }

  /// Valida se una stringa è un TUT valido
  static bool isValidTut(String? tut) {
    if (tut == null || tut.isEmpty) return false;
    if (tut.toUpperCase() == 'EXP' || tut.toUpperCase() == 'ISO') return true;

    final parts = tut.split('-');
    if (parts.length != 4) return false;

    return parts.every((p) => int.tryParse(p) != null);
  }
}
