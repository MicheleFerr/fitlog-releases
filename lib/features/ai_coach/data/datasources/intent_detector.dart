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
      r'^(hi|hello|hey|ciao|salve|ehilà|yo|wee)[\s!?]*$',
      r'^(good morning|good afternoon|good evening)',
      r'^(buongiorno|buonasera|salut|eccomi|sono qui)',
      // Casual Italian greetings
      r'^(ehi|bella|we|uè)[\s!?]*$',
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
      // Natural Italian phrases
      'come sto andando', 'sto migliorando', 'sto crescendo',
      'come vanno', 'sono migliorato', 'ho fatto progressi',
      'quanto ho migliorato', 'quanto sono migliorato',
      // Casual phrases
      'sto spaccando', 'sto pompando', 'sto volando',
      'sono più forte', 'divento più forte',
      'alzo di più', 'sollevo di più',
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
      // Natural Italian phrases
      'quante serie', 'quante ripetizioni', 'quanto alleno',
      'sto allenando troppo', 'sto esagerando',
      'mi sto allenando abbastanza', 'faccio abbastanza',
      'devo fare di più', 'devo fare di meno',
      'tonnellaggio', 'carico totale', 'peso totale',
      // Casual phrases
      'mi sto ammazzando', 'sto spaccando troppo',
      'sto facendo troppe serie', 'quante ne devo fare',
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
      // Natural Italian phrases
      'mi sento stanco', 'sono stanco', 'sono distrutto',
      'ho bisogno di riposo', 'devo recuperare',
      'quanto devo riposare', 'giorni di riposo',
      'ho male ai muscoli', 'mi fanno male',
      'sono indolenzito', 'ho i doms',
      'dormo poco', 'dormo male', 'non dormo bene',
      // Casual phrases
      'sono a pezzi', 'sono devastato', 'sono morto',
      'sono cotto', 'mi sento uno straccio',
      'non ce la faccio più', 'ho le gambe di legno',
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
      // Natural Italian phrases
      'sono bilanciato', 'sono equilibrato', 'sono simmetrico',
      'muscoli deboli', 'punti deboli', 'carenze',
      'ho squilibri', 'sono sbilanciato', 'sono asimmetrico',
      'quale muscolo', 'quali muscoli', 'cosa mi manca',
      'devo migliorare', 'cosa devo lavorare',
      'trascuro', 'non alleno abbastanza',
      // Body parts commonly discussed
      'petto piccolo', 'braccia piccole', 'spalle strette',
      'gambe sottili', 'schiena debole', 'addome debole',
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
      // Natural Italian phrases
      'come si fa', 'come si esegue', 'come faccio',
      'esecuzione corretta', 'tecnica corretta', 'forma corretta',
      'sto facendo bene', 'lo faccio giusto', 'è giusto così',
      'sbaglio qualcosa', 'faccio errori', 'cosa sbaglio',
      'mi fa male quando', 'sento dolore durante',
      'dove devo sentire', 'muscolo target',
      // Casual phrases
      'mi insegni', 'spiegami come', 'fammi vedere',
      'dammi dritte', 'tips per', 'trucchi per',
      // Common exercises for form questions
      'come squat', 'come stacco', 'come panca',
      'setup squat', 'setup stacco', 'setup panca',
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
      // Natural Italian phrases
      'non ho voglia', 'ho perso la voglia', 'non ce la faccio',
      'sono demotivato', 'mi sento giù', 'mi sento scoraggiato',
      'non vedo risultati', 'non miglioro', 'sono fermo',
      'ho mollato', 'voglio mollare', 'sto per mollare',
      'non serve a niente', 'è inutile', 'perdo tempo',
      'mi manca la costanza', 'non sono costante',
      // Casual phrases
      'dammi la carica', 'caricami', 'motivami',
      'ho bisogno di una spinta', 'tirami su',
      'sono in down', 'sono in crisi', 'momento no',
      // Positive seeking
      'cosa ho fatto bene', 'i miei successi', 'i miei traguardi',
      'quanto sono migliorato', 'progressi fatti',
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
      // Natural Italian phrases
      'cosa faccio oggi', 'cosa alleno oggi', 'che faccio oggi',
      'organizza allenamenti', 'organizza settimana',
      'quante volte', 'quante volte a settimana', 'frequenza',
      'scheda', 'scheda allenamento', 'nuova scheda',
      'cambiare programma', 'cambiare scheda', 'variare',
      'ho bisogno di un piano', 'creami un piano',
      // Split types commonly discussed
      'push pull legs', 'ppl', 'upper lower', 'bro split',
      'full body', 'total body', 'monofrequenza', 'multifrequenza',
      // Casual phrases
      'fammi una scheda', 'dammi un programma',
      'che esercizi faccio', 'cosa devo fare',
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
      // Natural Italian phrases
      'il mio record', 'mio pr', 'mio personal record',
      'quanto alzo', 'quanto spingo', 'quanto tiro',
      'peso massimo', 'carico massimo', 'il più pesante',
      'miglior alzata', 'miglior performance',
      'quanto ho fatto', 'quanto sono arrivato',
      // Exercise-specific queries
      'massimale panca', 'massimale squat', 'massimale stacco',
      'pr panca', 'pr squat', 'pr stacco',
      'record panca', 'record squat', 'record stacco',
      // Casual phrases
      'quanto butto', 'quanto carico', 'quanto sparo',
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
      // Natural Italian phrases
      'come funziona', 'come funzioni', 'cosa sai fare',
      'che cosa fai', 'a cosa servi', 'cosa posso chiederti',
      'mi puoi aiutare', 'puoi aiutarmi', 'ho bisogno di aiuto',
      'non capisco', 'non so come', 'spiegami',
      'istruzioni', 'guida', 'manuale',
      // Casual phrases
      'che fai', 'cosa fai', 'dimmi cosa fai',
      'come ti uso', 'fammi vedere', 'mostrami',
    ];

    return _containsAnyKeyword(message, keywords);
  }

  /// Check if message contains any of the keywords
  bool _containsAnyKeyword(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
}
