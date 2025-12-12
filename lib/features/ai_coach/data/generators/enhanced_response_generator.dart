/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/generators
/// 🎯 Feature: ai_coach
/// 🔧 Type: response_generator
///
/// Enhanced Response Generator - Context-aware response generation using search results
///
/// **Features**:
/// - Uses BM25 search results for context
/// - Generates data-driven responses
/// - Includes relevant workout statistics
/// - Provides personalized insights
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/query_expander.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/utils/document_data_extractor.dart';
import 'package:intl/intl.dart';

/// Generates enhanced responses using search results
///
/// **Localization Support**:
/// - All responses are localized (IT/EN)
/// - Uses professional fitness terminology
/// - Provides educational context for technical terms
class EnhancedResponseGenerator {
  /// Current locale for response generation
  String _locale = 'en';

  /// Set locale for responses ('en' or 'it')
  void setLocale(String locale) {
    _locale = locale == 'it' ? 'it' : 'en';
  }

  DateFormat get _dateFormat => DateFormat('d MMMM', _locale);
  DateFormat get _dayFormat => DateFormat('EEEE', _locale);
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  /// Localized strings
  String _l(String key) => _localizedStrings[_locale]?[key] ?? _localizedStrings['en']![key] ?? key;

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      // PR Response
      'pr_title': '💪 Your personal record for **{exercise}** is **{weight}kg**!',
      'pr_achieved_on': 'You achieved this on {date} ({day}).',
      'pr_recent': 'Recent performances:',
      'pr_not_found': 'I couldn\'t find a personal record for {exercise} in your history.',
      'pr_not_found_explanation': 'This could mean you haven\'t tracked this exercise yet, or you haven\'t marked any sets as PRs.',
      'pr_tip': '💡 **Tip**: When you hit a new personal best, tap the PR badge on that set!',
      // Progression
      'progression_title': '📈 **Progression Analysis**',
      'progression_starting': 'Starting',
      'progression_current': 'Current',
      'progression_improvement': 'Improvement',
      'progression_consistency': 'Consistency',
      'progression_insights': '**Key Insights:**',
      'progression_excellent': '✅ Excellent progress on compound movements',
      'progression_plateau': '⚠️ Some exercises showing plateau - consider variation',
      'progression_analyzing': 'Let me analyze your progression...',
      // Exercise
      'exercise_analysis': '📊 **{exercise} Analysis**',
      'exercise_summary': '**Performance Summary:**',
      'exercise_best': 'Best',
      'exercise_average': 'Average',
      'exercise_volume': 'Total Volume',
      'exercise_frequency': 'Frequency',
      'exercise_recent': '**Recent Sessions:**',
      'exercise_not_tracked': 'You haven\'t tracked {exercise} yet.',
      'exercise_start_logging': 'Start logging this exercise to build your performance history!',
      // Recovery
      'recovery_title': '🔄 **Recovery Analysis**',
      'recovery_pattern': '**Training Pattern:**',
      'recovery_sessions_week': 'Sessions per week',
      'recovery_avg_rest': 'Average rest days',
      'recovery_most_trained': 'Most trained',
      'recovery_least_trained': 'Least trained',
      'recovery_recommendations': '**Recommendations:**',
      'recovery_high_frequency': '⚠️ High training frequency detected - ensure adequate rest',
      'recovery_imbalance': '⚠️ Consider balancing muscle group distribution',
      'recovery_optimal': '✅ Optimal recovery: 48-72 hours between same muscle groups',
      // Volume
      'volume_title': '📊 **Volume Analysis**',
      'volume_period': '**{period} Volume:**',
      'volume_overall': '**Overall Volume:**',
      'volume_total': 'Total',
      'volume_average_session': 'Average per session',
      'volume_peak': 'Peak session',
      'volume_trend': 'Trend',
      'volume_distribution': '**Distribution by Muscle Group:**',
      // Form
      'form_title': '🎯 **Form Guide: {exercise}**',
      'form_key_points': '**Key Points:**',
      'form_your_notes': '**Your Notes:**',
      'form_specify': 'Please specify an exercise for form guidance.',
      'form_example': 'Example: "How is my squat form?" or "Bench press technique"',
      // History
      'history_period': '📅 **{period} Workout History**',
      'history_recent': '📅 **Recent Workout History**',
      'history_none': 'No workouts found for this period.',
      // Greeting
      'greeting_hello': '👋 Hello! Ready to train?',
      'greeting_today': 'Great workout today! 💪',
      'greeting_yesterday': 'You trained yesterday - nice consistency!',
      'greeting_days_ago': 'Last workout was {days} days ago.',
      'greeting_ask': 'What would you like to know about your training?',
      'greeting_options': 'You can ask about:',
      'greeting_pr': '• Personal records ("What\'s my squat PR?")',
      'greeting_progress': '• Progress tracking ("Show my bench progress")',
      'greeting_volume': '• Volume analysis ("Total volume this week")',
      'greeting_recovery': '• Recovery insights ("Am I training too much?")',
      // Generic
      'generic_based_on': 'Based on your workout history:',
      'generic_showing_from': '📅 Showing data from: {period}',
      'generic_focused_on': '🎯 Focused on: {exercises}',
      // No results
      'no_results': 'I couldn\'t find specific data for your query.',
      'no_results_pr': 'To track personal records:',
      'no_results_pr_tip1': '• Tap the PR badge when you hit a new max',
      'no_results_pr_tip2': '• I\'ll remember and celebrate your achievements!',
      'no_results_exercise': 'Start logging this exercise to build your history!',
      'no_results_exercise_tip1': '• Add it to your next workout',
      'no_results_exercise_tip2': '• Track sets, reps, and weight',
      'no_results_try': 'Try:',
      'no_results_tip1': '• Being more specific ("squat PR" instead of "max")',
      'no_results_tip2': '• Adding time context ("this week", "yesterday")',
      'no_results_tip3': '• Checking if you\'ve logged this data',
      // Encouragement
      'encourage_pr_100': '🔥 Incredible strength! You\'re in the 100kg+ club!',
      'encourage_pr_60': '💪 Solid PR! Keep pushing for new heights!',
      'encourage_pr_default': '👏 Great progress! Every PR is a step forward!',
      'encourage_generic': 'Keep up the great work!',
      // Form cues
      'form_controlled': 'Focus on controlled movement',
      'form_breathing': 'Maintain proper breathing',
      // Squat form cues
      'form_squat_1': 'Keep chest up and core tight',
      'form_squat_2': 'Knees track over toes',
      'form_squat_3': 'Hip crease below parallel',
      'form_squat_4': 'Drive through heels',
      // Bench form cues
      'form_bench_1': 'Maintain arch in lower back',
      'form_bench_2': 'Shoulder blades pulled back',
      'form_bench_3': 'Lower to chest with control',
      'form_bench_4': 'Press up and slightly back',
      // Deadlift form cues
      'form_deadlift_1': 'Neutral spine throughout',
      'form_deadlift_2': 'Shoulders over or slightly ahead of bar',
      'form_deadlift_3': 'Push floor away to start',
      'form_deadlift_4': 'Lock out hips and knees together',
      // Press form cues
      'form_press_1': 'Tight core, squeeze glutes',
      'form_press_2': 'Bar path goes back slightly',
      'form_press_3': 'Full lockout at the top',
      'form_press_4': 'Keep elbows slightly forward',
      // Row form cues
      'form_row_1': 'Pull elbows back, not just hands',
      'form_row_2': 'Squeeze shoulder blades at top',
      'form_row_3': 'Controlled negative phase',
      'form_row_4': 'Avoid momentum and swinging',
    },
    'it': {
      // PR Response
      'pr_title': '💪 Il tuo record personale per **{exercise}** è **{weight}kg**!',
      'pr_achieved_on': 'L\'hai raggiunto il {date} ({day}).',
      'pr_recent': 'Performance recenti:',
      'pr_not_found': 'Non ho trovato un record personale per {exercise} nella tua cronologia.',
      'pr_not_found_explanation': 'Potrebbe significare che non hai ancora tracciato questo esercizio, o non hai contrassegnato nessun set come PR.',
      'pr_tip': '💡 **Consiglio**: Quando raggiungi un nuovo massimale, tocca il badge PR su quella serie!',
      // Progression
      'progression_title': '📈 **Analisi Progressione**',
      'progression_starting': 'Inizio',
      'progression_current': 'Attuale',
      'progression_improvement': 'Miglioramento',
      'progression_consistency': 'Costanza',
      'progression_insights': '**Osservazioni Chiave:**',
      'progression_excellent': '✅ Ottimi progressi sui movimenti composti',
      'progression_plateau': '⚠️ Alcuni esercizi mostrano stallo - considera delle variazioni',
      'progression_analyzing': 'Analizzo la tua progressione...',
      // Exercise
      'exercise_analysis': '📊 **Analisi {exercise}**',
      'exercise_summary': '**Riepilogo Performance:**',
      'exercise_best': 'Migliore',
      'exercise_average': 'Media',
      'exercise_volume': 'Volume Totale',
      'exercise_frequency': 'Frequenza',
      'exercise_recent': '**Sessioni Recenti:**',
      'exercise_not_tracked': 'Non hai ancora tracciato {exercise}.',
      'exercise_start_logging': 'Inizia a registrare questo esercizio per costruire la tua cronologia!',
      // Recovery
      'recovery_title': '🔄 **Analisi Recupero**',
      'recovery_pattern': '**Pattern di Allenamento:**',
      'recovery_sessions_week': 'Sessioni a settimana',
      'recovery_avg_rest': 'Giorni di riposo medi',
      'recovery_most_trained': 'Più allenato',
      'recovery_least_trained': 'Meno allenato',
      'recovery_recommendations': '**Raccomandazioni:**',
      'recovery_high_frequency': '⚠️ Alta frequenza di allenamento rilevata - assicurati di riposare adeguatamente',
      'recovery_imbalance': '⚠️ Considera di bilanciare la distribuzione dei gruppi muscolari',
      'recovery_optimal': '✅ Recupero ottimale: 48-72 ore tra gli stessi gruppi muscolari',
      // Volume
      'volume_title': '📊 **Analisi Volume**',
      'volume_period': '**Volume {period}:**',
      'volume_overall': '**Volume Complessivo:**',
      'volume_total': 'Totale',
      'volume_average_session': 'Media per sessione',
      'volume_peak': 'Sessione picco',
      'volume_trend': 'Tendenza',
      'volume_distribution': '**Distribuzione per Gruppo Muscolare:**',
      // Form
      'form_title': '🎯 **Guida Tecnica: {exercise}**',
      'form_key_points': '**Punti Chiave:**',
      'form_your_notes': '**Le tue Note:**',
      'form_specify': 'Specifica un esercizio per la guida tecnica.',
      'form_example': 'Esempio: "Come è la mia tecnica di squat?" o "Tecnica panca"',
      // History
      'history_period': '📅 **Cronologia Allenamenti {period}**',
      'history_recent': '📅 **Cronologia Allenamenti Recenti**',
      'history_none': 'Nessun allenamento trovato per questo periodo.',
      // Greeting
      'greeting_hello': '👋 Ciao! Pronto ad allenarti?',
      'greeting_today': 'Ottimo allenamento oggi! 💪',
      'greeting_yesterday': 'Ti sei allenato ieri - bella costanza!',
      'greeting_days_ago': 'Ultimo allenamento {days} giorni fa.',
      'greeting_ask': 'Cosa vuoi sapere sul tuo allenamento?',
      'greeting_options': 'Puoi chiedere:',
      'greeting_pr': '• Record personali ("Qual è il mio PR di squat?")',
      'greeting_progress': '• Tracciamento progressi ("Mostrami i progressi di panca")',
      'greeting_volume': '• Analisi volume ("Volume totale questa settimana")',
      'greeting_recovery': '• Insights recupero ("Mi sto allenando troppo?")',
      // Generic
      'generic_based_on': 'In base alla tua cronologia allenamenti:',
      'generic_showing_from': '📅 Dati da: {period}',
      'generic_focused_on': '🎯 Focus su: {exercises}',
      // No results
      'no_results': 'Non ho trovato dati specifici per la tua richiesta.',
      'no_results_pr': 'Per tracciare i record personali:',
      'no_results_pr_tip1': '• Tocca il badge PR quando raggiungi un nuovo massimale',
      'no_results_pr_tip2': '• Ricorderò e celebrerò i tuoi successi!',
      'no_results_exercise': 'Inizia a registrare questo esercizio per costruire la tua cronologia!',
      'no_results_exercise_tip1': '• Aggiungilo al prossimo allenamento',
      'no_results_exercise_tip2': '• Traccia serie, ripetizioni e peso',
      'no_results_try': 'Prova:',
      'no_results_tip1': '• Sii più specifico ("PR squat" invece di "massimale")',
      'no_results_tip2': '• Aggiungi contesto temporale ("questa settimana", "ieri")',
      'no_results_tip3': '• Verifica di aver registrato questi dati',
      // Encouragement
      'encourage_pr_100': '🔥 Forza incredibile! Sei nel club dei 100kg+!',
      'encourage_pr_60': '💪 PR solido! Continua a puntare in alto!',
      'encourage_pr_default': '👏 Ottimi progressi! Ogni PR è un passo avanti!',
      'encourage_generic': 'Continua così!',
      // Form cues
      'form_controlled': 'Concentrati su movimenti controllati',
      'form_breathing': 'Mantieni una respirazione corretta',
      // Squat form cues
      'form_squat_1': 'Petto alto e core contratto',
      'form_squat_2': 'Ginocchia seguono la direzione dei piedi',
      'form_squat_3': 'Anca sotto il parallelo',
      'form_squat_4': 'Spingi attraverso i talloni',
      // Bench form cues
      'form_bench_1': 'Mantieni l\'arco lombare',
      'form_bench_2': 'Scapole addotte e depresse',
      'form_bench_3': 'Scendi al petto con controllo',
      'form_bench_4': 'Spingi su e leggermente indietro',
      // Deadlift form cues
      'form_deadlift_1': 'Colonna neutra per tutto il movimento',
      'form_deadlift_2': 'Spalle sopra o leggermente avanti alla barra',
      'form_deadlift_3': 'Spingi il pavimento via per iniziare',
      'form_deadlift_4': 'Blocca anche e ginocchia insieme',
      // Press form cues
      'form_press_1': 'Core teso, glutei contratti',
      'form_press_2': 'La traiettoria va leggermente indietro',
      'form_press_3': 'Blocco completo in alto',
      'form_press_4': 'Gomiti leggermente avanti',
      // Row form cues
      'form_row_1': 'Tira i gomiti indietro, non solo le mani',
      'form_row_2': 'Stringi le scapole in alto',
      'form_row_3': 'Fase eccentrica controllata',
      'form_row_4': 'Evita slancio e oscillazioni',
    },
  };

  /// Generate response based on search results and query analysis
  String generateResponse({
    required ExpandedQuery query,
    required List<SearchResult> searchResults,
    required UserIntent intent,
    String locale = 'en',
  }) {
    _locale = locale == 'it' ? 'it' : 'en';
    // No results found
    if (searchResults.isEmpty) {
      return _generateNoResultsResponse(query, intent);
    }

    // Generate response based on intent
    switch (intent) {
      case UserIntent.prQuery:
        return _generatePRResponse(query, searchResults);

      case UserIntent.progression:
        return _generateProgressionResponse(query, searchResults);

      case UserIntent.plan:
        return _generateExerciseResponse(query, searchResults);

      case UserIntent.recovery:
        return _generateRecoveryResponse(query, searchResults);

      case UserIntent.volume:
        return _generateVolumeResponse(query, searchResults);

      case UserIntent.form:
        return _generateFormResponse(query, searchResults);

      case UserIntent.help:
        return _generateHistoryResponse(query, searchResults);

      case UserIntent.greeting:
        return _generateGreetingWithContext(searchResults);

      default:
        return _generateGenericResponse(query, searchResults);
    }
  }

  /// Generate metadata for reasoning display
  Map<String, dynamic> generateMetadata({
    required List<SearchResult> searchResults,
    required ExpandedQuery query,
  }) {
    final topResult = searchResults.firstOrNull;

    return {
      'searchStats': {
        'resultsFound': searchResults.length,
        'topScore': topResult?.normalizedScore ?? 0,
        'confidence': topResult?.confidence ?? 'low',
        'queryComplexity': query.complexityScore,
      },
      'expandedTerms': query.expandedTokens.take(5).toList(),
      'temporalContext': query.temporalContext?.label,
      'dataSource': 'Your workout history',
      'matchedDocuments': searchResults.take(3).map((r) => r.document.id).toList(),
    };
  }

  /// Generate PR-specific response
  String _generatePRResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Find PR mentions in results
    final prResults = results.where((r) =>
        r.document.content.contains('personal record') ||
        r.document.content.contains('PR'));

    if (prResults.isNotEmpty) {
      final topPR = prResults.first;

      // Extract exercise name from document ID or content
      final exerciseName = _extractExerciseName(topPR.document);
      final weight = _extractWeight(topPR.document.content);
      final date = topPR.document.timestamp;

      if (exerciseName != null && weight != null) {
        buffer.writeln(_l('pr_title')
            .replaceAll('{exercise}', exerciseName)
            .replaceAll('{weight}', weight.toString()));

        if (date != null) {
          buffer.writeln();
          buffer.writeln(_l('pr_achieved_on')
              .replaceAll('{date}', _dateFormat.format(date))
              .replaceAll('{day}', _dayFormat.format(date)));
        }

        // Add context from other results
        final recentPerformances = _findRecentPerformances(exerciseName, results);
        if (recentPerformances.isNotEmpty) {
          buffer.writeln();
          buffer.writeln(_l('pr_recent'));
          for (final perf in recentPerformances.take(3)) {
            buffer.writeln(perf);
          }
        }

        // Add encouragement
        buffer.writeln();
        buffer.writeln(_generateEncouragement('pr', weight));
      } else {
        // Fallback if extraction fails
        buffer.writeln(_extractRelevantContent(topPR.document.content, 'PR'));
      }
    } else {
      // No PR found for query
      if (query.exerciseContext?.exercises.isNotEmpty ?? false) {
        final exercise = query.exerciseContext!.exercises.first;
        buffer.writeln(_l('pr_not_found').replaceAll('{exercise}', exercise));
        buffer.writeln();
        buffer.writeln(_l('pr_not_found_explanation'));
        buffer.writeln();
        buffer.writeln(_l('pr_tip'));
      } else {
        buffer.writeln(_generateNoResultsResponse(query, UserIntent.prQuery));
      }
    }

    return buffer.toString();
  }

  /// Generate progression analysis response
  String _generateProgressionResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Analyze progression from search results
    final progressData = _analyzeProgression(results);

    if (progressData.isNotEmpty) {
      buffer.writeln(_l('progression_title'));
      buffer.writeln();

      // Show exercise-specific progression
      for (final entry in progressData.entries.take(3)) {
        final exercise = entry.key;
        final data = entry.value;

        buffer.writeln('**$exercise**:');
        buffer.writeln('• ${_l('progression_starting')}: ${data['start']}kg → ${_l('progression_current')}: ${data['current']}kg');
        buffer.writeln('• ${_l('progression_improvement')}: ${data['improvement']}%');
        buffer.writeln('• ${_l('progression_consistency')}: ${data['frequency']}');
        buffer.writeln();
      }

      // Overall insights
      buffer.writeln(_l('progression_insights'));
      if (progressData.values.any((d) => d['improvement'] > 10)) {
        buffer.writeln(_l('progression_excellent'));
      }
      if (progressData.values.any((d) => d['improvement'] < 5)) {
        buffer.writeln(_l('progression_plateau'));
      }
    } else {
      buffer.writeln(_l('progression_analyzing'));
      buffer.writeln();
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'progress'));
    }

    return buffer.toString();
  }

  /// Generate exercise-specific response
  String _generateExerciseResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    final exerciseName = query.exerciseContext?.exercises.firstOrNull;

    if (exerciseName != null) {
      buffer.writeln(_l('exercise_analysis').replaceAll('{exercise}', exerciseName));
      buffer.writeln();

      // Find exercise-specific results
      final exerciseResults = results.where((r) =>
          r.document.content.toLowerCase().contains(exerciseName));

      if (exerciseResults.isNotEmpty) {
        // Extract key metrics
        final metrics = _extractExerciseMetrics(exerciseResults.toList());

        buffer.writeln(_l('exercise_summary'));
        if (metrics['maxWeight'] != null) {
          buffer.writeln('• ${_l('exercise_best')}: ${metrics['maxWeight']}kg');
        }
        if (metrics['avgWeight'] != null) {
          buffer.writeln('• ${_l('exercise_average')}: ${metrics['avgWeight']}kg');
        }
        if (metrics['totalVolume'] != null) {
          buffer.writeln('• ${_l('exercise_volume')}: ${_numberFormat.format(metrics['totalVolume'])}kg');
        }
        if (metrics['frequency'] != null) {
          buffer.writeln('• ${_l('exercise_frequency')}: ${metrics['frequency']}');
        }

        buffer.writeln();

        // Recent sessions
        final recentSessions = _extractRecentSessions(exerciseName, results);
        if (recentSessions.isNotEmpty) {
          buffer.writeln(_l('exercise_recent'));
          for (final session in recentSessions.take(3)) {
            buffer.writeln(session);
          }
        }
      } else {
        buffer.writeln(_l('exercise_not_tracked').replaceAll('{exercise}', exerciseName));
        buffer.writeln();
        buffer.writeln(_l('exercise_start_logging'));
      }
    } else {
      // General exercise response
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'exercise'));
    }

    return buffer.toString();
  }

  /// Generate recovery analysis response
  String _generateRecoveryResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln(_l('recovery_title'));
    buffer.writeln();

    // Analyze training frequency from results
    final frequencyData = _analyzeTrainingFrequency(results);

    if (frequencyData.isNotEmpty) {
      buffer.writeln(_l('recovery_pattern'));
      buffer.writeln('• ${_l('recovery_sessions_week')}: ${frequencyData['sessionsPerWeek']}');
      buffer.writeln('• ${_l('recovery_avg_rest')}: ${frequencyData['avgRestDays']}');
      if (frequencyData['mostTrained'] != null) {
        buffer.writeln('• ${_l('recovery_most_trained')}: ${frequencyData['mostTrained']}');
      }
      if (frequencyData['leastTrained'] != null) {
        buffer.writeln('• ${_l('recovery_least_trained')}: ${frequencyData['leastTrained']}');
      }
      buffer.writeln();

      // Recovery recommendations
      buffer.writeln(_l('recovery_recommendations'));
      if (frequencyData['sessionsPerWeek'] > 5) {
        buffer.writeln(_l('recovery_high_frequency'));
      }
      if (frequencyData['muscleImbalance'] == true) {
        buffer.writeln(_l('recovery_imbalance'));
      }
      buffer.writeln(_l('recovery_optimal'));
    } else {
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'recovery'));
    }

    return buffer.toString();
  }

  /// Generate volume analysis response
  String _generateVolumeResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln(_l('volume_title'));
    buffer.writeln();

    // Extract volume data from results
    final volumeData = _extractVolumeData(results);

    if (volumeData.isNotEmpty) {
      if (query.temporalContext != null) {
        buffer.writeln(_l('volume_period').replaceAll('{period}', query.temporalContext!.label.toUpperCase()));
      } else {
        buffer.writeln(_l('volume_overall'));
      }

      buffer.writeln('• ${_l('volume_total')}: ${_numberFormat.format(volumeData['total'])}kg');
      buffer.writeln('• ${_l('volume_average_session')}: ${_numberFormat.format(volumeData['average'])}kg');
      buffer.writeln('• ${_l('volume_peak')}: ${_numberFormat.format(volumeData['peak'])}kg');

      if (volumeData['trend'] != null) {
        buffer.writeln('• ${_l('volume_trend')}: ${volumeData['trend']}');
      }

      buffer.writeln();

      // Volume distribution
      if (volumeData['distribution'] != null) {
        buffer.writeln(_l('volume_distribution'));
        final distribution = volumeData['distribution'] as Map<String, double>;
        for (final entry in distribution.entries) {
          buffer.writeln('• ${entry.key}: ${_numberFormat.format(entry.value)}kg');
        }
      }
    } else {
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'volume'));
    }

    return buffer.toString();
  }

  /// Generate form/technique response
  String _generateFormResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    final exercise = query.exerciseContext?.exercises.firstOrNull;

    if (exercise != null) {
      buffer.writeln(_l('form_title').replaceAll('{exercise}', exercise.toUpperCase()));
      buffer.writeln();

      // Provide form cues based on exercise
      final formCues = _getFormCues(exercise);

      buffer.writeln(_l('form_key_points'));
      for (final cue in formCues) {
        buffer.writeln('• $cue');
      }

      buffer.writeln();

      // Add performance context from search
      final performanceNotes = _extractNotes(exercise, results);
      if (performanceNotes.isNotEmpty) {
        buffer.writeln(_l('form_your_notes'));
        for (final note in performanceNotes.take(3)) {
          buffer.writeln('• $note');
        }
      }
    } else {
      buffer.writeln(_l('form_specify'));
      buffer.writeln();
      buffer.writeln(_l('form_example'));
    }

    return buffer.toString();
  }

  /// Generate workout history response
  String _generateHistoryResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    if (query.temporalContext != null) {
      buffer.writeln(_l('history_period').replaceAll('{period}', query.temporalContext!.label.toUpperCase()));
    } else {
      buffer.writeln(_l('history_recent'));
    }
    buffer.writeln();

    // Extract workout summaries from results
    final workoutSummaries = _extractWorkoutSummaries(results);

    if (workoutSummaries.isNotEmpty) {
      for (final summary in workoutSummaries.take(5)) {
        buffer.writeln(summary);
      }
    } else {
      buffer.writeln(_l('history_none'));
    }

    return buffer.toString();
  }

  /// Generate greeting with workout context
  String _generateGreetingWithContext(List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln(_l('greeting_hello'));
    buffer.writeln();

    // Add recent workout context
    final recentWorkout = _findMostRecentWorkout(results);
    if (recentWorkout != null) {
      buffer.writeln(recentWorkout);
      buffer.writeln();
    }

    buffer.writeln(_l('greeting_ask'));
    buffer.writeln();
    buffer.writeln(_l('greeting_options'));
    buffer.writeln(_l('greeting_pr'));
    buffer.writeln(_l('greeting_progress'));
    buffer.writeln(_l('greeting_volume'));
    buffer.writeln(_l('greeting_recovery'));

    return buffer.toString();
  }

  /// Generate generic response using search results
  String _generateGenericResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Use top search results to construct response
    final topResults = results.take(3);

    buffer.writeln(_l('generic_based_on'));
    buffer.writeln();

    for (final result in topResults) {
      final summary = _summarizeDocument(result.document);
      if (summary.isNotEmpty) {
        buffer.writeln('• $summary');
      }
    }

    // Add query-specific context
    if (query.isTemporalQuery) {
      buffer.writeln();
      buffer.writeln(_l('generic_showing_from').replaceAll('{period}', query.temporalContext!.label));
    }

    if (query.isExerciseSpecific) {
      buffer.writeln();
      buffer.writeln(_l('generic_focused_on').replaceAll('{exercises}', query.exerciseContext!.exercises.join(', ')));
    }

    return buffer.toString();
  }

  /// Generate response when no results found
  String _generateNoResultsResponse(ExpandedQuery query, UserIntent intent) {
    final buffer = StringBuffer();

    buffer.writeln(_l('no_results'));
    buffer.writeln();

    // Provide intent-specific guidance
    switch (intent) {
      case UserIntent.prQuery:
        buffer.writeln(_l('no_results_pr'));
        buffer.writeln(_l('no_results_pr_tip1'));
        buffer.writeln(_l('no_results_pr_tip2'));
        break;

      case UserIntent.plan:
        buffer.writeln(_l('no_results_exercise'));
        buffer.writeln(_l('no_results_exercise_tip1'));
        buffer.writeln(_l('no_results_exercise_tip2'));
        break;

      default:
        buffer.writeln(_l('no_results_try'));
        buffer.writeln(_l('no_results_tip1'));
        buffer.writeln(_l('no_results_tip2'));
        buffer.writeln(_l('no_results_tip3'));
    }

    return buffer.toString();
  }

  // === Helper Methods ===

  String? _extractExerciseName(BM25Document document) {
    // Extract from document ID (e.g., "exercise_workout123_squat")
    if (document.id.startsWith('exercise_')) {
      final parts = document.id.split('_');
      if (parts.length >= 3) {
        return parts.last;
      }
    }

    // Extract from content
    final exercises = ['squat', 'bench', 'deadlift', 'press', 'row', 'curl'];
    for (final exercise in exercises) {
      if (document.content.toLowerCase().contains(exercise)) {
        return exercise;
      }
    }

    return null;
  }

  double? _extractWeight(String content) {
    // Look for pattern like "100 kg" or "100kg"
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*kg');
    final match = regex.firstMatch(content);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    return null;
  }

  List<String> _findRecentPerformances(String exercise, List<SearchResult> results) {
    final performances = <String>[];

    for (final result in results) {
      if (result.document.content.toLowerCase().contains(exercise)) {
        final weight = _extractWeight(result.document.content);
        final date = result.document.timestamp;

        if (weight != null && date != null) {
          performances.add('• ${_dateFormat.format(date)}: ${weight}kg');
        }
      }
    }

    return performances;
  }

  String _extractRelevantContent(String content, String keyword) {
    final lines = content.split('\n');
    final relevant = lines.where((line) => line.toLowerCase().contains(keyword));

    if (relevant.isNotEmpty) {
      return relevant.take(3).join('\n');
    }

    return lines.take(3).join('\n');
  }

  /// Analyze real progression from search results
  Map<String, Map<String, dynamic>> _analyzeProgression(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();
    final progressionData = <String, Map<String, dynamic>>{};

    // Group results by exercise
    final exerciseData = <String, List<_ExerciseDataPoint>>{};

    for (final result in results) {
      if (!result.document.id.startsWith('exercise_')) continue;

      final content = result.document.content;
      final exerciseName = extractor.extractExerciseNameFromContent(content);
      final date = result.document.timestamp;

      if (exerciseName == null || date == null) continue;

      final sets = extractor.extractSets(content);
      if (sets.isEmpty) continue;

      final maxWeight = extractor.calculateMaxWeight(sets);
      if (maxWeight == null) continue;

      exerciseData.putIfAbsent(exerciseName, () => []);
      exerciseData[exerciseName]!.add(_ExerciseDataPoint(
        date: date,
        maxWeight: maxWeight,
        volume: extractor.calculateTotalVolume(sets),
      ));
    }

    // Calculate progression for each exercise
    for (final entry in exerciseData.entries) {
      final dataPoints = entry.value..sort((a, b) => a.date.compareTo(b.date));

      if (dataPoints.length < 2) continue;

      final first = dataPoints.first;
      final last = dataPoints.last;

      final improvement = ((last.maxWeight - first.maxWeight) / first.maxWeight * 100);

      // Determine frequency
      final daySpan = last.date.difference(first.date).inDays;
      final frequency = daySpan > 0
          ? '${(dataPoints.length / (daySpan / 7)).toStringAsFixed(1)}x/week'
          : 'N/A';

      progressionData[entry.key] = {
        'start': first.maxWeight.round(),
        'current': last.maxWeight.round(),
        'improvement': improvement.round(),
        'frequency': frequency,
        'sessions': dataPoints.length,
      };
    }

    return progressionData;
  }

  /// Extract real metrics from exercise search results
  Map<String, dynamic> _extractExerciseMetrics(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    double? maxWeight;
    final allWeights = <double>[];
    double totalVolume = 0;
    int sessionCount = 0;

    for (final result in results) {
      final content = result.document.content;

      // Extract sets and calculate metrics
      final sets = extractor.extractSets(content);

      for (final set in sets) {
        if (set.weight != null) {
          allWeights.add(set.weight!);
          if (maxWeight == null || set.weight! > maxWeight) {
            maxWeight = set.weight;
          }
        }
      }

      // Extract volume
      final exerciseVolume = extractor.extractExerciseVolume(content);
      if (exerciseVolume != null) {
        totalVolume += exerciseVolume;
      } else {
        // Calculate from sets if not explicitly stated
        totalVolume += extractor.calculateTotalVolume(sets);
      }

      // Count sessions (documents with exercise_ prefix)
      if (result.document.id.startsWith('exercise_')) {
        sessionCount++;
      }
    }

    // Calculate average weight
    final avgWeight = allWeights.isNotEmpty
        ? allWeights.reduce((a, b) => a + b) / allWeights.length
        : null;

    // Determine frequency description
    String frequency;
    if (sessionCount >= 12) {
      frequency = '3+ times per week';
    } else if (sessionCount >= 8) {
      frequency = '2-3 times per week';
    } else if (sessionCount >= 4) {
      frequency = '1-2 times per week';
    } else {
      frequency = 'Less than weekly';
    }

    return {
      if (maxWeight != null) 'maxWeight': maxWeight.round(),
      if (avgWeight != null) 'avgWeight': avgWeight.round(),
      if (totalVolume > 0) 'totalVolume': totalVolume.round(),
      'frequency': frequency,
      'sessionCount': sessionCount,
    };
  }

  /// Extract real recent sessions from search results
  List<String> _extractRecentSessions(String exercise, List<SearchResult> results) {
    final extractor = DocumentDataExtractor();
    final sessions = <String>[];
    final dateFormat = DateFormat('EEEE'); // Day name

    // Filter for exercise documents and sort by date
    final exerciseResults = results
        .where((r) => r.document.id.startsWith('exercise_'))
        .where((r) => r.document.content.toLowerCase().contains(exercise.toLowerCase()))
        .toList()
      ..sort((a, b) {
        final dateA = a.document.timestamp ?? DateTime(1970);
        final dateB = b.document.timestamp ?? DateTime(1970);
        return dateB.compareTo(dateA); // Most recent first
      });

    for (final result in exerciseResults.take(5)) {
      final content = result.document.content;
      final sets = extractor.extractSets(content);
      final date = result.document.timestamp;

      if (sets.isNotEmpty && date != null) {
        final dayName = dateFormat.format(date);

        // Build set summary (e.g., "3x8 @ 80kg")
        if (sets.length > 1 && _areSetsHomogeneous(sets)) {
          // If all sets have same reps, show as NxR format
          final avgWeight = sets
              .where((s) => s.weight != null)
              .map((s) => s.weight!)
              .fold(0.0, (a, b) => a + b) / sets.length;

          sessions.add('$dayName: ${sets.length}x${sets.first.reps} @ ${avgWeight.round()}kg');
        } else {
          // Show individual sets
          final setSummary = sets.take(3).map((s) {
            if (s.weight != null && s.reps != null) {
              return '${s.reps}@${s.weight!.round()}kg';
            } else if (s.reps != null) {
              return '${s.reps} reps';
            }
            return '';
          }).where((s) => s.isNotEmpty).join(', ');

          sessions.add('$dayName: $setSummary');
        }
      }
    }

    return sessions;
  }

  /// Analyze real training frequency from search results
  Map<String, dynamic> _analyzeTrainingFrequency(List<SearchResult> results) {
    if (results.isEmpty) return {};

    // Get workout documents only
    final workoutResults = results
        .where((r) => r.document.id.startsWith('workout_'))
        .toList();

    if (workoutResults.isEmpty) return {};

    // Get dates and sort
    final workoutDates = workoutResults
        .map((r) => r.document.timestamp)
        .whereType<DateTime>()
        .toList()
      ..sort();

    if (workoutDates.isEmpty) return {};

    // Calculate sessions per week (last 4 weeks)
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentWorkouts = workoutDates.where((d) => d.isAfter(fourWeeksAgo)).length;
    final sessionsPerWeek = (recentWorkouts / 4).round();

    // Calculate average rest days
    double avgRestDays = 0;
    if (workoutDates.length > 1) {
      int totalRestDays = 0;
      for (int i = 1; i < workoutDates.length; i++) {
        totalRestDays += workoutDates[i].difference(workoutDates[i - 1]).inDays - 1;
      }
      avgRestDays = totalRestDays / (workoutDates.length - 1);
    }

    // Analyze muscle group distribution
    final muscleGroupCount = <String, int>{};
    for (final result in results) {
      final content = result.document.content.toLowerCase();

      // Check for category mentions
      for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
        if (content.contains(category)) {
          muscleGroupCount[category] = (muscleGroupCount[category] ?? 0) + 1;
        }
      }
    }

    // Find most and least trained
    String? mostTrained;
    String? leastTrained;

    if (muscleGroupCount.isNotEmpty) {
      final sorted = muscleGroupCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      mostTrained = sorted.first.key;
      mostTrained = mostTrained[0].toUpperCase() + mostTrained.substring(1);

      leastTrained = sorted.last.key;
      leastTrained = leastTrained[0].toUpperCase() + leastTrained.substring(1);
    }

    // Check for muscle imbalance (>2x difference)
    final muscleImbalance = muscleGroupCount.isNotEmpty &&
        muscleGroupCount.values.reduce((a, b) => a > b ? a : b) >
            muscleGroupCount.values.reduce((a, b) => a < b ? a : b) * 2;

    return {
      'sessionsPerWeek': sessionsPerWeek,
      'avgRestDays': double.parse(avgRestDays.toStringAsFixed(1)),
      if (mostTrained != null) 'mostTrained': mostTrained,
      if (leastTrained != null) 'leastTrained': leastTrained,
      'muscleImbalance': muscleImbalance,
      'totalWorkouts': workoutDates.length,
    };
  }

  /// Extract real volume data from search results
  Map<String, dynamic> _extractVolumeData(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    final volumes = <double>[];
    final muscleGroupVolumes = <String, double>{};

    for (final result in results) {
      final content = result.document.content;

      // Try to get total volume from workout documents
      if (result.document.id.startsWith('workout_')) {
        final volume = extractor.extractVolume(content);
        if (volume != null && volume > 0) {
          volumes.add(volume);
        }

        // Track muscle group distribution
        for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
          if (content.toLowerCase().contains(category)) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + (volume ?? 0) / 3; // Approximate split
          }
        }
      }

      // Get exercise-specific volume
      if (result.document.id.startsWith('exercise_')) {
        final exerciseVolume = extractor.extractExerciseVolume(content);
        if (exerciseVolume != null) {
          // Add to appropriate muscle group
          final exerciseName = extractor.extractExerciseNameFromContent(content);
          final category = _inferMuscleGroup(exerciseName ?? '');
          if (category != null) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + exerciseVolume;
          }
        }
      }
    }

    if (volumes.isEmpty) return {};

    final totalVolume = volumes.reduce((a, b) => a + b);
    final averageVolume = totalVolume / volumes.length;
    final peakVolume = volumes.reduce((a, b) => a > b ? a : b);

    // Determine trend
    String? trend;
    if (volumes.length >= 3) {
      final firstHalf = volumes.take(volumes.length ~/ 2).toList();
      final secondHalf = volumes.skip(volumes.length ~/ 2).toList();

      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg > firstAvg * 1.1) {
        trend = 'Increasing';
      } else if (secondAvg < firstAvg * 0.9) {
        trend = 'Decreasing';
      } else {
        trend = 'Stable';
      }
    }

    // Format muscle group volumes
    final distribution = <String, double>{};
    for (final entry in muscleGroupVolumes.entries) {
      if (entry.value > 0) {
        final formattedName = entry.key[0].toUpperCase() + entry.key.substring(1);
        distribution[formattedName] = entry.value.roundToDouble();
      }
    }

    return {
      'total': totalVolume.round(),
      'average': averageVolume.round(),
      'peak': peakVolume.round(),
      if (trend != null) 'trend': trend,
      if (distribution.isNotEmpty) 'distribution': distribution,
    };
  }

  List<String> _getFormCues(String exercise) {
    final lowerExercise = exercise.toLowerCase();

    // Squat variations
    if (lowerExercise.contains('squat') || lowerExercise.contains('accosciata')) {
      return [
        _l('form_squat_1'),
        _l('form_squat_2'),
        _l('form_squat_3'),
        _l('form_squat_4'),
      ];
    }

    // Bench press variations
    if (lowerExercise.contains('bench') || lowerExercise.contains('panca') || lowerExercise.contains('distensioni')) {
      return [
        _l('form_bench_1'),
        _l('form_bench_2'),
        _l('form_bench_3'),
        _l('form_bench_4'),
      ];
    }

    // Deadlift variations
    if (lowerExercise.contains('deadlift') || lowerExercise.contains('stacco')) {
      return [
        _l('form_deadlift_1'),
        _l('form_deadlift_2'),
        _l('form_deadlift_3'),
        _l('form_deadlift_4'),
      ];
    }

    // Overhead press variations
    if (lowerExercise.contains('press') || lowerExercise.contains('military') ||
        lowerExercise.contains('spinte') || lowerExercise.contains('lento')) {
      return [
        _l('form_press_1'),
        _l('form_press_2'),
        _l('form_press_3'),
        _l('form_press_4'),
      ];
    }

    // Row variations
    if (lowerExercise.contains('row') || lowerExercise.contains('rematore') || lowerExercise.contains('tirate')) {
      return [
        _l('form_row_1'),
        _l('form_row_2'),
        _l('form_row_3'),
        _l('form_row_4'),
      ];
    }

    // Default cues
    return [_l('form_controlled'), _l('form_breathing')];
  }

  List<String> _extractNotes(String exercise, List<SearchResult> results) {
    // Extract notes from workout document content if available
    // BM25Document doesn't have metadata, so we parse from content instead
    final notes = <String>[];

    for (final result in results) {
      final content = result.document.content;
      // Look for notes pattern in content: "Note: ..." or "Notes: ..."
      final noteMatch = RegExp(r'[Nn]ote[s]?:\s*([^\n]+)').firstMatch(content);
      if (noteMatch != null && noteMatch.group(1)?.isNotEmpty == true) {
        notes.add(noteMatch.group(1)!.trim());
      }
    }

    // If no notes found, return empty (don't show placeholder text)
    return notes;
  }

  List<String> _extractWorkoutSummaries(List<SearchResult> results) {
    final summaries = <String>[];

    for (final result in results.take(5)) {
      if (result.document.id.startsWith('workout_')) {
        final date = result.document.timestamp;
        if (date != null) {
          summaries.add('• ${_dayFormat.format(date)}, ${_dateFormat.format(date)} - ${_summarizeDocument(result.document)}');
        }
      }
    }

    return summaries;
  }

  String? _findMostRecentWorkout(List<SearchResult> results) {
    final workoutResults = results.where((r) => r.document.id.startsWith('workout_'));

    if (workoutResults.isNotEmpty) {
      final recent = workoutResults.first;
      final date = recent.document.timestamp;

      if (date != null) {
        final daysAgo = DateTime.now().difference(date).inDays;

        if (daysAgo == 0) {
          return _l('greeting_today');
        } else if (daysAgo == 1) {
          return _l('greeting_yesterday');
        } else if (daysAgo < 7) {
          return _l('greeting_days_ago').replaceAll('{days}', daysAgo.toString());
        }
      }
    }

    return null;
  }

  String _summarizeDocument(BM25Document document) {
    final lines = document.content.split('\n');
    final firstLine = lines.firstWhere(
      (line) => line.trim().isNotEmpty,
      orElse: () => '',
    );

    return firstLine.length > 100 ? '${firstLine.substring(0, 97)}...' : firstLine;
  }

  String _generateEncouragement(String type, double value) {
    if (type == 'pr') {
      if (value > 100) {
        return _l('encourage_pr_100');
      } else if (value > 60) {
        return _l('encourage_pr_60');
      } else {
        return _l('encourage_pr_default');
      }
    }
    return _l('encourage_generic');
  }

  /// Check if sets have similar reps (within 2 reps)
  bool _areSetsHomogeneous(List<ParsedSet> sets) {
    if (sets.isEmpty) return false;

    final reps = sets.where((s) => s.reps != null).map((s) => s.reps!).toList();
    if (reps.isEmpty) return false;

    final minReps = reps.reduce((a, b) => a < b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);

    return (maxReps - minReps) <= 2;
  }

  /// Infer muscle group from exercise name
  String? _inferMuscleGroup(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
      return 'chest';
    }
    if (name.contains('row') || name.contains('pull') || name.contains('lat') || name.contains('back')) {
      return 'back';
    }
    if (name.contains('squat') || name.contains('leg') || name.contains('lunge') || name.contains('deadlift')) {
      return 'legs';
    }
    if (name.contains('press') || name.contains('shoulder') || name.contains('delt')) {
      return 'shoulders';
    }
    if (name.contains('curl') || name.contains('tricep') || name.contains('bicep') || name.contains('arm')) {
      return 'arms';
    }
    if (name.contains('crunch') || name.contains('plank') || name.contains('ab') || name.contains('core')) {
      return 'core';
    }

    return null;
  }
}

/// Helper class for exercise progression tracking
class _ExerciseDataPoint {
  const _ExerciseDataPoint({
    required this.date,
    required this.maxWeight,
    required this.volume,
  });

  final DateTime date;
  final double maxWeight;
  final double volume;
}