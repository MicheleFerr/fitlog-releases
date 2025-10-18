/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 *
 * 📁 Layer: domain
 * 🎯 Feature: workout
 * 🔧 Type: entity
 * 🌍 Localization: N/A (enum)
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 *
 * Livelli di dettaglio per l'esportazione PDF dei template di workout.
 */

/// Livelli di dettaglio per la visualizzazione dei set nel PDF
enum PdfDetailLevel {
  /// Formato compatto: raggruppa set identici (es. "3 x 10")
  compact,

  /// Formato dettagliato con peso: mostra ogni set con peso e reps
  /// (es. "Set 1: 20kg x 10, Set 2: 22.5kg x 8")
  detailedWithWeight,

  /// Formato dettagliato senza peso: mostra ogni set solo con reps
  /// (es. "Set 1: 10 reps, Set 2: 8 reps")
  detailedWithoutWeight,
}

/// Extension per ottenere il nome salvato come stringa
extension PdfDetailLevelExtension on PdfDetailLevel {
  String get name {
    switch (this) {
      case PdfDetailLevel.compact:
        return 'compact';
      case PdfDetailLevel.detailedWithWeight:
        return 'detailedWithWeight';
      case PdfDetailLevel.detailedWithoutWeight:
        return 'detailedWithoutWeight';
    }
  }

  /// Parse da stringa a enum
  static PdfDetailLevel fromString(String value) {
    switch (value) {
      case 'compact':
        return PdfDetailLevel.compact;
      case 'detailedWithWeight':
        return PdfDetailLevel.detailedWithWeight;
      case 'detailedWithoutWeight':
        return PdfDetailLevel.detailedWithoutWeight;
      default:
        return PdfDetailLevel.compact; // Default fallback
    }
  }
}
