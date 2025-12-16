# Profile Hub Redesign - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modernizzare la schermata Profile Hub con design Apple Fitness+ style, ring cards interattive, avatar sbloccabili, e workout feed con preview esercizi.

**Architecture:** Refactor del widget `ProfileHubScreen` esistente, riutilizzando `EnhancedProgressRing` per le metriche. Nuovo provider per obiettivi utente (workout/settimana, volume target). Avatar collegati al sistema `achievementXPProvider` esistente.

**Tech Stack:** Flutter, Riverpod, Material 3 chips, EnhancedProgressRing (esistente), achievementXPProvider (esistente)

---

## Task 1: Localizzazione - Aggiungere nuove chiavi

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Aggiungere chiavi EN**

In `app_en.arb`, aggiungere dopo le chiavi esistenti:

```json
"streakWeeks": "Streak Weeks",
"workoutWeek": "Workout Week",
"volumeGoal": "Volume Goal",
"stats": "Stats",
"todayAt": "Today, {time}",
"@todayAt": {
  "placeholders": {
    "time": {"type": "String"}
  }
},
"yesterdayAt": "Yesterday, {time}",
"@yesterdayAt": {
  "placeholders": {
    "time": {"type": "String"}
  }
},
"daysAgo": "{days} days ago",
"@daysAgo": {
  "placeholders": {
    "days": {"type": "int"}
  }
},
"andNMore": "+{count} more",
"@andNMore": {
  "placeholders": {
    "count": {"type": "int"}
  }
},
"modifyGoal": "Modify Goal",
"workoutsPerWeek": "Workouts per week",
"weeklyVolumeTarget": "Weekly volume target",
"consecutiveWeeks": "{weeks} consecutive weeks",
"@consecutiveWeeks": {
  "placeholders": {
    "weeks": {"type": "int"}
  }
},
"totalWorkouts": "{count} total workouts",
"@totalWorkouts": {
  "placeholders": {
    "count": {"type": "int"}
  }
},
"memberSince": "Member since {date}",
"@memberSince": {
  "placeholders": {
    "date": {"type": "String"}
  }
}
```

**Step 2: Aggiungere chiavi IT**

In `app_it.arb`, aggiungere:

```json
"streakWeeks": "Settimane Streak",
"workoutWeek": "Workout Sett.",
"volumeGoal": "Obiettivo Volume",
"stats": "Stats",
"todayAt": "Oggi, {time}",
"@todayAt": {
  "placeholders": {
    "time": {"type": "String"}
  }
},
"yesterdayAt": "Ieri, {time}",
"@yesterdayAt": {
  "placeholders": {
    "time": {"type": "String"}
  }
},
"daysAgo": "{days} giorni fa",
"@daysAgo": {
  "placeholders": {
    "days": {"type": "int"}
  }
},
"andNMore": "+{count} altri",
"@andNMore": {
  "placeholders": {
    "count": {"type": "int"}
  }
},
"modifyGoal": "Modifica Obiettivo",
"workoutsPerWeek": "Workout a settimana",
"weeklyVolumeTarget": "Volume settimanale target",
"consecutiveWeeks": "{weeks} settimane consecutive",
"@consecutiveWeeks": {
  "placeholders": {
    "weeks": {"type": "int"}
  }
},
"totalWorkouts": "{count} workout totali",
"@totalWorkouts": {
  "placeholders": {
    "count": {"type": "int"}
  }
},
"memberSince": "Membro dal {date}",
"@memberSince": {
  "placeholders": {
    "date": {"type": "String"}
  }
}
```

**Step 3: Rigenerare localizzazioni**

Run: `flutter gen-l10n`
Expected: Files in `lib/shared/presentation/l10n/generated/` updated

