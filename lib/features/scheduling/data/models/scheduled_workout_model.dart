import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:hive_ce/hive.dart';

part 'scheduled_workout_model.g.dart';

/// Hive type ID for ScheduleStatusModel
/// Using 60-69 range for scheduling feature
@HiveType(typeId: 61)
enum ScheduleStatusModel {
  @HiveField(0)
  pending,

  @HiveField(1)
  due,

  @HiveField(2)
  completed,

  @HiveField(3)
  skipped,

  @HiveField(4)
  missed,
}

/// Extension to convert between ScheduleStatus and ScheduleStatusModel
extension ScheduleStatusModelExtension on ScheduleStatusModel {
  ScheduleStatus toEntity() {
    switch (this) {
      case ScheduleStatusModel.pending:
        return ScheduleStatus.pending;
      case ScheduleStatusModel.due:
        return ScheduleStatus.due;
      case ScheduleStatusModel.completed:
        return ScheduleStatus.completed;
      case ScheduleStatusModel.skipped:
        return ScheduleStatus.skipped;
      case ScheduleStatusModel.missed:
        return ScheduleStatus.missed;
    }
  }

  static ScheduleStatusModel fromEntity(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return ScheduleStatusModel.pending;
      case ScheduleStatus.due:
        return ScheduleStatusModel.due;
      case ScheduleStatus.completed:
        return ScheduleStatusModel.completed;
      case ScheduleStatus.skipped:
        return ScheduleStatusModel.skipped;
      case ScheduleStatus.missed:
        return ScheduleStatusModel.missed;
    }
  }
}

/// Hive model for ScheduledWorkout
/// Using typeId 62 for the scheduling feature range (60-69)
/// (60 was colliding with TutorialState, 61 is ScheduleStatusModel)
@HiveType(typeId: 62)
class ScheduledWorkoutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String templateId;

  @HiveField(2)
  final String templateName;

  @HiveField(3)
  final DateTime scheduledDate;

  @HiveField(4)
  final int reminderHour;

  @HiveField(5)
  final int reminderMinute;

  @HiveField(6)
  final ScheduleStatusModel status;

  @HiveField(7)
  final DateTime? completedAt;

  @HiveField(8)
  final DateTime? createdAt;

  @HiveField(9)
  final String? notificationId;

  ScheduledWorkoutModel({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.scheduledDate,
    required this.reminderHour,
    required this.reminderMinute,
    required this.status,
    this.completedAt,
    this.createdAt,
    this.notificationId,
  });

  /// Convert to domain entity
  ScheduledWorkout toEntity() {
    return ScheduledWorkout(
      id: id,
      templateId: templateId,
      templateName: templateName,
      scheduledDate: scheduledDate,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      status: status.toEntity(),
      completedAt: completedAt,
      createdAt: createdAt,
      notificationId: notificationId,
    );
  }

  /// Create from domain entity
  factory ScheduledWorkoutModel.fromEntity(ScheduledWorkout entity) {
    return ScheduledWorkoutModel(
      id: entity.id,
      templateId: entity.templateId,
      templateName: entity.templateName,
      scheduledDate: entity.scheduledDate,
      reminderHour: entity.reminderHour,
      reminderMinute: entity.reminderMinute,
      status: ScheduleStatusModelExtension.fromEntity(entity.status),
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      notificationId: entity.notificationId,
    );
  }

  /// Create a copy with updated fields
  ScheduledWorkoutModel copyWith({
    String? id,
    String? templateId,
    String? templateName,
    DateTime? scheduledDate,
    int? reminderHour,
    int? reminderMinute,
    ScheduleStatusModel? status,
    DateTime? completedAt,
    DateTime? createdAt,
    String? notificationId,
  }) {
    return ScheduledWorkoutModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
