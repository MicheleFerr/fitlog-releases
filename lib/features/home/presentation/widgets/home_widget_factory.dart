import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/unified_stats_card.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_pulse_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
// Removed duplicate import - currentWorkoutProvider is already available from workout_provider.dart
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
// Nuovi widget tier-1
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_progress_stats_widget.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/streak_tracker_widget.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/recent_workouts_widget.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/weekly_goals_widget.dart';
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Factory class to build home widgets based on configuration
class HomeWidgetFactory {
  static Widget buildWidget({
    required BuildContext context,
    required WidgetRef ref,
    required HomeWidgetConfig config,
    bool isPreview = false,
  }) {
    Widget widget;
    
    switch (config.type) {
      case HomeWidgetType.activeWorkout:
        final currentWorkout = ref.watch(currentWorkoutProvider);
        widget = _buildActiveWorkoutWidget(context, ref, currentWorkout);
        break;
        
      case HomeWidgetType.statsCard:
        widget = UnifiedStatsCard(
          size: config.size,
          onTapXP: isPreview ? null : () => context.push('/community'),
          onTapAchievements: isPreview ? null : () {},
        );
        break;
        
      case HomeWidgetType.aiCoach:
        widget = _buildAICoachWidget(context, ref, config.size, isPreview);
        break;
        
      case HomeWidgetType.quickStart:
        widget = _buildQuickStartWidget(context, ref, config.size, isPreview);
        break;
        
      case HomeWidgetType.progressDashboard:
        // Widget rimosso - sostituito con placeholder
        widget = _buildPlaceholderWidget(context, ref, config);
        break;
        
      case HomeWidgetType.communityPulse:
        widget = CommunityPulseCard(
          onViewAll: isPreview ? null : () => context.push('/community'),
        );
        break;
        
      case HomeWidgetType.quickActions:
        widget = _buildQuickActionsWidget(context, ref, isPreview);
        break;
        
      case HomeWidgetType.recentWorkouts:
        widget = _buildRecentWorkoutsWidget(context, ref);
        break;
        
      case HomeWidgetType.weeklyGoals:
        widget = _buildWeeklyGoalsWidget(context, ref);
        break;
        
      case HomeWidgetType.motivationalQuote:
        widget = _buildMotivationalQuoteWidget(context);
        break;
        
      case HomeWidgetType.exerciseOfTheDay:
        widget = _buildExerciseOfTheDayWidget(context);
        break;
        
      // Nuovi widget tier-1
      case HomeWidgetType.realProgressStats:
        // Usa il nuovo widget enhanced con tutte le funzionalità
        widget = const EnhancedProgressStatsWidget(size: WidgetSize.medium);
        break;
        
      case HomeWidgetType.streakTracker:
        widget = StreakTrackerWidget(size: config.size);
        break;
        
      case HomeWidgetType.recentWorkoutsNew:
        widget = RecentWorkoutsWidget(size: config.size);
        break;
        
      case HomeWidgetType.weeklyGoalsNew:
        widget = WeeklyGoalsWidget(size: config.size);
        break;
        
      case HomeWidgetType.exerciseStats:
        // TODO: Implementare ExerciseStatsWidget
        widget = _buildPlaceholderWidget(context, ref, config);
        break;

      case HomeWidgetType.templateQuickAccess:
        // TODO: Implementare TemplateQuickAccessWidget
        widget = _buildPlaceholderWidget(context, ref, config);
        break;

      default:
        widget = _buildPlaceholderWidget(context, ref, config);
    }
    
    // Apply size constraints based on config
    return _applySize(widget, config.size);
  }
  
  static Widget _applySize(Widget widget, WidgetSize size) {
    // Non applichiamo più altezze fisse, lasciamo che i widget si adattino
    return widget;
  }
  
