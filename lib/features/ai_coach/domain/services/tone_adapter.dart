/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/services
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// Tone Adapter - Adapts chatbot tone based on user profile (Phase 3.2)
///
/// **Features**:
/// - Adaptive tone based on experience level (beginner/intermediate/advanced)
/// - Goal-specific vocabulary and focus
/// - Personality traits (encouraging vs concise)
/// - Contextual tone adjustments
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Fitness goal type
enum FitnessGoal {
  muscleBuilding,
  strength,
  generalFitness,
  weightLoss,
  endurance,
}

/// Tone profile configuration
class ToneProfile { // Uses technical fitness terminology

  const ToneProfile({
    required this.experienceLevel,
    this.primaryGoal,
    this.isEncouraging = true,
    this.isDetailed = true,
    this.isTechnical = false,
  });
  final ExperienceLevel experienceLevel;
  final FitnessGoal? primaryGoal;
  final bool isEncouraging; // More motivational language
  final bool isDetailed; // Longer, more detailed responses
  final bool isTechnical;

  /// Default tone profile for new users
  static const ToneProfile defaultProfile = ToneProfile(
    experienceLevel: ExperienceLevel.beginner,
    primaryGoal: FitnessGoal.generalFitness,
    isEncouraging: true,
    isDetailed: true,
    isTechnical: false,
  );

  /// Beginner-friendly tone
  static const ToneProfile beginnerProfile = ToneProfile(
    experienceLevel: ExperienceLevel.beginner,
    isEncouraging: true,
    isDetailed: true,
    isTechnical: false,
  );

  /// Intermediate user tone
  static const ToneProfile intermediateProfile = ToneProfile(
    experienceLevel: ExperienceLevel.intermediate,
    isEncouraging: true,
    isDetailed: true,
    isTechnical: true,
  );

  /// Advanced user tone
  static const ToneProfile advancedProfile = ToneProfile(
    experienceLevel: ExperienceLevel.advanced,
    isEncouraging: false,
    isDetailed: false,
    isTechnical: true,
  );
}

/// Tone adapter service
class ToneAdapter {
  /// Get tone-adapted system prompt suffix
  ///
  /// This suffix is appended to the base system prompt to adapt the chatbot's
  /// tone based on user profile.
  String getTonePromptSuffix(ToneProfile profile) {
    final buffer = StringBuffer();

    // Experience level instructions
    buffer.writeln('\n\n**Tone Adaptation:**');
    switch (profile.experienceLevel) {
      case ExperienceLevel.beginner:
        buffer.writeln(
          '- User is a BEGINNER. Use simple language, explain concepts clearly, '
          'be encouraging and patient. Avoid jargon unless you explain it.',
        );
        break;
      case ExperienceLevel.intermediate:
        buffer.writeln(
          '- User is INTERMEDIATE. Balance technical and simple language. '
          'Assume basic fitness knowledge but still explain advanced concepts.',
        );
        break;
      case ExperienceLevel.advanced:
        buffer.writeln(
          '- User is ADVANCED. Use technical terminology freely. '
          'Be concise and assume deep fitness knowledge. Focus on optimization.',
        );
        break;
    }

    // Goal-specific focus
    if (profile.primaryGoal != null) {
      buffer.write('- Primary goal: ');
      switch (profile.primaryGoal!) {
        case FitnessGoal.muscleBuilding:
          buffer.writeln(
            'MUSCLE BUILDING (hypertrophy). Emphasize volume, progressive overload, '
            'time under tension, and nutrition for growth.',
          );
          break;
        case FitnessGoal.strength:
          buffer.writeln(
            'STRENGTH TRAINING. Focus on compound movements, low rep ranges (1-5), '
            'CNS adaptation, and powerlifting principles.',
          );
          break;
        case FitnessGoal.generalFitness:
          buffer.writeln(
            'GENERAL FITNESS. Balanced approach covering strength, cardio, flexibility. '
            'Focus on sustainable habits and overall health.',
          );
          break;
        case FitnessGoal.weightLoss:
          buffer.writeln(
            'WEIGHT LOSS. Emphasize caloric deficit, sustainable nutrition, '
            'metabolic health, and combining cardio with resistance training.',
          );
          break;
        case FitnessGoal.endurance:
          buffer.writeln(
            'ENDURANCE TRAINING. Focus on aerobic capacity, VO2 max, pacing, '
            'and progressive overload for distance/time.',
          );
          break;
      }
    }

    // Personality traits
    if (profile.isEncouraging) {
      buffer.writeln(
        '- Be ENCOURAGING and motivational. Celebrate progress and effort.',
      );
    } else {
      buffer.writeln(
        '- Be DIRECT and concise. User prefers efficiency over encouragement.',
      );
    }

    if (profile.isDetailed) {
      buffer.writeln(
        '- Provide DETAILED explanations with rationale and scientific backing.',
      );
    } else {
      buffer.writeln(
        '- Keep responses CONCISE. Provide key information without extensive detail.',
      );
    }

    if (profile.isTechnical) {
      buffer.writeln(
        '- Use TECHNICAL terminology (e.g., "hypertrophy", "periodization", "CNS adaptation").',
      );
    } else {
      buffer.writeln(
        '- Use SIMPLE terminology. Explain technical terms when necessary.',
      );
    }

    return buffer.toString();
  }

