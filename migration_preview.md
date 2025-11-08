# Localization Migration Preview

**Total Replacements**: 223
**Files Affected**: 95

## Changes by File

### `lib/core/data/repositories/base_hybrid_repository.dart` (3 changes)

**Line 148**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 188**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 223**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/core/data/repositories/optimized_base_hybrid_repository.dart` (1 changes)

**Line 313**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/admin/presentation/providers/community_corrections_provider.dart` (2 changes)

**Line 123**:
```dart
- if (user == null) throw Exception('User not authenticated');
+ if (user == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 147**:
```dart
- if (user == null) throw Exception('User not authenticated');
+ if (user == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/admin/presentation/providers/firebase_init_provider.dart` (1 changes)

**Line 54**:
```dart
- state = FirebaseInitState.error(result.error ?? 'Unknown error');
+ state = FirebaseInitState.error(result.error ?? context.l10n.unknownError);
```

### `lib/features/admin/presentation/screens/admin_analytics_dashboard_screen.dart` (1 changes)

**Line 90**:
```dart
- label: const Text('Go Back'),
+ label: const Text(context.l10n.goBack),
```

### `lib/features/admin/presentation/screens/admin_analytics_screen.dart` (2 changes)

**Line 1041**:
```dart
- Text('Top Exercises', style: theme.textTheme.titleMedium),
+ Text(context.l10n.topExercises, style: theme.textTheme.titleMedium),
```

**Line 531**:
```dart
- child: Text('No exercise data available'),
+ child: Text(context.l10n.noExerciseDataAvailable),
```

### `lib/features/analytics/domain/services/export_service.dart` (4 changes)

**Line 184**:
```dart
- _buildTableRow('Personal Records', statistics['totalPRs']?.toString() ?? '0'),
+ _buildTableRow(context.l10n.personalRecords, statistics['totalPRs']?.toString() ?? '0'),
```

**Line 205**:
```dart
- 'Personal Records',
+ context.l10n.personalRecords,
```

**Line 182**:
```dart
- _buildTableRow('Current Streak', '${statistics['currentStreak'] ?? 0} days'),
+ _buildTableRow(context.l10n.currentStreak, '${statistics['currentStreak'] ?? 0} days'),
```

**Line 279**:
```dart
- 'Recent Workouts',
+ context.l10n.recentWorkouts,
```

### `lib/features/analytics/presentation/analytics_screen.dart` (1 changes)

**Line 337**:
```dart
- 'Error loading analytics',
+ context.l10n.errorLoadingAnalytics,
```

### `lib/features/analytics/presentation/providers/analytics_feedback_provider.dart` (1 changes)

**Line 189**:
```dart
- Exception('User not authenticated'),
+ Exception(context.l10n.userNotAuthenticated),
```

### `lib/features/analytics/presentation/providers/workout_analytics_provider.dart` (2 changes)

**Line 230**:
```dart
- error: 'User not authenticated',
+ error: context.l10n.userNotAuthenticated,
```

**Line 388**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/analytics/presentation/screens/enhanced_analytics_screen.dart` (1 changes)

**Line 708**:
```dart
- 'Error loading analytics',
+ context.l10n.errorLoadingAnalytics,
```

### `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` (4 changes)

**Line 264**:
```dart
- child: Center(child: Text('No data available')),
+ child: Center(child: Text(context.l10n.noDataAvailable)),
```

**Line 632**:
```dart
- child: Center(child: Text('No data available')),
+ child: Center(child: Text(context.l10n.noDataAvailable)),
```

**Line 687**:
```dart
- child: Center(child: Text('No data available')),
+ child: Center(child: Text(context.l10n.noDataAvailable)),
```

**Line 741**:
```dart
- child: Center(child: Text('No data available')),
+ child: Center(child: Text(context.l10n.noDataAvailable)),
```

### `lib/features/analytics/presentation/tabs/analytics_progress_tab.dart` (3 changes)

**Line 89**:
```dart
- 'Volume Progress',
+ context.l10n.volumeProgress,
```

**Line 127**:
```dart
- //   featureName: 'Volume Progress',
+ //   featureName: context.l10n.volumeProgress,
```

**Line 167**:
```dart
- 'Personal Records',
+ context.l10n.personalRecords,
```

### `lib/features/analytics/presentation/tabs/analytics_routine_tab.dart` (2 changes)

**Line 84**:
```dart
- label: const Text('Create Routine'),
+ label: const Text(context.l10n.createRoutine),
```

**Line 362**:
```dart
- 'Current Streak',
+ context.l10n.currentStreak,
```

### `lib/features/analytics/presentation/widgets/enhanced_progress_indicators.dart` (1 changes)

**Line 231**:
```dart
- label: 'Volume Progress',
+ label: context.l10n.volumeProgress,
```

### `lib/features/analytics/presentation/widgets/enhanced_stat_cards.dart` (1 changes)

**Line 416**:
```dart
- 'Current Streak',
+ context.l10n.currentStreak,
```

### `lib/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart` (2 changes)

**Line 2150**:
```dart
- case 'volume': return 'Volume Progress';
+ case 'volume': return context.l10n.volumeProgress;
```

**Line 1105**:
```dart
- 'Muscle Efficiency Score',
+ context.l10n.muscleEfficiencyScore,
```

### `lib/features/analytics/presentation/widgets/exercise_history_search_modal.dart` (1 changes)

**Line 205**:
```dart
- 'Nessun esercizio trovato',
+ context.l10n.nessunEsercizioTrovato,
```

### `lib/features/analytics/presentation/widgets/exercise_stats_card.dart` (3 changes)

**Line 37**:
```dart
- 'Top Exercises',
+ context.l10n.topExercises,
```

**Line 46**:
```dart
- child: Text('View All'),
+ child: Text(context.l10n.viewAll),
```

**Line 57**:
```dart
- 'No exercise data available',
+ context.l10n.noExerciseDataAvailable,
```

### `lib/features/analytics/presentation/widgets/export_dialog.dart` (2 changes)

**Line 247**:
```dart
- return 'Volume Progress';
+ return context.l10n.volumeProgress;
```

**Line 249**:
```dart
- return 'Personal Records';
+ return context.l10n.personalRecords;
```

### `lib/features/analytics/presentation/widgets/fatigue_rating_dialog.dart` (1 changes)

**Line 228**:
```dart
- 'Muscle Efficiency Score',
+ context.l10n.muscleEfficiencyScore,
```

### `lib/features/analytics/presentation/widgets/interactive_weight_chart.dart` (2 changes)

**Line 391**:
```dart
- value: DateFormat('d MMM yyyy').format(data.date),
+ value: DateFormat(context.l10n.dMmmYyyy).format(data.date),
```

**Line 521**:
```dart
- 'Nessun dato disponibile',
+ context.l10n.nessunDatoDisponibile,
```

### `lib/features/analytics/presentation/widgets/one_rm_progression_chart.dart` (1 changes)

**Line 688**:
```dart
- value: DateFormat('d MMM yyyy').format(_selectedDataPoint!.date),
+ value: DateFormat(context.l10n.dMmmYyyy).format(_selectedDataPoint!.date),
```

### `lib/features/analytics/presentation/widgets/premium_feature_overlay.dart` (1 changes)

**Line 129**:
```dart
- 'Unlock Premium',
+ context.l10n.unlockPremium,
```

### `lib/features/analytics/presentation/widgets/recent_workouts_card.dart` (3 changes)

**Line 431**:
```dart
- 'Peso (kg)',
+ context.l10n.pesoKg,
```

**Line 51**:
```dart
- child: const Text('View All'),
+ child: const Text(context.l10n.viewAll),
```

**Line 37**:
```dart
- 'Recent Workouts',
+ context.l10n.recentWorkouts,
```

### `lib/features/analytics/presentation/widgets/volume_progress_chart_3d.dart` (3 changes)

**Line 351**:
```dart
- label: 'Volume Totale',
+ label: context.l10n.volumeTotale,
```

**Line 420**:
```dart
- label: 'Volume Totale',
+ label: context.l10n.volumeTotale,
```

**Line 472**:
```dart
- 'Nessun dato disponibile',
+ context.l10n.nessunDatoDisponibile,
```

### `lib/features/analytics/presentation/widgets/workout_frequency_chart.dart` (1 changes)

**Line 51**:
```dart
- 'No data available',
+ context.l10n.noDataAvailable,
```

### `lib/features/community/data/repositories/community_repository.dart` (1 changes)

**Line 219**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/community/data/repositories/hybrid_community_repository.dart` (3 changes)

**Line 75**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 100**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 332**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/community/presentation/providers/admin_moderation_provider.dart` (3 changes)

**Line 24**:
```dart
- if (user == null) throw Exception('User not authenticated');
+ if (user == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 46**:
```dart
- if (user == null) throw Exception('User not authenticated');
+ if (user == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 68**:
```dart
- if (user == null) throw Exception('User not authenticated');
+ if (user == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/community/presentation/providers/buddy_matching_provider.dart` (2 changes)

**Line 171**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 198**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/community/presentation/providers/community_provider.dart` (5 changes)

**Line 118**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 174**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 187**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 303**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 322**:
```dart
- if (userAsync == null) throw Exception('User not authenticated');
+ if (userAsync == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/community/presentation/providers/exercise_data_provider.dart` (1 changes)

**Line 144**:
```dart
- case 'Errori comuni':
+ case context.l10n.erroriComuni:
```

### `lib/features/exercise_analytics/presentation/screens/exercise_analytics_screen.dart` (3 changes)

**Line 263**:
```dart
- 'Volume Totale',
+ context.l10n.volumeTotale,
```

**Line 575**:
```dart
- _buildDetailRow('Volume Totale', '${exercise.totalVolume.toInt()} kg'),
+ _buildDetailRow(context.l10n.volumeTotale, '${exercise.totalVolume.toInt()} kg'),
```

**Line 331**:
```dart
- 'Nessun esercizio trovato',
+ context.l10n.nessunEsercizioTrovato,
```

### `lib/features/exercise_database/data/services/exercise_sync_service.dart` (2 changes)

**Line 79**:
```dart
- error: 'Sync already in progress',
+ error: context.l10n.syncAlreadyInProgress,
```

**Line 162**:
```dart
- error: 'Sync already in progress',
+ error: context.l10n.syncAlreadyInProgress,
```

### `lib/features/home/data/repositories/hybrid_achievement_repository.dart` (2 changes)

**Line 56**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 100**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/home/domain/models/home_widget_config.dart` (1 changes)

**Line 160**:
```dart
- title: 'AI Coach Insights',
+ title: context.l10n.aiCoachInsights,
```

### `lib/features/home/presentation/providers/insight_feedback_provider.dart` (1 changes)

**Line 72**:
```dart
- Exception('User not authenticated'),
+ Exception(context.l10n.userNotAuthenticated),
```

### `lib/features/home/presentation/widgets/ai_coach_card.dart` (1 changes)

**Line 1830**:
```dart
- if (e.toString().contains('User not authenticated')) {
+ if (e.toString().contains(context.l10n.userNotAuthenticated)) {
```

### `lib/features/home/presentation/widgets/home_widget_factory.dart` (5 changes)

**Line 587**:
```dart
- 'AI Coach Insights',
+ context.l10n.aiCoachInsights,
```

**Line 702**:
```dart
- 'AI Coach Insights',
+ context.l10n.aiCoachInsights,
```

**Line 912**:
```dart
- 'AI Coach Insights',
+ context.l10n.aiCoachInsights,
```

**Line 1986**:
```dart
- 'AI Coach Insights',
+ context.l10n.aiCoachInsights,
```

**Line 533**:
```dart
- 'AI Coach',
+ context.l10n.aiCoach,
```

### `lib/features/home/presentation/widgets/optimized_unified_stats_card.dart` (2 changes)

**Line 349**:
```dart
- 'Livello $level',
+ context.l10n.livelloLevel,
```

**Line 549**:
```dart
- Text('Livello $level', style: theme.textTheme.bodySmall),
+ Text(context.l10n.livelloLevel, style: theme.textTheme.bodySmall),
```

### `lib/features/home/presentation/widgets/unified_stats_card.dart` (1 changes)

**Line 285**:
```dart
- 'Livello $level',
+ context.l10n.livelloLevel,
```

### `lib/features/notifications/domain/services/intelligent_notification_service.dart` (1 changes)

**Line 78**:
```dart
- label: 'Vedi dettagli',
+ label: context.l10n.vediDettagli,
```

### `lib/features/notifications/presentation/providers/legacy_notification_provider.dart` (1 changes)

**Line 1055**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/notifications/presentation/providers/notification_provider.dart` (6 changes)

**Line 304**:
```dart
- title: 'AI Coach',
+ title: context.l10n.aiCoach,
```

**Line 308**:
```dart
- label: 'Vedi dettagli',
+ label: context.l10n.vediDettagli,
```

**Line 143**:
```dart
- title: 'Benvenuto in GymBro! 👋',
+ title: context.l10n.benvenutoInGymbro,
```

**Line 144**:
```dart
- message: 'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.',
+ message: context.l10n.iniziaIlTuoViaggioFitnessToccaLaCampanel,
```

**Line 147**:
```dart
- label: 'Inizia ora',
+ label: context.l10n.iniziaOra,
```

**Line 321**:
```dart
- label: 'Vedi achievement',
+ label: context.l10n.vediAchievement,
```

### `lib/features/notifications/presentation/providers/notification_provider_bridge.dart` (6 changes)

**Line 238**:
```dart
- title: 'AI Coach',
+ title: context.l10n.aiCoach,
```

**Line 242**:
```dart
- label: 'Vedi dettagli',
+ label: context.l10n.vediDettagli,
```

**Line 133**:
```dart
- title: 'Benvenuto in GymBro! 👋',
+ title: context.l10n.benvenutoInGymbro,
```

**Line 134**:
```dart
- message: 'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.',
+ message: context.l10n.iniziaIlTuoViaggioFitnessToccaLaCampanel,
```

**Line 137**:
```dart
- label: 'Inizia ora',
+ label: context.l10n.iniziaOra,
```

**Line 255**:
```dart
- label: 'Vedi achievement',
+ label: context.l10n.vediAchievement,
```

### `lib/features/notifications/presentation/providers/unified_notification_provider.dart` (1 changes)

**Line 171**:
```dart
- result.error ?? 'Unknown error',
+ result.error ?? context.l10n.unknownError,
```

### `lib/features/onboarding/domain/services/contextual_overlay_manager.dart` (5 changes)

**Line 104**:
```dart
- actionLabel: 'Got it',
+ actionLabel: context.l10n.gotIt,
```

**Line 129**:
```dart
- actionLabel: 'Got it',
+ actionLabel: context.l10n.gotIt,
```

**Line 143**:
```dart
- actionLabel: 'Got it',
+ actionLabel: context.l10n.gotIt,
```

**Line 122**:
```dart
- actionLabel: 'Show me',
+ actionLabel: context.l10n.showMe,
```

**Line 179**:
```dart
- actionLabel: 'Show me',
+ actionLabel: context.l10n.showMe,
```

### `lib/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart` (2 changes)

**Line 76**:
```dart
- 'Privacy Policy',
+ context.l10n.privacyPolicy,
```

**Line 89**:
```dart
- 'Terms of Service',
+ context.l10n.termsOfService,
```

### `lib/features/onboarding/presentation/widgets/steps/04_create_workout_step.dart` (1 changes)

**Line 475**:
```dart
- isItalian ? 'Upper Body • Push' : 'Upper Body • Push',
+ isItalian ? context.l10n.upperBodyPush : context.l10n.upperBodyPush,
```

### `lib/features/onboarding/presentation/widgets/steps/06_execute_set_step.dart` (2 changes)

**Line 559**:
```dart
- isItalian ? 'Peso (kg)' : 'Weight (kg)',
+ isItalian ? context.l10n.pesoKg : 'Weight (kg)',
```

**Line 559**:
```dart
- isItalian ? 'Peso (kg)' : 'Weight (kg)',
+ isItalian ? 'Peso (kg)' : context.l10n.weightKg,
```

### `lib/features/premium/presentation/screens/premium_purchase_screen.dart` (5 changes)

**Line 273**:
```dart
- 'Choose Your Plan',
+ context.l10n.chooseYourPlan,
```

**Line 462**:
```dart
- 'Privacy Policy',
+ context.l10n.privacyPolicy,
```

**Line 479**:
```dart
- 'Terms of Service',
+ context.l10n.termsOfService,
```

**Line 633**:
```dart
- 'You\'re Premium!',
+ context.l10n.yourePremium,
```

**Line 682**:
```dart
- 'Manage Subscription',
+ context.l10n.manageSubscription,
```

### `lib/features/premium/presentation/screens/premium_purchase_screen_v2.dart` (7 changes)

**Line 679**:
```dart
- 'Choose Your Plan',
+ context.l10n.chooseYourPlan,
```

**Line 715**:
```dart
- 'Choose Your Plan',
+ context.l10n.chooseYourPlan,
```

**Line 474**:
```dart
- 'Premium Features',
+ context.l10n.premiumFeatures,
```

**Line 1129**:
```dart
- 'Privacy Policy',
+ context.l10n.privacyPolicy,
```

**Line 1147**:
```dart
- 'Terms of Service',
+ context.l10n.termsOfService,
```

**Line 1444**:
```dart
- 'You\'re Premium!',
+ context.l10n.yourePremium,
```

**Line 1515**:
```dart
- 'Manage Subscription',
+ context.l10n.manageSubscription,
```

### `lib/features/premium/presentation/screens/premium_upgrade_screen.dart` (4 changes)

**Line 231**:
```dart
- 'Choose Your Plan',
+ context.l10n.chooseYourPlan,
```

**Line 196**:
```dart
- 'Premium Features',
+ context.l10n.premiumFeatures,
```

**Line 580**:
```dart
- 'You\'re Premium!',
+ context.l10n.yourePremium,
```

**Line 612**:
```dart
- label: const Text('Manage Subscription'),
+ label: const Text(context.l10n.manageSubscription),
```

### `lib/features/premium/presentation/screens/simple_premium_screen.dart` (4 changes)

**Line 138**:
```dart
- 'Choose Your Plan',
+ context.l10n.chooseYourPlan,
```

**Line 76**:
```dart
- 'Premium Features',
+ context.l10n.premiumFeatures,
```

**Line 86**:
```dart
- 'Volume Progress',
+ context.l10n.volumeProgress,
```

**Line 52**:
```dart
- isPremium ? 'You are Premium!' : 'Unlock Premium',
+ isPremium ? 'You are Premium!' : context.l10n.unlockPremium,
```

### `lib/features/premium/services/premium_sync_manager.dart` (1 changes)

**Line 143**:
```dart
- message: 'Sync already in progress',
+ message: context.l10n.syncAlreadyInProgress,
```

### `lib/features/routine/presentation/providers/flexible_routine_notifier.dart` (1 changes)

**Line 68**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/routine/presentation/screens/routine_detail_screen.dart` (2 changes)

**Line 335**:
```dart
- child: const Text('Go Back'),
+ child: const Text(context.l10n.goBack),
```

**Line 371**:
```dart
- child: const Text('Go Back'),
+ child: const Text(context.l10n.goBack),
```

### `lib/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart` (1 changes)

**Line 348**:
```dart
- label: 'Current Streak',
+ label: context.l10n.currentStreak,
```

### `lib/features/routine/presentation/widgets/editor_steps/review_step.dart` (1 changes)

**Line 162**:
```dart
- 'Tap "Create Routine" to begin your fitness journey',
+ 'Tap context.l10n.createRoutine to begin your fitness journey',
```

### `lib/features/routine/presentation/widgets/smart_cta_button/smart_cta_button.dart` (1 changes)

**Line 300**:
```dart
- 'Create Routine', // TODO: Add localization key
+ context.l10n.createRoutine, // TODO: Add localization key
```

### `lib/features/settings/presentation/providers/cloud_sync_provider.dart` (1 changes)

**Line 130**:
```dart
- errors: ['User not authenticated'],
+ errors: [context.l10n.userNotAuthenticated],
```

### `lib/features/settings/presentation/screens/legal_document_screen.dart` (2 changes)

**Line 252**:
```dart
- ? 'Privacy Policy'
+ ? context.l10n.privacyPolicy
```

**Line 253**:
```dart
- : 'Terms of Service';
+ : context.l10n.termsOfService;
```

### `lib/features/settings/presentation/widgets/premium_sync_card.dart` (1 changes)

**Line 104**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/workout/data/repositories/exercise_chart_repository_impl.dart` (1 changes)

**Line 56**:
```dart
- message: 'Exercise name cannot be empty',
+ message: context.l10n.exerciseNameCannotBeEmpty,
```

### `lib/features/workout/data/repositories/hybrid_exercise_activity_repository.dart` (3 changes)

**Line 80**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

**Line 135**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

**Line 439**:
```dart
- message: 'User not authenticated',
+ message: context.l10n.userNotAuthenticated,
```

### `lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart` (12 changes)

**Line 130**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 164**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 197**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 240**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 330**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 361**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 389**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 410**:
```dart
- return Stream.value(left(const AuthenticationFailure('User not authenticated')));
+ return Stream.value(left(const AuthenticationFailure(context.l10n.userNotAuthenticated)));
```

**Line 434**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 460**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

... and 2 more changes

### `lib/features/workout/data/repositories/workout_repository_impl.dart` (12 changes)

**Line 41**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 67**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 91**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 121**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 149**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 171**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 199**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 226**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 252**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

**Line 278**:
```dart
- return left(const AuthenticationFailure('User not authenticated'));
+ return left(const AuthenticationFailure(context.l10n.userNotAuthenticated));
```

... and 2 more changes

### `lib/features/workout/data/services/workout_sync_service.dart` (5 changes)

**Line 127**:
```dart
- message: 'User not authenticated',
+ message: context.l10n.userNotAuthenticated,
```

**Line 287**:
```dart
- message: 'User not authenticated',
+ message: context.l10n.userNotAuthenticated,
```

**Line 356**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

**Line 366**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

**Line 112**:
```dart
- message: 'Sync already in progress',
+ message: context.l10n.syncAlreadyInProgress,
```

### `lib/features/workout/domain/usecases/save_workout_usecase.dart` (1 changes)

**Line 103**:
```dart
- 'Exercise name cannot be empty',
+ context.l10n.exerciseNameCannotBeEmpty,
```

### `lib/features/workout/presentation/providers/workout_history_provider.dart` (1 changes)

**Line 108**:
```dart
- state = AsyncValue.error('User not authenticated', StackTrace.current);
+ state = AsyncValue.error(context.l10n.userNotAuthenticated, StackTrace.current);
```

### `lib/features/workout/presentation/screens/workout_templates_screen.dart` (1 changes)

**Line 415**:
```dart
- label: const Text('Crea Template'),
+ label: const Text(context.l10n.creaTemplate),
```

### `lib/features/workout/presentation/widgets/add_exercise_modal.dart` (3 changes)

**Line 770**:
```dart
- label: Text('APRE 3'),
+ label: Text(context.l10n.apre3),
```

**Line 775**:
```dart
- label: Text('APRE 6'),
+ label: Text(context.l10n.apre6),
```

**Line 780**:
```dart
- label: Text('APRE 10'),
+ label: Text(context.l10n.apre10),
```

### `lib/features/workout/presentation/widgets/auto_adjustment_modal.dart` (3 changes)

**Line 355**:
```dart
- label: Text('APRE 3'),
+ label: Text(context.l10n.apre3),
```

**Line 360**:
```dart
- label: Text('APRE 6'),
+ label: Text(context.l10n.apre6),
```

**Line 365**:
```dart
- label: Text('APRE 10'),
+ label: Text(context.l10n.apre10),
```

### `lib/features/workout/presentation/widgets/community_contribution_modal.dart` (2 changes)

**Line 532**:
```dart
- 'Errori comuni',
+ context.l10n.erroriComuni,
```

**Line 592**:
```dart
- case 'Errori comuni':
+ case context.l10n.erroriComuni:
```

### `lib/features/workout/presentation/widgets/create_template_modal.dart` (2 changes)

**Line 122**:
```dart
- localizations.createTemplate ?? 'Crea Template',
+ localizations.createTemplate ?? context.l10n.creaTemplate,
```

**Line 496**:
```dart
- : const Text('Crea Template'),
+ : const Text(context.l10n.creaTemplate),
```

### `lib/features/workout/presentation/widgets/edit_exercise_modal.dart` (3 changes)

**Line 454**:
```dart
- label: Text('APRE 3'),
+ label: Text(context.l10n.apre3),
```

**Line 459**:
```dart
- label: Text('APRE 6'),
+ label: Text(context.l10n.apre6),
```

**Line 464**:
```dart
- label: Text('APRE 10'),
+ label: Text(context.l10n.apre10),
```

### `lib/features/workout/presentation/widgets/exercise_options_modal.dart` (3 changes)

**Line 187**:
```dart
- content: Text('Dati esercizio non disponibili'),
+ content: Text(context.l10n.datiEsercizioNonDisponibili),
```

**Line 209**:
```dart
- ? 'Dati esercizio non disponibili'
+ ? context.l10n.datiEsercizioNonDisponibili
```

**Line 232**:
```dart
- ? 'Dati esercizio non disponibili'
+ ? context.l10n.datiEsercizioNonDisponibili
```

### `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart` (6 changes)

**Line 523**:
```dart
- tooltip: _isManualWeightEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualWeightEntry ? context.l10n.useWheel : 'Type manually',
```

**Line 678**:
```dart
- tooltip: _isManualRepsEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualRepsEntry ? context.l10n.useWheel : 'Type manually',
```

**Line 825**:
```dart
- tooltip: _isManualSecondsEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualSecondsEntry ? context.l10n.useWheel : 'Type manually',
```

**Line 523**:
```dart
- tooltip: _isManualWeightEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualWeightEntry ? 'Use wheel' : context.l10n.typeManually,
```

**Line 678**:
```dart
- tooltip: _isManualRepsEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualRepsEntry ? 'Use wheel' : context.l10n.typeManually,
```

**Line 825**:
```dart
- tooltip: _isManualSecondsEntry ? 'Use wheel' : 'Type manually',
+ tooltip: _isManualSecondsEntry ? 'Use wheel' : context.l10n.typeManually,
```

### `lib/features/workout/presentation/widgets/superset_execution_sheet.dart` (1 changes)

**Line 294**:
```dart
- labelText: 'Peso (kg)',
+ labelText: context.l10n.pesoKg,
```

### `lib/features/workout/presentation/widgets/warmup_progression_v2.dart` (1 changes)

**Line 110**:
```dart
- labelText: 'Weight (kg)',
+ labelText: context.l10n.weightKg,
```

### `lib/features/workout/presentation/widgets/zen_mode_settings_dialog.dart` (1 changes)

**Line 158**:
```dart
- title: 'Volume Totale',
+ title: context.l10n.volumeTotale,
```

### `lib/features/workout_templates/data/repositories/hybrid_template_repository.dart` (1 changes)

**Line 137**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/workout_templates/data/repositories/template_repository.dart` (6 changes)

**Line 46**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 126**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 158**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 188**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 205**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

**Line 291**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/workout_templates/domain/services/batch_import_service.dart` (1 changes)

**Line 387**:
```dart
- errors.add('Exercise name cannot be empty');
+ errors.add(context.l10n.exerciseNameCannotBeEmpty);
```

### `lib/features/workout_templates/domain/utils/import_error_mapper.dart` (1 changes)

**Line 48**:
```dart
- if (errorString.contains('Template name is required') ||
+ if (errorString.contains(context.l10n.templateNameIsRequired) ||
```

### `lib/features/workout_templates/domain/utils/import_validation_utils.dart` (2 changes)

**Line 112**:
```dart
- errors.add('Template name is required');
+ errors.add(context.l10n.templateNameIsRequired);
```

**Line 293**:
```dart
- errors.add('Template name is required');
+ errors.add(context.l10n.templateNameIsRequired);
```

### `lib/features/workout_templates/presentation/providers/template_export_provider.dart` (1 changes)

**Line 61**:
```dart
- throw Exception('User not authenticated');
+ throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/features/workout_templates/presentation/providers/template_import_provider.dart` (2 changes)

**Line 283**:
```dart
- message: 'User not authenticated',
+ message: context.l10n.userNotAuthenticated,
```

**Line 391**:
```dart
- message: 'User not authenticated',
+ message: context.l10n.userNotAuthenticated,
```

### `lib/features/workout_templates/presentation/providers/template_provider.dart` (4 changes)

**Line 179**:
```dart
- state = state.copyWith(error: 'Invalid template ID');
+ state = state.copyWith(error: context.l10n.invalidTemplateId);
```

**Line 220**:
```dart
- state = state.copyWith(error: 'Invalid template ID');
+ state = state.copyWith(error: context.l10n.invalidTemplateId);
```

**Line 277**:
```dart
- state = state.copyWith(error: 'Invalid template ID');
+ state = state.copyWith(error: context.l10n.invalidTemplateId);
```

**Line 334**:
```dart
- state = state.copyWith(error: 'Invalid template ID');
+ state = state.copyWith(error: context.l10n.invalidTemplateId);
```

### `lib/features/workout_templates/presentation/screens/template_export_screen.dart` (1 changes)

**Line 219**:
```dart
- 'Premium Features', // TODO: Add l10n.premiumFeatures
+ context.l10n.premiumFeatures, // TODO: Add l10n.premiumFeatures
```

### `lib/shared/data/repositories/hybrid_app_config_repository.dart` (1 changes)

**Line 56**:
```dart
- if (userId == null) throw Exception('User not authenticated');
+ if (userId == null) throw Exception(context.l10n.userNotAuthenticated);
```

### `lib/shared/domain/services/input_sanitizer.dart` (1 changes)

**Line 152**:
```dart
- errors.add('Exercise name cannot be empty');
+ errors.add(context.l10n.exerciseNameCannotBeEmpty);
```

### `lib/shared/domain/validation/template_validator.dart` (1 changes)

**Line 208**:
```dart
- return 'Exercise name cannot be empty';
+ return context.l10n.exerciseNameCannotBeEmpty;
```

### `lib/shared/presentation/widgets/error_boundary.dart` (1 changes)

**Line 94**:
```dart
- error?.toString() ?? 'Unknown error',
+ error?.toString() ?? context.l10n.unknownError,
```

