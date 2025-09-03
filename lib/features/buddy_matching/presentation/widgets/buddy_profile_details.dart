/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: buddy_matching
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: None
 * - Firebase: None
 * - Hive: None
 */

import 'package:flutter/material.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/buddy_profile.dart';
import 'fitness_level_badge.dart';
import 'workout_goals_chips.dart';
import 'instagram_link_button.dart';

class BuddyProfileDetails extends StatelessWidget {
  final BuddyProfile profile;

  const BuddyProfileDetails({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.viewProfile,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header
                      _buildProfileHeader(context, theme, l10n),
                      const SizedBox(height: 24),

                      // Basic info
                      _buildBasicInfo(context, theme, l10n),
                      const SizedBox(height: 24),

                      // Workout preferences
                      _buildWorkoutPreferences(context, theme, l10n),
                      const SizedBox(height: 24),

                      // Schedule
                      _buildSchedule(context, theme, l10n),
                      const SizedBox(height: 24),

                      // Stats
                      _buildStats(context, theme, l10n),
                      const SizedBox(height: 24),

                      // Badges
                      if (profile.badges.isNotEmpty)
                        _buildBadges(context, theme, l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Profile photo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: profile.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    profile.photoURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildProfilePlaceholder(theme),
                  ),
                )
              : _buildProfilePlaceholder(theme),
        ),

        const SizedBox(height: 16),

        // Name and verification
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.displayName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile.isVerified) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: Colors.blue,
                size: 24,
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Online status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: profile.isOnline 
                ? Colors.green.withValues(alpha: 0.2)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            profile.onlineStatus,
            style: theme.textTheme.bodySmall?.copyWith(
              color: profile.isOnline 
                  ? Colors.green.shade700
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePlaceholder(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.white,
    );
  }

  Widget _buildBasicInfo(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Bio
            if (profile.preferences.bio != null && profile.preferences.bio!.isNotEmpty) ...[
              Text(
                profile.preferences.bio!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fitness level
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                FitnessLevelBadge(level: profile.preferences.fitnessLevel),
              ],
            ),

            const SizedBox(height: 12),

            // Location
            if (profile.preferences.locationName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.preferences.locationName!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Instagram
            if (profile.preferences.instagramHandle != null)
              InstagramLinkButton(
                handle: profile.preferences.instagramHandle!,
                compact: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPreferences(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.workoutGoals,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (profile.preferences.goals.isNotEmpty)
              WorkoutGoalsChips(
                goals: profile.preferences.goals,
                compact: false,
              )
            else
              Text(
                'Nessun obiettivo specificato',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orari Preferiti',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (profile.preferences.preferredTimes.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.preferences.preferredTimes.map((time) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      time.displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                'Orari non specificati',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            if (profile.preferences.preferredDays.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Giorni Preferiti:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.preferences.preferredDays.map((day) => 
                  day.substring(0, 1).toUpperCase() + day.substring(1)
                ).join(', '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    theme,
                    Icons.fitness_center,
                    '${profile.totalWorkouts}',
                    l10n.workouts,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    theme,
                    Icons.handshake,
                    '${profile.partnershipsCount}',
                    l10n.partnerships,
                  ),
                ),
                if (profile.averageRating > 0)
                  Expanded(
                    child: _buildStatItem(
                      context,
                      theme,
                      Icons.star,
                      profile.averageRating.toStringAsFixed(1),
                      l10n.rating,
                    ),
                  ),
              ],
            ),

            if (profile.partnershipsCount > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tasso di successo: ${profile.successRate.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badge',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.badges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.withValues(alpha: 0.2),
                        Colors.orange.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getBadgeIcon(badge),
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBadgeIcon(BadgeType badge) {
    switch (badge) {
      case BadgeType.workoutBuddy:
        return Icons.handshake;
      case BadgeType.consistentPartner:
        return Icons.trending_up;
      case BadgeType.motivator:
        return Icons.psychology;
      case BadgeType.newbie:
        return Icons.star;
      case BadgeType.veteran:
        return Icons.workspace_premium;
      case BadgeType.verified:
        return Icons.verified;
    }
  }
}