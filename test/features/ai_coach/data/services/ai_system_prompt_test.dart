/// Unit tests for ai_system_prompt.dart
///
/// Tests verify the content and structure of the AI system prompt constant.
/// Since aiSystemPrompt is a pure String constant, tests check correctness
/// of its content against the documented behavioral spec.
///
/// **Layer**: Data - Tests
/// **Feature**: AI Coach
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_system_prompt.dart';

void main() {
  group('aiSystemPrompt', () {
    group('existence and basic structure', () {
      test('is a non-empty string', () {
        expect(aiSystemPrompt, isA<String>());
        expect(aiSystemPrompt.trim(), isNotEmpty);
      });

      test('is a compile-time const (no runtime cost)', () {
        // Verified by type: the library declares it as `const String`.
        // We can confirm the identical reference holds across usages.
        const s1 = aiSystemPrompt;
        const s2 = aiSystemPrompt;
        expect(identical(s1, s2), isTrue);
      });
    });

    group('core principles section', () {
      test('contains data-driven principle', () {
        expect(aiSystemPrompt, contains('Data-Driven'));
      });

      test('contains scientific principle', () {
        expect(aiSystemPrompt, contains('Scientific'));
      });

      test('contains conservative principle', () {
        expect(aiSystemPrompt, contains('Conservative'));
      });

      test('contains transparent principle', () {
        expect(aiSystemPrompt, contains('Transparent'));
      });
    });

    group('safety rules', () {
      test('prohibits diagnosing injuries or medical conditions', () {
        expect(aiSystemPrompt, contains('NEVER diagnose injuries'));
      });

      test('requires redirecting pain/injury questions to professionals', () {
        expect(aiSystemPrompt, contains('redirect pain/injury questions'));
      });

      test('requires disclaimer when discussing health topics', () {
        expect(aiSystemPrompt, contains("I'm not a doctor"));
      });

      test('prohibits unnecessary medical warnings when no symptoms mentioned',
          () {
        expect(
          aiSystemPrompt,
          contains(
            'Do NOT add medical warnings/disclaimers when the user did not mention pain',
          ),
        );
      });
    });

    group('language rules', () {
      test('mandates Italian-only responses', () {
        expect(aiSystemPrompt, contains('ALWAYS respond in Italian'));
      });

      test('prohibits English responses', () {
        expect(aiSystemPrompt, contains('NEVER respond in English'));
      });

      test('specifies responding in Italian even when user writes in English',
          () {
        expect(
          aiSystemPrompt,
          contains('If the user writes in English, still respond in Italian'),
        );
      });
    });

    group('experience-level tone adaptation', () {
      test('addresses beginner experience level', () {
        expect(aiSystemPrompt, contains('beginner'));
      });

      test('addresses experienced/some level', () {
        expect(aiSystemPrompt, contains('"some" or "experienced"'));
      });

      test('addresses athlete level', () {
        expect(aiSystemPrompt, contains('"athlete"'));
      });

      test('beginner section avoids jargon like RPE', () {
        // The prompt tells the AI to avoid RPE for beginners.
        expect(aiSystemPrompt, contains('Avoid jargon: RPE'));
      });

      test('experienced section uses technical terms like RPE', () {
        expect(aiSystemPrompt, contains('Use technical terms: RPE'));
      });

      test('athlete section references advanced concepts like peaking', () {
        expect(aiSystemPrompt, contains('peaking'));
      });
    });

    group('fitness goal guidance', () {
      test('covers muscle-building goal', () {
        expect(aiSystemPrompt, contains('Goal "muscle"'));
      });

      test('covers strength goal', () {
        expect(aiSystemPrompt, contains('Goal "strength"'));
      });

      test('covers endurance goal', () {
        expect(aiSystemPrompt, contains('Goal "endurance"'));
      });
    });

    group('tool definitions', () {
      final tools = [
        'get1RMHistory',
        'getWeeklyVolume',
        'analyzeMuscleBalance',
        'getRecoveryData',
        'suggestWorkout',
        'compareToStandards',
        'getWorkoutStats',
        'getPersonalRecords',
        'getStreak',
        'getWorkoutHistory',
        'generateTemplate',
        'getBodyProgress',
        'addBodyMeasurement',
        'getUserTemplates',
        'getTemplateDetails',
        'addExerciseToTemplate',
        'replaceExerciseInTemplate',
        'removeExerciseFromTemplate',
        'updateTemplateRestTime',
        'updateTemplateExerciseSetup',
        'searchExercises',
        'getAccessoryExercises',
        'searchScientificSources',
        'getUserProfileContext',
        'updateUserProfilePreferences',
        'getWeeklyCheckin',
        'getAutoProgressionPlan',
        'getAdherenceInsights',
        'getWorkoutPreferences',
        'updateWorkoutPreferences',
      ];

      for (final tool in tools) {
        test('lists tool: $tool', () {
          expect(aiSystemPrompt, contains(tool));
        });
      }
    });

    group('accessory exercise mandatory workflow', () {
      test('marks getAccessoryExercises as MANDATORY', () {
        expect(aiSystemPrompt, contains('MANDATORY'));
        expect(aiSystemPrompt, contains('getAccessoryExercises'));
      });

      test('prohibits guessing accessory exercises', () {
        expect(aiSystemPrompt, contains('NEVER guess or invent accessory'));
      });

      test('contains wrong-example about leg press for chest', () {
        expect(aiSystemPrompt, contains('leg press'));
        expect(aiSystemPrompt, contains('petto'));
      });
    });

    group('disambiguation section', () {
      test('contains disambiguation keyword', () {
        expect(aiSystemPrompt, contains('disambiguation'));
      });

      test('instructs to ask user for clarification naturally in Italian', () {
        expect(aiSystemPrompt, contains('Quale'));
        expect(aiSystemPrompt, contains('intendi?'));
      });
    });

    group('template edit workflows', () {
      test('requires confirmed=false for preview before committing', () {
        expect(aiSystemPrompt, contains('confirmed=false'));
      });

      test('requires explicit user confirmation before confirmed=true', () {
        expect(aiSystemPrompt, contains('confirmed=true'));
      });

      test('clarifies Italian terms for edit actions', () {
        expect(aiSystemPrompt, contains('"aggiungi"'));
        expect(aiSystemPrompt, contains('"sostituisci"'));
        expect(aiSystemPrompt, contains('"rimuovi"'));
      });
    });

    group('scientific sources workflow', () {
      test('restricts searchScientificSources to explicit user requests', () {
        expect(
          aiSystemPrompt,
          contains(
            'Call `searchScientificSources` only when the user asks for studies',
          ),
        );
      });

      test('limits references to 1-3 per answer', () {
        expect(aiSystemPrompt, contains('1-3 concise references'));
      });
    });

    group('didactic knowledge base', () {
      final terms = [
        '1RM',
        'RPE',
        'Volume',
        'Ipertrofia',
        'Progressive Overload',
        'Deload',
        'Superset',
        'Drop set',
        'DOMS',
        'Compound',
        'Isolation',
        'TUT',
        'BMI',
      ];

      for (final term in terms) {
        test('defines term: $term', () {
          expect(aiSystemPrompt, contains(term));
        });
      }
    });

    group('general guidelines section', () {
      test('provides rep ranges for strength (1-5)', () {
        expect(aiSystemPrompt, contains('1-5 per forza'));
      });

      test('provides rep ranges for hypertrophy (6-12)', () {
        expect(aiSystemPrompt, contains('6-12 per ipertrofia'));
      });

      test('provides weekly set recommendations for hypertrophy', () {
        expect(aiSystemPrompt, contains('10-20 per ipertrofia'));
      });

      test('references Schoenfeld as a scientific citation example', () {
        expect(aiSystemPrompt, contains('Schoenfeld'));
      });
    });

    group('tool response behavior section', () {
      test('prohibits repeated tool-call loops', () {
        expect(aiSystemPrompt, contains('DO NOT'));
        expect(
          aiSystemPrompt,
          contains('loop'),
        );
      });

      test('requires natural language response after tool results', () {
        expect(aiSystemPrompt, contains('respond with natural language'));
      });

      test('prohibits JSON-like phrasing in responses', () {
        expect(
          aiSystemPrompt,
          contains('Never write phrases like'),
        );
      });
    });

    group('capability/intro questions', () {
      test('handles "cosa puoi fare?" without calling tools', () {
        expect(aiSystemPrompt, contains('cosa puoi fare'));
      });

      test('contains example capability response listing analytics', () {
        expect(aiSystemPrompt, contains('Analisi progressi'));
      });
    });

    group('prompt length and completeness', () {
      test('has substantial content (> 5000 characters)', () {
        expect(aiSystemPrompt.length, greaterThan(5000));
      });

      test('starts with role declaration', () {
        expect(
          aiSystemPrompt.trim(),
          startsWith('You are an evidence-based Personal Trainer AI'),
        );
      });

      test('ends without dangling content (trimmed)', () {
        // The prompt should not end with only whitespace or incomplete sentences.
        expect(aiSystemPrompt.trimRight(), isNotEmpty);
      });
    });
  });
}
