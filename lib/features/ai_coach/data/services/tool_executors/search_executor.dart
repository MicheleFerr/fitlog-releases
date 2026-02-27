/// Search tool executor for AI Coach
///
/// Handles: searchExercises, getAccessoryExercises, searchScientificSources
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart'
    as h;
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/document_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:flutter/widgets.dart' show Locale;

class SearchExecutor {
  SearchExecutor({
    required this.exerciseSearchService,
    this.documentRepository,
    this.locale,
  });

  final ExerciseSearchService exerciseSearchService;
  final DocumentRepository? documentRepository;
  final Locale? locale;

  final Map<String, h.DocumentSearchCacheEntry> _documentSearchCache = {};

  // ------------------------------------------------------------------
  // searchExercises
  // ------------------------------------------------------------------

  Future<String> searchExercises(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final query = args['query'] as String?;
    if (query == null || query.isEmpty) {
      return jsonEncode({'error': 'Missing query parameter'});
    }

    final limitRaw = args['limit'];
    final limit = (limitRaw is num ? limitRaw.toInt() : 10).clamp(1, 20);

    try {
      final results = await exerciseSearchService.searchExercises(
        query,
        locale,
      );
      if (results.isEmpty) {
        return jsonEncode(
          {'message': 'Nessun esercizio trovato per "$query"'},
        );
      }

      final exercises = results
          .take(limit)
          .map(
            (ex) => {
              'name': ex.name,
              'muscles': ex.muscleGroups.take(3).toList(),
              'equipment':
                  ex.equipment.isNotEmpty ? ex.equipment.first : 'Nessuna',
              'imageUrl': ex.imageUrl,
            },
          )
          .toList();

      return jsonEncode({
        'exercises': exercises,
        'count': results.length,
        'showing': exercises.length,
      });
    } catch (e, st) {
      await h.recordToolError(e, st, reason: 'searchExercises failed');
      return jsonEncode({'error': '$e'});
    }
  }

  // ------------------------------------------------------------------
  // getAccessoryExercises
  // ------------------------------------------------------------------

  Future<String> getAccessoryExercises(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final rawExerciseName = args['exerciseName'] as String?;
    if (rawExerciseName == null || rawExerciseName.isEmpty) {
      return jsonEncode({
        'error': 'Missing exerciseName parameter',
        'toolName': 'getAccessoryExercises',
      });
    }

    final exerciseName = h.normalizeString(rawExerciseName);
    final limitRaw = args['limit'];
    final limit = (limitRaw is num ? limitRaw.toInt() : 8).clamp(1, 15);

    try {
      final mainResults = await exerciseSearchService.searchExercises(
        exerciseName,
        locale,
      );

      if (mainResults.isEmpty) {
        return jsonEncode({
          'error': 'Esercizio "$exerciseName" non trovato nel database',
          'suggestion': 'Prova con un nome diverso o più specifico',
          'toolName': 'getAccessoryExercises',
        });
      }

      final mainExercise = mainResults.first;
      final targetMuscles = mainExercise.muscleGroups;

      if (targetMuscles.isEmpty) {
        return jsonEncode({
          'error': 'Muscoli target non definiti per "$exerciseName"',
          'toolName': 'getAccessoryExercises',
        });
      }

      final primaryMuscle = targetMuscles.first;
      final accessoryResults = await exerciseSearchService.searchExercises(
        primaryMuscle,
        locale,
      );

      if (accessoryResults.isEmpty) {
        return jsonEncode({
          'mainExercise': mainExercise.name,
          'targetMuscles': targetMuscles,
          'accessories': <Map<String, dynamic>>[],
          'message':
              'Nessun esercizio accessorio trovato per $primaryMuscle',
          'toolName': 'getAccessoryExercises',
        });
      }

      final filteredResults = accessoryResults.where((ex) {
        final exNameLower = ex.name.toLowerCase();
        final mainNameLower = mainExercise.name.toLowerCase();
        if (exNameLower == mainNameLower) return false;
        if (h.areSimilarNames(exNameLower, mainNameLower)) return false;
        return true;
      }).toList();

      final diverseAccessories = h.selectDiverseExercises(
        filteredResults,
        limit,
      );

      final accessories = diverseAccessories.map((ex) {
        return {
          'name': ex.name,
          'muscles': ex.muscleGroups.take(3).toList(),
          'equipment':
              ex.equipment.isNotEmpty ? ex.equipment.first : 'Nessuna',
        };
      }).toList();

      return jsonEncode({
        'mainExercise': mainExercise.name,
        'targetMuscles': targetMuscles,
        'primaryMuscle': primaryMuscle,
        'accessories': accessories,
        'count': accessories.length,
        'note':
            'Tutti gli accessori lavorano gli stessi muscoli del principale',
        'toolName': 'getAccessoryExercises',
      });
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'AI Coach tool execution failed: getAccessoryExercises',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getAccessoryExercises',
      });
    }
  }

  // ------------------------------------------------------------------
  // searchScientificSources
  // ------------------------------------------------------------------

  Future<String> searchScientificSources(
    Map<String, dynamic> args,
    String userId,
  ) async {
    if (documentRepository == null) {
      return jsonEncode({
        'error': 'Archivio fonti non disponibile',
        'toolName': 'searchScientificSources',
      });
    }

    final query = (args['query'] as String?)?.trim();
    final category = (args['category'] as String?)?.trim();
    final requestedLimit = args['limit'];
    final limit =
        (requestedLimit is num ? requestedLimit.toInt() : 3).clamp(1, 5);

    if ((query == null || query.isEmpty) &&
        (category == null || category.isEmpty)) {
      return jsonEncode({
        'error': 'Specifica query o category',
        'toolName': 'searchScientificSources',
      });
    }

    final cacheKey =
        '${query?.toLowerCase() ?? ''}|${category?.toLowerCase() ?? ''}|$limit';
    final cached = _documentSearchCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) <=
            h.documentSearchCacheTtl) {
      return cached.payload;
    }

    try {
      final resultsEither = query != null && query.isNotEmpty
          ? await documentRepository!.searchDocuments(query)
          : await documentRepository!.getDocumentsByCategory(
              category!.toLowerCase(),
            );

      final payload = resultsEither.fold(
        (error) {
          return jsonEncode({
            'error': error,
            'toolName': 'searchScientificSources',
          });
        },
        (papers) {
          if (papers.isEmpty) {
            return jsonEncode({
              'message': 'Nessuna fonte scientifica trovata',
              if (query != null && query.isNotEmpty) 'query': query,
              if (category != null && category.isNotEmpty)
                'category': category,
              'count': 0,
              'toolName': 'searchScientificSources',
            });
          }

          final sources = papers.take(limit).map((paper) {
            return {
              'id': paper.id,
              'title': paper.title,
              'citation': paper.formatCitation(),
              'year': paper.year,
              'doi': paper.doi,
              'summary': paper.summary,
              'categories': paper.categories.take(3).toList(),
              'url': paper.url,
            };
          }).toList();

          return jsonEncode({
            if (query != null && query.isNotEmpty) 'query': query,
            if (category != null && category.isNotEmpty)
              'category': category,
            'sources': sources,
            'count': papers.length,
            'showing': sources.length,
            'toolName': 'searchScientificSources',
          });
        },
      );

      _documentSearchCache[cacheKey] = h.DocumentSearchCacheEntry(
        payload: payload,
        timestamp: DateTime.now(),
      );
      return payload;
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'searchScientificSources failed',
      );
      return jsonEncode({
        'error': e.toString(),
        'toolName': 'searchScientificSources',
      });
    }
  }
}
