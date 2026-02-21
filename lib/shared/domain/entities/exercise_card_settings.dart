import 'package:hive_ce_flutter/hive_flutter.dart';

part 'exercise_card_settings.g.dart';

/// GIF size options for Exercise Card
/// Controls the size of the exercise GIF/image in the card header
@HiveType(typeId: 120)
enum ExerciseGifSize {
  /// Small GIF (40x40)
  /// Use case: Maximum information density
  @HiveField(0)
  small(size: 40, label: 'Small'),

  /// Medium GIF (56x56, default)
  /// Use case: Balanced view
  @HiveField(1)
  medium(size: 56, label: 'Medium'),

  /// Large GIF (72x72)
  /// Use case: Better visibility of exercise form
  @HiveField(2)
  large(size: 72, label: 'Large'),

  /// Hidden - no GIF shown
  /// Use case: Maximum space efficiency
  @HiveField(3)
  hidden(size: 0, label: 'Hidden');

  const ExerciseGifSize({
    required this.size,
    required this.label,
  });

  final double size;
  final String label;

  String toJson() => name;

  static ExerciseGifSize fromJson(String json) {
    return ExerciseGifSize.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ExerciseGifSize.medium,
    );
  }
}

/// Card density options for Exercise Card
/// Controls vertical spacing and padding
@HiveType(typeId: 121)
enum ExerciseCardDensity {
  /// Compact density
  /// Reduced padding, tighter spacing
  /// Use case: Power users who want to see more sets at once
  @HiveField(0)
  compact(
    verticalPadding: 8,
    horizontalPadding: 12,
    sectionSpacing: 4,
    label: 'Compact',
  ),

  /// Standard density (default)
  /// Balanced padding and spacing
  /// Use case: Most users
  @HiveField(1)
  standard(
    verticalPadding: 12,
    horizontalPadding: 16,
    sectionSpacing: 8,
    label: 'Standard',
  ),

  /// Extended density
  /// More breathing room, larger touch targets
  /// Use case: Users who prefer larger UI elements
  @HiveField(2)
  extended(
    verticalPadding: 16,
    horizontalPadding: 20,
    sectionSpacing: 12,
    label: 'Extended',
  );

  const ExerciseCardDensity({
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.sectionSpacing,
    required this.label,
  });

  final double verticalPadding;
  final double horizontalPadding;
  final double sectionSpacing;
  final String label;

  String toJson() => name;

  static ExerciseCardDensity fromJson(String json) {
    return ExerciseCardDensity.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ExerciseCardDensity.standard,
    );
  }
}

/// Footer element options for Exercise Card
/// Elements that can be shown in the collapsible footer
@HiveType(typeId: 103)
enum ExerciseFooterElement {
  /// Tips/coaching hints
  @HiveField(0)
  tips('Tips'),

  /// Time Under Tension info
  @HiveField(1)
  tut('TUT'),

  /// Exercise notes
  @HiveField(2)
  notes('Notes');

  const ExerciseFooterElement(this.label);

  final String label;

  String toJson() => name;

  static ExerciseFooterElement fromJson(String json) {
    return ExerciseFooterElement.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ExerciseFooterElement.notes,
    );
  }
}

/// Exercise Card Settings
///
/// Controls the visual appearance and information density of exercise cards
/// during workout sessions. Users can customize which elements are visible
/// and how compact the card layout is.
///
/// Persona Impact Analysis:
/// - Marco (Beginner): ✅ Can hide advanced info (TUT, Insight) to reduce overwhelm
/// - Chiara (Multitask): ✅ Compact mode + hidden GIF = faster scrolling
/// - Luca (Powerlifter): ✅ All info visible, extended density for touch accuracy
/// - Sofia (Aesthetic): ✅ Clean look with minimal footer elements
/// - Roberto (Busy): ✅ Compact + essential info only = efficiency
@HiveType(typeId: 104)
class ExerciseCardSettings {
  const ExerciseCardSettings({
    this.gifSize = ExerciseGifSize.medium,
    this.density = ExerciseCardDensity.standard,
    this.showInsight = true,
    this.showTimer = true,
    this.showPlates = true,
    this.showRpe = true,
    this.footerElements = const [
      ExerciseFooterElement.tips,
      ExerciseFooterElement.tut,
      ExerciseFooterElement.notes,
    ],
    this.footerExpanded = false,
  });

  factory ExerciseCardSettings.fromJson(Map<String, dynamic> json) {
    return ExerciseCardSettings(
      gifSize: ExerciseGifSize.fromJson(json['gifSize'] ?? 'medium'),
      density: ExerciseCardDensity.fromJson(json['density'] ?? 'standard'),
      showInsight: json['showInsight'] ?? true,
      showTimer: json['showTimer'] ?? true,
      showPlates: json['showPlates'] ?? true,
      showRpe: json['showRpe'] ?? true,
      footerElements: (json['footerElements'] as List<dynamic>?)
              ?.map((e) => ExerciseFooterElement.fromJson(e as String))
              .toList() ??
          const [
            ExerciseFooterElement.tips,
            ExerciseFooterElement.tut,
            ExerciseFooterElement.notes,
          ],
      footerExpanded: json['footerExpanded'] ?? false,
    );
  }

