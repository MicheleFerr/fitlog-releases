import 'dart:math';

class LevelSystem {
  static const int maxLevel = 100;
  static const int baseXpPerLevel = 100;
  static const double xpMultiplier = 1.15;
  
  // Calcola XP necessari per un livello specifico
  static int getXpForLevel(int level) {
    if (level <= 1) return 0;
    if (level > maxLevel) return getXpForLevel(maxLevel);
    
    return (baseXpPerLevel * pow(xpMultiplier, level - 1)).round();
  }
  
  // Calcola XP totali necessari per raggiungere un livello
  static int getTotalXpForLevel(int level) {
    int totalXp = 0;
    for (int i = 2; i <= level; i++) {
      totalXp += getXpForLevel(i);
    }
    return totalXp;
  }
  
  // Determina livello attuale basato su XP totali
  static LevelInfo getLevelInfo(int totalXp) {
    int currentLevel = 1;
    int xpProgress = totalXp;
    
    while (currentLevel < maxLevel) {
      int xpNeeded = getXpForLevel(currentLevel + 1);
      if (xpProgress >= xpNeeded) {
        xpProgress -= xpNeeded;
        currentLevel++;
      } else {
        break;
      }
    }
    
    int xpForNextLevel = currentLevel < maxLevel ? getXpForLevel(currentLevel + 1) : 0;
    double progressPercentage = xpForNextLevel > 0 ? xpProgress / xpForNextLevel : 1.0;
    
    return LevelInfo(
      level: currentLevel,
      currentXp: xpProgress,
      xpForNextLevel: xpForNextLevel,
      totalXp: totalXp,
      progressPercentage: progressPercentage,
      title: _getTitleForLevel(currentLevel),
      perks: _getPerksForLevel(currentLevel),
    );
  }
  
  static String _getTitleForLevel(int level) {
    if (level <= 10) return 'Principiante';
    if (level <= 20) return 'Apprendista';
    if (level <= 30) return 'Intermedio';
    if (level <= 40) return 'Avanzato';
    if (level <= 50) return 'Esperto';
    if (level <= 60) return 'Maestro';
    if (level <= 70) return 'Veterano';
    if (level <= 80) return 'Elite';
    if (level <= 90) return 'Campione';
    if (level <= 99) return 'Leggenda';
    return 'Titano';
  }
  
  static List<LevelPerk> _getPerksForLevel(int level) {
    List<LevelPerk> perks = [];
    
    // Sblocchi ogni 5 livelli
    if (level >= 5) perks.add(LevelPerk.customWorkoutTemplates);
    if (level >= 10) perks.add(LevelPerk.advancedAnalytics);
    if (level >= 15) perks.add(LevelPerk.socialFeatures);
    if (level >= 20) perks.add(LevelPerk.personalRecords);
    if (level >= 25) perks.add(LevelPerk.customExercises);
    if (level >= 30) perks.add(LevelPerk.workoutPrograms);
    if (level >= 35) perks.add(LevelPerk.nutritionTracking);
    if (level >= 40) perks.add(LevelPerk.advancedTimers);
    if (level >= 45) perks.add(LevelPerk.teamWorkouts);
    if (level >= 50) perks.add(LevelPerk.coachingMode);
    
    return perks;
  }
  
  // Calcola XP guadagnati per un workout
  static int calculateWorkoutXp({
    required int duration, // in minuti
    required int exercises,
    required double totalVolume,
    bool isPersonalRecord = false,
    int streakDays = 0,
  }) {
    int baseXp = 50;
    
    // XP per durata (1 XP per minuto, max 60)
    baseXp += min(duration, 60);
    
    // XP per esercizi (5 XP per esercizio, max 50)
    baseXp += min(exercises * 5, 50);
    
    // XP per volume (1 XP per 100kg, max 100)
    baseXp += min((totalVolume / 100).round(), 100);
    
    // Bonus PR
    if (isPersonalRecord) baseXp += 50;
    
    // Bonus streak (2 XP per giorno, max 50)
    baseXp += min(streakDays * 2, 50);
    
    return baseXp;
  }
  
