// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FitLog Pro';

  @override
  String get welcome => 'Ready to train?';

  @override
  String get welcomeDescription =>
      'Track workouts, time your rest periods, and sync with Apple Health.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Your Workout Hub';

  @override
  String get onboardingWelcomeDescription =>
      'Track your progress, achieve your goals with the most comprehensive workout tracker';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start!';

  @override
  String get onboardingTitle => 'AI Coach Setup';

  @override
  String get onboardingExperienceTitle => 'What\'s your training experience?';

  @override
  String get onboardingExperienceSubtitle =>
      'Help us personalize your insights';

  @override
  String get beginnerLevel => 'Beginner';

  @override
  String get beginnerLevelDescription => '0-6 months of training';

  @override
  String get intermediateLevel => 'Intermediate';

  @override
  String get intermediateLevelDescription => '6-24 months of training';

  @override
  String get advancedLevel => 'Advanced';

  @override
  String get advancedLevelDescription => '2+ years of training';

  @override
  String get onboardingExitTitle => 'Exit Onboarding?';

  @override
  String get onboardingExitMessage =>
      'You can always set up AI Coach later in Settings';

  @override
  String get onboardingGoalTitle => 'What\'s your primary goal?';

  @override
  String get onboardingGoalSubtitle =>
      'We\'ll tailor insights to your training focus';

  @override
  String get hypertrophyGoal => 'Muscle Growth';

  @override
  String get hypertrophyGoalDescription => '8-12 reps, 60-90s rest';

  @override
  String get strengthGoal => 'Max Strength';

  @override
  String get strengthGoalDescription => '1-5 reps, 3-5min rest';

  @override
  String get enduranceGoal => 'Endurance';

  @override
  String get enduranceGoalDescription => '15+ reps, <30s rest';

  @override
  String get onboardingQuickWinTitle => 'Your Quick Win';

  @override
  String get onboardingQuickWinSubtitle =>
      'We analyzed your workouts. Here\'s your first insight!';

  @override
  String get analyzingWorkouts => 'Analyzing your workouts...';

  @override
  String get noWorkoutsYet => 'No workouts yet';

  @override
  String get noWorkoutsYetDescription =>
      'Start training and AI Coach will provide personalized insights!';

  @override
  String get beginnerQuickWinTitle => 'Great Start!';

  @override
  String get beginnerQuickWinDescription =>
      'You\'re building solid training foundations. Consistency is key!';

  @override
  String get beginnerQuickWinRecommendation =>
      'Focus on mastering proper form before increasing weight';

  @override
  String get intermediateQuickWinTitle => 'Balance Your Volume';

  @override
  String get intermediateQuickWinDescription =>
      'We detected potential muscle group imbalances in your training';

  @override
  String get intermediateQuickWinRecommendation =>
      'Add 2-3 more sets for lagging muscle groups each week';

  @override
  String get advancedQuickWinTitle => 'Break the Plateau';

  @override
  String get advancedQuickWinDescription =>
      'Your progress has stalled. Time to implement periodization!';

  @override
  String get advancedQuickWinRecommendation =>
      'Try deload weeks (40-50% volume) every 4-6 weeks for recovery';

  @override
  String get onboardingNotificationsTitle => 'Stay on Track';

  @override
  String get onboardingNotificationsSubtitle =>
      'Get timely insights to optimize your training';

  @override
  String get notificationBenefit1Title => 'Smart Insights';

  @override
  String get notificationBenefit1Description =>
      'Receive AI-powered coaching tips when you need them most';

  @override
  String get notificationBenefit2Title => 'Progress Updates';

  @override
  String get notificationBenefit2Description =>
      'Get notified when you break personal records or hit milestones';

  @override
  String get notificationBenefit3Title => 'Recovery Reminders';

  @override
  String get notificationBenefit3Description =>
      'Avoid overtraining with smart rest day recommendations';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWhatToExpect => 'What to expect:';

  @override
  String get onboardingModeTitle => 'Choose Your Experience';

  @override
  String get onboardingBaseMode => 'Base Mode';

  @override
  String get onboardingBaseModeDescription =>
      'Essential features for effective workouts. Perfect for beginners and focused training.';

  @override
  String get onboardingProMode => 'Pro Mode';

  @override
  String get onboardingProModeDescription =>
      'Advanced tracking with RPE, TUT, analytics and all features unlocked.';

  @override
  String get onboardingModeInfluenceDescription =>
      'The mode influences which features are visible and available';

  @override
  String get onboardingTimerRestTitle => 'Timer and Rest';

  @override
  String get onboardingTimerRestDescription =>
      'Discover how it works:\\n\\n• Automatic rest timer\\n• Live Activities on iOS\\n• Duration customization\\n• Sounds and notifications\\n• Custom timers per exercise\\n• Background functionality';

  @override
  String get onboardingAdvancedFeaturesTitle => 'Advanced Features';

  @override
  String get onboardingAdvancedFeaturesDescription =>
      'Explore Pro features:\\n\\n• Supersets and Dropsets\\n• Rest-Pause and advanced techniques\\n• Analytics and insights\\n• Community suggestions\\n• Automatic warmups\\n• 1-Rep Max calculation\\n• Export and sharing';

  @override
  String get onboardingCongratulations => 'Congratulations!';

  @override
  String get onboardingCompletedMessage =>
      'You have completed the complete FitLog Pro tutorial. Now you\'re ready to start your workouts!';

  @override
  String get selected => 'selected';

  @override
  String get onboardingFeaturesTitle => 'Powerful Features';

  @override
  String get onboardingFeature1 => 'Track sets, reps, and weight';

  @override
  String get onboardingFeature2 => 'Rest timer with Live Activities';

  @override
  String get onboardingFeature3 => 'Create and save templates';

  @override
  String get onboardingFeature4 => 'Supersets and dropsets';

  @override
  String get onboardingCustomizeTitle => 'Make It Yours';

  @override
  String get onboardingCustomizeDescription =>
      'Customize timers, sounds, themes and display options to match your training style.';

  @override
  String get onboardingGetStartedTitle => 'Ready to Train';

  @override
  String get onboardingGetStartedDescription =>
      'Start with a template or create your own custom workout. Let\'s begin your fitness journey!';

  @override
  String get onboardingDone => 'Get Started';

  @override
  String onboardingProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get globalOnboardingTitle => 'Complete FitLog Pro Guide';

  @override
  String get globalOnboardingDescription =>
      'Learn everything about the app with this interactive step-by-step tutorial';

  @override
  String get togglePanoramaTitle => 'Toggle Overview & Customizations';

  @override
  String get togglePanoramaDescription =>
      'Explore all available features and discover how to customize your experience';

  @override
  String currentMode(String mode) {
    return 'Current mode: $mode';
  }

  @override
  String get toggleSettingsHint =>
      'You can change any toggle anytime from settings ⚙️';

  @override
  String get createWorkoutStepTitle => 'Creating a Workout';

  @override
  String get createWorkoutStepDescription =>
      'Learn how to:\\n\\n• Create a new workout\\n• Use existing templates\\n• Customize the name\\n• Set your goals';

  @override
  String get addExerciseStepTitle => 'Adding an Exercise';

  @override
  String get addExerciseStepDescription =>
      'Step-by-step tutorial for:\\n\\n• Searching exercises in database\\n• Adding manual exercises\\n• Setting sets and reps\\n• Configuring weight and RPE\\n• Adding personal notes';

  @override
  String get executeSetStepTitle => 'Executing a Set';

  @override
  String get executeSetStepDescription =>
      'Learn to:\\n\\n• Mark sets as completed\\n• Use Quick Edit for rapid changes\\n• Rate RPE (Pro mode)\\n• Track weight and reps\\n• Handle failed or partial sets';

  @override
  String get timerRestStepTitle => 'Timer & Rest';

  @override
  String get advancedFeaturesStepTitle => 'Advanced Features';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get onboardingComplete =>
      'You\'ve completed the complete FitLog Pro tutorial. You\'re now ready to start your workouts!';

  @override
  String get onboardingTryItOut => 'Try it out!';

  @override
  String get onboardingTapToComplete => 'Tap to complete';

  @override
  String get onboardingExampleWorkout => 'Example Workout';

  @override
  String get onboardingSearchExercises => 'Search exercises...';

  @override
  String get onboardingMockExercise => 'Push ups';

  @override
  String get onboardingMockDescription =>
      'Classic bodyweight exercise for chest, shoulders and triceps';

  @override
  String get onboardingCompleted => 'Completed!';

  @override
  String get onboardingWelcomeMissionTitle => 'Our Mission';

  @override
  String get onboardingWelcomeMission =>
      'Your workout companion that never replaces your trainer but provides scientific data to help you reach your goals.';

  @override
  String get onboardingWelcomeFeature1Title => 'Interactive Tutorial';

  @override
  String get onboardingWelcomeFeature1Description =>
      'Learn by using the app in real time';

  @override
  String get onboardingWelcomeFeature2Title => 'Complete Customization';

  @override
  String get onboardingWelcomeFeature2Description =>
      'Discover all toggles and options';

  @override
  String get onboardingWelcomeFeature3Title => 'Complete Workflow';

  @override
  String get onboardingWelcomeFeature3Description => 'From setup to execution';

  @override
  String get onboardingWelcomeFeature4Title => 'Base and Pro Modes';

  @override
  String get onboardingWelcomeFeature4Description =>
      'Choose your functionality level';

  @override
  String get onboardingWelcomeCallToAction =>
      'This tutorial will guide you step by step through all app features. You can skip or repeat any section.';

  @override
  String get onboardingVideoPlaceholder => 'Video Missing';

  @override
  String get onboardingVideoComingSoon => 'Tutorial video coming soon!';

  @override
  String get onboardingTogglePanoramaTitle =>
      'Toggle Overview & Customizations';

  @override
  String get onboardingTogglePanoramaDescription =>
      'Explore all available features and discover how to customize your experience';

  @override
  String get onboardingToggleAdvancedTrackingTitle => 'Advanced Tracking';

  @override
  String get onboardingToggleAdvancedTrackingDescription =>
      'Features for detailed monitoring';

  @override
  String get onboardingToggleTimerAutomationTitle => 'Timer and Automation';

  @override
  String get onboardingToggleTimerAutomationDescription =>
      'Automatic rest time management';

  @override
  String get onboardingToggleInterfaceTitle => 'Interface and Tips';

  @override
  String get onboardingToggleInterfaceDescription =>
      'User experience customization';

  @override
  String get onboardingToggleSupportTitle => 'Support and Assistance';

  @override
  String get onboardingToggleSupportDescription =>
      'Tips and help during workouts';

  @override
  String get onboardingToggleSettingsChangePart1 =>
      'You can change any toggle anytime from';

  @override
  String get onboardingToggleSettingsChangePart2 => 'Customize Workout';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get quickWorkout => 'Quick Workout';

  @override
  String get quickWorkoutSubtitle => 'Start with empty workout';

  @override
  String get sessioneLibera => 'Free Session';

  @override
  String get suggested => 'Suggested';

  @override
  String get notWhatYouWanted => '💡 Not what you wanted?';

  @override
  String get browseTemplates => 'Browse Templates';

  @override
  String get upperBody => 'Upper Body';

  @override
  String get upperBodySubtitle => 'Chest, Back, Shoulders, Arms';

  @override
  String get lowerBody => 'Lower Body';

  @override
  String get lowerBodySubtitle => 'Legs, Glutes, Calves';

  @override
  String get exerciseSync => 'Exercise Sync';

  @override
  String get syncIdle => 'Ready';

  @override
  String get syncLoading => 'Loading...';

  @override
  String get syncSyncing => 'Syncing...';

  @override
  String get syncSuccess => 'Sync successful';

  @override
  String syncError(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get checkingStatus => 'Checking status...';

  @override
  String get statusError => 'Status error';

  @override
  String get versionInfo => 'Version Info';

  @override
  String get localVersion => 'Local Version';

  @override
  String get remoteVersion => 'Remote Version';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get checkingVersion => 'Checking version...';

  @override
  String get versionCheckError => 'Version check error';

  @override
  String get forceSync => 'Force Sync';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get autoSync => 'Auto Sync';

  @override
  String get autoSyncDescription =>
      'Automatically sync exercises in background';

  @override
  String get syncFrequency => 'Sync Frequency';

  @override
  String get everyHour => 'Every Hour';

  @override
  String get every6Hours => 'Every 6 Hours';

  @override
  String get every12Hours => 'Every 12 Hours';

  @override
  String get daily => 'Daily';

  @override
  String get every => 'Every';

  @override
  String get hours => 'hours';

  @override
  String get selectSyncFrequency => 'Select Sync Frequency';

  @override
  String get cacheStatistics => 'Cache Statistics';

  @override
  String get cachedExercises => 'Cached Exercises';

  @override
  String get cacheSize => 'Cache Size';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get loading => 'Loading...';

  @override
  String get ago => 'ago';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirmation =>
      'Are you sure you want to clear the exercise cache? This will remove all cached exercises and they will be downloaded again on next sync.';

  @override
  String get clearExerciseCacheDesc =>
      'Clear cached exercise database and force reload from JSON assets';

  @override
  String get exerciseCacheCleared =>
      'Exercise cache cleared successfully! Exercises will reload from JSON assets on next use.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get hiitTraining => 'HIIT Training';

  @override
  String get hiitTrainingSubtitle => 'High intensity intervals';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get completeWorkout => 'Complete Workout';

  @override
  String get newWorkout => 'New Workout';

  @override
  String get workoutName => 'Workout Name';

  @override
  String get workoutNameHint => 'e.g. Morning Session';

  @override
  String get exerciseName => 'Exercise';

  @override
  String get exerciseNameHint => 'e.g., Bench Press';

  @override
  String get importWorkoutTemplate => 'Import Workout Template';

  @override
  String get exportTemplates => 'Export Templates';

  @override
  String get importFormat => 'Import Format';

  @override
  String get naturalLanguageText => 'Natural Language';

  @override
  String get jsonFile => 'JSON File';

  @override
  String get workoutDescription => 'Workout Description';

  @override
  String get pasteWorkoutHere =>
      'Paste your workout description here...\n\nExample:\nLUNEDÌ - PUSH\nPanca Piana - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg';

  @override
  String get aiParsingInstructions => 'AI Parsing Instructions';

  @override
  String get aiInstructionsHint =>
      'Optional: Provide additional context for better parsing (e.g., language, units, custom exercise names)';

  @override
  String get aiInstructionsExample =>
      'Example: \"Text is in Italian, weights are in kg, \'Panca\' means Bench Press\"';

  @override
  String get selectJsonFile => 'Select JSON File';

  @override
  String get tapToSelectFile => 'Tap to select file';

  @override
  String get supportedFormats => 'Supports .json and .txt files';

  @override
  String get startImport => 'Start Import';

  @override
  String get exerciseDisambiguation => 'Exercise Disambiguation';

  @override
  String get percentageConversion => 'Percentage Weight Conversion';

  @override
  String get continueImport => 'Continue Import';

  @override
  String get finalizeImport => 'Finalize Import';

  @override
  String get importSuccessful => 'Import completed successfully!';

  @override
  String get importing => 'Importing...';

  @override
  String get importCompleted => 'Import Completed';

  @override
  String templatesImportedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates imported successfully!',
      one: '1 template imported successfully!',
    );
    return '$_temp0';
  }

  @override
  String get exportingTemplates => 'Exporting Templates';

  @override
  String get templatesSelected => 'templates selected';

  @override
  String get freeAccount => 'Free Account';

  @override
  String get premiumAccount => 'Premium Account';

  @override
  String get freeExportLimitations =>
      'Limited to 1 template export, no analytics data';

  @override
  String get premiumExportFeatures =>
      'Batch export, analytics data, multiple formats';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get downloadJson => 'Download JSON';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get exportSuccessful => 'Export completed successfully!';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get gymbroTemplatesExport => 'FitLog Pro Workout Templates Export';

  @override
  String get exportLimits => 'Export Limits';

  @override
  String get yourCurrentLimits => 'Your current export limits:';

  @override
  String get close => 'Close';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get upgradeToExportMore =>
      'Upgrade to premium to export more templates with analytics data.';

  @override
  String get pleaseSignIn => 'Please sign in to use export features';

  @override
  String get aiPromptHelper => 'AI Prompt Helper';

  @override
  String get createNew => 'Create New';

  @override
  String get convertExisting => 'Convert Existing';

  @override
  String get howToUse => 'How to Use';

  @override
  String get createNewWorkout => 'Create New Workout with AI';

  @override
  String get createNewWorkoutDesc =>
      'Generate a custom prompt to create workout templates with external AI services';

  @override
  String get selectWorkoutType => 'Select Workout Type';

  @override
  String get selectDifficulty => 'Select Difficulty Level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationDescription =>
      'Send a test notification to verify that notifications are working correctly';

  @override
  String get testNotificationSent => 'Test Notification Sent!';

  @override
  String get testNotificationSentDescription =>
      'Check your notification center to verify it works';

  @override
  String get prNotifications => 'New Personal Records';

  @override
  String get prNotificationsDescription =>
      'Get notified when you set a new personal record';

  @override
  String get streakAchievements => 'Workout Streaks';

  @override
  String get streakAchievementsDescription =>
      'Celebrate your workout consistency milestones';

  @override
  String get goalCompletions => 'Goal Completions';

  @override
  String get goalCompletionsDescription =>
      'Reach your monthly volume and workout goals';

  @override
  String get milestones => 'Milestones';

  @override
  String get milestonesDescription => 'Track major workout count achievements';

  @override
  String get customRequest => 'Custom Request (Optional)';

  @override
  String get customRequestHint =>
      'e.g., Focus on compound movements, 45-minute workout, minimal equipment';

  @override
  String get generatedPrompt => 'Generated AI Prompt';

  @override
  String get convertExistingWorkout => 'Convert Existing Workout';

  @override
  String get convertExistingDesc =>
      'Convert your existing workout text into FitLog Pro JSON format';

  @override
  String get pasteWorkoutText => 'Paste Your Workout Text';

  @override
  String get workoutTextHint =>
      'MONDAY - PUSH\nBench Press - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg\n...';

  @override
  String get generateConversionPrompt => 'Generate Conversion Prompt';

  @override
  String get conversionPrompt => 'Conversion Prompt';

  @override
  String get stepByStepGuide => 'Step-by-Step Guide';

  @override
  String get followTheseSteps =>
      'Follow these simple steps to create workout templates with AI';

  @override
  String get troubleshooting => 'Troubleshooting';

  @override
  String get promptToCopy => 'Prompt to Copy';

  @override
  String get copyPrompt => 'Copy Prompt';

  @override
  String get quickAIAccess => 'Quick AI Access';

  @override
  String get copyPromptAndOpenAI => 'Copy Prompt & Open AI Service';

  @override
  String get instructions => 'Instructions';

  @override
  String get conversionInstructions =>
      '1. Copy the prompt above 2. Open an AI service 3. Paste and send 4. Copy the JSON result 5. Import to FitLog Pro';

  @override
  String get creationInstructions =>
      '1. Copy the prompt above 2. Open an AI service 3. Paste and send 4. Copy the JSON result 5. Import to FitLog Pro';

  @override
  String get promptCopied => 'Prompt Copied!';

  @override
  String get promptCopiedDesc =>
      'The AI prompt has been copied to your clipboard.';

  @override
  String get nextSteps => 'Next steps:';

  @override
  String get step1OpenAI =>
      'Open your preferred AI service (ChatGPT, Claude, etc.)';

  @override
  String get step2PastePrompt => 'Paste the copied prompt and send';

  @override
  String get step3CopyJSON => 'Copy the JSON response from the AI';

  @override
  String get step4ReturnToApp =>
      'Return to FitLog Pro and use \'Import Template\'';

  @override
  String get gotIt => 'Got it!';

  @override
  String get openChatGPT => 'Open ChatGPT';

  @override
  String get cannotOpenUrl => 'Cannot open this URL';

  @override
  String get errorOpeningUrl => 'Error opening URL';

  @override
  String get pleaseEnterWorkoutText => 'Please enter workout text to convert';

  @override
  String get exerciseCategory => 'Exercise Category';

  @override
  String get sets => 'sets';

  @override
  String get addSet => 'Add Set';

  @override
  String get weight => 'Weight';

  @override
  String get oneRmEstimated => '1RM (Est.)';

  @override
  String get weightTimesReps => 'Weight × Reps';

  @override
  String get reps => 'reps';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Add form cues, progression notes, etc.';

  @override
  String get exerciseTypeSingle => 'Single';

  @override
  String get exerciseTypeSuperset => 'Superset';

  @override
  String get exerciseTypeDropset => 'DropSet';

  @override
  String get exerciseTypeRestPause => 'Rest-Pause';

  @override
  String get exerciseCategoryChest => 'Chest';

  @override
  String get exerciseCategoryBack => 'Back';

  @override
  String get exerciseCategoryShoulders => 'Shoulders';

  @override
  String get exerciseCategoryArms => 'Arms';

  @override
  String get exerciseCategoryLegs => 'Legs';

  @override
  String get exerciseCategoryAbs => 'Abs';

  @override
  String get exerciseCategoryCardio => 'Cardio';

  @override
  String get exerciseCategoryOther => 'Other';

  @override
  String get workoutStatusPlanned => 'Planned';

  @override
  String get workoutStatusInProgress => 'In Progress';

  @override
  String get workoutStatusCompleted => 'Completed';

  @override
  String get workoutStatusPaused => 'Paused';

  @override
  String get exercises => 'exercises';

  @override
  String get progress => 'Progress';

  @override
  String get workoutProgress => 'Workout Progress';

  @override
  String get tutTitle => 'Time Under Tension (T.U.T.)';

  @override
  String get tutEccentricPhase => 'Eccentric';

  @override
  String get tutEccentricDescription => 'Lowering/lengthening phase (seconds)';

  @override
  String get tutBottomPausePhase => 'Bottom Pause';

  @override
  String get tutBottomPauseDescription => 'Pause at bottom position (seconds)';

  @override
  String get tutConcentricPhase => 'Concentric';

  @override
  String get tutConcentricDescription => 'Lifting/shortening phase (seconds)';

  @override
  String get tutTopPausePhase => 'Top Pause';

  @override
  String get tutTopPauseDescription => 'Pause at top position (seconds)';

  @override
  String get tutPresets => 'Presets';

  @override
  String get tutPresetStandard => 'Standard';

  @override
  String get tutPresetSlow => 'Slow';

  @override
  String get tutPresetExplosive => 'Explosive';

  @override
  String get tutPresetIsometric => 'Isometric';

  @override
  String get tutCurrentTempo => 'Current Tempo';

  @override
  String get tutPhaseBreakdown => 'Phase Breakdown';

  @override
  String get tutEccentricFullDescription =>
      'Slowly lower the weight, controlling the movement with muscle tension';

  @override
  String get tutBottomPauseFullDescription =>
      'Hold the stretched position briefly to maximize muscle activation';

  @override
  String get tutConcentricFullDescription =>
      'Lift the weight with controlled force, focusing on muscle contraction';

  @override
  String get tutTopPauseFullDescription =>
      'Brief pause at peak contraction to enhance muscle engagement';

  @override
  String get tutExample => 'Example: 3-1-2-0';

  @override
  String tutExampleStandard(
    String eccentric,
    String bottomPause,
    String concentric,
    String topPause,
  ) {
    return 'Take $eccentric seconds to lower, pause $bottomPause seconds at bottom, take $concentric seconds to lift, then pause $topPause seconds at top.';
  }

  @override
  String get tutExampleExplosive =>
      'Move explosively during the marked phases (X) while maintaining control during the timed phases.';

  @override
  String get tutExampleIsometric =>
      'Hold the position without movement for the specified duration, focusing on muscle tension.';

  @override
  String get tutSubtitle => 'Control your tempo for better results';

  @override
  String get tutExplanationTitle => 'Understanding T.U.T. Format';

  @override
  String get tutFormat => 'Format: Eccentric - Pause 1 - Concentric - Pause 2';

  @override
  String get tutPhaseEccentric => 'Eccentric Phase';

  @override
  String get tutPhaseEccentricDesc =>
      'Lowering/lengthening the muscle (e.g., lowering the bar in bench press)';

  @override
  String get tutPhasePause1 => 'Bottom Pause';

  @override
  String get tutPhasePause1Desc => 'Hold at the bottom/stretched position';

  @override
  String get tutPhaseConcentric => 'Concentric Phase';

  @override
  String get tutPhaseConcentricDesc =>
      'Lifting/shortening the muscle (e.g., pressing the bar up)';

  @override
  String get tutPhasePause2 => 'Top Pause';

  @override
  String get tutPhasePause2Desc => 'Hold at the top/contracted position';

  @override
  String get tutExampleDesc =>
      '3 seconds down, 1 second pause, 2 seconds up, no pause at top';

  @override
  String get tutBenefits => 'Benefits of Controlled Tempo';

  @override
  String get tutBenefit1 => 'Increased muscle tension and growth';

  @override
  String get tutBenefit2 => 'Better mind-muscle connection';

  @override
  String get tutBenefit3 => 'Improved form and control';

  @override
  String get tutBenefit4 => 'Reduced injury risk';

  @override
  String get noExercisesYet => 'No exercises yet';

  @override
  String get tapToAddExercise => 'Tap the + button to add your first exercise';

  @override
  String get confirm => 'Confirm';

  @override
  String get start => 'Start';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get searchExercisesHint => 'Type to search exercise database';

  @override
  String get supersetInfo =>
      'Superset combines 2+ exercises performed back-to-back with minimal rest.';

  @override
  String get dropsetInfo =>
      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.';

  @override
  String get restPauseInfo =>
      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get pauseWorkout => 'Pause Workout';

  @override
  String get endWorkout => 'End Workout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLightDesc => 'Always use light theme';

  @override
  String get themeDarkDesc => 'Always use dark theme';

  @override
  String get themeSystemDesc => 'Follow system setting';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get workout => 'Workout';

  @override
  String get autoStartTimer => 'Auto-start Timer';

  @override
  String get autoStartTimerDesc => 'Start rest timer after completing set';

  @override
  String get defaultRestTime => 'Default Rest Time';

  @override
  String get advancedTechniques => 'Advanced Techniques';

  @override
  String get advancedTechniquesDesc => 'Show drop sets, supersets, etc.';

  @override
  String get unitsLanguage => 'Units & Language';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglishDesc => 'English (US)';

  @override
  String get languageItalianDesc => 'Italian (IT)';

  @override
  String get weightUnits => 'Weight Units';

  @override
  String get weightUnitsKg => 'Kilograms (kg)';

  @override
  String get weightUnitsLbs => 'Pounds (lbs)';

  @override
  String get weightUnitsKgDesc => 'Metric system';

  @override
  String get weightUnitsLbsDesc => 'Imperial system';

  @override
  String get iosFeatures => 'iOS Features';

  @override
  String get liveActivities => 'Live Activities';

  @override
  String get liveActivitiesDesc => 'Show timer on lock screen & Dynamic Island';

  @override
  String get healthAppSync => 'Health App Sync';

  @override
  String get healthAppSyncDesc => 'Sync workouts to Apple Health';

  @override
  String get audioFeedback => 'Audio & Feedback';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDesc => 'Play sounds for timer and completion';

  @override
  String get vibrations => 'Vibrations';

  @override
  String get vibrationsDesc => 'Haptic feedback for interactions';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String get exportSettingsDesc => 'Save settings as JSON file';

  @override
  String get importSettings => 'Import Settings';

  @override
  String get importSettingsDesc => 'Load settings from JSON file';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get resetToDefaultsDesc => 'Restore all settings to default';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get signOutDesc => 'Sign out of your account';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get save => 'Save';

  @override
  String get accept => 'Accept';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get restTimeSuggestion => 'Rest Time Suggestion';

  @override
  String get reset => 'Reset';

  @override
  String get settingsResetSuccess => 'Settings reset to defaults';

  @override
  String get exportFunctioningComingSoon => 'Export functionality coming soon';

  @override
  String get importFunctioningComingSoon => 'Import functionality coming soon';

  @override
  String get editExercise => 'Edit Exercise';

  @override
  String get exerciseRestTime => 'Rest Time';

  @override
  String get exerciseRestTimeDesc => 'Rest time for this exercise';

  @override
  String get restTimeSeconds => 'seconds';

  @override
  String get setRestTime => 'Set Timer';

  @override
  String get customRestTime => 'Custom Timer';

  @override
  String get useDefaultRestTime => 'Use Default Timer';

  @override
  String get yourTemplates => 'Your Templates';

  @override
  String get popularTemplates => 'Popular Templates';

  @override
  String get seeAll => 'See all';

  @override
  String get welcomeToGymBro => 'Welcome to your new fitness companion!';

  @override
  String get homeWelcomeDescription =>
      'Track your workouts with precision. Start a new session or continue where you left off.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get startFresh => 'Start fresh';

  @override
  String get history => 'History';

  @override
  String get viewPastWorkouts => 'View past workouts';

  @override
  String get analytics => 'Analytics';

  @override
  String get trackProgress => 'Track progress';

  @override
  String get templates => 'Templates';

  @override
  String get workoutRoutines => 'Workout routines';

  @override
  String get customizeApp => 'Customize app';

  @override
  String get importExercises => 'Import Exercises';

  @override
  String get loadFromJson => 'Load from JSON';

  @override
  String get activeWorkout => 'Active Workout';

  @override
  String get pausedWorkout => 'Paused Workout';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get resume => 'Resume';

  @override
  String get end => 'END';

  @override
  String get endWorkoutConfirm =>
      'Are you sure you want to end your current workout?';

  @override
  String get workoutCompleted => '🎉 Workout completed!';

  @override
  String get appSettings => 'App Settings';

  @override
  String get historyFeatureComingSoon => 'History feature coming soon!';

  @override
  String get customizeTemplate => 'Customize this template';

  @override
  String get deleteTemplatePermanently => 'Delete this template permanently';

  @override
  String get removeExercise => 'Remove Exercise';

  @override
  String confirmRemoveExercise(String exerciseName) {
    return 'Remove \"$exerciseName\" from template?';
  }

  @override
  String get timerSound => 'Timer Sound';

  @override
  String get timerSoundDescription =>
      'Choose the sound that plays when the rest timer completes';

  @override
  String get currentSound => 'Current';

  @override
  String get playPreview => 'Play Preview';

  @override
  String get playingPreview => 'Playing preview';

  @override
  String get statisticsDashboard => 'Statistics Dashboard';

  @override
  String get workoutAnalytics => 'Workout Analytics';

  @override
  String get progressTracking => 'Progress Tracking';

  @override
  String get detailedAnalytics => 'Detailed Analytics';

  @override
  String get thisWeek => 'This Week';

  @override
  String get totalVolume => 'total';

  @override
  String get consistency => 'Consistency';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get completedSessions => 'Completed Sessions';

  @override
  String get weightLifted => 'Weight Lifted';

  @override
  String get averageWorkoutTime => 'Average Workout Time';

  @override
  String get perSession => 'Per Session';

  @override
  String get personalRecords => 'Personal Records';

  @override
  String get newPRs => 'New PRs';

  @override
  String get weeklyVolumeChart => 'Weekly Volume Chart';

  @override
  String get workoutFrequency => 'Workout Frequency';

  @override
  String get bodyPartDistribution => 'Body Part Distribution';

  @override
  String get topExercises => 'Top Exercises';

  @override
  String get workoutStreak => 'Workout Streak';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get nextMilestone => 'Next Milestone';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get totalDays => 'Total Days';

  @override
  String get days => 'days';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get exportData => 'Export Data';

  @override
  String get viewDetails => 'View Details';

  @override
  String get noVolumeData => 'No volume data available';

  @override
  String get noFrequencyData => 'No frequency data available';

  @override
  String get noBodyPartData => 'No body part data available';

  @override
  String get noExerciseData => 'No exercise data available';

  @override
  String get noWorkoutData => 'No workout data yet';

  @override
  String get completeWorkoutsToSeeAnalytics =>
      'Complete some workouts to see your\nanalytics and progress!';

  @override
  String get startFirstWorkout => 'Start Your First Workout';

  @override
  String volumeIncreased(String amount) {
    return 'Volume increased by ${amount}kg from last week';
  }

  @override
  String volumeDecreased(String amount) {
    return 'Volume decreased by ${amount}kg from last week';
  }

  @override
  String get workouts => 'workouts';

  @override
  String bestWorkoutDay(String day) {
    return 'Best workout day: $day';
  }

  @override
  String averageWorkoutsPerDay(String average) {
    return 'Average: $average workouts per day';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get filterStatistics => 'Filter Statistics';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get muscleGroups => 'Muscle Groups';

  @override
  String get musclePectorals => 'Pectorals';

  @override
  String get muscleLats => 'Lats';

  @override
  String get muscleDeltoids => 'Shoulders';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleTrapezius => 'Traps';

  @override
  String get muscleRhomboids => 'Rhomboids';

  @override
  String get muscleQuads => 'Quads';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleHamstrings => 'Hamstrings';

  @override
  String get muscleCalves => 'Calves';

  @override
  String get muscleAbs => 'Abs';

  @override
  String get muscleObliques => 'Obliques';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleForearms => 'Forearms';

  @override
  String get muscleAdductors => 'Adductors';

  @override
  String get muscleLowerBack => 'Lower Back';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get lastThreeMonths => 'Last 3 Months';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get improvingProgressSummary =>
      'Your progress is improving! Keep it up!';

  @override
  String get needsImprovementSummary =>
      'Your progress needs improvement. Stay consistent!';

  @override
  String get steadyProgressSummary =>
      'Your progress is steady. Great consistency!';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get workoutGoal => 'Workout Goal';

  @override
  String get volumeGoal => 'Volume Goal';

  @override
  String get rpe => 'RPE';

  @override
  String get rpeDescription => 'Rate of Perceived Exertion (6-10)';

  @override
  String get rir => 'RIR';

  @override
  String get rirDescription => 'Reps in Reserve';

  @override
  String get actualReps => 'Actual Reps';

  @override
  String targetReps(int reps) {
    return '$reps reps target';
  }

  @override
  String get repsCompleted => 'Reps Completed';

  @override
  String get actualRepsCompleted => 'Actual Reps Completed';

  @override
  String get recordSetCompletion => 'Record Set Completion';

  @override
  String get howHardWasTheSet => 'How hard was this set?';

  @override
  String get veryEasy => 'Very Easy';

  @override
  String get easy => 'Easy';

  @override
  String get moderate => 'Moderate';

  @override
  String get hard => 'Hard';

  @override
  String get maximal => 'Maximal';

  @override
  String get ofWord => 'of';

  @override
  String get skipRpe => 'Skip RPE';

  @override
  String get confirmSet => 'Confirm Set';

  @override
  String get repsInReserve => 'reps in reserve';

  @override
  String get preferredTemplateSet => 'Preferred template set!';

  @override
  String get preferredTemplateRemoved => 'Preferred template removed';

  @override
  String get choosePreferredTemplate => 'Choose Preferred Template';

  @override
  String get removePreferredTemplate => 'Remove Preferred Template';

  @override
  String get startWithEmptyWorkout => 'Start with an empty workout';

  @override
  String get tapToStart => 'Tap to start';

  @override
  String get errorLoadingTemplates => 'Error loading templates';

  @override
  String get syncingWorkouts => 'Syncing workouts...';

  @override
  String get loadingWorkouts => 'Loading workouts...';

  @override
  String get errorLoadingWorkouts => 'Error loading workouts';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark All as Read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationsDescription =>
      'We\'ll keep you updated on your progress!';

  @override
  String get workoutReminderTitle => 'Workout Reminder';

  @override
  String workoutReminderBody(String workoutName) {
    return 'Time for your $workoutName workout! 💪';
  }

  @override
  String get recoveryAlertTitle => 'Recovery Needed';

  @override
  String recoveryAlertBodySingle(int days) {
    return 'You have $days skipped day to recover! 🔄';
  }

  @override
  String recoveryAlertBodyMultiple(int days) {
    return 'You have $days skipped days to recover! 🔄';
  }

  @override
  String get streakMotivationTitle => 'Keep Your Streak Going!';

  @override
  String streakMotivationBody(int streak) {
    return '$streak days streak! Don\'t break it now! 🔥';
  }

  @override
  String get restDayTitle => 'Rest Day';

  @override
  String get restDayBody =>
      'Today is your rest day. Recovery is just as important! 😴';

  @override
  String get enableWorkoutReminders => 'Enable Workout Reminders';

  @override
  String get enableRecoveryAlerts => 'Enable Recovery Alerts';

  @override
  String get enableStreakMotivation => 'Enable Streak Motivation';

  @override
  String get enableRestDayReminders => 'Enable Rest Day Reminders';

  @override
  String get preferredNotificationTime => 'Preferred Time';

  @override
  String get doNotDisturb => 'Do Not Disturb';

  @override
  String get morningTime => 'Morning (8:00 AM)';

  @override
  String get middayTime => 'Midday (12:30 PM)';

  @override
  String get afternoonTime => 'Afternoon (4:00 PM)';

  @override
  String get eveningTime => 'Evening (7:00 PM)';

  @override
  String get customTime => 'Custom time';

  @override
  String get newWeightPR => 'New Weight PR!';

  @override
  String get newRepsPR => 'New Reps PR!';

  @override
  String get newOneRMPR => 'New 1RM PR!';

  @override
  String get newVolumePR => 'New Volume PR!';

  @override
  String get buildingMomentum => 'Building Momentum!';

  @override
  String get oneWeekStrong => 'One Week Strong!';

  @override
  String get twoWeeksStreak => 'Two Weeks Streak!';

  @override
  String get oneMonthStreak => 'ONE MONTH STREAK!';

  @override
  String get legendaryStreak => 'LEGENDARY STREAK!';

  @override
  String get volumeMilestone => 'Volume Milestone!';

  @override
  String get massiveVolume => 'MASSIVE VOLUME!';

  @override
  String get legendaryVolume => 'LEGENDARY VOLUME!';

  @override
  String get quickStats => 'Your Progress';

  @override
  String get streak => 'Streak';

  @override
  String get achievements => 'Achievements';

  @override
  String get exerciseInfo => 'Info';

  @override
  String get warmup => 'Warmup';

  @override
  String get safetyTips => 'Prevention';

  @override
  String get warmupAndMobility => 'Warmup & Mobility';

  @override
  String get exerciseInformation => 'Exercise Information';

  @override
  String get safetyAndPrevention => 'Safety & Prevention';

  @override
  String get preWorkoutMobility => 'Pre-Workout Mobility';

  @override
  String get muscleActivation => 'Muscle Activation';

  @override
  String get warmupSets => 'Warmup Sets';

  @override
  String get recommendedWarmup => 'Recommended Warmup';

  @override
  String get warmupSmart => 'SMART';

  @override
  String get warmupTap => 'Tap';

  @override
  String get warmupIntelligentProgression => 'Intelligent Progression';

  @override
  String warmupProgressionDescription(
    String startWeight,
    String endWeight,
    String steps,
  ) {
    return 'From ${startWeight}kg to ${endWeight}kg in $steps steps';
  }

  @override
  String get workingWeight => 'Working Weight';

  @override
  String get emptyBarbell => 'Empty Barbell';

  @override
  String get customize => 'Customize';

  @override
  String get addAll => 'Add All';

  @override
  String editSet(String percentage) {
    return 'Edit Set $percentage%';
  }

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String warmupSetsAdded(String count) {
    return 'Added $count warmup sets';
  }

  @override
  String get warmupDuration => 'Warmup Duration';

  @override
  String get primaryMuscles => 'Primary Muscles';

  @override
  String get secondaryMuscles => 'Secondary Muscles';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get exerciseType => 'Exercise Type';

  @override
  String get equipment => 'Equipment';

  @override
  String get movementPattern => 'Movement Pattern';

  @override
  String get repRange => 'Rep Range';

  @override
  String get injuryPrevention => 'Injury Prevention';

  @override
  String get recommendedCooldown => 'Recommended Cooldown';

  @override
  String get technicalDrills => 'Technical Drills';

  @override
  String get technicalNotes => 'Technical Tips';

  @override
  String get targetMuscles => 'Target muscles';

  @override
  String get exerciseDetails => 'Exercise Details';

  @override
  String get preparation => 'Preparation';

  @override
  String get specificWarmup => 'Specific Warmup';

  @override
  String get safetyAndTechnique => 'Safety & Technique';

  @override
  String get recovery => 'Recovery';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name!';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name!';
  }

  @override
  String get readyToDominate => 'Ready to dominate?';

  @override
  String get workoutActive => 'WORKOUT ACTIVE';

  @override
  String get workoutPaused => 'PAUSED';

  @override
  String get duration => 'Duration';

  @override
  String get reorderExercises => 'Reorder exercises';

  @override
  String get confirmReorder => 'Confirm order';

  @override
  String get orderSaved => 'Order saved';

  @override
  String get startNow => 'Start Now';

  @override
  String get startImmediately =>
      'Start immediately and add exercises on the fly';

  @override
  String get workoutStartedQuickly =>
      'Workout started! Add exercises as you go';

  @override
  String get calories => 'Calories';

  @override
  String get aiCoach => 'AI Coach';

  @override
  String get showPR => 'Show PR';

  @override
  String get analyzeVolume => 'Analyze volume';

  @override
  String get howIsTraining => 'How is training?';

  @override
  String get needRest => 'Need rest?';

  @override
  String criticalInsights(int count) {
    return '$count Critical';
  }

  @override
  String get noInsights => 'Great Work!';

  @override
  String get noInsightsDescription =>
      'You\'re training optimally. Keep up the excellent work!';

  @override
  String get errorLoadingInsights => 'Error loading insights';

  @override
  String get volume => 'Volume';

  @override
  String get startWorkoutQuick => 'START WORKOUT';

  @override
  String get suggestedForToday => 'Suggested for today';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get pushDay => 'Push Day';

  @override
  String get pullDay => 'Pull Day';

  @override
  String get legDay => 'Leg Day';

  @override
  String get chestShouldersTriceps => 'Chest, Shoulders, Triceps';

  @override
  String get backBiceps => 'Back, Biceps';

  @override
  String get legsGlutes => 'Legs, Glutes';

  @override
  String get intensiveCardio => 'Intensive Cardio';

  @override
  String get quickTemplates => 'Quick Templates';

  @override
  String get predefined => 'Predefined';

  @override
  String get myTemplates => 'My Templates';

  @override
  String get noPersonalTemplates => 'No personal templates';

  @override
  String get createFirstTemplate => 'Create your first template!';

  @override
  String get createTemplate => 'Create Template';

  @override
  String get otherTools => 'Other tools';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get pastWorkouts => 'Past workouts';

  @override
  String workoutStarted(String name) {
    return 'Workout \"$name\" started!';
  }

  @override
  String get templateNotFound => 'Template not found';

  @override
  String get loadingTemplate => 'Loading template...';

  @override
  String templateLoadError(String error) {
    return 'Error loading template: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String workoutInProgress(String name) {
    return 'You already have a workout in progress: $name';
  }

  @override
  String get workoutDiscarded => 'Workout discarded';

  @override
  String get workoutSavedSuccessfully => 'Workout saved successfully!';

  @override
  String get howToEndWorkout => 'How would you like to end the workout?';

  @override
  String get discard => 'Discard';

  @override
  String get saveAndEnd => 'Save and End';

  @override
  String get aiCoachFirstWorkout =>
      'Start your first workout to unlock personalized tips!';

  @override
  String aiCoachStreakMessage(int days) {
    return 'Great job! $days consecutive days of training. Keep this excellent pace!';
  }

  @override
  String aiCoachVolumeIncrease(String increase) {
    return 'Your volume increased by $increase! Keep going to maximize results';
  }

  @override
  String aiCoachNewPR(String weight, String exercise) {
    return 'You set a new PR of $weight on $exercise! Aim to beat it';
  }

  @override
  String get aiCoachConsistency =>
      'Focus on consistency: try to work out at least 3-4 times this week';

  @override
  String get aiCoachPersonalized => 'Personalized for you';

  @override
  String get aiCoachTapHint => 'Tap for detailed insights';

  @override
  String get aiCoachDetailed => 'AI Coach Insights';

  @override
  String get aiCoachModalPlaceholder =>
      'Smart insights coming soon! Your AI Coach will analyze your training patterns and provide personalized recommendations.';

  @override
  String get aiCoachDisclaimer =>
      'These are general recommendations based on your training data. Always consult with a qualified fitness professional before making significant changes to your training program.';

  @override
  String get aiBadge => 'AI';

  @override
  String get badgeCritical => 'CRITICAL';

  @override
  String get badgeWarning => 'WARNING';

  @override
  String get badgeInfo => 'INFO';

  @override
  String get badgeSuccess => 'GREAT';

  @override
  String get aiInsightStartJourney => 'Start Your Journey';

  @override
  String get aiInsightStartJourneyDesc =>
      'Begin tracking workouts to unlock personalized insights';

  @override
  String get aiInsightStartJourneyRec =>
      'Complete your first workout to get started';

  @override
  String get aiCoachSeriesPerWeek => 'series/week';

  @override
  String get aiCoachTons => 'tons';

  @override
  String get aiCoachCurrentVolume => 'Current volume';

  @override
  String get aiCoachProgressiveLoad => 'Progressive overload';

  @override
  String get aiCoachTimesPerWeek => 'times/week';

  @override
  String get aiCoachCurrentFrequency => 'Current frequency';

  @override
  String aiCoachMEVRange(String min, String max) {
    return 'MEV: $min-$max sets';
  }

  @override
  String get aiCoachScientificReferences => 'Scientific References';

  @override
  String get aiInsightNewUser => 'Great Start!';

  @override
  String get aiInsightNewUserDesc =>
      'You\'re building a strong foundation! Keep consistent for better insights';

  @override
  String get aiInsightNewUserRec =>
      'Complete 5+ workouts to unlock advanced AI analysis';

  @override
  String get aiInsightMuscleImbalance => 'Muscle Group Imbalance';

  @override
  String aiInsightMuscleImbalanceDesc(String muscleGroup) {
    return '$muscleGroup is undertrained this week';
  }

  @override
  String aiInsightMuscleImbalanceRec(String muscleGroup) {
    return 'Add 2-3 $muscleGroup exercises to your next workout';
  }

  @override
  String get aiInsightPlateauAlert => 'Plateau Alert';

  @override
  String aiInsightPlateauDesc(String exercise) {
    return '$exercise weight hasn\'t increased in 3+ sessions';
  }

  @override
  String get aiInsightPlateauRec =>
      'Try increasing weight by 2.5-5kg or add more reps';

  @override
  String get aiInsightInsufficientRecovery => 'Insufficient Recovery';

  @override
  String get aiInsightInsufficientRecoveryDesc =>
      'Training too frequently without rest';

  @override
  String get aiInsightInsufficientRecoveryRec =>
      'Consider adding 1-2 rest days between sessions';

  @override
  String get aiInsightLongRecovery => 'Long Recovery Periods';

  @override
  String get aiInsightLongRecoveryDesc => 'Too much time between workouts';

  @override
  String get aiInsightLongRecoveryRec =>
      'Try to maintain 2-3 days between sessions for optimal progress';

  @override
  String get aiInsightLowVolume => 'Low Training Volume';

  @override
  String aiInsightLowVolumeDesc(int sets) {
    return 'Current average: $sets sets per workout';
  }

  @override
  String get aiInsightLowVolumeRec =>
      'Consider adding 3-5 more sets to maximize growth';

  @override
  String get aiInsightHighVolume => 'High Training Volume';

  @override
  String aiInsightHighVolumeDesc(int sets) {
    return 'Current average: $sets sets per workout';
  }

  @override
  String get aiInsightHighVolumeRec =>
      'Consider reducing volume to avoid overtraining';

  @override
  String get aiInsightLowFrequency => 'Low Training Frequency';

  @override
  String aiInsightLowFrequencyDesc(String frequency) {
    return 'Currently training $frequency times per week';
  }

  @override
  String get aiInsightLowFrequencyRec =>
      'Aim for 3-4 sessions per week for optimal results';

  @override
  String get aiInsightHighFrequency => 'Very High Frequency';

  @override
  String aiInsightHighFrequencyDesc(String frequency) {
    return 'Training $frequency times per week';
  }

  @override
  String get aiInsightHighFrequencyRec =>
      'Consider adding more rest days to prevent burnout';

  @override
  String get aiInsightVolumePlateau => 'Volume Plateau Detected';

  @override
  String get aiInsightVolumePlateauDesc =>
      'Training volume hasn\'t increased significantly';

  @override
  String get aiInsightVolumePlateauRec =>
      'Try new exercises, techniques, or increase intensity';

  @override
  String get aiInsightOptimalVolume => 'Perfect Volume!';

  @override
  String aiInsightOptimalVolumeDesc(String muscleGroup, int sets) {
    return '$muscleGroup volume is in the optimal range ($sets sets/week)';
  }

  @override
  String get aiInsightOptimalVolumeRec =>
      'Keep this up! You\'re in the sweet spot for muscle growth';

  @override
  String get aiInsightLargeWeightJump => 'Large Weight Jump';

  @override
  String aiInsightLargeWeightJumpDesc(String exercise, int increase) {
    return '$exercise weight increased by $increase%';
  }

  @override
  String get aiInsightLargeWeightJumpRec =>
      'Ensure proper form with this weight increase';

  @override
  String get muscleGroupLegs => 'Legs';

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupBack => 'Back';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupArms => 'Arms';

  @override
  String get muscleGroupOther => 'Other';

  @override
  String get perWeek => '/week';

  @override
  String get target => 'Target';

  @override
  String get frequency => 'Frequency';

  @override
  String get noRecord => 'No record';

  @override
  String get startToday => 'Start today!';

  @override
  String get great => 'Great!';

  @override
  String get keepGoing => 'Keep going!';

  @override
  String get day => 'Day';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get weeklyFrequency => 'Weekly Frequency';

  @override
  String get excellentProgress => 'Excellent Progress!';

  @override
  String get goodProgress => 'Good Progress!';

  @override
  String get getStarted => 'Let\'s Get Started!';

  @override
  String get streakMotivation => 'Streak Motivation';

  @override
  String get consistencyMotivation =>
      'Great consistency! Keep building your momentum.';

  @override
  String get buildStreakMotivation =>
      'Build your streak by staying consistent!';

  @override
  String get streakInfo =>
      'Streak counts consecutive days with at least one completed workout.';

  @override
  String get totalWorkoutsInfo =>
      'Total number of workout sessions you\'ve completed.';

  @override
  String get weeklyFrequencyInfo =>
      'Average number of workout days per week over the last 4 weeks.';

  @override
  String get retry => 'Retry';

  @override
  String get community => 'Community';

  @override
  String get communityComingSoonTitle => 'Community Feature Coming Soon';

  @override
  String get communityComingSoonDescription =>
      'We\'re working on building an amazing community feature where you can connect with other athletes, share your progress, and learn from each other. Stay tuned!';

  @override
  String get generalInformation => 'General Information';

  @override
  String get technicalNotesAndTut => 'Technical Notes & TuT';

  @override
  String get warmupAndPreparation => 'Warmup & Preparation';

  @override
  String get technicalDrill => 'Technical Drill';

  @override
  String get termsExplanation => 'Terms Explanation';

  @override
  String get addToSelection => 'Add to Selection';

  @override
  String get exercisesFound => 'exercises found';

  @override
  String get addedToSelection => 'added to selection';

  @override
  String get primaryFocus => 'Primary Focus';

  @override
  String get preMobilityWork => 'Pre-Mobility Work';

  @override
  String get preActivation => 'Pre-Activation';

  @override
  String get filters => 'Filters';

  @override
  String get addToWorkout => 'Add to Workout';

  @override
  String get exercisesSelected => 'exercises selected';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get tryModifyingFilters => 'Try modifying the search filters';

  @override
  String get clearAllFilters => 'Clear all filters';

  @override
  String get minutes => 'min';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get errorOccurred => 'An error occurred while loading the workout';

  @override
  String get ok => 'OK';

  @override
  String get networkError => 'Network Error';

  @override
  String get databaseError => 'Database Error';

  @override
  String get validationError => 'Validation Error';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get storageError => 'Storage Error';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get userNotFound => 'User not found';

  @override
  String get wrongPassword => 'Wrong Password';

  @override
  String get emailAlreadyInUse => 'Email Already In Use';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get weakPassword => 'Weak Password';

  @override
  String get authenticationError => 'Authentication Error';

  @override
  String get criticalError => 'Critical Error';

  @override
  String get goBack => 'Go Back';

  @override
  String get startNewCycle => 'Start new cycle';

  @override
  String get continueRoutine => 'Continue your routine';

  @override
  String resumeAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Resume after $days $_temp0';
  }

  @override
  String restartCycleAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Restart cycle after $days $_temp0';
  }

  @override
  String get nextInRotation => 'Next in rotation';

  @override
  String get yourMostFrequentWorkout => 'Your most frequent workout';

  @override
  String get selectExercise => 'Select an exercise to view progress';

  @override
  String get originalExercise => 'Original exercise';

  @override
  String get suggestedMatches => 'Suggested matches';

  @override
  String get match => 'match';

  @override
  String get linkedTo => 'Linked to';

  @override
  String get skipExercise => 'Skip Exercise';

  @override
  String get createNewExercise => 'Create New';

  @override
  String get useSelectedExercise => 'Use Selected';

  @override
  String get workoutTemplates => 'Workout Templates';

  @override
  String get discover => 'Discover';

  @override
  String get searchContributions => 'Search contributions...';

  @override
  String get sort => 'Sort';

  @override
  String get noContributionsFound => 'No contributions found';

  @override
  String get tryDifferentSearch => 'Try adjusting your search or filters';

  @override
  String get errorLoadingContributions => 'Error loading contributions';

  @override
  String get trending => 'Trending';

  @override
  String get avgRating => 'Avg Rating';

  @override
  String get newTemplate => 'New Template';

  @override
  String get searchTemplates => 'Search templates...';

  @override
  String get noPublicTemplatesFound => 'No public templates found';

  @override
  String get trendingComingSoon => 'Trending templates coming soon!';

  @override
  String get maxTemplatesReached =>
      'You have reached the maximum number of templates';

  @override
  String get createManually => 'Create Manually';

  @override
  String get buildFromScratch => 'Build your template from scratch';

  @override
  String get importFromJSON => 'Import from JSON';

  @override
  String get importJSONDescription => 'Import a template from JSON format';

  @override
  String get importFromFile => 'Import from File';

  @override
  String get importFileDescription => 'Select a JSON file from your device';

  @override
  String get jsonFormatGuide => 'JSON Format Guide';

  @override
  String get jsonFormatDescription =>
      '📝 How to convert your workout:\n1. Copy your workout (text or photo)\n2. Go to ChatGPT (free at chat.openai.com)\n3. Ask: \"Convert this workout to JSON format like this example\"\n4. Copy and paste the result below\n\n⚙️ Required fields: name, description, exercises array. Each exercise needs: exerciseName, sets with targetReps/targetWeight. Supersets need type:\"superset\" and exercises array.';

  @override
  String get copyExample => 'Copy example';

  @override
  String get exampleCopied => 'Example copied to clipboard';

  @override
  String get exampleCopiedAndPasted => 'Example copied and pasted in field';

  @override
  String get tapToCopyAndPaste => 'Tap to copy and paste in field below';

  @override
  String get tapToCopyToClipboard => 'Tap to copy to clipboard';

  @override
  String get tapToExpandExample => 'Tap to expand example and guide';

  @override
  String get hideKeyboard => 'Hide Keyboard';

  @override
  String exerciseNotFoundInDatabase(String exerciseName) {
    return 'Exercise \"$exerciseName\" not found in database - using original name';
  }

  @override
  String get exerciseNotFound => 'Can\'t find the exercise?';

  @override
  String exerciseNotFoundDescription(String exerciseName) {
    return 'The exercise \"$exerciseName\" was not found in our database. What would you like to do?';
  }

  @override
  String get exerciseNotFoundHelpText =>
      'Add it temporarily and we\'ll include it in the database soon!';

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get chooseFromDatabase => 'Choose from Database';

  @override
  String get createCustom => 'Create Custom';

  @override
  String get useOriginalName => 'Use Original Name';

  @override
  String get skip => 'Skip';

  @override
  String get selectExerciseFromDatabase => 'Select Exercise from Database';

  @override
  String get noExercisesInDatabase => 'No exercises found in database';

  @override
  String get createCustomExercise => 'Create Custom Exercise';

  @override
  String get category => 'Category';

  @override
  String get customExerciseNote =>
      'This exercise will be saved to your personal list';

  @override
  String get create => 'Create';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get customExerciseLimit =>
      'Free users can create up to 3 custom exercises per import. Upgrade to Premium for unlimited custom exercises!';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String confirmDeleteTemplate(String templateName) {
    return 'Are you sure you want to delete \"$templateName\"?';
  }

  @override
  String templateDeleted(String name) {
    return 'Template \"$name\" deleted';
  }

  @override
  String get shareLinkCopied => 'Share link copied to clipboard!';

  @override
  String templateDownloaded(String templateName) {
    return 'Template \"$templateName\" downloaded!';
  }

  @override
  String get failedToDownload => 'Failed to download template';

  @override
  String get pasteWorkoutJSON => 'Paste your workout template JSON below:';

  @override
  String get viewJSONFormat => 'View JSON Format';

  @override
  String get pasteJSONHere => 'Paste JSON here...';

  @override
  String get import => 'Import';

  @override
  String get pleaseProvideJSON => 'Please paste JSON content';

  @override
  String templateImportedSuccessfully(String templateName) {
    return 'Template \"$templateName\" imported successfully!';
  }

  @override
  String get importedProgram => 'Imported Program';

  @override
  String get noDaysFoundInProgram => 'No days found in program';

  @override
  String get selectDayToImport => 'Select Day to Import';

  @override
  String programFoundWithDays(String programName, int dayCount) {
    return 'Found program \"$programName\" with $dayCount days:';
  }

  @override
  String get select => 'Select';

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String importedFromProgram(String programName) {
    return 'Imported from program: $programName';
  }

  @override
  String errorImportingJSON(String error) {
    return 'Error importing JSON: $error';
  }

  @override
  String get filtersComingSoon => 'Filters coming soon';

  @override
  String byAuthor(String authorName) {
    return 'by $authorName';
  }

  @override
  String get anonymous => 'Anonymous';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get improvement => 'Improvement';

  @override
  String get decline => 'Decline';

  @override
  String get stall => 'Stall';

  @override
  String get totalExercises => 'Total';

  @override
  String get totalSets => 'Total Sets';

  @override
  String get avgVolumePerWorkout => 'Avg Volume Per Workout';

  @override
  String get average => 'Average';

  @override
  String get record => 'Record';

  @override
  String get trend => 'Trend';

  @override
  String get chest => 'Chest';

  @override
  String get back => 'Back';

  @override
  String get shoulders => 'Shoulders';

  @override
  String get arms => 'Arms';

  @override
  String get legs => 'Legs';

  @override
  String get abs => 'Abs';

  @override
  String get cardio => 'Cardio';

  @override
  String get other => 'Other';

  @override
  String get personal => 'Personal';

  @override
  String get usages => 'usages';

  @override
  String get muscleDistribution => 'Muscle Distribution';

  @override
  String get core => 'CORE (Abs/Lower Back)';

  @override
  String get chestFull => 'Chest Muscles';

  @override
  String get backFull => 'Back Muscles';

  @override
  String get shouldersFull => 'Shoulder Muscles';

  @override
  String get armsFull => 'Arm Muscles';

  @override
  String get legsFull => 'Leg Muscles';

  @override
  String get coreFull => 'Core Muscles';

  @override
  String get overview => 'Overview';

  @override
  String get strength => 'Strength';

  @override
  String get insights => 'Insights';

  @override
  String get muscleBalance => 'Muscle Balance';

  @override
  String get allExercises => 'All Exercises';

  @override
  String get trainingInsights => 'Training Insights';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get exerciseTrends => 'Exercise Trends';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get totalPRs => 'Total PRs';

  @override
  String get volumeChange => 'Volume Change';

  @override
  String get maxWeight => 'Max Weight';

  @override
  String get maxReps => 'Max Reps';

  @override
  String get estimated1RM => 'Estimated 1RM';

  @override
  String get volumeProgression => 'Volume Progression';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get volumeStatistics => 'Volume Statistics';

  @override
  String get pleaseLogin => 'Please Login';

  @override
  String get startWorkoutToSeeAnalytics =>
      'Start a workout to see your analytics';

  @override
  String get recentWorkouts => 'Recent Workouts';

  @override
  String get highPriority => 'High Priority';

  @override
  String get insight => 'Insight';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String get scientificStrategies => 'Scientific Strategies';

  @override
  String get dataPoints => 'Data Points';

  @override
  String get aboutStrengthProgression => 'About Strength Progression';

  @override
  String get strengthProgressionInfo =>
      'Track your strength gains over time with estimated 1RM calculations and progressive overload indicators.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get backToHomeKeepWorkout => 'Back to Home (Keep Workout)';

  @override
  String get backToHomeKeepWorkoutActive =>
      'Back to Home (Keep Workout Active)';

  @override
  String get unlockPremiumFeatures => 'Unlock Premium Features';

  @override
  String get premiumVolumeFeatures => 'Premium Volume Features';

  @override
  String get advancedInsights => 'Advanced Insights';

  @override
  String get recoveryRecommendation => 'Recovery Recommendation';

  @override
  String get trainingIntensity => 'Training Intensity';

  @override
  String get noDataForSelectedPeriod =>
      'No data available for the selected period';

  @override
  String get previous => 'Previous';

  @override
  String get tapForDetails => 'Tap for details';

  @override
  String get compareWithHistory => 'Compare with history';

  @override
  String get bestVolume => 'Best Volume';

  @override
  String get muscleGroupBalance => 'Muscle Group Balance';

  @override
  String get overallBalance => 'Overall Balance';

  @override
  String get excellentBalance => 'Excellent';

  @override
  String get goodBalance => 'Good';

  @override
  String get moderateBalance => 'Moderate';

  @override
  String get poorBalance => 'Poor';

  @override
  String get comparePrevious => 'Compare Previous';

  @override
  String get currentStrength => 'Current Strength';

  @override
  String get strengthCalculationHint =>
      'Strength is calculated based on volume progression relative to your previous best';

  @override
  String get howIsThisCalculated => 'How is this calculated?';

  @override
  String get refreshAnimation => 'Refresh Animation';

  @override
  String get editTargets => 'Edit Targets';

  @override
  String get tapToEditTarget => 'Tap to edit target';

  @override
  String get targetStrength => 'Target Strength';

  @override
  String get comparedToLastMonth => 'Compared to last month';

  @override
  String get recommendedExercises => 'Recommended Exercises';

  @override
  String get volumeBreakdown => 'Volume Breakdown';

  @override
  String strengthExplanation(String volume) {
    return 'Based on ${volume}kg total volume';
  }

  @override
  String get howStrengthIsCalculated => 'How Strength is Calculated';

  @override
  String get strengthCalculationExplanation =>
      'Strength percentage is calculated based on your training volume compared to your historical maximum volume for each muscle group.';

  @override
  String get volumeFormula => 'Volume Formula';

  @override
  String get strengthPercentage => 'Strength Percentage';

  @override
  String get targetExplanation =>
      'Targets are customizable goals that help you maintain balanced training across all muscle groups.';

  @override
  String get previousWeightsLoaded => 'Previous weights loaded successfully';

  @override
  String get insightStrengthGainsTitle => 'Strength Gains';

  @override
  String get insightStrengthGainsMessage =>
      'You\'ve made significant strength improvements';

  @override
  String get insightStrengthGainsRecommendation =>
      'Keep pushing progressive overload to maintain momentum';

  @override
  String get insightPlateauTitle => 'Performance Plateau';

  @override
  String get insightPlateauMessage => 'Your performance has plateaued recently';

  @override
  String get insightPlateauRecommendation =>
      'Consider changing your routine or taking a deload week';

  @override
  String get insightVolumeSurgeTitle => 'Volume Surge';

  @override
  String get insightVolumeSurgeMessage =>
      'Your training volume has increased significantly';

  @override
  String get insightVolumeSurgeRecommendation =>
      'Monitor recovery and adjust if needed';

  @override
  String get insightVolumeDropTitle => 'Volume Drop';

  @override
  String get insightVolumeDropMessage => 'Your training volume has decreased';

  @override
  String get insightVolumeDropRecommendation =>
      'Gradually increase volume to maintain progress';

  @override
  String get insightVolumePlateauTitle => 'Volume Plateau';

  @override
  String get insightVolumePlateauMessage => 'Your volume has remained stable';

  @override
  String get insightVolumePlateauRecommendation =>
      'Consider progressive overload techniques';

  @override
  String get insightLowFrequencyTitle => 'Low Training Frequency';

  @override
  String get insightLowFrequencyMessage =>
      'You\'ve been training less frequently';

  @override
  String get insightLowFrequencyRecommendation =>
      'Try to maintain consistent training schedule';

  @override
  String get insightHighLoadTitle => 'High Training Load';

  @override
  String get insightHighLoadMessage =>
      'You\'ve been training with high intensity';

  @override
  String get insightHighLoadRecommendation =>
      'Make sure to get adequate rest and recovery';

  @override
  String get insightGreatConsistencyTitle => 'Great Consistency';

  @override
  String get insightGreatConsistencyMessage =>
      'You\'ve maintained excellent training consistency';

  @override
  String get insightGreatConsistencyRecommendation => 'Keep up the great work!';

  @override
  String get insightExtendedBreakTitle => 'Extended Break';

  @override
  String get insightExtendedBreakMessage =>
      'You\'ve taken an extended break from training';

  @override
  String get insightExtendedBreakRecommendation =>
      'Start with lighter loads and gradually progress';

  @override
  String get insightChasePRsTitle => 'Chase PRs';

  @override
  String get insightChasePRsMessage =>
      'You\'re close to setting new personal records';

  @override
  String get insightChasePRsRecommendation =>
      'Focus on your strongest exercises for PR attempts';

  @override
  String get insightPRWeekTitle => 'PR Week';

  @override
  String get insightPRWeekMessage => 'You\'ve set multiple PRs this week';

  @override
  String get insightPRWeekRecommendation =>
      'Great job! Consider a deload to consolidate gains';

  @override
  String get insightPRDroughtTitle => 'PR Drought';

  @override
  String get insightPRDroughtMessage => 'It\'s been a while since your last PR';

  @override
  String get insightPRDroughtRecommendation =>
      'Try different rep ranges or exercise variations';

  @override
  String get insightMuscleImbalanceTitle => 'Muscle Imbalance';

  @override
  String get insightMuscleImbalanceMessage =>
      'Some muscle groups are lagging behind';

  @override
  String get insightMuscleImbalanceRecommendation =>
      'Focus more on weaker muscle groups';

  @override
  String get insightFocusAdjustmentTitle => 'Focus Adjustment';

  @override
  String get insightFocusAdjustmentMessage =>
      'Your training focus could be better balanced';

  @override
  String get insightFocusAdjustmentRecommendation =>
      'Adjust your program for better balance';

  @override
  String get insightWellBalancedTitle => 'Well Balanced';

  @override
  String get insightWellBalancedMessage =>
      'Your training is well balanced across muscle groups';

  @override
  String get insightWellBalancedRecommendation =>
      'Keep maintaining this balanced approach';

  @override
  String get insightOvertrainingTitle => 'Overtraining Risk';

  @override
  String get insightOvertrainingMessage => 'You may be at risk of overtraining';

  @override
  String get insightOvertrainingRecommendation =>
      'Consider taking a rest day or deload week';

  @override
  String get insightRecoveryNoteTitle => 'Recovery Note';

  @override
  String get insightRecoveryNoteMessage =>
      'Your recovery metrics need attention';

  @override
  String get insightRecoveryNoteRecommendation =>
      'Focus on sleep, nutrition, and stress management';

  @override
  String get insightStreakTitle => 'Training Streak';

  @override
  String get insightStreakMessage => 'You\'re on an impressive training streak';

  @override
  String get insightStreakRecommendation =>
      'Keep it up while listening to your body';

  @override
  String get insightVolumeMilestoneTitle => 'Volume Milestone';

  @override
  String get insightVolumeMilestoneMessage =>
      'You\'ve reached a new volume milestone';

  @override
  String get insightVolumeMilestoneRecommendation =>
      'Celebrate this achievement!';

  @override
  String get insightPRMachineTitle => 'PR Machine';

  @override
  String get insightPRMachineMessage => 'You\'re setting PRs consistently';

  @override
  String get insightPRMachineRecommendation =>
      'Amazing progress! Keep pushing your limits';

  @override
  String get insightConsistencyBonusTitle => 'Consistency Bonus';

  @override
  String get insightConsistencyBonusMessage => 'Your consistency is paying off';

  @override
  String get insightConsistencyBonusRecommendation =>
      'Consistency is the key to long-term success';

  @override
  String get signInRequired => 'Sign in required';

  @override
  String get signIn => 'Sign In';

  @override
  String get strengthProgression => 'Strength Progression';

  @override
  String get actualWeight => 'Actual Weight';

  @override
  String get trendLine => 'Trend Line';

  @override
  String get current1RM => 'Current 1RM';

  @override
  String get bestEver => 'Best Ever';

  @override
  String get noDataForExercise => 'No data available for this exercise';

  @override
  String get noDataForChart => 'No data available for selected metrics';

  @override
  String get chartTapToSeeRealValues => 'Tap chart to see real values';

  @override
  String get multiMetricComparison => 'Multi-Metric Comparison';

  @override
  String get volumeHeatmap => 'Volume Heatmap';

  @override
  String get workoutDays => 'Workout Days';

  @override
  String get weeksToShow => 'Weeks to Show';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get exercisesPerformed => 'Exercises Performed';

  @override
  String get mostSets => 'Most Sets';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get resetZoom => 'Reset Zoom';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String workoutWithExercises(Object workoutName, Object exerciseCount) {
    return '$workoutName with $exerciseCount exercises';
  }

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get restDay => 'Rest Day';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String setsCount(int count) {
    return '$count sets';
  }

  @override
  String setLabel(Object number) {
    return 'Set $number';
  }

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get repsLabel => 'reps';

  @override
  String get effortLabel => 'Effort';

  @override
  String get importedTemplate => 'Imported Template';

  @override
  String get noExercisesFoundInJSON => 'No exercises found in JSON';

  @override
  String get exercise => 'exercise';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get editRoundData => 'Edit round data';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get setUpdated => 'Set updated successfully';

  @override
  String get quickEditWeight => 'Weight';

  @override
  String get quickEditPlates => 'Plates';

  @override
  String get quickEditPercentage => '%';

  @override
  String get quickEditReps => 'Reps:';

  @override
  String get quickEditRpe => 'RPE:';

  @override
  String get quickEditCancel => 'Cancel';

  @override
  String get quickEditSave => 'Save';

  @override
  String get quickEditCalculate => 'Calculate';

  @override
  String quickEditCopiedFromSet(int setNumber) {
    return 'Copied from Set $setNumber';
  }

  @override
  String get plateCalculatorTitle => 'Plate Calculator';

  @override
  String get plateCalculatorDischi => 'Plates';

  @override
  String get plateCalculatorAll => 'All';

  @override
  String get plateCalculatorStandard => 'Standard';

  @override
  String get recentWeights => 'Recent Weights';

  @override
  String get quickAdjustment => 'Quick Adjustment';

  @override
  String barbellIncluded(double weight) {
    return 'Barbell ${weight}kg included';
  }

  @override
  String get noBarbell => 'No barbell';

  @override
  String get perSide => 'Per side:';

  @override
  String get onlyBarbell => 'Only barbell';

  @override
  String get noPlates => 'No plates';

  @override
  String get configureAvailablePlates => 'Configure available plates';

  @override
  String get selectAvailablePlates =>
      'Select the plates available in your gym:';

  @override
  String get selectBarbell => 'Select Barbell';

  @override
  String get selectBarbellButton => 'Select';

  @override
  String get replace => 'Replace';

  @override
  String get replaceExercise => 'Replace Exercise';

  @override
  String get deleteExercise => 'Delete Exercise';

  @override
  String get deleteExerciseDescription =>
      'This will permanently remove this exercise from your workout.';

  @override
  String get deleteSuperset => 'Delete Superset';

  @override
  String get deleteSupersetDescription =>
      'This will permanently remove this superset and all its exercises from your workout.';

  @override
  String deleteSetTitle(int setNumber) {
    return 'Delete set $setNumber?';
  }

  @override
  String get deleteWarmupSetTitle => 'Delete warmup set?';

  @override
  String get deleteSetMessage => 'This action cannot be undone.';

  @override
  String get collapseExercise => 'Collapse';

  @override
  String get confirmAction => 'Confirm Action';

  @override
  String get swipeToDeleteExercise => 'Swipe left to delete';

  @override
  String get swipeToEditExercise => 'Swipe left to edit';

  @override
  String get swipeToReplaceExercise => 'Swipe left to replace';

  @override
  String get supersetTraining => 'Superset Training';

  @override
  String get supersetDescription =>
      'Superset: Perform two exercises back-to-back with no rest between them.';

  @override
  String get selectedExercises => 'Selected Exercises';

  @override
  String get addAtLeastTwoExercises =>
      'Add at least 2 exercises to create a superset';

  @override
  String get addRound => 'Add Round';

  @override
  String get roundsConfiguration => 'Rounds Configuration';

  @override
  String get createSuperset => 'Create Superset';

  @override
  String get round => 'Round';

  @override
  String allExercisesWillBePerformed(int count) {
    return 'All $count exercises will be performed in this round';
  }

  @override
  String get optional => 'Optional';

  @override
  String get restSettings => 'Rest Settings';

  @override
  String get betweenExercises => 'Between Exercises';

  @override
  String get restTimeBetweenExercises =>
      'Rest time between each exercise in a round';

  @override
  String get afterRound => 'After Round';

  @override
  String get restTimeAfterRound => 'Rest time after completing all exercises';

  @override
  String get setCompleted => 'Set completed';

  @override
  String get next => 'Next';

  @override
  String get single => 'Single';

  @override
  String get superset => 'Superset';

  @override
  String get dropset => 'Drop Set';

  @override
  String get restPause => 'Rest-Pause';

  @override
  String get tapToSelectFromDatabase => 'Tap to select from database';

  @override
  String get restBetweenExercises => 'Rest between exercises';

  @override
  String get seconds => 'seconds';

  @override
  String get selectExercisesForSuperset => 'Select exercises for superset';

  @override
  String get selectExerciseForDropset => 'Select exercise for drop set';

  @override
  String get selectExerciseForRestPause => 'Select exercise for rest-pause';

  @override
  String get clearAll => 'Clear All';

  @override
  String get stages => 'Stages';

  @override
  String get addStage => 'Add Stage';

  @override
  String get miniSets => 'mini-sets';

  @override
  String get restTime => 'Rest Time';

  @override
  String supersetProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get swipeToNavigate =>
      'Swipe left or right to navigate between exercises';

  @override
  String get currentExercise => 'Current Exercise';

  @override
  String get nextExercise => 'Next Exercise';

  @override
  String get previousExercise => 'Previous Exercise';

  @override
  String get completeAndNext => 'Complete & Next';

  @override
  String get completeAndFinish => 'Complete & Finish';

  @override
  String get rateYourEffort => 'Rate Your Effort';

  @override
  String get completeSet => 'Complete Set';

  @override
  String get verifyWeightReps => 'Verify Weight & Reps';

  @override
  String get verifyTime => 'Verify Minutes & Seconds';

  @override
  String get verifyReps => 'Verify Reps';

  @override
  String get exerciseHistory => 'Exercise History';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get statistics => 'Statistics';

  @override
  String get avgWeight => 'Avg Weight';

  @override
  String get firstWorkout => 'First Workout';

  @override
  String get noHistoryFound => 'No History Found';

  @override
  String get completeWorkoutsToSeeHistory => 'Complete workouts to see history';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get workoutDatabase => 'Workout Database';

  @override
  String get editableWorkoutHistory => 'Editable Workout History';

  @override
  String get editWorkout => 'Edit Workout';

  @override
  String get deleteWorkout => 'Delete Workout';

  @override
  String workoutDate(int day, int month, int year) {
    return 'Workout $day/$month/$year';
  }

  @override
  String get workoutTime => 'Workout Time';

  @override
  String get removeSet => 'Remove Set';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteWorkoutConfirmation =>
      'Are you sure you want to delete this workout? This action cannot be undone.';

  @override
  String get workoutDeletedSuccessfully => 'Workout deleted successfully';

  @override
  String get workoutUpdatedSuccessfully => 'Workout updated successfully';

  @override
  String get noWorkoutsInHistory => 'No workouts in history';

  @override
  String get startTrackingWorkouts =>
      'Start tracking your workouts to see them here';

  @override
  String get searchWorkouts => 'Search workouts...';

  @override
  String get filterByExercise => 'Filter by exercise';

  @override
  String get sortByDate => 'Sort by date';

  @override
  String get sortByDuration => 'Sort by duration';

  @override
  String get sortByVolume => 'Sort by volume';

  @override
  String get dataMigration => 'Data Migration';

  @override
  String get dataMigrationDescription =>
      'Migrate your workout history from the old format to the new system for better performance and features.';

  @override
  String get noDataToMigrate => 'No data to migrate';

  @override
  String get migrationOptions => 'Migration Options';

  @override
  String get timeWindowHours => 'Time Window (hours)';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get createBackupDescription =>
      'Create a backup of your data before migration';

  @override
  String get minExercisesPerWorkout => 'Min exercises per workout';

  @override
  String get migrationPreview => 'Migration Preview';

  @override
  String get migrationResults => 'Migration Results';

  @override
  String get workoutsFound => 'Workouts found';

  @override
  String get migratedWorkouts => 'Migrated workouts';

  @override
  String get skippedExercises => 'Skipped exercises';

  @override
  String get errors => 'Errors';

  @override
  String get workoutGroupsPreview => 'Workout Groups Preview';

  @override
  String get analyzing => 'Analyzing';

  @override
  String get migrating => 'Migrating';

  @override
  String get analyzeData => 'Analyze Data';

  @override
  String get startMigration => 'Start Migration';

  @override
  String get confirmMigration => 'Confirm Migration';

  @override
  String get confirmMigrationDescription =>
      'Are you sure you want to start the migration? This process cannot be undone.';

  @override
  String get firebaseInitialization => 'Firebase Initialization';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get firebaseStatus => 'Firebase Status';

  @override
  String get initialized => 'Initialized';

  @override
  String get notInitialized => 'Not Initialized';

  @override
  String get checking => 'Checking...';

  @override
  String get checkFailed => 'Check Failed';

  @override
  String get currentVersion => 'Current Version';

  @override
  String get notAvailable => 'Not Available';

  @override
  String loadingError(String error) {
    return 'Loading error: $error';
  }

  @override
  String get collectionStats => 'Collection Statistics';

  @override
  String get versionMetadata => 'Version Metadata';

  @override
  String get present => 'Present';

  @override
  String get missing => 'Missing';

  @override
  String get searchIndex => 'Search Index';

  @override
  String get actions => 'Actions';

  @override
  String get initializeExercises => 'Initialize Exercises';

  @override
  String get verifyIntegrity => 'Verify Integrity';

  @override
  String get resetStatus => 'Reset Status';

  @override
  String get operationInProgress => 'Operation in progress...';

  @override
  String get operationSuccess => 'Operation Successful';

  @override
  String get operationError => 'Operation Error';

  @override
  String get details => 'Details';

  @override
  String get initializeDescription =>
      'This will load all exercises from the local JSON file into Firebase. This operation may take several minutes.';

  @override
  String get overwriteExisting => 'Overwrite Existing Data';

  @override
  String get overwriteExistingDescription =>
      'Warning: This will delete all existing exercise data in Firebase';

  @override
  String get versionOptional => 'Version (Optional)';

  @override
  String get initialize => 'Initialize';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get analyticsAdmin => 'Analytics Dashboard';

  @override
  String get manageExercises => 'Manage Exercises';

  @override
  String get manageExercisesDescription => 'Add, edit, remove exercises';

  @override
  String get reviewCorrections => 'Review Corrections';

  @override
  String get reviewCorrectionsDescription =>
      'Review community exercise corrections';

  @override
  String get userAnalytics => 'User Analytics';

  @override
  String get userAnalyticsDescription => 'View user statistics';

  @override
  String get databaseBackup => 'Database Backup';

  @override
  String get databaseBackupDescription => 'Backup system data';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDescription => 'Send notifications to users';

  @override
  String get featureComingSoon => 'This feature is coming soon';

  @override
  String get loadingActivity => 'Loading activity...';

  @override
  String get errorLoadingActivity => 'Error loading activity';

  @override
  String get noRecentActivity => 'No Recent Activity';

  @override
  String get noRecentActivityDescription =>
      'Community corrections and activities will appear here';

  @override
  String get allRecentActivity => 'All Recent Activity';

  @override
  String get suggestedCorrection => 'Suggested correction';

  @override
  String get approvedCorrection => 'Approved correction';

  @override
  String get rejectedCorrection => 'Rejected correction';

  @override
  String get activityFor => 'Activity for';

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get viewAll => 'View All';

  @override
  String get adminInfo => 'Admin Information';

  @override
  String get welcomeAdmin => 'Welcome, Admin!';

  @override
  String get adminDashboardDescription =>
      'Manage the FitLog Pro system and review community contributions';

  @override
  String get systemStatistics => 'System Statistics';

  @override
  String get firebaseDatabase => 'Firebase Database';

  @override
  String get communityActivity => 'Community Activity';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get versionControl => 'Version Control';

  @override
  String get versionControlDescription => 'Manage app versions';

  @override
  String get exerciseCountLabel => 'Exercise Count';

  @override
  String get pendingCorrections => 'Pending Corrections';

  @override
  String get approvedCorrections => 'Approved Corrections';

  @override
  String get rejectedCorrections => 'Rejected Corrections';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get loadingStats => 'Loading statistics...';

  @override
  String get errorLoadingStats => 'Error loading statistics';

  @override
  String get version => 'Version';

  @override
  String get refresh => 'Refresh';

  @override
  String get secureAdminAccess => 'Secure Admin Access';

  @override
  String get systemOverview => 'System Overview';

  @override
  String get firebaseManagement => 'Firebase Management';

  @override
  String get adminInfoDescription =>
      'Admin panel for system management and community oversight';

  @override
  String get exerciseManagement => 'Exercise Management';

  @override
  String get exerciseManagementDescription =>
      'Add, edit, and organize exercise database';

  @override
  String get communityCorrections => 'Community Corrections';

  @override
  String get communityCorrectionsDescription =>
      'Review and approve community-submitted exercise corrections';

  @override
  String get fixMissingData => 'Fix Missing Data';

  @override
  String get fixMissingDataDescription =>
      'Identify and add missing exercises to the database';

  @override
  String get errorLoadingCorrections => 'Error loading corrections';

  @override
  String get noCorrections => 'No corrections found';

  @override
  String get noCorrectionsDescription =>
      'Community corrections will appear here when submitted';

  @override
  String get reviewedCorrections => 'Reviewed Corrections';

  @override
  String get approveCorrection => 'Approve Correction';

  @override
  String get rejectCorrection => 'Reject Correction';

  @override
  String get confirmApproval =>
      'Are you sure you want to approve this correction?';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectionReason => 'Rejection Reason';

  @override
  String get rejectionReasonHint =>
      'Explain why this correction is being rejected';

  @override
  String get suggestedBy => 'Suggested by';

  @override
  String get correctionType => 'Correction Type';

  @override
  String get currentValue => 'Current value';

  @override
  String get proposedValue => 'Proposed Value';

  @override
  String get submittedAt => 'Submitted';

  @override
  String get reviewedBy => 'Reviewed by';

  @override
  String get exerciseImage => 'Exercise Image';

  @override
  String get muscleFocus => 'Muscle Focus';

  @override
  String get correction => 'Correction';

  @override
  String get tip => 'Tip';

  @override
  String get warning => 'Warning';

  @override
  String get variant => 'Variant';

  @override
  String get translation => 'Translation';

  @override
  String get technique => 'Technique';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get fix => 'Fix';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get databaseManager => 'Database Manager';

  @override
  String get publishNewVersion => 'Publish New Version';

  @override
  String get lastPublished => 'Last Published';

  @override
  String get totalExercisesInDb => 'Total Exercises in Database';

  @override
  String get versionHistory => 'Version History';

  @override
  String get publishVersion => 'Publish Version';

  @override
  String get versionNumber => 'Version Number';

  @override
  String get changelog => 'Changelog';

  @override
  String get changelogHint =>
      'Describe what changed in this version (e.g., \'Added 15 new shoulder exercises\')';

  @override
  String get publishing => 'Publishing...';

  @override
  String versionPublished(String version) {
    return 'Version $version published successfully! All users will receive the update within 6 hours.';
  }

  @override
  String publishFailed(String error) {
    return 'Failed to publish version: $error';
  }

  @override
  String get forceUpdate => 'Force Update (Required)';

  @override
  String get forceUpdateDesc =>
      'If enabled, users must update to continue using the app';

  @override
  String get multiSelectMode => 'Multi-Select Mode';

  @override
  String get exportAllJson => 'Export All to JSON';

  @override
  String get exportSelectedJson => 'Export Selected to JSON';

  @override
  String get importJson => 'Import from JSON';

  @override
  String get bodyweight => 'Bodyweight';

  @override
  String get uniqueMuscles => 'Muscles';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get bulkEdit => 'Bulk Edit';

  @override
  String get exercisesExport => 'Exercises Export';

  @override
  String get exportSuccess => 'Export completed successfully';

  @override
  String get importJsonDescription => 'Import exercises from JSON file';

  @override
  String get importWarning => 'This will overwrite existing exercises!';

  @override
  String get selectFile => 'Select File';

  @override
  String get selectField => 'Select Field';

  @override
  String get newValue => 'New value';

  @override
  String get apply => 'Apply';

  @override
  String confirmDeleteMultiple(int count) {
    return 'Delete $count exercises?';
  }

  @override
  String get exerciseNameRequired => 'Exercise name is required';

  @override
  String get updateExercise => 'Update Exercise';

  @override
  String get createExercise => 'Create Exercise';

  @override
  String get exerciseUpdateAvailable => 'Exercise Update Available';

  @override
  String get exerciseUpdateDescription =>
      'A new version of the exercise database is available with improved exercises and features.';

  @override
  String get downloadNow => 'Download Now';

  @override
  String get downloading => 'Downloading...';

  @override
  String get exerciseUpdateNote =>
      'This will download the latest exercise data and improve your workout experience.';

  @override
  String get tempoEsecuzione => 'Time Under Tension';

  @override
  String get tempoNote => 'Execution Time Note';

  @override
  String get imagePreview => 'Image Preview';

  @override
  String get changeImage => 'Change Image';

  @override
  String get expandDetails => 'Expand Details';

  @override
  String get clearFilter => 'Clear';

  @override
  String get timeUnderTensionExplanation =>
      'Time Under Tension (TUT) is the total amount of time a muscle is under strain during a set. It\'s a key factor for muscle growth and strength.';

  @override
  String get tutBasicExplanation =>
      'TUT is the duration your muscles work during an exercise set. Longer TUT can lead to more muscle growth.';

  @override
  String get tutFormatTitle => 'TUT Format: X-Y-Z-W';

  @override
  String get tutFormatExplanation =>
      'The TUT format X-Y-Z-W represents the duration in seconds for each phase of an exercise: X (eccentric/lowering), Y (pause at bottom), Z (concentric/lifting), W (pause at top).';

  @override
  String get warmupTipLight =>
      'Light warmup: Focus on dynamic stretches and light cardio to get your blood flowing.';

  @override
  String get warmupTipModerate =>
      'Moderate warmup: Include some light sets of your main exercise to prepare your muscles.';

  @override
  String get warmupTipHeavy =>
      'Heavy warmup: Gradually increase weight with several sets, ensuring proper form and muscle activation.';

  @override
  String get warmupTipMax =>
      'Max effort warmup: Perform a few very light sets, then jump straight into your working sets with minimal rest.';

  @override
  String get shareAdviceWithCommunity => 'Share an advice';

  @override
  String get communityAdvice => 'Community Advice';

  @override
  String get communityContributions => 'Community Contributions';

  @override
  String get reviewContributionsDescription =>
      'Review and manage community contributions';

  @override
  String peopleFoundHelpful(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'people',
      one: 'person',
      zero: 'people',
    );
    return '$count $_temp0 found this helpful';
  }

  @override
  String get noAdviceAvailable => 'No advice available for this exercise yet';

  @override
  String get beFirstToShare => 'Be the first to share your advice!';

  @override
  String get contributionSubmittedSuccess =>
      'Your contribution has been submitted for review!';

  @override
  String get thankYouForContributing => 'Thank you for helping the community!';

  @override
  String get startWorkoutWithTemplate => 'Start workout with this template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get editTemplateSubtitle => 'Modify exercises and sets';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get sharePdfSubtitle => 'Export as PDF and share';

  @override
  String get print => 'Print';

  @override
  String get printTemplate => 'Print workout template';

  @override
  String get pdfExportOptions => 'PDF Export Options';

  @override
  String get pdfDetailLevelCompact => 'Compact Format';

  @override
  String get pdfDetailLevelCompactDesc =>
      'Groups identical sets (e.g., 3 x 10)';

  @override
  String get pdfDetailLevelDetailed => 'Detailed with Weight';

  @override
  String get pdfDetailLevelDetailedDesc =>
      'Shows each set with weight (e.g., Set 1: 20kg x 10)';

  @override
  String get pdfDetailLevelNoWeight => 'Detailed without Weight';

  @override
  String get pdfDetailLevelNoWeightDesc =>
      'Shows each set with reps only (e.g., Set 1: 10 reps)';

  @override
  String get rememberMyChoice => 'Remember my choice';

  @override
  String get deleteTemplateSubtitle => 'Remove permanently';

  @override
  String workoutStartError(String error) {
    return 'Error starting workout: $error';
  }

  @override
  String get restComplete => 'Rest Complete';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get warmupComplete => 'Warmup Complete';

  @override
  String get cooldownComplete => 'Cooldown Complete';

  @override
  String get timerFinished => 'Your timer has finished';

  @override
  String setComplete(String exercise, int currentSet, int totalSets) {
    return '$exercise - Set $currentSet/$totalSets complete';
  }

  @override
  String exerciseComplete(String exercise) {
    return '$exercise complete';
  }

  @override
  String get workoutSaved => 'Workout saved!';

  @override
  String get errorSavingWorkout => 'Error saving workout';

  @override
  String get effortLevel => 'Effort';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get enterWorkoutName => 'Enter workout name';

  @override
  String get replacementKeepsSetsAndReps =>
      'Replacement keeps all sets and reps';

  @override
  String get smartSuggestions => 'Smart Suggestions';

  @override
  String get errorLoadingExercises => 'Error loading exercises';

  @override
  String get confirmReplacement => 'Confirm Replacement';

  @override
  String replaceExerciseConfirmation(String oldExercise, String newExercise) {
    return 'Replace $oldExercise with $newExercise?';
  }

  @override
  String get exerciseReplaced => 'Exercise replaced successfully';

  @override
  String get excellentReplacement => 'Excellent replacement';

  @override
  String get highlyCompatible => 'Highly compatible';

  @override
  String get goodAlternative => 'Good alternative';

  @override
  String get possibleAlternative => 'Possible alternative';

  @override
  String get differentMuscleGroup => 'Different muscle group';

  @override
  String get browseExerciseDatabase => 'Browse Exercise Database';

  @override
  String get chooseFromLibrary => 'Choose from our exercise library';

  @override
  String get cantFindExercise =>
      'Can\'t find the exercise? Create a custom one';

  @override
  String get enterCustomExerciseDetails =>
      'Enter custom exercise details below:';

  @override
  String get singleTab => 'Single';

  @override
  String get advancedTab => 'Advanced';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get addNotesAboutForm =>
      'Add notes about form, weight progression, etc.';

  @override
  String get exerciseNameLabel => 'Exercise Name';

  @override
  String get exerciseNameExample => 'e.g., Bench Press';

  @override
  String addedToWorkout(String exerciseName) {
    return 'Added $exerciseName to workout';
  }

  @override
  String get apreProtocol => 'APRE Protocol';

  @override
  String get apreAdjustment => 'APRE Adjustment';

  @override
  String apreSetWeight(int setNumber) {
    return 'Set $setNumber Weight:';
  }

  @override
  String apreCompletedReps(int actual, int target) {
    return 'You completed $actual reps (target: $target)';
  }

  @override
  String get apreApply => 'Apply';

  @override
  String apreWeightAdjusted(int setNumber, String weight) {
    return 'APRE: Set $setNumber weight adjusted to $weight kg';
  }

  @override
  String get apreAutoregulation => 'APRE Autoregulation';

  @override
  String get apreAutoregulationDescription =>
      'Automatic weight adjustment based on performance';

  @override
  String get apreProtocolSelect => 'Select APRE Protocol';

  @override
  String get apreProtocol3Description =>
      'Heavy strength protocol (3 reps target)';

  @override
  String get apreProtocol6Description =>
      'Strength and hypertrophy protocol (6 reps target)';

  @override
  String get apreProtocol10Description =>
      'Hypertrophy and endurance protocol (10 reps target)';

  @override
  String get apreBaseWeight => 'APRE Base Weight';

  @override
  String get apreBaseWeightHint => 'Enter your 3RM, 6RM or 10RM weight';

  @override
  String get apreProtocol3Helper => 'Use your 3 rep max weight';

  @override
  String get apreProtocol6Helper => 'Use your 6 rep max weight';

  @override
  String get apreProtocol10Helper => 'Use your 10 rep max weight';

  @override
  String get apreProtocolPreview => 'Protocol Change Preview';

  @override
  String get aprePreviewDescription =>
      'Preview how your weights will change with the new protocol';

  @override
  String apreCurrentProtocol(int protocol) {
    return 'Current (APRE $protocol)';
  }

  @override
  String apreNewProtocol(int protocol) {
    return 'New (APRE $protocol)';
  }

  @override
  String get apreSet1Preview => 'Set 1 (50%)';

  @override
  String get apreSet2Preview => 'Set 2 (75%)';

  @override
  String get apreSet3Preview => 'Set 3 (100%)';

  @override
  String get apreSet4Preview => 'Set 4';

  @override
  String get apreAdjustedBasedOnPerformance => 'Adjusted based on performance';

  @override
  String get apreApplyChanges => 'Apply Changes';

  @override
  String get autoAdjustment => 'Auto Adjustment';

  @override
  String get autoAdjustmentDescription =>
      'Automatic weight adjustment based on your performance';

  @override
  String get selectAutoAdjustmentType => 'Select Adjustment Type';

  @override
  String get rpeBasedAdjustment => 'RPE/RIR Based';

  @override
  String get rpeBasedDescription =>
      'Adjust weight based on your perceived exertion';

  @override
  String get rpeTargetRange => 'Target RPE Range';

  @override
  String get rpeTargetRangeHint => 'e.g., 7-9 RPE';

  @override
  String get adjustmentPercentage => 'Adjustment %';

  @override
  String increaseWeightBy(String percent) {
    return 'Increase by $percent%';
  }

  @override
  String decreaseWeightBy(String percent) {
    return 'Decrease by $percent%';
  }

  @override
  String get maintainWeight => 'Maintain current weight';

  @override
  String get rpeAutoregulation => 'RPE Autoregulation';

  @override
  String get actualRpe => 'Actual RPE';

  @override
  String targetRange(Object range) {
    return 'Target: $range';
  }

  @override
  String get actualRir => 'Actual RIR';

  @override
  String get targetRir => 'Target RIR';

  @override
  String get suggestedWeight => 'Suggested Weight';

  @override
  String get nextSetWeight => 'Next Set Weight';

  @override
  String get weightAdjustedTo => 'Weight adjusted to';

  @override
  String get templateOnboardingNameTitle =>
      'Here insert the name of your workout plan';

  @override
  String get templateOnboardingDescriptionTitle =>
      'This is a description of what the plan includes';

  @override
  String get templateOnboardingDescriptionSubtitle =>
      'Optional - helps you remember what this plan is about';

  @override
  String get templateOnboardingTagsTitle => 'Tags for community recognition';

  @override
  String get templateOnboardingTagsSubtitle =>
      'Select tags that describe your template to help others find it in the community';

  @override
  String get templateOnboardingRestTimerTitle =>
      'Default rest timer for all exercises';

  @override
  String get templateOnboardingRestTimerSubtitle =>
      'When you add a new exercise without manually setting the timer, this default timer will be applied';

  @override
  String get templateOnboardingNext => 'Next';

  @override
  String get templateOnboardingSkip => 'Skip Tutorial';

  @override
  String get templateOnboardingGotIt => 'Got it!';

  @override
  String get exerciseOnboardingSingleTabTitle =>
      'Start by adding a single exercise';

  @override
  String get exerciseOnboardingSingleTabSubtitle =>
      'This tab allows you to add one exercise at a time. You can also add supersets, dropsets, or rest-pause from other tabs';

  @override
  String get exerciseOnboardingSelectButtonTitle =>
      'Tap here to browse exercises';

  @override
  String get exerciseOnboardingSelectButtonSubtitle =>
      'Open the exercise database to choose from hundreds of exercises';

  @override
  String get exerciseOnboardingSearchTitle => 'Search for exercises';

  @override
  String get exerciseOnboardingSearchSubtitle =>
      'Type the name of the exercise you\'re looking for, like \"bench press\" or \"squat\"';

  @override
  String get exerciseOnboardingExerciseItemTitle => 'Select an exercise';

  @override
  String get exerciseOnboardingExerciseItemSubtitle =>
      'Tap to add it to your workout. Long press to see detailed information and execution tips';

  @override
  String get exerciseOnboardingFiltersTitle =>
      'Filter by category or muscle group';

  @override
  String get exerciseOnboardingFiltersSubtitle =>
      'Use filters to quickly find exercises for specific body parts';

  @override
  String get exerciseOnboardingConfirmTitle => 'Confirm to add the exercise';

  @override
  String get exerciseOnboardingConfirmSubtitle =>
      'Once you\'ve selected your exercises, tap here to add them to your workout';

  @override
  String get exerciseOnboardingNext => 'Next';

  @override
  String get exerciseOnboardingSkip => 'Skip Tutorial';

  @override
  String get exerciseOnboardingGotIt => 'Got it!';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingDesc =>
      'Re-show tutorial guides for templates and exercises';

  @override
  String get resetOnboardingConfirm =>
      'This will reset all onboarding tutorials. They will be shown again the next time you create a template or add an exercise.';

  @override
  String get onboardingResetSuccess =>
      'Onboarding tutorials reset successfully';

  @override
  String get templateDescriptionOptional => 'Description (optional)';

  @override
  String get templateNameLabel => 'Template Name *';

  @override
  String get templateNameRequired => 'Name is required';

  @override
  String get templateDescriptionHint => 'Brief workout description...';

  @override
  String get tags => 'Tags';

  @override
  String get selectTagsDescription => 'Select tags that describe your template';

  @override
  String get defaultRestTimer => 'Default Rest Timer';

  @override
  String get defaultRestTimerDescription =>
      'Set a default timer that will be applied to all exercises in the template';

  @override
  String get warmupProtocol => 'Warmup Protocol';

  @override
  String get warmupPhaseInfo => 'Understanding Warmup Phases';

  @override
  String get warmupPhase1Title => 'Mobility';

  @override
  String get warmupPhase1Desc =>
      'Prepares joints and range of motion with dynamic stretches. Examples: hip circles, arm swings, leg swings.';

  @override
  String get warmupPhase2Title => 'Activation';

  @override
  String get warmupPhase2Desc =>
      'Activates target muscles and stabilizers with light contractions. Examples: glute bridges, band work, light sets.';

  @override
  String get warmupPhase3Title => 'Specific Warmup';

  @override
  String get warmupPhase3Desc =>
      'Gradual progression towards working weight with the actual exercise. Examples: Bar×10, 40%×8, 60%×5, 80%×3.';

  @override
  String get warmupSetsLabel => 'Warmup Sets';

  @override
  String get warmupTimeLabel => 'Warmup Time';

  @override
  String get warmupInfoDialogTitle => 'Complete Warmup Protocol';

  @override
  String get warmupWhyImportant => 'Why is a proper warmup important?';

  @override
  String get warmupWhyImportantAnswer =>
      'A proper warmup reduces injury risk, improves performance, prepares your nervous system, and optimizes your workout quality.';

  @override
  String get customizeWorkout => 'Customize Workout';

  @override
  String get customizeWorkoutSubtitle => 'Enable or disable features';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get displayModeDescription => 'Choose your metrics detail level';

  @override
  String get baseMode => '🌱 Base';

  @override
  String get proMode => '🚀 Pro';

  @override
  String get baseModeActivated => 'Base Mode activated';

  @override
  String get proModeActivated => 'Pro Mode activated';

  @override
  String get coreFeaturesSection => '🏋️ Core Features';

  @override
  String get autoRestTimerTitle => 'Auto Rest Timer';

  @override
  String get autoRestTimerDescription =>
      'Automatically start timer after each set';

  @override
  String get autoRestTimerTooltip =>
      'When enabled, the rest timer starts automatically when you complete a set, helping you maintain consistent rest intervals.';

  @override
  String get warmupSuggestionsTitle => 'Warmup Suggestions';

  @override
  String get warmupSuggestionsDescription =>
      'Automatically calculate warmup sets';

  @override
  String get warmupSuggestionsTooltip =>
      'The system will suggest progressive warmup sets based on your working weight, preparing your muscles and nervous system.';

  @override
  String get autoCollapseTitle => 'Auto-Collapse Completed';

  @override
  String get autoCollapseDescription =>
      'Automatically collapse completed exercises';

  @override
  String get autoCollapseTooltip =>
      'Completed exercises will automatically minimize to keep your workout screen clean and focused on active exercises.';

  @override
  String get intelligentAutoRegulation => '⚡ Intelligent Auto-Regulation';

  @override
  String get apreSystemTitle => '📈 APRE System';

  @override
  String get apreSystemSubtitle => 'Reps-Based Auto-Regulation';

  @override
  String get enableApreTitle => 'Enable APRE';

  @override
  String get enableApreDescription =>
      'Automatic weight calculation from history for new exercises';

  @override
  String get enableApreTooltip =>
      'APRE analyzes your training history to calculate your 1RM and automatically suggests appropriate weights for each protocol (3, 6, or 10 reps).';

  @override
  String get apreProtocolTitle => 'APRE Protocol';

  @override
  String get apre3 => 'APRE 3';

  @override
  String get apre6 => 'APRE 6';

  @override
  String get apre10 => 'APRE 10';

  @override
  String get apre3Description =>
      'Ideal for maximum strength (3+ reps to failure)';

  @override
  String get apre6Description =>
      'Balanced for strength and hypertrophy (6+ reps)';

  @override
  String get apre10Description =>
      'Perfect for hypertrophy and endurance (10+ reps)';

  @override
  String get autoAdjustRestApreTitle => 'Auto-Adjust Rest Time';

  @override
  String get autoAdjustRestApreDescription => 'Increase rest if load decreases';

  @override
  String get autoAdjustRestApreTooltip =>
      'When your lifted weight decreases, the system automatically increases rest time to help manage fatigue.';

  @override
  String get rpeSystemTitle => '💪 RPE/RIR System';

  @override
  String get rpeSystemSubtitle => 'Effort-Based Auto-Regulation';

  @override
  String get enableRpeTitle => 'Enable RPE Tracking';

  @override
  String get enableRpeDescription => 'Request perceived effort after each set';

  @override
  String get enableRpeTooltip =>
      'RPE (Rate of Perceived Exertion) helps you track how hard each set feels, enabling smart auto-regulation based on your fatigue level.';

  @override
  String get attentionRequired => 'Attention';

  @override
  String get enable => 'Enable';

  @override
  String get essentialsSection => 'Essentials';

  @override
  String get essentialsSectionDesc => 'Core settings to get started';

  @override
  String get advancedSection => 'Advanced';

  @override
  String get advancedSectionDesc => 'Customizations for experienced users';

  @override
  String get visualizationCategory => 'Visualization';

  @override
  String get autoRegulationCategory => 'Auto-regulation';

  @override
  String get interfaceCategory => 'Interface';

  @override
  String get enableTutTitle => 'Enable TUT Tracking';

  @override
  String get enableTutDescription => 'Track Time Under Tension for each set';

  @override
  String get enableTutTooltip =>
      'TUT (Time Under Tension) measures how long each set takes, helping you optimize muscle growth by tracking execution speed and rest times.';

  @override
  String get setDurationTrackingTitle => 'Track Set Duration (TUT)';

  @override
  String get setDurationTrackingDescription =>
      'Measure Time Under Tension for each set';

  @override
  String get setDurationTrackingTooltip =>
      'Automatically track how long each set takes from start to completion, excluding rest time. This helps analyze your execution speed and optimize muscle growth.';

  @override
  String get startTrackingDuration => 'Start tracking duration';

  @override
  String get getReady => 'Get ready...';

  @override
  String get goStartYourSet => 'GO! Start your set';

  @override
  String get autoAdjustWeightRpeTitle => 'Auto-Adjust Weight';

  @override
  String get autoAdjustWeightRpeDescription =>
      'Adjust weight based on RPE feedback';

  @override
  String get autoAdjustWeightRpeTooltip =>
      'RPE 9-10: suggest -2.5kg/-5%. RPE ≤6: suggest +2.5kg/+5%. Helps you find the optimal load for your current state.';

  @override
  String get autoAdjustRestRpeTitle => 'Auto-Adjust Rest Time';

  @override
  String get autoAdjustRestRpeDescription =>
      'Adjust rest based on effort level';

  @override
  String get autoAdjustRestRpeTooltip =>
      'RPE 8-10: +30s rest. RPE ≤6: -15s rest. Automatically adapts recovery time to your fatigue level.';

  @override
  String get informationInsightsSection => '📊 Information & Insights';

  @override
  String get exerciseDetailsTitle => 'Exercise Details';

  @override
  String get exerciseDetailsDescription => 'Show notes and detailed statistics';

  @override
  String get exerciseDetailsTooltip =>
      'Display comprehensive exercise information including personal notes, progress statistics, and performance insights.';

  @override
  String get communitySuggestionsTitle => 'Community Suggestions';

  @override
  String get communitySuggestionsDescription => 'Show tips from the community';

  @override
  String get communitySuggestionsTooltip =>
      'Get helpful advice and tips from other experienced athletes for each exercise.';

  @override
  String get tutInfoTitle => 'TUT Information';

  @override
  String get tutInfoDescription => 'Display Time Under Tension info';

  @override
  String get tutInfoTooltip =>
      'Show tempo (e.g., 3-1-2-0) to control exercise speed and maximize muscle engagement.';

  @override
  String get quickAccessSection => '🎯 Quick Access';

  @override
  String get quickAccessIconsTitle => 'Quick Access Icons';

  @override
  String get quickAccessIconsDescription =>
      'Show info, warmup, and prevention icons';

  @override
  String get quickAccessIconsTooltip =>
      'Enable quick access buttons in exercise headers for instant access to information, warmup suggestions, and injury prevention tips.';

  @override
  String get interfaceSection => '⚙️ Interface & Performance';

  @override
  String get advancedMenuTitle => 'Advanced Options Menu';

  @override
  String get advancedMenuDescription =>
      'Show advanced options in exercise menu';

  @override
  String get advancedMenuTooltip =>
      'Display additional advanced options like exercise replacement, technique variations, and detailed settings.';

  @override
  String get customTimersTitle => 'Custom Timers';

  @override
  String get customTimersDescription =>
      'Show custom timer settings per exercise';

  @override
  String get customTimersTooltip =>
      'Set specific rest times for individual exercises, perfect for different training intensities.';

  @override
  String get collapseCountdownTitle => 'Collapse Countdown Animation';

  @override
  String get collapseCountdownDescription =>
      'Show countdown before auto-collapse';

  @override
  String get collapseCountdownTooltip =>
      'Display a visual countdown before exercises automatically collapse, giving you time to review.';

  @override
  String get simplifiedAnimationsTitle => 'Simplified Animations';

  @override
  String get simplifiedAnimationsDescription =>
      'Use simpler and faster animations';

  @override
  String get simplifiedAnimationsTooltip =>
      'Reduce animation complexity for better performance on older devices or if you prefer a snappier interface.';

  @override
  String get settingsAutoSaved =>
      'Settings are automatically saved and applied to all future workouts';

  @override
  String replaceExerciseReason(String exercise, String reason) {
    return 'Replace $exercise ($reason)';
  }

  @override
  String get plateauDetected => 'Plateau Detected';

  @override
  String get formRisk => 'Form Risk';

  @override
  String get selectReplacement => 'Select Replacement Exercise';

  @override
  String get similarExercises => 'Similar Exercises';

  @override
  String get selectTemplates => 'Select Templates to Update';

  @override
  String applyToTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates',
      one: '1 template',
    );
    return 'Apply to $_temp0';
  }

  @override
  String exerciseReplacedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates',
      one: '1 template',
    );
    return 'Exercise replaced successfully in $_temp0';
  }

  @override
  String get noSimilarExercises => 'No similar exercises found';

  @override
  String get selectAtLeastOneTemplate => 'Select at least one template';

  @override
  String get weightHandling => 'Weight Handling';

  @override
  String get keepCurrentWeight => 'Keep current weight';

  @override
  String get resetWeight => 'Reset weight (start fresh)';

  @override
  String get setManually => 'Set manually later';

  @override
  String get volumeDistribution => 'Volume Distribution';

  @override
  String get scientificRatios => 'Scientific Ratios';

  @override
  String get noMuscleGroupData => 'No muscle group data available';

  @override
  String get muscleBalanceScience => 'Muscle Balance Science';

  @override
  String get muscleBalanceExplanation =>
      'Muscle balance analysis shows volume distribution and scientifically validated ratios to prevent injury and optimize performance.';

  @override
  String get insightProgressiveOverloadRegressionTitle =>
      'Volume Regression Detected';

  @override
  String insightProgressiveOverloadRegressionMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return 'Volume decreased by $overloadPercent% on $exerciseName';
  }

  @override
  String get insightProgressiveOverloadRegressionRec =>
      'Verify recovery status and training stress. Reference: Kraemer & Ratamess (2004)';

  @override
  String get insightProgressiveOverloadExcessiveTitle =>
      'Excessive Volume Increase';

  @override
  String insightProgressiveOverloadExcessiveMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return '$exerciseName volume increased by $overloadPercent%';
  }

  @override
  String get insightProgressiveOverloadExcessiveRec =>
      'HIGH risk of overtraining/injury. Consider reducing volume. Reference: ACSM (2009)';

  @override
  String get insightProgressiveOverloadOptimalTitle =>
      'Optimal Progressive Overload';

  @override
  String insightProgressiveOverloadOptimalMessage(
    String overloadPercent,
    String exerciseName,
  ) {
    return '$exerciseName: +$overloadPercent% volume increase';
  }

  @override
  String get insightProgressiveOverloadOptimalRec =>
      'Perfect sustainable progression rate! Reference: Kraemer & Ratamess (2004)';

  @override
  String get insightVolumeLowTitle => 'Below Optimal Volume';

  @override
  String insightVolumeLowMessage(
    String muscleGroup,
    String currentSets,
    String targetMin,
  ) {
    return '$muscleGroup: $currentSets sets/week (target: $targetMin+)';
  }

  @override
  String get insightVolumeLowRec =>
      'Consider adding sets for optimal hypertrophy. Reference: Schoenfeld et al. (2017)';

  @override
  String get insightVolumeExcessiveTitle => 'Excessive Weekly Volume';

  @override
  String insightVolumeExcessiveMessage(
    String muscleGroup,
    String currentSets,
    String maxRecommended,
  ) {
    return '$muscleGroup: $currentSets sets/week (max recommended: $maxRecommended)';
  }

  @override
  String get insightVolumeExcessiveRec =>
      'Risk of overtraining. Consider deload week. Reference: Schoenfeld et al. (2017)';

  @override
  String get insightIntensityLowTitle => 'Low Training Intensity';

  @override
  String insightIntensityLowMessage(
    String exerciseName,
    String percentOf1RM,
    String weight,
    String reps,
  ) {
    return '$exerciseName: $percentOf1RM% 1RM (${weight}kg × $reps reps)';
  }

  @override
  String get insightIntensityLowRec =>
      'Better for muscular endurance. Increase weight for hypertrophy/strength. Reference: Reynolds et al. (2006)';

  @override
  String get insightPushPullImbalanceTitle => 'Push:Pull Imbalance';

  @override
  String insightPushPullImbalanceMessage(
    String ratio,
    String pushSets,
    String pullSets,
  ) {
    return 'Ratio: $ratio:1 ($pushSets push, $pullSets pull sets)';
  }

  @override
  String insightPushPullImbalanceRec(String feedback) {
    return '$feedback Reference: Boyle (2016)';
  }

  @override
  String get insightQuadHamHighRiskTitle => 'HIGH Hamstring Injury Risk';

  @override
  String insightQuadHamHighRiskMessage(
    String ratio,
    String quadSets,
    String hamSets,
  ) {
    return 'Quad:Ham ratio $ratio:1 ($quadSets quad, $hamSets hamstring sets)';
  }

  @override
  String insightQuadHamHighRiskRec(String riskMultiplier) {
    return 'Hamstrings severely under-trained ($riskMultiplier injury risk). Add RDLs, leg curls immediately. Reference: Croisier et al. (2008)';
  }

  @override
  String get processing => 'Processing...';

  @override
  String get errorAuthenticationRequired =>
      'Authentication required. Please sign in again.';

  @override
  String get errorCannotModifyTemplate =>
      'Cannot modify this template. You can only edit your own templates.';

  @override
  String get errorNetworkConnection => 'Network error. Check your connection.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get pushPullRatio => 'Push:Pull Ratio';

  @override
  String get quadHamstringRatio => 'Quad:Hamstring Ratio';

  @override
  String pushSetsLabel(Object count) {
    return '$count Push sets';
  }

  @override
  String pullSetsLabel(Object count) {
    return '$count Pull sets';
  }

  @override
  String quadSetsLabel(Object count) {
    return '$count Quad sets';
  }

  @override
  String hamstringSetsLabel(Object count) {
    return '$count Hamstring sets';
  }

  @override
  String get pushPullExplanation =>
      'Equal or Pull-emphasized for shoulder health and posture';

  @override
  String get quadHamExplanation =>
      'Ratio <0.6 increases hamstring injury risk by 17x';

  @override
  String get feedbackTooMuchPull => 'Too much Pull volume - increase Push work';

  @override
  String get feedbackTooMuchPush =>
      'Too much Push volume - risk of postural imbalances. Increase Pull work';

  @override
  String get feedbackSlightPushExcess =>
      'Slight Push excess - consider more Pull volume for shoulder health';

  @override
  String get feedbackOptimalPushPull => 'Optimal Push:Pull balance';

  @override
  String get feedbackGoodPullEmphasis =>
      'Good Pull emphasis - ideal for shoulder health';

  @override
  String get feedbackHamstringSeverelyUndertrained =>
      'Hamstrings severely under-trained - HIGH injury risk. Add RDLs, leg curls';

  @override
  String get feedbackHamstringUndertrained =>
      'Hamstrings under-trained - increase posterior chain volume';

  @override
  String get feedbackOptimalQuadHam => 'Optimal Quad:Hamstring balance';

  @override
  String get feedbackHamstringOveremphasized =>
      'Hamstrings potentially over-emphasized vs quads';

  @override
  String get insightDisclaimer =>
      'Insights are based on your recent training data and scientific research';

  @override
  String get mediumPriority => 'Medium Priority';

  @override
  String get lowPriority => 'Low Priority';

  @override
  String get whyThisMatters => 'Why This Matters';

  @override
  String get yourData => 'Your Data';

  @override
  String get evidenceBasedSolutions => 'Evidence-Based Solutions';

  @override
  String get howToImplement => 'How to implement:';

  @override
  String get trackYourFitnessJourney => 'Track your fitness journey';

  @override
  String get trackYourWorkoutsAndMonitorProgress =>
      'Track your workouts and monitor your progress';

  @override
  String get signInToViewAnalytics => 'Sign in to view analytics';

  @override
  String get startYourFirstWorkout => 'Start Your First Workout';

  @override
  String get startYourFirstWorkoutDesc =>
      'Start your first workout to see analytics';

  @override
  String get fitnessQuoteEmptyState =>
      'The journey of a thousand miles begins with a single rep';

  @override
  String get proTip => '💡 Pro Tip:';

  @override
  String get proTipFirstWorkout =>
      'Start with compound movements like squats and bench press for maximum gains';

  @override
  String get errorLoadingAnalytics => 'Error loading analytics';

  @override
  String get accountError => 'Account Error';

  @override
  String get unableToLoadUserData =>
      'Unable to load user data. Please sign out and sign in again.';

  @override
  String get year => 'Year';

  @override
  String get all => 'All';

  @override
  String get thisWeekProgress => 'This Week Progress';

  @override
  String get thisMonthProgress => 'This Month Progress';

  @override
  String get thisYearProgress => 'This Year Progress';

  @override
  String get allTimeProgress => 'All Time Progress';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last365Days => 'Last 365 days';

  @override
  String get allTime => 'All time';

  @override
  String get keepItUp => 'Keep it up!';

  @override
  String get viewStats => 'View Stats';

  @override
  String get noRecentWorkoutsDesc => 'Start a workout to see your progress';

  @override
  String get noRecentWorkouts => 'No recent workouts';

  @override
  String workoutsCount(int count) {
    return '$count workouts';
  }

  @override
  String repsCount(int count) {
    return '$count reps';
  }

  @override
  String get noActivitiesInPeriod => 'No activities in this period';

  @override
  String get noActivitiesForSelectedMuscleGroups =>
      'No activities for selected muscle groups';

  @override
  String get noCompletedExercises =>
      'No completed exercises found in your workouts';

  @override
  String get unableToLoadActivities => 'Unable to load exercise activities';

  @override
  String allActivitiesCount(int count) {
    return 'All Activities ($count)';
  }

  @override
  String get muscleGroupStatistics => 'Muscle Group Statistics';

  @override
  String get setsDetails => 'Sets Details';

  @override
  String volumeWithValue(String value) {
    return 'Volume: $value kg';
  }

  @override
  String rpeWithValue(String value) {
    return 'RPE: $value';
  }

  @override
  String kgMax(String value) {
    return '$value kg max';
  }

  @override
  String totalRepsCount(int count) {
    return '$count reps';
  }

  @override
  String aiWeightJumpAnalysis(Object absoluteIncrease, Object percentIncrease) {
    return 'Weight increased by $percentIncrease% (${absoluteIncrease}kg) in a single session. Research indicates that sudden load increases >15-20% significantly increase injury risk, particularly for connective tissue which adapts slower than muscle. Form breakdown often occurs when neural drive cannot support the new load.';
  }

  @override
  String dataPreviousWeight(Object weight) {
    return 'Previous weight: ${weight}kg';
  }

  @override
  String dataCurrentWeight(Object weight) {
    return 'Current weight: ${weight}kg';
  }

  @override
  String dataAbsoluteJump(Object weight) {
    return 'Absolute jump: +${weight}kg';
  }

  @override
  String dataPercentageIncrease(Object percent) {
    return 'Percentage increase: $percent%';
  }

  @override
  String dataSafeThreshold(Object threshold) {
    return 'Safe threshold: <$threshold%';
  }

  @override
  String get dataRiskFactors => 'Risk: Form breakdown, tendon strain';

  @override
  String get strategyUseSmallerIncrementsTitle => 'Use Smaller Increments';

  @override
  String get strategyUseSmallerIncrementsDesc =>
      'Gradual load progression allows connective tissue adaptation and maintains proper form';

  @override
  String get strategyUseSmallerIncrementsHow =>
      'Increase weight by 2.5-5% per session (2.5kg for lower body, 1.25kg for upper body). Use fractional plates or microloading';

  @override
  String get strategyUseSmallerIncrementsOutcome =>
      'Sustained progress with reduced injury risk. Tendons adapt within 6-8 weeks';

  @override
  String get strategyFocusRepQualityTitle => 'Focus on Rep Quality';

  @override
  String get strategyFocusRepQualityDesc =>
      'Technical proficiency should be maintained across all rep ranges. Speed and control are indicators of appropriate loading';

  @override
  String get strategyFocusRepQualityHow =>
      'Film your sets. If bar speed decreases >20% or form breaks down, reduce weight by 10% and rebuild';

  @override
  String get strategyFocusRepQualityOutcome =>
      'Improved motor patterns and long-term strength gains';

  @override
  String get strategyDeloadWeekTitle => 'Deload Week';

  @override
  String get strategyDeloadWeekDesc =>
      'After rapid load increases, connective tissue needs consolidation time';

  @override
  String get strategyDeloadWeekHow =>
      'Reduce weight by 20-30% for one week while maintaining volume. Focus on technique and recovery';

  @override
  String get strategyDeloadWeekOutcome =>
      'Reduced injury risk and better long-term adaptation';

  @override
  String get insightsAICoach => 'AI Coach Insights';

  @override
  String aiMuscleImbalanceAnalysis(Object muscleGroup, Object sets) {
    return '$muscleGroup is currently at $sets sets/week, which is below the Minimum Effective Volume (MEV) of 10 sets. Scientific research shows that muscles require at least 10-20 sets per week for optimal hypertrophy.';
  }

  @override
  String dataCurrentVolume(Object sets) {
    return 'Current volume: $sets sets/week';
  }

  @override
  String get dataMEV => 'MEV (Minimum): 10 sets/week';

  @override
  String get dataMAV => 'MAV (Optimal): 15-20 sets/week';

  @override
  String dataDeficit(Object deficit) {
    return 'Deficit: $deficit sets below MEV';
  }

  @override
  String dataExercisesList(Object exercises) {
    return 'Exercises: $exercises';
  }

  @override
  String aiHighVolumeAnalysis(Object muscleGroup, Object sets) {
    return '$muscleGroup is at $sets sets/week, exceeding the Maximum Recoverable Volume (MRV) of 25 sets. This level of volume can lead to systemic fatigue, impaired recovery, and diminishing returns. Research shows that exceeding MRV increases injury risk without additional muscle growth benefits.';
  }

  @override
  String get dataMRV => 'MRV (Maximum): 25 sets/week';

  @override
  String dataExcess(Object excess) {
    return 'Excess: $excess sets above MRV';
  }

  @override
  String get dataRiskOvertraining => 'Risk: Overtraining syndrome';

  @override
  String get strategyReduceVolumeTitle => 'Reduce Volume Gradually';

  @override
  String get strategyReduceVolumeDesc =>
      'Sudden volume drops can cause detraining. Gradual reduction maintains adaptations while allowing recovery';

  @override
  String get strategyReduceVolumeHow =>
      'Reduce by 20-30% per week until reaching 15-20 sets. Example: 28 sets → 22 sets → 18 sets over 2 weeks';

  @override
  String get strategyReduceVolumeOutcome =>
      'Restored recovery capacity and improved performance within 2-3 weeks';

  @override
  String get strategyDeloadTitle => 'Implement Deload Week';

  @override
  String get strategyDeloadDesc =>
      'Strategic recovery week allows supercompensation and fatigue dissipation';

  @override
  String get strategyDeloadHow =>
      'Reduce volume by 40-50% for one week. Maintain intensity but cut sets in half';

  @override
  String get strategyDeloadOutcome =>
      'Fresh nervous system and enhanced subsequent performance';

  @override
  String get strategyReallocateTitle => 'Reallocate Volume';

  @override
  String get strategyReallocateDesc =>
      'Distribute excess volume to underdeveloped muscle groups for balanced development';

  @override
  String get strategyReallocateHow =>
      'Identify muscles below MEV. Transfer 1-2 exercises from overtrained muscle to undertrained areas';

  @override
  String get strategyReallocateOutcome =>
      'Balanced development and optimized recovery resources';

  @override
  String aiPlateauAnalysis(Object variation) {
    return 'Weight variation across last 3 sessions is $variation% (threshold: 5%). This indicates insufficient progressive overload stimulus for adaptation.';
  }

  @override
  String dataWeightVariation(Object variation) {
    return 'Weight variation: $variation%';
  }

  @override
  String get dataThreshold => 'Progression threshold: >5%';

  @override
  String dataLastWeights(Object weights) {
    return 'Recent weights: $weights';
  }

  @override
  String dataRecommendedIncrease(Object increase) {
    return 'Recommended increase: ${increase}kg';
  }

  @override
  String aiInsufficientRecoveryAnalysis(Object days) {
    return 'Only $days days since last workout. Research shows that muscles need 24-48 hours for optimal protein synthesis and glycogen replenishment. Training too frequently can impair recovery and increase injury risk.';
  }

  @override
  String dataLastWorkout(Object days) {
    return 'Last workout: $days days ago';
  }

  @override
  String get dataMinimumRecovery => 'Recommended minimum: 1.0 days (24 hours)';

  @override
  String get dataOptimalRange => 'Optimal range: 1-3 days between sessions';

  @override
  String get dataCurrentStatus => 'Status: Insufficient recovery';

  @override
  String get dataMuscleProteinSynthesis => 'MPS window: Still active';

  @override
  String aiLongRecoveryAnalysis(Object days) {
    return '$days days without training. While recovery is important, gaps longer than 4 days can lead to detraining effects. Muscle protein synthesis returns to baseline after 48-72 hours, and strength adaptations begin to decline.';
  }

  @override
  String get dataMaxRecommended => 'Recommended maximum: 4.0 days';

  @override
  String get dataProteinSynthesisPeak =>
      'Protein synthesis peak: 24-48h post-workout';

  @override
  String get dataDetrainingRisk => 'Risk: Detraining effects';

  @override
  String get strategyActiveRecoveryTitle => 'Active Recovery Sessions';

  @override
  String get strategyActiveRecoveryDesc =>
      'Light movement maintains adaptations without adding fatigue';

  @override
  String get strategyActiveRecoveryHow =>
      'Perform 20-30 min of light cardio or bodyweight exercises at 40-60% intensity on rest days';

  @override
  String get strategyActiveRecoveryOutcome =>
      'Maintained adaptations and improved recovery quality';

  @override
  String get strategyScheduleWorkoutsTitle => 'Schedule Next Workout';

  @override
  String get strategyScheduleWorkoutsDesc =>
      'Consistency is key for long-term progress. Plan ahead to avoid extended breaks';

  @override
  String get strategyScheduleWorkoutsHow =>
      'Set specific workout days and times. Use calendar reminders. Aim for max 3-day gaps';

  @override
  String get strategyScheduleWorkoutsOutcome =>
      'Consistent stimulus for continuous adaptation';

  @override
  String aiLowFrequencyAnalysis(Object frequency) {
    return 'Current training frequency of $frequency sessions/week is below the minimum threshold for meaningful adaptations. Research demonstrates that training a muscle group less than once per week results in minimal hypertrophy and strength gains. Muscle protein synthesis peaks 24-48h post-workout and returns to baseline by 72h.';
  }

  @override
  String dataCurrentFrequency(Object frequency) {
    return 'Current frequency: $frequency workouts/week';
  }

  @override
  String get dataMinimumEffective => 'Minimum effective: 1-2 workouts/week';

  @override
  String get dataOptimalFrequency => 'Optimal range: 3-5 workouts/week';

  @override
  String get dataAdaptationStatus => 'Status: Suboptimal adaptation stimulus';

  @override
  String dataMPSCycle(Object hours) {
    return 'MPS cycle: ${hours}h window underutilized';
  }

  @override
  String get strategyIncreaseFrequencyTitle => 'Increase Training Frequency';

  @override
  String get strategyIncreaseFrequencyDesc =>
      'Higher frequency provides more frequent stimulus for adaptation';

  @override
  String get strategyIncreaseFrequencyHow =>
      'Add 1 session per week initially. Build up to 3-4 sessions. Focus on different muscle groups each session';

  @override
  String get strategyIncreaseFrequencyOutcome =>
      'Enhanced muscle protein synthesis frequency and faster gains';

  @override
  String get strategyFullBodyTitle => 'Adopt Full-Body Workouts';

  @override
  String get strategyFullBodyDesc =>
      'Full-body sessions allow hitting each muscle 2-3x/week even with lower frequency';

  @override
  String get strategyFullBodyHow =>
      'Design 2-3 workouts hitting all major muscles. Include 1-2 exercises per muscle group';

  @override
  String get strategyFullBodyOutcome =>
      'Optimal stimulus frequency even with limited workout days';

  @override
  String aiHighFrequencyAnalysis(Object frequency) {
    return 'Training $frequency times per week may exceed optimal frequency for recovery. While high frequency can work for advanced lifters with proper programming, it increases risk of overtraining, CNS fatigue, and diminishing returns. Studies show no additional hypertrophy benefits beyond 5-6 sessions/week when volume is equated.';
  }

  @override
  String get dataMaxBeneficial => 'Maximum beneficial: ~6 workouts/week';

  @override
  String get dataRecoveryStatus => 'Status: Potential overreaching';

  @override
  String get dataCNSFatigue => 'CNS fatigue risk: Elevated';

  @override
  String get strategyReduceFrequencyTitle => 'Reduce Training Frequency';

  @override
  String get strategyReduceFrequencyDesc =>
      'Lower frequency with maintained volume can improve recovery and results';

  @override
  String get strategyReduceFrequencyHow =>
      'Consolidate workouts into 4-5 quality sessions. Increase volume per session slightly';

  @override
  String get strategyReduceFrequencyOutcome =>
      'Better recovery, reduced injury risk, maintained or improved gains';

  @override
  String get strategyImplementRestDaysTitle => 'Implement Strategic Rest Days';

  @override
  String get strategyImplementRestDaysDesc =>
      'Scheduled rest allows adaptation and prevents accumulated fatigue';

  @override
  String get strategyImplementRestDaysHow =>
      'Take at least 1-2 complete rest days per week. Place them after hardest training days';

  @override
  String get strategyImplementRestDaysOutcome =>
      'Optimized recovery and sustained performance';

  @override
  String dataSession1(Object weight) {
    return 'Session 1: ${weight}kg';
  }

  @override
  String dataSession2(Object weight) {
    return 'Session 2: ${weight}kg';
  }

  @override
  String dataSession3(Object weight) {
    return 'Session 3: ${weight}kg';
  }

  @override
  String dataAverageWeight(Object weight) {
    return 'Average: ${weight}kg';
  }

  @override
  String dataWeightVariation2(Object percent, Object weight) {
    return 'Variation: ${weight}kg ($percent%)';
  }

  @override
  String get strategyPlateauincreasevolumeTitle => 'Increase Training Volume';

  @override
  String get strategyPlateauincreasevolumeDesc =>
      'Progressive volume increase is one of the primary drivers of hypertrophy adaptation';

  @override
  String get strategyPlateauincreasevolumeImpl =>
      'Add 1-2 sets per week until you reach 15-20 sets per muscle group. Example: if doing 3 sets, increase to 4-5 sets';

  @override
  String get strategyPlateauincreasevolumeOutcome =>
      'New growth stimulus within 2-4 weeks. Volume should increase gradually to avoid overtraining';

  @override
  String get strategyPlateauvaryrepsTitle => 'Vary Rep Ranges';

  @override
  String get strategyPlateauvaryrepsDesc =>
      'Different rep ranges recruit different muscle fiber types and create novel mechanical tension';

  @override
  String get strategyPlateauvaryrepsImpl =>
      'Alternate between strength (4-6 reps), hypertrophy (8-12 reps), and endurance (15-20 reps) ranges across weeks';

  @override
  String get strategyPlateauvaryrepsOutcome =>
      'Enhanced overall muscle development and strength gains across all ranges';

  @override
  String get strategyPlateauadvancedtechniquesTitle =>
      'Implement Advanced Techniques';

  @override
  String get strategyPlateauadvancedtechniquesDesc =>
      'Intensity techniques increase metabolic stress and mechanical tension beyond traditional sets';

  @override
  String get strategyPlateauadvancedtechniquesImpl =>
      'Use drop sets (reduce weight 20-30% after failure), rest-pause (10-15 sec rest between mini-sets), or forced reps on final set';

  @override
  String get strategyPlateauadvancedtechniquesOutcome =>
      'Immediate increase in muscle fiber recruitment and metabolic stress';

  @override
  String get strategyPlateauchangeexercisesTitle => 'Change Exercise Variation';

  @override
  String get strategyPlateauchangeexercisesDesc =>
      'Novel exercises create different force vectors and recruitment patterns';

  @override
  String get strategyPlateauchangeexercisesImpl =>
      'Substitute similar exercises with different angles. Example: flat bench → incline bench, squat → front squat';

  @override
  String get strategyPlateauchangeexercisesOutcome =>
      'Renewed strength gains and muscle activation in 1-2 weeks';

  @override
  String get strategyPlateaudeloadweekTitle => 'Deload Week';

  @override
  String get strategyPlateaudeloadweekDesc =>
      'Strategic recovery allows supercompensation and nervous system recovery';

  @override
  String get strategyPlateaudeloadweekImpl =>
      'Reduce volume by 40-50% for 1 week (half the sets, same weight). Maintain frequency but reduce total work';

  @override
  String get strategyPlateaudeloadweekOutcome =>
      'Return stronger after deload with reduced fatigue and improved neuromuscular efficiency';

  @override
  String get strategyBalanceincreasefrequencyTitle =>
      'Increase Training Frequency';

  @override
  String get strategyBalanceincreasefrequencyDesc =>
      'Higher frequency provides more opportunities for volume accumulation and skill practice';

  @override
  String get strategyBalanceincreasefrequencyImpl =>
      'Split current volume across 2-3 sessions per week instead of 1. Example: 10 sets → 5 sets × 2 days';

  @override
  String get strategyBalanceincreasefrequencyOutcome =>
      'Better recovery between sessions and higher quality sets';

  @override
  String get strategyBalanceprioritizeweakTitle =>
      'Prioritize Weak Muscle Groups';

  @override
  String get strategyBalanceprioritizeweakDesc =>
      'Training lagging muscles first when energy is highest maximizes adaptation';

  @override
  String get strategyBalanceprioritizeweakImpl =>
      'Perform weak muscle exercises at the beginning of your workout when neurologically fresh';

  @override
  String get strategyBalanceprioritizeweakOutcome =>
      'Improved performance and progressive overload on weak points';

  @override
  String get strategyBalanceaddisolationTitle => 'Add Isolation Work';

  @override
  String get strategyBalanceaddisolationDesc =>
      'Direct isolation allows targeted volume without systemic fatigue';

  @override
  String get strategyBalanceaddisolationImpl =>
      'Add 2-3 isolation exercises (12-15 reps) after compound movements for the weak muscle';

  @override
  String get strategyBalanceaddisolationOutcome =>
      'Increased local volume and muscle-mind connection';

  @override
  String get strategyRecoveryoptimizesleepTitle => 'Optimize Sleep Duration';

  @override
  String get strategyRecoveryoptimizesleepDesc =>
      'Sleep is the primary recovery mechanism for neuromuscular adaptation';

  @override
  String get strategyRecoveryoptimizesleepImpl =>
      'Aim for 7-9 hours per night. Prioritize consistent sleep schedule (same bedtime/wake time)';

  @override
  String get strategyRecoveryoptimizesleepOutcome =>
      'Enhanced muscle protein synthesis and reduced cortisol levels';

  @override
  String get strategyRecoveryperiodizeTitle => 'Periodize Training Stress';

  @override
  String get strategyRecoveryperiodizeDesc =>
      'Alternating high and low stress weeks prevents chronic fatigue';

  @override
  String get strategyRecoveryperiodizeImpl =>
      '3 weeks progressive overload → 1 deload week (50% volume reduction)';

  @override
  String get strategyRecoveryperiodizeOutcome =>
      'Sustained progress without burnout or injury risk';

  @override
  String get strategyRecoveryactiverecoveryTitle => 'Active Recovery Sessions';

  @override
  String get strategyRecoveryactiverecoveryDesc =>
      'Light activity enhances blood flow and waste removal without adding fatigue';

  @override
  String get strategyRecoveryactiverecoveryImpl =>
      'Add 20-30 min low-intensity cardio or mobility work on rest days';

  @override
  String get strategyRecoveryactiverecoveryOutcome =>
      'Faster recovery and reduced muscle soreness';

  @override
  String get strategyLongrecoveryscheduleTitle =>
      'Establish Consistent Schedule';

  @override
  String get strategyLongrecoveryscheduleDesc =>
      'Training frequency is more important than individual session quality for long-term progress';

  @override
  String get strategyLongrecoveryscheduleImpl =>
      'Schedule 3-5 fixed training days per week. Use calendar reminders. Prepare gym bag the night before';

  @override
  String get strategyLongrecoveryscheduleOutcome =>
      'Improved habit formation and training adherence within 3-4 weeks';

  @override
  String get strategyLongrecoverymindoseTitle => 'Use Minimum Effective Dose';

  @override
  String get strategyLongrecoverymindoseDesc =>
      'Short, frequent sessions maintain adaptations better than long, infrequent workouts';

  @override
  String get strategyLongrecoverymindoseImpl =>
      'If time-constrained, do 20-30 min sessions instead of skipping. Focus on compound movements';

  @override
  String get strategyLongrecoverymindoseOutcome =>
      'Maintained strength and muscle mass with 60% less volume';

  @override
  String get strategyLowfrequencyminviableTitle =>
      'Start with Minimum Viable Frequency';

  @override
  String get strategyLowfrequencyminviableDesc =>
      'Even 2 weekly sessions produce 80% of the benefits of higher frequencies for beginners';

  @override
  String get strategyLowfrequencyminviableImpl =>
      'Schedule 2 full-body sessions per week (e.g., Monday/Thursday). 45-60 min each with 4-5 compound exercises';

  @override
  String get strategyLowfrequencyminviableOutcome =>
      'Measurable strength gains within 4-6 weeks. Habit formation in 3-4 weeks';

  @override
  String get strategyLowfrequencytimeefficientTitle =>
      'Use Time-Efficient Protocols';

  @override
  String get strategyLowfrequencytimeefficientDesc =>
      'Strategic exercise selection maximizes results per minute invested';

  @override
  String get strategyLowfrequencytimeefficientImpl =>
      'Focus on compound movements: Squat, Bench, Deadlift, Row, Press. 3 sets of 8-12 reps each. Total: 30-40 min';

  @override
  String get strategyLowfrequencytimeefficientOutcome =>
      'Full-body stimulus with minimal time investment';

  @override
  String get strategyHighfrequencyconsolidateTitle =>
      'Consolidate Training Sessions';

  @override
  String get strategyHighfrequencyconsolidateDesc =>
      'Fewer, higher-quality sessions often outperform high-frequency, lower-quality work';

  @override
  String get strategyHighfrequencyconsolidateImpl =>
      'Combine similar muscle groups. Example: Instead of 7 separate sessions, do 4-5 focused sessions with more volume per workout';

  @override
  String get strategyHighfrequencyconsolidateOutcome =>
      'Better recovery, maintained volume, reduced fatigue accumulation';

  @override
  String get strategyHighfrequencyrestdaysTitle =>
      'Implement Strategic Rest Days';

  @override
  String get strategyHighfrequencyrestdaysDesc =>
      'Complete rest or active recovery days are essential for supercompensation';

  @override
  String get strategyHighfrequencyrestdaysImpl =>
      'Take 1-2 full rest days per week. On rest days, do light walking or mobility work only (no resistance training)';

  @override
  String get strategyHighfrequencyrestdaysOutcome =>
      'Improved strength rebound and reduced injury risk within 2-3 weeks';

  @override
  String get strategyHighvolumereducegraduallyTitle =>
      'Reduce Volume Gradually';

  @override
  String get strategyHighvolumereducegraduallyDesc =>
      'Sudden volume drops can cause detraining. Gradual reduction maintains adaptations while allowing recovery';

  @override
  String get strategyHighvolumereducegraduallyImpl =>
      'Reduce by 20-30% per week until reaching 15-20 sets. Example: 28 sets → 22 sets → 18 sets over 2 weeks';

  @override
  String get strategyHighvolumereducegraduallyOutcome =>
      'Restored recovery capacity and improved performance within 2-3 weeks';

  @override
  String get strategyHighvolumedeloadTitle => 'Implement Deload Week';

  @override
  String get strategyHighvolumedeloadDesc =>
      'Strategic recovery week allows supercompensation and fatigue dissipation';

  @override
  String get strategyHighvolumedeloadImpl =>
      'Cut volume by 50% for one week. Maintain weight but do half the sets. Then resume at optimal volume (15-20 sets)';

  @override
  String get strategyHighvolumedeloadOutcome =>
      'Return stronger with reduced accumulated fatigue. Strength rebound in 7-10 days';

  @override
  String get strategyHighvolumeincreasefreqTitle =>
      'Increase Training Frequency';

  @override
  String get strategyHighvolumeincreasefreqDesc =>
      'Same volume spread across more sessions reduces per-session fatigue';

  @override
  String get strategyHighvolumeincreasefreqImpl =>
      'Split current volume across more days. Example: 28 sets/week → 7 sets × 4 days instead of 14 sets × 2 days';

  @override
  String get strategyHighvolumeincreasefreqOutcome =>
      'Better recovery between sessions and higher quality sets';

  @override
  String get filterByType => 'Filter by Type';

  @override
  String get filterByPriority => 'Filter by Priority';

  @override
  String get success => 'Success';

  @override
  String get info => 'Info';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get criticalSeverity =>
      'Critical severity - immediate action required';

  @override
  String get highSeverity => 'High severity - action recommended';

  @override
  String get mediumSeverity => 'Medium severity - consider action';

  @override
  String get lowSeverity => 'Low severity - informational';

  @override
  String get filterRecommendations => 'Filter Recommendations';

  @override
  String get noRecommendationsFound => 'No recommendations match your filters';

  @override
  String get totalVolumeTooltip =>
      'Total Volume represents the sum of weight × reps across all exercises. It\'s a key indicator of overall training stress and progression.';

  @override
  String get workoutFrequencyTooltip =>
      'Workout Frequency is how often you train per week. Research shows 3-5 sessions per week is optimal for most goals.';

  @override
  String get consistencyTooltip =>
      'Consistency Score measures how regularly you stick to your training schedule. Higher scores (80%+) lead to better long-term results.';

  @override
  String get currentStreakTooltip =>
      'Current Streak tracks consecutive days with at least one workout. Maintaining streaks builds sustainable training habits.';

  @override
  String get muscleBalanceTooltip =>
      'Muscle Balance shows the distribution of training volume across muscle groups. Aim for balanced development (15-20% per group).';

  @override
  String get volumeTrendTooltip =>
      'Volume Trend indicates whether your total training volume is increasing (+), stable (=), or decreasing (-) over time.';

  @override
  String get weeklyDashboard => 'Weekly Dashboard';

  @override
  String get consistencyHeatmap => 'Consistency Heatmap';

  @override
  String get adminMode => 'ADMIN MODE';

  @override
  String get premiumInsights => 'Premium Insights';

  @override
  String get unlockAdvancedAnalytics =>
      'Unlock advanced analytics and insights';

  @override
  String get weeklyPerformanceDashboard => 'Weekly Performance Dashboard';

  @override
  String get muscleGroupBalanceAnalysis => 'Muscle Group Balance Analysis';

  @override
  String get workoutConsistencyTracking => 'Workout Consistency Tracking';

  @override
  String get personalizedRecommendations => 'Personalized Recommendations';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get scientificBasis => 'Scientific Basis';

  @override
  String get exerciseBreakdown => 'Exercise Breakdown';

  @override
  String get total => 'Total';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get tapForScientificExplanation => 'Tap for scientific explanation';

  @override
  String get pectorals => 'PETT (Pectorals)';

  @override
  String get deltoids => 'DELT (Deltoids)';

  @override
  String get premium => 'Premium';

  @override
  String get premiumAnalytics => 'Premium Analytics';

  @override
  String get scienceBasedInsights =>
      'Science-based insights for serious athletes';

  @override
  String get repContinuum => 'Rep Continuum';

  @override
  String get repContinuumSubtitle =>
      'Training distribution across strength, hypertrophy & endurance zones';

  @override
  String totalSetsAnalyzed(int count) {
    return '$count total sets analyzed';
  }

  @override
  String get strengthZone => 'Strength (1-5 reps)';

  @override
  String get strengthZoneDesc => 'Max force, neural adaptations';

  @override
  String get hypertrophyZone => 'Hypertrophy (6-15 reps)';

  @override
  String get hypertrophyZoneDesc => 'Muscle growth, metabolic stress';

  @override
  String get enduranceZone => 'Endurance (15+ reps)';

  @override
  String get enduranceZoneDesc => 'Muscular endurance, conditioning';

  @override
  String get repContinuumRecommendationBalanced =>
      '✅ Excellent! Your training is well-balanced for hypertrophy. Most sets (60%+) are in the optimal 6-15 rep range.';

  @override
  String get repContinuumRecommendationStrength =>
      '🏋️ Strength-focused training detected. Consider adding more hypertrophy work (6-15 reps) for muscle growth.';

  @override
  String get repContinuumRecommendationEndurance =>
      '🏃 High endurance volume. Add lower rep work (6-15 reps) for strength and hypertrophy gains.';

  @override
  String get repContinuumRecommendationMixed =>
      '📊 Mixed training approach. Ensure each muscle group has adequate volume in target rep ranges.';

  @override
  String get repContinuumScientificTitle => 'The Rep Continuum';

  @override
  String get repContinuumScientificSubtitle =>
      'Loading recommendations for muscle strength, hypertrophy, and endurance';

  @override
  String get repContinuumPaperSummary =>
      'This comprehensive review analyzed 100+ studies to determine optimal loading strategies. Key finding: different rep ranges produce distinct adaptations - strength (1-5), hypertrophy (6-15), endurance (15+).';

  @override
  String get keyFindings => 'Key Findings';

  @override
  String get repContinuumFinding1 =>
      'Strength Zone (1-5 reps): Maximizes neural adaptations and absolute strength. Best for powerlifting and max force production.';

  @override
  String get repContinuumFinding2 =>
      'Hypertrophy Zone (6-15 reps): Optimal for muscle growth through mechanical tension and metabolic stress. Industry standard for bodybuilding.';

  @override
  String get repContinuumFinding3 =>
      'Endurance Zone (15+ reps): Develops muscular endurance and work capacity. Important for metabolic conditioning.';

  @override
  String get practicalApplication => 'Practical Application';

  @override
  String get repContinuumPracticalAdvice =>
      'For balanced muscle development, aim for 60-70% of your training volume in the hypertrophy zone (6-15 reps). Include 15-20% strength work and 10-15% endurance work for complete adaptation.';

  @override
  String get volumeLandmarks => 'Volume Landmarks';

  @override
  String get volumeLandmarksSubtitle =>
      'Weekly set volume per muscle group with optimal zones';

  @override
  String get maintenanceVolume => 'MV';

  @override
  String get minEffectiveVolume => 'MEV';

  @override
  String get maxAdaptiveVolume => 'MAV';

  @override
  String get maxRecoverableVolume => 'MRV';

  @override
  String get volumeZoneBelowMaintenance => '⚠️ Below maintenance - add volume';

  @override
  String get volumeZoneMaintenance => 'Maintenance zone';

  @override
  String get volumeZoneEffective => '↗️ Effective zone - growing';

  @override
  String get volumeZoneOptimal => '✅ Optimal zone - perfect!';

  @override
  String get volumeZoneExcessive => '❌ Excessive - risk of overtraining';

  @override
  String get volumeLandmarksScientificTitle => 'Volume Landmarks Explained';

  @override
  String get volumeLandmarksScientificSubtitle =>
      'Evidence-based volume recommendations for muscle hypertrophy';

  @override
  String get volumeLandmarksPaperSummary =>
      'This umbrella review synthesized data from 50+ meta-analyses to establish volume landmarks. Research shows clear dose-response relationship between weekly sets and muscle growth up to MAV.';

  @override
  String get volumeZonesExplanation => 'Volume Zones Explained';

  @override
  String get mvExplanation =>
      'Minimum sets per week to maintain muscle mass. Below this, you\'ll lose muscle over time.';

  @override
  String get mevExplanation =>
      'Minimum sets to start seeing growth. This is your baseline for progressive overload.';

  @override
  String get mavExplanation =>
      'Sweet spot for muscle growth. Maximum hypertrophy response with manageable fatigue.';

  @override
  String get mrvExplanation =>
      'Maximum recoverable volume. Beyond this, fatigue accumulates faster than you can recover.';

  @override
  String get volumeLandmarksPracticalAdvice =>
      'Start at MEV and progressively increase volume each week until you reach MAV. When you hit MRV or plateau, take a deload week at MV levels, then restart the progression.';

  @override
  String get tutVelocityAnalytics => 'TUT & Velocity Analytics';

  @override
  String get tutVelocityDesc =>
      'Time under tension and bar velocity metrics for optimal muscle stimulus';

  @override
  String get dataConfidenceScore => 'Data Confidence Score';

  @override
  String get dataConfidenceDesc =>
      'Quality assessment of your tracking accuracy and consistency';

  @override
  String get anabolicSignals => 'Anabolic Signals';

  @override
  String get anabolicSignalsDesc =>
      'Real-time indicators of muscle growth stimulus and recovery status';

  @override
  String get unlockPremiumAnalytics => 'Unlock Premium Analytics';

  @override
  String get premiumAnalyticsDescription =>
      'Get science-backed insights based on peer-reviewed research. Make data-driven decisions for optimal muscle growth and performance.';

  @override
  String get repContinuumFeature =>
      'Rep Continuum Analysis - optimize training zones';

  @override
  String get volumeLandmarksFeature =>
      'Volume Landmarks - hit your growth sweet spot';

  @override
  String get tutVelocityFeature =>
      'TUT & Velocity tracking - maximize stimulus';

  @override
  String get dataConfidenceFeature =>
      'Data Confidence scoring - trust your data';

  @override
  String get premiumComingSoon => 'Premium features coming soon! 🚀';

  @override
  String get repContinuumPreview =>
      'See how your training is distributed across strength, hypertrophy, and endurance zones';

  @override
  String get volumeLandmarksPreview =>
      'Track your weekly volume against scientifically-validated landmarks (MV, MEV, MAV, MRV)';

  @override
  String volumeBelowMaintenanceExplanation(int current, int mv) {
    return 'You\'re doing only $current sets/week. Minimum to maintain muscle is $mv sets. You\'re at risk of muscle loss.';
  }

  @override
  String volumeBelowMaintenanceAdvice(int sets) {
    return 'Add at least $sets sets this week to reach maintenance volume and prevent muscle loss.';
  }

  @override
  String volumeMaintenanceExplanation(int current, int mv, int mev) {
    return 'You\'re doing $current sets/week. This maintains muscle ($mv-$mev sets) but won\'t trigger growth.';
  }

  @override
  String volumeMaintenanceAdvice(int sets) {
    return 'Add $sets more sets to reach MEV and start seeing muscle growth.';
  }

  @override
  String volumeEffectiveExplanation(int current, int mev, int mav) {
    return 'You\'re doing $current sets/week, in the growth zone ($mev-$mav sets). Good progress!';
  }

  @override
  String volumeEffectiveAdvice(int sets) {
    return 'You can add up to $sets more sets to reach optimal MAV zone for maximum gains.';
  }

  @override
  String volumeOptimalExplanation(int current, int mav, int mrv) {
    return 'You\'re doing $current sets/week, in the optimal zone ($mav-$mrv sets). Maximum hypertrophy stimulus!';
  }

  @override
  String get volumeOptimalAdvice =>
      'Perfect! Maintain this volume for 2-4 weeks, then consider a deload week.';

  @override
  String volumeExcessiveExplanation(int current, int mrv) {
    return 'You\'re doing $current sets/week, exceeding recovery limit ($mrv sets). Risk of overtraining!';
  }

  @override
  String volumeExcessiveAdvice(int sets) {
    return 'Reduce volume by $sets sets or take an immediate deload week at 50% volume to recover.';
  }

  @override
  String get exercisesThisWeek => 'Exercises This Week';

  @override
  String get rpeAndIntensity => 'RPE & Intensity';

  @override
  String get rpeIntensityDistribution => 'Training intensity distribution';

  @override
  String get setsWithRPETracked => 'Sets with RPE tracked';

  @override
  String get noRPEDataAvailable => 'No RPE data available';

  @override
  String get noRPEDataDescription =>
      'Start tracking RPE (Rate of Perceived Exertion) during your workouts to see intensity analysis';

  @override
  String get rpeDistribution => 'RPE Distribution';

  @override
  String get rpeRecovery => 'Recovery (5-6)';

  @override
  String get rpeModerate => 'Moderate (7)';

  @override
  String get rpeHard => 'Hard (8)';

  @override
  String get rpeVeryHard => 'Very Hard (9)';

  @override
  String get rpeMaximal => 'Maximal (10)';

  @override
  String get averageRPEPerMuscleGroup => 'Average RPE per Muscle Group';

  @override
  String get setsUnit => 'sets';

  @override
  String get rangeLabel => 'Range:';

  @override
  String get helmsEtAl2018 =>
      'Helms et al. (2018) - Strength & Conditioning Journal';

  @override
  String get intensityZoneTooEasy => 'Too Easy';

  @override
  String get intensityZoneTooEasyDesc =>
      'Over 50% of sets are low intensity (RPE 5-6). Risk of lack of progress.';

  @override
  String get intensityZoneTooEasyAdvice =>
      'Increase intensity: bring 60-80% of sets to RPE 7-9 to stimulate hypertrophy.';

  @override
  String get intensityZoneOptimalHypertrophy => 'Optimal for Hypertrophy';

  @override
  String get intensityZoneOptimalHypertrophyDesc =>
      '60-80% of sets are at productive intensity (RPE 7-9). Perfect for muscle growth!';

  @override
  String get intensityZoneOptimalHypertrophyAdvice =>
      'Keep it up! This distribution is ideal for maximizing hypertrophy.';

  @override
  String get intensityZoneOptimalStrength => 'Optimal for Strength';

  @override
  String get intensityZoneOptimalStrengthDesc =>
      '50-70% of sets are high intensity (RPE 8-10). Perfect for strength gains!';

  @override
  String get intensityZoneOptimalStrengthAdvice =>
      'Excellent! This distribution maximizes strength gains. Consider deload every 4-6 weeks.';

  @override
  String get intensityZoneBalanced => 'Balanced';

  @override
  String get intensityZoneBalancedDesc =>
      'Good mix of intensities. Suitable for general progress.';

  @override
  String get intensityZoneBalancedAdvice =>
      'Balanced distribution. For hypertrophy, increase RPE 7-9. For strength, increase RPE 8-10.';

  @override
  String get intensityZoneTooHard => 'Too Intense';

  @override
  String get intensityZoneTooHardDesc =>
      'Over 30% of sets are maximal (RPE 10). Risk of overtraining and injury.';

  @override
  String get intensityZoneTooHardAdvice =>
      'Reduce intensity: max 20-30% sets at RPE 10. Add more sets at RPE 7-8 for sustainable volume.';

  @override
  String get rpeInfoTitle => 'RPE & Intensity';

  @override
  String get rpeInfoDescription =>
      'RPE (Rate of Perceived Exertion) is a 5-10 effort scale:';

  @override
  String get rpeScale5_6 => 'RPE 5-6';

  @override
  String get rpeScale5_6Desc => 'Recovery - Easy';

  @override
  String get rpeScale7 => 'RPE 7';

  @override
  String get rpeScale7Desc => 'Moderate - 3 RIR';

  @override
  String get rpeScale8 => 'RPE 8';

  @override
  String get rpeScale8Desc => 'Hard - 2 RIR';

  @override
  String get rpeScale9 => 'RPE 9';

  @override
  String get rpeScale9Desc => 'Very Hard - 1 RIR';

  @override
  String get rpeScale10 => 'RPE 10';

  @override
  String get rpeScale10Desc => 'Maximal - 0 RIR';

  @override
  String get optimalDistribution => 'Optimal Distribution (Helms et al. 2018):';

  @override
  String get hypertrophyDistribution => '• Hypertrophy: 60-80% sets at RPE 7-9';

  @override
  String get strengthDistribution => '• Strength: 50-70% sets at RPE 8-10';

  @override
  String get recoveryDistribution => '• Recovery: <50% sets at RPE 5-6';

  @override
  String get closeButton => 'Close';

  @override
  String get uncategorizedExercises => 'Uncategorized Exercises';

  @override
  String get uncategorizedExercisesDesc =>
      'These exercises have \'other\' or \'cardio\' category and are not counted in volume. Tap to assign the correct muscle group.';

  @override
  String get categorizeExercise => 'Categorize Exercise';

  @override
  String get selectCorrectMuscleGroup => 'Select the correct muscle group:';

  @override
  String get chestMuscle => 'Chest';

  @override
  String get backMuscle => 'Back';

  @override
  String get shouldersMuscle => 'Shoulders';

  @override
  String get armsMuscle => 'Arms';

  @override
  String get legsMuscle => 'Legs';

  @override
  String get coreMuscle => 'Core';

  @override
  String get cancelButton => 'Cancel';

  @override
  String remappingComingSoon(String exerciseName, String muscleGroup) {
    return 'Feature coming soon: we\'ll save \"$exerciseName\" as $muscleGroup';
  }

  @override
  String get setsPerWeek => 'sets/week';

  @override
  String get unknownCategory => 'unknown';

  @override
  String get watchAdForPremium => 'Watch Ad for 24h Premium';

  @override
  String get premiumUnlockedFor24Hours => '🎉 Premium unlocked for 24 hours!';

  @override
  String get adNotReady => 'Ad not ready, try again later';

  @override
  String premiumActiveRemaining(String time) {
    return 'Premium active: $time remaining';
  }

  @override
  String get addTemporaryExercise => 'Add temporary exercise';

  @override
  String get reportMissingExercise => 'Report missing exercise';

  @override
  String get temporaryExerciseAdded =>
      'Temporary exercise added! We\'ll review your request.';

  @override
  String get enterExerciseName => 'Enter exercise name';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get pleaseEnterValidData => 'Please enter valid data';

  @override
  String get startRest => 'Start Rest';

  @override
  String get restBetweenSets => 'Rest Between Sets';

  @override
  String get completed => 'Completed';

  @override
  String get set => 'set';

  @override
  String get complete => 'Complete';

  @override
  String get execute => 'Execute';

  @override
  String get skipRest => 'Skip Rest';

  @override
  String get supersetCompleted => 'Superset Completed';

  @override
  String get greatJob => 'Great job!';

  @override
  String get cancelExercise => 'Cancel Exercise?';

  @override
  String get cancelExerciseMessage =>
      'Are you sure you want to cancel? Your progress will not be saved.';

  @override
  String get dropsetTraining => 'Dropset Training';

  @override
  String get dropsetDescription =>
      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.';

  @override
  String get selectedExercise => 'Selected Exercise';

  @override
  String get dropsetConfiguration => 'Dropset Configuration';

  @override
  String get initialWeight => 'Initial Weight';

  @override
  String get selectWeight => 'Select Weight';

  @override
  String get selectInitialWeight => 'Select Initial Weight';

  @override
  String get selectTargetReps => 'Select Target Reps';

  @override
  String get numberOfDrops => 'Number of Drops';

  @override
  String get drops => 'drops';

  @override
  String get dropPercentage => 'Drop Percentage';

  @override
  String get dropStagesPreview => 'Drop Stages Preview';

  @override
  String get mainSet => 'Main Set';

  @override
  String get drop => 'Drop';

  @override
  String get ofMax => 'of max';

  @override
  String get createDropset => 'Create Dropset';

  @override
  String get pleaseSelectExerciseAndWeight =>
      'Please select an exercise and set the initial weight';

  @override
  String get restPauseTraining => 'Rest-Pause Training';

  @override
  String get restPauseDescription =>
      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.';

  @override
  String get restPauseConfiguration => 'Rest-Pause Configuration';

  @override
  String get pauseDuration => 'Pause Duration';

  @override
  String get restPauseInstructions =>
      'Execute the main set to failure, then take short pauses and continue for additional mini-sets';

  @override
  String get createRestPause => 'Create Rest-Pause';

  @override
  String get restPauseLabel => 'REST-PAUSE';

  @override
  String get restPauseMainSet => 'Main Set';

  @override
  String restPauseMiniSet(int index) {
    return 'Mini-Set $index';
  }

  @override
  String get miniSetProgress => 'Mini-Set Progress';

  @override
  String get microPause => 'MICRO-PAUSE';

  @override
  String afterPauseDuration(int duration) {
    return 'After ${duration}s pause';
  }

  @override
  String get rpeLabel => 'Overall RPE (Perceived Exertion)';

  @override
  String get fitnessQuestionnaireTitle => 'Fitness Profile Setup';

  @override
  String get fitnessQuestionnaireWelcomeTitle =>
      'Get Personalized Weight Suggestions';

  @override
  String get fitnessQuestionnaireWelcomeDescription =>
      'Answer a few quick questions to receive scientifically-backed starting weight suggestions for your exercises.';

  @override
  String get fitnessQuestionnaireWelcomeSkip => 'Skip for now';

  @override
  String get fitnessQuestionnaireWelcomeStart => 'Let\'s Start';

  @override
  String get fitnessQuestionnaireDemographicsTitle => 'About You';

  @override
  String get fitnessQuestionnaireBodyweightLabel => 'Current Bodyweight';

  @override
  String get fitnessQuestionnaireBodyweightUnit => 'kg';

  @override
  String get fitnessQuestionnaireAgeLabel => 'Age';

  @override
  String get fitnessQuestionnaireSexLabel => 'Biological Sex';

  @override
  String get fitnessQuestionnaireSexMale => 'Male';

  @override
  String get fitnessQuestionnaireSexFemale => 'Female';

  @override
  String get fitnessQuestionnaireExperienceTitle => 'Training Experience';

  @override
  String get fitnessQuestionnaireExperienceLevelLabel => 'Experience Level';

  @override
  String get fitnessQuestionnaireExperienceLevelUntrained => 'Beginner';

  @override
  String get fitnessQuestionnaireExperienceLevelNovice => 'Novice';

  @override
  String get fitnessQuestionnaireExperienceLevelIntermediate => 'Intermediate';

  @override
  String get fitnessQuestionnaireExperienceLevelAdvanced => 'Advanced';

  @override
  String get fitnessQuestionnaireExperienceLevelElite => 'Elite';

  @override
  String get fitnessQuestionnaireMonthsTrainingLabel =>
      'Months of consistent training (optional)';

  @override
  String get fitnessQuestionnaireMaxLiftsTitle => 'Max Lifts (Optional)';

  @override
  String get fitnessQuestionnaireMaxLiftsDescription =>
      'Entering your max lifts improves suggestion accuracy. You can skip this if you don\'t know them.';

  @override
  String get fitnessQuestionnaireBenchPressLabel => 'Bench Press 1RM';

  @override
  String get fitnessQuestionnaireSquatLabel => 'Squat 1RM';

  @override
  String get fitnessQuestionnaireDeadliftLabel => 'Deadlift 1RM';

  @override
  String get fitnessQuestionnaireOhpLabel => 'Overhead Press 1RM';

  @override
  String get fitnessQuestionnaireCalculateFrom => 'Calculate from reps';

  @override
  String get fitnessQuestionnaireGoalsTitle => 'Goals & Preferences';

  @override
  String get fitnessQuestionnaireTrainingGoalLabel => 'Primary Training Goal';

  @override
  String get fitnessQuestionnaireTrainingGoalStrength => 'Strength (1-5 reps)';

  @override
  String get fitnessQuestionnaireTrainingGoalHypertrophy =>
      'Hypertrophy (8-12 reps)';

  @override
  String get fitnessQuestionnaireTrainingGoalEndurance =>
      'Endurance (15+ reps)';

  @override
  String get fitnessQuestionnaireInjuryHistoryLabel =>
      'I have a history of training-related injuries';

  @override
  String get fitnessQuestionnaireSuggestionStyleLabel => 'Suggestion Style';

  @override
  String get fitnessQuestionnaireSuggestionStyleConservative =>
      'Conservative (safer)';

  @override
  String get fitnessQuestionnaireSuggestionStyleBalanced =>
      'Balanced (recommended)';

  @override
  String get fitnessQuestionnaireSuggestionStyleAggressive =>
      'Aggressive (experienced)';

  @override
  String get fitnessQuestionnaireReviewTitle => 'Review & Complete';

  @override
  String get fitnessQuestionnaireReviewDescription =>
      'Review your information and complete the setup to start getting weight suggestions.';

  @override
  String get fitnessQuestionnaireComplete => 'Complete Setup';

  @override
  String get fitnessQuestionnaireBackButton => 'Back';

  @override
  String get fitnessQuestionnaireNextButton => 'Next';

  @override
  String get weightSuggestionSuggestedWeight => 'Suggested';

  @override
  String get weightSuggestionUse => 'Use Suggestion';

  @override
  String get weightSuggestionConfidenceExcellent => 'Excellent match';

  @override
  String get weightSuggestionConfidenceGood => 'Good match';

  @override
  String get weightSuggestionConfidenceFair => 'Fair match';

  @override
  String get weightSuggestionConfidenceLow => 'Low confidence';

  @override
  String get weightSuggestionWarningLow =>
      'This suggestion has low confidence. Start conservatively.';

  @override
  String get weightSuggestionNoData =>
      'No suggestion available for this exercise';

  @override
  String get weightSuggestionCompleteQuestionnaire =>
      'Complete fitness profile to get weight suggestions';

  @override
  String get weightSuggestionBasedOn => 'Based on strength standards';

  @override
  String get weightSuggestionViewDetails => 'View Details';

  @override
  String get weightSuggestionDetailsTitle => 'Weight Suggestion Details';

  @override
  String get weightSuggestionDetailsBaseOneRM => 'Estimated 1RM';

  @override
  String get weightSuggestionDetailsIntensityFactor =>
      'Training goal intensity';

  @override
  String get weightSuggestionDetailsAppliedMultipliers => 'Applied adjustments';

  @override
  String get weightSuggestionDetailsNotes => 'Important notes';

  @override
  String get oneRMCalculatorTitle => '1RM Calculator';

  @override
  String get oneRMCalculatorWeight => 'Weight lifted';

  @override
  String get oneRMCalculatorReps => 'Reps completed';

  @override
  String get oneRMCalculatorEstimated => 'Estimated 1RM';

  @override
  String get oneRMCalculatorFormula => 'Using Brzycki formula';

  @override
  String get oneRMCalculatorUse => 'Use This Value';

  @override
  String get step => 'Step';

  @override
  String get ofPreposition => 'of';

  @override
  String get fitnessBenchmarkCalculate => 'Calculate Your Level';

  @override
  String get fitnessBenchmarkUpdate => 'Update Benchmark';

  @override
  String get fitnessBenchmarkLevel => 'Level';

  @override
  String get fitnessBenchmarkDescription =>
      'Get personalized weight suggestions';

  @override
  String get fitnessQuestionnaireFullyRecovered => 'Fully Recovered';

  @override
  String get fitnessQuestionnaireInRehabilitation =>
      'Currently in Rehabilitation';

  @override
  String get fitnessQuestionnaireCurrentPainLevel => 'Current Pain Level';

  @override
  String get fitnessQuestionnaireMonthsHelperText =>
      'Optional - helps validate experience level';

  @override
  String get fitnessQuestionnaireReviewDemographics => 'Demographics';

  @override
  String get fitnessQuestionnaireReviewExperience => 'Experience';

  @override
  String get fitnessQuestionnaireReviewMaxLifts => 'Max Lifts';

  @override
  String get fitnessQuestionnaireReviewGoals => 'Goals';

  @override
  String get fitnessQuestionnaireReviewBodyweight => 'Bodyweight';

  @override
  String get fitnessQuestionnaireReviewAge => 'Age';

  @override
  String get fitnessQuestionnaireReviewSex => 'Sex';

  @override
  String get fitnessQuestionnaireReviewLevel => 'Level';

  @override
  String get fitnessQuestionnaireReviewTraining => 'Training';

  @override
  String get fitnessQuestionnaireReviewMonths => 'months';

  @override
  String get fitnessQuestionnaireReviewBench => 'Bench';

  @override
  String get fitnessQuestionnaireReviewSquat => 'Squat';

  @override
  String get fitnessQuestionnaireReviewDeadlift => 'Deadlift';

  @override
  String get fitnessQuestionnaireReviewOHP => 'OHP';

  @override
  String get fitnessQuestionnaireReviewTrainingGoal => 'Training Goal';

  @override
  String get fitnessQuestionnaireReviewSuggestionStyle => 'Suggestion Style';

  @override
  String get fitnessQuestionnaireReviewSelfAssessment => 'Self-Assessment';

  @override
  String get fitnessQuestionnaireSelfAssessmentTitle =>
      'Self-Assessment Calibration';

  @override
  String get fitnessQuestionnaireSelfAssessmentDescription =>
      'How accurate are you in assessing your abilities?';

  @override
  String get fitnessMedicalClearanceTitle => 'Medical Clearance (PAR-Q+)';

  @override
  String get fitnessMedicalClearanceDescription =>
      'Please answer these health screening questions honestly.';

  @override
  String get fitnessParqHeartCondition =>
      'Has a doctor ever said you have a heart condition?';

  @override
  String get fitnessParqChestPainActive =>
      'Do you feel pain in your chest during physical activity?';

  @override
  String get fitnessParqChestPainRest =>
      'In the past month, have you had chest pain when NOT doing physical activity?';

  @override
  String get fitnessParqDizziness =>
      'Do you lose balance because of dizziness or do you ever lose consciousness?';

  @override
  String get fitnessParqBoneJoint =>
      'Do you have a bone or joint problem that could be made worse by activity?';

  @override
  String get fitnessParqMedication =>
      'Are you currently taking medication for blood pressure or a heart condition?';

  @override
  String get fitnessParqOtherReason =>
      'Do you know of any other reason you should not do physical activity?';

  @override
  String get fitnessAcsmTitle => 'Additional Risk Factors (ACSM)';

  @override
  String get fitnessAcsmAge => 'Age ≥45 (men) or ≥55 (women)';

  @override
  String get fitnessAcsmFamilyHistory =>
      'Family history of heart disease before age 55';

  @override
  String get fitnessAcsmSmoker => 'Current smoker or quit within 6 months';

  @override
  String get fitnessAcsmObese =>
      'BMI ≥30 or waist >102cm (men) / >88cm (women)';

  @override
  String get fitnessAcsmDiabetes => 'Diabetes (Type 1 or 2)';

  @override
  String get fitnessAcsmHighBP =>
      'High blood pressure (≥140/90 or on medication)';

  @override
  String get fitnessValidationWeight => 'Enter a valid weight (40-200 kg)';

  @override
  String get fitnessValidationAge => 'Enter a valid age (13-100)';

  @override
  String get fitnessInjuryHistoryTitle => 'Injury History';

  @override
  String get fitnessInjuryType => 'Injury Type';

  @override
  String get fitnessInjuryBodyRegion => 'Body Region';

  @override
  String get fitnessInjuryMonthsSince => 'Months Since Injury';

  @override
  String get fitnessValidationRequired => 'Required';

  @override
  String get fitnessInjuryTypeHint => 'e.g., Lower back strain';

  @override
  String get dropsetStage1Weight => 'Stage 1 Weight';

  @override
  String dropsetStageNWeight(int stageNumber) {
    return 'Stage $stageNumber Weight';
  }

  @override
  String get previousStageWeight => 'Previous stage';

  @override
  String get detectedEquipmentType => 'Detected equipment';

  @override
  String get barbell => 'Barbell';

  @override
  String get dumbbell => 'Dumbbell';

  @override
  String get barbellRoundingInfo => 'Rounds to 2.5kg';

  @override
  String get dumbbellRoundingInfo => 'Custom increments';

  @override
  String get selectEquipmentType => 'Select Equipment Type';

  @override
  String get selectWeightDrop => 'Select Weight Drop';

  @override
  String get calculatedWeight => 'Calculated Weight';

  @override
  String get dumbbellIncrementQuestion =>
      'What dumbbell increments does your gym have?';

  @override
  String get dumbbellIncrementHalfKg => '0.5kg increments (17.5, 18, 18.5...)';

  @override
  String get dumbbellIncrementOneKg => '1kg increments (17, 18, 19...)';

  @override
  String get dumbbellIncrementTwoKg => '2kg increments (16, 18, 20...)';

  @override
  String get enterInitialWeight => 'Enter Initial Weight';

  @override
  String get confirmOrAdjustWeight => 'Confirm or Adjust Weight';

  @override
  String get appSubtitle => 'Track your fitness journey';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get joinGymBro => 'Join FitLog Pro';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get pleaseEnterEmailFirst => 'Please enter your email first';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent! Check your inbox.';

  @override
  String get restTimer => 'Rest Timer';

  @override
  String get errorDialogTitle => 'Error';

  @override
  String get workoutLoadError => 'An error occurred while loading the workout';

  @override
  String get goHomeButton => 'Go Home';

  @override
  String get createNewTemplate => 'Create New Template';

  @override
  String get saveTemplateComingSoon => 'Save template feature coming soon!';

  @override
  String get saveToFirebase => 'Save to Firebase for reuse';

  @override
  String get useTemplateScreenForImport =>
      'Use the import function in the template screen';

  @override
  String get keepWorkoutActiveTitle => 'Keep Workout Active?';

  @override
  String get workoutPausedMessage =>
      'Workout paused - Continue anytime from Home';

  @override
  String get completeWorkoutTitle => 'Complete Workout';

  @override
  String get completeWorkoutConfirmation =>
      'Are you sure you want to complete this workout?';

  @override
  String get completeButton => 'Complete';

  @override
  String get workoutCompletedSuccess => 'Workout completed! Great job!';

  @override
  String get workoutResumed => 'Workout restored - you can continue training';

  @override
  String get saveAsTemplate => 'Save as Template';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get addExerciseTitle => 'Add Exercise';

  @override
  String get addButton => 'Add';

  @override
  String get supersetTab => 'Superset';

  @override
  String get dropsetTab => 'Dropset';

  @override
  String get restPauseTab => 'Rest-Pause';

  @override
  String get exerciseCategoryLabel => 'Exercise Category';

  @override
  String get setsLabel => 'Sets';

  @override
  String get addSetButton => 'Add Set';

  @override
  String get removeSetTooltip => 'Remove Set';

  @override
  String get weightHint => 'Enter weight';

  @override
  String get repsHint => 'Enter reps';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String exerciseAddedMessage(String exerciseName) {
    return 'Added $exerciseName to workout';
  }

  @override
  String dropsetAddedMessage(String exerciseName) {
    return 'Added $exerciseName Drop Set to workout';
  }

  @override
  String restPauseAddedMessage(String exerciseName) {
    return 'Added $exerciseName Rest-Pause to workout';
  }

  @override
  String supersetAddedMessage(String exerciseName) {
    return 'Added $exerciseName Superset to workout';
  }

  @override
  String get categoryChest => 'Chest';

  @override
  String get categoryBack => 'Back';

  @override
  String get categoryShoulders => 'Shoulders';

  @override
  String get categoryArms => 'Arms';

  @override
  String get categoryLegs => 'Legs';

  @override
  String get categoryAbs => 'Abs';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryOther => 'Other';

  @override
  String exerciseCategorizedSuccess(
    String exerciseName,
    String muscleGroupName,
  ) {
    return '\"$exerciseName\" categorized as $muscleGroupName';
  }

  @override
  String get undo => 'Undo';

  @override
  String get categorizationUndone => 'Categorization removed';

  @override
  String get exerciseEditingComingSoon => 'Exercise editing coming soon!';

  @override
  String get exerciseReplacementComingSoon =>
      'Exercise replacement coming soon!';

  @override
  String get errorUserNotAuthenticated => 'User not authenticated';

  @override
  String get errorEntityValidationFailed => 'Validation failed';

  @override
  String get errorAudioFileNotFound => 'Audio file not found';

  @override
  String get errorAchievementNotFound => 'Achievement not found';

  @override
  String get errorRegistrationFailed => 'Registration failed';

  @override
  String get errorSignInFailed => 'Sign in failed';

  @override
  String errorLoadingWorkout(String error) {
    return 'Error loading workout: $error';
  }

  @override
  String get orSeparator => 'OR';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get backToOptions => 'Back to options';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get featureSmartTimer => 'Smart Timer';

  @override
  String get featureLiveActivities => 'Live Activities';

  @override
  String get featureAppleHealth => 'Apple Health';

  @override
  String get createAccount => 'Create Account';

  @override
  String get startTrackingJourney => 'Start tracking your fitness journey';

  @override
  String get registerQuickly => 'Register Quickly';

  @override
  String get autoAccountCreation =>
      'The system will automatically create your account\nif it\'s your first time logging in';

  @override
  String get orDivider => 'OR';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourName => 'Please enter your name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? ';

  @override
  String get myWorkouts => 'My Workouts';

  @override
  String get predefinedWorkouts => 'Predefined Workouts';

  @override
  String get noCustomTemplates => 'No custom templates';

  @override
  String get noPredefinedWorkouts => 'No predefined workouts';

  @override
  String get predefinedWorkoutsComingSoon => 'Predefined workouts coming soon!';

  @override
  String get customBadge => 'Custom';

  @override
  String get keepWorkoutActive => 'Keep Workout Active?';

  @override
  String get keepWorkoutActiveMessage =>
      'Do you want to go back to Home and keep your workout running in the background?\\n\\nYou can return to continue your workout anytime.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get workoutPausedContinue =>
      'Workout paused - Continue anytime from Home';

  @override
  String deleteTemplateConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deleteTemplateWarning => 'This action cannot be undone.';

  @override
  String get timerRest => 'Rest Timer';

  @override
  String get rpeTimerMore => 'RPE, Timer, and more';

  @override
  String get completeWorkoutConfirm =>
      'Are you sure you want to complete this workout?';

  @override
  String get error => 'Error';

  @override
  String get goHome => 'Go Home';

  @override
  String errorLoading(String error) {
    return 'Error loading: $error';
  }

  @override
  String get jsonFormat => 'JSON Format';

  @override
  String get pasteJsonHere => 'Paste your workout template JSON here';

  @override
  String get jsonPlaceholder => 'Example: name, description, exercises array';

  @override
  String get useImportFunction =>
      'Use the import function in the template screen';

  @override
  String get saveAsTemplateTitle => 'Save as Template';

  @override
  String get templateName => 'Template Name';

  @override
  String get templateNameHint => 'E.g. Push Day, Upper Body...';

  @override
  String get descriptionHint => 'Briefly describe this workout...';

  @override
  String get templateSyncInfo =>
      'The template will be saved to Firebase and available on all your devices';

  @override
  String get enterTemplateName => 'Enter a template name';

  @override
  String get savingToFirebase => 'Saving to Firebase...';

  @override
  String templateSavedSuccess(String name) {
    return 'Template \"$name\" saved successfully!';
  }

  @override
  String get view => 'View';

  @override
  String templateLimitReached(int max) {
    return 'You have reached the limit of $max private templates.';
  }

  @override
  String get deleteOrUpgrade =>
      'Delete an existing template or upgrade to Premium for more space.';

  @override
  String templatesRemaining(int remaining) {
    return 'Only $remaining templates remaining in Free plan';
  }

  @override
  String get customTemplate => 'Custom template';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get quotaExceeded => 'Limit Reached';

  @override
  String get deleteExistingOrUpgrade =>
      'Delete existing templates or upgrade to Premium.';

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get pdfSharedSuccess => 'PDF shared successfully!';

  @override
  String sharingError(String error) {
    return 'Sharing error: $error';
  }

  @override
  String get preparingPrint => 'Preparing print...';

  @override
  String printError(String error) {
    return 'Print error: $error';
  }

  @override
  String get templateUseFunctionComingSoon =>
      'Use the template screen to create new templates';

  @override
  String get saveTemplateFunctionComingSoon =>
      'Save template function coming soon!';

  @override
  String get workoutStartedQuick => 'Workout started quickly';

  @override
  String get quickWorkoutName => 'Quick Workout';

  @override
  String get startWorkoutTitle => 'Start Workout';

  @override
  String get startNowAction => 'Start Now';

  @override
  String get startExercise => 'Start Exercise';

  @override
  String get modifyTemplate => 'Modify Template';

  @override
  String get addOrRemoveExercises => 'Add or remove exercises';

  @override
  String get deleteTemplateAction => 'Delete Template';

  @override
  String get removePermanently => 'Remove permanently';

  @override
  String dropsetStages(int count) {
    return '$count stages';
  }

  @override
  String dropsetStage(int number) {
    return 'Stage $number';
  }

  @override
  String get dropsetGetReady => 'Get ready to drop the weight!';

  @override
  String get dropsetNoRest => 'No rest! Reduce weight and go again!';

  @override
  String get dropsetLastStage => 'Last stage! Give it everything!';

  @override
  String dropsetReduceWeightNow(String weight) {
    return 'Reduce weight to $weight kg NOW!';
  }

  @override
  String get dropsetCompleted => 'DropSet completed! 💪';

  @override
  String get completeDropset => 'Complete DropSet';

  @override
  String completeStage(int number) {
    return 'Complete Stage $number';
  }

  @override
  String get cancelDropset => 'Cancel DropSet?';

  @override
  String get cancelDropsetMessage =>
      'Your progress will not be saved. Are you sure?';

  @override
  String get executeDropset => 'Execute DropSet';

  @override
  String get executeRestPause => 'Execute Rest-Pause';

  @override
  String get keepWorkoutActiveContent =>
      'Do you want to go back to Home and keep your workout running in the background?\\n\\nYou can return to continue your workout anytime.';

  @override
  String deleteTemplateQuestion(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cannotUndo => 'This action cannot be undone.';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String templateQuotaLimit(int max) {
    return 'You have reached the limit of $max private templates.';
  }

  @override
  String get deleteExistingTemplateOrUpgrade =>
      'Delete an existing template or upgrade to Premium for more space.';

  @override
  String templatesRemainingWarning(int remaining) {
    return 'Only $remaining templates remaining in Free plan';
  }

  @override
  String get customTemplateDescription => 'Custom template';

  @override
  String templateSavedSuccessfully(String name) {
    return 'Template \"$name\" saved successfully!';
  }

  @override
  String templateDeletedSuccessfully(String name) {
    return 'Template \"$name\" deleted';
  }

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get pdfSharedSuccessfully => 'PDF shared successfully!';

  @override
  String sharingErrorMessage(String error) {
    return 'Sharing error: $error';
  }

  @override
  String printErrorMessage(String error) {
    return 'Print error: $error';
  }

  @override
  String savingErrorMessage(String error) {
    return 'Error saving: $error';
  }

  @override
  String get useImportFunctionInTemplateScreen =>
      'Use the import function in the template screen';

  @override
  String get deleteExistingOrUpgradeToPremium =>
      'Delete existing templates or upgrade to Premium.';

  @override
  String get removePermanentlyAction => 'Remove permanently';

  @override
  String get startWorkoutAction => 'Start Workout';

  @override
  String get startWorkoutDescription => 'Start immediately';

  @override
  String get templateSyncInformation =>
      'The template will be saved to Firebase and available on all your devices';

  @override
  String get tabSingle => 'Single';

  @override
  String get tabAdvanced => 'Advanced';

  @override
  String get tabSuperset => 'Superset';

  @override
  String get tabDropSet => 'DropSet';

  @override
  String get tabRestPause => 'Rest-Pause';

  @override
  String get dropSetInfoCard =>
      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.';

  @override
  String get restPauseInfoCard =>
      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.';

  @override
  String get exerciseNameHintBicepCurl => 'e.g., Bicep Curl Drop Set';

  @override
  String get exerciseNameHintBenchPress => 'e.g., Bench Press Rest-Pause';

  @override
  String get dropSetStagesTitle => 'Drop Set Stages';

  @override
  String get stageHeavy => 'Stage 1 (Heavy)';

  @override
  String get stageMedium => 'Stage 2 (Medium)';

  @override
  String get stageLight => 'Stage 3 (Light)';

  @override
  String get addStageButton => 'Add Stage';

  @override
  String get notesHintWeightDrops => 'Weight drops, rest between stages, etc.';

  @override
  String get notesHintFormCues => 'Form cues, progression strategy, etc.';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get targetRepsLabel => 'Target Reps';

  @override
  String get restPeriodSecondsLabel => 'Rest Period (seconds)';

  @override
  String get restPeriodSecondsHint => '10-15 seconds typical';

  @override
  String get maxRestPauseSetsLabel => 'Max Rest-Pause Sets';

  @override
  String get maxRestPauseSetsHint => '3-4 typical';

  @override
  String get addSetLabel => 'Add Set';

  @override
  String get weightHintKg => 'Weight (kg)';

  @override
  String get repsHintLabel => 'Reps';

  @override
  String get customExercisePrompt =>
      'Can\'t find your exercise? Create a custom one';

  @override
  String get customExerciseDetails => 'Enter custom exercise details:';

  @override
  String get focusLabel => 'Focus';

  @override
  String exerciseAddedToWorkout(String exerciseName) {
    return 'Added $exerciseName to workout';
  }

  @override
  String exerciseAddedDropSet(String exerciseName) {
    return 'Added $exerciseName Drop Set to workout';
  }

  @override
  String exerciseAddedRestPause(String exerciseName) {
    return 'Added $exerciseName Rest-Pause to workout';
  }

  @override
  String get quickTimerOptions => 'Quick Timer Options';

  @override
  String exerciseUpdated(String exerciseName) {
    return 'Exercise \"$exerciseName\" updated';
  }

  @override
  String get timerLabel => 'Timer';

  @override
  String get errorLoadingEditor => 'Error loading exercise editor';

  @override
  String get errorOpeningEditor =>
      'Error opening exercise editor. Please try again.';

  @override
  String get errorUnableToEdit => 'Error: Unable to edit this exercise';

  @override
  String get errorUpdatingExercise =>
      'Error updating exercise. Please try again.';

  @override
  String exerciseNameCannotBeEmpty(String exerciseName) {
    return '$exerciseName cannot be empty';
  }

  @override
  String get invalidRestTimeError =>
      'Please enter a valid rest time (1-3600 seconds)';

  @override
  String get invalidApreBaseWeight => 'Please enter a valid APRE base weight';

  @override
  String get notesSavedMessage => 'Notes saved';

  @override
  String exerciseCompletedTapToExpand(String exerciseName) {
    return '$exerciseName completed! Tap to expand';
  }

  @override
  String get expandLabel => 'Expand';

  @override
  String get settingsNotLoggedIn => 'Not logged in';

  @override
  String get settingsLoading => 'Loading...';

  @override
  String get settingsErrorLoadingUser => 'Error loading user';

  @override
  String get settingsGymBroUser => 'FitLog Pro User';

  @override
  String get settingsNoEmail => 'No email';

  @override
  String settingsLastUpdated(Object date) {
    return 'Last updated: $date';
  }

  @override
  String get settingsUpdateProfile => 'Update Profile';

  @override
  String get settingsAccentColor => 'Accent Color';

  @override
  String get settingsFontSize => 'Font Size';

  @override
  String get settingsFontSizeSmall => 'Small';

  @override
  String get settingsFontSizeNormal => 'Normal';

  @override
  String get settingsFontSizeLarge => 'Large';

  @override
  String get settingsWorkoutTitle => 'Workout';

  @override
  String get settingsAutoStartTimer => 'Auto-start Timer';

  @override
  String get settingsAutoStartTimerDesc =>
      'Start rest timer after completing set';

  @override
  String get settingsDefaultRestTime => 'Default Rest Time';

  @override
  String get settingsAdvancedTechniques => 'Advanced Techniques';

  @override
  String get settingsAdvancedTechniquesDesc =>
      'Show drop sets, supersets, etc.';

  @override
  String get settingsUnitsLanguage => 'Units & Language';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsWeightUnits => 'Weight Units';

  @override
  String get settingsIOSFeatures => 'iOS Features';

  @override
  String get settingsLiveActivities => 'Live Activities';

  @override
  String get settingsLiveActivitiesDesc =>
      'Show timer on lock screen & Dynamic Island';

  @override
  String get settingsHealthAppSync => 'Health App Sync';

  @override
  String get settingsHealthAppSyncDesc => 'Sync workouts to Apple Health';

  @override
  String get settingsAudioFeedback => 'Audio & Feedback';

  @override
  String get settingsSoundEffects => 'Sound Effects';

  @override
  String get settingsSoundEffectsDesc => 'Play sounds for timer and completion';

  @override
  String get settingsVibrations => 'Vibrations';

  @override
  String get settingsVibrationsDesc => 'Haptic feedback for interactions';

  @override
  String get settingsTestSounds => 'Test Sounds';

  @override
  String get settingsAdvancedTitle => 'Advanced';

  @override
  String get settingsExportSettings => 'Export Settings';

  @override
  String get settingsImportSettings => 'Import Settings';

  @override
  String get settingsResetTimerPosition => 'Reset Timer Position';

  @override
  String get settingsResetTimerPositionDesc =>
      'Reset draggable timer to default position';

  @override
  String get settingsDataMigrationCompleted =>
      'Migration completed or not needed';

  @override
  String get settingsMigrationHasData =>
      'You have data to migrate from previous version';

  @override
  String get settingsMigrationAvailable => 'Available';

  @override
  String get settingsBetaMode => 'Beta Mode';

  @override
  String get settingsBetaModeEnabled =>
      'Beta Mode enabled - All premium features unlocked!';

  @override
  String get settingsBetaModeDisabled => 'Beta Mode disabled';

  @override
  String get settingsBetaModeLabel => 'BETA';

  @override
  String get settingsBetaModeActivated =>
      '🧪 Beta Mode activated - All premium features unlocked!';

  @override
  String get settingsBetaModeDeactivated => 'Beta Mode deactivated';

  @override
  String get settingsResetToDefaults => 'Reset to Defaults';

  @override
  String get settingsAccountActionsTitle => 'Account Actions';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsChooseLanguage => 'Choose Language';

  @override
  String get settingsEnglishUS => 'English (US)';

  @override
  String get settingsItalianIT => 'Italian (IT)';

  @override
  String get settingsWeightUnitsTitle => 'Weight Units';

  @override
  String get settingsKilogramsKg => 'Kilograms (kg)';

  @override
  String get settingsMetricSystem => 'Metric system';

  @override
  String get settingsPoundsLbs => 'Pounds (lbs)';

  @override
  String get settingsImperialSystem => 'Imperial system';

  @override
  String get settingsResetTimerPositionTitle => 'Reset Timer Position';

  @override
  String get settingsResetTimerPositionMessage =>
      'This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.';

  @override
  String get settingsResetPosition => 'Reset Position';

  @override
  String get settingsTimerPositionReset => 'Timer position reset to default';

  @override
  String get settingsResetSettingsTitle => 'Reset Settings';

  @override
  String get settingsResetSettingsMessage =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get settingsResetSettingsButton => 'Reset';

  @override
  String get settingsSignOutTitle => 'Sign Out';

  @override
  String get settingsSignOutMessage => 'Are you sure you want to sign out?';

  @override
  String get settingsExportComingSoon => 'Export functionality coming soon';

  @override
  String get settingsImportComingSoon => 'Import functionality coming soon';

  @override
  String get templateSearchPlaceholder => 'Search templates...';

  @override
  String get templateDebugNotSeeing =>
      '❌ WorkoutTemplatesScreen - Not seeing my templates here';

  @override
  String get templateTemplatesCount => 'Templates';

  @override
  String get templateNoTemplatesYet => 'No popular templates yet';

  @override
  String get templateMostUsedTemplatesWillAppear =>
      'Most used templates will appear here';

  @override
  String get templateNoCustomTemplates => 'No custom templates';

  @override
  String get templateCreateFirstTemplate => 'Create your first custom template';

  @override
  String get templateNoTemplatesFound => 'No templates found';

  @override
  String get templateSyncStateTitle => 'Sync Status';

  @override
  String get templateSyncStatus => 'Status';

  @override
  String get templateLastSync => 'Last sync';

  @override
  String get templateTotalTemplates => 'Total templates';

  @override
  String get templateOfflineChanges =>
      'You have offline changes that will be synced on next connection.';

  @override
  String get templateSyncNow => 'Sync Now';

  @override
  String get templateSyncCompleted => 'Sync completed';

  @override
  String get templateDeleteTitle => 'Delete Template';

  @override
  String templateDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get templateDeleteButton => 'Delete';

  @override
  String get templateDeleteError => 'Error deleting template';

  @override
  String get templateStartError => 'Error starting workout';

  @override
  String get templateDay => 'Day';

  @override
  String get copyPreviousSet => 'Copy Previous Set';

  @override
  String get routineWeeklyRoutine => 'Weekly Routine';

  @override
  String get routineMyRoutine => 'My Routine';

  @override
  String get routineAddToRoutine => 'Add to Routine';

  @override
  String get routineSelectDay => 'Select Day';

  @override
  String get routineSelectDaySubtitle =>
      'Choose which day(s) to schedule this workout';

  @override
  String get routineMonday => 'Monday';

  @override
  String get routineTuesday => 'Tuesday';

  @override
  String get routineWednesday => 'Wednesday';

  @override
  String get routineThursday => 'Thursday';

  @override
  String get routineFriday => 'Friday';

  @override
  String get routineSaturday => 'Saturday';

  @override
  String get routineSunday => 'Sunday';

  @override
  String get routineDayAlreadyScheduled => 'This day already has a template';

  @override
  String get routineReplaceTemplate => 'Replace template?';

  @override
  String routineReplaceTemplateMessage(
    String day,
    String currentTemplate,
    String newTemplate,
  ) {
    return 'Day $day already has \"$currentTemplate\" scheduled. Replace it with \"$newTemplate\"?';
  }

  @override
  String get routineNoTemplateScheduled => 'No template scheduled';

  @override
  String get routineRestDay => 'Rest Day';

  @override
  String get routineQuickStart => 'Quick Start';

  @override
  String routineTemplateAddedSuccess(String day) {
    return 'Template added to $day';
  }

  @override
  String get routineNoWorkoutsScheduled => 'No workouts scheduled yet';

  @override
  String get routineStartScheduling => 'Start scheduling your weekly workouts';

  @override
  String get routineTapToAdd => 'Tap a template and select \'Add to Routine\'';

  @override
  String get routineChangeTemplate => 'Change Workout Template';

  @override
  String get routineRemoveFromDay => 'Remove from day';

  @override
  String get routineClearAllDays => 'Clear All Days';

  @override
  String get routineClearAllDaysConfirm =>
      'Are you sure you want to clear all scheduled templates?';

  @override
  String routineWorkoutsScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'workouts',
      one: 'workout',
    );
    return '$count $_temp0 scheduled';
  }

  @override
  String routineRestDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rest days',
      one: 'rest day',
    );
    return '$count $_temp0';
  }

  @override
  String routineExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'exercises',
      one: 'exercise',
    );
    return '$count $_temp0';
  }

  @override
  String get routineSaveChanges => 'Save Changes';

  @override
  String get routineDiscardChanges => 'Discard Changes';

  @override
  String get routineViewAndManage => 'View and manage your routine';

  @override
  String get feedbackQuestion => 'Rate your experience with this step';

  @override
  String get feedbackHelpful => 'Helpful';

  @override
  String get feedbackNotHelpful => 'Not Helpful';

  @override
  String get feedbackThankYou => 'Thanks for your feedback!';

  @override
  String get feedbackSubmitted => 'Feedback submitted';

  @override
  String get feedbackAlreadyGiven => 'You\'ve already rated this insight';

  @override
  String get dataQualityWarning => '⚠️ Based on questionable data';

  @override
  String get dataQualityLow => 'Low data quality';

  @override
  String anomaliesDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count data issues detected',
      one: '1 data issue detected',
    );
    return '$_temp0';
  }

  @override
  String get viewAnomalies => 'View data issues';

  @override
  String get anomalyImpossibleWeight => 'Impossible weight detected';

  @override
  String get anomalyExtremeWeightJump => 'Extreme weight jump detected';

  @override
  String get anomalyNegativeValues => 'Negative values detected';

  @override
  String get anomalyFutureDate => 'Future date detected';

  @override
  String get correctData => 'Correct data';

  @override
  String get dismissAnomaly => 'Dismiss';

  @override
  String get myFeedback => 'My Feedback';

  @override
  String get feedbackHistory => 'Feedback History';

  @override
  String get viewMyFeedback => 'View My Feedback';

  @override
  String get noFeedbackYet => 'No feedback yet';

  @override
  String get startRatingInsights =>
      'Start rating insights to help improve AI Coach recommendations';

  @override
  String get ratedHelpful => 'Rated helpful';

  @override
  String get ratedNotHelpful => 'Rated not helpful';

  @override
  String get feedbackOn => 'Feedback on';

  @override
  String get routineEditorTitle => 'Create Routine';

  @override
  String get routineEditorEditTitle => 'Edit Routine';

  @override
  String get routineStepInfo => 'Info';

  @override
  String get routineStepPattern => 'Pattern';

  @override
  String get routineStepReview => 'Review';

  @override
  String get routinePatternChooseTitle => 'Choose Your Pattern';

  @override
  String get routinePatternChooseDescription =>
      'Select a training split that fits your goals';

  @override
  String get routinePatternPreset => 'Preset';

  @override
  String get routinePatternCustom => 'Custom';

  @override
  String get routinePatternPopular => 'Popular Patterns';

  @override
  String routinePatternWorkouts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String routinePatternRest(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rest',
      one: '1 rest',
    );
    return '$_temp0';
  }

  @override
  String get customPatternBuilderTitle => 'Custom Pattern Builder';

  @override
  String get customPatternBuilderDescription =>
      'Build your own workout schedule';

  @override
  String customPatternYourSchedule(int count) {
    return 'Your Schedule ($count days)';
  }

  @override
  String get customPatternAddWorkout => 'Add Workout';

  @override
  String get customPatternAddRest => 'Add Rest Day';

  @override
  String get customPatternEmptyWarning =>
      'Add at least one workout day to continue';

  @override
  String get customPatternAddWorkoutDialogTitle => 'Add Workout Day';

  @override
  String get customPatternWorkoutNameLabel => 'Workout Name';

  @override
  String get customPatternWorkoutNameHint =>
      'e.g., Push, Pull, Legs, Upper, Lower';

  @override
  String customPatternDayNumber(int number) {
    return 'Day $number';
  }

  @override
  String get customPatternRestDay => 'Rest Day';

  @override
  String get customPatternRemoveDay => 'Remove day';

  @override
  String get customPatternSelectTemplate => 'Select Workout Template';

  @override
  String get customPatternNoTemplates =>
      'No workout templates available. Create templates first.';

  @override
  String get routineButtonBack => 'Back';

  @override
  String get routineButtonNext => 'Next';

  @override
  String get routineButtonCreate => 'Create Routine';

  @override
  String get routineErrorIncomplete => 'Please complete all required fields';

  @override
  String get routineErrorNoPattern => 'Please select a pattern';

  @override
  String routineSuccessCreated(String name) {
    return 'Routine \"$name\" created successfully! 🎉';
  }

  @override
  String get routineErrorCreateFailed => 'Failed to create routine';

  @override
  String get routineDiscardTitle => 'Discard changes?';

  @override
  String get routineDiscardMessage =>
      'Your progress will be lost if you go back now.';

  @override
  String get errorLoadingImage => 'Error loading image';

  @override
  String get tapAnywhereToClose => 'Tap anywhere to close';

  @override
  String get routineOnboardingSkip => 'Skip';

  @override
  String get routineOnboardingBack => 'Back';

  @override
  String get routineOnboardingNext => 'Next';

  @override
  String get routineOnboardingGetStarted => 'Get Started! 🚀';

  @override
  String get routineOnboardingWelcomeTitle => 'Welcome to\nRoutine Center! 🏋️';

  @override
  String get routineOnboardingWelcomeSubtitle =>
      'Your personal training plan manager.\nLet\'s learn how to use it!';

  @override
  String get routineOnboardingWhatIsTitle => 'What is a Routine? 🤔';

  @override
  String get routineOnboardingWhatIsDescription =>
      'A routine is a structured training plan with:';

  @override
  String get routineOnboardingFeatureScheduled => 'Scheduled Workout Days';

  @override
  String get routineOnboardingFeatureScheduledDesc =>
      'Plan your training weeks in advance';

  @override
  String get routineOnboardingFeatureTemplates => 'Specific Workout Templates';

  @override
  String get routineOnboardingFeatureTemplatesDesc =>
      'Assign exercises to each day';

  @override
  String get routineOnboardingFeatureProgression => 'Automatic Progression';

  @override
  String get routineOnboardingFeatureProgressionDesc =>
      'Your plan repeats automatically';

  @override
  String get routineOnboardingFeatureTracking => 'Progress Tracking';

  @override
  String get routineOnboardingFeatureTrackingDesc =>
      'See your consistency over time';

  @override
  String get routineOnboardingHowItWorksTitle => 'How It Works ⚙️';

  @override
  String get routineOnboardingStep1Title => 'Create Your Routine';

  @override
  String get routineOnboardingStep1Desc =>
      'Name it and choose training pattern\n(e.g., Push/Pull/Legs)';

  @override
  String get routineOnboardingStep2Title => 'Assign Workouts';

  @override
  String get routineOnboardingStep2Desc =>
      'Select workout templates for each training day';

  @override
  String get routineOnboardingStep3Title => 'Follow & Track';

  @override
  String get routineOnboardingStep3Desc =>
      'Complete workouts and watch your progress grow!';

  @override
  String get routineOnboardingBenefitsTitle => 'Why Use Routines? 💪';

  @override
  String get routineOnboardingBenefit1Title => 'Stay Consistent';

  @override
  String get routineOnboardingBenefit1Desc =>
      'No more \"what should I train today?\"';

  @override
  String get routineOnboardingBenefit2Title => 'See Progress';

  @override
  String get routineOnboardingBenefit2Desc =>
      'Track completion rate and streaks';

  @override
  String get routineOnboardingBenefit3Title => 'Smart Recovery';

  @override
  String get routineOnboardingBenefit3Desc =>
      'Miss a workout? Reschedule it easily';

  @override
  String get routineOnboardingReadyCTA => 'Ready to create your first routine?';

  @override
  String get routineCenter => 'Routine Center';

  @override
  String get routineCenterDescription =>
      'Multi-period routines with smart tracking';

  @override
  String get routineBasicInfoTitle => 'Basic Information';

  @override
  String get routineBasicInfoSubtitle =>
      'Set up the foundation of your routine';

  @override
  String get routineNameLabel => 'Routine Name *';

  @override
  String get routineNameHint => 'e.g., Summer Shred 2025';

  @override
  String get routineNameRequired => 'Please enter a name';

  @override
  String get routineNameMinLength => 'Name must be at least 3 characters';

  @override
  String get routineDescriptionLabel => 'Description (Optional)';

  @override
  String get routineDescriptionHint => 'Add notes about this routine...';

  @override
  String get routineTypeLabel => 'Routine Type';

  @override
  String get routineTypeWeekly => 'Weekly';

  @override
  String get routineTypeWeeklyDuration => '7 days';

  @override
  String get routineTypeMonthly => 'Monthly';

  @override
  String get routineTypeMonthlyDuration => '30 days';

  @override
  String get routineTypeBimonthly => 'Bimonthly';

  @override
  String get routineTypeBimonthlyDuration => '60 days';

  @override
  String get routineTypeSemester => 'Semester';

  @override
  String get routineTypeSemesterDuration => '6 months';

  @override
  String get routineTypeCustom => 'Custom';

  @override
  String get routineTypeCustomDuration => 'Any duration';

  @override
  String get routineDurationLabel => 'Duration';

  @override
  String get routineStartDateLabel => 'Start Date';

  @override
  String get routineEndDateLabel => 'End Date';

  @override
  String routineDurationWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String routineDurationDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String routineDurationInfo(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get routinePatternOneWorkoutOneRest => '1 Workout + 1 Rest';

  @override
  String get routinePatternOneWorkoutOneRestDesc =>
      '1 training day followed by 1 rest day';

  @override
  String get routinePatternTwoWorkoutsOneRest => '2 Workouts + 1 Rest';

  @override
  String get routinePatternTwoWorkoutsOneRestDesc =>
      '2 training days followed by 1 rest day';

  @override
  String get routinePatternThreeWorkoutsOneRest => '3 Workouts + 1 Rest';

  @override
  String get routinePatternThreeWorkoutsOneRestDesc =>
      '3 training days followed by 1 rest day';

  @override
  String get routinePatternThreeWorkoutsTwoRest => '3 Workouts + 2 Rest';

  @override
  String get routinePatternThreeWorkoutsTwoRestDesc =>
      '3 training days with 2 rest days per week';

  @override
  String get routinePatternFourWorkoutsOneRest => '4 Workouts + 1 Rest';

  @override
  String get routinePatternFourWorkoutsOneRestDesc =>
      '4 training days followed by 1 rest day';

  @override
  String get routinePatternFourWorkoutsThreeRest => '4 Workouts + 3 Rest';

  @override
  String get routinePatternFourWorkoutsThreeRestDesc =>
      '4 training days with 3 rest days per week';

  @override
  String get routinePatternFiveWorkoutsTwoRest => '5 Workouts + 2 Rest';

  @override
  String get routinePatternFiveWorkoutsTwoRestDesc =>
      '5 training days followed by 2 rest days';

  @override
  String get routinePatternSixWorkoutsOneRest => '6 Workouts + 1 Rest';

  @override
  String get routinePatternSixWorkoutsOneRestDesc =>
      '6 training days followed by 1 rest day';

  @override
  String get routineCalendarPreview => 'Calendar Preview';

  @override
  String get routineCalendarPreviewSubtitle =>
      'How your pattern looks on the calendar';

  @override
  String routineAndMoreDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '... and $count more $_temp0';
  }

  @override
  String routineTotalWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'workouts',
      one: 'workout',
    );
    return 'Total: $count $_temp0';
  }

  @override
  String routineTotalRestDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rest days',
      one: 'rest day',
    );
    return 'Total: $count $_temp0';
  }

  @override
  String get routineWorkoutDayLabel => 'Workout Days';

  @override
  String get routineRestDayLabel => 'Rest Days';

  @override
  String get routineTotalDaysLabel => 'Total Days';

  @override
  String get routineWeekdayMonday => 'Monday';

  @override
  String get routineWeekdayTuesday => 'Tuesday';

  @override
  String get routineWeekdayWednesday => 'Wednesday';

  @override
  String get routineWeekdayThursday => 'Thursday';

  @override
  String get routineWeekdayFriday => 'Friday';

  @override
  String get routineWeekdaySaturday => 'Saturday';

  @override
  String get routineWeekdaySunday => 'Sunday';

  @override
  String routineWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count workout$_temp0';
  }

  @override
  String routineRestCount(int count) {
    return '$count rest';
  }

  @override
  String get routineRotationTitle => 'Rotation Order';

  @override
  String get routineRotationSubtitle =>
      'Drag to reorder how templates will rotate across your workout days';

  @override
  String routineTemplatesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count template$_temp0 selected';
  }

  @override
  String get routineDistributionPreview => 'Distribution Preview';

  @override
  String routineFirstDaysPreview(int shown, int total) {
    return 'First $shown days (total: $total days)';
  }

  @override
  String routineMoreDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '... and $count more $_temp0';
  }

  @override
  String get routineNoTemplatesSelected => 'No Templates Selected';

  @override
  String get routineNoTemplatesMessage =>
      'Go back to the previous step and select at least one workout template';

  @override
  String get routineNoPatternSelected => 'No pattern selected';

  @override
  String routineErrorLoading(String error) {
    return 'Error: $error';
  }

  @override
  String get routineSelectionTitle => 'Select Workout Templates';

  @override
  String get routineSelectionSubtitle =>
      'Choose templates to rotate automatically across workout days';

  @override
  String get routineAvailableTemplates => 'Available Templates';

  @override
  String routineSelected(int count) {
    return '$count selected';
  }

  @override
  String get routineNextStepInfo =>
      'In the next step, you\'ll arrange the order in which these templates rotate';

  @override
  String get routineNoTemplatesYet => 'No Workout Templates Yet';

  @override
  String get routineNeedTemplatesMessage =>
      'You need workout templates to create a routine.\nChoose one of the options below to continue.';

  @override
  String get routineCreateTemplatesFirst =>
      'Before creating a routine, you need to create workout templates with exercises first.';

  @override
  String get routineWorkflowTitle => 'How it works';

  @override
  String get routineWorkflowStep1 =>
      'Go to \'My Templates\' and create workout templates with exercises';

  @override
  String get routineWorkflowStep2 =>
      'Return here and select your templates for the routine';

  @override
  String get routineWorkflowStep3 =>
      'Configure rotation and complete your routine setup';

  @override
  String get routinePopularTemplates => 'Popular Templates';

  @override
  String get routinePopularTemplatesDesc => 'Start with proven workout plans';

  @override
  String get routineImportPopularTemplates => 'Import Popular Templates';

  @override
  String get routineCustomTemplate => 'Custom Template';

  @override
  String get routineCustomTemplateDesc => 'Design your own workout plan';

  @override
  String get routineCreateFirstTemplate => 'Create First Template';

  @override
  String get routineNavigatingToCreator =>
      'Navigating to template creator... 🏗️';

  @override
  String get routineSelectTemplatesDialog =>
      'Select the templates you want to import';

  @override
  String get routineSelectTemplatesButton => 'Select templates';

  @override
  String routineImportCount(int count) {
    return 'Import ($count)';
  }

  @override
  String get routineOr => 'OR';

  @override
  String get routineErrorLoadingTemplates => 'Error loading templates';

  @override
  String routineSuccessCreatedInactive(String name) {
    return 'Routine \"$name\" created! Go to Routine Center to activate it.';
  }

  @override
  String get routineAnalyticsNoActiveRoutine => 'No Active Routine';

  @override
  String get routineAnalyticsNoActiveRoutineDesc =>
      'Create and activate a routine to see analytics here';

  @override
  String get routineAnalyticsCreateRoutine => 'Create Routine';

  @override
  String get routineAnalyticsErrorLoading => 'Error Loading Analytics';

  @override
  String get routineAnalyticsActiveRoutine => 'Active Routine Analytics';

  @override
  String get routineAnalyticsPerformanceMetrics => 'Performance Metrics';

  @override
  String get routineAnalyticsAdherence => 'Adherence';

  @override
  String get routineAnalyticsSkipRate => 'Skip Rate';

  @override
  String get routineAnalyticsRecovery => 'Recovery';

  @override
  String get routineAnalyticsAvgGap => 'Avg Gap';

  @override
  String get routineAnalyticsDays => 'days';

  @override
  String get routineAnalyticsSkipped => 'skipped';

  @override
  String get routineAnalyticsRecovered => 'recovered';

  @override
  String get routineAnalyticsBetweenWorkouts => 'between workouts';

  @override
  String get routineAnalyticsCurrentStreak => 'Current Streak';

  @override
  String get routineAnalyticsBestStreak => 'Best Streak';

  @override
  String get routineAnalyticsInsights => 'Insights';

  @override
  String get routineAnalyticsTemplateDistribution => 'Template Distribution';

  @override
  String get routineAnalyticsWeeklyPattern => 'Weekly Pattern';

  @override
  String get routineAnalyticsWeeklyTrend => 'Weekly Adherence Trend';

  @override
  String get routineAnalyticsChartComingSoon =>
      'Chart visualization coming soon';

  @override
  String get routine => 'Routine';

  @override
  String get feedbackPrompt => 'How was this step?';

  @override
  String get feedbackPoor => 'Poor';

  @override
  String get feedbackExcellent => 'Excellent';

  @override
  String get staleProfileTitle => 'Update Your Fitness Profile';

  @override
  String staleProfileSubtitle1Month(int days) {
    return 'Your profile hasn\'t been updated in $days days. Update it for more accurate suggestions!';
  }

  @override
  String staleProfileSubtitleMonths(int months) {
    return 'Your profile is $months months old. Time to update for better suggestions!';
  }

  @override
  String staleProfileSubtitleManyMonths(int months) {
    return 'Your profile hasn\'t been updated in $months months! Update now for accurate suggestions.';
  }

  @override
  String get staleProfileUpdateButton => 'Update';

  @override
  String get exerciseProgress => 'Exercise Progress';

  @override
  String get trackExerciseGrowth => 'Track your exercise gains';

  @override
  String get exerciseProgressTitle => 'Exercise Progress';

  @override
  String get searchExercisesPlaceholder => 'Search exercises...';

  @override
  String get weightProgression => 'Weight Progression';

  @override
  String get repsProgression => 'Reps Progression';

  @override
  String get effortProgression => 'Effort Progression';

  @override
  String get personalRecord => 'Personal Record';

  @override
  String get averageWeight => 'Avg Weight';

  @override
  String get averageRPE => 'Avg RPE';

  @override
  String get totalSessions => 'Total Sessions';

  @override
  String get exerciseStats => 'Exercise Statistics';

  @override
  String get progressionCharts => 'Progression Charts';

  @override
  String get noExercisesFoundDesc =>
      'Complete a workout to see your exercise progress';

  @override
  String get avgReps => 'Avg Reps';

  @override
  String get lastWorkout => 'Last Workout';

  @override
  String get viewProgress => 'View Progress';

  @override
  String get sessionHistory => 'Session History';

  @override
  String get improving => 'Improving';

  @override
  String get declining => 'Declining';

  @override
  String get stable => 'Stable';

  @override
  String get periodSelectorLabel => 'Time Period';

  @override
  String get combinedView => 'Combined';

  @override
  String get separatedView => 'Separated';

  @override
  String get combinedChart => 'Combined Progress';

  @override
  String get tapToToggle => 'Tap to show/hide';

  @override
  String get effort => 'Effort';

  @override
  String get weightSettings => 'Weight Settings';

  @override
  String get errorLoadingSettings => 'Error Loading Settings';

  @override
  String get quickIncrements => 'Quick Increments';

  @override
  String get quickIncrementsDescription =>
      'Select your default weight increment for quick +/- buttons';

  @override
  String get customIncrement => 'Custom Increment';

  @override
  String get customIncrementDescription =>
      'Set a custom weight increment for precise adjustments';

  @override
  String get plateCalculator => 'Plate Calculator';

  @override
  String get plateCalculatorDescription =>
      'Calculate which plates to load on the bar';

  @override
  String get availablePlates => 'Available Plates';

  @override
  String get availablePlatesDescription => 'Plates available in your gym';

  @override
  String get useCustomIncrement => 'Use Custom Increment';

  @override
  String get customIncrementActive => 'Custom increment is active';

  @override
  String get defaultIncrementActive => 'Default increment is active';

  @override
  String get customIncrementValue => 'Custom Increment Value';

  @override
  String get customIncrementHint => 'Enter a value between 0.5 and 100';

  @override
  String get pleaseEnterValue => 'Please enter a value';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid positive number';

  @override
  String get incrementTooLarge => 'Increment cannot exceed 100';

  @override
  String get saveCustomIncrement => 'Save Custom Increment';

  @override
  String get customIncrementSaved => 'Custom increment saved successfully';

  @override
  String get calculatePlatesNeeded => 'Calculate Plates Needed';

  @override
  String get barWeight => 'Bar Weight';

  @override
  String get targetWeight => 'Target Weight';

  @override
  String get calculate => 'Calculate';

  @override
  String get platesInYourGym => 'Plates in Your Gym';

  @override
  String get quantity => 'Quantity';

  @override
  String get editPlates => 'Edit Plates';

  @override
  String get pleaseEnterValidWeights => 'Please enter valid weights';

  @override
  String get targetWeightTooLow =>
      'Target weight must be greater than or equal to bar weight';

  @override
  String get plateCalculationResult => 'Plate Calculation Result';

  @override
  String get difference => 'Difference';

  @override
  String get platesPerSide => 'Plates Per Side';

  @override
  String get barOnly => 'Bar only (no plates needed)';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all settings to default values? This cannot be undone.';

  @override
  String get settingsReset => 'Settings reset to defaults';

  @override
  String get feedbackSettings => 'Haptic Feedback';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get enableHaptic => 'Enable haptic feedback';

  @override
  String get hapticIntensity => 'Haptic Intensity';

  @override
  String get intensityLight => 'Light';

  @override
  String get intensityMedium => 'Medium';

  @override
  String get intensityHeavy => 'Heavy';

  @override
  String get hapticDescription =>
      'Feel subtle vibrations when completing sets, exercises, and workouts';

  @override
  String get feedbackSettingsSaved => 'Feedback settings saved';

  @override
  String get historyViewSettings => 'History View Settings';

  @override
  String get viewMode => 'View Mode';

  @override
  String get viewModeList => 'List View';

  @override
  String get viewModeCompact => 'Compact';

  @override
  String get viewModeCalendar => 'Calendar View';

  @override
  String get viewModeStats => 'Stats View';

  @override
  String get historyDisplayOptions => 'Display Options';

  @override
  String get showThumbnails => 'Show Thumbnails';

  @override
  String get showDuration => 'Show Duration';

  @override
  String get showExerciseCount => 'Show Exercise Count';

  @override
  String get viewSettingsDescription =>
      'Customize how your workout history is displayed';

  @override
  String get historyViewSettingsSaved => 'View settings saved';

  @override
  String get reportExerciseIssue => 'Report Issue';

  @override
  String get feedbackType => 'Issue Type';

  @override
  String get feedbackBug => '🐛 Bug';

  @override
  String get feedbackSuggestion => '💡 Suggestion';

  @override
  String get feedbackTypo => '📝 Text Error';

  @override
  String get feedbackOther => '❓ Other';

  @override
  String get describeProblem => 'Describe the issue...';

  @override
  String get sendFeedback => 'Send Report';

  @override
  String get cancelFeedback => 'Cancel';

  @override
  String get feedbackSentSuccess => '✅ Thanks for the report!';

  @override
  String get feedbackSentError => '❌ Error sending report';

  @override
  String get feedbackRequired => 'Please describe the issue';

  @override
  String get exerciseReviewReport => 'Exercise Review Report';

  @override
  String get monthlyReview => 'Monthly Review';

  @override
  String get staleExercises => 'Stale Exercises';

  @override
  String get flaggedExercises => 'Flagged Exercises';

  @override
  String get exercisesObsolete => 'Stale Exercises';

  @override
  String get exercisesFlagged => 'Flagged Exercises';

  @override
  String get feedbackTotal => 'Total Feedback';

  @override
  String get criticalIssues => 'Critical Issues';

  @override
  String get daysThreshold => '>90 days';

  @override
  String get feedbackThreshold => '≥3 feedback';

  @override
  String get flagged => 'flagged';

  @override
  String get critical => 'critical';

  @override
  String modifiedDaysAgo(int days) {
    return 'Modified $days days ago';
  }

  @override
  String get noReportAvailable => 'No report available';

  @override
  String get reportWillBeAvailable =>
      'The monthly report will be available after the first execution';

  @override
  String get exerciseFeedback => 'Exercise Feedback';

  @override
  String get feedbackRefresh => 'Refresh';

  @override
  String get feedbackStatsTotal => 'Total';

  @override
  String get feedbackStatsOpen => 'Open';

  @override
  String get feedbackStatsResolved => 'Resolved';

  @override
  String get feedbackByType => 'Feedback by Type';

  @override
  String get feedbackBySeverity => 'Feedback by Severity';

  @override
  String get feedbackSeverityCritical => 'Critical';

  @override
  String get feedbackSeverityHigh => 'High';

  @override
  String get feedbackSeverityMedium => 'Medium';

  @override
  String get feedbackSeverityLow => 'Low';

  @override
  String get feedbackCriticalIssues => 'Critical Issues (Severity ≥ 4)';

  @override
  String get feedbackCriticalIssuesTitle => 'Critical Issues (Severity ≥ 4)';

  @override
  String get feedbackNoCriticalIssues => 'No critical issues';

  @override
  String get feedbackErrorLoadingCritical => 'Error loading critical issues';

  @override
  String get feedbackRecentOpen => 'Recent Open Feedback';

  @override
  String get feedbackRecentOpenTitle => 'Recent Open Feedback';

  @override
  String get feedbackNoOpenFeedback => 'No open feedback';

  @override
  String get feedbackErrorLoading => 'Error loading feedback';

  @override
  String get feedbackErrorLoadingList => 'Error loading feedback';

  @override
  String get feedbackLoadingMessage => 'Loading feedback...';

  @override
  String feedbackSubmittedBy(String email) {
    return 'by $email';
  }

  @override
  String get feedbackDetailUserMessage => 'User Message';

  @override
  String get feedbackDetailAdminNotes => 'Admin Notes';

  @override
  String get feedbackDetailAdminNotesHint =>
      'Add internal notes about this feedback...';

  @override
  String get feedbackDetailSaveNotes => 'Save Notes';

  @override
  String get feedbackDetailNotesSaved => 'Notes saved successfully';

  @override
  String get feedbackDetailNotesError => 'Error saving notes';

  @override
  String get feedbackDetailQuickActions => 'Quick Actions';

  @override
  String get feedbackActionStartReview => 'Start Review';

  @override
  String get feedbackActionMarkResolved => 'Mark Resolved';

  @override
  String get feedbackActionDismiss => 'Dismiss';

  @override
  String get feedbackActionReopen => 'Reopen';

  @override
  String feedbackStatusUpdated(String status) {
    return 'Status updated to $status';
  }

  @override
  String get feedbackStatusUpdateError => 'Error updating status';

  @override
  String get feedbackDetailChangeSeverity => 'Change Severity';

  @override
  String get feedbackSeverityUpdated => 'Severity updated';

  @override
  String get feedbackSeverityUpdateError => 'Error updating severity';

  @override
  String get feedbackDetailInfoUser => 'User';

  @override
  String get feedbackDetailInfoCreated => 'Created';

  @override
  String get feedbackDetailInfoVersion => 'Version';

  @override
  String get feedbackSeverityUrgent => 'Urgent';

  @override
  String feedbackTimeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String feedbackTimeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String feedbackTimeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String feedbackByUser(String email) {
    return 'by $email';
  }

  @override
  String get savingWorkout => 'Saving workout...';

  @override
  String get syncingToCloud => 'Syncing to cloud...';

  @override
  String get workoutSavedLocally => 'Workout saved locally';

  @override
  String get cloudSyncComplete => 'Cloud sync complete';

  @override
  String get cloudSyncQueued => 'Queued for sync';

  @override
  String get saveFailed => 'Failed to save';

  @override
  String get retryingSync => 'Retrying sync...';

  @override
  String get localSaveFailed => 'Local save failed';

  @override
  String get retryOrExport => 'Retry or export data';

  @override
  String get quickRepPresets => 'Quick Rep Presets';

  @override
  String get quickSetCount => 'Quick Set Count';

  @override
  String get averageRpe => 'Average RPE';

  @override
  String get routineDayCompleted => 'Routine day completed:';

  @override
  String get routineDayCompletionFailed => 'Failed to complete routine day';

  @override
  String get repPresetStrengthLabel => '1-3';

  @override
  String get repPresetStrengthDescription => 'Maximum Strength';

  @override
  String get repPresetPowerLabel => '4-6';

  @override
  String get repPresetPowerDescription => 'Power';

  @override
  String get repPresetStrengthHypertrophyLabel => '6-8';

  @override
  String get repPresetStrengthHypertrophyDescription =>
      'Strength / Hypertrophy';

  @override
  String get repPresetHypertrophyLabel => '8-12';

  @override
  String get repPresetHypertrophyDescription => 'Hypertrophy';

  @override
  String get repPresetEnduranceLabel => '12-15';

  @override
  String get repPresetEnduranceDescription => 'Muscular Endurance';

  @override
  String get repPresetHighEnduranceLabel => '15+';

  @override
  String get repPresetHighEnduranceDescription => 'High Endurance';

  @override
  String get restPresetNoTimer => 'No Timer';

  @override
  String get restPresetThirtySeconds => '30 seconds';

  @override
  String get restPresetOneMinute => '1 minute';

  @override
  String get restPresetOneMinuteThirty => '1:30 min';

  @override
  String get restPresetTwoMinutes => '2 minutes';

  @override
  String get restPresetThreeMinutes => '3 minutes';

  @override
  String get restPresetFiveMinutes => '5 minutes';

  @override
  String get restTimeDescription => 'Set the recovery timer between sets';

  @override
  String get useCustomTimer => 'Use custom timer';

  @override
  String get timerActiveForExercise => 'Timer active for this exercise';

  @override
  String get noSpecificTimer => 'No specific timer';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get customTimer => 'Custom Timer';

  @override
  String get timerSet => 'Timer set: ';

  @override
  String get swapDaysTitle => 'Swap Workout Days?';

  @override
  String get swapDaysDescription =>
      'Your routine scheduled differently. Do you want to swap these days?';

  @override
  String get daysSwappedSuccessfully =>
      'Days swapped successfully! Continuing with';

  @override
  String get errorSwappingDays => 'Error swapping days. Please try again.';

  @override
  String get errorMarkingDayAsSkipped => 'Error marking day as skipped';

  @override
  String get workoutCompletedButRoutineNotUpdated =>
      'Workout completed. Routine not updated.';

  @override
  String get continueNormal => 'Continue Normal';

  @override
  String get skipToday => 'Skip Today';

  @override
  String get swapDaysButtonLabel => 'Swap Days';

  @override
  String get routineRecoverSkippedDays => 'Recover Skipped Days';

  @override
  String get routineRecoverSkippedDaysSubtitle =>
      'Select a skipped day, then choose a rest day to recover it';

  @override
  String routineSkippedDaysCount(int count) {
    return 'Skipped Days ($count)';
  }

  @override
  String routineAvailableDaysCount(int count) {
    return 'Available Days ($count)';
  }

  @override
  String get routineSelectSkippedDayFirst => '← Select a skipped day first';

  @override
  String get routineNoSkippedDays => 'No skipped days!';

  @override
  String get routineOnTrack => 'You\'re on track with your routine 💪';

  @override
  String get routineNoRestDaysAvailable =>
      'No rest days available in the next 30 days';

  @override
  String routineWorkoutRecovered(String date) {
    return 'Workout recovered to $date';
  }

  @override
  String get routineRecoveryFailed => 'Failed to recover workout';

  @override
  String routineRecoveryError(String error) {
    return 'Error recovering workout: $error';
  }

  @override
  String get routineNoActiveRoutine => 'No active routine found';

  @override
  String get routineSkipRecovery => 'Skip Recovery';

  @override
  String notificationSkippedDaysSingle(int count, String routine) {
    return '$count day skipped in $routine';
  }

  @override
  String notificationSkippedDaysMultiple(int count, String routine) {
    return '$count days skipped in $routine';
  }

  @override
  String get notificationSkippedDaysBody =>
      'Tap to view recovery options and get back on track!';

  @override
  String notificationRoutineDayCompleted(String routine) {
    return '$routine day completed!';
  }

  @override
  String notificationGreatJob(String workout) {
    return 'Great job completing $workout!';
  }

  @override
  String notificationRecoverySingle(int count) {
    return '$count skipped day can be recovered';
  }

  @override
  String notificationRecoveryMultiple(int count) {
    return '$count skipped days can be recovered';
  }

  @override
  String notificationRecoveryBody(String routine) {
    return 'Tap to schedule recovery workouts in $routine';
  }

  @override
  String get errorJsonMalformed =>
      'Invalid JSON format. Check brackets and commas.';

  @override
  String get errorJsonUnexpectedCharacter =>
      'Unexpected character in JSON. Check syntax.';

  @override
  String get errorJsonMissingFields => 'Missing required fields in JSON.';

  @override
  String get errorFileNotFound => 'File not found. Please select a valid file.';

  @override
  String get errorFilePermission => 'Permission denied. Cannot access file.';

  @override
  String get errorFileAccess => 'Unable to access file. Try again.';

  @override
  String get errorFileTooLarge => 'File too large (max 5MB).';

  @override
  String get errorFileEmpty => 'File is empty. Please provide content.';

  @override
  String get errorFileAlreadyExists => 'File already exists.';

  @override
  String get errorDiskFull => 'Disk is full. Free up space and try again.';

  @override
  String get errorTemplateNameMissing => 'Template name is required.';

  @override
  String get errorNoExercises => 'Add at least one exercise to the template.';

  @override
  String get errorExercisesInvalid => 'Exercise data is invalid. Check format.';

  @override
  String get errorSetsRequired => 'Each exercise needs at least one set.';

  @override
  String get errorInvalidNumbers => 'Weight and reps must be valid numbers.';

  @override
  String get errorDuplicateTemplate =>
      'A template with this name already exists.';

  @override
  String get errorImportFailed => 'Import failed. Check format and try again.';

  @override
  String get suggestionCheckJsonFormat =>
      'Check JSON format (brackets, commas, quotes)';

  @override
  String get suggestionUseJsonValidator =>
      'Use a JSON validator online to check format';

  @override
  String get suggestionCopyExample => 'Copy the example template and modify it';

  @override
  String get suggestionCheckFilePath =>
      'Verify the file exists at the specified path';

  @override
  String get suggestionReduceFileSize =>
      'Reduce file size or split into multiple files';

  @override
  String get suggestionCheckPermissions =>
      'Check app permissions in device settings';

  @override
  String get suggestionAddTemplateName => 'Add a name field to your template';

  @override
  String get suggestionAddExercises => 'Add at least one exercise with sets';

  @override
  String get suggestionAddSets => 'Add set information (reps and weight)';

  @override
  String get suggestionCheckFormat =>
      'Check the template format matches the example';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get parsing => 'Parsing...';

  @override
  String get matchingExercises => 'Matching exercises...';

  @override
  String get convertingWeights => 'Converting weights...';

  @override
  String get finalizing => 'Finalizing...';

  @override
  String get importFailed => 'Import failed';

  @override
  String get noDescription => 'No description';

  @override
  String get exerciseDetailSummary => 'Summary';

  @override
  String get exerciseDetailHistory => 'History';

  @override
  String get exerciseDetailInstructions => 'Instructions';

  @override
  String get primaryMuscle => 'Primary Muscle';

  @override
  String get last3MonthsChart => 'Last 3 Months';

  @override
  String get best1RM => 'Best 1RM';

  @override
  String get bestSetVolume => 'Best Set Volume';

  @override
  String get bestSessionVolume => 'Best Session Volume';

  @override
  String get strengthLevel => 'Strength Level';

  @override
  String get strengthLevelComingSoon =>
      'Strength level benchmarks coming soon!';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get startWorkoutToSeeHistory =>
      'Start a workout to see your exercise history';

  @override
  String get unknownWorkout => 'Unknown Workout';

  @override
  String get videoTutorial => 'Video Tutorial';

  @override
  String get formCues => 'Form Cues';

  @override
  String get warmupPhase1Description =>
      'Joint mobilization and dynamic stretching (5-10 min)';

  @override
  String get warmupPhase2Description =>
      'Muscle activation with bodyweight exercises';

  @override
  String get warmupPhase3Description =>
      '2-3 warmup sets with progressive weight';

  @override
  String get warmupPhase4Title => 'Rest & Recovery';

  @override
  String get warmupPhase4Description =>
      '1-2 minutes rest before starting working sets';

  @override
  String get tips => 'Tips';

  @override
  String get backHint => 'Navigate to previous screen';

  @override
  String get createTemplateHint => 'Open form to create a new workout template';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncStatusHint =>
      'View cloud synchronization status and offline changes';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String modalTestSuccess(String modalName) {
    return '✅ $modalName - WORKING';
  }

  @override
  String modalTestOpened(String modalName) {
    return '✅ $modalName - OPENED (check functionality)';
  }

  @override
  String modalTestError(String modalName, String error) {
    return '❌ $modalName - ERROR: $error';
  }

  @override
  String modalTestRpeSuccess(String rpe) {
    return '✅ RpeSelectorBottomSheet - WORKING: RPE $rpe';
  }

  @override
  String get historyButtonTapped => '📊 History button tapped';

  @override
  String get editButtonTapped => '✏️ Edit button tapped';

  @override
  String get exerciseSelectVariation => 'Select Variation';

  @override
  String get exerciseFilterByEquipment => 'Filter by available equipment';

  @override
  String get exerciseVariationStandard => 'Standard';

  @override
  String get exerciseVariationEquipment => 'Equipment';

  @override
  String get exerciseVariationGrip => 'Grip';

  @override
  String get exerciseVariationAngle => 'Angle';

  @override
  String get exerciseVariationTempo => 'Tempo';

  @override
  String get exerciseVariationROM => 'Range of Motion';

  @override
  String get exerciseEquipmentNone => 'Bodyweight';

  @override
  String exerciseVariationsFiltered(int filtered, int total) {
    return 'Showing $filtered of $total variations';
  }

  @override
  String exerciseVariationsTotal(int total) {
    return '$total variations available';
  }

  @override
  String get exerciseNoVariationsWithEquipment =>
      'No variations available with your current equipment';

  @override
  String get exerciseNoVariationsAvailable =>
      'No variations available for this exercise';

  @override
  String get exerciseShowAllVariations => 'Show All Variations';

  @override
  String get equipmentProfile => 'Equipment Profile';

  @override
  String get equipmentProfileCreate => 'New';

  @override
  String equipmentProfileItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get equipmentProfileSelectOne => 'Select an equipment profile';

  @override
  String get equipmentProfileSelect => 'Select Equipment Profile';

  @override
  String get equipmentProfileCreateError =>
      'Failed to create equipment profile';

  @override
  String get equipmentProfileLoadError => 'Failed to load equipment profiles';

  @override
  String get equipmentProfileEmpty => 'No equipment profiles yet';

  @override
  String get equipmentProfileCreateFirst => 'Create First Profile';

  @override
  String get equipmentProfileCreateNew => 'Create Equipment Profile';

  @override
  String get equipmentProfileSelectTemplate => 'Select Starting Template';

  @override
  String get equipmentProfileCommercial => 'Commercial Gym';

  @override
  String get equipmentProfileCommercialDesc =>
      'Full equipment - barbell, dumbbells, machines, cables';

  @override
  String get equipmentProfileHomeBasic => 'Home Gym (Basic)';

  @override
  String get equipmentProfileHomeBasicDesc =>
      'Barbell, dumbbells, bench, resistance bands';

  @override
  String get equipmentProfileHomeComplete => 'Home Gym (Complete)';

  @override
  String get equipmentProfileHomeCompleteDesc =>
      'Advanced home setup - kettlebells, TRX, pull-up bar';

  @override
  String get equipmentProfileTravel => 'Travel / Hotel';

  @override
  String get equipmentProfileTravelDesc =>
      'Minimal - dumbbells and bodyweight exercises';

  @override
  String get equipmentProfileBodyweight => 'Bodyweight Only';

  @override
  String get equipmentProfileBodyweightDesc =>
      'No equipment - calisthenics and bodyweight movements';

  @override
  String get equipment_barbell => 'Barbell';

  @override
  String get equipment_dumbbell => 'Dumbbell';

  @override
  String get equipment_machine => 'Machine';

  @override
  String get equipment_cables => 'Cables';

  @override
  String get equipment_smith_machine => 'Smith Machine';

  @override
  String get equipment_ez_bar => 'EZ Bar';

  @override
  String get equipment_kettlebell => 'Kettlebell';

  @override
  String get equipment_bodyweight => 'Bodyweight';

  @override
  String get equipment_trx => 'TRX';

  @override
  String get equipment_bands => 'Resistance Bands';

  @override
  String get equipment_pullup_bar => 'Pull-up Bar';

  @override
  String get equipment_parallel_bars => 'Parallel Bars';

  @override
  String get equipment_rack => 'Rack';

  @override
  String get equipment_bench => 'Bench';

  @override
  String get rotationConfigTitle => 'Rotation Settings';

  @override
  String get rotationEnabled => 'Enable Rotation';

  @override
  String get rotationEnabledDesc => 'Automatically rotate exercise variations';

  @override
  String get rotationFrequency => 'Rotation Frequency';

  @override
  String get rotationNotifications => 'Notifications';

  @override
  String get rotationNotificationsDesc => 'Notify before variation changes';

  @override
  String get rotationNotifyDaysBefore => 'Notify days before';

  @override
  String rotationFrequencyWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Every $weeks weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String rotationNotifyDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get rotationPreview => 'Preview';

  @override
  String get rotationNextDate => 'Next rotation';

  @override
  String rotationInDays(int days) {
    return 'In $days days';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get noPermissionMessage =>
      'You don\'t have permission to access this feature. Please upgrade your account or contact support.';

  @override
  String sessionExpiringSoon(int seconds) {
    return 'Your session will expire in $seconds seconds. Tap to extend.';
  }

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get extendSession => 'Extend Session';

  @override
  String get equipmentProfileName => 'Profile Name';

  @override
  String get equipmentProfileNameHint => 'e.g., Home Gym, Travel Kit';

  @override
  String get equipmentProfileBadge => 'Type';

  @override
  String get equipmentProfileSelectEquipment => 'Select Available Equipment';

  @override
  String get selectAll => 'Select All';

  @override
  String get equipmentProfileEdit => 'Edit Equipment Profile';

  @override
  String get equipmentProfileTemplateHint =>
      'Choose a template to customize or start from scratch';

  @override
  String get equipmentProfilesTitle => 'Equipment Profiles';

  @override
  String get equipmentProfilesSubtitle =>
      'Manage your equipment availability for exercise recommendations';

  @override
  String get equipmentProfilesHelp => 'Equipment Profiles Help';

  @override
  String get equipmentProfilesHelpText =>
      'Equipment profiles help the app suggest exercises that match your available equipment. Create different profiles for different locations (gym, home, travel).';

  @override
  String get equipmentProfileBadgeFull => 'Full gym with 6+ equipment types';

  @override
  String get equipmentProfileBadgeHome => 'Home setup with 3-5 equipment types';

  @override
  String get equipmentProfileBadgeMinimal =>
      'Minimal setup with 1-2 equipment types';

  @override
  String get equipmentProfilesEmpty => 'No Equipment Profiles Yet';

  @override
  String get equipmentProfilesEmptyDescription =>
      'Create your first equipment profile to get exercise recommendations based on what you have available.';

  @override
  String get equipmentProfileUpdated => 'Profile updated successfully';

  @override
  String get equipmentProfileCreated => 'Profile created successfully';

  @override
  String get equipmentProfileSaveError => 'Failed to save profile';

  @override
  String get equipmentProfileDeleteConfirmTitle => 'Delete Equipment Profile?';

  @override
  String equipmentProfileDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get equipmentProfileDeleted => 'Profile deleted successfully';

  @override
  String get equipmentProfileDeleteError => 'Failed to delete profile';

  @override
  String get equipmentProfileSetDefault => 'Default profile updated';

  @override
  String get equipmentProfileDefaultError => 'Failed to set default profile';

  @override
  String get equipmentProfileDefault => 'Default';

  @override
  String get equipmentProfileMakeDefault => 'Set Default';

  @override
  String get equipmentProfileStepTitle => 'Available Equipment';

  @override
  String get equipmentProfileStepDescription =>
      'Select which equipment you have available for this routine. This will help filter exercises to match your setup.';

  @override
  String get equipmentProfileStepDescriptionOptional =>
      'Select which equipment you have available. You can skip this and set it up later.';

  @override
  String get equipmentProfileOptional => '(Optional)';

  @override
  String get equipmentProfileSkipForNow => 'Skip for now';

  @override
  String get equipmentProfileSkipConfirmTitle => 'Skip Equipment Profile?';

  @override
  String get equipmentProfileSkipConfirmMessage =>
      'You can add an equipment profile later from Settings. Without it, all exercises will be available.';

  @override
  String get equipmentProfileStepInfoTitle => 'Why is this important?';

  @override
  String get equipmentProfileStepInfoMessage =>
      'The app will only suggest exercises that match your selected equipment, ensuring you can actually perform the recommended workouts.';

  @override
  String get equipmentProfileManageInSettings => 'Manage Profiles in Settings';

  @override
  String get migrationWizardTitle => 'Equipment Profile Change';

  @override
  String get migrationWizardImpactAnalysisTitle => 'Analyzing Impact';

  @override
  String get migrationWizardImpactSummary => 'Impact Summary';

  @override
  String get migrationWizardFromProfile => 'From';

  @override
  String get migrationWizardToProfile => 'To';

  @override
  String migrationWizardAffectedExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises affected',
      one: '1 exercise affected',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardWithAlternatives => 'with alternatives';

  @override
  String get migrationWizardWithoutAlternatives => 'without alternatives';

  @override
  String migrationWizardAffectedRoutines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines',
      one: '1 routine',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardAffectedTemplates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates',
      one: '1 template',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardReviewChanges => 'Review Changes';

  @override
  String get migrationWizardNoImpact =>
      'No exercises are affected by this change.';

  @override
  String get migrationWizardNoImpactMessage =>
      'All your exercises are compatible with the new equipment profile.';

  @override
  String get migrationWizardExerciseReviewTitle => 'Review Exercise';

  @override
  String migrationWizardExerciseProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String migrationWizardRequiredEquipment(Object equipment) {
    return 'Required';
  }

  @override
  String get migrationWizardUsedIn => 'Used in';

  @override
  String get migrationWizardSuggestedAlternatives => 'Suggested Alternatives';

  @override
  String get migrationWizardNoAlternatives =>
      'No compatible alternatives found';

  @override
  String get migrationWizardNoAlternativesMessage =>
      'Consider keeping this exercise if you plan to get the equipment, or remove it.';

  @override
  String migrationWizardSimilarityScore(Object score) {
    return 'Match';
  }

  @override
  String get migrationWizardReplaceWith => 'Replace with';

  @override
  String get migrationWizardKeepExercise => 'Keep anyway';

  @override
  String get migrationWizardKeepExerciseHint => 'I\'ll get this equipment';

  @override
  String get migrationWizardRemoveExercise => 'Remove exercise';

  @override
  String get migrationWizardConfirmationTitle => 'Confirm Changes';

  @override
  String get migrationWizardConfirmationMessage =>
      'Review your decisions before applying';

  @override
  String get migrationWizardSummaryReplaced => 'Replaced';

  @override
  String get migrationWizardSummaryKept => 'Kept';

  @override
  String get migrationWizardSummaryRemoved => 'Removed';

  @override
  String get migrationWizardWillUpdate => 'This will update';

  @override
  String get migrationWizardApplyChanges => 'Apply Changes';

  @override
  String get migrationWizardApplying => 'Applying changes...';

  @override
  String get migrationWizardSuccessTitle => 'Migration Complete!';

  @override
  String get migrationWizardSuccessMessage =>
      'Your equipment profile has been updated.';

  @override
  String get migrationWizardChangesApplied => 'Changes applied';

  @override
  String migrationWizardExercisesReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises replaced',
      one: '1 exercise replaced',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises kept',
      one: '1 exercise kept',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises removed',
      one: '1 exercise removed',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardUpdated => 'Updated';

  @override
  String get migrationWizardAnalyzing => 'Analyzing impact...';

  @override
  String get migrationWizardScanningRoutines => 'Scanning active routines';

  @override
  String get migrationWizardScanningTemplates => 'Scanning workout templates';

  @override
  String get migrationWizardFindingAffected => 'Finding affected exercises';

  @override
  String get migrationWizardGeneratingAlternatives => 'Generating alternatives';

  @override
  String get migrationWizardImpactSummaryTitle => 'Migration Impact Summary';

  @override
  String get migrationWizardTotalAffected => 'Total Affected:';

  @override
  String migrationWizardExercisesWithAlternatives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count with alternatives',
      one: '1 with alternatives',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardExercisesWithoutAlternatives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count without alternatives',
      one: '1 without alternatives',
    );
    return '$_temp0';
  }

  @override
  String get migrationWizardImpactLabel => 'Impact:';

  @override
  String get migrationWizardNoImpactTitle => 'No Impact';

  @override
  String get migrationWizardContinueToReview => 'Continue to Review';

  @override
  String get migrationWizardSkipToConfirmation => 'Skip to Confirmation';

  @override
  String migrationWizardExerciseXOfY(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get migrationWizardNoAlternativesFound =>
      'No compatible alternatives found';

  @override
  String get migrationWizardPreviousExercise => 'Previous Exercise';

  @override
  String get migrationWizardNextExercise => 'Next Exercise';

  @override
  String get migrationWizardDecisionsSummary => 'Decisions Summary:';

  @override
  String migrationWizardReplaceAction(String original, String replacement) {
    return 'Replace: $original → $replacement';
  }

  @override
  String migrationWizardKeepAction(String exercise) {
    return 'Keep: $exercise';
  }

  @override
  String migrationWizardRemoveAction(String exercise) {
    return 'Remove: $exercise';
  }

  @override
  String get migrationWizardBackToReview => 'Back to Review';

  @override
  String get migrationWizardApplyingChanges => 'Applying changes...';

  @override
  String migrationWizardRoutinesUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines updated',
      one: '1 routine updated',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardTemplatesUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates updated',
      one: '1 template updated',
    );
    return '$_temp0';
  }

  @override
  String migrationWizardProfileSwitched(String profileName) {
    return 'Profile switched to: $profileName';
  }

  @override
  String get migrationWizardDone => 'Done';

  @override
  String get migrationWizardCancel => 'Cancel Migration';

  @override
  String get migrationWizardCancelConfirmTitle => 'Cancel Migration?';

  @override
  String get migrationWizardCancelConfirmMessage =>
      'Your decisions will not be saved and the equipment profile will not be changed.';

  @override
  String migrationWizardProgress(int percent) {
    return 'Progress: $percent%';
  }

  @override
  String migrationWizardError(String error) {
    return 'Error during migration: $error';
  }

  @override
  String get migrationWizardRetry => 'Retry';

  @override
  String get routineShiftTitle => 'Routine Auto-Shifted';

  @override
  String routineShiftMessage(String workoutName, String date) {
    return 'We shifted \'$workoutName\' to $date. Confirm or skip permanently?';
  }

  @override
  String get routineShiftConfirm => 'OK, keep shift';

  @override
  String get routineShiftRevert => 'Skip permanently';

  @override
  String get routineShiftConfirmed => 'Shift confirmed successfully';

  @override
  String get routineShiftConfirmFailed => 'Failed to confirm shift';

  @override
  String get routineShiftReverted => 'Shift reverted, workout skipped';

  @override
  String get routineShiftRevertFailed => 'Failed to revert shift';

  @override
  String get routineShiftRevertConfirmTitle => 'Skip Permanently?';

  @override
  String get routineShiftRevertConfirmMessage =>
      'This will undo the shift and mark the workout as skipped. This is not recommended. Are you sure?';

  @override
  String routineDateFormat(int day, int month, int year) {
    return '$month/$day/$year';
  }

  @override
  String get exerciseRotationTitle => 'Exercise Variation Rotation';

  @override
  String get exerciseRotationSubtitle =>
      'Automatically rotate exercise variations every few weeks to keep your workouts fresh and prevent adaptation';

  @override
  String get exerciseChangeVariation => 'Change Exercise';

  @override
  String get exerciseChangeVariationSuccess => 'Exercise changed successfully';

  @override
  String get rotationDueNow => 'Rotation Due Now!';

  @override
  String get rotationNextScheduled => 'Next Rotation Scheduled';

  @override
  String get rotationReadyToApply => 'Ready to apply new exercise variations';

  @override
  String get rotationApplyNow => 'Apply Rotation Now';

  @override
  String get rotationApplyEarly => 'Apply Early';

  @override
  String rotationInWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'In $weeks weeks',
      one: 'In 1 week',
    );
    return '$_temp0';
  }

  @override
  String get rotationApplyConfirmMessage =>
      'This will change all exercise variations in your routine. This action cannot be undone. Continue?';

  @override
  String get rotationAppliedSuccess =>
      'Rotation applied successfully! All exercise variations have been updated.';

  @override
  String get rotationAppliedError =>
      'Failed to apply rotation. Please try again.';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get noSimilarExercisesFound => 'No similar exercises found';

  @override
  String get sameMuscleGroup => 'Same muscle group';

  @override
  String get sameEquipment => 'Same equipment';

  @override
  String get favorites => 'Favorites';

  @override
  String get allCategories => 'All categories';

  @override
  String get allEquipment => 'All equipment';

  @override
  String get replaceExerciseWith => 'Replace this exercise with:';

  @override
  String get skipWorkoutTitle => 'Skip Workout';

  @override
  String skipConsecutiveWarning(int count) {
    return 'You have $count consecutive skip(s). Consider recovering them to maintain consistency.';
  }

  @override
  String get skipWhyQuestion => 'Why are you skipping?';

  @override
  String get skipWhatToDo => 'What would you like to do?';

  @override
  String get skipRecoverTitle => 'Recover (+1 day)';

  @override
  String get skipRecoverSubtitle =>
      'Shift entire routine by 1 day to recover this workout';

  @override
  String get skipPermanentlyTitle => 'Skip permanently';

  @override
  String get skipPermanentlySubtitle =>
      'Skip this workout completely (cannot be recovered)';

  @override
  String get skipAdditionalNotes => 'Additional notes (optional)';

  @override
  String get skipNotesHint => 'e.g., Feeling under the weather...';

  @override
  String get skipImpactTitle => 'Impact on your progress';

  @override
  String get skipCurrentStreak => 'Current Streak';

  @override
  String get skipWillBeLost => 'Will be lost';

  @override
  String get skipAdherenceRate => 'Adherence Rate';

  @override
  String skipDaysLabel(int count) {
    return '$count days';
  }

  @override
  String get skipReasonSick => 'Sick';

  @override
  String get skipReasonInjury => 'Injury';

  @override
  String get skipReasonBusy => 'Busy';

  @override
  String get skipReasonTired => 'Tired';

  @override
  String get skipReasonTravel => 'Travel';

  @override
  String get skipReasonWeather => 'Weather';

  @override
  String get skipReasonOther => 'Other';

  @override
  String get rotationPreviewTitle => 'Preview Rotation Changes';

  @override
  String get rotationSelectAll => 'Select All';

  @override
  String get rotationDeselectAll => 'Deselect All';

  @override
  String rotationSelectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get rotationCurrentLabel => 'Current';

  @override
  String get rotationNewLabel => 'New';

  @override
  String get rotationApplyChanges => 'Apply Changes';

  @override
  String get newRecordBadge => 'NEW RECORD!';

  @override
  String get progressTrend => 'Progress Trend';

  @override
  String get statsBreakdown => 'Stats Breakdown';

  @override
  String get comparisonAndContext => 'Comparison & Context';

  @override
  String get notesAndMedia => 'Notes & Media';

  @override
  String get relatedSessions => 'Related Sessions';

  @override
  String get shareFunctionalityComingSoon => 'Share functionality coming soon';

  @override
  String get editFunctionalityComingSoon => 'Edit functionality coming soon';

  @override
  String get deleteRecordTitle => 'Delete Record';

  @override
  String get deleteRecordConfirmation =>
      'Are you sure you want to delete this personal record?';

  @override
  String get bodyweightMultiplier => 'Bodyweight Multiplier';

  @override
  String get estimatedOneRM => 'Estimated 1RM';

  @override
  String relativeToBodyweight(String weight) {
    return 'Relative to $weight kg bodyweight';
  }

  @override
  String get usingBrzyckiFormula => 'Using Brzycki formula';

  @override
  String get totalWeightReps => 'Total weight × reps';

  @override
  String get noTrendDataAvailable => 'No trend data available';

  @override
  String get timeRangeLabel30D => '30D';

  @override
  String get timeRangeLabel90D => '90D';

  @override
  String get timeRangeLabelAll => 'All';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String weeksAgo(String weeks) {
    return '$weeks weeks ago';
  }

  @override
  String monthsAgo(String months) {
    return '$months months ago';
  }

  @override
  String dAgo(String days) {
    return '${days}d ago';
  }

  @override
  String setsCountShort(String count) {
    return '$count sets';
  }

  @override
  String volumeInTons(String value) {
    return '${value}t volume';
  }

  @override
  String get kgLabel => 'kg';

  @override
  String get debugLogsTitle => 'Debug Logs';

  @override
  String get debugLogsSubtitle => 'Configure logging categories';

  @override
  String get debugLogsDescription =>
      'Enable or disable specific log categories to reduce console noise during debugging. All categories are disabled by default.';

  @override
  String get debugLogsEnableAll => 'Enable All';

  @override
  String get debugLogsDisableAll => 'Disable All';

  @override
  String debugLogsEnabledCount(int count) {
    return '$count enabled';
  }

  @override
  String get debugLogsCategoriesTitle => 'Log Categories';

  @override
  String get debugLogsAllEnabled => 'All logs enabled successfully';

  @override
  String get debugLogsAllDisabled => 'All logs disabled successfully';

  @override
  String debugLogsCategoryEnabled(String category) {
    return '$category enabled';
  }

  @override
  String debugLogsCategoryDisabled(String category) {
    return '$category disabled';
  }

  @override
  String get countingModeWeighted => 'Weight + Reps';

  @override
  String get countingModeReps => 'Reps Only';

  @override
  String get countingModeTime => 'Time-based';

  @override
  String get refreshed => 'Refreshed';

  @override
  String get versionInformation => 'Version Information';

  @override
  String get quickStartTitle => 'Welcome to GymBro!';

  @override
  String get quickStartSubtitle =>
      'Your personalized fitness journey starts here';

  @override
  String get quickStartQuestion => 'Do you have gym experience?';

  @override
  String get quickStartQuestionDescription =>
      'This helps us customize your experience';

  @override
  String get quickStartBeginner => 'No, I\'m new 🌱';

  @override
  String get quickStartBeginnerDescription => 'I\'ll guide you step-by-step';

  @override
  String get quickStartExpert => 'Yes, I\'m experienced 💪';

  @override
  String get quickStartExpertDescription => 'Get out of my way';

  @override
  String get quickStartContinue => 'Continue';

  @override
  String get quickStartSkip => 'Skip for now';

  @override
  String get homeEmptyBeginnerTitle =>
      'Ready to start your fitness journey? 🌱';

  @override
  String get homeEmptyBeginnerDescription =>
      'Don\'t worry, I\'ll guide you through every step. Let\'s start with your first workout!';

  @override
  String get homeEmptyBeginnerCTA => 'Start My First Workout';

  @override
  String get homeEmptyExpertTitle => 'No active workout';

  @override
  String get homeEmptyExpertDescription =>
      'Start a quick workout or use a template';

  @override
  String get homeEmptyExpertCTA => 'Start Workout';

  @override
  String get useTemplate => 'Use Template';

  @override
  String get bullet => 'Bullet point';

  @override
  String get skipTour => 'Skip Tour';

  @override
  String get autoAdvance => 'Auto-advance';

  @override
  String autoAdvanceIn(int seconds) {
    return 'Auto-advance in ${seconds}s';
  }

  @override
  String get tourAiCoachTitle => 'AI Coach 👋';

  @override
  String get tourAiCoachDescription =>
      'Hi! I\'m your AI Coach.\nI\'ll give you personalized tips after your first workout!';

  @override
  String get tourFabTitle => 'Quick Start ⚡';

  @override
  String get tourFabDescription =>
      'Press here to start a workout quickly.\nIt\'s the easiest way to track your progress!';

  @override
  String get tourSmartWorkoutTitle => 'Smart Workout 🧠';

  @override
  String get tourSmartWorkoutDescription =>
      'Or let me create the perfect workout for you based on your goals!';

  @override
  String get tourAnalyticsTitle => 'Analytics - Your Progress 📊';

  @override
  String get tourAnalyticsDescription =>
      'Here you\'ll find detailed charts of:';

  @override
  String get tourAnalyticsBullet1 => 'Total volume per workout';

  @override
  String get tourAnalyticsBullet2 => 'Strength per exercise (estimated 1RM)';

  @override
  String get tourAnalyticsBullet3 => 'Personal records and improvements';

  @override
  String get tourHistoryTitle => 'Workout History 📅';

  @override
  String get tourHistoryDescription =>
      'Here you\'ll find your complete workout history.\nReview past sessions and track your consistency!';

  @override
  String get tourRoutineCenterTitle => 'Routine Center - Advanced Training 🏋️';

  @override
  String get tourRoutineCenterDescription => 'Create multi-week programs with:';

  @override
  String get tourRoutineCenterBullet1 =>
      'Periodization (strength → hypertrophy → deload)';

  @override
  String get tourRoutineCenterBullet2 => 'Automatic template swapping';

  @override
  String get tourRoutineCenterBullet3 => 'Progress tracking for each phase';

  @override
  String get tourCommunityTitle => 'Community 🤝';

  @override
  String get tourCommunityDescription =>
      'Connect with other athletes for motivation and support!';

  @override
  String get tourNotificationsTitle => 'Notifications 🔔';

  @override
  String get tourNotificationsDescription =>
      'Notifications will keep you updated on milestones and tips!';

  @override
  String get suggestedNextWorkout => 'Suggested Next Workout';

  @override
  String get startThisWorkout => 'Start This Workout';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get whyThisSuggestion => 'Why This Suggestion?';

  @override
  String get confidence => 'Confidence';

  @override
  String get levelPattern => 'Pattern';

  @override
  String get levelRoutine => 'Routine';

  @override
  String get levelFrequent => 'Frequent';

  @override
  String get levelDefault => 'Default';

  @override
  String get levelAlternative => 'Alternative';

  @override
  String get notEnoughWorkoutData => 'Not enough workout data yet';

  @override
  String get completeWorkoutsForSuggestions =>
      'Complete at least 6 workouts to get personalized suggestions';

  @override
  String get createWorkout => 'Create Workout';

  @override
  String get analyzingWorkoutPattern => 'Analyzing your workout pattern...';

  @override
  String get workoutSuggestionError => 'Failed to generate workout suggestion';

  @override
  String get pauseRoutine => 'Pause Routine';

  @override
  String get pauseRoutineTitle => 'Pause This Routine';

  @override
  String get pauseRoutineDescription =>
      'Your routine will be paused during this period. You won\'t receive workout reminders.';

  @override
  String get pauseReason => 'Reason for pause';

  @override
  String get pauseReasonInjury => 'Injury';

  @override
  String get pauseReasonSick => 'Sick/Illness';

  @override
  String get pauseReasonVacation => 'Vacation';

  @override
  String get pauseReasonBusy => 'Too Busy';

  @override
  String get pauseReasonBurnout => 'Burnout';

  @override
  String get pauseReasonOther => 'Other';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get pauseNotes => 'Notes (optional)';

  @override
  String get pauseNotesHint =>
      'E.g., Shoulder injury - avoid overhead pressing';

  @override
  String get confirmPause => 'Pause Routine';

  @override
  String get pausedBadge => 'Paused';

  @override
  String pausedUntil(String date) {
    return 'Paused until $date';
  }

  @override
  String get daysRemaining => 'days remaining';

  @override
  String get resumeRoutine => 'Resume Routine';

  @override
  String get routineResumed => 'Routine resumed!';

  @override
  String get pauseValidationStartInPast => 'Start date cannot be in the past';

  @override
  String get pauseValidationEndBeforeStart =>
      'End date must be after start date';

  @override
  String pauseValidationTooLong(int maxDays) {
    return 'Pause duration cannot exceed $maxDays days';
  }

  @override
  String pauseValidationOverlap(String date) {
    return 'Routine already paused until $date';
  }

  @override
  String get conflictingWorkouts => 'Scheduled Workouts in Pause Range';

  @override
  String conflictingWorkoutsMessage(int count) {
    return 'You have $count workouts scheduled during this pause. They will be automatically skipped.';
  }

  @override
  String get confirmAndPause => 'Confirm & Pause';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pause => 'Pause';

  @override
  String get routinePaused => 'Routine paused successfully';

  @override
  String get routineTemplateCreatedSuccess =>
      'Template created! Select it below to continue.';

  @override
  String get levelSystem => 'Level System';

  @override
  String get currentLevel => 'Current Level';

  @override
  String get toNextLevel => 'to next level';

  @override
  String get level => 'Level';

  @override
  String get current => 'Current';

  @override
  String get elite => 'Elite';

  @override
  String get novice => 'Novice';

  @override
  String get expert => 'Expert';

  @override
  String get master => 'Master';

  @override
  String get grandmaster => 'Grandmaster';

  @override
  String get champion => 'Champion';

  @override
  String get legend => 'Legend';

  @override
  String get titan => 'Titan';

  @override
  String get levelDesc1 =>
      'You\'re just getting started! Complete your first workouts to level up.';

  @override
  String get levelDesc2 =>
      'You\'ve completed your first workouts. Keep the momentum going!';

  @override
  String get levelDesc3 =>
      'You\'re building solid workout habits. Consistency is key!';

  @override
  String get levelDesc4 =>
      'Advanced lifter! Your dedication shows in your progress.';

  @override
  String get levelDesc5 =>
      'Expert level achieved! You\'re mastering your training.';

  @override
  String get levelDesc6 =>
      'Master of fitness! Your consistency inspires others.';

  @override
  String get levelDesc7 =>
      'Grandmaster status! Few reach this level of dedication.';

  @override
  String get levelDesc8 => 'Champion! You\'re in the top tier of athletes.';

  @override
  String get levelDesc9 => 'Legendary status! Your discipline is unmatched.';

  @override
  String get levelDesc10 => 'Titan! The ultimate level of fitness mastery.';

  @override
  String get benefit1_1 => 'Track your first workouts';

  @override
  String get benefit1_2 => 'Learn the basics of progress tracking';

  @override
  String get benefit2_1 => 'Unlock workout analytics';

  @override
  String get benefit2_2 => 'Access basic progress charts';

  @override
  String get benefit3_1 => 'Advanced exercise library access';

  @override
  String get benefit3_2 => 'Workout templates available';

  @override
  String get benefit3_3 => 'Custom workout creation';

  @override
  String get benefit4_1 => 'Personal records tracking';

  @override
  String get benefit4_2 => 'Advanced analytics dashboard';

  @override
  String get benefit4_3 => 'Volume and intensity insights';

  @override
  String get benefit5_1 => 'Expert workout recommendations';

  @override
  String get benefit5_2 => 'Periodization suggestions';

  @override
  String get benefit5_3 => 'Recovery optimization';

  @override
  String get benefit6_1 => 'Master-level training programs';

  @override
  String get benefit6_2 => 'Advanced progression tracking';

  @override
  String get benefit6_3 => 'Muscle group balance analysis';

  @override
  String get benefit7_1 => 'Elite training protocols';

  @override
  String get benefit7_2 => 'Competition preparation tools';

  @override
  String get benefit7_3 => 'Performance optimization';

  @override
  String get benefit8_1 => 'Champion workout strategies';

  @override
  String get benefit8_2 => 'Peak performance planning';

  @override
  String get benefit8_3 => 'Advanced recovery protocols';

  @override
  String get benefit9_1 => 'Legendary training methods';

  @override
  String get benefit9_2 => 'Pro-level analytics';

  @override
  String get benefit9_3 => 'Ultimate performance tracking';

  @override
  String get benefit10_1 => 'Titan workout mastery';

  @override
  String get benefit10_2 => 'Complete training ecosystem';

  @override
  String get benefit10_3 => 'Maximum potential unlocked';

  @override
  String get averageEffortLevel => 'Average Effort Level';

  @override
  String get fitnessLevel => 'Fitness Level';

  @override
  String get levelAndXpOnly => 'Level & XP Only';

  @override
  String levelRequired(int level) {
    return 'Level $level Required';
  }

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get velocityAnalytics => 'Velocity Analytics';

  @override
  String get performanceHeatmap => 'Performance Heatmap';

  @override
  String get loadVelocity => 'Load-Velocity';

  @override
  String get velocity => 'Velocity';

  @override
  String get load => 'Load';

  @override
  String get minVelocity => 'Min Velocity';

  @override
  String get avgVelocityLoss => 'Avg Velocity Loss';

  @override
  String get optimalLoad => 'Optimal Load';

  @override
  String get executionTime => 'Execution Time';

  @override
  String get formScore => 'Form Score';

  @override
  String get quality => 'Quality';

  @override
  String get fatigueIndex => 'Fatigue Index';

  @override
  String get explosiveZone => 'Explosive Zone';

  @override
  String get speedZone => 'Speed Zone';

  @override
  String get zones => 'Zones';

  @override
  String get analyzingVelocityData => 'Analyzing velocity data...';

  @override
  String get insufficientVelocityData => 'Insufficient velocity data';

  @override
  String get velocityAnalysisError => 'Velocity analysis error';

  @override
  String get noPerformanceData => 'No performance data available';

  @override
  String get startWorkoutToSeeData => 'Start a workout to see data';

  @override
  String get keyInsights => 'Key Insights';

  @override
  String get tapForMoreInfo => 'Tap for more info';

  @override
  String get tapToCollapse => 'Tap to collapse';

  @override
  String get whatDoesThisMean => 'What does this mean?';

  @override
  String get helpTitle => 'Help';

  @override
  String get defaultHelpContent => 'More information coming soon';

  @override
  String get formula => 'Formula';

  @override
  String get example => 'Example';

  @override
  String get generalTip => 'General Tip';

  @override
  String get volumeExplanation => 'Total Volume';

  @override
  String get volumeExplanationDesc =>
      'Total volume = Sets × Reps × Weight. Measures total training load.';

  @override
  String get volumeTip =>
      'Gradually increase volume by 5-10% per week to avoid overtraining.';

  @override
  String get intensityExplanation => 'Training Intensity';

  @override
  String get intensityExplanationDesc =>
      'Percentage of your one-rep max (1RM) used in training.';

  @override
  String get intensityTip =>
      'Vary intensity: 60-75% for volume, 80-90% for strength, 90%+ for power.';

  @override
  String get setsExplanation => 'Total Sets';

  @override
  String get setsExplanationDesc =>
      'Number of sets performed across all exercises.';

  @override
  String get setsTip =>
      'Research suggests 10-20 sets per muscle group per week for hypertrophy.';

  @override
  String get streakExplanation => 'Workout Streak';

  @override
  String get streakExplanationDesc =>
      'Consecutive days with at least one completed workout.';

  @override
  String get streakTip =>
      'Consistency beats intensity. Even light workouts maintain your streak.';

  @override
  String get oneRmExplanation => 'One-Rep Max (1RM)';

  @override
  String get oneRmExplanationDesc =>
      'Maximum weight you can lift for a single repetition.';

  @override
  String get oneRmTip =>
      'Test 1RM every 4-8 weeks to track strength progress safely.';

  @override
  String get whatIsTotalVolume => 'What is Total Volume?';

  @override
  String get totalVolumeExplanation =>
      'Total weight lifted across all sets and reps (Sets × Reps × Weight).';

  @override
  String get totalVolumeExample =>
      'Example: 3 sets × 10 reps × 50kg = 1,500kg total volume';

  @override
  String get whatAreTotalSets => 'What are Total Sets?';

  @override
  String get totalSetsExplanation =>
      'Number of sets performed across all exercises in your workout.';

  @override
  String get totalSetsExample =>
      'Example: 4 sets squats + 3 sets bench press = 7 total sets';

  @override
  String get whatIsWorkoutFrequency => 'What is Workout Frequency?';

  @override
  String get workoutFrequencyExplanation =>
      'Number of training sessions per week or muscle group hits per week.';

  @override
  String get workoutFrequencyExample =>
      'Example: Training chest 2× per week = 2× frequency';

  @override
  String get whatIsPersonalRecord => 'What is a Personal Record (PR)?';

  @override
  String get personalRecordExplanation =>
      'Your best performance for a specific exercise (max weight, reps, or volume).';

  @override
  String get personalRecordExample =>
      'Example: Bench press 100kg × 5 reps beats your previous 95kg × 5 reps';

  @override
  String get whatIsMuscleBalance => 'What is Muscle Balance?';

  @override
  String get muscleBalanceExample =>
      'Example: Training chest 3× per week but back only 1× creates imbalance';

  @override
  String get daysToGo => 'days to go';

  @override
  String get vsLastPeriod => 'vs last period';

  @override
  String get lastYear => 'Last Year';

  @override
  String get shade400 => 'Shade 400';

  @override
  String lastNMonths(int n) {
    return 'Last $n months';
  }

  @override
  String lastNDays(int n) {
    return 'Last $n days';
  }

  @override
  String get completeDayWithWorkout => 'Complete Day with Workout';

  @override
  String get selectWorkoutToLinkTo => 'Select workout to link to';

  @override
  String get completeWithoutWorkout => 'Complete without workout';

  @override
  String get noRecentWorkoutsFound => 'No recent workouts found';

  @override
  String get completeDayWithoutWorkout =>
      'Complete this day without linking a workout';

  @override
  String get completeDay => 'Complete Day';

  @override
  String get failedToLoadWorkouts => 'Failed to load workouts';

  @override
  String get dayCompletedWithWorkout => 'Day completed with workout!';

  @override
  String get dayCompletedManually => 'Day completed manually';

  @override
  String get failedToCompleteDay => 'Failed to complete day';

  @override
  String get changeCountingFormat => 'Change counting format';

  @override
  String get currentFormat => 'Current format';

  @override
  String get countingModeWeightedDesc => 'Input: Weight (kg/lb) + Reps';

  @override
  String get countingModeWeightedExample => 'Example: 80kg × 10 reps';

  @override
  String get countingModeRepsDesc => 'Input: Reps only (no weight)';

  @override
  String get countingModeRepsExample => 'Example: 15 reps';

  @override
  String get countingModeTimeDesc => 'Input: Duration (mm:ss)';

  @override
  String get countingModeTimeExample => 'Example: 1:30 (90 seconds)';

  @override
  String get confirmChange => 'Confirm change';

  @override
  String get countingModeWarningTitle => 'Warning';

  @override
  String countingModeWarningMessage(int count, String fromMode, String toMode) {
    return 'You have $count completed sets with format \"$fromMode\".\n\nChanging to \"$toMode\" may invalidate existing data.';
  }

  @override
  String get countingModeWarningInfo =>
      'Changing format during a workout is not recommended. Consider finishing the workout first.';

  @override
  String get keepData => 'Keep data';

  @override
  String get resetAll => 'Reset all';

  @override
  String get countingModeChanged => 'Counting format updated!';

  @override
  String get analyticsFeedbackThankYou => 'Thank you for your feedback!';

  @override
  String get analyticsFeedbackThankYouSubtitle =>
      'Your feedback helps us improve the analytics experience';

  @override
  String get analyticsFeedbackQuestion => 'Is this analytics view helpful?';

  @override
  String get analyticsFeedbackHelpful => 'Helpful';

  @override
  String get analyticsFeedbackNotHelpful => 'Not helpful';

  @override
  String get analyticsFeedbackCommentPlaceholder => 'Tell us more (optional)';

  @override
  String get analyticsFeedbackSubmitting => 'Submitting...';

  @override
  String get analyticsFeedbackSubmit => 'Submit feedback';

  @override
  String get analyticsFeedbackError =>
      'Could not submit feedback. Please try again.';

  @override
  String get analyticsFeedbackSuccess => 'Feedback submitted successfully!';

  @override
  String autoEnabledMaster(String masterName) {
    return '✅ $masterName auto-enabled (required for this feature)';
  }

  @override
  String dependentsDisabled(int count) {
    return '⚠️ $count dependent features auto-disabled';
  }

  @override
  String get quickInfoIconTitle => 'Quick Info Icon';

  @override
  String get quickInfoIconDescription => 'Tap for exercise details';

  @override
  String get quickInfoIconTooltip =>
      'Shows exercise information modal with form cues and tips';

  @override
  String get quickWarmupIconTitle => 'Warmup Icon';

  @override
  String get quickWarmupIconDescription => 'Tap for warmup suggestions';

  @override
  String get quickWarmupIconTooltip =>
      'Displays warmup sets recommendation based on working weight';

  @override
  String get quickPreventionIconTitle => 'Prevention Icon';

  @override
  String get quickPreventionIconDescription => 'Tap for injury prevention tips';

  @override
  String get quickPreventionIconTooltip =>
      'Shows injury prevention advice and mobility exercises';

  @override
  String get exerciseNotesTitle => 'Exercise Notes';

  @override
  String get exerciseNotesDescription => 'Add notes about form and cues';

  @override
  String get exerciseNotesTooltip =>
      'Personal notes visible only to you during workouts';

  @override
  String get exerciseInsightsTitle => 'Exercise Insights';

  @override
  String get exerciseInsightsDescription => 'View charts and statistics';

  @override
  String get exerciseInsightsTooltip =>
      'Analytics charts showing volume, PRs, and progress trends';

  @override
  String get insightsPerformanceWarning =>
      'ℹ️ Charts may slow down on older devices';

  @override
  String modeSwitchWarningTitle(String mode) {
    return 'Switch to $mode Mode?';
  }

  @override
  String modeSwitchWarningMessage(String mode) {
    return 'This will reset your custom settings to $mode defaults.';
  }

  @override
  String get modeSwitchUndoHint =>
      'You\'ll have 5 seconds to undo after confirming.';

  @override
  String get undoSuccessful => '✅ Settings restored';

  @override
  String get sortByHelpful => 'Most Helpful';

  @override
  String get sortByRecent => 'Most Recent';

  @override
  String get sortBySaved => 'Most Saved';

  @override
  String get sortByTrending => 'Trending';

  @override
  String get filterByDifficulty => 'Difficulty';

  @override
  String get filterByAuthorTier => 'Author';

  @override
  String get filterByDateRange => 'Date Range';

  @override
  String get resetFilters => 'Reset';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get contributionTypeCorrection => 'Correction';

  @override
  String get contributionTypeTip => 'Tip';

  @override
  String get contributionTypeWarning => 'Warning';

  @override
  String get contributionTypeVariant => 'Variant';

  @override
  String get contributionTypeTranslation => 'Translation';

  @override
  String get contributionTypeTechnique => 'Technique';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyIntermediate => 'Intermediate';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String get authorTierCommunity => 'Community';

  @override
  String get authorTierExpert => 'Expert';

  @override
  String get authorTierAdmin => 'Admin';

  @override
  String get saves => 'Saves';

  @override
  String get views => 'Views';

  @override
  String get comments => 'Comments';

  @override
  String get upvotes => 'Upvotes';

  @override
  String get bookmarkContribution => 'Bookmark contribution';

  @override
  String get saveContribution => 'Save';

  @override
  String get unsaveContribution => 'Unsave';

  @override
  String get saved => 'Saved';

  @override
  String get legalDisclaimerTitle => 'Medical Disclaimer';

  @override
  String get legalDisclaimerContent =>
      '⚠️ IMPORTANT NOTICE\n\nFITlog Pro is a workout tracking tool.\n\nNOT a substitute for:\n• Medical advice\n• Personal trainer\n• Sports physician\n• Fitness consultant\n\nYou MUST:\n✓ Consult a physician before starting any exercise program\n✓ Stop immediately if you experience pain or discomfort\n✓ Take sole responsibility for your safety during training\n\nThe provider is NOT liable for:\n• Physical injuries\n• Worsening of medical conditions\n• Failure to achieve fitness goals\n\nBy accepting, you acknowledge these risks and agree to the Terms of Service and Privacy Policy.';

  @override
  String get legalDisclaimerAccept => 'I Accept';

  @override
  String get legalDisclaimerDecline => 'I Decline';

  @override
  String get legalDocuments => 'Legal Documents';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'How we handle your data (GDPR compliant)';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get tosSubtitle => 'User agreements and liability limitations';

  @override
  String get disclaimerSubtitle => 'Important safety information';

  @override
  String get errorLoadingDocument =>
      'Error loading document. Please try again.';

  @override
  String get apreCalculationMetadata => 'Calculation Analysis';

  @override
  String get apreShowCalculationDetails => 'Show Calculation Details';

  @override
  String get apreHideCalculationDetails => 'Hide Calculation Details';

  @override
  String get apreFormula => 'Formula';

  @override
  String get apreDataPoints => 'Data Points';

  @override
  String get apreDataAge => 'Data Age';

  @override
  String get apreStandardDeviation => 'Variability';

  @override
  String get apreConfidence => 'Confidence';

  @override
  String get apreLastCalculation => 'Last Updated';

  @override
  String apreDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get apreNoHistory => 'No Historical Data';

  @override
  String get apreNoHistoryDescription =>
      'No historical data available for APRE calculations. Please select how you\'d like to estimate your 1RM to get started.';

  @override
  String get apreOptionFromLastWorkout => 'From Last Workout';

  @override
  String get apreOptionManualEstimate => 'Manual Estimate';

  @override
  String get apreOptionTestSet => 'Test Set';

  @override
  String get apreOptionFromLastWorkoutDescription =>
      'Use last set weight/reps as estimate';

  @override
  String get apreOptionManualEstimateDescription =>
      'Enter estimated 1RM directly';

  @override
  String get apreOptionTestSetDescription => 'Guide to do a test set first';

  @override
  String get apreEnter1RM => 'Enter Estimated 1RM (kg)';

  @override
  String get aprePreviewWeights => 'Preview Weights';

  @override
  String get apreContinue => 'Continue';

  @override
  String get apreCancel => 'Cancel';

  @override
  String get ageGateTitle => 'Verify Your Age';

  @override
  String get ageGateInstructions =>
      'Please enter your date of birth to continue.';

  @override
  String get ageGateBirthDate => 'Date of Birth';

  @override
  String get ageGateContinue => 'Continue';

  @override
  String get ageRestrictionTitle => 'Age Restriction';

  @override
  String get ageRestrictionMessage =>
      'You must be at least 14 years old to use FITlog Pro.\n\nThis requirement is mandated by GDPR (EU Regulation 2016/679) and Italian privacy laws.';

  @override
  String get ageRestrictionOk => 'I Understand';

  @override
  String get ageMinorWarningTitle => 'Important Notice for Minors';

  @override
  String get ageMinorWarningMessage =>
      'If you are between 14 and 17 years old:\n\n• You MUST have parental consent to use this app\n• You MUST consult a physician before training\n• You MUST be supervised by an adult during workouts\n• Your parents are legally responsible for your use of this app\n\nDo you confirm you have parental consent?';

  @override
  String get ageMinorWarningConfirm => 'Yes, I Have Consent';

  @override
  String get ageMinorWarningDecline => 'No';

  @override
  String get footerDisclaimerShort =>
      'NOT medical advice • Consult physician • Use at your own risk';

  @override
  String get footerDisclaimerTapHint => 'Tap for full disclaimer';

  @override
  String get apreProtocolChangeWarningTitle => 'Workout in Progress';

  @override
  String get apreProtocolChangeWarningMessage =>
      'You cannot change APRE protocol during an active workout. Please finish your current workout first, then return to adjust protocol settings.';

  @override
  String get apreGotIt => 'Got it';

  @override
  String get apreCalculationMethodTitle => 'APRE Calculation Method';

  @override
  String get apreCalculationMethodDescription =>
      'Choose how historical sets are selected for 1RM estimation in APRE workouts. Different strategies optimize for recency, data volume, or stability.';

  @override
  String get about => 'About';

  @override
  String get accurate => 'Accurate';

  @override
  String get achievementsCopied => 'Achievements copied';

  @override
  String get activeDays => 'Active days';

  @override
  String get activeMatches => 'Active matches';

  @override
  String get addRep => 'Add rep';

  @override
  String get advancedTemplate => 'Advanced template';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get ageRange => 'Age range';

  @override
  String get applyProgressiveOverload => 'Apply progressive overload';

  @override
  String get availability => 'Availability';

  @override
  String get averageVolume => 'Average volume';

  @override
  String get avgPerWeek => 'Avg per week';

  @override
  String get batterySaverActive => 'Battery saver active';

  @override
  String get beginnerTemplate => 'Beginner template';

  @override
  String get bestDay => 'Best day';

  @override
  String get bio => 'Bio';

  @override
  String get blockUser => 'Block user';

  @override
  String get boosted => 'Boosted';

  @override
  String get bothWorkoutAndGym => 'Both workout and gym';

  @override
  String get buddyMatching => 'Buddy matching';

  @override
  String get changeLayout => 'Change layout';

  @override
  String get cityPicker => 'City picker';

  @override
  String get clearAllSets => 'Clear all sets';

  @override
  String get clearDemoData => 'Clear demo data';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get compactView => 'Compact view';

  @override
  String get comparedTo => 'Compared to';

  @override
  String get comparedToLast => 'Compared to last';

  @override
  String get comparedToPrevious => 'Compared to previous';

  @override
  String get completeAllSets => 'Complete all sets';

  @override
  String get completeAnalysis => 'Complete analysis';

  @override
  String get completeStatistics => 'Complete statistics';

  @override
  String get consecutiveDays => 'Consecutive days';

  @override
  String get copyFromLastWorkout => 'Copied from last workout';

  @override
  String get criticalPriority => 'Critical priority';

  @override
  String get customDateRange => 'Custom date range';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get dailyTrend => 'Daily trend';

  @override
  String get dataExported => 'Data exported';

  @override
  String get dateRange => 'Date range';

  @override
  String get declined => 'Declined';

  @override
  String get demoProfiles => 'Demo profiles';

  @override
  String get detailedStats => 'Detailed stats';

  @override
  String get developmentMode => 'Development mode';

  @override
  String get discardWorkoutMessage => 'Discard workout message';

  @override
  String get discardWorkoutTitle => 'Discard workout title';

  @override
  String get distance => 'Distance';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get duplicateWorkout => 'Duplicate workout';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editTemplateDescription => 'Edit template description';

  @override
  String get enableLocation => 'Enable location';

  @override
  String get enableLocationForBetterMatches =>
      'Enable location for better matches';

  @override
  String get endWorkoutTitle => 'End workout title';

  @override
  String get endurance => 'Endurance';

  @override
  String get errorAuth => 'Error auth';

  @override
  String get errorGeneric => 'Error generic';

  @override
  String get errorInvalidEmail => 'Error invalid email';

  @override
  String get errorNetwork => 'Error network';

  @override
  String get errorUserNotFound => 'Error user not found';

  @override
  String get errorWeakPassword => 'Error weak password';

  @override
  String get essentialStatistics => 'Essential statistics';

  @override
  String get evening => 'Evening';

  @override
  String get executing => 'Executing';

  @override
  String get expertTemplate => 'Expert template';

  @override
  String get export => 'Export';

  @override
  String get exporting => 'Exporting';

  @override
  String get failed => 'Failed';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get fatto => 'Fatto';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get filterWorkouts => 'Filter workouts';

  @override
  String get findYourWorkoutPartner => 'Find your workout partner';

  @override
  String get flexibility => 'Flexibility';

  @override
  String get form => 'Form';

  @override
  String get fullView => 'Full view';

  @override
  String get generalFitness => 'General fitness';

  @override
  String get goPremium => 'Go premium';

  @override
  String get gymBuddyOnly => 'Gym buddy only';

  @override
  String get hypertrophy => 'Hypertrophy';

  @override
  String get iceBreakerCategoryCasual => 'Ice breaker category casual';

  @override
  String get iceBreakerCategoryExperience => 'Ice breaker category experience';

  @override
  String get iceBreakerCategoryFitness => 'Ice breaker category fitness';

  @override
  String get iceBreakerCategoryGoals => 'Ice breaker category goals';

  @override
  String get iceBreakerCategoryMotivation => 'Ice breaker category motivation';

  @override
  String get iceBreakerCategoryWorkout => 'Ice breaker category workout';

  @override
  String get iceBreakers => 'Ice breakers';

  @override
  String get improved => 'Improved';

  @override
  String get improvementDetected => 'Improvement detected';

  @override
  String get instagramHandle => 'Instagram handle';

  @override
  String get instagramVerified => 'Instagram verified';

  @override
  String get intensity => 'Intensity';

  @override
  String get intermediateTemplate => 'Intermediate template';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get itsAMatch => 'It\'s a match';

  @override
  String get km => 'Km';

  @override
  String get last => 'Last';

  @override
  String get lastSync => 'Last sync';

  @override
  String get like => 'Like';

  @override
  String get localStorageOnly => 'Local storage only';

  @override
  String get location => 'Location';

  @override
  String get locationHelpsFindNearbyBuddies =>
      'Location helps find nearby buddies';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionExplanation => 'Location permission explanation';

  @override
  String get locationPermissionGranted => 'Location permission granted';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get locationUpdateError => 'Location update error';

  @override
  String get locationUpdated => 'Location updated';

  @override
  String get lookingForWorkoutBuddy => 'Looking for workout buddy';

  @override
  String get matchFilters => 'Match filters';

  @override
  String get matchingPurpose => 'Matching purpose';

  @override
  String get matchingPurposeBoth => 'Matching purpose both';

  @override
  String get matchingPurposeGymBuddy => 'Matching purpose gym buddy';

  @override
  String get matchingPurposeOpenToEverything =>
      'Matching purpose open to everything';

  @override
  String get matchingPurposeWorkoutPartner =>
      'Matching purpose workout partner';

  @override
  String get maxAge => 'Max age';

  @override
  String get maxDistance => 'Max distance';

  @override
  String get midday => 'Midday';

  @override
  String get minAge => 'Min age';

  @override
  String get minimalView => 'Minimal view';

  @override
  String get morning => 'Morning';

  @override
  String get muscleGain => 'Muscle gain';

  @override
  String get needMoreWorkouts => 'Need more workouts';

  @override
  String get newPersonalRecordsAchieved => 'New personal records achieved';

  @override
  String get noComparisonData => 'No comparison data';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get noPRsYet => 'No p rs yet';

  @override
  String get noWorkoutsFound => 'No workouts found';

  @override
  String get noWorkoutsFoundDescription => 'No workouts found description';

  @override
  String get noWorkoutsRecorded => 'No workouts recorded';

  @override
  String get notNow => 'Not now';

  @override
  String get oops => 'Oops';

  @override
  String get openCityPicker => 'Open city picker';

  @override
  String get openIceBreakers => 'Open ice breakers';

  @override
  String get openInstagram => 'Open instagram';

  @override
  String get openSettings => 'Open settings';

  @override
  String get openToDating => 'Open to dating';

  @override
  String get openToFriendship => 'Open to friendship';

  @override
  String get overallAssessment => 'Overall assessment';

  @override
  String get partnerships => 'Partnerships';

  @override
  String get pass => 'Pass';

  @override
  String get perDay => 'Per day';

  @override
  String get performanceDeclined => 'Performance declined';

  @override
  String get photoVerified => 'Photo verified';

  @override
  String get pleaseSelectAtLeastOneGoal => 'Please select at least one goal';

  @override
  String get pleaseSelectPreferredTimes => 'Please select preferred times';

  @override
  String get pleaseSelectYourCity => 'Please select your city';

  @override
  String get preferredTimes => 'Preferred times';

  @override
  String get preparing => 'Preparing';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get progressTitle => 'Progress title';

  @override
  String get rating => 'Rating';

  @override
  String get redo => 'Redo';

  @override
  String get refreshMatches => 'Refresh matches';

  @override
  String get rep => 'Rep';

  @override
  String get reportReasonFakeProfile => 'Report reason fake profile';

  @override
  String get reportReasonHarassment => 'Report reason harassment';

  @override
  String get reportReasonInappropriatePhotos =>
      'Report reason inappropriate photos';

  @override
  String get reportReasonOther => 'Report reason other';

  @override
  String get reportReasonSpam => 'Report reason spam';

  @override
  String get reportReasonUnderage => 'Report reason underage';

  @override
  String get reportUser => 'Report user';

  @override
  String get resetDefaults => 'Reset defaults';

  @override
  String get resetLayout => 'Reset layout';

  @override
  String get resting => 'Resting';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get rpeTimerAndMore => 'Rpe timer and more';

  @override
  String get saveToFirebaseForReuse => 'Save to firebase for reuse';

  @override
  String get screenWontTurnOff => 'Screen wont turn off';

  @override
  String get search => 'Search';

  @override
  String get searchCity => 'Search city';

  @override
  String get searchingForMatches => 'Searching for matches';

  @override
  String get seedDemoData => 'Seed demo data';

  @override
  String get selectDataType => 'Select data type';

  @override
  String get selectDates => 'Select dates';

  @override
  String get selectExportFormat => 'Select export format';

  @override
  String get selectMetrics => 'Select metrics';

  @override
  String get setTrackingReady => 'Set tracking ready';

  @override
  String get setupYourProfile => 'Setup your profile';

  @override
  String get similarPerformance => 'Similar performance';

  @override
  String get sinceRegistration => 'Since registration';

  @override
  String get skipTimer => 'Skip timer';

  @override
  String get startWorkoutNow => 'Start workout now';

  @override
  String get stopSet => 'Stop set';

  @override
  String get streakLabel => 'Streak label';

  @override
  String get superLike => 'Super like';

  @override
  String get swipeToDecide => 'Swipe to decide';

  @override
  String get syncAllWorkouts => 'Sync all workouts';

  @override
  String get syncWorkouts => 'Sync workouts';

  @override
  String get syncing => 'Syncing...';

  @override
  String get tapPlusToAddExercise => 'Tap plus to add exercise';

  @override
  String get tapToViewMore => 'Tap to view more';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get templateLimitSuggestion => 'Template limit suggestion';

  @override
  String get templateSyncDescription => 'Template sync description';

  @override
  String get thisMonth => 'This month';

  @override
  String get older => 'Older';

  @override
  String get timeRange => 'Time range';

  @override
  String get toggleToShowInMatching => 'Toggle to show in matching';

  @override
  String get totalWeightLifted => 'Total weight lifted';

  @override
  String get trainingDays => 'Training days';

  @override
  String get unableToGetLocation => 'Unable to get location';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get updateLocation => 'Update location';

  @override
  String get upgradeForMoreTemplates => 'Upgrade for more templates';

  @override
  String get upgradeToPremiumForSync => 'Upgrade to premium for sync';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get valueTooHigh => 'Value too high';

  @override
  String get valueTooLow => 'Value too low';

  @override
  String get velocityProfile => 'Velocity profile';

  @override
  String get verified => 'Verified';

  @override
  String get verifiedOnly => 'Verified only';

  @override
  String get viewProfile => 'View profile';

  @override
  String get viewWorkout => 'View workout';

  @override
  String get volumeDetails => 'Volume details';

  @override
  String get volumePerDay => 'Volume per day';

  @override
  String get volumeSettings => 'Volume settings';

  @override
  String get vsLastWeek => 'Vs last week';

  @override
  String get weeklyDistribution => 'Weekly distribution';

  @override
  String get weeklyDistributionDesc => 'Weekly distribution desc';

  @override
  String get weeklyDistributionInfo => 'Weekly distribution info';

  @override
  String get weeklyVolume => 'Weekly volume';

  @override
  String get weightLoss => 'Weight loss';

  @override
  String get weightUnit => 'Weight unit';

  @override
  String get workoutComparison => 'Workout comparison';

  @override
  String get workoutDeclineDescription => 'Workout decline description';

  @override
  String get workoutDeleted => 'Workout deleted';

  @override
  String get workoutDuplicated => 'Workout duplicated';

  @override
  String get workoutGoals => 'Workout goals';

  @override
  String get workoutImprovementDescription => 'Workout improvement description';

  @override
  String get workoutPartnerOnly => 'Workout partner only';

  @override
  String get workoutSimilarDescription => 'Workout similar description';

  @override
  String get workoutType => 'Workout type';

  @override
  String get workoutsLabel => 'Workouts label';

  @override
  String get years => 'Years';

  @override
  String get zenMode => 'Zen mode';

  @override
  String get zenModeActiveDescription => 'Zen mode active description';

  @override
  String get zenModeInactiveDescription => 'Zen mode inactive description';

  @override
  String get zonePicker => 'Zone picker';

  @override
  String get workoutDuration => 'Workout duration';

  @override
  String get tryAgain => 'Try again';

  @override
  String andMoreRecords(int count) {
    return 'and $count more records';
  }

  @override
  String andXMore(int count) {
    return 'and $count more';
  }

  @override
  String get errorDeleting => 'Error deleting';

  @override
  String get errorPickingImage => 'Error picking image';

  @override
  String get errorSharing => 'Error sharing';

  @override
  String get errorStartingWorkout => 'Error starting workout';

  @override
  String exercisesCompleted(int count) {
    return '$count exercises completed';
  }

  @override
  String exportFailedError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get saveAndEndWorkout => 'Save and end workout';

  @override
  String saveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String superLikesRemaining(int count) {
    return '$count super likes remaining';
  }

  @override
  String templateLimitMessage(int max) {
    return 'You have reached the limit of $max templates';
  }

  @override
  String trustScore(int score) {
    return 'Trust score: $score';
  }

  @override
  String workoutStartedFromTemplate(String name) {
    return 'Workout started from template: $name';
  }

  @override
  String xpPoints(int count) {
    return '$count XP';
  }

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get recoveryWorkout => 'Recover Workout';

  @override
  String get recoverNow => 'Recover Now';

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String get doWorkoutNow => 'Do Workout Now';

  @override
  String get extendRoutine => 'Extend Routine';

  @override
  String get addToEndOfRoutine => 'Add to end of routine';

  @override
  String get skipPermanently => 'Skip Permanently';

  @override
  String get skipThisWorkout => 'Skip this workout';

  @override
  String get manageUncompletedWorkout => 'Manage missed workout';

  @override
  String get chooseHowToProceed => 'Choose how to proceed';

  @override
  String get routineExtendedSuccessfully => 'Routine extended successfully';

  @override
  String get workoutSkipped => 'Workout skipped';

  @override
  String get recoveryComplete => 'Recovery complete';

  @override
  String get workoutCompletedSuccessfully => 'Workout completed successfully';

  @override
  String get missedWorkoutRecovered => 'Missed workout recovered';

  @override
  String get routineSchedule => 'Schedule';

  @override
  String get routineStatusCompleted => 'Completed';

  @override
  String get routineStatusScheduled => 'Scheduled';

  @override
  String get routineStatusSkipped => 'Skipped';

  @override
  String get routineStatusRest => 'Rest';

  @override
  String get routineExtraWorkout => 'Extra Workout 💪';

  @override
  String get routineExtraWorkoutMessage =>
      'You trained on a scheduled rest day! Great dedication!';

  @override
  String get routineTodayPerformance => 'TODAY\'S PERFORMANCE';

  @override
  String get routineVolume => 'Volume';

  @override
  String get routineDuration => 'Duration';

  @override
  String get exercisesLabel => 'Exercises';

  @override
  String get routineAverageRPE => 'Average RPE';

  @override
  String get routineWorkoutPreview => 'WORKOUT PREVIEW';

  @override
  String get routineChange => 'Change';

  @override
  String get routineTemplateNotFound => 'Template not found';

  @override
  String get routineShowLess => 'Show Less';

  @override
  String routineShowAll(int count) {
    return 'Show All ($count more)';
  }

  @override
  String get routineWorkoutHistory => 'WORKOUT HISTORY';

  @override
  String get routineInsightsSuggestions => 'INSIGHTS & SUGGESTIONS';

  @override
  String get routineAiInsightsBased =>
      'AI-powered insights based on:\n• Your workout performance\n• Recovery metrics\n• Training patterns';

  @override
  String get routineBasedOnMetrics => 'Based on your performance metrics';

  @override
  String get routineStartWorkout => 'Start Workout';

  @override
  String get routineViewFullDetails => 'View Full Details';

  @override
  String get routineComplete => 'Complete';

  @override
  String get routineSkip => 'Skip';

  @override
  String get routineStatusRecovered => 'Recovered';

  @override
  String get routineWorkoutStarted => 'Workout started! 💪';

  @override
  String routineErrorStartingWorkout(String error) {
    return 'Error starting workout: $error';
  }

  @override
  String get routineSkipDay => 'Skip Day';

  @override
  String get routineSkipDayConfirm => 'Mark this day as skipped?';

  @override
  String get routineDaySkipped => 'Day skipped';

  @override
  String get routineFailedToSkip => 'Failed to skip day';

  @override
  String get routineNoTemplatesAvailable => 'No templates available';

  @override
  String get routineActiveRoutine => 'Active Routine';

  @override
  String get routineOtherRoutines => 'Other Routines';

  @override
  String get routineArchived => 'Routine archived';

  @override
  String get routineGoBack => 'Go Back';

  @override
  String get routineActivateRoutine => 'Activate Routine';

  @override
  String get routineArchiveRoutine => 'Archive Routine';

  @override
  String get routineDeleteRoutine => 'Delete Routine';

  @override
  String get routineWhyThisSuggestion => 'Why This Suggestion?';

  @override
  String get routineGotIt => 'Got it';

  @override
  String get routineViewCompletedWorkout => 'View Completed Workout';

  @override
  String get routineNotFound => 'Routine not found';

  @override
  String routineTemplateChanged(String templateName) {
    return 'Template changed to \"$templateName\"';
  }

  @override
  String get routineFailedToChange => 'Failed to change template';

  @override
  String routineErrorChanging(String error) {
    return 'Error changing template: $error';
  }

  @override
  String get routineTodayWorkout => 'Today\'s Workout';

  @override
  String smartButtonStartWorkout(String workoutName) {
    return 'Start $workoutName';
  }

  @override
  String get smartButtonViewRecap => 'View Recap';

  @override
  String smartButtonRestDay(String nextDate) {
    return 'Rest. Next: $nextDate';
  }

  @override
  String get smartButtonExploreWorkouts => 'Explore Workouts';

  @override
  String get smartButtonRecoveryTips => 'Recovery Tips';

  @override
  String get smartWorkoutCTAStart => 'START WORKOUT';

  @override
  String get smartWorkoutCTARestDay => 'Rest Day 🌟';

  @override
  String get smartWorkoutCTARestDayHint =>
      'Use \"+ Free Session\" button for a free workout';

  @override
  String smartWorkoutCTASuggestedToday(int duration) {
    return 'Suggested for today • ~$duration min';
  }

  @override
  String get smartWorkoutCTAErrorLoading => 'Loading error';

  @override
  String get smartWorkoutCTAErrorTemplate => 'Template loading error';

  @override
  String get smartWorkoutCTAIncompleteRoutine => 'Incomplete routine';

  @override
  String get smartWorkoutCTATemplateNotFound => 'Template not found';

  @override
  String get smartWorkoutCTARoutineUpdated => 'Routine updated ✓';

  @override
  String get smartWorkoutCTARestModeTitle => '💪 Enjoy your well-deserved rest';

  @override
  String get smartWorkoutCTARestModeSubtitle =>
      'You crushed an amazing workout!';

  @override
  String smartWorkoutCTARestModeVolume(String volume) {
    return 'Volume: $volume kg';
  }

  @override
  String smartWorkoutCTARestModeDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String smartWorkoutCTARestModeSets(int sets) {
    return 'Sets: $sets';
  }

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get selectAtLeastOneMetric => 'Select at least one metric';

  @override
  String get errorNormalizingData => 'Error normalizing data';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get aiCoachInsights => 'AI Coach Insights';

  @override
  String get syncAlreadyInProgress => 'Sync already in progress';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get invalidTemplateId => 'Invalid template ID';

  @override
  String get pesoKg => 'Peso (kg)';

  @override
  String get volumeTotale => 'Volume Totale';

  @override
  String get vediDettagli => 'Vedi dettagli';

  @override
  String get yourePremium => 'You\\\'re Premium!';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get creaTemplate => 'Crea Template';

  @override
  String get erroriComuni => 'Errori comuni';

  @override
  String get datiEsercizioNonDisponibili => 'Dati esercizio non disponibili';

  @override
  String get useWheel => 'Use wheel';

  @override
  String get typeManually => 'Type manually';

  @override
  String get templateNameIsRequired => 'Template name is required';

  @override
  String get livelloLevel => 'Livello \$level';

  @override
  String get volumeProgress => 'Volume Progress';

  @override
  String get createRoutine => 'Create Routine';

  @override
  String get nessunEsercizioTrovato => 'Nessun esercizio trovato';

  @override
  String get dMmmYyyy => 'd MMM yyyy';

  @override
  String get nessunDatoDisponibile => 'Nessun dato disponibile';

  @override
  String get noExerciseDataAvailable => 'No exercise data available';

  @override
  String get muscleEfficiencyScore => 'Muscle Efficiency Score';

  @override
  String get upperBodyPush => 'Upper Body • Push';

  @override
  String get showMe => 'Show me';

  @override
  String get benvenutoInGymbro => 'Benvenuto in GymBro! 👋';

  @override
  String get iniziaIlTuoViaggioFitnessToccaLaCampanel =>
      'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.';

  @override
  String get iniziaOra => 'Inizia ora';

  @override
  String get vediAchievement => 'Vedi achievement';

  @override
  String get milestoneRaggiunto => 'Milestone Raggiunto!';

  @override
  String get aggiornamentoProgressi => 'Aggiornamento Progressi';

  @override
  String get forcedCleanupCompletedAfterDisposalError =>
      '🔧 Forced cleanup completed after disposal error';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get premiumStatus => 'Premium Status';

  @override
  String get noPurchasesFoundToRestore => 'No purchases found to restore';

  @override
  String get seriePrincipale => 'Serie Principale';

  @override
  String get weightSuggestions => 'Weight Suggestions';

  @override
  String get erroreNelCaricamento => 'Errore nel caricamento';

  @override
  String get errorUnableToEditThisSet => 'Error: Unable to edit this set';

  @override
  String get contribuisciAllaCommunity => 'Contribuisci alla Community';

  @override
  String get inviaContributo => 'Invia Contributo';

  @override
  String get segnalaProblema => 'Segnala problema';

  @override
  String get weightToAll => 'Weight to All';

  @override
  String get repsToAll => 'Reps to All';

  @override
  String get ddMmmmYyyy => 'dd MMMM yyyy';

  @override
  String get patternIsEmpty => 'Pattern is empty';

  @override
  String get syncAvailableForPremiumUsersOnly =>
      'Sync available for premium users only';

  @override
  String get adminOnly => 'Admin Only';

  @override
  String get nessunContributo => 'Nessun Contributo';

  @override
  String get rifiutaContributo => 'Rifiuta Contributo';

  @override
  String get motivoOpzionale => 'Motivo (opzionale)';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get trovaIlTuoWorkoutBuddy => 'Trova il tuo Workout Buddy';

  @override
  String get adminModerationNotImplementedInHybridrep =>
      'Admin moderation not implemented in HybridRepository';

  @override
  String get descriviIlProblemaInDettaglio =>
      'Descrivi il problema in dettaglio...';

  @override
  String get templateNameCannotBeEmpty => 'Template name cannot be empty';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get invalidWeight => 'invalid weight';

  @override
  String get addSetInformationInFormatSet1X580kg =>
      'Add set information in format: Set1 x 5: 80kg';

  @override
  String get templateMustHaveAtLeastOneExercise =>
      'Template must have at least one exercise';

  @override
  String get atLeastOne => 'at least one';

  @override
  String get noWorkoutSectionsFoundInText =>
      'No workout sections found in text';

  @override
  String get noSetInformation => 'no set information';

  @override
  String get fatalErrorInGetusertemplates =>
      'Fatal error in getUserTemplates()';

  @override
  String get noEmail => 'No email';

  @override
  String get adminAccessRequired => 'Admin access required';

  @override
  String get analyticsInfo => 'Analytics Info';

  @override
  String get totalEvents => 'Total Events';

  @override
  String get avgDuration => 'Avg Duration';

  @override
  String get userProperties => 'User Properties';

  @override
  String get syncDashboard => 'Sync Dashboard';

  @override
  String get featureStatus => 'Feature Status';

  @override
  String get segnaComeCompletato => 'Segna come Completato';

  @override
  String get changeEquipment => 'Change Equipment';

  @override
  String get startSync => 'Start Sync';

  @override
  String get segnalazioniEBugUtenti => 'Segnalazioni e bug utenti';

  @override
  String get systemSoundTest => 'SYSTEM SOUND TEST';

  @override
  String get cleanhandle => '@\$cleanHandle';

  @override
  String get noTemplate => 'No template';

  @override
  String get recoverWorkout => 'Recover Workout';

  @override
  String get adherenceRate => 'Adherence Rate';

  @override
  String get skipWorkout => 'Skip Workout';

  @override
  String get gymbroUser => 'GymBro User';

  @override
  String get consigliPersonalizzati => 'Consigli Personalizzati';

  @override
  String get vediAnalytics => 'Vedi Analytics';

  @override
  String get scegliTemplate => 'Scegli Template';

  @override
  String get selezionaUnWorkoutSalvato => 'Seleziona un workout salvato';

  @override
  String get allenamentiRecenti => 'Allenamenti Recenti';

  @override
  String get esercizioDelGiorno => 'Esercizio del Giorno';

  @override
  String get progressiAchievement => '🏆 Progressi & Achievement';

  @override
  String get inarrestabile30GiorniDiStreak =>
      '🔥 Inarrestabile! 30+ giorni di streak!';

  @override
  String get modalTesterDebugMode => '🧪 MODAL TESTER - Debug Mode';

  @override
  String get testAllWorkoutModalsToIdentifyDuplicates =>
      'Test all workout modals to identify duplicates and determine which ones to keep';

  @override
  String get providerIsInErrorState => '💥 Provider is in ERROR state';

  @override
  String get workoutRecenti => 'Workout Recenti';

  @override
  String get streakAttuale => 'Streak Attuale';

  @override
  String get allenamentiTotali => 'Allenamenti Totali';

  @override
  String get questoMese => 'Questo Mese';

  @override
  String get secondaryActionsPreview => 'Secondary Actions Preview';

  @override
  String get resetTimerPosition => 'Reset Timer Position';

  @override
  String get apreCalculationMethod => 'APRE Calculation Method';

  @override
  String get errorDetails => 'Error Details';

  @override
  String get requestTimeout => 'Request timeout';

  @override
  String get sslHandshakeFailedPossibleMitmAttack =>
      'SSL handshake failed - possible MITM attack';

  @override
  String get errormsg => '❌ \$errorMsg';

  @override
  String get debugLogs => 'Debug Logs';

  @override
  String get timerDebugLogsAutorefreshEvery2sn =>
      'Timer Debug Logs - Auto-refresh every 2s\\n';

  @override
  String get pleaseLogInToViewYourAnalytics =>
      'Please log in to view your analytics';

  @override
  String get loadingYourAnalytics => 'Loading your analytics...';

  @override
  String get noWorkoutDataYet => 'No workout data yet';

  @override
  String get completeSomeWorkoutsToSeeYournanalyticsA =>
      'Complete some workouts to see your\\nanalytics and progress!';

  @override
  String get noPersonalRecordsYet => 'No personal records yet';

  @override
  String get newPr => 'NEW PR!';

  @override
  String get analyticsErrorNoValidWorkoutsFound =>
      '❌ [Analytics] ERROR: No valid workouts found!';

  @override
  String get noCompletedExercisesFoundInYourWorkouts =>
      'No completed exercises found in your workouts';

  @override
  String get analyticsErrorSyntheticactivitiesIsEmpty =>
      '❌ [Analytics] ERROR: syntheticActivities is EMPTY after processing!';

  @override
  String get unableToLoadExerciseActivities =>
      'Unable to load exercise activities';

  @override
  String get loadingRoutineAnalytics => 'Loading routine analytics...';

  @override
  String get noActiveRoutine => 'No Active Routine';

  @override
  String get createAndActivateARoutineToSeeAnalyticsH =>
      'Create and activate a routine to see analytics here';

  @override
  String get errorLoadingAnalytics2 => 'Error Loading Analytics';

  @override
  String get activeRoutineAnalytics => 'Active Routine Analytics';

  @override
  String get performanceMetrics => 'Performance Metrics';

  @override
  String get skipRate => 'Skip Rate';

  @override
  String get avgGap => 'Avg Gap';

  @override
  String get betweenWorkouts => 'between workouts';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get templateDistribution => 'Template Distribution';

  @override
  String get weeklyPattern => 'Weekly Pattern';

  @override
  String get weeklyAdherenceTrend => 'Weekly Adherence Trend';

  @override
  String get chartVisualizationComingSoon => 'Chart visualization coming soon';

  @override
  String get workoutmetricsBoxNotOpenedCallHiveopenbo =>
      'workoutMetrics box not opened. Call Hive.openBox<Map>(\\\'workoutMetrics\\\') first.';

  @override
  String get workoutmetricsBoxMustBeOpenedBeforeUsing =>
      'workoutMetrics box must be opened before using analytics';

  @override
  String get cannotCreateWorkoutFromEmptyActivitiesLi =>
      'Cannot create workout from empty activities list';

  @override
  String get trainingRecommendations => 'Training Recommendations';

  @override
  String get loadingAnalytics => 'Loading analytics...';

  @override
  String get noExercisesMatch_searchquery =>
      'No exercises match \"\$_searchQuery\"';

  @override
  String get noRpeDataAvailable => 'No RPE data available';

  @override
  String get storicoEsercizi => 'Storico Esercizi';

  @override
  String get cercaUnEsercizio => 'Cerca un esercizio...';

  @override
  String get pesoAttuale => 'Peso attuale';

  @override
  String get iniziaARegistrareIlTuoPeso => 'Inizia a registrare il tuo peso';

  @override
  String get allExercisesStatistics => 'All Exercises Statistics';

  @override
  String get attendiQualcheSecondo => 'Attendi qualche secondo...';

  @override
  String get tuttiIDatiSonoStatiSincronizzati =>
      'Tutti i dati sono stati sincronizzati!';

  @override
  String get siEVerificatoUnErroreDuranteLaSincronizz =>
      'Si è verificato un errore durante la sincronizzazione.';

  @override
  String get mostraTutti => 'Mostra tutti';

  @override
  String get periodoDiVisualizzazione => 'Periodo di visualizzazione';

  @override
  String get proiezione30Giorni => 'Proiezione 30 giorni';

  @override
  String get rmRmeffettivo => '1RM Effettivo';

  @override
  String get nessunDato1rmDisponibile => 'Nessun dato 1RM disponibile';

  @override
  String get datiInsufficientiPerAnalisi => 'Dati insufficienti per analisi';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get rateYourFatigueLevelToImproveRecoveryIns =>
      'Rate your fatigue level to improve recovery insights';

  @override
  String get anySpecificMuscleSorenessOrObservations =>
      'Any specific muscle soreness or observations?';

  @override
  String get e1rmTrackerTopExercises => 'e1RM Tracker - Top Exercises';

  @override
  String get bestSetOfTheWeek => 'Best Set of the Week';

  @override
  String get dataSyncedToCloud => 'Data synced to cloud';

  @override
  String get syncToCloud => 'Sync to Cloud';

  @override
  String get noWorkoutDataThisWeek => 'No workout data this week';

  @override
  String get completeWorkoutsToSeeYourProgress =>
      'Complete workouts to see your progress';

  @override
  String get fullHistoryComingSoon => 'Full history coming soon!';

  @override
  String get trainingInsight => '💡 Training Insight';

  @override
  String get considera23GiorniDiRecuperoCompletoOUnAl =>
      'Considera 2-3 giorni di recupero completo o un allenamento molto leggero.';

  @override
  String get sePianificatoOttimoAltrimentiVerificaSeS =>
      'Se pianificato, ottimo! Altrimenti, verifica se stai recuperando bene.';

  @override
  String get puoiMantenereQuestoRitmoMaMonitoraIlRecu =>
      'Puoi mantenere questo ritmo, ma monitora il recupero nei prossimi giorni.';

  @override
  String get consideraDiMantenereIlVolumeAttualePerCo =>
      'Considera di mantenere il volume attuale per consolidare i progressi.';

  @override
  String get sonoPassatiDayssincelastworkoutGiorniDal =>
      'Sono passati \$daysSinceLastWorkout giorni dall\'ultimo allenamento.';

  @override
  String get ripartiConCalmaMagariConUnVolumeRidottoD =>
      'Riparti con calma, magari con un volume ridotto del 20-30%.';

  @override
  String get assicuratiDiBilanciareConGiorniDiRecuper =>
      'Assicurati di bilanciare con giorni di recupero adeguati.';

  @override
  String get frequenzaDiAllenamentoElevataConWorkoutc =>
      'Frequenza di allenamento elevata con \$workoutCount sessioni questa settimana.';

  @override
  String get valutaSeRidurreLaFrequenzaPerMigliorareI =>
      'Valuta se ridurre la frequenza per migliorare il recupero.';

  @override
  String get continuaCosiAscoltandoSempreISegnaliDelT =>
      'Continua così, ascoltando sempre i segnali del tuo corpo.';

  @override
  String get analisiDettagliata => '📊 Analisi Dettagliata';

  @override
  String get sbloccaAnalisiAvanzate => '🎯 Sblocca Analisi Avanzate';

  @override
  String get previsioniPersonalizzateBasateSuAin =>
      '• Previsioni personalizzate basate su AI\\n';

  @override
  String get esempiPratici => 'Esempi Pratici';

  @override
  String get volumeSetsRepsWeight => 'Volume = Sets × Reps × Weight';

  @override
  String get strengthCurrentVolumeMaxVolume100 =>
      'Strength % = (Current Volume / Max Volume) × 100';

  @override
  String get loadOlderWorkouts => 'Load older workouts';

  @override
  String get boyle2016 => 'Boyle (2016)';

  @override
  String get croisierEtAl2008 => 'Croisier et al. (2008)';

  @override
  String get reference => '📚 \$reference';

  @override
  String get setsCompleted => 'Sets Completed';

  @override
  String get streakAttuale2 => 'Streak attuale';

  @override
  String get piu => 'Più';

  @override
  String get giornoDiRiposo => 'Giorno di riposo';

  @override
  String get optimalBalance17PerMuscleGroupResearchSh =>
      'Optimal balance: ~17% per muscle group. Research shows balanced training prevents injuries and maximizes growth (Baz-Valle 2022)';

  @override
  String get cercaEsercizio => 'Cerca Esercizio';

  @override
  String get cercaNeiTuoiEsercizi => 'Cerca nei tuoi esercizi';

  @override
  String get focusMoreOnNeglected => 'Focus more on \$neglected';

  @override
  String get considerReducingOverdevelopedVolume =>
      'Consider reducing \$overdeveloped volume';

  @override
  String get noMuscleGroupDataAvailable => 'No muscle group data available';

  @override
  String get ricaricaAnimazione => 'Ricarica animazione';

  @override
  String get forzaAttuale => 'Forza attuale';

  @override
  String get vsUltimoMese => 'vs ultimo mese';

  @override
  String get mmmmYyyy => 'MMMM yyyy';

  @override
  String get performanceTrends => 'Performance Trends';

  @override
  String get trackYourMuscleEfficiency => 'Track your muscle efficiency';

  @override
  String get efficiencyVolumeRecoveryTime =>
      'Efficiency = Volume / Recovery Time';

  @override
  String get rateTodaysFatigue => 'Rate Today\\\'s Fatigue';

  @override
  String get noWorkoutsTodayToRate => 'No workouts today to rate';

  @override
  String get fatigueLevelFatiguelevelRecorded =>
      'Fatigue level \$fatigueLevel recorded';

  @override
  String get noDataAvailableYet => 'No data available yet';

  @override
  String get currentScore => 'Current Score';

  @override
  String get scoreBreakdown => 'Score Breakdown';

  @override
  String get statsTemporarilyUnavailable => 'Stats temporarily unavailable';

  @override
  String get heatmapImplementationComingSoon =>
      'Heatmap implementation coming soon';

  @override
  String get chartImplementationComingSoon =>
      'Chart implementation coming soon';

  @override
  String get bernrdezvzquezEtAl2022Healthcare =>
      'Bernárdez-Vázquez et al. (2022) - Healthcare';

  @override
  String get schoenfeldEtAl2021JStrengthCondRes =>
      'Schoenfeld et al. (2021) - J Strength Cond Res';

  @override
  String get doesNotAccountForFatigueOrTrainingState =>
      'Does not account for fatigue or training state';

  @override
  String get errorMarginTypically510EvenInBestConditi =>
      'Error margin typically ±5-10% even in best conditions';

  @override
  String get gymbroAnalyticsReport => 'GymBro Analytics Report';

  @override
  String get trainingPerformanceAnalysis => 'Training Performance Analysis';

  @override
  String get trainingStatistics => 'Training Statistics';

  @override
  String get bestSet => 'Best Set';

  @override
  String get boxNotFound => 'Box not found';

  @override
  String get analyticsHiveBoxErrorDetectedRetrying =>
      '🔧 [Analytics] Hive box error detected. Retrying...';

  @override
  String get pleaseSelectYourDateOfBirth => 'Please select your date of birth';

  @override
  String get requiredByGdprAndItalianPrivacyLaws =>
      'Required by GDPR and Italian privacy laws';

  @override
  String get toggleAttivi => 'Toggle Attivi:';

  @override
  String get toggleDisattivi => 'Toggle Disattivi:';

  @override
  String get allenamentoRapido => 'Allenamento Rapido';

  @override
  String get daTemplate => 'Da Template';

  @override
  String get fromTemplate => 'From Template';

  @override
  String get nuovoAllenamento => 'Nuovo Allenamento';

  @override
  String get pettoETricipiti => 'Petto e Tricipiti';

  @override
  String get chestTriceps => 'Chest & Triceps';

  @override
  String get n45Min => '45 min';

  @override
  String get n4Esercizi => '4 esercizi';

  @override
  String get n4Exercises => '4 exercises';

  @override
  String get pettoTric => 'PETTO, TRIC';

  @override
  String get modificaRapida => 'Modifica Rapida';

  @override
  String get quickEdit => 'Quick Edit';

  @override
  String get rpe610 => 'RPE (6-10)';

  @override
  String get tapTheButtonToCreateYourFirstWorkout =>
      'Tap the + button to create your first workout';

  @override
  String get welcomeLetsCreateYourFirstWorkoutTogethe =>
      'Welcome! Let\\\'s create your first workout together. I\\\'ll guide you step-by-step.';

  @override
  String get letsGo => 'Let\'s go!';

  @override
  String get greatNowTapHereToAddYourFirstExercise =>
      'Great! Now tap here to add your first exercise.';

  @override
  String get searchByNameOrBrowseByMuscleGroupChooseA =>
      'Search by name or browse by muscle group. Choose any exercise to get started!';

  @override
  String get asIs => 'AS IS';

  @override
  String get noValueAssociatedWithKey_errordescriptio =>
      'No value associated with key \\(_errorDescription(of: key)).';

  @override
  String get unkeyedContainerIsAtEnd => 'Unkeyed container is at end.';

  @override
  String get initCoderHasNotBeenImplemented =>
      'init(coder:) has not been implemented';

  @override
  String get expectedTypeValueButFoundNullInstead =>
      'Expected \\(type) value but found null instead.';

  @override
  String get expectedTypeButFoundNullInstead =>
      'Expected \\(type) but found null instead.';

  @override
  String get erroreError => 'Errore: \$error';

  @override
  String get barbellBenchPress => 'Barbell Bench Press';

  @override
  String get expectImagepickercontroller => 'Expect imagePickerController';

  @override
  String get centroStorico => 'Centro Storico';

  @override
  String get noData => 'No data';

  @override
  String get benchPress => 'Bench Press';

  @override
  String get erroreE => 'Errore: \$e';

  @override
  String get parsedJsonNumberNumberDoesNotFitInType =>
      'Parsed JSON number <\\(number)> does not fit in \\(type).';

  @override
  String get expectGroup => 'Expect group';

  @override
  String get thisMethodMustBeOverridden => 'This method must be overridden.';

  @override
  String get workout1 => 'Workout 1';

  @override
  String get corpoLibero => 'Corpo Libero';

  @override
  String get stackStack => 'Stack: \$stack';

  @override
  String get workout2 => 'Workout 2';

  @override
  String get eeeeDMmmmYyyy => 'EEEE, d MMMM yyyy';

  @override
  String get pancaPiana => 'Panca Piana';

  @override
  String get timerComplete => 'Timer Complete';

  @override
  String get unknownExercise => 'Unknown Exercise';

  @override
  String get workout3 => 'Workout 3';

  @override
  String get syncFailedE => 'Sync failed: \$e';

  @override
  String get legCurl => 'Leg Curl';

  @override
  String get unauthorizedAdminOnly => 'Unauthorized: Admin only';

  @override
  String get testExercise => 'Test Exercise';

  @override
  String get myRoutine => 'My Routine';

  @override
  String get achievementNotFound => 'Achievement not found';

  @override
  String get cannotCastTypeOfObjcvalueToValueSelf =>
      'Cannot cast \\(type(of: objCValue)) to \\(Value.self)';

  @override
  String get expectCollectionview => 'Expect collectionView';

  @override
  String get iAut000017 => 'I-AUT000017';

  @override
  String get thisClassIsNotMeantToBeInitialized =>
      'This class is not meant to be initialized.';

  @override
  String get mmmD => 'MMM d';

  @override
  String get informazioniTut => 'Informazioni TUT';

  @override
  String get frenchPress => 'French Press';

  @override
  String get ezBar => 'EZ Bar';

  @override
  String get workoutReminders => 'Workout Reminders';

  @override
  String get dailyWorkoutReminder => 'Daily Workout Reminder';

  @override
  String get progressAndMotivation => 'Progress & Motivation';

  @override
  String get questaAzioneNonPuEssereAnnullata =>
      'Questa azione non può essere annullata.';

  @override
  String get exception => 'Exception: ';

  @override
  String get eliminaTemplate => 'Elimina Template';

  @override
  String get jump => '+\$jump';

  @override
  String get prevenzioneInfortuni => 'Prevenzione infortuni';

  @override
  String get hapticFeedbackErrorE => 'Haptic feedback error: \$e';

  @override
  String get ezCurl => 'EZ Curl';

  @override
  String get legPress => 'Leg Press';

  @override
  String get barbellBackSquat => 'Barbell Back Squat';

  @override
  String get erroreE2 => '❌ Errore: \$e';

  @override
  String get overheadPress => 'Overhead Press';

  @override
  String get rpeMedio => 'RPE Medio';

  @override
  String get mmmDY => 'MMM d, y';

  @override
  String get key1Workout1Rest => '1 Workout + 1 Rest';

  @override
  String get key2Workouts1Rest => '2 Workouts + 1 Rest';

  @override
  String get key3Workouts1Rest => '3 Workouts + 1 Rest';

  @override
  String get key3Workouts2Rest => '3 Workouts + 2 Rest';

  @override
  String get key4Workouts1Rest => '4 Workouts + 1 Rest';

  @override
  String get key4Workouts3Rest => '4 Workouts + 3 Rest';

  @override
  String get key5Workouts2Rest => '5 Workouts + 2 Rest';

  @override
  String get key6Workouts1Rest => '6 Workouts + 1 Rest';

  @override
  String get workout4 => 'Workout 4';

  @override
  String get key3Set => '3 set';

  @override
  String get continuaCos => 'Continua così!';

  @override
  String get avviaAllenamento => 'Avvia Allenamento';

  @override
  String get exerciseCurrentOfTotal => 'Exercise \$current of \$total';

  @override
  String get missingActivityid => 'Missing activityId';

  @override
  String get iAut000008 => 'I-AUT000008';

  @override
  String get idIdentifier => '   - ID: \\(identifier)';

  @override
  String get liveActivitiesRequireIos161OrLater =>
      'Live Activities require iOS 16.1 or later';

  @override
  String get stackStacktrace => 'Stack: \$stackTrace';

  @override
  String get workoutSummary => 'Workout Summary';

  @override
  String get tracciamentoRpe => 'Tracciamento RPE';

  @override
  String get timerAutomatico => 'Timer Automatico';

  @override
  String get suggerimentiCommunity => 'Suggerimenti Community';

  @override
  String get pettoTricDelt_ant => 'PETTO, TRIC, DELT_ANT';

  @override
  String get advancedFeatures => 'Advanced Features';

  @override
  String get useUnreadnotificationcountproviderFromUn =>
      'Use unreadNotificationCountProvider from unified_notification_provider.dart';

  @override
  String get useTodaynotificationsproviderFromUnified =>
      'Use todayNotificationsProvider from unified_notification_provider.dart';

  @override
  String get providerDisposed => 'Provider disposed';

  @override
  String get notificationPermissionsNotGranted =>
      'Notification permissions not granted';

  @override
  String get workoutReminder => 'Workout Reminder';

  @override
  String get advancedAnalytics => 'Advanced Analytics';

  @override
  String get save33 => 'Save 33%';

  @override
  String get bestValue => 'Best Value';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get youRePremium => 'You\\\'re Premium!';

  @override
  String get communityAccess => 'Community Access';

  @override
  String get shoulderPress => 'Shoulder Press';

  @override
  String get eliminaUnTemplateEsistenteOPassaAPremium =>
      'Elimina un template esistente o passa a Premium per avere più spazio.';

  @override
  String get ilTemplateVerrSalvatoSuFirebaseESarDispo =>
      'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi';

  @override
  String get templatePersonalizzato => 'Template personalizzato';

  @override
  String get eliminaTemplateEsistentiOPassaAPremium =>
      'Elimina template esistenti o passa a Premium.';

  @override
  String get fitlogPro => 'FitLog Pro';

  @override
  String get continueYourRoutine => 'Continue your routine';

  @override
  String get nessunTemplatePersonalizzato => 'Nessun template personalizzato';

  @override
  String get statoSincronizzazione => 'Stato Sincronizzazione';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get confermaSerie => 'Conferma Serie';

  @override
  String get muscoliSecondari => 'Muscoli secondari';

  @override
  String get tipoEsercizio => 'Tipo esercizio';

  @override
  String get rangeRipetizioni => 'Range ripetizioni';

  @override
  String get patternMovimento => 'Pattern movimento';

  @override
  String get serieRiscaldamento => 'Serie riscaldamento';

  @override
  String get durataRiscaldamento => 'Durata riscaldamento';

  @override
  String get mobilitArticolare => 'Mobilità articolare';

  @override
  String get attivazioneMuscolare => 'Attivazione muscolare';

  @override
  String get progressioneCarico => 'Progressione carico';

  @override
  String get noteTecniche => 'Note tecniche';

  @override
  String get drillTecnico => 'Drill tecnico';

  @override
  String get cooldownConsigliato => 'Cooldown consigliato';

  @override
  String get muscoliTarget => 'Muscoli target';

  @override
  String get serieDiRiscaldamento => 'Serie di Riscaldamento';

  @override
  String get prevenzioneInfortuni2 => 'Prevenzione Infortuni';

  @override
  String get hoCapito => 'Ho capito!';

  @override
  String get preLoadedFixedBar => 'Pre-loaded fixed bar';

  @override
  String get nonTroviLEsercizioCreaneUnoPersonalizzat =>
      'Non trovi l\\\'esercizio? Creane uno personalizzato';

  @override
  String get miniSetIndex => 'Mini-Set \$index';

  @override
  String get votoPositivo => '👍 Voto positivo!';

  @override
  String get votoNegativo => '👎 Voto negativo';

  @override
  String get inAttesa => 'In attesa';

  @override
  String get partnershipAttiva => 'Partnership attiva';

  @override
  String get dettagliEsercizio => 'Dettagli Esercizio';

  @override
  String get bug => '🐛 Bug';

  @override
  String get errorLoadingFeedback => 'Error loading feedback';

  @override
  String get eserciziObsoleti => 'Esercizi Obsoleti';

  @override
  String get eserciziFlaggati => 'Esercizi Flaggati';

  @override
  String get key3Feedback => '≥3 feedback';

  @override
  String get allenamentiFunzionali => 'allenamenti funzionali';

  @override
  String get key2Anni => '2 anni';

  @override
  String get barbellSquat => 'Barbell Squat';

  @override
  String get daySkipped => 'Day skipped';

  @override
  String get useridEmail => ', userId: email)';

  @override
  String get progressioneCarico2 => 'Progressione Carico';

  @override
  String get recuperoOttimale => 'Recupero Ottimale';

  @override
  String get bilanciamentoMuscolare => 'Bilanciamento Muscolare';

  @override
  String get accediPerVedereIWorkout => 'Accedi per vedere i workout';

  @override
  String get azioniRapide => 'Azioni Rapide';

  @override
  String get startRestTimerAfterCompletingSet =>
      'Start rest timer after completing set';

  @override
  String get showDropSetsSupersetsEtc => 'Show drop sets, supersets, etc.';

  @override
  String get showTimerOnLockScreenDynamicIsland =>
      'Show timer on lock screen & Dynamic Island';

  @override
  String get syncWorkoutsToAppleHealth => 'Sync workouts to Apple Health';

  @override
  String get playSoundsForTimerAndCompletion =>
      'Play sounds for timer and completion';

  @override
  String get hapticFeedbackForInteractions =>
      'Haptic feedback for interactions';

  @override
  String get englishUs => 'English (US)';

  @override
  String get italianIt => 'Italian (IT)';

  @override
  String get kilogramsKg => 'Kilograms (kg)';

  @override
  String get metricSystem => 'Metric system';

  @override
  String get poundsLbs => 'Pounds (lbs)';

  @override
  String get imperialSystem => 'Imperial system';

  @override
  String get areYouSureYouWantToResetAllSettingsToDef =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get areYouSureYouWantToSignOut => 'Are you sure you want to sign out?';

  @override
  String get exportFunctionalityComingSoon =>
      'Export functionality coming soon';

  @override
  String get importFunctionalityComingSoon =>
      'Import functionality coming soon';

  @override
  String get cercaEsercizi => 'Cerca esercizi...';

  @override
  String get aggiungiSerie => 'Aggiungi Serie';

  @override
  String get dropSet => 'Drop Set';

  @override
  String get unitDiPeso => 'Unità di Peso';

  @override
  String get seiSicuroDiVolerRipristinareTutteLeImpos =>
      'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.';

  @override
  String get templateNonTrovato => 'Template non trovato';

  @override
  String get rimuoviDefinitivamente => 'Rimuovi definitivamente';

  @override
  String get noteOpzionale => 'Note (opzionale)';

  @override
  String get aggiuntoExercisenameAllAllenamento =>
      'Aggiunto \$exerciseName all\\\'allenamento';

  @override
  String get applicaModifiche => 'Applica Modifiche';

  @override
  String get saltaPerOra => 'Salta per ora';

  @override
  String get inserisciLaTuaEmail => 'Inserisci la tua email';

  @override
  String get creaAccount => 'Crea Account';

  @override
  String get vaiAllaHome => 'Vai alla Home';

  @override
  String get seiSicuroDiVolerEliminareName =>
      'Sei sicuro di voler eliminare \\\"\$name\\\"?';

  @override
  String get creaRoutine => 'Crea Routine';

  @override
  String get noCompatibleAlternativesFound =>
      'No compatible alternatives found';

  @override
  String get applyingChanges => 'Applying changes...';

  @override
  String get dropSetPerformExerciseToFailureThenImmed =>
      'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.';

  @override
  String get restPausePerformToFailureRest1015Seconds =>
      'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get addedExercisenameToWorkout => 'Added \$exerciseName to workout';

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String get key1Template => '1 template';

  @override
  String get increaseTrainingFrequency => 'Increase Training Frequency';

  @override
  String get estimated1rm => 'Estimated 1RM';

  @override
  String get useTheImportFunctionInTheTemplateScreen =>
      'Use the import function in the template screen';

  @override
  String get areYouSureYouWantToDeleteName =>
      'Are you sure you want to delete \\\"\$name\\\"?';

  @override
  String get errorSavingError => 'Error saving: \$error';

  @override
  String get noRateLimiterForEndpointEndpoint =>
      '⚠️ No rate limiter for endpoint: \$endpoint';

  @override
  String get liveActivitiesAreDisabled => 'Live Activities are disabled';

  @override
  String get missingRequiredParameters => 'Missing required parameters';

  @override
  String get yearly => 'Yearly';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get saveThirtyThreePercent => 'Save 33%';

  @override
  String get prioritySupport => 'Priority Support';

  @override
  String get fullAccess => 'Full Access';

  @override
  String get active => 'Active';

  @override
  String get unlockGymbroPremium => 'Unlock GymBro Premium';

  @override
  String get premiumTagline =>
      'Sync everywhere • Backup forever • Join the community';

  @override
  String get allDevicesAlwaysInSync => 'All devices, always in sync';

  @override
  String get neverLoseYourData => 'Never lose your data';

  @override
  String get shareDiscoverWorkouts => 'Share & discover workouts';

  @override
  String get analyticsPro => 'Analytics Pro';

  @override
  String get liveUpdates => 'Live Updates';

  @override
  String get realTimeSync => 'Real-time sync';

  @override
  String get getHelpFast => 'Get help fast';

  @override
  String get yearlyPlanMonthlyPrice => 'Only \$3.33/month';

  @override
  String get recommended => 'RECOMMENDED';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get cancelAnytimeAppStore =>
      '• Cancel anytime from App Store\n• Subscription auto-renews unless turned off\n• Payment charged to iTunes account';

  @override
  String get cancelAnytimeGooglePlay =>
      '• Cancel anytime from Google Play\n• Subscription auto-renews unless turned off\n• Payment charged to Google Play account';

  @override
  String continueWithPlan(String plan) {
    return 'Continue with $plan';
  }

  @override
  String get pleaseWait => 'Please wait, this may take a moment';

  @override
  String accountTier(String tier) {
    return 'Account tier: $tier';
  }

  @override
  String get automatic => 'Automatic';

  @override
  String get premiumRestoredSuccess => '✅ Premium restored successfully!';

  @override
  String get noPurchasesToRestore => 'No purchases found to restore';

  @override
  String get annual => 'Annual';

  @override
  String get premiumMembership => 'Premium Membership';

  @override
  String get welcomeToPremium => 'Welcome to Premium! 🎉';

  @override
  String get purchaseCancelled => 'Purchase cancelled';

  @override
  String get templateCategoryStrength => 'Strength';

  @override
  String get templateCategoryCardio => 'Cardio';

  @override
  String get templateCategoryFlexibility => 'Flexibility';

  @override
  String get templateCategoryHybrid => 'Hybrid';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get templateStatsNew => '🆕 New';

  @override
  String get templateStatsToday => '✅ Today';

  @override
  String get templateStatsYesterday => '🕐 Yesterday';

  @override
  String templateStatsDaysAgo(int days) {
    return '🕐 $days days ago';
  }

  @override
  String get templateStatsResume => '🔄 Resume?';

  @override
  String get templateActionShare => 'Share';

  @override
  String get templateActionDuplicate => 'Duplicate';

  @override
  String get templateActionEdit => 'Edit';

  @override
  String get templateActionDelete => 'Delete';

  @override
  String purchaseError(String error) {
    return 'Error: $error';
  }

  @override
  String get unlockYourFullPotential => 'Unlock Your Full Potential';

  @override
  String get syncAcrossAllDevices =>
      'Sync across all devices, access community features, and never lose your progress';

  @override
  String get popular => 'POPULAR';

  @override
  String get whatUsersSay => 'What Users Say';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get startFreeTrialThen => 'Start Free Trial - Then \$39.99/year';

  @override
  String get thankYouForSupporting => 'Thank you for supporting GymBro';

  @override
  String get faqCanICancel => 'Can I cancel anytime?';

  @override
  String get faqWhatHappensToData => 'What happens to my data if I cancel?';

  @override
  String get faqCanIChangePlans => 'Can I change plans?';

  @override
  String get faqIsPaymentSecure => 'Is my payment secure?';

  @override
  String get faqCancelAnswer =>
      'Yes! You can cancel your subscription anytime from settings.';

  @override
  String get faqDataAnswer =>
      'Your data remains safe locally. You just lose cloud sync.';

  @override
  String get faqChangePlansAnswer =>
      'Yes, you can upgrade or downgrade anytime.';

  @override
  String get faqPaymentSecureAnswer =>
      'Yes, we use Apple/Google payment systems for maximum security.';

  @override
  String get testimonialJohnD =>
      'The sync feature is a game changer! I can start a workout on my phone and finish on my tablet.';

  @override
  String get testimonialSarahM =>
      'Community templates saved me hours of planning. Worth every penny!';

  @override
  String get testimonialMikeR =>
      'Never lost a workout since going premium. The backup is automatic and reliable.';

  @override
  String get enjoyAllPremiumFeatures => 'Enjoy all premium features';

  @override
  String get getUnlimitedAccess => 'Get unlimited access to all features';

  @override
  String get trackWorkoutVolume => 'Track your workout volume over time';

  @override
  String get comprehensiveWeeklyAnalytics =>
      'Comprehensive weekly workout analytics';

  @override
  String get analyzeMuscleGroupBalance => 'Analyze muscle group balance';

  @override
  String get deepInsights => 'Deep insights into your performance';

  @override
  String get detailedHistory => 'Detailed History';

  @override
  String get completeWorkoutHistory => 'Complete workout history with details';

  @override
  String get syncAcrossDevices => 'Sync across all your devices';

  @override
  String get noAds => 'No Ads';

  @override
  String get enjoyAdFreeExperience => 'Enjoy ad-free experience';

  @override
  String get inAppPurchasesComingSoon =>
      'In-app purchases coming soon!\nPremium features are currently in beta.';

  @override
  String get thankYouForBeingPremium => 'Thank you for being Premium!';

  @override
  String get gymbroPremium => 'GymBro Premium';

  @override
  String get youArePremium => 'You are Premium!';

  @override
  String get youHaveAccessToAllFeatures => 'You have access to all features';

  @override
  String planWillBeAvailableSoon(String plan) {
    return '$plan plan will be available soon!';
  }

  @override
  String get saveVsMonthly => 'Save 33% vs monthly';

  @override
  String get pleaseLoginToViewAnalytics =>
      'Please log in to view your analytics';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get userReportsAndBugs => 'User reports and bugs';

  @override
  String get onboardingResetComplete => 'Onboarding reset complete';

  @override
  String get customizeHome => 'Customize Home';

  @override
  String get dragToReorderTapToConfigure => 'Drag to reorder, tap to configure';

  @override
  String get manageExerciseReports => 'Manage exercise reports';

  @override
  String get compact => 'Compact';

  @override
  String get standard => 'Standard';

  @override
  String get expanded => 'Expanded';

  @override
  String get small => 'Small';

  @override
  String get large => 'Large';

  @override
  String get addWidget => 'Add Widget';

  @override
  String get createNewRoutine => 'Create New Routine';

  @override
  String get noRoutinesYet => 'No routines yet';

  @override
  String get createFirstRoutineDescription =>
      'Create your first training routine to get started';

  @override
  String get createFirstRoutineButton => 'Create routine';

  @override
  String get chooseFromPopularPatterns => 'Or choose from popular patterns';

  @override
  String get activateRoutineConfirm => 'Activate this routine?';

  @override
  String get archiveRoutineConfirm => 'Archive this routine?';

  @override
  String get deleteRoutineConfirm => 'Delete this routine?';

  @override
  String get routineUnarchived => 'Routine restored';

  @override
  String get routineDeleted => 'Routine deleted';

  @override
  String get failedToActivate => 'Failed to activate routine';

  @override
  String get failedToArchive => 'Failed to archive routine';

  @override
  String get failedToDelete => 'Failed to delete routine';

  @override
  String get failedToUnarchive => 'Failed to restore routine';

  @override
  String get failedToLoadTemplate => 'Failed to load template';

  @override
  String get alternativesComingSoon => 'Alternatives coming soon';

  @override
  String get checkFirebasePermissions =>
      'Please check Firebase permissions or contact support';

  @override
  String get errorLoadingRoutines => 'Error loading routines';

  @override
  String get suggestionLevel => 'Suggestion level';

  @override
  String get noExercises => 'No exercises';

  @override
  String get settingsWorkout => 'Workout';

  @override
  String get settingsIosFeatures => 'iOS Features';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsExport => 'Export Settings';

  @override
  String get settingsExportDesc => 'Save settings as JSON file';

  @override
  String get settingsImport => 'Import Settings';

  @override
  String get settingsImportDesc => 'Load settings from JSON file';

  @override
  String get settingsDataMigrationAvailable =>
      'You have data to migrate from previous version';

  @override
  String get settingsDataMigrationComplete =>
      'Migration completed or not needed';

  @override
  String get settingsAvailable => 'Available';

  @override
  String get settingsBetaModeEnabledDesc =>
      'All premium features unlocked for testing';

  @override
  String get settingsBetaModeDisabledDesc =>
      'Enable temporary access to all premium features';

  @override
  String get settingsResetToDefaultsDesc => 'Restore all settings to default';

  @override
  String get settingsAccountActions => 'Account Actions';

  @override
  String get settingsSignOutDesc => 'Sign out of your account';

  @override
  String get settingsItaliano => 'Italian';

  @override
  String get settingsAccentColorDialog => 'Accent Color';

  @override
  String get settingsDefaultRestTimeDialog => 'Default Rest Time';

  @override
  String get settingsResetTimerPositionDialog => 'Reset Timer Position';

  @override
  String get settingsResetTimerPositionDialogDesc =>
      'This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.';

  @override
  String get settingsTimerPositionResetSuccess =>
      'Timer position reset to default';

  @override
  String settingsFailedToClearCache(Object error) {
    return 'Failed to clear cache: $error';
  }

  @override
  String get settingsResetSettingsDialog => 'Reset Settings';

  @override
  String get settingsResetSettingsDialogDesc =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get settingsSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String settingsApreCalculationMethodUpdated(Object method) {
    return 'APRE calculation method updated to $method';
  }

  @override
  String get settingsApreCalculationMethodLoading => 'APRE Calculation Method';

  @override
  String get settingsLoadingGeneric => 'Loading...';

  @override
  String get settingsApreCalculationMethodError => 'APRE Calculation Method';

  @override
  String settingsErrorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get exerciseListEdit => 'Edit';

  @override
  String get exerciseListDuplicate => 'Duplicate';

  @override
  String get exerciseListInsight => 'Insight';

  @override
  String get exerciseListAddNotesHint => 'Add notes...';

  @override
  String get exerciseListTapToAddNotes => 'Tap to add notes';

  @override
  String exerciseListSetsProgress(Object completed, Object total) {
    return 'Sets ($completed/$total)';
  }

  @override
  String exerciseListSetAdded(Object setNumber) {
    return 'Set $setNumber added';
  }

  @override
  String exerciseListSetRestTimeMessage(Object exerciseName) {
    return 'Set rest time between sets for \"$exerciseName\"';
  }

  @override
  String get exerciseListCancel => 'Cancel';

  @override
  String get exerciseListSave => 'Save';

  @override
  String get exerciseListSetRestTimer => 'Set Rest Timer';

  @override
  String exerciseListCustomTime(Object time) {
    return 'Custom: $time';
  }

  @override
  String get exerciseListCustom => 'Custom';

  @override
  String get exerciseListConfirm => 'Confirm';

  @override
  String get exerciseListCustomRestTime => 'Custom Rest Time';

  @override
  String get exerciseListMinutes => 'Minutes';

  @override
  String get exerciseListSeconds => 'Seconds';

  @override
  String get exerciseListSetButton => 'Set';

  @override
  String exerciseListRestTimerSetTo(Object time) {
    return '⏱️ Rest timer set to $time';
  }

  @override
  String get workoutTemplateSearchHint => 'Search templates...';

  @override
  String get workoutTemplateRetry => 'Retry';

  @override
  String get workoutTemplateNoPopularYet => 'No popular templates yet';

  @override
  String get workoutTemplateMostUsedWillAppear =>
      'Most used templates will appear here';

  @override
  String get workoutTemplateNoCustom => 'No custom templates';

  @override
  String get workoutTemplateCreateFirstCustom =>
      'Create your first custom template';

  @override
  String get workoutTemplateNoneFound => 'No templates found';

  @override
  String get workoutTemplateSharingComingSoon =>
      '📤 Template sharing coming soon...';

  @override
  String workoutTemplateDuplicatedSuccess(Object templateName) {
    return '✅ Template duplicated: \"$templateName\"';
  }

  @override
  String workoutTemplateDuplicationError(Object error) {
    return 'Error duplicating: $error';
  }

  @override
  String get workoutTemplateDeleteTitle => 'Delete Template';

  @override
  String workoutTemplateDeleteConfirm(Object templateName) {
    return 'Are you sure you want to delete \"$templateName\"?';
  }

  @override
  String get workoutTemplateCancel => 'Cancel';

  @override
  String get workoutTemplateSyncStatus => 'Sync Status';

  @override
  String get exerciseOptionsTapToEnlarge => 'Tap to enlarge';

  @override
  String get exerciseOptionsExerciseInfo => 'Exercise info';

  @override
  String get exerciseOptionsExerciseInfoSubtitle =>
      'Muscles involved and technique';

  @override
  String get exerciseOptionsWarmupInfo => 'Warmup info';

  @override
  String get exerciseOptionsWarmupInfoSubtitle => 'Tips for warmup';

  @override
  String get exerciseOptionsNoWarmupDataAvailable => 'No warmup data available';

  @override
  String get exerciseOptionsInjuryPrevention => 'Injury prevention';

  @override
  String get exerciseOptionsInjuryPreventionSubtitle =>
      'Tips to avoid injuries';

  @override
  String get exerciseOptionsNoInjuryPreventionDataAvailable =>
      'No injury prevention data available';

  @override
  String get exerciseOptionsReportIssue => 'Report issue';

  @override
  String get exerciseOptionsReportIssueSubtitle =>
      'Bugs, errors or suggestions';

  @override
  String get exerciseOptionsHistory => 'History';

  @override
  String get exerciseOptionsEditNameAndNotes => 'Edit name and notes';

  @override
  String get exerciseOptionsEditNameAndNotesSubtitle =>
      'Customize exercise name and add notes';

  @override
  String get exerciseOptionsChangeCountingFormat => 'Change counting format';

  @override
  String get exerciseOptionsChangeCountingFormatSubtitle =>
      'Switch between weight/reps/time';

  @override
  String get exerciseOptionsDuplicate => 'Duplicate exercise';

  @override
  String get exerciseOptionsDelete => 'Delete exercise';

  @override
  String get exerciseOptionsExerciseInfoTitle => 'Exercise Info';

  @override
  String get exerciseOptionsPrimaryMuscles => 'Primary Muscles';

  @override
  String get exerciseOptionsSecondaryMuscles => 'Secondary Muscles';

  @override
  String get exerciseOptionsEquipment => 'Equipment';

  @override
  String get exerciseOptionsDifficultyLevel => 'Difficulty Level';

  @override
  String get exerciseOptionsWarmupInfoTitle => 'Warmup Info';

  @override
  String get exerciseOptionsPreWorkoutMobility => 'Pre-Workout Mobility';

  @override
  String get exerciseOptionsPreWorkoutActivation => 'Pre-Workout Activation';

  @override
  String get exerciseOptionsWarmupSets => 'Warmup Sets';

  @override
  String get exerciseOptionsInjuryPreventionTitle => 'Injury Prevention';

  @override
  String get exerciseOptionsInjuryPreventionSection => 'Injury Prevention';

  @override
  String get exerciseOptionsRecommendedCooldown => 'Recommended Cooldown';

  @override
  String get exerciseOptionsTechnicalTips => 'Technical Tips';

  @override
  String get dailyWorkoutAutoCompleting => 'Auto-completing day... ✨';

  @override
  String get dailyWorkoutDifferentWorkoutCompleted =>
      'You completed a different workout today';

  @override
  String get dailyWorkoutSubstitute => 'Substitute';

  @override
  String get dailyWorkoutSkip => 'Skip';

  @override
  String get dailyWorkoutComplete => 'Complete';

  @override
  String get dailyWorkoutRestAndRecovery => 'Rest & Recovery';

  @override
  String get dailyWorkoutRestAndRecoverySubtitle =>
      'Take a break and let your body recover';

  @override
  String get dailyWorkoutDefaultWorkoutName => 'Workout';

  @override
  String get dailyWorkoutLoading => 'Loading...';

  @override
  String get dailyWorkoutTapCompleteWhenDone => 'Tap complete when done';

  @override
  String get dailyWorkoutGreatWork => 'Great work! Keep it up 💪';

  @override
  String get dailyWorkoutDaySkipped => 'Day skipped. Consider recovering it!';

  @override
  String get dailyWorkoutDayRecovered => 'Day recovered successfully!';

  @override
  String get dailyWorkoutStatusCompleted => 'Completed ✓';

  @override
  String get dailyWorkoutStatusSkipped => 'Skipped';

  @override
  String get dailyWorkoutStatusRecovered => 'Recovered';

  @override
  String get dailyWorkoutStatusReadyToGo => 'Ready to go';

  @override
  String get dailyWorkoutSubstituteDialogTitle => 'Substitute Workout?';

  @override
  String get dailyWorkoutSubstituteDialogMessage =>
      'You completed a different workout today. Do you want to mark this day as completed with that workout instead?';

  @override
  String get dailyWorkoutSubstituteDialogConfirm => 'Substitute';

  @override
  String get dailyWorkoutSubstituteDialogCancel => 'Cancel';

  @override
  String get exerciseListUseDefaultTimer => 'Use default timer';

  @override
  String get exerciseListUsesGlobalRestTimer => 'Uses global rest timer';

  @override
  String get exerciseListQuickOptions => 'Quick options';

  @override
  String get exerciseListUsingDefaultTimer => 'Using default timer';

  @override
  String get settingsThemeColor => 'Theme Color';

  @override
  String get settingsThemeColorDesc => 'Tap to change';

  @override
  String get settingsTextSize => 'Text Size';

  @override
  String settingsTextSizePreview(Object size) {
    return 'Sample Text ($size)';
  }

  @override
  String get settingsWorkoutEssentials => 'Workout';

  @override
  String get settingsApreAutoAdjustment => 'APRE Auto-Adjustment';

  @override
  String get settingsApreAutoAdjustmentDesc => 'Automatic weight progression';

  @override
  String get settingsApreProtocol => 'APRE Protocol';

  @override
  String settingsApreProtocolDesc(Object number) {
    return 'Protocol $number';
  }

  @override
  String settingsApreProtocolUpdated(Object protocol) {
    return 'APRE protocol updated to $protocol';
  }

  @override
  String get settingsDayCutoffHour => 'Day Cutoff Hour';

  @override
  String settingsDayCutoffHourDesc(int hour) {
    return 'Workouts after $hour:00 count as \'today\'';
  }

  @override
  String get settingsDayCutoffHourDialog => 'Day Cutoff Hour';

  @override
  String settingsDayCutoffHourValue(int hour) {
    return '$hour:00';
  }

  @override
  String get settingsDayCutoffHourHint =>
      'Workouts completed after this hour will count as \'today\'. Useful for shift workers or late-night gym sessions.';

  @override
  String settingsDayCutoffHourUpdated(int hour) {
    return 'Day cutoff updated to $hour:00';
  }

  @override
  String get daysAgoShort => 'd ago';

  @override
  String get weeksAgoShort => 'w ago';

  @override
  String get monthsAgoShort => 'mo ago';

  @override
  String get previousDataCopied => 'Previous data copied to all sets';

  @override
  String get chooseWorkoutCategory => 'Choose workout category:';

  @override
  String get fullBody => 'Full Body';

  @override
  String get hiit => 'HIIT';

  @override
  String get customWorkout => 'Custom...';

  @override
  String get chestWorkout => 'Chest Workout';

  @override
  String get legsWorkout => 'Legs Workout';

  @override
  String get backWorkout => 'Back Workout';

  @override
  String get armsWorkout => 'Arms Workout';

  @override
  String get cardioWorkout => 'Cardio Workout';

  @override
  String get fullBodyWorkout => 'Full Body Workout';

  @override
  String get hiitWorkout => 'HIIT Workout';

  @override
  String get selectChestWorkout => 'Select chest workout';

  @override
  String get selectLegsWorkout => 'Select legs workout';

  @override
  String get selectBackWorkout => 'Select back workout';

  @override
  String get selectArmsWorkout => 'Select arms workout';

  @override
  String get selectCardioWorkout => 'Select cardio workout';

  @override
  String get selectFullBodyWorkout => 'Select full body workout';

  @override
  String get selectHiitWorkout => 'Select HIIT workout';

  @override
  String get selectCustomWorkout => 'Enter custom name';

  @override
  String get workoutNameRequired => 'Please enter a workout name';

  @override
  String get workoutNameTooShort => 'Name must be at least 2 characters';

  @override
  String get workoutNameTooLong => 'Name must be at most 50 characters';

  @override
  String workoutCreated(String workoutName) {
    return 'Workout $workoutName created';
  }

  @override
  String get usePreviousWeights => 'Use Previous Weights';

  @override
  String get selectWeightIncrease => 'Select how much to increase weights';

  @override
  String get sameWeights => 'Same weights';

  @override
  String get sameWeightsInfo => 'Use the same weights from your last workout';

  @override
  String increaseWeightsInfo(String percentage) {
    return 'Increase all weights by $percentage%';
  }

  @override
  String get morningPrefix => '🌅 Morning';

  @override
  String get afternoonPrefix => '☀️ Afternoon';

  @override
  String get eveningPrefix => '🌆 Evening';

  @override
  String get nightPrefix => '🌙 Night';

  @override
  String get contextTimeTitle => 'How much time do you have today?';

  @override
  String get contextTimeSubtitle =>
      'We\'ll help you choose the perfect workout';

  @override
  String get contextTimeHelp => 'Choose how many minutes you can train today';

  @override
  String timeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String selectTimeMinutes(int minutes) {
    return 'Select $minutes minutes';
  }

  @override
  String get contextExperienceTitle => 'What\'s your level?';

  @override
  String get contextExperienceSubtitle =>
      'To suggest the right weights and reps';

  @override
  String get experienceBeginner => 'Beginner';

  @override
  String get experienceBeginnerDesc => '< 6 months training';

  @override
  String get experienceIntermediate => 'Intermediate';

  @override
  String get experienceIntermediateDesc => '6-24 months';

  @override
  String get experienceAdvanced => 'Advanced';

  @override
  String get experienceAdvancedDesc => '2+ years';

  @override
  String selectExperienceLevel(String level) {
    return 'Select $level';
  }

  @override
  String get contextDemographicsTitle => 'Personalize your workout';

  @override
  String get contextDemographicsSubtitle =>
      'We\'ll suggest weights and exercises more suited to you';

  @override
  String get contextDemographicsReassurance =>
      'You can always change this in settings';

  @override
  String get contextSkipForNow => 'Skip for now';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String selectGender(String gender) {
    return 'Select $gender';
  }

  @override
  String get quickConfirmation => 'Quick confirmation';

  @override
  String quickConfirmationMessage(int minutes, String level) {
    return 'You selected:\n⏱️ $minutes min\n💪 $level\n\nConfirm?';
  }

  @override
  String get changeAnswers => 'Change answers';

  @override
  String get monthlyProgress => 'Monthly Progress';

  @override
  String get thisMonthVsLast => 'This month vs last month';

  @override
  String get bestImprovement => 'Best Improvement';

  @override
  String get peak => 'Peak';

  @override
  String get newPersonalRecord => 'New Personal Record';

  @override
  String get awesome => 'Awesome';

  @override
  String get alternativeExercises => 'Alternative Exercises';

  @override
  String get streakMessageNone => 'Start your streak today!';

  @override
  String get streakMessagePersonalRecord => 'New personal record!';

  @override
  String get streakMessageActive => 'Keep going strong!';

  @override
  String get streakMessageAtRisk => 'Don\'t break the streak! Workout today';

  @override
  String get streakMessageBroken => 'Streak broken. Start fresh today!';

  @override
  String get milestoneWeek => 'Week Warrior';

  @override
  String get milestoneTwoWeeks => 'Two-Week Champion';

  @override
  String get milestoneMonth => 'Monthly Master';

  @override
  String get milestoneTwoMonths => 'Two-Month Hero';

  @override
  String get milestoneQuarter => 'Quarterly Beast';

  @override
  String get milestoneSixMonths => 'Half-Year Legend';

  @override
  String get milestoneYear => 'Yearly Titan';

  @override
  String milestoneCustom(int days) {
    return '$days days';
  }

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get submit => 'Submit';

  @override
  String get feedbackWhyNotHelpful => 'Why wasn\'t this helpful?';

  @override
  String get dismissReasonAlreadyKnow => 'I already know this';

  @override
  String get dismissReasonNotRelevant => 'Not relevant to my goals';

  @override
  String get dismissReasonIncorrect => 'This seems incorrect';

  @override
  String get dismissReasonTooAdvanced => 'Too advanced for me';

  @override
  String get dismissReasonTooBasic => 'Too basic for me';

  @override
  String get dismissReasonNotInterested => 'Not interested in this topic';

  @override
  String get dismissReasonOther => 'Other reason';

  @override
  String get feedbackCommentOptional => 'Additional comments (optional)';

  @override
  String get feedbackCommentHint =>
      'Tell us more about why this wasn\'t helpful...';

  @override
  String get featureInsightsName => 'AI Insights';

  @override
  String get featureInsightsDescription => 'Get personalized training insights';

  @override
  String get featureNotificationsName => 'Smart Notifications';

  @override
  String get featureNotificationsDescription =>
      'Receive timely workout reminders';

  @override
  String get featureAchievementsName => 'Achievements';

  @override
  String get featureAchievementsDescription =>
      'Unlock achievements as you progress';

  @override
  String get featureStreakTrackingName => 'Streak Tracking';

  @override
  String get featureStreakTrackingDescription =>
      'Track your consistency streaks';

  @override
  String get featureAdvancedAnalyticsName => 'Advanced Analytics';

  @override
  String get featureAdvancedAnalyticsDescription =>
      'Deep insights into your progress';

  @override
  String get featureWorkoutSuggestionsName => 'Workout Suggestions';

  @override
  String get featureWorkoutSuggestionsDescription =>
      'Personalized workout recommendations';

  @override
  String get featureRecoveryInsightsName => 'Recovery Insights';

  @override
  String get featureRecoveryInsightsDescription =>
      'Optimize your recovery and rest days';

  @override
  String get featureFormCorrectionsName => 'Form Corrections';

  @override
  String get featureFormCorrectionsDescription =>
      'Get suggestions to improve exercise form';

  @override
  String get featureGateReasonGloballyDisabled =>
      'This feature is temporarily unavailable';

  @override
  String get featureGateReasonUserDisabled => 'You have disabled this feature';

  @override
  String get featureGateReasonDefaultEnabled => 'Feature enabled by default';

  @override
  String get featureGateReasonAllRulesPassed =>
      'You meet all requirements for this feature';

  @override
  String get featureGateReasonInsufficientExperience =>
      'Requires higher experience level';

  @override
  String get featureGateReasonInsufficientWorkouts =>
      'Complete more workouts to unlock';

  @override
  String get featureGateReasonAccountTooNew =>
      'Available after using the app longer';

  @override
  String get featureGateReasonLowEffectiveness =>
      'This feature needs improvement';

  @override
  String get featureGateReasonUnknown => 'This feature is unavailable';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDesc =>
      'Manage workout reminders, streak alerts, and more';

  @override
  String get frequencyCaps => 'Frequency Caps';

  @override
  String get frequencyCapsDescription =>
      'Limit notifications to prevent fatigue';

  @override
  String get maxPerDay => 'Max Per Day';

  @override
  String get maxPerWeek => 'Max Per Week';

  @override
  String get maxPerWeekDescription =>
      'Research shows >5/week increases quit risk by 64%';

  @override
  String get minIntervalHours => 'Minimum Interval (hours)';

  @override
  String get minIntervalHoursDescription =>
      'Minimum time between notifications (prevents spam)';

  @override
  String get notificationsPerDay => 'notifications/day';

  @override
  String get notificationsPerWeek => 'notifications/week';

  @override
  String get exceedsResearchLimit =>
      '⚠️ >5/week increases quit risk by 64% (research-backed)';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get quietHoursDescription => 'Set Do Not Disturb windows per category';

  @override
  String get quietHoursStart => 'Start Time';

  @override
  String get quietHoursEnd => 'End Time';

  @override
  String get allowPriorityBypass => 'Allow Priority Bypass';

  @override
  String get privacyAndGDPR => 'Privacy & GDPR';

  @override
  String get consentStatus => 'Consent Status';

  @override
  String get consentGiven => 'Consent Given';

  @override
  String get consentNotGiven => 'Consent Not Given';

  @override
  String get giveConsent => 'Give Consent';

  @override
  String get revokeConsent => 'Revoke Consent';

  @override
  String get enableAnalytics => 'Enable Analytics';

  @override
  String get analyticsDescription =>
      'Help improve the app by sharing usage data';

  @override
  String get dataRetention => 'Data Retention';

  @override
  String dataRetentionDays(int days) {
    return '$days days';
  }

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataWarning =>
      'This will permanently delete all notification data. This action CANNOT be undone!';

  @override
  String get deleteAllDataConfirm => 'Type DELETE to confirm';

  @override
  String lastSyncedAt(String time) {
    return 'Last synced: $time';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get resetToDefaultsConfirm =>
      'Reset all notification settings to defaults?';

  @override
  String get frequencyCapPresets => 'Presets';

  @override
  String get presetConservative => 'Conservative (2/day, 3/week)';

  @override
  String get presetBalanced => 'Balanced (3/day, 5/week)';

  @override
  String get presetAggressive => 'Aggressive (5/day, 10/week)';

  @override
  String get presetMinimal => 'Minimal (1/day, 2/week)';

  @override
  String get quietHoursPresets => 'Presets';

  @override
  String get presetOvernight => 'Overnight (10pm - 8am)';

  @override
  String get presetWorkHours => 'Work Hours (9am - 5pm)';

  @override
  String get presetWeekendMorning => 'Weekend Morning (Sat-Sun 8am - 12pm)';

  @override
  String get presetSiesta => 'Siesta (2pm - 4pm)';

  @override
  String get categorySpecificSettings => 'Category-Specific Settings';

  @override
  String get recoveryAlerts => 'Recovery Alerts';

  @override
  String get privacyConsentDialogTitle => 'Privacy & Data Collection';

  @override
  String get privacyConsentDialogBody =>
      'We collect notification delivery times, types, and read status to improve the app. Your workout data stays on your device.\n\nYou can revoke consent anytime in Settings.';

  @override
  String get iConsentToDataCollection => 'I consent to data collection';

  @override
  String get acceptConsent => 'Accept';

  @override
  String get declineConsent => 'Decline';

  @override
  String get syncingSettings => 'Syncing settings...';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get dailyWorkoutRemindersDescription =>
      'Get reminded to complete your daily workouts';

  @override
  String get recoveryAlertsDescription =>
      'Notifications when you have days to recover';

  @override
  String get streakMotivationDescription =>
      'Stay motivated with your active workout streak';

  @override
  String get timingPreferences => 'Timing Preferences';

  @override
  String get preferredTime => 'Preferred Time';

  @override
  String get smartScheduling => 'Smart Scheduling';

  @override
  String get smartSchedulingDescription =>
      'AI learns your habits and schedules notifications optimally';

  @override
  String get maxPerDayDescription => 'Maximum notifications per day';

  @override
  String get quietHoursWindow => 'Quiet Hours Window';

  @override
  String get enableDoNotDisturb => 'Enable Do Not Disturb';

  @override
  String get doNotDisturbDescription =>
      'Silence notifications during specific hours';

  @override
  String get viewConsent => 'View';

  @override
  String get dataRetentionPeriod => 'Data Retention Period';

  @override
  String get lastSynced => 'Last Synced';

  @override
  String get neverSynced => 'Never synced';

  @override
  String get outOfSync => 'Out of Sync';

  @override
  String get outOfSyncDescription => 'Local and cloud settings are different';

  @override
  String get resetToDefaultsDescription =>
      'Restore all settings to factory defaults';

  @override
  String get deleteAllDataDescription =>
      'Permanently delete all notification data';

  @override
  String get custom => 'Custom';

  @override
  String get allDataDeleted => 'All notification data deleted';

  @override
  String get privacyConsent => 'Privacy Consent';

  @override
  String get consentDescription =>
      'By enabling notifications, you consent to receive personalized workout reminders, recovery alerts, and streak motivation. Your notification preferences and history are stored locally and synced to the cloud for cross-device access. You can revoke consent at any time by disabling notifications or deleting all data.';

  @override
  String get consentVersion => 'Consent Version';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get supplementReminders => 'Supplement Reminders';

  @override
  String get supplementRemindersDescription =>
      'Get reminded to take your supplements (pre-workout, protein, etc.)';

  @override
  String get notificationHistory => 'Notification History';

  @override
  String get searchHistory => 'Search history...';

  @override
  String get showAll => 'Show All';

  @override
  String get unreadOnly => 'Unread Only';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get settingsVersion => 'Settings Version';

  @override
  String get migrationRequired => 'Migration Required';

  @override
  String get migrateNow => 'Migrate Now';

  @override
  String get migrationInProgress => 'Migrating settings...';

  @override
  String get migrationComplete => 'Migration Complete';

  @override
  String get useDefaultTime => 'Use default time';

  @override
  String get pr_celebration_title => 'New Personal Record!';

  @override
  String get pr_previous_value => 'Previous';

  @override
  String get pr_new_value => 'New';

  @override
  String get continue_text => 'Continue';

  @override
  String get near_pr_so_close => 'So close to a PR!';

  @override
  String get near_pr_almost_there => 'You\'re almost there!';

  @override
  String get near_pr_keep_pushing => 'Keep pushing!';

  @override
  String get near_pr_to_go => 'to go';

  @override
  String get recovery_tier_basic => 'Basic';

  @override
  String get recovery_tier_intermediate => 'Intermediate';

  @override
  String get recovery_tier_advanced => 'Advanced';

  @override
  String get recovery_tier_basic_desc =>
      'Overall readiness score based on workout frequency';

  @override
  String get recovery_tier_intermediate_desc =>
      'Per-muscle recovery status with volume tracking';

  @override
  String get recovery_tier_advanced_desc =>
      'Overtraining detection using HRV + TSB metrics';

  @override
  String get readiness_optimal => 'Optimal';

  @override
  String get readiness_good => 'Good';

  @override
  String get readiness_moderate => 'Moderate';

  @override
  String get readiness_low => 'Low';

  @override
  String get readiness_very_low => 'Very Low';

  @override
  String get readiness_locked => 'Locked';

  @override
  String get muscle_group_chest => 'Chest';

  @override
  String get muscle_group_back => 'Back';

  @override
  String get muscle_group_shoulders => 'Shoulders';

  @override
  String get muscle_group_biceps => 'Biceps';

  @override
  String get muscle_group_triceps => 'Triceps';

  @override
  String get muscle_group_legs => 'Legs';

  @override
  String get muscle_group_core => 'Core';

  @override
  String get recovery_fully_recovered => 'Fully Recovered';

  @override
  String get recovery_recovered => 'Recovered';

  @override
  String get recovery_partially_recovered => 'Partially Recovered';

  @override
  String get recovery_fatigued => 'Fatigued';

  @override
  String get risk_level_low => 'Low Risk';

  @override
  String get risk_level_moderate => 'Moderate Risk';

  @override
  String get risk_level_high => 'High Risk';

  @override
  String get risk_level_very_high => 'Very High Risk';

  @override
  String get training_load_very_fresh => 'Very Fresh';

  @override
  String get training_load_optimal => 'Optimal';

  @override
  String get training_load_normal => 'Normal Load';

  @override
  String get training_load_moderate_fatigue => 'Moderate Fatigue';

  @override
  String get training_load_high_fatigue => 'High Fatigue';

  @override
  String get training_load_very_high_fatigue => 'Very High Fatigue';

  @override
  String get tier_workouts_label => 'Workouts';

  @override
  String get tier_days_label => 'Days of Data';

  @override
  String get tier_unlocked => 'Unlocked!';

  @override
  String get tier_unlock_message => 'This tier is now available';

  @override
  String tier_unlock_requirement(int workouts, int days) {
    return 'Complete $workouts workouts over $days days to unlock';
  }

  @override
  String get migrateWorkoutHistory => 'Migrate Workout History';

  @override
  String get migrationWarning =>
      'This will migrate all your historical workout data to the new analytics system.';

  @override
  String get migrationDescription =>
      'This is a one-time operation that analyzes all past workouts and creates detailed exercise history. Your original workouts remain unchanged.';

  @override
  String get migrate => 'Migrate';

  @override
  String get migratingWorkouts => 'Migrating Workouts...';

  @override
  String get workoutsProcessed => 'Workouts Processed';

  @override
  String get uniqueExercises => 'Unique Exercises';

  @override
  String get skipped => 'Skipped';

  @override
  String get migrationFailed => 'Migration Failed';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryAnotherSearch =>
      'Try searching for a different exercise or muscle group';

  @override
  String get months => 'Months';

  @override
  String get noDataForTimeframe => 'No data available for this timeframe';

  @override
  String get tryDifferentTimeframe =>
      'Try selecting a different timeframe to see your progress';

  @override
  String get volumeRecord => 'Volume Record';

  @override
  String get heaviestSingleSet => 'Heaviest single set';

  @override
  String get calculatedMaxStrength => 'Calculated max strength';

  @override
  String get highestSingleWorkout => 'Highest single workout';

  @override
  String get setsRecord => 'Sets Record';

  @override
  String get mostSetsInOneWorkout => 'Most sets in one workout';

  @override
  String get activityStatistics => 'Activity Statistics';

  @override
  String get averageLast4Weeks => 'Average (last 4 weeks)';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get completeWorkoutsToTrackRecords =>
      'Complete workouts to track records';

  @override
  String get noWorkoutHistory => 'No workout history';

  @override
  String get noWorkoutHistoryYet => 'No workout history yet';

  @override
  String get completeWorkoutToSeeHistory => 'Complete a workout to see history';

  @override
  String get pr => 'PR';

  @override
  String get records => 'Records';

  @override
  String get expandAll => 'Expand All';

  @override
  String get collapseAll => 'Collapse All';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get correctionSavedLocally => 'Correction saved locally';

  @override
  String get correctMuscleGroup => 'Correct Muscle Group';

  @override
  String get currentMuscleGroup => 'Current Muscle Group';

  @override
  String get selectMuscleGroup => 'Select Muscle Group';

  @override
  String get saveCorrection => 'Save Correction';

  @override
  String get feedbackSubmittedSuccess =>
      'Feedback submitted! You\'ll be notified when admin reviews it.';

  @override
  String get reportToAdmin => 'Report to Admin?';

  @override
  String get reportToAdminExplanation =>
      'Your correction is already saved locally. Would you like to report this to the admin team so they can fix it globally for all users?';

  @override
  String get adminWillReviewNotification =>
      'An admin will review your suggestion and you\'ll receive a notification with their decision.';

  @override
  String get noKeepLocal => 'No, Keep Local';

  @override
  String get yesReportToAdmin => 'Yes, Report';

  @override
  String get viewModeByMuscleGroup => 'By Muscle Group';

  @override
  String get viewModeByDate => 'By Date';

  @override
  String get consistencyScore => 'Consistency Score';

  @override
  String get scoreRatingExcellent => 'Excellent';

  @override
  String get scoreRatingGreat => 'Great';

  @override
  String get scoreRatingGood => 'Good';

  @override
  String get scoreRatingFair => 'Fair';

  @override
  String get scoreRatingNeedsImprovement => 'Needs Improvement';

  @override
  String get frequencyScore => 'Frequency';

  @override
  String get restScore => 'Rest';

  @override
  String get volumeScore => 'Volume';

  @override
  String get progressionScore => 'Progression';

  @override
  String get overtrainingRisk => 'Overtraining Risk';

  @override
  String get riskLow => 'Low';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskHigh => 'High';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get workoutsPerWeek => 'workouts/week';

  @override
  String get restDaysPerWeek => 'rest days/week';

  @override
  String get weeklyStats => 'Weekly Stats (Last 4 Weeks)';

  @override
  String get aiCoachChatWelcome => 'Chat with AI Coach';

  @override
  String get aiCoachChatDescription =>
      'Ask me about your workouts, progression, and recovery';

  @override
  String get aiCoachQuestionProgress => 'How am I progressing?';

  @override
  String get aiCoachQuestionRest => 'Should I rest today?';

  @override
  String get aiCoachQuestionVolume => 'Am I training too much?';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to delete all conversation history?';

  @override
  String get aiCoachRespondingHint => 'AI is responding...';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get mostUsed => 'Most Used';

  @override
  String get recent => 'Recent';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get matchBreakdownTitle => 'Match Breakdown';

  @override
  String get matchBreakdownPrimaryMuscles => 'Primary Muscles';

  @override
  String get matchBreakdownEquipment => 'Equipment';

  @override
  String get matchBreakdownMovementPattern => 'Movement Pattern';

  @override
  String get matchBreakdownSecondaryMuscles => 'Secondary Muscles';

  @override
  String get matchBreakdownCategory => 'Category';

  @override
  String get matchBreakdownTotalScore => 'Total Score';

  @override
  String get matchBreakdownScore => 'Score';

  @override
  String get matchBreakdownWeight => 'Weight';

  @override
  String get matchBreakdownPrimaryMusclesDesc => 'Pectorals, Deltoids';

  @override
  String get matchBreakdownEquipmentDesc => 'Barbell → Dumbbell (compatible)';

  @override
  String get matchBreakdownMovementPatternDesc => 'Push pattern match';

  @override
  String get matchBreakdownSecondaryMusclesDesc => 'Different activation';

  @override
  String get matchBreakdownCategoryDesc => 'Chest vs Shoulders';

  @override
  String get reportError => 'Report Error';

  @override
  String get reportErrorTitle => 'Report Exercise Error';

  @override
  String get reportErrorDescription =>
      'Found incorrect information? Let us know and we\'ll review it.';

  @override
  String get selectFieldToCorrect => 'Select field to correct';

  @override
  String get reasonForChange => 'Reason for change';

  @override
  String get reasonHint =>
      'Explain why this change is needed (min 10 characters)';

  @override
  String get submitCorrection => 'Submit Correction';

  @override
  String get patchSubmittedSuccess =>
      'Correction submitted successfully! It will be reviewed by admins.';

  @override
  String get patchSubmittedLocalSuccess =>
      'Correction applied locally. Your view is updated immediately.';

  @override
  String get patchSubmissionError => 'Failed to submit correction';

  @override
  String get reasonTooShort => 'Reason must be at least 10 characters';

  @override
  String get duplicatePatchError =>
      'You already have a pending correction for this field';

  @override
  String get patchStatusPending => 'Pending Review';

  @override
  String get patchStatusApproved => 'Approved';

  @override
  String get patchStatusRejected => 'Rejected';

  @override
  String get patchStatusAutoRejected => 'Auto-Rejected';

  @override
  String get patchStatusExpired => 'Expired';

  @override
  String get myCorrections => 'My Corrections';

  @override
  String get noPatchesYet => 'No corrections submitted yet';

  @override
  String get noPatchesDescription =>
      'There are no exercise corrections pending review';

  @override
  String patchesCount(int count) {
    return '$count correction(s)';
  }

  @override
  String pendingPatchesCount(int count) {
    return '$count pending';
  }

  @override
  String get patchApprovedMessage => 'Your correction was approved!';

  @override
  String get patchRejectedMessage => 'Your correction was rejected';

  @override
  String get patchExpiredMessage => 'This correction expired after 30 days';

  @override
  String get adminNote => 'Admin note';

  @override
  String get rejectReason => 'Rejection reason';

  @override
  String daysUntilExpiration(int days) {
    return 'Expires in $days day(s)';
  }

  @override
  String get patchExpired => 'Expired';

  @override
  String get viewPatchDetails => 'View Details';

  @override
  String get patchDetailsTitle => 'Correction Details';

  @override
  String get fieldName => 'Field';

  @override
  String get oldValue => 'Old value';

  @override
  String get reviewedAt => 'Reviewed';

  @override
  String get pendingReview => 'Pending admin review';

  @override
  String get approvedAndApplied => 'Approved and applied to database';

  @override
  String get rejectedNotApplied => 'Rejected - not applied';

  @override
  String get expiredNotReviewed => 'Expired without review';

  @override
  String get reportExerciseError => 'Report Exercise Error';

  @override
  String get reportErrorSubtitle => 'Help improve our exercise database';

  @override
  String get pleaseSelectField => 'Please select a field';

  @override
  String get enterCorrectedValue => 'Enter the corrected value';

  @override
  String get pleaseEnterNewValue => 'Please enter a new value';

  @override
  String get newValueMustDiffer => 'New value must be different from current';

  @override
  String get reason => 'Reason';

  @override
  String get explainWhyCorrection => 'Explain why this correction is needed';

  @override
  String get pleaseProvideReason => 'Please provide a reason';

  @override
  String get exercisePatchReview => 'Exercise Patch Review';

  @override
  String get pendingPatches => 'Pending Patches';

  @override
  String get reviewedPatches => 'Reviewed Patches';

  @override
  String get noPatches => 'No patches to review';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get pendingCount => 'Pending';

  @override
  String get approvedCount => 'Approved';

  @override
  String get rejectedCount => 'Rejected';

  @override
  String get expiredCount => 'Expired';

  @override
  String get refreshPatches => 'Refresh patches';

  @override
  String get approvePatch => 'Approve';

  @override
  String get rejectPatch => 'Reject';

  @override
  String get patchApproved => 'Patch approved successfully';

  @override
  String get patchRejected => 'Patch rejected successfully';

  @override
  String get patchActionError => 'Failed to process patch';
}
