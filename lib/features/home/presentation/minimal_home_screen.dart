import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/start_workout_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/templates_carousel_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/exercise_wiki_card_compact.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/ai_coach_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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

    return Scaffold(
      backgroundColor: context.colors.surface,
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
                onPressed: () => context.push('/profile/settings'),
                icon: SemanticIcon(
                  icon: AppIcons.settings,
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
