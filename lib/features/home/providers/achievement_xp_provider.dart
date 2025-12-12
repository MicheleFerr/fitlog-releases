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
    // Safe parsing with defaults (Task 6.1)
    return Achievement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🏆',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      color: _getColorFromType(AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.general,
      )),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
        ? DateTime.parse(json['unlockedAt'] as String)
        : null,
      isNew: false,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.general,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      return const Color(0xFF2196F3); // Material Blue (primary)
    case AchievementType.streak:
      return const Color(0xFFFF9800); // Material Orange (secondary)
    case AchievementType.volume:
      return const Color(0xFF4CAF50); // Material Green (success)
    case AchievementType.pr:
      return const Color(0xFFF44336); // Material Red (error)
    case AchievementType.community:
      return const Color(0xFF9C27B0); // Material Purple (tertiary)
    case AchievementType.general:
      return const Color(0xFFBDBDBD); // Material Grey 400 (surfaceVariant)
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
final achievementXPProvider = AsyncNotifierProvider<AchievementXPNotifier, AchievementData>(AchievementXPNotifier.new);

class AchievementXPNotifier extends AsyncNotifier<AchievementData> {
  Ref get _ref => ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<AchievementData> build() async {
    // ✅ MEMORY FIX: Ensure proper cleanup when provider is disposed
    // ref.listen subscriptions are automatically cleaned up by Riverpod 2.6.x
    // but we add explicit onDispose for any future manual subscriptions
    ref.onDispose(() {
      // Listeners set up via ref.listen are auto-cleaned by Riverpod
      // This is a safety net for any future manual subscriptions
    });

    // Inizializza immediatamente con dati vuoti
    final initialData = AchievementData(
      totalXP: 0,
      allAchievements: _allAchievements,
      recentAchievements: [],
      xpByType: {},
    );

    // Setup listeners dopo l'inizializzazione
    _setupListeners();

    // Carica i dati reali
    try {
      return await _loadAchievementsData();
    } catch (e) {
      return initialData;
    }
  }

  // Definizione achievement disponibili
  static final List<Achievement> _allAchievements = [
    // Workout achievements
    Achievement(
      id: 'first_workout',
      title: 'Prima Volta',
      description: 'Completa il tuo primo allenamento',
      emoji: '🎯',
      xpReward: 50,
      color: const Color(0xFF2196F3), // Material Blue (primary)
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_5',
      title: 'In Movimento',
      description: 'Completa 5 allenamenti',
      emoji: '🏃',
      xpReward: 100,
      color: const Color(0xFF2196F3), // Material Blue (primary)
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_10',
      title: 'Costante',
      description: 'Completa 10 allenamenti',
      emoji: '💪',
      xpReward: 200,
      color: const Color(0xFF2196F3), // Material Blue (primary)
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_25',
      title: 'Dedicato',
      description: 'Completa 25 allenamenti',
      emoji: '🏋️',
      xpReward: 500,
      color: const Color(0xFF2196F3), // Material Blue (primary)
      isUnlocked: false,
      type: AchievementType.workout,
    ),
    Achievement(
      id: 'workout_50',
      title: 'Veterano',
      description: 'Completa 50 allenamenti',
      emoji: '🎖️',
      xpReward: 1000,
      color: const Color(0xFF2196F3), // Material Blue (primary)
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
      color: const Color(0xFFFF9800), // Material Orange (secondary)
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Settimana Perfetta',
      description: '7 giorni consecutivi',
      emoji: '🌟',
      xpReward: 150,
      color: const Color(0xFFFF9800), // Material Orange (secondary)
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Due Settimane',
      description: '14 giorni consecutivi',
      emoji: '⭐',
      xpReward: 300,
      color: const Color(0xFFFF9800), // Material Orange (secondary)
      isUnlocked: false,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Mese Completo',
      description: '30 giorni consecutivi',
      emoji: '🏆',
      xpReward: 750,
      color: const Color(0xFFFF9800), // Material Orange (secondary)
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
      color: const Color(0xFF4CAF50), // Material Green (success)
      isUnlocked: false,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'volume_5000',
      title: '5 Tonnellate',
      description: 'Solleva 5000kg totali',
      emoji: '🚛',
      xpReward: 250,
      color: const Color(0xFF4CAF50), // Material Green (success)
      isUnlocked: false,
      type: AchievementType.volume,
    ),
    Achievement(
      id: 'volume_10000',
      title: 'Forza Bruta',
      description: 'Solleva 10000kg totali',
      emoji: '🏗️',
      xpReward: 500,
      color: const Color(0xFF4CAF50), // Material Green (success)
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
      color: const Color(0xFFF44336), // Material Red (error)
      isUnlocked: false,
      type: AchievementType.pr,
    ),
    Achievement(
      id: 'pr_5',
      title: 'Record Breaker',
      description: 'Stabilisci 5 PR',
      emoji: '💥',
      xpReward: 150,
      color: const Color(0xFFF44336), // Material Red (error)
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
      color: const Color(0xFF9C27B0), // Material Purple (tertiary)
      isUnlocked: false,
      type: AchievementType.community,
    ),
    Achievement(
      id: 'contribution_approved',
      title: 'Contributore Verificato',
      description: 'Una tua correzione è stata approvata',
      emoji: '✅',
      xpReward: 100,
      color: const Color(0xFF9C27B0), // Material Purple (tertiary)
      isUnlocked: false,
      type: AchievementType.community,
    ),
    Achievement(
      id: 'community_votes_10',
      title: 'Reviewer Attivo',
      description: 'Vota 10 contributi',
      emoji: '👍',
      xpReward: 75,
      color: const Color(0xFF9C27B0), // Material Purple (tertiary)
      isUnlocked: false,
      type: AchievementType.community,
    ),
  ];
  
  Future<AchievementData> _loadAchievementsData() async {
    final userAsync = await _ref.read(currentUserProvider.future);
    if (userAsync == null) {
      return AchievementData(
        totalXP: 0,
        allAchievements: _allAchievements,
        recentAchievements: [],
        xpByType: {},
      );
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

      // Safe Map casting (Task 6.1)
      for (final entry in achievements.entries) {
        if (entry.value is Map<String, dynamic>) {
          unlockedIds[entry.key] = entry.value as Map<String, dynamic>;
        }
      }
    }

    // Aggiorna achievement con stato sbloccato
    final updatedAchievements = _allAchievements.map((achievement) {
      if (unlockedIds.containsKey(achievement.id)) {
        final unlockedData = unlockedIds[achievement.id]!;
        // Safe Timestamp parsing (Task 6.1)
        final unlockedAtTimestamp = unlockedData['unlockedAt'];
        final unlockedAtDate = unlockedAtTimestamp is Timestamp
            ? unlockedAtTimestamp.toDate()
            : null;

        return achievement.copyWith(
          isUnlocked: true,
          unlockedAt: unlockedAtDate,
          isNew: _isNew(unlockedAtTimestamp),
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

    return AchievementData(
      totalXP: totalXP,
      allAchievements: updatedAchievements,
      recentAchievements: recentAchievements,
      xpByType: xpByType,
    );
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
      ref.invalidateSelf();
      
      // TODO: Mostrare notifica di achievement sbloccato
    } catch (e) {
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

  // Helper to reload achievements
  Future<void> reloadAchievements() async {
    ref.invalidateSelf();
  }
}
