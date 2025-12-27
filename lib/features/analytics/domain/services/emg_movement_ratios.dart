/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// EMG-BASED MOVEMENT PATTERN RATIOS
///
/// Scientific basis for muscle activation distribution based on EMG research.
/// These ratios determine how volume/stress is distributed between primary
/// and secondary muscles for different movement patterns.
///
/// **Research Sources**:
/// - Rodríguez-Ridao et al. (2020) - Bench Press EMG at different inclinations
/// - Schoenfeld et al. (2020) - Muscle activation in resistance training
/// - Contreras et al. (2020) - Gluteus activation in lower body exercises
///
/// **Classification (MVIC)**:
/// - >60% MVIC = Primary mover
/// - 41-60% MVIC = High synergist
/// - 21-40% MVIC = Moderate synergist
/// - <20% MVIC = Low synergist
library;

/// Movement patterns for EMG-based volume distribution
enum MovementPattern {
  /// Bench Press, Push-up, Dips, Chest Fly
  /// Primary: Pectoralis Major (~65% MVIC)
  /// High Synergist: Anterior Deltoid (~35% MVIC)
  /// Moderate Synergist: Triceps (~15% MVIC)
  pushHorizontal,

  /// Overhead Press, Arnold Press, Landmine Press
  /// Primary: Deltoids (~75% MVIC)
  /// High Synergist: Triceps (~60% MVIC)
  /// Low Synergist: Upper Chest (~25% MVIC)
  pushVertical,

  /// Barbell Row, Dumbbell Row, Cable Row
  /// Primary: Lats, Rhomboids (~70% MVIC)
  /// High Synergist: Rear Delt, Mid Traps (~45% MVIC)
  /// Moderate Synergist: Biceps (~30% MVIC)
  pullHorizontal,

  /// Pull-up, Lat Pulldown, Chin-up
  /// Primary: Latissimus Dorsi (~85% MVIC)
  /// High Synergist: Biceps (~55% MVIC)
  /// Moderate Synergist: Rear Delt (~35% MVIC)
  pullVertical,

  /// Back Squat, Front Squat, Leg Press, Lunges
  /// Primary: Quads (~70% MVIC)
  /// High Synergist: Glutes (~55% MVIC)
  /// Moderate Synergist: Hamstrings (~30% MVIC)
  squat,

  /// Deadlift, RDL, Hip Thrust, Good Morning
  /// Primary: Glutes, Hamstrings (~75% MVIC)
  /// High Synergist: Erector Spinae (~50% MVIC)
  /// Low Synergist: Quads (~20% MVIC)
  hinge,

  /// Bicep Curl, Tricep Extension, Leg Extension, Leg Curl
  /// Primary: Target muscle (~90% MVIC)
  /// Low Synergist: Stabilizers (~10% MVIC)
  isolation,

  /// Crunches, Planks, Leg Raises
  /// Primary: Target core muscles (~85% MVIC)
  /// Low Synergist: Hip flexors/stabilizers (~15% MVIC)
  core,

  /// Cardio, stretching, unknown exercises
  /// No muscle distribution (100% to primary if specified)
  other,
}

/// EMG-based ratio configuration for a movement pattern
class EmgRatioConfig {
  const EmgRatioConfig({
    required this.primaryRatio,
    required this.highSynergistRatio,
    required this.moderateSynergistRatio,
    required this.lowSynergistRatio,
  });

  /// Ratio for primary movers (>60% MVIC activation)
  final double primaryRatio;

  /// Ratio for high synergists (41-60% MVIC activation)
  final double highSynergistRatio;

  /// Ratio for moderate synergists (21-40% MVIC activation)
  final double moderateSynergistRatio;

  /// Ratio for low synergists (<20% MVIC activation)
  final double lowSynergistRatio;

  /// Total should equal 1.0
  double get total =>
      primaryRatio + highSynergistRatio + moderateSynergistRatio + lowSynergistRatio;

  /// Validate ratios sum to 1.0
  bool get isValid => (total - 1.0).abs() < 0.001;
}

/// EMG Movement Ratios Service
///
/// Provides EMG-based volume distribution ratios for different movement patterns.
///
/// **Usage**:
/// ```dart
/// final ratios = EmgMovementRatios.getRatios(MovementPattern.pushHorizontal);
/// final primaryVolume = totalVolume * ratios.primaryRatio; // 60%
/// final synergistVolume = totalVolume * ratios.highSynergistRatio; // 25%
/// ```
class EmgMovementRatios {
  EmgMovementRatios._();

