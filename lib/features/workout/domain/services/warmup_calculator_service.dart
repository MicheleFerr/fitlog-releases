import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

/// Context for warmup generation — determines protocol aggressiveness.
enum WarmupContext {
  /// Full warmup protocol — used for the first compound exercise
  /// targeting a muscle group in a session.
  firstCompound,

  /// Abbreviated warmup — used when the muscle group has already been
  /// warmed up by a previous exercise (e.g., Incline DB after Bench Press).
  subsequent,

  /// No warmup needed — the exact same muscle group was already trained
  /// (not just synergistic, but direct match). Skip warmup entirely.
  alreadyWarm,
}

/// Science-based warmup calculator service.
///
/// Implements warmup protocols based on exercise science research.
/// V1 (legacy): Higher volume, all exercises treated equally.
/// V2: Reduced volume, context-aware (first compound vs subsequent).
///
/// References: PMC7558980, McGowan 2015, Ribeiro 2014, SBS Dec 2024.
class WarmupCalculatorService {
  /// Synergistic muscle groups — maps each category to categories it
  /// partially warms up via compound movements.
  ///
  /// Science basis:
  /// - Chest pressing → shoulders (anterior deltoid) + arms (triceps)
  /// - Back pulling → arms (biceps) + shoulders (rear deltoid)
  /// - Shoulder pressing → arms (triceps) + chest (clavicular head)
  /// - Legs (squat/deadlift) → abs (core stabilization)
  static const Map<ExerciseCategory, Set<ExerciseCategory>>
      synergisticCategories = {
    ExerciseCategory.chest: {ExerciseCategory.shoulders, ExerciseCategory.arms},
    ExerciseCategory.back: {ExerciseCategory.arms, ExerciseCategory.shoulders},
    ExerciseCategory.shoulders: {ExerciseCategory.arms, ExerciseCategory.chest},
    ExerciseCategory.legs: {ExerciseCategory.abs},
  };

  /// Determines warmup context for an exercise given previously trained
  /// categories in the session.
  ///
  /// Returns:
  /// - [WarmupContext.alreadyWarm] — same category was already trained
  ///   (muscle is fully irrorated, no warmup needed)
  /// - [WarmupContext.subsequent] — a synergistic category was trained
  ///   (muscle partially warm, 1 abbreviated set)
  /// - [WarmupContext.firstCompound] — no prior work for this muscle group
  static WarmupContext determineContext(
    ExerciseCategory category,
    Set<ExerciseCategory> categoriesAlreadyTrained,
  ) {
    // Direct match: same muscle group already trained → skip warmup
    if (categoriesAlreadyTrained.contains(category)) {
      return WarmupContext.alreadyWarm;
    }

    // Synergistic match: a category that warms this one was trained
    for (final trained in categoriesAlreadyTrained) {
      final synergies = synergisticCategories[trained];
      if (synergies != null && synergies.contains(category)) {
        return WarmupContext.subsequent;
      }
    }

    return WarmupContext.firstCompound;
  }

  /// Default available plates in kg (standard gym setup).
  static const List<double> defaultPlates = [
    25.0,
    20.0,
    15.0,
    10.0,
    5.0,
    2.5,
    1.25,
  ];

  /// Standard Olympic barbell weight in kg.
  static const double defaultBarbellWeight = 20.0;

