import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_search_mixin.dart';

// Concrete class to test the mixin
class _TestSearch with SettingsSearchMixin {}

void main() {
  late _TestSearch search;

  setUp(() {
    search = _TestSearch();
  });

  // ═══════════════════════════════════════════════════════════════
  // fuzzyMatch – exact contains
  // ═══════════════════════════════════════════════════════════════
  group('fuzzyMatch – exact contains', () {
    test('empty query always matches', () {
      expect(search.fuzzyMatch('Anything', ''), isTrue);
    });

    test('exact match', () {
      expect(search.fuzzyMatch('Theme', 'Theme'), isTrue);
    });

    test('case insensitive – query lower', () {
      expect(search.fuzzyMatch('Appearance', 'appearance'), isTrue);
    });

    test('case insensitive – query upper', () {
      expect(search.fuzzyMatch('appearance', 'APPEARANCE'), isTrue);
    });

    test('partial contains', () {
      expect(search.fuzzyMatch('Default Rest Time', 'rest'), isTrue);
    });

    test('no match returns false', () {
      expect(search.fuzzyMatch('Appearance', 'workout'), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // fuzzyMatch – accent normalisation
  // ═══════════════════════════════════════════════════════════════
  group('fuzzyMatch – accent normalisation', () {
    test('à normalised to a', () {
      expect(search.fuzzyMatch('Apparè', 'appare'), isTrue);
    });

    test('è normalised to e', () {
      expect(search.fuzzyMatch('Unità', 'unit'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // fuzzyMatch – subsequence match
  // ═══════════════════════════════════════════════════════════════
  group('fuzzyMatch – subsequence', () {
    test('subsequence found in text', () {
      // 'tm' is a subsequence of 'theme'
      expect(search.fuzzyMatch('Theme', 'tm'), isTrue);
    });

    test('subsequence with gap', () {
      // 'te' is a subsequence of 'Theme'
      expect(search.fuzzyMatch('Theme', 'te'), isTrue);
    });

    test('non-subsequence returns false', () {
      // 'xyz' is NOT a subsequence of 'Theme'
      expect(search.fuzzyMatch('Theme', 'xyz'), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // fuzzyMatch – Levenshtein typo tolerance (query ≤ 6 chars)
  // ═══════════════════════════════════════════════════════════════
  group('fuzzyMatch – Levenshtein typo tolerance', () {
    test('1 typo in short query', () {
      // 'thme' vs 'theme' – distance 1
      expect(search.fuzzyMatch('Theme', 'thme'), isTrue);
    });

    test('2 typos in short query', () {
      // 'thm' vs 'theme' – within distance 2
      expect(search.fuzzyMatch('Theme', 'thmee'), isTrue);
    });

    test('too many typos returns false', () {
      // 'xyz123' vs 'theme' – distance > 2
      expect(search.fuzzyMatch('Theme', 'xyzrst'), isFalse);
    });

    test('query longer than 6 chars skips Levenshtein but still can contains-match', () {
      expect(search.fuzzyMatch('Appearance Settings', 'appearance'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // sectionMatches
  // ═══════════════════════════════════════════════════════════════
  group('sectionMatches', () {
    test('empty query always matches', () {
      expect(search.sectionMatches('', ['theme', 'dark', 'light']), isTrue);
    });

    test('matches when keyword found', () {
      expect(search.sectionMatches('dark', ['theme', 'dark', 'light']), isTrue);
    });

    test('matches fuzzy keyword', () {
      // 'thme' is a typo of 'theme'
      expect(search.sectionMatches('thme', ['theme', 'dark', 'light']), isTrue);
    });

    test('no match returns false', () {
      expect(search.sectionMatches('xyz', ['theme', 'dark', 'light']), isFalse);
    });

    test('matches partial keyword', () {
      expect(search.sectionMatches('rest', ['default rest time', 'sounds']), isTrue);
    });

    test('empty keywords list never matches non-empty query', () {
      expect(search.sectionMatches('theme', []), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // anyMatches
  // ═══════════════════════════════════════════════════════════════
  group('anyMatches', () {
    final sectionKeywords = {
      'appearance': ['theme', 'dark', 'light'],
      'workout': ['rest', 'sounds', 'timer'],
      'units': ['kg', 'lbs', 'language'],
    };

    test('empty query returns true', () {
      expect(search.anyMatches('', sectionKeywords), isTrue);
    });

    test('matches first section', () {
      expect(search.anyMatches('dark', sectionKeywords), isTrue);
    });

    test('matches last section', () {
      expect(search.anyMatches('lbs', sectionKeywords), isTrue);
    });

    test('no section matches returns false', () {
      expect(search.anyMatches('xyz999', sectionKeywords), isFalse);
    });

    test('empty section map returns false for non-empty query', () {
      expect(search.anyMatches('theme', {}), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Levenshtein distance edge cases (tested via fuzzyMatch)
  // ═══════════════════════════════════════════════════════════════
  group('Levenshtein edge cases', () {
    test('empty text vs non-empty query – distance 1 matches', () {
      // _levenshteinDistance('', 'a') == 1 which is <= 2 tolerance
      expect(search.fuzzyMatch('', 'a'), isTrue);
    });

    test('single char exact match', () {
      expect(search.fuzzyMatch('a', 'a'), isTrue);
    });

    test('single char 1 away – matches within distance 2', () {
      // 'b' vs 'a' – distance 1, each ≤ 6 chars
      expect(search.fuzzyMatch('a', 'b'), isTrue);
    });

    test('two completely different short words', () {
      // 'cat' vs 'dog' – distance 3, should NOT match within ≤ 2
      expect(search.fuzzyMatch('cat', 'dog'), isFalse);
    });

    test('matching word among multi-word text', () {
      expect(search.fuzzyMatch('Default Rest Time', 'tim'), isTrue);
    });
  });
}
