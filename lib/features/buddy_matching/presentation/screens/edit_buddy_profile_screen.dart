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
 * - Riverpod: ConsumerWidget
 * - Firebase: Via repository
 * - Location: GPS permission
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/buddy_preferences.dart';
import '../providers/buddy_matching_provider.dart';
import '../widgets/enhanced/city_picker_widget.dart';
import '../../data/services/location_service.dart';

class EditBuddyProfileScreen extends ConsumerStatefulWidget {
  const EditBuddyProfileScreen({super.key});

  @override
  ConsumerState<EditBuddyProfileScreen> createState() => _EditBuddyProfileScreenState();
}

class _EditBuddyProfileScreenState extends ConsumerState<EditBuddyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _instagramController = TextEditingController();
  
  // Form state
  bool _isLookingForBuddy = true;
  FitnessLevel _fitnessLevel = FitnessLevel.intermediate;
  List<WorkoutGoal> _goals = [];
  List<PreferredTime> _preferredTimes = [];
  List<String> _preferredDays = [];
  double _maxDistance = 25.0;
  int _minAge = 18;
  int _maxAge = 40;
  MatchingPurpose _matchingPurpose = MatchingPurpose.workoutPartner;
  bool _openToFriendship = true;
  bool _openToDating = false;
  String? _selectedCityCode;
  String? _selectedCityName;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPreferences() async {
    final preferencesAsync = ref.read(buddyPreferencesProvider);
    
    preferencesAsync.when(
      data: (preferences) {
        if (preferences != null) {
          setState(() {
            _isLookingForBuddy = preferences.isLookingForBuddy;
            _fitnessLevel = preferences.fitnessLevel;
            _goals = List.from(preferences.goals);
            _preferredTimes = List.from(preferences.preferredTimes);
            _preferredDays = List.from(preferences.preferredDays);
            _maxDistance = preferences.maxDistance;
            _minAge = preferences.minAge;
            _maxAge = preferences.maxAge;
            _matchingPurpose = preferences.matchingPurpose;
            _openToFriendship = preferences.openToFriendship;
            _openToDating = preferences.openToDating;
            _selectedCityCode = preferences.cityCode;
            _selectedCityName = preferences.cityName;
            _bioController.text = preferences.bio ?? '';
            _instagramController.text = preferences.instagramHandle ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
      loading: () {},
      error: (error, _) {
        setState(() {
          _isLoading = false;
        });
        _showError('Errore nel caricamento delle preferenze: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferences,
            child: _isSaving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.save,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Looking for buddy toggle
              _buildSectionCard(
                title: l10n.availability,
                child: SwitchListTile(
                  title: Text(l10n.lookingForWorkoutBuddy),
                  subtitle: Text(l10n.toggleToShowInMatching),
                  value: _isLookingForBuddy,
                  onChanged: (value) => setState(() => _isLookingForBuddy = value),
                ),
              ),

              const SizedBox(height: 16),

              // Fitness Level
              _buildSectionCard(
                title: l10n.fitnessLevel,
                child: Column(
                  children: FitnessLevel.values.map((level) {
                    return RadioListTile<FitnessLevel>(
                      title: Text(_getFitnessLevelName(level, l10n)),
                      value: level,
                      groupValue: _fitnessLevel,
                      onChanged: (value) => setState(() => _fitnessLevel = value!),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Workout Goals
              _buildSectionCard(
                title: l10n.workoutGoals,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WorkoutGoal.values.map((goal) {
                    final isSelected = _goals.contains(goal);
                    return FilterChip(
                      label: Text(_getGoalName(goal, l10n)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _goals.add(goal);
                          } else {
                            _goals.remove(goal);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Preferred Times
              _buildSectionCard(
                title: l10n.preferredTimes,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PreferredTime.values.map((time) {
                    final isSelected = _preferredTimes.contains(time);
                    return FilterChip(
                      label: Text(_getPreferredTimeName(time, l10n)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _preferredTimes.add(time);
                          } else {
                            _preferredTimes.remove(time);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Max Distance
              _buildSectionCard(
                title: '${l10n.maxDistance}: ${_maxDistance.round()} km',
                child: Slider(
                  value: _maxDistance,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  onChanged: (value) => setState(() => _maxDistance = value),
                ),
              ),

              const SizedBox(height: 16),

              // Age Range
              _buildSectionCard(
                title: '${l10n.ageRange}: $_minAge - $_maxAge ${l10n.years}',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${l10n.minAge}: $_minAge'),
                        ),
                        Expanded(
                          flex: 2,
                          child: Slider(
                            value: _minAge.toDouble(),
                            min: 18,
                            max: 60,
                            divisions: 42,
                            onChanged: (value) {
                              final newMinAge = value.round();
                              if (newMinAge < _maxAge) {
                                setState(() => _minAge = newMinAge);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${l10n.maxAge}: $_maxAge'),
                        ),
                        Expanded(
                          flex: 2,
                          child: Slider(
                            value: _maxAge.toDouble(),
                            min: 18,
                            max: 60,
                            divisions: 42,
                            onChanged: (value) {
                              final newMaxAge = value.round();
                              if (newMaxAge > _minAge) {
                                setState(() => _maxAge = newMaxAge);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Matching Purpose
              _buildSectionCard(
                title: l10n.matchingPurpose,
                child: Column(
                  children: [
                    RadioListTile<MatchingPurpose>(
                      title: Text(l10n.workoutPartnerOnly),
                      value: MatchingPurpose.workoutPartner,
                      groupValue: _matchingPurpose,
                      onChanged: (value) => setState(() => _matchingPurpose = value!),
                    ),
                    RadioListTile<MatchingPurpose>(
                      title: Text(l10n.gymBuddyOnly),
                      value: MatchingPurpose.gymBuddy,
                      groupValue: _matchingPurpose,
                      onChanged: (value) => setState(() => _matchingPurpose = value!),
                    ),
                    RadioListTile<MatchingPurpose>(
                      title: Text(l10n.bothWorkoutAndGym),
                      value: MatchingPurpose.both,
                      groupValue: _matchingPurpose,
                      onChanged: (value) => setState(() => _matchingPurpose = value!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Location
              _buildSectionCard(
                title: l10n.location,
                child: Column(
                  children: [
                    CityPickerWidget(
                      selectedCityCode: _selectedCityCode,
                      onCityChanged: (cityCode, cityName) {
                        setState(() {
                          _selectedCityCode = cityCode;
                          _selectedCityName = cityName;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _updateCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: Text(l10n.useCurrentLocation),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bio
              _buildSectionCard(
                title: l10n.bio,
                child: TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: l10n.tellUsAboutYourself,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instagram Handle
              _buildSectionCard(
                title: l10n.instagramHandle,
                child: TextFormField(
                  controller: _instagramController,
                  decoration: InputDecoration(
                    hintText: '@username',
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : Text(l10n.saveChanges),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;
    if (_goals.isEmpty) {
      _showError(l10n.pleaseSelectAtLeastOneGoal);
      return;
    }
    if (_preferredTimes.isEmpty) {
      _showError(l10n.pleaseSelectPreferredTimes);
      return;
    }
    if (_selectedCityCode == null) {
      _showError(l10n.pleaseSelectYourCity);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final preferences = BuddyPreferences(
        isLookingForBuddy: _isLookingForBuddy,
        maxDistance: _maxDistance,
        fitnessLevel: _fitnessLevel,
        goals: _goals,
        preferredTimes: _preferredTimes,
        preferredDays: _preferredDays,
        instagramHandle: _instagramController.text.trim().isEmpty 
            ? null 
            : _instagramController.text.trim(),
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        minAge: _minAge,
        maxAge: _maxAge,
        cityCode: _selectedCityCode!,
        cityName: _selectedCityName!,
        matchingPurpose: _matchingPurpose,
        openToFriendship: _openToFriendship,
        openToDating: _openToDating,
        // Keep existing location data
        latitude: 0.0, // Will be updated by GPS
        longitude: 0.0, // Will be updated by GPS
        locationName: _selectedCityName,
        zoneName: null,
        lastLocationUpdate: DateTime.now(),
      );

      await ref.read(buddyPreferencesProvider.notifier).updatePreferences(preferences);
      
      // Refresh matches after saving
      ref.read(matchingProvider.notifier).refreshMatches();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccessfully),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Errore nel salvataggio: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _updateCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final locationService = ref.read(locationServiceProvider);
      
      // Check permission first
      final permissionStatus = await locationService.checkLocationPermission();
      
      if (permissionStatus != LocationPermissionStatus.granted) {
        final requestedStatus = await locationService.requestLocationPermission();
        
        if (requestedStatus != LocationPermissionStatus.granted) {
          _showError(l10n.locationPermissionRequired);
          return;
        }
      }
      
      // Get current location
      final location = await locationService.getCurrentLocation();
      
      if (location != null) {
        setState(() {
          _selectedCityCode = location.cityCode;
          _selectedCityName = location.cityName;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.locationUpdated}: ${location.cityName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        _showError(l10n.unableToGetLocation);
      }
    } catch (e) {
      _showError('${l10n.locationUpdateError}: $e');
    }
  }

  String _getFitnessLevelName(FitnessLevel level, AppLocalizations l10n) {
    switch (level) {
      case FitnessLevel.beginner:
        return l10n.beginner;
      case FitnessLevel.intermediate:
        return l10n.intermediate;
      case FitnessLevel.advanced:
        return l10n.advanced;
      case FitnessLevel.expert:
        return l10n.expert;
    }
  }

  String _getGoalName(WorkoutGoal goal, AppLocalizations l10n) {
    switch (goal) {
      case WorkoutGoal.weightLoss:
        return l10n.weightLoss;
      case WorkoutGoal.muscleGain:
        return l10n.muscleGain;
      case WorkoutGoal.strength:
        return l10n.strength;
      case WorkoutGoal.endurance:
        return l10n.endurance;
      case WorkoutGoal.flexibility:
        return l10n.flexibility;
      case WorkoutGoal.general:
        return l10n.generalFitness;
    }
  }

  String _getPreferredTimeName(PreferredTime time, AppLocalizations l10n) {
    switch (time) {
      case PreferredTime.morning:
        return l10n.morning;
      case PreferredTime.midday:
        return l10n.midday;
      case PreferredTime.afternoon:
        return l10n.afternoon;
      case PreferredTime.evening:
        return l10n.evening;
    }
  }
}