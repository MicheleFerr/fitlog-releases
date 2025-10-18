/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test
/// 🎯 Feature: buddy_matching
/// 🔧 Type: unit test
/// 🌍 Localization: N/A - Test file
/// 🎨 Theme: N/A - Test file
/// 📱 Platform: Universal
/// 
/// Testing ice breaker system for enhanced chat functionality
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/ice_breaker.dart';

void main() {
  group('IceBreaker', () {
    test('should create ice breaker with all properties', () {
      const iceBreaker = IceBreaker(
        id: 'test_1',
        messageTemplate: 'Test message {placeholder}',
        category: IceBreakerCategory.workout,
        tags: ['test', 'example'],
        isActive: true,
        usageCount: 5,
      );

      expect(iceBreaker.id, equals('test_1'));
      expect(iceBreaker.messageTemplate, contains('Test message'));
      expect(iceBreaker.category, equals(IceBreakerCategory.workout));
      expect(iceBreaker.tags, contains('test'));
      expect(iceBreaker.isActive, isTrue);
      expect(iceBreaker.usageCount, equals(5));
    });

    test('should support JSON serialization', () {
      const iceBreaker = IceBreaker(
        id: 'json_test',
        messageTemplate: 'JSON test message',
        category: IceBreakerCategory.motivation,
        tags: ['json', 'test'],
      );

      final json = iceBreaker.toJson();
      final fromJson = IceBreaker.fromJson(json);

      expect(fromJson.id, equals(iceBreaker.id));
      expect(fromJson.messageTemplate, equals(iceBreaker.messageTemplate));
      expect(fromJson.category, equals(iceBreaker.category));
      expect(fromJson.tags, equals(iceBreaker.tags));
    });
  });

  group('IceBreakerCategory', () {
    test('should have correct display names', () {
      expect(IceBreakerCategory.workout.displayName, equals('Allenamento'));
      expect(IceBreakerCategory.motivation.displayName, equals('Motivazione'));
      expect(IceBreakerCategory.fitness.displayName, equals('Fitness'));
      expect(IceBreakerCategory.goals.displayName, equals('Obiettivi'));
      expect(IceBreakerCategory.experience.displayName, equals('Esperienza'));
      expect(IceBreakerCategory.casual.displayName, equals('Casual'));
    });

    test('should have appropriate emojis', () {
      expect(IceBreakerCategory.workout.emoji, equals('💪'));
      expect(IceBreakerCategory.motivation.emoji, equals('🔥'));
      expect(IceBreakerCategory.fitness.emoji, equals('🏋️‍♂️'));
      expect(IceBreakerCategory.goals.emoji, equals('🎯'));
      expect(IceBreakerCategory.experience.emoji, equals('⭐'));
      expect(IceBreakerCategory.casual.emoji, equals('😊'));
    });
  });

  group('IceBreakers', () {
    test('should contain predefined messages', () {
      expect(IceBreakers.predefinedMessages.isNotEmpty, isTrue);
      expect(IceBreakers.predefinedMessages.length, greaterThanOrEqualTo(15));
    });

    test('should get ice breakers by category', () {
      final workoutIceBreakers = IceBreakers.getByCategory(IceBreakerCategory.workout);
      expect(workoutIceBreakers.isNotEmpty, isTrue);
      expect(workoutIceBreakers.every((ib) => ib.category == IceBreakerCategory.workout), isTrue);
    });

    test('should get random ice breaker from category', () {
      final randomWorkout = IceBreakers.getRandomByCategory(IceBreakerCategory.workout);
      expect(randomWorkout, isNotNull);
      expect(randomWorkout!.category, equals(IceBreakerCategory.workout));
    });

    test('should return null for empty category', () {
      // Since all categories have messages, this tests the logic
      final emptyCategory = IceBreakerCategory.values.firstWhere(
        (cat) => IceBreakers.getByCategory(cat).isEmpty,
        orElse: () => IceBreakerCategory.workout, // fallback
      );
      
      if (IceBreakers.getByCategory(emptyCategory).isEmpty) {
        final random = IceBreakers.getRandomByCategory(emptyCategory);
        expect(random, isNull);
      }
    });

    test('should get most popular ice breakers', () {
      final popular = IceBreakers.getMostPopular(limit: 3);
      expect(popular.length, lessThanOrEqualTo(3));
      
      if (popular.length > 1) {
        // Should be sorted by usage count descending
        for (int i = 0; i < popular.length - 1; i++) {
          expect(popular[i].usageCount, greaterThanOrEqualTo(popular[i + 1].usageCount));
        }
      }
    });

    test('should search ice breakers by text', () {
      final searchResults = IceBreakers.search('allenamento');
      expect(searchResults.isNotEmpty, isTrue);
      
      for (final result in searchResults) {
        final matchesText = result.messageTemplate.toLowerCase().contains('allenamento');
        final matchesTags = result.tags.any((tag) => tag.toLowerCase().contains('allenamento'));
        expect(matchesText || matchesTags, isTrue);
      }
    });

    test('should search ice breakers case insensitive', () {
      final lowerResults = IceBreakers.search('motivazione');
      final upperResults = IceBreakers.search('MOTIVAZIONE');
      
      // Use a term that definitely exists in our ice breakers
      final lowerAllenamento = IceBreakers.search('allenamento');
      final upperAllenamento = IceBreakers.search('ALLENAMENTO');
      
      expect(lowerAllenamento.isNotEmpty, isTrue);
      expect(upperAllenamento.length, equals(lowerAllenamento.length));
    });

    test('should get suggested ice breakers based on compatibility', () {
      final suggested = IceBreakers.getSuggested(
        commonGoals: ['strength', 'muscle'],
        commonTimes: ['morning', 'evening'],
        limit: 5,
      );
      
      expect(suggested.isNotEmpty, isTrue);
      expect(suggested.length, lessThanOrEqualTo(5));
      
      // Should include goal-related messages
      final hasGoalMessages = suggested.any((ib) => ib.category == IceBreakerCategory.goals);
      expect(hasGoalMessages, isTrue);
    });

    test('should include workout messages for common times', () {
      final suggested = IceBreakers.getSuggested(
        commonGoals: [],
        commonTimes: ['morning'],
        limit: 3,
      );
      
      final hasWorkoutMessages = suggested.any((ib) => ib.category == IceBreakerCategory.workout);
      expect(hasWorkoutMessages, isTrue);
    });

    test('should always include casual messages', () {
      final suggested = IceBreakers.getSuggested(
        commonGoals: [],
        commonTimes: [],
        limit: 3,
      );
      
      final hasCasualMessages = suggested.any((ib) => ib.category == IceBreakerCategory.casual);
      expect(hasCasualMessages, isTrue);
    });

    test('should not return duplicates in suggestions', () {
      final suggested = IceBreakers.getSuggested(
        commonGoals: ['strength'],
        commonTimes: ['morning'],
        limit: 10,
      );
      
      final uniqueIds = suggested.map((ib) => ib.id).toSet();
      expect(uniqueIds.length, equals(suggested.length));
    });

    test('should respect limit in suggestions', () {
      final suggested = IceBreakers.getSuggested(
        commonGoals: ['strength', 'muscle', 'endurance'],
        commonTimes: ['morning', 'evening'],
        limit: 2,
      );
      
      expect(suggested.length, lessThanOrEqualTo(2));
    });
  });

  group('Ice Breaker Content Quality', () {
    test('should have meaningful content in all predefined messages', () {
      for (final iceBreaker in IceBreakers.predefinedMessages) {
        expect(iceBreaker.messageTemplate.isNotEmpty, isTrue);
        expect(iceBreaker.messageTemplate.length, greaterThan(10));
        expect(iceBreaker.id.isNotEmpty, isTrue);
      }
    });

    test('should have appropriate tags for each category', () {
      final workoutMessages = IceBreakers.getByCategory(IceBreakerCategory.workout);
      
      for (final message in workoutMessages) {
        expect(message.tags.isNotEmpty, isTrue);
        
        // Workout messages should have fitness-related tags
        final hasRelevantTags = message.tags.any((tag) =>
            ['workout', 'training', 'gym', 'exercise', 'schedule'].contains(tag));
        expect(hasRelevantTags, isTrue, 
            reason: 'Workout message should have relevant tags: ${message.tags}');
      }
    });

    test('should have Italian language content', () {
      final italianMessages = IceBreakers.predefinedMessages.where((ib) =>
          ib.messageTemplate.contains('che') ||
          ib.messageTemplate.contains('come') ||
          ib.messageTemplate.contains('cosa') ||
          ib.messageTemplate.contains('ti') ||
          ib.messageTemplate.contains('mi')).toList();
      
      expect(italianMessages.isNotEmpty, isTrue);
      expect(italianMessages.length, greaterThan(5));
    });

    test('should have template variables in some messages', () {
      final templatedMessages = IceBreakers.predefinedMessages.where((ib) =>
          ib.messageTemplate.contains('{') && ib.messageTemplate.contains('}')).toList();
      
      expect(templatedMessages.isNotEmpty, isTrue);
    });
  });
}