  // Calcola XP bonus per accesso quotidiano consecutivo
  // Progressione: 1, 2, 4, 8, 16, 32, 64, 100 (poi sempre 100)
  static int calculateDailyLoginBonus(int consecutiveDays) {
    if (consecutiveDays <= 0) return 0;
    
    // Progressione esponenziale fino al giorno 7
    if (consecutiveDays <= 7) {
      // Giorni 1-6: 2^(n-1) con cap a 64
      if (consecutiveDays <= 6) {
        return pow(2, consecutiveDays - 1).toInt();
      }
      // Giorno 7: 100 XP
      return 100;
    }
    
    // Dal giorno 8 in poi: sempre 100 XP
    return 100;
  }
  
  // Ottieni la descrizione del bonus login per UI
  static DailyLoginBonusInfo getDailyLoginBonusInfo(int consecutiveDays) {
    final currentBonus = calculateDailyLoginBonus(consecutiveDays);
    final nextDayBonus = calculateDailyLoginBonus(consecutiveDays + 1);
    
    String message;
    if (consecutiveDays == 0) {
      message = 'Accedi domani per iniziare il bonus giornaliero!';
    } else if (consecutiveDays < 7) {
      message = 'Continua la serie! Domani: $nextDayBonus XP';
    } else {
      message = 'Bonus massimo raggiunto! 100 XP al giorno';
    }
    
    return DailyLoginBonusInfo(
      currentDayBonus: currentBonus,
      nextDayBonus: nextDayBonus,
      consecutiveDays: consecutiveDays,
      message: message,
      isMaxBonus: consecutiveDays >= 7,
    );
  }
}

class LevelInfo {
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final int totalXp;
  final double progressPercentage;
  final String title;
  final List<LevelPerk> perks;
  
  const LevelInfo({
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.totalXp,
    required this.progressPercentage,
    required this.title,
    required this.perks,
  });
}

class DailyLoginBonusInfo {
  final int currentDayBonus;
  final int nextDayBonus;
  final int consecutiveDays;
  final String message;
  final bool isMaxBonus;
  
  const DailyLoginBonusInfo({
    required this.currentDayBonus,
    required this.nextDayBonus,
    required this.consecutiveDays,
    required this.message,
    required this.isMaxBonus,
  });
}

enum LevelPerk {
  customWorkoutTemplates,
  advancedAnalytics,
  socialFeatures,
  personalRecords,
  customExercises,
  workoutPrograms,
  nutritionTracking,
  advancedTimers,
  teamWorkouts,
  coachingMode,
}

extension LevelPerkExtension on LevelPerk {
  String get title {
    switch (this) {
      case LevelPerk.customWorkoutTemplates:
        return 'Template Personalizzati';
      case LevelPerk.advancedAnalytics:
        return 'Analisi Avanzate';
      case LevelPerk.socialFeatures:
        return 'Funzioni Social';
      case LevelPerk.personalRecords:
        return 'Record Personali';
      case LevelPerk.customExercises:
        return 'Esercizi Custom';
      case LevelPerk.workoutPrograms:
        return 'Programmi Allenamento';
      case LevelPerk.nutritionTracking:
        return 'Tracciamento Nutrizione';
      case LevelPerk.advancedTimers:
        return 'Timer Avanzati';
      case LevelPerk.teamWorkouts:
        return 'Allenamenti di Squadra';
      case LevelPerk.coachingMode:
        return 'Modalità Coach';
    }
  }
  
  String get description {
    switch (this) {
      case LevelPerk.customWorkoutTemplates:
        return 'Crea e salva template di allenamento personalizzati';
      case LevelPerk.advancedAnalytics:
        return 'Grafici dettagliati e trend di progressione';
      case LevelPerk.socialFeatures:
        return 'Condividi progressi e sfida gli amici';
      case LevelPerk.personalRecords:
        return 'Traccia e celebra i tuoi record personali';
      case LevelPerk.customExercises:
        return 'Aggiungi esercizi personalizzati al database';
      case LevelPerk.workoutPrograms:
        return 'Accedi a programmi di allenamento strutturati';
      case LevelPerk.nutritionTracking:
        return 'Integra il tracciamento nutrizionale';
      case LevelPerk.advancedTimers:
        return 'Timer EMOM, Tabata e personalizzati';
      case LevelPerk.teamWorkouts:
        return 'Allenati insieme ad altri utenti';
      case LevelPerk.coachingMode:
        return 'Strumenti per allenare altri atleti';
    }
  }
}