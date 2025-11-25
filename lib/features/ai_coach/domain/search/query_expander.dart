/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/search
/// 🎯 Feature: ai_coach
/// 🔧 Type: query_expansion
///
/// Query Expander - Semantic expansion of user queries
///
/// **Features**:
/// - Synonym expansion for fitness terms
/// - Abbreviation resolution (PR, 1RM, etc.)
/// - Temporal expression parsing
/// - Muscle group expansion
/// - Exercise variation detection
library;

/// Expands user queries with semantically related terms
class QueryExpander {
  /// Fitness-specific synonyms and related terms (EN + IT)
  static final Map<String, List<String>> _synonyms = {
    // Exercise synonyms - English
    'squat': ['squats', 'back squat', 'front squat', 'goblet squat', 'accosciata', 'squat'],
    'bench': ['bench press', 'chest press', 'bench', 'bp', 'panca', 'distensioni'],
    'deadlift': ['deadlifts', 'dl', 'romanian deadlift', 'rdl', 'stacco', 'stacchi'],
    'press': ['shoulder press', 'overhead press', 'ohp', 'military press', 'spinta', 'lento'],
    'pullup': ['pullups', 'pull-up', 'pull up', 'chinup', 'chin-up', 'trazioni', 'sbarra'],
    'pushup': ['pushups', 'push-up', 'push up', 'press up', 'flessioni', 'piegamenti'],
    'row': ['rows', 'barbell row', 'dumbbell row', 'cable row', 'rematore', 'remata'],
    'curl': ['curls', 'bicep curl', 'hammer curl', 'preacher curl', 'curl bicipiti'],

    // Exercise synonyms - Italian
    'panca': ['bench press', 'distensioni panca', 'panca piana', 'bench', 'bp'],
    'stacco': ['deadlift', 'stacchi', 'stacco da terra', 'dl', 'deadlifts'],
    'accosciata': ['squat', 'squats', 'accosciate', 'back squat'],
    'trazioni': ['pullup', 'pullups', 'trazioni sbarra', 'pull-up', 'pull up'],
    'flessioni': ['pushup', 'pushups', 'piegamenti', 'push-up'],
    'rematore': ['row', 'rows', 'remata', 'rematore bilanciere'],
    'distensioni': ['bench press', 'press', 'spinta', 'shoulder press'],
    'affondi': ['lunges', 'lunge', 'affondo', 'split squat'],

    // Muscle group synonyms - English
    'chest': ['pec', 'pectorals', 'pecs', 'petto', 'pettorali'],
    'back': ['lats', 'latissimus', 'traps', 'trapezius', 'schiena', 'dorsali'],
    'shoulders': ['delts', 'deltoids', 'shoulder', 'spalle', 'deltoidi'],
    'legs': ['quads', 'quadriceps', 'hamstrings', 'glutes', 'calves', 'gambe', 'cosce'],
    'arms': ['biceps', 'triceps', 'forearms', 'braccia'],
    'core': ['abs', 'abdominals', 'obliques', 'abdomen', 'addome', 'addominali'],

    // Muscle group synonyms - Italian
    'petto': ['chest', 'pec', 'pectorals', 'pettorali'],
    'schiena': ['back', 'lats', 'dorsali', 'latissimus'],
    'spalle': ['shoulders', 'delts', 'deltoids', 'deltoidi'],
    'gambe': ['legs', 'quads', 'hamstrings', 'cosce', 'quadricipiti'],
    'braccia': ['arms', 'biceps', 'triceps', 'bicipiti', 'tricipiti'],
    'addome': ['core', 'abs', 'addominali', 'obliqui'],
    'pettorali': ['chest', 'pec', 'pectorals', 'petto'],
    'dorsali': ['back', 'lats', 'latissimus', 'schiena'],
    'deltoidi': ['shoulders', 'delts', 'deltoids', 'spalle'],
    'quadricipiti': ['quads', 'quadriceps', 'gambe', 'cosce'],
    'bicipiti': ['biceps', 'arms', 'braccia'],
    'tricipiti': ['triceps', 'arms', 'braccia'],
    'addominali': ['abs', 'abdominals', 'core', 'addome'],
    'glutei': ['glutes', 'gluteus', 'glute'],

    // Performance metrics - English
    'pr': ['personal record', 'pb', 'personal best', 'max', 'maximum', 'massimale', 'record'],
    'max': ['maximum', '1rm', 'one rep max', 'single', 'massimale', 'massimo'],
    'volume': ['total volume', 'tonnage', 'workload', 'volume totale', 'carico'],
    'weight': ['load', 'resistance', 'kg', 'pounds', 'lbs', 'peso', 'carico'],
    'reps': ['repetitions', 'rep', 'times', 'ripetizioni', 'rip'],
    'sets': ['set', 'rounds', 'serie'],

    // Performance metrics - Italian
    'massimale': ['max', 'maximum', '1rm', 'pr', 'personal record', 'record'],
    'record': ['pr', 'personal record', 'max', 'massimale', 'personal best'],
    'ripetizioni': ['reps', 'repetitions', 'rep', 'volte'],
    'serie': ['sets', 'set', 'rounds'],
    'peso': ['weight', 'load', 'kg', 'carico'],
    'carico': ['weight', 'load', 'volume', 'peso', 'resistance'],
    'volume': ['total volume', 'tonnage', 'volume totale'],
    'forza': ['strength', 'power', 'potenza'],

    // Time-related - English
    'today': ["today's", 'today', 'current day', 'oggi'],
    'yesterday': ["yesterday's", 'yesterday', 'previous day', 'ieri'],
    'week': ['weekly', 'this week', 'past week', '7 days', 'settimana'],
    'month': ['monthly', 'this month', 'past month', '30 days', 'mese'],
    'recent': ['latest', 'last', 'most recent', 'newest', 'recente', 'ultimo'],

    // Time-related - Italian
    'oggi': ['today', "today's", 'current day'],
    'ieri': ['yesterday', "yesterday's", 'previous day'],
    'settimana': ['week', 'weekly', 'this week', 'questa settimana'],
    'mese': ['month', 'monthly', 'this month', 'questo mese'],
    'anno': ['year', 'yearly', 'this year', 'quest anno'],
    'recente': ['recent', 'latest', 'last', 'ultimo'],
    'scorso': ['last', 'previous', 'past', 'precedente'],

    // Training concepts - English + Italian
    'superset': ['supersets', 'super set', 'super-set', 'paired', 'superserie'],
    'dropset': ['dropsets', 'drop set', 'drop-set', 'strip set', 'serie a scalare'],
    'restpause': ['rest-pause', 'rest pause', 'cluster', 'riposo-pausa'],
    'pyramid': ['pyramids', 'pyramid set', 'ascending', 'descending', 'piramidale'],

    // Training concepts - Italian
    'superserie': ['superset', 'supersets', 'super set'],
    'scalare': ['dropset', 'drop set', 'serie a scalare'],
    'piramidale': ['pyramid', 'pyramids', 'piramide'],
    'riscaldamento': ['warmup', 'warm-up', 'warm up', 'riscaldare'],

    // Common questions - English
    'progress': ['improvement', 'gains', 'progression', 'growth', 'progresso', 'miglioramento'],
    'plateau': ['plateaus', 'stuck', 'stagnant', 'no progress', 'stallo'],
    'form': ['technique', 'execution', 'proper form', 'how to', 'tecnica', 'esecuzione'],
    'recovery': ['rest', 'recuperation', 'rest day', 'recovery time', 'recupero', 'riposo'],
    'frequency': ['how often', 'times per week', 'weekly frequency', 'frequenza'],

    // Common questions - Italian
    'progresso': ['progress', 'improvement', 'gains', 'miglioramento'],
    'miglioramento': ['improvement', 'progress', 'gains', 'progressione'],
    'stallo': ['plateau', 'stuck', 'stagnant', 'no progress'],
    'tecnica': ['technique', 'form', 'execution', 'esecuzione'],
    'esecuzione': ['execution', 'technique', 'form', 'tecnica'],
    'recupero': ['recovery', 'rest', 'recuperation', 'riposo'],
    'riposo': ['rest', 'recovery', 'rest day', 'recupero'],
    'allenamento': ['workout', 'training', 'exercise', 'sessione'],
  };

