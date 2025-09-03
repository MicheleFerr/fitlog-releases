/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: buddy_matching
 * 🔧 Type: screen
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: ConsumerStatefulWidget
 * - Firebase: Via repository
 * - Hive: None
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/buddy_preferences.dart';
import '../providers/buddy_matching_provider.dart';
import '../widgets/onboarding/welcome_step.dart';
import '../widgets/onboarding/fitness_level_step.dart';
import '../widgets/onboarding/goals_step.dart';
import '../widgets/onboarding/schedule_step.dart';
import '../widgets/onboarding/location_step.dart';
import '../widgets/onboarding/profile_step.dart';
import '../widgets/onboarding/complete_step.dart';

class BuddyOnboardingScreen extends ConsumerStatefulWidget {
  const BuddyOnboardingScreen({super.key});

  @override
  ConsumerState<BuddyOnboardingScreen> createState() => _BuddyOnboardingScreenState();
}

class _BuddyOnboardingScreenState extends ConsumerState<BuddyOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Onboarding data
  FitnessLevel _fitnessLevel = FitnessLevel.intermediate;
  List<WorkoutGoal> _goals = [];
  List<PreferredTime> _preferredTimes = [];
  List<String> _preferredDays = [];
  double _maxDistance = 25.0;
  String? _instagramHandle;
  String? _bio;
  bool _allowMessages = true;
  bool _showOnMap = true;
  double? _latitude;
  double? _longitude;
  String? _locationName;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<String> _stepTitles = [
    'Benvenuto!',
    'Il tuo livello',
    'I tuoi obiettivi', 
    'I tuoi orari',
    'La tua zona',
    'Il tuo profilo',
    'Tutto pronto!',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            _buildProgressHeader(context, theme, l10n),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeStep(onNext: _nextStep),
                  FitnessLevelStep(
                    selectedLevel: _fitnessLevel,
                    onLevelChanged: (level) => setState(() => _fitnessLevel = level),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  GoalsStep(
                    selectedGoals: _goals,
                    onGoalsChanged: (goals) => setState(() => _goals = goals),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  ScheduleStep(
                    selectedTimes: _preferredTimes,
                    selectedDays: _preferredDays,
                    onTimesChanged: (times) => setState(() => _preferredTimes = times),
                    onDaysChanged: (days) => setState(() => _preferredDays = days),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  LocationStep(
                    maxDistance: _maxDistance,
                    currentLocation: _locationName,
                    onDistanceChanged: (distance) => setState(() => _maxDistance = distance),
                    onLocationSet: (lat, lng, name) => setState(() {
                      _latitude = lat;
                      _longitude = lng;
                      _locationName = name;
                    }),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  ProfileStep(
                    instagramHandle: _instagramHandle,
                    bio: _bio,
                    allowMessages: _allowMessages,
                    showOnMap: _showOnMap,
                    onInstagramChanged: (handle) => setState(() => _instagramHandle = handle),
                    onBioChanged: (bio) => setState(() => _bio = bio),
                    onAllowMessagesChanged: (allow) => setState(() => _allowMessages = allow),
                    onShowOnMapChanged: (show) => setState(() => _showOnMap = show),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  CompleteStep(
                    preferences: _buildPreferences(),
                    onComplete: _completeOnboarding,
                    onBack: _previousStep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and skip
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                ),
              const Spacer(),
              if (_currentStep < _stepTitles.length - 1)
                TextButton(
                  onPressed: _skipOnboarding,
                  child: Text('Salta'),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_currentStep + 1} / ${_stepTitles.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Step title
          Text(
            _stepTitles[_currentStep],
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _stepTitles.length);
  }

  BuddyPreferences _buildPreferences() {
    return BuddyPreferences(
      isLookingForBuddy: true,
      maxDistance: _maxDistance,
      fitnessLevel: _fitnessLevel,
      goals: _goals,
      preferredTimes: _preferredTimes,
      preferredDays: _preferredDays,
      instagramHandle: _instagramHandle,
      bio: _bio,
      allowMessages: _allowMessages,
      showOnMap: _showOnMap,
      latitude: _latitude,
      longitude: _longitude,
      locationName: _locationName,
      lastLocationUpdate: _latitude != null ? DateTime.now() : null,
    );
  }

  void _completeOnboarding() async {
    try {
      final preferences = _buildPreferences();
      await ref.read(buddyPreferencesProvider.notifier).updatePreferences(preferences);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/buddy-matching');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio delle preferenze'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salta configurazione?'),
        content: Text('Puoi sempre modificare le tue preferenze successivamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeOnboarding();
            },
            child: Text('Salta'),
          ),
        ],
      ),
    );
  }
}