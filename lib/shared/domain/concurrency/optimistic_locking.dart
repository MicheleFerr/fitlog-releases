/// 🏋️‍♂️ FitLog Pro - Flutter Fitness App
///
/// 📁 Layer: shared/domain/concurrency
/// 🎯 Feature: optimistic_locking
/// 🔧 Type: utility_mixin
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// **CRITICAL SECURITY COMPONENT**
/// Implements optimistic locking pattern to prevent data overwrites
/// Uses version field to detect concurrent modifications
///
/// **How It Works:**
/// 1. Read entity with version N
/// 2. User modifies entity
/// 3. Attempt update with version N
/// 4. Firestore checks: current version == N?
///    - YES: Update to version N+1 ✅
///    - NO: Throw OptimisticLockException ❌
///
/// **Example:**
/// ```dart
/// class Workout with OptimisticLockable {
///   final int version;
///   // ... other fields
/// }
///
/// // In repository:
/// try {
///   await updateWorkoutWithVersionCheck(workout);
/// } catch (e) {
///   if (e is OptimisticLockException) {
///     // Show user: "This workout was modified by another device"
///   }
/// }
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when optimistic lock fails
///
/// Indicates that the entity was modified by another client
/// between read and write operations
class OptimisticLockException implements Exception {
  const OptimisticLockException(this.message, {this.currentVersion, this.attemptedVersion});
  final String message;
  final int? currentVersion;
  final int? attemptedVersion;

  @override
  String toString() {
    if (currentVersion != null && attemptedVersion != null) {
      return 'OptimisticLockException: $message (current: $currentVersion, attempted: $attemptedVersion)';
    }
    return 'OptimisticLockException: $message';
  }
}

/// Mixin for entities that support optimistic locking
///
/// **Requirements:**
/// - Entity MUST have an `int version` field
/// - Initial version MUST be 0
/// - Version MUST increment on every update
mixin OptimisticLockable {
  /// Current version of the entity
  ///
  /// - Starts at 0 on creation
  /// - Increments by 1 on every successful update
  /// - Used to detect concurrent modifications
  int get version;

  /// Create a copy with incremented version
  ///
  /// Must be implemented by the entity class
  OptimisticLockable copyWithIncrementedVersion();
}

/// Service for atomic Firestore operations with optimistic locking
class FirestoreAtomicService {
  const FirestoreAtomicService(this._firestore);
  final FirebaseFirestore _firestore;

  /// Update document with optimistic locking using Firestore transaction
  ///
  /// **Atomicity Guarantee:**
  /// - Read + Version Check + Write happen atomically
  /// - No race conditions possible
  /// - Either ALL succeed or ALL fail
  ///
  /// **Parameters:**
  /// - [collectionPath]: Firestore collection path
  /// - [documentId]: Document ID to update
  /// - [data]: New data to write
  /// - [expectedVersion]: Expected current version (for optimistic lock)
  ///
  /// **Throws:**
  /// - [OptimisticLockException] if version mismatch detected
  /// - [FirebaseException] for other Firestore errors
  Future<void> updateWithVersionCheck({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    required int expectedVersion,
  }) async {
    final docRef = _firestore.collection(collectionPath).doc(documentId);

    try {
      await _firestore.runTransaction((transaction) async {
        // Read current document
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw OptimisticLockException('Document does not exist: $documentId');
        }

        // Check version
        final currentVersion = snapshot.data()?['version'] as int? ?? 0;

        if (currentVersion != expectedVersion) {
          throw OptimisticLockException(
            'Version mismatch detected. Document was modified by another client.',
            currentVersion: currentVersion,
            attemptedVersion: expectedVersion,
          );
        }

        // Version matches! Update with incremented version
        final updatedData = {
          ...data,
          'version': expectedVersion + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        transaction.update(docRef, updatedData);

        if (kDebugMode) {
          debugPrint('✅ [OptimisticLock] Updated $documentId: v$expectedVersion → v${expectedVersion + 1}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OptimisticLock] Failed to update $documentId: $e');
      }
      rethrow;
    }
  }

  /// Update multiple fields atomically in a single transaction
  ///
  /// **Use Case:**
  /// Update workout name, duration, and exercises in ONE atomic operation
  ///
  /// **Guarantee:**
  /// Either ALL fields update or NONE update
  Future<void> updateMultipleFieldsAtomically({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> fields,
    required int expectedVersion,
  }) async {
    await updateWithVersionCheck(
      collectionPath: collectionPath,
      documentId: documentId,
      data: fields,
      expectedVersion: expectedVersion,
    );
  }

  /// Batch update multiple documents atomically
  ///
  /// **Use Case:**
  /// - Update 10 workouts simultaneously
  /// - Completion flow: update workout + create analytics entry
  ///
  /// **Guarantee:**
  /// Either ALL documents update or NONE update
  ///
  /// **Limit:** Firestore batch limit is 500 operations
  Future<void> batchUpdateWithVersionCheck({
    required List<BatchUpdateOperation> operations,
  }) async {
    if (operations.isEmpty) return;

    if (operations.length > 500) {
      throw ArgumentError('Firestore batch limit is 500 operations. Got: ${operations.length}');
    }

    final batch = _firestore.batch();

    // First pass: Read all documents and check versions
    for (final op in operations) {
      final docRef = _firestore.collection(op.collectionPath).doc(op.documentId);
      final snapshot = await docRef.get();

      if (!snapshot.exists && op.requireExists) {
        throw OptimisticLockException('Document does not exist: ${op.documentId}');
      }

      if (op.expectedVersion != null) {
        final currentVersion = snapshot.data()?['version'] as int? ?? 0;
        if (currentVersion != op.expectedVersion) {
          throw OptimisticLockException(
            'Version mismatch in batch operation for ${op.documentId}',
            currentVersion: currentVersion,
            attemptedVersion: op.expectedVersion,
          );
        }
      }
    }

    // Second pass: All version checks passed, execute batch updates
    for (final op in operations) {
      final docRef = _firestore.collection(op.collectionPath).doc(op.documentId);

      final updatedData = {
        ...op.data,
        if (op.expectedVersion != null) 'version': op.expectedVersion! + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      batch.update(docRef, updatedData);
    }

    await batch.commit();

    if (kDebugMode) {
      debugPrint('✅ [OptimisticLock] Batch updated ${operations.length} documents atomically');
    }
  }
}

/// Represents a single operation in a batch update
class BatchUpdateOperation {
  const BatchUpdateOperation({
    required this.collectionPath,
    required this.documentId,
    required this.data,
    this.expectedVersion,
    this.requireExists = true,
  });

  final String collectionPath;
  final String documentId;
  final Map<String, dynamic> data;
  final int? expectedVersion;
  final bool requireExists;
}
