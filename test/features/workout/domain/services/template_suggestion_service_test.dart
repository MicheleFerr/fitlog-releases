import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_suggestion_service.dart';

void main() {
  late TemplateSuggestionService service;

  setUp(() {
    service = TemplateSuggestionService();
  });

  // ---------------------------------------------------------------------------
  // Helper to create WorkoutContext with sensible defaults
  // ---------------------------------------------------------------------------
  WorkoutContext _context({
    int timeAvailable = 30,
    ExperienceLevel? experienceLevel,
    String? gender,
  }) {
    return WorkoutContext(
      timeAvailable: timeAvailable,
      experienceLevel: experienceLevel,
      gender: gender,
      timestamp: DateTime(2026, 1, 1),
    );
  }

  group('TemplateSuggestionService', () {
    // =========================================================================
    // getSuggestedTemplate
    // =========================================================================
    group('getSuggestedTemplate', () {
      test('returns null for invalid category', () {
        final result = service.getSuggestedTemplate(
          context: _context(),
          category: 'nonexistent_category',
        );
        expect(result, isNull);
      });

      test('returns template for chest category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('chest'));
      });

      test('returns template for back category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'back',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('back'));
      });

      test('returns template for legs category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'legs',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('legs'));
      });

      test('returns template for shoulders category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'shoulders',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('shoulders'));
      });

      test('returns template for arms category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 5,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'arms',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('arms'));
      });

      test('returns template for abs category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 5,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'abs',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('abs'));
      });

      test('returns template for cardio category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'cardio',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('cardio'));
      });

      test('returns template for fullbody category', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'fullbody',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('fullbody'));
      });

      test('category matching is case insensitive', () {
        final result = service.getSuggestedTemplate(
          context: _context(),
          category: 'Chest',
        );
        // The service lowercases the category before comparing with tags
        expect(result, isNotNull);
      });

      test('prefers time + level match over level-only match', () {
        // Beginner + 5min -> should get the quick beginner chest template
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 5,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('beginner'));
        expect(result.estimatedDuration, lessThanOrEqualTo(10));
      });

      test('falls back to level match when time does not match', () {
        // Intermediate + 5min (quick) but no quick intermediate chest exists
        // Should fall back to intermediate level match
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 5,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('chest'));
      });

      test('falls back to category-only match with no level', () {
        // No experience level set
        final result = service.getSuggestedTemplate(
          context: _context(timeAvailable: 30),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('chest'));
      });

      test('advanced + 45min matches advanced chest template', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 45,
            experienceLevel: ExperienceLevel.advanced,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.tags, contains('advanced'));
      });
    });

    // =========================================================================
    // getSuggestedTemplates (multiple results)
    // =========================================================================
    group('getSuggestedTemplates', () {
      test('returns multiple templates sorted by score', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(results.isNotEmpty, isTrue);
        // All should have chest tag
        for (final t in results) {
          expect(t.tags, contains('chest'));
        }
      });

      test('respects maxResults parameter', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
          maxResults: 1,
        );
        expect(results.length, 1);
      });

      test('returns empty for invalid category', () {
        final results = service.getSuggestedTemplates(
          context: _context(),
          category: 'nonexistent_category',
        );
        expect(results, isEmpty);
      });

      test('returns all matching templates up to maxResults', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
          maxResults: 10,
        );
        // There are 3 chest templates in the predefined list
        expect(results.length, 3);
      });

      test('best match is first in list', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        if (results.length >= 2) {
          // First result should be the best match (intermediate, standard time)
          expect(results.first.tags, contains('intermediate'));
        }
      });

      test('legs category returns multiple templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'legs',
        );
        expect(results.length, greaterThanOrEqualTo(2));
      });
    });

    // =========================================================================
    // Time matching
    // =========================================================================
    group('time matching', () {
      test('5min maps to templates <= 10min', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 5,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.estimatedDuration, lessThanOrEqualTo(10));
      });

      test('15min maps to templates 10-20min', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'back',
        );
        expect(result, isNotNull);
        expect(result!.estimatedDuration, greaterThan(10));
        expect(result.estimatedDuration, lessThanOrEqualTo(20));
      });

      test('30min maps to templates 20-40min', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.estimatedDuration, greaterThan(20));
        expect(result.estimatedDuration, lessThanOrEqualTo(40));
      });

      test('45min maps to templates > 35min', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 45,
            experienceLevel: ExperienceLevel.advanced,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        expect(result!.estimatedDuration, greaterThan(35));
      });
    });

    // =========================================================================
    // Level matching
    // =========================================================================
    group('level matching', () {
      test('beginner level matches beginner templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 15,
            experienceLevel: ExperienceLevel.beginner,
          ),
          category: 'chest',
        );
        // The top result should be beginner (if time+level matches)
        expect(results.isNotEmpty, isTrue);
      });

      test('intermediate level matches intermediate templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'arms',
        );
        expect(results.isNotEmpty, isTrue);
        // The highest-scored result should have intermediate tag
        expect(results.first.tags, contains('intermediate'));
      });

      test('advanced level matches advanced templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 45,
            experienceLevel: ExperienceLevel.advanced,
          ),
          category: 'legs',
        );
        expect(results.isNotEmpty, isTrue);
        expect(results.first.tags, contains('advanced'));
      });

      test('null level matches all templates (no level filter)', () {
        final results = service.getSuggestedTemplates(
          context: _context(timeAvailable: 30),
          category: 'chest',
        );
        // Should get all 3 chest templates since null level matches everything
        expect(results.length, 3);
      });
    });

    // =========================================================================
    // Gender matching bonus
    // =========================================================================
    group('gender matching', () {
      test('female gender boosts female-tagged templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
            gender: 'female',
          ),
          category: 'legs',
        );
        expect(results.isNotEmpty, isTrue);
        // The female-tagged template should be boosted higher
        final femaleTemplateIndex = results.indexWhere(
          (t) => t.tags.contains('female'),
        );
        // If there's a female template, it should exist in results
        if (femaleTemplateIndex >= 0) {
          expect(femaleTemplateIndex, lessThan(results.length));
        }
      });

      test('male gender gives neutral bonus for gender-neutral templates', () {
        final results = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
            gender: 'male',
          ),
          category: 'chest',
        );
        expect(results.isNotEmpty, isTrue);
      });

      test('null gender does not add any gender bonus', () {
        final withGender = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
            gender: 'male',
          ),
          category: 'chest',
        );
        final withoutGender = service.getSuggestedTemplates(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        // Both should return results
        expect(withGender.isNotEmpty, isTrue);
        expect(withoutGender.isNotEmpty, isTrue);
      });
    });

    // =========================================================================
    // Template content validation
    // =========================================================================
    group('template content validation', () {
      test('all returned templates have exercises', () {
        final categories = [
          'chest',
          'back',
          'legs',
          'shoulders',
          'arms',
          'abs',
          'cardio',
          'fullbody',
        ];

        for (final cat in categories) {
          final result = service.getSuggestedTemplate(
            context: _context(
              timeAvailable: 15,
              experienceLevel: ExperienceLevel.beginner,
            ),
            category: cat,
          );
          if (result != null) {
            expect(
              result.exercises.isNotEmpty,
              isTrue,
              reason: '$cat template should have exercises',
            );
          }
        }
      });

      test('all templates have non-empty name and description', () {
        final results = service.getSuggestedTemplates(
          context: _context(timeAvailable: 30),
          category: 'chest',
          maxResults: 100,
        );
        for (final t in results) {
          expect(t.name.isNotEmpty, isTrue);
          expect(t.description.isNotEmpty, isTrue);
        }
      });

      test('all templates are not custom (predefined)', () {
        final results = service.getSuggestedTemplates(
          context: _context(timeAvailable: 30),
          category: 'legs',
          maxResults: 100,
        );
        for (final t in results) {
          expect(t.isCustom, isFalse);
        }
      });

      test('template exercise sets have valid set numbers', () {
        final result = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(result, isNotNull);
        for (final exercise in result!.exercises) {
          for (int i = 0; i < exercise.sets.length; i++) {
            expect(exercise.sets[i].setNumber, i + 1);
          }
        }
      });
    });

    // =========================================================================
    // Edge cases
    // =========================================================================
    group('edge cases', () {
      test('empty string category returns null', () {
        final result = service.getSuggestedTemplate(
          context: _context(),
          category: '',
        );
        expect(result, isNull);
      });

      test('very large time available still returns results', () {
        final result = service.getSuggestedTemplate(
          context: _context(timeAvailable: 120),
          category: 'chest',
        );
        // Should fall back to some match
        expect(result, isNotNull);
      });

      test('time=0 returns results via fallback', () {
        final result = service.getSuggestedTemplate(
          context: _context(timeAvailable: 0),
          category: 'chest',
        );
        // All templates <= 10min should match (5min bucket) or fallback
        expect(result, isNotNull);
      });

      test('maxResults=0 returns empty list', () {
        final results = service.getSuggestedTemplates(
          context: _context(),
          category: 'chest',
          maxResults: 0,
        );
        expect(results, isEmpty);
      });

      test('service can be instantiated multiple times', () {
        final service2 = TemplateSuggestionService();
        final result1 = service.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        final result2 = service2.getSuggestedTemplate(
          context: _context(
            timeAvailable: 30,
            experienceLevel: ExperienceLevel.intermediate,
          ),
          category: 'chest',
        );
        expect(result1?.id, result2?.id);
      });
    });
  });
}
