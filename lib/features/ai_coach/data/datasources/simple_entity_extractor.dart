/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity_extractor
///
/// Simple Entity Extractor - Estrae keyword semplici da messaggi utente
///
/// **Purpose**: Parsing leggero per cercare esercizi in database locale
///
/// **Strategy**:
/// - Rimuovi stop words comuni
/// - Mantieni parole significative (nomi esercizi)
/// - No fuzzy matching (delegato a search in JSON)
library;

/// Simple entity extractor per keyword extraction
class SimpleEntityExtractor {
  /// Stop words italiane comuni (non significative per esercizi)
  static const _stopWords = {
    // Articoli
    'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una',
    // Preposizioni
    'di', 'a', 'da', 'in', 'con', 'su', 'per', 'tra', 'fra',
    // Pronomi
    'mio', 'tuo', 'suo', 'nostro', 'vostro', 'loro',
    // Verbi ausiliari
    'è', 'sono', 'ho', 'hai', 'ha', 'abbiamo', 'avete', 'hanno',
    // Question words
    'qual', 'quale', 'quanto', 'quant', 'come', 'quando', 'dove', 'chi',
    // Intent keywords (non sono nomi esercizi)
    'massimale', '1rm', 'pr', 'record', 'personale', 'max', 'massimo',
    'volume', 'progressione', 'recupero', 'riposo',
    // Verbi comuni
    'voglio', 'vuoi', 'posso', 'puoi', 'devo', 'devi',
    'sapere', 'vedere', 'mostrare', 'dire', 'fare',
  };

  /// Estrai keyword da messaggio utente
  ///
  /// **Example**:
  /// - Input: "qual è il mio massimale di panca piana?"
  /// - Output: ["panca", "piana"]
  ///
  /// **Process**:
  /// 1. Lowercase + trim
  /// 2. Split by whitespace
  /// 3. Rimuovi punteggiatura
  /// 4. Filtra stop words
  /// 5. Ritorna keywords
  List<String> extractKeywords(String message) {
    // 1. Normalize
    final normalized = message.toLowerCase().trim();

    // 2. Split by whitespace and punctuation
    final words = normalized
        .replaceAll(RegExp(r'[?!.,;:]'), '') // Remove punctuation
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((w) => w.isNotEmpty)
        .toList();

    // 3. Filter stop words
    final keywords = words
        .where((w) => !_stopWords.contains(w))
        .toList();

    return keywords;
  }

  /// Check if message is asking about multiple exercises
  ///
  /// **Patterns**: "e squat?", "anche panca?", "pure stacchi?"
  bool isContinuation(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.startsWith(RegExp(r'^(e\s|anche\s|pure\s|poi\s)'));
  }

  /// Check if message is a direct answer (1-2 words, no question)
  ///
  /// **Used after**: Bot asks "Di quale esercizio?"
  /// **Example**: User replies "panca" or "panca piana"
  bool isDirectAnswer(String message) {
    final normalized = message.trim();
    final words = normalized.split(RegExp(r'\s+'));

    return words.length <= 3 &&
           !normalized.contains('?') &&
           !normalized.contains('qual');
  }
}
