import 'dart:math' as math;

/// Utility class for XP and level calculations
/// Uses a progressive system where each level requires more XP
class XPCalculator {
  /// Base XP required for level 2
  static const int baseXP = 100;
  
  /// Growth factor for XP requirements (1.15 = 15% more per level)
  static const double growthFactor = 1.15;
  
  /// Calculate the current level from total XP
  static int getLevelFromXP(int totalXP) {
    if (totalXP <= 0) return 1;
    
    int level = 1;
    int xpRequired = 0;
    
    while (xpRequired <= totalXP) {
      level++;
      xpRequired += getXPRequiredForLevel(level);
    }
    
    return level - 1;
  }
  
  /// Get XP required to reach a specific level from the previous level
  static int getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return baseXP;
    
    // Progressive formula: XP = base * (growthFactor ^ (level - 2))
    // Round to nearest 10 for cleaner numbers
    final exactXP = baseXP * math.pow(growthFactor, level - 2);
    return (exactXP / 10).round() * 10;
  }
  
  /// Get total XP required to reach a level from level 1
  static int getTotalXPForLevel(int level) {
    if (level <= 1) return 0;
    
    int totalXP = 0;
    for (int i = 2; i <= level; i++) {
      totalXP += getXPRequiredForLevel(i);
    }
    return totalXP;
  }
  
  /// Get current progress within the current level
  static LevelProgress getLevelProgress(int totalXP) {
    final currentLevel = getLevelFromXP(totalXP);
    final xpForCurrentLevel = getTotalXPForLevel(currentLevel);
    final xpForNextLevel = getTotalXPForLevel(currentLevel + 1);
    final xpInCurrentLevel = totalXP - xpForCurrentLevel;
    final xpNeededForNext = xpForNextLevel - xpForCurrentLevel;
    
    return LevelProgress(
      level: currentLevel,
      currentXP: xpInCurrentLevel,
      requiredXP: xpNeededForNext,
      totalXP: totalXP,
      progress: xpNeededForNext > 0 ? xpInCurrentLevel / xpNeededForNext : 0,
    );
  }
  
  /// Get a descriptive title for the level
  static String getLevelTitle(int level) {
    if (level >= 100) return 'Leggenda';
    if (level >= 75) return 'Maestro';
    if (level >= 50) return 'Elite';
    if (level >= 40) return 'Esperto';
    if (level >= 30) return 'Veterano';
    if (level >= 20) return 'Avanzato';
    if (level >= 15) return 'Competente';
    if (level >= 10) return 'Praticante';
    if (level >= 5) return 'Principiante';
    if (level >= 2) return 'Novizio';
    return 'Esordiente';
  }
  
  /// Get milestone levels (for special rewards)
  static List<int> getMilestoneLevels() {
    return [5, 10, 15, 20, 25, 30, 40, 50, 75, 100];
  }
  
  /// Check if a level is a milestone
  static bool isMilestoneLevel(int level) {
    return getMilestoneLevels().contains(level);
  }
}

class LevelProgress {
  
  const LevelProgress({
    required this.level,
    required this.currentXP,
    required this.requiredXP,
    required this.totalXP,
    required this.progress,
  });
  final int level;
  final int currentXP;
  final int requiredXP;
  final int totalXP;
  final double progress;
}