/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/help_center/presentation/screens
/// 🎯 Feature: help_center
/// 🔧 Type: screen
///
/// FAQ List Screen - Shows FAQ questions with expandable answers
///
/// **Features**:
/// - Expandable tiles for Q&A
/// - Category-based filtering
/// - Smooth expand/collapse animations
/// - Comprehensive coverage of ALL app features (60+ Q&A pairs)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/help_center/domain/entities/faq_category.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// FAQ List Screen - shows questions for a category
class FAQListScreen extends StatefulWidget {
  const FAQListScreen({
    required this.category,
    super.key,
  });

  final FAQCategory category;

  @override
  State<FAQListScreen> createState() => _FAQListScreenState();
}

class _FAQListScreenState extends State<FAQListScreen> {
  final Set<String> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    final title = _getLocalizedCategoryTitle(context, widget.category.titleKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          final isExpanded = _expandedItems.contains(item.id);

          return _FAQTile(
            item: item,
            isExpanded: isExpanded,
            onTap: () => _toggleExpanded(item.id),
          );
        },
      ),
    );
  }

  void _toggleExpanded(String itemId) {
    setState(() {
      if (_expandedItems.contains(itemId)) {
        _expandedItems.remove(itemId);
      } else {
        _expandedItems.add(itemId);
      }
    });
  }

  /// Get localized category title
  String _getLocalizedCategoryTitle(BuildContext context, String key) {
    final l10n = context.l10n;
    final strings = {
      'helpCategoryGettingStarted': l10n.helpCategoryGettingStarted,
      'helpCategoryWorkouts': l10n.helpCategoryWorkouts,
      'helpCategoryExerciseTracking': l10n.helpCategoryExerciseTracking,
      'helpCategoryAdvancedTechniques': l10n.helpCategoryAdvancedTechniques,
      'helpCategoryTimer': l10n.helpCategoryTimer,
      'helpCategoryAnalytics': l10n.helpCategoryAnalytics,
      'helpCategoryPremium': l10n.helpCategoryPremium,
      'helpCategoryAccount': l10n.helpCategoryAccount,
      'helpCategoryProfile': l10n.helpCategoryProfile,
      'helpCategorySettings': l10n.helpCategorySettings,
      'helpCategoryHealthSync': l10n.helpCategoryHealthSync,
      'helpCategoryTroubleshooting': l10n.helpCategoryTroubleshooting,
      // Legacy
      'helpCategoryAppUsage': l10n.helpCategoryGettingStarted,
      'helpCategoryProgress': l10n.helpCategoryAnalytics,
    };
    return strings[key] ?? key;
  }
}

