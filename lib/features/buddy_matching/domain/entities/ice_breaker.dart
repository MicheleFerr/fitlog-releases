/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ice_breaker.freezed.dart';
part 'ice_breaker.g.dart';

/// Categories for ice breaker messages
enum IceBreakerCategory {
  workout,
  motivation,
  fitness,
  goals,
  experience,
  casual;

  String get displayName {
    switch (this) {
      case IceBreakerCategory.workout:
        return 'Allenamento';
      case IceBreakerCategory.motivation:
        return 'Motivazione';
      case IceBreakerCategory.fitness:
        return 'Fitness';
      case IceBreakerCategory.goals:
        return 'Obiettivi';
      case IceBreakerCategory.experience:
        return 'Esperienza';
      case IceBreakerCategory.casual:
        return 'Casual';
    }
  }

  String get emoji {
    switch (this) {
      case IceBreakerCategory.workout:
        return '💪';
      case IceBreakerCategory.motivation:
        return '🔥';
      case IceBreakerCategory.fitness:
        return '🏋️‍♂️';
      case IceBreakerCategory.goals:
        return '🎯';
      case IceBreakerCategory.experience:
        return '⭐';
      case IceBreakerCategory.casual:
        return '😊';
    }
  }
}

@freezed
class IceBreaker with _$IceBreaker {
  const factory IceBreaker({
    required String id,
    required String messageTemplate,
    required IceBreakerCategory category,
    @Default([]) List<String> tags,
    @Default(true) bool isActive,
    @Default(0) int usageCount,
  }) = _IceBreaker;

  factory IceBreaker.fromJson(Map<String, dynamic> json) =>
      _$IceBreakerFromJson(json);

  factory IceBreaker.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IceBreaker.fromJson(data);
  }
}

/// Predefined ice breaker messages for GymBro
class IceBreakers {
  static const List<IceBreaker> predefinedMessages = [
    // Workout related
    IceBreaker(
      id: 'workout_1',
      messageTemplate: 'Che tipo di allenamento fai di solito? Io amo {workout_type}! 💪',
      category: IceBreakerCategory.workout,
      tags: ['workout', 'training'],
    ),
    IceBreaker(
      id: 'workout_2', 
      messageTemplate: 'Mi piacerebbe trovare qualcuno con cui allenarmi! Tu che orari preferisci?',
      category: IceBreakerCategory.workout,
      tags: ['schedule', 'partner'],
    ),
    IceBreaker(
      id: 'workout_3',
      messageTemplate: 'Che palestra frequenti? Magari siamo nella stessa zona! 🏋️‍♂️',
      category: IceBreakerCategory.workout,
      tags: ['gym', 'location'],
    ),
    
    // Motivation related
    IceBreaker(
      id: 'motivation_1',
      messageTemplate: 'Cosa ti motiva di più durante gli allenamenti? 🔥',
      category: IceBreakerCategory.motivation,
      tags: ['motivation', 'mindset'],
    ),
    IceBreaker(
      id: 'motivation_2',
      messageTemplate: 'Hai mai avuto giornate no in palestra? Come le superi?',
      category: IceBreakerCategory.motivation,
      tags: ['motivation', 'challenges'],
    ),
    IceBreaker(
      id: 'motivation_3',
      messageTemplate: 'La musica giusta fa tutta la differenza! Che genere ascolti in palestra? 🎵',
      category: IceBreakerCategory.motivation,
      tags: ['music', 'motivation'],
    ),

    // Fitness related  
    IceBreaker(
      id: 'fitness_1',
      messageTemplate: 'Da quanto tempo ti alleni? Io ho iniziato da {time_period}!',
      category: IceBreakerCategory.fitness,
      tags: ['experience', 'timeline'],
    ),
    IceBreaker(
      id: 'fitness_2',
      messageTemplate: 'Qual è stato il tuo più grande traguardo fitness finora? 🏆',
      category: IceBreakerCategory.fitness,
      tags: ['achievement', 'progress'],
    ),
    IceBreaker(
      id: 'fitness_3',
      messageTemplate: 'Preferisci allenarmi al mattino o alla sera? Io sono del team {time_preference}!',
      category: IceBreakerCategory.fitness,
      tags: ['schedule', 'preference'],
    ),

    // Goals related
    IceBreaker(
      id: 'goals_1',
      messageTemplate: 'Qual è il tuo obiettivo fitness per questanno? 🎯',
      category: IceBreakerCategory.goals,
      tags: ['goals', 'future'],
    ),
    IceBreaker(
      id: 'goals_2',
      messageTemplate: 'Stai lavorando su qualche obiettivo particolare in questo periodo?',
      category: IceBreakerCategory.goals,
      tags: ['goals', 'current'],
    ),
    IceBreaker(
      id: 'goals_3',
      messageTemplate: 'Credi nell\'importanza di avere un workout buddy per raggiungere i propri goal?',
      category: IceBreakerCategory.goals,
      tags: ['partnership', 'goals'],
    ),

    // Experience related
    IceBreaker(
      id: 'experience_1',
      messageTemplate: 'Hai mai fatto gare o competizioni? Mi piacerebbe saperne di più! ⭐',
      category: IceBreakerCategory.experience,
      tags: ['competition', 'experience'],
    ),
    IceBreaker(
      id: 'experience_2',
      messageTemplate: 'Quale esercizio odi di più ma sai che è fondamentale? 😅',
      category: IceBreakerCategory.experience,
      tags: ['exercises', 'humor'],
    ),
    IceBreaker(
      id: 'experience_3',
      messageTemplate: 'Hai qualche consiglio per un esercizio che vedo che fai spesso?',
      category: IceBreakerCategory.experience,
      tags: ['advice', 'learning'],
    ),

    // Casual related
    IceBreaker(
      id: 'casual_1',
      messageTemplate: 'Ciao! Mi piace il tuo profilo, sembra che abbiamo obiettivi simili! 😊',
      category: IceBreakerCategory.casual,
      tags: ['greeting', 'compatibility'],
    ),
    IceBreaker(
      id: 'casual_2',
      messageTemplate: 'Hey! Che ne dici di scambiarci qualche consiglio per l\'allenamento?',
      category: IceBreakerCategory.casual,
      tags: ['casual', 'advice'],
    ),
    IceBreaker(
      id: 'casual_3',
      messageTemplate: 'Ciao! Stavo guardando il tuo profilo e mi sembri una persona motivata! 💪',
      category: IceBreakerCategory.casual,
      tags: ['compliment', 'motivation'],
    ),
  ];

