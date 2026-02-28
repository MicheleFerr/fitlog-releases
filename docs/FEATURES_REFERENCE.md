# Features Reference - FitLog Pro

Quick reference for all 38 features. For documented features, see linked docs. For code-only features, this file is the primary reference.

**Last Updated**: 2026-02-28

---

## Feature Overview

| # | Feature | Status | Layers | Documentation |
|---|---------|--------|--------|---------------|
| 1 | ai_coach | Full | D/Da/P | [AI Coach Docs](AI_COACH_DOCUMENTS_IMPLEMENTATION.md) |
| 2 | analytics | Full | D/Da/P | [Analytics P1](../IMPLEMENTATION_PLAN_P1.md) |
| 3 | auth | Full | D/Da/P | Below |
| 4 | body_measurements | Full | D/Da/P | [Privacy Policy](../legal/PRIVACY_POLICY.md#appendix-body-measurements) |
| 5 | chat | Full | D/Da/P | Below |
| 6 | coach | Full | D/Da/P | Code only |
| 7 | custom_exercises | Full | D/Da/P | Code only |
| 8 | data_export | Full | D/Da/P | Code only |
| 9 | debug | Minimal | P | Below |
| 10 | exercise_database | Full | D/Da/P | [Popularity Ranking](design/EXERCISE_POPULARITY_RANKING.md) |
| 11 | exercise_merge | Full | D/Da/P | Code only |
| 12 | feedback | Full | D/Da/P | Below |
| 13 | health_sync | Full | D/Da/P | Code only |
| 14 | help_center | Minimal | D/Da/P | Below |
| 15 | history | Full | D/Da/P | Below |
| 16 | home | Full | P | Code only |
| 17 | import | Full | D/Da/P | Code only |
| 18 | landing | Minimal | P | Below |
| 19 | notifications | Full | Da/P | Code only |
| 20 | onboarding | Full | D/Da/P | [Onboarding Reference](ONBOARDING_COMPLETE_REFERENCE.md) |
| 21 | predictive_balance | Full | D/P | Below |
| 22 | premium | Minimal | P | Below |
| 23 | profile | Full | P | Below |
| 24 | progress | Full | D/Da/P | Code only |
| 25 | progress_photos | Full | D/Da/P | Below |
| 26 | progression | Skeleton | D | Below |
| 27 | quick_actions | Full | P | Code only |
| 28 | recovery_insight | Full | D/P | Below |
| 29 | scheduling | Full | D/Da/P | Below |
| 30 | settings | Full | P | Code only |
| 31 | splash | Minimal | P | Below |
| 32 | strength_standards | Full | D/Da/P | Below |
| 33 | stress_index | Full | D/Da/P | Below |
| 34 | workout | Full | D/Da/P | [Template Sync](TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md) |
| 35 | workout_import | Full | D/Da/P | Code only |
| 36 | workout_templates | Full | D/Da/P | Code only |
| 37 | admin | Full | Da/P | Below |
| 38 | feedback | Full | D/Da/P | Below |

**Legend**: D=Domain, Da=Data, P=Presentation

---

## Auth

**Purpose**: User registration, login, Firebase Auth integration, guest user support.

**Key Files**:
- `domain/entities/user_model.dart` - UserModel with UserPreferences, UserStats
- `data/auth_service.dart` - Firebase Auth wrapper
- `presentation/providers/auth_provider.dart` - Auth state management
- `presentation/login_screen.dart`, `register_screen.dart` - Auth UI
- `presentation/widgets/auth_visual_scaffold.dart`, `branded_auth_buttons.dart` - Shared auth components

**Architecture**: Full Clean Architecture (domain/data/presentation). Auth state flows via Riverpod `authProvider` → `StreamProvider<User?>`.

---

## History

**Purpose**: Past workout display with filtering, search, detail modals, editing, and sharing.

**Key Files**:
- `domain/entities/workout_history_detail.dart` - History entry with sync status
- `data/repositories/workout_history_repository_enhanced.dart` - Firestore + local data
- `presentation/providers/workout_history_provider.dart`
- `presentation/screens/workout_history_screen.dart`
- `presentation/widgets/` - `history_share_card.dart`, `workout_detail_modal.dart`, `workout_history_editor_enhanced.dart`

---

## Strength Standards

**Purpose**: Evidence-based 1RM strength standards per exercise using bodyweight-based tables with interpolation. Includes medical clearance questionnaire and suggestion accuracy tracking.

**Key Files**:
- `domain/entities/strength_standard.dart` - Bodyweight tables, ExperienceLevel enum, multipliers
- `domain/entities/medical_clearance_questionnaire.dart`, `suggestion_accuracy.dart`
- `data/datasources/strength_standards_local_datasource.dart`, `fitness_profile_local_datasource.dart`
- `data/repositories/strength_standards_repository_impl.dart`
- `domain/services/weight_suggestion_service.dart` - Calculates suggested weights
- `presentation/providers/strength_standards_providers.dart`

---

## Stress Index

**Purpose**: RTS-based training stress calculation with logarithmic scaling. Includes muscle recovery tracking, Fitness-Fatigue Model (FFM), sleep-adjusted readiness, and template stress analysis.

**Key Files**:
- `domain/entities/stress_index_result.dart`, `muscle_stress_data.dart`, `muscle_recovery_status.dart`, `personal_calibration.dart`, `template_stress_analysis.dart`
- `domain/constants/stress_index_constants.dart`, `volume_landmarks.dart`
- `domain/services/stress_index_calculator.dart` - RTS formula, EMG-based muscle distribution
- `domain/services/fitness_fatigue_service.dart`, `calibration_service.dart`, `prediction_service.dart`
- `domain/services/template_stress_analyzer.dart`, `template_suggestion_engine.dart`, `weekly_volume_tracker.dart`
- `data/repositories/stress_index_repository.dart`
- `presentation/providers/stress_index_provider.dart`, `template_suggestion_provider.dart`
- `presentation/widgets/stress_prediction_card.dart`, `template_suggestion_card.dart`

---

## Recovery Insight

**Purpose**: Combines HealthKit sleep data with workout history to calculate recovery scores and provide recommendations based on sleep quality and consecutive bad nights.

**Key Files**:
- `domain/entities/recovery_insight.dart` - RecoveryCategory enum, recovery scoring
- `domain/entities/sleep_record.dart`, `sleep_workout_correlation.dart`
- `domain/services/sleep_workout_correlation_service.dart`
- `presentation/extensions/recovery_category_l10n.dart`, `recovery_recommendation_l10n.dart`
- `presentation/providers/recovery_insight_provider.dart`
- `presentation/widgets/recovery_insight_card.dart`, `recovery_insight_sheet.dart`

---

## Predictive Balance

**Purpose**: Detects weekly workout patterns, identifies missing workouts in the current cycle, and suggests templates to restore balance using pattern fingerprinting and EMG-based muscle classification.

**Key Files**:
- `domain/entities/pattern_prediction.dart`, `weekly_pattern.dart`, `workout_fingerprint.dart`
- `domain/services/pattern_detector_service.dart`, `prediction_engine_service.dart`
- `presentation/providers/predictive_balance_provider.dart`
- `presentation/widgets/predictive_balance_indicator.dart`

---

## Progress Photos

**Purpose**: Photo capture, storage, and comparison with GDPR-compliant soft-delete. Supports ghost overlay for form consistency and coach sharing with granular consent.

**Key Files**:
- `domain/entities/progress_photo.dart` - PhotoPose enum, SyncStatus
- `domain/entities/photo_reminder.dart`
- `data/repositories/firebase_photo_repository.dart`, `photo_reminder_repository.dart`
- `data/services/photo_compression_service.dart`, `photo_reminder_notification_service.dart`
- `presentation/providers/progress_photo_providers.dart`
- `presentation/screens/my_photos_screen.dart`, `photo_comparison_screen.dart`
- `presentation/widgets/ghost_overlay_camera.dart`, `photo_capture_sheet.dart`, `photo_timeline_widget.dart`

---

## Chat

**Purpose**: Real-time messaging between athletes and coaches with text, images (form checks), and workout links. Includes read receipts and soft-delete.

**Key Files**:
- `domain/entities/chat_message.dart` - MessageType enum, WorkoutLinkMetadata, ImageMetadata
- `domain/entities/chat_conversation.dart`
- `domain/repositories/chat_repository.dart`
- `data/repositories/chat_repository_impl.dart`
- `presentation/providers/chat_providers.dart`
- `presentation/screens/chat_screen.dart`, `conversations_list_screen.dart`
- `presentation/widgets/message_bubble.dart`, `chat_input_bar.dart`, `conversation_tile.dart`

---

## Profile

**Purpose**: User profile hub with stats, XP/level display, goal management, weight tracking nudges, streak calendar, and weekly workout visualization.

**Key Files**:
- `presentation/providers/user_goals_provider.dart`, `weight_update_nudge_provider.dart`
- `presentation/screens/profile_hub_screen.dart`, `edit_profile_screen.dart`, `streak_calendar_screen.dart`
- `presentation/widgets/` - `compact_profile_header.dart`, `metric_ring_card.dart`, `level_info_modal.dart`, `weekly_workout_calendar.dart`, `account_mode_section.dart`

**Note**: Presentation-only feature. User data comes from shared `consolidated_user_provider`.

---

## Feedback

**Purpose**: Unified feedback system centralizing all user feedback (exercise corrections, AI insights, analytics usability, buddy reports, general) into single Firestore collection with admin workflow.

**Key Files**:
- `domain/entities/unified_feedback.dart` (Freezed)
- `domain/enums/unified_feedback_type.dart` - Exercise, AIInsight, Analytics, BuddyReport, General, ExercisePatch
- `domain/repositories/i_unified_feedback_repository.dart`
- `data/repositories/unified_feedback_repository_impl.dart`
- `presentation/providers/unified_feedback_provider.dart`

---

## Scheduling

**Purpose**: Schedule workouts on specific dates with reminder times. Integrates with iOS Live Activities. Supports multi-date selection and notification scheduling.

**Key Files**:
- `domain/entities/scheduled_workout.dart` - ScheduleStatus enum
- `data/models/scheduled_workout_model.dart` - Hive storage model
- `data/datasources/hive_scheduling_datasource.dart`
- `domain/repositories/scheduling_repository.dart`
- `data/repositories/scheduling_repository_impl.dart`
- `data/services/scheduling_notification_service.dart`, `schedule_live_activity_service.dart`
- `presentation/providers/scheduling_provider.dart`
- `presentation/widgets/multi_select_calendar.dart`, `reminder_time_picker.dart`, `schedule_bottom_sheet.dart`

---

## Admin

**Purpose**: Admin-only dashboard with database management, exercise publishing/editing, exercise feedback review, and analytics.

**Key Files**:
- `data/services/database_manager_service.dart`, `exercise_publish_service.dart`
- `presentation/providers/database_manager_provider.dart`, `exercise_feedback_provider.dart`, `exercise_publish_provider.dart`
- `presentation/screens/` - `admin_analytics_dashboard_screen.dart`, `database_manager_screen.dart`, `exercise_editor_screen.dart`, `exercise_feedback_screen.dart`

---

## Help Center

**Purpose**: In-app FAQ and help documentation with categories and searchable content.

**Key Files**:
- `domain/entities/faq_category.dart`
- `data/faq_data.dart` - Static FAQ content
- `presentation/screens/help_center_screen.dart`, `faq_list_screen.dart`

---

## Premium

**Purpose**: Subscription showcase with pricing tiers (monthly/yearly/lifetime). Displays IAP availability status and premium-only feature descriptions.

**Key Files**:
- `presentation/screens/simple_premium_screen.dart`

**Note**: Presentation-only. AccountTier subscription system not yet implemented (all users = `free`).

---

## Landing

**Purpose**: Marketing/landing page for web version.

**Key Files**:
- `presentation/screens/web_landing_page.dart`

---

## Splash

**Purpose**: Animated splash screen during app initialization.

**Key Files**:
- `presentation/screens/animated_splash_screen.dart`

---

## Progression

**Purpose**: Placeholder for future strength progression tracking feature.

**Status**: Skeleton only - domain/entities folder exists but is empty. Not yet implemented.

---

## Debug

**Purpose**: Internal dev tools - log viewer, modal showcase, tier limit testing.

**Key Files**:
- `data/demo_modal_data.dart`
- `presentation/screens/debug_logs_screen.dart`, `modal_showcase_screen.dart`, `tier_limits_test_screen.dart`

**Note**: Development-only feature, not visible to users in production.
