/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: response_templates
///
/// Response Repository - Pre-written responses for chat bot
///
/// **Purpose**: Provide template responses for each user intent
///
/// **Features**:
/// - Template variables: `{username}`, `{metric}`, `{recommendation}`
/// - Multiple response variants (randomized for variety)
/// - Localization support (EN + IT)
/// - Context-aware responses (uses analyzer data)
///
/// **Personalization Strategy**:
/// - Inject analyzer metrics into templates
/// - Use user's name for personal touch
/// - Reference recent workout data
/// - Provide actionable recommendations
library;

import 'dart:math';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

/// Response template with variables
class ResponseTemplate {

  const ResponseTemplate({
    required this.text,
    this.requiredVariables = const [],
  });
  final String text;
  final List<String> requiredVariables;

  /// Replace variables in template
  String format(Map<String, String> variables) {
    var result = text;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}

/// Repository for chat bot responses
///
/// **Usage**:
/// ```dart
/// final repo = ResponseRepository();
/// final response = repo.getResponse(
///   intent: UserIntent.progression,
///   context: {'username': 'Mike', 'metric': '+12%', 'period': '30 days'},
/// );
/// // Returns: "Great job Mike! You've improved by +12% over the last 30 days. Keep it up!"
/// ```
class ResponseRepository {
  final Random _random = Random();

  /// Get response for user intent with context
  ///
  /// **Parameters**:
  /// - `intent`: Detected user intent
  /// - `context`: Variables for personalization (username, metrics, etc.)
  /// - `locale`: Language code ('en' or 'it')
  ///
  /// **Returns**: Formatted response string
  String getResponse({
    required UserIntent intent,
    Map<String, String> context = const {},
    String locale = 'en',
  }) {
    // Get template variants for intent
    final templates = _getTemplatesForIntent(intent, locale);

    if (templates.isEmpty) {
      return _getFallbackResponse(locale);
    }

    // Special handling for prQuery intent (deterministic selection)
    if (intent == UserIntent.prQuery) {
      final template = _selectPRQueryTemplate(templates, context);
      return template.format(context);
    }

    // Pick random variant for variety (for other intents)
    final template = templates[_random.nextInt(templates.length)];

    // Format with context variables
    return template.format(context);
  }

  /// Select appropriate PR query template based on context
  ///
  /// **Template Selection Logic**:
  /// - Template 0: PR data (has_data = true)
  /// - Template 1: No data (has_data = false)
  /// - Template 2: Matches found (match_count > 0)
  /// - Template 3: No matches (match_count = 0)
  /// - Template 4: Generic fallback
  ///
  /// **Context Variables**:
  /// - `has_data`: 'true' if PR data found, 'false' if no data
  /// - `match_count`: Number of exercise matches found
  /// - `search_query`: User's search query (for no matches message)
  ResponseTemplate _selectPRQueryTemplate(
    List<ResponseTemplate> templates,
    Map<String, String> context,
  ) {
    final hasData = context['has_data'] == 'true';
    final matchCountStr = context['match_count'] ?? '0';
    final matchCount = int.tryParse(matchCountStr) ?? 0;

    if (hasData) {
      // User clicked exercise chip → show PR data
      return templates[0]; // PR data template
    } else if (context['has_data'] == 'false') {
      // Exercise found but no workout data
      return templates[1]; // No data template
    } else if (matchCount > 0) {
      // Exercise search found matches
      return templates[2]; // Matches found template
    } else if (matchCount == 0 && context.containsKey('search_query')) {
      // Exercise search found no matches
      return templates[3]; // No matches template
    } else {
      // Fallback for unclear query
      return templates[4]; // Generic fallback template
    }
  }