  /// Abbreviation expansions (EN + IT)
  static final Map<String, String> _abbreviations = {
    // English abbreviations
    'pr': 'personal record',
    'pb': 'personal best',
    '1rm': 'one rep max',
    'bp': 'bench press',
    'dl': 'deadlift',
    'ohp': 'overhead press',
    'rdl': 'romanian deadlift',
    'db': 'dumbbell',
    'bb': 'barbell',
    'kb': 'kettlebell',
    'bw': 'bodyweight',
    'amrap': 'as many reps as possible',
    'emom': 'every minute on the minute',
    'rir': 'reps in reserve',
    'rpe': 'rate of perceived exertion',
    'doms': 'delayed onset muscle soreness',
    'cns': 'central nervous system',

    // Italian abbreviations
    'rip': 'ripetizioni',
    'max': 'massimale',
    'rec': 'recupero',
    'all': 'allenamento',
    'es': 'esercizio',
    'kg': 'chilogrammi',
    'lb': 'libbre',
  };

  /// Muscle group hierarchies
  static final Map<String, List<String>> _muscleGroups = {
    'upper': ['chest', 'back', 'shoulders', 'arms', 'triceps', 'biceps'],
    'lower': ['legs', 'quads', 'hamstrings', 'glutes', 'calves'],
    'push': ['chest', 'shoulders', 'triceps'],
    'pull': ['back', 'biceps', 'lats'],
    'legs': ['quads', 'hamstrings', 'glutes', 'calves'],
  };

