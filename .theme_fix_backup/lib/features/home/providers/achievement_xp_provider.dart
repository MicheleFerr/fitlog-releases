import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';

// Model per Achievement
class Achievement {

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.xpReward,
    required this.color,
    required this.isUnlocked,
    this.unlockedAt,
    this.isNew = false,
    required this.type,
    this.metadata,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      xpReward: json['xpReward'],
      color: _getColorFromType(AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.general,
      )),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
        ? DateTime.parse(json['unlockedAt'])
        : null,
      isNew: false,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.general,
      ),
      metadata: json['metadata'],
    );
  }
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int xpReward;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isNew;
  final AchievementType type;
  final Map<String, dynamic>? metadata;

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? isNew,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      xpReward: xpReward,
      color: color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNew: isNew ?? this.isNew,
      type: type,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'xpReward': xpReward,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'type': type.name,
    'metadata': metadata,
  };
}

enum AchievementType {
  workout,
  streak,
  volume,
  pr,
  community,
  general,
}

Color _getColorFromType(AchievementType type) {
  switch (type) {
    case AchievementType.workout:
      return Colors.blue;
    case AchievementType.streak:
      return Colors.orange;
    case AchievementType.volume:
      return Colors.green;
    case AchievementType.pr:
      return Colors.red;
    case AchievementType.community:
      return Colors.purple;
    case AchievementType.general:
      return Colors.grey;
  }
}

// Achievement Data model
class AchievementData {

  AchievementData({
    required this.totalXP,
    required this.allAchievements,
    required this.recentAchievements,
    required this.xpByType,
  });
  final int totalXP;
  final List<Achievement> allAchievements;
  final List<Achievement> recentAchievements;
  final Map<AchievementType, int> xpByType;
}

// Provider per gestire achievement XP
final achievementXPProvider = StateNotifierProvider<AchievementXPNotifier, AsyncValue<AchievementData>>((ref) {
  return AchievementXPNotifier(ref);
});

class AchievementXPNotifier extends StateNotifier<AsyncValue<AchievementData>> {
  
  AchievementXPNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Inizializza immediatamente con dati vuoti, poi carica
    state = AsyncValue.data(AchievementData(
      totalXP: 0,
      allAchievements: _allAchievements,
      recentAchievements: [],
      xpByType: {},
    ));
    
