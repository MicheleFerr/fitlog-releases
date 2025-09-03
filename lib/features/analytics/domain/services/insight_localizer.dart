import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Helper class to localize insights with dynamic data
class InsightLocalizer {
  static TrainingInsight localizeInsight(
    BuildContext context,
    TrainingInsight insight,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final metadata = insight.metadata;
    
    String localizedTitle = '';
    String localizedMessage = '';
    String localizedRecommendation = '';
    
    // Localize based on the title key
    switch (insight.title) {
      // Performance insights
      case 'insightStrengthGainsTitle':
        localizedTitle = l10n.insightStrengthGainsTitle;
        localizedMessage = l10n.insightStrengthGainsMessage;
        localizedRecommendation = l10n.insightStrengthGainsRecommendation;
        break;
        
      case 'insightPlateauTitle':
        localizedTitle = l10n.insightPlateauTitle;
        localizedMessage = l10n.insightPlateauMessage;
        localizedRecommendation = l10n.insightPlateauRecommendation;
        break;
        
      // Volume insights
      case 'insightVolumeSurgeTitle':
        localizedTitle = l10n.insightVolumeSurgeTitle;
        localizedMessage = l10n.insightVolumeSurgeMessage;
        localizedRecommendation = l10n.insightVolumeSurgeRecommendation;
        break;
        
      case 'insightVolumeDropTitle':
        localizedTitle = l10n.insightVolumeDropTitle;
        localizedMessage = l10n.insightVolumeDropMessage;
        localizedRecommendation = l10n.insightVolumeDropRecommendation;
        break;
        
      case 'insightVolumePlateauTitle':
        localizedTitle = l10n.insightVolumePlateauTitle;
        localizedMessage = l10n.insightVolumePlateauMessage;
        localizedRecommendation = l10n.insightVolumePlateauRecommendation;
        break;
        
      // Frequency insights
      case 'insightLowFrequencyTitle':
        localizedTitle = l10n.insightLowFrequencyTitle;
        localizedMessage = l10n.insightLowFrequencyMessage;
        localizedRecommendation = l10n.insightLowFrequencyRecommendation;
        break;
        
      case 'insightHighLoadTitle':
        localizedTitle = l10n.insightHighLoadTitle;
        localizedMessage = l10n.insightHighLoadMessage;
        localizedRecommendation = l10n.insightHighLoadRecommendation;
        break;
        
      case 'insightGreatConsistencyTitle':
        localizedTitle = l10n.insightGreatConsistencyTitle;
        localizedMessage = l10n.insightGreatConsistencyMessage;
        localizedRecommendation = l10n.insightGreatConsistencyRecommendation;
        break;
        
      case 'insightExtendedBreakTitle':
        localizedTitle = l10n.insightExtendedBreakTitle;
        localizedMessage = l10n.insightExtendedBreakMessage;
        localizedRecommendation = l10n.insightExtendedBreakRecommendation;
        break;
        
      // PR insights
      case 'insightChasePRsTitle':
        localizedTitle = l10n.insightChasePRsTitle;
        localizedMessage = l10n.insightChasePRsMessage;
        localizedRecommendation = l10n.insightChasePRsRecommendation;
        break;
        
      case 'insightPRWeekTitle':
        localizedTitle = l10n.insightPRWeekTitle;
        localizedMessage = l10n.insightPRWeekMessage;
        localizedRecommendation = l10n.insightPRWeekRecommendation;
        break;
        
      case 'insightPRDroughtTitle':
        localizedTitle = l10n.insightPRDroughtTitle;
        localizedMessage = l10n.insightPRDroughtMessage;
        localizedRecommendation = l10n.insightPRDroughtRecommendation;
        break;
        
      // Muscle balance insights
      case 'insightMuscleImbalanceTitle':
        localizedTitle = l10n.insightMuscleImbalanceTitle;
        localizedMessage = l10n.insightMuscleImbalanceMessage;
        localizedRecommendation = l10n.insightMuscleImbalanceRecommendation;
        break;
        
      case 'insightFocusAdjustmentTitle':
        localizedTitle = l10n.insightFocusAdjustmentTitle;
        localizedMessage = l10n.insightFocusAdjustmentMessage;
        localizedRecommendation = l10n.insightFocusAdjustmentRecommendation;
        break;
        
      case 'insightWellBalancedTitle':
        localizedTitle = l10n.insightWellBalancedTitle;
        localizedMessage = l10n.insightWellBalancedMessage;
        localizedRecommendation = l10n.insightWellBalancedRecommendation;
        break;
        
      // Recovery insights
      case 'insightOvertrainingTitle':
        localizedTitle = l10n.insightOvertrainingTitle;
        localizedMessage = l10n.insightOvertrainingMessage;
        localizedRecommendation = l10n.insightOvertrainingRecommendation;
        break;
        
      case 'insightRecoveryNoteTitle':
        localizedTitle = l10n.insightRecoveryNoteTitle;
        localizedMessage = l10n.insightRecoveryNoteMessage;
        localizedRecommendation = l10n.insightRecoveryNoteRecommendation;
        break;
        
      // Motivational insights
      case 'insightStreakTitle':
        localizedTitle = l10n.insightStreakTitle;
        localizedMessage = l10n.insightStreakMessage;
        localizedRecommendation = l10n.insightStreakRecommendation;
        break;
        
      case 'insightVolumeMilestoneTitle':
        localizedTitle = l10n.insightVolumeMilestoneTitle;
        localizedMessage = l10n.insightVolumeMilestoneMessage;
        localizedRecommendation = l10n.insightVolumeMilestoneRecommendation;
        break;
        
      case 'insightPRMachineTitle':
        localizedTitle = l10n.insightPRMachineTitle;
        localizedMessage = l10n.insightPRMachineMessage;
        localizedRecommendation = l10n.insightPRMachineRecommendation;
        break;
        
      case 'insightConsistencyBonusTitle':
        localizedTitle = l10n.insightConsistencyBonusTitle;
        localizedMessage = l10n.insightConsistencyBonusMessage;
        localizedRecommendation = l10n.insightConsistencyBonusRecommendation;
        break;
        
      // Fallback to original if not found
      default:
        return insight;
    }
    
    // Return localized insight
    return TrainingInsight(
      id: insight.id,
      type: insight.type,
      priority: insight.priority,
      title: localizedTitle,
      message: localizedMessage,
      recommendation: localizedRecommendation,
      generatedAt: insight.generatedAt,
      metadata: insight.metadata,
    );
  }
  
  /// Localize a list of insights
  static List<TrainingInsight> localizeInsights(
    BuildContext context,
    List<TrainingInsight> insights,
  ) {
    return insights.map((insight) => localizeInsight(context, insight)).toList();
  }
}