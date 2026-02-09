import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'gym_equipment_profile.g.dart';

/// Profile for gym equipment configuration (barbells and plates)
/// Allows users to save different configurations for different gyms
@HiveType(typeId: 110)
class GymEquipmentProfile {
  GymEquipmentProfile({
    required this.id,
    required this.name,
    this.defaultBarbellWeight = 20.0,
    this.availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new profile with generated ID
  factory GymEquipmentProfile.create({
    required String name,
    double? defaultBarbellWeight,
    List<double>? availablePlates,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return GymEquipmentProfile(
      id: const Uuid().v4(),
      name: name,
      defaultBarbellWeight: defaultBarbellWeight ?? 20.0,
      availablePlates: availablePlates ?? const [25, 20, 15, 10, 5, 2.5, 1.25],
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create default profile from existing AppConfig availablePlates
  factory GymEquipmentProfile.createDefault({
    List<double>? availablePlates,
  }) {
    final now = DateTime.now();
    return GymEquipmentProfile(
      id: 'default_profile',
      name: 'Default',
      defaultBarbellWeight: 20.0,
      availablePlates: availablePlates ?? const [25, 20, 15, 10, 5, 2.5, 1.25],
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// Default barbell weight in kg. Null means "no barbell" option
  @HiveField(2)
  final double? defaultBarbellWeight;

  /// List of available plate weights in kg, sorted descending
  @HiveField(3)
  final List<double> availablePlates;

  /// Whether this is the default profile
  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  /// Standard plate set used in most gyms
  static const List<double> standardPlates = [25, 20, 15, 10, 5, 2.5, 1.25];

  /// All possible plates including less common ones
  static const List<double> allPlates = [25, 20, 15, 10, 5, 2.5, 1.25, 0.5];

  /// Common barbell weights for quick selection
  static const List<BarbellOption> commonBarbells = [
    BarbellOption(label: '20kg', weight: 20.0),
    BarbellOption(label: '15kg', weight: 15.0),
    BarbellOption(label: 'No', weight: null),
    BarbellOption(label: 'EZ 7.5', weight: 7.5),
  ];

  GymEquipmentProfile copyWith({
    String? name,
    double? defaultBarbellWeight,
    bool clearBarbellWeight = false,
    List<double>? availablePlates,
    bool? isDefault,
  }) {
    return GymEquipmentProfile(
      id: id,
      name: name ?? this.name,
      defaultBarbellWeight: clearBarbellWeight
          ? null
          : (defaultBarbellWeight ?? this.defaultBarbellWeight),
      availablePlates: availablePlates ?? this.availablePlates,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GymEquipmentProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GymEquipmentProfile{id: $id, name: $name, barbell: $defaultBarbellWeight, plates: ${availablePlates.length}, default: $isDefault}';
  }
}

/// Barbell option for quick selection
class BarbellOption {
  const BarbellOption({
    required this.label,
    required this.weight,
  });

  final String label;
  final double? weight; // null = no barbell
}
