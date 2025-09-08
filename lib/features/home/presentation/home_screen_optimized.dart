import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_hub.dart';
// import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_pulse_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_workout_banner.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/smart_workout_cta.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/progress_dashboard.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/template_carousel.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/secondary_actions.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/dynamic_greeting.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/modal_tester_widget.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/quick_edit_showcase.dart';

/// Optimized homepage that consolidates the best features from both implementations
/// while ensuring full compliance with localization and theming standards
class HomeScreenOptimized extends ConsumerWidget {
  const HomeScreenOptimized({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with proper theming
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const DynamicGreeting(),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            actions: const [NotificationHub(), SizedBox(width: 16)],
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active workout banner (enhanced)
                if (currentWorkout != null) ...[
                  EnhancedWorkoutBanner(workout: currentWorkout),
                  const SizedBox(height: 24),
                ],

                // Removed gamification features for MVP

                // AI Coach Insights Card
                const AICoachCard(),
                const SizedBox(height: 24),

                // Primary CTA - Smart workout starter
                const SmartWorkoutCTA(),
                const SizedBox(height: 24),

                // Progress Dashboard
                const ProgressDashboard(),
                const SizedBox(height: 24),
                
                // Modal Tester - Debug tool to identify duplicate modals
                const ModalTesterWidget(),
                const SizedBox(height: 24),
                
                // QuickEdit Showcase - Test all versions
                const QuickEditShowcase(),
                const SizedBox(height: 24),

                // Community Pulse Card - Temporarily disabled to fix gray widget issue
                // CommunityPulseCard(onViewAll: () => context.push('/community')),
                
                // Temporary simple community card placeholder
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.community,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Templates Carousel
                const TemplateCarousel(),
                const SizedBox(height: 24),

                // Secondary Actions Grid
                const SecondaryActions(),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),

      // Floating Action Button for emergency quick start
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: PremiumActionButton(
          onPressed: () => context.goNamed('workout'),
          icon: Icons.add,
          label: l10n.quickStart,
        ),
      ),
    );
  }
}
