import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../shared/presentation/widgets/premium_action_button.dart';
import '../../workout/presentation/providers/workout_provider.dart';
import '../../workout/domain/entities/workout.dart';
import '../../notifications/presentation/widgets/notification_hub.dart';
import '../../progress/presentation/providers/progress_provider.dart';
import '../../progress/domain/entities/progress_data.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'providers/template_provider.dart';
import '../../community/presentation/widgets/community_pulse_card.dart';
import 'widgets/unified_stats_card.dart';

class HomeScreenTier1 extends ConsumerWidget {
  const HomeScreenTier1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with blur effect
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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: _buildDynamicGreeting(context),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            actions: [
              const NotificationHub(),
              const SizedBox(width: 16),
            ],
          ),
          
          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active workout banner (enhanced)
                if (currentWorkout != null) ...[
                  _buildEnhancedWorkoutBanner(context, ref, currentWorkout),
                  const SizedBox(height: 24),
                ],
                
                // Unified Stats Card (XP + Achievement)
                UnifiedStatsCard(
                  onTapXP: () {
                    // Navigate to XP details or community
                    context.push('/community');
                  },
                  onTapAchievements: () {
                    // Navigate to achievements page
                    // TODO: Create achievements page
                  },
                ),
                const SizedBox(height: 24),
                
                // AI Coach Insights Card
                _buildAICoachCard(context),
                const SizedBox(height: 24),
                
                // Primary CTA - Smart workout starter
                _buildSmartWorkoutCTA(context),
                const SizedBox(height: 24),
                
                // Progress Dashboard
                _buildProgressDashboard(context),
                const SizedBox(height: 24),
                
                // Community Pulse Card
                CommunityPulseCard(
                  onViewAll: () {
                    // Navigate to community hub
                    context.push('/community');
                  },
                ),
                const SizedBox(height: 24),
                
                // Quick Templates Carousel
                _buildTemplateCarousel(context),
                const SizedBox(height: 24),
                
                // Achievement section è ora integrata in UnifiedStatsCard
                // _buildAchievementSection(context),
                // const SizedBox(height: 24),
                
                // Secondary Actions Grid
                _buildSecondaryActions(context),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      
      // Floating Action Button for emergency quick start
      floatingActionButton: _buildSmartFAB(context),
    );
  }

  Widget _buildDynamicGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    
    if (hour < 12) {
      greeting = "Buongiorno";
      emoji = "🌅";
    } else if (hour < 17) {
      greeting = "Buon pomeriggio";
      emoji = "☀️";
    } else {
      greeting = "Buonasera";
      emoji = "🌅";
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$emoji $greeting!",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          "Pronto per dominare?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }


  Widget _buildEnhancedWorkoutBanner(BuildContext context, WidgetRef ref, Workout workout) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    workout.isActive ? Icons.fitness_center : Icons.pause_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.isActive ? "🔥 ALLENAMENTO ATTIVO" : "⏸️ IN PAUSA",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildWorkoutStat("⏱️", "45 min", "Durata"),
                ),
                Expanded(
                  child: _buildWorkoutStat("💪", "8", "Esercizi"),
                ),
                Expanded(
                  child: _buildWorkoutStat("🔥", "340", "Calorie"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.goNamed('workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      workout.isActive ? "CONTINUA" : "RIPRENDI",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showEndWorkoutDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "TERMINA",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAICoachCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final quickStatsAsync = ref.watch(quickStatsProvider);
        final streakAsync = ref.watch(currentStreakProvider);
        final frequencyAsync = ref.watch(weeklyFrequencyProvider);
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "🧠 AI Coach",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getAICoachAdvice(quickStatsAsync.asData?.value, streakAsync.asData?.value ?? 0),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAIInsight(
                        "📈", 
                        quickStatsAsync.asData?.value?.formattedVolumeIncrease ?? "--",
                        "Volume"
                      ),
                    ),
                    Expanded(
                      child: _buildAIInsight(
                        "🎯", 
                        frequencyAsync.asData != null 
                            ? "${(frequencyAsync.asData!.value / 4 * 100).toInt()}%"
                            : "--",
                        "Consistenza"
                      ),
                    ),
                    Expanded(
                      child: _buildAIInsight(
                        "🔥", 
                        "${streakAsync.asData?.value ?? 0}",
                        "Streak"
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getAICoachAdvice(QuickStats? stats, int streak) {
    if (stats == null) {
      return "Inizia il tuo primo allenamento per sbloccare consigli personalizzati! 💪";
    }
    
    if (streak >= 7) {
      return "Ottimo lavoro! $streak giorni consecutivi di allenamento. Mantieni questo ritmo eccezionale! 🔥";
    }
    
    if (stats.volumeIncrease > 0) {
      return "Il tuo volume è aumentato del ${stats.formattedVolumeIncrease}! Continua così per massimizzare i risultati 💪";
    }
    
    if (stats.maxPR > 0) {
      return "Hai stabilito un nuovo PR di ${stats.formattedMaxPR} su ${stats.prExercise}! Punta a superarlo 🎯";
    }
    
    return "Concentrati sulla consistenza: prova ad allenarti almeno 3-4 volte questa settimana 📈";
  }

  Widget _buildAIInsight(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartWorkoutCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.goNamed('workout'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🚀 INIZIA ALLENAMENTO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Push Day Superiore",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Suggerito per oggi • 60 min",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📊 I tuoi progressi",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final quickStatsAsync = ref.watch(quickStatsProvider);
            final currentStreakAsync = ref.watch(currentStreakProvider);
            final weeklyFrequencyAsync = ref.watch(weeklyFrequencyProvider);

            return quickStatsAsync.when(
              data: (quickStats) {
                final streak = currentStreakAsync.asData?.value ?? 0;
                final frequency = weeklyFrequencyAsync.asData?.value ?? 0.0;
                
                if (quickStats == null) {
                  return _buildEmptyProgressDashboard(context);
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            context,
                            "💪",
                            "Volume",
                            quickStats.formattedVolume,
                            quickStats.formattedVolumeIncrease,
                            quickStats.volumeIncrease >= 0,
                            onTap: () => _showVolumeDetails(context, quickStats),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProgressCard(
                            context,
                            "🏋️",
                            "PR",
                            quickStats.formattedMaxPR,
                            quickStats.prExercise,
                            false,
                            onTap: () => _showPRDetails(context, quickStats),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressCard(
                            context,
                            "🔥",
                            "Streak",
                            streak > 0 ? "$streak giorni" : "0 giorni",
                            streak > 7 ? "Grande!" : "Continua così!",
                            streak > 0,
                            onTap: () => _showStreakDetails(context, ref, streak),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProgressCard(
                            context,
                            "📅",
                            "Frequenza",
                            "${frequency.toStringAsFixed(1)}/week",
                            "Target: 4x",
                            frequency >= 3.0,
                            onTap: () => _showFrequencyDetails(context, frequency),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => _buildLoadingProgressDashboard(context),
              error: (error, stack) => _buildErrorProgressDashboard(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyProgressDashboard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                context,
                "💪",
                "Volume",
                "0 kg",
                "Inizia ad allenarti!",
                false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                context,
                "🏋️",
                "PR",
                "0 kg",
                "Nessun record",
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                context,
                "🔥",
                "Streak",
                "0 giorni",
                "Inizia oggi!",
                false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                context,
                "📅",
                "Frequenza",
                "0.0/week",
                "Target: 4x",
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingProgressDashboard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonProgressCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonProgressCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonProgressCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonProgressCard(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonProgressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorProgressDashboard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            "Errore nel caricamento progressi",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tocca per riprovare",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String emoji,
    String title,
    String value,
    String subtitle,
    bool isPositive, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: isPositive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "⚡ Template Veloci",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.goNamed('workout-templates'),
              child: const Text("Vedi tutti"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Tab per categorizzazione template con stato dinamico
        Consumer(
          builder: (context, ref, child) {
            final selectedTab = ref.watch(selectedTemplateTabProvider);
            
            return Column(
              children: [
                _buildTemplateTabBar(context, ref, selectedTab),
                const SizedBox(height: 16),
                
                // Lista template dinamica con animazione fluida
                SizedBox(
                  height: 140,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: selectedTab == TemplateTab.predefined
                        ? _buildPredefinedTemplatesList()
                        : _buildMyTemplatesList(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTemplateTabBar(BuildContext context, WidgetRef ref, TemplateTab selectedTab) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(selectedTemplateTabProvider.notifier).state = TemplateTab.predefined,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selectedTab == TemplateTab.predefined 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "Predefiniti",
                    style: TextStyle(
                      color: selectedTab == TemplateTab.predefined 
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(selectedTemplateTabProvider.notifier).state = TemplateTab.myTemplates,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selectedTab == TemplateTab.myTemplates 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "I miei",
                    style: TextStyle(
                      color: selectedTab == TemplateTab.myTemplates 
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedTemplatesList() {
    return Consumer(
      builder: (context, ref, child) {
        return _buildTemplateList([
          _buildTemplateCard(
            context, 
            ref,
            "🔥", 
            "Push Day", 
            "Petto, Spalle, Tricipiti", 
            Colors.red.shade400,
            () => _startPredefinedWorkout(context, ref, "Push Day"),
          ),
          _buildTemplateCard(
            context,
            ref,
            "💪", 
            "Pull Day", 
            "Schiena, Bicipiti", 
            Colors.blue.shade400,
            () => _startPredefinedWorkout(context, ref, "Pull Day"),
          ),
          _buildTemplateCard(
            context,
            ref,
            "🦵", 
            "Leg Day", 
            "Gambe, Glutei", 
            Colors.green.shade400,
            () => _startPredefinedWorkout(context, ref, "Leg Day"),
          ),
          _buildTemplateCard(
            context,
            ref,
            "⚡", 
            "HIIT", 
            "Cardio Intenso", 
            Colors.orange.shade400,
            () => _startPredefinedWorkout(context, ref, "HIIT"),
          ),
        ], key: const ValueKey('predefined'));
      },
    );
  }
  
  void _startPredefinedWorkout(BuildContext context, WidgetRef ref, String templateName) {
    // Controlla se c'è già un workout attivo
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Text('Hai già un allenamento in corso: ${currentWorkout.name}'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          action: SnackBarAction(
            label: 'Vai',
            textColor: Colors.white,
            onPressed: () => context.goNamed('workout'),
          ),
        ),
      );
      return;
    }
    
    // Crea un nuovo workout basato sul template
    ref.read(currentWorkoutProvider.notifier).createWorkout(templateName);
    
    // Naviga alla schermata workout
    context.goNamed('workout');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Allenamento "$templateName" iniziato!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTemplateList(List<Widget> templates, {Key? key}) {
    return ListView.separated(
      key: key,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: templates.length,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
      itemBuilder: (context, index) => templates[index],
    );
  }

  Widget _buildMyTemplatesList() {
    return Consumer(
      builder: (context, ref, child) {
        final myTemplates = ref.watch(myTemplatesProvider);
        
        if (myTemplates.isEmpty) {
          return _buildEmptyMyTemplates(context, key: const ValueKey('emptyMyTemplates'));
        }

        final templateWidgets = myTemplates.map((template) {
          final colors = [
            Colors.purple.shade400,
            Colors.teal.shade400,
            Colors.indigo.shade400,
            Colors.orange.shade400,
            Colors.pink.shade400,
          ];
          final color = colors[myTemplates.indexOf(template) % colors.length];
          
          return _buildTemplateCard(
            context,
            ref,
            template.emoji,
            template.name,
            template.description,
            color,
            () => _startPredefinedWorkout(context, ref, template.name),
          );
        }).toList();

        return _buildTemplateList(templateWidgets, key: const ValueKey('myTemplates'));
      },
    );
  }

  Widget _buildEmptyMyTemplates(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              "Nessun template personale",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Crea il tuo primo template",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.goNamed('workout-templates'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Crea template"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, String emoji, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      width: 140,
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final streakAsync = ref.watch(currentStreakProvider);
        final streak = streakAsync.asData?.value ?? 0;
        
        if (streak == 0) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🎯", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Text(
                      "Inizia il tuo viaggio",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Completa il tuo primo allenamento per sbloccare achievements!",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        
        // Determina achievement in base allo streak
        String achievementTitle;
        String achievementDescription;
        double progress;
        int nextLevel;
        Color achievementColor;
        
        if (streak >= 30) {
          achievementTitle = "🏆 Leggenda del Fitness";
          achievementDescription = "$streak giorni consecutivi! Sei inarrestabile!";
          progress = 1.0;
          nextLevel = 0;
          achievementColor = Colors.purple;
        } else if (streak >= 14) {
          achievementTitle = "💎 Atleta Dedicato";
          achievementDescription = "$streak giorni di dedizione pura!";
          progress = (streak - 14) / 16.0;
          nextLevel = 30 - streak;
          achievementColor = Colors.blue;
        } else if (streak >= 7) {
          achievementTitle = "🔥 Consistency Master";
          achievementDescription = "$streak giorni consecutivi!";
          progress = (streak - 7) / 7.0;
          nextLevel = 14 - streak;
          achievementColor = Colors.amber;
        } else if (streak >= 3) {
          achievementTitle = "⚡ Momentum Builder";
          achievementDescription = "$streak giorni, continua così!";
          progress = (streak - 3) / 4.0;
          nextLevel = 7 - streak;
          achievementColor = Colors.orange;
        } else {
          achievementTitle = "🌟 Principiante Motivato";
          achievementDescription = "$streak giorni, ottimo inizio!";
          progress = streak / 3.0;
          nextLevel = 3 - streak;
          achievementColor = Colors.green;
        }
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                achievementColor.withValues(alpha: 0.1),
                achievementColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: achievementColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("🏆", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    "Achievement ${nextLevel == 0 ? 'Completo!' : 'in Corso'}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                achievementTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: achievementColor,
                ),
              ),
              Text(
                achievementDescription,
                style: const TextStyle(fontSize: 14),
              ),
              if (nextLevel > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: achievementColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(achievementColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "$nextLevel giorni al prossimo livello",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🔧 Altri strumenti",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryActionCard(
                context,
                Icons.history,
                "Cronologia",
                "Workout passati",
                () => context.goNamed('analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryActionCard(
                context,
                Icons.analytics,
                "Analytics",
                "Statistiche",
                () => context.goNamed('analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryActionCard(
                context,
                Icons.settings,
                "Settings",
                "Impostazioni",
                () => context.goNamed('settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PremiumActionButton(
        onPressed: () => context.goNamed('workout'),
        icon: Icons.add,
        label: "Quick Start",
      ),
    );
  }

  void _showVolumeDetails(BuildContext context, QuickStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text("💪", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Dettagli Volume',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, 'Volume totale:', stats.formattedVolume),
              const SizedBox(height: 12),
              _buildDetailRow(context, 'Variazione:', stats.formattedVolumeIncrease),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '📊 Come viene calcolato:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Volume = Peso × Ripetizioni per ogni set\n'
                '• Somma di tutti i set completati\n'
                '• Confronto con le ultime 4 settimane\n'
                '• Include solo workout salvati',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Il volume è calcolato solo dai workout completati e salvati su Firebase',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed('analytics');
            },
            child: const Text('Vedi Analytics'),
          ),
        ],
      ),
    );
  }

  void _showPRDetails(BuildContext context, QuickStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text("🏋️", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Dettagli Personal Record',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, 'Record attuale:', stats.formattedMaxPR),
              const SizedBox(height: 12),
              _buildDetailRow(context, 'Esercizio:', stats.prExercise.isNotEmpty ? stats.prExercise : 'Nessuno'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '🏆 Come viene calcolato:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Peso massimo sollevato per esercizio\n'
                '• Considera solo set completati\n'
                '• Basato sugli ultimi 30 giorni\n'
                '• Aggiornato ad ogni workout salvato',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (stats.maxPR == 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nessun PR registrato. Completa e salva workout per tracciare i tuoi record!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed('analytics');
            },
            child: const Text('Vedi Tutti'),
          ),
        ],
      ),
    );
  }

  void _showStreakDetails(BuildContext context, WidgetRef ref, int streak) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Dettagli Streak',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, 'Giorni consecutivi:', '$streak'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '📅 Come viene calcolato:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Conta i giorni consecutivi con almeno un workout\n'
                '• Parte da oggi e va indietro nel tempo\n'
                '• Si interrompe al primo giorno senza workout\n'
                '• Basato sui workout salvati',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Mostra calendario ultimi 7 giorni
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ultimi 7 giorni:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: _getRecentWorkoutDays(ref),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (index) {
                            final date = DateTime.now().subtract(Duration(days: 6 - index));
                            final hasWorkout = snapshot.data!.contains(
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                            );
                            return Column(
                              children: [
                                Text(
                                  _getDayName(date),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: hasWorkout
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: hasWorkout
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showFrequencyDetails(BuildContext context, double frequency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text("📅", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Dettagli Frequenza',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, 'Media settimanale:', '${frequency.toStringAsFixed(1)} workout'),
              const SizedBox(height: 12),
              _buildDetailRow(context, 'Target consigliato:', '4 workout/settimana'),
              const SizedBox(height: 16),
              // Progress verso il target
              LinearProgressIndicator(
                value: (frequency / 4).clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  frequency >= 4 ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '📊 Come viene calcolata:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Media degli ultimi 28 giorni (4 settimane)\n'
                '• Conta workout unici per giorno\n'
                '• Basato sui workout salvati su Firebase\n'
                '• Si aggiorna dopo ogni workout completato',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: frequency >= 3
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      frequency >= 3 ? Icons.check_circle : Icons.info_outline,
                      color: frequency >= 3
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        frequency >= 3
                            ? 'Ottima frequenza! Mantieni questo ritmo per risultati ottimali.'
                            : 'Prova ad aumentare la frequenza per migliorare i risultati.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed('analytics');
            },
            child: const Text('Vedi Dettagli'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<Set<String>> _getRecentWorkoutDays(WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser?.email == null) {
      return {};
    }

    final firestore = FirebaseFirestore.instance;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final query = await firestore
        .collection('exerciseActivities')
        .where('userEmail', isEqualTo: currentUser!.email!.toLowerCase().trim())
        .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .get();

    final Set<String> workoutDays = {};
    for (final doc in query.docs) {
      final timestamp = doc.data()['createdAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        workoutDays.add(dayKey);
      }
    }
    
    return workoutDays;
  }

  String _getDayName(DateTime date) {
    final days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    return days[date.weekday - 1];
  }

  void _showEndWorkoutDialog(BuildContext context, WidgetRef ref) {
    final workout = ref.read(currentWorkoutProvider);
    if (workout == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Termina Allenamento',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${workout.exercises.length} esercizi',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Come vuoi terminare l\'allenamento?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          // Annulla
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Annulla',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          // Scarta
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(currentWorkoutProvider.notifier).clearWorkout();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Allenamento scartato'),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Scarta'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
            ),
          ),
          // Salva e termina
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              
              // Prima completa il workout
              ref.read(currentWorkoutProvider.notifier).completeWorkout();
              
              // Mostra messaggio di successo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Allenamento salvato con successo!'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              
              // Pulisci il workout dopo un breve delay
              Future.delayed(const Duration(milliseconds: 500), () {
                ref.read(currentWorkoutProvider.notifier).clearWorkout();
              });
            },
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Salva e Termina'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}