/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: debug
/// 🎯 Feature: workout
/// 🔧 Type: debug_widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseHistoryTestWidget extends ConsumerStatefulWidget {
  
  const ExerciseHistoryTestWidget({
    super.key,
    required this.exerciseName,
  });
  final String exerciseName;

  @override
  ConsumerState<ExerciseHistoryTestWidget> createState() => _ExerciseHistoryTestWidgetState();
}

class _ExerciseHistoryTestWidgetState extends ConsumerState<ExerciseHistoryTestWidget> {
  List<String>? _allExerciseNames;
  int? _workoutCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      final service = ExerciseHistoryService(boxManager: HiveBoxManagerEnhanced());
      final exerciseNames = await service.getAllExerciseNames(userId);
      final workoutCount = await service.getWorkoutCount(userId);

      if (mounted) {
        setState(() {
          _allExerciseNames = exerciseNames;
          _workoutCount = workoutCount;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading debug data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final historyAsync = ref.watch(exerciseHistoryProvider(widget.exerciseName));
    final userId = ref.watch(currentUserIdProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise History Debug: ${widget.exerciseName}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // User Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Information',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('User ID: ${userId ?? "Not authenticated"}'),
                  Text('Workout Count: ${_workoutCount ?? "Loading..."}'),
                  Text('Total Exercises: ${_allExerciseNames?.length ?? "Loading..."}'),
                  if (_isLoading) 
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Available Exercises
            if (_allExerciseNames != null) ...[
              ExpansionTile(
                title: Text('Available Exercises (${_allExerciseNames!.length})'),
                children: [
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: _allExerciseNames!.length,
                      itemBuilder: (context, index) {
                        final exerciseName = _allExerciseNames![index];
                        final isCurrentExercise = exerciseName.toLowerCase() == widget.exerciseName.toLowerCase();
                        
                        return ListTile(
                          dense: true,
                          title: Text(
                            exerciseName,
                            style: TextStyle(
                              fontWeight: isCurrentExercise ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentExercise ? theme.colorScheme.primary : null,
                            ),
                          ),
                          leading: Icon(
                            isCurrentExercise ? AppIcons.complete : AppIcons.workout,
                            color: isCurrentExercise ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Exercise History Results
            Text(
              'Exercise History Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          AppIcons.warning,
                          color: theme.colorScheme.onErrorContainer,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No history found for "${widget.exerciseName}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This means either:\n'
                          '• The exercise name doesn\'t match exactly\n'
                          '• No workouts contain this exercise\n'
                          '• No sets are marked as completed\n'
                          '• User ID mismatch',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppIcons.complete,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Found ${history.length} history items',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Show first few history items
                      ...history.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${item.weight}kg x ${item.reps} reps on ${item.date.toString().split(' ')[0]} (${item.workoutName})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )),
                      
                      if (history.length > 3)
                        Text(
                          '... and ${history.length - 3} more items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: 100,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.error,
                      color: theme.colorScheme.onErrorContainer,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading history',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Refresh button
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(exerciseHistoryProvider(widget.exerciseName));
                _loadDebugData();
              },
              icon: const Icon(AppIcons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }
}