  /// Get follow-up chips for branching conversations
  ///
  /// **Parameters**:
  /// - `intent`: Current intent (main or sub-intent)
  /// - `locale`: Language code ('en' or 'it')
  /// - `depth`: Current conversation depth (0 = root, max 3)
  ///
  /// **Returns**: List of 2-3 follow-up chips (empty if depth >= 3)
  ///
  /// **Depth Strategy**:
  /// - Depth 0: Root chips (general exploration)
  /// - Depth 1: Sub-intent specific chips (deeper details)
  /// - Depth 2: Action chips (navigate to screens, end conversation)
  /// - Depth 3+: No chips (prevent infinite branching)
  List<FollowUpChip> getFollowUpChips({
    required UserIntent intent,
    String locale = 'en',
    int depth = 0,
  }) {
    // Max depth reached → no more follow-ups (prevent infinite branching)
    if (depth >= 3) {
      return [];
    }

    // Generate follow-up chips based on intent AND depth
    switch (intent) {
      case UserIntent.progression:
        return _getProgressionFollowUps(locale, depth);
      case UserIntent.volume:
        return _getVolumeFollowUps(locale, depth);
      case UserIntent.recovery:
        return _getRecoveryFollowUps(locale, depth);
      case UserIntent.balance:
        return _getBalanceFollowUps(locale, depth);
      case UserIntent.form:
        return _getFormFollowUps(locale, depth);
      case UserIntent.motivation:
        return _getMotivationFollowUps(locale, depth);
      case UserIntent.plan:
        return _getPlanFollowUps(locale, depth);
      case UserIntent.greeting:
      case UserIntent.unknown:
      case UserIntent.prQuery:
      case UserIntent.help:
        return []; // No follow-ups for these intents
    }
  }

  /// Convert chip intent to full question for intent detection
  ///
  /// **Purpose**: When user taps a chip, send a full question that triggers
  /// the correct intent detection, not just the chip label.
  ///
  /// **Example**:
  /// - Chip intent: "progression.details"
  /// - Returns: "Mostrami i dettagli numerici della mia progressione" (IT)
  /// - Returns: "Show me the numerical details of my progression" (EN)
  String getFullQuestionForChip(String chipIntent, String locale) {
    // Mapping: chip intent → full question that triggers intent detection
    final questionsIT = {
      // Progression sub-intents (depth 0)
      'progression.details': 'Mostrami i dettagli numerici della mia progressione',
      'progression.best_exercises': 'Quali sono i miei migliori esercizi in progressione?',
      'progression.worst_exercises': 'Quali esercizi sono in stallo o peggioramento?',
      // Progression depth 1
      'progression.trend': 'Mostrami il trend di progressione degli ultimi mesi',
      'progression.compare': 'Confronta la progressione tra diversi esercizi',
      'progression.goals': 'Quali sono i miei obiettivi di progressione?',

      // Volume sub-intents (depth 0)
      'volume.per_group': 'Mostrami il volume per ogni gruppo muscolare',
      'volume.weekly_comparison': 'Come si confronta il volume di questa settimana con la precedente?',
      'volume.recommendations': 'Dammi raccomandazioni sul volume di allenamento',
      // Volume depth 1
      'volume.optimize': 'Come posso ottimizzare il mio volume di allenamento?',
      'volume.reduce_fatigue': 'Come ridurre l\'affaticamento mantenendo volume?',

      // Recovery sub-intents (depth 0)
      'recovery.sleep_quality': 'Come influisce la qualità del sonno sul mio recupero?',
      'recovery.rest_times': 'Quali sono i tempi di recupero ottimali per me?',
      'recovery.overtraining_signs': 'Ho segnali di sovrallenamento o overtraining?',
      // Recovery depth 1
      'recovery.strategies': 'Quali strategie posso usare per recuperare meglio?',
      'recovery.deload': 'Ho bisogno di una settimana di deload?',

      // Balance sub-intents
      'balance.lagging_groups': 'Quali sono i miei gruppi muscolari più deboli?',
      'balance.push_pull_ratio': 'Come è il mio rapporto tra esercizi push e pull?',
      'balance.corrective_exercises': 'Quali esercizi correttivi dovrei fare?',

      // Form sub-intents
      'form.video_tutorials': 'Dove posso trovare video tutorial per la tecnica?',
      'form.common_mistakes': 'Quali sono gli errori comuni nella mia tecnica?',
      'form.optimal_setup': 'Come faccio il setup ottimale per questo esercizio?',

      // Motivation sub-intents
      'motivation.recent_achievements': 'Quali sono i miei ultimi successi in allenamento?',
      'motivation.next_goals': 'Quali dovrebbero essere i miei prossimi obiettivi?',
      'motivation.mental_strategies': 'Quali strategie mentali posso usare per migliorare?',

      // Plan sub-intents
      'plan.optimal_frequency': 'Qual è la frequenza di allenamento ottimale per me?',
      'plan.when_to_change': 'Quando dovrei cambiare il mio programma di allenamento?',
      'plan.key_exercises': 'Quali sono gli esercizi chiave che dovrei fare?',

      // Navigation actions (depth 2)
      'navigation.analytics': 'Voglio vedere le mie analytics dettagliate',
      'navigation.workout': 'Voglio iniziare un nuovo allenamento',
    };

    final questionsEN = {
      // Progression sub-intents (depth 0)
      'progression.details': 'Show me the numerical details of my progression',
      'progression.best_exercises': 'What are my best progressing exercises?',
      'progression.worst_exercises': 'Which exercises are stalled or regressing?',
      // Progression depth 1
      'progression.trend': 'Show me the progression trend over recent months',
      'progression.compare': 'Compare progression between different exercises',
      'progression.goals': 'What are my progression goals?',

      // Volume sub-intents (depth 0)
      'volume.per_group': 'Show me the volume for each muscle group',
      'volume.weekly_comparison': 'How does this week\'s volume compare to last week?',
      'volume.recommendations': 'Give me recommendations about training volume',
      // Volume depth 1
      'volume.optimize': 'How can I optimize my training volume?',
      'volume.reduce_fatigue': 'How to reduce fatigue while maintaining volume?',

      // Recovery sub-intents (depth 0)
      'recovery.sleep_quality': 'How does sleep quality affect my recovery?',
      'recovery.rest_times': 'What are the optimal rest times for me?',
      'recovery.overtraining_signs': 'Do I have signs of overtraining?',
      // Recovery depth 1
      'recovery.strategies': 'What strategies can I use to recover better?',
      'recovery.deload': 'Do I need a deload week?',

      // Balance sub-intents
      'balance.lagging_groups': 'What are my weakest muscle groups?',
      'balance.push_pull_ratio': 'What is my push-pull exercise ratio?',
      'balance.corrective_exercises': 'What corrective exercises should I do?',

      // Form sub-intents
      'form.video_tutorials': 'Where can I find video tutorials for technique?',
      'form.common_mistakes': 'What are common mistakes in my technique?',
      'form.optimal_setup': 'How do I set up optimally for this exercise?',

      // Motivation sub-intents
      'motivation.recent_achievements': 'What are my recent training achievements?',
      'motivation.next_goals': 'What should my next goals be?',
      'motivation.mental_strategies': 'What mental strategies can I use to improve?',

      // Plan sub-intents
      'plan.optimal_frequency': 'What is the optimal training frequency for me?',
      'plan.when_to_change': 'When should I change my training program?',
      'plan.key_exercises': 'What are the key exercises I should do?',

      // Navigation actions (depth 2)
      'navigation.analytics': 'I want to see my detailed analytics',
      'navigation.workout': 'I want to start a new workout',
    };

    final questions = locale == 'it' ? questionsIT : questionsEN;

    // Return full question or fallback to original chip label
    return questions[chipIntent] ?? chipIntent;
  }