  /// EMG-based ratios for each movement pattern
  ///
  /// Based on meta-analysis of EMG studies:
  /// - Rodríguez-Ridao 2020: Bench variations
  /// - Schoenfeld 2020: Compound movements
  /// - Contreras 2020: Lower body patterns
  static const Map<MovementPattern, EmgRatioConfig> _ratios = {
    // Push Horizontal: Chest 60%, Shoulders 25%, Triceps 15%
    MovementPattern.pushHorizontal: EmgRatioConfig(
      primaryRatio: 0.60,
      highSynergistRatio: 0.25,
      moderateSynergistRatio: 0.15,
      lowSynergistRatio: 0.0,
    ),

    // Push Vertical: Shoulders 55%, Triceps 35%, Upper Chest 10%
    MovementPattern.pushVertical: EmgRatioConfig(
      primaryRatio: 0.55,
      highSynergistRatio: 0.35,
      moderateSynergistRatio: 0.10,
      lowSynergistRatio: 0.0,
    ),

    // Pull Horizontal: Back 60%, Rear Delt 25%, Biceps 15%
    MovementPattern.pullHorizontal: EmgRatioConfig(
      primaryRatio: 0.60,
      highSynergistRatio: 0.25,
      moderateSynergistRatio: 0.15,
      lowSynergistRatio: 0.0,
    ),

    // Pull Vertical: Lats 55%, Biceps 30%, Rear Delt 15%
    MovementPattern.pullVertical: EmgRatioConfig(
      primaryRatio: 0.55,
      highSynergistRatio: 0.30,
      moderateSynergistRatio: 0.15,
      lowSynergistRatio: 0.0,
    ),

    // Squat: Quads 50%, Glutes 35%, Hamstrings 15%
    MovementPattern.squat: EmgRatioConfig(
      primaryRatio: 0.50,
      highSynergistRatio: 0.35,
      moderateSynergistRatio: 0.15,
      lowSynergistRatio: 0.0,
    ),

    // Hinge: Glutes/Hams 55%, Erectors 30%, Quads 15%
    MovementPattern.hinge: EmgRatioConfig(
      primaryRatio: 0.55,
      highSynergistRatio: 0.30,
      moderateSynergistRatio: 0.15,
      lowSynergistRatio: 0.0,
    ),

    // Isolation: Target 85%, Stabilizers 15%
    MovementPattern.isolation: EmgRatioConfig(
      primaryRatio: 0.85,
      highSynergistRatio: 0.15,
      moderateSynergistRatio: 0.0,
      lowSynergistRatio: 0.0,
    ),

    // Core: Target 85%, Hip flexors 15%
    MovementPattern.core: EmgRatioConfig(
      primaryRatio: 0.85,
      highSynergistRatio: 0.15,
      moderateSynergistRatio: 0.0,
      lowSynergistRatio: 0.0,
    ),

    // Other: 100% to primary (no distribution)
    MovementPattern.other: EmgRatioConfig(
      primaryRatio: 1.0,
      highSynergistRatio: 0.0,
      moderateSynergistRatio: 0.0,
      lowSynergistRatio: 0.0,
    ),
  };

  /// Get EMG ratios for a movement pattern
  static EmgRatioConfig getRatios(MovementPattern pattern) {
    return _ratios[pattern] ?? _ratios[MovementPattern.other]!;
  }

  /// Get simple two-way ratio (primary vs all synergists combined)
  ///
  /// For backwards compatibility with 70/30 style distribution
  static (double primary, double secondary) getSimpleRatios(MovementPattern pattern) {
    final config = getRatios(pattern);
    final secondaryTotal =
        config.highSynergistRatio + config.moderateSynergistRatio + config.lowSynergistRatio;
    return (config.primaryRatio, secondaryTotal);
  }

  /// Get tiered synergist distribution ratios
  ///
  /// Returns ratios for distributing volume among synergists based on their
  /// position in the list (first = high synergist, rest = moderate synergists).
  ///
  /// This is more accurate than equal distribution because:
  /// - First synergist is typically the main helper (e.g., anterior delt in bench)
  /// - Other synergists are secondary helpers (e.g., triceps in bench)
  ///
  /// Returns: (primaryRatio, highSynergistRatio, moderateSynergistRatio)
  /// where highSynergist applies to secondary[0] and moderate to secondary[1+]
  static (double primary, double highSynergist, double moderateSynergist) getTieredRatios(
    MovementPattern pattern,
  ) {
    final config = getRatios(pattern);
    return (
      config.primaryRatio,
      config.highSynergistRatio,
      config.moderateSynergistRatio + config.lowSynergistRatio,
    );
  }

