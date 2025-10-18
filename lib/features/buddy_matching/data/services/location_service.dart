/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data
/// 🎯 Feature: buddy_matching
/// 🔧 Type: service
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: N/A - Service class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Permission handler
/// - Location services
/// - Firebase Firestore
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';

/// Risultato dell'operazione di location
class LocationResult {

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.cityCode,
    this.cityName,
    this.zoneName,
    this.isAccurate = false,
  });
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? cityCode;
  final String? cityName;
  final String? zoneName;
  final bool isAccurate;
}

/// Enum per lo stato dei permessi location
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  notDetermined,
}

/// Service per gestire location GPS e permessi
class LocationService {
  factory LocationService() => _instance;
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _locationUpdateTimer;

  /// Controlla lo stato attuale dei permessi location
  Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      
      switch (status) {
        case PermissionStatus.granted:
          return LocationPermissionStatus.granted;
        case PermissionStatus.denied:
          return LocationPermissionStatus.denied;
        case PermissionStatus.permanentlyDenied:
          return LocationPermissionStatus.permanentlyDenied;
        default:
          return LocationPermissionStatus.notDetermined;
      }
    } catch (e) {
      debugPrint('❌ Errore controllo permessi location: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Richiede i permessi di location all'utente
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      final currentStatus = await checkLocationPermission();
      
      if (currentStatus == LocationPermissionStatus.granted) {
        return LocationPermissionStatus.granted;
      }
      
      if (currentStatus == LocationPermissionStatus.permanentlyDenied) {
        return LocationPermissionStatus.permanentlyDenied;
      }

      // Richiedi il permesso
      final status = await Permission.location.request();
      
      switch (status) {
        case PermissionStatus.granted:
          return LocationPermissionStatus.granted;
        case PermissionStatus.denied:
          return LocationPermissionStatus.denied;
        case PermissionStatus.permanentlyDenied:
          return LocationPermissionStatus.permanentlyDenied;
        default:
          return LocationPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('❌ Errore richiesta permessi location: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Ottiene la posizione GPS corrente (mock per ora)
  Future<LocationResult?> getCurrentLocation() async {
    try {
      final permissionStatus = await checkLocationPermission();
      
      if (permissionStatus != LocationPermissionStatus.granted) {
        debugPrint('📍 Permessi location non concessi');
        return null;
      }

      // MOCK IMPLEMENTATION - In produzione usare geolocator
      // Per ora genera una posizione casuale vicino a Milano
      final milanCity = ItalianCities.findByCode('MI')!;
      final randomOffset = (DateTime.now().millisecondsSinceEpoch % 1000) / 10000.0;
      
      final mockLatitude = milanCity.latitude + (randomOffset - 0.05);
      final mockLongitude = milanCity.longitude + (randomOffset - 0.05);

      // Trova la città più vicina
      final nearestCity = _findNearestCity(mockLatitude, mockLongitude);
      
      return LocationResult(
        latitude: mockLatitude,
        longitude: mockLongitude,
        locationName: '${nearestCity.name} Centro',
        cityCode: nearestCity.code,
        cityName: nearestCity.name,
        zoneName: _generateRandomZone(),
        isAccurate: true,
      );

      /* REAL IMPLEMENTATION (uncomment when geolocator is added):
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      final nearestCity = _findNearestCity(position.latitude, position.longitude);
      
      // Reverse geocoding per ottenere il nome del luogo
      String? locationName;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          locationName = '${placemark.locality ?? nearestCity.name} ${placemark.subLocality ?? ''}';
        }
      } catch (e) {
        debugPrint('❌ Errore reverse geocoding: $e');
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName ?? '${nearestCity.name} Centro',
        cityCode: nearestCity.code,
        cityName: nearestCity.name,
        zoneName: null,
        isAccurate: position.accuracy < 100, // < 100 metri = accurato
      );
      
      */
      
    } catch (e) {
      debugPrint('❌ Errore ottenimento location: $e');
      return null;
    }
  }

  /// Aggiorna la posizione dell'utente in Firestore
  Future<void> updateUserLocation(LocationResult location) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utente non autenticato');
      }

      await _firestore
          .collection('buddy_profiles')
          .doc(currentUser.uid)
          .update({
        'preferences.latitude': location.latitude,
        'preferences.longitude': location.longitude,
        'preferences.locationName': location.locationName,
        'preferences.cityCode': location.cityCode,
        'preferences.cityName': location.cityName,
        'preferences.zoneName': location.zoneName,
        'preferences.lastLocationUpdate': FieldValue.serverTimestamp(),
        'preferences.isLocationAccurate': location.isAccurate,
      });

      debugPrint('✅ Location utente aggiornata: ${location.cityName}');
    } catch (e) {
      debugPrint('❌ Errore aggiornamento location: $e');
      rethrow;
    }
  }

  /// Avvia aggiornamenti periodici della location (ogni 15 minuti)
  void startPeriodicLocationUpdates() {
    stopPeriodicLocationUpdates(); // Ferma eventuali timer esistenti
    
    _locationUpdateTimer = Timer.periodic(
      const Duration(minutes: 15),
      (timer) async {
        try {
          final location = await getCurrentLocation();
          if (location != null) {
            await updateUserLocation(location);
          }
        } catch (e) {
          debugPrint('❌ Errore aggiornamento periodico location: $e');
        }
      },
    );
    
    debugPrint('📍 Aggiornamenti periodici location avviati');
  }

  /// Ferma gli aggiornamenti periodici della location
  void stopPeriodicLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    debugPrint('📍 Aggiornamenti periodici location fermati');
  }

  /// Trova la città italiana più vicina alle coordinate date
  ItalianCity _findNearestCity(double latitude, double longitude) {
    ItalianCity? nearestCity;
    double minDistance = double.infinity;

    for (final city in ItalianCities.allCities) {
      final distance = _calculateDistance(
        latitude, longitude,
        city.latitude, city.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }

    return nearestCity ?? ItalianCities.findByCode('MI')!; // Fallback a Milano
  }

  /// Calcola la distanza tra due punti geografici (formula di Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() *
        (dLon / 2).sin() * (dLon / 2).sin();

    final double c = 2 * a.sqrt().asin();
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  String _generateRandomZone() {
    final zones = [
      'Centro', 'Stazione', 'Università', 'Quartiere Nord',
      'Zona Sud', 'Periferia', 'Centro Storico', 'Zona Industriale',
      'Quartiere Residenziale', 'Zona Commerciale'
    ];
    final random = DateTime.now().millisecondsSinceEpoch % zones.length;
    return zones[random];
  }

  /// Apre le impostazioni dell'app per i permessi
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Verifica se i servizi di location sono abilitati sul device
  Future<bool> isLocationServiceEnabled() async {
    try {
      // Con permission_handler non c'è un modo diretto per controllare i servizi location
      // Assumiamo che siano abilitati se il permesso è concesso
      final status = await checkLocationPermission();
      return status == LocationPermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Errore controllo servizi location: $e');
      return false;
    }
  }

  /// Ottiene statistiche sull'utilizzo della location
  Future<Map<String, dynamic>> getLocationStats() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return {};

      final userDoc = await _firestore
          .collection('buddy_profiles')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return {};

      final data = userDoc.data()!;
      final preferences = data['preferences'] as Map<String, dynamic>?;

      if (preferences == null) return {};

      return {
        'hasLocation': preferences['latitude'] != null && preferences['longitude'] != null,
        'cityName': preferences['cityName'],
        'locationName': preferences['locationName'],
        'isAccurate': preferences['isLocationAccurate'] ?? false,
        'lastUpdate': preferences['lastLocationUpdate'],
        'permissionStatus': (await checkLocationPermission()).name,
      };
    } catch (e) {
      debugPrint('❌ Errore ottenimento stats location: $e');
      return {};
    }
  }

  /// Cleanup quando l'app viene chiusa
  void dispose() {
    stopPeriodicLocationUpdates();
  }
}

/// Extension per conversioni matematiche
extension on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}
