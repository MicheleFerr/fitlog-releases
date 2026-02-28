import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Mixin providing fuzzy search capabilities for the settings screen.
mixin SettingsSearchMixin {
  /// Fuzzy match: returns true if query matches text with tolerance for typos
  bool fuzzyMatch(String text, String query) {
    if (query.isEmpty) return true;

    final normalizedText = _normalize(text);
    final normalizedQuery = _normalize(query);

    // Exact contains match
    if (normalizedText.contains(normalizedQuery)) return true;

    // Subsequence match (letters in order)
    if (_isSubsequence(normalizedQuery, normalizedText)) return true;

    // Levenshtein distance for short queries (typo tolerance)
    if (normalizedQuery.length <= 6) {
      // Check each word in text
      for (final word in normalizedText.split(RegExp(r'\s+'))) {
        if (_levenshteinDistance(word, normalizedQuery) <= 2) return true;
      }
    }

    return false;
  }

  /// Normalize text: lowercase, remove accents
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('\u00e0', 'a')
        .replaceAll('\u00e8', 'e')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ec', 'i')
        .replaceAll('\u00f2', 'o')
        .replaceAll('\u00f9', 'u');
  }

  /// Check if query chars appear in text in order
  bool _isSubsequence(String query, String text) {
    var queryIndex = 0;
    for (var i = 0; i < text.length && queryIndex < query.length; i++) {
      if (text[i] == query[queryIndex]) queryIndex++;
    }
    return queryIndex == query.length;
  }

  /// Levenshtein edit distance
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => i == 0 ? j : (j == 0 ? i : 0)),
    );

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[a.length][b.length];
  }

  /// Check if a section matches the search query
  bool sectionMatches(String searchQuery, List<String> keywords) {
    if (searchQuery.isEmpty) return true;
    return keywords.any((keyword) => fuzzyMatch(keyword, searchQuery));
  }

  /// Check if any section matches the current query
  bool anyMatches(
    String searchQuery,
    Map<String, List<String>> sectionKeywords,
  ) {
    return sectionKeywords.values
        .any((keywords) => sectionMatches(searchQuery, keywords));
  }

  /// Build keyword map for all sections
  Map<String, List<String>> buildSectionKeywords(AppLocalizations l10n) {
    return {
      'account': [
        'account',
        'profilo',
        'profile',
        'utente',
        'user',
        'email',
        'admin',
        l10n.account,
      ],
      'appearance': [
        'aspetto',
        'appearance',
        'tema',
        'theme',
        'dark',
        'light',
        'scuro',
        'chiaro',
        'system',
        'colori',
        'colors',
        l10n.appearance,
        l10n.theme,
      ],
      'workout': [
        'allenamento',
        'workout',
        'riposo',
        'rest',
        'serie',
        'set',
        'ripetizioni',
        'reps',
        'preset',
        '5x5',
        '4x8',
        'timer',
        'pausa',
        'suoni',
        'sounds',
        'audio',
        'vibrazione',
        'vibration',
        'schermo',
        'screen',
        l10n.settingsWorkout,
        l10n.settingsSounds,
        l10n.settingsDefaultRestTime,
      ],
      'exerciseCard': [
        'esercizio',
        'exercise',
        'card',
        'scheda',
        'gif',
        'animazione',
        'animation',
        'densita',
        'density',
        'compatto',
        'compact',
      ],
      'unitsLanguage': [
        'unita',
        'units',
        'lingua',
        'language',
        'italiano',
        'english',
        'kg',
        'lbs',
        'metric',
        'imperial',
        l10n.settingsUnitsLanguage,
        l10n.language,
      ],
      'data': [
        'dati',
        'data',
        'backup',
        'export',
        'import',
        'sync',
        'sincronizza',
        'health',
        'salute',
        'apple',
        'gdpr',
        'csv',
        'json',
        l10n.dataBackup,
        l10n.exportData,
      ],
      'premium': [
        'premium',
        'pro',
        'abbonamento',
        'subscription',
        'upgrade',
        'acquista',
        'buy',
      ],
      'help': [
        'aiuto',
        'help',
        'tutorial',
        'guida',
        'guide',
        'info',
        'informazioni',
        'about',
        'crediti',
        'credits',
        'versione',
        'version',
      ],
      'advanced': [
        'avanzate',
        'advanced',
        'ghost',
        'privacy',
        'nascondi',
        'hide',
        'xp',
        'tier',
        'debug',
        l10n.settingsAdvanced,
        l10n.ghostModeTitle,
      ],
      'accountActions': [
        'logout',
        'esci',
        'disconnetti',
        'elimina',
        'delete',
        'cancella',
        'account',
      ],
      'debug': ['debug', 'migrazione', 'migration', 'test', 'admin'],
    };
  }
}