  /// Distribute volume with tiered synergist support
  ///
  /// [primary]: List of primary muscles (receive primaryRatio)
  /// [secondary]: List of secondary muscles where:
  ///   - secondary[0]: High synergist (receives highSynergistRatio)
  ///   - secondary[1+]: Moderate synergists (split moderateSynergistRatio)
  ///
  /// Returns: Map of muscle abbreviation → distributed volume
  static Map<String, double> distributeWithTiers({
    required List<String> primary,
    required List<String> secondary,
    required double totalVolume,
    required MovementPattern pattern,
  }) {
    final result = <String, double>{};
    final (primaryRatio, highRatio, modRatio) = getTieredRatios(pattern);

    // Distribute to primary muscles (split evenly among them)
    if (primary.isNotEmpty) {
      final volumePerPrimary = (totalVolume * primaryRatio) / primary.length;
      for (final muscle in primary) {
        result[muscle.toLowerCase()] = volumePerPrimary;
      }
    }

    // Distribute to secondary muscles with tiered approach
    if (secondary.isNotEmpty) {
      // First synergist gets highRatio
      final highSynergistVolume = totalVolume * highRatio;
      result[secondary[0].toLowerCase()] = highSynergistVolume;

      // Remaining synergists split modRatio
      if (secondary.length > 1) {
        final remainingSynergists = secondary.sublist(1);
        final volumePerMod = (totalVolume * modRatio) / remainingSynergists.length;
        for (final muscle in remainingSynergists) {
          result[muscle.toLowerCase()] = volumePerMod;
        }
      }
    }

    return result;
  }

  /// Infer movement pattern from exercise file category and name
  ///
  /// Uses the exercise file (upper_push.json, etc.) and exercise name
  /// to determine the most likely movement pattern.
  static MovementPattern inferPattern({
    required String fileCategory,
    required String exerciseName,
    String? focusMuscle,
  }) {
    final lowerName = exerciseName.toLowerCase();
    final lowerFile = fileCategory.toLowerCase();

    // Core exercises
    if (lowerFile.contains('core') ||
        lowerName.contains('crunch') ||
        lowerName.contains('plank') ||
        lowerName.contains('addominali') ||
        lowerName.contains('obliqui')) {
      return MovementPattern.core;
    }

    // Lower body - need to distinguish squat vs hinge
    if (lowerFile.contains('lower')) {
      // Hinge patterns
      if (lowerName.contains('deadlift') ||
          lowerName.contains('stacco') ||
          lowerName.contains('rdl') ||
          lowerName.contains('hip thrust') ||
          lowerName.contains('good morning') ||
          lowerName.contains('hyperextension') ||
          lowerName.contains('glute') ||
          lowerName.contains('hamstring') ||
          lowerName.contains('leg curl') ||
          lowerName.contains('femorali')) {
        return MovementPattern.hinge;
      }

      // Squat patterns
      if (lowerName.contains('squat') ||
          lowerName.contains('leg press') ||
          lowerName.contains('pressa') ||
          lowerName.contains('lunge') ||
          lowerName.contains('affondo') ||
          lowerName.contains('step') ||
          lowerName.contains('quad') ||
          lowerName.contains('leg extension') ||
          lowerName.contains('estensioni')) {
        return MovementPattern.squat;
      }

      // Default lower to squat (more common)
      return MovementPattern.squat;
    }

    // Upper push
    if (lowerFile.contains('upper_push') || lowerFile.contains('push')) {
      // Vertical push
      if (lowerName.contains('overhead') ||
          lowerName.contains('ohp') ||
          lowerName.contains('military') ||
          lowerName.contains('shoulder press') ||
          lowerName.contains('arnold') ||
          lowerName.contains('lento avanti') ||
          lowerName.contains('spinte') && lowerName.contains('alto')) {
        return MovementPattern.pushVertical;
      }

      // Isolation push (triceps, lateral raises)
      if (lowerName.contains('tricep') ||
          lowerName.contains('pushdown') ||
          lowerName.contains('extension') && lowerName.contains('tric') ||
          lowerName.contains('alzate laterali') ||
          lowerName.contains('lateral raise') ||
          lowerName.contains('front raise') ||
          lowerName.contains('rear delt')) {
        return MovementPattern.isolation;
      }

      // Default upper push = horizontal push (bench, dips)
      return MovementPattern.pushHorizontal;
    }

    // Upper pull
    if (lowerFile.contains('upper_pull') || lowerFile.contains('pull')) {
      // Vertical pull
      if (lowerName.contains('pulldown') ||
          lowerName.contains('lat machine') ||
          lowerName.contains('pull-up') ||
          lowerName.contains('pullup') ||
          lowerName.contains('chin-up') ||
          lowerName.contains('chinup') ||
          lowerName.contains('trazioni')) {
        return MovementPattern.pullVertical;
      }

      // Isolation pull (biceps, rear delt)
      if (lowerName.contains('curl') ||
          lowerName.contains('bicep') ||
          lowerName.contains('bicipiti') ||
          lowerName.contains('hammer')) {
        return MovementPattern.isolation;
      }

      // Default upper pull = horizontal pull (rows)
      return MovementPattern.pullHorizontal;
    }

    // Other/unknown
    if (lowerFile.contains('other') || lowerFile.contains('cardio')) {
      return MovementPattern.other;
    }

    // Fallback: try to infer from focus muscle
    if (focusMuscle != null) {
      final lowerFocus = focusMuscle.toLowerCase();
      if (lowerFocus.contains('pett') || lowerFocus.contains('chest')) {
        return MovementPattern.pushHorizontal;
      }
      if (lowerFocus.contains('delt') || lowerFocus.contains('shoulder')) {
        return MovementPattern.pushVertical;
      }
      if (lowerFocus.contains('lat') || lowerFocus.contains('back')) {
        return MovementPattern.pullHorizontal;
      }
      if (lowerFocus.contains('quad') || lowerFocus.contains('leg')) {
        return MovementPattern.squat;
      }
      if (lowerFocus.contains('glut') || lowerFocus.contains('ham')) {
        return MovementPattern.hinge;
      }
      if (lowerFocus.contains('bic') || lowerFocus.contains('tric')) {
        return MovementPattern.isolation;
      }
      if (lowerFocus.contains('core') || lowerFocus.contains('abs')) {
        return MovementPattern.core;
      }
    }

    // Ultimate fallback
    return MovementPattern.other;
  }

