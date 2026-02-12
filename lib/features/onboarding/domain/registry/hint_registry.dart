import 'package:gymbro_flutter_new/features/onboarding/domain/models/hint_config.dart';

/// Centralized catalog of all discoverability hints.
///
/// Each hint is defined with its visual pattern, priority, trigger conditions,
/// and persistence behavior. The [DiscoverabilityHintService] queries this
/// registry to determine which hints to show and when.
///
/// Priorities follow the audit:
/// - P0: Core interactions users miss most (complete set, swipe actions, scheduling)
/// - P1: Important secondary gestures + feature discovery (photos, streaks, history)
/// - P2: Advanced features (charts, health sync, recovery)
class HintRegistry {
  HintRegistry._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // P0 - Critical discovery hints
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Tap the checkmark to complete a set
  static const tapCompleteSet = HintConfig(
    hintId: 'tap_complete_set',
    type: HintType.subtleText,
    priority: HintPriority.p0,
    messageKey: 'hint_tap_complete_set',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Swipe template card for quick actions (start, edit, delete)
  static const swipeTemplateActions = HintConfig(
    hintId: 'swipe_template_actions',
    type: HintType.peek,
    priority: HintPriority.p0,
    messageKey: 'hint_swipe_template_actions',
    gestureType: GestureHintType.swipeHorizontal,
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 5),
  );

