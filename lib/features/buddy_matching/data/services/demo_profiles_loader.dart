/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data
 * 🎯 Feature: buddy_matching
 * 🔧 Type: service
 * 🌍 Localization: N/A - Service class
 * 🎨 Theme: N/A - Service class
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Firebase: Firestore
 * - Demo data
 */

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../demo_profiles.dart';
import '../../domain/entities/buddy_profile.dart';
import '../../../../shared/domain/entities/italian_city.dart';

/// Service per caricare profili demo in Firestore per testing
class DemoProfilesLoader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Carica tutti i profili demo in Firestore
  Future<void> loadDemoProfiles({bool force = false}) async {
    try {
      // Check se i profili demo sono già stati caricati
      if (!force) {
        final existing = await _firestore
            .collection('buddy_profiles')
            .where('uid', whereIn: DemoProfiles.allProfiles.map((p) => p.uid).toList())
            .limit(1)
            .get();
            
        if (existing.docs.isNotEmpty) {
          print('📱 Demo profiles già caricati. Usa force=true per ricaricare.');
          return;
        }
      }

      print('📱 Caricamento ${DemoProfiles.allProfiles.length} profili demo...');

      final batch = _firestore.batch();
      
      for (final profile in DemoProfiles.allProfiles) {
        final docRef = _firestore.collection('buddy_profiles').doc(profile.uid);
        
        // Convert profile to JSON for Firestore
        final profileData = profile.toJson();
        
        // Add server timestamp for consistency
        profileData['serverTimestamp'] = FieldValue.serverTimestamp();
        profileData['isDemoProfile'] = true;
        profileData['loadedAt'] = DateTime.now().toIso8601String();
        
        batch.set(docRef, profileData);
      }

      await batch.commit();
      print('✅ ${DemoProfiles.allProfiles.length} profili demo caricati con successo!');
      
      // Carica anche le preferenze di matching
      await _loadDemoPreferences();
      
    } catch (e) {
      print('❌ Errore nel caricamento profili demo: $e');
      rethrow;
    }
  }

  /// Carica profili demo per una città specifica
  Future<void> loadDemoProfilesForCity(String cityCode, {int count = 5}) async {
    try {
      final cityProfiles = DemoProfiles.getProfilesByCity(cityCode);
      final profilesToLoad = cityProfiles.take(count).toList();
      
      if (profilesToLoad.isEmpty) {
        // Se non ci sono profili per questa città, prendi profili casuali
        final randomProfiles = DemoProfiles.getRandomProfiles(count: count);
        await _loadSpecificProfiles(randomProfiles, cityCode);
      } else {
        await _loadSpecificProfiles(profilesToLoad, cityCode);
      }
      
    } catch (e) {
      print('❌ Errore nel caricamento profili per città $cityCode: $e');
      rethrow;
    }
  }

  /// Carica profili demo per l'utente corrente (per testing)
  Future<void> loadDemoProfilesNearCurrentUser({int count = 10}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utente non autenticato');
      }

      // Prova a ottenere il profilo dell'utente corrente
      final userProfileDoc = await _firestore
          .collection('buddy_profiles')
          .doc(currentUser.uid)
          .get();
          
      String? userCityCode;
      if (userProfileDoc.exists) {
        final data = userProfileDoc.data();
        userCityCode = data?['preferences']?['cityCode'];
      }
      
      // Se non ha un profilo o città, usa Milano come default
      userCityCode ??= 'MI';
      
      await loadDemoProfilesForCity(userCityCode, count: count);
      
    } catch (e) {
      print('❌ Errore nel caricamento profili near user: $e');
      rethrow;
    }
  }

  /// Pulisce tutti i profili demo dal database
  Future<void> clearDemoProfiles() async {
    try {
      print('🧹 Rimozione profili demo...');
      
      final demoProfiles = await _firestore
          .collection('buddy_profiles')
          .where('isDemoProfile', isEqualTo: true)
          .get();
          
      final batch = _firestore.batch();
      for (final doc in demoProfiles.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ ${demoProfiles.docs.length} profili demo rimossi');
      
    } catch (e) {
      print('❌ Errore nella rimozione profili demo: $e');
      rethrow;
    }
  }

  /// Reload completo: rimuove e ricarica tutti i profili demo
  Future<void> reloadDemoProfiles() async {
    await clearDemoProfiles();
    await loadDemoProfiles(force: true);
  }

  /// Aggiorna le posizioni dei profili demo per essere vicini ad una città
  Future<void> updateDemoProfileLocations(String targetCityCode) async {
    try {
      final targetCity = ItalianCities.findByCode(targetCityCode);
      if (targetCity == null) {
        throw Exception('Città non trovata: $targetCityCode');
      }

      print('📍 Aggiornamento posizioni demo per ${targetCity.name}...');

      final demoProfiles = await _firestore
          .collection('buddy_profiles')
          .where('isDemoProfile', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in demoProfiles.docs) {
        // Create random position near target city (within 30km)
        final randomOffset = (math.Random().nextDouble() - 0.5) * 0.5; // ~30km range
        final newLatitude = targetCity.latitude + randomOffset;
        final newLongitude = targetCity.longitude + randomOffset;
        
        batch.update(doc.reference, {
          'preferences.latitude': newLatitude,
          'preferences.longitude': newLongitude,
          'preferences.cityCode': targetCityCode,
          'preferences.cityName': targetCity.name,
          'preferences.locationName': '${targetCity.name} ${_getRandomZoneName()}',
          'preferences.lastLocationUpdate': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
      print('✅ Posizioni aggiornate per ${demoProfiles.docs.length} profili');
      
    } catch (e) {
      print('❌ Errore nell\'aggiornamento posizioni: $e');
      rethrow;
    }
  }

  /// Verifica lo stato dei profili demo
  Future<Map<String, dynamic>> getDemoProfilesStatus() async {
    try {
      final demoProfiles = await _firestore
          .collection('buddy_profiles')
          .where('isDemoProfile', isEqualTo: true)
          .get();

      final totalProfiles = await _firestore
          .collection('buddy_profiles')
          .count()
          .get();

      final cityCounts = <String, int>{};
      for (final doc in demoProfiles.docs) {
        final data = doc.data();
        final cityCode = data['preferences']?['cityCode'] as String?;
        if (cityCode != null) {
          cityCounts[cityCode] = (cityCounts[cityCode] ?? 0) + 1;
        }
      }

      return {
        'demoProfilesCount': demoProfiles.docs.length,
        'totalProfilesCount': totalProfiles.count,
        'demoProfilesLoaded': demoProfiles.docs.isNotEmpty,
        'cityCounts': cityCounts,
        'profileIds': demoProfiles.docs.map((d) => d.id).toList(),
      };
    } catch (e) {
      print('❌ Errore nel controllo status: $e');
      rethrow;
    }
  }

  // Helper methods

  Future<void> _loadSpecificProfiles(List<BuddyProfile> profiles, String? targetCityCode) async {
    final batch = _firestore.batch();
    
    for (final profile in profiles) {
      final docRef = _firestore.collection('buddy_profiles').doc(profile.uid);
      
      var profileData = profile.toJson();
      profileData['serverTimestamp'] = FieldValue.serverTimestamp();
      profileData['isDemoProfile'] = true;
      profileData['loadedAt'] = DateTime.now().toIso8601String();
      
      // Se specificata una città target, aggiorna la posizione
      if (targetCityCode != null && targetCityCode != profile.preferences.cityCode) {
        final targetCity = ItalianCities.findByCode(targetCityCode);
        if (targetCity != null) {
          profileData['preferences']['cityCode'] = targetCityCode;
          profileData['preferences']['cityName'] = targetCity.name;
          profileData['preferences']['latitude'] = targetCity.latitude;
          profileData['preferences']['longitude'] = targetCity.longitude;
          profileData['preferences']['locationName'] = '${targetCity.name} ${_getRandomZoneName()}';
        }
      }
      
      batch.set(docRef, profileData);
    }

    await batch.commit();
    print('✅ ${profiles.length} profili specifici caricati');
  }

  Future<void> _loadDemoPreferences() async {
    // Carica anche alcune preferenze di esempio per l'algoritmo di matching
    print('📋 Caricamento preferenze demo...');
    
    final batch = _firestore.batch();
    
    // Crea alcune coppie di matching di esempio
    final matchingPairs = [
      ['demo_marco_123', 'demo_giulia_456'],
      ['demo_andrea_789', 'demo_valeria_505'],
      ['demo_chiara_101', 'demo_francesca_303'],
    ];
    
    for (final pair in matchingPairs) {
      // Crea like reciproci per alcuni profili per avere match di esempio
      final match1Id = '${pair[0]}_${pair[1]}';
      final match2Id = '${pair[1]}_${pair[0]}';
      
      batch.set(_firestore.collection('buddy_actions').doc(match1Id), {
        'fromUserId': pair[0],
        'toUserId': pair[1],
        'action': 'like',
        'timestamp': FieldValue.serverTimestamp(),
        'isDemoAction': true,
      });
      
      batch.set(_firestore.collection('buddy_actions').doc(match2Id), {
        'fromUserId': pair[1],
        'toUserId': pair[0],
        'action': 'like',
        'timestamp': FieldValue.serverTimestamp(),
        'isDemoAction': true,
      });
    }
    
    await batch.commit();
    print('✅ Preferenze demo caricate');
  }

  String _getRandomZoneName() {
    final zones = [
      'Centro', 'Stazione', 'Università', 'Quartiere Nord', 
      'Zona Sud', 'Periferia', 'Centro Storico', 'Nuovo'
    ];
    return zones[math.Random().nextInt(zones.length)];
  }
}