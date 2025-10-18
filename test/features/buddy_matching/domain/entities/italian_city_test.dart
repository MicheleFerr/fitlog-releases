/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test
/// 🎯 Feature: buddy_matching  
/// 🔧 Type: unit test
/// 🌍 Localization: N/A - Test file
/// 🎨 Theme: N/A - Test file
/// 📱 Platform: Universal
/// 
/// Testing Italian city system for buddy matching location features
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';

void main() {
  group('ItalianCity', () {
    test('should create Italian city with all properties', () {
      const city = ItalianCity(
        code: 'MI',
        name: 'Milano',
        region: 'Lombardia',
        latitude: 45.4642,
        longitude: 9.1900,
        population: 1396059,
      );

      expect(city.code, equals('MI'));
      expect(city.name, equals('Milano'));
      expect(city.region, equals('Lombardia'));
      expect(city.latitude, equals(45.4642));
      expect(city.longitude, equals(9.1900));
      expect(city.population, equals(1396059));
    });

    test('should support JSON serialization', () {
      const city = ItalianCity(
        code: 'RM',
        name: 'Roma',
        region: 'Lazio', 
        latitude: 41.9028,
        longitude: 12.4964,
        population: 2872800,
      );

      final json = city.toJson();
      final fromJson = ItalianCity.fromJson(json);

      expect(fromJson.code, equals(city.code));
      expect(fromJson.name, equals(city.name));
      expect(fromJson.region, equals(city.region));
      expect(fromJson.latitude, equals(city.latitude));
      expect(fromJson.longitude, equals(city.longitude));
      expect(fromJson.population, equals(city.population));
    });
  });

  group('ItalianCities', () {
    test('should contain major Italian cities', () {
      expect(ItalianCities.majorCities.isNotEmpty, isTrue);
      expect(ItalianCities.majorCities.length, greaterThanOrEqualTo(10));
    });

    test('should find city by code', () {
      final milano = ItalianCities.findByCode('MI');
      expect(milano, isNotNull);
      expect(milano!.name, equals('Milano'));
      expect(milano.region, equals('Lombardia'));
    });

    test('should return null for invalid city code', () {
      final invalidCity = ItalianCities.findByCode('XX');
      expect(invalidCity, isNull);
    });

    test('should find city by name', () {
      final roma = ItalianCities.findByName('Roma');
      expect(roma, isNotNull);
      expect(roma!.code, equals('RM'));
      expect(roma.region, equals('Lazio'));
    });

    test('should find city by name case insensitive', () {
      final napoli = ItalianCities.findByName('NAPOLI');
      expect(napoli, isNotNull);
      expect(napoli!.code, equals('NA'));
    });

    test('should search cities by query', () {
      final results = ItalianCities.search('Mil');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((city) => city.name == 'Milano'), isTrue);
    });

    test('should search cities by region', () {
      final results = ItalianCities.search('Lombardia');
      expect(results.isNotEmpty, isTrue);
      expect(results.every((city) => city.region == 'Lombardia'), isTrue);
    });

    test('should calculate distance between cities', () {
      final milano = ItalianCities.findByCode('MI')!;
      final roma = ItalianCities.findByCode('RM')!;

      final distance = ItalianCities.calculateDistance(milano, roma);
      
      // Distance between Milano and Roma should be around 480-500 km
      expect(distance, greaterThan(400));
      expect(distance, lessThan(600));
    });

    test('should calculate zero distance for same city', () {
      final milano = ItalianCities.findByCode('MI')!;
      final distance = ItalianCities.calculateDistance(milano, milano);
      expect(distance, equals(0.0));
    });
  });

  group('ItalianCityZones', () {
    test('should return zones for major cities', () {
      final milanoZones = ItalianCityZones.getZones('MI');
      expect(milanoZones.isNotEmpty, isTrue);
      expect(milanoZones.contains('Centro Storico'), isTrue);
      expect(milanoZones.contains('Navigli'), isTrue);
    });

    test('should return zones for Rome', () {
      final romaZones = ItalianCityZones.getZones('RM');
      expect(romaZones.isNotEmpty, isTrue);
      expect(romaZones.contains('Trastevere'), isTrue);
      expect(romaZones.contains('Centro Storico'), isTrue);
    });

    test('should return empty list for cities without zones', () {
      final unknownZones = ItalianCityZones.getZones('XX');
      expect(unknownZones.isEmpty, isTrue);
    });

    test('should have unique zones per city', () {
      final milanoZones = ItalianCityZones.getZones('MI');
      final uniqueZones = milanoZones.toSet();
      expect(milanoZones.length, equals(uniqueZones.length));
    });
  });
}