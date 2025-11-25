/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Entità per i dati di distribuzione muscolare e statistiche aggregate
///
/// Usato in:
/// - Muscle Distribution Analytics Screen (radar chart)
/// - Progress tracking per gruppo muscolare
/// - Volume analysis per muscle group
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_distribution_data.freezed.dart';
part 'muscle_distribution_data.g.dart';

/// Gruppi muscolari principali trackati dall'app
///
/// Mappatura con wger.de muscle groups:
/// - Schiena → Lats, Traps, Lower Back
/// - Petto → Chest
/// - Addome → Abs
/// - Spalle → Shoulders, Delts
/// - Braccia → Biceps, Triceps, Forearms
/// - Gambe → Quads, Hamstrings, Glutes, Calves
enum MuscleGroup {
  @JsonValue('schiena')
  schiena,
  @JsonValue('petto')
  petto,
  @JsonValue('addome')
  addome,
  @JsonValue('spalle')
  spalle,
  @JsonValue('braccia')
  braccia,
  @JsonValue('gambe')
  gambe,
}

/// Extension per localizzazione nomi gruppi muscolari
extension MuscleGroupExtension on MuscleGroup {
  /// Nome visualizzato (IT)
  String get displayNameIT {
    switch (this) {
      case MuscleGroup.schiena:
        return 'Schiena';
      case MuscleGroup.petto:
        return 'Petto';
      case MuscleGroup.addome:
        return 'Addome';
      case MuscleGroup.spalle:
        return 'Spalle';
      case MuscleGroup.braccia:
        return 'Braccia';
      case MuscleGroup.gambe:
        return 'Gambe';
    }
  }

  /// Nome visualizzato (EN)
  String get displayNameEN {
    switch (this) {
      case MuscleGroup.schiena:
        return 'Back';
      case MuscleGroup.petto:
        return 'Chest';
      case MuscleGroup.addome:
        return 'Abs';
      case MuscleGroup.spalle:
        return 'Shoulders';
      case MuscleGroup.braccia:
        return 'Arms';
      case MuscleGroup.gambe:
        return 'Legs';
    }
  }

  /// Icona emoji per il gruppo muscolare
  String get emoji {
    switch (this) {
      case MuscleGroup.schiena:
        return '🦍'; // Gorilla back
      case MuscleGroup.petto:
        return '💪'; // Chest flex
      case MuscleGroup.addome:
        return '🔥'; // Core burn
      case MuscleGroup.spalle:
        return '🏔️'; // Mountain shoulders
      case MuscleGroup.braccia:
        return '💪'; // Arm flex
      case MuscleGroup.gambe:
        return '🦵'; // Leg
    }
  }
}

/// Periodo temporale per il filtro dei dati
enum TimePeriod {
  @JsonValue('last_7_days')
  last7Days,
  @JsonValue('last_30_days')
  last30Days,
  @JsonValue('last_90_days')
  last90Days,
  @JsonValue('last_6_months')
  last6Months,
  @JsonValue('last_year')
  lastYear,
  @JsonValue('all_time')
  allTime,
}

/// Extension per localizzazione periodi temporali
extension TimePeriodExtension on TimePeriod {
  /// Label visualizzata (IT)
  String get labelIT {
    switch (this) {
      case TimePeriod.last7Days:
        return 'Ultimi 7 giorni';
      case TimePeriod.last30Days:
        return 'Ultimi 30 giorni';
      case TimePeriod.last90Days:
        return 'Ultimi 90 giorni';
      case TimePeriod.last6Months:
        return 'Ultimi 6 mesi';
      case TimePeriod.lastYear:
        return 'Ultimo anno';
      case TimePeriod.allTime:
        return 'Sempre';
    }
  }

  /// Label visualizzata (EN)
  String get labelEN {
    switch (this) {
      case TimePeriod.last7Days:
        return 'Last 7 days';
      case TimePeriod.last30Days:
        return 'Last 30 days';
      case TimePeriod.last90Days:
        return 'Last 90 days';
      case TimePeriod.last6Months:
        return 'Last 6 months';
      case TimePeriod.lastYear:
        return 'Last year';
      case TimePeriod.allTime:
        return 'All time';
    }
  }

  /// Numero di giorni da sottrarre da oggi per calcolare la data di inizio
  /// null = nessun limite (all time)
  int? get days {
    switch (this) {
      case TimePeriod.last7Days:
        return 7;
      case TimePeriod.last30Days:
        return 30;
      case TimePeriod.last90Days:
        return 90;
      case TimePeriod.last6Months:
        return 180;
      case TimePeriod.lastYear:
        return 365;
      case TimePeriod.allTime:
        return null;
    }
  }
}

