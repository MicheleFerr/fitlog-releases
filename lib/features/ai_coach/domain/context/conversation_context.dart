/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/context
/// 🎯 Feature: ai_coach
/// 🔧 Type: context_manager
///
/// Conversation Context - Tracks conversation history and resolves elliptical references
///
/// **Features**:
/// - Conversation history tracking
/// - Entity extraction (exercises, metrics, dates)
/// - Elliptical reference resolution ("show me", "what about bench?")
/// - Topic continuity across messages
/// - Context-aware query enrichment
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/query_expander.dart';

/// Manages conversation context for AI Coach
class ConversationContext {
  // Conversation history (last N messages)
  final List<AIMessage> _history = [];
  final int _maxHistorySize = 10;

  // Extracted entities from conversation
  final Set<String> _mentionedExercises = {};
  final Set<String> _mentionedMetrics = {};
  final Set<String> _mentionedTimeframes = {};

  // Current conversation state
  String? _currentTopic;
  DateTime? _lastQueryTime;
  ExpandedQuery? _lastExpandedQuery;

  /// Add message to conversation history
  void addMessage(AIMessage message) {
    _history.add(message);

    // Extract entities from user messages
    if (message.role == MessageRole.user) {
      _extractEntities(message.content);
      _lastQueryTime = DateTime.now();
    }

    // Maintain history size limit
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  /// Get conversation history
  List<AIMessage> get history => List.unmodifiable(_history);

  /// Get last user message
  AIMessage? get lastUserMessage {
    return _history.reversed.firstWhere(
      (msg) => msg.role == MessageRole.user,
      orElse: () => AIMessage.user(content: ''),
    );
  }

  /// Get last assistant message
  AIMessage? get lastAssistantMessage {
    return _history.reversed.firstWhere(
      (msg) => msg.role == MessageRole.assistant,
      orElse: () => AIMessage.assistant(content: ''),
    );
  }

  /// Enrich query with conversation context
  String enrichQueryWithContext(String query) {
    final lowerQuery = query.toLowerCase().trim();

    // Check if query is elliptical (references previous context)
    if (_isEllipticalReference(lowerQuery)) {
      return _resolveEllipticalReference(query);
    }

    return query;
  }

  /// Check if query is elliptical (incomplete, refers to previous context)
  bool _isEllipticalReference(String query) {
    // Elliptical patterns (EN + IT)
    final ellipticalPatterns = [
      // English
      RegExp(r'^(and|what about|how about|show me|tell me)\s+'),
      RegExp(r'^(it|that|this|those|these)\s+'),
      RegExp(r'^(also|too|as well)\b'),

      // Italian
      RegExp(r'^(e|ed|anche|pure)\s+'),
      RegExp(r'^(cosa|come|quanto|quanti)\s+(per|di|su)\s+'),
      RegExp(r'^(mostra|dimmi|fammi vedere)\s+(quello|quella|quelli|quelle)\s+'),
      RegExp(r'^(che|quale)\s+(altro|altra)\s+'),
    ];

    return ellipticalPatterns.any((pattern) => pattern.hasMatch(query));
  }

  /// Resolve elliptical reference using context
  String _resolveEllipticalReference(String query) {
    final lowerQuery = query.toLowerCase();

    // Pattern 1: "And bench?" → Add last exercise context
    if (lowerQuery.startsWith('and ') ||
        lowerQuery.startsWith('e ') ||
        lowerQuery.startsWith('ed ')) {
      if (_currentTopic != null) {
        // Continue with same topic
        return '$_currentTopic $query';
      }
      if (_mentionedExercises.isNotEmpty) {
        // Add last mentioned exercise
        return '${_mentionedExercises.last} $query';
      }
    }

    // Pattern 2: "What about X?" → Reframe with current metric
    if (lowerQuery.contains('what about') || lowerQuery.contains('come')) {
      if (_mentionedMetrics.isNotEmpty) {
        final metric = _mentionedMetrics.last;
        return query.replaceAll(
          RegExp(r'what about|come'),
          'what is my $metric for',
        );
      }
    }

    // Pattern 3: "Show me" / "Mostra" → Add last topic
    if (lowerQuery.startsWith('show me') ||
        lowerQuery.startsWith('mostra') ||
        lowerQuery.startsWith('fammi vedere')) {
      if (_currentTopic != null) {
        return '$query about $_currentTopic';
      }
      if (_lastExpandedQuery != null && _lastExpandedQuery!.isExerciseSpecific) {
        final exercise = _lastExpandedQuery!.exerciseContext!.exercises.first;
        return '$query for $exercise';
      }
    }

    // Pattern 4: "That too" / "Anche quello" → Repeat with variation
    if (lowerQuery.contains('that') ||
        lowerQuery.contains('quello') ||
        lowerQuery.contains('quella')) {
      if (lastUserMessage != null) {
        // Modify last query slightly
        return lastUserMessage!.content.replaceFirst(
          RegExp(r'\b(squat|bench|deadlift|panca|stacco)\b'),
          query,
        );
      }
    }

    // Pattern 5: Italian "Che altro" → "What else"
    if (lowerQuery.contains('che altro') || lowerQuery.contains('cos altro')) {
      if (_mentionedExercises.isNotEmpty) {
        return 'What else besides ${_mentionedExercises.join(", ")}?';
      }
    }

    // Fallback: Return original query
    return query;
  }

  /// Extract entities from user message
  void _extractEntities(String message) {
    final lowerMessage = message.toLowerCase();

    // Extract exercises
    final exercises = [
      // English
      'squat', 'squats', 'bench', 'bench press', 'deadlift', 'deadlifts',
      'press', 'row', 'rows', 'pullup', 'pullups', 'curl', 'curls',
      'pushup', 'pushups', 'lunge', 'lunges', 'plank',

      // Italian
      'panca', 'stacco', 'stacchi', 'accosciata', 'accosciate',
      'trazioni', 'flessioni', 'rematore', 'affondi', 'distensioni',
    ];

    for (final exercise in exercises) {
      if (lowerMessage.contains(exercise)) {
        _mentionedExercises.add(exercise);
        _currentTopic = exercise; // Update current topic
      }
    }

    // Extract metrics
    final metrics = [
      // English
      'pr', 'personal record', 'max', 'maximum', '1rm',
      'volume', 'weight', 'reps', 'sets', 'progress',

      // Italian
      'massimale', 'record', 'ripetizioni', 'serie', 'peso',
      'carico', 'volume', 'progresso',
    ];

    for (final metric in metrics) {
      if (lowerMessage.contains(metric)) {
        _mentionedMetrics.add(metric);
      }
    }

    // Extract timeframes
    final timeframes = [
      // English
      'today', 'yesterday', 'week', 'month', 'year',
      'recent', 'last', 'latest',

      // Italian
      'oggi', 'ieri', 'settimana', 'mese', 'anno',
      'recente', 'ultimo', 'scorso',
    ];

    for (final timeframe in timeframes) {
      if (lowerMessage.contains(timeframe)) {
        _mentionedTimeframes.add(timeframe);
      }
    }

    // Limit entity set sizes
    if (_mentionedExercises.length > 5) {
      _mentionedExercises.remove(_mentionedExercises.first);
    }
    if (_mentionedMetrics.length > 5) {
      _mentionedMetrics.remove(_mentionedMetrics.first);
    }
    if (_mentionedTimeframes.length > 3) {
      _mentionedTimeframes.remove(_mentionedTimeframes.first);
    }
  }

  /// Update last expanded query (for context)
  void updateLastExpandedQuery(ExpandedQuery expandedQuery) {
    _lastExpandedQuery = expandedQuery;

    // Update current topic based on query
    if (expandedQuery.isExerciseSpecific &&
        expandedQuery.exerciseContext!.exercises.isNotEmpty) {
      _currentTopic = expandedQuery.exerciseContext!.exercises.first;
    }
  }

  /// Get context summary for debugging
  Map<String, dynamic> getContextSummary() {
    return {
      'historySize': _history.length,
      'currentTopic': _currentTopic,
      'mentionedExercises': _mentionedExercises.toList(),
      'mentionedMetrics': _mentionedMetrics.toList(),
      'mentionedTimeframes': _mentionedTimeframes.toList(),
      'lastQueryTime': _lastQueryTime?.toIso8601String(),
      'hasLastExpandedQuery': _lastExpandedQuery != null,
    };
  }

  /// Check if conversation is stale (no activity for N minutes)
  bool isStale({int minutesThreshold = 30}) {
    if (_lastQueryTime == null) return true;

    final now = DateTime.now();
    final elapsed = now.difference(_lastQueryTime!);
    return elapsed.inMinutes > minutesThreshold;
  }

  /// Clear conversation context (new conversation)
  void clear() {
    _history.clear();
    _mentionedExercises.clear();
    _mentionedMetrics.clear();
    _mentionedTimeframes.clear();
    _currentTopic = null;
    _lastQueryTime = null;
    _lastExpandedQuery = null;
  }

  /// Get mentioned entities as query hints
  String getMentionedEntitiesAsHints() {
    final hints = <String>[];

    if (_mentionedExercises.isNotEmpty) {
      hints.add('exercises: ${_mentionedExercises.join(", ")}');
    }
    if (_mentionedMetrics.isNotEmpty) {
      hints.add('metrics: ${_mentionedMetrics.join(", ")}');
    }
    if (_mentionedTimeframes.isNotEmpty) {
      hints.add('timeframes: ${_mentionedTimeframes.join(", ")}');
    }

    return hints.isEmpty ? 'no context' : hints.join(' | ');
  }

  /// Check if user is continuing a topic
  bool isContinuingTopic(String newQuery) {
    if (_currentTopic == null) return false;

    final lowerQuery = newQuery.toLowerCase();
    return lowerQuery.contains(_currentTopic!);
  }

  /// Get suggested follow-up questions
  List<String> getSuggestedFollowUps() {
    final suggestions = <String>[];

    // Based on current topic
    if (_currentTopic != null) {
      suggestions.add('Show my $_currentTopic progress');
      suggestions.add('What\'s my $_currentTopic PR?');
      suggestions.add('When did I last do $_currentTopic?');
    }

    // Based on last metric
    if (_mentionedMetrics.isNotEmpty) {
      final metric = _mentionedMetrics.last;
      suggestions.add('Compare my $metric this month vs last month');
    }

    // Based on history
    if (_history.length >= 3) {
      suggestions.add('Summarize our conversation');
    }

    return suggestions.take(3).toList();
  }

  /// Export conversation for analysis
  String exportConversation() {
    final buffer = StringBuffer();

    buffer.writeln('Conversation Export');
    buffer.writeln('==================');
    buffer.writeln('Started: ${_history.firstOrNull?.timestamp}');
    buffer.writeln('Last activity: $_lastQueryTime');
    buffer.writeln('Messages: ${_history.length}');
    buffer.writeln();

    buffer.writeln('Context:');
    buffer.writeln('- Current topic: $_currentTopic');
    buffer.writeln('- Mentioned exercises: ${_mentionedExercises.join(", ")}');
    buffer.writeln('- Mentioned metrics: ${_mentionedMetrics.join(", ")}');
    buffer.writeln('- Mentioned timeframes: ${_mentionedTimeframes.join(", ")}');
    buffer.writeln();

    buffer.writeln('Messages:');
    buffer.writeln('---------');
    for (final message in _history) {
      buffer.writeln('[${message.role.name.toUpperCase()}] ${message.content}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