  static Widget _buildActiveWorkoutWidget(BuildContext context, WidgetRef ref, Workout? workout) {
    final theme = Theme.of(context);
    
    if (workout == null) {
      // Widget più compatto quando non c'è allenamento attivo
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: () => context.push('/workout'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16), // Ridotto da 20
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.addCircleOutline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Inizia un nuovo workout',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tocca per cominciare',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.forwardIos,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Allenamento attivo con pulsanti azione
    final duration = workout.endTime != null
        ? workout.endTime!.difference(workout.startTime!)
        : DateTime.now().difference(workout.startTime!);
    
    final minutes = duration.inMinutes;
    final exerciseCount = workout.exercises.length;
    final totalSets = workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    
    return Card(
      elevation: 4,
      color: theme.colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header cliccabile per andare al workout
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/workout'),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            workout.isActive ? AppIcons.play : AppIcons.pause,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.isActive ? 'Allenamento in corso' : 'In pausa',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                workout.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          AppIcons.forwardIos,
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Statistiche compatte
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCompactStat(AppIcons.timer, '$minutes min', theme.colorScheme.onPrimaryContainer),
                        _buildCompactStat(AppIcons.workout, '$exerciseCount esercizi', theme.colorScheme.onPrimaryContainer),
                        _buildCompactStat(AppIcons.repeat, '$totalSets serie', theme.colorScheme.onPrimaryContainer),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Pulsanti azione (area non cliccabile)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: AppIcons.play,
                    label: 'Riprendi',
                    color: theme.colorScheme.primary,
                    onTap: () => context.push('/workout'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: AppIcons.complete,
                    label: 'Termina',
                    color: context.successColor,
                    onTap: () => _showCompleteDialog(context, ref, workout),
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  icon: AppIcons.deleteOutline,
                  label: '',
                  color: context.errorColor,
                  onTap: () => _showDiscardDialog(context, ref),
                  isIconOnly: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildWorkoutStat(String emoji, String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
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
  
  static Widget _buildCompactStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  static Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isIconOnly = false,
  }) {
    final theme = Theme.of(context);
    
    if (isIconOnly) {
      return Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      );
    }
    
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  static void _showDiscardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).discardWorkoutTitle),
        content: Text(AppLocalizations.of(context).discardWorkoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Scarta l'allenamento
              ref.read(currentWorkoutProvider.notifier).clearWorkout();
              // Mostra conferma
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Allenamento scartato'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context).discard),
          ),
        ],
      ),
    );
  }
  
  static void _showCompleteDialog(BuildContext context, WidgetRef ref, Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).endWorkoutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).saveAndEndWorkout(workout.name)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).exercisesCompleted(workout.exercises.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continua'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Salva e termina l'allenamento
              ref.read(currentWorkoutProvider.notifier).completeWorkout();
              // Vai alla schermata di riepilogo
              context.push('/workout/summary');
            },
            child: const Text('Termina e Salva'),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildAICoachWidget(BuildContext context, WidgetRef ref, WidgetSize size, bool isPreview) {
    final theme = Theme.of(context);
    
    // Contenuto adattivo basato sulla dimensione
    if (size == WidgetSize.small) {
      // Layout compatto per small
      return Card(
        child: InkWell(
          onTap: isPreview ? null : () => _showAICoachDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.ai,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI Coach',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Analisi pronta',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (size == WidgetSize.medium) {
      // Layout medio con insight principale
      return Card(
        child: InkWell(
          onTap: isPreview ? null : () => _showAICoachDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AppIcons.ai,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Coach Insights',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Consiglio principale',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Consiglio principale con spiegazione
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: context.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Progressione Squat',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Considera un aumento del carico del 2-5% basato sui tuoi ultimi 3 allenamenti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Indicatore altri consigli
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Altri 2 consigli disponibili',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      AppIcons.forward,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Layout large con insights multipli
      return Card(
        child: InkWell(
          onTap: isPreview ? null : () => _showAICoachDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AppIcons.ai,
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
                            'AI Coach Insights',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Analisi personalizzata dei tuoi progressi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '3 nuovi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Insights list
                ..._buildInsightsList(context, theme),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  static List<Widget> _buildInsightsList(BuildContext context, ThemeData theme) {
    final insights = [
      {
        'icon': AppIcons.trendUp,
        'title': 'Progressione Carico',
        'message': 'Squat: incremento del 2-5% consigliato',
        'detail': 'Basato su 4 settimane di progressi costanti',
        'color': context.successColor,
      },
      {
        'icon': AppIcons.schedule,
        'title': 'Recupero Ottimale',
        'message': 'Considera 48-72h tra sessioni intense',
        'detail': 'Il tuo volume è aumentato del 15% questo mese',
        'color': context.warningColor,
      },
      {
        'icon': AppIcons.workout,
        'title': 'Bilanciamento Muscolare',
        'message': 'Rapporto push/pull equilibrato',
        'detail': 'Mantieni il volume attuale per i prossimi 2 microcicli',
        'color': context.infoColor,
      },
    ];
    
    return insights.map((insight) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (insight['color'] as Color).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  insight['icon'] as IconData,
                  color: insight['color'] as Color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            insight['title'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (insight['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BASATO SU DATI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: insight['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight['message'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight['detail'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  static void _showAICoachDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => _AICoachDialog(ref: ref),
    );
  }
  
  static void _showAICoachDialogOld(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AppIcons.ai,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Coach Insights',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Analisi basata sui tuoi progressi',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consigli Personalizzati',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Basati sulle ultime 4 settimane di allenamento',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildDetailedInsightsList(context, theme),
                      const SizedBox(height: 16),
                      
                      // Footer con azioni
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.info,
                              size: 16,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I consigli si aggiornano dopo ogni allenamento',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // 📱 Mostra Interstitial Ad prima di Analytics
                        final adService = InterstitialAdService();
                        await adService.showAdIfReady();

                        if (!context.mounted) return;

                        context.push('/analytics');
                      },
                      child: const Text('Vedi Analytics'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Chiudi'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  static Widget _buildDetailWidget(BuildContext context, ThemeData theme, Map<String, dynamic> insight) {
    final data = insight['detailData'] as Map<String, dynamic>;
    
    if (insight['title'] == 'Progressione Carico') {
      // Build progression table
      final history = data['history'] as List<dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I tuoi ultimi 4 allenamenti di Squat:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: history.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          item['period'],
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: Text(
                          item['weight'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('x', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item['reps']} reps',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${item['sets']} serie)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['summary'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    } else if (insight['title'] == 'Recupero Ottimale') {
      // Build rest times table
      final restTimes = data['restTimes'] as List<dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tempi medi ultimo allenamento gambe:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: restTimes.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          item['exercise'],
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${item['time']} min',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['status'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.successColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['summary'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    } else if (insight['title'] == 'Bilanciamento Muscolare') {
      // Build balance table
      final balance = data['balance'] as List<dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volume ultimo mese (serie totali):',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: balance.map<Widget>((group) {
                final breakdown = group['breakdown'] as List<dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          group['type'] == 'Push' ? AppIcons.north : AppIcons.south,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group['type']}:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${group['total']} serie totali',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...breakdown.map<Widget>((muscle) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 24, top: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                muscle['muscle'],
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              '${muscle['sets']} serie',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['summary'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
  
  static List<Widget> _buildDetailedInsightsList(BuildContext context, ThemeData theme) {
    final insights = [
      {
        'icon': AppIcons.trendUp,
        'title': 'Progressione Carico',
        'message': 'Squat: incremento del 2-5% consigliato',
        'detail': null, // Will be built as widget
        'detailWidget': true,
        'detailData': {
          'history': [
            {'period': '4 settimane fa', 'weight': '80.0kg', 'reps': '8', 'sets': '3 set'},
            {'period': '3 settimane fa', 'weight': '82.5kg', 'reps': '8', 'sets': '3 set'},
            {'period': '2 settimane fa', 'weight': '85.0kg', 'reps': '7', 'sets': '3 set'},
            {'period': 'Ultima volta', 'weight': '85.0kg', 'reps': '8', 'sets': '3 set'},
          ],
          'summary': 'Progressione totale: +6.25% in 4 settimane.\nUn incremento del 2-5% (2.5-5kg) ti permetterà di continuare a progredire senza rischiare sovraccarico.',
        },
        'action': 'Prova con 87.5kg nel prossimo allenamento',
        'color': context.successColor,
      },
      {
        'icon': AppIcons.schedule,
        'title': 'Recupero Ottimale',
        'message': 'Tempi di riposo analizzati',
        'detail': null,
        'detailWidget': true,
        'detailData': {
          'restTimes': [
            {'exercise': 'Squat', 'time': '3:45', 'status': 'Ottimale ✓'},
            {'exercise': 'Leg Press', 'time': '2:30', 'status': 'Perfetto ✓'},
            {'exercise': 'Leg Curl', 'time': '1:30', 'status': 'Ideale ✓'},
            {'exercise': 'Polpacci', 'time': '1:15', 'status': 'OK ✓'},
          ],
          'summary': 'Volume totale aumentato del 15% questo mese.\nAssicurati di avere 48-72h tra sessioni intense per le gambe.',
        },
        'action': 'Mantieni 2-3 giorni tra allenamenti gambe',
        'color': context.warningColor,
      },
      {
        'icon': AppIcons.workout,
        'title': 'Bilanciamento Muscolare',
        'message': 'Rapporto push/pull analizzato',
        'detail': null,
        'detailWidget': true,
        'detailData': {
          'balance': [
            {'type': 'Push', 'total': '84', 'breakdown': [
              {'muscle': 'Petto', 'sets': '36'},
              {'muscle': 'Spalle', 'sets': '28'},
              {'muscle': 'Tricipiti', 'sets': '20'},
            ]},
            {'type': 'Pull', 'total': '82', 'breakdown': [
              {'muscle': 'Dorso', 'sets': '44'},
              {'muscle': 'Bicipiti', 'sets': '24'},
              {'muscle': 'Trapezi', 'sets': '14'},
            ]},
          ],
          'summary': 'Rapporto Push/Pull: 1.02 (ottimale è 1:1)\nEquilibrio perfetto per prevenire squilibri posturali.',
        },
        'action': 'Equilibrio perfetto, mantieni così',
        'color': context.infoColor,
      },
    ];
    
    return insights.map((insight) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (insight['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (insight['color'] as Color).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      insight['icon'] as IconData,
                      color: insight['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          insight['message'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: insight['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Check if we need to build a custom widget for the detail
              if (insight['detailWidget'] == true && insight['detailData'] != null) ...[
                _buildDetailWidget(context, theme, insight),
              ] else if (insight['detail'] != null) ...[
                Text(
                  insight['detail'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (insight['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.tip,
                          size: 14,
                          color: insight['color'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            insight['action'] as String,
                            style: TextStyle(
                              color: insight['color'] as Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  static Widget _buildQuickStartWidget(BuildContext context, WidgetRef ref, WidgetSize size, bool isPreview) {
    final theme = Theme.of(context);
    
    // Layout adattivo basato sulla dimensione
    if (size == WidgetSize.small) {
      // Layout compatto orizzontale per small
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: isPreview ? null : () => context.push('/templates'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.workout,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Template',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Scegli workout',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.forwardIos,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (size == WidgetSize.medium) {
      // Layout medio orizzontale con più spazio
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: isPreview ? null : () => context.push('/templates'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.workout,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scegli Template',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seleziona un workout salvato',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.forward,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Layout large verticale centrato
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: isPreview ? null : () => context.push('/templates'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.workout,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scegli Template',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seleziona un workout salvato',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickStatSmall('12', 'Template', AppIcons.assignment, theme),
                    const SizedBox(width: 32),
                    _buildQuickStatSmall('45', 'Min medi', AppIcons.timer, theme),
                    const SizedBox(width: 32),
                    _buildQuickStatSmall('3.2k', 'kg/settimana', AppIcons.workout, theme),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  static Widget _buildQuickStatSmall(String value, String label, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  
  static Widget _buildQuickActionsWidget(BuildContext context, WidgetRef ref, bool isPreview) {
    final theme = Theme.of(context);

    final actions = [
      {'icon': AppIcons.assignment, 'label': 'Template', 'route': '/workout-templates'},
      {'icon': AppIcons.history, 'label': 'Cronologia', 'route': '/history'},
      {'icon': AppIcons.analytics, 'label': 'Analytics', 'route': '/analytics'},
      {'icon': AppIcons.settings, 'label': 'Impostazioni', 'route': '/settings'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            final route = action['route'] as String;
            final isAnalytics = route == '/analytics';

            return InkWell(
              onTap: isPreview
                  ? null
                  : () async {
                      // 📱 Mostra Interstitial Ad prima di Analytics
                      if (isAnalytics) {
                        final adService = InterstitialAdService();
                        await adService.showAdIfReady();

                        if (!context.mounted) return;
                      }

                      context.push(route);
                    },
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action['label'] as String,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  static Widget _buildRecentWorkoutsWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Allenamenti Recenti',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Implement recent workouts list
            Text(
              'Nessun allenamento recente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildWeeklyGoalsWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.flag, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Obiettivi',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '3/4 questa settimana',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildMotivationalQuoteWidget(BuildContext context) {
    final theme = Theme.of(context);
    final quotes = [
      'Il successo inizia con la volontà',
      'Ogni allenamento conta',
      'Supera i tuoi limiti',
      'La costanza batte il talento',
    ];
    
    final quote = quotes[DateTime.now().day % quotes.length];
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.formatQuote,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildExerciseOfTheDayWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: context.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esercizio del Giorno',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Squat - 4x12',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  static Widget _buildPlaceholderWidget(BuildContext context, WidgetRef ref, HomeWidgetConfig config) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                config.icon,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                config.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Nuovo widget AI Coach con dati reali
class _AICoachDialog extends ConsumerWidget {
  
  const _AICoachDialog({required this.ref});
  final WidgetRef ref;
  
  @override
  Widget build(BuildContext context, WidgetRef dialogRef) {
    final theme = Theme.of(context);
    final analyticsState = dialogRef.watch(analyticsProvider);
    
    // Genera insights basati sui dati reali
    final insights = _generateRealInsights(context, analyticsState, theme);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.ai,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Coach Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Analisi basata sui tuoi dati',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (analyticsState.isLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                    ] else if (insights.isEmpty) ...[
                      Text(
                        'Nessun dato sufficiente',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa almeno 4 allenamenti per ricevere consigli personalizzati.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ] else ...[
                      Text(
                        'Consigli Personalizzati',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Basati sui tuoi ultimi ${analyticsState.activities.length} allenamenti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...insights,
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      // 📱 Mostra Interstitial Ad prima di Analytics
                      final adService = InterstitialAdService();
                      await adService.showAdIfReady();

                      if (!context.mounted) return;

                      context.push('/analytics');
                    },
                    child: const Text('Vedi Analytics'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static List<Widget> _generateRealInsights(BuildContext context, AnalyticsState state, ThemeData theme) {
    final insights = <Widget>[];
    
    // Analizza progressione per gli esercizi più frequenti
    if (state.activities.isNotEmpty) {
      // Raggruppa per esercizio
      final exerciseGroups = <String, List<ExerciseActivity>>{};
      for (final activity in state.activities) {
        final key = activity.exerciseName;
        exerciseGroups[key] = (exerciseGroups[key] ?? [])..add(activity);
      }
      
      // Trova l'esercizio più frequente con almeno 4 sessioni
      String? mostFrequentExercise;
      List<ExerciseActivity>? exerciseHistory;
      
      for (final entry in exerciseGroups.entries) {
        if (entry.value.length >= 4) {
          if (exerciseHistory == null || entry.value.length > exerciseHistory.length) {
            mostFrequentExercise = entry.key;
            exerciseHistory = entry.value;
          }
        }
      }
      
      // Genera insight progressione se abbiamo dati
      if (mostFrequentExercise != null && exerciseHistory != null) {
        // Ordina per data
        exerciseHistory.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // Prendi ultimi 4
        final recentHistory = exerciseHistory.length > 4 
            ? exerciseHistory.sublist(exerciseHistory.length - 4)
            : exerciseHistory;
        
        insights.add(_buildProgressionInsight(context, 
          theme,
          mostFrequentExercise,
          recentHistory,
        ));
      }
    }
    
    // Analizza tempi di recupero se disponibili
    // TODO: Implement rest time analysis when available
    // if (state.activities.isNotEmpty) {
    //   insights.add(_buildRestTimeInsight(context, theme, state.activities));
    // }
    
    // Analizza bilanciamento muscolare
    if (state.muscleBalance.volumeDistribution.isNotEmpty) {
      insights.add(_buildMuscleBalanceInsight(context, theme, state.muscleBalance));
    }
    
    return insights;
  }
  
  static Widget _buildProgressionInsight(BuildContext context, 
    ThemeData theme,
    String exerciseName,
    List<ExerciseActivity> history,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.successColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.successColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: context.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progressione $exerciseName',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ultimi ${history.length} allenamenti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tabella progressione
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: history.map<Widget>((activity) {
                  final weights = activity.sets.map((s) => double.tryParse(s.weight) ?? 0.0).toList();
                  final maxWeight = weights.isEmpty ? 0.0 : weights.reduce((a, b) => a > b ? a : b);
                  final maxWeightSet = activity.sets.firstWhere(
                    (s) => double.tryParse(s.weight) == maxWeight,
                    orElse: () => activity.sets.first,
                  );
                  final maxReps = int.tryParse(maxWeightSet.reps) ?? 0;
                  final totalSets = activity.sets.length;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            _formatDate(activity.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Container(
                          width: 60,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${maxWeight.toStringAsFixed(1)}kg',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('x', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$maxReps reps',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($totalSets set)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Suggerimento
            Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: context.successColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _generateProgressionAdvice(history),
                          style: TextStyle(
                            color: context.successColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildRestTimeInsight(BuildContext context, ThemeData theme, List<ExerciseActivity> activities) {
    // Placeholder - da implementare con logica reale
    return const SizedBox.shrink();
  }
  
  static Widget _buildMuscleBalanceInsight(BuildContext context, ThemeData theme, MuscleGroupBalance balance) {
    // Placeholder - da implementare con logica reale
    return const SizedBox.shrink();
  }
  
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Oggi';
    if (diff == 1) return 'Ieri';
    if (diff < 7) return '$diff giorni fa';
    if (diff < 30) return '${(diff / 7).floor()} settimane fa';
    return '${(diff / 30).floor()} mesi fa';
  }
  
  static String _generateProgressionAdvice(List<ExerciseActivity> history) {
    if (history.length < 2) return 'Continua così';
    
    final last = history.last;
    final secondLast = history[history.length - 2];
    
    final lastWeights = last.sets.map((s) => double.tryParse(s.weight) ?? 0.0).toList();
    final lastMaxWeight = lastWeights.isEmpty ? 0.0 : lastWeights.reduce((a, b) => a > b ? a : b);
    
    final prevWeights = secondLast.sets.map((s) => double.tryParse(s.weight) ?? 0.0).toList();
    final prevMaxWeight = prevWeights.isEmpty ? 0.0 : prevWeights.reduce((a, b) => a > b ? a : b);
    
    if (lastMaxWeight > prevMaxWeight) {
      final increase = ((lastMaxWeight - prevMaxWeight) / prevMaxWeight * 100).toStringAsFixed(1);
      return 'Ottimo! +$increase% ultimo allenamento';
    } else if (lastMaxWeight == prevMaxWeight) {
      return 'Prova con +2.5kg nel prossimo allenamento';
    } else {
      return 'Consolida il peso attuale';
    }
  }
}