  /// Calculates science-based warmup sets for a target working weight.
  ///
  /// **Protocol Selection** (based on target weight):
  /// - **Light (<40kg)**: 1 set
  ///   - Barbell: Empty bar only
  ///   - Other: 50% of target
  /// - **Medium (40-80kg)**: 3 sets
  ///   - Bar (if barbell), 50%, 80%
  /// - **Heavy (80-120kg)**: 4 sets
  ///   - Bar (if barbell), 40%, 60%, 80%
  /// - **Very Heavy (>120kg)**: 5 sets
  ///   - Bar (if barbell), 40%, 55%, 70%, 80%
  ///
  /// **Rep Scheme Rationale:**
  /// - Higher reps (8-10) for lighter sets → technique, blood flow
  /// - Lower reps (1-3) for heavier sets → neural activation, no fatigue
  ///
  /// [targetWeight] - The working weight for the exercise (kg)
  /// [isBarbell] - Whether the exercise uses a barbell (affects first set)
  /// [availablePlates] - Optional list of available plates for rounding
  ///
  /// Returns a list of [WarmupSet] objects with weight, reps, and percentage.
  List<WarmupSet> calculateWarmupSets(
    double targetWeight, {
    required bool isBarbell,
    List<double>? availablePlates,
  }) {
    if (targetWeight <= 0) {
      return [];
    }

    final plates = availablePlates ?? defaultPlates;
    final sets = <WarmupSet>[];

    // Light weight protocol (<40kg)
    if (targetWeight < 40) {
      if (isBarbell && targetWeight >= defaultBarbellWeight * 1.5) {
        // Empty bar only if target is significantly above bar weight
        sets.add(
          const WarmupSet(
            weight: defaultBarbellWeight,
            reps: 10,
            percentage: 0, // Empty bar = 0% reference
          ),
        );
      } else {
        // For dumbbells/cables/machines: 50% warmup
        final weight50 = targetWeight * 0.5;
        sets.add(
          WarmupSet(
            weight: roundToAvailablePlates(weight50, availablePlates: plates),
            reps: 10,
            percentage: 50,
          ),
        );
      }
      return sets;
    }

    // Medium weight protocol (40-80kg)
    if (targetWeight >= 40 && targetWeight < 80) {
      // Set 1: Empty bar for barbell, or 50% for other equipment
      if (isBarbell) {
        sets.add(
          const WarmupSet(
            weight: defaultBarbellWeight,
            reps: 10,
            percentage: 0,
          ),
        );
      } else {
        final weight50 = targetWeight * 0.5;
        sets.add(
          WarmupSet(
            weight: roundToAvailablePlates(weight50, availablePlates: plates),
            reps: 10,
            percentage: 50,
          ),
        );
      }

      // Set 2: 50% (if not already done above)
      if (isBarbell) {
        final weight50 = targetWeight * 0.5;
        sets.add(
          WarmupSet(
            weight: roundToAvailablePlates(weight50, availablePlates: plates),
            reps: 8,
            percentage: 50,
          ),
        );
      }

      // Set 3: 80% (final warmup - science-based ceiling)
      final weight80 = targetWeight * 0.8;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight80, availablePlates: plates),
          reps: 3,
          percentage: 80,
        ),
      );

      return sets;
    }

    // Heavy weight protocol (80-120kg)
    if (targetWeight >= 80 && targetWeight < 120) {
      // Set 1: Empty bar for barbell
      if (isBarbell) {
        sets.add(
          const WarmupSet(
            weight: defaultBarbellWeight,
            reps: 10,
            percentage: 0,
          ),
        );
      }

      // Set 2: 40%
      final weight40 = targetWeight * 0.4;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight40, availablePlates: plates),
          reps: 8,
          percentage: 40,
        ),
      );

      // Set 3: 60%
      final weight60 = targetWeight * 0.6;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight60, availablePlates: plates),
          reps: 5,
          percentage: 60,
        ),
      );

      // Set 4: 80% (final warmup)
      final weight80 = targetWeight * 0.8;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight80, availablePlates: plates),
          reps: 3,
          percentage: 80,
        ),
      );

      return sets;
    }

    // Very heavy weight protocol (>120kg)
    if (targetWeight >= 120) {
      // Set 1: Empty bar for barbell
      if (isBarbell) {
        sets.add(
          const WarmupSet(
            weight: defaultBarbellWeight,
            reps: 10,
            percentage: 0,
          ),
        );
      }

      // Set 2: 40%
      final weight40 = targetWeight * 0.4;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight40, availablePlates: plates),
          reps: 8,
          percentage: 40,
        ),
      );

      // Set 3: 55%
      final weight55 = targetWeight * 0.55;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight55, availablePlates: plates),
          reps: 6,
          percentage: 55,
        ),
      );

      // Set 4: 70%
      final weight70 = targetWeight * 0.7;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight70, availablePlates: plates),
          reps: 4,
          percentage: 70,
        ),
      );

      // Set 5: 80% (final warmup - NOT 90%)
      final weight80 = targetWeight * 0.8;
      sets.add(
        WarmupSet(
          weight: roundToAvailablePlates(weight80, availablePlates: plates),
          reps: 2,
          percentage: 80,
        ),
      );

      return sets;
    }

    return sets;
  }

  /// Rounds weight to the nearest achievable value with available plates.
  ///
  /// This ensures warmup weights can actually be loaded with gym equipment.
  /// Rounding logic:
  /// - For plates ≥ 5kg: Round to nearest 2.5kg (standard increment)
  /// - For plates < 5kg: Round to nearest 1.25kg (microplates available)
  ///
  /// [weight] - The raw calculated weight to round
  /// [availablePlates] - Optional list of available plates
  ///
  /// Returns the rounded weight that can be loaded with available plates.
  double roundToAvailablePlates(
    double weight, {
    List<double>? availablePlates,
  }) {
    final plates = availablePlates ?? defaultPlates;

    // Find smallest plate available
    final smallestPlate = plates.reduce((a, b) => a < b ? a : b);

    // Rounding increment depends on smallest available plate
    // Standard gym: 2.5kg plates → round to 2.5kg
    // Microplates available: 1.25kg → round to 1.25kg
    final increment = smallestPlate <= 2.5 ? 2.5 : 5.0;

    return (weight / increment).round() * increment;
  }

  /// Detects if an exercise likely uses a barbell based on its name.
  ///
  /// This helps determine if the first warmup set should be the empty bar.
  /// Detection is case-insensitive and looks for common barbell exercise
  /// patterns in multiple languages.
  ///
  /// **Barbell indicators:**
  /// - "barbell", "bar", "bb" (explicit mention)
  /// - "squat", "bench", "deadlift", "press" (compound lifts)
  /// - Italian: "bilanciere", "panca", "stacco"
  ///
  /// **Non-barbell indicators:**
  /// - "dumbbell", "db", "cable", "machine", "smith"
  /// - Italian: "manubrio", "cavo", "macchina"
  ///
  /// [exerciseName] - The name of the exercise
  ///
  /// Returns `true` if the exercise likely uses a barbell.
  bool isLikelyBarbellExercise(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    // Explicit non-barbell equipment mentions
    if (nameLower.contains('dumbbell') ||
        nameLower.contains('db') ||
        nameLower.contains('cable') ||
        nameLower.contains('machine') ||
        nameLower.contains('smith') ||
        nameLower.contains('manubrio') || // Italian: dumbbell
        nameLower.contains('cavo') || // Italian: cable
        nameLower.contains('macchina')) {
      // Italian: machine
      return false;
    }

    // Explicit barbell mentions
    if (nameLower.contains('barbell') ||
        nameLower.contains('bar ') ||
        nameLower.contains(' bb') ||
        nameLower.contains('bilanciere')) {
      // Italian: barbell
      return true;
    }

    // Common barbell compound lifts (language-agnostic patterns)
    final barbellPatterns = [
      'squat', // Back squat, front squat
      'bench', // Bench press
      'deadlift', // Deadlift
      'press', // Overhead press, military press
      'row', // Bent-over row, pendlay row
      'clean', // Power clean, hang clean
      'snatch', // Olympic snatch
      'jerk', // Push jerk, split jerk
      'thruster', // Barbell thruster
      // Italian translations
      'panca', // Bench press
      'stacco', // Deadlift
      'rematore', // Row
    ];

    return barbellPatterns.any((pattern) => nameLower.contains(pattern));
  }

  /// Calculates the number of plates per side needed for a given total weight.
  ///
  /// This helps users know exactly which plates to load on each side of the bar.
  /// The algorithm optimizes for:
  /// 1. Using largest plates first (easier to load/unload)
  /// 2. Matching available gym equipment
  /// 3. Providing clear plate counts
  ///
  /// **Example:**
  /// - Target: 100kg total
  /// - Barbell: 20kg
  /// - Per side: (100 - 20) / 2 = 40kg per side
  /// - Plates: 1×20kg, 1×15kg, 1×5kg per side
  ///
  /// [totalWeight] - The total weight to load (including barbell)
  /// [barbellWeight] - The weight of the barbell itself
  /// [availablePlates] - Optional list of available plates
  ///
  /// Returns a map of plate weights to counts needed per side.
  /// Example: `{20.0: 1, 15.0: 1, 5.0: 1}` means 1×20kg + 1×15kg + 1×5kg per side
  Map<double, int> calculatePlatesPerSide(
    double totalWeight, {
    double barbellWeight = defaultBarbellWeight,
    List<double>? availablePlates,
  }) {
    final plates = List<double>.from(availablePlates ?? defaultPlates)
      ..sort((a, b) => b.compareTo(a)); // Sort descending (largest first)

    // Calculate weight needed per side
    double weightPerSide = (totalWeight - barbellWeight) / 2;

    // Handle edge cases
    if (weightPerSide <= 0) {
      return {}; // Empty bar or invalid input
    }

    final plateCounts = <double, int>{};

    // Greedy algorithm: Use largest plates first
    for (final plate in plates) {
      final count = (weightPerSide / plate).floor();
      if (count > 0) {
        plateCounts[plate] = count;
        weightPerSide -= plate * count;
      }

      // Stop if we've loaded enough weight (allow small rounding errors)
      if (weightPerSide < 0.1) break;
    }

    return plateCounts;
  }

  /// Detects if an exercise uses a barbell based on its equipment field.
  ///
  /// More accurate than name-based heuristic [isLikelyBarbellExercise]
  /// because it uses the structured `attrezzatura` field from the exercise DB.
  ///
  /// [attrezzatura] - The equipment string from exerciseData (e.g. 'Bilanciere')
  ///
  /// Returns `true` if the equipment indicates a barbell.
  bool isBarbellByAttrezzatura(String? attrezzatura) {
    if (attrezzatura == null || attrezzatura.isEmpty) return false;
    final lower = attrezzatura.toLowerCase();
    return lower == 'bilanciere' ||
        lower == 'barbell' ||
        lower == 'olympic barbell' ||
        lower == 'ez bar' ||
        lower == 'trap bar';
  }

  /// Science-based warmup V2 with reduced volume and context awareness.
  ///
  /// Key improvements over V1:
  /// - **Fewer reps** at each intensity level (research: PMC7558980)
  /// - **Higher percentages** for fewer sets (skip low-value light sets)
  /// - **Context-aware**: `firstCompound` gets full protocol, `subsequent`
  ///   gets a single abbreviated set (muscle group already warm)
  ///
  /// **"First Compound" protocol** (total reps by weight bracket):
  /// | Target   | Sets | Detail                              | Total Reps |
  /// |----------|------|-------------------------------------|------------|
  /// | <40kg    | 1    | Bar ×5 or 50% ×5                   | 5          |
  /// | 40-80kg  | 3    | Bar ×5, 60% ×3, 80% ×2             | 10         |
  /// | 80-120kg | 4    | Bar ×5, 50% ×3, 70% ×2, 85% ×1    | 11         |
  /// | >120kg   | 5    | Bar ×5, 40% ×3, 60% ×2, 75% ×1, 85% ×1 | 12    |
  ///
  /// **"Subsequent" protocol**: Always 1 set at 55% × 4 reps
  List<WarmupSet> calculateWarmupSetsV2(
    double targetWeight, {
    WarmupContext warmupContext = WarmupContext.firstCompound,
    required bool isBarbell,
    List<double>? availablePlates,
  }) {
    if (targetWeight <= 0) return [];

    // Already warm: same muscle group was directly trained → no warmup needed
    if (warmupContext == WarmupContext.alreadyWarm) return [];

    final plates = availablePlates ?? defaultPlates;

    // Subsequent exercises (synergistic warmup): abbreviated single set
    if (warmupContext == WarmupContext.subsequent) {
      final weight55 = targetWeight * 0.55;
      final roundedWeight = isBarbell
          ? weight55.clamp(defaultBarbellWeight, double.infinity)
          : weight55;
      return [
        WarmupSet(
          weight: roundToAvailablePlates(roundedWeight, availablePlates: plates),
          reps: 4,
          percentage: 55,
        ),
      ];
    }

    // First compound — full progressive protocol
    final sets = <WarmupSet>[];

    // Light weight (<40kg): 1 set
    if (targetWeight < 40) {
      if (isBarbell && targetWeight >= defaultBarbellWeight * 1.5) {
        sets.add(const WarmupSet(
          weight: defaultBarbellWeight,
          reps: 5,
          percentage: 0,
        ));
      } else {
        final weight50 = targetWeight * 0.5;
        sets.add(WarmupSet(
          weight: roundToAvailablePlates(weight50, availablePlates: plates),
          reps: 5,
          percentage: 50,
        ));
      }
      return sets;
    }

    // Medium weight (40-80kg): 3 sets — Bar ×5, 60% ×3, 80% ×2
    if (targetWeight < 80) {
      if (isBarbell) {
        sets.add(const WarmupSet(
          weight: defaultBarbellWeight,
          reps: 5,
          percentage: 0,
        ));
      } else {
        final weight40 = targetWeight * 0.4;
        sets.add(WarmupSet(
          weight: roundToAvailablePlates(weight40, availablePlates: plates),
          reps: 5,
          percentage: 40,
        ));
      }

      final weight60 = targetWeight * 0.6;
      sets.add(WarmupSet(
        weight: roundToAvailablePlates(weight60, availablePlates: plates),
        reps: 3,
        percentage: 60,
      ));

      final weight80 = targetWeight * 0.8;
      sets.add(WarmupSet(
        weight: roundToAvailablePlates(weight80, availablePlates: plates),
        reps: 2,
        percentage: 80,
      ));

      return sets;
    }

    // Heavy weight (80-120kg): 4 sets — Bar ×5, 50% ×3, 70% ×2, 85% ×1
    if (targetWeight < 120) {
      if (isBarbell) {
        sets.add(const WarmupSet(
          weight: defaultBarbellWeight,
          reps: 5,
          percentage: 0,
        ));
      }

      final weight50 = targetWeight * 0.5;
      sets.add(WarmupSet(
        weight: roundToAvailablePlates(weight50, availablePlates: plates),
        reps: 3,
        percentage: 50,
      ));

      final weight70 = targetWeight * 0.7;
      sets.add(WarmupSet(
        weight: roundToAvailablePlates(weight70, availablePlates: plates),
        reps: 2,
        percentage: 70,
      ));

      final weight85 = targetWeight * 0.85;
      sets.add(WarmupSet(
        weight: roundToAvailablePlates(weight85, availablePlates: plates),
        reps: 1,
        percentage: 85,
      ));

      return sets;
    }

    // Very heavy (>120kg): 5 sets — Bar ×5, 40% ×3, 60% ×2, 75% ×1, 85% ×1
    if (isBarbell) {
      sets.add(const WarmupSet(
        weight: defaultBarbellWeight,
        reps: 5,
        percentage: 0,
      ));
    }

    final weight40 = targetWeight * 0.4;
    sets.add(WarmupSet(
      weight: roundToAvailablePlates(weight40, availablePlates: plates),
      reps: 3,
      percentage: 40,
    ));

    final weight60 = targetWeight * 0.6;
    sets.add(WarmupSet(
      weight: roundToAvailablePlates(weight60, availablePlates: plates),
      reps: 2,
      percentage: 60,
    ));

    final weight75 = targetWeight * 0.75;
    sets.add(WarmupSet(
      weight: roundToAvailablePlates(weight75, availablePlates: plates),
      reps: 1,
      percentage: 75,
    ));

    final weight85 = targetWeight * 0.85;
    sets.add(WarmupSet(
      weight: roundToAvailablePlates(weight85, availablePlates: plates),
      reps: 1,
      percentage: 85,
    ));

    return sets;
  }
}

/// Represents a warmup set with weight, reps, and percentage of working weight
class WarmupSet {
  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });

  final double weight;
  final int reps;
  final int percentage;
}