  /// Question patterns that indicate specific intents (EN + IT)
  static final Map<String, List<String>> _questionPatterns = {
    // English patterns
    'how_much': ['how much', 'what weight', 'how heavy', 'quanto peso', 'quanti kg'],
    'how_many': ['how many', 'number of', 'count', 'quanti', 'quante', 'numero di'],
    'when': ['when', 'what day', 'what time', 'last time', 'quando', 'che giorno', 'ultima volta'],
    'comparison': ['better', 'versus', 'vs', 'compare', 'difference', 'meglio', 'confronta', 'differenza'],
    'recommendation': ['should i', 'recommend', 'suggest', 'advice', 'dovrei', 'consiglia', 'suggerisci'],

    // Italian patterns
    'come': ['come', 'how', 'in che modo'],
    'qual': ['qual è', 'quale', 'which', 'what'],
    'perche': ['perché', 'perchè', 'why', 'how come'],
    'mostra': ['mostra', 'show', 'visualizza', 'fammi vedere'],
    'dimmi': ['dimmi', 'tell me', 'spiegami', 'explain'],
  };

  /// Expand a query with related terms
  ExpandedQuery expandQuery(String originalQuery) {
    final query = originalQuery.toLowerCase();
    final tokens = _tokenize(query);

    final expandedTerms = <String>{};
    final detectedIntents = <String>{};
    final temporalContext = _extractTemporalContext(query);

    for (final token in tokens) {
      // Add original token
      expandedTerms.add(token);

      // Expand abbreviations
      if (_abbreviations.containsKey(token)) {
        final expanded = _abbreviations[token]!;
        expandedTerms.addAll(_tokenize(expanded));
      }

      // Add synonyms
      if (_synonyms.containsKey(token)) {
        expandedTerms.addAll(_synonyms[token]!);
      }

      // Check muscle group hierarchies
      if (_muscleGroups.containsKey(token)) {
        expandedTerms.addAll(_muscleGroups[token]!);
      }
    }

    // Detect question patterns
    for (final entry in _questionPatterns.entries) {
      for (final pattern in entry.value) {
        if (query.contains(pattern)) {
          detectedIntents.add(entry.key);
        }
      }
    }

    // Extract exercise context
    final exerciseContext = _extractExerciseContext(tokens, expandedTerms);

    return ExpandedQuery(
      original: originalQuery,
      expanded: expandedTerms.join(' '),
      tokens: tokens,
      expandedTokens: expandedTerms.toList(),
      intents: detectedIntents.toList(),
      temporalContext: temporalContext,
      exerciseContext: exerciseContext,
    );
  }

