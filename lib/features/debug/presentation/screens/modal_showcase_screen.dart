import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

// Modal imports - Existing
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/streak_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_modal.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/settings_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/create_template_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_save_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/weight_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/reps_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/warmup_customization_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/level_info_modal.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_details_modal.dart';

// Modal imports - NEW HIGH PRIORITY (Core Workout)
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_set_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_exercise_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_options_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_weight_picker_modal.dart';

// Modal imports - NEW MEDIUM PRIORITY (Advanced Workout)
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/auto_adjustment_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/counting_mode_picker_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_round_edit_modal.dart';

// Modal imports - NEW MEDIUM PRIORITY (Home Screen)
import 'package:gymbro_flutter_new/features/home/presentation/widgets/volume_details_modal.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/weekly_distribution_modal.dart';

// Modal imports - NEW MEDIUM PRIORITY (History & Analytics)
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_detail_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/feedback_submission_dialog.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_group_correction_sheet.dart';

// Modal imports - NEW LOW PRIORITY (Onboarding & Settings)
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/tour_bottom_sheet.dart';

// Services & Data
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/data/demo_modal_data.dart';

// Entities & Enums (NEW)
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

/// Modal Showcase Screen - Display all app modals for design review
///
/// This screen helps developers:
/// - Preview all modal designs in one place
/// - Ensure design consistency across modals
/// - Test modal behavior and animations
class ModalShowcaseScreen extends ConsumerWidget {
  const ModalShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Modal Showcase'),
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showDesignGuide(context),
            icon: SemanticIcon(
              icon: AppIcons.info,
              semanticLabel: 'Design Guide',
              size: AppIconSize.medium,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const _SectionHeader(
            title: 'Modal Design Showcase',
            subtitle: 'Tap any item to preview the modal',
          ),
          const SizedBox(height: 24),

          // Working Modals Section
          _CategorySection(
            title: 'Working Modals',
            icon: AppIcons.checkCircle,
            items: [
              _ModalItem(
                name: 'Settings Bottom Sheet',
                description: 'Main settings panel',
                onTap: () => showSettingsBottomSheet(context),
              ),
              _ModalItem(
                name: 'Create Template Modal',
                description: 'New workout template form',
                onTap: () => _showCreateTemplateModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ModalService Examples
          _CategorySection(
            title: 'ModalService Patterns',
            icon: AppIcons.info,
            items: [
              _ModalItem(
                name: 'Confirmation Dialog',
                description: 'Standard confirmation pattern',
                onTap: () => _showConfirmationExample(context),
              ),
              _ModalItem(
                name: 'Destructive Confirmation',
                description: 'Red destructive action dialog',
                onTap: () => _showDestructiveExample(context),
              ),
              _ModalItem(
                name: 'Success Dialog',
                description: 'Success state dialog',
                onTap: () => _showSuccessExample(context),
              ),
              _ModalItem(
                name: 'Error Dialog',
                description: 'Error state dialog',
                onTap: () => _showErrorExample(context),
              ),
              _ModalItem(
                name: 'Loading Dialog',
                description: 'Loading state overlay',
                onTap: () => _showLoadingExample(context),
              ),
              _ModalItem(
                name: 'Custom Bottom Sheet',
                description: 'Standard bottom sheet',
                onTap: () => _showBottomSheetExample(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Analytics Modals with Demo Data
          _CategorySection(
            title: 'Analytics Modals',
            icon: AppIcons.analytics,
            items: [
              _ModalItem(
                name: 'Weekly Modal',
                description: 'Weekly workout summary with calendar',
                onTap: () => _showWeeklyModal(context),
              ),
              _ModalItem(
                name: 'Streak Modal',
                description: 'GitHub-style workout heatmap',
                onTap: () => _showStreakModal(context),
              ),
              _ModalItem(
                name: 'Volume Modal',
                description: 'Radar chart volume distribution',
                onTap: () => _showVolumeModal(context),
              ),
              _ModalItem(
                name: 'PR Modal',
                description: 'Personal records display',
                onTap: () => _showPRModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile Modals - Working with demo data
          _CategorySection(
            title: 'Profile Modals',
            icon: AppIcons.person,
            items: [
              _ModalItem(
                name: 'Level Info Modal',
                description: 'XP and level explanation (demo data)',
                onTap: () => _showLevelInfoModal(context),
              ),
              _ModalItem(
                name: 'Legal Disclaimer',
                description: 'Terms and privacy notice',
                onTap: () => _showLegalDisclaimer(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Input Modals with Demo Data
          _CategorySection(
            title: 'Input Modals',
            icon: AppIcons.edit,
            items: [
              _ModalItem(
                name: 'Weight Picker Modal',
                description: 'Weight selection wheel picker',
                onTap: () => _showWeightPickerModal(context),
              ),
              _ModalItem(
                name: 'Reps Picker Modal',
                description: 'Reps selection wheel picker',
                onTap: () => _showRepsPickerModal(context),
              ),
              _ModalItem(
                name: 'RPE Selector',
                description: 'Rate of Perceived Exertion selector',
                onTap: () => _showRpeSelectorModal(context),
              ),
              _ModalItem(
                name: 'Rest Time Picker',
                description: 'Rest time between sets picker',
                onTap: () => _showRestTimePickerModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Workout Modals with Demo Data
          _CategorySection(
            title: 'Workout Modals',
            icon: AppIcons.workout,
            items: [
              _ModalItem(
                name: 'Template Save Dialog',
                description: 'Save/update workout template',
                onTap: () => _showTemplateSaveDialog(context),
              ),
              _ModalItem(
                name: 'Add Exercise Modal',
                description: 'Add new exercise to workout',
                onTap: () => _showAddExerciseModal(context),
              ),
              _ModalItem(
                name: 'Exercise Details Modal',
                description: 'Full exercise information',
                onTap: () => _showExerciseDetailsModal(context),
              ),
              _ModalItem(
                name: 'Warmup Customization Modal',
                description: 'Customize warmup sets progression',
                onTap: () => _showWarmupCustomizationModal(context),
              ),
              _ModalItem(
                name: 'Superset Execution Sheet',
                description: 'Sequential superset round execution',
                onTap: () => _showSupersetExecutionSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // HIGH PRIORITY - Core Workout Input Modals
          _CategorySection(
            title: 'Core Workout Input (HIGH PRIORITY)',
            icon: AppIcons.edit,
            items: [
              _ModalItem(
                name: 'Edit Set Modal',
                description: 'Edit completed set',
                onTap: () => _showEditSetModal(context),
              ),
              _ModalItem(
                name: 'Edit Exercise Modal',
                description: 'Edit exercise in active workout',
                onTap: () => _showEditExerciseModal(context),
              ),
              _ModalItem(
                name: 'Exercise Options Modal',
                description: 'Exercise menu (replace, duplicate, delete, info)',
                onTap: () => _showExerciseOptionsModal(context),
              ),
              _ModalItem(
                name: 'Dropset Weight Picker Modal',
                description: 'Select weights for dropset progression',
                onTap: () => _showDropsetWeightPickerModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MEDIUM PRIORITY - Advanced Workout Features
          _CategorySection(
            title: 'Advanced Workout Features (MEDIUM)',
            icon: AppIcons.settings,
            items: [
              _ModalItem(
                name: 'Auto Adjustment Modal',
                description: 'Automatic weight suggestions from history',
                onTap: () => _showAutoAdjustmentModal(context),
              ),
              _ModalItem(
                name: 'Counting Mode Picker Modal',
                description: 'Select counting mode (reps, time, distance)',
                onTap: () => _showCountingModePickerModal(context),
              ),
              _ModalItem(
                name: 'Exercise Replacement Modal',
                description: 'Alternative exercise suggestions',
                onTap: () => _showExerciseReplacementModal(context),
              ),
              _ModalItem(
                name: 'Superset Round Edit Modal',
                description: 'Edit single superset round',
                onTap: () => _showSupersetRoundEditModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MEDIUM PRIORITY - Home Screen Modals
          _CategorySection(
            title: 'Home Screen Widgets (MEDIUM)',
            icon: AppIcons.home,
            items: [
              _ModalItem(
                name: 'Volume Details Modal',
                description: 'Weekly volume details from home',
                onTap: () => _showVolumeDetailsModal(context),
              ),
              _ModalItem(
                name: 'Weekly Distribution Modal',
                description: 'Workout distribution across week',
                onTap: () => _showWeeklyDistributionModal(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MEDIUM PRIORITY - History & Analytics Modals
          _CategorySection(
            title: 'History & Analytics (MEDIUM)',
            icon: AppIcons.history,
            items: [
              _ModalItem(
                name: 'Workout Detail Modal',
                description: 'Completed workout details from history',
                onTap: () => _showWorkoutDetailModal(context),
              ),
              _ModalItem(
                name: 'Feedback Submission Dialog',
                description: 'Report muscle group correction to admin',
                onTap: () => _showFeedbackSubmissionDialog(context),
              ),
              _ModalItem(
                name: 'Muscle Group Correction Sheet',
                description: 'Correct muscle group locally',
                onTap: () => _showMuscleGroupCorrectionSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LOW PRIORITY - Onboarding & Settings
          _CategorySection(
            title: 'Onboarding & Settings (LOW)',
            icon: AppIcons.settings,
            items: [
              _ModalItem(
                name: 'Tour Bottom Sheet',
                description: 'Guided app tour for new users',
                onTap: () => _showTourBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // LOW PRIORITY - Community Features
          const TabBarBottomPadding(), // Bottom padding for tab bar overlay
        ],
      ),
    );
  }

  // Working Modals
  void _showCreateTemplateModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTemplateModal(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANALYTICS MODALS (with Demo Data)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showWeeklyModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklyModal(
        exerciseHistories: DemoModalData.exerciseHistories,
        weeklyWorkouts: DemoModalData.weeklyWorkouts,
      ),
    );
  }

  void _showStreakModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StreakModal(exerciseHistories: DemoModalData.exerciseHistories),
    );
  }

  void _showVolumeModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeModal(
        exerciseHistories: DemoModalData.exerciseHistories,
        volumeProgression: DemoModalData.volumeProgression,
      ),
    );
  }

  void _showPRModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PRModal(
        exerciseHistories: DemoModalData.exerciseHistories,
        recentPRCount: DemoModalData.recentPRCount,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WORKOUT MODALS (with Demo Data)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showTemplateSaveDialog(BuildContext context) {
    showTemplateSaveDialog(
      context: context,
      completedWorkout: DemoModalData.completedWorkout,
      originalTemplate: DemoModalData.originalTemplate,
    ).then((result) {
      if (result != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Selected: ${result.option.name}${result.newTemplateName != null ? ' - "${result.newTemplateName}"' : ''} (demo)',
        );
      }
    });
  }

  void _showAddExerciseModal(BuildContext context) {
    // ✅ UX: Use the new static show method
    AddExerciseModal.show(
      context,
      onExerciseAdded: (exercise) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, 'Added: ${exercise.name} (demo)');
      },
    );
  }

  void _showExerciseDetailsModal(BuildContext context) {
    ExerciseDetailsModal.show(context, DemoModalData.exerciseDefinition);
  }

  void _showWarmupCustomizationModal(BuildContext context) {
    WarmupCustomizationModal.show(
      context: context,
      initialSets: DemoModalData.demoWarmupSets,
      onConfirm: (customizedSets) {
        SnackBarService.showSuccess(
          context,
          'Warmup sets: ${customizedSets.length} sets configured (demo)',
        );
      },
    );
  }

  void _showSupersetExecutionSheet(BuildContext context) {
    SupersetSequentialExecutionSheet.show(
      context: context,
      superset: DemoModalData.demoSuperset,
      roundIndex: 0,
      onRoundCompleted: (completedRound) {
        final exerciseCount = completedRound.exerciseData.length;
        SnackBarService.showSuccess(
          context,
          'Round ${completedRound.setNumber} completed with $exerciseCount exercises (demo)',
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT MODALS (with Demo Data)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showWeightPickerModal(BuildContext context) {
    WeightPickerModal.show(
      context,
      initialWeight: DemoModalData.demoWeight,
    ).then((selectedWeight) {
      if (selectedWeight != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Selected weight: ${selectedWeight}kg (demo)',
        );
      }
    });
  }

  void _showRepsPickerModal(BuildContext context) {
    RepsPickerModal.show(context, initialReps: DemoModalData.demoReps).then((
      selectedReps,
    ) {
      if (selectedReps != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Selected reps: $selectedReps (demo)',
        );
      }
    });
  }

  void _showRpeSelectorModal(BuildContext context) {
    RpeSelectorBottomSheet.show(
      context: context,
      set: DemoModalData.demoExerciseSet,
      targetReps: DemoModalData.demoTargetReps,
      onConfirm: (actualReps, actualWeight, rpe) {
        SnackBarService.showSuccess(
          context,
          'RPE: $rpe | Reps: $actualReps | Weight: ${actualWeight}kg (demo)',
        );
      },
      exercise: DemoModalData.demoExercise,
    );
  }

  void _showRestTimePickerModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => RestTimePickerModal(
        initialRestTime: DemoModalData.demoRestTime,
        onRestTimeSelected: (seconds) {
          Navigator.pop(modalContext);
          if (seconds != null) {
            final minutes = seconds ~/ 60;
            final secs = seconds % 60;
            SnackBarService.showSuccess(
              context,
              'Rest time: $minutes:${secs.toString().padLeft(2, '0')} (demo)',
            );
          } else {
            SnackBarService.showInfo(context, 'No rest time set (demo)');
          }
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE MODALS (with Demo Data)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showLevelInfoModal(BuildContext context) {
    // Demo with Gold tier at 2450 XP (requires 1500 XP for Gold)
    LevelInfoModal.show(
      context: context,
      currentXP: 2450,
      currentTier: UserTier.gold,
    );
  }

  void _showLegalDisclaimer(BuildContext context) {
    LegalDisclaimerModal.show(
      context: context,
      onAccept: () {
        SnackBarService.showSuccess(context, 'Disclaimer accepted (demo)');
      },
      onDecline: () {
        SnackBarService.showInfo(context, 'Disclaimer declined (demo)');
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HIGH PRIORITY - Core Workout Input Modals (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showEditSetModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => EditSetModal(
        exerciseSet: DemoModalData.demoExerciseSet,
        onSave: (updatedSet) {
          Navigator.pop(modalContext);
          SnackBarService.showSuccess(
            context,
            'Set updated: ${updatedSet.weight}kg x ${updatedSet.reps} reps (demo)',
          );
        },
        exercise: DemoModalData.demoExercise,
        countingMode: ExerciseCountingMode.weighted,
      ),
    );
  }

  void _showEditExerciseModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => EditExerciseModal(
        exercise: DemoModalData.demoExercise,
        onSave: (updatedExercise) {
          Navigator.pop(modalContext);
          SnackBarService.showSuccess(
            context,
            'Exercise updated: ${updatedExercise.name} (demo)',
          );
        },
      ),
    );
  }

  void _showExerciseOptionsModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ExerciseOptionsModal(
        exercise: DemoModalData.demoExercise,
        onEdit: () {
          Navigator.pop(modalContext);
          SnackBarService.showInfo(context, 'Edit exercise (demo)');
        },
        onHistory: () {
          Navigator.pop(modalContext);
          SnackBarService.showInfo(context, 'View exercise history (demo)');
        },
        onDuplicate: () {
          Navigator.pop(modalContext);
          SnackBarService.showSuccess(context, 'Exercise duplicated (demo)');
        },
        onDelete: () {
          Navigator.pop(modalContext);
          SnackBarService.showError(context, 'Exercise deleted (demo)');
        },
      ),
    );
  }

  void _showDropsetWeightPickerModal(BuildContext context) {
    DropSetWeightPickerModal.show(
      context: context,
      stageIndex: 1, // Demo: second stage of dropset
      previousStageWeight: 100.0,
      initialWeight: 80.0,
      exerciseName: 'Bench Press',
    ).then((selectedWeight) {
      if (selectedWeight != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Dropset stage 2: ${selectedWeight}kg (demo)',
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIUM PRIORITY - Advanced Workout Features (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showAutoAdjustmentModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => AutoAdjustmentModal(
        exercise: DemoModalData.demoExercise,
        onSave: (updatedExercise) {
          Navigator.pop(modalContext);
          SnackBarService.showSuccess(context, 'Exercise auto-adjusted (demo)');
        },
      ),
    );
  }

  void _showCountingModePickerModal(BuildContext context) {
    CountingModePickerModal.show(
      context,
      currentMode:
          ExerciseCountingMode.weighted, // Must be ExerciseCountingMode enum
      showSaveAsDefault: false, // Demo mode - don't show save checkbox
    ).then((result) {
      if (result != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Mode: ${result.mode.name} (demo)',
        );
      }
    });
  }

  void _showExerciseReplacementModal(BuildContext context) {
    ExerciseReplacementModal.show(
      context,
      DemoModalData.demoExercise, // currentExercise (positional parameter)
      (newExercise) {
        // onReplace callback
        SnackBarService.showSuccess(
          context,
          'Replaced with: ${newExercise.name} (demo)',
        );
      },
    );
  }

  void _showSupersetRoundEditModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => SupersetRoundEditModal(
        superset: DemoModalData.demoSuperset,
        supersetSet: DemoModalData.demoSuperset.supersetSets.first,
        roundNumber: 1,
        onSetUpdate: (updatedSet) {
          Navigator.pop(modalContext);
          SnackBarService.showSuccess(context, 'Round updated (demo)');
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIUM PRIORITY - Home Screen Modals (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showVolumeDetailsModal(BuildContext context) {
    // Create demo volume data for last 7 days
    final now = DateTime.now();
    final dailyData = <DateTime, double>{
      now.subtract(const Duration(days: 6)): 2500.0, // Monday
      now.subtract(const Duration(days: 5)): 0.0, // Tuesday
      now.subtract(const Duration(days: 4)): 3000.0, // Wednesday
      now.subtract(const Duration(days: 3)): 0.0, // Thursday
      now.subtract(const Duration(days: 2)): 4000.0, // Friday
      now.subtract(const Duration(days: 1)): 0.0, // Saturday
      now: 3000.0, // Sunday
    };

    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeDetailsModal(
        currentVolume: 12500.0,
        dailyVolumeData: dailyData,
      ),
    );
  }

  void _showWeeklyDistributionModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WeeklyDistributionModal(
        weeklyData: {
          // Map of day names to workout volume (simplified for demo)
          'Monday': 2500.0,
          'Tuesday': 0.0,
          'Wednesday': 3000.0,
          'Thursday': 0.0,
          'Friday': 3500.0,
          'Saturday': 2000.0,
          'Sunday': 0.0,
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIUM PRIORITY - History & Analytics Modals (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showWorkoutDetailModal(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          WorkoutDetailModal(workout: DemoModalData.demoWorkoutHistoryDetail),
    );
  }

  void _showFeedbackSubmissionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => FeedbackSubmissionDialog(
        correction: DemoModalData.demoMuscleCorrection,
      ),
    );
  }

  void _showMuscleGroupCorrectionSheet(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MuscleGroupCorrectionSheet(
        exerciseName: 'Bench Press',
        currentMuscleGroup:
            'Back', // Incorrect demo value to show correction UI
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOW PRIORITY - Onboarding & Settings Modals (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showTourBottomSheet(BuildContext context) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TourBottomSheet(step: DemoModalData.demoTourStep),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOW PRIORITY - Community Features Modals (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  // ModalService Examples
  void _showConfirmationExample(BuildContext context) {
    ModalService.showConfirmDialog(
      context,
      title: 'Confirm Action',
      message: 'Are you sure you want to proceed with this action?',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
    );
  }

  void _showDestructiveExample(BuildContext context) {
    ModalService.showConfirmDialog(
      context,
      title: 'Delete Workout',
      message: 'This action cannot be undone. Are you sure?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );
  }

  void _showSuccessExample(BuildContext context) {
    ModalService.showInfoDialog(
      context,
      title: 'Success!',
      message: 'Your action was completed successfully.',
      icon: AppIcons.checkCircle,
    );
  }

  void _showErrorExample(BuildContext context) {
    ModalService.showErrorDialog(
      context,
      title: 'Error',
      message: 'Something went wrong. Please try again.',
    );
  }

  void _showLoadingExample(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Row(
          children: [
            const LoadingIndicator(),
            const SizedBox(width: 24),
            Text('Processing...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showBottomSheetExample(BuildContext context) {
    ModalService.showBottomSheet(
      context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bottom Sheet Example',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'This is a standard bottom sheet using ModalService.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
      height: 250,
    );
  }

  void _showDesignGuide(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modal Design Guidelines'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GuidelineItem(
                title: 'Corner Radius',
                value: '24px for bottom sheets, 16px for dialogs',
              ),
              _GuidelineItem(
                title: 'Handle Bar',
                value: '40x4px, 0.3 opacity outline color',
              ),
              _GuidelineItem(
                title: 'Padding',
                value: '24px horizontal, 16-24px vertical',
              ),
              _GuidelineItem(
                title: 'Background',
                value: 'context.colors.surface',
              ),
              _GuidelineItem(
                title: 'Title Style',
                value: 'titleLarge, bold weight',
              ),
              _GuidelineItem(
                title: 'Body Text',
                value: 'bodyMedium, onSurfaceVariant color',
              ),
              _GuidelineItem(
                title: 'Primary Button',
                value: 'FilledButton, full width',
              ),
              _GuidelineItem(
                title: 'Secondary Button',
                value: 'OutlinedButton or TextButton',
              ),
              _GuidelineItem(
                title: 'Spacing',
                value: 'Use multiples of 4: 8, 12, 16, 20, 24',
              ),
              _GuidelineItem(
                title: 'Icons',
                value: 'AppIcons.* with SemanticIcon wrapper',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_ModalItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: icon,
              semanticLabel: title,
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}

class _ModalItem extends StatelessWidget {
  const _ModalItem({
    required this.name,
    required this.description,
    required this.onTap,
  });

  final String name;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.openInNew,
                  semanticLabel: 'Open $name',
                  size: AppIconSize.small,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  const _GuidelineItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
