import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Rappresenta un widget configurabile nella home screen
class HomeWidgetConfig {

  const HomeWidgetConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.icon,
    this.isVisible = true,
    required this.order,
    this.settings,
    this.isRequired = false,
    this.allowResize = true,
    this.size = WidgetSize.medium,
  });

  factory HomeWidgetConfig.fromJson(Map<String, dynamic> json) {
    // Use a map to get the correct IconData constant
    final iconMap = {
      Icons.fitness_center.codePoint: Icons.fitness_center,
      Icons.emoji_events.codePoint: Icons.emoji_events,
      Icons.psychology.codePoint: Icons.psychology,
      Icons.play_arrow.codePoint: Icons.play_arrow,
      Icons.trending_up.codePoint: Icons.trending_up,
      Icons.people.codePoint: Icons.people,
      AppIcons.apps.codePoint: AppIcons.apps,
      Icons.history.codePoint: Icons.history,
      AppIcons.flag.codePoint: AppIcons.flag,
      Icons.format_quote.codePoint: Icons.format_quote,
      // Add more icons as needed
    };
    
    return HomeWidgetConfig(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      icon: iconMap[json['icon']] ?? AppIcons.widgets, // Fallback to AppIcons.widgets
      isVisible: json['isVisible'] ?? true,
      order: json['order'],
      settings: json['settings'],
      isRequired: json['isRequired'] ?? false,
      allowResize: json['allowResize'] ?? true,
      size: WidgetSize.values.firstWhere(
        (e) => e.name == json['size'],
        orElse: () => WidgetSize.medium,
      ),
    );
  }
  final String id;
  final String type;
  final String title;
  final IconData icon;
  final bool isVisible;
  final int order;
  final Map<String, dynamic>? settings;
  final bool isRequired; // Some widgets can't be hidden
  final bool allowResize; // Some widgets can't be resized
  final WidgetSize size;

  HomeWidgetConfig copyWith({
    bool? isVisible,
    int? order,
    Map<String, dynamic>? settings,
    bool? allowResize,
    WidgetSize? size,
  }) {
    return HomeWidgetConfig(
      id: id,
      type: type,
      title: title,
      icon: icon,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      settings: settings ?? this.settings,
      isRequired: isRequired,
      allowResize: allowResize ?? this.allowResize,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'icon': icon.codePoint,
    'isVisible': isVisible,
    'order': order,
    'settings': settings,
    'isRequired': isRequired,
    'allowResize': allowResize,
    'size': size.name,
  };
}

enum WidgetSize {
  small,   // 1/2 width
  medium,  // full width
  large,   // full width + extra height
}

/// Tipi di widget disponibili
class HomeWidgetType {
  static const String activeWorkout = 'active_workout';
  static const String statsCard = 'stats_card';
  static const String aiCoach = 'ai_coach';
  static const String quickStart = 'quick_start';
  static const String progressDashboard = 'progress_dashboard';
  static const String communityPulse = 'community_pulse';
  static const String quickActions = 'quick_actions';
  static const String recentWorkouts = 'recent_workouts';
  static const String weeklyGoals = 'weekly_goals';
  static const String motivationalQuote = 'motivational_quote';
  static const String exerciseOfTheDay = 'exercise_of_day';
  static const String nutritionTracker = 'nutrition_tracker';
  static const String waterIntake = 'water_intake';
  static const String sleepTracker = 'sleep_tracker';
  static const String bodyMeasurements = 'body_measurements';
  // Nuovi widget tier-1
  static const String realProgressStats = 'real_progress_stats';
  static const String streakTracker = 'streak_tracker';
  static const String recentWorkoutsNew = 'recent_workouts_new';
  static const String weeklyGoalsNew = 'weekly_goals_new';
  static const String exerciseStats = 'exercise_stats';
  static const String templateQuickAccess = 'template_quick_access';
}