/// Dati di distribuzione muscolare per un periodo specifico
///
/// Contiene:
/// - Volume totale per gruppo muscolare (kg)
/// - Numero di serie per gruppo muscolare
/// - Percentuale di distribuzione (0-100%)
@freezed
class MuscleDistributionData with _$MuscleDistributionData {
  const factory MuscleDistributionData({
    /// Mappa gruppo muscolare → volume totale (kg)
    required Map<MuscleGroup, double> volumeByMuscle,

    /// Mappa gruppo muscolare → numero di serie
    required Map<MuscleGroup, int> setsByMuscle,

    /// Mappa gruppo muscolare → percentuale di volume (0-100)
    required Map<MuscleGroup, double> volumePercentage,

    /// Periodo temporale di riferimento
    required TimePeriod period,

    /// Data inizio periodo
    required DateTime startDate,

    /// Data fine periodo (tipicamente oggi)
    required DateTime endDate,
  }) = _MuscleDistributionData;

  factory MuscleDistributionData.fromJson(Map<String, dynamic> json) =>
      _$MuscleDistributionDataFromJson(json);

  /// Factory per creare dati vuoti (nessun allenamento nel periodo)
  factory MuscleDistributionData.empty(TimePeriod period) {
    final now = DateTime.now();
    final daysAgo = period.days;
    final startDate = daysAgo != null
        ? now.subtract(Duration(days: daysAgo))
        : DateTime(2020); // Data arbitraria per "all time"

    return MuscleDistributionData(
      volumeByMuscle: {
        for (var muscle in MuscleGroup.values) muscle: 0.0,
      },
      setsByMuscle: {
        for (var muscle in MuscleGroup.values) muscle: 0,
      },
      volumePercentage: {
        for (var muscle in MuscleGroup.values) muscle: 0.0,
      },
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }
}

/// Statistiche aggregate per il periodo (mostrate nelle card sotto il grafico)
@freezed
class PeriodStatistics with _$PeriodStatistics {
  const factory PeriodStatistics({
    /// Numero di allenamenti completati
    required int workoutsCount,

    /// Durata totale in minuti
    required int totalDurationMinutes,

    /// Volume totale sollevato (kg)
    required double totalVolumeKg,

    /// Numero totale di serie completate
    required int totalSets,

    /// Periodo di riferimento
    required TimePeriod period,

    /// Data inizio periodo
    required DateTime startDate,

    /// Data fine periodo
    required DateTime endDate,
  }) = _PeriodStatistics;

  factory PeriodStatistics.fromJson(Map<String, dynamic> json) =>
      _$PeriodStatisticsFromJson(json);

  /// Factory per statistiche vuote
  factory PeriodStatistics.empty(TimePeriod period) {
    final now = DateTime.now();
    final daysAgo = period.days;
    final startDate = daysAgo != null
        ? now.subtract(Duration(days: daysAgo))
        : DateTime(2020);

    return PeriodStatistics(
      workoutsCount: 0,
      totalDurationMinutes: 0,
      totalVolumeKg: 0.0,
      totalSets: 0,
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }
}

/// Dati completi per la schermata muscle distribution
///
/// Include:
/// - Distribuzione muscolare attuale (periodo selezionato)
/// - Distribuzione muscolare precedente (per confronto)
/// - Statistiche aggregate periodo attuale
/// - Statistiche aggregate periodo precedente
@freezed
class MuscleAnalyticsData with _$MuscleAnalyticsData {
  const factory MuscleAnalyticsData({
    /// Distribuzione muscolare periodo attuale
    required MuscleDistributionData current,

    /// Distribuzione muscolare periodo precedente (per confronto radar chart)
    required MuscleDistributionData previous,

    /// Statistiche aggregate periodo attuale
    required PeriodStatistics currentStats,

    /// Statistiche aggregate periodo precedente
    required PeriodStatistics previousStats,
  }) = _MuscleAnalyticsData;

  factory MuscleAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$MuscleAnalyticsDataFromJson(json);

  /// Factory per dati vuoti (nessun allenamento)
  factory MuscleAnalyticsData.empty(TimePeriod period) {
    return MuscleAnalyticsData(
      current: MuscleDistributionData.empty(period),
      previous: MuscleDistributionData.empty(period),
      currentStats: PeriodStatistics.empty(period),
      previousStats: PeriodStatistics.empty(period),
    );
  }
}