  /// Get ice breakers by category
  static List<IceBreaker> getByCategory(IceBreakerCategory category) {
    return predefinedMessages
        .where((iceBreaker) => iceBreaker.category == category)
        .toList();
  }

  /// Get random ice breaker from category
  static IceBreaker? getRandomByCategory(IceBreakerCategory category) {
    final categoryMessages = getByCategory(category);
    if (categoryMessages.isEmpty) return null;
    
    categoryMessages.shuffle();
    return categoryMessages.first;
  }

  /// Get most popular ice breakers
  static List<IceBreaker> getMostPopular({int limit = 5}) {
    final sorted = List<IceBreaker>.from(predefinedMessages);
    sorted.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }

  /// Search ice breakers by text
  static List<IceBreaker> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return predefinedMessages
        .where((iceBreaker) =>
            iceBreaker.messageTemplate.toLowerCase().contains(lowercaseQuery) ||
            iceBreaker.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  /// Get suggested ice breakers based on user compatibility
  static List<IceBreaker> getSuggested({
    required List<String> commonGoals,
    required List<String> commonTimes,
    int limit = 3,
  }) {
    List<IceBreaker> suggested = [];

    // If they have common workout goals, suggest goal-related messages
    if (commonGoals.isNotEmpty) {
      suggested.addAll(getByCategory(IceBreakerCategory.goals));
    }

    // If they have common workout times, suggest workout-related messages  
    if (commonTimes.isNotEmpty) {
      suggested.addAll(getByCategory(IceBreakerCategory.workout));
    }

    // Always include some casual options
    suggested.addAll(getByCategory(IceBreakerCategory.casual));

    // Remove duplicates and shuffle
    suggested = suggested.toSet().toList();
    suggested.shuffle();

    return suggested.take(limit).toList();
  }
}