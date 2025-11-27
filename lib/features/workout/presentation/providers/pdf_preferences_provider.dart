/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A (provider)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Provider per gestire le preferenze di esportazione PDF dei template.
/// Salva e recupera il livello di dettaglio preferito dall'utente.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:flutter/foundation.dart';

/// Chiave per salvare la preferenza in SharedPreferences
const String _kPdfDetailLevelKey = 'pdf_detail_level_preference';

/// Provider per le preferenze di esportazione PDF
final pdfPreferencesProvider = NotifierProvider<PdfPreferencesNotifier, PdfDetailLevel?>(PdfPreferencesNotifier.new);

/// Notifier per gestire le preferenze PDF
class PdfPreferencesNotifier extends Notifier<PdfDetailLevel?> {
  @override
  PdfDetailLevel? build() {
    _loadPreference();
    return null;
  }

  /// Carica la preferenza salvata
  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString(_kPdfDetailLevelKey);

      if (savedValue != null) {
        state = PdfDetailLevelExtension.fromString(savedValue);
      }
    } catch (e) {
      // In caso di errore, mantieni null (nessuna preferenza salvata)
      if (kDebugMode) {
        debugPrint('Error loading PDF preference: $e');
      }
    }
  }

  /// Salva la preferenza dell'utente
  Future<void> savePreference(PdfDetailLevel level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPdfDetailLevelKey, level.name);
      state = level;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving PDF preference: $e');
      }
    }
  }

  /// Rimuove la preferenza salvata (per permettere di scegliere ogni volta)
  Future<void> clearPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPdfDetailLevelKey);
      state = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing PDF preference: $e');
      }
    }
  }
}
