/// Coach Dashboard Screen
///
/// Main dashboard for coaches showing:
/// - Athletes summary with quick access
/// - Today's stats (completed, in progress, to plan)
/// - Coach code for sharing
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/athlete_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

/// Coach dashboard screen - main hub for coaches
class CoachDashboardScreen extends ConsumerWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar.large(
            title: Text(context.l10n.coachModeTitle),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.settingsOutlined),
                onPressed: () {
                  context.pushNamed(AppRoutes.coachSettingsName);
                },
                tooltip: context.l10n.settings,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  _QuickActionsSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Athletes section
                  _AthletesSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Today's stats
                  _TodayStatsSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Coach code section
                  _CoachCodeSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // TODO section (future)
                  // _TodoSection(),
                ],
              ),
            ),
          ),

          // Bottom padding for tab bar overlay
          const SliverTabBarBottomPadding(),
        ],
      ),
    );
  }
}

/// Quick actions row for coach dashboard
class _QuickActionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(totalUnreadCountProvider);
    final unreadCount = unreadCountAsync.value ?? 0;

    return Column(
      children: [
        // First row: Templates + Athletes
        Row(
          children: [
            // Templates button
            Expanded(
              child: _QuickActionCard(
                icon: AppIcons.template,
                label: context.l10n.coachTemplates,
                color: context.colors.primary,
                onTap: () => context.pushNamed(AppRoutes.coachTemplatesName),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Athletes button
            Expanded(
              child: _QuickActionCard(
                icon: AppIcons.peopleOutline,
                label: context.l10n.athletes,
                color: context.colors.tertiary,
                onTap: () => context.pushNamed(AppRoutes.athletesListName),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Second row: Messages (full width)
        _QuickActionCard(
          icon: AppIcons.chatBubbleOutline,
          label: context.l10n.messages,
          color: context.colors.secondary,
          badge: unreadCount > 0 ? unreadCount : null,
          onTap: () => context.pushNamed(AppRoutes.conversationsName),
        ),
      ],
    );
  }
}

/// Individual quick action card
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    // Accessibility: Quick action card with semantic label
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: AppIconSize.medium),
                  if (badge != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badge! > 99 ? '99+' : badge.toString(),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// Section showing athletes with quick access
class _AthletesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athletesAsync = ref.watch(athletesListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(AppIcons.peopleOutline, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.athletes,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(AppIcons.personAdd),
              onPressed: () {
                // TODO: Navigate to add athlete
              },
              tooltip: context.l10n.addAthlete,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Athletes content
        athletesAsync.when(
          data: (athletes) => _buildAthletesList(context, ref, athletes),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthletesList(
    BuildContext context,
    WidgetRef ref,
    List<CoachRelationship> athletes,
  ) {
    if (athletes.isEmpty) {
      return _buildEmptyAthletesCard(context);
    }

    // Show up to 3 athletes, then a "view all" button
    final displayAthletes = athletes.take(3).toList();
    final hasMore = athletes.length > 3;

    return Column(
      children: [
        // Athlete cards
        ...displayAthletes.map(
          (athlete) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AthleteCard(
              relationship: athlete,
              onTap: () => _navigateToAthlete(context, athlete),
              workoutStatus: AthleteWorkoutStatus.restDay,
            ),
          ),
        ),

        // View all button
        if (hasMore || athletes.isNotEmpty)
          SizedBox(
            width: double.infinity,
            // Accessibility: View all athletes button with semantic label
            child: Semantics(
              label: context.l10n.viewAllAthletes(athletes.length),
              button: true,
              child: TextButton(
                onPressed: () => _navigateToAthletesList(context),
                child: Text(context.l10n.viewAllAthletes(athletes.length)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyAthletesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.peopleOutline,
            size: 48,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.noAthletesYet,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.addYourFirstAthlete,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Accessibility: Add athlete button with semantic label
          Semantics(
            label: context.l10n.addAthlete,
            button: true,
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to add athlete
              },
              icon: const Icon(AppIcons.personAdd),
              label: Text(context.l10n.addAthlete),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAthlete(BuildContext context, CoachRelationship athlete) {
    context.pushNamed(
      AppRoutes.athleteDetailName,
      pathParameters: {'athleteId': athlete.athleteId},
      queryParameters: {'name': athlete.athleteName ?? ''},
    );
  }

  void _navigateToAthletesList(BuildContext context) {
    context.pushNamed(AppRoutes.athletesListName);
  }
}

/// Section showing today's stats
class _TodayStatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingInvitationsCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(AppIcons.insightsOutlined, color: context.colors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.todayStats,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Stats grid
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '0',
                  label: context.l10n.workoutsCompleted,
                  icon: AppIcons.completeOutline,
                  color: context.colors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: context.colors.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: '0',
                  label: context.l10n.currentlyTraining,
                  icon: AppIcons.workout,
                  color: context.colors.tertiary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: context.colors.outline.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: '$pendingCount',
                  label: context.l10n.toPlan,
                  icon: AppIcons.pendingActions,
                  color: context.colors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppIconSize.medium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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
    );
  }
}

/// Section showing coach code for sharing
class _CoachCodeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeAsync = ref.watch(coachCodeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(AppIcons.qrCode, color: context.colors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.yourCoachCode,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Code card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primaryContainer,
                context.colors.primaryContainer.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: codeAsync.when(
            data: (code) => code != null
                ? _buildCodeContent(context, code)
                : _buildNoCodeContent(context),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: LoadingIndicator(),
              ),
            ),
            error: (_, __) => _buildNoCodeContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeContent(BuildContext context, String code) {
    return Column(
      children: [
        Text(
          context.l10n.shareCodeWithAthletes,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),

        // Code display
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            code,
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _copyCode(context, code),
              icon: const Icon(AppIcons.copy, size: 18),
              label: Text(context.l10n.copyCode),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.onPrimaryContainer,
                side: BorderSide(color: context.colors.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Accessibility: Share code button with semantic label
            Semantics(
              label: context.l10n.shareCode,
              button: true,
              child: FilledButton.icon(
                onPressed: () => _shareCode(context, code),
                icon: const Icon(AppIcons.share, size: 18),
                label: Text(context.l10n.shareCode),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoCodeContent(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.generateCoachCode,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.onPrimaryContainer,
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    SnackBarService.showSuccess(context, context.l10n.codeCopied);
  }

  void _shareCode(BuildContext context, String code) {
    final message = context.l10n.shareCodeMessage(code);
    share_plus.SharePlus.instance.share(share_plus.ShareParams(text: message));
  }
}
