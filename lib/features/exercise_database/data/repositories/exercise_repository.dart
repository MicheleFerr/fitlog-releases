// import 'package:cloud_firestore/cloud_firestore.dart';  // Temporarily disabled
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return MockExerciseRepository(); // Temporarily using mock implementation
});

abstract class ExerciseRepository {
  Stream<List<ExerciseTemplate>> getAllExercises();
  Stream<List<ExerciseTemplate>> getExercisesByCategory(
    ExerciseCategory category,
  );
  Stream<List<ExerciseTemplate>> searchExercises(String query);
  Future<ExerciseTemplate?> getExerciseById(String id);
  Future<List<ExerciseTemplate>> getExercisesByMuscleGroup(String muscleGroup);
}

// Temporarily disabled Firestore implementation
/*
class FirestoreExerciseRepository implements ExerciseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'exercises';

  @override
  Stream<List<ExerciseTemplate>> getAllExercises() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(_mapSnapshotToExercises);
  }

  @override
  Stream<List<ExerciseTemplate>> getExercisesByCategory(ExerciseCategory category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.name)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(_mapSnapshotToExercises);
  }

  @override
  Stream<List<ExerciseTemplate>> searchExercises(String query) {
    if (query.isEmpty) return getAllExercises();
    
    // Firestore doesn't support full-text search, so we'll implement a simple prefix search
    // For better search, consider using Algolia or ElasticSearch
    final queryLower = query.toLowerCase();
    
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          final exercises = _mapSnapshotToExercises(snapshot);
          return exercises.where((exercise) {
            return exercise.name.toLowerCase().contains(queryLower) ||
                   exercise.description.toLowerCase().contains(queryLower) ||
                   exercise.muscleGroups.any((muscle) => 
                     muscle.toLowerCase().contains(queryLower));
          }).toList();
        });
  }

  @override
  Future<ExerciseTemplate?> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ExerciseTemplate.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get exercise: $e');
    }
  }

  @override
  Future<List<ExerciseTemplate>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('muscleGroups', arrayContains: muscleGroup)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return _mapSnapshotToExercises(snapshot);
    } catch (e) {
      throw Exception('Failed to get exercises by muscle group: $e');
    }
  }

  List<ExerciseTemplate> _mapSnapshotToExercises(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      // Convert Firestore timestamps to DateTime
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      
      return ExerciseTemplate.fromJson(data);
    }).toList();
  }
}
*/

// Temporary mock implementation for iOS build compatibility
class MockExerciseRepository implements ExerciseRepository {
  final List<ExerciseTemplate> _mockExercises = [
    const ExerciseTemplate(
      id: '1',
      name: 'Push-up',
      description: 'Basic bodyweight chest exercise',
      category: ExerciseCategory.chest,
      type: ExerciseType.single,
      muscleGroups: ['chest', 'triceps', 'shoulders'],
      equipment: ['bodyweight'],
      instructions: [
        'Start in plank position',
        'Lower chest to ground',
        'Push back up',
      ],
      isActive: true,
    ),
  ];

  @override
  Stream<List<ExerciseTemplate>> getAllExercises() {
    return Stream.value(_mockExercises);
  }

  @override
  Stream<List<ExerciseTemplate>> getExercisesByCategory(
    ExerciseCategory category,
  ) {
    return Stream.value(
      _mockExercises.where((e) => e.category == category).toList(),
    );
  }

  @override
  Stream<List<ExerciseTemplate>> searchExercises(String query) {
    if (query.isEmpty) return getAllExercises();
    return Stream.value(
      _mockExercises
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  @override
  Future<ExerciseTemplate?> getExerciseById(String id) async {
    try {
      return _mockExercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExerciseTemplate>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    return _mockExercises
        .where(
          (e) => e.muscleGroups.any(
            (m) => m.toLowerCase().contains(muscleGroup.toLowerCase()),
          ),
        )
        .toList();
  }
}
