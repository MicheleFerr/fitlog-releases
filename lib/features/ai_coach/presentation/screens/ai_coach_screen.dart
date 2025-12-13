/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// AI Coach Screen - Main recovery insights screen
///
/// **Displays**:
/// - Tier Progress Cards (3-tier unlock system)
/// - Readiness Score (Basic tier - always visible)
/// - Muscle Recovery Data (Intermediate tier - if unlocked)
/// - Overtraining Risk (Advanced tier - if unlocked)
///
/// **Features**:
/// - Auto-dispose providers (memory optimized)
/// - Loading states for each section
/// - Error handling with retry
/// - Tap navigation to tier details
///
/// **Navigation**:
/// - Entry point: Settings screen or Home dashboard
/// - Route: /ai-coach
///
/// **Usage**:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const AICoachScreen()),
/// );
/// // or
/// context.push('/ai-coach');
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/recovery_insights_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/tier_progress_indicator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/readiness_score.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/muscle_recovery_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/overtraining_risk.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// AI Coach Screen - main recovery insights UI
///
/// **State Management**: Riverpod ConsumerWidget
/// **Auto-dispose**: Yes (all providers auto-dispose when unmounted)
class AICoachScreen extends ConsumerWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tierStatusesAsync = ref.watch(tierStatusesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiCoach),
        elevation: 0,
      ),
      body: tierStatusesAsync.when(
        data: (statuses) => _buildContent(context, ref, statuses),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildError(context, ref, error),
      ),
    );
  }

  /// Build main content with all sections
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<RecoveryTierStatus> statuses,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Clear cache and refetch
        await ref.read(clearCacheProvider.future);
        ref.invalidate(tierStatusesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),
            const SizedBox(height: 24),

            // Tier Progress Cards
            TierProgressList(
              tierStatuses: statuses,
              onTierTap: (tier) => _showTierDetails(context, tier),
            ),
            const SizedBox(height: 32),

            // Insights Section Header
            Text(
              context.l10n.recovery_tier_basic,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Basic Tier Content (always visible)
            _buildBasicTierContent(context, ref),
            const SizedBox(height: 24),

            // Intermediate Tier Content (if unlocked)
            if (statuses
                .firstWhere((s) => s.tier == RecoveryTier.intermediate)
                .isUnlocked) ...[
              Text(
                context.l10n.recovery_tier_intermediate,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildIntermediateTierContent(context, ref),
              const SizedBox(height: 24),
            ],

            // Advanced Tier Content (if unlocked)
            if (statuses
                .firstWhere((s) => s.tier == RecoveryTier.advanced)
                .isUnlocked) ...[
              Text(
                context.l10n.recovery_tier_advanced,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAdvancedTierContent(context, ref),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  /// Build header with title and description
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.insights,
              semanticLabel: 'Recovery Insights',
              size: AppIconSize.xxlarge,
              color: context.colors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recovery Insights',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock advanced insights by completing workouts',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Basic Tier content (Readiness Score)
  Widget _buildBasicTierContent(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(readinessScoreProvider);

    return readinessAsync.when(
      data: (score) => _buildReadinessCard(context, score),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: LoadingIndicator()),
        ),
      ),
      error: (error, _) => _buildLockedCard(
        context,
        'Readiness Score',
        'Complete 6 workouts over 14 days to unlock',
        AppIcons.lock,
      ),
    );
  }

  /// Build readiness score card
  Widget _buildReadinessCard(BuildContext context, ReadinessScore score) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: 'Readiness',
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Readiness Score',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    '${score.score}',
                    style: context.textTheme.displayLarge?.copyWith(
                      color: _getReadinessColor(context, score.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getReadinessCategoryText(context, score.category),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: _getReadinessColor(context, score.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getReadinessDescription(score.category),
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Intermediate Tier content (Muscle Recovery)
  Widget _buildIntermediateTierContent(BuildContext context, WidgetRef ref) {
    final muscleRecoveryAsync = ref.watch(muscleRecoveryProvider);

    return muscleRecoveryAsync.when(
      data: (data) => _buildMuscleRecoveryCard(context, data),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: LoadingIndicator()),
        ),
      ),
      error: (error, _) => _buildLockedCard(
        context,
        'Muscle Recovery',
        'Complete 12 workouts over 28 days to unlock',
        AppIcons.lock,
      ),
    );
  }

  /// Build muscle recovery card
  Widget _buildMuscleRecoveryCard(
    BuildContext context,
    MuscleRecoveryData data,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.analytics,
                  semanticLabel: 'Muscle Recovery',
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Muscle Recovery',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...data.muscleGroups.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getMuscleGroupText(context, entry.key),
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRecoveryStatusText(context, entry.value.status),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: _getRecoveryColor(
                                context,
                                entry.value.status,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRecoveryColor(context, entry.value.status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value.daysSinceLastWorkout}d ago',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: _getRecoveryColor(context, entry.value.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build Advanced Tier content (Overtraining Risk)
  Widget _buildAdvancedTierContent(BuildContext context, WidgetRef ref) {
    final overtrainingAsync = ref.watch(overtrainingRiskProvider);

    return overtrainingAsync.when(
      data: (risk) => _buildOvertrainingCard(context, risk),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: LoadingIndicator()),
        ),
      ),
      error: (error, _) => _buildLockedCard(
        context,
        'Overtraining Risk',
        'Complete 20 workouts over 42 days to unlock',
        AppIcons.lock,
      ),
    );
  }

  /// Build overtraining risk card
  Widget _buildOvertrainingCard(BuildContext context, OvertrainingRisk risk) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.warning,
                  semanticLabel: 'Overtraining Risk',
                  size: AppIconSize.large,
                  color: _getRiskColor(context, risk.riskLevel),
                ),
                const SizedBox(width: 12),
                Text(
                  'Overtraining Risk',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRiskColor(context, risk.riskLevel)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRiskColor(context, risk.riskLevel),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRiskLevelText(context, risk.riskLevel),
                          style: context.textTheme.titleMedium?.copyWith(
                            color: _getRiskColor(context, risk.riskLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TSB: ${risk.tsbScore.toStringAsFixed(1)}',
                          style: context.textTheme.bodyLarge,
                        ),
                        Text(
                          'HRV Deviation: ${risk.hrvDeviation.toStringAsFixed(1)}%',
                          style: context.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRiskDescription(risk.riskLevel),
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build locked tier card
  Widget _buildLockedCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: 'Locked',
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: 'Error',
              size: AppIconSize.xxlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading recovery insights',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(tierStatusesProvider);
              },
              icon: const SemanticIcon(
  icon: AppIcons.refresh,
  semanticLabel: 'Refresh',
),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show tier details (placeholder for future implementation)
  void _showTierDetails(BuildContext context, RecoveryTier tier) {
    // TODO: Navigate to detailed tier screen
    SnackBarService.showInfo(context, 'Tier details: ${tier.displayName}');
  }

  // Helper methods for colors and text

  Color _getReadinessColor(BuildContext context, ReadinessCategory category) {
    switch (category) {
      case ReadinessCategory.optimal:
        return context.colors.success;
      case ReadinessCategory.good:
        return context.colors.primary;
      case ReadinessCategory.moderate:
        return context.colors.warning;
      case ReadinessCategory.low:
        return context.colors.error;
      case ReadinessCategory.veryLow:
        return context.colors.error;
      case ReadinessCategory.locked:
        return context.colors.onSurfaceVariant;
    }
  }

  String _getReadinessCategoryText(
    BuildContext context,
    ReadinessCategory category,
  ) {
    switch (category) {
      case ReadinessCategory.optimal:
        return context.l10n.readiness_optimal;
      case ReadinessCategory.good:
        return context.l10n.readiness_good;
      case ReadinessCategory.moderate:
        return context.l10n.readiness_moderate;
      case ReadinessCategory.low:
        return context.l10n.readiness_low;
      case ReadinessCategory.veryLow:
        return context.l10n.readiness_very_low;
      case ReadinessCategory.locked:
        return context.l10n.readiness_locked;
    }
  }

  String _getReadinessDescription(ReadinessCategory category) {
    switch (category) {
      case ReadinessCategory.optimal:
        return 'Your body is fully recovered and ready for high-intensity training';
      case ReadinessCategory.good:
        return 'Good recovery status - suitable for moderate to high intensity';
      case ReadinessCategory.moderate:
        return 'Moderate recovery - consider light to moderate intensity';
      case ReadinessCategory.low:
        return 'Low recovery - focus on light activity or active recovery';
      case ReadinessCategory.veryLow:
        return 'Very low recovery - rest day recommended';
      case ReadinessCategory.locked:
        return 'Complete more workouts to unlock readiness tracking';
    }
  }

  Color _getRecoveryColor(BuildContext context, RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.fullyRecovered:
        return context.colors.success;
      case RecoveryStatus.recovered:
        return context.colors.primary;
      case RecoveryStatus.partiallyRecovered:
        return context.colors.warning;
      case RecoveryStatus.fatigued:
        return context.colors.error;
    }
  }

  String _getRecoveryStatusText(BuildContext context, RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.fullyRecovered:
        return context.l10n.recovery_fully_recovered;
      case RecoveryStatus.recovered:
        return context.l10n.recovery_recovered;
      case RecoveryStatus.partiallyRecovered:
        return context.l10n.recovery_partially_recovered;
      case RecoveryStatus.fatigued:
        return context.l10n.recovery_fatigued;
    }
  }

  String _getMuscleGroupText(BuildContext context, MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return context.l10n.muscle_group_chest;
      case MuscleGroup.back:
        return context.l10n.muscle_group_back;
      case MuscleGroup.shoulders:
        return context.l10n.muscle_group_shoulders;
      case MuscleGroup.biceps:
        return context.l10n.muscle_group_biceps;
      case MuscleGroup.triceps:
        return context.l10n.muscle_group_triceps;
      case MuscleGroup.legs:
        return context.l10n.muscle_group_legs;
      case MuscleGroup.core:
        return context.l10n.muscle_group_core;
    }
  }

  Color _getRiskColor(BuildContext context, RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return context.colors.success;
      case RiskLevel.moderate:
        return context.colors.warning;
      case RiskLevel.high:
        return context.colors.error;
      case RiskLevel.veryHigh:
        return context.colors.error;
      case RiskLevel.locked:
        return context.colors.onSurfaceVariant;
    }
  }

  String _getRiskLevelText(BuildContext context, RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return context.l10n.risk_level_low;
      case RiskLevel.moderate:
        return context.l10n.risk_level_moderate;
      case RiskLevel.high:
        return context.l10n.risk_level_high;
      case RiskLevel.veryHigh:
        return context.l10n.risk_level_very_high;
      case RiskLevel.locked:
        return 'Locked';
    }
  }

  String _getRiskDescription(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Your training load is well-balanced. You can continue your current program';
      case RiskLevel.moderate:
        return 'Slightly elevated fatigue. Consider adding a deload week soon';
      case RiskLevel.high:
        return 'High accumulated fatigue. Reduce volume or take a deload week';
      case RiskLevel.veryHigh:
        return 'Very high risk - immediate rest or significant volume reduction recommended';
      case RiskLevel.locked:
        return 'Complete 20 workouts over 42 days to unlock overtraining risk tracking';
    }
  }
}
