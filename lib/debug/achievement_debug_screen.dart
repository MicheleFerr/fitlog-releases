/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: debug
/// 🎯 Feature: Achievement Notification Debug Screen
/// 🔧 Type: Debug UI Screen
///
/// Visual testing tool for all 13 mock achievements.
/// Navigate to this screen to preview how each achievement looks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/mock_achievement_notification_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Debug screen to test all mock achievements visually
class AchievementDebugScreen extends ConsumerWidget {
  const AchievementDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockService = ref.read(mockAchievementNotificationServiceProvider);
    final allAchievements = mockService.getAllMockAchievements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement Mock Data (13 items)'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.shuffle),
            onPressed: () {
              final random = mockService.getRandomMockAchievement();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Random: ${random.title}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Get Random Achievement',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: allAchievements.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          return _AchievementCard(
            achievement: achievement,
            index: index + 1,
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final MockAchievement achievement;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.index,
  });

  Color _getTypeColor(BuildContext context, MockAchievementType type) {
    switch (type) {
      case MockAchievementType.personalRecord:
        return context.colors.error; // Red for PRs
      case MockAchievementType.workoutStreak:
        return context.colors.warning; // Orange for streaks
      case MockAchievementType.goalCompletion:
        return context.colors.success; // Green for goals
      case MockAchievementType.milestone:
        return context.colors.primary; // Blue for milestones
    }
  }

  IconData _getTypeIcon(MockAchievementType type) {
    switch (type) {
      case MockAchievementType.personalRecord:
        return AppIcons.trendingUp;
      case MockAchievementType.workoutStreak:
        return AppIcons.streak;
      case MockAchievementType.goalCompletion:
        return AppIcons.flag;
      case MockAchievementType.milestone:
        return AppIcons.stars;
    }
  }

  String _getTypeName(MockAchievementType type) {
    switch (type) {
      case MockAchievementType.personalRecord:
        return 'Personal Record';
      case MockAchievementType.workoutStreak:
        return 'Workout Streak';
      case MockAchievementType.goalCompletion:
        return 'Goal Completion';
      case MockAchievementType.milestone:
        return 'Milestone';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(context, achievement.type);
    final typeIcon = _getTypeIcon(achievement.type);
    final typeName = _getTypeName(achievement.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Simulate notification trigger
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  if (achievement.emoji != null)
                    Text(
                      achievement.emoji!,
                      style: context.textTheme.headlineMedium,
                    ),
                  if (achievement.emoji != null) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          achievement.title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: typeColor.withValues(alpha: 0.9),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Index badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          size: 16,
                          color: typeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          typeName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Emoji
                  if (achievement.emoji != null)
                    Text(
                      achievement.emoji!,
                      style: context.textTheme.headlineMedium,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                achievement.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                achievement.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Tap to test hint
              Row(
                children: [
                  Icon(
                    AppIcons.info,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to simulate notification',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
