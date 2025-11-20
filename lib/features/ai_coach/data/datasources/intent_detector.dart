/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: intent_classifier
///
/// Intent Detector - Pattern-based intent classification
///
/// **Purpose**: Classify user intent from chat messages using regex + keywords
///
/// **Supported Intents**:
/// - `progression`: "How am I progressing?", "Am I getting stronger?"
/// - `volume`: "Am I training too much?", "Volume optimization"
/// - `recovery`: "Should I rest?", "Am I recovered?"
/// - `balance`: "Muscle group balance?", "Am I balanced?"
/// - `form`: "Form check", "Technique tips"
/// - `motivation`: "Need motivation", "Feeling demotivated"
/// - `greeting`: "Hi", "Hello", "Hey"
/// - `unknown`: Fallback when no pattern matches
///
/// **Classification Strategy**:
/// - Keyword matching (case-insensitive)
/// - Regex patterns for common phrases
/// - Fuzzy matching for typos (using fuzzy_bolt)
library;

/// User intent types
enum UserIntent {
  progression,  // "How am I progressing?"
  volume,       // "Am I training too much?"
  recovery,     // "Should I rest?"
  balance,      // "Muscle group balance?"
  form,         // "Form check"
  motivation,   // "Need motivation"
  plan,         // "Need a workout plan"
  prQuery,      // "What's my max on bench press?" (Personal Record query)
  greeting,     // "Hi", "Hello"
  help,         // "Help", "What can you do?"
  unknown,      // Fallback
}

/// Intent detector for pattern-based classification
///
/// **Usage**:
/// ```dart
/// final detector = IntentDetector();
/// final intent = detector.detectIntent("How am I progressing?");
/// // Returns: UserIntent.progression
/// ```
class IntentDetector {
  /// Detect user intent from message
  ///
  /// **Parameters**:
  /// - `message`: User's input text (trimmed, lowercase)
  ///
  /// **Returns**: UserIntent enum
  ///
  /// **Algorithm**:
  /// 1. Normalize message (lowercase, trim)
  /// 2. Check greeting patterns first (highest priority)
  /// 3. Check keyword patterns for each intent
  /// 4. Return first match or `unknown`
  UserIntent detectIntent(String message) {
    final normalized = message.toLowerCase().trim();

    // Priority 1: Greetings (short messages)
    if (_isGreeting(normalized)) {
      return UserIntent.greeting;
    }

    // Priority 2: Specific intents (keyword matching)
    if (_isProgressionIntent(normalized)) {
      return UserIntent.progression;
    }

    if (_isVolumeIntent(normalized)) {
      return UserIntent.volume;
    }

    if (_isRecoveryIntent(normalized)) {
      return UserIntent.recovery;
    }

    if (_isBalanceIntent(normalized)) {
      return UserIntent.balance;
    }

    if (_isFormIntent(normalized)) {
      return UserIntent.form;
    }

    if (_isMotivationIntent(normalized)) {
      return UserIntent.motivation;
    }

    if (_isPlanIntent(normalized)) {
      return UserIntent.plan;
    }

    if (_isPRQueryIntent(normalized)) {
      return UserIntent.prQuery;
    }

    if (_isHelpIntent(normalized)) {
      return UserIntent.help;
    }

    // Fallback
    return UserIntent.unknown;
  }

  /// Check if message is a greeting
  bool _isGreeting(String message) {
    final greetingPatterns = [
      r'^(hi|hello|hey|ciao|salve)[\s!?]*$',
      r'^(good morning|good afternoon|good evening)',
      r'^(buongiorno|buonasera|salut)',
    ];

    return greetingPatterns.any((pattern) => RegExp(pattern).hasMatch(message));
  }

