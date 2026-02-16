/// Servizio di ricerca esercizi V3 - Con Fuzzy Search
///
/// Caratteristiche:
/// - Fuzzy matching: "distenzioni" trova "distensioni" (typo tolerance)
/// - Order-agnostic: "Leg Curl" trova "Curl Sdraiato Leg"
/// - Token-based matching: cerca tutti i token della query
/// - Sinonimi per categorie (push, pull, gambe, etc.)
library;

import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

class ExerciseSearchService {
  factory ExerciseSearchService() => _instance;
  ExerciseSearchService._internal();
  static final ExerciseSearchService _instance =
      ExerciseSearchService._internal();

  List<Map<String, dynamic>> _exercisesData = [];
  String? _cachedLocaleCode;

  /// Get search abbreviations for a query term
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  /// Returns muscle abbreviation codes that match the search term.
  static List<String> _getSearchAbbreviations(String query) {
    return MuscleAbbreviationMapper.getSearchAbbreviations(query);
  }

  /// Get display name for a muscle code
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  static String _getMuscleDisplayName(String code) {
    return MuscleAbbreviationMapper.codeToDisplayName(code);
  }

  /// Check if a code is a valid muscle abbreviation
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  static bool _isValidMuscleCode(String code) {
    return MuscleAbbreviationMapper.getMuscleInfo(code) != null;
  }

  Future<void> loadExercises([Locale? locale]) async {
    final localeCode = locale?.languageCode ?? 'en';

    if (_cachedLocaleCode != localeCode) {
      _exercisesData = [];
      _cachedLocaleCode = localeCode;
    }

    if (_exercisesData.isNotEmpty) return;

    try {
      _exercisesData = await ExerciseJsonLoader.loadExercises(localeCode);
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading exercises: $e');
      _exercisesData = [];
    }
  }

  Future<List<ExerciseTemplate>> searchExercises(
    String query, [
    Locale? locale,
  ]) async {
    await loadExercises(locale);

    final queryLower = query.toLowerCase().trim();
    if (queryLower.isEmpty) return _getAllExercises();

    // 1. Check category mapping (es: "push", "gambe")
    final mappedMuscles = _getMappedMuscles(queryLower);
    if (mappedMuscles.isNotEmpty) {
      return _searchByMuscles(mappedMuscles);
    }

    // 2. Order-agnostic token search
    return _orderAgnosticSearch(queryLower);
  }

  /// Soglia minima per fuzzy match (0-100)
  /// 70 = permette ~30% di errori (es: "distenzioni" → "distensioni")
  static const int _fuzzyThreshold = 70;

  /// Ricerca order-agnostic con fuzzy matching
  /// "Leg Curl" trova "Curl Sdraiato Leg"
  /// "distenzioni" trova "distensioni" (typo tolerance)
  List<ExerciseTemplate> _orderAgnosticSearch(String query) {
    final queryTokens = _normalizeAndTokenize(query);
    if (queryTokens.isEmpty) return [];

    final scoredResults = <_ScoredExercise>[];

    for (final exerciseData in _exercisesData) {
      final nome = (exerciseData['nome'] as String?) ?? '';
      final normalizedNome = _normalize(nome);
      final nameTokens = normalizedNome.split(RegExp(r'\s+'));

      // Calcola score basato su quanti token della query matchano
      double totalScore = 0;
      int matchedTokens = 0;

      for (final qt in queryTokens) {
        int bestMatchScore = 0;

        // Trova il miglior match fuzzy tra i token del nome
        for (final nt in nameTokens) {
          // 1. Check match esatto o substring (veloce)
          if (nt == qt) {
            bestMatchScore = 100;
            break;
          } else if (nt.contains(qt) || qt.contains(nt)) {
            final substringScore = nt.startsWith(qt) || qt.startsWith(nt) ? 95 : 90;
            if (substringScore > bestMatchScore) {
              bestMatchScore = substringScore;
            }
          } else {
            // 2. Fuzzy match per typos (es: distenzioni → distensioni)
            final fuzzyScore = ratio(qt, nt);
            if (fuzzyScore > bestMatchScore) {
              bestMatchScore = fuzzyScore;
            }
          }
        }

        // Token matcha se supera la soglia
        if (bestMatchScore >= _fuzzyThreshold) {
          matchedTokens++;
          totalScore += bestMatchScore / 100.0;
        }
      }

      // Skip se non tutti i token matchano (con tolleranza fuzzy)
      if (matchedTokens < queryTokens.length) continue;

      // Normalizza score
      final normalizedScore = totalScore / queryTokens.length;

      // Bonus per nome che inizia con il primo token della query
      double finalScore = normalizedScore;
      if (nameTokens.isNotEmpty && queryTokens.isNotEmpty) {
        final firstTokenMatch = ratio(nameTokens.first, queryTokens.first);
        if (firstTokenMatch >= 80) {
          finalScore *= 1.1;
        }
      }

      scoredResults.add(
        _ScoredExercise(
          data: exerciseData,
          score: finalScore.clamp(0.0, 1.0),
        ),
      );
    }

    // Ordina per score decrescente
    scoredResults.sort((a, b) => b.score.compareTo(a.score));

    // Converti in ExerciseTemplate
    return scoredResults
        .take(50) // Limita risultati
        .map((sr) => _mapToExerciseTemplate(sr.data))
        .toList();
  }

