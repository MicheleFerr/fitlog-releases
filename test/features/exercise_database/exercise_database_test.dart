import 'package:flutter_test/flutter_test.dart';

// Mock exercise database data
class ExerciseDatabase {
  static final List<Map<String, dynamic>> exercises = [
    {
      'id': 'bench-press',
      'name': 'Bench Press',
      'muscleGroups': ['chest', 'triceps', 'shoulders'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    {
      'id': 'squat',
      'name': 'Squat',
      'muscleGroups': ['quadriceps', 'glutes', 'hamstrings'],
      'category': 'compound',
      'equipment': 'barbell',
    },
    {
      'id': 'bicep-curl',
      'name': 'Bicep Curl',
      'muscleGroups': ['biceps'],
      'category': 'isolation',
      'equipment': 'dumbbell',
    },
  ];
  
  static List<Map<String, dynamic>> searchExercises(String query) {
    final lowerQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise['name'].toString().toLowerCase().contains(lowerQuery) ||
             (exercise['muscleGroups'] as List).any((muscle) => 
                muscle.toString().toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  static List<Map<String, dynamic>> filterByMuscleGroup(String muscleGroup) {
    return exercises.where((exercise) {
      return (exercise['muscleGroups'] as List).contains(muscleGroup.toLowerCase());
    }).toList();
  }
  
  static List<Map<String, dynamic>> filterByEquipment(String equipment) {
    return exercises.where((exercise) {
      return exercise['equipment'] == equipment.toLowerCase();
    }).toList();
  }
  
  static Map<String, dynamic>? getExerciseById(String id) {
    try {
      return exercises.firstWhere((exercise) => exercise['id'] == id);
    } catch (e) {
      return null;
    }
  }
}

void main() {
  group('💪 Exercise Database Tests', () {
    
    test('✅ TEST 1: Load exercise database', () {
      final exercises = ExerciseDatabase.exercises;
      
      expect(exercises, isNotEmpty);
      expect(exercises.length, greaterThanOrEqualTo(3));
      
      // Check first exercise structure
      final firstExercise = exercises.first;
      expect(firstExercise['id'], isNotNull);
      expect(firstExercise['name'], isNotNull);
      expect(firstExercise['muscleGroups'], isA<List>());
    });
    
    test('✅ TEST 2: Search exercises by name', () {
      final results = ExerciseDatabase.searchExercises('bench');
      
      expect(results, isNotEmpty);
      expect(results.first['name'], 'Bench Press');
      
      // Case insensitive search
      final resultsUpper = ExerciseDatabase.searchExercises('BENCH');
      expect(resultsUpper, isNotEmpty);
    });
    
    test('✅ TEST 3: Search exercises by muscle group', () {
      final chestExercises = ExerciseDatabase.searchExercises('chest');
      
      expect(chestExercises, isNotEmpty);
      expect(chestExercises.any((ex) => ex['id'] == 'bench-press'), true);
    });
    
    test('✅ TEST 4: Filter by specific muscle group', () {
      final bicepExercises = ExerciseDatabase.filterByMuscleGroup('biceps');
      
      expect(bicepExercises, isNotEmpty);
      expect(bicepExercises.every((ex) => 
        (ex['muscleGroups'] as List).contains('biceps')), true);
    });
    
    test('✅ TEST 5: Filter by equipment type', () {
      final barbellExercises = ExerciseDatabase.filterByEquipment('barbell');
      
      expect(barbellExercises.length, 2); // Bench press and squat
      expect(barbellExercises.every((ex) => ex['equipment'] == 'barbell'), true);
      
      final dumbbellExercises = ExerciseDatabase.filterByEquipment('dumbbell');
      expect(dumbbellExercises.length, 1); // Bicep curl
    });
    
    test('✅ TEST 6: Get exercise by ID', () {
      final exercise = ExerciseDatabase.getExerciseById('bench-press');
      
      expect(exercise, isNotNull);
      expect(exercise!['name'], 'Bench Press');
      expect(exercise['category'], 'compound');
    });
    
    test('✅ TEST 7: Handle non-existent exercise ID', () {
      final exercise = ExerciseDatabase.getExerciseById('non-existent');
      
      expect(exercise, isNull);
    });
    
    test('✅ TEST 8: Search with no results', () {
      final results = ExerciseDatabase.searchExercises('xyz123');
      
      expect(results, isEmpty);
    });
    
    test('✅ TEST 9: Multiple muscle groups per exercise', () {
      final benchPress = ExerciseDatabase.getExerciseById('bench-press');
      
      expect(benchPress, isNotNull);
      final muscleGroups = benchPress!['muscleGroups'] as List;
      
      expect(muscleGroups.length, 3);
      expect(muscleGroups.contains('chest'), true);
      expect(muscleGroups.contains('triceps'), true);
      expect(muscleGroups.contains('shoulders'), true);
    });
    
    test('✅ TEST 10: Exercise categories', () {
      final exercises = ExerciseDatabase.exercises;
      
      final compoundExercises = exercises.where((ex) => 
        ex['category'] == 'compound').toList();
      final isolationExercises = exercises.where((ex) => 
        ex['category'] == 'isolation').toList();
      
      expect(compoundExercises.length, 2); // Bench press and squat
      expect(isolationExercises.length, 1); // Bicep curl
      
      // Compound exercises should target multiple muscle groups
      expect(compoundExercises.every((ex) => 
        (ex['muscleGroups'] as List).length > 1), true);
    });
  });
}