  /// Map patternMovimento string from JSON directly to MovementPattern
  ///
  /// This is more accurate than name/file inference because the JSON
  /// already classifies exercises by movement pattern.
  ///
  /// Known patterns from JSON:
  /// - "Push Pattern" → pushHorizontal (default, uses name for vertical)
  /// - "Pull Pattern" → pullHorizontal (default, uses name for vertical)
  /// - "Squat Pattern" → squat
  /// - "Hinge Pattern" → hinge
  /// - "Lunge Pattern" → squat (lunge is squat-dominant)
  /// - "Isolation" → isolation
  /// - "Anti-Rotation / Core Stability" → core
  /// - "Functional Movement", "Strength", etc. → infer from name
  static MovementPattern fromPatternMovimento(
    String patternMovimento, {
    String exerciseName = '',
  }) {
    final lower = patternMovimento.toLowerCase().trim();
    final nameLower = exerciseName.toLowerCase();

    // Direct mappings from JSON patternMovimento
    if (lower.contains('push pattern') || lower == 'push') {
      // Distinguish vertical vs horizontal push
      if (nameLower.contains('overhead') ||
          nameLower.contains('ohp') ||
          nameLower.contains('military') ||
          nameLower.contains('shoulder press') ||
          nameLower.contains('arnold') ||
          nameLower.contains('lento avanti') ||
          (nameLower.contains('spinte') && nameLower.contains('alto'))) {
        return MovementPattern.pushVertical;
      }
      return MovementPattern.pushHorizontal;
    }

    if (lower.contains('pull pattern') || lower == 'pull') {
      // Distinguish vertical vs horizontal pull
      if (nameLower.contains('pulldown') ||
          nameLower.contains('lat machine') ||
          nameLower.contains('pull-up') ||
          nameLower.contains('pullup') ||
          nameLower.contains('chin-up') ||
          nameLower.contains('chinup') ||
          nameLower.contains('trazioni')) {
        return MovementPattern.pullVertical;
      }
      return MovementPattern.pullHorizontal;
    }

    if (lower.contains('squat pattern') || lower == 'squat') {
      return MovementPattern.squat;
    }

    if (lower.contains('lunge pattern') || lower == 'lunge') {
      // Lunges are squat-dominant (quad focus with glute synergist)
      return MovementPattern.squat;
    }

    if (lower.contains('hinge pattern') || lower == 'hinge') {
      return MovementPattern.hinge;
    }

    if (lower == 'isolation') {
      return MovementPattern.isolation;
    }

    if (lower.contains('core') ||
        lower.contains('anti-rotation') ||
        lower.contains('stability')) {
      return MovementPattern.core;
    }

    // For generic patterns, try to infer from name
    if (lower.contains('functional') ||
        lower.contains('strength') ||
        lower.contains('powerlifting') ||
        lower.contains('olympic')) {
      // These need name-based inference
      return inferPattern(
        fileCategory: '',
        exerciseName: exerciseName,
      );
    }

    // Flexibility/Plyometrics/Other → minimal muscle distribution
    if (lower.contains('flexibility') ||
        lower.contains('plyometric') ||
        lower.isEmpty) {
      return MovementPattern.other;
    }

    return MovementPattern.other;
  }
}
