/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy_action.freezed.dart';
part 'buddy_action.g.dart';

/// Types of actions users can take on buddy profiles
enum BuddyActionType {
  like,
  superLike,
  pass,
  block,
  report;

  String get displayName {
    switch (this) {
      case BuddyActionType.like:
        return 'Mi piace';
      case BuddyActionType.superLike:
        return 'Super Like';
      case BuddyActionType.pass:
        return 'Passa oltre';
      case BuddyActionType.block:
        return 'Blocca';
      case BuddyActionType.report:
        return 'Segnala';
    }
  }

  String get emoji {
    switch (this) {
      case BuddyActionType.like:
        return '❤️';
      case BuddyActionType.superLike:
        return '⭐';
      case BuddyActionType.pass:
        return '👎';
      case BuddyActionType.block:
        return '🚫';
      case BuddyActionType.report:
        return '⚠️';
    }
  }
}

/// Report reasons for user safety
enum ReportReason {
  inappropriatePhotos,
  harassment,
  spam,
  fakeProfile,
  underage,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.inappropriatePhotos:
        return 'Foto inappropriate';
      case ReportReason.harassment:
        return 'Molestie o bullismo';
      case ReportReason.spam:
        return 'Spam o contenuto promozionale';
      case ReportReason.fakeProfile:
        return 'Profilo falso';
      case ReportReason.underage:
        return 'Minorenne';
      case ReportReason.other:
        return 'Altro';
    }
  }
}

@freezed
class BuddyAction with _$BuddyAction {
  const factory BuddyAction({
    required String id,
    required String fromUserId,
    required String toUserId,
    required BuddyActionType actionType,
    DateTime? createdAt,
    // For reports
    ReportReason? reportReason,
    String? reportDescription,
    // For super likes
    bool? wasSuperLike,
    // Matching result
    bool? resultedInMatch,
  }) = _BuddyAction;

  factory BuddyAction.fromJson(Map<String, dynamic> json) =>
      _$BuddyActionFromJson(json);

  /// Create from Firestore document
  factory BuddyAction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BuddyAction(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      actionType: BuddyActionType.values.firstWhere(
        (type) => type.name == data['actionType'],
        orElse: () => BuddyActionType.pass,
      ),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      reportReason: data['reportReason'] != null
          ? ReportReason.values.firstWhere(
              (reason) => reason.name == data['reportReason'],
              orElse: () => ReportReason.other,
            )
          : null,
      reportDescription: data['reportDescription'] as String?,
      wasSuperLike: data['wasSuperLike'] as bool?,
      resultedInMatch: data['resultedInMatch'] as bool?,
    );
  }
}

extension BuddyActionX on BuddyAction {
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'actionType': actionType.name,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (reportReason != null) 'reportReason': reportReason!.name,
      if (reportDescription != null) 'reportDescription': reportDescription,
      if (wasSuperLike != null) 'wasSuperLike': wasSuperLike,
      if (resultedInMatch != null) 'resultedInMatch': resultedInMatch,
    };
  }

  /// Check if this action is positive (like/super like)
  bool get isPositiveAction => 
      actionType == BuddyActionType.like || actionType == BuddyActionType.superLike;

  /// Check if this action is negative (pass/block/report)
  bool get isNegativeAction =>
      actionType == BuddyActionType.pass ||
      actionType == BuddyActionType.block ||
      actionType == BuddyActionType.report;

  /// Check if this is a report action
  bool get isReport => actionType == BuddyActionType.report;

  /// Check if this action prevents further matching
  bool get preventsMatching =>
      actionType == BuddyActionType.block || actionType == BuddyActionType.report;
}