  /// Check if message is about progression
  bool _isProgressionIntent(String message) {
    final keywords = [
      'progress', 'progressing', 'progression', 'progresso',
      'stronger', 'improve', 'improving', 'miglior',
      'trend', 'tendenza', 'growing', 'crescita',
      'pr', 'personal record', 'record',
      // Sub-intent keywords (from follow-up chips)
      'dettagli', 'details', 'numeri', 'numbers',
      'migliori esercizi', 'best exercises',
      'esercizi in stallo', 'stalled exercises', 'worst exercises',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about volume
  bool _isVolumeIntent(String message) {
    final keywords = [
      'volume', 'volum', 'too much', 'troppo',
      'overtraining', 'over training', 'sovrallenamento',
      'sets', 'serie', 'reps', 'ripetizioni',
      'doing enough', 'abbastanza',
      // Sub-intent keywords (from follow-up chips)
      'volume per gruppo', 'volume per group',
      'confronto settimane', 'weekly comparison',
      'raccomandazioni', 'recommendations',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about recovery
  bool _isRecoveryIntent(String message) {
    final keywords = [
      'recover', 'recovery', 'recupero', 'riposo',
      'rest', 'resting', 'ripos',
      'tired', 'stanco', 'fatigue', 'fatica',
      'sore', 'doms', 'dolori', 'muscle soreness',
      'should i rest', 'devo riposare',
      // Sub-intent keywords (from follow-up chips)
      'qualità sonno', 'sleep quality',
      'tempi recupero', 'rest times',
      'segnali overtraining', 'overtraining signs',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about muscle group balance
  bool _isBalanceIntent(String message) {
    final keywords = [
      'balance', 'balanced', 'bilanciato', 'equilibrio',
      'muscle group', 'gruppo muscolare', 'symmetry',
      'imbalance', 'squilibrio', 'weak', 'debole',
      'lagging', 'indietro', 'proportions',
      // Sub-intent keywords (from follow-up chips)
      'gruppi deboli', 'lagging groups',
      'push/pull ratio', 'push pull ratio',
      'esercizi correttivi', 'corrective exercises',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about form/technique
  bool _isFormIntent(String message) {
    final keywords = [
      'form', 'technique', 'tecnica', 'esecuzione',
      'how to', 'come fare', 'correctly', 'correttamente',
      'cue', 'tip', 'consiglio', 'suggerimento',
      'posture', 'postura', 'movement', 'movimento',
      // Sub-intent keywords (from follow-up chips)
      'video tutorial', 'video tutorials',
      'errori comuni', 'common mistakes',
      'setup ottimale', 'optimal setup',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about motivation
  bool _isMotivationIntent(String message) {
    final keywords = [
      'motivat', 'motivation', 'motivazione', 'motivare',
      'demotivat', 'discourag', 'scoraggia',
      'give up', 'rinuncio', 'not working', 'non funziona',
      'plateau', 'stuck', 'bloccato', 'fermo',
      'inspire', 'ispira', 'encourage', 'incoraggia',
      // Sub-intent keywords (from follow-up chips)
      'ultimi successi', 'recent wins', 'recent achievements',
      'obiettivi prossimi', 'next goals',
      'strategie mentali', 'mental strategies',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is about workout planning
  bool _isPlanIntent(String message) {
    final keywords = [
      'plan', 'program', 'schedule', 'pianifica', 'programma',
      'routine', 'rutina', 'split', 'divid',
      'what should i do', 'cosa dovrei fare',
      'workout plan', 'piano allenamento', 'training schedule',
      // Sub-intent keywords (from follow-up chips)
      'frequenza ottimale', 'optimal frequency',
      'quando cambiare', 'when to change',
      'esercizi chiave', 'key exercises',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is asking about personal records (massimale/1RM)
  ///
  /// **Examples**:
  /// - "qual è il mio massimale di panca?"
  /// - "what's my 1rm on squat?"
  /// - "dimmi il mio record su stacchi"
  bool _isPRQueryIntent(String message) {
    final keywords = [
      'massimale', '1rm', 'max', 'massimo',
      'one rep max', 'personal best',
      'picco', 'top', 'meglio che ho fatto',
      'quanto sollevo', 'quanto peso',
      // Question patterns
      'qual è il mio max', 'qual è il massimale',
      'what is my max', 'what\'s my max',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message is asking for help
  ///
  /// **Examples**:
  /// - "help", "aiuto", "help me"
  /// - "what can you do?", "cosa puoi fare?"
  /// - "show me your capabilities", "mostrami le tue capacità"
  bool _isHelpIntent(String message) {
    final keywords = [
      'help', 'aiuto', 'help me', 'aiutami',
      'what can you do', 'cosa puoi fare',
      'capabilities', 'capacità', 'features', 'funzioni',
      'commands', 'comandi', 'options', 'opzioni',
      'how to use', 'come usare', 'how does this work',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message contains any of the keywords
  bool _containsAnyKeyword(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
}