**Step 4: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb lib/shared/presentation/l10n/generated/
git commit -m "feat(profile): add localization keys for profile hub redesign"
```

---

## Task 2: Provider obiettivi utente

**Files:**
- Create: `lib/features/profile/presentation/providers/user_goals_provider.dart`

**Step 1: Creare il provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// User fitness goals (workouts per week, volume target)
class UserGoals {
  const UserGoals({
    this.workoutsPerWeek = 2,
    this.weeklyVolumeTarget = 5000,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      workoutsPerWeek: (json['workoutsPerWeek'] as num?)?.toInt() ?? 2,
      weeklyVolumeTarget: (json['weeklyVolumeTarget'] as num?)?.toInt() ?? 5000,
    );
  }

  final int workoutsPerWeek;
  final int weeklyVolumeTarget; // in kg

  Map<String, dynamic> toJson() => {
    'workoutsPerWeek': workoutsPerWeek,
    'weeklyVolumeTarget': weeklyVolumeTarget,
  };

  UserGoals copyWith({
    int? workoutsPerWeek,
    int? weeklyVolumeTarget,
  }) {
    return UserGoals(
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      weeklyVolumeTarget: weeklyVolumeTarget ?? this.weeklyVolumeTarget,
    );
  }
}

/// Provider per gli obiettivi fitness dell'utente
final userGoalsProvider = StateNotifierProvider<UserGoalsNotifier, AsyncValue<UserGoals>>((ref) {
  return UserGoalsNotifier(ref);
});

class UserGoalsNotifier extends StateNotifier<AsyncValue<UserGoals>> {
  UserGoalsNotifier(this._ref) : super(const AsyncValue.data(UserGoals())) {
    _loadGoals();
  }

  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadGoals() async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) {
        state = const AsyncValue.data(UserGoals());
        return;
      }

      final doc = await _firestore
          .collection('user_goals')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        state = AsyncValue.data(UserGoals.fromJson(doc.data()!));
      } else {
        state = const AsyncValue.data(UserGoals());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWorkoutsPerWeek(int value) async {
    final currentGoals = state.value ?? const UserGoals();
    final newGoals = currentGoals.copyWith(workoutsPerWeek: value.clamp(1, 7));
    await _saveGoals(newGoals);
  }

  Future<void> updateWeeklyVolumeTarget(int value) async {
    final currentGoals = state.value ?? const UserGoals();
    final newGoals = currentGoals.copyWith(weeklyVolumeTarget: value.clamp(1000, 50000));
    await _saveGoals(newGoals);
  }

  Future<void> _saveGoals(UserGoals goals) async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) return;

      await _firestore
          .collection('user_goals')
          .doc(user.uid)
          .set(goals.toJson(), SetOptions(merge: true));

      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/providers/user_goals_provider.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/providers/user_goals_provider.dart
git commit -m "feat(profile): add user goals provider for weekly targets"
```

---

## Task 3: Widget MetricRingCard

**Files:**
- Create: `lib/features/profile/presentation/widgets/metric_ring_card.dart`

**Step 1: Creare il widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_progress_indicators.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Compact ring card for displaying a single metric
class MetricRingCard extends StatelessWidget {
  const MetricRingCard({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    this.onTap,
    this.displayValue,
  });

  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? displayValue; // Override for display (e.g., "3/4" instead of percentage)

  @override
  Widget build(BuildContext context) {
    final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final display = displayValue ?? '${(progress * 100).toInt()}%';

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnhancedProgressRing(
              progress: progress,
              size: 64,
              strokeWidth: 6,
              progressColor: color,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(
                display,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/widgets/metric_ring_card.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/widgets/metric_ring_card.dart
git commit -m "feat(profile): add MetricRingCard widget with EnhancedProgressRing"
```

---

## Task 4: Widget QuickActionChips

**Files:**
- Create: `lib/features/profile/presentation/widgets/quick_action_chips.dart`

**Step 1: Creare il widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// M3-compliant quick action chips for profile
class QuickActionChips extends StatelessWidget {
  const QuickActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionChip(
            icon: AppIcons.analytics,
            label: context.l10n.stats,
            onTap: () => context.pushNamed(AppRoutes.analyticsName),
          ),
          _ActionChip(
            icon: AppIcons.history,
            label: context.l10n.workoutHistory,
            onTap: () => context.pushNamed(AppRoutes.workoutHistoryName),
          ),
          _ActionChip(
            icon: AppIcons.bodyMeasurements,
            label: context.l10n.measurements,
            onTap: () => context.pushNamed(AppRoutes.bodyMeasurementsName),
          ),
          _ActionChip(
            icon: AppIcons.calendar,
            label: context.l10n.calendar,
            onTap: () => context.pushNamed(AppRoutes.streakCalendarName),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colors.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/widgets/quick_action_chips.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/widgets/quick_action_chips.dart
git commit -m "feat(profile): add M3-compliant QuickActionChips widget"
```

---

## Task 5: Widget CompactProfileHeader

**Files:**
- Create: `lib/features/profile/presentation/widgets/compact_profile_header.dart`

**Step 1: Creare il widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:intl/intl.dart';

/// Compact profile header with avatar on left, info on right
class CompactProfileHeader extends ConsumerWidget {
  const CompactProfileHeader({
    super.key,
    required this.userName,
    required this.memberSince,
    required this.onSettingsTap,
    required this.onEditTap,
  });

  final String userName;
  final DateTime? memberSince;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementData = ref.watch(achievementXPProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final workoutCountAsync = ref.watch(completedWorkoutsCountProvider);

    final totalXP = achievementData.value?.totalXP ?? 0;
    final tier = _getTierFromXP(totalXP);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: action icons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    AppIcons.edit,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEditTap();
                  },
                  tooltip: context.l10n.edit,
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.settingsOutlined,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSettingsTap();
                  },
                  tooltip: context.l10n.settings,
                ),
              ],
            ),

