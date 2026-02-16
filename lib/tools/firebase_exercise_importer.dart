import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart' as WorkoutExercise;
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:flutter/foundation.dart';

class FirebaseExerciseImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'exercises';

  /// Import exercises for a specific language (defaults to English)
  Future<void> importExercisesFromJson({String languageCode = 'en'}) async {
    try {
      if (kDebugMode) {
        debugPrint('🔥 IMPORTER: Starting exercise import from JSON ($languageCode)...');
      }

      // 1. Load JSON from new folder structure
      final jsonList = await ExerciseJsonLoader.loadExercises(languageCode);
      
      if (kDebugMode) {
        debugPrint('📋 IMPORTER: Found ${jsonList.length} exercises in JSON');
      }
      
      // 2. Check if exercises already exist
      final existingDocs = await _firestore.collection(_collection).get();
      
      if (existingDocs.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️  IMPORTER: Found ${existingDocs.docs.length} existing exercises. Clearing collection...');
        }
        
        // Delete existing exercises
        final batch = _firestore.batch();
        for (var doc in existingDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (kDebugMode) {
          debugPrint('🗑️  IMPORTER: Cleared existing exercises');
        }
      }
      
      // 3. Import exercises in smaller batches to avoid size limits
      const batchSize = 100; // Reduced batch size
      int imported = 0;
      
      for (int i = 0; i < jsonList.length; i += batchSize) {
        try {
          final batch = _firestore.batch();
          final end = (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;
          
          for (int j = i; j < end; j++) {
            final exerciseJson = jsonList[j];

            // Convert JSON structure to Firebase format
            final firebaseData = _convertJsonToFirebaseFormat(exerciseJson);
            
            // Use the exercise id as document id
            final docRef = _firestore.collection(_collection).doc(exerciseJson['id']);
            batch.set(docRef, firebaseData);
          }
          
          if (kDebugMode) {
            debugPrint('📤 IMPORTER: Committing batch ${(i ~/ batchSize) + 1}...');
          }
          await batch.commit();
          imported += (end - i);
          if (kDebugMode) {
            debugPrint('✅ IMPORTER: Imported batch ${(i ~/ batchSize) + 1} - Total: $imported/${jsonList.length}');
          }
          
          // Small delay between batches to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));
          
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ BATCH ERROR ${(i ~/ batchSize) + 1}: $e');
          }
          
          // Try individual imports for this batch
          if (kDebugMode) {
            debugPrint('🔄 IMPORTER: Trying individual imports for batch ${(i ~/ batchSize) + 1}...');
          }
          final end = (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;
          
          for (int j = i; j < end; j++) {
            try {
              final exerciseJson = jsonList[j];
              final firebaseData = _convertJsonToFirebaseFormat(exerciseJson);
              final docRef = _firestore.collection(_collection).doc(exerciseJson['id']);
              
              await docRef.set(firebaseData);
              imported++;
              
              if (j % 10 == 0) {
                if (kDebugMode) {
                  debugPrint('📤 Individual import: $imported/${jsonList.length}');
                }
              }
              
              // Small delay between individual writes
              await Future.delayed(const Duration(milliseconds: 50));
              
            } catch (individualError) {
              final exerciseJson = jsonList[j];
              if (kDebugMode) {
                debugPrint('❌ Failed to import exercise ${exerciseJson['id']}: $individualError');
              }
            }
          }
        }
      }
      
      if (kDebugMode) {
        debugPrint('✅ IMPORTER: Successfully imported $imported exercises to Firebase!');
      }
      
      // 4. Verify import
      await _verifyImport(jsonList.length);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ IMPORTER ERROR: $e');
      }
      rethrow;
    }
  }
  
  Map<String, dynamic> _convertJsonToFirebaseFormat(Map<String, dynamic> jsonData) {
    // Convert from JSON structure to Firebase/ExerciseTemplate structure
    return {
      'name': jsonData['nome'] ?? '',
      'description': jsonData['noteTecniche'] ?? '',
      'category': _mapFocusToCategory(jsonData['focus'] ?? ''),
      'type': 'single', // Default type
      'muscleGroups': _parseMuscleGroups(jsonData['focus'] ?? ''),
      'secondaryMuscles': _parseMuscleGroups(jsonData['muscoliSecondari'] ?? ''),
      'equipment': [jsonData['attrezzatura'] ?? 'Vario'],
      'instructions': _parseInstructions(jsonData),
      'imageUrl': jsonData['imageUrl'] ?? '',
      'difficulty': jsonData['difficolta'] ?? 'Intermedio',
      'exerciseType': jsonData['tipoEsercizio'] ?? 'Isolamento',
      'movementPattern': jsonData['patternMovimento'] ?? '',
      'repRange': jsonData['rangeRipetizioni'] ?? '8-12',
      'preMobility': jsonData['mobilitaPre'] ?? '',
      'preActivation': jsonData['attivazionePre'] ?? '',
      'countingMode': jsonData['countingMode'] ?? 'weighted', // weighted, reps, or time
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  String _mapFocusToCategory(String focus) {
    // Split focus string by comma to create a list
    final focusList = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final category = ExerciseConverter.mapFocusToCategory(focusList);

    // Convert enum to lowercase string for Firebase
    switch (category) {
      case WorkoutExercise.ExerciseCategory.chest:
        return 'chest';
      case WorkoutExercise.ExerciseCategory.back:
        return 'back';
      case WorkoutExercise.ExerciseCategory.shoulders:
        return 'shoulders';
      case WorkoutExercise.ExerciseCategory.arms:
        return 'arms';
      case WorkoutExercise.ExerciseCategory.legs:
        return 'legs';
      case WorkoutExercise.ExerciseCategory.abs:
        return 'core';
      case WorkoutExercise.ExerciseCategory.cardio:
        return 'cardio';
      case WorkoutExercise.ExerciseCategory.other:
        return 'other';
    }
  }
  
  List<String> _parseMuscleGroups(String muscleString) {
    if (muscleString.isEmpty) return [];
    
    final muscles = muscleString.split(',').map((m) => m.trim()).toList();
    final result = <String>[];
    
    for (final muscle in muscles) {
      final muscleLower = muscle.toLowerCase();
      if (muscleLower.contains('quad')) result.add('quadriceps');
      if (muscleLower.contains('glut')) result.add('glutes');
      if (muscleLower.contains('femor') || muscleLower.contains('hamstring')) result.add('hamstrings');
      if (muscleLower.contains('pett') || muscleLower.contains('chest')) result.add('chest');
      if (muscleLower.contains('dors') || muscleLower.contains('lat')) result.add('lats');
      if (muscleLower.contains('delt') || muscleLower.contains('spall')) result.add('shoulders');
      if (muscleLower.contains('brac') || muscleLower.contains('bicep')) result.add('biceps');
      if (muscleLower.contains('tric')) result.add('triceps');
      if (muscleLower.contains('core') || muscleLower.contains('add')) result.add('core');
      if (muscleLower.contains('polp') || muscleLower.contains('calf')) result.add('calves');
    }
    
    return result.isEmpty ? [muscleString] : result;
  }
  
  List<String> _parseInstructions(Map<String, dynamic> jsonData) {
    final instructions = <String>[];

    if (jsonData['noteTecniche'] != null && jsonData['noteTecniche'].toString().isNotEmpty) {
      instructions.add('Tecnica: ${jsonData['noteTecniche']}');
    }

    if (jsonData['mobilitaPre'] != null && jsonData['mobilitaPre'].toString().isNotEmpty) {
      instructions.add('Mobilità pre: ${jsonData['mobilitaPre']}');
    }

    if (jsonData['attivazionePre'] != null && jsonData['attivazionePre'].toString().isNotEmpty) {
      instructions.add('Attivazione pre: ${jsonData['attivazionePre']}');
    }

    return instructions.isEmpty ? ['Esegui l\'esercizio seguendo la tecnica corretta'] : instructions;
  }
  
  Future<void> _verifyImport(int expectedCount) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final actualCount = snapshot.docs.length;
      
      if (kDebugMode) {
        debugPrint('🔍 IMPORTER: Verification - Expected: $expectedCount, Found: $actualCount');
      }
      
      if (actualCount == expectedCount) {
        if (kDebugMode) {
          debugPrint('✅ IMPORT VERIFICATION: Success! All exercises imported correctly');
        }
        
        // Sample a few exercises to verify structure
        final sampleExercises = snapshot.docs.take(3);
        for (final doc in sampleExercises) {
          final data = doc.data();
          if (kDebugMode) {
            debugPrint('📋 Sample Exercise: ${data['name']} (${doc.id})');
          }
          if (kDebugMode) {
            debugPrint('   - Category: ${data['category']}');
          }
          if (kDebugMode) {
            debugPrint('   - Muscle Groups: ${data['muscleGroups']}');
          }
          if (kDebugMode) {
            debugPrint('   - Equipment: ${data['equipment']}');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️  IMPORT VERIFICATION: Warning - Count mismatch!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ VERIFICATION ERROR: $e');
      }
    }
  }
  
  // Method to test a single exercise import
  Future<void> testSingleExercise({String languageCode = 'en'}) async {
    try {
      // Load from new folder structure using ExerciseJsonLoader
      final jsonList = await ExerciseJsonLoader.loadExercises(languageCode);

      if (jsonList.isNotEmpty) {
        final testExercise = jsonList.first;
        final firebaseData = _convertJsonToFirebaseFormat(testExercise);

        if (kDebugMode) {
          debugPrint('🧪 TEST: Converting exercise "${testExercise['nome']}"');
        }
        if (kDebugMode) {
          debugPrint('📋 Firebase format:');
        }
        firebaseData.forEach((key, value) {
          if (kDebugMode) {
            debugPrint('   $key: $value');
          }
        });

        // Test write to Firebase
        await _firestore.collection('test_exercises').doc('test').set(firebaseData);
        if (kDebugMode) {
          debugPrint('✅ TEST: Successfully wrote test exercise to Firebase');
        }

        // Clean up test
        await _firestore.collection('test_exercises').doc('test').delete();
        if (kDebugMode) {
          debugPrint('🗑️  TEST: Cleaned up test exercise');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TEST ERROR: $e');
      }
    }
  }
}