/// Single FAQ tile with expandable answer
class _FAQTile extends StatelessWidget {
  const _FAQTile({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  final FAQItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final question = _getLocalizedQuestion(context, item.questionKey);
    final answer = _getLocalizedAnswer(context, item.answerKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isExpanded ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpanded
            ? BorderSide(color: context.colors.primary, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.help,
                      semanticLabel: 'Question',
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: SemanticIcon(
                        icon: AppIcons.expandMore,
                        semanticLabel: isExpanded ? 'Collapse' : 'Expand',
                        size: AppIconSize.medium,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Answer (collapsible)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get localized question from key - ALL 60+ FAQ questions
  String _getLocalizedQuestion(BuildContext context, String key) {
    final l10n = context.l10n;
    final strings = {
      // ============ GETTING STARTED ============
      'faqWhatIsAppQuestion': l10n.faqWhatIsAppQuestion,
      'faqFirstWorkoutQuestion': l10n.faqFirstWorkoutQuestion,
      'faqQuickStartQuestion': l10n.faqQuickStartQuestion,
      'faqNavigationQuestion': l10n.faqNavigationQuestion,
      'faqTemplatesIntroQuestion': l10n.faqTemplatesIntroQuestion,

      // ============ WORKOUTS ============
      'faqCreateWorkoutQuestion': l10n.faqCreateWorkoutQuestion,
      'faqTemplatesQuestion': l10n.faqTemplatesQuestion,
      'faqSaveTemplateQuestion': l10n.faqSaveTemplateQuestion,
      'faqEditWorkoutQuestion': l10n.faqEditWorkoutQuestion,
      'faqDraftRecoveryQuestion': l10n.faqDraftRecoveryQuestion,
      'faqCompleteWorkoutQuestion': l10n.faqCompleteWorkoutQuestion,

      // ============ EXERCISE TRACKING ============
      'faqAddExerciseQuestion': l10n.faqAddExerciseQuestion,
      'faqSetsRepsQuestion': l10n.faqSetsRepsQuestion,
      'faqRpeRirQuestion': l10n.faqRpeRirQuestion,
      'faqCountingModesQuestion': l10n.faqCountingModesQuestion,
      'faqWarmupSetsQuestion': l10n.faqWarmupSetsQuestion,
      'faqExerciseNotesQuestion': l10n.faqExerciseNotesQuestion,
      'faqExercisesQuestion': l10n.faqAddExerciseQuestion, // Legacy

      // ============ ADVANCED TECHNIQUES ============
      'faqSupersetsQuestion': l10n.faqSupersetsQuestion,
      'faqDropsetsQuestion': l10n.faqDropsetsQuestion,
      'faqRestPauseQuestion': l10n.faqRestPauseQuestion,
      'faqAutoWarmupQuestion': l10n.faqAutoWarmupQuestion,
      'faqAutoRegulationQuestion': l10n.faqAutoRegulationQuestion,

      // ============ TIMER ============
      'faqTimerQuestion': l10n.faqTimerQuestion,
      'faqTimerBackgroundQuestion': l10n.faqTimerBackgroundQuestion,
      'faqLiveActivitiesQuestion': l10n.faqLiveActivitiesQuestion,
      'faqTimerSoundsQuestion': l10n.faqTimerSoundsQuestion,
      'faqDefaultRestQuestion': l10n.faqDefaultRestQuestion,

      // ============ ANALYTICS ============
      'faqTrackProgressQuestion': l10n.faqTrackProgressQuestion,
      'faqPersonalRecordsQuestion': l10n.faqPersonalRecordsQuestion,
      'faqVolumeQuestion': l10n.faqVolumeQuestion,
      'faqMuscleBalanceQuestion': l10n.faqMuscleBalanceQuestion,
      'faqChartsQuestion': l10n.faqChartsQuestion,
      'faqHistoryQuestion': l10n.faqHistoryQuestion,

      // ============ PREMIUM ============
      'faqPremiumBenefitsQuestion': l10n.faqPremiumBenefitsQuestion,
      'faqPremiumPricingQuestion': l10n.faqPremiumPricingQuestion,
      'faqRestorePurchaseQuestion': l10n.faqRestorePurchaseQuestion,
      'faqCancelSubscriptionQuestion': l10n.faqCancelSubscriptionQuestion,
      'faqFreeVsPremiumQuestion': l10n.faqFreeVsPremiumQuestion,

      // ============ ACCOUNT ============
      'faqSignInMethodsQuestion': l10n.faqSignInMethodsQuestion,
      'faqCloudSyncQuestion': l10n.faqCloudSyncQuestion,
      'faqBackupQuestion': l10n.faqBackupQuestion,
      'faqSwitchDeviceQuestion': l10n.faqSwitchDeviceQuestion,
      'faqDeleteAccountQuestion': l10n.faqDeleteAccountQuestion,

      // ============ PROFILE ============
      'faqSetGoalsQuestion': l10n.faqSetGoalsQuestion,
      'faqStreaksQuestion': l10n.faqStreaksQuestion,
      'faqBodyMeasurementsQuestion': l10n.faqBodyMeasurementsQuestion,
      'faqXpLevelsQuestion': l10n.faqXpLevelsQuestion,
      'faqAchievementsQuestion': l10n.faqAchievementsQuestion,

      // ============ SETTINGS ============
      'faqUnitsQuestion': l10n.faqUnitsQuestion,
      'faqLanguageQuestion': l10n.faqLanguageQuestion,
      'faqThemeQuestion': l10n.faqThemeQuestion,
      'faqZenModeQuestion': l10n.faqZenModeQuestion,
      'faqNotificationsQuestion': l10n.faqNotificationsQuestion,

      // ============ HEALTH SYNC ============
      'faqAppleHealthQuestion': l10n.faqAppleHealthQuestion,
      'faqHealthConnectQuestion': l10n.faqHealthConnectQuestion,
      'faqHealthPermissionsQuestion': l10n.faqHealthPermissionsQuestion,
      'faqWeightSyncQuestion': l10n.faqWeightSyncQuestion,

      // ============ TROUBLESHOOTING ============
      'faqDataLostQuestion': l10n.faqDataLostQuestion,
      'faqTimerNotWorkingQuestion': l10n.faqTimerNotWorkingQuestion,
      'faqSyncIssuesQuestion': l10n.faqSyncIssuesQuestion,
      'faqAppCrashQuestion': l10n.faqAppCrashQuestion,
      'faqContactSupportQuestion': l10n.faqContactSupportQuestion,
    };
    return strings[key] ?? key;
  }

  /// Get localized answer from key - ALL 60+ FAQ answers
  String _getLocalizedAnswer(BuildContext context, String key) {
    final l10n = context.l10n;
    final strings = {
      // ============ GETTING STARTED ============
      'faqWhatIsAppAnswer': l10n.faqWhatIsAppAnswer,
      'faqFirstWorkoutAnswer': l10n.faqFirstWorkoutAnswer,
      'faqQuickStartAnswer': l10n.faqQuickStartAnswer,
      'faqNavigationAnswer': l10n.faqNavigationAnswer,
      'faqTemplatesIntroAnswer': l10n.faqTemplatesIntroAnswer,

      // ============ WORKOUTS ============
      'faqCreateWorkoutAnswer': l10n.faqCreateWorkoutAnswer,
      'faqTemplatesAnswer': l10n.faqTemplatesAnswer,
      'faqSaveTemplateAnswer': l10n.faqSaveTemplateAnswer,
      'faqEditWorkoutAnswer': l10n.faqEditWorkoutAnswer,
      'faqDraftRecoveryAnswer': l10n.faqDraftRecoveryAnswer,
      'faqCompleteWorkoutAnswer': l10n.faqCompleteWorkoutAnswer,

      // ============ EXERCISE TRACKING ============
      'faqAddExerciseAnswer': l10n.faqAddExerciseAnswer,
      'faqSetsRepsAnswer': l10n.faqSetsRepsAnswer,
      'faqRpeRirAnswer': l10n.faqRpeRirAnswer,
      'faqCountingModesAnswer': l10n.faqCountingModesAnswer,
      'faqWarmupSetsAnswer': l10n.faqWarmupSetsAnswer,
      'faqExerciseNotesAnswer': l10n.faqExerciseNotesAnswer,
      'faqExercisesAnswer': l10n.faqAddExerciseAnswer, // Legacy

      // ============ ADVANCED TECHNIQUES ============
      'faqSupersetsAnswer': l10n.faqSupersetsAnswer,
      'faqDropsetsAnswer': l10n.faqDropsetsAnswer,
      'faqRestPauseAnswer': l10n.faqRestPauseAnswer,
      'faqAutoWarmupAnswer': l10n.faqAutoWarmupAnswer,
      'faqAutoRegulationAnswer': l10n.faqAutoRegulationAnswer,

      // ============ TIMER ============
      'faqTimerAnswer': l10n.faqTimerAnswer,
      'faqTimerBackgroundAnswer': l10n.faqTimerBackgroundAnswer,
      'faqLiveActivitiesAnswer': l10n.faqLiveActivitiesAnswer,
      'faqTimerSoundsAnswer': l10n.faqTimerSoundsAnswer,
      'faqDefaultRestAnswer': l10n.faqDefaultRestAnswer,

      // ============ ANALYTICS ============
      'faqTrackProgressAnswer': l10n.faqTrackProgressAnswer,
      'faqPersonalRecordsAnswer': l10n.faqPersonalRecordsAnswer,
      'faqVolumeAnswer': l10n.faqVolumeAnswer,
      'faqMuscleBalanceAnswer': l10n.faqMuscleBalanceAnswer,
      'faqChartsAnswer': l10n.faqChartsAnswer,
      'faqHistoryAnswer': l10n.faqHistoryAnswer,

      // ============ PREMIUM ============
      'faqPremiumBenefitsAnswer': l10n.faqPremiumBenefitsAnswer,
      'faqPremiumPricingAnswer': l10n.faqPremiumPricingAnswer,
      'faqRestorePurchaseAnswer': l10n.faqRestorePurchaseAnswer,
      'faqCancelSubscriptionAnswer': l10n.faqCancelSubscriptionAnswer,
      'faqFreeVsPremiumAnswer': l10n.faqFreeVsPremiumAnswer,

      // ============ ACCOUNT ============
      'faqSignInMethodsAnswer': l10n.faqSignInMethodsAnswer,
      'faqCloudSyncAnswer': l10n.faqCloudSyncAnswer,
      'faqBackupAnswer': l10n.faqBackupAnswer,
      'faqSwitchDeviceAnswer': l10n.faqSwitchDeviceAnswer,
      'faqDeleteAccountAnswer': l10n.faqDeleteAccountAnswer,

      // ============ PROFILE ============
      'faqSetGoalsAnswer': l10n.faqSetGoalsAnswer,
      'faqStreaksAnswer': l10n.faqStreaksAnswer,
      'faqBodyMeasurementsAnswer': l10n.faqBodyMeasurementsAnswer,
      'faqXpLevelsAnswer': l10n.faqXpLevelsAnswer,
      'faqAchievementsAnswer': l10n.faqAchievementsAnswer,

      // ============ SETTINGS ============
      'faqUnitsAnswer': l10n.faqUnitsAnswer,
      'faqLanguageAnswer': l10n.faqLanguageAnswer,
      'faqThemeAnswer': l10n.faqThemeAnswer,
      'faqZenModeAnswer': l10n.faqZenModeAnswer,
      'faqNotificationsAnswer': l10n.faqNotificationsAnswer,

      // ============ HEALTH SYNC ============
      'faqAppleHealthAnswer': l10n.faqAppleHealthAnswer,
      'faqHealthConnectAnswer': l10n.faqHealthConnectAnswer,
      'faqHealthPermissionsAnswer': l10n.faqHealthPermissionsAnswer,
      'faqWeightSyncAnswer': l10n.faqWeightSyncAnswer,

      // ============ TROUBLESHOOTING ============
      'faqDataLostAnswer': l10n.faqDataLostAnswer,
      'faqTimerNotWorkingAnswer': l10n.faqTimerNotWorkingAnswer,
      'faqSyncIssuesAnswer': l10n.faqSyncIssuesAnswer,
      'faqAppCrashAnswer': l10n.faqAppCrashAnswer,
      'faqContactSupportAnswer': l10n.faqContactSupportAnswer,
    };
    return strings[key] ?? key;
  }
}
