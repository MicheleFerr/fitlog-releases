/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data
/// 🎯 Feature: community
/// 🔧 Type: service
/// 🌍 Localization: N/A - Service class
/// 🎨 Theme: N/A - Service class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: Firestore
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DemoProfilesLoader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  /// Load demo profiles to Firestore for testing
  Future<void> loadDemoProfiles() async {
    final profiles = _generateDemoProfiles();
    
    final batch = _firestore.batch();
    
    for (final profile in profiles) {
      final docRef = _firestore.collection('buddy_profiles').doc(profile['userId']);
      batch.set(docRef, profile);
    }
    
    await batch.commit();
  }

  /// Load demo profiles for a specific city
  Future<void> loadLocalDemoProfiles(String cityCode) async {
    final profiles = _generateDemoProfiles(cityCode: cityCode);
    
    final batch = _firestore.batch();
    
    for (final profile in profiles) {
      final docRef = _firestore.collection('buddy_profiles').doc(profile['userId']);
      batch.set(docRef, profile);
    }
    
    await batch.commit();
  }

  /// Reload existing demo profiles with fresh data
  Future<void> reloadDemoProfiles() async {
    await clearDemoProfiles();
    await loadDemoProfiles();
  }

  /// Clear all demo profiles
  Future<void> clearDemoProfiles() async {
    final querySnapshot = await _firestore
        .collection('buddy_profiles')
        .where('isDemo', isEqualTo: true)
        .get();
    
    final batch = _firestore.batch();
    
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  List<Map<String, dynamic>> _generateDemoProfiles({String? cityCode}) {
    final cities = cityCode != null 
        ? [cityCode]
        : ['MI', 'RM', 'NA', 'TO', 'FI'];
    
    final profiles = <Map<String, dynamic>>[];
    
    final names = [
      'Luca', 'Marco', 'Alessandro', 'Francesco', 'Matteo',
      'Giulia', 'Sara', 'Chiara', 'Martina', 'Federica'
    ];
    
    final bios = [
      '💪 Powerlifter | 🏋️ 5 anni di esperienza | Sempre alla ricerca di un buddy per spingersi oltre i limiti!',
      '🏃‍♂️ Runner & CrossFit enthusiast | Mi alleno 5 volte a settimana | Cerco compagni per WOD e corse',
      '🥊 Boxe e functional training | Discipline e costanza | Cerchiamo di migliorare insieme!',
      '🧘‍♀️ Yoga al mattino, pesi la sera | Balance is key | Buddy per sessioni miste?',
      '🚴 Ciclista e gym addicted | Cardio + forza | Motivazione reciproca garantita!',
      '🤸‍♂️ Calisthenics pro | Street workout | Chi vuole imparare muscle up?',
      '🏊‍♂️ Nuoto e palestra | Total body workout | Cerco buddy per allenamenti completi',
      '⚡ HIIT specialist | Burn calories together | Ready for intense sessions?',
      '🎯 Bodybuilding focused | Aesthetic goals | Looking for serious training partner',
      '🔥 Fitness coach | Posso aiutarti con la forma | Alleniamoci insieme!'
    ];
    
    final instagramHandles = [
      'luca_fit', 'marco_strong', 'ale_powerlifter', 'francesco_gym',
      'matteo_athlete', 'giulia_fitness', 'sara_workout', 'chiara_fit',
      'martina_gym', 'federica_strong'
    ];
    
    for (int i = 0; i < 10; i++) {
      final isLookingForDating = _random.nextBool();
      final city = cities[_random.nextInt(cities.length)];
      
      profiles.add({
        'userId': 'demo_user_${i + 1}',
        'name': names[i],
        'age': 20 + _random.nextInt(20),
        'bio': bios[i],
        'photoUrl': 'https://source.unsplash.com/400x600/?fitness,gym,person&sig=$i',
        'instagramHandle': instagramHandles[i],
        'location': {
          'cityCode': city,
          'cityName': _getCityName(city),
          'zone': _getRandomZone(city),
        },
        'preferences': {
          'workoutSchedule': _getRandomSchedule(),
          'fitnessLevel': _getRandomFitnessLevel(),
          'goals': _getRandomGoals(),
          'personalityType': _getRandomPersonality(),
          'isLookingForDating': isLookingForDating,
          'isLookingForBuddy': true,
          'preferredAgeRange': {
            'min': 18,
            'max': 50,
          },
          'preferredGender': 'all',
          'maxDistance': 20,
        },
        'stats': {
          'rating': 3.5 + _random.nextDouble() * 1.5,
          'completedWorkouts': _random.nextInt(100),
          'responseRate': 0.7 + _random.nextDouble() * 0.3,
        },
        'isDemo': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
    
    return profiles;
  }

  String _getCityName(String code) {
    final cityNames = {
      'MI': 'Milano',
      'RM': 'Roma',
      'NA': 'Napoli',
      'TO': 'Torino',
      'FI': 'Firenze',
    };
    return cityNames[code] ?? 'Milano';
  }

  String _getRandomZone(String cityCode) {
    final zones = {
      'MI': ['Centro Storico', 'Navigli', 'Porta Romana', 'Città Studi', 'Brera'],
      'RM': ['Centro Storico', 'Trastevere', 'Testaccio', 'San Lorenzo', 'Prati'],
      'NA': ['Centro Storico', 'Vomero', 'Chiaia', 'Posillipo', 'Fuorigrotta'],
      'TO': ['Centro', 'San Salvario', 'Crocetta', 'San Paolo', 'Lingotto'],
      'FI': ['Centro Storico', 'Oltrarno', 'San Lorenzo', 'Santa Croce', 'Campo di Marte'],
    };
    
    final cityZones = zones[cityCode] ?? zones['MI']!;
    return cityZones[_random.nextInt(cityZones.length)];
  }

  List<String> _getRandomSchedule() {
    final schedules = [
      ['morning', 'evening'],
      ['morning'],
      ['evening'],
      ['afternoon', 'evening'],
      ['morning', 'afternoon'],
    ];
    return schedules[_random.nextInt(schedules.length)];
  }

  String _getRandomFitnessLevel() {
    final levels = ['beginner', 'intermediate', 'advanced', 'expert'];
    return levels[_random.nextInt(levels.length)];
  }

  List<String> _getRandomGoals() {
    final allGoals = [
      'muscle_gain', 'weight_loss', 'strength', 
      'endurance', 'flexibility', 'general_fitness'
    ];
    
    final numGoals = 1 + _random.nextInt(3);
    final goals = <String>[];
    
    for (int i = 0; i < numGoals; i++) {
      final goal = allGoals[_random.nextInt(allGoals.length)];
      if (!goals.contains(goal)) {
        goals.add(goal);
      }
    }
    
    return goals;
  }

  String _getRandomPersonality() {
    final personalities = ['motivator', 'competitor', 'socializer', 'focused'];
    return personalities[_random.nextInt(personalities.length)];
  }
}