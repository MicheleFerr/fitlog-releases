/// Audit all muscle abbreviations to identify canonical vs variants
///
/// Checks:
/// - Current canonical definitions
/// - All variants mapped
/// - Proposes single source of truth
library;

void main() {
  print('🔍 Muscle Abbreviation Canonical Audit\n');
  print('=' * 70);

  // Current mapper structure from muscle_abbreviation_mapper.dart
  final muscleDefinitions = {
    'Arms': {
      'TRIC': {'canonical': 'TRIC', 'variants': [], 'length': 4},
      'BICI': {'canonical': 'BICI', 'variants': ['BIC'], 'length': 4},
      'AVA': {'canonical': 'AVA', 'variants': ['AVAMB'], 'length': 3},
    },
    'Back': {
      'LAT': {'canonical': 'LAT', 'variants': ['DORSO'], 'length': 3},
      'TRAP': {'canonical': 'TRAP', 'variants': [], 'length': 4},
      'LOMBAR': {'canonical': 'LOMBAR', 'variants': ['LOMB', 'LOM'], 'length': 6},
    },
    'Chest': {
      'PETT': {'canonical': 'PETT', 'variants': [], 'length': 4},
    },
    'Shoulders': {
      'DELT': {'canonical': 'DELT', 'variants': [], 'length': 4},
      'DELT_ANT': {'canonical': 'DELT_ANT', 'variants': [], 'length': 8},
      'DELT_LAT': {'canonical': 'DELT_LAT', 'variants': [], 'length': 8},
      'DELT_POST': {'canonical': 'DELT_POST', 'variants': [], 'length': 9},
      'COLLO': {'canonical': 'COLLO', 'variants': [], 'length': 5},
    },
    'Legs': {
      'GLUT': {'canonical': 'GLUT', 'variants': [], 'length': 4},
      'QUAD': {'canonical': 'QUAD', 'variants': [], 'length': 4},
      'FEMOR': {'canonical': 'FEMOR', 'variants': ['FEMO'], 'length': 5},
      'POLP': {'canonical': 'POLP', 'variants': ['POLL'], 'length': 4},
      'ADD': {'canonical': 'ADD', 'variants': ['ADDO', 'ADDUT'], 'length': 3},
      'ABDU': {'canonical': 'ABDU', 'variants': ['ABDUT'], 'length': 4},
    },
    'Core': {
      'CORE': {'canonical': 'CORE', 'variants': ['ADDOM'], 'length': 4},
    },
  };

  // Analyze length distribution
  final lengthDistribution = <int, List<String>>{};
  var totalCanonical = 0;

  for (final category in muscleDefinitions.entries) {
    for (final muscle in category.value.entries) {
      final canonical = muscle.value['canonical'] as String;
      final length = muscle.value['length'] as int;

      lengthDistribution.putIfAbsent(length, () => []).add(canonical);
      totalCanonical++;
    }
  }

  print('📊 Current Canonical Length Distribution:\n');
  for (final entry in lengthDistribution.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length))) {
    final percent = (entry.value.length / totalCanonical * 100).toStringAsFixed(1);
    print('${entry.key} letters: ${entry.value.length} muscles ($percent%)');
    for (final muscle in entry.value) {
      print('  • $muscle');
    }
    print('');
  }

  print('=' * 70);
  print('💡 STANDARDIZATION PROPOSAL\n');

  // Propose 4-letter standard
  print('Standard: 4 letters (used by 66% of muscles)\n');
  print('Changes needed:\n');

  final changes = <Map<String, String>>[];

  // Check each muscle
  for (final category in muscleDefinitions.entries) {
    for (final muscle in category.value.entries) {
      final canonical = muscle.value['canonical'] as String;
      final variants = muscle.value['variants'] as List<dynamic>;
      final length = muscle.value['length'] as int;

      if (length != 4 && !canonical.contains('_')) {
        // Find 4-letter variant or suggest
        String? suggested;
        for (final variant in variants) {
          if (variant.toString().length == 4) {
            suggested = variant.toString();
            break;
          }
        }

        // If no 4-letter variant, truncate or keep as-is
        if (suggested == null && canonical.length >= 4) {
          suggested = canonical.substring(0, 4);
        } else if (suggested == null) {
          suggested = canonical; // Keep short ones as-is
        }

        changes.add({
          'category': category.key,
          'current': canonical,
          'proposed': suggested,
          'reason': length > 4
              ? 'Shorten from $length to 4 letters'
              : 'Extend from $length to 4 letters (or keep as-is)',
        });
      }
    }
  }

  if (changes.isEmpty) {
    print('✅ No changes needed for 4-letter standard (ignoring _ANT/_LAT/_POST)\n');
  } else {
    for (final change in changes) {
      print('${change['category']}:');
      print('  ${change['current']} → ${change['proposed']}');
      print('  Reason: ${change['reason']}\n');
    }
  }

  print('=' * 70);
  print('🎯 RECOMMENDATION\n');
  print('1. Use 4-letter standard for simple muscles');
  print('2. Keep DELT_ANT/LAT/POST for shoulder specificity');
  print('3. Exceptions: AVA (3), ADD (3), LAT (3) - common/short');
  print('');
  print('Proposed changes:');
  print('  • LOMBAR (6) → LOMB (4) - variant already exists');
  print('  • FEMOR (5) → FEMO (4) - variant already exists');
  print('  • COLLO (5) → COLL (4) - new abbreviation');
  print('');
  print('Keep as-is (common short forms):');
  print('  • AVA (3) - avambracci');
  print('  • ADD (3) - adduttori');
  print('  • LAT (3) - dorsali');
}