  /// Get example vocabulary based on tone profile
  ///
  /// Returns a map of concept -> adapted term for the user's level
  Map<String, String> getVocabulary(ToneProfile profile) {
    switch (profile.experienceLevel) {
      case ExperienceLevel.beginner:
        return {
          'hypertrophy': 'muscle growth',
          'progressive overload': 'gradually increasing weight/reps',
          'CNS': 'nervous system',
          'periodization': 'training phases',
          'RPE': 'effort level (1-10 scale)',
          'AMRAP': 'as many reps as possible',
          'superset': 'two exercises back-to-back',
        };

      case ExperienceLevel.intermediate:
        return {
          'CNS': 'central nervous system',
          'periodization': 'structured training cycles',
          'RPE': 'rate of perceived exertion',
          // Uses technical terms but may still explain occasionally
        };

      case ExperienceLevel.advanced:
        return {
          // Uses all technical terms without explanation
        };
    }
  }

  /// Get encouraging phrases based on profile and locale
  ///
  /// **Parameters**:
  /// - `profile`: User's tone profile
  /// - `locale`: Language code ('en' or 'it')
  ///
  /// **Returns**: List of localized encouraging phrases
  List<String> getEncouragingPhrases(ToneProfile profile, {String locale = 'en'}) {
    if (!profile.isEncouraging) {
      return []; // No encouraging phrases for direct/concise tone
    }

    if (locale == 'it') {
      return _getItalianEncouragingPhrases(profile.experienceLevel);
    }
    return _getEnglishEncouragingPhrases(profile.experienceLevel);
  }

  /// Italian encouraging phrases by experience level
  List<String> _getItalianEncouragingPhrases(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return [
          'Ottimo inizio!',
          'Stai andando alla grande!',
          'Ogni ripetizione conta!',
          'Ce la puoi fare!',
          'Continua così!',
          'I progressi richiedono tempo - sii paziente!',
          'Bravissimo!',
          'Forza!',
        ];

      case ExperienceLevel.intermediate:
        return [
          'Progressi solidi!',
          'Continua a spingere!',
          'Sei sulla strada giusta!',
          'Ottimo lavoro!',
          'Prestazione forte!',
        ];

      case ExperienceLevel.advanced:
        return [
          'Esecuzione eccellente.',
          'Ottimo lavoro.',
          'Ben fatto.',
          'Impressionante.',
        ];
    }
  }

  /// English encouraging phrases by experience level
  List<String> _getEnglishEncouragingPhrases(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return [
          'Great start!',
          "You're doing awesome!",
          'Every rep counts!',
          "You've got this!",
          'Keep up the great work!',
          'Progress takes time - be patient!',
        ];

      case ExperienceLevel.intermediate:
        return [
          'Solid progress!',
          'Keep pushing!',
          "You're on the right track!",
          'Nice work!',
          'Strong performance!',
        ];

      case ExperienceLevel.advanced:
        return [
          'Excellent execution.',
          'Strong work.',
          'Well done.',
          'Impressive.',
        ];
    }
  }

  /// Debug log for tone adaptation (development only)
  void logToneAdaptation(ToneProfile profile, String context) {
    if (kDebugMode) {
      debugPrint('🎭 [Tone Adapter] Context: $context');
      debugPrint('   Experience: ${profile.experienceLevel.name}');
      debugPrint('   Goal: ${profile.primaryGoal?.name ?? "none"}');
      debugPrint('   Encouraging: ${profile.isEncouraging}');
      debugPrint('   Detailed: ${profile.isDetailed}');
      debugPrint('   Technical: ${profile.isTechnical}');
    }
  }
}