  /// Tokenize text into terms
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
  }

  /// Extract temporal context from query (EN + IT)
  TemporalContext? _extractTemporalContext(String query) {
    final now = DateTime.now();

    // Today / Oggi
    if (query.contains('today') || query.contains('oggi')) {
      return TemporalContext(
        start: DateTime(now.year, now.month, now.day),
        end: now,
        label: 'today',
      );
    }

    // Yesterday / Ieri
    if (query.contains('yesterday') || query.contains('ieri')) {
      final yesterday = now.subtract(const Duration(days: 1));
      return TemporalContext(
        start: DateTime(yesterday.year, yesterday.month, yesterday.day),
        end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        label: 'yesterday',
      );
    }

    // This week / Questa settimana / Past week / Settimana scorsa
    if (query.contains('this week') ||
        query.contains('past week') ||
        query.contains('questa settimana') ||
        query.contains('settimana scorsa') ||
        query.contains('ultima settimana')) {
      return TemporalContext(
        start: now.subtract(const Duration(days: 7)),
        end: now,
        label: 'week',
      );
    }

    // This month / Questo mese / Past month / Mese scorso
    if (query.contains('this month') ||
        query.contains('past month') ||
        query.contains('questo mese') ||
        query.contains('mese scorso') ||
        query.contains('ultimo mese')) {
      return TemporalContext(
        start: DateTime(now.year, now.month, 1),
        end: now,
        label: 'month',
      );
    }

    // This year / Quest'anno
    if (query.contains('this year') ||
        query.contains('quest anno') ||
        query.contains("quest'anno") ||
        query.contains('anno corrente')) {
      return TemporalContext(
        start: DateTime(now.year, 1, 1),
        end: now,
        label: 'year',
      );
    }

    // Check for specific day mentions (EN + IT)
    final daysEN = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final daysIT = ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'];
    final daysITNoAccent = ['lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica'];

    // Check English days
    for (int i = 0; i < daysEN.length; i++) {
      if (query.contains(daysEN[i])) {
        // Find most recent occurrence of this day
        int daysBack = (now.weekday - (i + 1)) % 7;
        if (daysBack == 0 && now.hour < 12) {
          daysBack = 7; // If it's that day but early, assume last week
        }
        final targetDay = now.subtract(Duration(days: daysBack));
        return TemporalContext(
          start: DateTime(targetDay.year, targetDay.month, targetDay.day),
          end: DateTime(targetDay.year, targetDay.month, targetDay.day, 23, 59, 59),
          label: daysEN[i],
        );
      }
    }

    // Check Italian days (with and without accents)
    for (int i = 0; i < daysIT.length; i++) {
      if (query.contains(daysIT[i]) || query.contains(daysITNoAccent[i])) {
        // Find most recent occurrence of this day
        int daysBack = (now.weekday - (i + 1)) % 7;
        if (daysBack == 0 && now.hour < 12) {
          daysBack = 7; // If it's that day but early, assume last week
        }
        final targetDay = now.subtract(Duration(days: daysBack));
        return TemporalContext(
          start: DateTime(targetDay.year, targetDay.month, targetDay.day),
          end: DateTime(targetDay.year, targetDay.month, targetDay.day, 23, 59, 59),
          label: daysIT[i],
        );
      }
    }

    return null;
  }

  /// Extract exercise context from tokens
  ExerciseContext? _extractExerciseContext(
    List<String> tokens,
    Set<String> expandedTerms,
  ) {
    // Check for specific exercises
    final exercises = ['squat', 'bench', 'deadlift', 'press', 'row', 'curl', 'pullup'];
    final detectedExercises = <String>[];

    for (final exercise in exercises) {
      if (tokens.contains(exercise) || expandedTerms.contains(exercise)) {
        detectedExercises.add(exercise);
      }
    }

    if (detectedExercises.isEmpty) return null;

    // Check for muscle groups
    final muscleGroups = <String>[];
    for (final muscle in ['chest', 'back', 'shoulders', 'legs', 'arms', 'core']) {
      if (expandedTerms.contains(muscle)) {
        muscleGroups.add(muscle);
      }
    }

    // Check for equipment
    String? equipment;
    for (final equip in ['barbell', 'dumbbell', 'cable', 'machine', 'bodyweight']) {
      if (expandedTerms.contains(equip)) {
        equipment = equip;
        break;
      }
    }

    return ExerciseContext(
      exercises: detectedExercises,
      muscleGroups: muscleGroups,
      equipment: equipment,
    );
  }

  /// Create targeted sub-queries for better search
  List<String> createSubQueries(ExpandedQuery expandedQuery) {
    final subQueries = <String>[];

    // Original query
    subQueries.add(expandedQuery.original);

    // Exercise-focused query
    if (expandedQuery.exerciseContext != null) {
      final exercises = expandedQuery.exerciseContext!.exercises.join(' ');
      if (exercises.isNotEmpty) {
        subQueries.add(exercises);
      }
    }

    // Temporal-focused query
    if (expandedQuery.temporalContext != null) {
      final temporal = expandedQuery.temporalContext!.label;
      final mainTerms = expandedQuery.tokens.where((t) => t.length > 3).join(' ');
      subQueries.add('$temporal $mainTerms');
    }

    // Intent-specific queries
    if (expandedQuery.intents.contains('how_much')) {
      subQueries.add('weight kg personal record max');
    }

    if (expandedQuery.intents.contains('comparison')) {
      subQueries.add('progress improvement gains increase');
    }

    return subQueries.toSet().toList(); // Remove duplicates
  }
}

