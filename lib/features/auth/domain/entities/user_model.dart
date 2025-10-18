import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    required this.isGuest,
    required this.preferences,
    required this.stats,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null for user: ${doc.id}');
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'GymBro User',
      photoURL: data['photoURL'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isGuest: data['isGuest'] as bool? ?? false,
      preferences: UserPreferences.fromMap(
        (data['preferences'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      stats: UserStats.fromMap(
        (data['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
    );
  }

  /// Alternative factory for creating from a DocumentSnapshot with generic data
  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null for user: ${doc.id}');
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'GymBro User',
      photoURL: data['photoURL'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isGuest: data['isGuest'] as bool? ?? false,
      preferences: UserPreferences.fromMap(
        (data['preferences'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
      stats: UserStats.fromMap(
        (data['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{}
      ),
    );
  }
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isGuest;
  final UserPreferences preferences;
  final UserStats stats;

  Map<String, dynamic> toFirestore({bool useServerTimestamp = true}) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': _mapTimestamp(createdAt, useServerTimestamp),
      'lastLoginAt': _mapTimestamp(lastLoginAt, useServerTimestamp),
      'isGuest': isGuest,
      'preferences': preferences.toMap(),
      'stats': stats.toMap(),
    };
  }

  /// Helper method to handle timestamp mapping with null safety
  dynamic _mapTimestamp(DateTime? dateTime, bool useServerTimestamp) {
    if (dateTime != null) {
      return Timestamp.fromDate(dateTime);
    }
    return useServerTimestamp ? FieldValue.serverTimestamp() : null;
  }

  /// Converts to a map suitable for updates (excludes uid)
  Map<String, dynamic> toFirestoreUpdate({bool useServerTimestamp = false}) {
    final data = toFirestore(useServerTimestamp: useServerTimestamp);
    data.remove('uid'); // Don't update the uid field
    return data;
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isGuest,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isGuest: isGuest ?? this.isGuest,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }

  /// Validates the user model data
  bool get isValid {
    return uid.isNotEmpty && 
           email.isNotEmpty && 
           displayName.isNotEmpty;
  }

  /// Returns a string representation for debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
           'isGuest: $isGuest, createdAt: $createdAt)';
  }

  /// Equality operator for comparing UserModel instances
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
           other.uid == uid &&
           other.email == email &&
           other.displayName == displayName &&
           other.photoURL == photoURL &&
           other.createdAt == createdAt &&
           other.lastLoginAt == lastLoginAt &&
           other.isGuest == isGuest &&
           other.preferences == preferences &&
           other.stats == stats;
  }

  /// Hash code for the UserModel
  @override
  int get hashCode {
    return uid.hashCode ^
           email.hashCode ^
           displayName.hashCode ^
           (photoURL?.hashCode ?? 0) ^
           (createdAt?.hashCode ?? 0) ^
           (lastLoginAt?.hashCode ?? 0) ^
           isGuest.hashCode ^
           preferences.hashCode ^
           stats.hashCode;
  }
}

class UserPreferences {

  const UserPreferences({
    this.units = 'kg',
    this.restTimerSound = true,
    this.notifications = true,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      units: map['units'] as String? ?? 'kg',
      restTimerSound: map['restTimerSound'] as bool? ?? true,
      notifications: map['notifications'] as bool? ?? true,
    );
  }
  final String units; // 'kg' or 'lbs'
  final bool restTimerSound;
  final bool notifications;

  Map<String, dynamic> toMap() {
    return {
      'units': units,
      'restTimerSound': restTimerSound,
      'notifications': notifications,
    };
  }

  UserPreferences copyWith({
    String? units,
    bool? restTimerSound,
    bool? notifications,
  }) {
    return UserPreferences(
      units: units ?? this.units,
      restTimerSound: restTimerSound ?? this.restTimerSound,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
           other.units == units &&
           other.restTimerSound == restTimerSound &&
           other.notifications == notifications;
  }

  @override
  int get hashCode {
    return units.hashCode ^ restTimerSound.hashCode ^ notifications.hashCode;
  }

  @override
  String toString() {
    return 'UserPreferences(units: $units, restTimerSound: $restTimerSound, notifications: $notifications)';
  }
}

class UserStats {

  const UserStats({
    this.totalWorkouts = 0,
    this.totalExercises = 0,
    this.totalVolume = 0.0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalWorkouts: map['totalWorkouts'] as int? ?? 0,
      totalExercises: map['totalExercises'] as int? ?? 0,
      totalVolume: (map['totalVolume'] as num?)?.toDouble() ?? 0.0,
    );
  }
  final int totalWorkouts;
  final int totalExercises;
  final double totalVolume;

  Map<String, dynamic> toMap() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalVolume': totalVolume,
    };
  }

  UserStats copyWith({
    int? totalWorkouts,
    int? totalExercises,
    double? totalVolume,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalExercises: totalExercises ?? this.totalExercises,
      totalVolume: totalVolume ?? this.totalVolume,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
           other.totalWorkouts == totalWorkouts &&
           other.totalExercises == totalExercises &&
           other.totalVolume == totalVolume;
  }

  @override
  int get hashCode {
    return totalWorkouts.hashCode ^ totalExercises.hashCode ^ totalVolume.hashCode;
  }

  @override
  String toString() {
    return 'UserStats(totalWorkouts: $totalWorkouts, totalExercises: $totalExercises, totalVolume: $totalVolume)';
  }
}