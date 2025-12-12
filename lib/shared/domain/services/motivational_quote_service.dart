/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/domain/services
/// Feature: Motivational Quotes
/// Type: Service
///
/// Provides daily rotating motivational quotes from a JSON pool.
/// Quotes change daily but remain consistent throughout the day.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

/// Service for loading and providing motivational quotes
///
/// Quotes are loaded from assets/data/motivational_quotes.json
/// and selected based on the day of year for consistency.
class MotivationalQuoteService {
  MotivationalQuoteService._();

  static MotivationalQuoteService? _instance;
  static MotivationalQuoteService get instance {
    _instance ??= MotivationalQuoteService._();
    return _instance!;
  }

  Map<String, List<String>>? _quotes;
  bool _isLoaded = false;

  /// Load quotes from JSON asset
  Future<void> loadQuotes() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/motivational_quotes.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final quotesData = data['quotes'] as Map<String, dynamic>;

      _quotes = {
        'en': List<String>.from(quotesData['en'] as List),
        'it': List<String>.from(quotesData['it'] as List),
      };
      _isLoaded = true;
    } catch (e) {
      // Fallback quotes if loading fails
      _quotes = {
        'en': ['Every rep counts.', 'Stronger than yesterday.', 'Make it happen.'],
        'it': ['Ogni ripetizione conta.', 'Più forte di ieri.', 'Fallo accadere.'],
      };
      _isLoaded = true;
    }
  }

  /// Get the quote of the day for the specified language
  ///
  /// Uses day of year to ensure consistency throughout the day
  /// but variation across days.
  String getQuoteOfTheDay(String languageCode) {
    if (!_isLoaded || _quotes == null) {
      return languageCode == 'it'
          ? 'Ogni ripetizione conta.'
          : 'Every rep counts.';
    }

    final quotes = _quotes![languageCode] ?? _quotes!['en']!;
    final dayOfYear = _getDayOfYear();
    final index = dayOfYear % quotes.length;

    return quotes[index];
  }

  /// Get a random quote (different each call)
  String getRandomQuote(String languageCode) {
    if (!_isLoaded || _quotes == null) {
      return languageCode == 'it'
          ? 'Ogni ripetizione conta.'
          : 'Every rep counts.';
    }

    final quotes = _quotes![languageCode] ?? _quotes!['en']!;
    final random = Random();

    return quotes[random.nextInt(quotes.length)];
  }

  /// Get quote based on time of day (3 per day: morning/afternoon/evening)
  ///
  /// Combines day of year with time slot (0-2) for 3 different quotes per day
  String getQuoteForTimeSlot(String languageCode) {
    if (!_isLoaded || _quotes == null) {
      return languageCode == 'it'
          ? 'Ogni ripetizione conta.'
          : 'Every rep counts.';
    }

    final quotes = _quotes![languageCode] ?? _quotes!['en']!;
    final now = DateTime.now();
    final dayOfYear = _getDayOfYear();
    final hour = now.hour;

    // 3 time slots: morning (5-12), afternoon (12-18), evening (18-5)
    int timeSlot;
    if (hour >= 5 && hour < 12) {
      timeSlot = 0; // Morning
    } else if (hour >= 12 && hour < 18) {
      timeSlot = 1; // Afternoon
    } else {
      timeSlot = 2; // Evening
    }

    // Create a unique index based on day + time slot
    final seed = dayOfYear * 3 + timeSlot;
    final index = seed % quotes.length;

    return quotes[index];
  }

  int _getDayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  /// Get total number of quotes available
  int getQuoteCount(String languageCode) {
    if (!_isLoaded || _quotes == null) return 0;
    return _quotes![languageCode]?.length ?? _quotes!['en']?.length ?? 0;
  }
}
