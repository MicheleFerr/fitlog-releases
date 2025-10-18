import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending,
  approved,
  rejected,
  completed,
}

class MissingExerciseRequest {

  const MissingExerciseRequest({
    required this.id,
    required this.exerciseName,
    required this.exerciseId,
    required this.userId,
    required this.requestedAt,
    this.status = RequestStatus.pending,
    this.adminNotes,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory MissingExerciseRequest.fromJson(Map<String, dynamic> json) {
    return MissingExerciseRequest(
      id: json['id'] as String,
      exerciseName: json['exerciseName'] as String,
      exerciseId: json['exerciseId'] as String,
      userId: json['userId'] as String,
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      adminNotes: json['adminNotes'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? (json['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewedBy: json['reviewedBy'] as String?,
    );
  }
  final String id;
  final String exerciseName;
  final String exerciseId;
  final String userId;
  final DateTime requestedAt;
  final RequestStatus status;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
      'userId': userId,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status.name,
      'adminNotes': adminNotes,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
    };
  }

  MissingExerciseRequest copyWith({
    String? id,
    String? exerciseName,
    String? exerciseId,
    String? userId,
    DateTime? requestedAt,
    RequestStatus? status,
    String? adminNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return MissingExerciseRequest(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseId: exerciseId ?? this.exerciseId,
      userId: userId ?? this.userId,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
