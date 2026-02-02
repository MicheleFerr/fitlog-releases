/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: presentation/providers
/// Feature: Home - Motivational Quotes
/// Type: Provider
///
/// Provides daily rotating motivational quotes based on time of day.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/services/motivational_quote_service.dart';

/// Provider for the motivational quote service initialization
final motivationalQuoteServiceProvider =
    FutureProvider<MotivationalQuoteService>((ref) async {
      final service = MotivationalQuoteService.instance;
      await service.loadQuotes();
      return service;
    });

/// Provider for the current quote based on time of day
///
/// Changes 3 times per day (morning/afternoon/evening)
/// but remains consistent within each period.
///
/// Usage: ref.watch(currentQuoteProvider('en')) or ref.watch(currentQuoteProvider('it'))
final currentQuoteProvider = Provider.family<String, String>((
  ref,
  languageCode,
) {
  final serviceAsync = ref.watch(motivationalQuoteServiceProvider);

  return serviceAsync.when(
    data: (service) => service.getQuoteForTimeSlot(languageCode),
    loading: () =>
        languageCode == 'it' ? 'Ogni ripetizione conta.' : 'Every rep counts.',
    error: (_, __) =>
        languageCode == 'it' ? 'Ogni ripetizione conta.' : 'Every rep counts.',
  );
});
