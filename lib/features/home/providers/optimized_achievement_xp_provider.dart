import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/optimized_progress_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'dart:async';

/// OPTIMIZED VERSION - Fixed listener loops and excessive Firebase queries

/// Optimized Achievement XP Provider with debounced listening and caching
final optimizedAchievementXPProvider = StateNotifierProvider<OptimizedAchievementXPNotifier, AsyncValue<AchievementData>>((ref) {
  return OptimizedAchievementXPNotifier(ref);
});

class OptimizedAchievementXPNotifier extends StateNotifier<AsyncValue<AchievementData>> {
  
  OptimizedAchievementXPNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initializeWithDefaults();
    _loadAchievements();
    _setupOptimizedListeners();
  }
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Debouncing and caching
  Timer? _debounceTimer;
  Timer? _cacheTimer;
  DateTime? _lastFetchTime;
  static const Duration _debounceDelay = Duration(milliseconds: 500);
  static const Duration _cacheValidity = Duration(minutes: 5);
  
  // Listener management
  StreamSubscription? _workoutListener;
  StreamSubscription? _streakListener;
  bool _listenersSetup = false;
  
  // Current data cache
  int _cachedWorkoutCount = 0;
  int _cachedStreak = 0;
  
  void _initializeWithDefaults() {
    // Provide immediate default data to prevent loading states
    state = AsyncValue.data(AchievementData(
      totalXP: 0,
      allAchievements: AchievementXPNotifier._allAchievements,
      recentAchievements: [],
      xpByType: {},
    ));
  }
  
  Future<void> _loadAchievements() async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) {
        return;
      }
      
      // Check cache validity
      if (_lastFetchTime != null && 
          DateTime.now().difference(_lastFetchTime!) < _cacheValidity) {
        return; // Use cached data
      }
      
      final userAchievementsDoc = await _firestore
          .collection('user_achievements')
          .doc(userAsync.uid)
          .get();
      
      final unlockedIds = <String, Map<String, dynamic>>{};
      if (userAchievementsDoc.exists) {
        final data = userAchievementsDoc.data() ?? {};
        final achievements = data['achievements'] as Map<String, dynamic>? ?? {};
        
        for (final entry in achievements.entries) {
          unlockedIds[entry.key] = entry.value as Map<String, dynamic>;
        }
      }
      
      final updatedAchievements = AchievementXPNotifier._allAchievements.map((achievement) {
        if (unlockedIds.containsKey(achievement.id)) {
          final unlockedData = unlockedIds[achievement.id]!;
          return achievement.copyWith(
            isUnlocked: true,
            unlockedAt: unlockedData['unlockedAt'] != null
                ? (unlockedData['unlockedAt'] as Timestamp).toDate()
                : null,
            isNew: _isNew(unlockedData['unlockedAt'], unlockedData['viewedAt']),
          );
        }
        return achievement;
      }).toList();
      
      int totalXP = 0;
      final xpByType = <AchievementType, int>{};
      final recentAchievements = <Achievement>[];
      
      for (final achievement in updatedAchievements) {
        if (achievement.isUnlocked) {
          totalXP += achievement.xpReward;
          xpByType[achievement.type] = (xpByType[achievement.type] ?? 0) + achievement.xpReward;
          
          if (achievement.unlockedAt != null) {
            recentAchievements.add(achievement);
          }
        }
      }
      
      recentAchievements.sort((a, b) => 
        b.unlockedAt!.compareTo(a.unlockedAt!)
      );
      
      state = AsyncValue.data(AchievementData(
        totalXP: totalXP,
        allAchievements: updatedAchievements,
        recentAchievements: recentAchievements,
        xpByType: xpByType,
      ));
      
      _lastFetchTime = DateTime.now();
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void _setupOptimizedListeners() {
    if (_listenersSetup) return;
    _listenersSetup = true;
    
    // OPTIMIZED: Use debounced listeners to prevent excessive checking
    _workoutListener = _ref.listen(optimizedCompletedWorkoutsCountProvider, (previous, next) {
      if (next.hasValue && next.value != _cachedWorkoutCount) {
        _cachedWorkoutCount = next.value!;
        _debouncedCheckAchievements('workout', next.value!);
      }
    });
    
    _streakListener = _ref.listen(optimizedCurrentStreakProvider, (previous, next) {
      if (next.hasValue && next.value != _cachedStreak) {
        _cachedStreak = next.value!;
        _debouncedCheckAchievements('streak', next.value!);
      }
    });
  }
  
  void _debouncedCheckAchievements(String type, int value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (type == 'workout') {
        _checkWorkoutAchievements(value);
      } else if (type == 'streak') {
        _checkStreakAchievements(value);
      }
    });
  }
  
  Future<void> _checkWorkoutAchievements(int workoutCount) async {
    final achievementsToCheck = [
      ('first_workout', 1),
      ('workout_5', 5),
      ('workout_10', 10),
      ('workout_25', 25),
      ('workout_50', 50),
    ];
    
    // Check only relevant achievements to avoid unnecessary Firebase calls
    for (final (id, threshold) in achievementsToCheck) {
      if (workoutCount >= threshold) {
        final currentState = state.value;
        if (currentState != null) {
          final achievement = currentState.allAchievements.firstWhere(
            (a) => a.id == id,
            orElse: () => throw Exception('Achievement not found'),
          );
          
          if (!achievement.isUnlocked) {
            await _unlockAchievement(id);
            break; // Only unlock one at a time to prevent spam
          }
        }
      }
    }
  }
  
  Future<void> _checkStreakAchievements(int streak) async {
    final achievementsToCheck = [
      ('streak_3', 3),
      ('streak_7', 7),
      ('streak_14', 14),
      ('streak_30', 30),
    ];
    
    // Check only relevant achievements
    for (final (id, threshold) in achievementsToCheck) {
      if (streak >= threshold) {
        final currentState = state.value;
        if (currentState != null) {
          final achievement = currentState.allAchievements.firstWhere(
            (a) => a.id == id,
            orElse: () => throw Exception('Achievement not found'),
          );
          
          if (!achievement.isUnlocked) {
            await _unlockAchievement(id);
            break; // Only unlock one at a time
          }
        }
      }
    }
  }
  
  Future<void> _unlockAchievement(String achievementId) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) return;
      
      final currentState = state.value;
      if (currentState == null) return;
      
      final achievement = currentState.allAchievements.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => throw Exception('Achievement not found'),
      );
      
      if (achievement.isUnlocked) return;
      
      // Batch write to Firebase for efficiency
      await _firestore
          .collection('user_achievements')
          .doc(userAsync.uid)
          .set({
            'achievements': {
              achievementId: {
                'unlockedAt': FieldValue.serverTimestamp(),
                'xpAwarded': achievement.xpReward,
              }
            }
          }, SetOptions(merge: true));
      
      // Update local state immediately for better UX
      await _loadAchievements();
      
    } catch (e) {
      // Silent error handling to prevent disrupting user experience
    }
  }
  
  bool _isNew(dynamic unlockedAt, dynamic viewedAt) {
    if (unlockedAt == null) return false;
    if (viewedAt != null) return false;
    
    final date = unlockedAt is Timestamp 
        ? unlockedAt.toDate()
        : unlockedAt as DateTime;
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    return difference.inDays <= 3;
  }
  
  Future<void> markAllNewAsViewed() async {
    final currentState = state.value;
    if (currentState == null) return;
    
    final newAchievementIds = currentState.allAchievements
        .where((a) => a.isUnlocked && a.isNew)
        .map((a) => a.id)
        .toList();
    
    if (newAchievementIds.isNotEmpty) {
      await markAchievementsAsViewed(newAchievementIds);
    }
  }
  
  Future<void> markAchievementsAsViewed(List<String> achievementIds) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) return;
      
      final updates = <String, dynamic>{};
      for (final id in achievementIds) {
        updates['achievements.$id.viewedAt'] = FieldValue.serverTimestamp();
      }
      
      await _firestore
          .collection('user_achievements')
          .doc(userAsync.uid)
          .update(updates);
      
      await _loadAchievements();
    } catch (e) {
      // Silent error handling
    }
  }
  
  Future<void> forceRefresh() async {
    _lastFetchTime = null; // Invalidate cache
    await _loadAchievements();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cacheTimer?.cancel();
    _workoutListener?.cancel();
    _streakListener?.cancel();
    super.dispose();
  }
}