/// Expanded query with metadata
class ExpandedQuery {

  const ExpandedQuery({
    required this.original,
    required this.expanded,
    required this.tokens,
    required this.expandedTokens,
    required this.intents,
    this.temporalContext,
    this.exerciseContext,
  });
  final String original;
  final String expanded;
  final List<String> tokens;
  final List<String> expandedTokens;
  final List<String> intents;
  final TemporalContext? temporalContext;
  final ExerciseContext? exerciseContext;

  /// Check if query is about personal records
  bool get isPRQuery => expandedTokens.any((t) =>
      t.contains('pr') ||
      t.contains('personal') ||
      t.contains('record') ||
      t.contains('max') ||
      t.contains('best'));

  /// Check if query is temporal
  bool get isTemporalQuery => temporalContext != null;

  /// Check if query is about specific exercises
  bool get isExerciseSpecific => exerciseContext?.exercises.isNotEmpty ?? false;

  /// Get query complexity score
  double get complexityScore {
    double score = tokens.length / 10.0; // Base complexity from length

    if (isTemporalQuery) score += 0.2;
    if (isExerciseSpecific) score += 0.3;
    if (intents.isNotEmpty) score += 0.2;
    if (isPRQuery) score += 0.2;

    return score.clamp(0.0, 1.0);
  }
}

/// Temporal context for queries
class TemporalContext {

  const TemporalContext({
    required this.start,
    required this.end,
    required this.label,
  });
  final DateTime start;
  final DateTime end;
  final String label;

  /// Check if a date falls within this context
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }
}

/// Exercise context for queries
class ExerciseContext {

  const ExerciseContext({
    required this.exercises,
    required this.muscleGroups,
    this.equipment,
  });
  final List<String> exercises;
  final List<String> muscleGroups;
  final String? equipment;

  /// Check if context matches an exercise
  bool matchesExercise(String exerciseName) {
    final normalized = exerciseName.toLowerCase();
    return exercises.any((e) => normalized.contains(e));
  }
}