import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/start_workout_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/templates_carousel_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/xp_progress_bar.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/exercise_wiki_card_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/ai_coach_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/motivational_quote_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/settings_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/debug_logs_screen.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/modal_showcase_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/activity_rings_widget.dart';

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
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // "FitLog" - main brand name
                  Text(
                    'FitLog',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .slideX(begin: -0.2, end: 0, duration: 600.ms),
                  const SizedBox(width: 6),
                  // "Pro" - premium badge style with separate animation
                  _AnimatedProBadge(),
                ],
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
                // 0. Personalized Greeting with Motivational Quote
                _buildGreetingSection(context, ref),
                const SizedBox(height: 16),

                // 0.5 XP Progress Bar
                const XPProgressBar(),
                const SizedBox(height: 20),

                // 0.75 Activity Rings (HealthKit Integration)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ActivityRingsWidget(),
                ),
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

  /// Build personalized motivational greeting section
  ///
  /// Dynamic design with:
  /// - Personalized greeting with user's name
  /// - Motivational quote as HERO element
  /// - Visual accent for premium feel
  Widget _buildGreetingSection(BuildContext context, WidgetRef ref) {
    // Get user's display name
    final userName = ref.watch(userDisplayNameProvider);
    final firstName = userName.split(' ').first;

    // Get time-based greeting
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = context.l10n.greetingMorning;
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = context.l10n.greetingAfternoon;
    } else {
      timeGreeting = context.l10n.greetingEvening;
    }

    // Get motivational quote from provider
    final languageCode = Localizations.localeOf(context).languageCode;
    final motivationalQuote = ref.watch(currentQuoteProvider(languageCode));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized greeting with name
          Text(
            '$timeGreeting, $firstName',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Motivational quote - HERO element
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent bar
              Container(
                width: 4,
                height: 52,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Quote text
              Expanded(
                child: Text(
                  motivationalQuote,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
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
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: safeMax,
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

/// Animated "PRO" badge with entry animation + continuous shimmer
class _AnimatedProBadge extends StatefulWidget {
  @override
  State<_AnimatedProBadge> createState() => _AnimatedProBadgeState();
}

class _AnimatedProBadgeState extends State<_AnimatedProBadge> {
  bool _entryComplete = false;

  @override
  void initState() {
    super.initState();
    // Mark entry animation as complete after it finishes
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _entryComplete = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'PRO',
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colors.onPrimary,
          letterSpacing: 1.2,
          fontSize: 10,
        ),
      ),
    );

    if (!_entryComplete) {
      // Entry animation: fade + elastic scale
      return badge
          .animate()
          .fadeIn(delay: 400.ms, duration: 500.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            delay: 400.ms,
            duration: 500.ms,
            curve: Curves.elasticOut,
          );
    }

    // After entry: continuous shimmer
    return badge
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          delay: 2000.ms,
          duration: 1500.ms,
          color: context.colors.onPrimary.withValues(alpha: 0.5),
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
