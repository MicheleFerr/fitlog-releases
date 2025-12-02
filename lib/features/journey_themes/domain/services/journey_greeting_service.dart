/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/domain/services
/// Feature: Journey Themes Gamification
/// Type: Service
///
/// Provides personalized time-based greetings with theme-specific
/// motivational phrases.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Time of day categories for greetings
enum TimeOfDay {
  morning,   // 5:00 - 11:59
  afternoon, // 12:00 - 17:59
  evening,   // 18:00 - 21:59
  night,     // 22:00 - 4:59
}

/// Service for generating personalized journey theme greetings
class JourneyGreetingService {
  JourneyGreetingService._();

  static final _random = Random();

  /// Get current time of day
  static TimeOfDay getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return TimeOfDay.morning;
    } else if (hour >= 12 && hour < 18) {
      return TimeOfDay.afternoon;
    } else if (hour >= 18 && hour < 22) {
      return TimeOfDay.evening;
    } else {
      return TimeOfDay.night;
    }
  }

  /// Get localized time greeting (Buongiorno, Buonpomeriggio, etc.)
  static String getTimeGreeting(BuildContext context, TimeOfDay timeOfDay) {
    final l10n = AppLocalizations.of(context);
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return l10n.greetingMorning;
      case TimeOfDay.afternoon:
        return l10n.greetingAfternoon;
      case TimeOfDay.evening:
        return l10n.greetingEvening;
      case TimeOfDay.night:
        return l10n.greetingNight;
    }
  }

  /// Get a random motivational phrase for the theme and time of day
  static String getMotivationalPhrase(
    BuildContext context,
    JourneyTheme theme,
    TimeOfDay timeOfDay,
  ) {
    final l10n = AppLocalizations.of(context);
    final phrases = _getPhrasesForThemeAndTime(l10n, theme, timeOfDay);
    return phrases[_random.nextInt(phrases.length)];
  }

  /// Get all phrases for a specific theme and time of day
  static List<String> _getPhrasesForThemeAndTime(
    AppLocalizations l10n,
    JourneyTheme theme,
    TimeOfDay timeOfDay,
  ) {
    switch (theme) {
      case JourneyTheme.hero:
        return _getHeroPhrases(l10n, timeOfDay);
      case JourneyTheme.hunter:
        return _getHunterPhrases(l10n, timeOfDay);
      case JourneyTheme.warriorGoddess:
        return _getWarriorGoddessPhrases(l10n, timeOfDay);
      case JourneyTheme.natureSpirit:
        return _getNatureSpiritPhrases(l10n, timeOfDay);
      case JourneyTheme.phoenix:
        return _getPhoenixPhrases(l10n, timeOfDay);
      case JourneyTheme.frost:
        return _getFrostPhrases(l10n, timeOfDay);
    }
  }

  /// Hero theme phrases
  static List<String> _getHeroPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.heroMorning1,
          l10n.heroMorning2,
          l10n.heroMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.heroAfternoon1,
          l10n.heroAfternoon2,
          l10n.heroAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.heroEvening1,
          l10n.heroEvening2,
          l10n.heroEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.heroNight1,
          l10n.heroNight2,
          l10n.heroNight3,
        ];
    }
  }

  /// Hunter theme phrases
  static List<String> _getHunterPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.hunterMorning1,
          l10n.hunterMorning2,
          l10n.hunterMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.hunterAfternoon1,
          l10n.hunterAfternoon2,
          l10n.hunterAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.hunterEvening1,
          l10n.hunterEvening2,
          l10n.hunterEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.hunterNight1,
          l10n.hunterNight2,
          l10n.hunterNight3,
        ];
    }
  }

  /// Warrior Goddess theme phrases
  static List<String> _getWarriorGoddessPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.warriorGoddessMorning1,
          l10n.warriorGoddessMorning2,
          l10n.warriorGoddessMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.warriorGoddessAfternoon1,
          l10n.warriorGoddessAfternoon2,
          l10n.warriorGoddessAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.warriorGoddessEvening1,
          l10n.warriorGoddessEvening2,
          l10n.warriorGoddessEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.warriorGoddessNight1,
          l10n.warriorGoddessNight2,
          l10n.warriorGoddessNight3,
        ];
    }
  }

  /// Nature Spirit theme phrases
  static List<String> _getNatureSpiritPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.natureSpiritMorning1,
          l10n.natureSpiritMorning2,
          l10n.natureSpiritMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.natureSpiritAfternoon1,
          l10n.natureSpiritAfternoon2,
          l10n.natureSpiritAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.natureSpiritEvening1,
          l10n.natureSpiritEvening2,
          l10n.natureSpiritEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.natureSpiritNight1,
          l10n.natureSpiritNight2,
          l10n.natureSpiritNight3,
        ];
    }
  }

  /// Phoenix theme phrases
  static List<String> _getPhoenixPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.phoenixMorning1,
          l10n.phoenixMorning2,
          l10n.phoenixMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.phoenixAfternoon1,
          l10n.phoenixAfternoon2,
          l10n.phoenixAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.phoenixEvening1,
          l10n.phoenixEvening2,
          l10n.phoenixEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.phoenixNight1,
          l10n.phoenixNight2,
          l10n.phoenixNight3,
        ];
    }
  }

  /// Frost theme phrases
  static List<String> _getFrostPhrases(AppLocalizations l10n, TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          l10n.frostMorning1,
          l10n.frostMorning2,
          l10n.frostMorning3,
        ];
      case TimeOfDay.afternoon:
        return [
          l10n.frostAfternoon1,
          l10n.frostAfternoon2,
          l10n.frostAfternoon3,
        ];
      case TimeOfDay.evening:
        return [
          l10n.frostEvening1,
          l10n.frostEvening2,
          l10n.frostEvening3,
        ];
      case TimeOfDay.night:
        return [
          l10n.frostNight1,
          l10n.frostNight2,
          l10n.frostNight3,
        ];
    }
  }

  /// Get full personalized greeting
  /// Example: "Buongiorno Hero, andiamo a distruggere i pesi cattivi!"
  static String getFullGreeting(
    BuildContext context,
    JourneyTheme theme,
    String name,
  ) {
    final timeOfDay = getCurrentTimeOfDay();
    final timeGreeting = getTimeGreeting(context, timeOfDay);
    final phrase = getMotivationalPhrase(context, theme, timeOfDay);

    return '$timeGreeting $name, $phrase';
  }
}