  /// GIF display size
  @HiveField(0)
  final ExerciseGifSize gifSize;

  /// Card density/spacing
  @HiveField(1)
  final ExerciseCardDensity density;

  /// Show performance insight inline with exercise name
  @HiveField(2)
  final bool showInsight;

  /// Show rest timer badge in header
  @HiveField(3)
  final bool showTimer;

  /// Show plate calculator section
  @HiveField(4)
  final bool showPlates;

  /// Show RPE input on sets
  @HiveField(5)
  final bool showRpe;

  /// Elements to show in the footer
  @HiveField(6)
  final List<ExerciseFooterElement> footerElements;

  /// Whether footer is expanded by default
  @HiveField(7)
  final bool footerExpanded;

  /// Convenience getter: is GIF visible?
  bool get showGif => gifSize != ExerciseGifSize.hidden;

  /// Convenience getter: has any footer elements?
  bool get hasFooter => footerElements.isNotEmpty;

  ExerciseCardSettings copyWith({
    ExerciseGifSize? gifSize,
    ExerciseCardDensity? density,
    bool? showInsight,
    bool? showTimer,
    bool? showPlates,
    bool? showRpe,
    List<ExerciseFooterElement>? footerElements,
    bool? footerExpanded,
  }) {
    return ExerciseCardSettings(
      gifSize: gifSize ?? this.gifSize,
      density: density ?? this.density,
      showInsight: showInsight ?? this.showInsight,
      showTimer: showTimer ?? this.showTimer,
      showPlates: showPlates ?? this.showPlates,
      showRpe: showRpe ?? this.showRpe,
      footerElements: footerElements ?? this.footerElements,
      footerExpanded: footerExpanded ?? this.footerExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gifSize': gifSize.toJson(),
      'density': density.toJson(),
      'showInsight': showInsight,
      'showTimer': showTimer,
      'showPlates': showPlates,
      'showRpe': showRpe,
      'footerElements': footerElements.map((e) => e.toJson()).toList(),
      'footerExpanded': footerExpanded,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExerciseCardSettings) return false;
    return gifSize == other.gifSize &&
        density == other.density &&
        showInsight == other.showInsight &&
        showTimer == other.showTimer &&
        showPlates == other.showPlates &&
        showRpe == other.showRpe &&
        _listEquals(footerElements, other.footerElements) &&
        footerExpanded == other.footerExpanded;
  }

  @override
  int get hashCode {
    return Object.hash(
      gifSize,
      density,
      showInsight,
      showTimer,
      showPlates,
      showRpe,
      Object.hashAll(footerElements),
      footerExpanded,
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Preset configurations for different user personas
class ExerciseCardPresets {
  /// Default settings - balanced for most users
  static const ExerciseCardSettings defaultSettings = ExerciseCardSettings();

  /// Beginner settings (Marco persona)
  /// - Hide insight (confusing for beginners)
  /// - Show notes and tips for guidance
  /// - Standard density for comfortable tapping
  static const ExerciseCardSettings beginnerSettings = ExerciseCardSettings(
    gifSize: ExerciseGifSize.large,
    density: ExerciseCardDensity.standard,
    showInsight: false,
    showTimer: true,
    showPlates: true,
    showRpe: false,
    footerElements: [
      ExerciseFooterElement.tips,
      ExerciseFooterElement.notes,
    ],
    footerExpanded: true,
  );

  /// Power user settings (Luca persona)
  /// - All info visible
  /// - Include TUT for advanced tracking
  /// - Extended density for touch accuracy with callused hands
  static const ExerciseCardSettings powerUserSettings = ExerciseCardSettings(
    gifSize: ExerciseGifSize.small,
    density: ExerciseCardDensity.extended,
    showInsight: true,
    showTimer: true,
    showPlates: true,
    showRpe: true,
    footerElements: [
      ExerciseFooterElement.tips,
      ExerciseFooterElement.tut,
      ExerciseFooterElement.notes,
    ],
    footerExpanded: false,
  );

  /// Efficient settings (Chiara/Roberto persona)
  /// - Compact for quick viewing
  /// - Essential info only
  /// - No footer for speed
  static const ExerciseCardSettings efficientSettings = ExerciseCardSettings(
    gifSize: ExerciseGifSize.hidden,
    density: ExerciseCardDensity.compact,
    showInsight: true,
    showTimer: true,
    showPlates: false,
    showRpe: true,
    footerElements: [],
    footerExpanded: false,
  );

  /// Minimal settings (Sofia persona)
  /// - Clean, aesthetic look
  /// - Only essential elements
  static const ExerciseCardSettings minimalSettings = ExerciseCardSettings(
    gifSize: ExerciseGifSize.medium,
    density: ExerciseCardDensity.standard,
    showInsight: false,
    showTimer: true,
    showPlates: false,
    showRpe: false,
    footerElements: [ExerciseFooterElement.notes],
    footerExpanded: false,
  );
}
