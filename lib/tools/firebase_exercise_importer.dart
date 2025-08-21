import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/exercise_database/domain/entities/exercise_template.dart';
import '../features/exercise_database/data/models/exercise_model.dart';

class FirebaseExerciseImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'exercises';

  Future<void> importExercisesFromJson() async {
    try {
      print('🔥 IMPORTER: Starting exercise import from JSON...');
      
      // 1. Load JSON file
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      print('📋 IMPORTER: Found ${jsonList.length} exercises in JSON');
      
      // 2. Check if exercises already exist
      final existingDocs = await _firestore.collection(_collection).get();
      
      if (existingDocs.docs.isNotEmpty) {
        print('⚠️  IMPORTER: Found ${existingDocs.docs.length} existing exercises. Clearing collection...');
        
        // Delete existing exercises
        final batch = _firestore.batch();
        for (var doc in existingDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🗑️  IMPORTER: Cleared existing exercises');
      }
      
      // 3. Import exercises in smaller batches to avoid size limits
      const batchSize = 100; // Reduced batch size
      int imported = 0;
      
      for (int i = 0; i < jsonList.length; i += batchSize) {
        try {
          final batch = _firestore.batch();
          final end = (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;
          
          for (int j = i; j < end; j++) {
            final exerciseJson = jsonList[j] as Map<String, dynamic>;
            
            // Convert JSON structure to Firebase format
            final firebaseData = _convertJsonToFirebaseFormat(exerciseJson);
            
            // Use the exercise id as document id
            final docRef = _firestore.collection(_collection).doc(exerciseJson['id']);
            batch.set(docRef, firebaseData);
          }
          
          print('📤 IMPORTER: Committing batch ${(i ~/ batchSize) + 1}...');
          await batch.commit();
          imported += (end - i);
          print('✅ IMPORTER: Imported batch ${(i ~/ batchSize) + 1} - Total: $imported/${jsonList.length}');
          
          // Small delay between batches to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));
          
        } catch (e) {
          print('❌ BATCH ERROR ${(i ~/ batchSize) + 1}: $e');
          
          // Try individual imports for this batch
          print('🔄 IMPORTER: Trying individual imports for batch ${(i ~/ batchSize) + 1}...');
          final end = (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;
          
          for (int j = i; j < end; j++) {
            try {
              final exerciseJson = jsonList[j] as Map<String, dynamic>;
              final firebaseData = _convertJsonToFirebaseFormat(exerciseJson);
              final docRef = _firestore.collection(_collection).doc(exerciseJson['id']);
              
              await docRef.set(firebaseData);
              imported++;
              
              if (j % 10 == 0) {
                print('📤 Individual import: $imported/${jsonList.length}');
              }
              
              // Small delay between individual writes
              await Future.delayed(const Duration(milliseconds: 50));
              
            } catch (individualError) {
              final exerciseJson = jsonList[j] as Map<String, dynamic>;
              print('❌ Failed to import exercise ${exerciseJson['id']}: $individualError');
            }
          }
        }
      }
      
      print('✅ IMPORTER: Successfully imported $imported exercises to Firebase!');
      
      // 4. Verify import
      await _verifyImport(jsonList.length);
      
    } catch (e) {
      print('❌ IMPORTER ERROR: $e');
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
      'warmupSets': jsonData['warmupSets'] ?? '',
      'warmupTime': jsonData['tempoWarmup'] ?? '',
      'preMobility': jsonData['mobilitaPre'] ?? '',
      'preActivation': jsonData['attivazionePre'] ?? '',
      'technicalDrill': jsonData['drillTecnico'] ?? '',
      'injuryPrevention': jsonData['prevenzioneInfortuni'] ?? '',
      'cooldownRecommended': jsonData['cooldownConsigliato'] ?? '',
      'termExplanation': jsonData['spiegazioneTermini'] ?? '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  String _mapFocusToCategory(String focus) {
    final focusLower = focus.toLowerCase();
    if (focusLower.contains('pett') || focusLower.contains('chest')) return 'chest';
    if (focusLower.contains('dors') || focusLower.contains('back')) return 'back'; 
    if (focusLower.contains('quad') || focusLower.contains('glut') || focusLower.contains('femor')) return 'legs';
    if (focusLower.contains('delt') || focusLower.contains('spall') || focusLower.contains('shoulder')) return 'shoulders';
    if (focusLower.contains('brac') || focusLower.contains('tric') || focusLower.contains('arm')) return 'arms';
    if (focusLower.contains('core') || focusLower.contains('add')) return 'core';
    return 'other';
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
    
    if (jsonData['drillTecnico'] != null && jsonData['drillTecnico'].toString().isNotEmpty) {
      instructions.add('Drill tecnico: ${jsonData['drillTecnico']}');
    }
    
    return instructions.isEmpty ? ['Esegui l\'esercizio seguendo la tecnica corretta'] : instructions;
  }
  
  Future<void> _verifyImport(int expectedCount) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final actualCount = snapshot.docs.length;
      
      print('🔍 IMPORTER: Verification - Expected: $expectedCount, Found: $actualCount');
      
      if (actualCount == expectedCount) {
        print('✅ IMPORT VERIFICATION: Success! All exercises imported correctly');
        
        // Sample a few exercises to verify structure
        final sampleExercises = snapshot.docs.take(3);
        for (final doc in sampleExercises) {
          final data = doc.data();
          print('📋 Sample Exercise: ${data['name']} (${doc.id})');
          print('   - Category: ${data['category']}');
          print('   - Muscle Groups: ${data['muscleGroups']}');
          print('   - Equipment: ${data['equipment']}');
        }
      } else {
        print('⚠️  IMPORT VERIFICATION: Warning - Count mismatch!');
      }
    } catch (e) {
      print('❌ VERIFICATION ERROR: $e');
    }
  }
  
  // Method to test a single exercise import
  Future<void> testSingleExercise() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      if (jsonList.isNotEmpty) {
        final testExercise = jsonList.first as Map<String, dynamic>;
        final firebaseData = _convertJsonToFirebaseFormat(testExercise);
        
        print('🧪 TEST: Converting exercise "${testExercise['nome']}"');
        print('📋 Firebase format:');
        firebaseData.forEach((key, value) {
          print('   $key: $value');
        });
        
        // Test write to Firebase
        await _firestore.collection('test_exercises').doc('test').set(firebaseData);
        print('✅ TEST: Successfully wrote test exercise to Firebase');
        
        // Clean up test
        await _firestore.collection('test_exercises').doc('test').delete();
        print('🗑️  TEST: Cleaned up test exercise');
      }
    } catch (e) {
      print('❌ TEST ERROR: $e');
    }
  }
}