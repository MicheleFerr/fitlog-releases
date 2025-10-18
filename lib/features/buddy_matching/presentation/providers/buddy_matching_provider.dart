/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: provider
/// 🌍 Localization: N/A - Provider class
/// 🎨 Theme: N/A - Provider class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: StateNotifierProvider, FutureProvider
/// - Firebase: Via repository
/// - Hive: None
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_match.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/repositories/buddy_matching_repository.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/repositories/firebase_buddy_matching_repository.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/services/demo_profiles_loader.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/data/services/location_service.dart';

// Repository Provider
final buddyMatchingRepositoryProvider = Provider<BuddyMatchingRepository>((ref) {
  return FirebaseBuddyMatchingRepository();
});

// Current User Provider
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// User Profile Providers
final buddyProfileProvider = FutureProvider.family<BuddyProfile?, String>((ref, userId) async {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  return repository.getUserProfile(userId);
});

final currentUserBuddyProfileProvider = FutureProvider<BuddyProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  return repository.getUserProfile(userId);
});

// Matching State
class MatchingState {

  const MatchingState({
    this.potentialMatches = const [],
    this.isLoading = false,
    this.error,
    this.currentProfile,
    this.currentIndex = 0,
  });
  final List<BuddyProfile> potentialMatches;
  final bool isLoading;
  final String? error;
  final BuddyProfile? currentProfile;
  final int currentIndex;

  MatchingState copyWith({
    List<BuddyProfile>? potentialMatches,
    bool? isLoading,
    String? error,
    BuddyProfile? currentProfile,
    int? currentIndex,
  }) {
    return MatchingState(
      potentialMatches: potentialMatches ?? this.potentialMatches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProfile: currentProfile ?? this.currentProfile,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  BuddyProfile? get currentMatch {
    if (currentIndex >= 0 && currentIndex < potentialMatches.length) {
      return potentialMatches[currentIndex];
    }
    return null;
  }

  bool get hasMoreMatches => currentIndex < potentialMatches.length - 1;
  bool get hasMatches => potentialMatches.isNotEmpty;
}

class MatchingNotifier extends StateNotifier<MatchingState> {

  MatchingNotifier(this._repository, this._userId) : super(const MatchingState()) {
    if (_userId != null) {
      loadPotentialMatches();
    }
  }
  final BuddyMatchingRepository _repository;
  final String? _userId;

  Future<void> loadPotentialMatches() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userProfile = await _repository.getUserProfile(_userId);
      if (userProfile == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Profilo utente non trovato',
        );
        return;
      }

      // Start listening to potential matches stream
      _repository.getPotentialMatches(_userId, limit: 50).listen(
        (matches) {
          state = state.copyWith(
            potentialMatches: matches,
            isLoading: false,
            error: null,
            currentProfile: userProfile,
            currentIndex: 0,
          );
        },
        onError: (error) {
          state = state.copyWith(
            isLoading: false,
            error: 'Errore nel caricamento: $error',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nel caricamento: $e',
      );
    }
  }

  Future<BuddyMatch?> likeCurrentProfile() async {
    if (_userId == null || state.currentMatch == null) return null;

    try {
      final match = await _repository.likeProfile(_userId, state.currentMatch!.uid);
      _goToNextProfile();
      return match;
    } catch (e) {
      state = state.copyWith(error: 'Errore nel like: $e');
      return null;
    }
  }

  Future<void> dislikeCurrentProfile() async {
    if (_userId == null || state.currentMatch == null) return;

    try {
      await _repository.dislikeProfile(_userId, state.currentMatch!.uid);
      _goToNextProfile();
    } catch (e) {
      state = state.copyWith(error: 'Errore nel dislike: $e');
    }
  }

  void _goToNextProfile() {
    if (state.hasMoreMatches) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      // Load more matches
      loadPotentialMatches();
    }
  }

  Future<void> refreshMatches() async {
    await loadPotentialMatches();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final matchingProvider = StateNotifierProvider<MatchingNotifier, MatchingState>((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return MatchingNotifier(repository, userId);
});

// User Matches Provider
final userMatchesProvider = StreamProvider.family<List<BuddyMatch>, MatchStatus?>((ref, status) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return Stream.value([]);
  
  return repository.getUserMatches(userId, status: status);
});

// Active matches (confirmed or partnership)
final activeMatchesProvider = StreamProvider<List<BuddyMatch>>((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return Stream.value([]);
  
  return repository.getUserMatches(userId).map((matches) =>
      matches.where((match) => 
        match.status == MatchStatus.confirmed || 
        match.status == MatchStatus.partnership
      ).toList()
  );
});

// Pending matches (waiting for response)
final pendingMatchesProvider = StreamProvider<List<BuddyMatch>>((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return Stream.value([]);
  
  return repository.getUserMatches(userId, status: MatchStatus.pending);
});

// Preferences Management
class PreferencesNotifier extends StateNotifier<AsyncValue<BuddyPreferences?>> {

  PreferencesNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _loadPreferences();
    }
  }
  final BuddyMatchingRepository _repository;
  final String? _userId;

  Future<void> _loadPreferences() async {
    try {
      final profile = await _repository.getUserProfile(_userId!);
      state = AsyncValue.data(profile?.preferences);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updatePreferences(BuddyPreferences preferences) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    
    try {
      await _repository.updateUserPreferences(_userId, preferences);
      state = AsyncValue.data(preferences);
      
      // Refresh matches after preferences change
      // This will trigger a new matching algorithm run
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setLookingForBuddy(bool isLooking) async {
    if (_userId == null) return;

    try {
      await _repository.setLookingForBuddy(_userId, isLooking);
      final currentPrefs = state.value;
      if (currentPrefs != null) {
        state = AsyncValue.data(currentPrefs.copyWith(isLookingForBuddy: isLooking));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateLocation(double latitude, double longitude, String? locationName) async {
    if (_userId == null) return;

    try {
      await _repository.updateUserLocation(_userId, latitude, longitude, locationName);
      final currentPrefs = state.value;
      if (currentPrefs != null) {
        state = AsyncValue.data(currentPrefs.copyWith(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          lastLocationUpdate: DateTime.now(),
        ));
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final buddyPreferencesProvider = StateNotifierProvider<PreferencesNotifier, AsyncValue<BuddyPreferences?>>((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PreferencesNotifier(repository, userId);
});

// Search Provider
class SearchState {

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.lastQuery,
    this.filters = const {},
  });
  final List<BuddyProfile> results;
  final bool isLoading;
  final String? error;
  final String? lastQuery;
  final Map<String, dynamic> filters;

  SearchState copyWith({
    List<BuddyProfile>? results,
    bool? isLoading,
    String? error,
    String? lastQuery,
    Map<String, dynamic>? filters,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastQuery: lastQuery ?? this.lastQuery,
      filters: filters ?? this.filters,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {

  SearchNotifier(this._repository, this._userId) : super(const SearchState());
  final BuddyMatchingRepository _repository;
  final String? _userId;

  Future<void> searchProfiles({
    String? query,
    Map<String, dynamic> filters = const {},
  }) async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _repository.searchProfiles(
        userId: _userId,
        query: query,
        maxDistance: filters['maxDistance']?.toDouble(),
        fitnessLevel: filters['fitnessLevel'] as FitnessLevel?,
        goals: filters['goals'] as List<WorkoutGoal>?,
        minAge: filters['minAge'] as int?,
        maxAge: filters['maxAge'] as int?,
        isVerified: filters['isVerified'] as bool?,
        limit: 20,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
        lastQuery: query,
        filters: filters,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Errore nella ricerca: $e',
      );
    }
  }

  void clearResults() {
    state = const SearchState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return SearchNotifier(repository, userId);
});

// Match Actions Provider
final matchActionsProvider = Provider((ref) {
  final repository = ref.watch(buddyMatchingRepositoryProvider);
  
  return MatchActions(repository);
});

// Demo Profiles Loader Provider
final demoProfilesLoaderProvider = Provider<DemoProfilesLoader>((ref) {
  return DemoProfilesLoader();
});

// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class MatchActions {

  MatchActions(this._repository);
  final BuddyMatchingRepository _repository;

  Future<BuddyMatch?> confirmMatch(String matchId, String userId) async {
    return _repository.confirmMatch(matchId, userId);
  }

  Future<void> cancelMatch(String matchId, String userId) async {
    return _repository.cancelMatch(matchId, userId);
  }

  Future<BuddyMatch?> startPartnership(String matchId, String userId) async {
    return _repository.startPartnership(matchId, userId);
  }

  Future<void> endPartnership(String matchId, String userId, {
    int? rating,
    String? feedback,
  }) async {
    return _repository.endPartnership(
      matchId, 
      userId, 
      rating: rating, 
      feedback: feedback,
    );
  }
}