  /// Swipe exercise card for actions (replace, reorder, delete)
  static const swipeExerciseActions = HintConfig(
    hintId: 'swipe_exercise_actions',
    type: HintType.peek,
    priority: HintPriority.p0,
    messageKey: 'hint_swipe_exercise_actions',
    gestureType: GestureHintType.swipeHorizontal,
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 5),
  );

  /// Swipe history workout card for repeat/delete actions
  static const historySwipeWorkoutCard = HintConfig(
    hintId: 'history_swipe_workout_card',
    type: HintType.peek,
    priority: HintPriority.p0,
    messageKey: 'hint_swipe_history_card',
    gestureType: GestureHintType.swipeHorizontal,
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 5),
  );

  /// Discover tab in templates screen
  static const templatesDiscoverTab = HintConfig(
    hintId: 'templates_discover_tab',
    type: HintType.softPulse,
    priority: HintPriority.p0,
    messageKey: 'hint_discover_templates',
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// AI Coach discovery from home screen
  static const homeAiCoachDiscovery = HintConfig(
    hintId: 'home_ai_coach_discovery',
    type: HintType.suggestionCard,
    priority: HintPriority.p0,
    messageKey: 'hint_ai_coach_desc',
    requiredWorkouts: 3,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  /// Import data suggestion for new users
  static const settingsImportData = HintConfig(
    hintId: 'settings_import_data',
    type: HintType.suggestionCard,
    priority: HintPriority.p0,
    messageKey: 'hint_import_desc',
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  /// Long press exercise in analytics to correct muscle group
  static const analyticsLongPressCorrection = HintConfig(
    hintId: 'analytics_exercise_long_press_correction',
    type: HintType.subtleText,
    priority: HintPriority.p0,
    messageKey: 'hint_long_press_correction',
    gestureType: GestureHintType.longPress,
    requiredWorkouts: 3,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Discover scheduling/reminders (critical for Chiara/Roberto personas)
  static const discoverScheduling = HintConfig(
    hintId: 'discover_scheduling',
    type: HintType.suggestionCard,
    priority: HintPriority.p0,
    messageKey: 'hint_discover_scheduling',
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // P1 - Important secondary gestures + feature discovery
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Long press FAB for extended menu options
  static const longPressFabMenu = HintConfig(
    hintId: 'long_press_fab_menu',
    type: HintType.softPulse,
    priority: HintPriority.p1,
    messageKey: 'hint_long_press_fab_menu',
    gestureType: GestureHintType.longPress,
    requiredWorkouts: 1,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 3,
  );

  /// Swipe mini timer bar to expand/interact
  static const swipeMiniBar = HintConfig(
    hintId: 'swipe_mini_bar',
    type: HintType.contextualChip,
    priority: HintPriority.p1,
    messageKey: 'hint_swipe_mini_bar',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 1,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 3,
  );

  /// Tap workout name to share workout
  static const tapWorkoutNameShare = HintConfig(
    hintId: 'tap_workout_name_share',
    type: HintType.microTip,
    priority: HintPriority.p1,
    messageKey: 'hint_tap_workout_name_share',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 2,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Long press timer to skip rest
  static const longPressSkipTimer = HintConfig(
    hintId: 'long_press_skip_timer',
    type: HintType.microTip,
    priority: HintPriority.p1,
    messageKey: 'hint_long_press_skip_timer',
    gestureType: GestureHintType.longPress,
    requiredWorkouts: 1,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 3,
  );

  /// Discover streaks (gamification for retention)
  static const discoverStreaks = HintConfig(
    hintId: 'discover_streaks',
    type: HintType.softPulse,
    priority: HintPriority.p1,
    messageKey: 'hint_discover_streaks',
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Discover per-exercise history (key for Luca/Roberto)
  static const discoverExerciseHistory = HintConfig(
    hintId: 'discover_exercise_history',
    type: HintType.subtleText,
    priority: HintPriority.p1,
    messageKey: 'hint_discover_exercise_history',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Discover achievements/badges (key for Sofia/Marco)
  static const discoverAchievements = HintConfig(
    hintId: 'discover_achievements',
    type: HintType.suggestionCard,
    priority: HintPriority.p1,
    messageKey: 'hint_discover_achievements',
    requiredWorkouts: 3,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  /// Discover body measurements (key for Sofia)
  static const discoverBodyMeasurements = HintConfig(
    hintId: 'discover_body_measurements',
    type: HintType.suggestionCard,
    priority: HintPriority.p1,
    messageKey: 'hint_discover_body_measurements',
    requiredWorkouts: 2,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  /// Swipe superset card for quick actions
  static const swipeSupersetCardActions = HintConfig(
    hintId: 'swipe_superset_card_actions',
    type: HintType.peek,
    priority: HintPriority.p1,
    messageKey: 'hint_swipe_superset_actions',
    gestureType: GestureHintType.swipeHorizontal,
    requiredWorkouts: 1,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Tap body heatmap muscles for volume details
  static const tapBodyHeatmapMuscles = HintConfig(
    hintId: 'tap_body_heatmap_muscles',
    type: HintType.softPulse,
    priority: HintPriority.p1,
    messageKey: 'hint_tap_heatmap_muscles',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 3,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Pinch to zoom analytics charts
  static const pinchZoomCharts = HintConfig(
    hintId: 'pinch_zoom_charts',
    type: HintType.microTip,
    priority: HintPriority.p1,
    messageKey: 'hint_pinch_zoom_charts',
    gestureType: GestureHintType.pinchZoom,
    requiredWorkouts: 3,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Tap weekly calendar for workout stats
  static const tapWeeklyCalendarStats = HintConfig(
    hintId: 'tap_weekly_calendar_stats',
    type: HintType.subtleText,
    priority: HintPriority.p1,
    messageKey: 'hint_tap_calendar_stats',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Long press AI coach message for actions
  static const longPressAiMessageActions = HintConfig(
    hintId: 'long_press_ai_message_actions',
    type: HintType.subtleText,
    priority: HintPriority.p1,
    messageKey: 'hint_long_press_ai_message',
    gestureType: GestureHintType.longPress,
    requiredWorkouts: 0,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Double-tap superset exercise for quick edit
  static const doubleTapSupersetQuickEdit = HintConfig(
    hintId: 'double_tap_superset_quick_edit',
    type: HintType.microTip,
    priority: HintPriority.p1,
    messageKey: 'hint_double_tap_superset_edit',
    gestureType: GestureHintType.doubleTap,
    requiredWorkouts: 2,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Long press superset card for options menu
  static const longPressSupersetOptions = HintConfig(
    hintId: 'long_press_superset_options',
    type: HintType.contextualChip,
    priority: HintPriority.p1,
    messageKey: 'hint_long_press_superset',
    gestureType: GestureHintType.longPress,
    requiredWorkouts: 2,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Drag to reorder analytics charts
  static const dragReorderCharts = HintConfig(
    hintId: 'drag_reorder_charts',
    type: HintType.subtleText,
    priority: HintPriority.p1,
    messageKey: 'hint_drag_reorder_charts',
    gestureType: GestureHintType.drag,
    requiredWorkouts: 3,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // P2 - Advanced feature discovery
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Drag FAB to reposition it
  static const dragFab = HintConfig(
    hintId: 'drag_fab',
    type: HintType.microTip,
    priority: HintPriority.p2,
    messageKey: 'hint_drag_fab',
    gestureType: GestureHintType.drag,
    requiredWorkouts: 5,
    permanent: false,
    autoTimeout: Duration(seconds: 4),
    maxShowCount: 2,
  );

  /// Swipe history card for details/actions
  static const swipeHistoryCard = HintConfig(
    hintId: 'swipe_history_card',
    type: HintType.peek,
    priority: HintPriority.p2,
    messageKey: 'hint_swipe_history_card',
    gestureType: GestureHintType.swipeLeft,
    requiredWorkouts: 2,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Discover superset functionality (tuned: 5 workouts per personas analysis)
  static const discoverSuperset = HintConfig(
    hintId: 'discover_superset',
    type: HintType.suggestionCard,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_superset',
    requiredWorkouts: 5,
    permanent: false,
    autoTimeout: Duration(seconds: 6),
    maxShowCount: 2,
  );

  /// Discover RPE tracking (tuned: 8 workouts per personas analysis)
  static const discoverRpe = HintConfig(
    hintId: 'discover_rpe',
    type: HintType.suggestionCard,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_rpe',
    requiredWorkouts: 8,
    permanent: false,
    autoTimeout: Duration(seconds: 6),
    maxShowCount: 2,
  );

  /// Discover Health Sync (Apple Health)
  static const discoverHealthSync = HintConfig(
    hintId: 'discover_health_sync',
    type: HintType.suggestionCard,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_health_sync',
    requiredWorkouts: 3,
    permanent: true,
    autoTimeout: Duration(seconds: 8),
  );

  /// Discover recovery insight
  static const discoverRecoveryInsight = HintConfig(
    hintId: 'discover_recovery_insight',
    type: HintType.microTip,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_recovery',
    requiredWorkouts: 5,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Discover strength standards comparison
  static const discoverStrengthStandards = HintConfig(
    hintId: 'discover_strength_standards',
    type: HintType.contextualChip,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_strength_standards',
    requiredWorkouts: 5,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Discover plate calculator
  static const discoverPlateCalculator = HintConfig(
    hintId: 'discover_plate_calculator',
    type: HintType.microTip,
    priority: HintPriority.p2,
    messageKey: 'hint_discover_plate_calculator',
    requiredWorkouts: 2,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  /// Tap calendar days for workout details
  static const tapCalendarDayDetails = HintConfig(
    hintId: 'tap_calendar_day_details',
    type: HintType.subtleText,
    priority: HintPriority.p2,
    messageKey: 'hint_tap_calendar_details',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 2,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Tap collapsed exercise card to re-expand
  static const tapCollapsedExerciseExpand = HintConfig(
    hintId: 'tap_collapsed_exercise_expand',
    type: HintType.subtleText,
    priority: HintPriority.p2,
    messageKey: 'hint_tap_expand_exercise',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 2,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Tap activity rings to refresh health data
  static const tapActivityRingsRefresh = HintConfig(
    hintId: 'tap_activity_rings_refresh',
    type: HintType.subtleText,
    priority: HintPriority.p2,
    messageKey: 'hint_tap_rings_refresh',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 1,
    permanent: true,
    autoTimeout: Duration(seconds: 6),
  );

  /// Tap rep zone chart to toggle bar/pie view
  static const tapRepZoneToggle = HintConfig(
    hintId: 'tap_rep_zone_toggle',
    type: HintType.microTip,
    priority: HintPriority.p2,
    messageKey: 'hint_tap_rep_zone_toggle',
    gestureType: GestureHintType.tap,
    requiredWorkouts: 3,
    permanent: false,
    autoTimeout: Duration(seconds: 5),
    maxShowCount: 2,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CATALOG ACCESS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// All registered hints indexed by hintId.
  static final Map<String, HintConfig> _allHints = {
    for (final hint in _allHintsList) hint.hintId: hint,
  };

  /// All hints in priority order (P0 first).
  static final List<HintConfig> _allHintsList = [
    // P0 - Critical
    tapCompleteSet,
    swipeTemplateActions,
    swipeExerciseActions,
    historySwipeWorkoutCard,
    templatesDiscoverTab,
    homeAiCoachDiscovery,
    settingsImportData,
    analyticsLongPressCorrection,
    discoverScheduling,
    // P1 - Important
    longPressFabMenu,
    swipeMiniBar,
    tapWorkoutNameShare,
    longPressSkipTimer,
    discoverStreaks,
    discoverExerciseHistory,
    discoverAchievements,
    discoverBodyMeasurements,
    swipeSupersetCardActions,
    tapBodyHeatmapMuscles,
    pinchZoomCharts,
    tapWeeklyCalendarStats,
    longPressAiMessageActions,
    doubleTapSupersetQuickEdit,
    longPressSupersetOptions,
    dragReorderCharts,
    // P2 - Advanced
    dragFab,
    swipeHistoryCard,
    discoverSuperset,
    discoverRpe,
    discoverHealthSync,
    discoverRecoveryInsight,
    discoverStrengthStandards,
    discoverPlateCalculator,
    tapCalendarDayDetails,
    tapCollapsedExerciseExpand,
    tapActivityRingsRefresh,
    tapRepZoneToggle,
  ];

  /// Get a hint by its ID. Returns null if not found.
  static HintConfig? findById(String hintId) => _allHints[hintId];

  /// Get all registered hints (in priority order).
  static List<HintConfig> get allHints => List.unmodifiable(_allHintsList);

  /// Get hints filtered by priority.
  static List<HintConfig> getByPriority(HintPriority priority) =>
      _allHintsList.where((h) => h.priority == priority).toList();

  /// Get hints filtered by type.
  static List<HintConfig> getByType(HintType type) =>
      _allHintsList.where((h) => h.type == type).toList();

  /// Total number of registered hints.
  static int get count => _allHintsList.length;
}
