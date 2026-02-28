/// Unit tests for tool_executor_helpers.dart
///
/// Tests pure/static helpers: normalizeString, parseBoundedInt,
/// normalizeForMatch, areSimilarNames, selectDiverseExercises,
/// goalFromOnboarding, experienceFromOnboarding, normalizeGoalInput,
/// normalizeExperienceInput, goalToOnboardingValue,
/// profileSuggestionsForMissing, parseBoolFlag,
/// canonicalMuscleGroup, muscleGroupLabel, searchQueryForMuscle,
/// encodeToolError.
///
/// No Firebase / Hive / external services are required because all
/// tested functions are pure or deterministic utilities.
///
/// **Layer**: Data - Tests
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseDefinitionTemplate _makeExercise(String name,
    {List<String> muscles = const ['chest']}) {
  return ExerciseDefinitionTemplate(
    id: name.toLowerCase().replaceAll(' ', '_'),
    name: name,
    description: '',
    category: ExerciseCategory.chest,
    type: ExerciseType.single,
    muscleGroups: muscles,
    equipment: const [],
  );
}

OnboardingState _stateWith({
  String? userGoal,
  String? userExperienceLevel,
  Map<String, dynamic> stepData = const {},
}) {
  return OnboardingState(
    userGoal: userGoal,
    userExperienceLevel: userExperienceLevel,
    stepData: stepData,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('normalizeString', () {
    test('passes through plain ASCII unchanged', () {
      expect(normalizeString('hello world'), 'hello world');
    });

    test('decodes single unicode escape \\u00b0 to degree symbol', () {
      expect(normalizeString(r'\u00b0'), '\u00b0');
    });

    test('decodes \\u0041 to letter A', () {
      expect(normalizeString(r'\u0041'), 'A');
    });

    test('decodes multiple unicode escapes in one string', () {
      // \u0048 = H, \u0069 = i
      expect(normalizeString(r'\u0048\u0069'), 'Hi');
    });

    test('decodes uppercase hex digits', () {
      expect(normalizeString(r'\u004F'), 'O');
    });

    test('handles mixed literal text and unicode escapes', () {
      final result = normalizeString(r'temp: \u00b0C');
      expect(result, 'temp: \u00b0C');
    });

    test('returns empty string for empty input', () {
      expect(normalizeString(''), '');
    });

    test('leaves already-decoded characters unchanged', () {
      expect(normalizeString('café'), 'café');
    });

    test('does not touch partial escape sequences', () {
      // Only 3 hex digits — not a valid \uXXXX escape, left as-is.
      expect(normalizeString(r'\u004'), r'\u004');
    });
  });

  // -------------------------------------------------------------------------
  group('parseBoundedInt', () {
    test('returns value when within bounds', () {
      expect(parseBoundedInt(5, defaultValue: 3, min: 1, max: 10), 5);
    });

    test('parses String input', () {
      expect(parseBoundedInt('7', defaultValue: 3, min: 1, max: 10), 7);
    });

    test('parses double (num) input by truncating', () {
      expect(parseBoundedInt(4.9, defaultValue: 3, min: 1, max: 10), 4);
    });

    test('uses defaultValue for null', () {
      expect(parseBoundedInt(null, defaultValue: 5, min: 1, max: 10), 5);
    });

    test('uses defaultValue for unparseable String', () {
      expect(parseBoundedInt('abc', defaultValue: 3, min: 1, max: 10), 3);
    });

    test('clamps value below min to min', () {
      expect(parseBoundedInt(0, defaultValue: 3, min: 1, max: 10), 1);
    });

    test('clamps value above max to max', () {
      expect(parseBoundedInt(999, defaultValue: 3, min: 1, max: 10), 10);
    });

    test('accepts value exactly equal to min', () {
      expect(parseBoundedInt(1, defaultValue: 3, min: 1, max: 10), 1);
    });

    test('accepts value exactly equal to max', () {
      expect(parseBoundedInt(10, defaultValue: 3, min: 1, max: 10), 10);
    });

    test('clamps defaultValue itself if it is out of range', () {
      // default 0 < min 1 → clamps to 1
      expect(parseBoundedInt(null, defaultValue: 0, min: 1, max: 10), 1);
    });

    test('handles negative min/max bounds', () {
      expect(parseBoundedInt(-5, defaultValue: 0, min: -10, max: -1), -5);
    });
  });

  // -------------------------------------------------------------------------
  group('normalizeForMatch', () {
    test('lowercases input', () {
      expect(normalizeForMatch('SQUAT'), 'squat');
    });

    test('trims leading and trailing whitespace', () {
      expect(normalizeForMatch('  squat  '), 'squat');
    });

    test('collapses internal whitespace to single space', () {
      expect(normalizeForMatch('panca   piana'), 'panca piana');
    });

    test('removes special characters outside allowed set', () {
      // Dots, hyphens, parentheses are replaced with space then collapsed.
      expect(normalizeForMatch('Bench-Press (barbell)'), 'bench press barbell');
    });

    test('preserves accented Italian characters', () {
      expect(normalizeForMatch('Alzàte Obliquè'), 'alzàte obliquè');
    });

    test('returns empty string for whitespace-only input', () {
      expect(normalizeForMatch('   '), '');
    });

    test('returns empty string for empty input', () {
      expect(normalizeForMatch(''), '');
    });

    test('handles already-normalized input unchanged', () {
      expect(normalizeForMatch('squat'), 'squat');
    });

    test('replaces slash with space', () {
      expect(normalizeForMatch('pull/push'), 'pull push');
    });
  });

  // -------------------------------------------------------------------------
  group('areSimilarNames', () {
    test('identical names are similar', () {
      expect(areSimilarNames('bench press', 'bench press'), isTrue);
    });

    test('names sharing majority of significant words are similar', () {
      // "panca piana con bilanciere" vs "panca piana" share 2/2 words of
      // the smaller set → ≥ 60% threshold → similar.
      expect(
        areSimilarNames('panca piana con bilanciere', 'panca piana'),
        isTrue,
      );
    });

    test('completely different names are not similar', () {
      expect(areSimilarNames('squat', 'bench press'), isFalse);
    });

    test('short words (≤2 chars) are ignored', () {
      // "ab cd" — both words are ≤ 2 chars → both sets empty → not similar.
      expect(areSimilarNames('ab cd', 'ab cd'), isFalse);
    });

    test('single short word on each side returns false', () {
      expect(areSimilarNames('ab', 'ab'), isFalse);
    });

    test('names with one long word in common are similar', () {
      // smaller set has size 1, intersection size 1 → ceil(0.6) = 1 → similar.
      expect(areSimilarNames('squat', 'squat variation'), isTrue);
    });

    test('names with no common long words are not similar', () {
      expect(areSimilarNames('deadlift', 'overhead press'), isFalse);
    });

    test('case sensitivity: lowercase comparison produces correct result', () {
      // areSimilarNames does NOT lowercase internally; callers should pass
      // lowercased strings (as selectDiverseExercises does).
      expect(areSimilarNames('squat', 'squat'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('selectDiverseExercises', () {
    test('returns empty list for empty input', () {
      expect(selectDiverseExercises([], 4), isEmpty);
    });

    test('returns up to limit exercises', () {
      // Use names that share no common word with each other.
      final exercises = [
        _makeExercise('Squat'),
        _makeExercise('Deadlift'),
        _makeExercise('Pulldown'),
        _makeExercise('Overhead'),
        _makeExercise('Crunch'),
        _makeExercise('Lunge'),
      ];
      expect(selectDiverseExercises(exercises, 4).length, 4);
    });

    test('returns all exercises when count <= limit', () {
      final exercises = [
        _makeExercise('Squat'),
        _makeExercise('Deadlift'),
        _makeExercise('Bench Press'),
      ];
      expect(selectDiverseExercises(exercises, 10).length, 3);
    });

    test('excludes duplicate similar names', () {
      final exercises = [
        _makeExercise('panca piana'),
        _makeExercise('panca piana con bilanciere'), // similar to first
        _makeExercise('squat'),
      ];
      final result = selectDiverseExercises(exercises, 10);
      // The second exercise should be excluded as a duplicate.
      expect(result.length, 2);
      expect(result.map((e) => e.name).contains('squat'), isTrue);
    });

    test('preserves order of first-seen diverse exercises', () {
      final exercises = [
        _makeExercise('Squat'),
        _makeExercise('Deadlift'),
        _makeExercise('Bench Press'),
      ];
      final result = selectDiverseExercises(exercises, 3);
      expect(result[0].name, 'Squat');
      expect(result[1].name, 'Deadlift');
      expect(result[2].name, 'Bench Press');
    });

    test('limit of 0 returns empty list', () {
      final exercises = [_makeExercise('Squat')];
      expect(selectDiverseExercises(exercises, 0), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('normalizeGoalInput', () {
    test('returns null for null input', () {
      expect(normalizeGoalInput(null), isNull);
    });

    test('returns null for empty string', () {
      expect(normalizeGoalInput(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(normalizeGoalInput('   '), isNull);
    });

    test('recognizes "muscle" keyword', () {
      expect(normalizeGoalInput('muscle'), 'muscle');
    });

    test('recognizes Italian "massa" keyword', () {
      expect(normalizeGoalInput('massa muscolare'), 'muscle');
    });

    test('recognizes "ipertrof" (ipertrofia)', () {
      expect(normalizeGoalInput('ipertrofia'), 'muscle');
    });

    test('recognizes "strength" keyword', () {
      expect(normalizeGoalInput('strength'), 'strength');
    });

    test('recognizes Italian "forza"', () {
      expect(normalizeGoalInput('guadagnare forza'), 'strength');
    });

    test('recognizes "power"', () {
      expect(normalizeGoalInput('power lifting'), 'strength');
    });

    test('recognizes "fat" keyword', () {
      expect(normalizeGoalInput('fat loss'), 'fat_loss');
    });

    test('recognizes Italian "dimagr"', () {
      expect(normalizeGoalInput('dimagrire'), 'fat_loss');
    });

    test('recognizes "lose" keyword', () {
      expect(normalizeGoalInput('lose weight'), 'fat_loss');
    });

    test('recognizes Italian "peso"', () {
      expect(normalizeGoalInput('perdere peso'), 'fat_loss');
    });

    test('recognizes "endur" keyword', () {
      expect(normalizeGoalInput('endurance training'), 'endurance');
    });

    test('recognizes Italian "resistenza"', () {
      expect(normalizeGoalInput('resistenza'), 'endurance');
    });

    test('recognizes "fit" keyword', () {
      expect(normalizeGoalInput('stay fit'), 'endurance');
    });

    test('recognizes "ricompos" for recomposition', () {
      expect(normalizeGoalInput('ricomposizione corporea'), 'recomposition');
    });

    test('recognizes "recomposition" keyword', () {
      expect(normalizeGoalInput('body recomposition'), 'recomposition');
    });

    test('is case-insensitive', () {
      expect(normalizeGoalInput('MUSCLE'), 'muscle');
    });

    test('returns null for unrecognized input', () {
      expect(normalizeGoalInput('flexibility'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('normalizeExperienceInput', () {
    test('returns null for null input', () {
      expect(normalizeExperienceInput(null), isNull);
    });

    test('returns null for empty string', () {
      expect(normalizeExperienceInput(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(normalizeExperienceInput('   '), isNull);
    });

    test('recognizes "begin" keyword', () {
      expect(normalizeExperienceInput('beginner'), 'beginner');
    });

    test('recognizes Italian "principiante"', () {
      expect(normalizeExperienceInput('principiante'), 'beginner');
    });

    test('recognizes "athlet" keyword', () {
      expect(normalizeExperienceInput('athlete'), 'athlete');
    });

    test('recognizes Italian "atleta"', () {
      expect(normalizeExperienceInput('atleta'), 'athlete');
    });

    test('recognizes "expert" keyword', () {
      expect(normalizeExperienceInput('expert'), 'experienced');
    });

    test('recognizes Italian "esperto"', () {
      expect(normalizeExperienceInput('esperto'), 'experienced');
    });

    test('recognizes "advanced" keyword', () {
      expect(normalizeExperienceInput('advanced'), 'experienced');
    });

    test('recognizes Italian "avanz" (avanzato)', () {
      expect(normalizeExperienceInput('avanzato'), 'experienced');
    });

    test('recognizes "intermedio"', () {
      expect(normalizeExperienceInput('intermedio'), 'some');
    });

    test('recognizes "intermediate"', () {
      expect(normalizeExperienceInput('intermediate'), 'some');
    });

    test('recognizes "some" keyword', () {
      expect(normalizeExperienceInput('some experience'), 'some');
    });

    test('is case-insensitive', () {
      expect(normalizeExperienceInput('BEGINNER'), 'beginner');
    });

    test('returns null for unrecognized input', () {
      expect(normalizeExperienceInput('unknown level'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('goalFromOnboarding', () {
    test('returns null for null state', () {
      expect(goalFromOnboarding(null), isNull);
    });

    test('maps userGoal buildMuscle to muscle', () {
      expect(goalFromOnboarding(_stateWith(userGoal: 'buildMuscle')), 'muscle');
    });

    test('maps userGoal loseWeight to fat_loss', () {
      expect(
        goalFromOnboarding(_stateWith(userGoal: 'loseWeight')),
        'fat_loss',
      );
    });

    test('maps userGoal getStronger to strength', () {
      expect(
        goalFromOnboarding(_stateWith(userGoal: 'getStronger')),
        'strength',
      );
    });

    test('maps userGoal stayFit to endurance', () {
      expect(
        goalFromOnboarding(_stateWith(userGoal: 'stayFit')),
        'endurance',
      );
    });

    test('returns null for unrecognized userGoal', () {
      expect(goalFromOnboarding(_stateWith(userGoal: 'unknown')), isNull);
    });

    test('returns null when no goal set', () {
      expect(goalFromOnboarding(_stateWith()), isNull);
    });

    test('stepData aiGoal takes precedence over userGoal', () {
      // aiGoal="muscle" should override userGoal="stayFit".
      final state = _stateWith(
        userGoal: 'stayFit',
        stepData: {'aiGoal': 'muscle building'},
      );
      expect(goalFromOnboarding(state), 'muscle');
    });

    test('falls back to userGoal when aiGoal is unrecognizable', () {
      final state = _stateWith(
        userGoal: 'getStronger',
        stepData: {'aiGoal': 'random words'},
      );
      expect(goalFromOnboarding(state), 'strength');
    });
  });

  // -------------------------------------------------------------------------
  group('experienceFromOnboarding', () {
    test('returns null for null state', () {
      expect(experienceFromOnboarding(null), isNull);
    });

    test('maps userExperienceLevel beginner to beginner', () {
      expect(
        experienceFromOnboarding(_stateWith(userExperienceLevel: 'beginner')),
        'beginner',
      );
    });

    test('maps userExperienceLevel expert to experienced', () {
      expect(
        experienceFromOnboarding(_stateWith(userExperienceLevel: 'expert')),
        'experienced',
      );
    });

    test('returns null for unrecognized userExperienceLevel', () {
      expect(
        experienceFromOnboarding(_stateWith(userExperienceLevel: 'wizard')),
        isNull,
      );
    });

    test('returns null when no level set', () {
      expect(experienceFromOnboarding(_stateWith()), isNull);
    });

    test('stepData aiExperienceLevel takes precedence over userExperienceLevel',
        () {
      final state = _stateWith(
        userExperienceLevel: 'beginner',
        stepData: {'aiExperienceLevel': 'atleta'},
      );
      expect(experienceFromOnboarding(state), 'athlete');
    });

    test(
        'falls back to userExperienceLevel when aiExperienceLevel unrecognized',
        () {
      final state = _stateWith(
        userExperienceLevel: 'beginner',
        stepData: {'aiExperienceLevel': 'unknown'},
      );
      expect(experienceFromOnboarding(state), 'beginner');
    });
  });

  // -------------------------------------------------------------------------
  group('goalToOnboardingValue', () {
    test('maps muscle to buildMuscle', () {
      expect(goalToOnboardingValue('muscle'), 'buildMuscle');
    });

    test('maps fat_loss to loseWeight', () {
      expect(goalToOnboardingValue('fat_loss'), 'loseWeight');
    });

    test('maps strength to getStronger', () {
      expect(goalToOnboardingValue('strength'), 'getStronger');
    });

    test('maps endurance to stayFit', () {
      expect(goalToOnboardingValue('endurance'), 'stayFit');
    });

    test('returns null for recomposition (no mapping)', () {
      expect(goalToOnboardingValue('recomposition'), isNull);
    });

    test('returns null for unknown goal', () {
      expect(goalToOnboardingValue('unknown'), isNull);
    });

    test('roundtrip: muscle -> buildMuscle -> muscle via normalizeGoalInput',
        () {
      final onboarding = goalToOnboardingValue('muscle');
      expect(onboarding, 'buildMuscle');
      // Simulate reading back: normalizeGoalInput('buildMuscle') → 'muscle'
      expect(normalizeGoalInput(onboarding), 'muscle');
    });
  });

  // -------------------------------------------------------------------------
  group('profileSuggestionsForMissing', () {
    test('returns experience level suggestions for "experienceLevel" field',
        () {
      final suggestions = profileSuggestionsForMissing('experienceLevel');
      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Sono principiante'));
      expect(suggestions, contains('Sono intermedio'));
      expect(suggestions, contains('Sono avanzato'));
    });

    test('returns goal suggestions for "goal" field', () {
      final suggestions = profileSuggestionsForMissing('goal');
      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Obiettivo: massa muscolare'));
      expect(suggestions, contains('Obiettivo: forza'));
      expect(suggestions, contains('Obiettivo: dimagrimento'));
    });

    test('returns weekly target suggestions for "weeklyTarget" field', () {
      final suggestions = profileSuggestionsForMissing('weeklyTarget');
      expect(suggestions, isNotEmpty);
      expect(suggestions, contains('Mi alleno 3 volte a settimana'));
      expect(suggestions, contains('Mi alleno 4 volte a settimana'));
      expect(suggestions, contains('Mi alleno 5 volte a settimana'));
    });

    test('returns empty list for unknown field', () {
      expect(profileSuggestionsForMissing('unknown_field'), isEmpty);
    });

    test('experienceLevel returns exactly 3 suggestions', () {
      expect(profileSuggestionsForMissing('experienceLevel').length, 3);
    });

    test('goal returns exactly 3 suggestions', () {
      expect(profileSuggestionsForMissing('goal').length, 3);
    });

    test('weeklyTarget returns exactly 3 suggestions', () {
      expect(profileSuggestionsForMissing('weeklyTarget').length, 3);
    });
  });

  // -------------------------------------------------------------------------
  group('parseBoolFlag', () {
    test('null returns defaultValue false when not specified', () {
      expect(parseBoolFlag(null), isFalse);
    });

    test('null returns defaultValue true when specified', () {
      expect(parseBoolFlag(null, defaultValue: true), isTrue);
    });

    test('bool true returns true', () {
      expect(parseBoolFlag(true), isTrue);
    });

    test('bool false returns false', () {
      expect(parseBoolFlag(false), isFalse);
    });

    test('num 1 returns true', () {
      expect(parseBoolFlag(1), isTrue);
    });

    test('num 0 returns false', () {
      expect(parseBoolFlag(0), isFalse);
    });

    test('num non-zero double returns true', () {
      expect(parseBoolFlag(3.14), isTrue);
    });

    test('String "true" returns true', () {
      expect(parseBoolFlag('true'), isTrue);
    });

    test('String "false" returns false', () {
      expect(parseBoolFlag('false'), isFalse);
    });

    test('String "1" returns true', () {
      expect(parseBoolFlag('1'), isTrue);
    });

    test('String "0" returns false', () {
      expect(parseBoolFlag('0'), isFalse);
    });

    test('String "yes" returns true', () {
      expect(parseBoolFlag('yes'), isTrue);
    });

    test('String "no" returns false', () {
      expect(parseBoolFlag('no'), isFalse);
    });

    test('String "si" (Italian yes) returns true', () {
      expect(parseBoolFlag('si'), isTrue);
    });

    test('String "sì" (Italian yes with accent) returns true', () {
      expect(parseBoolFlag('sì'), isTrue);
    });

    test('String "vero" (Italian true) returns true', () {
      expect(parseBoolFlag('vero'), isTrue);
    });

    test('String "falso" (Italian false) returns false', () {
      expect(parseBoolFlag('falso'), isFalse);
    });

    test('String "TRUE" (uppercase) returns true', () {
      expect(parseBoolFlag('TRUE'), isTrue);
    });

    test('String "FALSE" (uppercase) returns false', () {
      expect(parseBoolFlag('FALSE'), isFalse);
    });

    test('empty string returns defaultValue', () {
      expect(parseBoolFlag(''), isFalse);
      expect(parseBoolFlag('', defaultValue: true), isTrue);
    });

    test('whitespace-only string returns defaultValue', () {
      expect(parseBoolFlag('   '), isFalse);
    });

    test('unrecognized string returns defaultValue', () {
      expect(parseBoolFlag('maybe'), isFalse);
      expect(parseBoolFlag('maybe', defaultValue: true), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('canonicalMuscleGroup', () {
    test('empty string returns other', () {
      expect(canonicalMuscleGroup(''), 'other');
    });

    test('"other" returns other', () {
      expect(canonicalMuscleGroup('other'), 'other');
    });

    test('"altro" (Italian) returns other', () {
      expect(canonicalMuscleGroup('altro'), 'other');
    });

    test('"back" returns back', () {
      expect(canonicalMuscleGroup('back'), 'back');
    });

    test('"dorso" returns back', () {
      expect(canonicalMuscleGroup('dorso'), 'back');
    });

    test('"schiena" returns back', () {
      expect(canonicalMuscleGroup('schiena'), 'back');
    });

    test('"lat" partial returns back', () {
      expect(canonicalMuscleGroup('latissimus'), 'back');
    });

    test('"trapez" partial returns back', () {
      expect(canonicalMuscleGroup('trapezio'), 'back');
    });

    test('"chest" returns chest', () {
      expect(canonicalMuscleGroup('chest'), 'chest');
    });

    test('"petto" returns chest', () {
      expect(canonicalMuscleGroup('petto'), 'chest');
    });

    test('"pector" partial returns chest', () {
      expect(canonicalMuscleGroup('pectoralis'), 'chest');
    });

    test('"legs" returns legs', () {
      expect(canonicalMuscleGroup('legs'), 'legs');
    });

    test('"gamb" partial returns legs', () {
      expect(canonicalMuscleGroup('gambe'), 'legs');
    });

    test('"quad" partial returns legs', () {
      expect(canonicalMuscleGroup('quadricipiti'), 'legs');
    });

    test('"hamstring" returns legs', () {
      expect(canonicalMuscleGroup('hamstring'), 'legs');
    });

    test('"polpacc" partial returns legs (calves)', () {
      expect(canonicalMuscleGroup('polpaccio'), 'legs');
    });

    test('"calf" returns legs', () {
      expect(canonicalMuscleGroup('calf'), 'legs');
    });

    test('"glute" partial returns glutes', () {
      expect(canonicalMuscleGroup('glutei'), 'glutes');
    });

    test('"shoulders" returns shoulders', () {
      expect(canonicalMuscleGroup('shoulders'), 'shoulders');
    });

    test('"spall" partial returns shoulders', () {
      expect(canonicalMuscleGroup('spalle'), 'shoulders');
    });

    test('"delt" partial returns shoulders', () {
      expect(canonicalMuscleGroup('deltoids'), 'shoulders');
    });

    test('"arms" returns arms', () {
      expect(canonicalMuscleGroup('arms'), 'arms');
    });

    test('"bracc" partial returns arms', () {
      expect(canonicalMuscleGroup('braccia'), 'arms');
    });

    test('"bicip" partial returns arms', () {
      expect(canonicalMuscleGroup('bicipiti'), 'arms');
    });

    test('"tricip" partial returns arms', () {
      expect(canonicalMuscleGroup('tricipiti'), 'arms');
    });

    test('"avambr" partial returns arms (forearms)', () {
      expect(canonicalMuscleGroup('avambraccio'), 'arms');
    });

    test('"core" returns core', () {
      expect(canonicalMuscleGroup('core'), 'core');
    });

    test('"addom" partial returns core', () {
      expect(canonicalMuscleGroup('addominali'), 'core');
    });

    test('"abs" returns core', () {
      expect(canonicalMuscleGroup('abs'), 'core');
    });

    test('"obliqu" partial returns core', () {
      expect(canonicalMuscleGroup('obliqui'), 'core');
    });

    test('"lomb" partial returns core (lower back)', () {
      expect(canonicalMuscleGroup('lombari'), 'core');
    });

    test('"full body" returns full_body', () {
      expect(canonicalMuscleGroup('full body'), 'full_body');
    });

    test('is case-insensitive', () {
      expect(canonicalMuscleGroup('CHEST'), 'chest');
    });

    test('trims whitespace', () {
      expect(canonicalMuscleGroup('  back  '), 'back');
    });

    test('returns other for completely unknown value', () {
      expect(canonicalMuscleGroup('unknown_muscle'), 'other');
    });
  });

  // -------------------------------------------------------------------------
  group('muscleGroupLabel', () {
    test('back returns dorso', () {
      expect(muscleGroupLabel('back'), 'dorso');
    });

    test('chest returns petto', () {
      expect(muscleGroupLabel('chest'), 'petto');
    });

    test('legs returns gambe', () {
      expect(muscleGroupLabel('legs'), 'gambe');
    });

    test('glutes returns glutei', () {
      expect(muscleGroupLabel('glutes'), 'glutei');
    });

    test('shoulders returns spalle', () {
      expect(muscleGroupLabel('shoulders'), 'spalle');
    });

    test('arms returns braccia', () {
      expect(muscleGroupLabel('arms'), 'braccia');
    });

    test('core returns core', () {
      expect(muscleGroupLabel('core'), 'core');
    });

    test('full_body returns full body', () {
      expect(muscleGroupLabel('full_body'), 'full body');
    });

    test('recovery returns recupero attivo', () {
      expect(muscleGroupLabel('recovery'), 'recupero attivo');
    });

    test('unknown canonical returns the input unchanged', () {
      expect(muscleGroupLabel('unknown_key'), 'unknown_key');
    });
  });

  // -------------------------------------------------------------------------
  group('searchQueryForMuscle', () {
    test('back returns schiena', () {
      expect(searchQueryForMuscle('back'), 'schiena');
    });

    test('chest returns petto', () {
      expect(searchQueryForMuscle('chest'), 'petto');
    });

    test('legs returns gambe', () {
      expect(searchQueryForMuscle('legs'), 'gambe');
    });

    test('glutes returns glutei', () {
      expect(searchQueryForMuscle('glutes'), 'glutei');
    });

    test('shoulders returns spalle', () {
      expect(searchQueryForMuscle('shoulders'), 'spalle');
    });

    test('arms returns braccia', () {
      expect(searchQueryForMuscle('arms'), 'braccia');
    });

    test('core returns addome', () {
      expect(searchQueryForMuscle('core'), 'addome');
    });

    test('full_body returns full body', () {
      expect(searchQueryForMuscle('full_body'), 'full body');
    });

    test('unknown canonical returns the input unchanged', () {
      expect(searchQueryForMuscle('other'), 'other');
    });
  });

  // -------------------------------------------------------------------------
  group('encodeToolError', () {
    test('returns valid JSON string', () {
      final result = encodeToolError('something went wrong', 'myTool');
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('encoded JSON contains error field', () {
      final result = encodeToolError('oops', 'myTool');
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['error'], 'oops');
    });

    test('encoded JSON contains toolName field', () {
      final result = encodeToolError('oops', 'myTool');
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['toolName'], 'myTool');
    });

    test('handles empty error message', () {
      final result = encodeToolError('', 'tool');
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['error'], '');
    });

    test('handles special characters in error message', () {
      final result = encodeToolError('error: "quotes" and \'apostrophes\'', 't');
      expect(() => jsonDecode(result), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  group('majorMuscleGroups constant', () {
    test('contains expected canonical groups', () {
      expect(majorMuscleGroups, containsAll(['chest', 'back', 'legs']));
      expect(
        majorMuscleGroups,
        containsAll(['shoulders', 'arms', 'core', 'glutes']),
      );
    });

    test('contains exactly 7 groups', () {
      expect(majorMuscleGroups.length, 7);
    });
  });

  // -------------------------------------------------------------------------
  group('documentSearchCacheTtl constant', () {
    test('is 10 minutes', () {
      expect(documentSearchCacheTtl, const Duration(minutes: 10));
    });
  });
}
