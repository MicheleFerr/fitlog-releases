/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/presentation/providers/buddy_matching_provider.dart';

class BuddyFilterSheet extends ConsumerStatefulWidget {
  const BuddyFilterSheet({super.key});

  @override
  ConsumerState<BuddyFilterSheet> createState() => _BuddyFilterSheetState();
}

class _BuddyFilterSheetState extends ConsumerState<BuddyFilterSheet> {
  double _maxDistance = 25.0;
  FitnessLevel? _selectedFitnessLevel;
  List<WorkoutGoal> _selectedGoals = [];
  RangeValues _ageRange = const RangeValues(18, 65);
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    // Load filters from search provider or preferences
    // This would typically come from saved search filters
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.matchFilters,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(l10n.clearFilters),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance
                      _buildSectionTitle(theme, l10n.distance),
                      _buildDistanceSlider(theme, l10n),
                      const SizedBox(height: 24),

                      // Fitness Level
                      _buildSectionTitle(theme, l10n.fitnessLevel),
                      _buildFitnessLevelSelector(theme),
                      const SizedBox(height: 24),

                      // Workout Goals
                      _buildSectionTitle(theme, l10n.workoutGoals),
                      _buildWorkoutGoalsSelector(theme),
                      const SizedBox(height: 24),

                      // Age Range
                      _buildSectionTitle(theme, l10n.ageRange),
                      _buildAgeRangeSlider(theme),
                      const SizedBox(height: 24),

                      // Verified Only
                      _buildVerifiedOnlyToggle(theme, l10n),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.applyFilters),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDistanceSlider(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Slider(
          value: _maxDistance,
          min: 1.0,
          max: 100.0,
          divisions: 99,
          label: '${_maxDistance.round()} ${l10n.km}',
          onChanged: (value) => setState(() => _maxDistance = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 ${l10n.km}', style: theme.textTheme.bodySmall),
            Text('${_maxDistance.round()} ${l10n.km}', 
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('100 ${l10n.km}', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildFitnessLevelSelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FitnessLevel.values.map((level) {
        final isSelected = _selectedFitnessLevel == level;
        return FilterChip(
          label: Text(level.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFitnessLevel = selected ? level : null;
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutGoalsSelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WorkoutGoal.values.map((goal) {
        final isSelected = _selectedGoals.contains(goal);
        return FilterChip(
          label: Text(goal.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedGoals.add(goal);
              } else {
                _selectedGoals.remove(goal);
              }
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildAgeRangeSlider(ThemeData theme) {
    return Column(
      children: [
        RangeSlider(
          values: _ageRange,
          min: 18.0,
          max: 80.0,
          divisions: 62,
          labels: RangeLabels(
            '${_ageRange.start.round()}',
            '${_ageRange.end.round()}',
          ),
          onChanged: (values) => setState(() => _ageRange = values),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('18', style: theme.textTheme.bodySmall),
            Text('${_ageRange.start.round()} - ${_ageRange.end.round()}', 
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('80', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifiedOnlyToggle(ThemeData theme, AppLocalizations l10n) {
    return SwitchListTile(
      title: Text(l10n.verifiedOnly),
      subtitle: const Text('Mostra solo utenti con profilo verificato'),
      value: _verifiedOnly,
      onChanged: (value) => setState(() => _verifiedOnly = value),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _clearFilters() {
    setState(() {
      _maxDistance = 25.0;
      _selectedFitnessLevel = null;
      _selectedGoals = [];
      _ageRange = const RangeValues(18, 65);
      _verifiedOnly = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'maxDistance': _maxDistance,
      if (_selectedFitnessLevel != null) 'fitnessLevel': _selectedFitnessLevel,
      if (_selectedGoals.isNotEmpty) 'goals': _selectedGoals,
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
      'isVerified': _verifiedOnly,
    };

    // Apply filters through search provider
    ref.read(searchProvider.notifier).searchProfiles(filters: filters);

    Navigator.of(context).pop();
  }
}