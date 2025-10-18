/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: shared/domain
/// 🎯 Feature: location
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'italian_city.freezed.dart';
part 'italian_city.g.dart';

@freezed
class ItalianCity with _$ItalianCity {
  const factory ItalianCity({
    required String code,
    required String name,
    required String region,
    required double latitude,
    required double longitude,
    @Default([]) List<String> zones,
    @Default(0) int population,
  }) = _ItalianCity;

  factory ItalianCity.fromJson(Map<String, dynamic> json) =>
      _$ItalianCityFromJson(json);
}

/// Italian city zones/districts for major cities
class ItalianCityZones {
  static const Map<String, List<String>> zones = {
    'MI': [ // Milano
      'Centro Storico',
      'Porta Garibaldi',
      'Navigli',
      'Brera',
      'Porta Romana',
      'Città Studi',
      'Isola',
      'Lambrate',
      'Porta Venezia',
      'Bovisa',
    ],
    'RM': [ // Roma  
      'Centro Storico',
      'Trastevere',
      'Testaccio',
      'San Lorenzo',
      'Pigneto',
      'Monti',
      'Prati',
      'EUR',
      'Ostiense',
      'Flaminio',
    ],
    'NA': [ // Napoli
      'Centro Storico',
      'Vomero',
      'Chiaia',
      'Posillipo',
      'Fuorigrotta',
      'Bagnoli',
      'Mergellina',
      'Corso Garibaldi',
      'Sanità',
      'Montesanto',
    ],
    'TO': [ // Torino
      'Centro',
      'San Salvario',
      'Crocetta',
      'San Paolo',
      'Lingotto',
      'Mirafiori',
      'Borgo Po',
      'Quadrilatero Romano',
      'Aurora',
      'Barriera Milano',
    ],
    'PA': [ // Palermo
      'Centro Storico',
      'Kalsa',
      'Vucciria',
      'Borgo Vecchio',
      'Libertà',
      'Mondello',
      'Zen',
      'Brancaccio',
      'Ballarò',
      'Capo',
    ],
    'GE': [ // Genova
      'Centro Storico',
      'Castelletto',
      'Albaro',
      'Foce',
      'San Martino',
      'Marassi',
      'Sampierdarena',
      'Sestri Ponente',
      'Carignano',
      'Maddalena',
    ],
    'BO': [ // Bologna
      'Centro Storico',
      'Universitaria',
      'Santo Stefano',
      'Saragozza',
      'San Donato',
      'Bolognina',
      'Borgo Panigale',
      'Navile',
      'Reno',
      'San Vitale',
    ],
    'FI': [ // Firenze
      'Centro Storico',
      'Oltrarno',
      'San Lorenzo',
      'Santa Croce',
      'San Niccolò',
      'Campo di Marte',
      'Isolotto',
      'Rifredi',
      'Novoli',
      'Le Cure',
    ],
    'BA': [ // Bari
      'Bari Vecchia',
      'Murat',
      'Libertà',
      'San Paolo',
      'Carrassi',
      'Madonnella',
      'Japigia',
      'San Girolamo',
      'Fesca',
      'Torre a Mare',
    ],
    'CT': [ // Catania
      'Centro Storico',
      'Via Etnea',
      'Borgo',
      'San Giovanni Galermo',
      'Librino',
      'San Giorgio',
      'Cibali',
      'Ognina',
      'San Leone',
      'Nesima',
    ],
  };

  static List<String> getZones(String cityCode) {
    return zones[cityCode] ?? [];
  }
}

/// Major Italian cities for buddy matching
class ItalianCities {
  static const List<ItalianCity> majorCities = [
    // Lombardia
    ItalianCity(
      code: 'MI',
      name: 'Milano',
      region: 'Lombardia',
      latitude: 45.4642,
      longitude: 9.1900,
      population: 1396059,
    ),
    ItalianCity(
      code: 'BG',
      name: 'Bergamo',
      region: 'Lombardia', 
      latitude: 45.6983,
      longitude: 9.6773,
      population: 122182,
    ),
    ItalianCity(
      code: 'BS',
      name: 'Brescia',
      region: 'Lombardia',
      latitude: 45.5416,
      longitude: 10.2118,
      population: 200722,
    ),
    
    // Lazio
    ItalianCity(
      code: 'RM',
      name: 'Roma',
      region: 'Lazio',
      latitude: 41.9028,
      longitude: 12.4964,
      population: 2872800,
    ),
    
    // Campania
    ItalianCity(
      code: 'NA',
      name: 'Napoli',
      region: 'Campania',
      latitude: 40.8518,
      longitude: 14.2681,
      population: 967069,
    ),
    
    // Piemonte
    ItalianCity(
      code: 'TO',
      name: 'Torino',
      region: 'Piemonte',
      latitude: 45.0703,
      longitude: 7.6869,
      population: 870952,
    ),
    
    // Sicilia
    ItalianCity(
      code: 'PA',
      name: 'Palermo',
      region: 'Sicilia',
      latitude: 38.1157,
      longitude: 13.3615,
      population: 673735,
    ),
    ItalianCity(
      code: 'CT',
      name: 'Catania',
      region: 'Sicilia',
      latitude: 37.5079,
      longitude: 15.0830,
      population: 311584,
    ),
    
    // Liguria
    ItalianCity(
      code: 'GE',
      name: 'Genova',
      region: 'Liguria',
      latitude: 44.4056,
      longitude: 8.9463,
      population: 583601,
    ),
    
    // Emilia-Romagna
    ItalianCity(
      code: 'BO',
      name: 'Bologna',
      region: 'Emilia-Romagna',
      latitude: 44.4949,
      longitude: 11.3426,
      population: 394843,
    ),
    
    // Toscana
    ItalianCity(
      code: 'FI',
      name: 'Firenze',
      region: 'Toscana',
      latitude: 43.7696,
      longitude: 11.2558,
      population: 382258,
    ),
    
    // Puglia
    ItalianCity(
      code: 'BA',
      name: 'Bari',
      region: 'Puglia',
      latitude: 41.1171,
      longitude: 16.8719,
      population: 320475,
    ),
    
    // Veneto
    ItalianCity(
      code: 'VE',
      name: 'Venezia',
      region: 'Veneto',
      latitude: 45.4408,
      longitude: 12.3155,
      population: 261905,
    ),
    ItalianCity(
      code: 'VR',
      name: 'Verona',
      region: 'Veneto',
      latitude: 45.4384,
      longitude: 10.9916,
      population: 259608,
    ),
    ItalianCity(
      code: 'PD',
      name: 'Padova',
      region: 'Veneto',
      latitude: 45.4064,
      longitude: 11.8768,
      population: 214198,
    ),
  ];

  /// Alias for majorCities for compatibility
  static List<ItalianCity> get allCities => majorCities;

  static ItalianCity? findByCode(String code) {
    try {
      return majorCities.firstWhere((city) => city.code == code);
    } catch (e) {
      return null;
    }
  }

  static ItalianCity? findByName(String name) {
    try {
      return majorCities.firstWhere(
        (city) => city.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<ItalianCity> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return majorCities
        .where((city) =>
            city.name.toLowerCase().contains(lowercaseQuery) ||
            city.region.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  static double calculateDistance(ItalianCity city1, ItalianCity city2) {
    return _haversineDistance(
      city1.latitude,
      city1.longitude,
      city2.latitude,
      city2.longitude,
    );
  }

  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}