            // Main content: avatar + info
            Row(
              children: [
                // Avatar with tier border
                _TierAvatar(
                  userName: userName,
                  tier: tier,
                  totalXP: totalXP,
                ),
                const SizedBox(width: 16),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Streak row
                      streakAsync.when(
                        data: (streak) => Row(
                          children: [
                            Text(
                              '🔥',
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.streakDays(streak),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 2),

                      // Workout count
                      workoutCountAsync.when(
                        data: (count) => Row(
                          children: [
                            Text(
                              '💪',
                              style: context.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.totalWorkouts(count),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tier progress
            if (tier.nextTier != null) ...[
              const SizedBox(height: 12),
              _TierProgressBar(
                currentXP: totalXP,
                tier: tier,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ProfileTier _getTierFromXP(int xp) {
    if (xp >= 5000) {
      return _ProfileTier.platinum;
    } else if (xp >= 2000) {
      return _ProfileTier.gold;
    } else if (xp >= 1000) {
      return _ProfileTier.silver;
    } else if (xp >= 500) {
      return _ProfileTier.bronze;
    } else {
      return _ProfileTier.starter;
    }
  }
}

enum _ProfileTier {
  starter(0, 500, 'Starter', Color(0xFF9E9E9E), '🏋️'),
  bronze(500, 1000, 'Bronze', Color(0xFFCD7F32), '🥉'),
  silver(1000, 2000, 'Silver', Color(0xFFC0C0C0), '🥈'),
  gold(2000, 5000, 'Gold', Color(0xFFFFD700), '🥇'),
  platinum(5000, null, 'Platinum', Color(0xFFE5E4E2), '🏆');

  const _ProfileTier(this.minXP, this.maxXP, this.name, this.color, this.emoji);

  final int minXP;
  final int? maxXP;
  final String name;
  final Color color;
  final String emoji;

  _ProfileTier? get nextTier {
    final index = _ProfileTier.values.indexOf(this);
    if (index < _ProfileTier.values.length - 1) {
      return _ProfileTier.values[index + 1];
    }
    return null;
  }
}

class _TierAvatar extends StatelessWidget {
  const _TierAvatar({
    required this.userName,
    required this.tier,
    required this.totalXP,
  });

  final String userName;
  final _ProfileTier tier;
  final int totalXP;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            tier.color,
            tier.color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surface,
        ),
        child: Center(
          child: Text(
            tier.emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}

class _TierProgressBar extends StatelessWidget {
  const _TierProgressBar({
    required this.currentXP,
    required this.tier,
  });

  final int currentXP;
  final _ProfileTier tier;

  @override
  Widget build(BuildContext context) {
    final nextTier = tier.nextTier;
    if (nextTier == null) return const SizedBox.shrink();

    final progressInTier = currentXP - tier.minXP;
    final tierRange = nextTier.minXP - tier.minXP;
    final progress = (progressInTier / tierRange).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tier.name,
              style: context.textTheme.labelSmall?.copyWith(
                color: tier.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              nextTier.name,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(tier.color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/widgets/compact_profile_header.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/widgets/compact_profile_header.dart
git commit -m "feat(profile): add CompactProfileHeader with tier system"
```

---

## Task 6: Widget ModernWorkoutCard

**Files:**
- Create: `lib/features/profile/presentation/widgets/modern_workout_card.dart`

**Step 1: Creare il widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Modern workout card with exercise preview
class ModernWorkoutCard extends StatelessWidget {
  const ModernWorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  final WorkoutHistoryDetail workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final exercises = workout.exercises;
    final exerciseNames = exercises.map((e) => e.exerciseName).toList();
    final visibleExercises = exerciseNames.take(3).toList();
    final remainingCount = exerciseNames.length - 3;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  _getWorkoutEmoji(workout.name),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatRelativeDate(context, workout.completedAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${workout.duration.inMinutes} min',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Exercise chips
            if (exerciseNames.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...visibleExercises.map((name) => _ExerciseChip(name: name)),
                  if (remainingCount > 0)
                    _MoreChip(
                      count: remainingCount,
                      onTap: onTap,
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Progress bar + badge
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _getIntensityFactor(workout),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getIntensityBadge(workout),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWorkoutEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('push') || lower.contains('chest') || lower.contains('petto')) {
      return '🏋️';
    } else if (lower.contains('pull') || lower.contains('back') || lower.contains('schiena')) {
      return '🔙';
    } else if (lower.contains('leg') || lower.contains('gambe')) {
      return '🦵';
    } else if (lower.contains('arm') || lower.contains('braccia')) {
      return '💪';
    } else if (lower.contains('shoulder') || lower.contains('spalle')) {
      return '🎯';
    } else if (lower.contains('full') || lower.contains('total')) {
      return '🔥';
    }
    return '🏋️';
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    final timeFormat = DateFormat.Hm(context.l10n.localeName);
    final time = timeFormat.format(date);

    if (difference == 0) {
      return context.l10n.todayAt(time);
    } else if (difference == 1) {
      return context.l10n.yesterdayAt(time);
    } else if (difference < 7) {
      return context.l10n.daysAgo(difference);
    } else {
      return DateFormat.yMMMd(context.l10n.localeName).format(date);
    }
  }

  double _getIntensityFactor(WorkoutHistoryDetail workout) {
    // Simple heuristic: more exercises + longer duration = higher intensity
    final exerciseCount = workout.exercises.length;
    final duration = workout.duration.inMinutes;

    // Normalize: assume 8 exercises and 60 min is "max"
    final exerciseFactor = (exerciseCount / 8).clamp(0.0, 1.0);
    final durationFactor = (duration / 60).clamp(0.0, 1.0);

    return ((exerciseFactor + durationFactor) / 2).clamp(0.3, 1.0);
  }

  String _getIntensityBadge(WorkoutHistoryDetail workout) {
    final intensity = _getIntensityFactor(workout);
    if (intensity >= 0.8) return '⚡'; // PR / intense
    if (intensity >= 0.6) return '🔥'; // Good
    return '💪'; // Normal
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // Abbreviate long names
    final displayName = name.length > 10 ? '${name.substring(0, 8)}...' : name;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          displayName,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.andNMore(count),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.arrow_forward_ios,
            size: 10,
            color: context.colors.primary,
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/widgets/modern_workout_card.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/widgets/modern_workout_card.dart
git commit -m "feat(profile): add ModernWorkoutCard with exercise preview"
```

---

## Task 7: Refactor ProfileHubScreen

**Files:**
- Modify: `lib/features/profile/presentation/screens/profile_hub_screen.dart`

**Step 1: Aggiornare imports e struttura**

Sostituire l'intero contenuto del file con la nuova implementazione:

```dart
/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Profile Hub
/// Type: Screen
///
/// Modern profile hub with compact header, ring metrics, quick actions, and workout feed.
/// Apple Fitness+ inspired design with tier system and achievement integration.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

import '../providers/user_goals_provider.dart';
import '../widgets/compact_profile_header.dart';
import '../widgets/metric_ring_card.dart';
import '../widgets/quick_action_chips.dart';
import '../widgets/modern_workout_card.dart';

/// Profile hub screen - modern Apple Fitness+ inspired design
class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, ref, user),
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, user) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Compact header with avatar and stats
          SliverToBoxAdapter(
            child: CompactProfileHeader(
              userName: user?.displayName ?? context.l10n.profile,
              memberSince: user?.metadata.creationTime,
              onSettingsTap: () => context.pushNamed(AppRoutes.settingsName),
              onEditTap: () => context.pushNamed(AppRoutes.editProfileName),
            ),
          ),

          // Ring cards section
          SliverToBoxAdapter(
            child: _RingCardsSection(),
          ),

          // Quick action chips
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: QuickActionChips(),
            ),
          ),

          // Recent workouts feed
          SliverToBoxAdapter(
            child: _RecentWorkoutsFeed(),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Ring cards showing key metrics
class _RingCardsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(userGoalsProvider);
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    final goals = goalsAsync.value ?? const UserGoals();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Streak Weeks
          Expanded(
            child: streakAsync.when(
              data: (streak) {
                // Calculate "week streak" - consecutive weeks hitting goal
                // For now, use day streak / 7 as approximation
                final weekStreak = (streak / 7).floor();
                return MetricRingCard(
                  value: weekStreak.toDouble(),
                  maxValue: 4, // 4 week target
                  label: context.l10n.streakWeeks,
                  color: context.colors.success,
                  displayValue: '$weekStreak',
                  onTap: () => _showStreakDetail(context, streak),
                );
              },
              loading: () => MetricRingCard(
                value: 0,
                maxValue: 4,
                label: context.l10n.streakWeeks,
                color: context.colors.success,
                displayValue: '-',
              ),
              error: (_, __) => MetricRingCard(
                value: 0,
                maxValue: 4,
                label: context.l10n.streakWeeks,
                color: context.colors.success,
                displayValue: '-',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Workout this week
          Expanded(
            child: workoutsAsync.when(
              data: (workouts) {
                final thisWeek = _countWorkoutsThisWeek(workouts);
                return MetricRingCard(
                  value: thisWeek.toDouble(),
                  maxValue: goals.workoutsPerWeek.toDouble(),
                  label: context.l10n.workoutWeek,
                  color: context.colors.primary,
                  displayValue: '$thisWeek/${goals.workoutsPerWeek}',
                  onTap: () => _showWorkoutGoalSheet(context, ref, goals),
                );
              },
              loading: () => MetricRingCard(
                value: 0,
                maxValue: goals.workoutsPerWeek.toDouble(),
                label: context.l10n.workoutWeek,
                color: context.colors.primary,
                displayValue: '-/${goals.workoutsPerWeek}',
              ),
              error: (_, __) => MetricRingCard(
                value: 0,
                maxValue: goals.workoutsPerWeek.toDouble(),
                label: context.l10n.workoutWeek,
                color: context.colors.primary,
                displayValue: '-',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Volume goal
          Expanded(
            child: workoutsAsync.when(
              data: (workouts) {
                final weeklyVolume = _calculateWeeklyVolume(workouts);
                final progress = (weeklyVolume / goals.weeklyVolumeTarget * 100).round();
                return MetricRingCard(
                  value: weeklyVolume,
                  maxValue: goals.weeklyVolumeTarget.toDouble(),
                  label: context.l10n.volumeGoal,
                  color: context.colors.secondary,
                  displayValue: '$progress%',
                  onTap: () => _showVolumeGoalSheet(context, ref, goals),
                );
              },
              loading: () => MetricRingCard(
                value: 0,
                maxValue: goals.weeklyVolumeTarget.toDouble(),
                label: context.l10n.volumeGoal,
                color: context.colors.secondary,
                displayValue: '-',
              ),
              error: (_, __) => MetricRingCard(
                value: 0,
                maxValue: goals.weeklyVolumeTarget.toDouble(),
                label: context.l10n.volumeGoal,
                color: context.colors.secondary,
                displayValue: '-',
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countWorkoutsThisWeek(List<WorkoutHistoryDetail> workouts) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    return workouts.where((w) => w.completedAt.isAfter(weekStartDate)).length;
  }

  double _calculateWeeklyVolume(List<WorkoutHistoryDetail> workouts) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    double totalVolume = 0;
    for (final workout in workouts.where((w) => w.completedAt.isAfter(weekStartDate))) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          final weight = double.tryParse(set.weight) ?? 0;
          final reps = int.tryParse(set.reps) ?? 0;
          totalVolume += weight * reps;
        }
      }
    }
    return totalVolume;
  }

  void _showStreakDetail(BuildContext context, int streak) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.streakWeeks,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.consecutiveWeeks((streak / 7).floor()),
              style: context.textTheme.bodyLarge,
            ),
            Text(
              context.l10n.streakDays(streak),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showWorkoutGoalSheet(BuildContext context, WidgetRef ref, UserGoals goals) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _GoalEditSheet(
        title: context.l10n.workoutsPerWeek,
        currentValue: goals.workoutsPerWeek,
        minValue: 1,
        maxValue: 7,
        onSave: (value) {
          ref.read(userGoalsProvider.notifier).updateWorkoutsPerWeek(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showVolumeGoalSheet(BuildContext context, WidgetRef ref, UserGoals goals) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _GoalEditSheet(
        title: context.l10n.weeklyVolumeTarget,
        currentValue: goals.weeklyVolumeTarget ~/ 1000,
        minValue: 1,
        maxValue: 50,
        suffix: 'k kg',
        onSave: (value) {
          ref.read(userGoalsProvider.notifier).updateWeeklyVolumeTarget(value * 1000);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Goal edit bottom sheet
class _GoalEditSheet extends StatefulWidget {
  const _GoalEditSheet({
    required this.title,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.onSave,
    this.suffix,
  });

  final String title;
  final int currentValue;
  final int minValue;
  final int maxValue;
  final String? suffix;
  final void Function(int) onSave;

  @override
  State<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<_GoalEditSheet> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _value > widget.minValue
                    ? () => setState(() => _value--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 24),
              Text(
                widget.suffix != null ? '$_value ${widget.suffix}' : '$_value',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: _value < widget.maxValue
                    ? () => setState(() => _value++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => widget.onSave(_value),
              child: Text(context.l10n.save),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Recent workouts feed with modern cards
class _RecentWorkoutsFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.recentWorkouts,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(AppRoutes.workoutHistoryName),
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          workoutsAsync.when(
            data: (workouts) => _buildWorkoutsList(context, workouts),
            loading: () => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: LoadingIndicator()),
            ),
            error: (_, __) => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  context.l10n.errorLoadingData,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, List<WorkoutHistoryDetail> workouts) {
    if (workouts.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            context.l10n.noRecentWorkouts,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Show last 3 workouts with staggered animation
    final recentWorkouts = workouts.take(3).toList();

    return Column(
      children: recentWorkouts.asMap().entries.map((entry) {
        final index = entry.key;
        final workout = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ModernWorkoutCard(
            workout: workout,
            onTap: () {
              // Navigate to workout detail
              context.pushNamed(
                AppRoutes.workoutDetailName,
                pathParameters: {'id': workout.id},
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
```

**Step 2: Verificare che compili**

Run: `flutter analyze lib/features/profile/presentation/screens/profile_hub_screen.dart`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/screens/profile_hub_screen.dart
git commit -m "feat(profile): refactor ProfileHubScreen with modern Apple Fitness+ design"
```

---

## Task 8: Final Verification

**Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues in profile feature

**Step 2: Test dark/light mode**

Manual test: Toggle theme in settings and verify profile looks good in both

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat(profile): complete profile hub redesign with modern UI

- Add CompactProfileHeader with tier system
- Add MetricRingCard with EnhancedProgressRing
- Add QuickActionChips M3-compliant
- Add ModernWorkoutCard with exercise preview
- Add UserGoalsProvider for weekly targets
- Add localization keys (EN/IT)
- Integrate with achievement XP system for tier display"
```

---

## Summary

| Task | Description | Est. Time |
|------|-------------|-----------|
| 1 | Localization keys | 10 min |
| 2 | UserGoalsProvider | 15 min |
| 3 | MetricRingCard | 10 min |
| 4 | QuickActionChips | 10 min |
| 5 | CompactProfileHeader | 20 min |
| 6 | ModernWorkoutCard | 20 min |
| 7 | ProfileHubScreen refactor | 25 min |
| 8 | Final verification | 10 min |

**Total: ~2 hours**
