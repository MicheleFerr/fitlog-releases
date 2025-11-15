/// Represents streak milestone achievements
enum StreakMilestone {
  weekWarrior(days: 7, badge: '🔥 Week Warrior'),
  consistentChampion(days: 30, badge: '💪 Consistent Champion'),
  legendary(days: 100, badge: '🏆 Legendary');

  const StreakMilestone({required this.days, required this.badge});

  final int days;
  final String badge;

  static StreakMilestone? getNextMilestone(int currentStreak) {
    if (currentStreak < 7) return weekWarrior;
    if (currentStreak < 30) return consistentChampion;
    if (currentStreak < 100) return legendary;
    return null;
  }

  static StreakMilestone? getCurrentMilestone(int currentStreak) {
    if (currentStreak >= 100) return legendary;
    if (currentStreak >= 30) return consistentChampion;
    if (currentStreak >= 7) return weekWarrior;
    return null;
  }

  /// Calculate progress to next milestone (0.0 to 1.0)
  static double getProgressToNext(int currentStreak) {
    final next = getNextMilestone(currentStreak);
    if (next == null) return 1.0; // Already at max milestone

    final current = getCurrentMilestone(currentStreak);
    final previousDays = current?.days ?? 0;
    final nextDays = next.days;

    return (currentStreak - previousDays) / (nextDays - previousDays);
  }
}