  List<String> _normalizeAndTokenize(String text) {
    return _normalize(text)
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2) // Min 2 caratteri
        .toList();
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }

  /// Get muscle codes for a search query
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper for all mappings.
  List<String> _getMappedMuscles(String query) {
    final muscles = <String>{};

    // Get search abbreviations from mapper (handles patterns like 'push', 'legs', etc.)
    final searchAbbrs = _getSearchAbbreviations(query);
    muscles.addAll(searchAbbrs);

    // Also check if query itself is a valid muscle code
    final upperQuery = query.toUpperCase();
    if (_isValidMuscleCode(upperQuery)) {
      muscles.add(upperQuery);
    }

    return muscles.toList();
  }

  List<ExerciseTemplate> _searchByMuscles(List<String> muscles) {
    final results = <ExerciseTemplate>[];

    for (final exerciseData in _exercisesData) {
      final focus = exerciseData['focus'] as String?;
      if (focus == null) continue;

      for (final muscle in muscles) {
        if (focus.contains(muscle)) {
          results.add(_mapToExerciseTemplate(exerciseData));
          break;
        }
      }
    }

    return results;
  }

  List<ExerciseTemplate> _getAllExercises() {
    return _exercisesData.map(_mapToExerciseTemplate).toList();
  }

  ExerciseTemplate _mapToExerciseTemplate(Map<String, dynamic> data) {
    final focus = data['focus'] as String? ?? '';
    final muscleGroups = _parseMuscleGroups(focus);
    final category = _determineCategory(focus);

    return ExerciseTemplate(
      id: data['id'] ?? '',
      name: data['nome'] ?? '',
      description: '${data['focus'] ?? ''} - ${data['tipoEsercizio'] ?? ''}',
      category: category,
      type: ExerciseType.single,
      muscleGroups: muscleGroups,
      equipment: [data['attrezzatura'] ?? 'Nessuna'],
      instructions: [
        if (data['noteTecniche'] != null) data['noteTecniche'],
        if (data['tempoNote'] != null) 'Tempo: ${data['tempoNote']}',
      ],
      imageUrl: data['imageUrl'],
      difficulty: data['difficolta'] ?? 'Intermedio',
      isActive: true,
    );
  }

  /// Parse muscle codes into display names
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper.
  List<String> _parseMuscleGroups(String focus) {
    final groups = <String>[];
    final parts = focus.split(',').map((s) => s.trim()).toList();

    for (final part in parts) {
      final displayName = _getMuscleDisplayName(part);
      groups.add(displayName);
    }

    return groups;
  }

  /// Determine exercise category from focus codes
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper.
  ExerciseCategory _determineCategory(String focus) {
    final parts = focus.split(',').map((s) => s.trim()).toList();
    return MuscleAbbreviationMapper.focusListToExerciseCategory(parts);
  }

  // Quick filter buttons
  static const List<Map<String, dynamic>> quickFilters = [
    {'label': 'Upper Body', 'icon': '💪', 'query': 'upper body'},
    {'label': 'Lower Body', 'icon': '🦵', 'query': 'lower body'},
    {'label': 'Core', 'icon': '🎯', 'query': 'core'},
    {'label': 'Push', 'icon': '🫸', 'query': 'push'},
    {'label': 'Pull', 'icon': '🫷', 'query': 'pull'},
    {'label': 'Full Body', 'icon': '🏋️', 'query': 'full body'},
  ];
}

/// Helper class per ordinare risultati
class _ScoredExercise {
  _ScoredExercise({required this.data, required this.score});
  final Map<String, dynamic> data;
  final double score;
}