  /// Get all template variants for an intent
  List<ResponseTemplate> _getTemplatesForIntent(UserIntent intent, String locale) {
    switch (intent) {
      case UserIntent.greeting:
        return _getGreetingTemplates(locale);
      case UserIntent.progression:
        return _getProgressionTemplates(locale);
      case UserIntent.volume:
        return _getVolumeTemplates(locale);
      case UserIntent.recovery:
        return _getRecoveryTemplates(locale);
      case UserIntent.balance:
        return _getBalanceTemplates(locale);
      case UserIntent.form:
        return _getFormTemplates(locale);
      case UserIntent.motivation:
        return _getMotivationTemplates(locale);
      case UserIntent.plan:
        return _getPlanTemplates(locale);
      case UserIntent.prQuery:
        return _getPRQueryTemplates(locale);
      case UserIntent.help:
        return _getHelpTemplates(locale);
      case UserIntent.unknown:
        return _getUnknownTemplates(locale);
    }
  }

  // ========================================================================
  // Template Variants (EN)
  // ========================================================================

  List<ResponseTemplate> _getGreetingTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(text: "Ciao {username}! Come va l'allenamento oggi? 💪"),
        const ResponseTemplate(text: 'Hey {username}! Pronto per analizzare i tuoi progressi?'),
        const ResponseTemplate(text: 'Ciao! Cosa vuoi sapere sui tuoi allenamenti?'),
      ];
    }
    return [
      const ResponseTemplate(text: "Hey {username}! How's your training going today? 💪"),
      const ResponseTemplate(text: 'Hi {username}! Ready to analyze your progress?'),
      const ResponseTemplate(text: 'Hello! What would you like to know about your workouts?'),
    ];
  }

  List<ResponseTemplate> _getProgressionTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Ottimo lavoro {username}! Negli ultimi {period} hai migliorato di {metric}. {recommendation}',
          requiredVariables: ['username', 'period', 'metric', 'recommendation'],
        ),
        const ResponseTemplate(
          text: 'La tua progressione è {trend}. {metric} negli ultimi {period}. {recommendation}',
          requiredVariables: ['trend', 'metric', 'period', 'recommendation'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: "Great job {username}! Over the last {period} you've improved by {metric}. {recommendation}",
        requiredVariables: ['username', 'period', 'metric', 'recommendation'],
      ),
      const ResponseTemplate(
        text: 'Your progression trend is {trend}. {metric} over {period}. {recommendation}',
        requiredVariables: ['trend', 'metric', 'period', 'recommendation'],
      ),
    ];
  }

  List<ResponseTemplate> _getVolumeTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Il tuo volume settimanale è {volume}. {recommendation}',
          requiredVariables: ['volume', 'recommendation'],
        ),
        const ResponseTemplate(
          text: '{assessment} Stai facendo {sets_per_week} serie/settimana. {recommendation}',
          requiredVariables: ['assessment', 'sets_per_week', 'recommendation'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: 'Your weekly volume is {volume}. {recommendation}',
        requiredVariables: ['volume', 'recommendation'],
      ),
      const ResponseTemplate(
        text: "{assessment} You're doing {sets_per_week} sets/week. {recommendation}",
        requiredVariables: ['assessment', 'sets_per_week', 'recommendation'],
      ),
    ];
  }

  List<ResponseTemplate> _getRecoveryTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Il tuo punteggio di recupero è {score}/100. {recommendation}',
          requiredVariables: ['score', 'recommendation'],
        ),
        const ResponseTemplate(
          text: '{status_emoji} Recupero: {status}. Ultima sessione: {hours_ago} ore fa. {recommendation}',
          requiredVariables: ['status_emoji', 'status', 'hours_ago', 'recommendation'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: 'Your recovery score is {score}/100. {recommendation}',
        requiredVariables: ['score', 'recommendation'],
      ),
      const ResponseTemplate(
        text: '{status_emoji} Recovery: {status}. Last session: {hours_ago}h ago. {recommendation}',
        requiredVariables: ['status_emoji', 'status', 'hours_ago', 'recommendation'],
      ),
    ];
  }

  List<ResponseTemplate> _getBalanceTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Equilibrio gruppi muscolari: {balance_score}%. {lagging_groups} {recommendation}',
          requiredVariables: ['balance_score', 'lagging_groups', 'recommendation'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: 'Muscle group balance: {balance_score}%. {lagging_groups} {recommendation}',
        requiredVariables: ['balance_score', 'lagging_groups', 'recommendation'],
      ),
    ];
  }

  List<ResponseTemplate> _getFormTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Per {exercise}: {form_cue}. {safety_tip}',
          requiredVariables: ['exercise', 'form_cue', 'safety_tip'],
        ),
        const ResponseTemplate(
          text: 'La tecnica è fondamentale! Concentrati su: {form_cue}',
          requiredVariables: ['form_cue'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: 'For {exercise}: {form_cue}. {safety_tip}',
        requiredVariables: ['exercise', 'form_cue', 'safety_tip'],
      ),
      const ResponseTemplate(
        text: 'Technique is key! Focus on: {form_cue}',
        requiredVariables: ['form_cue'],
      ),
    ];
  }

  List<ResponseTemplate> _getMotivationTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(text: '💪 Non mollare! Ogni ripetizione conta. {achievement}'),
        const ResponseTemplate(text: 'Ricorda perché hai iniziato. {recent_progress}'),
        const ResponseTemplate(text: 'I plateau sono temporanei. {strategy}'),
      ];
    }
    return [
      const ResponseTemplate(text: "💪 Don't give up! Every rep counts. {achievement}"),
      const ResponseTemplate(text: 'Remember why you started. {recent_progress}'),
      const ResponseTemplate(text: 'Plateaus are temporary. {strategy}'),
    ];
  }

  List<ResponseTemplate> _getPlanTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: 'Basandomi sui tuoi dati: {current_split}. {recommendation}',
          requiredVariables: ['current_split', 'recommendation'],
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: 'Based on your data: {current_split}. {recommendation}',
        requiredVariables: ['current_split', 'recommendation'],
      ),
    ];
  }

  List<ResponseTemplate> _getPRQueryTemplates(String locale) {
    // Phase 4+5: PR query templates with dynamic exercise matching + PR data display
    // Context variables:
    // - Phase 4 (search): exercise_matches, match_count, search_query
    // - Phase 5 (PR data): exercise_name, pr_1rm, pr_weight, pr_reps, pr_date, has_data
    //
    // Template selection logic (manual in getResponse):
    // 1. If has_data = true → use template 0 (PR data)
    // 2. If has_data = false → use template 1 (no data)
    // 3. If match_count > 0 → use template 2 (matches found)
    // 4. If match_count = 0 → use template 3 (no matches)
    // 5. Otherwise → use template 4 (generic)
    if (locale == 'it') {
      return [
        // Template 0: PR data (has_data = true)
        const ResponseTemplate(
          text: '🏋️ Il tuo record personale per {exercise_name}:\n\n'
              '💪 **1RM stimato**: {pr_1rm} kg\n'
              '🎯 **Miglior set**: {pr_weight} kg × {pr_reps} ripetizioni\n'
              '📅 **Data**: {pr_date}\n\n'
              '📊 *1RM calcolato con formula Epley: (peso × reps / 37.5) + peso*\n\n'
              'Continua così! 💯',
          requiredVariables: ['exercise_name', 'pr_1rm', 'pr_weight', 'pr_reps', 'pr_date'],
        ),
        // Template 1: No data found (has_data = false)
        const ResponseTemplate(
          text: 'Non ho trovato dati storici per {exercise_name}. Inizia a registrare i tuoi allenamenti per tracciare i progressi! 📊',
          requiredVariables: ['exercise_name'],
        ),
        // Template 2: Matches found (match_count > 0)
        const ResponseTemplate(
          text: "Ho trovato {match_count} esercizi corrispondenti a '{search_query}'. Seleziona quello che ti interessa:",
          requiredVariables: ['match_count', 'search_query'],
        ),
        // Template 3: No matches (match_count = 0)
        const ResponseTemplate(
          text: "Non ho trovato esercizi corrispondenti a '{search_query}'. Prova a riformulare (es. 'panca piana', 'squat', 'deadlift').",
          requiredVariables: ['search_query'],
        ),
        // Template 4: Generic fallback
        const ResponseTemplate(
          text: 'Cerchiamo il tuo massimale! Di quale esercizio vuoi sapere il record?',
        ),
      ];
    }
    return [
      // Template 0: PR data (has_data = true) (EN)
      const ResponseTemplate(
        text: '🏋️ Your personal record for {exercise_name}:\n\n'
            '💪 **Estimated 1RM**: {pr_1rm} kg\n'
            '🎯 **Best set**: {pr_weight} kg × {pr_reps} reps\n'
            '📅 **Date**: {pr_date}\n\n'
            '📊 *1RM calculated with Epley formula: (weight × reps / 37.5) + weight*\n\n'
            'Keep it up! 💯',
        requiredVariables: ['exercise_name', 'pr_1rm', 'pr_weight', 'pr_reps', 'pr_date'],
      ),
      // Template 1: No data found (has_data = false) (EN)
      const ResponseTemplate(
        text: "I couldn't find historical data for {exercise_name}. Start logging your workouts to track progress! 📊",
        requiredVariables: ['exercise_name'],
      ),
      // Template 2: Matches found (match_count > 0) (EN)
      const ResponseTemplate(
        text: "I found {match_count} exercises matching '{search_query}'. Select the one you're interested in:",
        requiredVariables: ['match_count', 'search_query'],
      ),
      // Template 3: No matches (match_count = 0) (EN)
      const ResponseTemplate(
        text: "I couldn't find exercises matching '{search_query}'. Try rephrasing (e.g., 'bench press', 'squat', 'deadlift').",
        requiredVariables: ['search_query'],
      ),
      // Template 4: Generic fallback (EN)
      const ResponseTemplate(
        text: "Let's find your max! Which exercise do you want to know your record for?",
      ),
    ];
  }

  List<ResponseTemplate> _getHelpTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: '🤖 Ecco cosa posso fare per te:\n\n'
              '📈 **Progressione**: "Come sto progredendo?", "Mostrami i miei record"\n'
              '💪 **Volume**: "Sto allenandomi troppo?", "Volume ottimale?"\n'
              '😴 **Recupero**: "Devo riposare?", "Sono recuperato?"\n'
              '⚖️ **Equilibrio**: "I miei muscoli sono bilanciati?"\n'
              '🎯 **Tecnica**: "Consigli sulla tecnica", "Come fare squat?"\n'
              '🔥 **Motivazione**: "Ho bisogno di motivazione"\n'
              '📅 **Piano**: "Serve un nuovo programma?"\n\n'
              '💡 **Tip**: Fai domande naturali, rispondo in base ai tuoi dati di allenamento!',
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: "🤖 Here's what I can do for you:\n\n"
            '📈 **Progression**: "How am I progressing?", "Show my PRs"\n'
            '💪 **Volume**: "Am I training too much?", "Optimal volume?"\n'
            '😴 **Recovery**: "Should I rest?", "Am I recovered?"\n'
            '⚖️ **Balance**: "Are my muscles balanced?"\n'
            '🎯 **Form**: "Form tips", "How to squat?"\n'
            '🔥 **Motivation**: "Need motivation"\n'
            '📅 **Plan**: "Need a new program?"\n\n'
            "💡 **Tip**: Ask natural questions, I'll answer based on your workout data!",
      ),
    ];
  }

  List<ResponseTemplate> _getUnknownTemplates(String locale) {
    if (locale == 'it') {
      return [
        const ResponseTemplate(
          text: '🤔 Non ho capito bene la tua richiesta.\n\n'
              'Posso aiutarti con: **progressi**, **volume**, **recupero**, **equilibrio muscolare**, **tecnica**, **motivazione**.\n\n'
              '❓ Prova a riformulare, ad esempio:\n'
              '• "Come sto progredendo?"\n'
              '• "Devo riposare?"\n'
              '• "Qual è il mio massimale di panca?"\n\n'
              "💡 Scrivi **'aiuto'** per vedere tutte le mie capacità.",
        ),
        const ResponseTemplate(
          text: '⚠️ Non sono sicuro di cosa intendi.\n\n'
              'Posso rispondere a domande su:\n'
              '• Progressione e record personali\n'
              '• Volume di allenamento\n'
              '• Recupero e riposo\n'
              '• Equilibrio muscolare\n\n'
              "🔄 Prova a riformulare o scrivi **'aiuto'** per la lista completa.",
        ),
      ];
    }
    return [
      const ResponseTemplate(
        text: "🤔 I didn't quite understand your request.\n\n"
            'I can help with: **progress**, **volume**, **recovery**, **muscle balance**, **form**, **motivation**.\n\n'
            '❓ Try rephrasing, for example:\n'
            '• "How am I progressing?"\n'
            '• "Should I rest?"\n'
            "• \"What's my bench press max?\"\n\n"
            "💡 Type **'help'** to see all my capabilities.",
      ),
      const ResponseTemplate(
        text: "⚠️ I'm not sure what you mean.\n\n"
            'I can answer questions about:\n'
            '• Progression and personal records\n'
            '• Training volume\n'
            '• Recovery and rest\n'
            '• Muscle balance\n\n'
            "🔄 Try rephrasing or type **'help'** for the complete list.",
      ),
    ];
  }

  String _getFallbackResponse(String locale) {
    return locale == 'it'
        ? 'Scusa, non riesco a rispondere a questo. Prova con domande su allenamento e progressi.'
        : "Sorry, I can't answer that. Try asking about training and progress.";
  }

  // ========================================================================
  // Follow-Up Chips Generators (Branching Conversation)
  // ========================================================================

  List<FollowUpChip> _getProgressionFollowUps(String locale, int depth) {
    // Depth 0: Root exploration chips
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Dettagli numeri',
            intent: 'progression.details',
            emoji: '📊',
          ),
          const FollowUpChip(
            label: 'Migliori esercizi',
            intent: 'progression.best_exercises',
            emoji: '💪',
          ),
          const FollowUpChip(
            label: 'Esercizi in stallo',
            intent: 'progression.worst_exercises',
            emoji: '⚠️',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Number details',
          intent: 'progression.details',
          emoji: '📊',
        ),
        const FollowUpChip(
          label: 'Best exercises',
          intent: 'progression.best_exercises',
          emoji: '💪',
        ),
        const FollowUpChip(
          label: 'Stalled exercises',
          intent: 'progression.worst_exercises',
          emoji: '⚠️',
        ),
      ];
    }

    // Depth 1: Deeper exploration chips
    if (depth == 1) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Trend ultimi mesi',
            intent: 'progression.trend',
            emoji: '📈',
          ),
          const FollowUpChip(
            label: 'Confronto esercizi',
            intent: 'progression.compare',
            emoji: '🔄',
          ),
          const FollowUpChip(
            label: 'Obiettivi',
            intent: 'progression.goals',
            emoji: '🎯',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Recent trend',
          intent: 'progression.trend',
          emoji: '📈',
        ),
        const FollowUpChip(
          label: 'Compare exercises',
          intent: 'progression.compare',
          emoji: '🔄',
        ),
        const FollowUpChip(
          label: 'Goals',
          intent: 'progression.goals',
          emoji: '🎯',
        ),
      ];
    }

    // Depth 2: Action chips (navigate or end)
    if (locale == 'it') {
      return [
        const FollowUpChip(
          label: 'Vai ad Analytics',
          intent: 'navigation.analytics',
          emoji: '📱',
        ),
        const FollowUpChip(
          label: 'Nuovo allenamento',
          intent: 'navigation.workout',
          emoji: '🏋️',
        ),
      ];
    }
    return [
      const FollowUpChip(
        label: 'Go to Analytics',
        intent: 'navigation.analytics',
        emoji: '📱',
      ),
      const FollowUpChip(
        label: 'New workout',
        intent: 'navigation.workout',
        emoji: '🏋️',
      ),
    ];
  }

  List<FollowUpChip> _getVolumeFollowUps(String locale, int depth) {
    // Depth 0: Root exploration
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Volume per gruppo',
            intent: 'volume.per_group',
            emoji: '📈',
          ),
          const FollowUpChip(
            label: 'Confronto settimane',
            intent: 'volume.weekly_comparison',
            emoji: '🔄',
          ),
          const FollowUpChip(
            label: 'Raccomandazioni',
            intent: 'volume.recommendations',
            emoji: '💡',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Volume per group',
          intent: 'volume.per_group',
          emoji: '📈',
        ),
        const FollowUpChip(
          label: 'Weekly comparison',
          intent: 'volume.weekly_comparison',
          emoji: '🔄',
        ),
        const FollowUpChip(
          label: 'Recommendations',
          intent: 'volume.recommendations',
          emoji: '💡',
        ),
      ];
    }

    // Depth 1: Deeper analysis
    if (depth == 1) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Ottimizza volume',
            intent: 'volume.optimize',
            emoji: '⚡',
          ),
          const FollowUpChip(
            label: 'Ridurre affaticamento',
            intent: 'volume.reduce_fatigue',
            emoji: '😴',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Optimize volume',
          intent: 'volume.optimize',
          emoji: '⚡',
        ),
        const FollowUpChip(
          label: 'Reduce fatigue',
          intent: 'volume.reduce_fatigue',
          emoji: '😴',
        ),
      ];
    }

    // Depth 2: Actions
    if (locale == 'it') {
      return [
        const FollowUpChip(
          label: 'Vai ad Analytics',
          intent: 'navigation.analytics',
          emoji: '📱',
        ),
      ];
    }
    return [
      const FollowUpChip(
        label: 'Go to Analytics',
        intent: 'navigation.analytics',
        emoji: '📱',
      ),
    ];
  }

  List<FollowUpChip> _getRecoveryFollowUps(String locale, int depth) {
    // Depth 0: Root exploration
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Qualità sonno',
            intent: 'recovery.sleep_quality',
            emoji: '😴',
          ),
          const FollowUpChip(
            label: 'Tempi recupero',
            intent: 'recovery.rest_times',
            emoji: '🕐',
          ),
          const FollowUpChip(
            label: 'Segnali overtraining',
            intent: 'recovery.overtraining_signs',
            emoji: '🚨',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Sleep quality',
          intent: 'recovery.sleep_quality',
          emoji: '😴',
        ),
        const FollowUpChip(
          label: 'Rest times',
          intent: 'recovery.rest_times',
          emoji: '🕐',
        ),
        const FollowUpChip(
          label: 'Overtraining signs',
          intent: 'recovery.overtraining_signs',
          emoji: '🚨',
        ),
      ];
    }

    // Depth 1: Actionable recovery advice
    if (depth == 1) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Strategie recupero',
            intent: 'recovery.strategies',
            emoji: '💡',
          ),
          const FollowUpChip(
            label: 'Deload necessario?',
            intent: 'recovery.deload',
            emoji: '📉',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Recovery strategies',
          intent: 'recovery.strategies',
          emoji: '💡',
        ),
        const FollowUpChip(
          label: 'Need deload?',
          intent: 'recovery.deload',
          emoji: '📉',
        ),
      ];
    }

    // Depth 2: End conversation
    return [];
  }

  List<FollowUpChip> _getBalanceFollowUps(String locale, int depth) {
    // Depth 0: Root
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Gruppi deboli',
            intent: 'balance.lagging_groups',
            emoji: '🔍',
          ),
          const FollowUpChip(
            label: 'Push/Pull ratio',
            intent: 'balance.push_pull_ratio',
            emoji: '⚖️',
          ),
          const FollowUpChip(
            label: 'Esercizi correttivi',
            intent: 'balance.corrective_exercises',
            emoji: '🎯',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Lagging groups',
          intent: 'balance.lagging_groups',
          emoji: '🔍',
        ),
        const FollowUpChip(
          label: 'Push/Pull ratio',
          intent: 'balance.push_pull_ratio',
          emoji: '⚖️',
        ),
        const FollowUpChip(
          label: 'Corrective exercises',
          intent: 'balance.corrective_exercises',
          emoji: '🎯',
        ),
      ];
    }

    // Depth 1+: End
    return [];
  }

  List<FollowUpChip> _getFormFollowUps(String locale, int depth) {
    // Depth 0: Root
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Video tutorial',
            intent: 'form.video_tutorials',
            emoji: '🎥',
          ),
          const FollowUpChip(
            label: 'Errori comuni',
            intent: 'form.common_mistakes',
            emoji: '⚠️',
          ),
          const FollowUpChip(
            label: 'Setup ottimale',
            intent: 'form.optimal_setup',
            emoji: '🔧',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Video tutorials',
          intent: 'form.video_tutorials',
          emoji: '🎥',
        ),
        const FollowUpChip(
          label: 'Common mistakes',
          intent: 'form.common_mistakes',
          emoji: '⚠️',
        ),
        const FollowUpChip(
          label: 'Optimal setup',
          intent: 'form.optimal_setup',
          emoji: '🔧',
        ),
      ];
    }

    // Depth 1+: End
    return [];
  }

  List<FollowUpChip> _getMotivationFollowUps(String locale, int depth) {
    // Depth 0: Root
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Ultimi successi',
            intent: 'motivation.recent_achievements',
            emoji: '🏆',
          ),
          const FollowUpChip(
            label: 'Obiettivi prossimi',
            intent: 'motivation.next_goals',
            emoji: '🎯',
          ),
          const FollowUpChip(
            label: 'Strategie mentali',
            intent: 'motivation.mental_strategies',
            emoji: '💭',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Recent wins',
          intent: 'motivation.recent_achievements',
          emoji: '🏆',
        ),
        const FollowUpChip(
          label: 'Next goals',
          intent: 'motivation.next_goals',
          emoji: '🎯',
        ),
        const FollowUpChip(
          label: 'Mental strategies',
          intent: 'motivation.mental_strategies',
          emoji: '💭',
        ),
      ];
    }

    // Depth 1+: End
    return [];
  }

  List<FollowUpChip> _getPlanFollowUps(String locale, int depth) {
    // Depth 0: Root
    if (depth == 0) {
      if (locale == 'it') {
        return [
          const FollowUpChip(
            label: 'Frequenza ottimale',
            intent: 'plan.optimal_frequency',
            emoji: '📅',
          ),
          const FollowUpChip(
            label: 'Quando cambiare',
            intent: 'plan.when_to_change',
            emoji: '🔄',
          ),
          const FollowUpChip(
            label: 'Esercizi chiave',
            intent: 'plan.key_exercises',
            emoji: '💪',
          ),
        ];
      }
      return [
        const FollowUpChip(
          label: 'Optimal frequency',
          intent: 'plan.optimal_frequency',
          emoji: '📅',
        ),
        const FollowUpChip(
          label: 'When to change',
          intent: 'plan.when_to_change',
          emoji: '🔄',
        ),
        const FollowUpChip(
          label: 'Key exercises',
          intent: 'plan.key_exercises',
          emoji: '💪',
        ),
      ];
    }

    // Depth 1+: End
    return [];
  }
}
