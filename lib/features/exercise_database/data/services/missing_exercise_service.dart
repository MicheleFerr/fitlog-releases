import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/missing_exercise_request.dart';

class MissingExerciseService {
  MissingExerciseService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collectionName = 'missing_exercise_requests';

  /// Submit a new missing exercise request
  Future<void> submitRequest({
    required String exerciseName,
    required String exerciseId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User must be authenticated to submit requests');
    }

    // Check if request already exists for this exercise name
    final existingRequest = await _firestore
        .collection(_collectionName)
        .where('exerciseName', isEqualTo: exerciseName)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      // Request already exists, no need to create duplicate
      return;
    }

    final request = MissingExerciseRequest(
      id: '', // Will be set by Firestore
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      userId: userId,
      requestedAt: DateTime.now(),
      status: RequestStatus.pending,
    );

    // Add to Firestore
    final docRef = await _firestore
        .collection(_collectionName)
        .add(request.toJson());

    // Update with document ID
    await docRef.update({'id': docRef.id});
  }

  /// Get all pending requests (admin only)
  Stream<List<MissingExerciseRequest>> getPendingRequests() {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MissingExerciseRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get all requests (admin only)
  Stream<List<MissingExerciseRequest>> getAllRequests() {
    return _firestore
        .collection(_collectionName)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MissingExerciseRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get requests by status (admin only)
  Stream<List<MissingExerciseRequest>> getRequestsByStatus(
    RequestStatus status,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: status.name)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MissingExerciseRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get user's requests
  Stream<List<MissingExerciseRequest>> getUserRequests() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MissingExerciseRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Update request status (admin only)
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    String? adminNotes,
  }) async {
    final adminUserId = _auth.currentUser?.uid;
    if (adminUserId == null) {
      throw Exception('Admin must be authenticated');
    }

    await _firestore.collection(_collectionName).doc(requestId).update({
      'status': status.name,
      'adminNotes': adminNotes,
      'reviewedAt': Timestamp.now(),
      'reviewedBy': adminUserId,
    });
  }

  /// Approve request (admin only)
  Future<void> approveRequest({
    required String requestId,
    String? notes,
  }) async {
    await updateRequestStatus(
      requestId: requestId,
      status: RequestStatus.approved,
      adminNotes: notes,
    );
  }

  /// Reject request (admin only)
  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    await updateRequestStatus(
      requestId: requestId,
      status: RequestStatus.rejected,
      adminNotes: reason,
    );
  }

  /// Mark request as completed (admin only)
  Future<void> markAsCompleted({
    required String requestId,
    String? notes,
  }) async {
    await updateRequestStatus(
      requestId: requestId,
      status: RequestStatus.completed,
      adminNotes: notes,
    );
  }

  /// Delete request (admin only)
  Future<void> deleteRequest(String requestId) async {
    await _firestore.collection(_collectionName).doc(requestId).delete();
  }

  /// Get request count by status (admin only)
  Future<Map<RequestStatus, int>> getRequestCounts() async {
    final counts = <RequestStatus, int>{};

    for (final status in RequestStatus.values) {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status.name)
          .count()
          .get();

      counts[status] = snapshot.count ?? 0;
    }

    return counts;
  }
}