/// Default widget configurations
class DefaultHomeWidgets {
  static const List<HomeWidgetConfig> defaultWidgets = [
    HomeWidgetConfig(
      id: 'active_workout',
      type: HomeWidgetType.activeWorkout,
      title: 'Allenamento Attivo',
      icon: AppIcons.workout,
      order: 0,
      isRequired: true, // Can't be hidden
      size: WidgetSize.medium,
    ),
    HomeWidgetConfig(
      id: 'stats_card',
      type: HomeWidgetType.statsCard,
      title: 'Progressi & Achievement',
      icon: AppIcons.achievement,
      order: 1,
      size: WidgetSize.large,
    ),
    // TODO: AI Coach temporaneamente disabilitato per revisione scientifica
    // Problemi identificati:
    // 1. Volume calcolato per workout invece che per settimana
    // 2. Testi hardcoded in inglese (violazione CLAUDE.md)
    // 3. Consigli potenzialmente dannosi per principianti
    // 4. Manca differenziazione per training age
    // Re-enable dopo fix in ai_coach_service.dart
    HomeWidgetConfig(
      id: 'ai_coach',
      type: HomeWidgetType.aiCoach,
      title: 'AI Coach Insights',
      icon: AppIcons.ai,
      order: 2,
      isVisible: false, // DISABILITATO - Fix scientifici necessari
      allowResize: false,
      size: WidgetSize.medium,
    ),
    HomeWidgetConfig(
      id: 'quick_start',
      type: HomeWidgetType.quickStart,
      title: 'Avvia Allenamento',
      icon: AppIcons.play,
      order: 3,
      allowResize: false, // Cannot be resized
      size: WidgetSize.medium,
    ),
    // ProgressDashboard rimosso - widget obsoleto
    // HomeWidgetConfig(
    //   id: 'progress_dashboard',
    //   type: HomeWidgetType.progressDashboard,
    //   title: 'Dashboard Progressi',
    //   icon: AppIcons.trendUp,
    //   order: 4,
    //   allowResize: false, // Cannot be resized
    //   size: WidgetSize.large,
    // ),
    HomeWidgetConfig(
      id: 'community_pulse',
      type: HomeWidgetType.communityPulse,
      title: 'Community',
      icon: AppIcons.people,
      order: 4,
      allowResize: false, // Cannot be resized
      size: WidgetSize.large,
    ),
    HomeWidgetConfig(
      id: 'quick_actions',
      type: HomeWidgetType.quickActions,
      title: 'Azioni Rapide',
      icon: AppIcons.apps,
      order: 5,
      allowResize: false, // Cannot be resized
      size: WidgetSize.large,
    ),
    HomeWidgetConfig(
      id: 'recent_workouts',
      type: HomeWidgetType.recentWorkouts,
      title: 'Allenamenti Recenti',
      icon: AppIcons.history,
      order: 6,
      isVisible: false, // Hidden by default
      size: WidgetSize.medium,
    ),
    HomeWidgetConfig(
      id: 'weekly_goals',
      type: HomeWidgetType.weeklyGoals,
      title: 'Obiettivi Settimanali',
      icon: AppIcons.flag,
      order: 7,
      isVisible: false,
      size: WidgetSize.small,
    ),
    // Nuovi widget tier-1
    HomeWidgetConfig(
      id: 'real_progress_stats',
      type: HomeWidgetType.realProgressStats,
      title: 'Analisi Progressi',
      icon: AppIcons.analytics,
      order: 8,
      isVisible: true,
      size: WidgetSize.medium,
    ),
    HomeWidgetConfig(
      id: 'streak_tracker',
      type: HomeWidgetType.streakTracker,
      title: 'Streak Tracker',
      icon: AppIcons.streak,
      order: 9,
      isVisible: true,
      size: WidgetSize.small,
    ),
    HomeWidgetConfig(
      id: 'recent_workouts_new',
      type: HomeWidgetType.recentWorkoutsNew,
      title: 'Workout Recenti',
      icon: AppIcons.history,
      order: 10,
      isVisible: true,
      size: WidgetSize.medium,
    ),
    HomeWidgetConfig(
      id: 'weekly_goals_new',
      type: HomeWidgetType.weeklyGoalsNew,
      title: 'Obiettivi',
      icon: AppIcons.flag,
      order: 11,
      isVisible: true,
      size: WidgetSize.small,
    ),
    HomeWidgetConfig(
      id: 'motivational_quote',
      type: HomeWidgetType.motivationalQuote,
      title: 'Quote del Giorno',
      icon: AppIcons.formatQuote,
      order: 12,
      isVisible: false,
      size: WidgetSize.small,
    ),
    HomeWidgetConfig(
      id: 'exercise_of_day',
      type: HomeWidgetType.exerciseOfTheDay,
      title: 'Esercizio del Giorno',
      icon: AppIcons.workout,
      order: 13,
      isVisible: false,
      size: WidgetSize.medium,
    ),
  ];
}
