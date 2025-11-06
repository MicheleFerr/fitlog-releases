/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// STATS DASHBOARD - Statistics overview for routine
///
/// Features:
/// - Progress percentage
/// - Adherence rate
/// - Skip rate
/// - Current streak
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Dashboard showing routine statistics
class StatsDashboard extends StatelessWidget {

  const StatsDashboard({
    super.key,
    required this.routine,
  });
  final FlexibleRoutine routine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primaryContainer.withValues(alpha: 0.3),
            context.colors.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.analytics,
                color: context.colors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Progress Overview',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    '${(routine.progressPercentage * 100).toInt()}%',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: routine.progressPercentage,
                  minHeight: 12,
                  backgroundColor:
                      context.colors.primaryContainer.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(context.colors.primary),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${routine.completedDays} of ${routine.totalWorkoutDays} workouts completed',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: AppIcons.trendUp,
                  label: 'Adherence',
                  value: '${routine.adherenceRate.toInt()}%',
                  color: _getAdherenceColor(routine.adherenceRate, context),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: AppIcons.streak,
                  label: 'Streak',
                  value: '${routine.currentStreak}',
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: AppIcons.eventBusy,
                  label: 'Skips',
                  value: '${routine.skipTracker.totalSkips}',
                  color: context.colors.error,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: AppIcons.refresh,
                  label: 'Recovered',
                  value: '${routine.skipTracker.totalRecoveries}',
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAdherenceColor(double adherence, BuildContext context) {
    if (adherence >= 80) {
      return context.colors.success;
    } else if (adherence >= 60) {
      return context.colors.secondary;
    } else {
      return context.colors.error;
    }
  }
}