    // Poi carica i dati reali
    _loadAchievements();
    _setupListeners();
  }
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Definizione achievement disponibili
  static final List<Achievement> _allAchievements = [
    // Workout achievements
    Achievement(
      id: 'first_workout',
      title: 'Prima Volta',
      description: 'Completa il tuo primo allenamento',
      emoji: '🎯',
      xpReward: 50,
      color: Colors.blue,
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_5',
      title: 'In Movimento',
      description: 'Completa 5 allenamenti',
      emoji: '🏃',
      xpReward: 100,
      color: Colors.blue,
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_10',
      title: 'Costante',
      description: 'Completa 10 allenamenti',
      emoji: '💪',
      xpReward: 200,
      color: Colors.blue,
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_25',
      title: 'Dedicato',
      description: 'Completa 25 allenamenti',
      emoji: '🏋️',
      xpReward: 500,
      color: Colors.blue,
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_50',
      title: 'Veterano',
      description: 'Completa 50 allenamenti',
      emoji: '🎖️',
      xpReward: 1000,
      color: Colors.blue,
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    
    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Iniziato',
      description: '3 giorni consecutivi',
      emoji: '🔥',
      xpReward: 75,
      color: Colors.orange,
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Settimana Perfetta',
      description: '7 giorni consecutivi',
      emoji: '🌟',
      xpReward: 150,
      color: Colors.orange,
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Due Settimane',
      description: '14 giorni consecutivi',
      emoji: '⭐',
      xpReward: 300,
      color: Colors.orange,
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Mese Completo',
      description: '30 giorni consecutivi',
      emoji: '🏆',
      xpReward: 750,
      color: Colors.orange,
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    
    // Volume achievements
    Achievement(
      id: 'volume_1000',
      title: 'Prima Tonnellata',
      description: 'Solleva 1000kg totali',
      emoji: '📦',
      xpReward: 100,
      color: Colors.green,
      isUnlocked: false,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'volume_5000',
      title: '5 Tonnellate',
      description: 'Solleva 5000kg totali',
      emoji: '🚛',
      xpReward: 250,
      color: Colors.green,
      isUnlocked: false,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'volume_10000',
      title: 'Forza Bruta',
      description: 'Solleva 10000kg totali',
      emoji: '🏗️',
      xpReward: 500,
      color: Colors.green,
      isUnlocked: false,
      type: AchievementType.volume,
    ),
    
    // PR achievements
    Achievement(
      id: 'first_pr',
      title: 'Nuovo Record',
      description: 'Stabilisci il tuo primo PR',
      emoji: '📈',
      xpReward: 50,
      color: Colors.red,
      isUnlocked: false,
      type: AchievementType.pr,
    ),
    Achievement(
      id: 'pr_5',
      title: 'Record Breaker',
      description: 'Stabilisci 5 PR',
      emoji: '💥',
      xpReward: 150,
      color: Colors.red,
      isUnlocked: false,
      type: AchievementType.pr,
    ),
    
    // Community achievements
    Achievement(
      id: 'first_contribution',
      title: 'Helper',
      description: 'Prima contribuzione community',
      emoji: '🤝',
      xpReward: 50,
      color: Colors.purple,
      isUnlocked: false,
      type: AchievementType.community,
    ),
    Achievement(
      id: 'contribution_approved',
      title: 'Contributore Verificato',
      description: 'Una tua correzione è stata approvata',
      emoji: '✅',
      xpReward: 100,
      color: Colors.purple,
      isUnlocked: false,
      type: AchievementType.community,
    ),
    Achievement(
      id: 'community_votes_10',
      title: 'Reviewer Attivo',
      description: 'Vota 10 contributi',
      emoji: '👍',
      xpReward: 75,
      color: Colors.purple,
      isUnlocked: false,
      type: AchievementType.community,
    ),
  ];
  
  Future<void> _loadAchievements() async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) {
        state = AsyncValue.data(AchievementData(
          totalXP: 0,
          allAchievements: _allAchievements,
          recentAchievements: [],
          xpByType: {},
        ));
        return;
      }
      
      // Carica achievement sbloccati dall'utente
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
      
      // Aggiorna achievement con stato sbloccato
      final updatedAchievements = _allAchievements.map((achievement) {
        if (unlockedIds.containsKey(achievement.id)) {
          final unlockedData = unlockedIds[achievement.id]!;
          return achievement.copyWith(
            isUnlocked: true,
            unlockedAt: unlockedData['unlockedAt'] != null
                ? (unlockedData['unlockedAt'] as Timestamp).toDate()
                : null,
            isNew: _isNew(unlockedData['unlockedAt']),
          );
        }
        return achievement;
      }).toList();
      
      // Calcola XP totali e per tipo
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
      
      // Ordina achievement recenti
      recentAchievements.sort((a, b) => 
        b.unlockedAt!.compareTo(a.unlockedAt!)
      );
      
      state = AsyncValue.data(AchievementData(
        totalXP: totalXP,
        allAchievements: updatedAchievements,
        recentAchievements: recentAchievements,
        xpByType: xpByType,
      ));
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void _setupListeners() {
    // Ascolta cambiamenti in workout count
    _ref.listen(completedWorkoutsCountProvider, (previous, next) {
      if (next.hasValue) {
        _checkWorkoutAchievements(next.value!);
      }
    });
    
    // Ascolta cambiamenti in streak
    _ref.listen(currentStreakProvider, (previous, next) {
      if (next.hasValue) {
        _checkStreakAchievements(next.value!);
      }
    });
    
    // Ascolta cambiamenti in volume totale
    // TODO: Aggiungere provider per volume totale
  }
  
  Future<void> _checkWorkoutAchievements(int workoutCount) async {
    final achievementsToCheck = [
      ('first_workout', 1),
      ('workout_5', 5),
      ('workout_10', 10),
      ('workout_25', 25),
      ('workout_50', 50),
    ];
    
    for (final (id, threshold) in achievementsToCheck) {
      if (workoutCount >= threshold) {
        await _unlockAchievement(id);
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
    
    for (final (id, threshold) in achievementsToCheck) {
      if (streak >= threshold) {
        await _unlockAchievement(id);
      }
    }
  }
  
  Future<void> _unlockAchievement(String achievementId) async {
    try {
      final userAsync = await _ref.read(currentUserProvider.future);
      if (userAsync == null) return;
      
      final currentState = state.value;
      if (currentState == null) return;
      
      // Verifica se già sbloccato
      final achievement = currentState.allAchievements.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => throw Exception('Achievement not found'),
      );
      
      if (achievement.isUnlocked) return;
      
      // Sblocca achievement
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
      
      // Aggiorna stato locale
      await _loadAchievements();
      
      // TODO: Mostrare notifica di achievement sbloccato
    } catch (e) {
      // print('Error unlocking achievement: $e');
    }
  }
  
  bool _isNew(dynamic unlockedAt) {
    if (unlockedAt == null) return false;
    
    final date = unlockedAt is Timestamp 
        ? unlockedAt.toDate()
        : unlockedAt as DateTime;
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    // Considera "nuovo" se sbloccato negli ultimi 3 giorni
    return difference.inDays <= 3;
  }
  
  Future<void> checkAllAchievements() async {
    // Forza controllo di tutti gli achievement
    final workoutCount = await _ref.read(completedWorkoutsCountProvider.future);
    await _checkWorkoutAchievements(workoutCount);
    
    final streak = await _ref.read(currentStreakProvider.future);
    await _checkStreakAchievements(streak);
    
    // TODO: Aggiungere altri controlli (volume, PR, community)
  }
}