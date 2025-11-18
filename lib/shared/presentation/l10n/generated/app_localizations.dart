import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Main application title
  ///
  /// In en, this message translates to:
  /// **'FitLog Pro'**
  String get appTitle;

  /// Welcome message on the main screen
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get welcome;

  /// Welcome description on login screen
  ///
  /// In en, this message translates to:
  /// **'Track workouts, time your rest periods, and sync with Apple Health.'**
  String get welcomeDescription;

  /// Title for the onboarding welcome step
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Workout Hub'**
  String get onboardingWelcomeTitle;

  /// Description for the onboarding welcome step
  ///
  /// In en, this message translates to:
  /// **'Track your progress, achieve your goals with the most comprehensive workout tracker'**
  String get onboardingWelcomeDescription;

  /// Skip button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Back button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// Next button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Start button in onboarding final step
  ///
  /// In en, this message translates to:
  /// **'Start!'**
  String get onboardingStart;

  /// AI Coach onboarding title
  ///
  /// In en, this message translates to:
  /// **'AI Coach Setup'**
  String get onboardingTitle;

  /// Experience level selection title
  ///
  /// In en, this message translates to:
  /// **'What\'s your training experience?'**
  String get onboardingExperienceTitle;

  /// Experience level selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your insights'**
  String get onboardingExperienceSubtitle;

  /// Beginner experience level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginnerLevel;

  /// Beginner level description
  ///
  /// In en, this message translates to:
  /// **'0-6 months of training'**
  String get beginnerLevelDescription;

  /// Intermediate experience level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediateLevel;

  /// Intermediate level description
  ///
  /// In en, this message translates to:
  /// **'6-24 months of training'**
  String get intermediateLevelDescription;

  /// Advanced experience level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedLevel;

  /// Advanced level description
  ///
  /// In en, this message translates to:
  /// **'2+ years of training'**
  String get advancedLevelDescription;

  /// Exit confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit Onboarding?'**
  String get onboardingExitTitle;

  /// Exit confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'You can always set up AI Coach later in Settings'**
  String get onboardingExitMessage;

  /// Goal selection title
  ///
  /// In en, this message translates to:
  /// **'What\'s your primary goal?'**
  String get onboardingGoalTitle;

  /// Goal selection subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor insights to your training focus'**
  String get onboardingGoalSubtitle;

  /// Hypertrophy goal
  ///
  /// In en, this message translates to:
  /// **'Muscle Growth'**
  String get hypertrophyGoal;

  /// Hypertrophy goal description
  ///
  /// In en, this message translates to:
  /// **'8-12 reps, 60-90s rest'**
  String get hypertrophyGoalDescription;

  /// Strength goal
  ///
  /// In en, this message translates to:
  /// **'Max Strength'**
  String get strengthGoal;

  /// Strength goal description
  ///
  /// In en, this message translates to:
  /// **'1-5 reps, 3-5min rest'**
  String get strengthGoalDescription;

  /// Endurance goal
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get enduranceGoal;

  /// Endurance goal description
  ///
  /// In en, this message translates to:
  /// **'15+ reps, <30s rest'**
  String get enduranceGoalDescription;

  /// Quick win onboarding title
  ///
  /// In en, this message translates to:
  /// **'Your Quick Win'**
  String get onboardingQuickWinTitle;

  /// Quick win onboarding subtitle
  ///
  /// In en, this message translates to:
  /// **'We analyzed your workouts. Here\'s your first insight!'**
  String get onboardingQuickWinSubtitle;

  /// Analyzing workouts loading message
  ///
  /// In en, this message translates to:
  /// **'Analyzing your workouts...'**
  String get analyzingWorkouts;

  /// No workouts message
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// No workouts empty state description
  ///
  /// In en, this message translates to:
  /// **'Start training and AI Coach will provide personalized insights!'**
  String get noWorkoutsYetDescription;

  /// Beginner quick win insight title
  ///
  /// In en, this message translates to:
  /// **'Great Start!'**
  String get beginnerQuickWinTitle;

  /// Beginner quick win insight description
  ///
  /// In en, this message translates to:
  /// **'You\'re building solid training foundations. Consistency is key!'**
  String get beginnerQuickWinDescription;

  /// Beginner quick win recommendation
  ///
  /// In en, this message translates to:
  /// **'Focus on mastering proper form before increasing weight'**
  String get beginnerQuickWinRecommendation;

  /// Intermediate quick win insight title
  ///
  /// In en, this message translates to:
  /// **'Balance Your Volume'**
  String get intermediateQuickWinTitle;

  /// Intermediate quick win insight description
  ///
  /// In en, this message translates to:
  /// **'We detected potential muscle group imbalances in your training'**
  String get intermediateQuickWinDescription;

  /// Intermediate quick win recommendation
  ///
  /// In en, this message translates to:
  /// **'Add 2-3 more sets for lagging muscle groups each week'**
  String get intermediateQuickWinRecommendation;

  /// Advanced quick win insight title
  ///
  /// In en, this message translates to:
  /// **'Break the Plateau'**
  String get advancedQuickWinTitle;

  /// Advanced quick win insight description
  ///
  /// In en, this message translates to:
  /// **'Your progress has stalled. Time to implement periodization!'**
  String get advancedQuickWinDescription;

  /// Advanced quick win recommendation
  ///
  /// In en, this message translates to:
  /// **'Try deload weeks (40-50% volume) every 4-6 weeks for recovery'**
  String get advancedQuickWinRecommendation;

  /// Notifications onboarding title
  ///
  /// In en, this message translates to:
  /// **'Stay on Track'**
  String get onboardingNotificationsTitle;

  /// Notifications onboarding subtitle
  ///
  /// In en, this message translates to:
  /// **'Get timely insights to optimize your training'**
  String get onboardingNotificationsSubtitle;

  /// First notification benefit title
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get notificationBenefit1Title;

  /// First notification benefit description
  ///
  /// In en, this message translates to:
  /// **'Receive AI-powered coaching tips when you need them most'**
  String get notificationBenefit1Description;

  /// Second notification benefit title
  ///
  /// In en, this message translates to:
  /// **'Progress Updates'**
  String get notificationBenefit2Title;

  /// Second notification benefit description
  ///
  /// In en, this message translates to:
  /// **'Get notified when you break personal records or hit milestones'**
  String get notificationBenefit2Description;

  /// Third notification benefit title
  ///
  /// In en, this message translates to:
  /// **'Recovery Reminders'**
  String get notificationBenefit3Title;

  /// Third notification benefit description
  ///
  /// In en, this message translates to:
  /// **'Avoid overtraining with smart rest day recommendations'**
  String get notificationBenefit3Description;

  /// Enable notifications button
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Step indicator in onboarding
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// What to expect section title in welcome step
  ///
  /// In en, this message translates to:
  /// **'What to expect:'**
  String get onboardingWhatToExpect;

  /// Title for the mode selection step
  ///
  /// In en, this message translates to:
  /// **'Choose Your Experience'**
  String get onboardingModeTitle;

  /// Base mode option in onboarding
  ///
  /// In en, this message translates to:
  /// **'Base Mode'**
  String get onboardingBaseMode;

  /// Description of base mode in onboarding
  ///
  /// In en, this message translates to:
  /// **'Essential features for effective workouts. Perfect for beginners and focused training.'**
  String get onboardingBaseModeDescription;

  /// Pro mode option in onboarding
  ///
  /// In en, this message translates to:
  /// **'Pro Mode'**
  String get onboardingProMode;

  /// Description of pro mode in onboarding
  ///
  /// In en, this message translates to:
  /// **'Advanced tracking with RPE, TUT, analytics and all features unlocked.'**
  String get onboardingProModeDescription;

  /// Description explaining how mode selection affects app features
  ///
  /// In en, this message translates to:
  /// **'The mode influences which features are visible and available'**
  String get onboardingModeInfluenceDescription;

  /// Title for timer and rest onboarding step
  ///
  /// In en, this message translates to:
  /// **'Timer and Rest'**
  String get onboardingTimerRestTitle;

  /// Description of timer and rest features
  ///
  /// In en, this message translates to:
  /// **'Discover how it works:\\n\\n• Automatic rest timer\\n• Live Activities on iOS\\n• Duration customization\\n• Sounds and notifications\\n• Custom timers per exercise\\n• Background functionality'**
  String get onboardingTimerRestDescription;

  /// Title for advanced features onboarding step
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get onboardingAdvancedFeaturesTitle;

  /// Description of advanced pro features
  ///
  /// In en, this message translates to:
  /// **'Explore Pro features:\\n\\n• Supersets and Dropsets\\n• Rest-Pause and advanced techniques\\n• Analytics and insights\\n• Community suggestions\\n• Automatic warmups\\n• 1-Rep Max calculation\\n• Export and sharing'**
  String get onboardingAdvancedFeaturesDescription;

  /// Congratulations message in onboarding
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get onboardingCongratulations;

  /// Message shown when onboarding is completed
  ///
  /// In en, this message translates to:
  /// **'You have completed the complete FitLog Pro tutorial. Now you\'re ready to start your workouts!'**
  String get onboardingCompletedMessage;

  /// Selected count suffix
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// Title for the features overview step
  ///
  /// In en, this message translates to:
  /// **'Powerful Features'**
  String get onboardingFeaturesTitle;

  /// First feature in onboarding
  ///
  /// In en, this message translates to:
  /// **'Track sets, reps, and weight'**
  String get onboardingFeature1;

  /// Second feature in onboarding
  ///
  /// In en, this message translates to:
  /// **'Rest timer with Live Activities'**
  String get onboardingFeature2;

  /// Third feature in onboarding
  ///
  /// In en, this message translates to:
  /// **'Create and save templates'**
  String get onboardingFeature3;

  /// Fourth feature in onboarding
  ///
  /// In en, this message translates to:
  /// **'Supersets and dropsets'**
  String get onboardingFeature4;

  /// Title for the customization step
  ///
  /// In en, this message translates to:
  /// **'Make It Yours'**
  String get onboardingCustomizeTitle;

  /// Description for the customization step
  ///
  /// In en, this message translates to:
  /// **'Customize timers, sounds, themes and display options to match your training style.'**
  String get onboardingCustomizeDescription;

  /// Title for the get started step
  ///
  /// In en, this message translates to:
  /// **'Ready to Train'**
  String get onboardingGetStartedTitle;

  /// Description for the get started step
  ///
  /// In en, this message translates to:
  /// **'Start with a template or create your own custom workout. Let\'s begin your fitness journey!'**
  String get onboardingGetStartedDescription;

  /// Done button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingDone;

  /// Progress indicator in onboarding
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingProgress(int current, int total);

  /// Title for global onboarding
  ///
  /// In en, this message translates to:
  /// **'Complete FitLog Pro Guide'**
  String get globalOnboardingTitle;

  /// Description for global onboarding
  ///
  /// In en, this message translates to:
  /// **'Learn everything about the app with this interactive step-by-step tutorial'**
  String get globalOnboardingDescription;

  /// Title for toggle panorama step
  ///
  /// In en, this message translates to:
  /// **'Toggle Overview & Customizations'**
  String get togglePanoramaTitle;

  /// Description for toggle panorama step
  ///
  /// In en, this message translates to:
  /// **'Explore all available features and discover how to customize your experience'**
  String get togglePanoramaDescription;

  /// Shows the current mode (Base/Pro)
  ///
  /// In en, this message translates to:
  /// **'Current mode: {mode}'**
  String currentMode(String mode);

  /// Hint about changing toggles in settings
  ///
  /// In en, this message translates to:
  /// **'You can change any toggle anytime from settings ⚙️'**
  String get toggleSettingsHint;

  /// Title for create workout step
  ///
  /// In en, this message translates to:
  /// **'Creating a Workout'**
  String get createWorkoutStepTitle;

  /// Description for create workout step
  ///
  /// In en, this message translates to:
  /// **'Learn how to:\\n\\n• Create a new workout\\n• Use existing templates\\n• Customize the name\\n• Set your goals'**
  String get createWorkoutStepDescription;

  /// Title for add exercise step
  ///
  /// In en, this message translates to:
  /// **'Adding an Exercise'**
  String get addExerciseStepTitle;

  /// Description for add exercise step
  ///
  /// In en, this message translates to:
  /// **'Step-by-step tutorial for:\\n\\n• Searching exercises in database\\n• Adding manual exercises\\n• Setting sets and reps\\n• Configuring weight and RPE\\n• Adding personal notes'**
  String get addExerciseStepDescription;

  /// Title for execute set step
  ///
  /// In en, this message translates to:
  /// **'Executing a Set'**
  String get executeSetStepTitle;

  /// Description for execute set step
  ///
  /// In en, this message translates to:
  /// **'Learn to:\\n\\n• Mark sets as completed\\n• Use Quick Edit for rapid changes\\n• Rate RPE (Pro mode)\\n• Track weight and reps\\n• Handle failed or partial sets'**
  String get executeSetStepDescription;

  /// Title for timer rest step
  ///
  /// In en, this message translates to:
  /// **'Timer & Rest'**
  String get timerRestStepTitle;

  /// Title for advanced features step
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get advancedFeaturesStepTitle;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Onboarding completion message
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed the complete FitLog Pro tutorial. You\'re now ready to start your workouts!'**
  String get onboardingComplete;

  /// Try it out button for interactive demos
  ///
  /// In en, this message translates to:
  /// **'Try it out!'**
  String get onboardingTryItOut;

  /// Instruction for tapping to complete interactive demo
  ///
  /// In en, this message translates to:
  /// **'Tap to complete'**
  String get onboardingTapToComplete;

  /// Title for example workout in demo
  ///
  /// In en, this message translates to:
  /// **'Example Workout'**
  String get onboardingExampleWorkout;

  /// Placeholder for exercise search in demo
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get onboardingSearchExercises;

  /// Example exercise name in demo
  ///
  /// In en, this message translates to:
  /// **'Push ups'**
  String get onboardingMockExercise;

  /// Example exercise description in demo
  ///
  /// In en, this message translates to:
  /// **'Classic bodyweight exercise for chest, shoulders and triceps'**
  String get onboardingMockDescription;

  /// Completed status in interactive demo
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get onboardingCompleted;

  /// Title for the mission section in onboarding welcome
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get onboardingWelcomeMissionTitle;

  /// Mission statement for the app in onboarding welcome
  ///
  /// In en, this message translates to:
  /// **'Your workout companion that never replaces your trainer but provides scientific data to help you reach your goals.'**
  String get onboardingWelcomeMission;

  /// Title for first onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Interactive Tutorial'**
  String get onboardingWelcomeFeature1Title;

  /// Description for first onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Learn by using the app in real time'**
  String get onboardingWelcomeFeature1Description;

  /// Title for second onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Complete Customization'**
  String get onboardingWelcomeFeature2Title;

  /// Description for second onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Discover all toggles and options'**
  String get onboardingWelcomeFeature2Description;

  /// Title for third onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Complete Workflow'**
  String get onboardingWelcomeFeature3Title;

  /// Description for third onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'From setup to execution'**
  String get onboardingWelcomeFeature3Description;

  /// Title for fourth onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Base and Pro Modes'**
  String get onboardingWelcomeFeature4Title;

  /// Description for fourth onboarding welcome feature
  ///
  /// In en, this message translates to:
  /// **'Choose your functionality level'**
  String get onboardingWelcomeFeature4Description;

  /// Call to action text in welcome step
  ///
  /// In en, this message translates to:
  /// **'This tutorial will guide you step by step through all app features. You can skip or repeat any section.'**
  String get onboardingWelcomeCallToAction;

  /// Placeholder text for missing videos in onboarding
  ///
  /// In en, this message translates to:
  /// **'Video Missing'**
  String get onboardingVideoPlaceholder;

  /// Text indicating that tutorial video will be available soon
  ///
  /// In en, this message translates to:
  /// **'Tutorial video coming soon!'**
  String get onboardingVideoComingSoon;

  /// Title for toggle panorama onboarding step
  ///
  /// In en, this message translates to:
  /// **'Toggle Overview & Customizations'**
  String get onboardingTogglePanoramaTitle;

  /// Description for toggle panorama onboarding step
  ///
  /// In en, this message translates to:
  /// **'Explore all available features and discover how to customize your experience'**
  String get onboardingTogglePanoramaDescription;

  /// Title for advanced tracking toggle category
  ///
  /// In en, this message translates to:
  /// **'Advanced Tracking'**
  String get onboardingToggleAdvancedTrackingTitle;

  /// Description for advanced tracking toggle category
  ///
  /// In en, this message translates to:
  /// **'Features for detailed monitoring'**
  String get onboardingToggleAdvancedTrackingDescription;

  /// Title for timer and automation toggle category
  ///
  /// In en, this message translates to:
  /// **'Timer and Automation'**
  String get onboardingToggleTimerAutomationTitle;

  /// Description for timer and automation toggle category
  ///
  /// In en, this message translates to:
  /// **'Automatic rest time management'**
  String get onboardingToggleTimerAutomationDescription;

  /// Title for interface and tips toggle category
  ///
  /// In en, this message translates to:
  /// **'Interface and Tips'**
  String get onboardingToggleInterfaceTitle;

  /// Description for interface and tips toggle category
  ///
  /// In en, this message translates to:
  /// **'User experience customization'**
  String get onboardingToggleInterfaceDescription;

  /// Title for support and assistance toggle category
  ///
  /// In en, this message translates to:
  /// **'Support and Assistance'**
  String get onboardingToggleSupportTitle;

  /// Description for support and assistance toggle category
  ///
  /// In en, this message translates to:
  /// **'Tips and help during workouts'**
  String get onboardingToggleSupportDescription;

  /// First part of toggle settings change information
  ///
  /// In en, this message translates to:
  /// **'You can change any toggle anytime from'**
  String get onboardingToggleSettingsChangePart1;

  /// Second part of toggle settings change information
  ///
  /// In en, this message translates to:
  /// **'Customize Workout'**
  String get onboardingToggleSettingsChangePart2;

  /// Title for exercise template quick selection
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// Quick workout button text
  ///
  /// In en, this message translates to:
  /// **'Quick Workout'**
  String get quickWorkout;

  /// Quick workout subtitle
  ///
  /// In en, this message translates to:
  /// **'Start with empty workout'**
  String get quickWorkoutSubtitle;

  /// Free session button label
  ///
  /// In en, this message translates to:
  /// **'Free Session'**
  String get sessioneLibera;

  /// Suggested label for recommendations
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// Prompt to browse other options
  ///
  /// In en, this message translates to:
  /// **'💡 Not what you wanted?'**
  String get notWhatYouWanted;

  /// Button to browse workout templates
  ///
  /// In en, this message translates to:
  /// **'Browse Templates'**
  String get browseTemplates;

  /// Upper body workout template
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// Upper body workout description
  ///
  /// In en, this message translates to:
  /// **'Chest, Back, Shoulders, Arms'**
  String get upperBodySubtitle;

  /// Lower body workout template
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// Lower body workout description
  ///
  /// In en, this message translates to:
  /// **'Legs, Glutes, Calves'**
  String get lowerBodySubtitle;

  /// Exercise synchronization section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Sync'**
  String get exerciseSync;

  /// Sync status when idle
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get syncIdle;

  /// Sync status when loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get syncLoading;

  /// Sync status when syncing
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncSyncing;

  /// Success message after sync completes
  ///
  /// In en, this message translates to:
  /// **'Sync successful'**
  String get syncSuccess;

  /// Error message when sync fails
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncError(String error);

  /// Message when checking sync status
  ///
  /// In en, this message translates to:
  /// **'Checking status...'**
  String get checkingStatus;

  /// Error message prefix for status errors
  ///
  /// In en, this message translates to:
  /// **'Status error'**
  String get statusError;

  /// Version information section title
  ///
  /// In en, this message translates to:
  /// **'Version Info'**
  String get versionInfo;

  /// Local version label
  ///
  /// In en, this message translates to:
  /// **'Local Version'**
  String get localVersion;

  /// Remote version label
  ///
  /// In en, this message translates to:
  /// **'Remote Version'**
  String get remoteVersion;

  /// Message when update is available
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// Message when checking version
  ///
  /// In en, this message translates to:
  /// **'Checking version...'**
  String get checkingVersion;

  /// Error message for version check failures
  ///
  /// In en, this message translates to:
  /// **'Version check error'**
  String get versionCheckError;

  /// Button to force synchronization
  ///
  /// In en, this message translates to:
  /// **'Force Sync'**
  String get forceSync;

  /// Sync settings button and title
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// Auto sync toggle label
  ///
  /// In en, this message translates to:
  /// **'Auto Sync'**
  String get autoSync;

  /// Auto sync description
  ///
  /// In en, this message translates to:
  /// **'Automatically sync exercises in background'**
  String get autoSyncDescription;

  /// Sync frequency setting label
  ///
  /// In en, this message translates to:
  /// **'Sync Frequency'**
  String get syncFrequency;

  /// Sync frequency option
  ///
  /// In en, this message translates to:
  /// **'Every Hour'**
  String get everyHour;

  /// Sync frequency option
  ///
  /// In en, this message translates to:
  /// **'Every 6 Hours'**
  String get every6Hours;

  /// Sync frequency option
  ///
  /// In en, this message translates to:
  /// **'Every 12 Hours'**
  String get every12Hours;

  /// Sync frequency option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Prefix for custom frequency
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// Unit label for hours
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Dialog title for frequency selection
  ///
  /// In en, this message translates to:
  /// **'Select Sync Frequency'**
  String get selectSyncFrequency;

  /// Cache statistics section title
  ///
  /// In en, this message translates to:
  /// **'Cache Statistics'**
  String get cacheStatistics;

  /// Number of cached exercises label
  ///
  /// In en, this message translates to:
  /// **'Cached Exercises'**
  String get cachedExercises;

  /// Cache size label
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// Last update stat label
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// Loading status text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Time ago suffix
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Confirmation message for clearing cache
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the exercise cache? This will remove all cached exercises and they will be downloaded again on next sync.'**
  String get clearCacheConfirmation;

  /// Description for clear exercise cache option
  ///
  /// In en, this message translates to:
  /// **'Clear cached exercise database and force reload from JSON assets'**
  String get clearExerciseCacheDesc;

  /// Success message after clearing exercise cache
  ///
  /// In en, this message translates to:
  /// **'Exercise cache cleared successfully! Exercises will reload from JSON assets on next use.'**
  String get exerciseCacheCleared;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Generic done/complete button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// HIIT training template
  ///
  /// In en, this message translates to:
  /// **'HIIT Training'**
  String get hiitTraining;

  /// HIIT training description
  ///
  /// In en, this message translates to:
  /// **'High intensity intervals'**
  String get hiitTrainingSubtitle;

  /// Start workout action
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Add new exercise button
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// Complete workout button tooltip
  ///
  /// In en, this message translates to:
  /// **'Complete Workout'**
  String get completeWorkout;

  /// New workout quick action
  ///
  /// In en, this message translates to:
  /// **'New Workout'**
  String get newWorkout;

  /// Workout name input label
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutName;

  /// Hint text for workout name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Session'**
  String get workoutNameHint;

  /// Exercise name field label
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// Exercise name input field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Bench Press'**
  String get exerciseNameHint;

  /// Import workout template screen title
  ///
  /// In en, this message translates to:
  /// **'Import Workout Template'**
  String get importWorkoutTemplate;

  /// Export templates screen title
  ///
  /// In en, this message translates to:
  /// **'Export Templates'**
  String get exportTemplates;

  /// Import format selection label
  ///
  /// In en, this message translates to:
  /// **'Import Format'**
  String get importFormat;

  /// Natural language text import option
  ///
  /// In en, this message translates to:
  /// **'Natural Language'**
  String get naturalLanguageText;

  /// JSON file import option
  ///
  /// In en, this message translates to:
  /// **'JSON File'**
  String get jsonFile;

  /// Workout description input label
  ///
  /// In en, this message translates to:
  /// **'Workout Description'**
  String get workoutDescription;

  /// Workout text input placeholder
  ///
  /// In en, this message translates to:
  /// **'Paste your workout description here...\n\nExample:\nLUNEDÌ - PUSH\nPanca Piana - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg'**
  String get pasteWorkoutHere;

  /// AI parsing instructions label
  ///
  /// In en, this message translates to:
  /// **'AI Parsing Instructions'**
  String get aiParsingInstructions;

  /// AI instructions input hint
  ///
  /// In en, this message translates to:
  /// **'Optional: Provide additional context for better parsing (e.g., language, units, custom exercise names)'**
  String get aiInstructionsHint;

  /// AI instructions example text
  ///
  /// In en, this message translates to:
  /// **'Example: \"Text is in Italian, weights are in kg, \'Panca\' means Bench Press\"'**
  String get aiInstructionsExample;

  /// JSON file selection label
  ///
  /// In en, this message translates to:
  /// **'Select JSON File'**
  String get selectJsonFile;

  /// File selection button text
  ///
  /// In en, this message translates to:
  /// **'Tap to select file'**
  String get tapToSelectFile;

  /// Supported file formats info
  ///
  /// In en, this message translates to:
  /// **'Supports .json and .txt files'**
  String get supportedFormats;

  /// Start import button text
  ///
  /// In en, this message translates to:
  /// **'Start Import'**
  String get startImport;

  /// Exercise disambiguation section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Disambiguation'**
  String get exerciseDisambiguation;

  /// Percentage conversion section title
  ///
  /// In en, this message translates to:
  /// **'Percentage Weight Conversion'**
  String get percentageConversion;

  /// Continue import button text
  ///
  /// In en, this message translates to:
  /// **'Continue Import'**
  String get continueImport;

  /// Finalize import button text
  ///
  /// In en, this message translates to:
  /// **'Finalize Import'**
  String get finalizeImport;

  /// Import success message
  ///
  /// In en, this message translates to:
  /// **'Import completed successfully!'**
  String get importSuccessful;

  /// Import in progress message
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// Import completed title
  ///
  /// In en, this message translates to:
  /// **'Import Completed'**
  String get importCompleted;

  /// Success message showing number of templates imported
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template imported successfully!} other{{count} templates imported successfully!}}'**
  String templatesImportedSuccessfully(int count);

  /// Exporting progress text
  ///
  /// In en, this message translates to:
  /// **'Exporting Templates'**
  String get exportingTemplates;

  /// Templates selection count suffix
  ///
  /// In en, this message translates to:
  /// **'templates selected'**
  String get templatesSelected;

  /// Free account tier label
  ///
  /// In en, this message translates to:
  /// **'Free Account'**
  String get freeAccount;

  /// Premium account tier label
  ///
  /// In en, this message translates to:
  /// **'Premium Account'**
  String get premiumAccount;

  /// Free tier export limitations
  ///
  /// In en, this message translates to:
  /// **'Limited to 1 template export, no analytics data'**
  String get freeExportLimitations;

  /// Premium tier export features
  ///
  /// In en, this message translates to:
  /// **'Batch export, analytics data, multiple formats'**
  String get premiumExportFeatures;

  /// Upgrade button
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Download JSON button text
  ///
  /// In en, this message translates to:
  /// **'Download JSON'**
  String get downloadJson;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully!'**
  String get exportSuccessful;

  /// Export failure message
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailed;

  /// Export file sharing text
  ///
  /// In en, this message translates to:
  /// **'FitLog Pro Workout Templates Export'**
  String get gymbroTemplatesExport;

  /// Export limits dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Limits'**
  String get exportLimits;

  /// Export limits description
  ///
  /// In en, this message translates to:
  /// **'Your current export limits:'**
  String get yourCurrentLimits;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Quota limit reached title
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// Upgrade prompt for export limits
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium to export more templates with analytics data.'**
  String get upgradeToExportMore;

  /// Sign in requirement message
  ///
  /// In en, this message translates to:
  /// **'Please sign in to use export features'**
  String get pleaseSignIn;

  /// AI prompt helper screen title
  ///
  /// In en, this message translates to:
  /// **'AI Prompt Helper'**
  String get aiPromptHelper;

  /// Create new workout tab
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNew;

  /// Convert existing workout tab
  ///
  /// In en, this message translates to:
  /// **'Convert Existing'**
  String get convertExisting;

  /// How to use tab
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// Create new workout section title
  ///
  /// In en, this message translates to:
  /// **'Create New Workout with AI'**
  String get createNewWorkout;

  /// Create new workout description
  ///
  /// In en, this message translates to:
  /// **'Generate a custom prompt to create workout templates with external AI services'**
  String get createNewWorkoutDesc;

  /// Workout type selection label
  ///
  /// In en, this message translates to:
  /// **'Select Workout Type'**
  String get selectWorkoutType;

  /// Difficulty selection label
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty Level'**
  String get selectDifficulty;

  /// Beginner difficulty level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Intermediate difficulty level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Advanced section header
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Button to send test notification
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// Description for test notification button
  ///
  /// In en, this message translates to:
  /// **'Send a test notification to verify that notifications are working correctly'**
  String get testNotificationDescription;

  /// Confirmation that test notification was sent
  ///
  /// In en, this message translates to:
  /// **'Test Notification Sent!'**
  String get testNotificationSent;

  /// Instructions after sending test notification
  ///
  /// In en, this message translates to:
  /// **'Check your notification center to verify it works'**
  String get testNotificationSentDescription;

  /// Toggle for PR (Personal Record) achievement notifications
  ///
  /// In en, this message translates to:
  /// **'New Personal Records'**
  String get prNotifications;

  /// Description for PR notification toggle
  ///
  /// In en, this message translates to:
  /// **'Get notified when you set a new personal record'**
  String get prNotificationsDescription;

  /// Toggle for workout streak achievement notifications (7/30/100 days)
  ///
  /// In en, this message translates to:
  /// **'Workout Streaks'**
  String get streakAchievements;

  /// Description for workout streak notification toggle
  ///
  /// In en, this message translates to:
  /// **'Celebrate your workout consistency milestones'**
  String get streakAchievementsDescription;

  /// Toggle for goal completion notifications (volume, frequency targets)
  ///
  /// In en, this message translates to:
  /// **'Goal Completions'**
  String get goalCompletions;

  /// Description for goal completion notification toggle
  ///
  /// In en, this message translates to:
  /// **'Reach your monthly volume and workout goals'**
  String get goalCompletionsDescription;

  /// Toggle for milestone achievement notifications (50/100/500 workouts)
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// Description for milestone notification toggle
  ///
  /// In en, this message translates to:
  /// **'Track major workout count achievements'**
  String get milestonesDescription;

  /// Custom request input label
  ///
  /// In en, this message translates to:
  /// **'Custom Request (Optional)'**
  String get customRequest;

  /// Custom request input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Focus on compound movements, 45-minute workout, minimal equipment'**
  String get customRequestHint;

  /// Generated prompt section title
  ///
  /// In en, this message translates to:
  /// **'Generated AI Prompt'**
  String get generatedPrompt;

  /// Convert existing workout section title
  ///
  /// In en, this message translates to:
  /// **'Convert Existing Workout'**
  String get convertExistingWorkout;

  /// Convert existing workout description
  ///
  /// In en, this message translates to:
  /// **'Convert your existing workout text into FitLog Pro JSON format'**
  String get convertExistingDesc;

  /// Paste workout text label
  ///
  /// In en, this message translates to:
  /// **'Paste Your Workout Text'**
  String get pasteWorkoutText;

  /// Workout text input hint
  ///
  /// In en, this message translates to:
  /// **'MONDAY - PUSH\nBench Press - 3 min\nSet1 x 5: 80kg\nSet2 x 5: 82.5kg\n...'**
  String get workoutTextHint;

  /// Generate conversion prompt button
  ///
  /// In en, this message translates to:
  /// **'Generate Conversion Prompt'**
  String get generateConversionPrompt;

  /// Conversion prompt section title
  ///
  /// In en, this message translates to:
  /// **'Conversion Prompt'**
  String get conversionPrompt;

  /// Step by step guide title
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step Guide'**
  String get stepByStepGuide;

  /// Follow steps description
  ///
  /// In en, this message translates to:
  /// **'Follow these simple steps to create workout templates with AI'**
  String get followTheseSteps;

  /// Troubleshooting section title
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshooting;

  /// Prompt to copy label
  ///
  /// In en, this message translates to:
  /// **'Prompt to Copy'**
  String get promptToCopy;

  /// Copy prompt tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy Prompt'**
  String get copyPrompt;

  /// Quick AI access section title
  ///
  /// In en, this message translates to:
  /// **'Quick AI Access'**
  String get quickAIAccess;

  /// Copy prompt and open AI button
  ///
  /// In en, this message translates to:
  /// **'Copy Prompt & Open AI Service'**
  String get copyPromptAndOpenAI;

  /// Instructions label
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// Conversion instructions text
  ///
  /// In en, this message translates to:
  /// **'1. Copy the prompt above 2. Open an AI service 3. Paste and send 4. Copy the JSON result 5. Import to FitLog Pro'**
  String get conversionInstructions;

  /// Creation instructions text
  ///
  /// In en, this message translates to:
  /// **'1. Copy the prompt above 2. Open an AI service 3. Paste and send 4. Copy the JSON result 5. Import to FitLog Pro'**
  String get creationInstructions;

  /// Prompt copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Prompt Copied!'**
  String get promptCopied;

  /// Prompt copied description
  ///
  /// In en, this message translates to:
  /// **'The AI prompt has been copied to your clipboard.'**
  String get promptCopiedDesc;

  /// Next steps label
  ///
  /// In en, this message translates to:
  /// **'Next steps:'**
  String get nextSteps;

  /// Step 1 instruction
  ///
  /// In en, this message translates to:
  /// **'Open your preferred AI service (ChatGPT, Claude, etc.)'**
  String get step1OpenAI;

  /// Step 2 instruction
  ///
  /// In en, this message translates to:
  /// **'Paste the copied prompt and send'**
  String get step2PastePrompt;

  /// Step 3 instruction
  ///
  /// In en, this message translates to:
  /// **'Copy the JSON response from the AI'**
  String get step3CopyJSON;

  /// Step 4 instruction
  ///
  /// In en, this message translates to:
  /// **'Return to FitLog Pro and use \'Import Template\''**
  String get step4ReturnToApp;

  /// Button to dismiss explanation dialog
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// Open ChatGPT button
  ///
  /// In en, this message translates to:
  /// **'Open ChatGPT'**
  String get openChatGPT;

  /// Cannot open URL error
  ///
  /// In en, this message translates to:
  /// **'Cannot open this URL'**
  String get cannotOpenUrl;

  /// Error opening URL message
  ///
  /// In en, this message translates to:
  /// **'Error opening URL'**
  String get errorOpeningUrl;

  /// Please enter workout text message
  ///
  /// In en, this message translates to:
  /// **'Please enter workout text to convert'**
  String get pleaseEnterWorkoutText;

  /// Label for exercise category selection
  ///
  /// In en, this message translates to:
  /// **'Exercise Category'**
  String get exerciseCategory;

  /// Plural form of exercise sets
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get sets;

  /// Button to add a new set
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// Weight metric label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Label for repetitions (lowercase)
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get reps;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Notes input field hint
  ///
  /// In en, this message translates to:
  /// **'Add form cues, progression notes, etc.'**
  String get notesHint;

  /// Single exercise type
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get exerciseTypeSingle;

  /// Superset exercise type
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get exerciseTypeSuperset;

  /// Dropset exercise type
  ///
  /// In en, this message translates to:
  /// **'DropSet'**
  String get exerciseTypeDropset;

  /// Rest-pause exercise type
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause'**
  String get exerciseTypeRestPause;

  /// Chest exercise category
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get exerciseCategoryChest;

  /// Back exercise category
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get exerciseCategoryBack;

  /// Shoulders exercise category
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get exerciseCategoryShoulders;

  /// Arms exercise category
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get exerciseCategoryArms;

  /// Legs exercise category
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get exerciseCategoryLegs;

  /// Abs exercise category
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get exerciseCategoryAbs;

  /// Cardio exercise category
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get exerciseCategoryCardio;

  /// Other exercise category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get exerciseCategoryOther;

  /// Planned workout status
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get workoutStatusPlanned;

  /// In progress workout status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get workoutStatusInProgress;

  /// Completed workout status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutStatusCompleted;

  /// Paused workout status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get workoutStatusPaused;

  /// Exercises label (plural)
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercises;

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Workout progress label
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgress;

  /// TUT explanation modal title
  ///
  /// In en, this message translates to:
  /// **'Time Under Tension (T.U.T.)'**
  String get tutTitle;

  /// TUT eccentric phase label
  ///
  /// In en, this message translates to:
  /// **'Eccentric'**
  String get tutEccentricPhase;

  /// TUT eccentric phase description
  ///
  /// In en, this message translates to:
  /// **'Lowering/lengthening phase (seconds)'**
  String get tutEccentricDescription;

  /// TUT bottom pause phase label
  ///
  /// In en, this message translates to:
  /// **'Bottom Pause'**
  String get tutBottomPausePhase;

  /// TUT bottom pause phase description
  ///
  /// In en, this message translates to:
  /// **'Pause at bottom position (seconds)'**
  String get tutBottomPauseDescription;

  /// TUT concentric phase label
  ///
  /// In en, this message translates to:
  /// **'Concentric'**
  String get tutConcentricPhase;

  /// TUT concentric phase description
  ///
  /// In en, this message translates to:
  /// **'Lifting/shortening phase (seconds)'**
  String get tutConcentricDescription;

  /// TUT top pause phase label
  ///
  /// In en, this message translates to:
  /// **'Top Pause'**
  String get tutTopPausePhase;

  /// TUT top pause phase description
  ///
  /// In en, this message translates to:
  /// **'Pause at top position (seconds)'**
  String get tutTopPauseDescription;

  /// TUT presets section title
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get tutPresets;

  /// TUT standard preset
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get tutPresetStandard;

  /// TUT slow preset
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get tutPresetSlow;

  /// TUT explosive preset
  ///
  /// In en, this message translates to:
  /// **'Explosive'**
  String get tutPresetExplosive;

  /// TUT isometric preset
  ///
  /// In en, this message translates to:
  /// **'Isometric'**
  String get tutPresetIsometric;

  /// Current TUT tempo label
  ///
  /// In en, this message translates to:
  /// **'Current Tempo'**
  String get tutCurrentTempo;

  /// TUT phase breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Phase Breakdown'**
  String get tutPhaseBreakdown;

  /// Full description of eccentric phase
  ///
  /// In en, this message translates to:
  /// **'Slowly lower the weight, controlling the movement with muscle tension'**
  String get tutEccentricFullDescription;

  /// Full description of bottom pause phase
  ///
  /// In en, this message translates to:
  /// **'Hold the stretched position briefly to maximize muscle activation'**
  String get tutBottomPauseFullDescription;

  /// Full description of concentric phase
  ///
  /// In en, this message translates to:
  /// **'Lift the weight with controlled force, focusing on muscle contraction'**
  String get tutConcentricFullDescription;

  /// Full description of top pause phase
  ///
  /// In en, this message translates to:
  /// **'Brief pause at peak contraction to enhance muscle engagement'**
  String get tutTopPauseFullDescription;

  /// TUT example
  ///
  /// In en, this message translates to:
  /// **'Example: 3-1-2-0'**
  String get tutExample;

  /// Standard TUT example with parameters
  ///
  /// In en, this message translates to:
  /// **'Take {eccentric} seconds to lower, pause {bottomPause} seconds at bottom, take {concentric} seconds to lift, then pause {topPause} seconds at top.'**
  String tutExampleStandard(
    String eccentric,
    String bottomPause,
    String concentric,
    String topPause,
  );

  /// Explosive TUT example
  ///
  /// In en, this message translates to:
  /// **'Move explosively during the marked phases (X) while maintaining control during the timed phases.'**
  String get tutExampleExplosive;

  /// Isometric TUT example
  ///
  /// In en, this message translates to:
  /// **'Hold the position without movement for the specified duration, focusing on muscle tension.'**
  String get tutExampleIsometric;

  /// TUT explanation modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Control your tempo for better results'**
  String get tutSubtitle;

  /// TUT format explanation section title
  ///
  /// In en, this message translates to:
  /// **'Understanding T.U.T. Format'**
  String get tutExplanationTitle;

  /// TUT format explanation
  ///
  /// In en, this message translates to:
  /// **'Format: Eccentric - Pause 1 - Concentric - Pause 2'**
  String get tutFormat;

  /// Eccentric phase label
  ///
  /// In en, this message translates to:
  /// **'Eccentric Phase'**
  String get tutPhaseEccentric;

  /// Eccentric phase description
  ///
  /// In en, this message translates to:
  /// **'Lowering/lengthening the muscle (e.g., lowering the bar in bench press)'**
  String get tutPhaseEccentricDesc;

  /// First pause phase label
  ///
  /// In en, this message translates to:
  /// **'Bottom Pause'**
  String get tutPhasePause1;

  /// First pause phase description
  ///
  /// In en, this message translates to:
  /// **'Hold at the bottom/stretched position'**
  String get tutPhasePause1Desc;

  /// Concentric phase label
  ///
  /// In en, this message translates to:
  /// **'Concentric Phase'**
  String get tutPhaseConcentric;

  /// Concentric phase description
  ///
  /// In en, this message translates to:
  /// **'Lifting/shortening the muscle (e.g., pressing the bar up)'**
  String get tutPhaseConcentricDesc;

  /// Second pause phase label
  ///
  /// In en, this message translates to:
  /// **'Top Pause'**
  String get tutPhasePause2;

  /// Second pause phase description
  ///
  /// In en, this message translates to:
  /// **'Hold at the top/contracted position'**
  String get tutPhasePause2Desc;

  /// TUT example description
  ///
  /// In en, this message translates to:
  /// **'3 seconds down, 1 second pause, 2 seconds up, no pause at top'**
  String get tutExampleDesc;

  /// TUT benefits section title
  ///
  /// In en, this message translates to:
  /// **'Benefits of Controlled Tempo'**
  String get tutBenefits;

  /// First TUT benefit
  ///
  /// In en, this message translates to:
  /// **'Increased muscle tension and growth'**
  String get tutBenefit1;

  /// Second TUT benefit
  ///
  /// In en, this message translates to:
  /// **'Better mind-muscle connection'**
  String get tutBenefit2;

  /// Third TUT benefit
  ///
  /// In en, this message translates to:
  /// **'Improved form and control'**
  String get tutBenefit3;

  /// Fourth TUT benefit
  ///
  /// In en, this message translates to:
  /// **'Reduced injury risk'**
  String get tutBenefit4;

  /// Empty exercise list message
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get noExercisesYet;

  /// Empty exercise list instruction
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first exercise'**
  String get tapToAddExercise;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Duplicate button label
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Search exercises placeholder
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// Search exercises input hint
  ///
  /// In en, this message translates to:
  /// **'Type to search exercise database'**
  String get searchExercisesHint;

  /// Superset explanation text
  ///
  /// In en, this message translates to:
  /// **'Superset combines 2+ exercises performed back-to-back with minimal rest.'**
  String get supersetInfo;

  /// Drop set explanation text
  ///
  /// In en, this message translates to:
  /// **'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.'**
  String get dropsetInfo;

  /// Rest-pause explanation text
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.'**
  String get restPauseInfo;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sign out menu item
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Pause workout menu item
  ///
  /// In en, this message translates to:
  /// **'Pause Workout'**
  String get pauseWorkout;

  /// End workout menu item
  ///
  /// In en, this message translates to:
  /// **'End Workout'**
  String get endWorkout;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get themeLightDesc;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get themeDarkDesc;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get themeSystemDesc;

  /// Font size setting
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Small font size
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// Normal font size
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get fontSizeNormal;

  /// Large font size
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// Accent color setting
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// Workout section header
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Auto-start timer setting
  ///
  /// In en, this message translates to:
  /// **'Auto-start Timer'**
  String get autoStartTimer;

  /// Auto-start timer description
  ///
  /// In en, this message translates to:
  /// **'Start rest timer after completing set'**
  String get autoStartTimerDesc;

  /// Default rest time setting
  ///
  /// In en, this message translates to:
  /// **'Default Rest Time'**
  String get defaultRestTime;

  /// Advanced techniques setting
  ///
  /// In en, this message translates to:
  /// **'Advanced Techniques'**
  String get advancedTechniques;

  /// Advanced techniques description
  ///
  /// In en, this message translates to:
  /// **'Show drop sets, supersets, etc.'**
  String get advancedTechniquesDesc;

  /// Units and language section
  ///
  /// In en, this message translates to:
  /// **'Units & Language'**
  String get unitsLanguage;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// English language description
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglishDesc;

  /// Italian language description
  ///
  /// In en, this message translates to:
  /// **'Italian (IT)'**
  String get languageItalianDesc;

  /// Weight units setting
  ///
  /// In en, this message translates to:
  /// **'Weight Units'**
  String get weightUnits;

  /// Kilograms weight unit
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get weightUnitsKg;

  /// Pounds weight unit
  ///
  /// In en, this message translates to:
  /// **'Pounds (lbs)'**
  String get weightUnitsLbs;

  /// Metric system description
  ///
  /// In en, this message translates to:
  /// **'Metric system'**
  String get weightUnitsKgDesc;

  /// Imperial system description
  ///
  /// In en, this message translates to:
  /// **'Imperial system'**
  String get weightUnitsLbsDesc;

  /// iOS features section
  ///
  /// In en, this message translates to:
  /// **'iOS Features'**
  String get iosFeatures;

  /// Live Activities setting
  ///
  /// In en, this message translates to:
  /// **'Live Activities'**
  String get liveActivities;

  /// Live Activities description
  ///
  /// In en, this message translates to:
  /// **'Show timer on lock screen & Dynamic Island'**
  String get liveActivitiesDesc;

  /// Health app sync setting
  ///
  /// In en, this message translates to:
  /// **'Health App Sync'**
  String get healthAppSync;

  /// Health app sync description
  ///
  /// In en, this message translates to:
  /// **'Sync workouts to Apple Health'**
  String get healthAppSyncDesc;

  /// Audio and feedback section
  ///
  /// In en, this message translates to:
  /// **'Audio & Feedback'**
  String get audioFeedback;

  /// Sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Sound effects description
  ///
  /// In en, this message translates to:
  /// **'Play sounds for timer and completion'**
  String get soundEffectsDesc;

  /// Vibrations setting
  ///
  /// In en, this message translates to:
  /// **'Vibrations'**
  String get vibrations;

  /// Vibrations description
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback for interactions'**
  String get vibrationsDesc;

  /// Export settings option
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// Export settings description
  ///
  /// In en, this message translates to:
  /// **'Save settings as JSON file'**
  String get exportSettingsDesc;

  /// Import settings option
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// Import settings description
  ///
  /// In en, this message translates to:
  /// **'Load settings from JSON file'**
  String get importSettingsDesc;

  /// Button to restore default notification settings
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Reset to defaults description
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to default'**
  String get resetToDefaultsDesc;

  /// Account actions section
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// Sign out description
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutDesc;

  /// Choose theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Reset settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Reset settings confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults? This cannot be undone.'**
  String get resetSettingsConfirm;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Accept button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Title for rest time suggestion banner
  ///
  /// In en, this message translates to:
  /// **'Rest Time Suggestion'**
  String get restTimeSuggestion;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Settings reset success message
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetSuccess;

  /// Export functionality coming soon message
  ///
  /// In en, this message translates to:
  /// **'Export functionality coming soon'**
  String get exportFunctioningComingSoon;

  /// Import functionality coming soon message
  ///
  /// In en, this message translates to:
  /// **'Import functionality coming soon'**
  String get importFunctioningComingSoon;

  /// Edit exercise screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExercise;

  /// Exercise rest time setting label
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get exerciseRestTime;

  /// Exercise rest time description
  ///
  /// In en, this message translates to:
  /// **'Rest time for this exercise'**
  String get exerciseRestTimeDesc;

  /// Seconds unit for rest time
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get restTimeSeconds;

  /// Set rest timer button text
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get setRestTime;

  /// Custom rest timer option
  ///
  /// In en, this message translates to:
  /// **'Custom Timer'**
  String get customRestTime;

  /// Use default rest timer option
  ///
  /// In en, this message translates to:
  /// **'Use Default Timer'**
  String get useDefaultRestTime;

  /// Your templates tab title
  ///
  /// In en, this message translates to:
  /// **'Your Templates'**
  String get yourTemplates;

  /// Popular templates section title
  ///
  /// In en, this message translates to:
  /// **'Popular Templates'**
  String get popularTemplates;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Welcome message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to your new fitness companion!'**
  String get welcomeToGymBro;

  /// Welcome description on home screen
  ///
  /// In en, this message translates to:
  /// **'Track your workouts with precision. Start a new session or continue where you left off.'**
  String get homeWelcomeDescription;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// New workout subtitle
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get startFresh;

  /// History button label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// History subtitle
  ///
  /// In en, this message translates to:
  /// **'View past workouts'**
  String get viewPastWorkouts;

  /// Analytics quick action
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Analytics subtitle
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get trackProgress;

  /// Templates quick action
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// Templates subtitle
  ///
  /// In en, this message translates to:
  /// **'Workout routines'**
  String get workoutRoutines;

  /// Settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize app'**
  String get customizeApp;

  /// Import exercises quick action
  ///
  /// In en, this message translates to:
  /// **'Import Exercises'**
  String get importExercises;

  /// Import exercises subtitle
  ///
  /// In en, this message translates to:
  /// **'Load from JSON'**
  String get loadFromJson;

  /// Active workout banner title
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkout;

  /// Paused workout banner title
  ///
  /// In en, this message translates to:
  /// **'Paused Workout'**
  String get pausedWorkout;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// Resume button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// End button text
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get end;

  /// End workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end your current workout?'**
  String get endWorkoutConfirm;

  /// Workout completed message
  ///
  /// In en, this message translates to:
  /// **'🎉 Workout completed!'**
  String get workoutCompleted;

  /// App settings menu item
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// History feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'History feature coming soon!'**
  String get historyFeatureComingSoon;

  /// Template customization subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize this template'**
  String get customizeTemplate;

  /// Template deletion subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete this template permanently'**
  String get deleteTemplatePermanently;

  /// Title for removing exercise from template
  ///
  /// In en, this message translates to:
  /// **'Remove Exercise'**
  String get removeExercise;

  /// Confirmation message for removing exercise from template
  ///
  /// In en, this message translates to:
  /// **'Remove \"{exerciseName}\" from template?'**
  String confirmRemoveExercise(String exerciseName);

  /// Timer sound setting title
  ///
  /// In en, this message translates to:
  /// **'Timer Sound'**
  String get timerSound;

  /// Timer sound setting description
  ///
  /// In en, this message translates to:
  /// **'Choose the sound that plays when the rest timer completes'**
  String get timerSoundDescription;

  /// Label for currently selected sound
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentSound;

  /// Button to preview sound
  ///
  /// In en, this message translates to:
  /// **'Play Preview'**
  String get playPreview;

  /// Message when playing sound preview
  ///
  /// In en, this message translates to:
  /// **'Playing preview'**
  String get playingPreview;

  /// Statistics dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics Dashboard'**
  String get statisticsDashboard;

  /// Workout analytics section title
  ///
  /// In en, this message translates to:
  /// **'Workout Analytics'**
  String get workoutAnalytics;

  /// Progress tracking section title
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// Detailed analytics section title
  ///
  /// In en, this message translates to:
  /// **'Detailed Analytics'**
  String get detailedAnalytics;

  /// This week label for workout count
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Label for total training volume
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get totalVolume;

  /// Consistency metric label
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// Total workouts count label
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// Completed sessions subtitle
  ///
  /// In en, this message translates to:
  /// **'Completed Sessions'**
  String get completedSessions;

  /// Weight lifted subtitle
  ///
  /// In en, this message translates to:
  /// **'Weight Lifted'**
  String get weightLifted;

  /// Average workout time statistic
  ///
  /// In en, this message translates to:
  /// **'Average Workout Time'**
  String get averageWorkoutTime;

  /// Per session subtitle
  ///
  /// In en, this message translates to:
  /// **'Per Session'**
  String get perSession;

  /// Personal records section title
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get personalRecords;

  /// New personal records subtitle
  ///
  /// In en, this message translates to:
  /// **'New PRs'**
  String get newPRs;

  /// Weekly volume chart title
  ///
  /// In en, this message translates to:
  /// **'Weekly Volume Chart'**
  String get weeklyVolumeChart;

  /// Workout frequency chart title
  ///
  /// In en, this message translates to:
  /// **'Workout Frequency'**
  String get workoutFrequency;

  /// Body part distribution chart title
  ///
  /// In en, this message translates to:
  /// **'Body Part Distribution'**
  String get bodyPartDistribution;

  /// Top exercises ranking title
  ///
  /// In en, this message translates to:
  /// **'Top Exercises'**
  String get topExercises;

  /// Workout streak card title
  ///
  /// In en, this message translates to:
  /// **'Workout Streak'**
  String get workoutStreak;

  /// Label for day streak stat
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Label for next streak milestone
  ///
  /// In en, this message translates to:
  /// **'Next Milestone'**
  String get nextMilestone;

  /// Label for all-time longest streak
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// Label for total workout days stat
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// Unit for day count
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Export data menu option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Button text to view correction details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No volume data message
  ///
  /// In en, this message translates to:
  /// **'No volume data available'**
  String get noVolumeData;

  /// No frequency data message
  ///
  /// In en, this message translates to:
  /// **'No frequency data available'**
  String get noFrequencyData;

  /// No body part data message
  ///
  /// In en, this message translates to:
  /// **'No body part data available'**
  String get noBodyPartData;

  /// No exercise data message
  ///
  /// In en, this message translates to:
  /// **'No exercise data available'**
  String get noExerciseData;

  /// No workout data message
  ///
  /// In en, this message translates to:
  /// **'No workout data yet'**
  String get noWorkoutData;

  /// Message to complete workouts for analytics
  ///
  /// In en, this message translates to:
  /// **'Complete some workouts to see your\nanalytics and progress!'**
  String get completeWorkoutsToSeeAnalytics;

  /// Start first workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Your First Workout'**
  String get startFirstWorkout;

  /// Volume increase insight message
  ///
  /// In en, this message translates to:
  /// **'Volume increased by {amount}kg from last week'**
  String volumeIncreased(String amount);

  /// Volume decrease insight message
  ///
  /// In en, this message translates to:
  /// **'Volume decreased by {amount}kg from last week'**
  String volumeDecreased(String amount);

  /// Workouts unit label
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workouts;

  /// Best workout day insight
  ///
  /// In en, this message translates to:
  /// **'Best workout day: {day}'**
  String bestWorkoutDay(String day);

  /// Average workouts per day insight
  ///
  /// In en, this message translates to:
  /// **'Average: {average} workouts per day'**
  String averageWorkoutsPerDay(String average);

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Monday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// Tuesday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// Wednesday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// Thursday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// Friday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// Saturday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// Sunday short abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// Filter statistics dialog title
  ///
  /// In en, this message translates to:
  /// **'Filter Statistics'**
  String get filterStatistics;

  /// Time period filter section
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// Muscle groups filter section
  ///
  /// In en, this message translates to:
  /// **'Muscle Groups'**
  String get muscleGroups;

  /// Pectorals muscle group
  ///
  /// In en, this message translates to:
  /// **'Pectorals'**
  String get musclePectorals;

  /// Latissimus dorsi muscle group
  ///
  /// In en, this message translates to:
  /// **'Lats'**
  String get muscleLats;

  /// Deltoid muscles (shoulders)
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleDeltoids;

  /// Biceps muscle group
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// Triceps muscle group
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// Trapezius muscle group
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleTrapezius;

  /// Rhomboid muscles
  ///
  /// In en, this message translates to:
  /// **'Rhomboids'**
  String get muscleRhomboids;

  /// Quadriceps muscle group
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleQuads;

  /// Gluteus muscle group
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// Hamstring muscle group
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleHamstrings;

  /// Calf muscles
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// Abdominal muscles
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleAbs;

  /// Oblique muscles
  ///
  /// In en, this message translates to:
  /// **'Obliques'**
  String get muscleObliques;

  /// Core muscles
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// Forearm muscles
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleForearms;

  /// Adductor muscles
  ///
  /// In en, this message translates to:
  /// **'Adductors'**
  String get muscleAdductors;

  /// Lower back muscles
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get muscleLowerBack;

  /// Last week filter option
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// Last month filter option
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// Last three months filter option
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get lastThreeMonths;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Improving progress summary message
  ///
  /// In en, this message translates to:
  /// **'Your progress is improving! Keep it up!'**
  String get improvingProgressSummary;

  /// Needs improvement progress summary message
  ///
  /// In en, this message translates to:
  /// **'Your progress needs improvement. Stay consistent!'**
  String get needsImprovementSummary;

  /// Steady progress summary message
  ///
  /// In en, this message translates to:
  /// **'Your progress is steady. Great consistency!'**
  String get steadyProgressSummary;

  /// Weekly progress title
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// Workout goal label
  ///
  /// In en, this message translates to:
  /// **'Workout Goal'**
  String get workoutGoal;

  /// Volume goal label
  ///
  /// In en, this message translates to:
  /// **'Volume Goal'**
  String get volumeGoal;

  /// Rate of perceived exertion label
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpe;

  /// Full description of RPE scale
  ///
  /// In en, this message translates to:
  /// **'Rate of Perceived Exertion (6-10)'**
  String get rpeDescription;

  /// Reps in Reserve abbreviation
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get rir;

  /// Full description of RIR
  ///
  /// In en, this message translates to:
  /// **'Reps in Reserve'**
  String get rirDescription;

  /// Actual repetitions completed
  ///
  /// In en, this message translates to:
  /// **'Actual Reps'**
  String get actualReps;

  /// Target reps for dropset stage
  ///
  /// In en, this message translates to:
  /// **'{reps} reps target'**
  String targetReps(int reps);

  /// Number of reps completed
  ///
  /// In en, this message translates to:
  /// **'Reps Completed'**
  String get repsCompleted;

  /// Actual repetitions that were completed
  ///
  /// In en, this message translates to:
  /// **'Actual Reps Completed'**
  String get actualRepsCompleted;

  /// Title for recording set completion details
  ///
  /// In en, this message translates to:
  /// **'Record Set Completion'**
  String get recordSetCompletion;

  /// Question asking about set difficulty
  ///
  /// In en, this message translates to:
  /// **'How hard was this set?'**
  String get howHardWasTheSet;

  /// RPE 6 description
  ///
  /// In en, this message translates to:
  /// **'Very Easy'**
  String get veryEasy;

  /// RPE 7 description
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// RPE 8 description
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// RPE 9 description
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// RPE 10 description
  ///
  /// In en, this message translates to:
  /// **'Maximal'**
  String get maximal;

  /// Word 'of' for 'X of Y'
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofWord;

  /// Button to skip RPE recording
  ///
  /// In en, this message translates to:
  /// **'Skip RPE'**
  String get skipRpe;

  /// Button to confirm set completion
  ///
  /// In en, this message translates to:
  /// **'Confirm Set'**
  String get confirmSet;

  /// Full text for reps in reserve
  ///
  /// In en, this message translates to:
  /// **'reps in reserve'**
  String get repsInReserve;

  /// Message when user sets a preferred workout template
  ///
  /// In en, this message translates to:
  /// **'Preferred template set!'**
  String get preferredTemplateSet;

  /// Message when user removes the preferred workout template
  ///
  /// In en, this message translates to:
  /// **'Preferred template removed'**
  String get preferredTemplateRemoved;

  /// Title for choosing preferred workout template
  ///
  /// In en, this message translates to:
  /// **'Choose Preferred Template'**
  String get choosePreferredTemplate;

  /// Option to remove the preferred template
  ///
  /// In en, this message translates to:
  /// **'Remove Preferred Template'**
  String get removePreferredTemplate;

  /// Description for starting with empty workout
  ///
  /// In en, this message translates to:
  /// **'Start with an empty workout'**
  String get startWithEmptyWorkout;

  /// Exercise start button hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// Error message when templates fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading templates'**
  String get errorLoadingTemplates;

  /// Message shown when syncing workouts
  ///
  /// In en, this message translates to:
  /// **'Syncing workouts...'**
  String get syncingWorkouts;

  /// Message shown when loading workouts
  ///
  /// In en, this message translates to:
  /// **'Loading workouts...'**
  String get loadingWorkouts;

  /// Error message when workouts fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading workouts'**
  String get errorLoadingWorkouts;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Button to mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// Empty state message when no notifications exist
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// Description for empty notifications state
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep you updated on your progress!'**
  String get notificationsDescription;

  /// Title for workout reminder notification
  ///
  /// In en, this message translates to:
  /// **'Workout Reminder'**
  String get workoutReminderTitle;

  /// Body for workout reminder notification
  ///
  /// In en, this message translates to:
  /// **'Time for your {workoutName} workout! 💪'**
  String workoutReminderBody(String workoutName);

  /// Title for recovery alert notification
  ///
  /// In en, this message translates to:
  /// **'Recovery Needed'**
  String get recoveryAlertTitle;

  /// Body for recovery alert notification (singular)
  ///
  /// In en, this message translates to:
  /// **'You have {days} skipped day to recover! 🔄'**
  String recoveryAlertBodySingle(int days);

  /// Body for recovery alert notification (plural)
  ///
  /// In en, this message translates to:
  /// **'You have {days} skipped days to recover! 🔄'**
  String recoveryAlertBodyMultiple(int days);

  /// Title for streak motivation notification
  ///
  /// In en, this message translates to:
  /// **'Keep Your Streak Going!'**
  String get streakMotivationTitle;

  /// Body for streak motivation notification
  ///
  /// In en, this message translates to:
  /// **'{streak} days streak! Don\'t break it now! 🔥'**
  String streakMotivationBody(int streak);

  /// Title for rest day reminder notification
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDayTitle;

  /// Body for rest day reminder notification
  ///
  /// In en, this message translates to:
  /// **'Today is your rest day. Recovery is just as important! 😴'**
  String get restDayBody;

  /// Toggle for enabling workout reminders
  ///
  /// In en, this message translates to:
  /// **'Enable Workout Reminders'**
  String get enableWorkoutReminders;

  /// Toggle for enabling recovery alerts
  ///
  /// In en, this message translates to:
  /// **'Enable Recovery Alerts'**
  String get enableRecoveryAlerts;

  /// Toggle for enabling streak motivation notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Streak Motivation'**
  String get enableStreakMotivation;

  /// Toggle for enabling rest day reminders
  ///
  /// In en, this message translates to:
  /// **'Enable Rest Day Reminders'**
  String get enableRestDayReminders;

  /// Label for preferred notification time setting
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get preferredNotificationTime;

  /// Label for Do Not Disturb setting
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get doNotDisturb;

  /// Morning time option for notifications
  ///
  /// In en, this message translates to:
  /// **'Morning (8:00 AM)'**
  String get morningTime;

  /// Midday time option for notifications
  ///
  /// In en, this message translates to:
  /// **'Midday (12:30 PM)'**
  String get middayTime;

  /// Afternoon time option for notifications
  ///
  /// In en, this message translates to:
  /// **'Afternoon (4:00 PM)'**
  String get afternoonTime;

  /// Evening time option for notifications
  ///
  /// In en, this message translates to:
  /// **'Evening (7:00 PM)'**
  String get eveningTime;

  /// Label for custom notification time
  ///
  /// In en, this message translates to:
  /// **'Custom time'**
  String get customTime;

  /// Title for new weight personal record notification
  ///
  /// In en, this message translates to:
  /// **'New Weight PR!'**
  String get newWeightPR;

  /// Title for new reps personal record notification
  ///
  /// In en, this message translates to:
  /// **'New Reps PR!'**
  String get newRepsPR;

  /// Title for new 1RM personal record notification
  ///
  /// In en, this message translates to:
  /// **'New 1RM PR!'**
  String get newOneRMPR;

  /// Title for new volume personal record notification
  ///
  /// In en, this message translates to:
  /// **'New Volume PR!'**
  String get newVolumePR;

  /// Title for 3-day streak achievement
  ///
  /// In en, this message translates to:
  /// **'Building Momentum!'**
  String get buildingMomentum;

  /// Title for 7-day streak achievement
  ///
  /// In en, this message translates to:
  /// **'One Week Strong!'**
  String get oneWeekStrong;

  /// Title for 14-day streak achievement
  ///
  /// In en, this message translates to:
  /// **'Two Weeks Streak!'**
  String get twoWeeksStreak;

  /// Title for 30-day streak achievement
  ///
  /// In en, this message translates to:
  /// **'ONE MONTH STREAK!'**
  String get oneMonthStreak;

  /// Title for 50+ day streak achievement
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY STREAK!'**
  String get legendaryStreak;

  /// Title for volume milestone achievement
  ///
  /// In en, this message translates to:
  /// **'Volume Milestone!'**
  String get volumeMilestone;

  /// Title for 50k+ kg volume achievement
  ///
  /// In en, this message translates to:
  /// **'MASSIVE VOLUME!'**
  String get massiveVolume;

  /// Title for 100k+ kg volume achievement
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY VOLUME!'**
  String get legendaryVolume;

  /// Quick stats section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get quickStats;

  /// Label for workout consistency streak
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Achievements label
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Exercise information chip label
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get exerciseInfo;

  /// Warmup chip label
  ///
  /// In en, this message translates to:
  /// **'Warmup'**
  String get warmup;

  /// Safety tips chip label
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get safetyTips;

  /// Warmup modal title
  ///
  /// In en, this message translates to:
  /// **'Warmup & Mobility'**
  String get warmupAndMobility;

  /// Exercise info modal title
  ///
  /// In en, this message translates to:
  /// **'Exercise Information'**
  String get exerciseInformation;

  /// Safety modal title
  ///
  /// In en, this message translates to:
  /// **'Safety & Prevention'**
  String get safetyAndPrevention;

  /// Pre-workout mobility section title
  ///
  /// In en, this message translates to:
  /// **'Pre-Workout Mobility'**
  String get preWorkoutMobility;

  /// Muscle activation section title
  ///
  /// In en, this message translates to:
  /// **'Muscle Activation'**
  String get muscleActivation;

  /// Warmup sets section title
  ///
  /// In en, this message translates to:
  /// **'Warmup Sets'**
  String get warmupSets;

  /// Title for recommended warmup card
  ///
  /// In en, this message translates to:
  /// **'Recommended Warmup'**
  String get recommendedWarmup;

  /// Smart warmup badge label
  ///
  /// In en, this message translates to:
  /// **'SMART'**
  String get warmupSmart;

  /// Warmup tap action text
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get warmupTap;

  /// Warmup intelligent progression title
  ///
  /// In en, this message translates to:
  /// **'Intelligent Progression'**
  String get warmupIntelligentProgression;

  /// Warmup progression description with placeholders
  ///
  /// In en, this message translates to:
  /// **'From {startWeight}kg to {endWeight}kg in {steps} steps'**
  String warmupProgressionDescription(
    String startWeight,
    String endWeight,
    String steps,
  );

  /// Working weight label
  ///
  /// In en, this message translates to:
  /// **'Working Weight'**
  String get workingWeight;

  /// Empty barbell label
  ///
  /// In en, this message translates to:
  /// **'Empty Barbell'**
  String get emptyBarbell;

  /// Customize button label
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// Add all button label
  ///
  /// In en, this message translates to:
  /// **'Add All'**
  String get addAll;

  /// Edit set dialog title with percentage
  ///
  /// In en, this message translates to:
  /// **'Edit Set {percentage}%'**
  String editSet(String percentage);

  /// Coming soon label
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Snackbar message for added warmup sets
  ///
  /// In en, this message translates to:
  /// **'Added {count} warmup sets'**
  String warmupSetsAdded(String count);

  /// Warmup duration section title
  ///
  /// In en, this message translates to:
  /// **'Warmup Duration'**
  String get warmupDuration;

  /// Primary muscles section title
  ///
  /// In en, this message translates to:
  /// **'Primary Muscles'**
  String get primaryMuscles;

  /// Label for secondary muscles
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get secondaryMuscles;

  /// Difficulty level section title
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// Exercise type field label
  ///
  /// In en, this message translates to:
  /// **'Exercise Type'**
  String get exerciseType;

  /// Equipment field label
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// Movement pattern label
  ///
  /// In en, this message translates to:
  /// **'Movement Pattern'**
  String get movementPattern;

  /// Repetition range field label
  ///
  /// In en, this message translates to:
  /// **'Rep Range'**
  String get repRange;

  /// Injury prevention section title
  ///
  /// In en, this message translates to:
  /// **'Injury Prevention'**
  String get injuryPrevention;

  /// Recommended cooldown section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Cooldown'**
  String get recommendedCooldown;

  /// Technical drills section title
  ///
  /// In en, this message translates to:
  /// **'Technical Drills'**
  String get technicalDrills;

  /// Technical tips from exercise database (not personal notes)
  ///
  /// In en, this message translates to:
  /// **'Technical Tips'**
  String get technicalNotes;

  /// Label for target muscle groups
  ///
  /// In en, this message translates to:
  /// **'Target muscles'**
  String get targetMuscles;

  /// Exercise details screen title
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetails;

  /// Preparation group title
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparation;

  /// Specific warmup group title
  ///
  /// In en, this message translates to:
  /// **'Specific Warmup'**
  String get specificWarmup;

  /// Safety and technique group title
  ///
  /// In en, this message translates to:
  /// **'Safety & Technique'**
  String get safetyAndTechnique;

  /// Recovery group title
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning! 🌅'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon! ☀️'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening! 🌙'**
  String get goodEvening;

  /// Motivational subtitle under greeting
  ///
  /// In en, this message translates to:
  /// **'Ready to dominate?'**
  String get readyToDominate;

  /// Active workout status
  ///
  /// In en, this message translates to:
  /// **'WORKOUT ACTIVE'**
  String get workoutActive;

  /// Paused workout status
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get workoutPaused;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Tooltip for reordering exercises
  ///
  /// In en, this message translates to:
  /// **'Reorder exercises'**
  String get reorderExercises;

  /// Tooltip for confirming reorder
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get confirmReorder;

  /// Feedback message when exercise order is saved
  ///
  /// In en, this message translates to:
  /// **'Order saved'**
  String get orderSaved;

  /// Quick start workout button
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// Start immediately description
  ///
  /// In en, this message translates to:
  /// **'Start immediately and add exercises on the fly'**
  String get startImmediately;

  /// Feedback when quick workout starts
  ///
  /// In en, this message translates to:
  /// **'Workout started! Add exercises as you go'**
  String get workoutStartedQuickly;

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// AI Coach section title
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get aiCoach;

  /// Critical insights count badge
  ///
  /// In en, this message translates to:
  /// **'{count} Critical'**
  String criticalInsights(int count);

  /// No insights empty state title
  ///
  /// In en, this message translates to:
  /// **'Great Work!'**
  String get noInsights;

  /// No insights empty state description
  ///
  /// In en, this message translates to:
  /// **'You\'re training optimally. Keep up the excellent work!'**
  String get noInsightsDescription;

  /// Error message when insights fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading insights'**
  String get errorLoadingInsights;

  /// Label for volume calculation
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// Quick start workout button
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get startWorkoutQuick;

  /// Suggested workout subtitle
  ///
  /// In en, this message translates to:
  /// **'Suggested for today'**
  String get suggestedForToday;

  /// Progress section header
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Push day workout template
  ///
  /// In en, this message translates to:
  /// **'Push Day'**
  String get pushDay;

  /// Pull day workout template
  ///
  /// In en, this message translates to:
  /// **'Pull Day'**
  String get pullDay;

  /// Leg day workout template
  ///
  /// In en, this message translates to:
  /// **'Leg Day'**
  String get legDay;

  /// Push day muscle groups
  ///
  /// In en, this message translates to:
  /// **'Chest, Shoulders, Triceps'**
  String get chestShouldersTriceps;

  /// Pull day muscle groups
  ///
  /// In en, this message translates to:
  /// **'Back, Biceps'**
  String get backBiceps;

  /// Leg day muscle groups
  ///
  /// In en, this message translates to:
  /// **'Legs, Glutes'**
  String get legsGlutes;

  /// HIIT workout description
  ///
  /// In en, this message translates to:
  /// **'Intensive Cardio'**
  String get intensiveCardio;

  /// Templates section title
  ///
  /// In en, this message translates to:
  /// **'Quick Templates'**
  String get quickTemplates;

  /// Predefined templates tab
  ///
  /// In en, this message translates to:
  /// **'Predefined'**
  String get predefined;

  /// Tab label for user's templates
  ///
  /// In en, this message translates to:
  /// **'My Templates'**
  String get myTemplates;

  /// Empty state title for personal templates
  ///
  /// In en, this message translates to:
  /// **'No personal templates'**
  String get noPersonalTemplates;

  /// CTA for creating first template
  ///
  /// In en, this message translates to:
  /// **'Create your first template!'**
  String get createFirstTemplate;

  /// Create template button label
  ///
  /// In en, this message translates to:
  /// **'Create Template'**
  String get createTemplate;

  /// Secondary actions section title
  ///
  /// In en, this message translates to:
  /// **'Other tools'**
  String get otherTools;

  /// Workout history card title
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// Past workouts subtitle
  ///
  /// In en, this message translates to:
  /// **'Past workouts'**
  String get pastWorkouts;

  /// Workout started snackbar
  ///
  /// In en, this message translates to:
  /// **'Workout \"{name}\" started!'**
  String workoutStarted(String name);

  /// Template not found error
  ///
  /// In en, this message translates to:
  /// **'Template not found'**
  String get templateNotFound;

  /// Loading template message
  ///
  /// In en, this message translates to:
  /// **'Loading template...'**
  String get loadingTemplate;

  /// Template load error message
  ///
  /// In en, this message translates to:
  /// **'Error loading template: {error}'**
  String templateLoadError(String error);

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// Workout already in progress warning
  ///
  /// In en, this message translates to:
  /// **'You already have a workout in progress: {name}'**
  String workoutInProgress(String name);

  /// Workout discarded message
  ///
  /// In en, this message translates to:
  /// **'Workout discarded'**
  String get workoutDiscarded;

  /// Workout saved success message
  ///
  /// In en, this message translates to:
  /// **'Workout saved successfully!'**
  String get workoutSavedSuccessfully;

  /// End workout dialog question
  ///
  /// In en, this message translates to:
  /// **'How would you like to end the workout?'**
  String get howToEndWorkout;

  /// Discard button
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Save and end button
  ///
  /// In en, this message translates to:
  /// **'Save and End'**
  String get saveAndEnd;

  /// AI Coach prompt to start first workout
  ///
  /// In en, this message translates to:
  /// **'Start your first workout to unlock personalized tips!'**
  String get aiCoachFirstWorkout;

  /// AI Coach streak encouragement
  ///
  /// In en, this message translates to:
  /// **'Great job! {days} consecutive days of training. Keep this excellent pace!'**
  String aiCoachStreakMessage(int days);

  /// AI Coach volume increase message
  ///
  /// In en, this message translates to:
  /// **'Your volume increased by {increase}! Keep going to maximize results'**
  String aiCoachVolumeIncrease(String increase);

  /// AI Coach personal record message
  ///
  /// In en, this message translates to:
  /// **'You set a new PR of {weight} on {exercise}! Aim to beat it'**
  String aiCoachNewPR(String weight, String exercise);

  /// AI Coach consistency advice
  ///
  /// In en, this message translates to:
  /// **'Focus on consistency: try to work out at least 3-4 times this week'**
  String get aiCoachConsistency;

  /// AI Coach personalization subtitle
  ///
  /// In en, this message translates to:
  /// **'Personalized for you'**
  String get aiCoachPersonalized;

  /// Hint to tap AI Coach card for more details
  ///
  /// In en, this message translates to:
  /// **'Tap for detailed insights'**
  String get aiCoachTapHint;

  /// Title for detailed AI Coach modal
  ///
  /// In en, this message translates to:
  /// **'AI Coach Insights'**
  String get aiCoachDetailed;

  /// Placeholder text for AI Coach modal
  ///
  /// In en, this message translates to:
  /// **'Smart insights coming soon! Your AI Coach will analyze your training patterns and provide personalized recommendations.'**
  String get aiCoachModalPlaceholder;

  /// Disclaimer for AI Coach recommendations
  ///
  /// In en, this message translates to:
  /// **'These are general recommendations based on your training data. Always consult with a qualified fitness professional before making significant changes to your training program.'**
  String get aiCoachDisclaimer;

  /// AI badge text shown in AI Coach card header
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiBadge;

  /// Critical severity badge for AI insights (injury risk, overtraining)
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get badgeCritical;

  /// Warning severity badge for AI insights (plateaus, imbalances)
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get badgeWarning;

  /// Info severity badge for AI insights (educational content)
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get badgeInfo;

  /// Success severity badge for AI insights (positive feedback)
  ///
  /// In en, this message translates to:
  /// **'GREAT'**
  String get badgeSuccess;

  /// AI insight title for first workout
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get aiInsightStartJourney;

  /// AI insight description for first workout
  ///
  /// In en, this message translates to:
  /// **'Begin tracking workouts to unlock personalized insights'**
  String get aiInsightStartJourneyDesc;

  /// AI insight recommendation for first workout
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout to get started'**
  String get aiInsightStartJourneyRec;

  /// Unit for sets per week in AI Coach insights
  ///
  /// In en, this message translates to:
  /// **'series/week'**
  String get aiCoachSeriesPerWeek;

  /// Unit for volume in tons (metric) in AI Coach insights
  ///
  /// In en, this message translates to:
  /// **'tons'**
  String get aiCoachTons;

  /// Label for current training volume metric
  ///
  /// In en, this message translates to:
  /// **'Current volume'**
  String get aiCoachCurrentVolume;

  /// Label for progressive overload percentage
  ///
  /// In en, this message translates to:
  /// **'Progressive overload'**
  String get aiCoachProgressiveLoad;

  /// Unit for training frequency per week
  ///
  /// In en, this message translates to:
  /// **'times/week'**
  String get aiCoachTimesPerWeek;

  /// Label for current training frequency
  ///
  /// In en, this message translates to:
  /// **'Current frequency'**
  String get aiCoachCurrentFrequency;

  /// MEV (Minimum Effective Volume) range display
  ///
  /// In en, this message translates to:
  /// **'MEV: {min}-{max} sets'**
  String aiCoachMEVRange(String min, String max);

  /// Title for collapsible scientific references section
  ///
  /// In en, this message translates to:
  /// **'Scientific References'**
  String get aiCoachScientificReferences;

  /// AI insight title for new users (1-3 workouts)
  ///
  /// In en, this message translates to:
  /// **'Great Start!'**
  String get aiInsightNewUser;

  /// AI insight description for new users
  ///
  /// In en, this message translates to:
  /// **'You\'re building a strong foundation! Keep consistent for better insights'**
  String get aiInsightNewUserDesc;

  /// AI insight recommendation for new users
  ///
  /// In en, this message translates to:
  /// **'Complete 5+ workouts to unlock advanced AI analysis'**
  String get aiInsightNewUserRec;

  /// AI insight title for muscle group imbalance
  ///
  /// In en, this message translates to:
  /// **'Muscle Group Imbalance'**
  String get aiInsightMuscleImbalance;

  /// AI insight description for muscle group imbalance
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup} is undertrained this week'**
  String aiInsightMuscleImbalanceDesc(String muscleGroup);

  /// AI insight recommendation for muscle group imbalance
  ///
  /// In en, this message translates to:
  /// **'Add 2-3 {muscleGroup} exercises to your next workout'**
  String aiInsightMuscleImbalanceRec(String muscleGroup);

  /// AI insight title for plateau
  ///
  /// In en, this message translates to:
  /// **'Plateau Alert'**
  String get aiInsightPlateauAlert;

  /// AI insight description for plateau
  ///
  /// In en, this message translates to:
  /// **'{exercise} weight hasn\'t increased in 3+ sessions'**
  String aiInsightPlateauDesc(String exercise);

  /// AI insight recommendation for plateau
  ///
  /// In en, this message translates to:
  /// **'Try increasing weight by 2.5-5kg or add more reps'**
  String get aiInsightPlateauRec;

  /// AI insight title for insufficient recovery
  ///
  /// In en, this message translates to:
  /// **'Insufficient Recovery'**
  String get aiInsightInsufficientRecovery;

  /// AI insight description for insufficient recovery
  ///
  /// In en, this message translates to:
  /// **'Training too frequently without rest'**
  String get aiInsightInsufficientRecoveryDesc;

  /// AI insight recommendation for insufficient recovery
  ///
  /// In en, this message translates to:
  /// **'Consider adding 1-2 rest days between sessions'**
  String get aiInsightInsufficientRecoveryRec;

  /// AI insight title for long recovery
  ///
  /// In en, this message translates to:
  /// **'Long Recovery Periods'**
  String get aiInsightLongRecovery;

  /// AI insight description for long recovery
  ///
  /// In en, this message translates to:
  /// **'Too much time between workouts'**
  String get aiInsightLongRecoveryDesc;

  /// AI insight recommendation for long recovery
  ///
  /// In en, this message translates to:
  /// **'Try to maintain 2-3 days between sessions for optimal progress'**
  String get aiInsightLongRecoveryRec;

  /// AI insight title for low volume
  ///
  /// In en, this message translates to:
  /// **'Low Training Volume'**
  String get aiInsightLowVolume;

  /// AI insight description for low volume
  ///
  /// In en, this message translates to:
  /// **'Current average: {sets} sets per workout'**
  String aiInsightLowVolumeDesc(int sets);

  /// AI insight recommendation for low volume
  ///
  /// In en, this message translates to:
  /// **'Consider adding 3-5 more sets to maximize growth'**
  String get aiInsightLowVolumeRec;

  /// AI insight title for high volume
  ///
  /// In en, this message translates to:
  /// **'High Training Volume'**
  String get aiInsightHighVolume;

  /// AI insight description for high volume
  ///
  /// In en, this message translates to:
  /// **'Current average: {sets} sets per workout'**
  String aiInsightHighVolumeDesc(int sets);

  /// AI insight recommendation for high volume
  ///
  /// In en, this message translates to:
  /// **'Consider reducing volume to avoid overtraining'**
  String get aiInsightHighVolumeRec;

  /// AI insight title for low frequency
  ///
  /// In en, this message translates to:
  /// **'Low Training Frequency'**
  String get aiInsightLowFrequency;

  /// AI insight description for low frequency
  ///
  /// In en, this message translates to:
  /// **'Currently training {frequency} times per week'**
  String aiInsightLowFrequencyDesc(String frequency);

  /// AI insight recommendation for low frequency
  ///
  /// In en, this message translates to:
  /// **'Aim for 3-4 sessions per week for optimal results'**
  String get aiInsightLowFrequencyRec;

  /// AI insight title for high frequency
  ///
  /// In en, this message translates to:
  /// **'Very High Frequency'**
  String get aiInsightHighFrequency;

  /// AI insight description for high frequency
  ///
  /// In en, this message translates to:
  /// **'Training {frequency} times per week'**
  String aiInsightHighFrequencyDesc(String frequency);

  /// AI insight recommendation for high frequency
  ///
  /// In en, this message translates to:
  /// **'Consider adding more rest days to prevent burnout'**
  String get aiInsightHighFrequencyRec;

  /// AI insight title for volume plateau
  ///
  /// In en, this message translates to:
  /// **'Volume Plateau Detected'**
  String get aiInsightVolumePlateau;

  /// AI insight description for volume plateau
  ///
  /// In en, this message translates to:
  /// **'Training volume hasn\'t increased significantly'**
  String get aiInsightVolumePlateauDesc;

  /// AI insight recommendation for volume plateau
  ///
  /// In en, this message translates to:
  /// **'Try new exercises, techniques, or increase intensity'**
  String get aiInsightVolumePlateauRec;

  /// AI insight title for optimal training volume
  ///
  /// In en, this message translates to:
  /// **'Perfect Volume!'**
  String get aiInsightOptimalVolume;

  /// AI insight description for optimal volume
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup} volume is in the optimal range ({sets} sets/week)'**
  String aiInsightOptimalVolumeDesc(String muscleGroup, int sets);

  /// AI insight recommendation for optimal volume
  ///
  /// In en, this message translates to:
  /// **'Keep this up! You\'re in the sweet spot for muscle growth'**
  String get aiInsightOptimalVolumeRec;

  /// AI insight title for large weight jump
  ///
  /// In en, this message translates to:
  /// **'Large Weight Jump'**
  String get aiInsightLargeWeightJump;

  /// AI insight description for large weight jump
  ///
  /// In en, this message translates to:
  /// **'{exercise} weight increased by {increase}%'**
  String aiInsightLargeWeightJumpDesc(String exercise, int increase);

  /// AI insight recommendation for large weight jump
  ///
  /// In en, this message translates to:
  /// **'Ensure proper form with this weight increase'**
  String get aiInsightLargeWeightJumpRec;

  /// Muscle group name for legs
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleGroupLegs;

  /// Muscle group name for chest
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleGroupChest;

  /// Muscle group name for back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleGroupBack;

  /// Muscle group name for shoulders
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleGroupShoulders;

  /// Muscle group name for arms
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get muscleGroupArms;

  /// Muscle group name for other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get muscleGroupOther;

  /// Per week suffix
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get perWeek;

  /// Target label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Frequency label
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No record placeholder
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get noRecord;

  /// Start today encouragement
  ///
  /// In en, this message translates to:
  /// **'Start today!'**
  String get startToday;

  /// Great exclamation
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// Keep going encouragement
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// Generic day label
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Pull to refresh instruction
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Weekly training frequency label
  ///
  /// In en, this message translates to:
  /// **'Weekly Frequency'**
  String get weeklyFrequency;

  /// Excellent progress message
  ///
  /// In en, this message translates to:
  /// **'Excellent Progress!'**
  String get excellentProgress;

  /// Good progress message
  ///
  /// In en, this message translates to:
  /// **'Good Progress!'**
  String get goodProgress;

  /// Get started encouragement
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started!'**
  String get getStarted;

  /// Category label for streak motivation notifications
  ///
  /// In en, this message translates to:
  /// **'Streak Motivation'**
  String get streakMotivation;

  /// Motivation for consistent users
  ///
  /// In en, this message translates to:
  /// **'Great consistency! Keep building your momentum.'**
  String get consistencyMotivation;

  /// Motivation to build a workout streak
  ///
  /// In en, this message translates to:
  /// **'Build your streak by staying consistent!'**
  String get buildStreakMotivation;

  /// Information about how workout streaks are calculated
  ///
  /// In en, this message translates to:
  /// **'Streak counts consecutive days with at least one completed workout.'**
  String get streakInfo;

  /// Information about total workouts metric
  ///
  /// In en, this message translates to:
  /// **'Total number of workout sessions you\'ve completed.'**
  String get totalWorkoutsInfo;

  /// Information about weekly frequency calculation
  ///
  /// In en, this message translates to:
  /// **'Average number of workout days per week over the last 4 weeks.'**
  String get weeklyFrequencyInfo;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Community section title
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Community feature coming soon dialog title
  ///
  /// In en, this message translates to:
  /// **'Community Feature Coming Soon'**
  String get communityComingSoonTitle;

  /// Community feature coming soon dialog description
  ///
  /// In en, this message translates to:
  /// **'We\'re working on building an amazing community feature where you can connect with other athletes, share your progress, and learn from each other. Stay tuned!'**
  String get communityComingSoonDescription;

  /// General information section title
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInformation;

  /// Technical notes and Time under Tension section title
  ///
  /// In en, this message translates to:
  /// **'Technical Notes & TuT'**
  String get technicalNotesAndTut;

  /// Warmup and preparation section title
  ///
  /// In en, this message translates to:
  /// **'Warmup & Preparation'**
  String get warmupAndPreparation;

  /// Technical drill section title
  ///
  /// In en, this message translates to:
  /// **'Technical Drill'**
  String get technicalDrill;

  /// Terms explanation section title
  ///
  /// In en, this message translates to:
  /// **'Terms Explanation'**
  String get termsExplanation;

  /// Add exercise to selection button text
  ///
  /// In en, this message translates to:
  /// **'Add to Selection'**
  String get addToSelection;

  /// Number of exercises found in search results
  ///
  /// In en, this message translates to:
  /// **'exercises found'**
  String get exercisesFound;

  /// Message when exercise is added to selection
  ///
  /// In en, this message translates to:
  /// **'added to selection'**
  String get addedToSelection;

  /// Primary focus muscles label
  ///
  /// In en, this message translates to:
  /// **'Primary Focus'**
  String get primaryFocus;

  /// Pre-workout mobility work label
  ///
  /// In en, this message translates to:
  /// **'Pre-Mobility Work'**
  String get preMobilityWork;

  /// Pre-workout activation label
  ///
  /// In en, this message translates to:
  /// **'Pre-Activation'**
  String get preActivation;

  /// Filters section title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Add to workout button text
  ///
  /// In en, this message translates to:
  /// **'Add to Workout'**
  String get addToWorkout;

  /// Number of exercises selected text
  ///
  /// In en, this message translates to:
  /// **'exercises selected'**
  String get exercisesSelected;

  /// Empty state when no exercises match search
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// Suggestion when no exercises found
  ///
  /// In en, this message translates to:
  /// **'Try modifying the search filters'**
  String get tryModifyingFilters;

  /// Clear all filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearAllFilters;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// Message when user has no templates
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// Difficulty field label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the workout'**
  String get errorOccurred;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Network connection error message
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// Database operation error message
  ///
  /// In en, this message translates to:
  /// **'Database Error'**
  String get databaseError;

  /// Input validation error message
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// Permission denied error message
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// Storage operation error message
  ///
  /// In en, this message translates to:
  /// **'Storage Error'**
  String get storageError;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// Error message when user is not found
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Wrong password error message
  ///
  /// In en, this message translates to:
  /// **'Wrong Password'**
  String get wrongPassword;

  /// Email already in use error message
  ///
  /// In en, this message translates to:
  /// **'Email Already In Use'**
  String get emailAlreadyInUse;

  /// Invalid email format error message
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// Password too weak error message
  ///
  /// In en, this message translates to:
  /// **'Weak Password'**
  String get weakPassword;

  /// General authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// Critical system error message
  ///
  /// In en, this message translates to:
  /// **'Critical Error'**
  String get criticalError;

  /// Button to go back to previous screen
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Start new workout cycle suggestion message
  ///
  /// In en, this message translates to:
  /// **'Start new cycle'**
  String get startNewCycle;

  /// Continue workout routine suggestion message
  ///
  /// In en, this message translates to:
  /// **'Continue your routine'**
  String get continueRoutine;

  /// Resume workout after N days message
  ///
  /// In en, this message translates to:
  /// **'Resume after {days} {days, plural, =1{day} other{days}}'**
  String resumeAfterDays(int days);

  /// Restart workout cycle after N days message
  ///
  /// In en, this message translates to:
  /// **'Restart cycle after {days} {days, plural, =1{day} other{days}}'**
  String restartCycleAfterDays(int days);

  /// Next workout in rotation suggestion message
  ///
  /// In en, this message translates to:
  /// **'Next in rotation'**
  String get nextInRotation;

  /// Most frequent workout suggestion message
  ///
  /// In en, this message translates to:
  /// **'Your most frequent workout'**
  String get yourMostFrequentWorkout;

  /// Hint to select an exercise
  ///
  /// In en, this message translates to:
  /// **'Select an exercise to view progress'**
  String get selectExercise;

  /// Label for original exercise name in selection dialog
  ///
  /// In en, this message translates to:
  /// **'Original exercise'**
  String get originalExercise;

  /// Title for suggested exercise matches section
  ///
  /// In en, this message translates to:
  /// **'Suggested matches'**
  String get suggestedMatches;

  /// Match percentage label
  ///
  /// In en, this message translates to:
  /// **'match'**
  String get match;

  /// Label for workout already linked to another date
  ///
  /// In en, this message translates to:
  /// **'Linked to'**
  String get linkedTo;

  /// Button to skip current exercise
  ///
  /// In en, this message translates to:
  /// **'Skip Exercise'**
  String get skipExercise;

  /// Button to create new exercise
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get createNewExercise;

  /// Button to confirm exercise selection
  ///
  /// In en, this message translates to:
  /// **'Use Selected'**
  String get useSelectedExercise;

  /// Title for workout templates screen
  ///
  /// In en, this message translates to:
  /// **'Workout Templates'**
  String get workoutTemplates;

  /// Tab label for discovering public templates
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// Placeholder text for contribution search in community discovery
  ///
  /// In en, this message translates to:
  /// **'Search contributions...'**
  String get searchContributions;

  /// Sort button label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Message when no contributions match search/filters
  ///
  /// In en, this message translates to:
  /// **'No contributions found'**
  String get noContributionsFound;

  /// Hint message when no contributions are found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryDifferentSearch;

  /// Error message when contributions fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading contributions'**
  String get errorLoadingContributions;

  /// Tab label for trending templates
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// Average rating statistic label
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// Button to create new template
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get newTemplate;

  /// Placeholder text for template search
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get searchTemplates;

  /// Message when no public templates match search
  ///
  /// In en, this message translates to:
  /// **'No public templates found'**
  String get noPublicTemplatesFound;

  /// Placeholder message for trending templates
  ///
  /// In en, this message translates to:
  /// **'Trending templates coming soon!'**
  String get trendingComingSoon;

  /// Error message when template limit reached
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum number of templates'**
  String get maxTemplatesReached;

  /// Option to create template manually
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get createManually;

  /// Description for manual template creation
  ///
  /// In en, this message translates to:
  /// **'Build your template from scratch'**
  String get buildFromScratch;

  /// Option to import template from JSON
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get importFromJSON;

  /// Description for JSON import option
  ///
  /// In en, this message translates to:
  /// **'Import a template from JSON format'**
  String get importJSONDescription;

  /// Option to import template from a JSON file
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFromFile;

  /// Description for file import option
  ///
  /// In en, this message translates to:
  /// **'Select a JSON file from your device'**
  String get importFileDescription;

  /// Title for JSON format guidelines
  ///
  /// In en, this message translates to:
  /// **'JSON Format Guide'**
  String get jsonFormatGuide;

  /// Description of required JSON format
  ///
  /// In en, this message translates to:
  /// **'📝 How to convert your workout:\n1. Copy your workout (text or photo)\n2. Go to ChatGPT (free at chat.openai.com)\n3. Ask: \"Convert this workout to JSON format like this example\"\n4. Copy and paste the result below\n\n⚙️ Required fields: name, description, exercises array. Each exercise needs: exerciseName, sets with targetReps/targetWeight. Supersets need type:\"superset\" and exercises array.'**
  String get jsonFormatDescription;

  /// Tooltip for copying JSON example
  ///
  /// In en, this message translates to:
  /// **'Copy example'**
  String get copyExample;

  /// Message when JSON example is copied
  ///
  /// In en, this message translates to:
  /// **'Example copied to clipboard'**
  String get exampleCopied;

  /// Confirmation message when example is copied and pasted
  ///
  /// In en, this message translates to:
  /// **'Example copied and pasted in field'**
  String get exampleCopiedAndPasted;

  /// Instruction to tap example to copy and paste
  ///
  /// In en, this message translates to:
  /// **'Tap to copy and paste in field below'**
  String get tapToCopyAndPaste;

  /// Instruction to tap example to copy to clipboard only
  ///
  /// In en, this message translates to:
  /// **'Tap to copy to clipboard'**
  String get tapToCopyToClipboard;

  /// Text shown when example is minimized
  ///
  /// In en, this message translates to:
  /// **'Tap to expand example and guide'**
  String get tapToExpandExample;

  /// Button to hide keyboard
  ///
  /// In en, this message translates to:
  /// **'Hide Keyboard'**
  String get hideKeyboard;

  /// Message when exercise is not found in database during JSON import
  ///
  /// In en, this message translates to:
  /// **'Exercise \"{exerciseName}\" not found in database - using original name'**
  String exerciseNotFoundInDatabase(String exerciseName);

  /// Header for missing exercise widget
  ///
  /// In en, this message translates to:
  /// **'Can\'t find the exercise?'**
  String get exerciseNotFound;

  /// Description when exercise is not found
  ///
  /// In en, this message translates to:
  /// **'The exercise \"{exerciseName}\" was not found in our database. What would you like to do?'**
  String exerciseNotFoundDescription(String exerciseName);

  /// Generic help text for missing exercise feature
  ///
  /// In en, this message translates to:
  /// **'Add it temporarily and we\'ll include it in the database soon!'**
  String get exerciseNotFoundHelpText;

  /// Question asking user what they want to do
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// Option to choose exercise from database
  ///
  /// In en, this message translates to:
  /// **'Choose from Database'**
  String get chooseFromDatabase;

  /// Option to create custom exercise
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get createCustom;

  /// Option to use original exercise name
  ///
  /// In en, this message translates to:
  /// **'Use Original Name'**
  String get useOriginalName;

  /// Button to skip weight selection and use default values
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Dialog title for selecting exercise from database
  ///
  /// In en, this message translates to:
  /// **'Select Exercise from Database'**
  String get selectExerciseFromDatabase;

  /// Message when database is empty
  ///
  /// In en, this message translates to:
  /// **'No exercises found in database'**
  String get noExercisesInDatabase;

  /// Dialog title for creating custom exercise
  ///
  /// In en, this message translates to:
  /// **'Create Custom Exercise'**
  String get createCustomExercise;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Note about custom exercises
  ///
  /// In en, this message translates to:
  /// **'This exercise will be saved to your personal list'**
  String get customExerciseNote;

  /// Button to create something
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Dialog title for premium features
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// Message about custom exercise limit for free users
  ///
  /// In en, this message translates to:
  /// **'Free users can create up to 3 custom exercises per import. Upgrade to Premium for unlimited custom exercises!'**
  String get customExerciseLimit;

  /// Button to upgrade to premium
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// Delete template menu item
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// Confirmation message for deleting template
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{templateName}\"?'**
  String confirmDeleteTemplate(String templateName);

  /// Template deleted success message
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" deleted'**
  String templateDeleted(String name);

  /// Success message when share link is copied
  ///
  /// In en, this message translates to:
  /// **'Share link copied to clipboard!'**
  String get shareLinkCopied;

  /// Success message when template is downloaded
  ///
  /// In en, this message translates to:
  /// **'Template \"{templateName}\" downloaded!'**
  String templateDownloaded(String templateName);

  /// Error message when template download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download template'**
  String get failedToDownload;

  /// Instructions for JSON import dialog
  ///
  /// In en, this message translates to:
  /// **'Paste your workout template JSON below:'**
  String get pasteWorkoutJSON;

  /// Button to show JSON format example
  ///
  /// In en, this message translates to:
  /// **'View JSON Format'**
  String get viewJSONFormat;

  /// Placeholder text for JSON input field
  ///
  /// In en, this message translates to:
  /// **'Paste JSON here...'**
  String get pasteJSONHere;

  /// Import button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Error message when JSON field is empty
  ///
  /// In en, this message translates to:
  /// **'Please paste JSON content'**
  String get pleaseProvideJSON;

  /// Success message when template is imported
  ///
  /// In en, this message translates to:
  /// **'Template \"{templateName}\" imported successfully!'**
  String templateImportedSuccessfully(String templateName);

  /// Default name for imported programs
  ///
  /// In en, this message translates to:
  /// **'Imported Program'**
  String get importedProgram;

  /// Error message when program has no days
  ///
  /// In en, this message translates to:
  /// **'No days found in program'**
  String get noDaysFoundInProgram;

  /// Dialog title for selecting which day to import
  ///
  /// In en, this message translates to:
  /// **'Select Day to Import'**
  String get selectDayToImport;

  /// Program information in day selection dialog
  ///
  /// In en, this message translates to:
  /// **'Found program \"{programName}\" with {dayCount} days:'**
  String programFoundWithDays(String programName, int dayCount);

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Exercise count label
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// Template description for imported days
  ///
  /// In en, this message translates to:
  /// **'Imported from program: {programName}'**
  String importedFromProgram(String programName);

  /// Error message when JSON import fails
  ///
  /// In en, this message translates to:
  /// **'Error importing JSON: {error}'**
  String errorImportingJSON(String error);

  /// Placeholder for filter functionality
  ///
  /// In en, this message translates to:
  /// **'Filters coming soon'**
  String get filtersComingSoon;

  /// Template author attribution
  ///
  /// In en, this message translates to:
  /// **'by {authorName}'**
  String byAuthor(String authorName);

  /// Fallback name for unknown author
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Week time period label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month time period label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Progress improvement label
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// Progress decline label
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Progress stall label
  ///
  /// In en, this message translates to:
  /// **'Stall'**
  String get stall;

  /// Total exercises stats label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalExercises;

  /// Migration stat label
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// Average volume per workout statistic
  ///
  /// In en, this message translates to:
  /// **'Avg Volume Per Workout'**
  String get avgVolumePerWorkout;

  /// Average label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Personal record label
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// Trend label
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// Chest workout category
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// Back workout category
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Shoulders muscle group
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// Arms workout category
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// Legs workout category
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// Abdominals muscle group
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get abs;

  /// Cardio workout category
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// Other exercise category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Personal/custom template badge
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// Number of times a template has been used
  ///
  /// In en, this message translates to:
  /// **'usages'**
  String get usages;

  /// Title for muscle group breakdown section
  ///
  /// In en, this message translates to:
  /// **'Muscle Distribution'**
  String get muscleDistribution;

  /// Core muscle group
  ///
  /// In en, this message translates to:
  /// **'CORE (Abs/Lower Back)'**
  String get core;

  /// Full chest muscle group name
  ///
  /// In en, this message translates to:
  /// **'Chest Muscles'**
  String get chestFull;

  /// Full back muscle group name
  ///
  /// In en, this message translates to:
  /// **'Back Muscles'**
  String get backFull;

  /// Full shoulders muscle group name
  ///
  /// In en, this message translates to:
  /// **'Shoulder Muscles'**
  String get shouldersFull;

  /// Full arms muscle group name
  ///
  /// In en, this message translates to:
  /// **'Arm Muscles'**
  String get armsFull;

  /// Full legs muscle group name
  ///
  /// In en, this message translates to:
  /// **'Leg Muscles'**
  String get legsFull;

  /// Full core muscle group name
  ///
  /// In en, this message translates to:
  /// **'Core Muscles'**
  String get coreFull;

  /// Overview tab label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Strength tab label
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// Insights tab label
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Muscle balance section title
  ///
  /// In en, this message translates to:
  /// **'Muscle Balance'**
  String get muscleBalance;

  /// All exercises section title
  ///
  /// In en, this message translates to:
  /// **'All Exercises'**
  String get allExercises;

  /// Training insights section title
  ///
  /// In en, this message translates to:
  /// **'Training Insights'**
  String get trainingInsights;

  /// Recommendations section header
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Exercise trends section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Trends'**
  String get exerciseTrends;

  /// Current workout streak statistic
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Total personal records statistic
  ///
  /// In en, this message translates to:
  /// **'Total PRs'**
  String get totalPRs;

  /// Volume change statistic
  ///
  /// In en, this message translates to:
  /// **'Volume Change'**
  String get volumeChange;

  /// Max weight personal record label
  ///
  /// In en, this message translates to:
  /// **'Max Weight'**
  String get maxWeight;

  /// Maximum reps statistic
  ///
  /// In en, this message translates to:
  /// **'Max Reps'**
  String get maxReps;

  /// Estimated one-rep max label
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get estimated1RM;

  /// Volume progression chart title
  ///
  /// In en, this message translates to:
  /// **'Volume Progression'**
  String get volumeProgression;

  /// Weekly period label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly period label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Volume statistics section title
  ///
  /// In en, this message translates to:
  /// **'Volume Statistics'**
  String get volumeStatistics;

  /// Please login message
  ///
  /// In en, this message translates to:
  /// **'Please Login'**
  String get pleaseLogin;

  /// Message to start workout for analytics
  ///
  /// In en, this message translates to:
  /// **'Start a workout to see your analytics'**
  String get startWorkoutToSeeAnalytics;

  /// Recent workouts section title
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentWorkouts;

  /// Label for high priority recommendation
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriority;

  /// Insight label
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insight;

  /// Recommendation label
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// Expand button label
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// Collapse button label
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// Scientific strategies section title
  ///
  /// In en, this message translates to:
  /// **'Scientific Strategies'**
  String get scientificStrategies;

  /// Data points section title
  ///
  /// In en, this message translates to:
  /// **'Data Points'**
  String get dataPoints;

  /// About strength progression dialog title
  ///
  /// In en, this message translates to:
  /// **'About Strength Progression'**
  String get aboutStrengthProgression;

  /// Strength progression information text
  ///
  /// In en, this message translates to:
  /// **'Track your strength gains over time with estimated 1RM calculations and progressive overload indicators.'**
  String get strengthProgressionInfo;

  /// Back to home button tooltip
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Back to home while keeping workout active
  ///
  /// In en, this message translates to:
  /// **'Back to Home (Keep Workout)'**
  String get backToHomeKeepWorkout;

  /// Back to home tooltip while keeping workout active
  ///
  /// In en, this message translates to:
  /// **'Back to Home (Keep Workout Active)'**
  String get backToHomeKeepWorkoutActive;

  /// Button text to unlock premium features
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Features'**
  String get unlockPremiumFeatures;

  /// Title for premium volume analysis features
  ///
  /// In en, this message translates to:
  /// **'Premium Volume Features'**
  String get premiumVolumeFeatures;

  /// Advanced analytics insights section title
  ///
  /// In en, this message translates to:
  /// **'Advanced Insights'**
  String get advancedInsights;

  /// Recovery recommendation section title
  ///
  /// In en, this message translates to:
  /// **'Recovery Recommendation'**
  String get recoveryRecommendation;

  /// Training intensity metric label
  ///
  /// In en, this message translates to:
  /// **'Training Intensity'**
  String get trainingIntensity;

  /// Message when no data exists for selected time period
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected period'**
  String get noDataForSelectedPeriod;

  /// Previous period label
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Instruction to tap for more details
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// Option to compare with historical data
  ///
  /// In en, this message translates to:
  /// **'Compare with history'**
  String get compareWithHistory;

  /// Best volume achieved label
  ///
  /// In en, this message translates to:
  /// **'Best Volume'**
  String get bestVolume;

  /// Title for muscle balance chart
  ///
  /// In en, this message translates to:
  /// **'Muscle Group Balance'**
  String get muscleGroupBalance;

  /// Overall muscle balance score
  ///
  /// In en, this message translates to:
  /// **'Overall Balance'**
  String get overallBalance;

  /// Excellent muscle balance rating
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellentBalance;

  /// Good muscle balance rating
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodBalance;

  /// Moderate muscle balance rating
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderateBalance;

  /// Poor muscle balance rating
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poorBalance;

  /// Compare with previous period option
  ///
  /// In en, this message translates to:
  /// **'Compare Previous'**
  String get comparePrevious;

  /// Current strength level label
  ///
  /// In en, this message translates to:
  /// **'Current Strength'**
  String get currentStrength;

  /// Explanation of how strength is calculated
  ///
  /// In en, this message translates to:
  /// **'Strength is calculated based on volume progression relative to your previous best'**
  String get strengthCalculationHint;

  /// Button tooltip asking about calculation method
  ///
  /// In en, this message translates to:
  /// **'How is this calculated?'**
  String get howIsThisCalculated;

  /// Tooltip for refresh animation button
  ///
  /// In en, this message translates to:
  /// **'Refresh Animation'**
  String get refreshAnimation;

  /// Button to edit target values
  ///
  /// In en, this message translates to:
  /// **'Edit Targets'**
  String get editTargets;

  /// Instruction to tap to edit target
  ///
  /// In en, this message translates to:
  /// **'Tap to edit target'**
  String get tapToEditTarget;

  /// Target strength level label
  ///
  /// In en, this message translates to:
  /// **'Target Strength'**
  String get targetStrength;

  /// Comparison with last month
  ///
  /// In en, this message translates to:
  /// **'Compared to last month'**
  String get comparedToLastMonth;

  /// Recommended exercises section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Exercises'**
  String get recommendedExercises;

  /// Volume breakdown by exercise
  ///
  /// In en, this message translates to:
  /// **'Volume Breakdown'**
  String get volumeBreakdown;

  /// Explanation of strength calculation
  ///
  /// In en, this message translates to:
  /// **'Based on {volume}kg total volume'**
  String strengthExplanation(String volume);

  /// Dialog title explaining strength calculation
  ///
  /// In en, this message translates to:
  /// **'How Strength is Calculated'**
  String get howStrengthIsCalculated;

  /// Detailed explanation of strength calculation
  ///
  /// In en, this message translates to:
  /// **'Strength percentage is calculated based on your training volume compared to your historical maximum volume for each muscle group.'**
  String get strengthCalculationExplanation;

  /// Volume calculation formula title
  ///
  /// In en, this message translates to:
  /// **'Volume Formula'**
  String get volumeFormula;

  /// Strength percentage calculation title
  ///
  /// In en, this message translates to:
  /// **'Strength Percentage'**
  String get strengthPercentage;

  /// Explanation of target system
  ///
  /// In en, this message translates to:
  /// **'Targets are customizable goals that help you maintain balanced training across all muscle groups.'**
  String get targetExplanation;

  /// Message when previous workout weights are loaded
  ///
  /// In en, this message translates to:
  /// **'Previous weights loaded successfully'**
  String get previousWeightsLoaded;

  /// Title for strength gains insight
  ///
  /// In en, this message translates to:
  /// **'Strength Gains'**
  String get insightStrengthGainsTitle;

  /// Message for strength gains insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve made significant strength improvements'**
  String get insightStrengthGainsMessage;

  /// Recommendation for strength gains insight
  ///
  /// In en, this message translates to:
  /// **'Keep pushing progressive overload to maintain momentum'**
  String get insightStrengthGainsRecommendation;

  /// Title for plateau insight
  ///
  /// In en, this message translates to:
  /// **'Performance Plateau'**
  String get insightPlateauTitle;

  /// Message for plateau insight
  ///
  /// In en, this message translates to:
  /// **'Your performance has plateaued recently'**
  String get insightPlateauMessage;

  /// Recommendation for plateau insight
  ///
  /// In en, this message translates to:
  /// **'Consider changing your routine or taking a deload week'**
  String get insightPlateauRecommendation;

  /// Title for volume surge insight
  ///
  /// In en, this message translates to:
  /// **'Volume Surge'**
  String get insightVolumeSurgeTitle;

  /// Message for volume surge insight
  ///
  /// In en, this message translates to:
  /// **'Your training volume has increased significantly'**
  String get insightVolumeSurgeMessage;

  /// Recommendation for volume surge insight
  ///
  /// In en, this message translates to:
  /// **'Monitor recovery and adjust if needed'**
  String get insightVolumeSurgeRecommendation;

  /// Title for volume drop insight
  ///
  /// In en, this message translates to:
  /// **'Volume Drop'**
  String get insightVolumeDropTitle;

  /// Message for volume drop insight
  ///
  /// In en, this message translates to:
  /// **'Your training volume has decreased'**
  String get insightVolumeDropMessage;

  /// Recommendation for volume drop insight
  ///
  /// In en, this message translates to:
  /// **'Gradually increase volume to maintain progress'**
  String get insightVolumeDropRecommendation;

  /// Title for volume plateau insight
  ///
  /// In en, this message translates to:
  /// **'Volume Plateau'**
  String get insightVolumePlateauTitle;

  /// Message for volume plateau insight
  ///
  /// In en, this message translates to:
  /// **'Your volume has remained stable'**
  String get insightVolumePlateauMessage;

  /// Recommendation for volume plateau insight
  ///
  /// In en, this message translates to:
  /// **'Consider progressive overload techniques'**
  String get insightVolumePlateauRecommendation;

  /// Title for low frequency insight
  ///
  /// In en, this message translates to:
  /// **'Low Training Frequency'**
  String get insightLowFrequencyTitle;

  /// Message for low frequency insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve been training less frequently'**
  String get insightLowFrequencyMessage;

  /// Recommendation for low frequency insight
  ///
  /// In en, this message translates to:
  /// **'Try to maintain consistent training schedule'**
  String get insightLowFrequencyRecommendation;

  /// Title for high load insight
  ///
  /// In en, this message translates to:
  /// **'High Training Load'**
  String get insightHighLoadTitle;

  /// Message for high load insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve been training with high intensity'**
  String get insightHighLoadMessage;

  /// Recommendation for high load insight
  ///
  /// In en, this message translates to:
  /// **'Make sure to get adequate rest and recovery'**
  String get insightHighLoadRecommendation;

  /// Title for consistency insight
  ///
  /// In en, this message translates to:
  /// **'Great Consistency'**
  String get insightGreatConsistencyTitle;

  /// Message for consistency insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve maintained excellent training consistency'**
  String get insightGreatConsistencyMessage;

  /// Recommendation for consistency insight
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get insightGreatConsistencyRecommendation;

  /// Title for extended break insight
  ///
  /// In en, this message translates to:
  /// **'Extended Break'**
  String get insightExtendedBreakTitle;

  /// Message for extended break insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve taken an extended break from training'**
  String get insightExtendedBreakMessage;

  /// Recommendation for extended break insight
  ///
  /// In en, this message translates to:
  /// **'Start with lighter loads and gradually progress'**
  String get insightExtendedBreakRecommendation;

  /// Title for chase PRs insight
  ///
  /// In en, this message translates to:
  /// **'Chase PRs'**
  String get insightChasePRsTitle;

  /// Message for chase PRs insight
  ///
  /// In en, this message translates to:
  /// **'You\'re close to setting new personal records'**
  String get insightChasePRsMessage;

  /// Recommendation for chase PRs insight
  ///
  /// In en, this message translates to:
  /// **'Focus on your strongest exercises for PR attempts'**
  String get insightChasePRsRecommendation;

  /// Title for PR week insight
  ///
  /// In en, this message translates to:
  /// **'PR Week'**
  String get insightPRWeekTitle;

  /// Message for PR week insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve set multiple PRs this week'**
  String get insightPRWeekMessage;

  /// Recommendation for PR week insight
  ///
  /// In en, this message translates to:
  /// **'Great job! Consider a deload to consolidate gains'**
  String get insightPRWeekRecommendation;

  /// Title for PR drought insight
  ///
  /// In en, this message translates to:
  /// **'PR Drought'**
  String get insightPRDroughtTitle;

  /// Message for PR drought insight
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while since your last PR'**
  String get insightPRDroughtMessage;

  /// Recommendation for PR drought insight
  ///
  /// In en, this message translates to:
  /// **'Try different rep ranges or exercise variations'**
  String get insightPRDroughtRecommendation;

  /// Title for muscle imbalance insight
  ///
  /// In en, this message translates to:
  /// **'Muscle Imbalance'**
  String get insightMuscleImbalanceTitle;

  /// Message for muscle imbalance insight
  ///
  /// In en, this message translates to:
  /// **'Some muscle groups are lagging behind'**
  String get insightMuscleImbalanceMessage;

  /// Recommendation for muscle imbalance insight
  ///
  /// In en, this message translates to:
  /// **'Focus more on weaker muscle groups'**
  String get insightMuscleImbalanceRecommendation;

  /// Title for focus adjustment insight
  ///
  /// In en, this message translates to:
  /// **'Focus Adjustment'**
  String get insightFocusAdjustmentTitle;

  /// Message for focus adjustment insight
  ///
  /// In en, this message translates to:
  /// **'Your training focus could be better balanced'**
  String get insightFocusAdjustmentMessage;

  /// Recommendation for focus adjustment insight
  ///
  /// In en, this message translates to:
  /// **'Adjust your program for better balance'**
  String get insightFocusAdjustmentRecommendation;

  /// Title for well balanced insight
  ///
  /// In en, this message translates to:
  /// **'Well Balanced'**
  String get insightWellBalancedTitle;

  /// Message for well balanced insight
  ///
  /// In en, this message translates to:
  /// **'Your training is well balanced across muscle groups'**
  String get insightWellBalancedMessage;

  /// Recommendation for well balanced insight
  ///
  /// In en, this message translates to:
  /// **'Keep maintaining this balanced approach'**
  String get insightWellBalancedRecommendation;

  /// Title for overtraining insight
  ///
  /// In en, this message translates to:
  /// **'Overtraining Risk'**
  String get insightOvertrainingTitle;

  /// Message for overtraining insight
  ///
  /// In en, this message translates to:
  /// **'You may be at risk of overtraining'**
  String get insightOvertrainingMessage;

  /// Recommendation for overtraining insight
  ///
  /// In en, this message translates to:
  /// **'Consider taking a rest day or deload week'**
  String get insightOvertrainingRecommendation;

  /// Title for recovery note insight
  ///
  /// In en, this message translates to:
  /// **'Recovery Note'**
  String get insightRecoveryNoteTitle;

  /// Message for recovery note insight
  ///
  /// In en, this message translates to:
  /// **'Your recovery metrics need attention'**
  String get insightRecoveryNoteMessage;

  /// Recommendation for recovery note insight
  ///
  /// In en, this message translates to:
  /// **'Focus on sleep, nutrition, and stress management'**
  String get insightRecoveryNoteRecommendation;

  /// Title for streak insight
  ///
  /// In en, this message translates to:
  /// **'Training Streak'**
  String get insightStreakTitle;

  /// Message for streak insight
  ///
  /// In en, this message translates to:
  /// **'You\'re on an impressive training streak'**
  String get insightStreakMessage;

  /// Recommendation for streak insight
  ///
  /// In en, this message translates to:
  /// **'Keep it up while listening to your body'**
  String get insightStreakRecommendation;

  /// Title for volume milestone insight
  ///
  /// In en, this message translates to:
  /// **'Volume Milestone'**
  String get insightVolumeMilestoneTitle;

  /// Message for volume milestone insight
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached a new volume milestone'**
  String get insightVolumeMilestoneMessage;

  /// Recommendation for volume milestone insight
  ///
  /// In en, this message translates to:
  /// **'Celebrate this achievement!'**
  String get insightVolumeMilestoneRecommendation;

  /// Title for PR machine insight
  ///
  /// In en, this message translates to:
  /// **'PR Machine'**
  String get insightPRMachineTitle;

  /// Message for PR machine insight
  ///
  /// In en, this message translates to:
  /// **'You\'re setting PRs consistently'**
  String get insightPRMachineMessage;

  /// Recommendation for PR machine insight
  ///
  /// In en, this message translates to:
  /// **'Amazing progress! Keep pushing your limits'**
  String get insightPRMachineRecommendation;

  /// Title for consistency bonus insight
  ///
  /// In en, this message translates to:
  /// **'Consistency Bonus'**
  String get insightConsistencyBonusTitle;

  /// Message for consistency bonus insight
  ///
  /// In en, this message translates to:
  /// **'Your consistency is paying off'**
  String get insightConsistencyBonusMessage;

  /// Recommendation for consistency bonus insight
  ///
  /// In en, this message translates to:
  /// **'Consistency is the key to long-term success'**
  String get insightConsistencyBonusRecommendation;

  /// Sign in required message
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequired;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Strength progression chart title
  ///
  /// In en, this message translates to:
  /// **'Strength Progression'**
  String get strengthProgression;

  /// Label for actual achievable weight
  ///
  /// In en, this message translates to:
  /// **'Actual Weight'**
  String get actualWeight;

  /// Trend line in charts
  ///
  /// In en, this message translates to:
  /// **'Trend Line'**
  String get trendLine;

  /// Current one rep max
  ///
  /// In en, this message translates to:
  /// **'Current 1RM'**
  String get current1RM;

  /// Best performance ever achieved
  ///
  /// In en, this message translates to:
  /// **'Best Ever'**
  String get bestEver;

  /// Message when no data exists for exercise
  ///
  /// In en, this message translates to:
  /// **'No data available for this exercise'**
  String get noDataForExercise;

  /// Message when multi-metric chart has no data
  ///
  /// In en, this message translates to:
  /// **'No data available for selected metrics'**
  String get noDataForChart;

  /// Hint text explaining that chart shows normalized values and user can tap to see actual values
  ///
  /// In en, this message translates to:
  /// **'Tap chart to see real values'**
  String get chartTapToSeeRealValues;

  /// Title for multi-metric overlay chart section
  ///
  /// In en, this message translates to:
  /// **'Multi-Metric Comparison'**
  String get multiMetricComparison;

  /// Volume heatmap chart title
  ///
  /// In en, this message translates to:
  /// **'Volume Heatmap'**
  String get volumeHeatmap;

  /// Days when workouts were performed
  ///
  /// In en, this message translates to:
  /// **'Workout Days'**
  String get workoutDays;

  /// Number of weeks to display
  ///
  /// In en, this message translates to:
  /// **'Weeks to Show'**
  String get weeksToShow;

  /// Less option
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// More option
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Number of exercises performed
  ///
  /// In en, this message translates to:
  /// **'Exercises Performed'**
  String get exercisesPerformed;

  /// Highest number of sets
  ///
  /// In en, this message translates to:
  /// **'Most Sets'**
  String get mostSets;

  /// Zoom out button
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// Reset zoom button
  ///
  /// In en, this message translates to:
  /// **'Reset Zoom'**
  String get resetZoom;

  /// Zoom in button
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// Workout name with exercise count
  ///
  /// In en, this message translates to:
  /// **'{workoutName} with {exerciseCount} exercises'**
  String workoutWithExercises(Object workoutName, Object exerciseCount);

  /// Total duration of workout
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// Day designated for rest
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDay;

  /// Exercise count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(int count);

  /// Duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String durationMinutes(Object minutes);

  /// Number of sets
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCount(int count);

  /// Label for a numbered set
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setLabel(Object number);

  /// Weight input field label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// Short label for repetitions
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get repsLabel;

  /// Effort or intensity label
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effortLabel;

  /// No description provided for @importedTemplate.
  ///
  /// In en, this message translates to:
  /// **'Imported Template'**
  String get importedTemplate;

  /// No description provided for @noExercisesFoundInJSON.
  ///
  /// In en, this message translates to:
  /// **'No exercises found in JSON'**
  String get noExercisesFoundInJSON;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Round number label
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(int number);

  /// Edit round data subtitle
  ///
  /// In en, this message translates to:
  /// **'Edit round data'**
  String get editRoundData;

  /// Weight input label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// Set updated success message
  ///
  /// In en, this message translates to:
  /// **'Set updated successfully'**
  String get setUpdated;

  /// Weight tab label in quick edit
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get quickEditWeight;

  /// Plates tab label in quick edit
  ///
  /// In en, this message translates to:
  /// **'Plates'**
  String get quickEditPlates;

  /// Percentage tab label in quick edit
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get quickEditPercentage;

  /// Reps label in quick edit
  ///
  /// In en, this message translates to:
  /// **'Reps:'**
  String get quickEditReps;

  /// RPE label in quick edit
  ///
  /// In en, this message translates to:
  /// **'RPE:'**
  String get quickEditRpe;

  /// Cancel button in quick edit
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quickEditCancel;

  /// Save button in quick edit
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get quickEditSave;

  /// Calculate button for 1RM in quick edit
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get quickEditCalculate;

  /// Message when copying values from previous set
  ///
  /// In en, this message translates to:
  /// **'Copied from Set {setNumber}'**
  String quickEditCopiedFromSet(int setNumber);

  /// Plate calculator section title
  ///
  /// In en, this message translates to:
  /// **'Plate Calculator'**
  String get plateCalculatorTitle;

  /// Italian 'Dischi' button for plate calculator
  ///
  /// In en, this message translates to:
  /// **'Plates'**
  String get plateCalculatorDischi;

  /// Select all plates button
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get plateCalculatorAll;

  /// Select standard plates button
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get plateCalculatorStandard;

  /// Recent weights section title
  ///
  /// In en, this message translates to:
  /// **'Recent Weights'**
  String get recentWeights;

  /// Quick weight adjustment section title
  ///
  /// In en, this message translates to:
  /// **'Quick Adjustment'**
  String get quickAdjustment;

  /// Barbell weight included message
  ///
  /// In en, this message translates to:
  /// **'Barbell {weight}kg included'**
  String barbellIncluded(double weight);

  /// No barbell selected message
  ///
  /// In en, this message translates to:
  /// **'No barbell'**
  String get noBarbell;

  /// Per side label for plate calculation
  ///
  /// In en, this message translates to:
  /// **'Per side:'**
  String get perSide;

  /// Only barbell message when no plates needed
  ///
  /// In en, this message translates to:
  /// **'Only barbell'**
  String get onlyBarbell;

  /// No plates needed message
  ///
  /// In en, this message translates to:
  /// **'No plates'**
  String get noPlates;

  /// Configure plates button text
  ///
  /// In en, this message translates to:
  /// **'Configure available plates'**
  String get configureAvailablePlates;

  /// Instructions for selecting available plates
  ///
  /// In en, this message translates to:
  /// **'Select the plates available in your gym:'**
  String get selectAvailablePlates;

  /// Select barbell dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Barbell'**
  String get selectBarbell;

  /// Select barbell button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectBarbellButton;

  /// Replace exercise swipe action
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// Action button to replace exercise in templates
  ///
  /// In en, this message translates to:
  /// **'Replace Exercise'**
  String get replaceExercise;

  /// Delete exercise dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExercise;

  /// Delete exercise confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this exercise from your workout.'**
  String get deleteExerciseDescription;

  /// Delete superset dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Superset'**
  String get deleteSuperset;

  /// Delete superset confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this superset and all its exercises from your workout.'**
  String get deleteSupersetDescription;

  /// Delete set dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete set {setNumber}?'**
  String deleteSetTitle(int setNumber);

  /// Delete warmup set dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete warmup set?'**
  String get deleteWarmupSetTitle;

  /// Delete set confirmation message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteSetMessage;

  /// Button to manually collapse completed exercise card
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapseExercise;

  /// Confirm action dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// Swipe instruction for deleting exercise
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get swipeToDeleteExercise;

  /// Swipe instruction for editing exercise
  ///
  /// In en, this message translates to:
  /// **'Swipe left to edit'**
  String get swipeToEditExercise;

  /// Swipe instruction for replacing exercise
  ///
  /// In en, this message translates to:
  /// **'Swipe left to replace'**
  String get swipeToReplaceExercise;

  /// Superset training title
  ///
  /// In en, this message translates to:
  /// **'Superset Training'**
  String get supersetTraining;

  /// Superset technique description
  ///
  /// In en, this message translates to:
  /// **'Superset: Perform two exercises back-to-back with no rest between them.'**
  String get supersetDescription;

  /// Selected exercises section title
  ///
  /// In en, this message translates to:
  /// **'Selected Exercises'**
  String get selectedExercises;

  /// Minimum exercises requirement message
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 exercises to create a superset'**
  String get addAtLeastTwoExercises;

  /// Add round button text
  ///
  /// In en, this message translates to:
  /// **'Add Round'**
  String get addRound;

  /// Rounds configuration section title
  ///
  /// In en, this message translates to:
  /// **'Rounds Configuration'**
  String get roundsConfiguration;

  /// Create superset button text
  ///
  /// In en, this message translates to:
  /// **'Create Superset'**
  String get createSuperset;

  /// Round label
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Exercise count message
  ///
  /// In en, this message translates to:
  /// **'All {count} exercises will be performed in this round'**
  String allExercisesWillBePerformed(int count);

  /// Optional field hint
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Rest settings section title
  ///
  /// In en, this message translates to:
  /// **'Rest Settings'**
  String get restSettings;

  /// Between exercises rest label
  ///
  /// In en, this message translates to:
  /// **'Between Exercises'**
  String get betweenExercises;

  /// Rest time between exercises description
  ///
  /// In en, this message translates to:
  /// **'Rest time between each exercise in a round'**
  String get restTimeBetweenExercises;

  /// After round rest label
  ///
  /// In en, this message translates to:
  /// **'After Round'**
  String get afterRound;

  /// Rest time after round description
  ///
  /// In en, this message translates to:
  /// **'Rest time after completing all exercises'**
  String get restTimeAfterRound;

  /// Label for set completion status (used in toggle and messages)
  ///
  /// In en, this message translates to:
  /// **'Set completed'**
  String get setCompleted;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Single exercise type
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// Superset exercise type
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get superset;

  /// Drop set exercise type
  ///
  /// In en, this message translates to:
  /// **'Drop Set'**
  String get dropset;

  /// Rest-pause exercise type
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause'**
  String get restPause;

  /// Instruction to select exercise from database
  ///
  /// In en, this message translates to:
  /// **'Tap to select from database'**
  String get tapToSelectFromDatabase;

  /// Rest time between exercises label
  ///
  /// In en, this message translates to:
  /// **'Rest between exercises'**
  String get restBetweenExercises;

  /// Seconds time unit
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Title for superset exercise selection
  ///
  /// In en, this message translates to:
  /// **'Select exercises for superset'**
  String get selectExercisesForSuperset;

  /// Title for drop set exercise selection
  ///
  /// In en, this message translates to:
  /// **'Select exercise for drop set'**
  String get selectExerciseForDropset;

  /// Title for rest-pause exercise selection
  ///
  /// In en, this message translates to:
  /// **'Select exercise for rest-pause'**
  String get selectExerciseForRestPause;

  /// Clear all selections button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Drop set stages label
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stages;

  /// Add new drop set stage button
  ///
  /// In en, this message translates to:
  /// **'Add Stage'**
  String get addStage;

  /// Label for number of mini-sets in rest-pause
  ///
  /// In en, this message translates to:
  /// **'mini-sets'**
  String get miniSets;

  /// Rest time label
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTime;

  /// Shows current exercise position in superset
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String supersetProgress(int current, int total);

  /// Instruction for superset navigation
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to navigate between exercises'**
  String get swipeToNavigate;

  /// Label for current exercise in superset
  ///
  /// In en, this message translates to:
  /// **'Current Exercise'**
  String get currentExercise;

  /// Next exercise button text
  ///
  /// In en, this message translates to:
  /// **'Next Exercise'**
  String get nextExercise;

  /// Previous exercise button text
  ///
  /// In en, this message translates to:
  /// **'Previous Exercise'**
  String get previousExercise;

  /// Complete current exercise and move to next
  ///
  /// In en, this message translates to:
  /// **'Complete & Next'**
  String get completeAndNext;

  /// Complete current exercise and finish superset
  ///
  /// In en, this message translates to:
  /// **'Complete & Finish'**
  String get completeAndFinish;

  /// Header text for RPE rating section
  ///
  /// In en, this message translates to:
  /// **'Rate Your Effort'**
  String get rateYourEffort;

  /// Button text to complete a set
  ///
  /// In en, this message translates to:
  /// **'Complete Set'**
  String get completeSet;

  /// Toggle text to verify weight and reps before RPE
  ///
  /// In en, this message translates to:
  /// **'Verify Weight & Reps'**
  String get verifyWeightReps;

  /// Toggle text to verify time before RPE (time counting mode)
  ///
  /// In en, this message translates to:
  /// **'Verify Minutes & Seconds'**
  String get verifyTime;

  /// Toggle text to verify reps before RPE (reps-only counting mode)
  ///
  /// In en, this message translates to:
  /// **'Verify Reps'**
  String get verifyReps;

  /// Title for exercise history bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Exercise History'**
  String get exerciseHistory;

  /// Error message when history fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get errorLoadingHistory;

  /// Statistics section header
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Label for average weight lifted
  ///
  /// In en, this message translates to:
  /// **'Avg Weight'**
  String get avgWeight;

  /// First workout date statistic label
  ///
  /// In en, this message translates to:
  /// **'First Workout'**
  String get firstWorkout;

  /// Message when no exercise history is available
  ///
  /// In en, this message translates to:
  /// **'No History Found'**
  String get noHistoryFound;

  /// Instruction text when no history is available
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see history'**
  String get completeWorkoutsToSeeHistory;

  /// Today time reference
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday time reference
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Workout database screen title
  ///
  /// In en, this message translates to:
  /// **'Workout Database'**
  String get workoutDatabase;

  /// Subtitle for editable workout history
  ///
  /// In en, this message translates to:
  /// **'Editable Workout History'**
  String get editableWorkoutHistory;

  /// Button to edit workout
  ///
  /// In en, this message translates to:
  /// **'Edit Workout'**
  String get editWorkout;

  /// Button to delete workout
  ///
  /// In en, this message translates to:
  /// **'Delete Workout'**
  String get deleteWorkout;

  /// Workout date format
  ///
  /// In en, this message translates to:
  /// **'Workout {day}/{month}/{year}'**
  String workoutDate(int day, int month, int year);

  /// Label for workout time
  ///
  /// In en, this message translates to:
  /// **'Workout Time'**
  String get workoutTime;

  /// Tooltip for removing a set
  ///
  /// In en, this message translates to:
  /// **'Remove Set'**
  String get removeSet;

  /// Button to save changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Button to discard changes
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Confirmation message for workout deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout? This action cannot be undone.'**
  String get deleteWorkoutConfirmation;

  /// Success message for workout deletion
  ///
  /// In en, this message translates to:
  /// **'Workout deleted successfully'**
  String get workoutDeletedSuccessfully;

  /// Success message for workout update
  ///
  /// In en, this message translates to:
  /// **'Workout updated successfully'**
  String get workoutUpdatedSuccessfully;

  /// Message when no workouts exist
  ///
  /// In en, this message translates to:
  /// **'No workouts in history'**
  String get noWorkoutsInHistory;

  /// Instructions when no workouts exist
  ///
  /// In en, this message translates to:
  /// **'Start tracking your workouts to see them here'**
  String get startTrackingWorkouts;

  /// Placeholder for workout search field
  ///
  /// In en, this message translates to:
  /// **'Search workouts...'**
  String get searchWorkouts;

  /// Option to filter workouts by exercise
  ///
  /// In en, this message translates to:
  /// **'Filter by exercise'**
  String get filterByExercise;

  /// Option to sort workouts by date
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get sortByDate;

  /// Option to sort workouts by duration
  ///
  /// In en, this message translates to:
  /// **'Sort by duration'**
  String get sortByDuration;

  /// Option to sort workouts by volume
  ///
  /// In en, this message translates to:
  /// **'Sort by volume'**
  String get sortByVolume;

  /// Title for data migration screen
  ///
  /// In en, this message translates to:
  /// **'Data Migration'**
  String get dataMigration;

  /// Description of what data migration does
  ///
  /// In en, this message translates to:
  /// **'Migrate your workout history from the old format to the new system for better performance and features.'**
  String get dataMigrationDescription;

  /// Message when no data needs migration
  ///
  /// In en, this message translates to:
  /// **'No data to migrate'**
  String get noDataToMigrate;

  /// Title for migration options section
  ///
  /// In en, this message translates to:
  /// **'Migration Options'**
  String get migrationOptions;

  /// Label for time window option
  ///
  /// In en, this message translates to:
  /// **'Time Window (hours)'**
  String get timeWindowHours;

  /// Option to create backup before migration
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Description for backup option
  ///
  /// In en, this message translates to:
  /// **'Create a backup of your data before migration'**
  String get createBackupDescription;

  /// Minimum exercises required to create a workout
  ///
  /// In en, this message translates to:
  /// **'Min exercises per workout'**
  String get minExercisesPerWorkout;

  /// Title for migration preview results
  ///
  /// In en, this message translates to:
  /// **'Migration Preview'**
  String get migrationPreview;

  /// Title for migration final results
  ///
  /// In en, this message translates to:
  /// **'Migration Results'**
  String get migrationResults;

  /// Label for number of workouts found
  ///
  /// In en, this message translates to:
  /// **'Workouts found'**
  String get workoutsFound;

  /// Label for number of successfully migrated workouts
  ///
  /// In en, this message translates to:
  /// **'Migrated workouts'**
  String get migratedWorkouts;

  /// Label for number of skipped exercises
  ///
  /// In en, this message translates to:
  /// **'Skipped exercises'**
  String get skippedExercises;

  /// Label for errors section
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// Title for workout groups preview list
  ///
  /// In en, this message translates to:
  /// **'Workout Groups Preview'**
  String get workoutGroupsPreview;

  /// Status when analyzing data
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analyzing;

  /// Status when migrating data
  ///
  /// In en, this message translates to:
  /// **'Migrating'**
  String get migrating;

  /// Button to analyze data for migration
  ///
  /// In en, this message translates to:
  /// **'Analyze Data'**
  String get analyzeData;

  /// Button to start the migration process
  ///
  /// In en, this message translates to:
  /// **'Start Migration'**
  String get startMigration;

  /// Title for migration confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Migration'**
  String get confirmMigration;

  /// Description for migration confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start the migration? This process cannot be undone.'**
  String get confirmMigrationDescription;

  /// Title for Firebase initialization section
  ///
  /// In en, this message translates to:
  /// **'Firebase Initialization'**
  String get firebaseInitialization;

  /// Title for current status section
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// Label for Firebase status
  ///
  /// In en, this message translates to:
  /// **'Firebase Status'**
  String get firebaseStatus;

  /// Status when Firebase is initialized
  ///
  /// In en, this message translates to:
  /// **'Initialized'**
  String get initialized;

  /// Status when Firebase is not initialized
  ///
  /// In en, this message translates to:
  /// **'Not Initialized'**
  String get notInitialized;

  /// Status when checking something
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// Status when a check fails
  ///
  /// In en, this message translates to:
  /// **'Check Failed'**
  String get checkFailed;

  /// Current database version label
  ///
  /// In en, this message translates to:
  /// **'Current Version'**
  String get currentVersion;

  /// Text when something is not available
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// Generic loading error message with error details
  ///
  /// In en, this message translates to:
  /// **'Loading error: {error}'**
  String loadingError(String error);

  /// Title for collection statistics
  ///
  /// In en, this message translates to:
  /// **'Collection Statistics'**
  String get collectionStats;

  /// Version metadata stat label
  ///
  /// In en, this message translates to:
  /// **'Version Metadata'**
  String get versionMetadata;

  /// Present status label
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// Missing status label
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// Search index stat label
  ///
  /// In en, this message translates to:
  /// **'Search Index'**
  String get searchIndex;

  /// Title for actions section
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Button text to initialize exercises
  ///
  /// In en, this message translates to:
  /// **'Initialize Exercises'**
  String get initializeExercises;

  /// Button text to verify data integrity
  ///
  /// In en, this message translates to:
  /// **'Verify Integrity'**
  String get verifyIntegrity;

  /// Button text to reset status
  ///
  /// In en, this message translates to:
  /// **'Reset Status'**
  String get resetStatus;

  /// Status text when operation is in progress
  ///
  /// In en, this message translates to:
  /// **'Operation in progress...'**
  String get operationInProgress;

  /// Status text when operation succeeds
  ///
  /// In en, this message translates to:
  /// **'Operation Successful'**
  String get operationSuccess;

  /// Status text when operation fails
  ///
  /// In en, this message translates to:
  /// **'Operation Error'**
  String get operationError;

  /// Label for details section
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Description for initialize operation
  ///
  /// In en, this message translates to:
  /// **'This will load all exercises from the local JSON file into Firebase. This operation may take several minutes.'**
  String get initializeDescription;

  /// Checkbox label to overwrite existing data
  ///
  /// In en, this message translates to:
  /// **'Overwrite Existing Data'**
  String get overwriteExisting;

  /// Warning description for overwrite option
  ///
  /// In en, this message translates to:
  /// **'Warning: This will delete all existing exercise data in Firebase'**
  String get overwriteExistingDescription;

  /// Label for optional version field
  ///
  /// In en, this message translates to:
  /// **'Version (Optional)'**
  String get versionOptional;

  /// Initialize button text
  ///
  /// In en, this message translates to:
  /// **'Initialize'**
  String get initialize;

  /// Admin dashboard title
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Analytics admin dashboard title
  ///
  /// In en, this message translates to:
  /// **'Analytics Dashboard'**
  String get analyticsAdmin;

  /// Manage exercises action title
  ///
  /// In en, this message translates to:
  /// **'Manage Exercises'**
  String get manageExercises;

  /// Manage exercises action description
  ///
  /// In en, this message translates to:
  /// **'Add, edit, remove exercises'**
  String get manageExercisesDescription;

  /// Review corrections action title
  ///
  /// In en, this message translates to:
  /// **'Review Corrections'**
  String get reviewCorrections;

  /// Review corrections action description
  ///
  /// In en, this message translates to:
  /// **'Review community exercise corrections'**
  String get reviewCorrectionsDescription;

  /// User analytics action title
  ///
  /// In en, this message translates to:
  /// **'User Analytics'**
  String get userAnalytics;

  /// User analytics action description
  ///
  /// In en, this message translates to:
  /// **'View user statistics'**
  String get userAnalyticsDescription;

  /// Database backup action title
  ///
  /// In en, this message translates to:
  /// **'Database Backup'**
  String get databaseBackup;

  /// Database backup action description
  ///
  /// In en, this message translates to:
  /// **'Backup system data'**
  String get databaseBackupDescription;

  /// Push notifications action title
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications action description
  ///
  /// In en, this message translates to:
  /// **'Send notifications to users'**
  String get pushNotificationsDescription;

  /// Message for features not yet implemented
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon'**
  String get featureComingSoon;

  /// Loading activity message
  ///
  /// In en, this message translates to:
  /// **'Loading activity...'**
  String get loadingActivity;

  /// Error loading activity message
  ///
  /// In en, this message translates to:
  /// **'Error loading activity'**
  String get errorLoadingActivity;

  /// No recent activity message
  ///
  /// In en, this message translates to:
  /// **'No Recent Activity'**
  String get noRecentActivity;

  /// No recent activity description
  ///
  /// In en, this message translates to:
  /// **'Community corrections and activities will appear here'**
  String get noRecentActivityDescription;

  /// All recent activity dialog title
  ///
  /// In en, this message translates to:
  /// **'All Recent Activity'**
  String get allRecentActivity;

  /// Suggested correction activity type
  ///
  /// In en, this message translates to:
  /// **'Suggested correction'**
  String get suggestedCorrection;

  /// Approved correction activity type
  ///
  /// In en, this message translates to:
  /// **'Approved correction'**
  String get approvedCorrection;

  /// Rejected correction activity type
  ///
  /// In en, this message translates to:
  /// **'Rejected correction'**
  String get rejectedCorrection;

  /// Generic activity type prefix
  ///
  /// In en, this message translates to:
  /// **'Activity for'**
  String get activityFor;

  /// Timestamp showing hours elapsed
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Timestamp showing minutes elapsed
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Timestamp indicating action just happened
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Admin info section title
  ///
  /// In en, this message translates to:
  /// **'Admin Information'**
  String get adminInfo;

  /// Welcome message for admin
  ///
  /// In en, this message translates to:
  /// **'Welcome, Admin!'**
  String get welcomeAdmin;

  /// Admin dashboard description
  ///
  /// In en, this message translates to:
  /// **'Manage the FitLog Pro system and review community contributions'**
  String get adminDashboardDescription;

  /// System stats section title
  ///
  /// In en, this message translates to:
  /// **'System Statistics'**
  String get systemStatistics;

  /// Firebase database section title
  ///
  /// In en, this message translates to:
  /// **'Firebase Database'**
  String get firebaseDatabase;

  /// Community activity section title
  ///
  /// In en, this message translates to:
  /// **'Community Activity'**
  String get communityActivity;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Version control action title
  ///
  /// In en, this message translates to:
  /// **'Version Control'**
  String get versionControl;

  /// Version control action description
  ///
  /// In en, this message translates to:
  /// **'Manage app versions'**
  String get versionControlDescription;

  /// Exercise count stat label
  ///
  /// In en, this message translates to:
  /// **'Exercise Count'**
  String get exerciseCountLabel;

  /// Title for pending corrections section
  ///
  /// In en, this message translates to:
  /// **'Pending Corrections'**
  String get pendingCorrections;

  /// Title for approved corrections
  ///
  /// In en, this message translates to:
  /// **'Approved Corrections'**
  String get approvedCorrections;

  /// Title for rejected corrections
  ///
  /// In en, this message translates to:
  /// **'Rejected Corrections'**
  String get rejectedCorrections;

  /// Total users stat label
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// Loading stats message
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStats;

  /// Error loading stats message
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStats;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Secure admin access label
  ///
  /// In en, this message translates to:
  /// **'Secure Admin Access'**
  String get secureAdminAccess;

  /// System overview section title
  ///
  /// In en, this message translates to:
  /// **'System Overview'**
  String get systemOverview;

  /// Firebase management section title
  ///
  /// In en, this message translates to:
  /// **'Firebase Management'**
  String get firebaseManagement;

  /// Admin info description text
  ///
  /// In en, this message translates to:
  /// **'Admin panel for system management and community oversight'**
  String get adminInfoDescription;

  /// Exercise management title
  ///
  /// In en, this message translates to:
  /// **'Exercise Management'**
  String get exerciseManagement;

  /// Exercise management description
  ///
  /// In en, this message translates to:
  /// **'Add, edit, and organize exercise database'**
  String get exerciseManagementDescription;

  /// Community corrections title
  ///
  /// In en, this message translates to:
  /// **'Community Corrections'**
  String get communityCorrections;

  /// Community corrections description
  ///
  /// In en, this message translates to:
  /// **'Review and approve community-submitted exercise corrections'**
  String get communityCorrectionsDescription;

  /// Button to fix missing exercises in database
  ///
  /// In en, this message translates to:
  /// **'Fix Missing Data'**
  String get fixMissingData;

  /// Description for the fix missing data action
  ///
  /// In en, this message translates to:
  /// **'Identify and add missing exercises to the database'**
  String get fixMissingDataDescription;

  /// Error message when corrections fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading corrections'**
  String get errorLoadingCorrections;

  /// Message when no corrections are available
  ///
  /// In en, this message translates to:
  /// **'No corrections found'**
  String get noCorrections;

  /// Description for empty corrections state
  ///
  /// In en, this message translates to:
  /// **'Community corrections will appear here when submitted'**
  String get noCorrectionsDescription;

  /// Title for reviewed corrections section
  ///
  /// In en, this message translates to:
  /// **'Reviewed Corrections'**
  String get reviewedCorrections;

  /// Title for approve correction dialog
  ///
  /// In en, this message translates to:
  /// **'Approve Correction'**
  String get approveCorrection;

  /// Title for reject correction dialog
  ///
  /// In en, this message translates to:
  /// **'Reject Correction'**
  String get rejectCorrection;

  /// Confirmation message for approving correction
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this correction?'**
  String get confirmApproval;

  /// Approve button text
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Label for rejection reason field
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// Hint text for rejection reason field
  ///
  /// In en, this message translates to:
  /// **'Explain why this correction is being rejected'**
  String get rejectionReasonHint;

  /// Label for who suggested the correction
  ///
  /// In en, this message translates to:
  /// **'Suggested by'**
  String get suggestedBy;

  /// Label for type of correction
  ///
  /// In en, this message translates to:
  /// **'Correction Type'**
  String get correctionType;

  /// Label for current value in correction
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get currentValue;

  /// Label for proposed value in correction
  ///
  /// In en, this message translates to:
  /// **'Proposed Value'**
  String get proposedValue;

  /// Label for submission timestamp
  ///
  /// In en, this message translates to:
  /// **'Submitted At'**
  String get submittedAt;

  /// Label for who reviewed the correction
  ///
  /// In en, this message translates to:
  /// **'Reviewed by'**
  String get reviewedBy;

  /// Label for exercise image correction type
  ///
  /// In en, this message translates to:
  /// **'Exercise Image'**
  String get exerciseImage;

  /// Label for muscle focus correction type
  ///
  /// In en, this message translates to:
  /// **'Muscle Focus'**
  String get muscleFocus;

  /// Label for correction contribution type
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// Label for tip contribution type
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// Warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Label for variant contribution type
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant;

  /// Label for translation contribution type
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// Label for technique contribution type
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get technique;

  /// Status label for pending items
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Status label for approved items
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Status label for rejected items
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Button text for fix action
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get fix;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Generic label for status field
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Database Manager screen title
  ///
  /// In en, this message translates to:
  /// **'Database Manager'**
  String get databaseManager;

  /// Button to publish new exercise database version
  ///
  /// In en, this message translates to:
  /// **'Publish New Version'**
  String get publishNewVersion;

  /// Last publication date label
  ///
  /// In en, this message translates to:
  /// **'Last Published'**
  String get lastPublished;

  /// Total exercises count label
  ///
  /// In en, this message translates to:
  /// **'Total Exercises in Database'**
  String get totalExercisesInDb;

  /// Version history section title
  ///
  /// In en, this message translates to:
  /// **'Version History'**
  String get versionHistory;

  /// Publish version dialog title
  ///
  /// In en, this message translates to:
  /// **'Publish Version'**
  String get publishVersion;

  /// Version number input label
  ///
  /// In en, this message translates to:
  /// **'Version Number'**
  String get versionNumber;

  /// Changelog input label
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// Changelog input hint
  ///
  /// In en, this message translates to:
  /// **'Describe what changed in this version (e.g., \'Added 15 new shoulder exercises\')'**
  String get changelogHint;

  /// Publishing progress message
  ///
  /// In en, this message translates to:
  /// **'Publishing...'**
  String get publishing;

  /// Version published success message
  ///
  /// In en, this message translates to:
  /// **'Version {version} published successfully! All users will receive the update within 6 hours.'**
  String versionPublished(String version);

  /// Publish failed error message
  ///
  /// In en, this message translates to:
  /// **'Failed to publish version: {error}'**
  String publishFailed(String error);

  /// Force update checkbox label
  ///
  /// In en, this message translates to:
  /// **'Force Update (Required)'**
  String get forceUpdate;

  /// Force update description
  ///
  /// In en, this message translates to:
  /// **'If enabled, users must update to continue using the app'**
  String get forceUpdateDesc;

  /// Multi-select mode toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Multi-Select Mode'**
  String get multiSelectMode;

  /// Export all exercises to JSON menu item
  ///
  /// In en, this message translates to:
  /// **'Export All to JSON'**
  String get exportAllJson;

  /// Export selected exercises to JSON menu item
  ///
  /// In en, this message translates to:
  /// **'Export Selected to JSON'**
  String get exportSelectedJson;

  /// Import exercises from JSON menu item
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get importJson;

  /// Bodyweight exercises stats label
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get bodyweight;

  /// Unique muscles stats label
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get uniqueMuscles;

  /// Button to clear all active filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Bulk edit button
  ///
  /// In en, this message translates to:
  /// **'Bulk Edit'**
  String get bulkEdit;

  /// Export file subject
  ///
  /// In en, this message translates to:
  /// **'Exercises Export'**
  String get exercisesExport;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully'**
  String get exportSuccess;

  /// Import JSON dialog description
  ///
  /// In en, this message translates to:
  /// **'Import exercises from JSON file'**
  String get importJsonDescription;

  /// Import warning message
  ///
  /// In en, this message translates to:
  /// **'This will overwrite existing exercises!'**
  String get importWarning;

  /// Select file button
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Select field to bulk edit
  ///
  /// In en, this message translates to:
  /// **'Select Field'**
  String get selectField;

  /// New value for bulk edit
  ///
  /// In en, this message translates to:
  /// **'New Value'**
  String get newValue;

  /// Button to apply selected weight increase percentage
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Confirm delete multiple exercises
  ///
  /// In en, this message translates to:
  /// **'Delete {count} exercises?'**
  String confirmDeleteMultiple(int count);

  /// Exercise name validation message
  ///
  /// In en, this message translates to:
  /// **'Exercise name is required'**
  String get exerciseNameRequired;

  /// Update exercise button
  ///
  /// In en, this message translates to:
  /// **'Update Exercise'**
  String get updateExercise;

  /// Create exercise button
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExercise;

  /// Title for exercise database update dialog
  ///
  /// In en, this message translates to:
  /// **'Exercise Update Available'**
  String get exerciseUpdateAvailable;

  /// Description for exercise update dialog
  ///
  /// In en, this message translates to:
  /// **'A new version of the exercise database is available with improved exercises and features.'**
  String get exerciseUpdateDescription;

  /// Download now button text
  ///
  /// In en, this message translates to:
  /// **'Download Now'**
  String get downloadNow;

  /// Downloading progress text
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// Note about exercise update benefits
  ///
  /// In en, this message translates to:
  /// **'This will download the latest exercise data and improve your workout experience.'**
  String get exerciseUpdateNote;

  /// Time under tension field label
  ///
  /// In en, this message translates to:
  /// **'Time Under Tension'**
  String get tempoEsecuzione;

  /// Execution time note field label
  ///
  /// In en, this message translates to:
  /// **'Execution Time Note'**
  String get tempoNote;

  /// Image preview modal title
  ///
  /// In en, this message translates to:
  /// **'Image Preview'**
  String get imagePreview;

  /// Change image button text
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// Expand details section button
  ///
  /// In en, this message translates to:
  /// **'Expand Details'**
  String get expandDetails;

  /// Clear individual filter button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// Explanation of what Time Under Tension means
  ///
  /// In en, this message translates to:
  /// **'Time Under Tension (TUT) is the total amount of time a muscle is under strain during a set. It\'s a key factor for muscle growth and strength.'**
  String get timeUnderTensionExplanation;

  /// Basic explanation of Time Under Tension
  ///
  /// In en, this message translates to:
  /// **'TUT is the duration your muscles work during an exercise set. Longer TUT can lead to more muscle growth.'**
  String get tutBasicExplanation;

  /// Title showing the TUT format structure
  ///
  /// In en, this message translates to:
  /// **'TUT Format: X-Y-Z-W'**
  String get tutFormatTitle;

  /// Detailed explanation of the TUT format phases
  ///
  /// In en, this message translates to:
  /// **'The TUT format X-Y-Z-W represents the duration in seconds for each phase of an exercise: X (eccentric/lowering), Y (pause at bottom), Z (concentric/lifting), W (pause at top).'**
  String get tutFormatExplanation;

  /// Warmup tip for light intensity
  ///
  /// In en, this message translates to:
  /// **'Light warmup: Focus on dynamic stretches and light cardio to get your blood flowing.'**
  String get warmupTipLight;

  /// Warmup tip for moderate intensity
  ///
  /// In en, this message translates to:
  /// **'Moderate warmup: Include some light sets of your main exercise to prepare your muscles.'**
  String get warmupTipModerate;

  /// Warmup tip for heavy intensity
  ///
  /// In en, this message translates to:
  /// **'Heavy warmup: Gradually increase weight with several sets, ensuring proper form and muscle activation.'**
  String get warmupTipHeavy;

  /// Warmup tip for maximum effort intensity
  ///
  /// In en, this message translates to:
  /// **'Max effort warmup: Perform a few very light sets, then jump straight into your working sets with minimal rest.'**
  String get warmupTipMax;

  /// Text for chip to share advice with community
  ///
  /// In en, this message translates to:
  /// **'Share an advice'**
  String get shareAdviceWithCommunity;

  /// Menu option to view community advice for exercise
  ///
  /// In en, this message translates to:
  /// **'Community Advice'**
  String get communityAdvice;

  /// Admin section title for managing community contributions
  ///
  /// In en, this message translates to:
  /// **'Community Contributions'**
  String get communityContributions;

  /// Description for community contributions admin action
  ///
  /// In en, this message translates to:
  /// **'Review and manage community contributions'**
  String get reviewContributionsDescription;

  /// Text showing how many people found a contribution helpful
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =0{people} =1{person} other{people}} found this helpful'**
  String peopleFoundHelpful(int count);

  /// Message when no community advice is available for an exercise
  ///
  /// In en, this message translates to:
  /// **'No advice available for this exercise yet'**
  String get noAdviceAvailable;

  /// Encouraging message to be first to contribute advice
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your advice!'**
  String get beFirstToShare;

  /// Success message after submitting a contribution
  ///
  /// In en, this message translates to:
  /// **'Your contribution has been submitted for review!'**
  String get contributionSubmittedSuccess;

  /// Thank you message for community contributions
  ///
  /// In en, this message translates to:
  /// **'Thank you for helping the community!'**
  String get thankYouForContributing;

  /// Start workout menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Start workout with this template'**
  String get startWorkoutWithTemplate;

  /// Edit template menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// Edit template menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Modify exercises and sets'**
  String get editTemplateSubtitle;

  /// Share PDF menu item
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// Share PDF menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Export as PDF and share'**
  String get sharePdfSubtitle;

  /// Print menu item
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// Print template menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Print workout template'**
  String get printTemplate;

  /// Title for PDF export options dialog
  ///
  /// In en, this message translates to:
  /// **'PDF Export Options'**
  String get pdfExportOptions;

  /// Option for compact PDF format
  ///
  /// In en, this message translates to:
  /// **'Compact Format'**
  String get pdfDetailLevelCompact;

  /// Description for compact PDF format
  ///
  /// In en, this message translates to:
  /// **'Groups identical sets (e.g., 3 x 10)'**
  String get pdfDetailLevelCompactDesc;

  /// Option for detailed PDF format with weight
  ///
  /// In en, this message translates to:
  /// **'Detailed with Weight'**
  String get pdfDetailLevelDetailed;

  /// Description for detailed PDF format with weight
  ///
  /// In en, this message translates to:
  /// **'Shows each set with weight (e.g., Set 1: 20kg x 10)'**
  String get pdfDetailLevelDetailedDesc;

  /// Option for detailed PDF format without weight
  ///
  /// In en, this message translates to:
  /// **'Detailed without Weight'**
  String get pdfDetailLevelNoWeight;

  /// Description for detailed PDF format without weight
  ///
  /// In en, this message translates to:
  /// **'Shows each set with reps only (e.g., Set 1: 10 reps)'**
  String get pdfDetailLevelNoWeightDesc;

  /// Checkbox to save PDF export preference
  ///
  /// In en, this message translates to:
  /// **'Remember my choice'**
  String get rememberMyChoice;

  /// Delete template subtitle
  ///
  /// In en, this message translates to:
  /// **'Remove permanently'**
  String get deleteTemplateSubtitle;

  /// Error message when workout fails to start
  ///
  /// In en, this message translates to:
  /// **'Error starting workout: {error}'**
  String workoutStartError(String error);

  /// Timer notification title for rest timer completion
  ///
  /// In en, this message translates to:
  /// **'Rest Complete'**
  String get restComplete;

  /// Timer notification title for workout timer completion
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutComplete;

  /// Timer notification title for warmup timer completion
  ///
  /// In en, this message translates to:
  /// **'Warmup Complete'**
  String get warmupComplete;

  /// Timer notification title for cooldown timer completion
  ///
  /// In en, this message translates to:
  /// **'Cooldown Complete'**
  String get cooldownComplete;

  /// Generic timer notification body when exercise name is not available
  ///
  /// In en, this message translates to:
  /// **'Your timer has finished'**
  String get timerFinished;

  /// Timer notification body with set information
  ///
  /// In en, this message translates to:
  /// **'{exercise} - Set {currentSet}/{totalSets} complete'**
  String setComplete(String exercise, int currentSet, int totalSets);

  /// Timer notification body for exercise completion
  ///
  /// In en, this message translates to:
  /// **'{exercise} complete'**
  String exerciseComplete(String exercise);

  /// Success message after workout is saved
  ///
  /// In en, this message translates to:
  /// **'Workout saved!'**
  String get workoutSaved;

  /// Error message when workout save fails
  ///
  /// In en, this message translates to:
  /// **'Error saving workout'**
  String get errorSavingWorkout;

  /// Label for effort/RPE input field
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effortLevel;

  /// Title for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Message for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get unsavedChangesMessage;

  /// Label for custom workout name input
  ///
  /// In en, this message translates to:
  /// **'Enter workout name'**
  String get enterWorkoutName;

  /// Info message about exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Replacement keeps all sets and reps'**
  String get replacementKeepsSetsAndReps;

  /// Section title for smart exercise suggestions
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get smartSuggestions;

  /// Error message when exercises fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading exercises'**
  String get errorLoadingExercises;

  /// Title for exercise replacement confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm Replacement'**
  String get confirmReplacement;

  /// Confirmation message for exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Replace {oldExercise} with {newExercise}?'**
  String replaceExerciseConfirmation(String oldExercise, String newExercise);

  /// Success message for exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Exercise replaced successfully'**
  String get exerciseReplaced;

  /// Label for highly compatible exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Excellent replacement'**
  String get excellentReplacement;

  /// Label for compatible exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Highly compatible'**
  String get highlyCompatible;

  /// Label for good exercise alternative
  ///
  /// In en, this message translates to:
  /// **'Good alternative'**
  String get goodAlternative;

  /// Label for possible exercise alternative
  ///
  /// In en, this message translates to:
  /// **'Possible alternative'**
  String get possibleAlternative;

  /// Label for exercise with different muscle group
  ///
  /// In en, this message translates to:
  /// **'Different muscle group'**
  String get differentMuscleGroup;

  /// Browse exercise database button text
  ///
  /// In en, this message translates to:
  /// **'Browse Exercise Database'**
  String get browseExerciseDatabase;

  /// Exercise library description
  ///
  /// In en, this message translates to:
  /// **'Choose from our exercise library'**
  String get chooseFromLibrary;

  /// Prompt to create custom exercise
  ///
  /// In en, this message translates to:
  /// **'Can\'t find the exercise? Create a custom one'**
  String get cantFindExercise;

  /// Helper text for custom exercise section
  ///
  /// In en, this message translates to:
  /// **'Enter custom exercise details below:'**
  String get enterCustomExerciseDetails;

  /// Single exercise tab label
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get singleTab;

  /// Advanced exercises tab label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedTab;

  /// Optional notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Placeholder for notes field
  ///
  /// In en, this message translates to:
  /// **'Add notes about form, weight progression, etc.'**
  String get addNotesAboutForm;

  /// Exercise name field label
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseNameLabel;

  /// Example for exercise name field
  ///
  /// In en, this message translates to:
  /// **'e.g., Bench Press'**
  String get exerciseNameExample;

  /// Success message when exercise is added
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} to workout'**
  String addedToWorkout(String exerciseName);

  /// Label for APRE protocol
  ///
  /// In en, this message translates to:
  /// **'APRE Protocol'**
  String get apreProtocol;

  /// Label for APRE weight adjustment
  ///
  /// In en, this message translates to:
  /// **'APRE Adjustment'**
  String get apreAdjustment;

  /// Label for set weight in APRE
  ///
  /// In en, this message translates to:
  /// **'Set {setNumber} Weight:'**
  String apreSetWeight(int setNumber);

  /// APRE reps completed message
  ///
  /// In en, this message translates to:
  /// **'You completed {actual} reps (target: {target})'**
  String apreCompletedReps(int actual, int target);

  /// Button to apply APRE suggestion
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apreApply;

  /// Confirmation message for APRE weight adjustment
  ///
  /// In en, this message translates to:
  /// **'APRE: Set {setNumber} weight adjusted to {weight} kg'**
  String apreWeightAdjusted(int setNumber, String weight);

  /// APRE autoregulation toggle label
  ///
  /// In en, this message translates to:
  /// **'APRE Autoregulation'**
  String get apreAutoregulation;

  /// APRE autoregulation description
  ///
  /// In en, this message translates to:
  /// **'Automatic weight adjustment based on performance'**
  String get apreAutoregulationDescription;

  /// Label for APRE protocol selection
  ///
  /// In en, this message translates to:
  /// **'Select APRE Protocol'**
  String get apreProtocolSelect;

  /// Description for APRE 3 protocol
  ///
  /// In en, this message translates to:
  /// **'Heavy strength protocol (3 reps target)'**
  String get apreProtocol3Description;

  /// Description for APRE 6 protocol
  ///
  /// In en, this message translates to:
  /// **'Strength and hypertrophy protocol (6 reps target)'**
  String get apreProtocol6Description;

  /// Description for APRE 10 protocol
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy and endurance protocol (10 reps target)'**
  String get apreProtocol10Description;

  /// Label for APRE base weight input
  ///
  /// In en, this message translates to:
  /// **'APRE Base Weight'**
  String get apreBaseWeight;

  /// Hint for APRE base weight input
  ///
  /// In en, this message translates to:
  /// **'Enter your 3RM, 6RM or 10RM weight'**
  String get apreBaseWeightHint;

  /// Helper text for APRE 3 protocol
  ///
  /// In en, this message translates to:
  /// **'Use your 3 rep max weight'**
  String get apreProtocol3Helper;

  /// Helper text for APRE 6 protocol
  ///
  /// In en, this message translates to:
  /// **'Use your 6 rep max weight'**
  String get apreProtocol6Helper;

  /// Helper text for APRE 10 protocol
  ///
  /// In en, this message translates to:
  /// **'Use your 10 rep max weight'**
  String get apreProtocol10Helper;

  /// Title for APRE protocol change preview
  ///
  /// In en, this message translates to:
  /// **'Protocol Change Preview'**
  String get apreProtocolPreview;

  /// Description for protocol preview feature
  ///
  /// In en, this message translates to:
  /// **'Preview how your weights will change with the new protocol'**
  String get aprePreviewDescription;

  /// Label for current protocol in preview
  ///
  /// In en, this message translates to:
  /// **'Current (APRE {protocol})'**
  String apreCurrentProtocol(int protocol);

  /// Label for new protocol in preview
  ///
  /// In en, this message translates to:
  /// **'New (APRE {protocol})'**
  String apreNewProtocol(int protocol);

  /// Label for Set 1 in protocol preview
  ///
  /// In en, this message translates to:
  /// **'Set 1 (50%)'**
  String get apreSet1Preview;

  /// Label for Set 2 in protocol preview
  ///
  /// In en, this message translates to:
  /// **'Set 2 (75%)'**
  String get apreSet2Preview;

  /// Label for Set 3 in protocol preview
  ///
  /// In en, this message translates to:
  /// **'Set 3 (100%)'**
  String get apreSet3Preview;

  /// Label for Set 4 in protocol preview
  ///
  /// In en, this message translates to:
  /// **'Set 4'**
  String get apreSet4Preview;

  /// Description for Set 4 adjustment in protocol preview
  ///
  /// In en, this message translates to:
  /// **'Adjusted based on performance'**
  String get apreAdjustedBasedOnPerformance;

  /// Button to apply protocol changes in preview
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get apreApplyChanges;

  /// Label for automatic load adjustment feature
  ///
  /// In en, this message translates to:
  /// **'Auto Adjustment'**
  String get autoAdjustment;

  /// Description for auto adjustment feature
  ///
  /// In en, this message translates to:
  /// **'Automatic weight adjustment based on your performance'**
  String get autoAdjustmentDescription;

  /// Label for selecting auto adjustment type
  ///
  /// In en, this message translates to:
  /// **'Select Adjustment Type'**
  String get selectAutoAdjustmentType;

  /// Label for RPE/RIR based adjustment
  ///
  /// In en, this message translates to:
  /// **'RPE/RIR Based'**
  String get rpeBasedAdjustment;

  /// Description for RPE based adjustment
  ///
  /// In en, this message translates to:
  /// **'Adjust weight based on your perceived exertion'**
  String get rpeBasedDescription;

  /// Label for target RPE range
  ///
  /// In en, this message translates to:
  /// **'Target RPE Range'**
  String get rpeTargetRange;

  /// Hint for RPE target range input
  ///
  /// In en, this message translates to:
  /// **'e.g., 7-9 RPE'**
  String get rpeTargetRangeHint;

  /// Label for adjustment percentage
  ///
  /// In en, this message translates to:
  /// **'Adjustment %'**
  String get adjustmentPercentage;

  /// Increase weight suggestion
  ///
  /// In en, this message translates to:
  /// **'Increase by {percent}%'**
  String increaseWeightBy(String percent);

  /// Decrease weight suggestion
  ///
  /// In en, this message translates to:
  /// **'Decrease by {percent}%'**
  String decreaseWeightBy(String percent);

  /// Maintain weight suggestion
  ///
  /// In en, this message translates to:
  /// **'Maintain current weight'**
  String get maintainWeight;

  /// RPE autoregulation title
  ///
  /// In en, this message translates to:
  /// **'RPE Autoregulation'**
  String get rpeAutoregulation;

  /// Actual RPE label
  ///
  /// In en, this message translates to:
  /// **'Actual RPE'**
  String get actualRpe;

  /// Target range label
  ///
  /// In en, this message translates to:
  /// **'Target: {range}'**
  String targetRange(Object range);

  /// Actual RIR label
  ///
  /// In en, this message translates to:
  /// **'Actual RIR'**
  String get actualRir;

  /// Target RIR label
  ///
  /// In en, this message translates to:
  /// **'Target RIR'**
  String get targetRir;

  /// Suggested weight label
  ///
  /// In en, this message translates to:
  /// **'Suggested Weight'**
  String get suggestedWeight;

  /// Next set weight label
  ///
  /// In en, this message translates to:
  /// **'Next Set Weight'**
  String get nextSetWeight;

  /// Weight adjusted to message
  ///
  /// In en, this message translates to:
  /// **'Weight adjusted to'**
  String get weightAdjustedTo;

  /// Template onboarding step 1 - name field
  ///
  /// In en, this message translates to:
  /// **'Here insert the name of your workout plan'**
  String get templateOnboardingNameTitle;

  /// Template onboarding step 2 - description field
  ///
  /// In en, this message translates to:
  /// **'This is a description of what the plan includes'**
  String get templateOnboardingDescriptionTitle;

  /// Template onboarding step 2 - description subtitle
  ///
  /// In en, this message translates to:
  /// **'Optional - helps you remember what this plan is about'**
  String get templateOnboardingDescriptionSubtitle;

  /// Template onboarding step 3 - tags
  ///
  /// In en, this message translates to:
  /// **'Tags for community recognition'**
  String get templateOnboardingTagsTitle;

  /// Template onboarding step 3 - tags subtitle
  ///
  /// In en, this message translates to:
  /// **'Select tags that describe your template to help others find it in the community'**
  String get templateOnboardingTagsSubtitle;

  /// Template onboarding step 4 - rest timer
  ///
  /// In en, this message translates to:
  /// **'Default rest timer for all exercises'**
  String get templateOnboardingRestTimerTitle;

  /// Template onboarding step 4 - rest timer subtitle
  ///
  /// In en, this message translates to:
  /// **'When you add a new exercise without manually setting the timer, this default timer will be applied'**
  String get templateOnboardingRestTimerSubtitle;

  /// Template onboarding next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get templateOnboardingNext;

  /// Template onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get templateOnboardingSkip;

  /// Template onboarding finish button
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get templateOnboardingGotIt;

  /// Exercise onboarding step 1 - single tab
  ///
  /// In en, this message translates to:
  /// **'Start by adding a single exercise'**
  String get exerciseOnboardingSingleTabTitle;

  /// Exercise onboarding step 1 - single tab subtitle
  ///
  /// In en, this message translates to:
  /// **'This tab allows you to add one exercise at a time. You can also add supersets, dropsets, or rest-pause from other tabs'**
  String get exerciseOnboardingSingleTabSubtitle;

  /// Exercise onboarding step 2 - select button
  ///
  /// In en, this message translates to:
  /// **'Tap here to browse exercises'**
  String get exerciseOnboardingSelectButtonTitle;

  /// Exercise onboarding step 2 - select button subtitle
  ///
  /// In en, this message translates to:
  /// **'Open the exercise database to choose from hundreds of exercises'**
  String get exerciseOnboardingSelectButtonSubtitle;

  /// Exercise onboarding step 3 - search bar
  ///
  /// In en, this message translates to:
  /// **'Search for exercises'**
  String get exerciseOnboardingSearchTitle;

  /// Exercise onboarding step 3 - search bar subtitle
  ///
  /// In en, this message translates to:
  /// **'Type the name of the exercise you\'re looking for, like \"bench press\" or \"squat\"'**
  String get exerciseOnboardingSearchSubtitle;

  /// Exercise onboarding step 4 - exercise item
  ///
  /// In en, this message translates to:
  /// **'Select an exercise'**
  String get exerciseOnboardingExerciseItemTitle;

  /// Exercise onboarding step 4 - exercise item subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap to add it to your workout. Long press to see detailed information and execution tips'**
  String get exerciseOnboardingExerciseItemSubtitle;

  /// Exercise onboarding step 5 - filters
  ///
  /// In en, this message translates to:
  /// **'Filter by category or muscle group'**
  String get exerciseOnboardingFiltersTitle;

  /// Exercise onboarding step 5 - filters subtitle
  ///
  /// In en, this message translates to:
  /// **'Use filters to quickly find exercises for specific body parts'**
  String get exerciseOnboardingFiltersSubtitle;

  /// Exercise onboarding step 6 - confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm to add the exercise'**
  String get exerciseOnboardingConfirmTitle;

  /// Exercise onboarding step 6 - confirm button subtitle
  ///
  /// In en, this message translates to:
  /// **'Once you\'ve selected your exercises, tap here to add them to your workout'**
  String get exerciseOnboardingConfirmSubtitle;

  /// Exercise onboarding next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get exerciseOnboardingNext;

  /// Exercise onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get exerciseOnboardingSkip;

  /// Exercise onboarding finish button
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get exerciseOnboardingGotIt;

  /// Reset onboarding option title
  ///
  /// In en, this message translates to:
  /// **'Reset Onboarding'**
  String get resetOnboarding;

  /// Reset onboarding option description
  ///
  /// In en, this message translates to:
  /// **'Re-show tutorial guides for templates and exercises'**
  String get resetOnboardingDesc;

  /// Reset onboarding confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will reset all onboarding tutorials. They will be shown again the next time you create a template or add an exercise.'**
  String get resetOnboardingConfirm;

  /// Reset onboarding success message
  ///
  /// In en, this message translates to:
  /// **'Onboarding tutorials reset successfully'**
  String get onboardingResetSuccess;

  /// Optional description field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get templateDescriptionOptional;

  /// Template name field label
  ///
  /// In en, this message translates to:
  /// **'Template Name *'**
  String get templateNameLabel;

  /// Template name validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get templateNameRequired;

  /// Template description field hint
  ///
  /// In en, this message translates to:
  /// **'Brief workout description...'**
  String get templateDescriptionHint;

  /// Tags section title
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Tags section description
  ///
  /// In en, this message translates to:
  /// **'Select tags that describe your template'**
  String get selectTagsDescription;

  /// Default rest timer section title
  ///
  /// In en, this message translates to:
  /// **'Default Rest Timer'**
  String get defaultRestTimer;

  /// Default rest timer section description
  ///
  /// In en, this message translates to:
  /// **'Set a default timer that will be applied to all exercises in the template'**
  String get defaultRestTimerDescription;

  /// Section title for warmup protocol
  ///
  /// In en, this message translates to:
  /// **'Warmup Protocol'**
  String get warmupProtocol;

  /// Title for warmup phases info dialog
  ///
  /// In en, this message translates to:
  /// **'Understanding Warmup Phases'**
  String get warmupPhaseInfo;

  /// Title for warmup phase 1
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get warmupPhase1Title;

  /// Description for mobility phase
  ///
  /// In en, this message translates to:
  /// **'Prepares joints and range of motion with dynamic stretches. Examples: hip circles, arm swings, leg swings.'**
  String get warmupPhase1Desc;

  /// Title for warmup phase 2
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get warmupPhase2Title;

  /// Description for activation phase
  ///
  /// In en, this message translates to:
  /// **'Activates target muscles and stabilizers with light contractions. Examples: glute bridges, band work, light sets.'**
  String get warmupPhase2Desc;

  /// Title for warmup phase 3
  ///
  /// In en, this message translates to:
  /// **'Specific Warmup'**
  String get warmupPhase3Title;

  /// Description for warmup sets phase
  ///
  /// In en, this message translates to:
  /// **'Gradual progression towards working weight with the actual exercise. Examples: Bar×10, 40%×8, 60%×5, 80%×3.'**
  String get warmupPhase3Desc;

  /// Label for warmup sets field
  ///
  /// In en, this message translates to:
  /// **'Warmup Sets'**
  String get warmupSetsLabel;

  /// Label for warmup time field
  ///
  /// In en, this message translates to:
  /// **'Warmup Time'**
  String get warmupTimeLabel;

  /// Title for warmup info dialog
  ///
  /// In en, this message translates to:
  /// **'Complete Warmup Protocol'**
  String get warmupInfoDialogTitle;

  /// Question about warmup importance
  ///
  /// In en, this message translates to:
  /// **'Why is a proper warmup important?'**
  String get warmupWhyImportant;

  /// Answer about warmup importance
  ///
  /// In en, this message translates to:
  /// **'A proper warmup reduces injury risk, improves performance, prepares your nervous system, and optimizes your workout quality.'**
  String get warmupWhyImportantAnswer;

  /// Customize workout menu item
  ///
  /// In en, this message translates to:
  /// **'Customize Workout'**
  String get customizeWorkout;

  /// Workout customization modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable or disable features'**
  String get customizeWorkoutSubtitle;

  /// Display mode section title
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// Display mode section description
  ///
  /// In en, this message translates to:
  /// **'Choose your metrics detail level'**
  String get displayModeDescription;

  /// Base mode label
  ///
  /// In en, this message translates to:
  /// **'🌱 Base'**
  String get baseMode;

  /// Pro mode label
  ///
  /// In en, this message translates to:
  /// **'🚀 Pro'**
  String get proMode;

  /// Base mode activation message
  ///
  /// In en, this message translates to:
  /// **'Base Mode activated'**
  String get baseModeActivated;

  /// Pro mode activation message
  ///
  /// In en, this message translates to:
  /// **'Pro Mode activated'**
  String get proModeActivated;

  /// Core features section title
  ///
  /// In en, this message translates to:
  /// **'🏋️ Core Features'**
  String get coreFeaturesSection;

  /// Auto rest timer toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto Rest Timer'**
  String get autoRestTimerTitle;

  /// Auto rest timer toggle description
  ///
  /// In en, this message translates to:
  /// **'Automatically start timer after each set'**
  String get autoRestTimerDescription;

  /// Auto rest timer tooltip
  ///
  /// In en, this message translates to:
  /// **'When enabled, the rest timer starts automatically when you complete a set, helping you maintain consistent rest intervals.'**
  String get autoRestTimerTooltip;

  /// Warmup suggestions toggle title
  ///
  /// In en, this message translates to:
  /// **'Warmup Suggestions'**
  String get warmupSuggestionsTitle;

  /// Warmup suggestions toggle description
  ///
  /// In en, this message translates to:
  /// **'Automatically calculate warmup sets'**
  String get warmupSuggestionsDescription;

  /// Warmup suggestions tooltip
  ///
  /// In en, this message translates to:
  /// **'The system will suggest progressive warmup sets based on your working weight, preparing your muscles and nervous system.'**
  String get warmupSuggestionsTooltip;

  /// Auto collapse toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto-Collapse Completed'**
  String get autoCollapseTitle;

  /// Auto collapse toggle description
  ///
  /// In en, this message translates to:
  /// **'Automatically collapse completed exercises'**
  String get autoCollapseDescription;

  /// Auto collapse tooltip
  ///
  /// In en, this message translates to:
  /// **'Completed exercises will automatically minimize to keep your workout screen clean and focused on active exercises.'**
  String get autoCollapseTooltip;

  /// Auto-regulation section title
  ///
  /// In en, this message translates to:
  /// **'⚡ Intelligent Auto-Regulation'**
  String get intelligentAutoRegulation;

  /// APRE system subsection title
  ///
  /// In en, this message translates to:
  /// **'📈 APRE System'**
  String get apreSystemTitle;

  /// APRE system subsection subtitle
  ///
  /// In en, this message translates to:
  /// **'Reps-Based Auto-Regulation'**
  String get apreSystemSubtitle;

  /// Enable APRE toggle title
  ///
  /// In en, this message translates to:
  /// **'Enable APRE'**
  String get enableApreTitle;

  /// Enable APRE toggle description
  ///
  /// In en, this message translates to:
  /// **'Automatic weight calculation from history for new exercises'**
  String get enableApreDescription;

  /// Enable APRE tooltip
  ///
  /// In en, this message translates to:
  /// **'APRE analyzes your training history to calculate your 1RM and automatically suggests appropriate weights for each protocol (3, 6, or 10 reps).'**
  String get enableApreTooltip;

  /// APRE protocol selector title
  ///
  /// In en, this message translates to:
  /// **'APRE Protocol'**
  String get apreProtocolTitle;

  /// APRE 3 protocol label
  ///
  /// In en, this message translates to:
  /// **'APRE 3'**
  String get apre3;

  /// APRE 6 protocol label
  ///
  /// In en, this message translates to:
  /// **'APRE 6'**
  String get apre6;

  /// APRE 10 protocol label
  ///
  /// In en, this message translates to:
  /// **'APRE 10'**
  String get apre10;

  /// APRE 3 protocol description
  ///
  /// In en, this message translates to:
  /// **'Ideal for maximum strength (3+ reps to failure)'**
  String get apre3Description;

  /// APRE 6 protocol description
  ///
  /// In en, this message translates to:
  /// **'Balanced for strength and hypertrophy (6+ reps)'**
  String get apre6Description;

  /// APRE 10 protocol description
  ///
  /// In en, this message translates to:
  /// **'Perfect for hypertrophy and endurance (10+ reps)'**
  String get apre10Description;

  /// Auto-adjust rest from APRE toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto-Adjust Rest Time'**
  String get autoAdjustRestApreTitle;

  /// Auto-adjust rest from APRE toggle description
  ///
  /// In en, this message translates to:
  /// **'Increase rest if load decreases'**
  String get autoAdjustRestApreDescription;

  /// Auto-adjust rest from APRE tooltip
  ///
  /// In en, this message translates to:
  /// **'When your lifted weight decreases, the system automatically increases rest time to help manage fatigue.'**
  String get autoAdjustRestApreTooltip;

  /// RPE system subsection title
  ///
  /// In en, this message translates to:
  /// **'💪 RPE/RIR System'**
  String get rpeSystemTitle;

  /// RPE system subsection subtitle
  ///
  /// In en, this message translates to:
  /// **'Effort-Based Auto-Regulation'**
  String get rpeSystemSubtitle;

  /// Enable RPE toggle title
  ///
  /// In en, this message translates to:
  /// **'Enable RPE Tracking'**
  String get enableRpeTitle;

  /// Enable RPE toggle description
  ///
  /// In en, this message translates to:
  /// **'Request perceived effort after each set'**
  String get enableRpeDescription;

  /// Enable RPE tooltip
  ///
  /// In en, this message translates to:
  /// **'RPE (Rate of Perceived Exertion) helps you track how hard each set feels, enabling smart auto-regulation based on your fatigue level.'**
  String get enableRpeTooltip;

  /// V4 dialog title for dependency warning
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attentionRequired;

  /// V4 dialog button to enable feature
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// V4 essentials section title
  ///
  /// In en, this message translates to:
  /// **'Essentials'**
  String get essentialsSection;

  /// V4 essentials section description
  ///
  /// In en, this message translates to:
  /// **'Core settings to get started'**
  String get essentialsSectionDesc;

  /// V4 advanced section title
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedSection;

  /// V4 advanced section description
  ///
  /// In en, this message translates to:
  /// **'Customizations for experienced users'**
  String get advancedSectionDesc;

  /// V4 visualization subcategory title
  ///
  /// In en, this message translates to:
  /// **'Visualization'**
  String get visualizationCategory;

  /// V4 auto-regulation subcategory title
  ///
  /// In en, this message translates to:
  /// **'Auto-regulation'**
  String get autoRegulationCategory;

  /// V4 interface subcategory title
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interfaceCategory;

  /// Enable TUT toggle title
  ///
  /// In en, this message translates to:
  /// **'Enable TUT Tracking'**
  String get enableTutTitle;

  /// Enable TUT toggle description
  ///
  /// In en, this message translates to:
  /// **'Track Time Under Tension for each set'**
  String get enableTutDescription;

  /// Enable TUT tooltip
  ///
  /// In en, this message translates to:
  /// **'TUT (Time Under Tension) measures how long each set takes, helping you optimize muscle growth by tracking execution speed and rest times.'**
  String get enableTutTooltip;

  /// Set duration tracking toggle title
  ///
  /// In en, this message translates to:
  /// **'Track Set Duration (TUT)'**
  String get setDurationTrackingTitle;

  /// Set duration tracking toggle description
  ///
  /// In en, this message translates to:
  /// **'Measure Time Under Tension for each set'**
  String get setDurationTrackingDescription;

  /// Set duration tracking tooltip
  ///
  /// In en, this message translates to:
  /// **'Automatically track how long each set takes from start to completion, excluding rest time. This helps analyze your execution speed and optimize muscle growth.'**
  String get setDurationTrackingTooltip;

  /// Exercise start button main text
  ///
  /// In en, this message translates to:
  /// **'Start tracking duration'**
  String get startTrackingDuration;

  /// Countdown message during set preparation
  ///
  /// In en, this message translates to:
  /// **'Get ready...'**
  String get getReady;

  /// Message when countdown reaches zero
  ///
  /// In en, this message translates to:
  /// **'GO! Start your set'**
  String get goStartYourSet;

  /// Auto-adjust weight from RPE toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto-Adjust Weight'**
  String get autoAdjustWeightRpeTitle;

  /// Auto-adjust weight from RPE toggle description
  ///
  /// In en, this message translates to:
  /// **'Adjust weight based on RPE feedback'**
  String get autoAdjustWeightRpeDescription;

  /// Auto-adjust weight from RPE tooltip
  ///
  /// In en, this message translates to:
  /// **'RPE 9-10: suggest -2.5kg/-5%. RPE ≤6: suggest +2.5kg/+5%. Helps you find the optimal load for your current state.'**
  String get autoAdjustWeightRpeTooltip;

  /// Auto-adjust rest from RPE toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto-Adjust Rest Time'**
  String get autoAdjustRestRpeTitle;

  /// Auto-adjust rest from RPE toggle description
  ///
  /// In en, this message translates to:
  /// **'Adjust rest based on effort level'**
  String get autoAdjustRestRpeDescription;

  /// Auto-adjust rest from RPE tooltip
  ///
  /// In en, this message translates to:
  /// **'RPE 8-10: +30s rest. RPE ≤6: -15s rest. Automatically adapts recovery time to your fatigue level.'**
  String get autoAdjustRestRpeTooltip;

  /// Information section title
  ///
  /// In en, this message translates to:
  /// **'📊 Information & Insights'**
  String get informationInsightsSection;

  /// Exercise details toggle title
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetailsTitle;

  /// Exercise details toggle description
  ///
  /// In en, this message translates to:
  /// **'Show notes and detailed statistics'**
  String get exerciseDetailsDescription;

  /// Exercise details tooltip
  ///
  /// In en, this message translates to:
  /// **'Display comprehensive exercise information including personal notes, progress statistics, and performance insights.'**
  String get exerciseDetailsTooltip;

  /// Community suggestions toggle title
  ///
  /// In en, this message translates to:
  /// **'Community Suggestions'**
  String get communitySuggestionsTitle;

  /// Community suggestions toggle description
  ///
  /// In en, this message translates to:
  /// **'Show tips from the community'**
  String get communitySuggestionsDescription;

  /// Community suggestions tooltip
  ///
  /// In en, this message translates to:
  /// **'Get helpful advice and tips from other experienced athletes for each exercise.'**
  String get communitySuggestionsTooltip;

  /// TUT info toggle title
  ///
  /// In en, this message translates to:
  /// **'TUT Information'**
  String get tutInfoTitle;

  /// TUT info toggle description
  ///
  /// In en, this message translates to:
  /// **'Display Time Under Tension info'**
  String get tutInfoDescription;

  /// TUT info tooltip
  ///
  /// In en, this message translates to:
  /// **'Show tempo (e.g., 3-1-2-0) to control exercise speed and maximize muscle engagement.'**
  String get tutInfoTooltip;

  /// Quick access section title
  ///
  /// In en, this message translates to:
  /// **'🎯 Quick Access'**
  String get quickAccessSection;

  /// Quick access icons toggle title
  ///
  /// In en, this message translates to:
  /// **'Quick Access Icons'**
  String get quickAccessIconsTitle;

  /// Quick access icons toggle description
  ///
  /// In en, this message translates to:
  /// **'Show info, warmup, and prevention icons'**
  String get quickAccessIconsDescription;

  /// Quick access icons tooltip
  ///
  /// In en, this message translates to:
  /// **'Enable quick access buttons in exercise headers for instant access to information, warmup suggestions, and injury prevention tips.'**
  String get quickAccessIconsTooltip;

  /// Interface section title
  ///
  /// In en, this message translates to:
  /// **'⚙️ Interface & Performance'**
  String get interfaceSection;

  /// Advanced menu toggle title
  ///
  /// In en, this message translates to:
  /// **'Advanced Options Menu'**
  String get advancedMenuTitle;

  /// Advanced menu toggle description
  ///
  /// In en, this message translates to:
  /// **'Show advanced options in exercise menu'**
  String get advancedMenuDescription;

  /// Advanced menu tooltip
  ///
  /// In en, this message translates to:
  /// **'Display additional advanced options like exercise replacement, technique variations, and detailed settings.'**
  String get advancedMenuTooltip;

  /// Custom timers toggle title
  ///
  /// In en, this message translates to:
  /// **'Custom Timers'**
  String get customTimersTitle;

  /// Custom timers toggle description
  ///
  /// In en, this message translates to:
  /// **'Show custom timer settings per exercise'**
  String get customTimersDescription;

  /// Custom timers tooltip
  ///
  /// In en, this message translates to:
  /// **'Set specific rest times for individual exercises, perfect for different training intensities.'**
  String get customTimersTooltip;

  /// Collapse countdown toggle title
  ///
  /// In en, this message translates to:
  /// **'Collapse Countdown Animation'**
  String get collapseCountdownTitle;

  /// Collapse countdown toggle description
  ///
  /// In en, this message translates to:
  /// **'Show countdown before auto-collapse'**
  String get collapseCountdownDescription;

  /// Collapse countdown tooltip
  ///
  /// In en, this message translates to:
  /// **'Display a visual countdown before exercises automatically collapse, giving you time to review.'**
  String get collapseCountdownTooltip;

  /// Simplified animations toggle title
  ///
  /// In en, this message translates to:
  /// **'Simplified Animations'**
  String get simplifiedAnimationsTitle;

  /// Simplified animations toggle description
  ///
  /// In en, this message translates to:
  /// **'Use simpler and faster animations'**
  String get simplifiedAnimationsDescription;

  /// Simplified animations tooltip
  ///
  /// In en, this message translates to:
  /// **'Reduce animation complexity for better performance on older devices or if you prefer a snappier interface.'**
  String get simplifiedAnimationsTooltip;

  /// Settings auto-save info message
  ///
  /// In en, this message translates to:
  /// **'Settings are automatically saved and applied to all future workouts'**
  String get settingsAutoSaved;

  /// Action button with exercise name and reason
  ///
  /// In en, this message translates to:
  /// **'Replace {exercise} ({reason})'**
  String replaceExerciseReason(String exercise, String reason);

  /// Reason for exercise replacement - plateau
  ///
  /// In en, this message translates to:
  /// **'Plateau Detected'**
  String get plateauDetected;

  /// Reason for exercise replacement - form warning
  ///
  /// In en, this message translates to:
  /// **'Form Risk'**
  String get formRisk;

  /// Title for replacement exercise selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Replacement Exercise'**
  String get selectReplacement;

  /// Section title for similar exercises list
  ///
  /// In en, this message translates to:
  /// **'Similar Exercises'**
  String get similarExercises;

  /// Title for template selection
  ///
  /// In en, this message translates to:
  /// **'Select Templates to Update'**
  String get selectTemplates;

  /// Confirm button text with template count
  ///
  /// In en, this message translates to:
  /// **'Apply to {count, plural, =1{1 template} other{{count} templates}}'**
  String applyToTemplates(int count);

  /// Success message after exercise replacement
  ///
  /// In en, this message translates to:
  /// **'Exercise replaced successfully in {count, plural, =1{1 template} other{{count} templates}}'**
  String exerciseReplacedSuccess(int count);

  /// Message when no similar exercises are available
  ///
  /// In en, this message translates to:
  /// **'No similar exercises found'**
  String get noSimilarExercises;

  /// Error message when no template is selected
  ///
  /// In en, this message translates to:
  /// **'Select at least one template'**
  String get selectAtLeastOneTemplate;

  /// Section title for weight handling options
  ///
  /// In en, this message translates to:
  /// **'Weight Handling'**
  String get weightHandling;

  /// Option to keep current weight when replacing exercise
  ///
  /// In en, this message translates to:
  /// **'Keep current weight'**
  String get keepCurrentWeight;

  /// Option to reset weight when replacing exercise
  ///
  /// In en, this message translates to:
  /// **'Reset weight (start fresh)'**
  String get resetWeight;

  /// Option to set weight manually later
  ///
  /// In en, this message translates to:
  /// **'Set manually later'**
  String get setManually;

  /// Subtitle for muscle balance chart
  ///
  /// In en, this message translates to:
  /// **'Volume Distribution'**
  String get volumeDistribution;

  /// Title for scientific ratios section
  ///
  /// In en, this message translates to:
  /// **'Scientific Ratios'**
  String get scientificRatios;

  /// Empty state message for muscle balance
  ///
  /// In en, this message translates to:
  /// **'No muscle group data available'**
  String get noMuscleGroupData;

  /// Title for help dialog
  ///
  /// In en, this message translates to:
  /// **'Muscle Balance Science'**
  String get muscleBalanceScience;

  /// Explanation of muscle balance
  ///
  /// In en, this message translates to:
  /// **'Muscle balance analysis shows volume distribution and scientifically validated ratios to prevent injury and optimize performance.'**
  String get muscleBalanceExplanation;

  /// Title for progressive overload regression insight
  ///
  /// In en, this message translates to:
  /// **'Volume Regression Detected'**
  String get insightProgressiveOverloadRegressionTitle;

  /// Message for progressive overload regression
  ///
  /// In en, this message translates to:
  /// **'Volume decreased by {overloadPercent}% on {exerciseName}'**
  String insightProgressiveOverloadRegressionMessage(
    String overloadPercent,
    String exerciseName,
  );

  /// Recommendation for regression
  ///
  /// In en, this message translates to:
  /// **'Verify recovery status and training stress. Reference: Kraemer & Ratamess (2004)'**
  String get insightProgressiveOverloadRegressionRec;

  /// Title for excessive overload
  ///
  /// In en, this message translates to:
  /// **'Excessive Volume Increase'**
  String get insightProgressiveOverloadExcessiveTitle;

  /// Message for excessive overload
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} volume increased by {overloadPercent}%'**
  String insightProgressiveOverloadExcessiveMessage(
    String overloadPercent,
    String exerciseName,
  );

  /// Recommendation for excessive overload
  ///
  /// In en, this message translates to:
  /// **'HIGH risk of overtraining/injury. Consider reducing volume. Reference: ACSM (2009)'**
  String get insightProgressiveOverloadExcessiveRec;

  /// Title for optimal overload
  ///
  /// In en, this message translates to:
  /// **'Optimal Progressive Overload'**
  String get insightProgressiveOverloadOptimalTitle;

  /// Message for optimal overload
  ///
  /// In en, this message translates to:
  /// **'{exerciseName}: +{overloadPercent}% volume increase'**
  String insightProgressiveOverloadOptimalMessage(
    String overloadPercent,
    String exerciseName,
  );

  /// Recommendation for optimal overload
  ///
  /// In en, this message translates to:
  /// **'Perfect sustainable progression rate! Reference: Kraemer & Ratamess (2004)'**
  String get insightProgressiveOverloadOptimalRec;

  /// Title for low volume
  ///
  /// In en, this message translates to:
  /// **'Below Optimal Volume'**
  String get insightVolumeLowTitle;

  /// Message for low volume
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup}: {currentSets} sets/week (target: {targetMin}+)'**
  String insightVolumeLowMessage(
    String muscleGroup,
    String currentSets,
    String targetMin,
  );

  /// Recommendation for low volume
  ///
  /// In en, this message translates to:
  /// **'Consider adding sets for optimal hypertrophy. Reference: Schoenfeld et al. (2017)'**
  String get insightVolumeLowRec;

  /// Title for excessive volume
  ///
  /// In en, this message translates to:
  /// **'Excessive Weekly Volume'**
  String get insightVolumeExcessiveTitle;

  /// Message for excessive volume
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup}: {currentSets} sets/week (max recommended: {maxRecommended})'**
  String insightVolumeExcessiveMessage(
    String muscleGroup,
    String currentSets,
    String maxRecommended,
  );

  /// Recommendation for excessive volume
  ///
  /// In en, this message translates to:
  /// **'Risk of overtraining. Consider deload week. Reference: Schoenfeld et al. (2017)'**
  String get insightVolumeExcessiveRec;

  /// Title for low intensity
  ///
  /// In en, this message translates to:
  /// **'Low Training Intensity'**
  String get insightIntensityLowTitle;

  /// Message for low intensity
  ///
  /// In en, this message translates to:
  /// **'{exerciseName}: {percentOf1RM}% 1RM ({weight}kg × {reps} reps)'**
  String insightIntensityLowMessage(
    String exerciseName,
    String percentOf1RM,
    String weight,
    String reps,
  );

  /// Recommendation for low intensity
  ///
  /// In en, this message translates to:
  /// **'Better for muscular endurance. Increase weight for hypertrophy/strength. Reference: Reynolds et al. (2006)'**
  String get insightIntensityLowRec;

  /// Title for push pull imbalance
  ///
  /// In en, this message translates to:
  /// **'Push:Pull Imbalance'**
  String get insightPushPullImbalanceTitle;

  /// Message for push pull imbalance
  ///
  /// In en, this message translates to:
  /// **'Ratio: {ratio}:1 ({pushSets} push, {pullSets} pull sets)'**
  String insightPushPullImbalanceMessage(
    String ratio,
    String pushSets,
    String pullSets,
  );

  /// Recommendation for push pull imbalance
  ///
  /// In en, this message translates to:
  /// **'{feedback} Reference: Boyle (2016)'**
  String insightPushPullImbalanceRec(String feedback);

  /// Title for high risk quad ham ratio
  ///
  /// In en, this message translates to:
  /// **'HIGH Hamstring Injury Risk'**
  String get insightQuadHamHighRiskTitle;

  /// Message for high risk
  ///
  /// In en, this message translates to:
  /// **'Quad:Ham ratio {ratio}:1 ({quadSets} quad, {hamSets} hamstring sets)'**
  String insightQuadHamHighRiskMessage(
    String ratio,
    String quadSets,
    String hamSets,
  );

  /// Recommendation for high risk
  ///
  /// In en, this message translates to:
  /// **'Hamstrings severely under-trained ({riskMultiplier} injury risk). Add RDLs, leg curls immediately. Reference: Croisier et al. (2008)'**
  String insightQuadHamHighRiskRec(String riskMultiplier);

  /// Generic processing message shown during async operations
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Error message when user needs to authenticate
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please sign in again.'**
  String get errorAuthenticationRequired;

  /// Error when user tries to modify someone else's template
  ///
  /// In en, this message translates to:
  /// **'Cannot modify this template. You can only edit your own templates.'**
  String get errorCannotModifyTemplate;

  /// Error for network/connectivity issues
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetworkConnection;

  /// Generic error message for unexpected errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @pushPullRatio.
  ///
  /// In en, this message translates to:
  /// **'Push:Pull Ratio'**
  String get pushPullRatio;

  /// No description provided for @quadHamstringRatio.
  ///
  /// In en, this message translates to:
  /// **'Quad:Hamstring Ratio'**
  String get quadHamstringRatio;

  /// No description provided for @pushSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Push sets'**
  String pushSetsLabel(Object count);

  /// No description provided for @pullSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Pull sets'**
  String pullSetsLabel(Object count);

  /// No description provided for @quadSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Quad sets'**
  String quadSetsLabel(Object count);

  /// No description provided for @hamstringSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Hamstring sets'**
  String hamstringSetsLabel(Object count);

  /// No description provided for @pushPullExplanation.
  ///
  /// In en, this message translates to:
  /// **'Equal or Pull-emphasized for shoulder health and posture'**
  String get pushPullExplanation;

  /// No description provided for @quadHamExplanation.
  ///
  /// In en, this message translates to:
  /// **'Ratio <0.6 increases hamstring injury risk by 17x'**
  String get quadHamExplanation;

  /// No description provided for @feedbackTooMuchPull.
  ///
  /// In en, this message translates to:
  /// **'Too much Pull volume - increase Push work'**
  String get feedbackTooMuchPull;

  /// No description provided for @feedbackTooMuchPush.
  ///
  /// In en, this message translates to:
  /// **'Too much Push volume - risk of postural imbalances. Increase Pull work'**
  String get feedbackTooMuchPush;

  /// No description provided for @feedbackSlightPushExcess.
  ///
  /// In en, this message translates to:
  /// **'Slight Push excess - consider more Pull volume for shoulder health'**
  String get feedbackSlightPushExcess;

  /// No description provided for @feedbackOptimalPushPull.
  ///
  /// In en, this message translates to:
  /// **'Optimal Push:Pull balance'**
  String get feedbackOptimalPushPull;

  /// No description provided for @feedbackGoodPullEmphasis.
  ///
  /// In en, this message translates to:
  /// **'Good Pull emphasis - ideal for shoulder health'**
  String get feedbackGoodPullEmphasis;

  /// No description provided for @feedbackHamstringSeverelyUndertrained.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings severely under-trained - HIGH injury risk. Add RDLs, leg curls'**
  String get feedbackHamstringSeverelyUndertrained;

  /// No description provided for @feedbackHamstringUndertrained.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings under-trained - increase posterior chain volume'**
  String get feedbackHamstringUndertrained;

  /// No description provided for @feedbackOptimalQuadHam.
  ///
  /// In en, this message translates to:
  /// **'Optimal Quad:Hamstring balance'**
  String get feedbackOptimalQuadHam;

  /// No description provided for @feedbackHamstringOveremphasized.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings potentially over-emphasized vs quads'**
  String get feedbackHamstringOveremphasized;

  /// No description provided for @insightDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Insights are based on your recent training data and scientific research'**
  String get insightDisclaimer;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get mediumPriority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get lowPriority;

  /// No description provided for @whyThisMatters.
  ///
  /// In en, this message translates to:
  /// **'Why This Matters'**
  String get whyThisMatters;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @evidenceBasedSolutions.
  ///
  /// In en, this message translates to:
  /// **'Evidence-Based Solutions'**
  String get evidenceBasedSolutions;

  /// No description provided for @howToImplement.
  ///
  /// In en, this message translates to:
  /// **'How to implement:'**
  String get howToImplement;

  /// Subtitle for Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Track your fitness journey'**
  String get trackYourFitnessJourney;

  /// Description for not authenticated view
  ///
  /// In en, this message translates to:
  /// **'Track your workouts and monitor your progress'**
  String get trackYourWorkoutsAndMonitorProgress;

  /// Message shown when user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'Sign in to view analytics'**
  String get signInToViewAnalytics;

  /// Empty state title for no workouts
  ///
  /// In en, this message translates to:
  /// **'Start Your First Workout'**
  String get startYourFirstWorkout;

  /// Empty state description for no workouts
  ///
  /// In en, this message translates to:
  /// **'Start your first workout to see analytics'**
  String get startYourFirstWorkoutDesc;

  /// Motivational quote for analytics empty state
  ///
  /// In en, this message translates to:
  /// **'The journey of a thousand miles begins with a single rep'**
  String get fitnessQuoteEmptyState;

  /// Label for pro tip section in empty states
  ///
  /// In en, this message translates to:
  /// **'💡 Pro Tip:'**
  String get proTip;

  /// Pro tip for first workout in analytics empty state
  ///
  /// In en, this message translates to:
  /// **'Start with compound movements like squats and bench press for maximum gains'**
  String get proTipFirstWorkout;

  /// Error message when analytics fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics'**
  String get errorLoadingAnalytics;

  /// Title for account-related errors
  ///
  /// In en, this message translates to:
  /// **'Account Error'**
  String get accountError;

  /// Error message when user data cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load user data. Please sign out and sign in again.'**
  String get unableToLoadUserData;

  /// Year period filter
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Title for this week's progress
  ///
  /// In en, this message translates to:
  /// **'This Week Progress'**
  String get thisWeekProgress;

  /// Title for this month's progress
  ///
  /// In en, this message translates to:
  /// **'This Month Progress'**
  String get thisMonthProgress;

  /// Title for this year's progress
  ///
  /// In en, this message translates to:
  /// **'This Year Progress'**
  String get thisYearProgress;

  /// Title for all time progress
  ///
  /// In en, this message translates to:
  /// **'All Time Progress'**
  String get allTimeProgress;

  /// Subtitle for last 7 days period
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// Subtitle for last 30 days period
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// Subtitle for last 365 days period
  ///
  /// In en, this message translates to:
  /// **'Last 365 days'**
  String get last365Days;

  /// Subtitle for all time period
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// Encouragement message for active streak
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// Button to view detailed statistics
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// Description for no recent workouts state
  ///
  /// In en, this message translates to:
  /// **'Start a workout to see your progress'**
  String get noRecentWorkoutsDesc;

  /// Title for no recent workouts state
  ///
  /// In en, this message translates to:
  /// **'No recent workouts'**
  String get noRecentWorkouts;

  /// Label showing workout count
  ///
  /// In en, this message translates to:
  /// **'{count} workouts'**
  String workoutsCount(int count);

  /// Label showing reps count
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String repsCount(int count);

  /// Message when no activities in selected period
  ///
  /// In en, this message translates to:
  /// **'No activities in this period'**
  String get noActivitiesInPeriod;

  /// Message when no activities match muscle group filter
  ///
  /// In en, this message translates to:
  /// **'No activities for selected muscle groups'**
  String get noActivitiesForSelectedMuscleGroups;

  /// Error message when no completed exercises
  ///
  /// In en, this message translates to:
  /// **'No completed exercises found in your workouts'**
  String get noCompletedExercises;

  /// Error loading activities
  ///
  /// In en, this message translates to:
  /// **'Unable to load exercise activities'**
  String get unableToLoadActivities;

  /// Title with count of all activities
  ///
  /// In en, this message translates to:
  /// **'All Activities ({count})'**
  String allActivitiesCount(int count);

  /// Title for muscle group statistics section
  ///
  /// In en, this message translates to:
  /// **'Muscle Group Statistics'**
  String get muscleGroupStatistics;

  /// Title for sets details section
  ///
  /// In en, this message translates to:
  /// **'Sets Details'**
  String get setsDetails;

  /// Volume label with value
  ///
  /// In en, this message translates to:
  /// **'Volume: {value} kg'**
  String volumeWithValue(String value);

  /// RPE label with value
  ///
  /// In en, this message translates to:
  /// **'RPE: {value}'**
  String rpeWithValue(String value);

  /// Maximum weight
  ///
  /// In en, this message translates to:
  /// **'{value} kg max'**
  String kgMax(String value);

  /// Total reps count
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String totalRepsCount(int count);

  /// No description provided for @aiWeightJumpAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Weight increased by {percentIncrease}% ({absoluteIncrease}kg) in a single session. Research indicates that sudden load increases >15-20% significantly increase injury risk, particularly for connective tissue which adapts slower than muscle. Form breakdown often occurs when neural drive cannot support the new load.'**
  String aiWeightJumpAnalysis(Object absoluteIncrease, Object percentIncrease);

  /// No description provided for @dataPreviousWeight.
  ///
  /// In en, this message translates to:
  /// **'Previous weight: {weight}kg'**
  String dataPreviousWeight(Object weight);

  /// No description provided for @dataCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight: {weight}kg'**
  String dataCurrentWeight(Object weight);

  /// No description provided for @dataAbsoluteJump.
  ///
  /// In en, this message translates to:
  /// **'Absolute jump: +{weight}kg'**
  String dataAbsoluteJump(Object weight);

  /// No description provided for @dataPercentageIncrease.
  ///
  /// In en, this message translates to:
  /// **'Percentage increase: {percent}%'**
  String dataPercentageIncrease(Object percent);

  /// No description provided for @dataSafeThreshold.
  ///
  /// In en, this message translates to:
  /// **'Safe threshold: <{threshold}%'**
  String dataSafeThreshold(Object threshold);

  /// No description provided for @dataRiskFactors.
  ///
  /// In en, this message translates to:
  /// **'Risk: Form breakdown, tendon strain'**
  String get dataRiskFactors;

  /// No description provided for @strategyUseSmallerIncrementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Smaller Increments'**
  String get strategyUseSmallerIncrementsTitle;

  /// No description provided for @strategyUseSmallerIncrementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Gradual load progression allows connective tissue adaptation and maintains proper form'**
  String get strategyUseSmallerIncrementsDesc;

  /// No description provided for @strategyUseSmallerIncrementsHow.
  ///
  /// In en, this message translates to:
  /// **'Increase weight by 2.5-5% per session (2.5kg for lower body, 1.25kg for upper body). Use fractional plates or microloading'**
  String get strategyUseSmallerIncrementsHow;

  /// No description provided for @strategyUseSmallerIncrementsOutcome.
  ///
  /// In en, this message translates to:
  /// **'Sustained progress with reduced injury risk. Tendons adapt within 6-8 weeks'**
  String get strategyUseSmallerIncrementsOutcome;

  /// No description provided for @strategyFocusRepQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus on Rep Quality'**
  String get strategyFocusRepQualityTitle;

  /// No description provided for @strategyFocusRepQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Technical proficiency should be maintained across all rep ranges. Speed and control are indicators of appropriate loading'**
  String get strategyFocusRepQualityDesc;

  /// No description provided for @strategyFocusRepQualityHow.
  ///
  /// In en, this message translates to:
  /// **'Film your sets. If bar speed decreases >20% or form breaks down, reduce weight by 10% and rebuild'**
  String get strategyFocusRepQualityHow;

  /// No description provided for @strategyFocusRepQualityOutcome.
  ///
  /// In en, this message translates to:
  /// **'Improved motor patterns and long-term strength gains'**
  String get strategyFocusRepQualityOutcome;

  /// No description provided for @strategyDeloadWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Deload Week'**
  String get strategyDeloadWeekTitle;

  /// No description provided for @strategyDeloadWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'After rapid load increases, connective tissue needs consolidation time'**
  String get strategyDeloadWeekDesc;

  /// No description provided for @strategyDeloadWeekHow.
  ///
  /// In en, this message translates to:
  /// **'Reduce weight by 20-30% for one week while maintaining volume. Focus on technique and recovery'**
  String get strategyDeloadWeekHow;

  /// No description provided for @strategyDeloadWeekOutcome.
  ///
  /// In en, this message translates to:
  /// **'Reduced injury risk and better long-term adaptation'**
  String get strategyDeloadWeekOutcome;

  /// No description provided for @insightsAICoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach Insights'**
  String get insightsAICoach;

  /// No description provided for @aiMuscleImbalanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup} is currently at {sets} sets/week, which is below the Minimum Effective Volume (MEV) of 10 sets. Scientific research shows that muscles require at least 10-20 sets per week for optimal hypertrophy.'**
  String aiMuscleImbalanceAnalysis(Object muscleGroup, Object sets);

  /// No description provided for @dataCurrentVolume.
  ///
  /// In en, this message translates to:
  /// **'Current volume: {sets} sets/week'**
  String dataCurrentVolume(Object sets);

  /// No description provided for @dataMEV.
  ///
  /// In en, this message translates to:
  /// **'MEV (Minimum): 10 sets/week'**
  String get dataMEV;

  /// No description provided for @dataMAV.
  ///
  /// In en, this message translates to:
  /// **'MAV (Optimal): 15-20 sets/week'**
  String get dataMAV;

  /// No description provided for @dataDeficit.
  ///
  /// In en, this message translates to:
  /// **'Deficit: {deficit} sets below MEV'**
  String dataDeficit(Object deficit);

  /// No description provided for @dataExercisesList.
  ///
  /// In en, this message translates to:
  /// **'Exercises: {exercises}'**
  String dataExercisesList(Object exercises);

  /// No description provided for @aiHighVolumeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'{muscleGroup} is at {sets} sets/week, exceeding the Maximum Recoverable Volume (MRV) of 25 sets. This level of volume can lead to systemic fatigue, impaired recovery, and diminishing returns. Research shows that exceeding MRV increases injury risk without additional muscle growth benefits.'**
  String aiHighVolumeAnalysis(Object muscleGroup, Object sets);

  /// No description provided for @dataMRV.
  ///
  /// In en, this message translates to:
  /// **'MRV (Maximum): 25 sets/week'**
  String get dataMRV;

  /// No description provided for @dataExcess.
  ///
  /// In en, this message translates to:
  /// **'Excess: {excess} sets above MRV'**
  String dataExcess(Object excess);

  /// No description provided for @dataRiskOvertraining.
  ///
  /// In en, this message translates to:
  /// **'Risk: Overtraining syndrome'**
  String get dataRiskOvertraining;

  /// No description provided for @strategyReduceVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce Volume Gradually'**
  String get strategyReduceVolumeTitle;

  /// No description provided for @strategyReduceVolumeDesc.
  ///
  /// In en, this message translates to:
  /// **'Sudden volume drops can cause detraining. Gradual reduction maintains adaptations while allowing recovery'**
  String get strategyReduceVolumeDesc;

  /// No description provided for @strategyReduceVolumeHow.
  ///
  /// In en, this message translates to:
  /// **'Reduce by 20-30% per week until reaching 15-20 sets. Example: 28 sets → 22 sets → 18 sets over 2 weeks'**
  String get strategyReduceVolumeHow;

  /// No description provided for @strategyReduceVolumeOutcome.
  ///
  /// In en, this message translates to:
  /// **'Restored recovery capacity and improved performance within 2-3 weeks'**
  String get strategyReduceVolumeOutcome;

  /// No description provided for @strategyDeloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Implement Deload Week'**
  String get strategyDeloadTitle;

  /// No description provided for @strategyDeloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Strategic recovery week allows supercompensation and fatigue dissipation'**
  String get strategyDeloadDesc;

  /// No description provided for @strategyDeloadHow.
  ///
  /// In en, this message translates to:
  /// **'Reduce volume by 40-50% for one week. Maintain intensity but cut sets in half'**
  String get strategyDeloadHow;

  /// No description provided for @strategyDeloadOutcome.
  ///
  /// In en, this message translates to:
  /// **'Fresh nervous system and enhanced subsequent performance'**
  String get strategyDeloadOutcome;

  /// No description provided for @strategyReallocateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reallocate Volume'**
  String get strategyReallocateTitle;

  /// No description provided for @strategyReallocateDesc.
  ///
  /// In en, this message translates to:
  /// **'Distribute excess volume to underdeveloped muscle groups for balanced development'**
  String get strategyReallocateDesc;

  /// No description provided for @strategyReallocateHow.
  ///
  /// In en, this message translates to:
  /// **'Identify muscles below MEV. Transfer 1-2 exercises from overtrained muscle to undertrained areas'**
  String get strategyReallocateHow;

  /// No description provided for @strategyReallocateOutcome.
  ///
  /// In en, this message translates to:
  /// **'Balanced development and optimized recovery resources'**
  String get strategyReallocateOutcome;

  /// No description provided for @aiPlateauAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Weight variation across last 3 sessions is {variation}% (threshold: 5%). This indicates insufficient progressive overload stimulus for adaptation.'**
  String aiPlateauAnalysis(Object variation);

  /// No description provided for @dataWeightVariation.
  ///
  /// In en, this message translates to:
  /// **'Weight variation: {variation}%'**
  String dataWeightVariation(Object variation);

  /// No description provided for @dataThreshold.
  ///
  /// In en, this message translates to:
  /// **'Progression threshold: >5%'**
  String get dataThreshold;

  /// No description provided for @dataLastWeights.
  ///
  /// In en, this message translates to:
  /// **'Recent weights: {weights}'**
  String dataLastWeights(Object weights);

  /// No description provided for @dataRecommendedIncrease.
  ///
  /// In en, this message translates to:
  /// **'Recommended increase: {increase}kg'**
  String dataRecommendedIncrease(Object increase);

  /// No description provided for @aiInsufficientRecoveryAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Only {days} days since last workout. Research shows that muscles need 24-48 hours for optimal protein synthesis and glycogen replenishment. Training too frequently can impair recovery and increase injury risk.'**
  String aiInsufficientRecoveryAnalysis(Object days);

  /// No description provided for @dataLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Last workout: {days} days ago'**
  String dataLastWorkout(Object days);

  /// No description provided for @dataMinimumRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recommended minimum: 1.0 days (24 hours)'**
  String get dataMinimumRecovery;

  /// No description provided for @dataOptimalRange.
  ///
  /// In en, this message translates to:
  /// **'Optimal range: 1-3 days between sessions'**
  String get dataOptimalRange;

  /// No description provided for @dataCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: Insufficient recovery'**
  String get dataCurrentStatus;

  /// No description provided for @dataMuscleProteinSynthesis.
  ///
  /// In en, this message translates to:
  /// **'MPS window: Still active'**
  String get dataMuscleProteinSynthesis;

  /// No description provided for @aiLongRecoveryAnalysis.
  ///
  /// In en, this message translates to:
  /// **'{days} days without training. While recovery is important, gaps longer than 4 days can lead to detraining effects. Muscle protein synthesis returns to baseline after 48-72 hours, and strength adaptations begin to decline.'**
  String aiLongRecoveryAnalysis(Object days);

  /// No description provided for @dataMaxRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended maximum: 4.0 days'**
  String get dataMaxRecommended;

  /// No description provided for @dataProteinSynthesisPeak.
  ///
  /// In en, this message translates to:
  /// **'Protein synthesis peak: 24-48h post-workout'**
  String get dataProteinSynthesisPeak;

  /// No description provided for @dataDetrainingRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk: Detraining effects'**
  String get dataDetrainingRisk;

  /// No description provided for @strategyActiveRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Recovery Sessions'**
  String get strategyActiveRecoveryTitle;

  /// No description provided for @strategyActiveRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Light movement maintains adaptations without adding fatigue'**
  String get strategyActiveRecoveryDesc;

  /// No description provided for @strategyActiveRecoveryHow.
  ///
  /// In en, this message translates to:
  /// **'Perform 20-30 min of light cardio or bodyweight exercises at 40-60% intensity on rest days'**
  String get strategyActiveRecoveryHow;

  /// No description provided for @strategyActiveRecoveryOutcome.
  ///
  /// In en, this message translates to:
  /// **'Maintained adaptations and improved recovery quality'**
  String get strategyActiveRecoveryOutcome;

  /// No description provided for @strategyScheduleWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Next Workout'**
  String get strategyScheduleWorkoutsTitle;

  /// No description provided for @strategyScheduleWorkoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key for long-term progress. Plan ahead to avoid extended breaks'**
  String get strategyScheduleWorkoutsDesc;

  /// No description provided for @strategyScheduleWorkoutsHow.
  ///
  /// In en, this message translates to:
  /// **'Set specific workout days and times. Use calendar reminders. Aim for max 3-day gaps'**
  String get strategyScheduleWorkoutsHow;

  /// No description provided for @strategyScheduleWorkoutsOutcome.
  ///
  /// In en, this message translates to:
  /// **'Consistent stimulus for continuous adaptation'**
  String get strategyScheduleWorkoutsOutcome;

  /// No description provided for @aiLowFrequencyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Current training frequency of {frequency} sessions/week is below the minimum threshold for meaningful adaptations. Research demonstrates that training a muscle group less than once per week results in minimal hypertrophy and strength gains. Muscle protein synthesis peaks 24-48h post-workout and returns to baseline by 72h.'**
  String aiLowFrequencyAnalysis(Object frequency);

  /// No description provided for @dataCurrentFrequency.
  ///
  /// In en, this message translates to:
  /// **'Current frequency: {frequency} workouts/week'**
  String dataCurrentFrequency(Object frequency);

  /// No description provided for @dataMinimumEffective.
  ///
  /// In en, this message translates to:
  /// **'Minimum effective: 1-2 workouts/week'**
  String get dataMinimumEffective;

  /// No description provided for @dataOptimalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Optimal range: 3-5 workouts/week'**
  String get dataOptimalFrequency;

  /// No description provided for @dataAdaptationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: Suboptimal adaptation stimulus'**
  String get dataAdaptationStatus;

  /// No description provided for @dataMPSCycle.
  ///
  /// In en, this message translates to:
  /// **'MPS cycle: {hours}h window underutilized'**
  String dataMPSCycle(Object hours);

  /// No description provided for @strategyIncreaseFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase Training Frequency'**
  String get strategyIncreaseFrequencyTitle;

  /// No description provided for @strategyIncreaseFrequencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Higher frequency provides more frequent stimulus for adaptation'**
  String get strategyIncreaseFrequencyDesc;

  /// No description provided for @strategyIncreaseFrequencyHow.
  ///
  /// In en, this message translates to:
  /// **'Add 1 session per week initially. Build up to 3-4 sessions. Focus on different muscle groups each session'**
  String get strategyIncreaseFrequencyHow;

  /// No description provided for @strategyIncreaseFrequencyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Enhanced muscle protein synthesis frequency and faster gains'**
  String get strategyIncreaseFrequencyOutcome;

  /// No description provided for @strategyFullBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Adopt Full-Body Workouts'**
  String get strategyFullBodyTitle;

  /// No description provided for @strategyFullBodyDesc.
  ///
  /// In en, this message translates to:
  /// **'Full-body sessions allow hitting each muscle 2-3x/week even with lower frequency'**
  String get strategyFullBodyDesc;

  /// No description provided for @strategyFullBodyHow.
  ///
  /// In en, this message translates to:
  /// **'Design 2-3 workouts hitting all major muscles. Include 1-2 exercises per muscle group'**
  String get strategyFullBodyHow;

  /// No description provided for @strategyFullBodyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Optimal stimulus frequency even with limited workout days'**
  String get strategyFullBodyOutcome;

  /// No description provided for @aiHighFrequencyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Training {frequency} times per week may exceed optimal frequency for recovery. While high frequency can work for advanced lifters with proper programming, it increases risk of overtraining, CNS fatigue, and diminishing returns. Studies show no additional hypertrophy benefits beyond 5-6 sessions/week when volume is equated.'**
  String aiHighFrequencyAnalysis(Object frequency);

  /// No description provided for @dataMaxBeneficial.
  ///
  /// In en, this message translates to:
  /// **'Maximum beneficial: ~6 workouts/week'**
  String get dataMaxBeneficial;

  /// No description provided for @dataRecoveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: Potential overreaching'**
  String get dataRecoveryStatus;

  /// No description provided for @dataCNSFatigue.
  ///
  /// In en, this message translates to:
  /// **'CNS fatigue risk: Elevated'**
  String get dataCNSFatigue;

  /// No description provided for @strategyReduceFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce Training Frequency'**
  String get strategyReduceFrequencyTitle;

  /// No description provided for @strategyReduceFrequencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Lower frequency with maintained volume can improve recovery and results'**
  String get strategyReduceFrequencyDesc;

  /// No description provided for @strategyReduceFrequencyHow.
  ///
  /// In en, this message translates to:
  /// **'Consolidate workouts into 4-5 quality sessions. Increase volume per session slightly'**
  String get strategyReduceFrequencyHow;

  /// No description provided for @strategyReduceFrequencyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Better recovery, reduced injury risk, maintained or improved gains'**
  String get strategyReduceFrequencyOutcome;

  /// No description provided for @strategyImplementRestDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Implement Strategic Rest Days'**
  String get strategyImplementRestDaysTitle;

  /// No description provided for @strategyImplementRestDaysDesc.
  ///
  /// In en, this message translates to:
  /// **'Scheduled rest allows adaptation and prevents accumulated fatigue'**
  String get strategyImplementRestDaysDesc;

  /// No description provided for @strategyImplementRestDaysHow.
  ///
  /// In en, this message translates to:
  /// **'Take at least 1-2 complete rest days per week. Place them after hardest training days'**
  String get strategyImplementRestDaysHow;

  /// No description provided for @strategyImplementRestDaysOutcome.
  ///
  /// In en, this message translates to:
  /// **'Optimized recovery and sustained performance'**
  String get strategyImplementRestDaysOutcome;

  /// No description provided for @dataSession1.
  ///
  /// In en, this message translates to:
  /// **'Session 1: {weight}kg'**
  String dataSession1(Object weight);

  /// No description provided for @dataSession2.
  ///
  /// In en, this message translates to:
  /// **'Session 2: {weight}kg'**
  String dataSession2(Object weight);

  /// No description provided for @dataSession3.
  ///
  /// In en, this message translates to:
  /// **'Session 3: {weight}kg'**
  String dataSession3(Object weight);

  /// No description provided for @dataAverageWeight.
  ///
  /// In en, this message translates to:
  /// **'Average: {weight}kg'**
  String dataAverageWeight(Object weight);

  /// No description provided for @dataWeightVariation2.
  ///
  /// In en, this message translates to:
  /// **'Variation: {weight}kg ({percent}%)'**
  String dataWeightVariation2(Object percent, Object weight);

  /// No description provided for @strategyPlateauincreasevolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase Training Volume'**
  String get strategyPlateauincreasevolumeTitle;

  /// No description provided for @strategyPlateauincreasevolumeDesc.
  ///
  /// In en, this message translates to:
  /// **'Progressive volume increase is one of the primary drivers of hypertrophy adaptation'**
  String get strategyPlateauincreasevolumeDesc;

  /// No description provided for @strategyPlateauincreasevolumeImpl.
  ///
  /// In en, this message translates to:
  /// **'Add 1-2 sets per week until you reach 15-20 sets per muscle group. Example: if doing 3 sets, increase to 4-5 sets'**
  String get strategyPlateauincreasevolumeImpl;

  /// No description provided for @strategyPlateauincreasevolumeOutcome.
  ///
  /// In en, this message translates to:
  /// **'New growth stimulus within 2-4 weeks. Volume should increase gradually to avoid overtraining'**
  String get strategyPlateauincreasevolumeOutcome;

  /// No description provided for @strategyPlateauvaryrepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vary Rep Ranges'**
  String get strategyPlateauvaryrepsTitle;

  /// No description provided for @strategyPlateauvaryrepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Different rep ranges recruit different muscle fiber types and create novel mechanical tension'**
  String get strategyPlateauvaryrepsDesc;

  /// No description provided for @strategyPlateauvaryrepsImpl.
  ///
  /// In en, this message translates to:
  /// **'Alternate between strength (4-6 reps), hypertrophy (8-12 reps), and endurance (15-20 reps) ranges across weeks'**
  String get strategyPlateauvaryrepsImpl;

  /// No description provided for @strategyPlateauvaryrepsOutcome.
  ///
  /// In en, this message translates to:
  /// **'Enhanced overall muscle development and strength gains across all ranges'**
  String get strategyPlateauvaryrepsOutcome;

  /// No description provided for @strategyPlateauadvancedtechniquesTitle.
  ///
  /// In en, this message translates to:
  /// **'Implement Advanced Techniques'**
  String get strategyPlateauadvancedtechniquesTitle;

  /// No description provided for @strategyPlateauadvancedtechniquesDesc.
  ///
  /// In en, this message translates to:
  /// **'Intensity techniques increase metabolic stress and mechanical tension beyond traditional sets'**
  String get strategyPlateauadvancedtechniquesDesc;

  /// No description provided for @strategyPlateauadvancedtechniquesImpl.
  ///
  /// In en, this message translates to:
  /// **'Use drop sets (reduce weight 20-30% after failure), rest-pause (10-15 sec rest between mini-sets), or forced reps on final set'**
  String get strategyPlateauadvancedtechniquesImpl;

  /// No description provided for @strategyPlateauadvancedtechniquesOutcome.
  ///
  /// In en, this message translates to:
  /// **'Immediate increase in muscle fiber recruitment and metabolic stress'**
  String get strategyPlateauadvancedtechniquesOutcome;

  /// No description provided for @strategyPlateauchangeexercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Exercise Variation'**
  String get strategyPlateauchangeexercisesTitle;

  /// No description provided for @strategyPlateauchangeexercisesDesc.
  ///
  /// In en, this message translates to:
  /// **'Novel exercises create different force vectors and recruitment patterns'**
  String get strategyPlateauchangeexercisesDesc;

  /// No description provided for @strategyPlateauchangeexercisesImpl.
  ///
  /// In en, this message translates to:
  /// **'Substitute similar exercises with different angles. Example: flat bench → incline bench, squat → front squat'**
  String get strategyPlateauchangeexercisesImpl;

  /// No description provided for @strategyPlateauchangeexercisesOutcome.
  ///
  /// In en, this message translates to:
  /// **'Renewed strength gains and muscle activation in 1-2 weeks'**
  String get strategyPlateauchangeexercisesOutcome;

  /// No description provided for @strategyPlateaudeloadweekTitle.
  ///
  /// In en, this message translates to:
  /// **'Deload Week'**
  String get strategyPlateaudeloadweekTitle;

  /// No description provided for @strategyPlateaudeloadweekDesc.
  ///
  /// In en, this message translates to:
  /// **'Strategic recovery allows supercompensation and nervous system recovery'**
  String get strategyPlateaudeloadweekDesc;

  /// No description provided for @strategyPlateaudeloadweekImpl.
  ///
  /// In en, this message translates to:
  /// **'Reduce volume by 40-50% for 1 week (half the sets, same weight). Maintain frequency but reduce total work'**
  String get strategyPlateaudeloadweekImpl;

  /// No description provided for @strategyPlateaudeloadweekOutcome.
  ///
  /// In en, this message translates to:
  /// **'Return stronger after deload with reduced fatigue and improved neuromuscular efficiency'**
  String get strategyPlateaudeloadweekOutcome;

  /// No description provided for @strategyBalanceincreasefrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase Training Frequency'**
  String get strategyBalanceincreasefrequencyTitle;

  /// No description provided for @strategyBalanceincreasefrequencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Higher frequency provides more opportunities for volume accumulation and skill practice'**
  String get strategyBalanceincreasefrequencyDesc;

  /// No description provided for @strategyBalanceincreasefrequencyImpl.
  ///
  /// In en, this message translates to:
  /// **'Split current volume across 2-3 sessions per week instead of 1. Example: 10 sets → 5 sets × 2 days'**
  String get strategyBalanceincreasefrequencyImpl;

  /// No description provided for @strategyBalanceincreasefrequencyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Better recovery between sessions and higher quality sets'**
  String get strategyBalanceincreasefrequencyOutcome;

  /// No description provided for @strategyBalanceprioritizeweakTitle.
  ///
  /// In en, this message translates to:
  /// **'Prioritize Weak Muscle Groups'**
  String get strategyBalanceprioritizeweakTitle;

  /// No description provided for @strategyBalanceprioritizeweakDesc.
  ///
  /// In en, this message translates to:
  /// **'Training lagging muscles first when energy is highest maximizes adaptation'**
  String get strategyBalanceprioritizeweakDesc;

  /// No description provided for @strategyBalanceprioritizeweakImpl.
  ///
  /// In en, this message translates to:
  /// **'Perform weak muscle exercises at the beginning of your workout when neurologically fresh'**
  String get strategyBalanceprioritizeweakImpl;

  /// No description provided for @strategyBalanceprioritizeweakOutcome.
  ///
  /// In en, this message translates to:
  /// **'Improved performance and progressive overload on weak points'**
  String get strategyBalanceprioritizeweakOutcome;

  /// No description provided for @strategyBalanceaddisolationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Isolation Work'**
  String get strategyBalanceaddisolationTitle;

  /// No description provided for @strategyBalanceaddisolationDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct isolation allows targeted volume without systemic fatigue'**
  String get strategyBalanceaddisolationDesc;

  /// No description provided for @strategyBalanceaddisolationImpl.
  ///
  /// In en, this message translates to:
  /// **'Add 2-3 isolation exercises (12-15 reps) after compound movements for the weak muscle'**
  String get strategyBalanceaddisolationImpl;

  /// No description provided for @strategyBalanceaddisolationOutcome.
  ///
  /// In en, this message translates to:
  /// **'Increased local volume and muscle-mind connection'**
  String get strategyBalanceaddisolationOutcome;

  /// No description provided for @strategyRecoveryoptimizesleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimize Sleep Duration'**
  String get strategyRecoveryoptimizesleepTitle;

  /// No description provided for @strategyRecoveryoptimizesleepDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep is the primary recovery mechanism for neuromuscular adaptation'**
  String get strategyRecoveryoptimizesleepDesc;

  /// No description provided for @strategyRecoveryoptimizesleepImpl.
  ///
  /// In en, this message translates to:
  /// **'Aim for 7-9 hours per night. Prioritize consistent sleep schedule (same bedtime/wake time)'**
  String get strategyRecoveryoptimizesleepImpl;

  /// No description provided for @strategyRecoveryoptimizesleepOutcome.
  ///
  /// In en, this message translates to:
  /// **'Enhanced muscle protein synthesis and reduced cortisol levels'**
  String get strategyRecoveryoptimizesleepOutcome;

  /// No description provided for @strategyRecoveryperiodizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodize Training Stress'**
  String get strategyRecoveryperiodizeTitle;

  /// No description provided for @strategyRecoveryperiodizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Alternating high and low stress weeks prevents chronic fatigue'**
  String get strategyRecoveryperiodizeDesc;

  /// No description provided for @strategyRecoveryperiodizeImpl.
  ///
  /// In en, this message translates to:
  /// **'3 weeks progressive overload → 1 deload week (50% volume reduction)'**
  String get strategyRecoveryperiodizeImpl;

  /// No description provided for @strategyRecoveryperiodizeOutcome.
  ///
  /// In en, this message translates to:
  /// **'Sustained progress without burnout or injury risk'**
  String get strategyRecoveryperiodizeOutcome;

  /// No description provided for @strategyRecoveryactiverecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Recovery Sessions'**
  String get strategyRecoveryactiverecoveryTitle;

  /// No description provided for @strategyRecoveryactiverecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Light activity enhances blood flow and waste removal without adding fatigue'**
  String get strategyRecoveryactiverecoveryDesc;

  /// No description provided for @strategyRecoveryactiverecoveryImpl.
  ///
  /// In en, this message translates to:
  /// **'Add 20-30 min low-intensity cardio or mobility work on rest days'**
  String get strategyRecoveryactiverecoveryImpl;

  /// No description provided for @strategyRecoveryactiverecoveryOutcome.
  ///
  /// In en, this message translates to:
  /// **'Faster recovery and reduced muscle soreness'**
  String get strategyRecoveryactiverecoveryOutcome;

  /// No description provided for @strategyLongrecoveryscheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Establish Consistent Schedule'**
  String get strategyLongrecoveryscheduleTitle;

  /// No description provided for @strategyLongrecoveryscheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'Training frequency is more important than individual session quality for long-term progress'**
  String get strategyLongrecoveryscheduleDesc;

  /// No description provided for @strategyLongrecoveryscheduleImpl.
  ///
  /// In en, this message translates to:
  /// **'Schedule 3-5 fixed training days per week. Use calendar reminders. Prepare gym bag the night before'**
  String get strategyLongrecoveryscheduleImpl;

  /// No description provided for @strategyLongrecoveryscheduleOutcome.
  ///
  /// In en, this message translates to:
  /// **'Improved habit formation and training adherence within 3-4 weeks'**
  String get strategyLongrecoveryscheduleOutcome;

  /// No description provided for @strategyLongrecoverymindoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Minimum Effective Dose'**
  String get strategyLongrecoverymindoseTitle;

  /// No description provided for @strategyLongrecoverymindoseDesc.
  ///
  /// In en, this message translates to:
  /// **'Short, frequent sessions maintain adaptations better than long, infrequent workouts'**
  String get strategyLongrecoverymindoseDesc;

  /// No description provided for @strategyLongrecoverymindoseImpl.
  ///
  /// In en, this message translates to:
  /// **'If time-constrained, do 20-30 min sessions instead of skipping. Focus on compound movements'**
  String get strategyLongrecoverymindoseImpl;

  /// No description provided for @strategyLongrecoverymindoseOutcome.
  ///
  /// In en, this message translates to:
  /// **'Maintained strength and muscle mass with 60% less volume'**
  String get strategyLongrecoverymindoseOutcome;

  /// No description provided for @strategyLowfrequencyminviableTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with Minimum Viable Frequency'**
  String get strategyLowfrequencyminviableTitle;

  /// No description provided for @strategyLowfrequencyminviableDesc.
  ///
  /// In en, this message translates to:
  /// **'Even 2 weekly sessions produce 80% of the benefits of higher frequencies for beginners'**
  String get strategyLowfrequencyminviableDesc;

  /// No description provided for @strategyLowfrequencyminviableImpl.
  ///
  /// In en, this message translates to:
  /// **'Schedule 2 full-body sessions per week (e.g., Monday/Thursday). 45-60 min each with 4-5 compound exercises'**
  String get strategyLowfrequencyminviableImpl;

  /// No description provided for @strategyLowfrequencyminviableOutcome.
  ///
  /// In en, this message translates to:
  /// **'Measurable strength gains within 4-6 weeks. Habit formation in 3-4 weeks'**
  String get strategyLowfrequencyminviableOutcome;

  /// No description provided for @strategyLowfrequencytimeefficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Time-Efficient Protocols'**
  String get strategyLowfrequencytimeefficientTitle;

  /// No description provided for @strategyLowfrequencytimeefficientDesc.
  ///
  /// In en, this message translates to:
  /// **'Strategic exercise selection maximizes results per minute invested'**
  String get strategyLowfrequencytimeefficientDesc;

  /// No description provided for @strategyLowfrequencytimeefficientImpl.
  ///
  /// In en, this message translates to:
  /// **'Focus on compound movements: Squat, Bench, Deadlift, Row, Press. 3 sets of 8-12 reps each. Total: 30-40 min'**
  String get strategyLowfrequencytimeefficientImpl;

  /// No description provided for @strategyLowfrequencytimeefficientOutcome.
  ///
  /// In en, this message translates to:
  /// **'Full-body stimulus with minimal time investment'**
  String get strategyLowfrequencytimeefficientOutcome;

  /// No description provided for @strategyHighfrequencyconsolidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Consolidate Training Sessions'**
  String get strategyHighfrequencyconsolidateTitle;

  /// No description provided for @strategyHighfrequencyconsolidateDesc.
  ///
  /// In en, this message translates to:
  /// **'Fewer, higher-quality sessions often outperform high-frequency, lower-quality work'**
  String get strategyHighfrequencyconsolidateDesc;

  /// No description provided for @strategyHighfrequencyconsolidateImpl.
  ///
  /// In en, this message translates to:
  /// **'Combine similar muscle groups. Example: Instead of 7 separate sessions, do 4-5 focused sessions with more volume per workout'**
  String get strategyHighfrequencyconsolidateImpl;

  /// No description provided for @strategyHighfrequencyconsolidateOutcome.
  ///
  /// In en, this message translates to:
  /// **'Better recovery, maintained volume, reduced fatigue accumulation'**
  String get strategyHighfrequencyconsolidateOutcome;

  /// No description provided for @strategyHighfrequencyrestdaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Implement Strategic Rest Days'**
  String get strategyHighfrequencyrestdaysTitle;

  /// No description provided for @strategyHighfrequencyrestdaysDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete rest or active recovery days are essential for supercompensation'**
  String get strategyHighfrequencyrestdaysDesc;

  /// No description provided for @strategyHighfrequencyrestdaysImpl.
  ///
  /// In en, this message translates to:
  /// **'Take 1-2 full rest days per week. On rest days, do light walking or mobility work only (no resistance training)'**
  String get strategyHighfrequencyrestdaysImpl;

  /// No description provided for @strategyHighfrequencyrestdaysOutcome.
  ///
  /// In en, this message translates to:
  /// **'Improved strength rebound and reduced injury risk within 2-3 weeks'**
  String get strategyHighfrequencyrestdaysOutcome;

  /// No description provided for @strategyHighvolumereducegraduallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce Volume Gradually'**
  String get strategyHighvolumereducegraduallyTitle;

  /// No description provided for @strategyHighvolumereducegraduallyDesc.
  ///
  /// In en, this message translates to:
  /// **'Sudden volume drops can cause detraining. Gradual reduction maintains adaptations while allowing recovery'**
  String get strategyHighvolumereducegraduallyDesc;

  /// No description provided for @strategyHighvolumereducegraduallyImpl.
  ///
  /// In en, this message translates to:
  /// **'Reduce by 20-30% per week until reaching 15-20 sets. Example: 28 sets → 22 sets → 18 sets over 2 weeks'**
  String get strategyHighvolumereducegraduallyImpl;

  /// No description provided for @strategyHighvolumereducegraduallyOutcome.
  ///
  /// In en, this message translates to:
  /// **'Restored recovery capacity and improved performance within 2-3 weeks'**
  String get strategyHighvolumereducegraduallyOutcome;

  /// No description provided for @strategyHighvolumedeloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Implement Deload Week'**
  String get strategyHighvolumedeloadTitle;

  /// No description provided for @strategyHighvolumedeloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Strategic recovery week allows supercompensation and fatigue dissipation'**
  String get strategyHighvolumedeloadDesc;

  /// No description provided for @strategyHighvolumedeloadImpl.
  ///
  /// In en, this message translates to:
  /// **'Cut volume by 50% for one week. Maintain weight but do half the sets. Then resume at optimal volume (15-20 sets)'**
  String get strategyHighvolumedeloadImpl;

  /// No description provided for @strategyHighvolumedeloadOutcome.
  ///
  /// In en, this message translates to:
  /// **'Return stronger with reduced accumulated fatigue. Strength rebound in 7-10 days'**
  String get strategyHighvolumedeloadOutcome;

  /// No description provided for @strategyHighvolumeincreasefreqTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase Training Frequency'**
  String get strategyHighvolumeincreasefreqTitle;

  /// No description provided for @strategyHighvolumeincreasefreqDesc.
  ///
  /// In en, this message translates to:
  /// **'Same volume spread across more sessions reduces per-session fatigue'**
  String get strategyHighvolumeincreasefreqDesc;

  /// No description provided for @strategyHighvolumeincreasefreqImpl.
  ///
  /// In en, this message translates to:
  /// **'Split current volume across more days. Example: 28 sets/week → 7 sets × 4 days instead of 14 sets × 2 days'**
  String get strategyHighvolumeincreasefreqImpl;

  /// No description provided for @strategyHighvolumeincreasefreqOutcome.
  ///
  /// In en, this message translates to:
  /// **'Better recovery between sessions and higher quality sets'**
  String get strategyHighvolumeincreasefreqOutcome;

  /// Label for notification type filter
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterByType;

  /// Filter label for recommendation priority filter
  ///
  /// In en, this message translates to:
  /// **'Filter by Priority'**
  String get filterByPriority;

  /// Success type filter option
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Info type filter option
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// High priority filter option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Medium priority filter option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Low priority filter option
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Semantic label for critical severity indicator (accessibility)
  ///
  /// In en, this message translates to:
  /// **'Critical severity - immediate action required'**
  String get criticalSeverity;

  /// Semantic label for high severity indicator (accessibility)
  ///
  /// In en, this message translates to:
  /// **'High severity - action recommended'**
  String get highSeverity;

  /// Semantic label for medium severity indicator (accessibility)
  ///
  /// In en, this message translates to:
  /// **'Medium severity - consider action'**
  String get mediumSeverity;

  /// Semantic label for low severity indicator (accessibility)
  ///
  /// In en, this message translates to:
  /// **'Low severity - informational'**
  String get lowSeverity;

  /// Filter section title for recommendations
  ///
  /// In en, this message translates to:
  /// **'Filter Recommendations'**
  String get filterRecommendations;

  /// Empty state message when no recommendations match filters
  ///
  /// In en, this message translates to:
  /// **'No recommendations match your filters'**
  String get noRecommendationsFound;

  /// Tooltip explanation for total volume metric
  ///
  /// In en, this message translates to:
  /// **'Total Volume represents the sum of weight × reps across all exercises. It\'s a key indicator of overall training stress and progression.'**
  String get totalVolumeTooltip;

  /// Tooltip explanation for workout frequency metric
  ///
  /// In en, this message translates to:
  /// **'Workout Frequency is how often you train per week. Research shows 3-5 sessions per week is optimal for most goals.'**
  String get workoutFrequencyTooltip;

  /// Tooltip explanation for consistency metric
  ///
  /// In en, this message translates to:
  /// **'Consistency Score measures how regularly you stick to your training schedule. Higher scores (80%+) lead to better long-term results.'**
  String get consistencyTooltip;

  /// Tooltip explanation for current streak metric
  ///
  /// In en, this message translates to:
  /// **'Current Streak tracks consecutive days with at least one workout. Maintaining streaks builds sustainable training habits.'**
  String get currentStreakTooltip;

  /// Tooltip explanation for muscle balance metric
  ///
  /// In en, this message translates to:
  /// **'Muscle Balance shows the distribution of training volume across muscle groups. Aim for balanced development (15-20% per group).'**
  String get muscleBalanceTooltip;

  /// Tooltip explanation for volume trend metric
  ///
  /// In en, this message translates to:
  /// **'Volume Trend indicates whether your total training volume is increasing (+), stable (=), or decreasing (-) over time.'**
  String get volumeTrendTooltip;

  /// Title for weekly performance dashboard
  ///
  /// In en, this message translates to:
  /// **'Weekly Dashboard'**
  String get weeklyDashboard;

  /// Title for workout consistency heatmap
  ///
  /// In en, this message translates to:
  /// **'Consistency Heatmap'**
  String get consistencyHeatmap;

  /// Label for admin mode indicator
  ///
  /// In en, this message translates to:
  /// **'ADMIN MODE'**
  String get adminMode;

  /// Title for premium insights lock screen
  ///
  /// In en, this message translates to:
  /// **'Premium Insights'**
  String get premiumInsights;

  /// Description for premium insights
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced analytics and insights'**
  String get unlockAdvancedAnalytics;

  /// Premium feature: weekly dashboard
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance Dashboard'**
  String get weeklyPerformanceDashboard;

  /// Premium feature: muscle balance
  ///
  /// In en, this message translates to:
  /// **'Muscle Group Balance Analysis'**
  String get muscleGroupBalanceAnalysis;

  /// Premium feature: consistency tracking
  ///
  /// In en, this message translates to:
  /// **'Workout Consistency Tracking'**
  String get workoutConsistencyTracking;

  /// Premium feature: recommendations
  ///
  /// In en, this message translates to:
  /// **'Personalized Recommendations'**
  String get personalizedRecommendations;

  /// Title for premium unlock card
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// Dialog title for scientific explanation
  ///
  /// In en, this message translates to:
  /// **'Scientific Basis'**
  String get scientificBasis;

  /// Section title for exercise list
  ///
  /// In en, this message translates to:
  /// **'Exercise Breakdown'**
  String get exerciseBreakdown;

  /// Label for total volume
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Label for primary volume
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// Label for secondary volume
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// Hint to tap for more details
  ///
  /// In en, this message translates to:
  /// **'Tap for scientific explanation'**
  String get tapForScientificExplanation;

  /// Pectorals muscle group
  ///
  /// In en, this message translates to:
  /// **'PETT (Pectorals)'**
  String get pectorals;

  /// Deltoids muscle group
  ///
  /// In en, this message translates to:
  /// **'DELT (Deltoids)'**
  String get deltoids;

  /// Premium tab label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Premium analytics section title
  ///
  /// In en, this message translates to:
  /// **'Premium Analytics'**
  String get premiumAnalytics;

  /// Premium analytics subtitle
  ///
  /// In en, this message translates to:
  /// **'Science-based insights for serious athletes'**
  String get scienceBasedInsights;

  /// Rep continuum card title
  ///
  /// In en, this message translates to:
  /// **'Rep Continuum'**
  String get repContinuum;

  /// Rep continuum card subtitle
  ///
  /// In en, this message translates to:
  /// **'Training distribution across strength, hypertrophy & endurance zones'**
  String get repContinuumSubtitle;

  /// Total sets counter
  ///
  /// In en, this message translates to:
  /// **'{count} total sets analyzed'**
  String totalSetsAnalyzed(int count);

  /// Strength zone label
  ///
  /// In en, this message translates to:
  /// **'Strength (1-5 reps)'**
  String get strengthZone;

  /// Strength zone description
  ///
  /// In en, this message translates to:
  /// **'Max force, neural adaptations'**
  String get strengthZoneDesc;

  /// Hypertrophy zone label
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy (6-15 reps)'**
  String get hypertrophyZone;

  /// Hypertrophy zone description
  ///
  /// In en, this message translates to:
  /// **'Muscle growth, metabolic stress'**
  String get hypertrophyZoneDesc;

  /// Endurance zone label
  ///
  /// In en, this message translates to:
  /// **'Endurance (15+ reps)'**
  String get enduranceZone;

  /// Endurance zone description
  ///
  /// In en, this message translates to:
  /// **'Muscular endurance, conditioning'**
  String get enduranceZoneDesc;

  /// Balanced rep continuum recommendation
  ///
  /// In en, this message translates to:
  /// **'✅ Excellent! Your training is well-balanced for hypertrophy. Most sets (60%+) are in the optimal 6-15 rep range.'**
  String get repContinuumRecommendationBalanced;

  /// Strength-focused recommendation
  ///
  /// In en, this message translates to:
  /// **'🏋️ Strength-focused training detected. Consider adding more hypertrophy work (6-15 reps) for muscle growth.'**
  String get repContinuumRecommendationStrength;

  /// Endurance-focused recommendation
  ///
  /// In en, this message translates to:
  /// **'🏃 High endurance volume. Add lower rep work (6-15 reps) for strength and hypertrophy gains.'**
  String get repContinuumRecommendationEndurance;

  /// Mixed training recommendation
  ///
  /// In en, this message translates to:
  /// **'📊 Mixed training approach. Ensure each muscle group has adequate volume in target rep ranges.'**
  String get repContinuumRecommendationMixed;

  /// Scientific explanation title
  ///
  /// In en, this message translates to:
  /// **'The Rep Continuum'**
  String get repContinuumScientificTitle;

  /// Scientific explanation subtitle
  ///
  /// In en, this message translates to:
  /// **'Loading recommendations for muscle strength, hypertrophy, and endurance'**
  String get repContinuumScientificSubtitle;

  /// Paper summary
  ///
  /// In en, this message translates to:
  /// **'This comprehensive review analyzed 100+ studies to determine optimal loading strategies. Key finding: different rep ranges produce distinct adaptations - strength (1-5), hypertrophy (6-15), endurance (15+).'**
  String get repContinuumPaperSummary;

  /// Section title for key findings
  ///
  /// In en, this message translates to:
  /// **'Key Findings'**
  String get keyFindings;

  /// Rep continuum finding 1
  ///
  /// In en, this message translates to:
  /// **'Strength Zone (1-5 reps): Maximizes neural adaptations and absolute strength. Best for powerlifting and max force production.'**
  String get repContinuumFinding1;

  /// Rep continuum finding 2
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy Zone (6-15 reps): Optimal for muscle growth through mechanical tension and metabolic stress. Industry standard for bodybuilding.'**
  String get repContinuumFinding2;

  /// Rep continuum finding 3
  ///
  /// In en, this message translates to:
  /// **'Endurance Zone (15+ reps): Develops muscular endurance and work capacity. Important for metabolic conditioning.'**
  String get repContinuumFinding3;

  /// Section title for practical advice
  ///
  /// In en, this message translates to:
  /// **'Practical Application'**
  String get practicalApplication;

  /// Practical advice for rep continuum
  ///
  /// In en, this message translates to:
  /// **'For balanced muscle development, aim for 60-70% of your training volume in the hypertrophy zone (6-15 reps). Include 15-20% strength work and 10-15% endurance work for complete adaptation.'**
  String get repContinuumPracticalAdvice;

  /// Volume landmarks card title
  ///
  /// In en, this message translates to:
  /// **'Volume Landmarks'**
  String get volumeLandmarks;

  /// Volume landmarks subtitle
  ///
  /// In en, this message translates to:
  /// **'Weekly set volume per muscle group with optimal zones'**
  String get volumeLandmarksSubtitle;

  /// Maintenance Volume abbreviation
  ///
  /// In en, this message translates to:
  /// **'MV'**
  String get maintenanceVolume;

  /// Minimum Effective Volume abbreviation
  ///
  /// In en, this message translates to:
  /// **'MEV'**
  String get minEffectiveVolume;

  /// Maximum Adaptive Volume abbreviation
  ///
  /// In en, this message translates to:
  /// **'MAV'**
  String get maxAdaptiveVolume;

  /// Maximum Recoverable Volume abbreviation
  ///
  /// In en, this message translates to:
  /// **'MRV'**
  String get maxRecoverableVolume;

  /// Volume zone indicator
  ///
  /// In en, this message translates to:
  /// **'⚠️ Below maintenance - add volume'**
  String get volumeZoneBelowMaintenance;

  /// Volume zone indicator
  ///
  /// In en, this message translates to:
  /// **'Maintenance zone'**
  String get volumeZoneMaintenance;

  /// Volume zone indicator
  ///
  /// In en, this message translates to:
  /// **'↗️ Effective zone - growing'**
  String get volumeZoneEffective;

  /// Volume zone indicator
  ///
  /// In en, this message translates to:
  /// **'✅ Optimal zone - perfect!'**
  String get volumeZoneOptimal;

  /// Volume zone indicator
  ///
  /// In en, this message translates to:
  /// **'❌ Excessive - risk of overtraining'**
  String get volumeZoneExcessive;

  /// Scientific explanation title
  ///
  /// In en, this message translates to:
  /// **'Volume Landmarks Explained'**
  String get volumeLandmarksScientificTitle;

  /// Scientific explanation subtitle
  ///
  /// In en, this message translates to:
  /// **'Evidence-based volume recommendations for muscle hypertrophy'**
  String get volumeLandmarksScientificSubtitle;

  /// Paper summary
  ///
  /// In en, this message translates to:
  /// **'This umbrella review synthesized data from 50+ meta-analyses to establish volume landmarks. Research shows clear dose-response relationship between weekly sets and muscle growth up to MAV.'**
  String get volumeLandmarksPaperSummary;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Volume Zones Explained'**
  String get volumeZonesExplanation;

  /// MV explanation
  ///
  /// In en, this message translates to:
  /// **'Minimum sets per week to maintain muscle mass. Below this, you\'ll lose muscle over time.'**
  String get mvExplanation;

  /// MEV explanation
  ///
  /// In en, this message translates to:
  /// **'Minimum sets to start seeing growth. This is your baseline for progressive overload.'**
  String get mevExplanation;

  /// MAV explanation
  ///
  /// In en, this message translates to:
  /// **'Sweet spot for muscle growth. Maximum hypertrophy response with manageable fatigue.'**
  String get mavExplanation;

  /// MRV explanation
  ///
  /// In en, this message translates to:
  /// **'Maximum recoverable volume. Beyond this, fatigue accumulates faster than you can recover.'**
  String get mrvExplanation;

  /// Practical advice for volume landmarks
  ///
  /// In en, this message translates to:
  /// **'Start at MEV and progressively increase volume each week until you reach MAV. When you hit MRV or plateau, take a deload week at MV levels, then restart the progression.'**
  String get volumeLandmarksPracticalAdvice;

  /// Coming soon feature title
  ///
  /// In en, this message translates to:
  /// **'TUT & Velocity Analytics'**
  String get tutVelocityAnalytics;

  /// Coming soon feature description
  ///
  /// In en, this message translates to:
  /// **'Time under tension and bar velocity metrics for optimal muscle stimulus'**
  String get tutVelocityDesc;

  /// Coming soon feature title
  ///
  /// In en, this message translates to:
  /// **'Data Confidence Score'**
  String get dataConfidenceScore;

  /// Coming soon feature description
  ///
  /// In en, this message translates to:
  /// **'Quality assessment of your tracking accuracy and consistency'**
  String get dataConfidenceDesc;

  /// Coming soon feature title
  ///
  /// In en, this message translates to:
  /// **'Anabolic Signals'**
  String get anabolicSignals;

  /// Coming soon feature description
  ///
  /// In en, this message translates to:
  /// **'Real-time indicators of muscle growth stimulus and recovery status'**
  String get anabolicSignalsDesc;

  /// Premium lock CTA title
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Analytics'**
  String get unlockPremiumAnalytics;

  /// Premium lock CTA description
  ///
  /// In en, this message translates to:
  /// **'Get science-backed insights based on peer-reviewed research. Make data-driven decisions for optimal muscle growth and performance.'**
  String get premiumAnalyticsDescription;

  /// Premium feature description
  ///
  /// In en, this message translates to:
  /// **'Rep Continuum Analysis - optimize training zones'**
  String get repContinuumFeature;

  /// Premium feature description
  ///
  /// In en, this message translates to:
  /// **'Volume Landmarks - hit your growth sweet spot'**
  String get volumeLandmarksFeature;

  /// Premium feature description
  ///
  /// In en, this message translates to:
  /// **'TUT & Velocity tracking - maximize stimulus'**
  String get tutVelocityFeature;

  /// Premium feature description
  ///
  /// In en, this message translates to:
  /// **'Data Confidence scoring - trust your data'**
  String get dataConfidenceFeature;

  /// Premium coming soon message
  ///
  /// In en, this message translates to:
  /// **'Premium features coming soon! 🚀'**
  String get premiumComingSoon;

  /// Preview description
  ///
  /// In en, this message translates to:
  /// **'See how your training is distributed across strength, hypertrophy, and endurance zones'**
  String get repContinuumPreview;

  /// Preview description
  ///
  /// In en, this message translates to:
  /// **'Track your weekly volume against scientifically-validated landmarks (MV, MEV, MAV, MRV)'**
  String get volumeLandmarksPreview;

  /// Below maintenance explanation
  ///
  /// In en, this message translates to:
  /// **'You\'re doing only {current} sets/week. Minimum to maintain muscle is {mv} sets. You\'re at risk of muscle loss.'**
  String volumeBelowMaintenanceExplanation(int current, int mv);

  /// Below maintenance advice
  ///
  /// In en, this message translates to:
  /// **'Add at least {sets} sets this week to reach maintenance volume and prevent muscle loss.'**
  String volumeBelowMaintenanceAdvice(int sets);

  /// Maintenance zone explanation
  ///
  /// In en, this message translates to:
  /// **'You\'re doing {current} sets/week. This maintains muscle ({mv}-{mev} sets) but won\'t trigger growth.'**
  String volumeMaintenanceExplanation(int current, int mv, int mev);

  /// Maintenance zone advice
  ///
  /// In en, this message translates to:
  /// **'Add {sets} more sets to reach MEV and start seeing muscle growth.'**
  String volumeMaintenanceAdvice(int sets);

  /// Effective zone explanation
  ///
  /// In en, this message translates to:
  /// **'You\'re doing {current} sets/week, in the growth zone ({mev}-{mav} sets). Good progress!'**
  String volumeEffectiveExplanation(int current, int mev, int mav);

  /// Effective zone advice
  ///
  /// In en, this message translates to:
  /// **'You can add up to {sets} more sets to reach optimal MAV zone for maximum gains.'**
  String volumeEffectiveAdvice(int sets);

  /// Optimal zone explanation
  ///
  /// In en, this message translates to:
  /// **'You\'re doing {current} sets/week, in the optimal zone ({mav}-{mrv} sets). Maximum hypertrophy stimulus!'**
  String volumeOptimalExplanation(int current, int mav, int mrv);

  /// Optimal zone advice
  ///
  /// In en, this message translates to:
  /// **'Perfect! Maintain this volume for 2-4 weeks, then consider a deload week.'**
  String get volumeOptimalAdvice;

  /// Excessive zone explanation
  ///
  /// In en, this message translates to:
  /// **'You\'re doing {current} sets/week, exceeding recovery limit ({mrv} sets). Risk of overtraining!'**
  String volumeExcessiveExplanation(int current, int mrv);

  /// Excessive zone advice
  ///
  /// In en, this message translates to:
  /// **'Reduce volume by {sets} sets or take an immediate deload week at 50% volume to recover.'**
  String volumeExcessiveAdvice(int sets);

  /// Section title for exercises performed this week
  ///
  /// In en, this message translates to:
  /// **'Exercises This Week'**
  String get exercisesThisWeek;

  /// No description provided for @rpeAndIntensity.
  ///
  /// In en, this message translates to:
  /// **'RPE & Intensity'**
  String get rpeAndIntensity;

  /// No description provided for @rpeIntensityDistribution.
  ///
  /// In en, this message translates to:
  /// **'Training intensity distribution'**
  String get rpeIntensityDistribution;

  /// No description provided for @setsWithRPETracked.
  ///
  /// In en, this message translates to:
  /// **'Sets with RPE tracked'**
  String get setsWithRPETracked;

  /// No description provided for @noRPEDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No RPE data available'**
  String get noRPEDataAvailable;

  /// No description provided for @noRPEDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Start tracking RPE (Rate of Perceived Exertion) during your workouts to see intensity analysis'**
  String get noRPEDataDescription;

  /// No description provided for @rpeDistribution.
  ///
  /// In en, this message translates to:
  /// **'RPE Distribution'**
  String get rpeDistribution;

  /// No description provided for @rpeRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery (5-6)'**
  String get rpeRecovery;

  /// No description provided for @rpeModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (7)'**
  String get rpeModerate;

  /// No description provided for @rpeHard.
  ///
  /// In en, this message translates to:
  /// **'Hard (8)'**
  String get rpeHard;

  /// No description provided for @rpeVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard (9)'**
  String get rpeVeryHard;

  /// No description provided for @rpeMaximal.
  ///
  /// In en, this message translates to:
  /// **'Maximal (10)'**
  String get rpeMaximal;

  /// No description provided for @averageRPEPerMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Average RPE per Muscle Group'**
  String get averageRPEPerMuscleGroup;

  /// No description provided for @setsUnit.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get setsUnit;

  /// No description provided for @rangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range:'**
  String get rangeLabel;

  /// No description provided for @helmsEtAl2018.
  ///
  /// In en, this message translates to:
  /// **'Helms et al. (2018) - Strength & Conditioning Journal'**
  String get helmsEtAl2018;

  /// No description provided for @intensityZoneTooEasy.
  ///
  /// In en, this message translates to:
  /// **'Too Easy'**
  String get intensityZoneTooEasy;

  /// No description provided for @intensityZoneTooEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Over 50% of sets are low intensity (RPE 5-6). Risk of lack of progress.'**
  String get intensityZoneTooEasyDesc;

  /// No description provided for @intensityZoneTooEasyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Increase intensity: bring 60-80% of sets to RPE 7-9 to stimulate hypertrophy.'**
  String get intensityZoneTooEasyAdvice;

  /// No description provided for @intensityZoneOptimalHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Optimal for Hypertrophy'**
  String get intensityZoneOptimalHypertrophy;

  /// No description provided for @intensityZoneOptimalHypertrophyDesc.
  ///
  /// In en, this message translates to:
  /// **'60-80% of sets are at productive intensity (RPE 7-9). Perfect for muscle growth!'**
  String get intensityZoneOptimalHypertrophyDesc;

  /// No description provided for @intensityZoneOptimalHypertrophyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! This distribution is ideal for maximizing hypertrophy.'**
  String get intensityZoneOptimalHypertrophyAdvice;

  /// No description provided for @intensityZoneOptimalStrength.
  ///
  /// In en, this message translates to:
  /// **'Optimal for Strength'**
  String get intensityZoneOptimalStrength;

  /// No description provided for @intensityZoneOptimalStrengthDesc.
  ///
  /// In en, this message translates to:
  /// **'50-70% of sets are high intensity (RPE 8-10). Perfect for strength gains!'**
  String get intensityZoneOptimalStrengthDesc;

  /// No description provided for @intensityZoneOptimalStrengthAdvice.
  ///
  /// In en, this message translates to:
  /// **'Excellent! This distribution maximizes strength gains. Consider deload every 4-6 weeks.'**
  String get intensityZoneOptimalStrengthAdvice;

  /// No description provided for @intensityZoneBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get intensityZoneBalanced;

  /// No description provided for @intensityZoneBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Good mix of intensities. Suitable for general progress.'**
  String get intensityZoneBalancedDesc;

  /// No description provided for @intensityZoneBalancedAdvice.
  ///
  /// In en, this message translates to:
  /// **'Balanced distribution. For hypertrophy, increase RPE 7-9. For strength, increase RPE 8-10.'**
  String get intensityZoneBalancedAdvice;

  /// No description provided for @intensityZoneTooHard.
  ///
  /// In en, this message translates to:
  /// **'Too Intense'**
  String get intensityZoneTooHard;

  /// No description provided for @intensityZoneTooHardDesc.
  ///
  /// In en, this message translates to:
  /// **'Over 30% of sets are maximal (RPE 10). Risk of overtraining and injury.'**
  String get intensityZoneTooHardDesc;

  /// No description provided for @intensityZoneTooHardAdvice.
  ///
  /// In en, this message translates to:
  /// **'Reduce intensity: max 20-30% sets at RPE 10. Add more sets at RPE 7-8 for sustainable volume.'**
  String get intensityZoneTooHardAdvice;

  /// No description provided for @rpeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'RPE & Intensity'**
  String get rpeInfoTitle;

  /// No description provided for @rpeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'RPE (Rate of Perceived Exertion) is a 5-10 effort scale:'**
  String get rpeInfoDescription;

  /// No description provided for @rpeScale5_6.
  ///
  /// In en, this message translates to:
  /// **'RPE 5-6'**
  String get rpeScale5_6;

  /// No description provided for @rpeScale5_6Desc.
  ///
  /// In en, this message translates to:
  /// **'Recovery - Easy'**
  String get rpeScale5_6Desc;

  /// No description provided for @rpeScale7.
  ///
  /// In en, this message translates to:
  /// **'RPE 7'**
  String get rpeScale7;

  /// No description provided for @rpeScale7Desc.
  ///
  /// In en, this message translates to:
  /// **'Moderate - 3 RIR'**
  String get rpeScale7Desc;

  /// No description provided for @rpeScale8.
  ///
  /// In en, this message translates to:
  /// **'RPE 8'**
  String get rpeScale8;

  /// No description provided for @rpeScale8Desc.
  ///
  /// In en, this message translates to:
  /// **'Hard - 2 RIR'**
  String get rpeScale8Desc;

  /// No description provided for @rpeScale9.
  ///
  /// In en, this message translates to:
  /// **'RPE 9'**
  String get rpeScale9;

  /// No description provided for @rpeScale9Desc.
  ///
  /// In en, this message translates to:
  /// **'Very Hard - 1 RIR'**
  String get rpeScale9Desc;

  /// No description provided for @rpeScale10.
  ///
  /// In en, this message translates to:
  /// **'RPE 10'**
  String get rpeScale10;

  /// No description provided for @rpeScale10Desc.
  ///
  /// In en, this message translates to:
  /// **'Maximal - 0 RIR'**
  String get rpeScale10Desc;

  /// No description provided for @optimalDistribution.
  ///
  /// In en, this message translates to:
  /// **'Optimal Distribution (Helms et al. 2018):'**
  String get optimalDistribution;

  /// No description provided for @hypertrophyDistribution.
  ///
  /// In en, this message translates to:
  /// **'• Hypertrophy: 60-80% sets at RPE 7-9'**
  String get hypertrophyDistribution;

  /// No description provided for @strengthDistribution.
  ///
  /// In en, this message translates to:
  /// **'• Strength: 50-70% sets at RPE 8-10'**
  String get strengthDistribution;

  /// No description provided for @recoveryDistribution.
  ///
  /// In en, this message translates to:
  /// **'• Recovery: <50% sets at RPE 5-6'**
  String get recoveryDistribution;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @uncategorizedExercises.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized Exercises'**
  String get uncategorizedExercises;

  /// No description provided for @uncategorizedExercisesDesc.
  ///
  /// In en, this message translates to:
  /// **'These exercises have \'other\' or \'cardio\' category and are not counted in volume. Tap to assign the correct muscle group.'**
  String get uncategorizedExercisesDesc;

  /// No description provided for @categorizeExercise.
  ///
  /// In en, this message translates to:
  /// **'Categorize Exercise'**
  String get categorizeExercise;

  /// No description provided for @selectCorrectMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Select the correct muscle group:'**
  String get selectCorrectMuscleGroup;

  /// No description provided for @chestMuscle.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chestMuscle;

  /// No description provided for @backMuscle.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backMuscle;

  /// No description provided for @shouldersMuscle.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shouldersMuscle;

  /// No description provided for @armsMuscle.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get armsMuscle;

  /// No description provided for @legsMuscle.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legsMuscle;

  /// No description provided for @coreMuscle.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get coreMuscle;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @remappingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon: we\'ll save \"{exerciseName}\" as {muscleGroup}'**
  String remappingComingSoon(String exerciseName, String muscleGroup);

  /// No description provided for @setsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'sets/week'**
  String get setsPerWeek;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknownCategory;

  /// Button to watch rewarded ad for premium unlock
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for 24h Premium'**
  String get watchAdForPremium;

  /// Success message after watching rewarded ad
  ///
  /// In en, this message translates to:
  /// **'🎉 Premium unlocked for 24 hours!'**
  String get premiumUnlockedFor24Hours;

  /// Error message when ad is not ready to show
  ///
  /// In en, this message translates to:
  /// **'Ad not ready, try again later'**
  String get adNotReady;

  /// Shows remaining time for premium access
  ///
  /// In en, this message translates to:
  /// **'Premium active: {time} remaining'**
  String premiumActiveRemaining(String time);

  /// Button to add a temporary exercise
  ///
  /// In en, this message translates to:
  /// **'Add temporary exercise'**
  String get addTemporaryExercise;

  /// Button to report a missing exercise to admin
  ///
  /// In en, this message translates to:
  /// **'Report missing exercise'**
  String get reportMissingExercise;

  /// Confirmation message when temporary exercise is created
  ///
  /// In en, this message translates to:
  /// **'Temporary exercise added! We\'ll review your request.'**
  String get temporaryExerciseAdded;

  /// Hint for exercise name input
  ///
  /// In en, this message translates to:
  /// **'Enter exercise name'**
  String get enterExerciseName;

  /// Confirmation yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Confirmation no button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter valid data'**
  String get pleaseEnterValidData;

  /// Button to start rest timer after completing exercises
  ///
  /// In en, this message translates to:
  /// **'Start Rest'**
  String get startRest;

  /// Title for rest timer screen
  ///
  /// In en, this message translates to:
  /// **'Rest Between Sets'**
  String get restBetweenSets;

  /// Label indicating something is completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Singular form of exercise set
  ///
  /// In en, this message translates to:
  /// **'set'**
  String get set;

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Button label to execute an action
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// Button to skip rest period
  ///
  /// In en, this message translates to:
  /// **'Skip Rest'**
  String get skipRest;

  /// Title shown when superset is completed
  ///
  /// In en, this message translates to:
  /// **'Superset Completed'**
  String get supersetCompleted;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// Dialog title for canceling exercise
  ///
  /// In en, this message translates to:
  /// **'Cancel Exercise?'**
  String get cancelExercise;

  /// Dialog message for canceling exercise
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? Your progress will not be saved.'**
  String get cancelExerciseMessage;

  /// Dropset training technique title
  ///
  /// In en, this message translates to:
  /// **'Dropset Training'**
  String get dropsetTraining;

  /// Dropset technique description
  ///
  /// In en, this message translates to:
  /// **'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.'**
  String get dropsetDescription;

  /// Label for selected exercise section
  ///
  /// In en, this message translates to:
  /// **'Selected Exercise'**
  String get selectedExercise;

  /// Title for dropset configuration section
  ///
  /// In en, this message translates to:
  /// **'Dropset Configuration'**
  String get dropsetConfiguration;

  /// Label for initial weight in dropset
  ///
  /// In en, this message translates to:
  /// **'Initial Weight'**
  String get initialWeight;

  /// Placeholder for selecting weight
  ///
  /// In en, this message translates to:
  /// **'Select Weight'**
  String get selectWeight;

  /// Title for weight picker modal
  ///
  /// In en, this message translates to:
  /// **'Select Initial Weight'**
  String get selectInitialWeight;

  /// Title for reps picker modal
  ///
  /// In en, this message translates to:
  /// **'Select Target Reps'**
  String get selectTargetReps;

  /// Label for number of weight drops
  ///
  /// In en, this message translates to:
  /// **'Number of Drops'**
  String get numberOfDrops;

  /// Unit for number of drops (lowercase)
  ///
  /// In en, this message translates to:
  /// **'drops'**
  String get drops;

  /// Label for weight reduction percentage
  ///
  /// In en, this message translates to:
  /// **'Drop Percentage'**
  String get dropPercentage;

  /// Title for dropset stages preview
  ///
  /// In en, this message translates to:
  /// **'Drop Stages Preview'**
  String get dropStagesPreview;

  /// Label for main set in dropset
  ///
  /// In en, this message translates to:
  /// **'Main Set'**
  String get mainSet;

  /// Label for drop stage
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// Percentage of maximum weight
  ///
  /// In en, this message translates to:
  /// **'of max'**
  String get ofMax;

  /// Button to create dropset exercise
  ///
  /// In en, this message translates to:
  /// **'Create Dropset'**
  String get createDropset;

  /// Error message when creating dropset without required fields
  ///
  /// In en, this message translates to:
  /// **'Please select an exercise and set the initial weight'**
  String get pleaseSelectExerciseAndWeight;

  /// Rest-pause training technique title
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause Training'**
  String get restPauseTraining;

  /// Rest-pause technique description
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.'**
  String get restPauseDescription;

  /// Rest-Pause configuration section title
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause Configuration'**
  String get restPauseConfiguration;

  /// Label for pause duration between mini-sets
  ///
  /// In en, this message translates to:
  /// **'Pause Duration'**
  String get pauseDuration;

  /// Instructions for rest-pause technique
  ///
  /// In en, this message translates to:
  /// **'Execute the main set to failure, then take short pauses and continue for additional mini-sets'**
  String get restPauseInstructions;

  /// Button to create rest-pause exercise
  ///
  /// In en, this message translates to:
  /// **'Create Rest-Pause'**
  String get createRestPause;

  /// Label for rest-pause execution header
  ///
  /// In en, this message translates to:
  /// **'REST-PAUSE'**
  String get restPauseLabel;

  /// Label for main set in rest-pause execution
  ///
  /// In en, this message translates to:
  /// **'Main Set'**
  String get restPauseMainSet;

  /// Label for individual mini-set in rest-pause
  ///
  /// In en, this message translates to:
  /// **'Mini-Set {index}'**
  String restPauseMiniSet(int index);

  /// Label for mini-set progress indicator
  ///
  /// In en, this message translates to:
  /// **'Mini-Set Progress'**
  String get miniSetProgress;

  /// Label for rest timer during rest-pause
  ///
  /// In en, this message translates to:
  /// **'MICRO-PAUSE'**
  String get microPause;

  /// Text showing pause duration
  ///
  /// In en, this message translates to:
  /// **'After {duration}s pause'**
  String afterPauseDuration(int duration);

  /// Label for RPE selector in rest-pause execution
  ///
  /// In en, this message translates to:
  /// **'Overall RPE (Perceived Exertion)'**
  String get rpeLabel;

  /// Title for fitness questionnaire
  ///
  /// In en, this message translates to:
  /// **'Fitness Profile Setup'**
  String get fitnessQuestionnaireTitle;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Get Personalized Weight Suggestions'**
  String get fitnessQuestionnaireWelcomeTitle;

  /// Welcome screen description
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions to receive scientifically-backed starting weight suggestions for your exercises.'**
  String get fitnessQuestionnaireWelcomeDescription;

  /// Skip questionnaire button
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get fitnessQuestionnaireWelcomeSkip;

  /// Start questionnaire button
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get fitnessQuestionnaireWelcomeStart;

  /// Demographics step title
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get fitnessQuestionnaireDemographicsTitle;

  /// Bodyweight input label
  ///
  /// In en, this message translates to:
  /// **'Current Bodyweight'**
  String get fitnessQuestionnaireBodyweightLabel;

  /// Bodyweight unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get fitnessQuestionnaireBodyweightUnit;

  /// Age input label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fitnessQuestionnaireAgeLabel;

  /// Biological sex label
  ///
  /// In en, this message translates to:
  /// **'Biological Sex'**
  String get fitnessQuestionnaireSexLabel;

  /// Male option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get fitnessQuestionnaireSexMale;

  /// Female option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get fitnessQuestionnaireSexFemale;

  /// Experience step title
  ///
  /// In en, this message translates to:
  /// **'Training Experience'**
  String get fitnessQuestionnaireExperienceTitle;

  /// Experience level label
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get fitnessQuestionnaireExperienceLevelLabel;

  /// Untrained level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get fitnessQuestionnaireExperienceLevelUntrained;

  /// Novice level (2-6 months)
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get fitnessQuestionnaireExperienceLevelNovice;

  /// Intermediate level (1-2 years)
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get fitnessQuestionnaireExperienceLevelIntermediate;

  /// Advanced level (3-5 years)
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get fitnessQuestionnaireExperienceLevelAdvanced;

  /// Elite level (5+ years)
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get fitnessQuestionnaireExperienceLevelElite;

  /// Months of training label
  ///
  /// In en, this message translates to:
  /// **'Months of consistent training (optional)'**
  String get fitnessQuestionnaireMonthsTrainingLabel;

  /// Max lifts step title
  ///
  /// In en, this message translates to:
  /// **'Max Lifts (Optional)'**
  String get fitnessQuestionnaireMaxLiftsTitle;

  /// Max lifts description
  ///
  /// In en, this message translates to:
  /// **'Entering your max lifts improves suggestion accuracy. You can skip this if you don\'t know them.'**
  String get fitnessQuestionnaireMaxLiftsDescription;

  /// Bench press max label
  ///
  /// In en, this message translates to:
  /// **'Bench Press 1RM'**
  String get fitnessQuestionnaireBenchPressLabel;

  /// Squat max label
  ///
  /// In en, this message translates to:
  /// **'Squat 1RM'**
  String get fitnessQuestionnaireSquatLabel;

  /// Deadlift max label
  ///
  /// In en, this message translates to:
  /// **'Deadlift 1RM'**
  String get fitnessQuestionnaireDeadliftLabel;

  /// OHP max label
  ///
  /// In en, this message translates to:
  /// **'Overhead Press 1RM'**
  String get fitnessQuestionnaireOhpLabel;

  /// Link to 1RM calculator
  ///
  /// In en, this message translates to:
  /// **'Calculate from reps'**
  String get fitnessQuestionnaireCalculateFrom;

  /// Goals step title
  ///
  /// In en, this message translates to:
  /// **'Goals & Preferences'**
  String get fitnessQuestionnaireGoalsTitle;

  /// Training goal label
  ///
  /// In en, this message translates to:
  /// **'Primary Training Goal'**
  String get fitnessQuestionnaireTrainingGoalLabel;

  /// Strength goal
  ///
  /// In en, this message translates to:
  /// **'Strength (1-5 reps)'**
  String get fitnessQuestionnaireTrainingGoalStrength;

  /// Hypertrophy goal
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy (8-12 reps)'**
  String get fitnessQuestionnaireTrainingGoalHypertrophy;

  /// Endurance goal
  ///
  /// In en, this message translates to:
  /// **'Endurance (15+ reps)'**
  String get fitnessQuestionnaireTrainingGoalEndurance;

  /// Injury history checkbox
  ///
  /// In en, this message translates to:
  /// **'I have a history of training-related injuries'**
  String get fitnessQuestionnaireInjuryHistoryLabel;

  /// Suggestion style label
  ///
  /// In en, this message translates to:
  /// **'Suggestion Style'**
  String get fitnessQuestionnaireSuggestionStyleLabel;

  /// Conservative style
  ///
  /// In en, this message translates to:
  /// **'Conservative (safer)'**
  String get fitnessQuestionnaireSuggestionStyleConservative;

  /// Balanced style
  ///
  /// In en, this message translates to:
  /// **'Balanced (recommended)'**
  String get fitnessQuestionnaireSuggestionStyleBalanced;

  /// Aggressive style
  ///
  /// In en, this message translates to:
  /// **'Aggressive (experienced)'**
  String get fitnessQuestionnaireSuggestionStyleAggressive;

  /// Review step title
  ///
  /// In en, this message translates to:
  /// **'Review & Complete'**
  String get fitnessQuestionnaireReviewTitle;

  /// Review step description
  ///
  /// In en, this message translates to:
  /// **'Review your information and complete the setup to start getting weight suggestions.'**
  String get fitnessQuestionnaireReviewDescription;

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get fitnessQuestionnaireComplete;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get fitnessQuestionnaireBackButton;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get fitnessQuestionnaireNextButton;

  /// Suggested weight label
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get weightSuggestionSuggestedWeight;

  /// Use suggestion button
  ///
  /// In en, this message translates to:
  /// **'Use Suggestion'**
  String get weightSuggestionUse;

  /// Excellent confidence
  ///
  /// In en, this message translates to:
  /// **'Excellent match'**
  String get weightSuggestionConfidenceExcellent;

  /// Good confidence
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get weightSuggestionConfidenceGood;

  /// Fair confidence
  ///
  /// In en, this message translates to:
  /// **'Fair match'**
  String get weightSuggestionConfidenceFair;

  /// Low confidence
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get weightSuggestionConfidenceLow;

  /// Low confidence warning
  ///
  /// In en, this message translates to:
  /// **'This suggestion has low confidence. Start conservatively.'**
  String get weightSuggestionWarningLow;

  /// No suggestion message
  ///
  /// In en, this message translates to:
  /// **'No suggestion available for this exercise'**
  String get weightSuggestionNoData;

  /// Prompt to complete questionnaire
  ///
  /// In en, this message translates to:
  /// **'Complete fitness profile to get weight suggestions'**
  String get weightSuggestionCompleteQuestionnaire;

  /// Suggestion basis label
  ///
  /// In en, this message translates to:
  /// **'Based on strength standards'**
  String get weightSuggestionBasedOn;

  /// View suggestion details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get weightSuggestionViewDetails;

  /// Details dialog title
  ///
  /// In en, this message translates to:
  /// **'Weight Suggestion Details'**
  String get weightSuggestionDetailsTitle;

  /// Base 1RM label
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get weightSuggestionDetailsBaseOneRM;

  /// Intensity factor label
  ///
  /// In en, this message translates to:
  /// **'Training goal intensity'**
  String get weightSuggestionDetailsIntensityFactor;

  /// Multipliers list label
  ///
  /// In en, this message translates to:
  /// **'Applied adjustments'**
  String get weightSuggestionDetailsAppliedMultipliers;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Important notes'**
  String get weightSuggestionDetailsNotes;

  /// 1RM calculator title
  ///
  /// In en, this message translates to:
  /// **'1RM Calculator'**
  String get oneRMCalculatorTitle;

  /// Weight input label
  ///
  /// In en, this message translates to:
  /// **'Weight lifted'**
  String get oneRMCalculatorWeight;

  /// Reps input label
  ///
  /// In en, this message translates to:
  /// **'Reps completed'**
  String get oneRMCalculatorReps;

  /// Estimated 1RM result label
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get oneRMCalculatorEstimated;

  /// Formula note
  ///
  /// In en, this message translates to:
  /// **'Using Brzycki formula'**
  String get oneRMCalculatorFormula;

  /// Use calculated value button
  ///
  /// In en, this message translates to:
  /// **'Use This Value'**
  String get oneRMCalculatorUse;

  /// Step indicator
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// of (as in step 1 of 5)
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofPreposition;

  /// Hero card title when no profile exists
  ///
  /// In en, this message translates to:
  /// **'Calculate Your Level'**
  String get fitnessBenchmarkCalculate;

  /// Hero card title when profile exists
  ///
  /// In en, this message translates to:
  /// **'Update Benchmark'**
  String get fitnessBenchmarkUpdate;

  /// Label for experience level in hero card
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get fitnessBenchmarkLevel;

  /// Description in hero card when no profile
  ///
  /// In en, this message translates to:
  /// **'Get personalized weight suggestions'**
  String get fitnessBenchmarkDescription;

  /// No description provided for @fitnessQuestionnaireFullyRecovered.
  ///
  /// In en, this message translates to:
  /// **'Fully Recovered'**
  String get fitnessQuestionnaireFullyRecovered;

  /// No description provided for @fitnessQuestionnaireInRehabilitation.
  ///
  /// In en, this message translates to:
  /// **'Currently in Rehabilitation'**
  String get fitnessQuestionnaireInRehabilitation;

  /// No description provided for @fitnessQuestionnaireCurrentPainLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Pain Level'**
  String get fitnessQuestionnaireCurrentPainLevel;

  /// No description provided for @fitnessQuestionnaireMonthsHelperText.
  ///
  /// In en, this message translates to:
  /// **'Optional - helps validate experience level'**
  String get fitnessQuestionnaireMonthsHelperText;

  /// No description provided for @fitnessQuestionnaireReviewDemographics.
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get fitnessQuestionnaireReviewDemographics;

  /// No description provided for @fitnessQuestionnaireReviewExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get fitnessQuestionnaireReviewExperience;

  /// No description provided for @fitnessQuestionnaireReviewMaxLifts.
  ///
  /// In en, this message translates to:
  /// **'Max Lifts'**
  String get fitnessQuestionnaireReviewMaxLifts;

  /// No description provided for @fitnessQuestionnaireReviewGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get fitnessQuestionnaireReviewGoals;

  /// No description provided for @fitnessQuestionnaireReviewBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get fitnessQuestionnaireReviewBodyweight;

  /// No description provided for @fitnessQuestionnaireReviewAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fitnessQuestionnaireReviewAge;

  /// No description provided for @fitnessQuestionnaireReviewSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get fitnessQuestionnaireReviewSex;

  /// No description provided for @fitnessQuestionnaireReviewLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get fitnessQuestionnaireReviewLevel;

  /// No description provided for @fitnessQuestionnaireReviewTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get fitnessQuestionnaireReviewTraining;

  /// No description provided for @fitnessQuestionnaireReviewMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get fitnessQuestionnaireReviewMonths;

  /// No description provided for @fitnessQuestionnaireReviewBench.
  ///
  /// In en, this message translates to:
  /// **'Bench'**
  String get fitnessQuestionnaireReviewBench;

  /// No description provided for @fitnessQuestionnaireReviewSquat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get fitnessQuestionnaireReviewSquat;

  /// No description provided for @fitnessQuestionnaireReviewDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get fitnessQuestionnaireReviewDeadlift;

  /// No description provided for @fitnessQuestionnaireReviewOHP.
  ///
  /// In en, this message translates to:
  /// **'OHP'**
  String get fitnessQuestionnaireReviewOHP;

  /// No description provided for @fitnessQuestionnaireReviewTrainingGoal.
  ///
  /// In en, this message translates to:
  /// **'Training Goal'**
  String get fitnessQuestionnaireReviewTrainingGoal;

  /// No description provided for @fitnessQuestionnaireReviewSuggestionStyle.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Style'**
  String get fitnessQuestionnaireReviewSuggestionStyle;

  /// No description provided for @fitnessQuestionnaireReviewSelfAssessment.
  ///
  /// In en, this message translates to:
  /// **'Self-Assessment'**
  String get fitnessQuestionnaireReviewSelfAssessment;

  /// No description provided for @fitnessQuestionnaireSelfAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-Assessment Calibration'**
  String get fitnessQuestionnaireSelfAssessmentTitle;

  /// No description provided for @fitnessQuestionnaireSelfAssessmentDescription.
  ///
  /// In en, this message translates to:
  /// **'How accurate are you in assessing your abilities?'**
  String get fitnessQuestionnaireSelfAssessmentDescription;

  /// No description provided for @fitnessMedicalClearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Clearance (PAR-Q+)'**
  String get fitnessMedicalClearanceTitle;

  /// No description provided for @fitnessMedicalClearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Please answer these health screening questions honestly.'**
  String get fitnessMedicalClearanceDescription;

  /// No description provided for @fitnessParqHeartCondition.
  ///
  /// In en, this message translates to:
  /// **'Has a doctor ever said you have a heart condition?'**
  String get fitnessParqHeartCondition;

  /// No description provided for @fitnessParqChestPainActive.
  ///
  /// In en, this message translates to:
  /// **'Do you feel pain in your chest during physical activity?'**
  String get fitnessParqChestPainActive;

  /// No description provided for @fitnessParqChestPainRest.
  ///
  /// In en, this message translates to:
  /// **'In the past month, have you had chest pain when NOT doing physical activity?'**
  String get fitnessParqChestPainRest;

  /// No description provided for @fitnessParqDizziness.
  ///
  /// In en, this message translates to:
  /// **'Do you lose balance because of dizziness or do you ever lose consciousness?'**
  String get fitnessParqDizziness;

  /// No description provided for @fitnessParqBoneJoint.
  ///
  /// In en, this message translates to:
  /// **'Do you have a bone or joint problem that could be made worse by activity?'**
  String get fitnessParqBoneJoint;

  /// No description provided for @fitnessParqMedication.
  ///
  /// In en, this message translates to:
  /// **'Are you currently taking medication for blood pressure or a heart condition?'**
  String get fitnessParqMedication;

  /// No description provided for @fitnessParqOtherReason.
  ///
  /// In en, this message translates to:
  /// **'Do you know of any other reason you should not do physical activity?'**
  String get fitnessParqOtherReason;

  /// No description provided for @fitnessAcsmTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional Risk Factors (ACSM)'**
  String get fitnessAcsmTitle;

  /// No description provided for @fitnessAcsmAge.
  ///
  /// In en, this message translates to:
  /// **'Age ≥45 (men) or ≥55 (women)'**
  String get fitnessAcsmAge;

  /// No description provided for @fitnessAcsmFamilyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family history of heart disease before age 55'**
  String get fitnessAcsmFamilyHistory;

  /// No description provided for @fitnessAcsmSmoker.
  ///
  /// In en, this message translates to:
  /// **'Current smoker or quit within 6 months'**
  String get fitnessAcsmSmoker;

  /// No description provided for @fitnessAcsmObese.
  ///
  /// In en, this message translates to:
  /// **'BMI ≥30 or waist >102cm (men) / >88cm (women)'**
  String get fitnessAcsmObese;

  /// No description provided for @fitnessAcsmDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes (Type 1 or 2)'**
  String get fitnessAcsmDiabetes;

  /// No description provided for @fitnessAcsmHighBP.
  ///
  /// In en, this message translates to:
  /// **'High blood pressure (≥140/90 or on medication)'**
  String get fitnessAcsmHighBP;

  /// No description provided for @fitnessValidationWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight (40-200 kg)'**
  String get fitnessValidationWeight;

  /// No description provided for @fitnessValidationAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age (13-100)'**
  String get fitnessValidationAge;

  /// No description provided for @fitnessInjuryHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Injury History'**
  String get fitnessInjuryHistoryTitle;

  /// No description provided for @fitnessInjuryType.
  ///
  /// In en, this message translates to:
  /// **'Injury Type'**
  String get fitnessInjuryType;

  /// No description provided for @fitnessInjuryBodyRegion.
  ///
  /// In en, this message translates to:
  /// **'Body Region'**
  String get fitnessInjuryBodyRegion;

  /// No description provided for @fitnessInjuryMonthsSince.
  ///
  /// In en, this message translates to:
  /// **'Months Since Injury'**
  String get fitnessInjuryMonthsSince;

  /// No description provided for @fitnessValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fitnessValidationRequired;

  /// No description provided for @fitnessInjuryTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Lower back strain'**
  String get fitnessInjuryTypeHint;

  /// Label for first dropset stage weight input
  ///
  /// In en, this message translates to:
  /// **'Stage 1 Weight'**
  String get dropsetStage1Weight;

  /// Label for dropset stage N weight input
  ///
  /// In en, this message translates to:
  /// **'Stage {stageNumber} Weight'**
  String dropsetStageNWeight(int stageNumber);

  /// Label showing weight from previous dropset stage
  ///
  /// In en, this message translates to:
  /// **'Previous stage'**
  String get previousStageWeight;

  /// Label for automatically detected equipment type
  ///
  /// In en, this message translates to:
  /// **'Detected equipment'**
  String get detectedEquipmentType;

  /// Barbell equipment type
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get barbell;

  /// Dumbbell equipment type
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get dumbbell;

  /// Info about barbell weight rounding
  ///
  /// In en, this message translates to:
  /// **'Rounds to 2.5kg'**
  String get barbellRoundingInfo;

  /// Info about dumbbell weight rounding
  ///
  /// In en, this message translates to:
  /// **'Custom increments'**
  String get dumbbellRoundingInfo;

  /// Header for equipment type selector
  ///
  /// In en, this message translates to:
  /// **'Select Equipment Type'**
  String get selectEquipmentType;

  /// Header for percentage drop selector
  ///
  /// In en, this message translates to:
  /// **'Select Weight Drop'**
  String get selectWeightDrop;

  /// Label for automatically calculated weight
  ///
  /// In en, this message translates to:
  /// **'Calculated Weight'**
  String get calculatedWeight;

  /// Question about gym dumbbell increments
  ///
  /// In en, this message translates to:
  /// **'What dumbbell increments does your gym have?'**
  String get dumbbellIncrementQuestion;

  /// 0.5kg dumbbell increment option
  ///
  /// In en, this message translates to:
  /// **'0.5kg increments (17.5, 18, 18.5...)'**
  String get dumbbellIncrementHalfKg;

  /// 1kg dumbbell increment option
  ///
  /// In en, this message translates to:
  /// **'1kg increments (17, 18, 19...)'**
  String get dumbbellIncrementOneKg;

  /// 2kg dumbbell increment option
  ///
  /// In en, this message translates to:
  /// **'2kg increments (16, 18, 20...)'**
  String get dumbbellIncrementTwoKg;

  /// Instruction to enter first stage weight
  ///
  /// In en, this message translates to:
  /// **'Enter Initial Weight'**
  String get enterInitialWeight;

  /// Instruction to confirm or manually adjust calculated weight
  ///
  /// In en, this message translates to:
  /// **'Confirm or Adjust Weight'**
  String get confirmOrAdjustWeight;

  /// Application subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Track your fitness journey'**
  String get appSubtitle;

  /// Email input field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// Password input field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Confirm password input field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// Full name input field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// Create account screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// Register screen welcome title
  ///
  /// In en, this message translates to:
  /// **'Join FitLog Pro'**
  String get joinGymBro;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Google sign up button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Apple sign up button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Email sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// Tooltip for back to login button
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Error message when email is missing for password reset
  ///
  /// In en, this message translates to:
  /// **'Please enter your email first'**
  String get pleaseEnterEmailFirst;

  /// Success message after password reset email sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get passwordResetEmailSent;

  /// Rest timer label
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// Generic error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorDialogTitle;

  /// Error message when workout fails to load
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the workout'**
  String get workoutLoadError;

  /// Navigate to home button text
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHomeButton;

  /// Create new template button
  ///
  /// In en, this message translates to:
  /// **'Create New Template'**
  String get createNewTemplate;

  /// Info message about upcoming template save feature
  ///
  /// In en, this message translates to:
  /// **'Save template feature coming soon!'**
  String get saveTemplateComingSoon;

  /// Save as template subtitle
  ///
  /// In en, this message translates to:
  /// **'Save to Firebase for reuse'**
  String get saveToFirebase;

  /// Instructions to use template import
  ///
  /// In en, this message translates to:
  /// **'Use the import function in the template screen'**
  String get useTemplateScreenForImport;

  /// Dialog title asking to keep workout active
  ///
  /// In en, this message translates to:
  /// **'Keep Workout Active?'**
  String get keepWorkoutActiveTitle;

  /// Workout paused snackbar message
  ///
  /// In en, this message translates to:
  /// **'Workout paused - Continue anytime from Home'**
  String get workoutPausedMessage;

  /// Complete workout dialog title
  ///
  /// In en, this message translates to:
  /// **'Complete Workout'**
  String get completeWorkoutTitle;

  /// Confirmation message for completing workout
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete this workout?'**
  String get completeWorkoutConfirmation;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeButton;

  /// Workout completion success message
  ///
  /// In en, this message translates to:
  /// **'Workout completed! Great job!'**
  String get workoutCompletedSuccess;

  /// Message shown when workout completion is undone
  ///
  /// In en, this message translates to:
  /// **'Workout restored - you can continue training'**
  String get workoutResumed;

  /// Save as template menu item
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplate;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// Add exercise modal title
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseTitle;

  /// Generic add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Superset tab label
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get supersetTab;

  /// Dropset tab label
  ///
  /// In en, this message translates to:
  /// **'Dropset'**
  String get dropsetTab;

  /// Rest-pause tab label
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause'**
  String get restPauseTab;

  /// Exercise category selection label
  ///
  /// In en, this message translates to:
  /// **'Exercise Category'**
  String get exerciseCategoryLabel;

  /// Sets section label
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsLabel;

  /// Add set button text
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSetButton;

  /// Remove set button tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove Set'**
  String get removeSetTooltip;

  /// Weight input field hint
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get weightHint;

  /// Reps input field hint
  ///
  /// In en, this message translates to:
  /// **'Enter reps'**
  String get repsHint;

  /// Notes input field label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// Success message when exercise is added
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} to workout'**
  String exerciseAddedMessage(String exerciseName);

  /// Success message when dropset is added
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} Drop Set to workout'**
  String dropsetAddedMessage(String exerciseName);

  /// Success message when rest-pause is added
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} Rest-Pause to workout'**
  String restPauseAddedMessage(String exerciseName);

  /// Success message when superset is added
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} Superset to workout'**
  String supersetAddedMessage(String exerciseName);

  /// Chest muscle category
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get categoryChest;

  /// Back muscle category
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get categoryBack;

  /// Shoulders muscle category
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get categoryShoulders;

  /// Arms muscle category
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get categoryArms;

  /// Legs muscle category
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get categoryLegs;

  /// Abs muscle category
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get categoryAbs;

  /// Cardio category
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get categoryCardio;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Success message when exercise is manually categorized
  ///
  /// In en, this message translates to:
  /// **'\"{exerciseName}\" categorized as {muscleGroupName}'**
  String exerciseCategorizedSuccess(
    String exerciseName,
    String muscleGroupName,
  );

  /// Undo button label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Message shown when categorization is undone
  ///
  /// In en, this message translates to:
  /// **'Categorization removed'**
  String get categorizationUndone;

  /// Exercise editing coming soon message
  ///
  /// In en, this message translates to:
  /// **'Exercise editing coming soon!'**
  String get exerciseEditingComingSoon;

  /// Exercise replacement coming soon message
  ///
  /// In en, this message translates to:
  /// **'Exercise replacement coming soon!'**
  String get exerciseReplacementComingSoon;

  /// Error message when user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get errorUserNotAuthenticated;

  /// Error message when entity validation fails
  ///
  /// In en, this message translates to:
  /// **'Validation failed'**
  String get errorEntityValidationFailed;

  /// Error message when audio file is not found
  ///
  /// In en, this message translates to:
  /// **'Audio file not found'**
  String get errorAudioFileNotFound;

  /// Error message when achievement is not found
  ///
  /// In en, this message translates to:
  /// **'Achievement not found'**
  String get errorAchievementNotFound;

  /// Error message when registration fails
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get errorRegistrationFailed;

  /// Error message when sign in fails
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get errorSignInFailed;

  /// Error message when workout loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading workout: {error}'**
  String errorLoadingWorkout(String error);

  /// OR text separator between options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// Text asking if user already has an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Text asking if user doesn't have an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Back to login options button text
  ///
  /// In en, this message translates to:
  /// **'Back to options'**
  String get backToOptions;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Validation message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Smart timer feature preview label
  ///
  /// In en, this message translates to:
  /// **'Smart Timer'**
  String get featureSmartTimer;

  /// Live Activities feature preview label
  ///
  /// In en, this message translates to:
  /// **'Live Activities'**
  String get featureLiveActivities;

  /// Apple Health feature preview label
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get featureAppleHealth;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Start tracking your fitness journey'**
  String get startTrackingJourney;

  /// Quick registration section title
  ///
  /// In en, this message translates to:
  /// **'Register Quickly'**
  String get registerQuickly;

  /// Auto account creation explanation
  ///
  /// In en, this message translates to:
  /// **'The system will automatically create your account\nif it\'s your first time logging in'**
  String get autoAccountCreation;

  /// OR divider text between sections
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Name required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterYourName;

  /// Name required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// Name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Email required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// Invalid email validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// Password required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password required validation
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// Passwords mismatch validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Google sign up button alternative
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// Apple sign up button alternative
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get signUpWithApple;

  /// Already have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountPrompt;

  /// My workouts screen title
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get myWorkouts;

  /// Predefined workouts tab title
  ///
  /// In en, this message translates to:
  /// **'Predefined Workouts'**
  String get predefinedWorkouts;

  /// Empty state for custom templates
  ///
  /// In en, this message translates to:
  /// **'No custom templates'**
  String get noCustomTemplates;

  /// Empty state for predefined workouts
  ///
  /// In en, this message translates to:
  /// **'No predefined workouts'**
  String get noPredefinedWorkouts;

  /// Coming soon message for predefined workouts
  ///
  /// In en, this message translates to:
  /// **'Predefined workouts coming soon!'**
  String get predefinedWorkoutsComingSoon;

  /// Custom template badge
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customBadge;

  /// Dialog title for keeping workout active
  ///
  /// In en, this message translates to:
  /// **'Keep Workout Active?'**
  String get keepWorkoutActive;

  /// Dialog message for keeping workout active
  ///
  /// In en, this message translates to:
  /// **'Do you want to go back to Home and keep your workout running in the background?\\n\\nYou can return to continue your workout anytime.'**
  String get keepWorkoutActiveMessage;

  /// Go to home button
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// Snackbar message for paused workout
  ///
  /// In en, this message translates to:
  /// **'Workout paused - Continue anytime from Home'**
  String get workoutPausedContinue;

  /// Delete template confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteTemplateConfirm(String name);

  /// Delete warning message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteTemplateWarning;

  /// Rest timer label
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get timerRest;

  /// Customize workout subtitle
  ///
  /// In en, this message translates to:
  /// **'RPE, Timer, and more'**
  String get rpeTimerMore;

  /// Complete workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete this workout?'**
  String get completeWorkoutConfirm;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Go home button
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Error loading message
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String errorLoading(String error);

  /// JSON format title
  ///
  /// In en, this message translates to:
  /// **'JSON Format'**
  String get jsonFormat;

  /// JSON paste instruction
  ///
  /// In en, this message translates to:
  /// **'Paste your workout template JSON here'**
  String get pasteJsonHere;

  /// JSON placeholder example
  ///
  /// In en, this message translates to:
  /// **'Example: name, description, exercises array'**
  String get jsonPlaceholder;

  /// Import function redirect message
  ///
  /// In en, this message translates to:
  /// **'Use the import function in the template screen'**
  String get useImportFunction;

  /// Save as template dialog title
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplateTitle;

  /// Template name field label
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// Template name field hint
  ///
  /// In en, this message translates to:
  /// **'E.g. Push Day, Upper Body...'**
  String get templateNameHint;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Briefly describe this workout...'**
  String get descriptionHint;

  /// Template sync information
  ///
  /// In en, this message translates to:
  /// **'The template will be saved to Firebase and available on all your devices'**
  String get templateSyncInfo;

  /// Template name required validation
  ///
  /// In en, this message translates to:
  /// **'Enter a template name'**
  String get enterTemplateName;

  /// Saving to Firebase loading message
  ///
  /// In en, this message translates to:
  /// **'Saving to Firebase...'**
  String get savingToFirebase;

  /// Template saved success message
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" saved successfully!'**
  String templateSavedSuccess(String name);

  /// View button
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Template limit message
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of {max} private templates.'**
  String templateLimitReached(int max);

  /// Delete or upgrade suggestion
  ///
  /// In en, this message translates to:
  /// **'Delete an existing template or upgrade to Premium for more space.'**
  String get deleteOrUpgrade;

  /// Templates remaining warning
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} templates remaining in Free plan'**
  String templatesRemaining(int remaining);

  /// Custom template default description
  ///
  /// In en, this message translates to:
  /// **'Custom template'**
  String get customTemplate;

  /// Error saving message
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// Quota exceeded title
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get quotaExceeded;

  /// Delete or upgrade suggestion alternative
  ///
  /// In en, this message translates to:
  /// **'Delete existing templates or upgrade to Premium.'**
  String get deleteExistingOrUpgrade;

  /// Generating PDF loading message
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// PDF shared success message
  ///
  /// In en, this message translates to:
  /// **'PDF shared successfully!'**
  String get pdfSharedSuccess;

  /// Sharing error message
  ///
  /// In en, this message translates to:
  /// **'Sharing error: {error}'**
  String sharingError(String error);

  /// Preparing print loading message
  ///
  /// In en, this message translates to:
  /// **'Preparing print...'**
  String get preparingPrint;

  /// Print error message
  ///
  /// In en, this message translates to:
  /// **'Print error: {error}'**
  String printError(String error);

  /// Template function coming soon message
  ///
  /// In en, this message translates to:
  /// **'Use the template screen to create new templates'**
  String get templateUseFunctionComingSoon;

  /// Save template coming soon message
  ///
  /// In en, this message translates to:
  /// **'Save template function coming soon!'**
  String get saveTemplateFunctionComingSoon;

  /// Quick workout started message
  ///
  /// In en, this message translates to:
  /// **'Workout started quickly'**
  String get workoutStartedQuick;

  /// Quick workout default name
  ///
  /// In en, this message translates to:
  /// **'Quick Workout'**
  String get quickWorkoutName;

  /// Start workout menu item title
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkoutTitle;

  /// Start now action
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNowAction;

  /// Start exercise action
  ///
  /// In en, this message translates to:
  /// **'Start Exercise'**
  String get startExercise;

  /// Modify template action
  ///
  /// In en, this message translates to:
  /// **'Modify Template'**
  String get modifyTemplate;

  /// Add or remove exercises description
  ///
  /// In en, this message translates to:
  /// **'Add or remove exercises'**
  String get addOrRemoveExercises;

  /// Delete template action
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplateAction;

  /// Remove permanently description
  ///
  /// In en, this message translates to:
  /// **'Remove permanently'**
  String get removePermanently;

  /// Number of dropset stages
  ///
  /// In en, this message translates to:
  /// **'{count} stages'**
  String dropsetStages(int count);

  /// Dropset stage number
  ///
  /// In en, this message translates to:
  /// **'Stage {number}'**
  String dropsetStage(int number);

  /// Motivational message for first dropset stage
  ///
  /// In en, this message translates to:
  /// **'Get ready to drop the weight!'**
  String get dropsetGetReady;

  /// Motivational message for intermediate dropset stages
  ///
  /// In en, this message translates to:
  /// **'No rest! Reduce weight and go again!'**
  String get dropsetNoRest;

  /// Motivational message for last dropset stage
  ///
  /// In en, this message translates to:
  /// **'Last stage! Give it everything!'**
  String get dropsetLastStage;

  /// Weight change reminder
  ///
  /// In en, this message translates to:
  /// **'Reduce weight to {weight} kg NOW!'**
  String dropsetReduceWeightNow(String weight);

  /// Success message when dropset is complete
  ///
  /// In en, this message translates to:
  /// **'DropSet completed! 💪'**
  String get dropsetCompleted;

  /// Button to complete entire dropset
  ///
  /// In en, this message translates to:
  /// **'Complete DropSet'**
  String get completeDropset;

  /// Button to complete current stage
  ///
  /// In en, this message translates to:
  /// **'Complete Stage {number}'**
  String completeStage(int number);

  /// Cancel dropset confirmation title
  ///
  /// In en, this message translates to:
  /// **'Cancel DropSet?'**
  String get cancelDropset;

  /// Cancel dropset confirmation message
  ///
  /// In en, this message translates to:
  /// **'Your progress will not be saved. Are you sure?'**
  String get cancelDropsetMessage;

  /// Button to start dropset execution
  ///
  /// In en, this message translates to:
  /// **'Execute DropSet'**
  String get executeDropset;

  /// Button to start rest-pause execution
  ///
  /// In en, this message translates to:
  /// **'Execute Rest-Pause'**
  String get executeRestPause;

  /// Keep workout active dialog content
  ///
  /// In en, this message translates to:
  /// **'Do you want to go back to Home and keep your workout running in the background?\\n\\nYou can return to continue your workout anytime.'**
  String get keepWorkoutActiveContent;

  /// Delete template confirmation question
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteTemplateQuestion(String name);

  /// Cannot undo warning
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotUndo;

  /// Error label with placeholder
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// Template quota limit message
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of {max} private templates.'**
  String templateQuotaLimit(int max);

  /// Delete or upgrade suggestion
  ///
  /// In en, this message translates to:
  /// **'Delete an existing template or upgrade to Premium for more space.'**
  String get deleteExistingTemplateOrUpgrade;

  /// Templates remaining warning
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} templates remaining in Free plan'**
  String templatesRemainingWarning(int remaining);

  /// Custom template default description
  ///
  /// In en, this message translates to:
  /// **'Custom template'**
  String get customTemplateDescription;

  /// Template saved success message
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" saved successfully!'**
  String templateSavedSuccessfully(String name);

  /// Template deleted success message
  ///
  /// In en, this message translates to:
  /// **'Template \"{name}\" deleted'**
  String templateDeletedSuccessfully(String name);

  /// Error with message placeholder
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// PDF shared success message
  ///
  /// In en, this message translates to:
  /// **'PDF shared successfully!'**
  String get pdfSharedSuccessfully;

  /// Sharing error message
  ///
  /// In en, this message translates to:
  /// **'Sharing error: {error}'**
  String sharingErrorMessage(String error);

  /// Print error message
  ///
  /// In en, this message translates to:
  /// **'Print error: {error}'**
  String printErrorMessage(String error);

  /// Saving error message
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String savingErrorMessage(String error);

  /// Import function redirect message
  ///
  /// In en, this message translates to:
  /// **'Use the import function in the template screen'**
  String get useImportFunctionInTemplateScreen;

  /// Delete or upgrade alternative
  ///
  /// In en, this message translates to:
  /// **'Delete existing templates or upgrade to Premium.'**
  String get deleteExistingOrUpgradeToPremium;

  /// Remove permanently action
  ///
  /// In en, this message translates to:
  /// **'Remove permanently'**
  String get removePermanentlyAction;

  /// Start workout action
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkoutAction;

  /// Start workout description
  ///
  /// In en, this message translates to:
  /// **'Start immediately'**
  String get startWorkoutDescription;

  /// Template sync information
  ///
  /// In en, this message translates to:
  /// **'The template will be saved to Firebase and available on all your devices'**
  String get templateSyncInformation;

  /// Single exercise tab label
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get tabSingle;

  /// Advanced exercises tab label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get tabAdvanced;

  /// Superset tab label
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get tabSuperset;

  /// DropSet tab label
  ///
  /// In en, this message translates to:
  /// **'DropSet'**
  String get tabDropSet;

  /// Rest-Pause tab label
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause'**
  String get tabRestPause;

  /// Drop Set information card description
  ///
  /// In en, this message translates to:
  /// **'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.'**
  String get dropSetInfoCard;

  /// Rest-Pause information card description
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.'**
  String get restPauseInfoCard;

  /// Exercise name hint for drop set
  ///
  /// In en, this message translates to:
  /// **'e.g., Bicep Curl Drop Set'**
  String get exerciseNameHintBicepCurl;

  /// Exercise name hint for rest-pause
  ///
  /// In en, this message translates to:
  /// **'e.g., Bench Press Rest-Pause'**
  String get exerciseNameHintBenchPress;

  /// Drop Set stages section title
  ///
  /// In en, this message translates to:
  /// **'Drop Set Stages'**
  String get dropSetStagesTitle;

  /// Heavy stage label for drop sets
  ///
  /// In en, this message translates to:
  /// **'Stage 1 (Heavy)'**
  String get stageHeavy;

  /// Medium stage label for drop sets
  ///
  /// In en, this message translates to:
  /// **'Stage 2 (Medium)'**
  String get stageMedium;

  /// Light stage label for drop sets
  ///
  /// In en, this message translates to:
  /// **'Stage 3 (Light)'**
  String get stageLight;

  /// Add stage button for drop sets
  ///
  /// In en, this message translates to:
  /// **'Add Stage'**
  String get addStageButton;

  /// Notes hint for drop set
  ///
  /// In en, this message translates to:
  /// **'Weight drops, rest between stages, etc.'**
  String get notesHintWeightDrops;

  /// Notes hint for rest-pause
  ///
  /// In en, this message translates to:
  /// **'Form cues, progression strategy, etc.'**
  String get notesHintFormCues;

  /// Weight in kg label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// Target reps label
  ///
  /// In en, this message translates to:
  /// **'Target Reps'**
  String get targetRepsLabel;

  /// Rest period in seconds label
  ///
  /// In en, this message translates to:
  /// **'Rest Period (seconds)'**
  String get restPeriodSecondsLabel;

  /// Rest period hint text
  ///
  /// In en, this message translates to:
  /// **'10-15 seconds typical'**
  String get restPeriodSecondsHint;

  /// Max rest-pause sets label
  ///
  /// In en, this message translates to:
  /// **'Max Rest-Pause Sets'**
  String get maxRestPauseSetsLabel;

  /// Max sets hint text
  ///
  /// In en, this message translates to:
  /// **'3-4 typical'**
  String get maxRestPauseSetsHint;

  /// Add set button label
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSetLabel;

  /// Weight hint in kg
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightHintKg;

  /// Reps hint label
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsHintLabel;

  /// Prompt to create custom exercise
  ///
  /// In en, this message translates to:
  /// **'Can\'t find your exercise? Create a custom one'**
  String get customExercisePrompt;

  /// Custom exercise details instruction
  ///
  /// In en, this message translates to:
  /// **'Enter custom exercise details:'**
  String get customExerciseDetails;

  /// Exercise focus label
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusLabel;

  /// Success message for adding exercise
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} to workout'**
  String exerciseAddedToWorkout(String exerciseName);

  /// Success message for adding drop set
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} Drop Set to workout'**
  String exerciseAddedDropSet(String exerciseName);

  /// Success message for adding rest-pause
  ///
  /// In en, this message translates to:
  /// **'Added {exerciseName} Rest-Pause to workout'**
  String exerciseAddedRestPause(String exerciseName);

  /// Quick timer options section label
  ///
  /// In en, this message translates to:
  /// **'Quick Timer Options'**
  String get quickTimerOptions;

  /// Exercise updated success message
  ///
  /// In en, this message translates to:
  /// **'Exercise \"{exerciseName}\" updated'**
  String exerciseUpdated(String exerciseName);

  /// Timer label for snackbar
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerLabel;

  /// Error loading editor message
  ///
  /// In en, this message translates to:
  /// **'Error loading exercise editor'**
  String get errorLoadingEditor;

  /// Error opening editor modal message
  ///
  /// In en, this message translates to:
  /// **'Error opening exercise editor. Please try again.'**
  String get errorOpeningEditor;

  /// Error unable to edit exercise
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to edit this exercise'**
  String get errorUnableToEdit;

  /// Error updating exercise message
  ///
  /// In en, this message translates to:
  /// **'Error updating exercise. Please try again.'**
  String get errorUpdatingExercise;

  /// Exercise name validation error
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} cannot be empty'**
  String exerciseNameCannotBeEmpty(String exerciseName);

  /// Invalid rest time validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid rest time (1-3600 seconds)'**
  String get invalidRestTimeError;

  /// Invalid APRE base weight error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid APRE base weight'**
  String get invalidApreBaseWeight;

  /// Notes saved success message
  ///
  /// In en, this message translates to:
  /// **'Notes saved'**
  String get notesSavedMessage;

  /// Exercise completed with expand action
  ///
  /// In en, this message translates to:
  /// **'{exerciseName} completed! Tap to expand'**
  String exerciseCompletedTapToExpand(String exerciseName);

  /// Expand action label
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandLabel;

  /// User info when not logged in
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get settingsNotLoggedIn;

  /// Loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get settingsLoading;

  /// Error state
  ///
  /// In en, this message translates to:
  /// **'Error loading user'**
  String get settingsErrorLoadingUser;

  /// Default username
  ///
  /// In en, this message translates to:
  /// **'FitLog Pro User'**
  String get settingsGymBroUser;

  /// No email message
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get settingsNoEmail;

  /// Last updated label
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String settingsLastUpdated(Object date);

  /// Update profile button
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get settingsUpdateProfile;

  /// Accent color setting
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// Font size label
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSize;

  /// Small font
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsFontSizeSmall;

  /// Normal font
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsFontSizeNormal;

  /// Large font
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsFontSizeLarge;

  /// Workout section
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get settingsWorkoutTitle;

  /// Auto start timer
  ///
  /// In en, this message translates to:
  /// **'Auto-start Timer'**
  String get settingsAutoStartTimer;

  /// Auto timer desc
  ///
  /// In en, this message translates to:
  /// **'Start rest timer after completing set'**
  String get settingsAutoStartTimerDesc;

  /// Default rest time
  ///
  /// In en, this message translates to:
  /// **'Default Rest Time'**
  String get settingsDefaultRestTime;

  /// Advanced techniques
  ///
  /// In en, this message translates to:
  /// **'Advanced Techniques'**
  String get settingsAdvancedTechniques;

  /// Advanced tech desc
  ///
  /// In en, this message translates to:
  /// **'Show drop sets, supersets, etc.'**
  String get settingsAdvancedTechniquesDesc;

  /// Units and language
  ///
  /// In en, this message translates to:
  /// **'Units & Language'**
  String get settingsUnitsLanguage;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Weight units
  ///
  /// In en, this message translates to:
  /// **'Weight Units'**
  String get settingsWeightUnits;

  /// iOS features
  ///
  /// In en, this message translates to:
  /// **'iOS Features'**
  String get settingsIOSFeatures;

  /// Live activities
  ///
  /// In en, this message translates to:
  /// **'Live Activities'**
  String get settingsLiveActivities;

  /// Live activities desc
  ///
  /// In en, this message translates to:
  /// **'Show timer on lock screen & Dynamic Island'**
  String get settingsLiveActivitiesDesc;

  /// Health sync
  ///
  /// In en, this message translates to:
  /// **'Health App Sync'**
  String get settingsHealthAppSync;

  /// Health sync desc
  ///
  /// In en, this message translates to:
  /// **'Sync workouts to Apple Health'**
  String get settingsHealthAppSyncDesc;

  /// Audio feedback
  ///
  /// In en, this message translates to:
  /// **'Audio & Feedback'**
  String get settingsAudioFeedback;

  /// Sound effects
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// Sound effects desc
  ///
  /// In en, this message translates to:
  /// **'Play sounds for timer and completion'**
  String get settingsSoundEffectsDesc;

  /// Vibrations
  ///
  /// In en, this message translates to:
  /// **'Vibrations'**
  String get settingsVibrations;

  /// Vibrations desc
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback for interactions'**
  String get settingsVibrationsDesc;

  /// Test sounds tooltip
  ///
  /// In en, this message translates to:
  /// **'Test Sounds'**
  String get settingsTestSounds;

  /// Advanced section
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvancedTitle;

  /// Export settings
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get settingsExportSettings;

  /// Import settings
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get settingsImportSettings;

  /// Reset timer position
  ///
  /// In en, this message translates to:
  /// **'Reset Timer Position'**
  String get settingsResetTimerPosition;

  /// Reset timer desc
  ///
  /// In en, this message translates to:
  /// **'Reset draggable timer to default position'**
  String get settingsResetTimerPositionDesc;

  /// Migration completed
  ///
  /// In en, this message translates to:
  /// **'Migration completed or not needed'**
  String get settingsDataMigrationCompleted;

  /// Has migration data
  ///
  /// In en, this message translates to:
  /// **'You have data to migrate from previous version'**
  String get settingsMigrationHasData;

  /// Available label
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get settingsMigrationAvailable;

  /// Beta mode
  ///
  /// In en, this message translates to:
  /// **'Beta Mode'**
  String get settingsBetaMode;

  /// Beta enabled
  ///
  /// In en, this message translates to:
  /// **'Beta Mode enabled - All premium features unlocked!'**
  String get settingsBetaModeEnabled;

  /// Beta disabled
  ///
  /// In en, this message translates to:
  /// **'Beta Mode disabled'**
  String get settingsBetaModeDisabled;

  /// BETA label
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get settingsBetaModeLabel;

  /// Beta activated
  ///
  /// In en, this message translates to:
  /// **'🧪 Beta Mode activated - All premium features unlocked!'**
  String get settingsBetaModeActivated;

  /// Beta deactivated
  ///
  /// In en, this message translates to:
  /// **'Beta Mode deactivated'**
  String get settingsBetaModeDeactivated;

  /// Reset to defaults
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get settingsResetToDefaults;

  /// Account actions
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get settingsAccountActionsTitle;

  /// Sign out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// Choose language
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsChooseLanguage;

  /// English US
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get settingsEnglishUS;

  /// Italian IT
  ///
  /// In en, this message translates to:
  /// **'Italian (IT)'**
  String get settingsItalianIT;

  /// Weight units title
  ///
  /// In en, this message translates to:
  /// **'Weight Units'**
  String get settingsWeightUnitsTitle;

  /// Kilograms
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get settingsKilogramsKg;

  /// Metric system
  ///
  /// In en, this message translates to:
  /// **'Metric system'**
  String get settingsMetricSystem;

  /// Pounds
  ///
  /// In en, this message translates to:
  /// **'Pounds (lbs)'**
  String get settingsPoundsLbs;

  /// Imperial system
  ///
  /// In en, this message translates to:
  /// **'Imperial system'**
  String get settingsImperialSystem;

  /// Reset timer title
  ///
  /// In en, this message translates to:
  /// **'Reset Timer Position'**
  String get settingsResetTimerPositionTitle;

  /// Reset timer message
  ///
  /// In en, this message translates to:
  /// **'This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.'**
  String get settingsResetTimerPositionMessage;

  /// Reset position
  ///
  /// In en, this message translates to:
  /// **'Reset Position'**
  String get settingsResetPosition;

  /// Timer reset snackbar
  ///
  /// In en, this message translates to:
  /// **'Timer position reset to default'**
  String get settingsTimerPositionReset;

  /// Reset settings title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetSettingsTitle;

  /// Reset settings message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults? This cannot be undone.'**
  String get settingsResetSettingsMessage;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetSettingsButton;

  /// Sign out title
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOutTitle;

  /// Sign out message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutMessage;

  /// Export coming soon
  ///
  /// In en, this message translates to:
  /// **'Export functionality coming soon'**
  String get settingsExportComingSoon;

  /// Import coming soon
  ///
  /// In en, this message translates to:
  /// **'Import functionality coming soon'**
  String get settingsImportComingSoon;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get templateSearchPlaceholder;

  /// Debug banner
  ///
  /// In en, this message translates to:
  /// **'❌ WorkoutTemplatesScreen - Not seeing my templates here'**
  String get templateDebugNotSeeing;

  /// Templates count
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templateTemplatesCount;

  /// No popular templates
  ///
  /// In en, this message translates to:
  /// **'No popular templates yet'**
  String get templateNoTemplatesYet;

  /// Most used explanation
  ///
  /// In en, this message translates to:
  /// **'Most used templates will appear here'**
  String get templateMostUsedTemplatesWillAppear;

  /// No custom templates
  ///
  /// In en, this message translates to:
  /// **'No custom templates'**
  String get templateNoCustomTemplates;

  /// Create first template
  ///
  /// In en, this message translates to:
  /// **'Create your first custom template'**
  String get templateCreateFirstTemplate;

  /// No templates found
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get templateNoTemplatesFound;

  /// Sync status title
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get templateSyncStateTitle;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get templateSyncStatus;

  /// Last sync label
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get templateLastSync;

  /// Total templates
  ///
  /// In en, this message translates to:
  /// **'Total templates'**
  String get templateTotalTemplates;

  /// Offline changes
  ///
  /// In en, this message translates to:
  /// **'You have offline changes that will be synced on next connection.'**
  String get templateOfflineChanges;

  /// Sync now button
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get templateSyncNow;

  /// Sync completed
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get templateSyncCompleted;

  /// Delete template title
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get templateDeleteTitle;

  /// Delete message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String templateDeleteMessage(String name);

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get templateDeleteButton;

  /// Delete error
  ///
  /// In en, this message translates to:
  /// **'Error deleting template'**
  String get templateDeleteError;

  /// Start error
  ///
  /// In en, this message translates to:
  /// **'Error starting workout'**
  String get templateStartError;

  /// Day label
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get templateDay;

  /// Button to copy weight and reps from the previous set
  ///
  /// In en, this message translates to:
  /// **'Copy Previous Set'**
  String get copyPreviousSet;

  /// Weekly routine title
  ///
  /// In en, this message translates to:
  /// **'Weekly Routine'**
  String get routineWeeklyRoutine;

  /// My routine title
  ///
  /// In en, this message translates to:
  /// **'My Routine'**
  String get routineMyRoutine;

  /// Add template to routine action
  ///
  /// In en, this message translates to:
  /// **'Add to Routine'**
  String get routineAddToRoutine;

  /// Select day dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get routineSelectDay;

  /// Select day dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose which day(s) to schedule this workout'**
  String get routineSelectDaySubtitle;

  /// Monday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get routineMonday;

  /// Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get routineTuesday;

  /// Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get routineWednesday;

  /// Thursday
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get routineThursday;

  /// Friday
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get routineFriday;

  /// Saturday
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get routineSaturday;

  /// Sunday
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get routineSunday;

  /// Day already scheduled warning
  ///
  /// In en, this message translates to:
  /// **'This day already has a template'**
  String get routineDayAlreadyScheduled;

  /// Replace template confirmation title
  ///
  /// In en, this message translates to:
  /// **'Replace template?'**
  String get routineReplaceTemplate;

  /// Replace template confirmation message
  ///
  /// In en, this message translates to:
  /// **'Day {day} already has \"{currentTemplate}\" scheduled. Replace it with \"{newTemplate}\"?'**
  String routineReplaceTemplateMessage(
    String day,
    String currentTemplate,
    String newTemplate,
  );

  /// No template on this day
  ///
  /// In en, this message translates to:
  /// **'No template scheduled'**
  String get routineNoTemplateScheduled;

  /// Rest day label
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get routineRestDay;

  /// Quick start workout button
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get routineQuickStart;

  /// Template added success message
  ///
  /// In en, this message translates to:
  /// **'Template added to {day}'**
  String routineTemplateAddedSuccess(String day);

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No workouts scheduled yet'**
  String get routineNoWorkoutsScheduled;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start scheduling your weekly workouts'**
  String get routineStartScheduling;

  /// Empty state instruction
  ///
  /// In en, this message translates to:
  /// **'Tap a template and select \'Add to Routine\''**
  String get routineTapToAdd;

  /// Title for change template dialog
  ///
  /// In en, this message translates to:
  /// **'Change Workout Template'**
  String get routineChangeTemplate;

  /// Remove template from day action
  ///
  /// In en, this message translates to:
  /// **'Remove from day'**
  String get routineRemoveFromDay;

  /// Clear all scheduled templates
  ///
  /// In en, this message translates to:
  /// **'Clear All Days'**
  String get routineClearAllDays;

  /// Clear all confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all scheduled templates?'**
  String get routineClearAllDaysConfirm;

  /// Number of workouts scheduled
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{workout} other{workouts}} scheduled'**
  String routineWorkoutsScheduled(int count);

  /// Number of rest days
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{rest day} other{rest days}}'**
  String routineRestDays(int count);

  /// Number of exercises in template
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{exercise} other{exercises}}'**
  String routineExercises(int count);

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get routineSaveChanges;

  /// Discard changes button
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get routineDiscardChanges;

  /// Subtitle for routine card on home screen
  ///
  /// In en, this message translates to:
  /// **'View and manage your routine'**
  String get routineViewAndManage;

  /// Question asking user to provide feedback
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with this step'**
  String get feedbackQuestion;

  /// Helpful feedback button
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get feedbackHelpful;

  /// Not helpful feedback button
  ///
  /// In en, this message translates to:
  /// **'Not Helpful'**
  String get feedbackNotHelpful;

  /// Thank you message after feedback submission
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedbackThankYou;

  /// Confirmation that feedback was saved
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted'**
  String get feedbackSubmitted;

  /// Message when user tries to rate insight twice
  ///
  /// In en, this message translates to:
  /// **'You\'ve already rated this insight'**
  String get feedbackAlreadyGiven;

  /// Warning shown when insight is based on anomalous data
  ///
  /// In en, this message translates to:
  /// **'⚠️ Based on questionable data'**
  String get dataQualityWarning;

  /// Badge for insights with low confidence
  ///
  /// In en, this message translates to:
  /// **'Low data quality'**
  String get dataQualityLow;

  /// Number of anomalies affecting this insight
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 data issue detected} other{{count} data issues detected}}'**
  String anomaliesDetected(int count);

  /// Button to view detected anomalies
  ///
  /// In en, this message translates to:
  /// **'View data issues'**
  String get viewAnomalies;

  /// Anomaly type: weight exceeds realistic limits
  ///
  /// In en, this message translates to:
  /// **'Impossible weight detected'**
  String get anomalyImpossibleWeight;

  /// Anomaly type: large weight increase between sessions
  ///
  /// In en, this message translates to:
  /// **'Extreme weight jump detected'**
  String get anomalyExtremeWeightJump;

  /// Anomaly type: negative weight or reps
  ///
  /// In en, this message translates to:
  /// **'Negative values detected'**
  String get anomalyNegativeValues;

  /// Anomaly type: workout date in the future
  ///
  /// In en, this message translates to:
  /// **'Future date detected'**
  String get anomalyFutureDate;

  /// Button to correct anomalous data
  ///
  /// In en, this message translates to:
  /// **'Correct data'**
  String get correctData;

  /// Button to dismiss data anomaly warning
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAnomaly;

  /// Title for feedback history screen
  ///
  /// In en, this message translates to:
  /// **'My Feedback'**
  String get myFeedback;

  /// Header for feedback history list
  ///
  /// In en, this message translates to:
  /// **'Feedback History'**
  String get feedbackHistory;

  /// Button to open feedback history
  ///
  /// In en, this message translates to:
  /// **'View My Feedback'**
  String get viewMyFeedback;

  /// Message when user has not given any feedback
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get noFeedbackYet;

  /// Subtitle for empty feedback state
  ///
  /// In en, this message translates to:
  /// **'Start rating insights to help improve AI Coach recommendations'**
  String get startRatingInsights;

  /// Label for feedback that was marked helpful
  ///
  /// In en, this message translates to:
  /// **'Rated helpful'**
  String get ratedHelpful;

  /// Label for feedback that was marked not helpful
  ///
  /// In en, this message translates to:
  /// **'Rated not helpful'**
  String get ratedNotHelpful;

  /// Prefix for insight type in feedback history
  ///
  /// In en, this message translates to:
  /// **'Feedback on'**
  String get feedbackOn;

  /// Routine editor: routineEditorTitle
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get routineEditorTitle;

  /// Routine editor: routineEditorEditTitle
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get routineEditorEditTitle;

  /// Routine editor: routineStepInfo
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get routineStepInfo;

  /// Routine editor: routineStepPattern
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get routineStepPattern;

  /// Routine editor: routineStepReview
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get routineStepReview;

  /// Routine editor: routinePatternChooseTitle
  ///
  /// In en, this message translates to:
  /// **'Choose Your Pattern'**
  String get routinePatternChooseTitle;

  /// Routine editor: routinePatternChooseDescription
  ///
  /// In en, this message translates to:
  /// **'Select a training split that fits your goals'**
  String get routinePatternChooseDescription;

  /// Routine editor: routinePatternPreset
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get routinePatternPreset;

  /// Routine editor: routinePatternCustom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get routinePatternCustom;

  /// Routine editor: routinePatternPopular
  ///
  /// In en, this message translates to:
  /// **'Popular Patterns'**
  String get routinePatternPopular;

  /// Routine editor: routinePatternWorkouts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}}'**
  String routinePatternWorkouts(num count);

  /// Routine editor: routinePatternRest
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rest} other{{count} rest}}'**
  String routinePatternRest(num count);

  /// Routine editor: customPatternBuilderTitle
  ///
  /// In en, this message translates to:
  /// **'Custom Pattern Builder'**
  String get customPatternBuilderTitle;

  /// Routine editor: customPatternBuilderDescription
  ///
  /// In en, this message translates to:
  /// **'Build your own workout schedule'**
  String get customPatternBuilderDescription;

  /// Routine editor: customPatternYourSchedule
  ///
  /// In en, this message translates to:
  /// **'Your Schedule ({count} days)'**
  String customPatternYourSchedule(int count);

  /// Routine editor: customPatternAddWorkout
  ///
  /// In en, this message translates to:
  /// **'Add Workout'**
  String get customPatternAddWorkout;

  /// Routine editor: customPatternAddRest
  ///
  /// In en, this message translates to:
  /// **'Add Rest Day'**
  String get customPatternAddRest;

  /// Routine editor: customPatternEmptyWarning
  ///
  /// In en, this message translates to:
  /// **'Add at least one workout day to continue'**
  String get customPatternEmptyWarning;

  /// Routine editor: customPatternAddWorkoutDialogTitle
  ///
  /// In en, this message translates to:
  /// **'Add Workout Day'**
  String get customPatternAddWorkoutDialogTitle;

  /// Routine editor: customPatternWorkoutNameLabel
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get customPatternWorkoutNameLabel;

  /// Routine editor: customPatternWorkoutNameHint
  ///
  /// In en, this message translates to:
  /// **'e.g., Push, Pull, Legs, Upper, Lower'**
  String get customPatternWorkoutNameHint;

  /// Routine editor: customPatternDayNumber
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String customPatternDayNumber(int number);

  /// Routine editor: customPatternRestDay
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get customPatternRestDay;

  /// Routine editor: customPatternRemoveDay
  ///
  /// In en, this message translates to:
  /// **'Remove day'**
  String get customPatternRemoveDay;

  /// Routine editor: customPatternSelectTemplate
  ///
  /// In en, this message translates to:
  /// **'Select Workout Template'**
  String get customPatternSelectTemplate;

  /// Routine editor: customPatternNoTemplates
  ///
  /// In en, this message translates to:
  /// **'No workout templates available. Create templates first.'**
  String get customPatternNoTemplates;

  /// Routine editor: routineButtonBack
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get routineButtonBack;

  /// Routine editor: routineButtonNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get routineButtonNext;

  /// Routine editor: routineButtonCreate
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get routineButtonCreate;

  /// Routine editor: routineErrorIncomplete
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get routineErrorIncomplete;

  /// Routine editor: routineErrorNoPattern
  ///
  /// In en, this message translates to:
  /// **'Please select a pattern'**
  String get routineErrorNoPattern;

  /// Routine editor: routineSuccessCreated
  ///
  /// In en, this message translates to:
  /// **'Routine \"{name}\" created successfully! 🎉'**
  String routineSuccessCreated(String name);

  /// Routine editor: routineErrorCreateFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to create routine'**
  String get routineErrorCreateFailed;

  /// Routine editor: routineDiscardTitle
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get routineDiscardTitle;

  /// Routine editor: routineDiscardMessage
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost if you go back now.'**
  String get routineDiscardMessage;

  /// Error message when exercise GIF/image fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get errorLoadingImage;

  /// Hint message in fullscreen view to close by tapping
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to close'**
  String get tapAnywhereToClose;

  /// Routine onboarding: Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get routineOnboardingSkip;

  /// Routine onboarding: Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get routineOnboardingBack;

  /// Routine onboarding: Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get routineOnboardingNext;

  /// Routine onboarding: Get started button on last page
  ///
  /// In en, this message translates to:
  /// **'Get Started! 🚀'**
  String get routineOnboardingGetStarted;

  /// Routine onboarding: Welcome page title
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nRoutine Center! 🏋️'**
  String get routineOnboardingWelcomeTitle;

  /// Routine onboarding: Welcome page subtitle
  ///
  /// In en, this message translates to:
  /// **'Your personal training plan manager.\nLet\'s learn how to use it!'**
  String get routineOnboardingWelcomeSubtitle;

  /// Routine onboarding: What is page title
  ///
  /// In en, this message translates to:
  /// **'What is a Routine? 🤔'**
  String get routineOnboardingWhatIsTitle;

  /// Routine onboarding: What is page description
  ///
  /// In en, this message translates to:
  /// **'A routine is a structured training plan with:'**
  String get routineOnboardingWhatIsDescription;

  /// Routine onboarding: Feature - scheduled workouts
  ///
  /// In en, this message translates to:
  /// **'Scheduled Workout Days'**
  String get routineOnboardingFeatureScheduled;

  /// Routine onboarding: Feature - scheduled workouts description
  ///
  /// In en, this message translates to:
  /// **'Plan your training weeks in advance'**
  String get routineOnboardingFeatureScheduledDesc;

  /// Routine onboarding: Feature - workout templates
  ///
  /// In en, this message translates to:
  /// **'Specific Workout Templates'**
  String get routineOnboardingFeatureTemplates;

  /// Routine onboarding: Feature - workout templates description
  ///
  /// In en, this message translates to:
  /// **'Assign exercises to each day'**
  String get routineOnboardingFeatureTemplatesDesc;

  /// Routine onboarding: Feature - automatic progression
  ///
  /// In en, this message translates to:
  /// **'Automatic Progression'**
  String get routineOnboardingFeatureProgression;

  /// Routine onboarding: Feature - automatic progression description
  ///
  /// In en, this message translates to:
  /// **'Your plan repeats automatically'**
  String get routineOnboardingFeatureProgressionDesc;

  /// Routine onboarding: Feature - progress tracking
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get routineOnboardingFeatureTracking;

  /// Routine onboarding: Feature - progress tracking description
  ///
  /// In en, this message translates to:
  /// **'See your consistency over time'**
  String get routineOnboardingFeatureTrackingDesc;

  /// Routine onboarding: How it works page title
  ///
  /// In en, this message translates to:
  /// **'How It Works ⚙️'**
  String get routineOnboardingHowItWorksTitle;

  /// Routine onboarding: Step 1 title
  ///
  /// In en, this message translates to:
  /// **'Create Your Routine'**
  String get routineOnboardingStep1Title;

  /// Routine onboarding: Step 1 description
  ///
  /// In en, this message translates to:
  /// **'Name it and choose training pattern\n(e.g., Push/Pull/Legs)'**
  String get routineOnboardingStep1Desc;

  /// Routine onboarding: Step 2 title
  ///
  /// In en, this message translates to:
  /// **'Assign Workouts'**
  String get routineOnboardingStep2Title;

  /// Routine onboarding: Step 2 description
  ///
  /// In en, this message translates to:
  /// **'Select workout templates for each training day'**
  String get routineOnboardingStep2Desc;

  /// Routine onboarding: Step 3 title
  ///
  /// In en, this message translates to:
  /// **'Follow & Track'**
  String get routineOnboardingStep3Title;

  /// Routine onboarding: Step 3 description
  ///
  /// In en, this message translates to:
  /// **'Complete workouts and watch your progress grow!'**
  String get routineOnboardingStep3Desc;

  /// Routine onboarding: Benefits page title
  ///
  /// In en, this message translates to:
  /// **'Why Use Routines? 💪'**
  String get routineOnboardingBenefitsTitle;

  /// Routine onboarding: Benefit 1 title
  ///
  /// In en, this message translates to:
  /// **'Stay Consistent'**
  String get routineOnboardingBenefit1Title;

  /// Routine onboarding: Benefit 1 description
  ///
  /// In en, this message translates to:
  /// **'No more \"what should I train today?\"'**
  String get routineOnboardingBenefit1Desc;

  /// Routine onboarding: Benefit 2 title
  ///
  /// In en, this message translates to:
  /// **'See Progress'**
  String get routineOnboardingBenefit2Title;

  /// Routine onboarding: Benefit 2 description
  ///
  /// In en, this message translates to:
  /// **'Track completion rate and streaks'**
  String get routineOnboardingBenefit2Desc;

  /// Routine onboarding: Benefit 3 title
  ///
  /// In en, this message translates to:
  /// **'Smart Recovery'**
  String get routineOnboardingBenefit3Title;

  /// Routine onboarding: Benefit 3 description
  ///
  /// In en, this message translates to:
  /// **'Miss a workout? Reschedule it easily'**
  String get routineOnboardingBenefit3Desc;

  /// Routine onboarding: Ready CTA on benefits page
  ///
  /// In en, this message translates to:
  /// **'Ready to create your first routine?'**
  String get routineOnboardingReadyCTA;

  /// Routine Center title on home screen
  ///
  /// In en, this message translates to:
  /// **'Routine Center'**
  String get routineCenter;

  /// Routine Center description on home screen
  ///
  /// In en, this message translates to:
  /// **'Multi-period routines with smart tracking'**
  String get routineCenterDescription;

  /// Basic info step title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get routineBasicInfoTitle;

  /// Basic info step subtitle
  ///
  /// In en, this message translates to:
  /// **'Set up the foundation of your routine'**
  String get routineBasicInfoSubtitle;

  /// Routine name field label
  ///
  /// In en, this message translates to:
  /// **'Routine Name *'**
  String get routineNameLabel;

  /// Routine name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Summer Shred 2025'**
  String get routineNameHint;

  /// Routine name required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get routineNameRequired;

  /// Routine name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get routineNameMinLength;

  /// Routine description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get routineDescriptionLabel;

  /// Routine description field hint
  ///
  /// In en, this message translates to:
  /// **'Add notes about this routine...'**
  String get routineDescriptionHint;

  /// Routine type section label
  ///
  /// In en, this message translates to:
  /// **'Routine Type'**
  String get routineTypeLabel;

  /// Weekly routine type
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get routineTypeWeekly;

  /// Weekly routine duration
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get routineTypeWeeklyDuration;

  /// Monthly routine type
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get routineTypeMonthly;

  /// Monthly routine duration
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get routineTypeMonthlyDuration;

  /// Bimonthly routine type
  ///
  /// In en, this message translates to:
  /// **'Bimonthly'**
  String get routineTypeBimonthly;

  /// Bimonthly routine duration
  ///
  /// In en, this message translates to:
  /// **'60 days'**
  String get routineTypeBimonthlyDuration;

  /// Semester routine type
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get routineTypeSemester;

  /// Semester routine duration
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get routineTypeSemesterDuration;

  /// Custom routine type
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get routineTypeCustom;

  /// Custom routine duration
  ///
  /// In en, this message translates to:
  /// **'Any duration'**
  String get routineTypeCustomDuration;

  /// Duration section label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get routineDurationLabel;

  /// Start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get routineStartDateLabel;

  /// End date field label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get routineEndDateLabel;

  /// Duration in weeks
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week} other{{weeks} weeks}}'**
  String routineDurationWeeks(int weeks);

  /// Duration in days
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String routineDurationDays(int days);

  /// Duration info label
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String routineDurationInfo(String duration);

  /// Pattern name: 1 workout 1 rest
  ///
  /// In en, this message translates to:
  /// **'1 Workout + 1 Rest'**
  String get routinePatternOneWorkoutOneRest;

  /// Pattern description: 1 workout 1 rest
  ///
  /// In en, this message translates to:
  /// **'1 training day followed by 1 rest day'**
  String get routinePatternOneWorkoutOneRestDesc;

  /// Pattern name: 2 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'2 Workouts + 1 Rest'**
  String get routinePatternTwoWorkoutsOneRest;

  /// Pattern description: 2 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'2 training days followed by 1 rest day'**
  String get routinePatternTwoWorkoutsOneRestDesc;

  /// Pattern name: 3 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'3 Workouts + 1 Rest'**
  String get routinePatternThreeWorkoutsOneRest;

  /// Pattern description: 3 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'3 training days followed by 1 rest day'**
  String get routinePatternThreeWorkoutsOneRestDesc;

  /// Pattern name: 3 workouts 2 rest
  ///
  /// In en, this message translates to:
  /// **'3 Workouts + 2 Rest'**
  String get routinePatternThreeWorkoutsTwoRest;

  /// Pattern description: 3 workouts 2 rest
  ///
  /// In en, this message translates to:
  /// **'3 training days with 2 rest days per week'**
  String get routinePatternThreeWorkoutsTwoRestDesc;

  /// Pattern name: 4 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'4 Workouts + 1 Rest'**
  String get routinePatternFourWorkoutsOneRest;

  /// Pattern description: 4 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'4 training days followed by 1 rest day'**
  String get routinePatternFourWorkoutsOneRestDesc;

  /// Pattern name: 4 workouts 3 rest
  ///
  /// In en, this message translates to:
  /// **'4 Workouts + 3 Rest'**
  String get routinePatternFourWorkoutsThreeRest;

  /// Pattern description: 4 workouts 3 rest
  ///
  /// In en, this message translates to:
  /// **'4 training days with 3 rest days per week'**
  String get routinePatternFourWorkoutsThreeRestDesc;

  /// Pattern name: 5 workouts 2 rest
  ///
  /// In en, this message translates to:
  /// **'5 Workouts + 2 Rest'**
  String get routinePatternFiveWorkoutsTwoRest;

  /// Pattern description: 5 workouts 2 rest
  ///
  /// In en, this message translates to:
  /// **'5 training days followed by 2 rest days'**
  String get routinePatternFiveWorkoutsTwoRestDesc;

  /// Pattern name: 6 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'6 Workouts + 1 Rest'**
  String get routinePatternSixWorkoutsOneRest;

  /// Pattern description: 6 workouts 1 rest
  ///
  /// In en, this message translates to:
  /// **'6 training days followed by 1 rest day'**
  String get routinePatternSixWorkoutsOneRestDesc;

  /// Calendar preview title
  ///
  /// In en, this message translates to:
  /// **'Calendar Preview'**
  String get routineCalendarPreview;

  /// Calendar preview subtitle
  ///
  /// In en, this message translates to:
  /// **'How your pattern looks on the calendar'**
  String get routineCalendarPreviewSubtitle;

  /// More days indicator
  ///
  /// In en, this message translates to:
  /// **'... and {count} more {count, plural, =1{day} other{days}}'**
  String routineAndMoreDays(int count);

  /// Total workouts in period
  ///
  /// In en, this message translates to:
  /// **'Total: {count} {count, plural, =1{workout} other{workouts}}'**
  String routineTotalWorkouts(int count);

  /// Total rest days in period
  ///
  /// In en, this message translates to:
  /// **'Total: {count} {count, plural, =1{rest day} other{rest days}}'**
  String routineTotalRestDays(int count);

  /// Workout days label
  ///
  /// In en, this message translates to:
  /// **'Workout Days'**
  String get routineWorkoutDayLabel;

  /// Rest days label
  ///
  /// In en, this message translates to:
  /// **'Rest Days'**
  String get routineRestDayLabel;

  /// Total days label
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get routineTotalDaysLabel;

  /// Monday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get routineWeekdayMonday;

  /// Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get routineWeekdayTuesday;

  /// Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get routineWeekdayWednesday;

  /// Thursday
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get routineWeekdayThursday;

  /// Friday
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get routineWeekdayFriday;

  /// Saturday
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get routineWeekdaySaturday;

  /// Sunday
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get routineWeekdaySunday;

  /// Workout count text
  ///
  /// In en, this message translates to:
  /// **'{count} workout{count, plural, =1{} other{s}}'**
  String routineWorkoutCount(int count);

  /// Rest count text
  ///
  /// In en, this message translates to:
  /// **'{count} rest'**
  String routineRestCount(int count);

  /// Template rotation step title
  ///
  /// In en, this message translates to:
  /// **'Rotation Order'**
  String get routineRotationTitle;

  /// Template rotation step subtitle
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder how templates will rotate across your workout days'**
  String get routineRotationSubtitle;

  /// Number of templates selected
  ///
  /// In en, this message translates to:
  /// **'{count} template{count, plural, =1{} other{s}} selected'**
  String routineTemplatesSelected(int count);

  /// Distribution preview title
  ///
  /// In en, this message translates to:
  /// **'Distribution Preview'**
  String get routineDistributionPreview;

  /// First N days preview label
  ///
  /// In en, this message translates to:
  /// **'First {shown} days (total: {total} days)'**
  String routineFirstDaysPreview(int shown, int total);

  /// More days indicator
  ///
  /// In en, this message translates to:
  /// **'... and {count} more {count, plural, =1{day} other{days}}'**
  String routineMoreDays(int count);

  /// No templates selected title
  ///
  /// In en, this message translates to:
  /// **'No Templates Selected'**
  String get routineNoTemplatesSelected;

  /// No templates selected message
  ///
  /// In en, this message translates to:
  /// **'Go back to the previous step and select at least one workout template'**
  String get routineNoTemplatesMessage;

  /// No pattern selected error
  ///
  /// In en, this message translates to:
  /// **'No pattern selected'**
  String get routineNoPatternSelected;

  /// Error loading message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String routineErrorLoading(String error);

  /// Template selection step title
  ///
  /// In en, this message translates to:
  /// **'Select Workout Templates'**
  String get routineSelectionTitle;

  /// Template selection step subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose templates to rotate automatically across workout days'**
  String get routineSelectionSubtitle;

  /// Available templates label
  ///
  /// In en, this message translates to:
  /// **'Available Templates'**
  String get routineAvailableTemplates;

  /// Selected count badge
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String routineSelected(int count);

  /// Info about next step
  ///
  /// In en, this message translates to:
  /// **'In the next step, you\'ll arrange the order in which these templates rotate'**
  String get routineNextStepInfo;

  /// No templates empty state title
  ///
  /// In en, this message translates to:
  /// **'No Workout Templates Yet'**
  String get routineNoTemplatesYet;

  /// No templates empty state message
  ///
  /// In en, this message translates to:
  /// **'You need workout templates to create a routine.\nChoose one of the options below to continue.'**
  String get routineNeedTemplatesMessage;

  /// Message explaining users need to create templates first
  ///
  /// In en, this message translates to:
  /// **'Before creating a routine, you need to create workout templates with exercises first.'**
  String get routineCreateTemplatesFirst;

  /// Workflow section title
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get routineWorkflowTitle;

  /// First step in routine workflow
  ///
  /// In en, this message translates to:
  /// **'Go to \'My Templates\' and create workout templates with exercises'**
  String get routineWorkflowStep1;

  /// Second step in routine workflow
  ///
  /// In en, this message translates to:
  /// **'Return here and select your templates for the routine'**
  String get routineWorkflowStep2;

  /// Third step in routine workflow
  ///
  /// In en, this message translates to:
  /// **'Configure rotation and complete your routine setup'**
  String get routineWorkflowStep3;

  /// Popular templates option title
  ///
  /// In en, this message translates to:
  /// **'Popular Templates'**
  String get routinePopularTemplates;

  /// Popular templates option description
  ///
  /// In en, this message translates to:
  /// **'Start with proven workout plans'**
  String get routinePopularTemplatesDesc;

  /// Import popular templates button
  ///
  /// In en, this message translates to:
  /// **'Import Popular Templates'**
  String get routineImportPopularTemplates;

  /// Custom template option title
  ///
  /// In en, this message translates to:
  /// **'Custom Template'**
  String get routineCustomTemplate;

  /// Custom template option description
  ///
  /// In en, this message translates to:
  /// **'Design your own workout plan'**
  String get routineCustomTemplateDesc;

  /// Create first template button
  ///
  /// In en, this message translates to:
  /// **'Create First Template'**
  String get routineCreateFirstTemplate;

  /// Navigating to template creator message
  ///
  /// In en, this message translates to:
  /// **'Navigating to template creator... 🏗️'**
  String get routineNavigatingToCreator;

  /// Select templates dialog message
  ///
  /// In en, this message translates to:
  /// **'Select the templates you want to import'**
  String get routineSelectTemplatesDialog;

  /// Select templates button (disabled state)
  ///
  /// In en, this message translates to:
  /// **'Select templates'**
  String get routineSelectTemplatesButton;

  /// Import button with count
  ///
  /// In en, this message translates to:
  /// **'Import ({count})'**
  String routineImportCount(int count);

  /// OR divider text
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get routineOr;

  /// Error loading templates
  ///
  /// In en, this message translates to:
  /// **'Error loading templates'**
  String get routineErrorLoadingTemplates;

  /// Success message when routine is created as inactive
  ///
  /// In en, this message translates to:
  /// **'Routine \"{name}\" created! Go to Routine Center to activate it.'**
  String routineSuccessCreatedInactive(String name);

  /// Title when no routine is active in analytics
  ///
  /// In en, this message translates to:
  /// **'No Active Routine'**
  String get routineAnalyticsNoActiveRoutine;

  /// Description when no routine is active
  ///
  /// In en, this message translates to:
  /// **'Create and activate a routine to see analytics here'**
  String get routineAnalyticsNoActiveRoutineDesc;

  /// Button to create a routine
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get routineAnalyticsCreateRoutine;

  /// Error title for analytics
  ///
  /// In en, this message translates to:
  /// **'Error Loading Analytics'**
  String get routineAnalyticsErrorLoading;

  /// Subtitle for active routine card
  ///
  /// In en, this message translates to:
  /// **'Active Routine Analytics'**
  String get routineAnalyticsActiveRoutine;

  /// Section title for KPI metrics
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get routineAnalyticsPerformanceMetrics;

  /// Adherence metric label
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get routineAnalyticsAdherence;

  /// Skip rate metric label
  ///
  /// In en, this message translates to:
  /// **'Skip Rate'**
  String get routineAnalyticsSkipRate;

  /// Recovery metric label
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get routineAnalyticsRecovery;

  /// Average gap metric label
  ///
  /// In en, this message translates to:
  /// **'Avg Gap'**
  String get routineAnalyticsAvgGap;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get routineAnalyticsDays;

  /// Skipped label
  ///
  /// In en, this message translates to:
  /// **'skipped'**
  String get routineAnalyticsSkipped;

  /// Recovered label
  ///
  /// In en, this message translates to:
  /// **'recovered'**
  String get routineAnalyticsRecovered;

  /// Between workouts label
  ///
  /// In en, this message translates to:
  /// **'between workouts'**
  String get routineAnalyticsBetweenWorkouts;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get routineAnalyticsCurrentStreak;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get routineAnalyticsBestStreak;

  /// Insights section title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get routineAnalyticsInsights;

  /// Template distribution section title
  ///
  /// In en, this message translates to:
  /// **'Template Distribution'**
  String get routineAnalyticsTemplateDistribution;

  /// Weekly pattern section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Pattern'**
  String get routineAnalyticsWeeklyPattern;

  /// Weekly trend chart title
  ///
  /// In en, this message translates to:
  /// **'Weekly Adherence Trend'**
  String get routineAnalyticsWeeklyTrend;

  /// Placeholder for chart
  ///
  /// In en, this message translates to:
  /// **'Chart visualization coming soon'**
  String get routineAnalyticsChartComingSoon;

  /// Routine tab label
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// Prompt asking user to rate questionnaire step
  ///
  /// In en, this message translates to:
  /// **'How was this step?'**
  String get feedbackPrompt;

  /// Label for 1-star rating (poor)
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get feedbackPoor;

  /// Label for 5-star rating (excellent)
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get feedbackExcellent;

  /// Title for stale profile banner
  ///
  /// In en, this message translates to:
  /// **'Update Your Fitness Profile'**
  String get staleProfileTitle;

  /// Subtitle when profile is 30-59 days old
  ///
  /// In en, this message translates to:
  /// **'Your profile hasn\'t been updated in {days} days. Update it for more accurate suggestions!'**
  String staleProfileSubtitle1Month(int days);

  /// Subtitle when profile is 2-5 months old
  ///
  /// In en, this message translates to:
  /// **'Your profile is {months} months old. Time to update for better suggestions!'**
  String staleProfileSubtitleMonths(int months);

  /// Subtitle when profile is 6+ months old
  ///
  /// In en, this message translates to:
  /// **'Your profile hasn\'t been updated in {months} months! Update now for accurate suggestions.'**
  String staleProfileSubtitleManyMonths(int months);

  /// Button text to update profile
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get staleProfileUpdateButton;

  /// Exercise progress feature title
  ///
  /// In en, this message translates to:
  /// **'Exercise Progress'**
  String get exerciseProgress;

  /// Subtitle for exercise progress card describing functionality
  ///
  /// In en, this message translates to:
  /// **'Track your exercise gains'**
  String get trackExerciseGrowth;

  /// Exercise progress screen title
  ///
  /// In en, this message translates to:
  /// **'Exercise Progress'**
  String get exerciseProgressTitle;

  /// Placeholder for exercise search field
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercisesPlaceholder;

  /// Weight progression chart title
  ///
  /// In en, this message translates to:
  /// **'Weight Progression'**
  String get weightProgression;

  /// Reps progression chart title
  ///
  /// In en, this message translates to:
  /// **'Reps Progression'**
  String get repsProgression;

  /// RPE/Effort progression chart title
  ///
  /// In en, this message translates to:
  /// **'Effort Progression'**
  String get effortProgression;

  /// Personal record full label
  ///
  /// In en, this message translates to:
  /// **'Personal Record'**
  String get personalRecord;

  /// Average weight label
  ///
  /// In en, this message translates to:
  /// **'Avg Weight'**
  String get averageWeight;

  /// Average RPE label
  ///
  /// In en, this message translates to:
  /// **'Avg RPE'**
  String get averageRPE;

  /// Migration stat label
  ///
  /// In en, this message translates to:
  /// **'Total Sessions'**
  String get totalSessions;

  /// Exercise statistics section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Statistics'**
  String get exerciseStats;

  /// Progression charts section title
  ///
  /// In en, this message translates to:
  /// **'Progression Charts'**
  String get progressionCharts;

  /// Description for empty exercise list
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to see your exercise progress'**
  String get noExercisesFoundDesc;

  /// Average reps label
  ///
  /// In en, this message translates to:
  /// **'Avg Reps'**
  String get avgReps;

  /// Last workout date label
  ///
  /// In en, this message translates to:
  /// **'Last Workout'**
  String get lastWorkout;

  /// Button to view progress details
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// Session history section title
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistory;

  /// Positive trend indicator
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get improving;

  /// Negative trend indicator
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get declining;

  /// Stable trend indicator
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// Period selector label
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get periodSelectorLabel;

  /// Combined chart view option
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get combinedView;

  /// Separated charts view option
  ///
  /// In en, this message translates to:
  /// **'Separated'**
  String get separatedView;

  /// Combined chart title
  ///
  /// In en, this message translates to:
  /// **'Combined Progress'**
  String get combinedChart;

  /// Legend tap instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to show/hide'**
  String get tapToToggle;

  /// Effort (RPE) metric label
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get effort;

  /// Weight settings screen title
  ///
  /// In en, this message translates to:
  /// **'Weight Settings'**
  String get weightSettings;

  /// Error message when settings fail to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Settings'**
  String get errorLoadingSettings;

  /// Quick increment chips section title
  ///
  /// In en, this message translates to:
  /// **'Quick Increments'**
  String get quickIncrements;

  /// Quick increments section description
  ///
  /// In en, this message translates to:
  /// **'Select your default weight increment for quick +/- buttons'**
  String get quickIncrementsDescription;

  /// Custom increment section title
  ///
  /// In en, this message translates to:
  /// **'Custom Increment'**
  String get customIncrement;

  /// Custom increment section description
  ///
  /// In en, this message translates to:
  /// **'Set a custom weight increment for precise adjustments'**
  String get customIncrementDescription;

  /// Plate calculator section title
  ///
  /// In en, this message translates to:
  /// **'Plate Calculator'**
  String get plateCalculator;

  /// Plate calculator section description
  ///
  /// In en, this message translates to:
  /// **'Calculate which plates to load on the bar'**
  String get plateCalculatorDescription;

  /// Available plates section title
  ///
  /// In en, this message translates to:
  /// **'Available Plates'**
  String get availablePlates;

  /// Available plates section description
  ///
  /// In en, this message translates to:
  /// **'Plates available in your gym'**
  String get availablePlatesDescription;

  /// Toggle to use custom increment
  ///
  /// In en, this message translates to:
  /// **'Use Custom Increment'**
  String get useCustomIncrement;

  /// Message when custom increment is enabled
  ///
  /// In en, this message translates to:
  /// **'Custom increment is active'**
  String get customIncrementActive;

  /// Message when default increment is enabled
  ///
  /// In en, this message translates to:
  /// **'Default increment is active'**
  String get defaultIncrementActive;

  /// TextField label for custom increment value
  ///
  /// In en, this message translates to:
  /// **'Custom Increment Value'**
  String get customIncrementValue;

  /// Hint text for custom increment input
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 0.5 and 100'**
  String get customIncrementHint;

  /// Validation message for empty value
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// Validation message for invalid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterValidNumber;

  /// Validation message for too large increment
  ///
  /// In en, this message translates to:
  /// **'Increment cannot exceed 100'**
  String get incrementTooLarge;

  /// Button to save custom increment
  ///
  /// In en, this message translates to:
  /// **'Save Custom Increment'**
  String get saveCustomIncrement;

  /// Success message after saving custom increment
  ///
  /// In en, this message translates to:
  /// **'Custom increment saved successfully'**
  String get customIncrementSaved;

  /// Plate calculator subsection title
  ///
  /// In en, this message translates to:
  /// **'Calculate Plates Needed'**
  String get calculatePlatesNeeded;

  /// TextField label for bar weight
  ///
  /// In en, this message translates to:
  /// **'Bar Weight'**
  String get barWeight;

  /// TextField label for target weight
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// Button to calculate plates
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// Available plates list title
  ///
  /// In en, this message translates to:
  /// **'Plates in Your Gym'**
  String get platesInYourGym;

  /// Quantity label for plates
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Button to edit available plates
  ///
  /// In en, this message translates to:
  /// **'Edit Plates'**
  String get editPlates;

  /// Error when weight values are invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter valid weights'**
  String get pleaseEnterValidWeights;

  /// Warning when target weight is less than bar weight
  ///
  /// In en, this message translates to:
  /// **'Target weight must be greater than or equal to bar weight'**
  String get targetWeightTooLow;

  /// Dialog title for plate calculation result
  ///
  /// In en, this message translates to:
  /// **'Plate Calculation Result'**
  String get plateCalculationResult;

  /// Label for weight difference
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// Section title for plates needed per side
  ///
  /// In en, this message translates to:
  /// **'Plates Per Side'**
  String get platesPerSide;

  /// Message when no plates are needed
  ///
  /// In en, this message translates to:
  /// **'Bar only (no plates needed)'**
  String get barOnly;

  /// Confirmation message for resetting settings
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to default values? This cannot be undone.'**
  String get resetSettingsConfirmation;

  /// Success message after resetting settings
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsReset;

  /// Haptic feedback settings screen title
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get feedbackSettings;

  /// Haptic feedback section title
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Toggle to enable haptic feedback
  ///
  /// In en, this message translates to:
  /// **'Enable haptic feedback'**
  String get enableHaptic;

  /// Haptic intensity setting label
  ///
  /// In en, this message translates to:
  /// **'Haptic Intensity'**
  String get hapticIntensity;

  /// Light haptic intensity
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get intensityLight;

  /// Medium haptic intensity
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get intensityMedium;

  /// Heavy haptic intensity
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get intensityHeavy;

  /// Description of haptic feedback feature
  ///
  /// In en, this message translates to:
  /// **'Feel subtle vibrations when completing sets, exercises, and workouts'**
  String get hapticDescription;

  /// Success message after saving feedback settings
  ///
  /// In en, this message translates to:
  /// **'Feedback settings saved'**
  String get feedbackSettingsSaved;

  /// Title for history view settings screen
  ///
  /// In en, this message translates to:
  /// **'History View Settings'**
  String get historyViewSettings;

  /// Label for view mode setting
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// List view mode option
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get viewModeList;

  /// Compact view mode option
  ///
  /// In en, this message translates to:
  /// **'Compact View'**
  String get viewModeCompact;

  /// Calendar view mode option
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get viewModeCalendar;

  /// Stats view mode option
  ///
  /// In en, this message translates to:
  /// **'Stats View'**
  String get viewModeStats;

  /// Section title for display options
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get historyDisplayOptions;

  /// Toggle to show/hide exercise thumbnails
  ///
  /// In en, this message translates to:
  /// **'Show Thumbnails'**
  String get showThumbnails;

  /// Toggle to show/hide workout duration
  ///
  /// In en, this message translates to:
  /// **'Show Duration'**
  String get showDuration;

  /// Toggle to show/hide exercise count
  ///
  /// In en, this message translates to:
  /// **'Show Exercise Count'**
  String get showExerciseCount;

  /// Description of view settings feature
  ///
  /// In en, this message translates to:
  /// **'Customize how your workout history is displayed'**
  String get viewSettingsDescription;

  /// Success message after saving view settings
  ///
  /// In en, this message translates to:
  /// **'View settings saved'**
  String get historyViewSettingsSaved;

  /// Button tooltip for reporting exercise issues
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportExerciseIssue;

  /// Label for feedback type selection
  ///
  /// In en, this message translates to:
  /// **'Issue Type'**
  String get feedbackType;

  /// Bug issue type option
  ///
  /// In en, this message translates to:
  /// **'🐛 Bug'**
  String get feedbackBug;

  /// Suggestion issue type option
  ///
  /// In en, this message translates to:
  /// **'💡 Suggestion'**
  String get feedbackSuggestion;

  /// Text error issue type option
  ///
  /// In en, this message translates to:
  /// **'📝 Text Error'**
  String get feedbackTypo;

  /// Other issue type option
  ///
  /// In en, this message translates to:
  /// **'❓ Other'**
  String get feedbackOther;

  /// Placeholder text for feedback message input
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get describeProblem;

  /// Button label for sending feedback
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendFeedback;

  /// Button label for canceling feedback dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelFeedback;

  /// Success message after sending feedback
  ///
  /// In en, this message translates to:
  /// **'✅ Thanks for the report!'**
  String get feedbackSentSuccess;

  /// Error message when sending feedback fails
  ///
  /// In en, this message translates to:
  /// **'❌ Error sending report'**
  String get feedbackSentError;

  /// Error message when feedback message is empty
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get feedbackRequired;

  /// Title for the exercise review report screen
  ///
  /// In en, this message translates to:
  /// **'Exercise Review Report'**
  String get exerciseReviewReport;

  /// Monthly review section header
  ///
  /// In en, this message translates to:
  /// **'Monthly Review'**
  String get monthlyReview;

  /// Stale exercises section header
  ///
  /// In en, this message translates to:
  /// **'Stale Exercises'**
  String get staleExercises;

  /// Flagged exercises section header
  ///
  /// In en, this message translates to:
  /// **'Flagged Exercises'**
  String get flaggedExercises;

  /// Stale exercises count label
  ///
  /// In en, this message translates to:
  /// **'Stale Exercises'**
  String get exercisesObsolete;

  /// Flagged exercises count label
  ///
  /// In en, this message translates to:
  /// **'Flagged Exercises'**
  String get exercisesFlagged;

  /// Total feedback count label
  ///
  /// In en, this message translates to:
  /// **'Total Feedback'**
  String get feedbackTotal;

  /// Critical issues count label
  ///
  /// In en, this message translates to:
  /// **'Critical Issues'**
  String get criticalIssues;

  /// Days threshold description for stale exercises
  ///
  /// In en, this message translates to:
  /// **'>90 days'**
  String get daysThreshold;

  /// Feedback threshold for flagged exercises
  ///
  /// In en, this message translates to:
  /// **'≥3 feedback'**
  String get feedbackThreshold;

  /// Flagged status indicator
  ///
  /// In en, this message translates to:
  /// **'flagged'**
  String get flagged;

  /// Critical status indicator
  ///
  /// In en, this message translates to:
  /// **'critical'**
  String get critical;

  /// Days since modification
  ///
  /// In en, this message translates to:
  /// **'Modified {days} days ago'**
  String modifiedDaysAgo(int days);

  /// Message when no review report is available
  ///
  /// In en, this message translates to:
  /// **'No report available'**
  String get noReportAvailable;

  /// Description when no review report exists yet
  ///
  /// In en, this message translates to:
  /// **'The monthly report will be available after the first execution'**
  String get reportWillBeAvailable;

  /// Title for exercise feedback admin dashboard
  ///
  /// In en, this message translates to:
  /// **'Exercise Feedback'**
  String get exerciseFeedback;

  /// Refresh button tooltip for feedback list
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get feedbackRefresh;

  /// Total feedback count stat label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get feedbackStatsTotal;

  /// Open feedback count stat label - feedback awaiting admin review
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get feedbackStatsOpen;

  /// Resolved feedback count stat label - issues that have been fixed
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get feedbackStatsResolved;

  /// Section title for feedback grouped by type (bug, suggestion, etc)
  ///
  /// In en, this message translates to:
  /// **'Feedback by Type'**
  String get feedbackByType;

  /// Section title for feedback grouped by severity (critical, high, medium, low)
  ///
  /// In en, this message translates to:
  /// **'Feedback by Severity'**
  String get feedbackBySeverity;

  /// Critical severity level (4-5) - requires immediate attention
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get feedbackSeverityCritical;

  /// High severity level (3) - important issue to address soon
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get feedbackSeverityHigh;

  /// Medium severity level (2) - standard priority issue
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get feedbackSeverityMedium;

  /// Low severity level (1) - minor issue or enhancement
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get feedbackSeverityLow;

  /// Section title for critical issues that need immediate attention
  ///
  /// In en, this message translates to:
  /// **'Critical Issues (Severity ≥ 4)'**
  String get feedbackCriticalIssues;

  /// Section title for critical issues that need immediate attention
  ///
  /// In en, this message translates to:
  /// **'Critical Issues (Severity ≥ 4)'**
  String get feedbackCriticalIssuesTitle;

  /// Message when there are no critical issues - good news!
  ///
  /// In en, this message translates to:
  /// **'No critical issues'**
  String get feedbackNoCriticalIssues;

  /// Error message when critical issues fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading critical issues'**
  String get feedbackErrorLoadingCritical;

  /// Section title for latest open feedback items awaiting review
  ///
  /// In en, this message translates to:
  /// **'Recent Open Feedback'**
  String get feedbackRecentOpen;

  /// Section title for latest open feedback items awaiting review
  ///
  /// In en, this message translates to:
  /// **'Recent Open Feedback'**
  String get feedbackRecentOpenTitle;

  /// Message when all feedback has been reviewed - all caught up!
  ///
  /// In en, this message translates to:
  /// **'No open feedback'**
  String get feedbackNoOpenFeedback;

  /// Error message when feedback list fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading feedback'**
  String get feedbackErrorLoading;

  /// Error message when feedback list fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading feedback'**
  String get feedbackErrorLoadingList;

  /// Loading message while fetching feedback data
  ///
  /// In en, this message translates to:
  /// **'Loading feedback...'**
  String get feedbackLoadingMessage;

  /// Prefix for user email who submitted feedback
  ///
  /// In en, this message translates to:
  /// **'by {email}'**
  String feedbackSubmittedBy(String email);

  /// Section title for the message submitted by the user
  ///
  /// In en, this message translates to:
  /// **'User Message'**
  String get feedbackDetailUserMessage;

  /// Section title for internal admin notes - not visible to users
  ///
  /// In en, this message translates to:
  /// **'Admin Notes'**
  String get feedbackDetailAdminNotes;

  /// Hint text for admin notes field - explain it's for internal use only
  ///
  /// In en, this message translates to:
  /// **'Add internal notes about this feedback...'**
  String get feedbackDetailAdminNotesHint;

  /// Button to save admin notes to database
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get feedbackDetailSaveNotes;

  /// Success message after saving admin notes
  ///
  /// In en, this message translates to:
  /// **'Notes saved successfully'**
  String get feedbackDetailNotesSaved;

  /// Error message when saving admin notes fails
  ///
  /// In en, this message translates to:
  /// **'Error saving notes'**
  String get feedbackDetailNotesError;

  /// Section title for quick action buttons to change feedback status
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get feedbackDetailQuickActions;

  /// Action to mark feedback as 'REVIEWING' - you're actively working on it
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get feedbackActionStartReview;

  /// Action to mark feedback as 'RESOLVED' - issue has been fixed
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get feedbackActionMarkResolved;

  /// Action to mark feedback as 'DISMISSED' - won't fix or not applicable
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get feedbackActionDismiss;

  /// Action to reopen feedback back to 'OPEN' status - needs more attention
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get feedbackActionReopen;

  /// Success message after changing feedback status
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String feedbackStatusUpdated(String status);

  /// Error message when status update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating status'**
  String get feedbackStatusUpdateError;

  /// Section title for changing feedback severity level (1-5)
  ///
  /// In en, this message translates to:
  /// **'Change Severity'**
  String get feedbackDetailChangeSeverity;

  /// Success message after changing severity level
  ///
  /// In en, this message translates to:
  /// **'Severity updated'**
  String get feedbackSeverityUpdated;

  /// Error message when severity update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating severity'**
  String get feedbackSeverityUpdateError;

  /// Label for user email in feedback detail
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get feedbackDetailInfoUser;

  /// Label for creation date in feedback detail
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get feedbackDetailInfoCreated;

  /// Label for app version when feedback was submitted
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get feedbackDetailInfoVersion;

  /// Urgent severity level (5) - critical issue requiring immediate action
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get feedbackSeverityUrgent;

  /// Relative time format for minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String feedbackTimeMinutesAgo(int minutes);

  /// Relative time format for hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String feedbackTimeHoursAgo(int hours);

  /// Relative time format for days
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String feedbackTimeDaysAgo(int days);

  /// Shows who submitted the feedback - 'by email@example.com'
  ///
  /// In en, this message translates to:
  /// **'by {email}'**
  String feedbackByUser(String email);

  /// Message shown while saving workout
  ///
  /// In en, this message translates to:
  /// **'Saving workout...'**
  String get savingWorkout;

  /// Message shown while syncing workout to cloud
  ///
  /// In en, this message translates to:
  /// **'Syncing to cloud...'**
  String get syncingToCloud;

  /// Message when workout is saved to local storage
  ///
  /// In en, this message translates to:
  /// **'Workout saved locally'**
  String get workoutSavedLocally;

  /// Message when cloud synchronization completes successfully
  ///
  /// In en, this message translates to:
  /// **'Cloud sync complete'**
  String get cloudSyncComplete;

  /// Message when workout is queued for cloud synchronization
  ///
  /// In en, this message translates to:
  /// **'Queued for sync'**
  String get cloudSyncQueued;

  /// Error message when save operation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get saveFailed;

  /// Message when retrying cloud synchronization
  ///
  /// In en, this message translates to:
  /// **'Retrying sync...'**
  String get retryingSync;

  /// Critical error message when local save fails
  ///
  /// In en, this message translates to:
  /// **'Local save failed'**
  String get localSaveFailed;

  /// Action message for local save failure
  ///
  /// In en, this message translates to:
  /// **'Retry or export data'**
  String get retryOrExport;

  /// Title for quick rep preset chips section
  ///
  /// In en, this message translates to:
  /// **'Quick Rep Presets'**
  String get quickRepPresets;

  /// Title for quick set count selector
  ///
  /// In en, this message translates to:
  /// **'Quick Set Count'**
  String get quickSetCount;

  /// Average Rate of Perceived Exertion label in workout summary
  ///
  /// In en, this message translates to:
  /// **'Average RPE'**
  String get averageRpe;

  /// Success message when a routine day is auto-completed
  ///
  /// In en, this message translates to:
  /// **'Routine day completed:'**
  String get routineDayCompleted;

  /// Error message when routine day completion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to complete routine day'**
  String get routineDayCompletionFailed;

  /// No description provided for @repPresetStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'1-3'**
  String get repPresetStrengthLabel;

  /// No description provided for @repPresetStrengthDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum Strength'**
  String get repPresetStrengthDescription;

  /// No description provided for @repPresetPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'4-6'**
  String get repPresetPowerLabel;

  /// No description provided for @repPresetPowerDescription.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get repPresetPowerDescription;

  /// No description provided for @repPresetStrengthHypertrophyLabel.
  ///
  /// In en, this message translates to:
  /// **'6-8'**
  String get repPresetStrengthHypertrophyLabel;

  /// No description provided for @repPresetStrengthHypertrophyDescription.
  ///
  /// In en, this message translates to:
  /// **'Strength / Hypertrophy'**
  String get repPresetStrengthHypertrophyDescription;

  /// No description provided for @repPresetHypertrophyLabel.
  ///
  /// In en, this message translates to:
  /// **'8-12'**
  String get repPresetHypertrophyLabel;

  /// No description provided for @repPresetHypertrophyDescription.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get repPresetHypertrophyDescription;

  /// No description provided for @repPresetEnduranceLabel.
  ///
  /// In en, this message translates to:
  /// **'12-15'**
  String get repPresetEnduranceLabel;

  /// No description provided for @repPresetEnduranceDescription.
  ///
  /// In en, this message translates to:
  /// **'Muscular Endurance'**
  String get repPresetEnduranceDescription;

  /// No description provided for @repPresetHighEnduranceLabel.
  ///
  /// In en, this message translates to:
  /// **'15+'**
  String get repPresetHighEnduranceLabel;

  /// No description provided for @repPresetHighEnduranceDescription.
  ///
  /// In en, this message translates to:
  /// **'High Endurance'**
  String get repPresetHighEnduranceDescription;

  /// No description provided for @restPresetNoTimer.
  ///
  /// In en, this message translates to:
  /// **'No Timer'**
  String get restPresetNoTimer;

  /// No description provided for @restPresetThirtySeconds.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get restPresetThirtySeconds;

  /// No description provided for @restPresetOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get restPresetOneMinute;

  /// No description provided for @restPresetOneMinuteThirty.
  ///
  /// In en, this message translates to:
  /// **'1:30 min'**
  String get restPresetOneMinuteThirty;

  /// No description provided for @restPresetTwoMinutes.
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get restPresetTwoMinutes;

  /// No description provided for @restPresetThreeMinutes.
  ///
  /// In en, this message translates to:
  /// **'3 minutes'**
  String get restPresetThreeMinutes;

  /// No description provided for @restPresetFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get restPresetFiveMinutes;

  /// Description for rest time modal
  ///
  /// In en, this message translates to:
  /// **'Set the recovery timer between sets'**
  String get restTimeDescription;

  /// Switch to enable/disable custom timer
  ///
  /// In en, this message translates to:
  /// **'Use custom timer'**
  String get useCustomTimer;

  /// Subtitle when timer is enabled
  ///
  /// In en, this message translates to:
  /// **'Timer active for this exercise'**
  String get timerActiveForExercise;

  /// Subtitle when timer is disabled
  ///
  /// In en, this message translates to:
  /// **'No specific timer'**
  String get noSpecificTimer;

  /// Header for quick preset buttons
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get quickPresets;

  /// Header for custom timer picker
  ///
  /// In en, this message translates to:
  /// **'Custom Timer'**
  String get customTimer;

  /// Preview label for selected time
  ///
  /// In en, this message translates to:
  /// **'Timer set: '**
  String get timerSet;

  /// Title of swap confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Swap Workout Days?'**
  String get swapDaysTitle;

  /// Explanation of swap feature
  ///
  /// In en, this message translates to:
  /// **'Your routine scheduled differently. Do you want to swap these days?'**
  String get swapDaysDescription;

  /// Success message after swap
  ///
  /// In en, this message translates to:
  /// **'Days swapped successfully! Continuing with'**
  String get daysSwappedSuccessfully;

  /// Error message when swap fails
  ///
  /// In en, this message translates to:
  /// **'Error swapping days. Please try again.'**
  String get errorSwappingDays;

  /// Error message for skip action
  ///
  /// In en, this message translates to:
  /// **'Error marking day as skipped'**
  String get errorMarkingDayAsSkipped;

  /// Info message when user chose 'Continue Normal'
  ///
  /// In en, this message translates to:
  /// **'Workout completed. Routine not updated.'**
  String get workoutCompletedButRoutineNotUpdated;

  /// Button label - do workout without routine update
  ///
  /// In en, this message translates to:
  /// **'Continue Normal'**
  String get continueNormal;

  /// Button label - mark today's workout as skipped
  ///
  /// In en, this message translates to:
  /// **'Skip Today'**
  String get skipToday;

  /// Button label - swap the two days (recommended)
  ///
  /// In en, this message translates to:
  /// **'Swap Days'**
  String get swapDaysButtonLabel;

  /// Title of skip recovery dialog
  ///
  /// In en, this message translates to:
  /// **'Recover Skipped Days'**
  String get routineRecoverSkippedDays;

  /// Subtitle explaining how skip recovery works
  ///
  /// In en, this message translates to:
  /// **'Select a skipped day, then choose a rest day to recover it'**
  String get routineRecoverSkippedDaysSubtitle;

  /// Header for skipped days list
  ///
  /// In en, this message translates to:
  /// **'Skipped Days ({count})'**
  String routineSkippedDaysCount(int count);

  /// Header for available recovery days list
  ///
  /// In en, this message translates to:
  /// **'Available Days ({count})'**
  String routineAvailableDaysCount(int count);

  /// Hint when no skipped day is selected
  ///
  /// In en, this message translates to:
  /// **'← Select a skipped day first'**
  String get routineSelectSkippedDayFirst;

  /// Empty state when no days are skipped
  ///
  /// In en, this message translates to:
  /// **'No skipped days!'**
  String get routineNoSkippedDays;

  /// Encouragement message when no skipped days
  ///
  /// In en, this message translates to:
  /// **'You\'re on track with your routine 💪'**
  String get routineOnTrack;

  /// Empty state when no recovery days available
  ///
  /// In en, this message translates to:
  /// **'No rest days available in the next 30 days'**
  String get routineNoRestDaysAvailable;

  /// Success message after recovering a workout
  ///
  /// In en, this message translates to:
  /// **'Workout recovered to {date}'**
  String routineWorkoutRecovered(String date);

  /// Error message when recovery fails
  ///
  /// In en, this message translates to:
  /// **'Failed to recover workout'**
  String get routineRecoveryFailed;

  /// Error message with details
  ///
  /// In en, this message translates to:
  /// **'Error recovering workout: {error}'**
  String routineRecoveryError(String error);

  /// Error when no active routine exists
  ///
  /// In en, this message translates to:
  /// **'No active routine found'**
  String get routineNoActiveRoutine;

  /// Button label to open skip recovery dialog
  ///
  /// In en, this message translates to:
  /// **'Skip Recovery'**
  String get routineSkipRecovery;

  /// Notification title for single skipped day
  ///
  /// In en, this message translates to:
  /// **'{count} day skipped in {routine}'**
  String notificationSkippedDaysSingle(int count, String routine);

  /// Notification title for multiple skipped days
  ///
  /// In en, this message translates to:
  /// **'{count} days skipped in {routine}'**
  String notificationSkippedDaysMultiple(int count, String routine);

  /// Notification body for skipped days reminder
  ///
  /// In en, this message translates to:
  /// **'Tap to view recovery options and get back on track!'**
  String get notificationSkippedDaysBody;

  /// Notification title for routine day completion
  ///
  /// In en, this message translates to:
  /// **'{routine} day completed!'**
  String notificationRoutineDayCompleted(String routine);

  /// Notification body for workout completion
  ///
  /// In en, this message translates to:
  /// **'Great job completing {workout}!'**
  String notificationGreatJob(String workout);

  /// Notification title for single recovery opportunity
  ///
  /// In en, this message translates to:
  /// **'{count} skipped day can be recovered'**
  String notificationRecoverySingle(int count);

  /// Notification title for multiple recovery opportunities
  ///
  /// In en, this message translates to:
  /// **'{count} skipped days can be recovered'**
  String notificationRecoveryMultiple(int count);

  /// Notification body for recovery opportunity
  ///
  /// In en, this message translates to:
  /// **'Tap to schedule recovery workouts in {routine}'**
  String notificationRecoveryBody(String routine);

  /// Error shown when JSON is malformed
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format. Check brackets and commas.'**
  String get errorJsonMalformed;

  /// Error for unexpected character in JSON
  ///
  /// In en, this message translates to:
  /// **'Unexpected character in JSON. Check syntax.'**
  String get errorJsonUnexpectedCharacter;

  /// Error for missing required fields
  ///
  /// In en, this message translates to:
  /// **'Missing required fields in JSON.'**
  String get errorJsonMissingFields;

  /// Error when file doesn't exist
  ///
  /// In en, this message translates to:
  /// **'File not found. Please select a valid file.'**
  String get errorFileNotFound;

  /// Error when lacking file permissions
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Cannot access file.'**
  String get errorFilePermission;

  /// Generic file access error
  ///
  /// In en, this message translates to:
  /// **'Unable to access file. Try again.'**
  String get errorFileAccess;

  /// Error when file exceeds size limit
  ///
  /// In en, this message translates to:
  /// **'File too large (max 5MB).'**
  String get errorFileTooLarge;

  /// Error when file has no content
  ///
  /// In en, this message translates to:
  /// **'File is empty. Please provide content.'**
  String get errorFileEmpty;

  /// Error when file already exists
  ///
  /// In en, this message translates to:
  /// **'File already exists.'**
  String get errorFileAlreadyExists;

  /// Error when disk has no space
  ///
  /// In en, this message translates to:
  /// **'Disk is full. Free up space and try again.'**
  String get errorDiskFull;

  /// Error when template has no name
  ///
  /// In en, this message translates to:
  /// **'Template name is required.'**
  String get errorTemplateNameMissing;

  /// Error when template has no exercises
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise to the template.'**
  String get errorNoExercises;

  /// Error when exercise data is malformed
  ///
  /// In en, this message translates to:
  /// **'Exercise data is invalid. Check format.'**
  String get errorExercisesInvalid;

  /// Error when exercise has no sets
  ///
  /// In en, this message translates to:
  /// **'Each exercise needs at least one set.'**
  String get errorSetsRequired;

  /// Error when weight/reps are not numbers
  ///
  /// In en, this message translates to:
  /// **'Weight and reps must be valid numbers.'**
  String get errorInvalidNumbers;

  /// Error when template name is duplicate
  ///
  /// In en, this message translates to:
  /// **'A template with this name already exists.'**
  String get errorDuplicateTemplate;

  /// Generic import error fallback
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check format and try again.'**
  String get errorImportFailed;

  /// Suggestion to check JSON syntax
  ///
  /// In en, this message translates to:
  /// **'Check JSON format (brackets, commas, quotes)'**
  String get suggestionCheckJsonFormat;

  /// Suggestion to use online JSON validator
  ///
  /// In en, this message translates to:
  /// **'Use a JSON validator online to check format'**
  String get suggestionUseJsonValidator;

  /// Suggestion to use example template
  ///
  /// In en, this message translates to:
  /// **'Copy the example template and modify it'**
  String get suggestionCopyExample;

  /// Suggestion to check file location
  ///
  /// In en, this message translates to:
  /// **'Verify the file exists at the specified path'**
  String get suggestionCheckFilePath;

  /// Suggestion to make file smaller
  ///
  /// In en, this message translates to:
  /// **'Reduce file size or split into multiple files'**
  String get suggestionReduceFileSize;

  /// Suggestion to check file permissions
  ///
  /// In en, this message translates to:
  /// **'Check app permissions in device settings'**
  String get suggestionCheckPermissions;

  /// Suggestion to add template name
  ///
  /// In en, this message translates to:
  /// **'Add a name field to your template'**
  String get suggestionAddTemplateName;

  /// Suggestion to add exercises
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise with sets'**
  String get suggestionAddExercises;

  /// Suggestion to add sets to exercise
  ///
  /// In en, this message translates to:
  /// **'Add set information (reps and weight)'**
  String get suggestionAddSets;

  /// Generic suggestion to check format
  ///
  /// In en, this message translates to:
  /// **'Check the template format matches the example'**
  String get suggestionCheckFormat;

  /// List view mode
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// Grid view mode
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// Import phase: parsing JSON
  ///
  /// In en, this message translates to:
  /// **'Parsing...'**
  String get parsing;

  /// Import phase: matching exercises with database
  ///
  /// In en, this message translates to:
  /// **'Matching exercises...'**
  String get matchingExercises;

  /// Import phase: converting percentage weights
  ///
  /// In en, this message translates to:
  /// **'Converting weights...'**
  String get convertingWeights;

  /// Import phase: finalizing import
  ///
  /// In en, this message translates to:
  /// **'Finalizing...'**
  String get finalizing;

  /// Import failed error message
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// Placeholder for missing description
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Exercise detail tab: Summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get exerciseDetailSummary;

  /// Exercise detail tab: History
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get exerciseDetailHistory;

  /// Exercise detail tab: Instructions
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get exerciseDetailInstructions;

  /// Label for primary muscle
  ///
  /// In en, this message translates to:
  /// **'Primary Muscle'**
  String get primaryMuscle;

  /// Chart title for last 3 months data
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3MonthsChart;

  /// Label for best one rep max
  ///
  /// In en, this message translates to:
  /// **'Best 1RM'**
  String get best1RM;

  /// Label for best volume in a single set
  ///
  /// In en, this message translates to:
  /// **'Best Set Volume'**
  String get bestSetVolume;

  /// Label for best total session volume
  ///
  /// In en, this message translates to:
  /// **'Best Session Volume'**
  String get bestSessionVolume;

  /// Label for user's strength level
  ///
  /// In en, this message translates to:
  /// **'Strength Level'**
  String get strengthLevel;

  /// Placeholder message for strength level feature
  ///
  /// In en, this message translates to:
  /// **'Strength level benchmarks coming soon!'**
  String get strengthLevelComingSoon;

  /// Message when exercise has no history
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// Hint to start workout to see history
  ///
  /// In en, this message translates to:
  /// **'Start a workout to see your exercise history'**
  String get startWorkoutToSeeHistory;

  /// Placeholder for workout with no name
  ///
  /// In en, this message translates to:
  /// **'Unknown Workout'**
  String get unknownWorkout;

  /// Section title for video tutorial
  ///
  /// In en, this message translates to:
  /// **'Video Tutorial'**
  String get videoTutorial;

  /// Section title for form cues
  ///
  /// In en, this message translates to:
  /// **'Form Cues'**
  String get formCues;

  /// Description for warmup phase 1
  ///
  /// In en, this message translates to:
  /// **'Joint mobilization and dynamic stretching (5-10 min)'**
  String get warmupPhase1Description;

  /// Description for warmup phase 2
  ///
  /// In en, this message translates to:
  /// **'Muscle activation with bodyweight exercises'**
  String get warmupPhase2Description;

  /// Description for warmup phase 3
  ///
  /// In en, this message translates to:
  /// **'2-3 warmup sets with progressive weight'**
  String get warmupPhase3Description;

  /// Title for warmup phase 4
  ///
  /// In en, this message translates to:
  /// **'Rest & Recovery'**
  String get warmupPhase4Title;

  /// Description for warmup phase 4
  ///
  /// In en, this message translates to:
  /// **'1-2 minutes rest before starting working sets'**
  String get warmupPhase4Description;

  /// Section title for tips
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// Back button accessibility hint
  ///
  /// In en, this message translates to:
  /// **'Navigate to previous screen'**
  String get backHint;

  /// Create template button accessibility hint
  ///
  /// In en, this message translates to:
  /// **'Open form to create a new workout template'**
  String get createTemplateHint;

  /// Section title for cross-device sync status
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// Sync status button accessibility hint
  ///
  /// In en, this message translates to:
  /// **'View cloud synchronization status and offline changes'**
  String get syncStatusHint;

  /// Error message for 404 page
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// Success message for modal test
  ///
  /// In en, this message translates to:
  /// **'✅ {modalName} - WORKING'**
  String modalTestSuccess(String modalName);

  /// Modal opened message for testing
  ///
  /// In en, this message translates to:
  /// **'✅ {modalName} - OPENED (check functionality)'**
  String modalTestOpened(String modalName);

  /// Error message for modal test
  ///
  /// In en, this message translates to:
  /// **'❌ {modalName} - ERROR: {error}'**
  String modalTestError(String modalName, String error);

  /// RPE selector test success message
  ///
  /// In en, this message translates to:
  /// **'✅ RpeSelectorBottomSheet - WORKING: RPE {rpe}'**
  String modalTestRpeSuccess(String rpe);

  /// Message when history button is tapped
  ///
  /// In en, this message translates to:
  /// **'📊 History button tapped'**
  String get historyButtonTapped;

  /// Message when edit button is tapped
  ///
  /// In en, this message translates to:
  /// **'✏️ Edit button tapped'**
  String get editButtonTapped;

  /// Title for variation selector dialog
  ///
  /// In en, this message translates to:
  /// **'Select Variation'**
  String get exerciseSelectVariation;

  /// Label for equipment filter toggle
  ///
  /// In en, this message translates to:
  /// **'Filter by available equipment'**
  String get exerciseFilterByEquipment;

  /// Label for standard variation type
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get exerciseVariationStandard;

  /// Label for equipment variation type
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseVariationEquipment;

  /// Label for grip variation type
  ///
  /// In en, this message translates to:
  /// **'Grip'**
  String get exerciseVariationGrip;

  /// Label for angle variation type
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get exerciseVariationAngle;

  /// Label for tempo variation type
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get exerciseVariationTempo;

  /// Label for range of motion variation type
  ///
  /// In en, this message translates to:
  /// **'Range of Motion'**
  String get exerciseVariationROM;

  /// Label when no equipment is required
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get exerciseEquipmentNone;

  /// Info text showing filtered variation count
  ///
  /// In en, this message translates to:
  /// **'Showing {filtered} of {total} variations'**
  String exerciseVariationsFiltered(int filtered, int total);

  /// Info text showing total variation count
  ///
  /// In en, this message translates to:
  /// **'{total} variations available'**
  String exerciseVariationsTotal(int total);

  /// Empty state message when no variations match equipment
  ///
  /// In en, this message translates to:
  /// **'No variations available with your current equipment'**
  String get exerciseNoVariationsWithEquipment;

  /// Empty state message when no variations exist
  ///
  /// In en, this message translates to:
  /// **'No variations available for this exercise'**
  String get exerciseNoVariationsAvailable;

  /// Button to disable equipment filter
  ///
  /// In en, this message translates to:
  /// **'Show All Variations'**
  String get exerciseShowAllVariations;

  /// Equipment profile label
  ///
  /// In en, this message translates to:
  /// **'Equipment Profile'**
  String get equipmentProfile;

  /// Button to create new equipment profile
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get equipmentProfileCreate;

  /// Equipment count in profile
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String equipmentProfileItemsCount(int count);

  /// Placeholder when no profile selected
  ///
  /// In en, this message translates to:
  /// **'Select an equipment profile'**
  String get equipmentProfileSelectOne;

  /// Title for profile selection sheet
  ///
  /// In en, this message translates to:
  /// **'Select Equipment Profile'**
  String get equipmentProfileSelect;

  /// Error message when profile creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create equipment profile'**
  String get equipmentProfileCreateError;

  /// Error message when profiles fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load equipment profiles'**
  String get equipmentProfileLoadError;

  /// Message when no profiles exist
  ///
  /// In en, this message translates to:
  /// **'No equipment profiles yet'**
  String get equipmentProfileEmpty;

  /// Button to create first profile
  ///
  /// In en, this message translates to:
  /// **'Create First Profile'**
  String get equipmentProfileCreateFirst;

  /// Dialog title for creating new profile
  ///
  /// In en, this message translates to:
  /// **'Create Equipment Profile'**
  String get equipmentProfileCreateNew;

  /// Instructions for template selection
  ///
  /// In en, this message translates to:
  /// **'Select Starting Template'**
  String get equipmentProfileSelectTemplate;

  /// Commercial gym profile name
  ///
  /// In en, this message translates to:
  /// **'Commercial Gym'**
  String get equipmentProfileCommercial;

  /// Commercial gym profile description
  ///
  /// In en, this message translates to:
  /// **'Full equipment - barbell, dumbbells, machines, cables'**
  String get equipmentProfileCommercialDesc;

  /// Home basic profile name
  ///
  /// In en, this message translates to:
  /// **'Home Gym (Basic)'**
  String get equipmentProfileHomeBasic;

  /// Home basic profile description
  ///
  /// In en, this message translates to:
  /// **'Barbell, dumbbells, bench, resistance bands'**
  String get equipmentProfileHomeBasicDesc;

  /// Home complete profile name
  ///
  /// In en, this message translates to:
  /// **'Home Gym (Complete)'**
  String get equipmentProfileHomeComplete;

  /// Home complete profile description
  ///
  /// In en, this message translates to:
  /// **'Advanced home setup - kettlebells, TRX, pull-up bar'**
  String get equipmentProfileHomeCompleteDesc;

  /// Travel profile name
  ///
  /// In en, this message translates to:
  /// **'Travel / Hotel'**
  String get equipmentProfileTravel;

  /// Travel profile description
  ///
  /// In en, this message translates to:
  /// **'Minimal - dumbbells and bodyweight exercises'**
  String get equipmentProfileTravelDesc;

  /// Bodyweight profile name
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Only'**
  String get equipmentProfileBodyweight;

  /// Bodyweight profile description
  ///
  /// In en, this message translates to:
  /// **'No equipment - calisthenics and bodyweight movements'**
  String get equipmentProfileBodyweightDesc;

  /// Barbell equipment type
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipment_barbell;

  /// Dumbbell equipment type
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipment_dumbbell;

  /// Weight machine equipment type
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipment_machine;

  /// Cable machine equipment type
  ///
  /// In en, this message translates to:
  /// **'Cables'**
  String get equipment_cables;

  /// Smith machine equipment type
  ///
  /// In en, this message translates to:
  /// **'Smith Machine'**
  String get equipment_smith_machine;

  /// EZ curl bar equipment type
  ///
  /// In en, this message translates to:
  /// **'EZ Bar'**
  String get equipment_ez_bar;

  /// Kettlebell equipment type
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipment_kettlebell;

  /// Bodyweight/calisthenics equipment type
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipment_bodyweight;

  /// TRX/suspension training equipment type
  ///
  /// In en, this message translates to:
  /// **'TRX'**
  String get equipment_trx;

  /// Resistance bands equipment type
  ///
  /// In en, this message translates to:
  /// **'Resistance Bands'**
  String get equipment_bands;

  /// Pull-up bar equipment type
  ///
  /// In en, this message translates to:
  /// **'Pull-up Bar'**
  String get equipment_pullup_bar;

  /// Parallel bars/dip station equipment type
  ///
  /// In en, this message translates to:
  /// **'Parallel Bars'**
  String get equipment_parallel_bars;

  /// Power rack/squat rack equipment type
  ///
  /// In en, this message translates to:
  /// **'Rack'**
  String get equipment_rack;

  /// Weight bench equipment type
  ///
  /// In en, this message translates to:
  /// **'Bench'**
  String get equipment_bench;

  /// Title for rotation config dialog
  ///
  /// In en, this message translates to:
  /// **'Rotation Settings'**
  String get rotationConfigTitle;

  /// Enable rotation toggle label
  ///
  /// In en, this message translates to:
  /// **'Enable Rotation'**
  String get rotationEnabled;

  /// Description for rotation enable toggle
  ///
  /// In en, this message translates to:
  /// **'Automatically rotate exercise variations'**
  String get rotationEnabledDesc;

  /// Label for rotation frequency section
  ///
  /// In en, this message translates to:
  /// **'Rotation Frequency'**
  String get rotationFrequency;

  /// Label for notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get rotationNotifications;

  /// Description for notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Notify before variation changes'**
  String get rotationNotificationsDesc;

  /// Label for notification days selector
  ///
  /// In en, this message translates to:
  /// **'Notify days before'**
  String get rotationNotifyDaysBefore;

  /// Rotation frequency in weeks
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{Every week} other{Every {weeks} weeks}}'**
  String rotationFrequencyWeeks(int weeks);

  /// Notification days count
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String rotationNotifyDaysCount(int days);

  /// Label for rotation preview section
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get rotationPreview;

  /// Label for next rotation date
  ///
  /// In en, this message translates to:
  /// **'Next rotation'**
  String get rotationNextDate;

  /// Next rotation in N days
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String rotationInDays(int days);

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Access denied title for unauthorized screen
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// Message shown when user lacks required permission
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this feature. Please upgrade your account or contact support.'**
  String get noPermissionMessage;

  /// Warning message shown before session timeout
  ///
  /// In en, this message translates to:
  /// **'Your session will expire in {seconds} seconds. Tap to extend.'**
  String sessionExpiringSoon(int seconds);

  /// Message shown when session has timed out
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// Button to extend user session
  ///
  /// In en, this message translates to:
  /// **'Extend Session'**
  String get extendSession;

  /// No description provided for @equipmentProfileName.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get equipmentProfileName;

  /// No description provided for @equipmentProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Home Gym, Travel Kit'**
  String get equipmentProfileNameHint;

  /// No description provided for @equipmentProfileBadge.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get equipmentProfileBadge;

  /// No description provided for @equipmentProfileSelectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select Available Equipment'**
  String get equipmentProfileSelectEquipment;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @equipmentProfileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Equipment Profile'**
  String get equipmentProfileEdit;

  /// No description provided for @equipmentProfileTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a template to customize or start from scratch'**
  String get equipmentProfileTemplateHint;

  /// No description provided for @equipmentProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment Profiles'**
  String get equipmentProfilesTitle;

  /// No description provided for @equipmentProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your equipment availability for exercise recommendations'**
  String get equipmentProfilesSubtitle;

  /// No description provided for @equipmentProfilesHelp.
  ///
  /// In en, this message translates to:
  /// **'Equipment Profiles Help'**
  String get equipmentProfilesHelp;

  /// No description provided for @equipmentProfilesHelpText.
  ///
  /// In en, this message translates to:
  /// **'Equipment profiles help the app suggest exercises that match your available equipment. Create different profiles for different locations (gym, home, travel).'**
  String get equipmentProfilesHelpText;

  /// No description provided for @equipmentProfileBadgeFull.
  ///
  /// In en, this message translates to:
  /// **'Full gym with 6+ equipment types'**
  String get equipmentProfileBadgeFull;

  /// No description provided for @equipmentProfileBadgeHome.
  ///
  /// In en, this message translates to:
  /// **'Home setup with 3-5 equipment types'**
  String get equipmentProfileBadgeHome;

  /// No description provided for @equipmentProfileBadgeMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal setup with 1-2 equipment types'**
  String get equipmentProfileBadgeMinimal;

  /// No description provided for @equipmentProfilesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Equipment Profiles Yet'**
  String get equipmentProfilesEmpty;

  /// No description provided for @equipmentProfilesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first equipment profile to get exercise recommendations based on what you have available.'**
  String get equipmentProfilesEmptyDescription;

  /// No description provided for @equipmentProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get equipmentProfileUpdated;

  /// No description provided for @equipmentProfileCreated.
  ///
  /// In en, this message translates to:
  /// **'Profile created successfully'**
  String get equipmentProfileCreated;

  /// No description provided for @equipmentProfileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get equipmentProfileSaveError;

  /// No description provided for @equipmentProfileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Equipment Profile?'**
  String get equipmentProfileDeleteConfirmTitle;

  /// Confirmation message for deleting equipment profile
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String equipmentProfileDeleteConfirmMessage(String name);

  /// No description provided for @equipmentProfileDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile deleted successfully'**
  String get equipmentProfileDeleted;

  /// No description provided for @equipmentProfileDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile'**
  String get equipmentProfileDeleteError;

  /// No description provided for @equipmentProfileSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Default profile updated'**
  String get equipmentProfileSetDefault;

  /// No description provided for @equipmentProfileDefaultError.
  ///
  /// In en, this message translates to:
  /// **'Failed to set default profile'**
  String get equipmentProfileDefaultError;

  /// No description provided for @equipmentProfileDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get equipmentProfileDefault;

  /// No description provided for @equipmentProfileMakeDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get equipmentProfileMakeDefault;

  /// No description provided for @equipmentProfileStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Equipment'**
  String get equipmentProfileStepTitle;

  /// No description provided for @equipmentProfileStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Select which equipment you have available for this routine. This will help filter exercises to match your setup.'**
  String get equipmentProfileStepDescription;

  /// No description provided for @equipmentProfileStepDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Select which equipment you have available. You can skip this and set it up later.'**
  String get equipmentProfileStepDescriptionOptional;

  /// No description provided for @equipmentProfileOptional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get equipmentProfileOptional;

  /// No description provided for @equipmentProfileSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get equipmentProfileSkipForNow;

  /// No description provided for @equipmentProfileSkipConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip Equipment Profile?'**
  String get equipmentProfileSkipConfirmTitle;

  /// No description provided for @equipmentProfileSkipConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You can add an equipment profile later from Settings. Without it, all exercises will be available.'**
  String get equipmentProfileSkipConfirmMessage;

  /// No description provided for @equipmentProfileStepInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Why is this important?'**
  String get equipmentProfileStepInfoTitle;

  /// No description provided for @equipmentProfileStepInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will only suggest exercises that match your selected equipment, ensuring you can actually perform the recommended workouts.'**
  String get equipmentProfileStepInfoMessage;

  /// No description provided for @equipmentProfileManageInSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage Profiles in Settings'**
  String get equipmentProfileManageInSettings;

  /// No description provided for @migrationWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment Profile Change'**
  String get migrationWizardTitle;

  /// No description provided for @migrationWizardImpactAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Impact'**
  String get migrationWizardImpactAnalysisTitle;

  /// No description provided for @migrationWizardImpactSummary.
  ///
  /// In en, this message translates to:
  /// **'Impact Summary'**
  String get migrationWizardImpactSummary;

  /// No description provided for @migrationWizardFromProfile.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get migrationWizardFromProfile;

  /// No description provided for @migrationWizardToProfile.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get migrationWizardToProfile;

  /// No description provided for @migrationWizardAffectedExercises.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise affected} other{{count} exercises affected}}'**
  String migrationWizardAffectedExercises(int count);

  /// No description provided for @migrationWizardWithAlternatives.
  ///
  /// In en, this message translates to:
  /// **'with alternatives'**
  String get migrationWizardWithAlternatives;

  /// No description provided for @migrationWizardWithoutAlternatives.
  ///
  /// In en, this message translates to:
  /// **'without alternatives'**
  String get migrationWizardWithoutAlternatives;

  /// No description provided for @migrationWizardAffectedRoutines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 routine} other{{count} routines}}'**
  String migrationWizardAffectedRoutines(int count);

  /// No description provided for @migrationWizardAffectedTemplates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template} other{{count} templates}}'**
  String migrationWizardAffectedTemplates(int count);

  /// No description provided for @migrationWizardReviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Review Changes'**
  String get migrationWizardReviewChanges;

  /// No description provided for @migrationWizardNoImpact.
  ///
  /// In en, this message translates to:
  /// **'No exercises are affected by this change.'**
  String get migrationWizardNoImpact;

  /// No description provided for @migrationWizardNoImpactMessage.
  ///
  /// In en, this message translates to:
  /// **'All your exercises are compatible with the new equipment profile.'**
  String get migrationWizardNoImpactMessage;

  /// No description provided for @migrationWizardExerciseReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Exercise'**
  String get migrationWizardExerciseReviewTitle;

  /// No description provided for @migrationWizardExerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String migrationWizardExerciseProgress(int current, int total);

  /// No description provided for @migrationWizardRequiredEquipment.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String migrationWizardRequiredEquipment(Object equipment);

  /// No description provided for @migrationWizardUsedIn.
  ///
  /// In en, this message translates to:
  /// **'Used in'**
  String get migrationWizardUsedIn;

  /// No description provided for @migrationWizardSuggestedAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Suggested Alternatives'**
  String get migrationWizardSuggestedAlternatives;

  /// No description provided for @migrationWizardNoAlternatives.
  ///
  /// In en, this message translates to:
  /// **'No compatible alternatives found'**
  String get migrationWizardNoAlternatives;

  /// No description provided for @migrationWizardNoAlternativesMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider keeping this exercise if you plan to get the equipment, or remove it.'**
  String get migrationWizardNoAlternativesMessage;

  /// No description provided for @migrationWizardSimilarityScore.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String migrationWizardSimilarityScore(Object score);

  /// No description provided for @migrationWizardReplaceWith.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get migrationWizardReplaceWith;

  /// No description provided for @migrationWizardKeepExercise.
  ///
  /// In en, this message translates to:
  /// **'Keep anyway'**
  String get migrationWizardKeepExercise;

  /// No description provided for @migrationWizardKeepExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'I\'ll get this equipment'**
  String get migrationWizardKeepExerciseHint;

  /// No description provided for @migrationWizardRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get migrationWizardRemoveExercise;

  /// No description provided for @migrationWizardConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Changes'**
  String get migrationWizardConfirmationTitle;

  /// No description provided for @migrationWizardConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Review your decisions before applying'**
  String get migrationWizardConfirmationMessage;

  /// No description provided for @migrationWizardSummaryReplaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get migrationWizardSummaryReplaced;

  /// No description provided for @migrationWizardSummaryKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get migrationWizardSummaryKept;

  /// No description provided for @migrationWizardSummaryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get migrationWizardSummaryRemoved;

  /// No description provided for @migrationWizardWillUpdate.
  ///
  /// In en, this message translates to:
  /// **'This will update'**
  String get migrationWizardWillUpdate;

  /// No description provided for @migrationWizardApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get migrationWizardApplyChanges;

  /// No description provided for @migrationWizardApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying changes...'**
  String get migrationWizardApplying;

  /// No description provided for @migrationWizardSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration Complete!'**
  String get migrationWizardSuccessTitle;

  /// No description provided for @migrationWizardSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your equipment profile has been updated.'**
  String get migrationWizardSuccessMessage;

  /// No description provided for @migrationWizardChangesApplied.
  ///
  /// In en, this message translates to:
  /// **'Changes applied'**
  String get migrationWizardChangesApplied;

  /// No description provided for @migrationWizardExercisesReplaced.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise replaced} other{{count} exercises replaced}}'**
  String migrationWizardExercisesReplaced(int count);

  /// No description provided for @migrationWizardExercisesKept.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise kept} other{{count} exercises kept}}'**
  String migrationWizardExercisesKept(int count);

  /// No description provided for @migrationWizardExercisesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise removed} other{{count} exercises removed}}'**
  String migrationWizardExercisesRemoved(int count);

  /// No description provided for @migrationWizardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get migrationWizardUpdated;

  /// No description provided for @migrationWizardAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing impact...'**
  String get migrationWizardAnalyzing;

  /// No description provided for @migrationWizardScanningRoutines.
  ///
  /// In en, this message translates to:
  /// **'Scanning active routines'**
  String get migrationWizardScanningRoutines;

  /// No description provided for @migrationWizardScanningTemplates.
  ///
  /// In en, this message translates to:
  /// **'Scanning workout templates'**
  String get migrationWizardScanningTemplates;

  /// No description provided for @migrationWizardFindingAffected.
  ///
  /// In en, this message translates to:
  /// **'Finding affected exercises'**
  String get migrationWizardFindingAffected;

  /// No description provided for @migrationWizardGeneratingAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Generating alternatives'**
  String get migrationWizardGeneratingAlternatives;

  /// No description provided for @migrationWizardImpactSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Migration Impact Summary'**
  String get migrationWizardImpactSummaryTitle;

  /// No description provided for @migrationWizardTotalAffected.
  ///
  /// In en, this message translates to:
  /// **'Total Affected:'**
  String get migrationWizardTotalAffected;

  /// No description provided for @migrationWizardExercisesWithAlternatives.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 with alternatives} other{{count} with alternatives}}'**
  String migrationWizardExercisesWithAlternatives(int count);

  /// No description provided for @migrationWizardExercisesWithoutAlternatives.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 without alternatives} other{{count} without alternatives}}'**
  String migrationWizardExercisesWithoutAlternatives(int count);

  /// No description provided for @migrationWizardImpactLabel.
  ///
  /// In en, this message translates to:
  /// **'Impact:'**
  String get migrationWizardImpactLabel;

  /// No description provided for @migrationWizardNoImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'No Impact'**
  String get migrationWizardNoImpactTitle;

  /// No description provided for @migrationWizardContinueToReview.
  ///
  /// In en, this message translates to:
  /// **'Continue to Review'**
  String get migrationWizardContinueToReview;

  /// No description provided for @migrationWizardSkipToConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Skip to Confirmation'**
  String get migrationWizardSkipToConfirmation;

  /// No description provided for @migrationWizardExerciseXOfY.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String migrationWizardExerciseXOfY(int current, int total);

  /// No description provided for @migrationWizardNoAlternativesFound.
  ///
  /// In en, this message translates to:
  /// **'No compatible alternatives found'**
  String get migrationWizardNoAlternativesFound;

  /// No description provided for @migrationWizardPreviousExercise.
  ///
  /// In en, this message translates to:
  /// **'Previous Exercise'**
  String get migrationWizardPreviousExercise;

  /// No description provided for @migrationWizardNextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next Exercise'**
  String get migrationWizardNextExercise;

  /// No description provided for @migrationWizardDecisionsSummary.
  ///
  /// In en, this message translates to:
  /// **'Decisions Summary:'**
  String get migrationWizardDecisionsSummary;

  /// No description provided for @migrationWizardReplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace: {original} → {replacement}'**
  String migrationWizardReplaceAction(String original, String replacement);

  /// No description provided for @migrationWizardKeepAction.
  ///
  /// In en, this message translates to:
  /// **'Keep: {exercise}'**
  String migrationWizardKeepAction(String exercise);

  /// No description provided for @migrationWizardRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove: {exercise}'**
  String migrationWizardRemoveAction(String exercise);

  /// No description provided for @migrationWizardBackToReview.
  ///
  /// In en, this message translates to:
  /// **'Back to Review'**
  String get migrationWizardBackToReview;

  /// No description provided for @migrationWizardApplyingChanges.
  ///
  /// In en, this message translates to:
  /// **'Applying changes...'**
  String get migrationWizardApplyingChanges;

  /// No description provided for @migrationWizardRoutinesUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 routine updated} other{{count} routines updated}}'**
  String migrationWizardRoutinesUpdated(int count);

  /// No description provided for @migrationWizardTemplatesUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template updated} other{{count} templates updated}}'**
  String migrationWizardTemplatesUpdated(int count);

  /// No description provided for @migrationWizardProfileSwitched.
  ///
  /// In en, this message translates to:
  /// **'Profile switched to: {profileName}'**
  String migrationWizardProfileSwitched(String profileName);

  /// No description provided for @migrationWizardDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get migrationWizardDone;

  /// No description provided for @migrationWizardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Migration'**
  String get migrationWizardCancel;

  /// No description provided for @migrationWizardCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Migration?'**
  String get migrationWizardCancelConfirmTitle;

  /// No description provided for @migrationWizardCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your decisions will not be saved and the equipment profile will not be changed.'**
  String get migrationWizardCancelConfirmMessage;

  /// No description provided for @migrationWizardProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String migrationWizardProgress(int percent);

  /// No description provided for @migrationWizardError.
  ///
  /// In en, this message translates to:
  /// **'Error during migration: {error}'**
  String migrationWizardError(String error);

  /// No description provided for @migrationWizardRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get migrationWizardRetry;

  /// Title for auto-shift confirmation banner
  ///
  /// In en, this message translates to:
  /// **'Routine Auto-Shifted'**
  String get routineShiftTitle;

  /// Message explaining the auto-shift
  ///
  /// In en, this message translates to:
  /// **'We shifted \'{workoutName}\' to {date}. Confirm or skip permanently?'**
  String routineShiftMessage(String workoutName, String date);

  /// Button to confirm the auto-shift (recommended)
  ///
  /// In en, this message translates to:
  /// **'OK, keep shift'**
  String get routineShiftConfirm;

  /// Button to revert shift and skip permanently (not recommended)
  ///
  /// In en, this message translates to:
  /// **'Skip permanently'**
  String get routineShiftRevert;

  /// Success message after confirming shift
  ///
  /// In en, this message translates to:
  /// **'Shift confirmed successfully'**
  String get routineShiftConfirmed;

  /// Error message when confirm fails
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm shift'**
  String get routineShiftConfirmFailed;

  /// Success message after reverting shift
  ///
  /// In en, this message translates to:
  /// **'Shift reverted, workout skipped'**
  String get routineShiftReverted;

  /// Error message when revert fails
  ///
  /// In en, this message translates to:
  /// **'Failed to revert shift'**
  String get routineShiftRevertFailed;

  /// Dialog title for confirming permanent skip
  ///
  /// In en, this message translates to:
  /// **'Skip Permanently?'**
  String get routineShiftRevertConfirmTitle;

  /// Dialog message warning about permanent skip
  ///
  /// In en, this message translates to:
  /// **'This will undo the shift and mark the workout as skipped. This is not recommended. Are you sure?'**
  String get routineShiftRevertConfirmMessage;

  /// Date format for routine shift banner
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year}'**
  String routineDateFormat(int day, int month, int year);

  /// Title for exercise rotation config step in wizard
  ///
  /// In en, this message translates to:
  /// **'Exercise Variation Rotation'**
  String get exerciseRotationTitle;

  /// Subtitle explaining exercise rotation benefits
  ///
  /// In en, this message translates to:
  /// **'Automatically rotate exercise variations every few weeks to keep your workouts fresh and prevent adaptation'**
  String get exerciseRotationSubtitle;

  /// Menu option to change/replace exercise with a variation or different exercise
  ///
  /// In en, this message translates to:
  /// **'Change Exercise'**
  String get exerciseChangeVariation;

  /// Success message after changing exercise
  ///
  /// In en, this message translates to:
  /// **'Exercise changed successfully'**
  String get exerciseChangeVariationSuccess;

  /// Banner title when rotation is ready to apply
  ///
  /// In en, this message translates to:
  /// **'Rotation Due Now!'**
  String get rotationDueNow;

  /// Banner title showing when next rotation will occur
  ///
  /// In en, this message translates to:
  /// **'Next Rotation Scheduled'**
  String get rotationNextScheduled;

  /// Text shown when rotation is due
  ///
  /// In en, this message translates to:
  /// **'Ready to apply new exercise variations'**
  String get rotationReadyToApply;

  /// Button to apply rotation immediately when due
  ///
  /// In en, this message translates to:
  /// **'Apply Rotation Now'**
  String get rotationApplyNow;

  /// Button to apply rotation before scheduled date
  ///
  /// In en, this message translates to:
  /// **'Apply Early'**
  String get rotationApplyEarly;

  /// Shows weeks until rotation
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{In 1 week} other{In {weeks} weeks}}'**
  String rotationInWeeks(int weeks);

  /// Confirmation message before applying rotation
  ///
  /// In en, this message translates to:
  /// **'This will change all exercise variations in your routine. This action cannot be undone. Continue?'**
  String get rotationApplyConfirmMessage;

  /// Success message after rotation is applied
  ///
  /// In en, this message translates to:
  /// **'Rotation applied successfully! All exercise variations have been updated.'**
  String get rotationAppliedSuccess;

  /// Error message when rotation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to apply rotation. Please try again.'**
  String get rotationAppliedError;

  /// Message shown when settings are successfully saved
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Message shown when no similar exercises are available for replacement
  ///
  /// In en, this message translates to:
  /// **'No similar exercises found'**
  String get noSimilarExercisesFound;

  /// Filter label for exercises targeting the same muscle group
  ///
  /// In en, this message translates to:
  /// **'Same muscle group'**
  String get sameMuscleGroup;

  /// Filter label for exercises using the same equipment
  ///
  /// In en, this message translates to:
  /// **'Same equipment'**
  String get sameEquipment;

  /// Label for favorite exercises filter
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Label for showing all exercise categories
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// Label for showing all equipment types
  ///
  /// In en, this message translates to:
  /// **'All equipment'**
  String get allEquipment;

  /// Header text for exercise replacement dialog
  ///
  /// In en, this message translates to:
  /// **'Replace this exercise with:'**
  String get replaceExerciseWith;

  /// Title for skip workout dialog
  ///
  /// In en, this message translates to:
  /// **'Skip Workout'**
  String get skipWorkoutTitle;

  /// Warning message for consecutive skips
  ///
  /// In en, this message translates to:
  /// **'You have {count} consecutive skip(s). Consider recovering them to maintain consistency.'**
  String skipConsecutiveWarning(int count);

  /// Question asking reason for skip
  ///
  /// In en, this message translates to:
  /// **'Why are you skipping?'**
  String get skipWhyQuestion;

  /// Question asking user choice for skip action
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get skipWhatToDo;

  /// Title for recover option
  ///
  /// In en, this message translates to:
  /// **'Recover (+1 day)'**
  String get skipRecoverTitle;

  /// Subtitle explaining recover option
  ///
  /// In en, this message translates to:
  /// **'Shift entire routine by 1 day to recover this workout'**
  String get skipRecoverSubtitle;

  /// Title for skip permanently option
  ///
  /// In en, this message translates to:
  /// **'Skip permanently'**
  String get skipPermanentlyTitle;

  /// Subtitle explaining skip permanently option
  ///
  /// In en, this message translates to:
  /// **'Skip this workout completely (cannot be recovered)'**
  String get skipPermanentlySubtitle;

  /// Label for optional notes field
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get skipAdditionalNotes;

  /// Hint text for notes field
  ///
  /// In en, this message translates to:
  /// **'e.g., Feeling under the weather...'**
  String get skipNotesHint;

  /// Title for impact preview section
  ///
  /// In en, this message translates to:
  /// **'Impact on your progress'**
  String get skipImpactTitle;

  /// Label for current streak
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get skipCurrentStreak;

  /// Message indicating streak will be lost
  ///
  /// In en, this message translates to:
  /// **'Will be lost'**
  String get skipWillBeLost;

  /// Label for adherence rate
  ///
  /// In en, this message translates to:
  /// **'Adherence Rate'**
  String get skipAdherenceRate;

  /// Label for days count
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String skipDaysLabel(int count);

  /// Skip reason: sick
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get skipReasonSick;

  /// Skip reason: injury
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get skipReasonInjury;

  /// Skip reason: busy
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get skipReasonBusy;

  /// Skip reason: tired
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get skipReasonTired;

  /// Skip reason: travel
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get skipReasonTravel;

  /// Skip reason: weather
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get skipReasonWeather;

  /// Skip reason: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get skipReasonOther;

  /// Title for rotation preview dialog
  ///
  /// In en, this message translates to:
  /// **'Preview Rotation Changes'**
  String get rotationPreviewTitle;

  /// Button to select all exercises for rotation
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get rotationSelectAll;

  /// Button to deselect all exercises for rotation
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get rotationDeselectAll;

  /// Label showing number of selected exercises
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String rotationSelectedCount(int selected, int total);

  /// Label for current variation
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get rotationCurrentLabel;

  /// Label for new variation
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get rotationNewLabel;

  /// Button to confirm and apply rotation changes
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get rotationApplyChanges;

  /// Badge text for new personal records
  ///
  /// In en, this message translates to:
  /// **'NEW RECORD!'**
  String get newRecordBadge;

  /// Title for progress trend chart section
  ///
  /// In en, this message translates to:
  /// **'Progress Trend'**
  String get progressTrend;

  /// Title for statistics breakdown section
  ///
  /// In en, this message translates to:
  /// **'Stats Breakdown'**
  String get statsBreakdown;

  /// Title for comparison and context section
  ///
  /// In en, this message translates to:
  /// **'Comparison & Context'**
  String get comparisonAndContext;

  /// Title for notes and media section
  ///
  /// In en, this message translates to:
  /// **'Notes & Media'**
  String get notesAndMedia;

  /// Title for related workout sessions section
  ///
  /// In en, this message translates to:
  /// **'Related Sessions'**
  String get relatedSessions;

  /// Placeholder message for share feature
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon'**
  String get shareFunctionalityComingSoon;

  /// Placeholder message for edit feature
  ///
  /// In en, this message translates to:
  /// **'Edit functionality coming soon'**
  String get editFunctionalityComingSoon;

  /// Title for delete record confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecordTitle;

  /// Confirmation message for deleting a personal record
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this personal record?'**
  String get deleteRecordConfirmation;

  /// Label for weight relative to bodyweight
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Multiplier'**
  String get bodyweightMultiplier;

  /// Label for estimated one-rep max
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get estimatedOneRM;

  /// Subtitle explaining bodyweight multiplier
  ///
  /// In en, this message translates to:
  /// **'Relative to {weight} kg bodyweight'**
  String relativeToBodyweight(String weight);

  /// Subtitle explaining 1RM calculation method
  ///
  /// In en, this message translates to:
  /// **'Using Brzycki formula'**
  String get usingBrzyckiFormula;

  /// Subtitle explaining volume calculation
  ///
  /// In en, this message translates to:
  /// **'Total weight × reps'**
  String get totalWeightReps;

  /// Message shown when no trend data exists
  ///
  /// In en, this message translates to:
  /// **'No trend data available'**
  String get noTrendDataAvailable;

  /// Label for 30 days time range
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get timeRangeLabel30D;

  /// Label for 90 days time range
  ///
  /// In en, this message translates to:
  /// **'90D'**
  String get timeRangeLabel90D;

  /// Label for all time range
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get timeRangeLabelAll;

  /// Format for days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Format for weeks ago
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String weeksAgo(String weeks);

  /// Format for months ago
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String monthsAgo(String months);

  /// Short format for days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String dAgo(String days);

  /// Short format for number of sets
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCountShort(String count);

  /// Format for volume in tons
  ///
  /// In en, this message translates to:
  /// **'{value}t volume'**
  String volumeInTons(String value);

  /// Label for kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kgLabel;

  /// Debug logs settings screen title
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get debugLogsTitle;

  /// Debug logs settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure logging categories'**
  String get debugLogsSubtitle;

  /// Debug logs settings description
  ///
  /// In en, this message translates to:
  /// **'Enable or disable specific log categories to reduce console noise during debugging. All categories are disabled by default.'**
  String get debugLogsDescription;

  /// Button to enable all log categories
  ///
  /// In en, this message translates to:
  /// **'Enable All'**
  String get debugLogsEnableAll;

  /// Button to disable all log categories
  ///
  /// In en, this message translates to:
  /// **'Disable All'**
  String get debugLogsDisableAll;

  /// Shows count of enabled log categories
  ///
  /// In en, this message translates to:
  /// **'{count} enabled'**
  String debugLogsEnabledCount(int count);

  /// Section title for log categories list
  ///
  /// In en, this message translates to:
  /// **'Log Categories'**
  String get debugLogsCategoriesTitle;

  /// Snackbar message when all logs enabled
  ///
  /// In en, this message translates to:
  /// **'All logs enabled successfully'**
  String get debugLogsAllEnabled;

  /// Snackbar message when all logs disabled
  ///
  /// In en, this message translates to:
  /// **'All logs disabled successfully'**
  String get debugLogsAllDisabled;

  /// Snackbar message when a category is enabled
  ///
  /// In en, this message translates to:
  /// **'{category} enabled'**
  String debugLogsCategoryEnabled(String category);

  /// Snackbar message when a category is disabled
  ///
  /// In en, this message translates to:
  /// **'{category} disabled'**
  String debugLogsCategoryDisabled(String category);

  /// Counting mode for weighted exercises
  ///
  /// In en, this message translates to:
  /// **'Weight + Reps'**
  String get countingModeWeighted;

  /// Counting mode for bodyweight exercises
  ///
  /// In en, this message translates to:
  /// **'Reps Only'**
  String get countingModeReps;

  /// Counting mode for time-based exercises
  ///
  /// In en, this message translates to:
  /// **'Time-based'**
  String get countingModeTime;

  /// Data refreshed successfully status message
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get refreshed;

  /// Database version information section title
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get versionInformation;

  /// Title for Quick Start screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to GymBro!'**
  String get quickStartTitle;

  /// Subtitle for Quick Start screen
  ///
  /// In en, this message translates to:
  /// **'Your personalized fitness journey starts here'**
  String get quickStartSubtitle;

  /// Quick Start question asking about user experience
  ///
  /// In en, this message translates to:
  /// **'Do you have gym experience?'**
  String get quickStartQuestion;

  /// Description for Quick Start question
  ///
  /// In en, this message translates to:
  /// **'This helps us customize your experience'**
  String get quickStartQuestionDescription;

  /// Beginner option in Quick Start
  ///
  /// In en, this message translates to:
  /// **'No, I\'m new 🌱'**
  String get quickStartBeginner;

  /// Description for beginner option
  ///
  /// In en, this message translates to:
  /// **'I\'ll guide you step-by-step'**
  String get quickStartBeginnerDescription;

  /// Expert option in Quick Start
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m experienced 💪'**
  String get quickStartExpert;

  /// Description for expert option
  ///
  /// In en, this message translates to:
  /// **'Get out of my way'**
  String get quickStartExpertDescription;

  /// Continue button in Quick Start
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quickStartContinue;

  /// Skip button in Quick Start
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get quickStartSkip;

  /// Home empty state title for beginners
  ///
  /// In en, this message translates to:
  /// **'Ready to start your fitness journey? 🌱'**
  String get homeEmptyBeginnerTitle;

  /// Home empty state description for beginners
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, I\'ll guide you through every step. Let\'s start with your first workout!'**
  String get homeEmptyBeginnerDescription;

  /// Home empty state CTA button for beginners
  ///
  /// In en, this message translates to:
  /// **'Start My First Workout'**
  String get homeEmptyBeginnerCTA;

  /// Home empty state title for experts
  ///
  /// In en, this message translates to:
  /// **'No active workout'**
  String get homeEmptyExpertTitle;

  /// Home empty state description for experts
  ///
  /// In en, this message translates to:
  /// **'Start a quick workout or use a template'**
  String get homeEmptyExpertDescription;

  /// Home empty state CTA button for experts
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get homeEmptyExpertCTA;

  /// Button to use a workout template
  ///
  /// In en, this message translates to:
  /// **'Use Template'**
  String get useTemplate;

  /// Semantic label for bullet points
  ///
  /// In en, this message translates to:
  /// **'Bullet point'**
  String get bullet;

  /// Skip tour button
  ///
  /// In en, this message translates to:
  /// **'Skip Tour'**
  String get skipTour;

  /// Auto-advance semantic label
  ///
  /// In en, this message translates to:
  /// **'Auto-advance'**
  String get autoAdvance;

  /// Auto-advance countdown
  ///
  /// In en, this message translates to:
  /// **'Auto-advance in {seconds}s'**
  String autoAdvanceIn(int seconds);

  /// Tour step 1 title - AI Coach
  ///
  /// In en, this message translates to:
  /// **'AI Coach 👋'**
  String get tourAiCoachTitle;

  /// Tour step 1 description - AI Coach
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your AI Coach.\nI\'ll give you personalized tips after your first workout!'**
  String get tourAiCoachDescription;

  /// Tour step 2 title - FAB
  ///
  /// In en, this message translates to:
  /// **'Quick Start ⚡'**
  String get tourFabTitle;

  /// Tour step 2 description - FAB
  ///
  /// In en, this message translates to:
  /// **'Press here to start a workout quickly.\nIt\'s the easiest way to track your progress!'**
  String get tourFabDescription;

  /// Tour step 3 title - Smart Workout
  ///
  /// In en, this message translates to:
  /// **'Smart Workout 🧠'**
  String get tourSmartWorkoutTitle;

  /// Tour step 3 description - Smart Workout
  ///
  /// In en, this message translates to:
  /// **'Or let me create the perfect workout for you based on your goals!'**
  String get tourSmartWorkoutDescription;

  /// Tour step 4 title - Analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics - Your Progress 📊'**
  String get tourAnalyticsTitle;

  /// Tour step 4 description - Analytics
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll find detailed charts of:'**
  String get tourAnalyticsDescription;

  /// Tour step 4 bullet 1
  ///
  /// In en, this message translates to:
  /// **'Total volume per workout'**
  String get tourAnalyticsBullet1;

  /// Tour step 4 bullet 2
  ///
  /// In en, this message translates to:
  /// **'Strength per exercise (estimated 1RM)'**
  String get tourAnalyticsBullet2;

  /// Tour step 4 bullet 3
  ///
  /// In en, this message translates to:
  /// **'Personal records and improvements'**
  String get tourAnalyticsBullet3;

  /// Tour step 5 title - History
  ///
  /// In en, this message translates to:
  /// **'Workout History 📅'**
  String get tourHistoryTitle;

  /// Tour step 5 description - History
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll find your complete workout history.\nReview past sessions and track your consistency!'**
  String get tourHistoryDescription;

  /// Tour step 6 title - Routine Center
  ///
  /// In en, this message translates to:
  /// **'Routine Center - Advanced Training 🏋️'**
  String get tourRoutineCenterTitle;

  /// Tour step 6 description - Routine Center
  ///
  /// In en, this message translates to:
  /// **'Create multi-week programs with:'**
  String get tourRoutineCenterDescription;

  /// Tour step 6 bullet 1
  ///
  /// In en, this message translates to:
  /// **'Periodization (strength → hypertrophy → deload)'**
  String get tourRoutineCenterBullet1;

  /// Tour step 6 bullet 2
  ///
  /// In en, this message translates to:
  /// **'Automatic template swapping'**
  String get tourRoutineCenterBullet2;

  /// Tour step 6 bullet 3
  ///
  /// In en, this message translates to:
  /// **'Progress tracking for each phase'**
  String get tourRoutineCenterBullet3;

  /// Tour step 7 title - Community
  ///
  /// In en, this message translates to:
  /// **'Community 🤝'**
  String get tourCommunityTitle;

  /// Tour step 7 description - Community
  ///
  /// In en, this message translates to:
  /// **'Connect with other athletes for motivation and support!'**
  String get tourCommunityDescription;

  /// Tour step 8 title - Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications 🔔'**
  String get tourNotificationsTitle;

  /// Tour step 8 description - Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications will keep you updated on milestones and tips!'**
  String get tourNotificationsDescription;

  /// Title for AI workout suggestion card
  ///
  /// In en, this message translates to:
  /// **'Suggested Next Workout'**
  String get suggestedNextWorkout;

  /// Button to start suggested workout
  ///
  /// In en, this message translates to:
  /// **'Start This Workout'**
  String get startThisWorkout;

  /// Button to show alternative workout suggestions
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// Button to explain reasoning behind suggestion
  ///
  /// In en, this message translates to:
  /// **'Why This Suggestion?'**
  String get whyThisSuggestion;

  /// Label for suggestion confidence level
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Badge for pattern-based suggestion level
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get levelPattern;

  /// Badge for routine-based suggestion level
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get levelRoutine;

  /// Badge for frequency-based suggestion level
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get levelFrequent;

  /// Badge for day-based (default) suggestion level
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get levelDefault;

  /// Badge when suggesting alternative template
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get levelAlternative;

  /// Empty state title when user has no workout history
  ///
  /// In en, this message translates to:
  /// **'Not enough workout data yet'**
  String get notEnoughWorkoutData;

  /// Empty state message explaining minimum workouts needed
  ///
  /// In en, this message translates to:
  /// **'Complete at least 6 workouts to get personalized suggestions'**
  String get completeWorkoutsForSuggestions;

  /// Button to create new workout from empty state
  ///
  /// In en, this message translates to:
  /// **'Create Workout'**
  String get createWorkout;

  /// Loading message while analyzing workout history
  ///
  /// In en, this message translates to:
  /// **'Analyzing your workout pattern...'**
  String get analyzingWorkoutPattern;

  /// Error message when suggestion generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate workout suggestion'**
  String get workoutSuggestionError;

  /// Button/title to pause a routine
  ///
  /// In en, this message translates to:
  /// **'Pause Routine'**
  String get pauseRoutine;

  /// Modal title for pause routine dialog
  ///
  /// In en, this message translates to:
  /// **'Pause This Routine'**
  String get pauseRoutineTitle;

  /// Description in pause routine modal
  ///
  /// In en, this message translates to:
  /// **'Your routine will be paused during this period. You won\'t receive workout reminders.'**
  String get pauseRoutineDescription;

  /// Label for pause reason selection
  ///
  /// In en, this message translates to:
  /// **'Reason for pause'**
  String get pauseReason;

  /// Pause reason: Injury
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get pauseReasonInjury;

  /// Pause reason: Sick or illness
  ///
  /// In en, this message translates to:
  /// **'Sick/Illness'**
  String get pauseReasonSick;

  /// Pause reason: Vacation or travel
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get pauseReasonVacation;

  /// Pause reason: Work or life busy period
  ///
  /// In en, this message translates to:
  /// **'Too Busy'**
  String get pauseReasonBusy;

  /// Pause reason: Mental health or burnout
  ///
  /// In en, this message translates to:
  /// **'Burnout'**
  String get pauseReasonBurnout;

  /// Pause reason: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pauseReasonOther;

  /// Label for pause start date picker
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// Label for pause end date picker
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Label for optional pause notes field
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get pauseNotes;

  /// Hint text for pause notes field
  ///
  /// In en, this message translates to:
  /// **'E.g., Shoulder injury - avoid overhead pressing'**
  String get pauseNotesHint;

  /// Button to confirm pause creation
  ///
  /// In en, this message translates to:
  /// **'Pause Routine'**
  String get confirmPause;

  /// Badge showing routine is paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedBadge;

  /// Shows when pause ends
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String pausedUntil(String date);

  /// Label for days until next milestone
  ///
  /// In en, this message translates to:
  /// **'days remaining'**
  String get daysRemaining;

  /// Button to manually resume a paused routine
  ///
  /// In en, this message translates to:
  /// **'Resume Routine'**
  String get resumeRoutine;

  /// Success message when routine is resumed
  ///
  /// In en, this message translates to:
  /// **'Routine resumed!'**
  String get routineResumed;

  /// Validation error: start date is in past
  ///
  /// In en, this message translates to:
  /// **'Start date cannot be in the past'**
  String get pauseValidationStartInPast;

  /// Validation error: end date before start date
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get pauseValidationEndBeforeStart;

  /// Validation error: pause too long
  ///
  /// In en, this message translates to:
  /// **'Pause duration cannot exceed {maxDays} days'**
  String pauseValidationTooLong(int maxDays);

  /// Validation error: overlapping pause exists
  ///
  /// In en, this message translates to:
  /// **'Routine already paused until {date}'**
  String pauseValidationOverlap(String date);

  /// Dialog title for workout conflicts
  ///
  /// In en, this message translates to:
  /// **'Scheduled Workouts in Pause Range'**
  String get conflictingWorkouts;

  /// Message showing count of conflicting workouts
  ///
  /// In en, this message translates to:
  /// **'You have {count} workouts scheduled during this pause. They will be automatically skipped.'**
  String conflictingWorkoutsMessage(int count);

  /// Button to confirm pause despite conflicts
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pause'**
  String get confirmAndPause;

  /// Placeholder when no date selected
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Generic pause label
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Success message when routine is paused
  ///
  /// In en, this message translates to:
  /// **'Routine paused successfully'**
  String get routinePaused;

  /// Success message after creating a template from routine editor empty state
  ///
  /// In en, this message translates to:
  /// **'Template created! Select it below to continue.'**
  String get routineTemplateCreatedSuccess;

  /// Level system header
  ///
  /// In en, this message translates to:
  /// **'Level System'**
  String get levelSystem;

  /// Current level label
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// Progress indicator suffix
  ///
  /// In en, this message translates to:
  /// **'to next level'**
  String get toNextLevel;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Badge label indicating current selection
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Default level name
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get elite;

  /// Level 2 name
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get novice;

  /// Level 5 name
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// Level 6 name
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// Level 7 name
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get grandmaster;

  /// Level 8 name
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get champion;

  /// Level 9 name
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// Level 10 name
  ///
  /// In en, this message translates to:
  /// **'Titan'**
  String get titan;

  /// Level 1 description
  ///
  /// In en, this message translates to:
  /// **'You\'re just getting started! Complete your first workouts to level up.'**
  String get levelDesc1;

  /// Level 2 description
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed your first workouts. Keep the momentum going!'**
  String get levelDesc2;

  /// Level 3 description
  ///
  /// In en, this message translates to:
  /// **'You\'re building solid workout habits. Consistency is key!'**
  String get levelDesc3;

  /// Level 4 description
  ///
  /// In en, this message translates to:
  /// **'Advanced lifter! Your dedication shows in your progress.'**
  String get levelDesc4;

  /// Level 5 description
  ///
  /// In en, this message translates to:
  /// **'Expert level achieved! You\'re mastering your training.'**
  String get levelDesc5;

  /// Level 6 description
  ///
  /// In en, this message translates to:
  /// **'Master of fitness! Your consistency inspires others.'**
  String get levelDesc6;

  /// Level 7 description
  ///
  /// In en, this message translates to:
  /// **'Grandmaster status! Few reach this level of dedication.'**
  String get levelDesc7;

  /// Level 8 description
  ///
  /// In en, this message translates to:
  /// **'Champion! You\'re in the top tier of athletes.'**
  String get levelDesc8;

  /// Level 9 description
  ///
  /// In en, this message translates to:
  /// **'Legendary status! Your discipline is unmatched.'**
  String get levelDesc9;

  /// Level 10 description
  ///
  /// In en, this message translates to:
  /// **'Titan! The ultimate level of fitness mastery.'**
  String get levelDesc10;

  /// Level 1 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Track your first workouts'**
  String get benefit1_1;

  /// Level 1 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of progress tracking'**
  String get benefit1_2;

  /// Level 2 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Unlock workout analytics'**
  String get benefit2_1;

  /// Level 2 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Access basic progress charts'**
  String get benefit2_2;

  /// Level 3 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Advanced exercise library access'**
  String get benefit3_1;

  /// Level 3 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Workout templates available'**
  String get benefit3_2;

  /// Level 3 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Custom workout creation'**
  String get benefit3_3;

  /// Level 4 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Personal records tracking'**
  String get benefit4_1;

  /// Level 4 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics dashboard'**
  String get benefit4_2;

  /// Level 4 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Volume and intensity insights'**
  String get benefit4_3;

  /// Level 5 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Expert workout recommendations'**
  String get benefit5_1;

  /// Level 5 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Periodization suggestions'**
  String get benefit5_2;

  /// Level 5 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Recovery optimization'**
  String get benefit5_3;

  /// Level 6 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Master-level training programs'**
  String get benefit6_1;

  /// Level 6 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Advanced progression tracking'**
  String get benefit6_2;

  /// Level 6 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Muscle group balance analysis'**
  String get benefit6_3;

  /// Level 7 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Elite training protocols'**
  String get benefit7_1;

  /// Level 7 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Competition preparation tools'**
  String get benefit7_2;

  /// Level 7 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Performance optimization'**
  String get benefit7_3;

  /// Level 8 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Champion workout strategies'**
  String get benefit8_1;

  /// Level 8 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Peak performance planning'**
  String get benefit8_2;

  /// Level 8 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Advanced recovery protocols'**
  String get benefit8_3;

  /// Level 9 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Legendary training methods'**
  String get benefit9_1;

  /// Level 9 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Pro-level analytics'**
  String get benefit9_2;

  /// Level 9 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Ultimate performance tracking'**
  String get benefit9_3;

  /// Level 10 benefit 1
  ///
  /// In en, this message translates to:
  /// **'Titan workout mastery'**
  String get benefit10_1;

  /// Level 10 benefit 2
  ///
  /// In en, this message translates to:
  /// **'Complete training ecosystem'**
  String get benefit10_2;

  /// Level 10 benefit 3
  ///
  /// In en, this message translates to:
  /// **'Maximum potential unlocked'**
  String get benefit10_3;

  /// Average effort level metric
  ///
  /// In en, this message translates to:
  /// **'Average Effort Level'**
  String get averageEffortLevel;

  /// Fitness level label
  ///
  /// In en, this message translates to:
  /// **'Fitness Level'**
  String get fitnessLevel;

  /// Display option for level and XP
  ///
  /// In en, this message translates to:
  /// **'Level & XP Only'**
  String get levelAndXpOnly;

  /// Level requirement message
  ///
  /// In en, this message translates to:
  /// **'Level {level} Required'**
  String levelRequired(int level);

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Velocity analytics section title
  ///
  /// In en, this message translates to:
  /// **'Velocity Analytics'**
  String get velocityAnalytics;

  /// Performance heatmap title
  ///
  /// In en, this message translates to:
  /// **'Performance Heatmap'**
  String get performanceHeatmap;

  /// Load-velocity relationship
  ///
  /// In en, this message translates to:
  /// **'Load-Velocity'**
  String get loadVelocity;

  /// Velocity metric
  ///
  /// In en, this message translates to:
  /// **'Velocity'**
  String get velocity;

  /// Load/weight metric
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// Minimum velocity threshold
  ///
  /// In en, this message translates to:
  /// **'Min Velocity'**
  String get minVelocity;

  /// Average velocity loss metric
  ///
  /// In en, this message translates to:
  /// **'Avg Velocity Loss'**
  String get avgVelocityLoss;

  /// Optimal training load
  ///
  /// In en, this message translates to:
  /// **'Optimal Load'**
  String get optimalLoad;

  /// Exercise execution time
  ///
  /// In en, this message translates to:
  /// **'Execution Time'**
  String get executionTime;

  /// Exercise form quality score
  ///
  /// In en, this message translates to:
  /// **'Form Score'**
  String get formScore;

  /// Quality metric
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// Fatigue accumulation metric
  ///
  /// In en, this message translates to:
  /// **'Fatigue Index'**
  String get fatigueIndex;

  /// Explosive training zone
  ///
  /// In en, this message translates to:
  /// **'Explosive Zone'**
  String get explosiveZone;

  /// Speed training zone
  ///
  /// In en, this message translates to:
  /// **'Speed Zone'**
  String get speedZone;

  /// Training zones
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zones;

  /// Loading message for velocity analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing velocity data...'**
  String get analyzingVelocityData;

  /// Error message for missing velocity data
  ///
  /// In en, this message translates to:
  /// **'Insufficient velocity data'**
  String get insufficientVelocityData;

  /// Error message for velocity analysis failure
  ///
  /// In en, this message translates to:
  /// **'Velocity analysis error'**
  String get velocityAnalysisError;

  /// Empty state message for performance data
  ///
  /// In en, this message translates to:
  /// **'No performance data available'**
  String get noPerformanceData;

  /// Empty state instruction
  ///
  /// In en, this message translates to:
  /// **'Start a workout to see data'**
  String get startWorkoutToSeeData;

  /// Key insights section header
  ///
  /// In en, this message translates to:
  /// **'Key Insights'**
  String get keyInsights;

  /// Action hint for expandable content
  ///
  /// In en, this message translates to:
  /// **'Tap for more info'**
  String get tapForMoreInfo;

  /// Action hint to collapse content
  ///
  /// In en, this message translates to:
  /// **'Tap to collapse'**
  String get tapToCollapse;

  /// Help dialog title
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get whatDoesThisMean;

  /// Help section title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// Default help content placeholder
  ///
  /// In en, this message translates to:
  /// **'More information coming soon'**
  String get defaultHelpContent;

  /// Formula/calculation label
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// Example label
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// General tip label
  ///
  /// In en, this message translates to:
  /// **'General Tip'**
  String get generalTip;

  /// Volume metric explanation title
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get volumeExplanation;

  /// Volume metric explanation description
  ///
  /// In en, this message translates to:
  /// **'Total volume = Sets × Reps × Weight. Measures total training load.'**
  String get volumeExplanationDesc;

  /// Volume training tip
  ///
  /// In en, this message translates to:
  /// **'Gradually increase volume by 5-10% per week to avoid overtraining.'**
  String get volumeTip;

  /// Intensity metric explanation title
  ///
  /// In en, this message translates to:
  /// **'Training Intensity'**
  String get intensityExplanation;

  /// Intensity metric explanation description
  ///
  /// In en, this message translates to:
  /// **'Percentage of your one-rep max (1RM) used in training.'**
  String get intensityExplanationDesc;

  /// Intensity training tip
  ///
  /// In en, this message translates to:
  /// **'Vary intensity: 60-75% for volume, 80-90% for strength, 90%+ for power.'**
  String get intensityTip;

  /// Sets metric explanation title
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get setsExplanation;

  /// Sets metric explanation description
  ///
  /// In en, this message translates to:
  /// **'Number of sets performed across all exercises.'**
  String get setsExplanationDesc;

  /// Sets training tip
  ///
  /// In en, this message translates to:
  /// **'Research suggests 10-20 sets per muscle group per week for hypertrophy.'**
  String get setsTip;

  /// Streak metric explanation title
  ///
  /// In en, this message translates to:
  /// **'Workout Streak'**
  String get streakExplanation;

  /// Streak metric explanation description
  ///
  /// In en, this message translates to:
  /// **'Consecutive days with at least one completed workout.'**
  String get streakExplanationDesc;

  /// Streak training tip
  ///
  /// In en, this message translates to:
  /// **'Consistency beats intensity. Even light workouts maintain your streak.'**
  String get streakTip;

  /// 1RM explanation title
  ///
  /// In en, this message translates to:
  /// **'One-Rep Max (1RM)'**
  String get oneRmExplanation;

  /// 1RM explanation description
  ///
  /// In en, this message translates to:
  /// **'Maximum weight you can lift for a single repetition.'**
  String get oneRmExplanationDesc;

  /// 1RM training tip
  ///
  /// In en, this message translates to:
  /// **'Test 1RM every 4-8 weeks to track strength progress safely.'**
  String get oneRmTip;

  /// Total volume help question
  ///
  /// In en, this message translates to:
  /// **'What is Total Volume?'**
  String get whatIsTotalVolume;

  /// Total volume explanation
  ///
  /// In en, this message translates to:
  /// **'Total weight lifted across all sets and reps (Sets × Reps × Weight).'**
  String get totalVolumeExplanation;

  /// Total volume example
  ///
  /// In en, this message translates to:
  /// **'Example: 3 sets × 10 reps × 50kg = 1,500kg total volume'**
  String get totalVolumeExample;

  /// Total sets help question
  ///
  /// In en, this message translates to:
  /// **'What are Total Sets?'**
  String get whatAreTotalSets;

  /// Total sets explanation
  ///
  /// In en, this message translates to:
  /// **'Number of sets performed across all exercises in your workout.'**
  String get totalSetsExplanation;

  /// Total sets example
  ///
  /// In en, this message translates to:
  /// **'Example: 4 sets squats + 3 sets bench press = 7 total sets'**
  String get totalSetsExample;

  /// Workout frequency help question
  ///
  /// In en, this message translates to:
  /// **'What is Workout Frequency?'**
  String get whatIsWorkoutFrequency;

  /// Workout frequency explanation
  ///
  /// In en, this message translates to:
  /// **'Number of training sessions per week or muscle group hits per week.'**
  String get workoutFrequencyExplanation;

  /// Workout frequency example
  ///
  /// In en, this message translates to:
  /// **'Example: Training chest 2× per week = 2× frequency'**
  String get workoutFrequencyExample;

  /// Personal record help question
  ///
  /// In en, this message translates to:
  /// **'What is a Personal Record (PR)?'**
  String get whatIsPersonalRecord;

  /// Personal record explanation
  ///
  /// In en, this message translates to:
  /// **'Your best performance for a specific exercise (max weight, reps, or volume).'**
  String get personalRecordExplanation;

  /// Personal record example
  ///
  /// In en, this message translates to:
  /// **'Example: Bench press 100kg × 5 reps beats your previous 95kg × 5 reps'**
  String get personalRecordExample;

  /// Muscle balance help question
  ///
  /// In en, this message translates to:
  /// **'What is Muscle Balance?'**
  String get whatIsMuscleBalance;

  /// Muscle balance example
  ///
  /// In en, this message translates to:
  /// **'Example: Training chest 3× per week but back only 1× creates imbalance'**
  String get muscleBalanceExample;

  /// Days remaining suffix
  ///
  /// In en, this message translates to:
  /// **'days to go'**
  String get daysToGo;

  /// Comparison to previous period
  ///
  /// In en, this message translates to:
  /// **'vs last period'**
  String get vsLastPeriod;

  /// Last year time period
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// Color shade identifier
  ///
  /// In en, this message translates to:
  /// **'Shade 400'**
  String get shade400;

  /// Time period - last N months
  ///
  /// In en, this message translates to:
  /// **'Last {n} months'**
  String lastNMonths(int n);

  /// Time period - last N days
  ///
  /// In en, this message translates to:
  /// **'Last {n} days'**
  String lastNDays(int n);

  /// Header for workout selector sheet
  ///
  /// In en, this message translates to:
  /// **'Complete Day with Workout'**
  String get completeDayWithWorkout;

  /// Subtitle for workout selector sheet
  ///
  /// In en, this message translates to:
  /// **'Select workout to link to'**
  String get selectWorkoutToLinkTo;

  /// Fallback button to complete day without linking a workout
  ///
  /// In en, this message translates to:
  /// **'Complete without workout'**
  String get completeWithoutWorkout;

  /// Empty state message when no recent workouts available
  ///
  /// In en, this message translates to:
  /// **'No recent workouts found'**
  String get noRecentWorkoutsFound;

  /// Empty state description for completing without workout
  ///
  /// In en, this message translates to:
  /// **'Complete this day without linking a workout'**
  String get completeDayWithoutWorkout;

  /// Button to complete day in empty state
  ///
  /// In en, this message translates to:
  /// **'Complete Day'**
  String get completeDay;

  /// Error message when workout loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load workouts'**
  String get failedToLoadWorkouts;

  /// Success message when day is completed with a linked workout
  ///
  /// In en, this message translates to:
  /// **'Day completed with workout!'**
  String get dayCompletedWithWorkout;

  /// Success message when day is completed without a workout
  ///
  /// In en, this message translates to:
  /// **'Day completed manually'**
  String get dayCompletedManually;

  /// Error message when day completion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to complete day'**
  String get failedToCompleteDay;

  /// Button to change exercise counting format during workout
  ///
  /// In en, this message translates to:
  /// **'Change counting format'**
  String get changeCountingFormat;

  /// Label showing the current counting format
  ///
  /// In en, this message translates to:
  /// **'Current format'**
  String get currentFormat;

  /// Description for weighted counting mode
  ///
  /// In en, this message translates to:
  /// **'Input: Weight (kg/lb) + Reps'**
  String get countingModeWeightedDesc;

  /// Example for weighted counting mode
  ///
  /// In en, this message translates to:
  /// **'Example: 80kg × 10 reps'**
  String get countingModeWeightedExample;

  /// Description for reps-only counting mode
  ///
  /// In en, this message translates to:
  /// **'Input: Reps only (no weight)'**
  String get countingModeRepsDesc;

  /// Example for reps-only counting mode
  ///
  /// In en, this message translates to:
  /// **'Example: 15 reps'**
  String get countingModeRepsExample;

  /// Description for time-based counting mode
  ///
  /// In en, this message translates to:
  /// **'Input: Duration (mm:ss)'**
  String get countingModeTimeDesc;

  /// Example for time-based counting mode
  ///
  /// In en, this message translates to:
  /// **'Example: 1:30 (90 seconds)'**
  String get countingModeTimeExample;

  /// Button to confirm a change action
  ///
  /// In en, this message translates to:
  /// **'Confirm change'**
  String get confirmChange;

  /// Title for counting mode change warning dialog
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get countingModeWarningTitle;

  /// Warning message when changing counting mode with completed sets
  ///
  /// In en, this message translates to:
  /// **'You have {count} completed sets with format \"{fromMode}\".\n\nChanging to \"{toMode}\" may invalidate existing data.'**
  String countingModeWarningMessage(int count, String fromMode, String toMode);

  /// Additional info in counting mode warning dialog
  ///
  /// In en, this message translates to:
  /// **'Changing format during a workout is not recommended. Consider finishing the workout first.'**
  String get countingModeWarningInfo;

  /// Button to keep existing data when changing format
  ///
  /// In en, this message translates to:
  /// **'Keep data'**
  String get keepData;

  /// Button to reset all data when changing format
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// Success message after counting mode change
  ///
  /// In en, this message translates to:
  /// **'Counting format updated!'**
  String get countingModeChanged;

  /// Thank you message after submitting analytics feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get analyticsFeedbackThankYou;

  /// Subtitle for thank you message
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve the analytics experience'**
  String get analyticsFeedbackThankYouSubtitle;

  /// Question asking if analytics is helpful
  ///
  /// In en, this message translates to:
  /// **'Is this analytics view helpful?'**
  String get analyticsFeedbackQuestion;

  /// Button for positive feedback
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get analyticsFeedbackHelpful;

  /// Button for negative feedback
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get analyticsFeedbackNotHelpful;

  /// Placeholder for comment text field
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get analyticsFeedbackCommentPlaceholder;

  /// Button text while submitting feedback
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get analyticsFeedbackSubmitting;

  /// Button text to submit feedback
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get analyticsFeedbackSubmit;

  /// Error message when feedback submission fails
  ///
  /// In en, this message translates to:
  /// **'Could not submit feedback. Please try again.'**
  String get analyticsFeedbackError;

  /// Success message after feedback submission
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted successfully!'**
  String get analyticsFeedbackSuccess;

  /// Snackbar message when master toggle is auto-enabled
  ///
  /// In en, this message translates to:
  /// **'✅ {masterName} auto-enabled (required for this feature)'**
  String autoEnabledMaster(String masterName);

  /// Snackbar message when dependent toggles are auto-disabled
  ///
  /// In en, this message translates to:
  /// **'⚠️ {count} dependent features auto-disabled'**
  String dependentsDisabled(int count);

  /// Title for quick info icon toggle
  ///
  /// In en, this message translates to:
  /// **'Quick Info Icon'**
  String get quickInfoIconTitle;

  /// Description for quick info icon toggle
  ///
  /// In en, this message translates to:
  /// **'Tap for exercise details'**
  String get quickInfoIconDescription;

  /// Tooltip for quick info icon toggle
  ///
  /// In en, this message translates to:
  /// **'Shows exercise information modal with form cues and tips'**
  String get quickInfoIconTooltip;

  /// Title for warmup icon toggle
  ///
  /// In en, this message translates to:
  /// **'Warmup Icon'**
  String get quickWarmupIconTitle;

  /// Description for warmup icon toggle
  ///
  /// In en, this message translates to:
  /// **'Tap for warmup suggestions'**
  String get quickWarmupIconDescription;

  /// Tooltip for warmup icon toggle
  ///
  /// In en, this message translates to:
  /// **'Displays warmup sets recommendation based on working weight'**
  String get quickWarmupIconTooltip;

  /// Title for prevention icon toggle
  ///
  /// In en, this message translates to:
  /// **'Prevention Icon'**
  String get quickPreventionIconTitle;

  /// Description for prevention icon toggle
  ///
  /// In en, this message translates to:
  /// **'Tap for injury prevention tips'**
  String get quickPreventionIconDescription;

  /// Tooltip for prevention icon toggle
  ///
  /// In en, this message translates to:
  /// **'Shows injury prevention advice and mobility exercises'**
  String get quickPreventionIconTooltip;

  /// Title for exercise notes toggle
  ///
  /// In en, this message translates to:
  /// **'Exercise Notes'**
  String get exerciseNotesTitle;

  /// Description for exercise notes toggle
  ///
  /// In en, this message translates to:
  /// **'Add notes about form and cues'**
  String get exerciseNotesDescription;

  /// Tooltip for exercise notes toggle
  ///
  /// In en, this message translates to:
  /// **'Personal notes visible only to you during workouts'**
  String get exerciseNotesTooltip;

  /// Title for exercise insights toggle
  ///
  /// In en, this message translates to:
  /// **'Exercise Insights'**
  String get exerciseInsightsTitle;

  /// Description for exercise insights toggle
  ///
  /// In en, this message translates to:
  /// **'View charts and statistics'**
  String get exerciseInsightsDescription;

  /// Tooltip for exercise insights toggle
  ///
  /// In en, this message translates to:
  /// **'Analytics charts showing volume, PRs, and progress trends'**
  String get exerciseInsightsTooltip;

  /// Performance warning for insights charts
  ///
  /// In en, this message translates to:
  /// **'ℹ️ Charts may slow down on older devices'**
  String get insightsPerformanceWarning;

  /// Title for mode switch confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Switch to {mode} Mode?'**
  String modeSwitchWarningTitle(String mode);

  /// Message for mode switch confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will reset your custom settings to {mode} defaults.'**
  String modeSwitchWarningMessage(String mode);

  /// Hint about undo feature in mode switch dialog
  ///
  /// In en, this message translates to:
  /// **'You\'ll have 5 seconds to undo after confirming.'**
  String get modeSwitchUndoHint;

  /// Snackbar message when undo is successful
  ///
  /// In en, this message translates to:
  /// **'✅ Settings restored'**
  String get undoSuccessful;

  /// Sort option for most helpful contributions
  ///
  /// In en, this message translates to:
  /// **'Most Helpful'**
  String get sortByHelpful;

  /// Sort option for most recent contributions
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get sortByRecent;

  /// Sort option for most saved contributions
  ///
  /// In en, this message translates to:
  /// **'Most Saved'**
  String get sortBySaved;

  /// Sort option for trending contributions
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get sortByTrending;

  /// Filter label for difficulty level
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get filterByDifficulty;

  /// Filter label for author tier
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get filterByAuthorTier;

  /// Filter label for date range
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterByDateRange;

  /// Button to reset filters to default
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// Label for start date in date range filter
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get dateFrom;

  /// Label for end date in date range filter
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get dateTo;

  /// Contribution type: correction to exercise information
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get contributionTypeCorrection;

  /// Contribution type: helpful tip or advice
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get contributionTypeTip;

  /// Contribution type: safety warning or caution
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get contributionTypeWarning;

  /// Contribution type: exercise variant or alternative
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get contributionTypeVariant;

  /// Contribution type: translation improvement
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get contributionTypeTranslation;

  /// Contribution type: technique advice or form tip
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get contributionTypeTechnique;

  /// Beginner difficulty level badge
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get difficultyBeginner;

  /// Intermediate difficulty level badge
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get difficultyIntermediate;

  /// Advanced difficulty level badge
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get difficultyAdvanced;

  /// Author tier: community member
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get authorTierCommunity;

  /// Author tier: verified expert
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get authorTierExpert;

  /// Author tier: administrator
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get authorTierAdmin;

  /// Label for number of times a contribution was saved
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get saves;

  /// Label for number of views on a contribution
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// Label for number of comments on a contribution
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Label for number of upvotes on a contribution
  ///
  /// In en, this message translates to:
  /// **'Upvotes'**
  String get upvotes;

  /// Semantic label for bookmark contribution button
  ///
  /// In en, this message translates to:
  /// **'Bookmark contribution'**
  String get bookmarkContribution;

  /// Button to save a contribution
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveContribution;

  /// Button to remove a saved contribution
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsaveContribution;

  /// Label indicating a contribution is saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Title for the legal disclaimer modal
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get legalDisclaimerTitle;

  /// Content text for the legal disclaimer modal
  ///
  /// In en, this message translates to:
  /// **'⚠️ IMPORTANT NOTICE\n\nFITlog Pro is a workout tracking tool.\n\nNOT a substitute for:\n• Medical advice\n• Personal trainer\n• Sports physician\n• Fitness consultant\n\nYou MUST:\n✓ Consult a physician before starting any exercise program\n✓ Stop immediately if you experience pain or discomfort\n✓ Take sole responsibility for your safety during training\n\nThe provider is NOT liable for:\n• Physical injuries\n• Worsening of medical conditions\n• Failure to achieve fitness goals\n\nBy accepting, you acknowledge these risks and agree to the Terms of Service and Privacy Policy.'**
  String get legalDisclaimerContent;

  /// Accept button for legal disclaimer
  ///
  /// In en, this message translates to:
  /// **'I Accept'**
  String get legalDisclaimerAccept;

  /// Decline button for legal disclaimer
  ///
  /// In en, this message translates to:
  /// **'I Decline'**
  String get legalDisclaimerDecline;

  /// Title for legal documents screen
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocuments;

  /// Privacy Policy title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy Policy subtitle
  ///
  /// In en, this message translates to:
  /// **'How we handle your data (GDPR compliant)'**
  String get privacyPolicySubtitle;

  /// Terms of Service title
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms of Service subtitle
  ///
  /// In en, this message translates to:
  /// **'User agreements and liability limitations'**
  String get tosSubtitle;

  /// Medical Disclaimer subtitle
  ///
  /// In en, this message translates to:
  /// **'Important safety information'**
  String get disclaimerSubtitle;

  /// Error message when document fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading document. Please try again.'**
  String get errorLoadingDocument;

  /// Header for APRE calculation metadata display
  ///
  /// In en, this message translates to:
  /// **'Calculation Analysis'**
  String get apreCalculationMetadata;

  /// Button to expand calculation metadata banner
  ///
  /// In en, this message translates to:
  /// **'Show Calculation Details'**
  String get apreShowCalculationDetails;

  /// Button to collapse calculation metadata banner
  ///
  /// In en, this message translates to:
  /// **'Hide Calculation Details'**
  String get apreHideCalculationDetails;

  /// Label for 1RM calculation formula
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get apreFormula;

  /// Label for number of sets analyzed
  ///
  /// In en, this message translates to:
  /// **'Data Points'**
  String get apreDataPoints;

  /// Label for age of data used in calculation
  ///
  /// In en, this message translates to:
  /// **'Data Age'**
  String get apreDataAge;

  /// Label for standard deviation of estimates
  ///
  /// In en, this message translates to:
  /// **'Variability'**
  String get apreStandardDeviation;

  /// Label for confidence level of calculation
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get apreConfidence;

  /// Label for last calculation date
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get apreLastCalculation;

  /// Format for displaying days since data
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today} =1{Yesterday} other{{days} days ago}}'**
  String apreDaysAgo(int days);

  /// Title when user has no APRE historical data
  ///
  /// In en, this message translates to:
  /// **'No Historical Data'**
  String get apreNoHistory;

  /// Description when user has no APRE historical data
  ///
  /// In en, this message translates to:
  /// **'No historical data available for APRE calculations. Please select how you\'d like to estimate your 1RM to get started.'**
  String get apreNoHistoryDescription;

  /// Option to use last workout weight/reps as estimate
  ///
  /// In en, this message translates to:
  /// **'From Last Workout'**
  String get apreOptionFromLastWorkout;

  /// Option to manually enter estimated 1RM
  ///
  /// In en, this message translates to:
  /// **'Manual Estimate'**
  String get apreOptionManualEstimate;

  /// Option to guide user to do a test set
  ///
  /// In en, this message translates to:
  /// **'Test Set'**
  String get apreOptionTestSet;

  /// Description for from last workout option
  ///
  /// In en, this message translates to:
  /// **'Use last set weight/reps as estimate'**
  String get apreOptionFromLastWorkoutDescription;

  /// Description for manual estimate option
  ///
  /// In en, this message translates to:
  /// **'Enter estimated 1RM directly'**
  String get apreOptionManualEstimateDescription;

  /// Description for test set option
  ///
  /// In en, this message translates to:
  /// **'Guide to do a test set first'**
  String get apreOptionTestSetDescription;

  /// Label for 1RM input field
  ///
  /// In en, this message translates to:
  /// **'Enter Estimated 1RM (kg)'**
  String get apreEnter1RM;

  /// Label for weight preview section
  ///
  /// In en, this message translates to:
  /// **'Preview Weights'**
  String get aprePreviewWeights;

  /// Continue button in APRE modal
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get apreContinue;

  /// Cancel button in APRE modal
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get apreCancel;

  /// Title for age verification screen
  ///
  /// In en, this message translates to:
  /// **'Verify Your Age'**
  String get ageGateTitle;

  /// Instructions for age verification
  ///
  /// In en, this message translates to:
  /// **'Please enter your date of birth to continue.'**
  String get ageGateInstructions;

  /// Label for birth date selection
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get ageGateBirthDate;

  /// Continue button on age gate
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get ageGateContinue;

  /// Title for age restriction dialog
  ///
  /// In en, this message translates to:
  /// **'Age Restriction'**
  String get ageRestrictionTitle;

  /// Message explaining age restriction
  ///
  /// In en, this message translates to:
  /// **'You must be at least 14 years old to use FITlog Pro.\n\nThis requirement is mandated by GDPR (EU Regulation 2016/679) and Italian privacy laws.'**
  String get ageRestrictionMessage;

  /// OK button on age restriction dialog
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get ageRestrictionOk;

  /// Title for minor warning dialog
  ///
  /// In en, this message translates to:
  /// **'Important Notice for Minors'**
  String get ageMinorWarningTitle;

  /// Warning message for minors
  ///
  /// In en, this message translates to:
  /// **'If you are between 14 and 17 years old:\n\n• You MUST have parental consent to use this app\n• You MUST consult a physician before training\n• You MUST be supervised by an adult during workouts\n• Your parents are legally responsible for your use of this app\n\nDo you confirm you have parental consent?'**
  String get ageMinorWarningMessage;

  /// Confirm button for minor consent
  ///
  /// In en, this message translates to:
  /// **'Yes, I Have Consent'**
  String get ageMinorWarningConfirm;

  /// Decline button for minor consent
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get ageMinorWarningDecline;

  /// Short disclaimer text for footer
  ///
  /// In en, this message translates to:
  /// **'NOT medical advice • Consult physician • Use at your own risk'**
  String get footerDisclaimerShort;

  /// Hint text to tap footer for full disclaimer
  ///
  /// In en, this message translates to:
  /// **'Tap for full disclaimer'**
  String get footerDisclaimerTapHint;

  /// Title for APRE protocol change warning dialog
  ///
  /// In en, this message translates to:
  /// **'Workout in Progress'**
  String get apreProtocolChangeWarningTitle;

  /// Message explaining why APRE protocol cannot be changed during workout
  ///
  /// In en, this message translates to:
  /// **'You cannot change APRE protocol during an active workout. Please finish your current workout first, then return to adjust protocol settings.'**
  String get apreProtocolChangeWarningMessage;

  /// Button to dismiss APRE workout-in-progress warning
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get apreGotIt;

  /// Title for APRE calculation method setting
  ///
  /// In en, this message translates to:
  /// **'APRE Calculation Method'**
  String get apreCalculationMethodTitle;

  /// Description explaining APRE calculation method options
  ///
  /// In en, this message translates to:
  /// **'Choose how historical sets are selected for 1RM estimation in APRE workouts. Different strategies optimize for recency, data volume, or stability.'**
  String get apreCalculationMethodDescription;

  /// Auto-generated for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Auto-generated for accurate
  ///
  /// In en, this message translates to:
  /// **'Accurate'**
  String get accurate;

  /// Auto-generated for achievementsCopied
  ///
  /// In en, this message translates to:
  /// **'Achievements copied'**
  String get achievementsCopied;

  /// Auto-generated for activeDays
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// Auto-generated for activeMatches
  ///
  /// In en, this message translates to:
  /// **'Active matches'**
  String get activeMatches;

  /// Auto-generated for addRep
  ///
  /// In en, this message translates to:
  /// **'Add rep'**
  String get addRep;

  /// Auto-generated for advancedTemplate
  ///
  /// In en, this message translates to:
  /// **'Advanced template'**
  String get advancedTemplate;

  /// Auto-generated for afternoon
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Auto-generated for ageRange
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// Auto-generated for applyProgressiveOverload
  ///
  /// In en, this message translates to:
  /// **'Apply progressive overload'**
  String get applyProgressiveOverload;

  /// Auto-generated for availability
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// Auto-generated for averageVolume
  ///
  /// In en, this message translates to:
  /// **'Average volume'**
  String get averageVolume;

  /// Auto-generated for avgPerWeek
  ///
  /// In en, this message translates to:
  /// **'Avg per week'**
  String get avgPerWeek;

  /// Auto-generated for batterySaverActive
  ///
  /// In en, this message translates to:
  /// **'Battery saver active'**
  String get batterySaverActive;

  /// Auto-generated for beginnerTemplate
  ///
  /// In en, this message translates to:
  /// **'Beginner template'**
  String get beginnerTemplate;

  /// Auto-generated for bestDay
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// Auto-generated for bio
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Auto-generated for blockUser
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// Auto-generated for boosted
  ///
  /// In en, this message translates to:
  /// **'Boosted'**
  String get boosted;

  /// Auto-generated for bothWorkoutAndGym
  ///
  /// In en, this message translates to:
  /// **'Both workout and gym'**
  String get bothWorkoutAndGym;

  /// Auto-generated for buddyMatching
  ///
  /// In en, this message translates to:
  /// **'Buddy matching'**
  String get buddyMatching;

  /// Auto-generated for changeLayout
  ///
  /// In en, this message translates to:
  /// **'Change layout'**
  String get changeLayout;

  /// Auto-generated for cityPicker
  ///
  /// In en, this message translates to:
  /// **'City picker'**
  String get cityPicker;

  /// Auto-generated for clearAllSets
  ///
  /// In en, this message translates to:
  /// **'Clear all sets'**
  String get clearAllSets;

  /// Auto-generated for clearDemoData
  ///
  /// In en, this message translates to:
  /// **'Clear demo data'**
  String get clearDemoData;

  /// Auto-generated for cloudSync
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// Auto-generated for compactView
  ///
  /// In en, this message translates to:
  /// **'Compact view'**
  String get compactView;

  /// Auto-generated for comparedTo
  ///
  /// In en, this message translates to:
  /// **'Compared to'**
  String get comparedTo;

  /// Auto-generated for comparedToLast
  ///
  /// In en, this message translates to:
  /// **'Compared to last'**
  String get comparedToLast;

  /// Auto-generated for comparedToPrevious
  ///
  /// In en, this message translates to:
  /// **'Compared to previous'**
  String get comparedToPrevious;

  /// Auto-generated for completeAllSets
  ///
  /// In en, this message translates to:
  /// **'Complete all sets'**
  String get completeAllSets;

  /// Auto-generated for completeAnalysis
  ///
  /// In en, this message translates to:
  /// **'Complete analysis'**
  String get completeAnalysis;

  /// Auto-generated for completeStatistics
  ///
  /// In en, this message translates to:
  /// **'Complete statistics'**
  String get completeStatistics;

  /// Auto-generated for consecutiveDays
  ///
  /// In en, this message translates to:
  /// **'Consecutive days'**
  String get consecutiveDays;

  /// Auto-generated for copyFromLastWorkout
  ///
  /// In en, this message translates to:
  /// **'Copied from last workout'**
  String get copyFromLastWorkout;

  /// Auto-generated for criticalPriority
  ///
  /// In en, this message translates to:
  /// **'Critical priority'**
  String get criticalPriority;

  /// Auto-generated for customDateRange
  ///
  /// In en, this message translates to:
  /// **'Custom date range'**
  String get customDateRange;

  /// Auto-generated for dailyAverage
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// Auto-generated for dailyTrend
  ///
  /// In en, this message translates to:
  /// **'Daily trend'**
  String get dailyTrend;

  /// Auto-generated for dataExported
  ///
  /// In en, this message translates to:
  /// **'Data exported'**
  String get dataExported;

  /// Auto-generated for dateRange
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// Auto-generated for declined
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// Auto-generated for demoProfiles
  ///
  /// In en, this message translates to:
  /// **'Demo profiles'**
  String get demoProfiles;

  /// Auto-generated for detailedStats
  ///
  /// In en, this message translates to:
  /// **'Detailed stats'**
  String get detailedStats;

  /// Auto-generated for developmentMode
  ///
  /// In en, this message translates to:
  /// **'Development mode'**
  String get developmentMode;

  /// Auto-generated for discardWorkoutMessage
  ///
  /// In en, this message translates to:
  /// **'Discard workout message'**
  String get discardWorkoutMessage;

  /// Auto-generated for discardWorkoutTitle
  ///
  /// In en, this message translates to:
  /// **'Discard workout title'**
  String get discardWorkoutTitle;

  /// Auto-generated for distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Auto-generated for downloaded
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// Auto-generated for duplicateWorkout
  ///
  /// In en, this message translates to:
  /// **'Duplicate workout'**
  String get duplicateWorkout;

  /// Auto-generated for editProfile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Auto-generated for editTemplateDescription
  ///
  /// In en, this message translates to:
  /// **'Edit template description'**
  String get editTemplateDescription;

  /// Auto-generated for enableLocation
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// Auto-generated for enableLocationForBetterMatches
  ///
  /// In en, this message translates to:
  /// **'Enable location for better matches'**
  String get enableLocationForBetterMatches;

  /// Auto-generated for endWorkoutTitle
  ///
  /// In en, this message translates to:
  /// **'End workout title'**
  String get endWorkoutTitle;

  /// Auto-generated for endurance
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// Auto-generated for errorAuth
  ///
  /// In en, this message translates to:
  /// **'Error auth'**
  String get errorAuth;

  /// Auto-generated for errorGeneric
  ///
  /// In en, this message translates to:
  /// **'Error generic'**
  String get errorGeneric;

  /// Auto-generated for errorInvalidEmail
  ///
  /// In en, this message translates to:
  /// **'Error invalid email'**
  String get errorInvalidEmail;

  /// Auto-generated for errorNetwork
  ///
  /// In en, this message translates to:
  /// **'Error network'**
  String get errorNetwork;

  /// Auto-generated for errorUserNotFound
  ///
  /// In en, this message translates to:
  /// **'Error user not found'**
  String get errorUserNotFound;

  /// Auto-generated for errorWeakPassword
  ///
  /// In en, this message translates to:
  /// **'Error weak password'**
  String get errorWeakPassword;

  /// Auto-generated for essentialStatistics
  ///
  /// In en, this message translates to:
  /// **'Essential statistics'**
  String get essentialStatistics;

  /// Auto-generated for evening
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// Auto-generated for executing
  ///
  /// In en, this message translates to:
  /// **'Executing'**
  String get executing;

  /// Auto-generated for expertTemplate
  ///
  /// In en, this message translates to:
  /// **'Expert template'**
  String get expertTemplate;

  /// Auto-generated for export
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Auto-generated for exporting
  ///
  /// In en, this message translates to:
  /// **'Exporting'**
  String get exporting;

  /// Auto-generated for failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Auto-generated for fatigue
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// Auto-generated for fatto
  ///
  /// In en, this message translates to:
  /// **'Fatto'**
  String get fatto;

  /// Auto-generated for fieldRequired
  ///
  /// In en, this message translates to:
  /// **'Field required'**
  String get fieldRequired;

  /// Auto-generated for filterWorkouts
  ///
  /// In en, this message translates to:
  /// **'Filter workouts'**
  String get filterWorkouts;

  /// Auto-generated for findYourWorkoutPartner
  ///
  /// In en, this message translates to:
  /// **'Find your workout partner'**
  String get findYourWorkoutPartner;

  /// Auto-generated for flexibility
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get flexibility;

  /// Auto-generated for form
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get form;

  /// Auto-generated for fullView
  ///
  /// In en, this message translates to:
  /// **'Full view'**
  String get fullView;

  /// Auto-generated for generalFitness
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get generalFitness;

  /// Auto-generated for goPremium
  ///
  /// In en, this message translates to:
  /// **'Go premium'**
  String get goPremium;

  /// Auto-generated for gymBuddyOnly
  ///
  /// In en, this message translates to:
  /// **'Gym buddy only'**
  String get gymBuddyOnly;

  /// Auto-generated for hypertrophy
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get hypertrophy;

  /// Auto-generated for iceBreakerCategoryCasual
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category casual'**
  String get iceBreakerCategoryCasual;

  /// Auto-generated for iceBreakerCategoryExperience
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category experience'**
  String get iceBreakerCategoryExperience;

  /// Auto-generated for iceBreakerCategoryFitness
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category fitness'**
  String get iceBreakerCategoryFitness;

  /// Auto-generated for iceBreakerCategoryGoals
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category goals'**
  String get iceBreakerCategoryGoals;

  /// Auto-generated for iceBreakerCategoryMotivation
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category motivation'**
  String get iceBreakerCategoryMotivation;

  /// Auto-generated for iceBreakerCategoryWorkout
  ///
  /// In en, this message translates to:
  /// **'Ice breaker category workout'**
  String get iceBreakerCategoryWorkout;

  /// Auto-generated for iceBreakers
  ///
  /// In en, this message translates to:
  /// **'Ice breakers'**
  String get iceBreakers;

  /// Auto-generated for improved
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get improved;

  /// Auto-generated for improvementDetected
  ///
  /// In en, this message translates to:
  /// **'Improvement detected'**
  String get improvementDetected;

  /// Auto-generated for instagramHandle
  ///
  /// In en, this message translates to:
  /// **'Instagram handle'**
  String get instagramHandle;

  /// Auto-generated for instagramVerified
  ///
  /// In en, this message translates to:
  /// **'Instagram verified'**
  String get instagramVerified;

  /// Auto-generated for intensity
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// Auto-generated for intermediateTemplate
  ///
  /// In en, this message translates to:
  /// **'Intermediate template'**
  String get intermediateTemplate;

  /// Auto-generated for invalidValue
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// Auto-generated for itsAMatch
  ///
  /// In en, this message translates to:
  /// **'It\'s a match'**
  String get itsAMatch;

  /// Auto-generated for km
  ///
  /// In en, this message translates to:
  /// **'Km'**
  String get km;

  /// Auto-generated for last
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// Auto-generated for lastSync
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// Auto-generated for like
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Auto-generated for localStorageOnly
  ///
  /// In en, this message translates to:
  /// **'Local storage only'**
  String get localStorageOnly;

  /// Auto-generated for location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Auto-generated for locationHelpsFindNearbyBuddies
  ///
  /// In en, this message translates to:
  /// **'Location helps find nearby buddies'**
  String get locationHelpsFindNearbyBuddies;

  /// Auto-generated for locationPermissionDenied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// Auto-generated for locationPermissionExplanation
  ///
  /// In en, this message translates to:
  /// **'Location permission explanation'**
  String get locationPermissionExplanation;

  /// Auto-generated for locationPermissionGranted
  ///
  /// In en, this message translates to:
  /// **'Location permission granted'**
  String get locationPermissionGranted;

  /// Auto-generated for locationPermissionRequired
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// Auto-generated for locationUpdateError
  ///
  /// In en, this message translates to:
  /// **'Location update error'**
  String get locationUpdateError;

  /// Auto-generated for locationUpdated
  ///
  /// In en, this message translates to:
  /// **'Location updated'**
  String get locationUpdated;

  /// Auto-generated for lookingForWorkoutBuddy
  ///
  /// In en, this message translates to:
  /// **'Looking for workout buddy'**
  String get lookingForWorkoutBuddy;

  /// Auto-generated for matchFilters
  ///
  /// In en, this message translates to:
  /// **'Match filters'**
  String get matchFilters;

  /// Auto-generated for matchingPurpose
  ///
  /// In en, this message translates to:
  /// **'Matching purpose'**
  String get matchingPurpose;

  /// Auto-generated for matchingPurposeBoth
  ///
  /// In en, this message translates to:
  /// **'Matching purpose both'**
  String get matchingPurposeBoth;

  /// Auto-generated for matchingPurposeGymBuddy
  ///
  /// In en, this message translates to:
  /// **'Matching purpose gym buddy'**
  String get matchingPurposeGymBuddy;

  /// Auto-generated for matchingPurposeOpenToEverything
  ///
  /// In en, this message translates to:
  /// **'Matching purpose open to everything'**
  String get matchingPurposeOpenToEverything;

  /// Auto-generated for matchingPurposeWorkoutPartner
  ///
  /// In en, this message translates to:
  /// **'Matching purpose workout partner'**
  String get matchingPurposeWorkoutPartner;

  /// Auto-generated for maxAge
  ///
  /// In en, this message translates to:
  /// **'Max age'**
  String get maxAge;

  /// Auto-generated for maxDistance
  ///
  /// In en, this message translates to:
  /// **'Max distance'**
  String get maxDistance;

  /// Auto-generated for midday
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get midday;

  /// Auto-generated for minAge
  ///
  /// In en, this message translates to:
  /// **'Min age'**
  String get minAge;

  /// Auto-generated for minimalView
  ///
  /// In en, this message translates to:
  /// **'Minimal view'**
  String get minimalView;

  /// Auto-generated for morning
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Auto-generated for muscleGain
  ///
  /// In en, this message translates to:
  /// **'Muscle gain'**
  String get muscleGain;

  /// Auto-generated for needMoreWorkouts
  ///
  /// In en, this message translates to:
  /// **'Need more workouts'**
  String get needMoreWorkouts;

  /// Auto-generated for newPersonalRecordsAchieved
  ///
  /// In en, this message translates to:
  /// **'New personal records achieved'**
  String get newPersonalRecordsAchieved;

  /// Auto-generated for noComparisonData
  ///
  /// In en, this message translates to:
  /// **'No comparison data'**
  String get noComparisonData;

  /// Auto-generated for noMatchesFound
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// Auto-generated for noPRsYet
  ///
  /// In en, this message translates to:
  /// **'No p rs yet'**
  String get noPRsYet;

  /// Auto-generated for noWorkoutsFound
  ///
  /// In en, this message translates to:
  /// **'No workouts found'**
  String get noWorkoutsFound;

  /// Auto-generated for noWorkoutsFoundDescription
  ///
  /// In en, this message translates to:
  /// **'No workouts found description'**
  String get noWorkoutsFoundDescription;

  /// Auto-generated for noWorkoutsRecorded
  ///
  /// In en, this message translates to:
  /// **'No workouts recorded'**
  String get noWorkoutsRecorded;

  /// Auto-generated for notNow
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Auto-generated for oops
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get oops;

  /// Auto-generated for openCityPicker
  ///
  /// In en, this message translates to:
  /// **'Open city picker'**
  String get openCityPicker;

  /// Auto-generated for openIceBreakers
  ///
  /// In en, this message translates to:
  /// **'Open ice breakers'**
  String get openIceBreakers;

  /// Auto-generated for openInstagram
  ///
  /// In en, this message translates to:
  /// **'Open instagram'**
  String get openInstagram;

  /// Auto-generated for openSettings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Auto-generated for openToDating
  ///
  /// In en, this message translates to:
  /// **'Open to dating'**
  String get openToDating;

  /// Auto-generated for openToFriendship
  ///
  /// In en, this message translates to:
  /// **'Open to friendship'**
  String get openToFriendship;

  /// Auto-generated for overallAssessment
  ///
  /// In en, this message translates to:
  /// **'Overall assessment'**
  String get overallAssessment;

  /// Auto-generated for partnerships
  ///
  /// In en, this message translates to:
  /// **'Partnerships'**
  String get partnerships;

  /// Auto-generated for pass
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// Auto-generated for perDay
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get perDay;

  /// Auto-generated for performanceDeclined
  ///
  /// In en, this message translates to:
  /// **'Performance declined'**
  String get performanceDeclined;

  /// Auto-generated for photoVerified
  ///
  /// In en, this message translates to:
  /// **'Photo verified'**
  String get photoVerified;

  /// Auto-generated for pleaseSelectAtLeastOneGoal
  ///
  /// In en, this message translates to:
  /// **'Please select at least one goal'**
  String get pleaseSelectAtLeastOneGoal;

  /// Auto-generated for pleaseSelectPreferredTimes
  ///
  /// In en, this message translates to:
  /// **'Please select preferred times'**
  String get pleaseSelectPreferredTimes;

  /// Auto-generated for pleaseSelectYourCity
  ///
  /// In en, this message translates to:
  /// **'Please select your city'**
  String get pleaseSelectYourCity;

  /// Auto-generated for preferredTimes
  ///
  /// In en, this message translates to:
  /// **'Preferred times'**
  String get preferredTimes;

  /// Auto-generated for preparing
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// Auto-generated for profileUpdatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Auto-generated for progressTitle
  ///
  /// In en, this message translates to:
  /// **'Progress title'**
  String get progressTitle;

  /// Auto-generated for rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Auto-generated for redo
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Auto-generated for refreshMatches
  ///
  /// In en, this message translates to:
  /// **'Refresh matches'**
  String get refreshMatches;

  /// Auto-generated for rep
  ///
  /// In en, this message translates to:
  /// **'Rep'**
  String get rep;

  /// Auto-generated for reportReasonFakeProfile
  ///
  /// In en, this message translates to:
  /// **'Report reason fake profile'**
  String get reportReasonFakeProfile;

  /// Auto-generated for reportReasonHarassment
  ///
  /// In en, this message translates to:
  /// **'Report reason harassment'**
  String get reportReasonHarassment;

  /// Auto-generated for reportReasonInappropriatePhotos
  ///
  /// In en, this message translates to:
  /// **'Report reason inappropriate photos'**
  String get reportReasonInappropriatePhotos;

  /// Auto-generated for reportReasonOther
  ///
  /// In en, this message translates to:
  /// **'Report reason other'**
  String get reportReasonOther;

  /// Auto-generated for reportReasonSpam
  ///
  /// In en, this message translates to:
  /// **'Report reason spam'**
  String get reportReasonSpam;

  /// Auto-generated for reportReasonUnderage
  ///
  /// In en, this message translates to:
  /// **'Report reason underage'**
  String get reportReasonUnderage;

  /// Auto-generated for reportUser
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// Auto-generated for resetDefaults
  ///
  /// In en, this message translates to:
  /// **'Reset defaults'**
  String get resetDefaults;

  /// Auto-generated for resetLayout
  ///
  /// In en, this message translates to:
  /// **'Reset layout'**
  String get resetLayout;

  /// Auto-generated for resting
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get resting;

  /// Auto-generated for restorePurchases
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// Auto-generated for rpeTimerAndMore
  ///
  /// In en, this message translates to:
  /// **'Rpe timer and more'**
  String get rpeTimerAndMore;

  /// Auto-generated for saveToFirebaseForReuse
  ///
  /// In en, this message translates to:
  /// **'Save to firebase for reuse'**
  String get saveToFirebaseForReuse;

  /// Auto-generated for screenWontTurnOff
  ///
  /// In en, this message translates to:
  /// **'Screen wont turn off'**
  String get screenWontTurnOff;

  /// Auto-generated for search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Auto-generated for searchCity
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// Auto-generated for searchingForMatches
  ///
  /// In en, this message translates to:
  /// **'Searching for matches'**
  String get searchingForMatches;

  /// Auto-generated for seedDemoData
  ///
  /// In en, this message translates to:
  /// **'Seed demo data'**
  String get seedDemoData;

  /// Auto-generated for selectDataType
  ///
  /// In en, this message translates to:
  /// **'Select data type'**
  String get selectDataType;

  /// Auto-generated for selectDates
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get selectDates;

  /// Auto-generated for selectExportFormat
  ///
  /// In en, this message translates to:
  /// **'Select export format'**
  String get selectExportFormat;

  /// Auto-generated for selectMetrics
  ///
  /// In en, this message translates to:
  /// **'Select metrics'**
  String get selectMetrics;

  /// Auto-generated for setTrackingReady
  ///
  /// In en, this message translates to:
  /// **'Set tracking ready'**
  String get setTrackingReady;

  /// Auto-generated for setupYourProfile
  ///
  /// In en, this message translates to:
  /// **'Setup your profile'**
  String get setupYourProfile;

  /// Auto-generated for similarPerformance
  ///
  /// In en, this message translates to:
  /// **'Similar performance'**
  String get similarPerformance;

  /// Auto-generated for sinceRegistration
  ///
  /// In en, this message translates to:
  /// **'Since registration'**
  String get sinceRegistration;

  /// Auto-generated for skipTimer
  ///
  /// In en, this message translates to:
  /// **'Skip timer'**
  String get skipTimer;

  /// Auto-generated for startWorkoutNow
  ///
  /// In en, this message translates to:
  /// **'Start workout now'**
  String get startWorkoutNow;

  /// Auto-generated for stopSet
  ///
  /// In en, this message translates to:
  /// **'Stop set'**
  String get stopSet;

  /// Auto-generated for streakLabel
  ///
  /// In en, this message translates to:
  /// **'Streak label'**
  String get streakLabel;

  /// Auto-generated for superLike
  ///
  /// In en, this message translates to:
  /// **'Super like'**
  String get superLike;

  /// Auto-generated for swipeToDecide
  ///
  /// In en, this message translates to:
  /// **'Swipe to decide'**
  String get swipeToDecide;

  /// Auto-generated for syncAllWorkouts
  ///
  /// In en, this message translates to:
  /// **'Sync all workouts'**
  String get syncAllWorkouts;

  /// Auto-generated for syncWorkouts
  ///
  /// In en, this message translates to:
  /// **'Sync workouts'**
  String get syncWorkouts;

  /// Status text shown while syncing
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Auto-generated for tapPlusToAddExercise
  ///
  /// In en, this message translates to:
  /// **'Tap plus to add exercise'**
  String get tapPlusToAddExercise;

  /// Auto-generated for tapToViewMore
  ///
  /// In en, this message translates to:
  /// **'Tap to view more'**
  String get tapToViewMore;

  /// Auto-generated for tellUsAboutYourself
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// Auto-generated for templateLimitSuggestion
  ///
  /// In en, this message translates to:
  /// **'Template limit suggestion'**
  String get templateLimitSuggestion;

  /// Auto-generated for templateSyncDescription
  ///
  /// In en, this message translates to:
  /// **'Template sync description'**
  String get templateSyncDescription;

  /// Auto-generated for thisMonth
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Auto-generated for timeRange
  ///
  /// In en, this message translates to:
  /// **'Time range'**
  String get timeRange;

  /// Auto-generated for toggleToShowInMatching
  ///
  /// In en, this message translates to:
  /// **'Toggle to show in matching'**
  String get toggleToShowInMatching;

  /// Auto-generated for totalWeightLifted
  ///
  /// In en, this message translates to:
  /// **'Total weight lifted'**
  String get totalWeightLifted;

  /// Auto-generated for trainingDays
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get trainingDays;

  /// Auto-generated for unableToGetLocation
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;

  /// Auto-generated for unknownLocation
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// Auto-generated for updateLocation
  ///
  /// In en, this message translates to:
  /// **'Update location'**
  String get updateLocation;

  /// Auto-generated for upgradeForMoreTemplates
  ///
  /// In en, this message translates to:
  /// **'Upgrade for more templates'**
  String get upgradeForMoreTemplates;

  /// Auto-generated for upgradeToPremiumForSync
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium for sync'**
  String get upgradeToPremiumForSync;

  /// Auto-generated for uploaded
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// Auto-generated for useCurrentLocation
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// Auto-generated for valueTooHigh
  ///
  /// In en, this message translates to:
  /// **'Value too high'**
  String get valueTooHigh;

  /// Auto-generated for valueTooLow
  ///
  /// In en, this message translates to:
  /// **'Value too low'**
  String get valueTooLow;

  /// Auto-generated for velocityProfile
  ///
  /// In en, this message translates to:
  /// **'Velocity profile'**
  String get velocityProfile;

  /// Auto-generated for verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Auto-generated for verifiedOnly
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get verifiedOnly;

  /// Auto-generated for viewProfile
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// Auto-generated for viewWorkout
  ///
  /// In en, this message translates to:
  /// **'View workout'**
  String get viewWorkout;

  /// Auto-generated for volumeDetails
  ///
  /// In en, this message translates to:
  /// **'Volume details'**
  String get volumeDetails;

  /// Auto-generated for volumePerDay
  ///
  /// In en, this message translates to:
  /// **'Volume per day'**
  String get volumePerDay;

  /// Auto-generated for volumeSettings
  ///
  /// In en, this message translates to:
  /// **'Volume settings'**
  String get volumeSettings;

  /// Auto-generated for vsLastWeek
  ///
  /// In en, this message translates to:
  /// **'Vs last week'**
  String get vsLastWeek;

  /// Auto-generated for weeklyDistribution
  ///
  /// In en, this message translates to:
  /// **'Weekly distribution'**
  String get weeklyDistribution;

  /// Auto-generated for weeklyDistributionDesc
  ///
  /// In en, this message translates to:
  /// **'Weekly distribution desc'**
  String get weeklyDistributionDesc;

  /// Auto-generated for weeklyDistributionInfo
  ///
  /// In en, this message translates to:
  /// **'Weekly distribution info'**
  String get weeklyDistributionInfo;

  /// Auto-generated for weeklyVolume
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get weeklyVolume;

  /// Auto-generated for weightLoss
  ///
  /// In en, this message translates to:
  /// **'Weight loss'**
  String get weightLoss;

  /// Auto-generated for weightUnit
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get weightUnit;

  /// Auto-generated for workoutComparison
  ///
  /// In en, this message translates to:
  /// **'Workout comparison'**
  String get workoutComparison;

  /// Auto-generated for workoutDeclineDescription
  ///
  /// In en, this message translates to:
  /// **'Workout decline description'**
  String get workoutDeclineDescription;

  /// Auto-generated for workoutDeleted
  ///
  /// In en, this message translates to:
  /// **'Workout deleted'**
  String get workoutDeleted;

  /// Auto-generated for workoutDuplicated
  ///
  /// In en, this message translates to:
  /// **'Workout duplicated'**
  String get workoutDuplicated;

  /// Auto-generated for workoutGoals
  ///
  /// In en, this message translates to:
  /// **'Workout goals'**
  String get workoutGoals;

  /// Auto-generated for workoutImprovementDescription
  ///
  /// In en, this message translates to:
  /// **'Workout improvement description'**
  String get workoutImprovementDescription;

  /// Auto-generated for workoutPartnerOnly
  ///
  /// In en, this message translates to:
  /// **'Workout partner only'**
  String get workoutPartnerOnly;

  /// Auto-generated for workoutSimilarDescription
  ///
  /// In en, this message translates to:
  /// **'Workout similar description'**
  String get workoutSimilarDescription;

  /// Auto-generated for workoutType
  ///
  /// In en, this message translates to:
  /// **'Workout type'**
  String get workoutType;

  /// Auto-generated for workoutsLabel
  ///
  /// In en, this message translates to:
  /// **'Workouts label'**
  String get workoutsLabel;

  /// Auto-generated for years
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// Auto-generated for zenMode
  ///
  /// In en, this message translates to:
  /// **'Zen mode'**
  String get zenMode;

  /// Auto-generated for zenModeActiveDescription
  ///
  /// In en, this message translates to:
  /// **'Zen mode active description'**
  String get zenModeActiveDescription;

  /// Auto-generated for zenModeInactiveDescription
  ///
  /// In en, this message translates to:
  /// **'Zen mode inactive description'**
  String get zenModeInactiveDescription;

  /// Auto-generated for zonePicker
  ///
  /// In en, this message translates to:
  /// **'Zone picker'**
  String get zonePicker;

  /// Workout duration label
  ///
  /// In en, this message translates to:
  /// **'Workout duration'**
  String get workoutDuration;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Additional records count
  ///
  /// In en, this message translates to:
  /// **'and {count} more records'**
  String andMoreRecords(int count);

  /// Additional items count
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andXMore(int count);

  /// Error message for delete failure
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get errorDeleting;

  /// Error message for image picker failure
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// Error message for share failure
  ///
  /// In en, this message translates to:
  /// **'Error sharing'**
  String get errorSharing;

  /// Error message for workout start failure
  ///
  /// In en, this message translates to:
  /// **'Error starting workout'**
  String get errorStartingWorkout;

  /// Number of completed exercises
  ///
  /// In en, this message translates to:
  /// **'{count} exercises completed'**
  String exercisesCompleted(int count);

  /// Export failure error message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailedError(String error);

  /// Button to save and finish workout
  ///
  /// In en, this message translates to:
  /// **'Save and end workout'**
  String get saveAndEndWorkout;

  /// Save failure error message
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String saveError(String error);

  /// Remaining super likes count
  ///
  /// In en, this message translates to:
  /// **'{count} super likes remaining'**
  String superLikesRemaining(int count);

  /// Template limit reached message
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of {max} templates'**
  String templateLimitMessage(int max);

  /// User trust score display
  ///
  /// In en, this message translates to:
  /// **'Trust score: {score}'**
  String trustScore(int score);

  /// Workout started message
  ///
  /// In en, this message translates to:
  /// **'Workout started from template: {name}'**
  String workoutStartedFromTemplate(String name);

  /// Experience points display
  ///
  /// In en, this message translates to:
  /// **'{count} XP'**
  String xpPoints(int count);

  /// Setting to keep screen on during workouts
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// Title for missed workout recovery feature
  ///
  /// In en, this message translates to:
  /// **'Recover Workout'**
  String get recoveryWorkout;

  /// Button to start recovery of missed workout
  ///
  /// In en, this message translates to:
  /// **'Recover Now'**
  String get recoverNow;

  /// Display when a workout was completed
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String completedOn(String date);

  /// Button to start a workout immediately
  ///
  /// In en, this message translates to:
  /// **'Do Workout Now'**
  String get doWorkoutNow;

  /// Option to extend routine by adding day
  ///
  /// In en, this message translates to:
  /// **'Extend Routine'**
  String get extendRoutine;

  /// Description for extending routine
  ///
  /// In en, this message translates to:
  /// **'Add to end of routine'**
  String get addToEndOfRoutine;

  /// Option to permanently skip a workout
  ///
  /// In en, this message translates to:
  /// **'Skip Permanently'**
  String get skipPermanently;

  /// Confirm skipping the current workout
  ///
  /// In en, this message translates to:
  /// **'Skip this workout'**
  String get skipThisWorkout;

  /// Title for managing uncompleted workouts
  ///
  /// In en, this message translates to:
  /// **'Manage missed workout'**
  String get manageUncompletedWorkout;

  /// Prompt for user to choose action
  ///
  /// In en, this message translates to:
  /// **'Choose how to proceed'**
  String get chooseHowToProceed;

  /// Success message when routine is extended
  ///
  /// In en, this message translates to:
  /// **'Routine extended successfully'**
  String get routineExtendedSuccessfully;

  /// Confirmation that workout was skipped
  ///
  /// In en, this message translates to:
  /// **'Workout skipped'**
  String get workoutSkipped;

  /// Success message when recovery is finished
  ///
  /// In en, this message translates to:
  /// **'Recovery complete'**
  String get recoveryComplete;

  /// Confirmation that workout was completed
  ///
  /// In en, this message translates to:
  /// **'Workout completed successfully'**
  String get workoutCompletedSuccessfully;

  /// Message confirming missed workout has been recovered
  ///
  /// In en, this message translates to:
  /// **'Missed workout recovered'**
  String get missedWorkoutRecovered;

  /// Calendar schedule title in routine center
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get routineSchedule;

  /// Status completed in calendar legend
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get routineStatusCompleted;

  /// Status scheduled in calendar legend
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get routineStatusScheduled;

  /// Status skipped in calendar legend
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get routineStatusSkipped;

  /// Status rest day in calendar legend
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get routineStatusRest;

  /// Badge shown when workout done on rest day
  ///
  /// In en, this message translates to:
  /// **'Extra Workout 💪'**
  String get routineExtraWorkout;

  /// Message shown for workout on rest day
  ///
  /// In en, this message translates to:
  /// **'You trained on a scheduled rest day! Great dedication!'**
  String get routineExtraWorkoutMessage;

  /// Section title for today's workout performance
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PERFORMANCE'**
  String get routineTodayPerformance;

  /// Label for workout volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get routineVolume;

  /// Label for workout duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get routineDuration;

  /// Label for exercises (without count)
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesLabel;

  /// Label for average RPE
  ///
  /// In en, this message translates to:
  /// **'Average RPE'**
  String get routineAverageRPE;

  /// Section title for workout preview
  ///
  /// In en, this message translates to:
  /// **'WORKOUT PREVIEW'**
  String get routineWorkoutPreview;

  /// Button to change workout template
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get routineChange;

  /// Error message when template not found
  ///
  /// In en, this message translates to:
  /// **'Template not found'**
  String get routineTemplateNotFound;

  /// Button to show less exercises
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get routineShowLess;

  /// Button to show all exercises
  ///
  /// In en, this message translates to:
  /// **'Show All ({count} more)'**
  String routineShowAll(int count);

  /// Section title for workout history
  ///
  /// In en, this message translates to:
  /// **'WORKOUT HISTORY'**
  String get routineWorkoutHistory;

  /// Section title for insights
  ///
  /// In en, this message translates to:
  /// **'INSIGHTS & SUGGESTIONS'**
  String get routineInsightsSuggestions;

  /// AI insights disclaimer
  ///
  /// In en, this message translates to:
  /// **'AI-powered insights based on:\n• Your workout performance\n• Recovery metrics\n• Training patterns'**
  String get routineAiInsightsBased;

  /// Insights based on metrics message
  ///
  /// In en, this message translates to:
  /// **'Based on your performance metrics'**
  String get routineBasedOnMetrics;

  /// Button to start workout
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get routineStartWorkout;

  /// Button to view full workout details
  ///
  /// In en, this message translates to:
  /// **'View Full Details'**
  String get routineViewFullDetails;

  /// Button to mark day as complete
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get routineComplete;

  /// Button to skip day
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get routineSkip;

  /// Status recovered
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get routineStatusRecovered;

  /// Success message when workout starts
  ///
  /// In en, this message translates to:
  /// **'Workout started! 💪'**
  String get routineWorkoutStarted;

  /// Error message when workout fails to start
  ///
  /// In en, this message translates to:
  /// **'Error starting workout: {error}'**
  String routineErrorStartingWorkout(String error);

  /// Dialog title for skipping day
  ///
  /// In en, this message translates to:
  /// **'Skip Day'**
  String get routineSkipDay;

  /// Confirmation message for skipping day
  ///
  /// In en, this message translates to:
  /// **'Mark this day as skipped?'**
  String get routineSkipDayConfirm;

  /// Success message when day skipped
  ///
  /// In en, this message translates to:
  /// **'Day skipped'**
  String get routineDaySkipped;

  /// Error message when skip fails
  ///
  /// In en, this message translates to:
  /// **'Failed to skip day'**
  String get routineFailedToSkip;

  /// Message when no templates available
  ///
  /// In en, this message translates to:
  /// **'No templates available'**
  String get routineNoTemplatesAvailable;

  /// Section title for active routine
  ///
  /// In en, this message translates to:
  /// **'Active Routine'**
  String get routineActiveRoutine;

  /// Section title for other routines
  ///
  /// In en, this message translates to:
  /// **'Other Routines'**
  String get routineOtherRoutines;

  /// Section title for archived routines
  ///
  /// In en, this message translates to:
  /// **'Routine archived'**
  String get routineArchived;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get routineGoBack;

  /// Dialog title to activate routine
  ///
  /// In en, this message translates to:
  /// **'Activate Routine'**
  String get routineActivateRoutine;

  /// Dialog title to archive routine
  ///
  /// In en, this message translates to:
  /// **'Archive Routine'**
  String get routineArchiveRoutine;

  /// Dialog title to delete routine
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get routineDeleteRoutine;

  /// Dialog title for suggestion explanation
  ///
  /// In en, this message translates to:
  /// **'Why This Suggestion?'**
  String get routineWhyThisSuggestion;

  /// Button to dismiss dialog
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get routineGotIt;

  /// Button to view completed workout details
  ///
  /// In en, this message translates to:
  /// **'View Completed Workout'**
  String get routineViewCompletedWorkout;

  /// Error when routine not found
  ///
  /// In en, this message translates to:
  /// **'Routine not found'**
  String get routineNotFound;

  /// Success message when template changed
  ///
  /// In en, this message translates to:
  /// **'Template changed to \"{templateName}\"'**
  String routineTemplateChanged(String templateName);

  /// Error when template change fails
  ///
  /// In en, this message translates to:
  /// **'Failed to change template'**
  String get routineFailedToChange;

  /// Error message with details
  ///
  /// In en, this message translates to:
  /// **'Error changing template: {error}'**
  String routineErrorChanging(String error);

  /// Title for today's workout card
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get routineTodayWorkout;

  /// CTA button text when user has scheduled workout
  ///
  /// In en, this message translates to:
  /// **'Start {workoutName}'**
  String smartButtonStartWorkout(String workoutName);

  /// CTA button text when user completed workout today
  ///
  /// In en, this message translates to:
  /// **'View Recap'**
  String get smartButtonViewRecap;

  /// CTA button text on rest day
  ///
  /// In en, this message translates to:
  /// **'Rest. Next: {nextDate}'**
  String smartButtonRestDay(String nextDate);

  /// CTA button text when no workout scheduled
  ///
  /// In en, this message translates to:
  /// **'Explore Workouts'**
  String get smartButtonExploreWorkouts;

  /// Secondary action for rest day
  ///
  /// In en, this message translates to:
  /// **'Recovery Tips'**
  String get smartButtonRecoveryTips;

  /// CTA button text to start workout
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get smartWorkoutCTAStart;

  /// CTA card title on rest day
  ///
  /// In en, this message translates to:
  /// **'Rest Day 🌟'**
  String get smartWorkoutCTARestDay;

  /// Hint text on rest day card
  ///
  /// In en, this message translates to:
  /// **'Use \"+ Free Session\" button for a free workout'**
  String get smartWorkoutCTARestDayHint;

  /// Subtitle showing workout suggestion and duration
  ///
  /// In en, this message translates to:
  /// **'Suggested for today • ~{duration} min'**
  String smartWorkoutCTASuggestedToday(int duration);

  /// Error message when routine fails to load
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get smartWorkoutCTAErrorLoading;

  /// Error message when template fails to load
  ///
  /// In en, this message translates to:
  /// **'Template loading error'**
  String get smartWorkoutCTAErrorTemplate;

  /// Error message when routine data is incomplete
  ///
  /// In en, this message translates to:
  /// **'Incomplete routine'**
  String get smartWorkoutCTAIncompleteRoutine;

  /// Error message when template doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Template not found'**
  String get smartWorkoutCTATemplateNotFound;

  /// Smart Workout CTA disabled state - routine auto-cleaned after template deletion
  ///
  /// In en, this message translates to:
  /// **'Routine updated ✓'**
  String get smartWorkoutCTARoutineUpdated;

  /// Title for rest mode when user already worked out today
  ///
  /// In en, this message translates to:
  /// **'💪 Enjoy your well-deserved rest'**
  String get smartWorkoutCTARestModeTitle;

  /// Subtitle congratulating user on completed workout
  ///
  /// In en, this message translates to:
  /// **'You crushed an amazing workout!'**
  String get smartWorkoutCTARestModeSubtitle;

  /// Total volume lifted in workout
  ///
  /// In en, this message translates to:
  /// **'Volume: {volume} kg'**
  String smartWorkoutCTARestModeVolume(String volume);

  /// Total workout duration
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String smartWorkoutCTARestModeDuration(String duration);

  /// Total sets completed
  ///
  /// In en, this message translates to:
  /// **'Sets: {sets}'**
  String smartWorkoutCTARestModeSets(int sets);

  /// From quick wins migration - 11 occurrences
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'AI Coach Insights'**
  String get aiCoachInsights;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync already in progress'**
  String get syncAlreadyInProgress;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Invalid template ID'**
  String get invalidTemplateId;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Peso (kg)'**
  String get pesoKg;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Volume Totale'**
  String get volumeTotale;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Vedi dettagli'**
  String get vediDettagli;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'You\\\'re Premium!'**
  String get yourePremium;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Crea Template'**
  String get creaTemplate;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Errori comuni'**
  String get erroriComuni;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Dati esercizio non disponibili'**
  String get datiEsercizioNonDisponibili;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Use wheel'**
  String get useWheel;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Type manually'**
  String get typeManually;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template name is required'**
  String get templateNameIsRequired;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Livello \$level'**
  String get livelloLevel;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Volume Progress'**
  String get volumeProgress;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createRoutine;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nessun esercizio trovato'**
  String get nessunEsercizioTrovato;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'d MMM yyyy'**
  String get dMmmYyyy;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nessun dato disponibile'**
  String get nessunDatoDisponibile;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No exercise data available'**
  String get noExerciseDataAvailable;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Muscle Efficiency Score'**
  String get muscleEfficiencyScore;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Upper Body • Push'**
  String get upperBodyPush;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get showMe;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Benvenuto in GymBro! 👋'**
  String get benvenutoInGymbro;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Inizia il tuo viaggio fitness. Tocca la campanella per vedere i tuoi progressi e ricevere consigli personalizzati.'**
  String get iniziaIlTuoViaggioFitnessToccaLaCampanel;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Inizia ora'**
  String get iniziaOra;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Vedi achievement'**
  String get vediAchievement;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Milestone Raggiunto!'**
  String get milestoneRaggiunto;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Aggiornamento Progressi'**
  String get aggiornamentoProgressi;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'🔧 Forced cleanup completed after disposal error'**
  String get forcedCleanupCompletedAfterDisposalError;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoringPurchases;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Premium Status'**
  String get premiumStatus;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore'**
  String get noPurchasesFoundToRestore;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Serie Principale'**
  String get seriePrincipale;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Weight Suggestions'**
  String get weightSuggestions;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Errore nel caricamento'**
  String get erroreNelCaricamento;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error: Unable to edit this set'**
  String get errorUnableToEditThisSet;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Contribuisci alla Community'**
  String get contribuisciAllaCommunity;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Invia Contributo'**
  String get inviaContributo;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Segnala problema'**
  String get segnalaProblema;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Weight to All'**
  String get weightToAll;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Reps to All'**
  String get repsToAll;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'dd MMMM yyyy'**
  String get ddMmmmYyyy;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Pattern is empty'**
  String get patternIsEmpty;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync available for premium users only'**
  String get syncAvailableForPremiumUsersOnly;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Admin Only'**
  String get adminOnly;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nessun Contributo'**
  String get nessunContributo;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Rifiuta Contributo'**
  String get rifiutaContributo;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Motivo (opzionale)'**
  String get motivoOpzionale;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get noReasonProvided;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Trova il tuo Workout Buddy'**
  String get trovaIlTuoWorkoutBuddy;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Admin moderation not implemented in HybridRepository'**
  String get adminModerationNotImplementedInHybridrep;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Descrivi il problema in dettaglio...'**
  String get descriviIlProblemaInDettaglio;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template name cannot be empty'**
  String get templateNameCannotBeEmpty;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'invalid weight'**
  String get invalidWeight;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Add set information in format: Set1 x 5: 80kg'**
  String get addSetInformationInFormatSet1X580kg;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template must have at least one exercise'**
  String get templateMustHaveAtLeastOneExercise;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'at least one'**
  String get atLeastOne;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No workout sections found in text'**
  String get noWorkoutSectionsFoundInText;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'no set information'**
  String get noSetInformation;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Fatal error in getUserTemplates()'**
  String get fatalErrorInGetusertemplates;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Admin access required'**
  String get adminAccessRequired;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Analytics Info'**
  String get analyticsInfo;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Total Events'**
  String get totalEvents;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get avgDuration;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'User Properties'**
  String get userProperties;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync Dashboard'**
  String get syncDashboard;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Feature Status'**
  String get featureStatus;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Segna come Completato'**
  String get segnaComeCompletato;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Change Equipment'**
  String get changeEquipment;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Start Sync'**
  String get startSync;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Segnalazioni e bug utenti'**
  String get segnalazioniEBugUtenti;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'SYSTEM SOUND TEST'**
  String get systemSoundTest;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'@\$cleanHandle'**
  String get cleanhandle;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'No template'**
  String get noTemplate;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Recover Workout'**
  String get recoverWorkout;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Adherence Rate'**
  String get adherenceRate;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Skip Workout'**
  String get skipWorkout;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'GymBro User'**
  String get gymbroUser;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Consigli Personalizzati'**
  String get consigliPersonalizzati;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Vedi Analytics'**
  String get vediAnalytics;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Scegli Template'**
  String get scegliTemplate;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Seleziona un workout salvato'**
  String get selezionaUnWorkoutSalvato;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Allenamenti Recenti'**
  String get allenamentiRecenti;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Esercizio del Giorno'**
  String get esercizioDelGiorno;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'🏆 Progressi & Achievement'**
  String get progressiAchievement;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'🔥 Inarrestabile! 30+ giorni di streak!'**
  String get inarrestabile30GiorniDiStreak;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'🧪 MODAL TESTER - Debug Mode'**
  String get modalTesterDebugMode;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Test all workout modals to identify duplicates and determine which ones to keep'**
  String get testAllWorkoutModalsToIdentifyDuplicates;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'💥 Provider is in ERROR state'**
  String get providerIsInErrorState;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout Recenti'**
  String get workoutRecenti;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Streak Attuale'**
  String get streakAttuale;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Allenamenti Totali'**
  String get allenamentiTotali;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Questo Mese'**
  String get questoMese;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Secondary Actions Preview'**
  String get secondaryActionsPreview;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Reset Timer Position'**
  String get resetTimerPosition;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'APRE Calculation Method'**
  String get apreCalculationMethod;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error Details'**
  String get errorDetails;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get requestTimeout;

  /// From quick wins migration - 2 occurrences
  ///
  /// In en, this message translates to:
  /// **'SSL handshake failed - possible MITM attack'**
  String get sslHandshakeFailedPossibleMitmAttack;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'❌ \$errorMsg'**
  String get errormsg;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get debugLogs;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Timer Debug Logs - Auto-refresh every 2s\\n'**
  String get timerDebugLogsAutorefreshEvery2sn;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your analytics'**
  String get pleaseLogInToViewYourAnalytics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Loading your analytics...'**
  String get loadingYourAnalytics;

  /// Empty state for volume chart
  ///
  /// In en, this message translates to:
  /// **'No workout data yet'**
  String get noWorkoutDataYet;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Complete some workouts to see your\\nanalytics and progress!'**
  String get completeSomeWorkoutsToSeeYournanalyticsA;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No personal records yet'**
  String get noPersonalRecordsYet;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'NEW PR!'**
  String get newPr;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'❌ [Analytics] ERROR: No valid workouts found!'**
  String get analyticsErrorNoValidWorkoutsFound;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No completed exercises found in your workouts'**
  String get noCompletedExercisesFoundInYourWorkouts;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'❌ [Analytics] ERROR: syntheticActivities is EMPTY after processing!'**
  String get analyticsErrorSyntheticactivitiesIsEmpty;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Unable to load exercise activities'**
  String get unableToLoadExerciseActivities;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Loading routine analytics...'**
  String get loadingRoutineAnalytics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No Active Routine'**
  String get noActiveRoutine;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Create and activate a routine to see analytics here'**
  String get createAndActivateARoutineToSeeAnalyticsH;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error Loading Analytics'**
  String get errorLoadingAnalytics2;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Active Routine Analytics'**
  String get activeRoutineAnalytics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Skip Rate'**
  String get skipRate;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Avg Gap'**
  String get avgGap;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'between workouts'**
  String get betweenWorkouts;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template Distribution'**
  String get templateDistribution;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Weekly Pattern'**
  String get weeklyPattern;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Weekly Adherence Trend'**
  String get weeklyAdherenceTrend;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Chart visualization coming soon'**
  String get chartVisualizationComingSoon;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'workoutMetrics box not opened. Call Hive.openBox<Map>(\\\'workoutMetrics\\\') first.'**
  String get workoutmetricsBoxNotOpenedCallHiveopenbo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'workoutMetrics box must be opened before using analytics'**
  String get workoutmetricsBoxMustBeOpenedBeforeUsing;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cannot create workout from empty activities list'**
  String get cannotCreateWorkoutFromEmptyActivitiesLi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Training Recommendations'**
  String get trainingRecommendations;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Loading analytics...'**
  String get loadingAnalytics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No exercises match \"\$_searchQuery\"'**
  String get noExercisesMatch_searchquery;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No RPE data available'**
  String get noRpeDataAvailable;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Storico Esercizi'**
  String get storicoEsercizi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cerca un esercizio...'**
  String get cercaUnEsercizio;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Peso attuale'**
  String get pesoAttuale;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Inizia a registrare il tuo peso'**
  String get iniziaARegistrareIlTuoPeso;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'All Exercises Statistics'**
  String get allExercisesStatistics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Attendi qualche secondo...'**
  String get attendiQualcheSecondo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Tutti i dati sono stati sincronizzati!'**
  String get tuttiIDatiSonoStatiSincronizzati;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Si è verificato un errore durante la sincronizzazione.'**
  String get siEVerificatoUnErroreDuranteLaSincronizz;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Mostra tutti'**
  String get mostraTutti;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Periodo di visualizzazione'**
  String get periodoDiVisualizzazione;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Proiezione 30 giorni'**
  String get proiezione30Giorni;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'1RM Effettivo'**
  String get rmRmeffettivo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nessun dato 1RM disponibile'**
  String get nessunDato1rmDisponibile;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Dati insufficienti per analisi'**
  String get datiInsufficientiPerAnalisi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Rate your fatigue level to improve recovery insights'**
  String get rateYourFatigueLevelToImproveRecoveryIns;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Any specific muscle soreness or observations?'**
  String get anySpecificMuscleSorenessOrObservations;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'e1RM Tracker - Top Exercises'**
  String get e1rmTrackerTopExercises;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Best Set of the Week'**
  String get bestSetOfTheWeek;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Data synced to cloud'**
  String get dataSyncedToCloud;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync to Cloud'**
  String get syncToCloud;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No workout data this week'**
  String get noWorkoutDataThisWeek;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see your progress'**
  String get completeWorkoutsToSeeYourProgress;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Full history coming soon!'**
  String get fullHistoryComingSoon;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'💡 Training Insight'**
  String get trainingInsight;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Considera 2-3 giorni di recupero completo o un allenamento molto leggero.'**
  String get considera23GiorniDiRecuperoCompletoOUnAl;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Se pianificato, ottimo! Altrimenti, verifica se stai recuperando bene.'**
  String get sePianificatoOttimoAltrimentiVerificaSeS;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Puoi mantenere questo ritmo, ma monitora il recupero nei prossimi giorni.'**
  String get puoiMantenereQuestoRitmoMaMonitoraIlRecu;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Considera di mantenere il volume attuale per consolidare i progressi.'**
  String get consideraDiMantenereIlVolumeAttualePerCo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sono passati \$daysSinceLastWorkout giorni dall\'ultimo allenamento.'**
  String get sonoPassatiDayssincelastworkoutGiorniDal;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Riparti con calma, magari con un volume ridotto del 20-30%.'**
  String get ripartiConCalmaMagariConUnVolumeRidottoD;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Assicurati di bilanciare con giorni di recupero adeguati.'**
  String get assicuratiDiBilanciareConGiorniDiRecuper;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Frequenza di allenamento elevata con \$workoutCount sessioni questa settimana.'**
  String get frequenzaDiAllenamentoElevataConWorkoutc;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Valuta se ridurre la frequenza per migliorare il recupero.'**
  String get valutaSeRidurreLaFrequenzaPerMigliorareI;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Continua così, ascoltando sempre i segnali del tuo corpo.'**
  String get continuaCosiAscoltandoSempreISegnaliDelT;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'📊 Analisi Dettagliata'**
  String get analisiDettagliata;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'🎯 Sblocca Analisi Avanzate'**
  String get sbloccaAnalisiAvanzate;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'• Previsioni personalizzate basate su AI\\n'**
  String get previsioniPersonalizzateBasateSuAin;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Esempi Pratici'**
  String get esempiPratici;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Volume = Sets × Reps × Weight'**
  String get volumeSetsRepsWeight;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Strength % = (Current Volume / Max Volume) × 100'**
  String get strengthCurrentVolumeMaxVolume100;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Load older workouts'**
  String get loadOlderWorkouts;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Boyle (2016)'**
  String get boyle2016;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Croisier et al. (2008)'**
  String get croisierEtAl2008;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'📚 \$reference'**
  String get reference;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sets Completed'**
  String get setsCompleted;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Streak attuale'**
  String get streakAttuale2;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Più'**
  String get piu;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Giorno di riposo'**
  String get giornoDiRiposo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Optimal balance: ~17% per muscle group. Research shows balanced training prevents injuries and maximizes growth (Baz-Valle 2022)'**
  String get optimalBalance17PerMuscleGroupResearchSh;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cerca Esercizio'**
  String get cercaEsercizio;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cerca nei tuoi esercizi'**
  String get cercaNeiTuoiEsercizi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Focus more on \$neglected'**
  String get focusMoreOnNeglected;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Consider reducing \$overdeveloped volume'**
  String get considerReducingOverdevelopedVolume;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No muscle group data available'**
  String get noMuscleGroupDataAvailable;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Ricarica animazione'**
  String get ricaricaAnimazione;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Forza attuale'**
  String get forzaAttuale;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'vs ultimo mese'**
  String get vsUltimoMese;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'MMMM yyyy'**
  String get mmmmYyyy;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Performance Trends'**
  String get performanceTrends;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Track your muscle efficiency'**
  String get trackYourMuscleEfficiency;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Efficiency = Volume / Recovery Time'**
  String get efficiencyVolumeRecoveryTime;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Rate Today\\\'s Fatigue'**
  String get rateTodaysFatigue;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No workouts today to rate'**
  String get noWorkoutsTodayToRate;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Fatigue level \$fatigueLevel recorded'**
  String get fatigueLevelFatiguelevelRecorded;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailableYet;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Current Score'**
  String get currentScore;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get scoreBreakdown;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Stats temporarily unavailable'**
  String get statsTemporarilyUnavailable;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Heatmap implementation coming soon'**
  String get heatmapImplementationComingSoon;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Chart implementation coming soon'**
  String get chartImplementationComingSoon;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Bernárdez-Vázquez et al. (2022) - Healthcare'**
  String get bernrdezvzquezEtAl2022Healthcare;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Schoenfeld et al. (2021) - J Strength Cond Res'**
  String get schoenfeldEtAl2021JStrengthCondRes;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Does not account for fatigue or training state'**
  String get doesNotAccountForFatigueOrTrainingState;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error margin typically ±5-10% even in best conditions'**
  String get errorMarginTypically510EvenInBestConditi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'GymBro Analytics Report'**
  String get gymbroAnalyticsReport;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Training Performance Analysis'**
  String get trainingPerformanceAnalysis;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Training Statistics'**
  String get trainingStatistics;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Best Set'**
  String get bestSet;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Box not found'**
  String get boxNotFound;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'🔧 [Analytics] Hive box error detected. Retrying...'**
  String get analyticsHiveBoxErrorDetectedRetrying;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get pleaseSelectYourDateOfBirth;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Required by GDPR and Italian privacy laws'**
  String get requiredByGdprAndItalianPrivacyLaws;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Toggle Attivi:'**
  String get toggleAttivi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Toggle Disattivi:'**
  String get toggleDisattivi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Allenamento Rapido'**
  String get allenamentoRapido;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Da Template'**
  String get daTemplate;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'From Template'**
  String get fromTemplate;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nuovo Allenamento'**
  String get nuovoAllenamento;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Petto e Tricipiti'**
  String get pettoETricipiti;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Chest & Triceps'**
  String get chestTriceps;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get n45Min;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'4 esercizi'**
  String get n4Esercizi;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'4 exercises'**
  String get n4Exercises;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'PETTO, TRIC'**
  String get pettoTric;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Modifica Rapida'**
  String get modificaRapida;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Quick Edit'**
  String get quickEdit;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'RPE (6-10)'**
  String get rpe610;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first workout'**
  String get tapTheButtonToCreateYourFirstWorkout;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Welcome! Let\\\'s create your first workout together. I\\\'ll guide you step-by-step.'**
  String get welcomeLetsCreateYourFirstWorkoutTogethe;

  /// Button to proceed in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get letsGo;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Great! Now tap here to add your first exercise.'**
  String get greatNowTapHereToAddYourFirstExercise;

  /// From quick wins migration - 1 occurrences
  ///
  /// In en, this message translates to:
  /// **'Search by name or browse by muscle group. Choose any exercise to get started!'**
  String get searchByNameOrBrowseByMuscleGroupChooseA;

  /// From quick wins migration - 39 occurrences
  ///
  /// In en, this message translates to:
  /// **'AS IS'**
  String get asIs;

  /// From quick wins migration - 16 occurrences
  ///
  /// In en, this message translates to:
  /// **'No value associated with key \\(_errorDescription(of: key)).'**
  String get noValueAssociatedWithKey_errordescriptio;

  /// From quick wins migration - 16 occurrences
  ///
  /// In en, this message translates to:
  /// **'Unkeyed container is at end.'**
  String get unkeyedContainerIsAtEnd;

  /// From quick wins migration - 15 occurrences
  ///
  /// In en, this message translates to:
  /// **'init(coder:) has not been implemented'**
  String get initCoderHasNotBeenImplemented;

  /// From quick wins migration - 15 occurrences
  ///
  /// In en, this message translates to:
  /// **'Expected \\(type) value but found null instead.'**
  String get expectedTypeValueButFoundNullInstead;

  /// From quick wins migration - 15 occurrences
  ///
  /// In en, this message translates to:
  /// **'Expected \\(type) but found null instead.'**
  String get expectedTypeButFoundNullInstead;

  /// From quick wins migration - 12 occurrences
  ///
  /// In en, this message translates to:
  /// **'Errore: \$error'**
  String get erroreError;

  /// From quick wins migration - 12 occurrences
  ///
  /// In en, this message translates to:
  /// **'Barbell Bench Press'**
  String get barbellBenchPress;

  /// From quick wins migration - 12 occurrences
  ///
  /// In en, this message translates to:
  /// **'Expect imagePickerController'**
  String get expectImagepickercontroller;

  /// From quick wins migration - 11 occurrences
  ///
  /// In en, this message translates to:
  /// **'Centro Storico'**
  String get centroStorico;

  /// From quick wins migration - 10 occurrences
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// From quick wins migration - 10 occurrences
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get benchPress;

  /// From quick wins migration - 10 occurrences
  ///
  /// In en, this message translates to:
  /// **'Errore: \$e'**
  String get erroreE;

  /// From quick wins migration - 10 occurrences
  ///
  /// In en, this message translates to:
  /// **'Parsed JSON number <\\(number)> does not fit in \\(type).'**
  String get parsedJsonNumberNumberDoesNotFitInType;

  /// From quick wins migration - 9 occurrences
  ///
  /// In en, this message translates to:
  /// **'Expect group'**
  String get expectGroup;

  /// From quick wins migration - 9 occurrences
  ///
  /// In en, this message translates to:
  /// **'This method must be overridden.'**
  String get thisMethodMustBeOverridden;

  /// From quick wins migration - 8 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout 1'**
  String get workout1;

  /// From quick wins migration - 7 occurrences
  ///
  /// In en, this message translates to:
  /// **'Corpo Libero'**
  String get corpoLibero;

  /// From quick wins migration - 7 occurrences
  ///
  /// In en, this message translates to:
  /// **'Stack: \$stack'**
  String get stackStack;

  /// From quick wins migration - 7 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout 2'**
  String get workout2;

  /// From quick wins migration - 6 occurrences
  ///
  /// In en, this message translates to:
  /// **'EEEE, d MMMM yyyy'**
  String get eeeeDMmmmYyyy;

  /// From quick wins migration - 6 occurrences
  ///
  /// In en, this message translates to:
  /// **'Panca Piana'**
  String get pancaPiana;

  /// From quick wins migration - 6 occurrences
  ///
  /// In en, this message translates to:
  /// **'Timer Complete'**
  String get timerComplete;

  /// From quick wins migration - 6 occurrences
  ///
  /// In en, this message translates to:
  /// **'Unknown Exercise'**
  String get unknownExercise;

  /// From quick wins migration - 6 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout 3'**
  String get workout3;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync failed: \$e'**
  String get syncFailedE;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Leg Curl'**
  String get legCurl;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Unauthorized: Admin only'**
  String get unauthorizedAdminOnly;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Test Exercise'**
  String get testExercise;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'My Routine'**
  String get myRoutine;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Achievement not found'**
  String get achievementNotFound;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cannot cast \\(type(of: objCValue)) to \\(Value.self)'**
  String get cannotCastTypeOfObjcvalueToValueSelf;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'Expect collectionView'**
  String get expectCollectionview;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'I-AUT000017'**
  String get iAut000017;

  /// From quick wins migration - 5 occurrences
  ///
  /// In en, this message translates to:
  /// **'This class is not meant to be initialized.'**
  String get thisClassIsNotMeantToBeInitialized;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'MMM d'**
  String get mmmD;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Informazioni TUT'**
  String get informazioniTut;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'French Press'**
  String get frenchPress;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'EZ Bar'**
  String get ezBar;

  /// Category label for workout reminder notifications
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get workoutReminders;

  /// Toggle for daily workout reminders
  ///
  /// In en, this message translates to:
  /// **'Daily Workout Reminder'**
  String get dailyWorkoutReminder;

  /// Category label for progress tracking and motivational notifications
  ///
  /// In en, this message translates to:
  /// **'Progress & Motivation'**
  String get progressAndMotivation;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Questa azione non può essere annullata.'**
  String get questaAzioneNonPuEssereAnnullata;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Exception: '**
  String get exception;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Elimina Template'**
  String get eliminaTemplate;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'+\$jump'**
  String get jump;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Prevenzione infortuni'**
  String get prevenzioneInfortuni;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback error: \$e'**
  String get hapticFeedbackErrorE;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'EZ Curl'**
  String get ezCurl;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Leg Press'**
  String get legPress;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Barbell Back Squat'**
  String get barbellBackSquat;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'❌ Errore: \$e'**
  String get erroreE2;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Overhead Press'**
  String get overheadPress;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'RPE Medio'**
  String get rpeMedio;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'MMM d, y'**
  String get mmmDY;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'1 Workout + 1 Rest'**
  String get key1Workout1Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'2 Workouts + 1 Rest'**
  String get key2Workouts1Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'3 Workouts + 1 Rest'**
  String get key3Workouts1Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'3 Workouts + 2 Rest'**
  String get key3Workouts2Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'4 Workouts + 1 Rest'**
  String get key4Workouts1Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'4 Workouts + 3 Rest'**
  String get key4Workouts3Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'5 Workouts + 2 Rest'**
  String get key5Workouts2Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'6 Workouts + 1 Rest'**
  String get key6Workouts1Rest;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout 4'**
  String get workout4;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'3 set'**
  String get key3Set;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Continua così!'**
  String get continuaCos;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Avvia Allenamento'**
  String get avviaAllenamento;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Exercise \$current of \$total'**
  String get exerciseCurrentOfTotal;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Missing activityId'**
  String get missingActivityid;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'I-AUT000008'**
  String get iAut000008;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'   - ID: \\(identifier)'**
  String get idIdentifier;

  /// From quick wins migration - 4 occurrences
  ///
  /// In en, this message translates to:
  /// **'Live Activities require iOS 16.1 or later'**
  String get liveActivitiesRequireIos161OrLater;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Stack: \$stackTrace'**
  String get stackStacktrace;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Tracciamento RPE'**
  String get tracciamentoRpe;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Timer Automatico'**
  String get timerAutomatico;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Suggerimenti Community'**
  String get suggerimentiCommunity;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'PETTO, TRIC, DELT_ANT'**
  String get pettoTricDelt_ant;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get advancedFeatures;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Use unreadNotificationCountProvider from unified_notification_provider.dart'**
  String get useUnreadnotificationcountproviderFromUn;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Use todayNotificationsProvider from unified_notification_provider.dart'**
  String get useTodaynotificationsproviderFromUnified;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Provider disposed'**
  String get providerDisposed;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Notification permissions not granted'**
  String get notificationPermissionsNotGranted;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Workout Reminder'**
  String get workoutReminder;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Save 33%'**
  String get save33;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'You\\\'re Premium!'**
  String get youRePremium;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Community Access'**
  String get communityAccess;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Shoulder Press'**
  String get shoulderPress;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Elimina un template esistente o passa a Premium per avere più spazio.'**
  String get eliminaUnTemplateEsistenteOPassaAPremium;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi'**
  String get ilTemplateVerrSalvatoSuFirebaseESarDispo;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template personalizzato'**
  String get templatePersonalizzato;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Elimina template esistenti o passa a Premium.'**
  String get eliminaTemplateEsistentiOPassaAPremium;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'FitLog Pro'**
  String get fitlogPro;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Continue your routine'**
  String get continueYourRoutine;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Nessun template personalizzato'**
  String get nessunTemplatePersonalizzato;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Stato Sincronizzazione'**
  String get statoSincronizzazione;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Conferma Serie'**
  String get confermaSerie;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Muscoli secondari'**
  String get muscoliSecondari;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Tipo esercizio'**
  String get tipoEsercizio;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Range ripetizioni'**
  String get rangeRipetizioni;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Pattern movimento'**
  String get patternMovimento;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Serie riscaldamento'**
  String get serieRiscaldamento;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Durata riscaldamento'**
  String get durataRiscaldamento;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Mobilità articolare'**
  String get mobilitArticolare;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Attivazione muscolare'**
  String get attivazioneMuscolare;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Progressione carico'**
  String get progressioneCarico;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Note tecniche'**
  String get noteTecniche;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Drill tecnico'**
  String get drillTecnico;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cooldown consigliato'**
  String get cooldownConsigliato;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Muscoli target'**
  String get muscoliTarget;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Serie di Riscaldamento'**
  String get serieDiRiscaldamento;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Prevenzione Infortuni'**
  String get prevenzioneInfortuni2;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Ho capito!'**
  String get hoCapito;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Pre-loaded fixed bar'**
  String get preLoadedFixedBar;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Non trovi l\\\'esercizio? Creane uno personalizzato'**
  String get nonTroviLEsercizioCreaneUnoPersonalizzat;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Mini-Set \$index'**
  String get miniSetIndex;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'👍 Voto positivo!'**
  String get votoPositivo;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'👎 Voto negativo'**
  String get votoNegativo;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'In attesa'**
  String get inAttesa;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Partnership attiva'**
  String get partnershipAttiva;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Dettagli Esercizio'**
  String get dettagliEsercizio;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'🐛 Bug'**
  String get bug;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error loading feedback'**
  String get errorLoadingFeedback;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Esercizi Obsoleti'**
  String get eserciziObsoleti;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Esercizi Flaggati'**
  String get eserciziFlaggati;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'≥3 feedback'**
  String get key3Feedback;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'allenamenti funzionali'**
  String get allenamentiFunzionali;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'2 anni'**
  String get key2Anni;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Barbell Squat'**
  String get barbellSquat;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Day skipped'**
  String get daySkipped;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **', userId: email)}'**
  String get useridEmail;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Progressione Carico'**
  String get progressioneCarico2;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Recupero Ottimale'**
  String get recuperoOttimale;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Bilanciamento Muscolare'**
  String get bilanciamentoMuscolare;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Accedi per vedere i workout'**
  String get accediPerVedereIWorkout;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Azioni Rapide'**
  String get azioniRapide;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Start rest timer after completing set'**
  String get startRestTimerAfterCompletingSet;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Show drop sets, supersets, etc.'**
  String get showDropSetsSupersetsEtc;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Show timer on lock screen & Dynamic Island'**
  String get showTimerOnLockScreenDynamicIsland;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sync workouts to Apple Health'**
  String get syncWorkoutsToAppleHealth;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Play sounds for timer and completion'**
  String get playSoundsForTimerAndCompletion;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback for interactions'**
  String get hapticFeedbackForInteractions;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get englishUs;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Italian (IT)'**
  String get italianIt;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get kilogramsKg;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Metric system'**
  String get metricSystem;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Pounds (lbs)'**
  String get poundsLbs;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Imperial system'**
  String get imperialSystem;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults? This cannot be undone.'**
  String get areYouSureYouWantToResetAllSettingsToDef;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Export functionality coming soon'**
  String get exportFunctionalityComingSoon;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Import functionality coming soon'**
  String get importFunctionalityComingSoon;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Cerca esercizi...'**
  String get cercaEsercizi;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Aggiungi Serie'**
  String get aggiungiSerie;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Drop Set'**
  String get dropSet;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Unità di Peso'**
  String get unitDiPeso;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sei sicuro di voler ripristinare tutte le impostazioni ai valori predefiniti? Questa azione non può essere annullata.'**
  String get seiSicuroDiVolerRipristinareTutteLeImpos;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Template non trovato'**
  String get templateNonTrovato;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Rimuovi definitivamente'**
  String get rimuoviDefinitivamente;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Note (opzionale)'**
  String get noteOpzionale;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Aggiunto \$exerciseName all\\\'allenamento'**
  String get aggiuntoExercisenameAllAllenamento;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Applica Modifiche'**
  String get applicaModifiche;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Salta per ora'**
  String get saltaPerOra;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Inserisci la tua email'**
  String get inserisciLaTuaEmail;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Crea Account'**
  String get creaAccount;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Vai alla Home'**
  String get vaiAllaHome;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Sei sicuro di voler eliminare \\\"\$name\\\"?'**
  String get seiSicuroDiVolerEliminareName;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Crea Routine'**
  String get creaRoutine;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'No compatible alternatives found'**
  String get noCompatibleAlternativesFound;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Applying changes...'**
  String get applyingChanges;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Drop Set: Perform exercise to failure, then immediately reduce weight and continue.'**
  String get dropSetPerformExerciseToFailureThenImmed;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Rest-Pause: Perform to failure, rest 10-15 seconds, repeat until target reps.'**
  String get restPausePerformToFailureRest1015Seconds;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Added \$exerciseName to workout'**
  String get addedExercisenameToWorkout;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'1 template'**
  String get key1Template;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Increase Training Frequency'**
  String get increaseTrainingFrequency;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get estimated1rm;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Use the import function in the template screen'**
  String get useTheImportFunctionInTheTemplateScreen;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \\\"\$name\\\"?'**
  String get areYouSureYouWantToDeleteName;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Error saving: \$error'**
  String get errorSavingError;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'⚠️ No rate limiter for endpoint: \$endpoint'**
  String get noRateLimiterForEndpointEndpoint;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Live Activities are disabled'**
  String get liveActivitiesAreDisabled;

  /// From quick wins migration - 3 occurrences
  ///
  /// In en, this message translates to:
  /// **'Missing required parameters'**
  String get missingRequiredParameters;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @saveThirtyThreePercent.
  ///
  /// In en, this message translates to:
  /// **'Save 33%'**
  String get saveThirtyThreePercent;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get prioritySupport;

  /// No description provided for @fullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full Access'**
  String get fullAccess;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Hero section title for premium screen
  ///
  /// In en, this message translates to:
  /// **'Unlock GymBro Premium'**
  String get unlockGymbroPremium;

  /// Premium hero section subtitle
  ///
  /// In en, this message translates to:
  /// **'Sync everywhere • Backup forever • Join the community'**
  String get premiumTagline;

  /// Cloud sync feature description
  ///
  /// In en, this message translates to:
  /// **'All devices, always in sync'**
  String get allDevicesAlwaysInSync;

  /// Auto backup feature description
  ///
  /// In en, this message translates to:
  /// **'Never lose your data'**
  String get neverLoseYourData;

  /// Community feature description
  ///
  /// In en, this message translates to:
  /// **'Share & discover workouts'**
  String get shareDiscoverWorkouts;

  /// Analytics Pro feature title
  ///
  /// In en, this message translates to:
  /// **'Analytics Pro'**
  String get analyticsPro;

  /// Live updates feature title
  ///
  /// In en, this message translates to:
  /// **'Live Updates'**
  String get liveUpdates;

  /// Live updates feature description
  ///
  /// In en, this message translates to:
  /// **'Real-time sync'**
  String get realTimeSync;

  /// Priority support feature description
  ///
  /// In en, this message translates to:
  /// **'Get help fast'**
  String get getHelpFast;

  /// Yearly plan broken down to monthly price
  ///
  /// In en, this message translates to:
  /// **'Only \$3.33/month'**
  String get yearlyPlanMonthlyPrice;

  /// Badge for recommended plan
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get recommended;

  /// Terms and conditions section title
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// iOS subscription terms
  ///
  /// In en, this message translates to:
  /// **'• Cancel anytime from App Store\n• Subscription auto-renews unless turned off\n• Payment charged to iTunes account'**
  String get cancelAnytimeAppStore;

  /// Android subscription terms
  ///
  /// In en, this message translates to:
  /// **'• Cancel anytime from Google Play\n• Subscription auto-renews unless turned off\n• Payment charged to Google Play account'**
  String get cancelAnytimeGooglePlay;

  /// Purchase button with plan name
  ///
  /// In en, this message translates to:
  /// **'Continue with {plan}'**
  String continueWithPlan(String plan);

  /// Message during migration
  ///
  /// In en, this message translates to:
  /// **'Please wait, this may take a moment'**
  String get pleaseWait;

  /// Account tier display
  ///
  /// In en, this message translates to:
  /// **'Account tier: {tier}'**
  String accountTier(String tier);

  /// Automatic backup status
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// Success message after restoring premium
  ///
  /// In en, this message translates to:
  /// **'✅ Premium restored successfully!'**
  String get premiumRestoredSuccess;

  /// Message when no purchases to restore
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore'**
  String get noPurchasesToRestore;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @premiumMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembership;

  /// No description provided for @welcomeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium! 🎉'**
  String get welcomeToPremium;

  /// No description provided for @purchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled'**
  String get purchaseCancelled;

  /// Template category: strength training
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get templateCategoryStrength;

  /// Template category: cardio training
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get templateCategoryCardio;

  /// Template category: flexibility/mobility training
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get templateCategoryFlexibility;

  /// Template category: hybrid/mixed training
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get templateCategoryHybrid;

  /// Expert difficulty level badge
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// Template never performed before
  ///
  /// In en, this message translates to:
  /// **'🆕 New'**
  String get templateStatsNew;

  /// Template performed today
  ///
  /// In en, this message translates to:
  /// **'✅ Today'**
  String get templateStatsToday;

  /// Template performed yesterday
  ///
  /// In en, this message translates to:
  /// **'🕐 Yesterday'**
  String get templateStatsYesterday;

  /// Template performed X days ago
  ///
  /// In en, this message translates to:
  /// **'🕐 {days} days ago'**
  String templateStatsDaysAgo(int days);

  /// Template not performed in 14+ days, encourage resuming
  ///
  /// In en, this message translates to:
  /// **'🔄 Resume?'**
  String get templateStatsResume;

  /// Share template action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get templateActionShare;

  /// Duplicate template action
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get templateActionDuplicate;

  /// Edit template action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get templateActionEdit;

  /// Delete template action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get templateActionDelete;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String purchaseError(String error);

  /// No description provided for @unlockYourFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Full Potential'**
  String get unlockYourFullPotential;

  /// No description provided for @syncAcrossAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync across all devices, access community features, and never lose your progress'**
  String get syncAcrossAllDevices;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// No description provided for @whatUsersSay.
  ///
  /// In en, this message translates to:
  /// **'What Users Say'**
  String get whatUsersSay;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @startFreeTrialThen.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial - Then \$39.99/year'**
  String get startFreeTrialThen;

  /// No description provided for @thankYouForSupporting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting GymBro'**
  String get thankYouForSupporting;

  /// No description provided for @faqCanICancel.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel anytime?'**
  String get faqCanICancel;

  /// No description provided for @faqWhatHappensToData.
  ///
  /// In en, this message translates to:
  /// **'What happens to my data if I cancel?'**
  String get faqWhatHappensToData;

  /// No description provided for @faqCanIChangePlans.
  ///
  /// In en, this message translates to:
  /// **'Can I change plans?'**
  String get faqCanIChangePlans;

  /// No description provided for @faqIsPaymentSecure.
  ///
  /// In en, this message translates to:
  /// **'Is my payment secure?'**
  String get faqIsPaymentSecure;

  /// No description provided for @faqCancelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can cancel your subscription anytime from settings.'**
  String get faqCancelAnswer;

  /// No description provided for @faqDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your data remains safe locally. You just lose cloud sync.'**
  String get faqDataAnswer;

  /// No description provided for @faqChangePlansAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can upgrade or downgrade anytime.'**
  String get faqChangePlansAnswer;

  /// No description provided for @faqPaymentSecureAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, we use Apple/Google payment systems for maximum security.'**
  String get faqPaymentSecureAnswer;

  /// No description provided for @testimonialJohnD.
  ///
  /// In en, this message translates to:
  /// **'The sync feature is a game changer! I can start a workout on my phone and finish on my tablet.'**
  String get testimonialJohnD;

  /// No description provided for @testimonialSarahM.
  ///
  /// In en, this message translates to:
  /// **'Community templates saved me hours of planning. Worth every penny!'**
  String get testimonialSarahM;

  /// No description provided for @testimonialMikeR.
  ///
  /// In en, this message translates to:
  /// **'Never lost a workout since going premium. The backup is automatic and reliable.'**
  String get testimonialMikeR;

  /// No description provided for @enjoyAllPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all premium features'**
  String get enjoyAllPremiumFeatures;

  /// No description provided for @getUnlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to all features'**
  String get getUnlimitedAccess;

  /// No description provided for @trackWorkoutVolume.
  ///
  /// In en, this message translates to:
  /// **'Track your workout volume over time'**
  String get trackWorkoutVolume;

  /// No description provided for @comprehensiveWeeklyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive weekly workout analytics'**
  String get comprehensiveWeeklyAnalytics;

  /// No description provided for @analyzeMuscleGroupBalance.
  ///
  /// In en, this message translates to:
  /// **'Analyze muscle group balance'**
  String get analyzeMuscleGroupBalance;

  /// No description provided for @deepInsights.
  ///
  /// In en, this message translates to:
  /// **'Deep insights into your performance'**
  String get deepInsights;

  /// No description provided for @detailedHistory.
  ///
  /// In en, this message translates to:
  /// **'Detailed History'**
  String get detailedHistory;

  /// No description provided for @completeWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Complete workout history with details'**
  String get completeWorkoutHistory;

  /// No description provided for @syncAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync across all your devices'**
  String get syncAcrossDevices;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// No description provided for @enjoyAdFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Enjoy ad-free experience'**
  String get enjoyAdFreeExperience;

  /// No description provided for @inAppPurchasesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases coming soon!\nPremium features are currently in beta.'**
  String get inAppPurchasesComingSoon;

  /// No description provided for @thankYouForBeingPremium.
  ///
  /// In en, this message translates to:
  /// **'Thank you for being Premium!'**
  String get thankYouForBeingPremium;

  /// No description provided for @gymbroPremium.
  ///
  /// In en, this message translates to:
  /// **'GymBro Premium'**
  String get gymbroPremium;

  /// No description provided for @youArePremium.
  ///
  /// In en, this message translates to:
  /// **'You are Premium!'**
  String get youArePremium;

  /// No description provided for @youHaveAccessToAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'You have access to all features'**
  String get youHaveAccessToAllFeatures;

  /// Message shown when plan is not yet available
  ///
  /// In en, this message translates to:
  /// **'{plan} plan will be available soon!'**
  String planWillBeAvailableSoon(String plan);

  /// No description provided for @saveVsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Save 33% vs monthly'**
  String get saveVsMonthly;

  /// No description provided for @pleaseLoginToViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your analytics'**
  String get pleaseLoginToViewAnalytics;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @userReportsAndBugs.
  ///
  /// In en, this message translates to:
  /// **'User reports and bugs'**
  String get userReportsAndBugs;

  /// No description provided for @onboardingResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Onboarding reset complete'**
  String get onboardingResetComplete;

  /// No description provided for @customizeHome.
  ///
  /// In en, this message translates to:
  /// **'Customize Home'**
  String get customizeHome;

  /// No description provided for @dragToReorderTapToConfigure.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder, tap to configure'**
  String get dragToReorderTapToConfigure;

  /// No description provided for @manageExerciseReports.
  ///
  /// In en, this message translates to:
  /// **'Manage exercise reports'**
  String get manageExerciseReports;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @expanded.
  ///
  /// In en, this message translates to:
  /// **'Expanded'**
  String get expanded;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @addWidget.
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get addWidget;

  /// No description provided for @createNewRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create New Routine'**
  String get createNewRoutine;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get noRoutinesYet;

  /// No description provided for @createFirstRoutineDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first training routine to get started'**
  String get createFirstRoutineDescription;

  /// No description provided for @createFirstRoutineButton.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createFirstRoutineButton;

  /// No description provided for @chooseFromPopularPatterns.
  ///
  /// In en, this message translates to:
  /// **'Or choose from popular patterns'**
  String get chooseFromPopularPatterns;

  /// No description provided for @activateRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Activate this routine?'**
  String get activateRoutineConfirm;

  /// No description provided for @archiveRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this routine?'**
  String get archiveRoutineConfirm;

  /// No description provided for @deleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine?'**
  String get deleteRoutineConfirm;

  /// No description provided for @routineUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Routine restored'**
  String get routineUnarchived;

  /// No description provided for @routineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Routine deleted'**
  String get routineDeleted;

  /// No description provided for @failedToActivate.
  ///
  /// In en, this message translates to:
  /// **'Failed to activate routine'**
  String get failedToActivate;

  /// No description provided for @failedToArchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive routine'**
  String get failedToArchive;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete routine'**
  String get failedToDelete;

  /// No description provided for @failedToUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore routine'**
  String get failedToUnarchive;

  /// No description provided for @failedToLoadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to load template'**
  String get failedToLoadTemplate;

  /// No description provided for @alternativesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Alternatives coming soon'**
  String get alternativesComingSoon;

  /// No description provided for @checkFirebasePermissions.
  ///
  /// In en, this message translates to:
  /// **'Please check Firebase permissions or contact support'**
  String get checkFirebasePermissions;

  /// No description provided for @errorLoadingRoutines.
  ///
  /// In en, this message translates to:
  /// **'Error loading routines'**
  String get errorLoadingRoutines;

  /// No description provided for @suggestionLevel.
  ///
  /// In en, this message translates to:
  /// **'Suggestion level'**
  String get suggestionLevel;

  /// Shown when a template has no exercises
  ///
  /// In en, this message translates to:
  /// **'No exercises'**
  String get noExercises;

  /// No description provided for @settingsWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get settingsWorkout;

  /// No description provided for @settingsIosFeatures.
  ///
  /// In en, this message translates to:
  /// **'iOS Features'**
  String get settingsIosFeatures;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get settingsExport;

  /// No description provided for @settingsExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Save settings as JSON file'**
  String get settingsExportDesc;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get settingsImport;

  /// No description provided for @settingsImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Load settings from JSON file'**
  String get settingsImportDesc;

  /// No description provided for @settingsDataMigrationAvailable.
  ///
  /// In en, this message translates to:
  /// **'You have data to migrate from previous version'**
  String get settingsDataMigrationAvailable;

  /// No description provided for @settingsDataMigrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Migration completed or not needed'**
  String get settingsDataMigrationComplete;

  /// No description provided for @settingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get settingsAvailable;

  /// No description provided for @settingsBetaModeEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'All premium features unlocked for testing'**
  String get settingsBetaModeEnabledDesc;

  /// No description provided for @settingsBetaModeDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable temporary access to all premium features'**
  String get settingsBetaModeDisabledDesc;

  /// No description provided for @settingsResetToDefaultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to default'**
  String get settingsResetToDefaultsDesc;

  /// No description provided for @settingsAccountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get settingsAccountActions;

  /// No description provided for @settingsSignOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsSignOutDesc;

  /// No description provided for @settingsItaliano.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get settingsItaliano;

  /// No description provided for @settingsAccentColorDialog.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColorDialog;

  /// No description provided for @settingsDefaultRestTimeDialog.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Time'**
  String get settingsDefaultRestTimeDialog;

  /// No description provided for @settingsResetTimerPositionDialog.
  ///
  /// In en, this message translates to:
  /// **'Reset Timer Position'**
  String get settingsResetTimerPositionDialog;

  /// No description provided for @settingsResetTimerPositionDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.'**
  String get settingsResetTimerPositionDialogDesc;

  /// No description provided for @settingsTimerPositionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Timer position reset to default'**
  String get settingsTimerPositionResetSuccess;

  /// No description provided for @settingsFailedToClearCache.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache: {error}'**
  String settingsFailedToClearCache(Object error);

  /// No description provided for @settingsResetSettingsDialog.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetSettingsDialog;

  /// No description provided for @settingsResetSettingsDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults? This cannot be undone.'**
  String get settingsResetSettingsDialogDesc;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutConfirm;

  /// No description provided for @settingsApreCalculationMethodUpdated.
  ///
  /// In en, this message translates to:
  /// **'APRE calculation method updated to {method}'**
  String settingsApreCalculationMethodUpdated(Object method);

  /// No description provided for @settingsApreCalculationMethodLoading.
  ///
  /// In en, this message translates to:
  /// **'APRE Calculation Method'**
  String get settingsApreCalculationMethodLoading;

  /// No description provided for @settingsLoadingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get settingsLoadingGeneric;

  /// No description provided for @settingsApreCalculationMethodError.
  ///
  /// In en, this message translates to:
  /// **'APRE Calculation Method'**
  String get settingsApreCalculationMethodError;

  /// No description provided for @settingsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String settingsErrorGeneric(Object error);

  /// No description provided for @exerciseListEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get exerciseListEdit;

  /// No description provided for @exerciseListDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get exerciseListDuplicate;

  /// No description provided for @exerciseListInsight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get exerciseListInsight;

  /// No description provided for @exerciseListAddNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get exerciseListAddNotesHint;

  /// No description provided for @exerciseListTapToAddNotes.
  ///
  /// In en, this message translates to:
  /// **'Tap to add notes'**
  String get exerciseListTapToAddNotes;

  /// No description provided for @exerciseListSetsProgress.
  ///
  /// In en, this message translates to:
  /// **'Sets ({completed}/{total})'**
  String exerciseListSetsProgress(Object completed, Object total);

  /// No description provided for @exerciseListSetAdded.
  ///
  /// In en, this message translates to:
  /// **'Set {setNumber} added'**
  String exerciseListSetAdded(Object setNumber);

  /// No description provided for @exerciseListSetRestTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'Set rest time between sets for \"{exerciseName}\"'**
  String exerciseListSetRestTimeMessage(Object exerciseName);

  /// No description provided for @exerciseListCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get exerciseListCancel;

  /// No description provided for @exerciseListSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get exerciseListSave;

  /// No description provided for @exerciseListSetRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Set Rest Timer'**
  String get exerciseListSetRestTimer;

  /// No description provided for @exerciseListCustomTime.
  ///
  /// In en, this message translates to:
  /// **'Custom: {time}'**
  String exerciseListCustomTime(Object time);

  /// No description provided for @exerciseListCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get exerciseListCustom;

  /// No description provided for @exerciseListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get exerciseListConfirm;

  /// No description provided for @exerciseListCustomRestTime.
  ///
  /// In en, this message translates to:
  /// **'Custom Rest Time'**
  String get exerciseListCustomRestTime;

  /// No description provided for @exerciseListMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get exerciseListMinutes;

  /// No description provided for @exerciseListSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get exerciseListSeconds;

  /// No description provided for @exerciseListSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get exerciseListSetButton;

  /// No description provided for @exerciseListRestTimerSetTo.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Rest timer set to {time}'**
  String exerciseListRestTimerSetTo(Object time);

  /// No description provided for @workoutTemplateSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get workoutTemplateSearchHint;

  /// No description provided for @workoutTemplateRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workoutTemplateRetry;

  /// No description provided for @workoutTemplateNoPopularYet.
  ///
  /// In en, this message translates to:
  /// **'No popular templates yet'**
  String get workoutTemplateNoPopularYet;

  /// No description provided for @workoutTemplateMostUsedWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Most used templates will appear here'**
  String get workoutTemplateMostUsedWillAppear;

  /// No description provided for @workoutTemplateNoCustom.
  ///
  /// In en, this message translates to:
  /// **'No custom templates'**
  String get workoutTemplateNoCustom;

  /// No description provided for @workoutTemplateCreateFirstCustom.
  ///
  /// In en, this message translates to:
  /// **'Create your first custom template'**
  String get workoutTemplateCreateFirstCustom;

  /// No description provided for @workoutTemplateNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get workoutTemplateNoneFound;

  /// No description provided for @workoutTemplateSharingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'📤 Template sharing coming soon...'**
  String get workoutTemplateSharingComingSoon;

  /// No description provided for @workoutTemplateDuplicatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Template duplicated: \"{templateName}\"'**
  String workoutTemplateDuplicatedSuccess(Object templateName);

  /// No description provided for @workoutTemplateDuplicationError.
  ///
  /// In en, this message translates to:
  /// **'Error duplicating: {error}'**
  String workoutTemplateDuplicationError(Object error);

  /// No description provided for @workoutTemplateDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get workoutTemplateDeleteTitle;

  /// No description provided for @workoutTemplateDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{templateName}\"?'**
  String workoutTemplateDeleteConfirm(Object templateName);

  /// No description provided for @workoutTemplateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutTemplateCancel;

  /// No description provided for @workoutTemplateSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get workoutTemplateSyncStatus;

  /// No description provided for @exerciseOptionsTapToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Tap to enlarge'**
  String get exerciseOptionsTapToEnlarge;

  /// No description provided for @exerciseOptionsExerciseInfo.
  ///
  /// In en, this message translates to:
  /// **'Exercise info'**
  String get exerciseOptionsExerciseInfo;

  /// No description provided for @exerciseOptionsExerciseInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Muscles involved and technique'**
  String get exerciseOptionsExerciseInfoSubtitle;

  /// No description provided for @exerciseOptionsWarmupInfo.
  ///
  /// In en, this message translates to:
  /// **'Warmup info'**
  String get exerciseOptionsWarmupInfo;

  /// No description provided for @exerciseOptionsWarmupInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for warmup'**
  String get exerciseOptionsWarmupInfoSubtitle;

  /// No description provided for @exerciseOptionsNoWarmupDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No warmup data available'**
  String get exerciseOptionsNoWarmupDataAvailable;

  /// No description provided for @exerciseOptionsInjuryPrevention.
  ///
  /// In en, this message translates to:
  /// **'Injury prevention'**
  String get exerciseOptionsInjuryPrevention;

  /// No description provided for @exerciseOptionsInjuryPreventionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tips to avoid injuries'**
  String get exerciseOptionsInjuryPreventionSubtitle;

  /// No description provided for @exerciseOptionsNoInjuryPreventionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No injury prevention data available'**
  String get exerciseOptionsNoInjuryPreventionDataAvailable;

  /// No description provided for @exerciseOptionsReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report issue'**
  String get exerciseOptionsReportIssue;

  /// No description provided for @exerciseOptionsReportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bugs, errors or suggestions'**
  String get exerciseOptionsReportIssueSubtitle;

  /// No description provided for @exerciseOptionsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get exerciseOptionsHistory;

  /// No description provided for @exerciseOptionsEditNameAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit name and notes'**
  String get exerciseOptionsEditNameAndNotes;

  /// No description provided for @exerciseOptionsEditNameAndNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize exercise name and add notes'**
  String get exerciseOptionsEditNameAndNotesSubtitle;

  /// No description provided for @exerciseOptionsChangeCountingFormat.
  ///
  /// In en, this message translates to:
  /// **'Change counting format'**
  String get exerciseOptionsChangeCountingFormat;

  /// No description provided for @exerciseOptionsChangeCountingFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between weight/reps/time'**
  String get exerciseOptionsChangeCountingFormatSubtitle;

  /// No description provided for @exerciseOptionsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate exercise'**
  String get exerciseOptionsDuplicate;

  /// No description provided for @exerciseOptionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get exerciseOptionsDelete;

  /// No description provided for @exerciseOptionsExerciseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Info'**
  String get exerciseOptionsExerciseInfoTitle;

  /// No description provided for @exerciseOptionsPrimaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Primary Muscles'**
  String get exerciseOptionsPrimaryMuscles;

  /// No description provided for @exerciseOptionsSecondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get exerciseOptionsSecondaryMuscles;

  /// No description provided for @exerciseOptionsEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseOptionsEquipment;

  /// No description provided for @exerciseOptionsDifficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get exerciseOptionsDifficultyLevel;

  /// No description provided for @exerciseOptionsWarmupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Warmup Info'**
  String get exerciseOptionsWarmupInfoTitle;

  /// No description provided for @exerciseOptionsPreWorkoutMobility.
  ///
  /// In en, this message translates to:
  /// **'Pre-Workout Mobility'**
  String get exerciseOptionsPreWorkoutMobility;

  /// No description provided for @exerciseOptionsPreWorkoutActivation.
  ///
  /// In en, this message translates to:
  /// **'Pre-Workout Activation'**
  String get exerciseOptionsPreWorkoutActivation;

  /// No description provided for @exerciseOptionsWarmupSets.
  ///
  /// In en, this message translates to:
  /// **'Warmup Sets'**
  String get exerciseOptionsWarmupSets;

  /// No description provided for @exerciseOptionsInjuryPreventionTitle.
  ///
  /// In en, this message translates to:
  /// **'Injury Prevention'**
  String get exerciseOptionsInjuryPreventionTitle;

  /// No description provided for @exerciseOptionsInjuryPreventionSection.
  ///
  /// In en, this message translates to:
  /// **'Injury Prevention'**
  String get exerciseOptionsInjuryPreventionSection;

  /// No description provided for @exerciseOptionsRecommendedCooldown.
  ///
  /// In en, this message translates to:
  /// **'Recommended Cooldown'**
  String get exerciseOptionsRecommendedCooldown;

  /// No description provided for @exerciseOptionsTechnicalTips.
  ///
  /// In en, this message translates to:
  /// **'Technical Tips'**
  String get exerciseOptionsTechnicalTips;

  /// No description provided for @dailyWorkoutAutoCompleting.
  ///
  /// In en, this message translates to:
  /// **'Auto-completing day... ✨'**
  String get dailyWorkoutAutoCompleting;

  /// No description provided for @dailyWorkoutDifferentWorkoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed a different workout today'**
  String get dailyWorkoutDifferentWorkoutCompleted;

  /// No description provided for @dailyWorkoutSubstitute.
  ///
  /// In en, this message translates to:
  /// **'Substitute'**
  String get dailyWorkoutSubstitute;

  /// No description provided for @dailyWorkoutSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dailyWorkoutSkip;

  /// No description provided for @dailyWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get dailyWorkoutComplete;

  /// No description provided for @dailyWorkoutRestAndRecovery.
  ///
  /// In en, this message translates to:
  /// **'Rest & Recovery'**
  String get dailyWorkoutRestAndRecovery;

  /// No description provided for @dailyWorkoutRestAndRecoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a break and let your body recover'**
  String get dailyWorkoutRestAndRecoverySubtitle;

  /// No description provided for @dailyWorkoutDefaultWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get dailyWorkoutDefaultWorkoutName;

  /// No description provided for @dailyWorkoutLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get dailyWorkoutLoading;

  /// No description provided for @dailyWorkoutTapCompleteWhenDone.
  ///
  /// In en, this message translates to:
  /// **'Tap complete when done'**
  String get dailyWorkoutTapCompleteWhenDone;

  /// No description provided for @dailyWorkoutGreatWork.
  ///
  /// In en, this message translates to:
  /// **'Great work! Keep it up 💪'**
  String get dailyWorkoutGreatWork;

  /// No description provided for @dailyWorkoutDaySkipped.
  ///
  /// In en, this message translates to:
  /// **'Day skipped. Consider recovering it!'**
  String get dailyWorkoutDaySkipped;

  /// No description provided for @dailyWorkoutDayRecovered.
  ///
  /// In en, this message translates to:
  /// **'Day recovered successfully!'**
  String get dailyWorkoutDayRecovered;

  /// No description provided for @dailyWorkoutStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get dailyWorkoutStatusCompleted;

  /// No description provided for @dailyWorkoutStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get dailyWorkoutStatusSkipped;

  /// No description provided for @dailyWorkoutStatusRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get dailyWorkoutStatusRecovered;

  /// No description provided for @dailyWorkoutStatusReadyToGo.
  ///
  /// In en, this message translates to:
  /// **'Ready to go'**
  String get dailyWorkoutStatusReadyToGo;

  /// No description provided for @dailyWorkoutSubstituteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Substitute Workout?'**
  String get dailyWorkoutSubstituteDialogTitle;

  /// No description provided for @dailyWorkoutSubstituteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You completed a different workout today. Do you want to mark this day as completed with that workout instead?'**
  String get dailyWorkoutSubstituteDialogMessage;

  /// No description provided for @dailyWorkoutSubstituteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Substitute'**
  String get dailyWorkoutSubstituteDialogConfirm;

  /// No description provided for @dailyWorkoutSubstituteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dailyWorkoutSubstituteDialogCancel;

  /// No description provided for @exerciseListUseDefaultTimer.
  ///
  /// In en, this message translates to:
  /// **'Use default timer'**
  String get exerciseListUseDefaultTimer;

  /// No description provided for @exerciseListUsesGlobalRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Uses global rest timer'**
  String get exerciseListUsesGlobalRestTimer;

  /// No description provided for @exerciseListQuickOptions.
  ///
  /// In en, this message translates to:
  /// **'Quick options'**
  String get exerciseListQuickOptions;

  /// No description provided for @exerciseListUsingDefaultTimer.
  ///
  /// In en, this message translates to:
  /// **'Using default timer'**
  String get exerciseListUsingDefaultTimer;

  /// No description provided for @settingsThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get settingsThemeColor;

  /// No description provided for @settingsThemeColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get settingsThemeColorDesc;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Sample Text ({size})'**
  String settingsTextSizePreview(Object size);

  /// No description provided for @settingsWorkoutEssentials.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get settingsWorkoutEssentials;

  /// No description provided for @settingsApreAutoAdjustment.
  ///
  /// In en, this message translates to:
  /// **'APRE Auto-Adjustment'**
  String get settingsApreAutoAdjustment;

  /// No description provided for @settingsApreAutoAdjustmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatic weight progression'**
  String get settingsApreAutoAdjustmentDesc;

  /// No description provided for @settingsApreProtocol.
  ///
  /// In en, this message translates to:
  /// **'APRE Protocol'**
  String get settingsApreProtocol;

  /// No description provided for @settingsApreProtocolDesc.
  ///
  /// In en, this message translates to:
  /// **'Protocol {number}'**
  String settingsApreProtocolDesc(Object number);

  /// No description provided for @settingsApreProtocolUpdated.
  ///
  /// In en, this message translates to:
  /// **'APRE protocol updated to {protocol}'**
  String settingsApreProtocolUpdated(Object protocol);

  /// Title for day cutoff hour setting
  ///
  /// In en, this message translates to:
  /// **'Day Cutoff Hour'**
  String get settingsDayCutoffHour;

  /// Subtitle for day cutoff hour setting
  ///
  /// In en, this message translates to:
  /// **'Workouts after {hour}:00 count as \'today\''**
  String settingsDayCutoffHourDesc(int hour);

  /// Title for day cutoff hour dialog
  ///
  /// In en, this message translates to:
  /// **'Day Cutoff Hour'**
  String get settingsDayCutoffHourDialog;

  /// Display value for selected hour
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String settingsDayCutoffHourValue(int hour);

  /// Hint text explaining day cutoff hour
  ///
  /// In en, this message translates to:
  /// **'Workouts completed after this hour will count as \'today\'. Useful for shift workers or late-night gym sessions.'**
  String get settingsDayCutoffHourHint;

  /// Success message after updating day cutoff hour
  ///
  /// In en, this message translates to:
  /// **'Day cutoff updated to {hour}:00'**
  String settingsDayCutoffHourUpdated(int hour);

  /// Short form for days ago (e.g., '5d ago')
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgoShort;

  /// Short form for weeks ago (e.g., '2w ago')
  ///
  /// In en, this message translates to:
  /// **'w ago'**
  String get weeksAgoShort;

  /// Short form for months ago (e.g., '2mo ago')
  ///
  /// In en, this message translates to:
  /// **'mo ago'**
  String get monthsAgoShort;

  /// Success message when previous workout data is auto-filled to all sets
  ///
  /// In en, this message translates to:
  /// **'Previous data copied to all sets'**
  String get previousDataCopied;

  /// Title for workout category selection bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Choose workout category:'**
  String get chooseWorkoutCategory;

  /// Full body workout category
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullBody;

  /// HIIT workout category
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get hiit;

  /// Custom workout name option
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get customWorkout;

  /// Default name for chest workout
  ///
  /// In en, this message translates to:
  /// **'Chest Workout'**
  String get chestWorkout;

  /// Default name for legs workout
  ///
  /// In en, this message translates to:
  /// **'Legs Workout'**
  String get legsWorkout;

  /// Default name for back workout
  ///
  /// In en, this message translates to:
  /// **'Back Workout'**
  String get backWorkout;

  /// Default name for arms workout
  ///
  /// In en, this message translates to:
  /// **'Arms Workout'**
  String get armsWorkout;

  /// Default name for cardio workout
  ///
  /// In en, this message translates to:
  /// **'Cardio Workout'**
  String get cardioWorkout;

  /// Default name for full body workout
  ///
  /// In en, this message translates to:
  /// **'Full Body Workout'**
  String get fullBodyWorkout;

  /// Default name for HIIT workout
  ///
  /// In en, this message translates to:
  /// **'HIIT Workout'**
  String get hiitWorkout;

  /// Semantic label for chest workout chip
  ///
  /// In en, this message translates to:
  /// **'Select chest workout'**
  String get selectChestWorkout;

  /// Semantic label for legs workout chip
  ///
  /// In en, this message translates to:
  /// **'Select legs workout'**
  String get selectLegsWorkout;

  /// Semantic label for back workout chip
  ///
  /// In en, this message translates to:
  /// **'Select back workout'**
  String get selectBackWorkout;

  /// Semantic label for arms workout chip
  ///
  /// In en, this message translates to:
  /// **'Select arms workout'**
  String get selectArmsWorkout;

  /// Semantic label for cardio workout chip
  ///
  /// In en, this message translates to:
  /// **'Select cardio workout'**
  String get selectCardioWorkout;

  /// Semantic label for full body workout chip
  ///
  /// In en, this message translates to:
  /// **'Select full body workout'**
  String get selectFullBodyWorkout;

  /// Semantic label for HIIT workout chip
  ///
  /// In en, this message translates to:
  /// **'Select HIIT workout'**
  String get selectHiitWorkout;

  /// Semantic label for custom workout chip
  ///
  /// In en, this message translates to:
  /// **'Enter custom name'**
  String get selectCustomWorkout;

  /// Error message when workout name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name'**
  String get workoutNameRequired;

  /// Error message when workout name is too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get workoutNameTooShort;

  /// Error message when workout name is too long
  ///
  /// In en, this message translates to:
  /// **'Name must be at most 50 characters'**
  String get workoutNameTooLong;

  /// Success message when workout is created
  ///
  /// In en, this message translates to:
  /// **'Workout {workoutName} created'**
  String workoutCreated(String workoutName);

  /// Title for modal to use previous workout weights
  ///
  /// In en, this message translates to:
  /// **'Use Previous Weights'**
  String get usePreviousWeights;

  /// Subtitle for modal to select weight increase percentage
  ///
  /// In en, this message translates to:
  /// **'Select how much to increase weights'**
  String get selectWeightIncrease;

  /// Option to use same weights as previous workout (0% increase)
  ///
  /// In en, this message translates to:
  /// **'Same weights'**
  String get sameWeights;

  /// Info text for using same weights option
  ///
  /// In en, this message translates to:
  /// **'Use the same weights from your last workout'**
  String get sameWeightsInfo;

  /// Info text for increasing weights by percentage
  ///
  /// In en, this message translates to:
  /// **'Increase all weights by {percentage}%'**
  String increaseWeightsInfo(String percentage);

  /// Time of day prefix for morning workouts (5:00-11:59)
  ///
  /// In en, this message translates to:
  /// **'🌅 Morning'**
  String get morningPrefix;

  /// Time of day prefix for afternoon workouts (12:00-17:59)
  ///
  /// In en, this message translates to:
  /// **'☀️ Afternoon'**
  String get afternoonPrefix;

  /// Time of day prefix for evening workouts (18:00-21:59)
  ///
  /// In en, this message translates to:
  /// **'🌆 Evening'**
  String get eveningPrefix;

  /// Time of day prefix for night workouts (22:00-4:59)
  ///
  /// In en, this message translates to:
  /// **'🌙 Night'**
  String get nightPrefix;

  /// Title for context gathering time selection step
  ///
  /// In en, this message translates to:
  /// **'How much time do you have today?'**
  String get contextTimeTitle;

  /// Subtitle for context gathering time selection step
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you choose the perfect workout'**
  String get contextTimeSubtitle;

  /// Help text for confused users on time selection
  ///
  /// In en, this message translates to:
  /// **'Choose how many minutes you can train today'**
  String get contextTimeHelp;

  /// Time display in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String timeMinutes(int minutes);

  /// Semantic label for time chip selection
  ///
  /// In en, this message translates to:
  /// **'Select {minutes} minutes'**
  String selectTimeMinutes(int minutes);

  /// Title for context gathering experience level step
  ///
  /// In en, this message translates to:
  /// **'What\'s your level?'**
  String get contextExperienceTitle;

  /// Subtitle for context gathering experience level step
  ///
  /// In en, this message translates to:
  /// **'To suggest the right weights and reps'**
  String get contextExperienceSubtitle;

  /// Beginner experience level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get experienceBeginner;

  /// Beginner experience level description
  ///
  /// In en, this message translates to:
  /// **'< 6 months training'**
  String get experienceBeginnerDesc;

  /// Intermediate experience level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get experienceIntermediate;

  /// Intermediate experience level description
  ///
  /// In en, this message translates to:
  /// **'6-24 months'**
  String get experienceIntermediateDesc;

  /// Advanced experience level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get experienceAdvanced;

  /// Advanced experience level description
  ///
  /// In en, this message translates to:
  /// **'2+ years'**
  String get experienceAdvancedDesc;

  /// Semantic label for experience level chip selection
  ///
  /// In en, this message translates to:
  /// **'Select {level}'**
  String selectExperienceLevel(String level);

  /// Title for demographics step (value-first messaging)
  ///
  /// In en, this message translates to:
  /// **'Personalize your workout'**
  String get contextDemographicsTitle;

  /// Subtitle for demographics step (explain value)
  ///
  /// In en, this message translates to:
  /// **'We\'ll suggest weights and exercises more suited to you'**
  String get contextDemographicsSubtitle;

  /// Reassurance text for demographics step
  ///
  /// In en, this message translates to:
  /// **'You can always change this in settings'**
  String get contextDemographicsReassurance;

  /// Skip button for optional demographics step
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get contextSkipForNow;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// Semantic label for gender chip selection
  ///
  /// In en, this message translates to:
  /// **'Select {gender}'**
  String selectGender(String gender);

  /// Title for turbo user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Quick confirmation'**
  String get quickConfirmation;

  /// Message for turbo user confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You selected:\n⏱️ {minutes} min\n💪 {level}\n\nConfirm?'**
  String quickConfirmationMessage(int minutes, String level);

  /// Button to change answers in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Change answers'**
  String get changeAnswers;

  /// Title for monthly progress analytics card
  ///
  /// In en, this message translates to:
  /// **'Monthly Progress'**
  String get monthlyProgress;

  /// Subtitle showing comparison period
  ///
  /// In en, this message translates to:
  /// **'This month vs last month'**
  String get thisMonthVsLast;

  /// Label for best improvement metric highlight
  ///
  /// In en, this message translates to:
  /// **'Best Improvement'**
  String get bestImprovement;

  /// Label for peak/maximum value
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peak;

  /// Title for PR celebration
  ///
  /// In en, this message translates to:
  /// **'New Personal Record'**
  String get newPersonalRecord;

  /// Celebration button text
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get awesome;

  /// Tab title for alternative exercises
  ///
  /// In en, this message translates to:
  /// **'Alternative Exercises'**
  String get alternativeExercises;

  /// Message when user has no active streak
  ///
  /// In en, this message translates to:
  /// **'Start your streak today!'**
  String get streakMessageNone;

  /// Message when current streak is a personal record
  ///
  /// In en, this message translates to:
  /// **'New personal record!'**
  String get streakMessagePersonalRecord;

  /// Message when user has active streak
  ///
  /// In en, this message translates to:
  /// **'Keep going strong!'**
  String get streakMessageActive;

  /// Message when streak is at risk (need to workout today)
  ///
  /// In en, this message translates to:
  /// **'Don\'t break the streak! Workout today'**
  String get streakMessageAtRisk;

  /// Message when streak was broken
  ///
  /// In en, this message translates to:
  /// **'Streak broken. Start fresh today!'**
  String get streakMessageBroken;

  /// Name for 7-day milestone
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get milestoneWeek;

  /// Name for 14-day milestone
  ///
  /// In en, this message translates to:
  /// **'Two-Week Champion'**
  String get milestoneTwoWeeks;

  /// Name for 30-day milestone
  ///
  /// In en, this message translates to:
  /// **'Monthly Master'**
  String get milestoneMonth;

  /// Name for 60-day milestone
  ///
  /// In en, this message translates to:
  /// **'Two-Month Hero'**
  String get milestoneTwoMonths;

  /// Name for 90-day milestone
  ///
  /// In en, this message translates to:
  /// **'Quarterly Beast'**
  String get milestoneQuarter;

  /// Name for 180-day milestone
  ///
  /// In en, this message translates to:
  /// **'Half-Year Legend'**
  String get milestoneSixMonths;

  /// Name for 365-day milestone
  ///
  /// In en, this message translates to:
  /// **'Yearly Titan'**
  String get milestoneYear;

  /// Custom milestone name
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String milestoneCustom(int days);

  /// Title for achievement unlock animation
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// Common rarity level
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// Uncommon rarity level
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get rarityUncommon;

  /// Rare rarity level
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// Epic rarity level
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  /// Legendary rarity level
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Dialog title for dismiss reason
  ///
  /// In en, this message translates to:
  /// **'Why wasn\'t this helpful?'**
  String get feedbackWhyNotHelpful;

  /// Dismiss reason: already know
  ///
  /// In en, this message translates to:
  /// **'I already know this'**
  String get dismissReasonAlreadyKnow;

  /// Dismiss reason: not relevant
  ///
  /// In en, this message translates to:
  /// **'Not relevant to my goals'**
  String get dismissReasonNotRelevant;

  /// Dismiss reason: incorrect
  ///
  /// In en, this message translates to:
  /// **'This seems incorrect'**
  String get dismissReasonIncorrect;

  /// Dismiss reason: too advanced
  ///
  /// In en, this message translates to:
  /// **'Too advanced for me'**
  String get dismissReasonTooAdvanced;

  /// Dismiss reason: too basic
  ///
  /// In en, this message translates to:
  /// **'Too basic for me'**
  String get dismissReasonTooBasic;

  /// Dismiss reason: not interested
  ///
  /// In en, this message translates to:
  /// **'Not interested in this topic'**
  String get dismissReasonNotInterested;

  /// Dismiss reason: other
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get dismissReasonOther;

  /// Comment field label in dismiss dialog
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get feedbackCommentOptional;

  /// Comment field hint text
  ///
  /// In en, this message translates to:
  /// **'Tell us more about why this wasn\'t helpful...'**
  String get feedbackCommentHint;

  /// Feature name: AI insights
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get featureInsightsName;

  /// Feature description: AI insights
  ///
  /// In en, this message translates to:
  /// **'Get personalized training insights'**
  String get featureInsightsDescription;

  /// Feature name: notifications
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get featureNotificationsName;

  /// Feature description: notifications
  ///
  /// In en, this message translates to:
  /// **'Receive timely workout reminders'**
  String get featureNotificationsDescription;

  /// Feature name: achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get featureAchievementsName;

  /// Feature description: achievements
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements as you progress'**
  String get featureAchievementsDescription;

  /// Feature name: streak tracking
  ///
  /// In en, this message translates to:
  /// **'Streak Tracking'**
  String get featureStreakTrackingName;

  /// Feature description: streak tracking
  ///
  /// In en, this message translates to:
  /// **'Track your consistency streaks'**
  String get featureStreakTrackingDescription;

  /// Feature name: advanced analytics
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get featureAdvancedAnalyticsName;

  /// Feature description: advanced analytics
  ///
  /// In en, this message translates to:
  /// **'Deep insights into your progress'**
  String get featureAdvancedAnalyticsDescription;

  /// Feature name: workout suggestions
  ///
  /// In en, this message translates to:
  /// **'Workout Suggestions'**
  String get featureWorkoutSuggestionsName;

  /// Feature description: workout suggestions
  ///
  /// In en, this message translates to:
  /// **'Personalized workout recommendations'**
  String get featureWorkoutSuggestionsDescription;

  /// Feature name: recovery insights
  ///
  /// In en, this message translates to:
  /// **'Recovery Insights'**
  String get featureRecoveryInsightsName;

  /// Feature description: recovery insights
  ///
  /// In en, this message translates to:
  /// **'Optimize your recovery and rest days'**
  String get featureRecoveryInsightsDescription;

  /// Feature name: form corrections
  ///
  /// In en, this message translates to:
  /// **'Form Corrections'**
  String get featureFormCorrectionsName;

  /// Feature description: form corrections
  ///
  /// In en, this message translates to:
  /// **'Get suggestions to improve exercise form'**
  String get featureFormCorrectionsDescription;

  /// Feature disabled globally
  ///
  /// In en, this message translates to:
  /// **'This feature is temporarily unavailable'**
  String get featureGateReasonGloballyDisabled;

  /// Feature disabled by user preference
  ///
  /// In en, this message translates to:
  /// **'You have disabled this feature'**
  String get featureGateReasonUserDisabled;

  /// Feature enabled without special requirements
  ///
  /// In en, this message translates to:
  /// **'Feature enabled by default'**
  String get featureGateReasonDefaultEnabled;

  /// All feature gate rules passed
  ///
  /// In en, this message translates to:
  /// **'You meet all requirements for this feature'**
  String get featureGateReasonAllRulesPassed;

  /// Not enough experience for feature
  ///
  /// In en, this message translates to:
  /// **'Requires higher experience level'**
  String get featureGateReasonInsufficientExperience;

  /// Not enough workouts for feature
  ///
  /// In en, this message translates to:
  /// **'Complete more workouts to unlock'**
  String get featureGateReasonInsufficientWorkouts;

  /// Account too new for feature
  ///
  /// In en, this message translates to:
  /// **'Available after using the app longer'**
  String get featureGateReasonAccountTooNew;

  /// Feature has low effectiveness rating
  ///
  /// In en, this message translates to:
  /// **'This feature needs improvement'**
  String get featureGateReasonLowEffectiveness;

  /// Unknown reason for feature being disabled
  ///
  /// In en, this message translates to:
  /// **'This feature is unavailable'**
  String get featureGateReasonUnknown;

  /// Title for notification settings screen
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Description for notification settings menu item
  ///
  /// In en, this message translates to:
  /// **'Manage workout reminders, streak alerts, and more'**
  String get notificationSettingsDesc;

  /// Section title for frequency cap settings
  ///
  /// In en, this message translates to:
  /// **'Frequency Caps'**
  String get frequencyCaps;

  /// Description for frequency caps feature
  ///
  /// In en, this message translates to:
  /// **'Limit notifications to prevent fatigue'**
  String get frequencyCapsDescription;

  /// Label for maximum notifications per day setting
  ///
  /// In en, this message translates to:
  /// **'Max Per Day'**
  String get maxPerDay;

  /// Label for maximum notifications per week setting
  ///
  /// In en, this message translates to:
  /// **'Max Per Week'**
  String get maxPerWeek;

  /// Research-backed explanation for weekly limit
  ///
  /// In en, this message translates to:
  /// **'Research shows >5/week increases quit risk by 64%'**
  String get maxPerWeekDescription;

  /// Label for minimum time between notifications
  ///
  /// In en, this message translates to:
  /// **'Minimum Interval (hours)'**
  String get minIntervalHours;

  /// Description for minimum interval hours setting
  ///
  /// In en, this message translates to:
  /// **'Minimum time between notifications (prevents spam)'**
  String get minIntervalHoursDescription;

  /// Label for notifications per day unit
  ///
  /// In en, this message translates to:
  /// **'notifications/day'**
  String get notificationsPerDay;

  /// Label for notifications per week unit
  ///
  /// In en, this message translates to:
  /// **'notifications/week'**
  String get notificationsPerWeek;

  /// Warning when frequency cap exceeds research-backed optimal limit
  ///
  /// In en, this message translates to:
  /// **'⚠️ >5/week increases quit risk by 64% (research-backed)'**
  String get exceedsResearchLimit;

  /// Section title for Do Not Disturb settings
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quietHours;

  /// Description for quiet hours feature
  ///
  /// In en, this message translates to:
  /// **'Set Do Not Disturb windows per category'**
  String get quietHoursDescription;

  /// Label for quiet hours start time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get quietHoursStart;

  /// Label for quiet hours end time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get quietHoursEnd;

  /// Toggle to allow high-priority notifications during quiet hours
  ///
  /// In en, this message translates to:
  /// **'Allow Priority Bypass'**
  String get allowPriorityBypass;

  /// Section title for privacy and GDPR settings
  ///
  /// In en, this message translates to:
  /// **'Privacy & GDPR'**
  String get privacyAndGDPR;

  /// Label showing current GDPR consent status
  ///
  /// In en, this message translates to:
  /// **'Consent Status'**
  String get consentStatus;

  /// Status when user has given consent
  ///
  /// In en, this message translates to:
  /// **'Consent Given'**
  String get consentGiven;

  /// Status when user has not given consent
  ///
  /// In en, this message translates to:
  /// **'Consent Not Given'**
  String get consentNotGiven;

  /// Button to open consent dialog
  ///
  /// In en, this message translates to:
  /// **'Give Consent'**
  String get giveConsent;

  /// Button to revoke previously given consent
  ///
  /// In en, this message translates to:
  /// **'Revoke Consent'**
  String get revokeConsent;

  /// Toggle for analytics data collection
  ///
  /// In en, this message translates to:
  /// **'Enable Analytics'**
  String get enableAnalytics;

  /// Description for analytics toggle
  ///
  /// In en, this message translates to:
  /// **'Help improve the app by sharing usage data'**
  String get analyticsDescription;

  /// Label for data retention period setting
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get dataRetention;

  /// Format for data retention period
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String dataRetentionDays(int days);

  /// Button to delete all notification data (GDPR Article 17)
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Warning shown before deleting all data
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all notification data. This action CANNOT be undone!'**
  String get deleteAllDataWarning;

  /// Confirmation prompt for data deletion
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteAllDataConfirm;

  /// Label showing when settings were last synced to cloud
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSyncedAt(String time);

  /// Button to manually trigger sync to cloud
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Confirmation dialog for resetting settings
  ///
  /// In en, this message translates to:
  /// **'Reset all notification settings to defaults?'**
  String get resetToDefaultsConfirm;

  /// Label for frequency cap preset options
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get frequencyCapPresets;

  /// Conservative frequency cap preset
  ///
  /// In en, this message translates to:
  /// **'Conservative (2/day, 3/week)'**
  String get presetConservative;

  /// Balanced frequency cap preset (default)
  ///
  /// In en, this message translates to:
  /// **'Balanced (3/day, 5/week)'**
  String get presetBalanced;

  /// Aggressive frequency cap preset
  ///
  /// In en, this message translates to:
  /// **'Aggressive (5/day, 10/week)'**
  String get presetAggressive;

  /// Minimal frequency cap preset
  ///
  /// In en, this message translates to:
  /// **'Minimal (1/day, 2/week)'**
  String get presetMinimal;

  /// Label for quiet hours preset options
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get quietHoursPresets;

  /// Overnight quiet hours preset
  ///
  /// In en, this message translates to:
  /// **'Overnight (10pm - 8am)'**
  String get presetOvernight;

  /// Work hours quiet hours preset
  ///
  /// In en, this message translates to:
  /// **'Work Hours (9am - 5pm)'**
  String get presetWorkHours;

  /// Weekend morning quiet hours preset
  ///
  /// In en, this message translates to:
  /// **'Weekend Morning (Sat-Sun 8am - 12pm)'**
  String get presetWeekendMorning;

  /// Siesta quiet hours preset
  ///
  /// In en, this message translates to:
  /// **'Siesta (2pm - 4pm)'**
  String get presetSiesta;

  /// Section for per-category notification settings
  ///
  /// In en, this message translates to:
  /// **'Category-Specific Settings'**
  String get categorySpecificSettings;

  /// Category label for recovery alert notifications
  ///
  /// In en, this message translates to:
  /// **'Recovery Alerts'**
  String get recoveryAlerts;

  /// Title for GDPR consent dialog
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Collection'**
  String get privacyConsentDialogTitle;

  /// Body text for GDPR consent dialog
  ///
  /// In en, this message translates to:
  /// **'We collect notification delivery times, types, and read status to improve the app. Your workout data stays on your device.\n\nYou can revoke consent anytime in Settings.'**
  String get privacyConsentDialogBody;

  /// Checkbox label for consent
  ///
  /// In en, this message translates to:
  /// **'I consent to data collection'**
  String get iConsentToDataCollection;

  /// Button to accept consent
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptConsent;

  /// Button to decline consent
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineConsent;

  /// Status message when syncing settings to cloud
  ///
  /// In en, this message translates to:
  /// **'Syncing settings...'**
  String get syncingSettings;

  /// Section title for notification type toggles
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// Description for daily workout reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Get reminded to complete your daily workouts'**
  String get dailyWorkoutRemindersDescription;

  /// Description for recovery alerts toggle
  ///
  /// In en, this message translates to:
  /// **'Notifications when you have days to recover'**
  String get recoveryAlertsDescription;

  /// Description for streak motivation toggle
  ///
  /// In en, this message translates to:
  /// **'Stay motivated with your active workout streak'**
  String get streakMotivationDescription;

  /// Section title for notification timing settings
  ///
  /// In en, this message translates to:
  /// **'Timing Preferences'**
  String get timingPreferences;

  /// Label for preferred notification time setting
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get preferredTime;

  /// Toggle for AI-powered notification scheduling
  ///
  /// In en, this message translates to:
  /// **'Smart Scheduling'**
  String get smartScheduling;

  /// Description for smart scheduling feature
  ///
  /// In en, this message translates to:
  /// **'AI learns your habits and schedules notifications optimally'**
  String get smartSchedulingDescription;

  /// Description for max per day setting
  ///
  /// In en, this message translates to:
  /// **'Maximum notifications per day'**
  String get maxPerDayDescription;

  /// Label for quiet hours time window setting
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours Window'**
  String get quietHoursWindow;

  /// Toggle to enable quiet hours feature
  ///
  /// In en, this message translates to:
  /// **'Enable Do Not Disturb'**
  String get enableDoNotDisturb;

  /// Description for Do Not Disturb feature
  ///
  /// In en, this message translates to:
  /// **'Silence notifications during specific hours'**
  String get doNotDisturbDescription;

  /// Button to view GDPR consent details
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewConsent;

  /// Label for data retention period setting
  ///
  /// In en, this message translates to:
  /// **'Data Retention Period'**
  String get dataRetentionPeriod;

  /// Label for last sync timestamp
  ///
  /// In en, this message translates to:
  /// **'Last Synced'**
  String get lastSynced;

  /// Status when settings have never been synced
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get neverSynced;

  /// Warning when local and cloud settings differ
  ///
  /// In en, this message translates to:
  /// **'Out of Sync'**
  String get outOfSync;

  /// Description of out-of-sync status
  ///
  /// In en, this message translates to:
  /// **'Local and cloud settings are different'**
  String get outOfSyncDescription;

  /// Description for reset to defaults button
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to factory defaults'**
  String get resetToDefaultsDescription;

  /// Description for delete all data button
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all notification data'**
  String get deleteAllDataDescription;

  /// Label for custom time preference option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Success message after deleting all notification data
  ///
  /// In en, this message translates to:
  /// **'All notification data deleted'**
  String get allDataDeleted;

  /// Title for privacy consent dialog
  ///
  /// In en, this message translates to:
  /// **'Privacy Consent'**
  String get privacyConsent;

  /// Description of privacy consent for notifications
  ///
  /// In en, this message translates to:
  /// **'By enabling notifications, you consent to receive personalized workout reminders, recovery alerts, and streak motivation. Your notification preferences and history are stored locally and synced to the cloud for cross-device access. You can revoke consent at any time by disabling notifications or deleting all data.'**
  String get consentDescription;

  /// Label for consent version number
  ///
  /// In en, this message translates to:
  /// **'Consent Version'**
  String get consentVersion;

  /// Label for quiet hours start time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// Label for quiet hours end time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Title for supplement reminder notifications
  ///
  /// In en, this message translates to:
  /// **'Supplement Reminders'**
  String get supplementReminders;

  /// Description for supplement reminder toggle
  ///
  /// In en, this message translates to:
  /// **'Get reminded to take your supplements (pre-workout, protein, etc.)'**
  String get supplementRemindersDescription;

  /// Title for notification history screen
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get notificationHistory;

  /// Placeholder for notification history search
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchHistory;

  /// Option to show all notification types
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// Filter option to show only unread notifications
  ///
  /// In en, this message translates to:
  /// **'Unread Only'**
  String get unreadOnly;

  /// Button to clear notification history
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Label showing current settings schema version
  ///
  /// In en, this message translates to:
  /// **'Settings Version'**
  String get settingsVersion;

  /// Warning when settings need migration to v2.0
  ///
  /// In en, this message translates to:
  /// **'Migration Required'**
  String get migrationRequired;

  /// Button to trigger v1.0 → v2.0 migration
  ///
  /// In en, this message translates to:
  /// **'Migrate Now'**
  String get migrateNow;

  /// Status text during migration
  ///
  /// In en, this message translates to:
  /// **'Migrating settings...'**
  String get migrationInProgress;

  /// Title after successful migration
  ///
  /// In en, this message translates to:
  /// **'Migration Complete'**
  String get migrationComplete;

  /// Label indicating default time will be used
  ///
  /// In en, this message translates to:
  /// **'Use default time'**
  String get useDefaultTime;

  /// Title of PR celebration modal
  ///
  /// In en, this message translates to:
  /// **'New Personal Record!'**
  String get pr_celebration_title;

  /// Label for previous PR value in celebration modal
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get pr_previous_value;

  /// Label for new PR value in celebration modal
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get pr_new_value;

  /// Continue button text in PR celebration modal
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_text;

  /// Motivational message when very close to PR (95%+)
  ///
  /// In en, this message translates to:
  /// **'So close to a PR!'**
  String get near_pr_so_close;

  /// Motivational message when close to PR (90-95%)
  ///
  /// In en, this message translates to:
  /// **'You\'re almost there!'**
  String get near_pr_almost_there;

  /// Motivational message when approaching PR (85-90%)
  ///
  /// In en, this message translates to:
  /// **'Keep pushing!'**
  String get near_pr_keep_pushing;

  /// Label for remaining weight/reps to reach PR
  ///
  /// In en, this message translates to:
  /// **'to go'**
  String get near_pr_to_go;

  /// Basic recovery tier name
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get recovery_tier_basic;

  /// Intermediate recovery tier name
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get recovery_tier_intermediate;

  /// Advanced recovery tier name
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get recovery_tier_advanced;

  /// Basic tier description
  ///
  /// In en, this message translates to:
  /// **'Overall readiness score based on workout frequency'**
  String get recovery_tier_basic_desc;

  /// Intermediate tier description
  ///
  /// In en, this message translates to:
  /// **'Per-muscle recovery status with volume tracking'**
  String get recovery_tier_intermediate_desc;

  /// Advanced tier description
  ///
  /// In en, this message translates to:
  /// **'Overtraining detection using HRV + TSB metrics'**
  String get recovery_tier_advanced_desc;

  /// Optimal readiness category (90-100)
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get readiness_optimal;

  /// Good readiness category (75-89)
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get readiness_good;

  /// Moderate readiness category (60-74)
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get readiness_moderate;

  /// Low readiness category (40-59)
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get readiness_low;

  /// Very low readiness category (0-39)
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get readiness_very_low;

  /// Locked readiness category (tier not unlocked)
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get readiness_locked;

  /// Chest muscle group
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscle_group_chest;

  /// Back muscle group
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscle_group_back;

  /// Shoulders muscle group
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscle_group_shoulders;

  /// Biceps muscle group
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscle_group_biceps;

  /// Triceps muscle group
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscle_group_triceps;

  /// Legs muscle group
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscle_group_legs;

  /// Core muscle group
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscle_group_core;

  /// Fully recovered status (72h+ rest)
  ///
  /// In en, this message translates to:
  /// **'Fully Recovered'**
  String get recovery_fully_recovered;

  /// Recovered status (48-72h rest)
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recovery_recovered;

  /// Partially recovered status (24-48h rest)
  ///
  /// In en, this message translates to:
  /// **'Partially Recovered'**
  String get recovery_partially_recovered;

  /// Fatigued status (<24h rest)
  ///
  /// In en, this message translates to:
  /// **'Fatigued'**
  String get recovery_fatigued;

  /// Low overtraining risk
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get risk_level_low;

  /// Moderate overtraining risk
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get risk_level_moderate;

  /// High overtraining risk
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get risk_level_high;

  /// Very high overtraining risk
  ///
  /// In en, this message translates to:
  /// **'Very High Risk'**
  String get risk_level_very_high;

  /// TSB > +5
  ///
  /// In en, this message translates to:
  /// **'Very Fresh'**
  String get training_load_very_fresh;

  /// TSB 0 to +5
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get training_load_optimal;

  /// TSB -5 to 0
  ///
  /// In en, this message translates to:
  /// **'Normal Load'**
  String get training_load_normal;

  /// TSB -10 to -5
  ///
  /// In en, this message translates to:
  /// **'Moderate Fatigue'**
  String get training_load_moderate_fatigue;

  /// TSB -15 to -10
  ///
  /// In en, this message translates to:
  /// **'High Fatigue'**
  String get training_load_high_fatigue;

  /// TSB < -15
  ///
  /// In en, this message translates to:
  /// **'Very High Fatigue'**
  String get training_load_very_high_fatigue;

  /// Label for workouts progress
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get tier_workouts_label;

  /// Label for days of data progress
  ///
  /// In en, this message translates to:
  /// **'Days of Data'**
  String get tier_days_label;

  /// Tier unlocked status
  ///
  /// In en, this message translates to:
  /// **'Unlocked!'**
  String get tier_unlocked;

  /// Message when tier is unlocked
  ///
  /// In en, this message translates to:
  /// **'This tier is now available'**
  String get tier_unlock_message;

  /// Generic unlock requirement message
  ///
  /// In en, this message translates to:
  /// **'Complete {workouts} workouts over {days} days to unlock'**
  String tier_unlock_requirement(int workouts, int days);

  /// Title for workout migration dialog
  ///
  /// In en, this message translates to:
  /// **'Migrate Workout History'**
  String get migrateWorkoutHistory;

  /// Warning message in migration dialog
  ///
  /// In en, this message translates to:
  /// **'This will migrate all your historical workout data to the new analytics system.'**
  String get migrationWarning;

  /// Description of migration process
  ///
  /// In en, this message translates to:
  /// **'This is a one-time operation that analyzes all past workouts and creates detailed exercise history. Your original workouts remain unchanged.'**
  String get migrationDescription;

  /// Migration button text
  ///
  /// In en, this message translates to:
  /// **'Migrate'**
  String get migrate;

  /// Title during migration
  ///
  /// In en, this message translates to:
  /// **'Migrating Workouts...'**
  String get migratingWorkouts;

  /// Migration stat label
  ///
  /// In en, this message translates to:
  /// **'Workouts Processed'**
  String get workoutsProcessed;

  /// Migration stat label
  ///
  /// In en, this message translates to:
  /// **'Unique Exercises'**
  String get uniqueExercises;

  /// Skipped exercises label
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// Title when migration fails
  ///
  /// In en, this message translates to:
  /// **'Migration Failed'**
  String get migrationFailed;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Suggestion message when no search results found
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different exercise or muscle group'**
  String get tryAnotherSearch;

  /// Plural form of month
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// Message when no data exists in selected timeframe
  ///
  /// In en, this message translates to:
  /// **'No data available for this timeframe'**
  String get noDataForTimeframe;

  /// Suggestion when no data in current timeframe
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different timeframe to see your progress'**
  String get tryDifferentTimeframe;

  /// Total volume record label
  ///
  /// In en, this message translates to:
  /// **'Volume Record'**
  String get volumeRecord;

  /// Max weight record description
  ///
  /// In en, this message translates to:
  /// **'Heaviest single set'**
  String get heaviestSingleSet;

  /// Estimated 1RM description
  ///
  /// In en, this message translates to:
  /// **'Calculated max strength'**
  String get calculatedMaxStrength;

  /// Volume record description
  ///
  /// In en, this message translates to:
  /// **'Highest single workout'**
  String get highestSingleWorkout;

  /// Total sets record label
  ///
  /// In en, this message translates to:
  /// **'Sets Record'**
  String get setsRecord;

  /// Sets record description
  ///
  /// In en, this message translates to:
  /// **'Most sets in one workout'**
  String get mostSetsInOneWorkout;

  /// Activity statistics section title
  ///
  /// In en, this message translates to:
  /// **'Activity Statistics'**
  String get activityStatistics;

  /// Weekly frequency time period
  ///
  /// In en, this message translates to:
  /// **'Average (last 4 weeks)'**
  String get averageLast4Weeks;

  /// Empty state when no personal records exist
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// Prompt to complete workouts for records
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to track records'**
  String get completeWorkoutsToTrackRecords;

  /// Empty state accessibility label
  ///
  /// In en, this message translates to:
  /// **'No workout history'**
  String get noWorkoutHistory;

  /// Empty state message for workout history
  ///
  /// In en, this message translates to:
  /// **'No workout history yet'**
  String get noWorkoutHistoryYet;

  /// Prompt to complete first workout
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to see history'**
  String get completeWorkoutToSeeHistory;

  /// Personal record abbreviation badge
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get pr;

  /// Records tab label
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
