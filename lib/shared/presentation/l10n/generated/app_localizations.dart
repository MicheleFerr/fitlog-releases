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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'GymBro TrackLog'**
  String get appTitle;

  /// Welcome message on the main screen
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get welcome;

  /// Welcome description explaining the app functionality
  ///
  /// In en, this message translates to:
  /// **'Start a new workout and track your exercises with sets, supersets, dropsets, and rest-pause techniques.'**
  String get welcomeDescription;

  /// Quick start section title
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

  /// Start workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// Add exercise button text
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// Complete workout button text
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

  /// Workout name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Push Day, Leg Day'**
  String get workoutNameHint;

  /// Exercise name input label
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// Exercise name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Bench Press'**
  String get exerciseNameHint;

  /// Exercise category selection label
  ///
  /// In en, this message translates to:
  /// **'Exercise Category'**
  String get exerciseCategory;

  /// Sets label
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// Add set button text
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// Weight input label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// Abbreviation for repetitions
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get reps;

  /// Notes input label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// Notes input hint
  ///
  /// In en, this message translates to:
  /// **'Add any notes about form, weight progression, etc.'**
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

  /// Exercises label
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
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

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// Search exercises input label
  ///
  /// In en, this message translates to:
  /// **'Search Exercises'**
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

  /// End workout dialog title
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

  /// Advanced section header
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

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

  /// Reset to defaults option
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

  /// Choose language dialog title
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

  /// Edit exercise dialog title
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

  /// Your custom templates section title
  ///
  /// In en, this message translates to:
  /// **'Your Templates'**
  String get yourTemplates;

  /// Popular templates section title
  ///
  /// In en, this message translates to:
  /// **'Popular Templates'**
  String get popularTemplates;

  /// See all button text
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Welcome title on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to GymBro!'**
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

  /// Continue workout button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Resume workout button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// End workout button
  ///
  /// In en, this message translates to:
  /// **'End'**
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

  /// Total volume statistic
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// Consistency statistic
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// Total workouts statistic
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

  /// Personal records statistic
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

  /// Export data menu option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// View details menu option
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
  /// **'Complete some workouts to see your analytics and progress!'**
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

  /// Rate of Perceived Exertion abbreviation
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

  /// Target repetitions planned
  ///
  /// In en, this message translates to:
  /// **'Target Reps'**
  String get targetReps;

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

  /// Instruction to tap to start workout
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// Error message when templates fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading templates'**
  String get errorLoadingTemplates;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Button to mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Empty state for notifications
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Description for empty notifications state
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep you updated on your progress!'**
  String get notificationsDescription;

  /// Quick stats section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get quickStats;

  /// Workout streak label
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

  /// Secondary muscles section title
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get secondaryMuscles;

  /// Difficulty level section title
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// Exercise type section title
  ///
  /// In en, this message translates to:
  /// **'Exercise Type'**
  String get exerciseType;

  /// Equipment section title
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// Movement pattern section title
  ///
  /// In en, this message translates to:
  /// **'Movement Pattern'**
  String get movementPattern;

  /// Rep range section title
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

  /// Technical notes section title
  ///
  /// In en, this message translates to:
  /// **'Technical Notes'**
  String get technicalNotes;

  /// Target muscles group title
  ///
  /// In en, this message translates to:
  /// **'Target Muscles'**
  String get targetMuscles;

  /// Exercise details group title
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
