import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/tier1_exercise_card.dart';

/// Schermata di preview per i mockup delle card esercizio
class ExerciseCardMockupsScreen extends ConsumerWidget {
  const ExerciseCardMockupsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Mock exercise data
    final mockExercise1 = Exercise(
      id: '1',
      name: 'Panca Piana',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      restTime: 90, // 1m 30s
      notes: 'Fare attenzione alla forma, scendere lentamente',
      sets: [
        ExerciseSet(isCompleted: true, reps: 8, weight: 85),
        ExerciseSet(isCompleted: true, reps: 8, weight: 85),
        ExerciseSet(isCompleted: false, reps: 8, weight: 85),
        ExerciseSet(isCompleted: false, reps: 8, weight: 85),
      ],
    );
    
    final mockExercise2 = Exercise(
      id: '2',
      name: 'Squat con Bilanciere',
      type: ExerciseType.superset,
      category: ExerciseCategory.legs,
      restTime: 180, // 3m
      notes: 'Profondità completa, ATG',
      sets: [
        ExerciseSet(isCompleted: true, reps: 10, weight: 100),
        ExerciseSet(isCompleted: true, reps: 10, weight: 100),
        ExerciseSet(isCompleted: true, reps: 10, weight: 100),
      ],
    );
    
    final mockExercise3 = Exercise(
      id: '3',
      name: 'Bicep Curl con Manubri',
      type: ExerciseType.dropset,
      category: ExerciseCategory.arms,
      restTime: 60,
      notes: null, // No notes
      sets: [
        ExerciseSet(isCompleted: false, reps: 12, weight: 15),
        ExerciseSet(isCompleted: false, reps: 12, weight: 15),
        ExerciseSet(isCompleted: false, reps: 12, weight: 15),
      ],
    );
    
    final mockExercise4 = Exercise(
      id: '4',
      name: 'Lat Machine Presa Stretta Rest-Pause',
      type: ExerciseType.restPause,
      category: ExerciseCategory.back,
      restTime: 120,
      notes: 'Tecnica rest-pause: 8 rep, 15 sec pausa, max rep, 15 sec, max rep',
      sets: [
        ExerciseSet(isCompleted: true, reps: 15, weight: 70),
        ExerciseSet(isCompleted: false, reps: 15, weight: 70),
      ],
    );
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Exercise Card Mockups'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark 
                ? Icons.light_mode 
                : Icons.dark_mode,
            ),
            onPressed: () {
              // Toggle theme (you'd need to implement this in your app)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toggle theme to see dark/light variations'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version 1 - Ultra Compact
            _buildSectionHeader(context, 'Versione 1 - Ultra Compatta', 
              'Design minimalista a due linee con tutte le info essenziali'),
            const SizedBox(height: 8),
            Tier1ExerciseCardV1(
              exercise: mockExercise1,
              index: 0,
              onTap: () => _showTapFeedback(context, 'V1 - Panca Piana'),
            ),
            Tier1ExerciseCardV1(
              exercise: mockExercise2,
              index: 1,
              onTap: () => _showTapFeedback(context, 'V1 - Squat'),
            ),
            Tier1ExerciseCardV1(
              exercise: mockExercise3,
              index: 2,
              onTap: () => _showTapFeedback(context, 'V1 - Bicep Curl'),
            ),
            Tier1ExerciseCardV1(
              exercise: mockExercise4,
              index: 3,
              onTap: () => _showTapFeedback(context, 'V1 - Lat Machine'),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Version 2 - Material You
            _buildSectionHeader(context, 'Versione 2 - Material You', 
              'Design con chip colorati e indicatore circolare di progresso'),
            const SizedBox(height: 8),
            Tier1ExerciseCardV2(
              exercise: mockExercise1,
              index: 0,
              onTap: () => _showTapFeedback(context, 'V2 - Panca Piana'),
            ),
            Tier1ExerciseCardV2(
              exercise: mockExercise2,
              index: 1,
              onTap: () => _showTapFeedback(context, 'V2 - Squat'),
            ),
            Tier1ExerciseCardV2(
              exercise: mockExercise3,
              index: 2,
              onTap: () => _showTapFeedback(context, 'V2 - Bicep Curl'),
            ),
            Tier1ExerciseCardV2(
              exercise: mockExercise4,
              index: 3,
              onTap: () => _showTapFeedback(context, 'V2 - Lat Machine'),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Version 3 - iOS Minimal
            _buildSectionHeader(context, 'Versione 3 - iOS Minimal', 
              'Design pulito stile iOS con ombre sottili'),
            const SizedBox(height: 8),
            Tier1ExerciseCardV3(
              exercise: mockExercise1,
              index: 0,
              onTap: () => _showTapFeedback(context, 'V3 - Panca Piana'),
            ),
            Tier1ExerciseCardV3(
              exercise: mockExercise2,
              index: 1,
              onTap: () => _showTapFeedback(context, 'V3 - Squat'),
            ),
            Tier1ExerciseCardV3(
              exercise: mockExercise3,
              index: 2,
              onTap: () => _showTapFeedback(context, 'V3 - Bicep Curl'),
            ),
            Tier1ExerciseCardV3(
              exercise: mockExercise4,
              index: 3,
              onTap: () => _showTapFeedback(context, 'V3 - Lat Machine'),
            ),
            
            const SizedBox(height: 40),
            
            // Feature comparison
            _buildComparisonSection(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComparisonSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confronto Caratteristiche',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFeatureRow(context, 'Compattezza', 
            ['★★★★★', '★★★☆☆', '★★★★☆']),
          _buildFeatureRow(context, 'Info Visibili', 
            ['★★★★☆', '★★★★★', '★★★★☆']),
          _buildFeatureRow(context, 'Modernità', 
            ['★★★★☆', '★★★★★', '★★★☆☆']),
          _buildFeatureRow(context, 'iOS Feel', 
            ['★★☆☆☆', '★★★☆☆', '★★★★★']),
          _buildFeatureRow(context, 'Dark Mode', 
            ['★★★★☆', '★★★★★', '★★★★★']),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 Raccomandazione',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La Versione 1 (Ultra Compatta) offre il miglior compromesso tra compattezza e visibilità delle informazioni. Perfetta per liste lunghe di esercizi mantenendo tutte le info essenziali visibili.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(BuildContext context, String feature, List<String> ratings) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              feature,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ...ratings.map((rating) => Expanded(
            child: Text(
              rating,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ],
      ),
    );
  }
  
  void _showTapFeedback(BuildContext context, String cardName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: $cardName'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}