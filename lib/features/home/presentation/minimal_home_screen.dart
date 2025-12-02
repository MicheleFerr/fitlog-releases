import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/start_workout_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/templates_carousel_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/xp_progress_bar.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/exercise_wiki_card_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/ai_coach_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/settings_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/debug_logs_screen.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/modal_showcase_screen.dart';
import 'package:gymbro_flutter_new/features/journey_themes/presentation/providers/journey_theme_provider.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/services/journey_greeting_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Minimal Home Screen - Clean dark premium design
///
/// Structure:
/// - AppBar: Logo + Settings
/// - StartWorkoutCard: Hero CTA
/// - TemplatesCarouselCompact: Quick access to templates
/// - AICoachCard: AI insights (hidden if no data)
/// - ExerciseWikiCardCompact: Exercise wiki contributions
class MinimalHomeScreen extends ConsumerWidget {
  const MinimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryAdviceAsync = ref.watch(primaryAIAdviceProvider);
    final isAdmin = ref.watch(isAdminCachedProvider);
    final isDeveloper = ref.watch(isDeveloperProvider);
    final journeyThemeState = ref.watch(journeyThemeProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      floatingActionButton: isDeveloper
          ? FloatingActionButton(
              onPressed: () => _showDeveloperTools(context),
              backgroundColor: context.colors.tertiary,
              child: SemanticIcon(
                icon: AppIcons.code,
                semanticLabel: 'Developer Tools',
                color: context.colors.onTertiary,
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // Minimal AppBar
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: false,
            backgroundColor: context.colors.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: Text(
                'FitLog Pro',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => showSettingsBottomSheet(context),
                icon: SemanticIcon(
                  icon: AppIcons.settingsOutlined,
                  semanticLabel: context.l10n.settings,
                  size: AppIconSize.medium,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 0. Personalized Greeting
                _buildGreetingSection(context, journeyThemeState),
                const SizedBox(height: 16),

                // 0.5 XP Progress Bar
                const XPProgressBar(),
                const SizedBox(height: 20),

                // 1. Start Workout Card (Hero)
                const StartWorkoutCard(),
                const SizedBox(height: 24),

                // 2. Templates Carousel
                const TemplatesCarouselCompact(),
                const SizedBox(height: 24),

                // 3. AI Coach Card (conditional - only if insights available)
                primaryAdviceAsync.when(
                  data: (advice) {
                    if (advice != null) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: AppSpacing.xl,
                        ),
                        child: const AICoachCard(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 4. Exercise Wiki Card
                const ExerciseWikiCardCompact(),
                const SizedBox(height: 24),

                // Admin feedback card (only for admins)
                if (isAdmin) ...[
                  _AdminFeedbackCard(),
                  const SizedBox(height: 24),
                ],

                // Bottom padding for navigation bar
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build personalized greeting section based on journey theme
  Widget _buildGreetingSection(BuildContext context, JourneyThemeState state) {
    final timeOfDay = JourneyGreetingService.getCurrentTimeOfDay();
    final timeGreeting = JourneyGreetingService.getTimeGreeting(context, timeOfDay);
    final motivationalPhrase = JourneyGreetingService.getMotivationalPhrase(
      context,
      state.effectiveTheme,
      timeOfDay,
    );
    final greetingName = state.greetingName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main greeting with name
          Text(
            '$timeGreeting $greetingName,',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.journeyThemeOrDefault.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // Motivational phrase
          Text(
            motivationalPhrase,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperTools(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DeveloperToolsSheet(),
    );
  }
}

/// Developer Tools Bottom Sheet
class _DeveloperToolsSheet extends StatelessWidget {
  const _DeveloperToolsSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar (fixed)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.code,
                          size: AppIconSize.large,
                          color: context.colors.tertiary,
                          semanticLabel: 'Developer Tools',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Developer Tools',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Debug and development options',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Developer actions
                    _DeveloperToolItem(
                      icon: AppIcons.gridView,
                      title: 'Modal Showcase',
                      subtitle: 'Preview all app modals for design review',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ModalShowcaseScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DeveloperToolItem(
                      icon: AppIcons.bugReport,
                      title: 'Debug Logs',
                      subtitle: 'View timer and system logs',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DebugLogsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DeveloperToolItem(
                      icon: AppIcons.analytics,
                      title: 'View Analytics Debug',
                      subtitle: 'Raw analytics data and metrics',
                      onTap: () {
                        Navigator.pop(context);
                        SnackBarService.showInfo(
                          context,
                          'Analytics Debug coming soon',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DeveloperToolItem(
                      icon: AppIcons.storage,
                      title: 'Database Inspector',
                      subtitle: 'View local and remote data',
                      onTap: () {
                        Navigator.pop(context);
                        SnackBarService.showInfo(
                          context,
                          'Database Inspector coming soon',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DeveloperToolItem(
                      icon: AppIcons.timer,
                      title: 'Timer Debug',
                      subtitle: 'Test timer and Live Activity',
                      onTap: () {
                        Navigator.pop(context);
                        SnackBarService.showInfo(
                          context,
                          'Timer Debug coming soon',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DeveloperToolItem(
                      icon: AppIcons.notifications,
                      title: 'Notification Tester',
                      subtitle: 'Test push notifications',
                      onTap: () {
                        Navigator.pop(context);
                        SnackBarService.showInfo(
                          context,
                          'Notification Tester coming soon',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperToolItem extends StatelessWidget {
  const _DeveloperToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SemanticIcon(
                  icon: icon,
                  semanticLabel: title,
                  size: AppIconSize.medium,
                  color: context.colors.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'Open',
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin-only feedback card
class _AdminFeedbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.tertiary,
            context.colors.tertiary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExerciseFeedbackScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.flagCircle,
                    semanticLabel: 'Admin',
                    color: context.colors.surface,
                    size: AppIconSize.medium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 Exercise Feedback',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colors.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.l10n.manageExerciseReports,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.surface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.chevronRight,
                  semanticLabel: context.l10n.viewAll,
                  size: AppIconSize.small,
                  color: context.colors.surface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
