/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per le statistiche admin del sistema
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminStatsData {

  AdminStatsData({
    required this.pendingCorrections,
    required this.approvedCorrections,
    required this.rejectedCorrections,
    required this.totalUsers,
    this.lastUpdate,
  });

  factory AdminStatsData.empty() {
    return AdminStatsData(
      pendingCorrections: 0,
      approvedCorrections: 0,
      rejectedCorrections: 0,
      totalUsers: 0,
      lastUpdate: null,
    );
  }
  final int pendingCorrections;
  final int approvedCorrections;
  final int rejectedCorrections;
  final int totalUsers;
  final DateTime? lastUpdate;
}

final adminStatsProvider = FutureProvider<AdminStatsData>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Query per correzioni in pending
    final pendingQuery = await firestore
        .collection('exercise_corrections')
        .where('status', isEqualTo: 'pending')
        .get();

    // Query per correzioni approvate
    final approvedQuery = await firestore
        .collection('exercise_corrections')
        .where('status', isEqualTo: 'approved')
        .get();

    // Query per correzioni rifiutate
    final rejectedQuery = await firestore
        .collection('exercise_corrections')
        .where('status', isEqualTo: 'rejected')
        .get();

    // Query per conteggio utenti (limitiamo a 1000 per evitare problemi di performance)
    final usersQuery = await firestore
        .collection('users')
        .limit(1000)
        .get();

    // Calcola ultima attività
    DateTime? lastUpdate;
    if (pendingQuery.docs.isNotEmpty || approvedQuery.docs.isNotEmpty || rejectedQuery.docs.isNotEmpty) {
      final allDocs = [...pendingQuery.docs, ...approvedQuery.docs, ...rejectedQuery.docs];
      for (final doc in allDocs) {
        final data = doc.data();
        if (data.containsKey('createdAt')) {
          final timestamp = data['createdAt'];
          DateTime docDate;

          if (timestamp is Timestamp) {
            docDate = timestamp.toDate();
          } else if (timestamp is DateTime) {
            docDate = timestamp;
          } else {
            continue;
          }

          if (lastUpdate == null || docDate.isAfter(lastUpdate)) {
            lastUpdate = docDate;
          }
        }
      }
    }

    return AdminStatsData(
      pendingCorrections: pendingQuery.docs.length,
      approvedCorrections: approvedQuery.docs.length,
      rejectedCorrections: rejectedQuery.docs.length,
      totalUsers: usersQuery.docs.length,
      lastUpdate: lastUpdate,
    );
  } catch (e) {
    // In caso di errore, ritorna dati vuoti
    return AdminStatsData.empty();
  }
});

// Provider per statistiche in tempo reale
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final realtimeAdminStatsProvider = StreamProvider.autoDispose<AdminStatsData>((ref) {
  final firestore = FirebaseFirestore.instance;

  // Stream per le correzioni pending
  final pendingStream = firestore
      .collection('exercise_corrections')
      .where('status', isEqualTo: 'pending')
      .snapshots();

  return pendingStream.map((snapshot) {
    // Per semplicità, per ora ritorniamo solo il conteggio pending
    // In una implementazione completa, combineremmo più stream
    return AdminStatsData(
      pendingCorrections: snapshot.docs.length,
      approvedCorrections: 0, // Placeholder
      rejectedCorrections: 0, // Placeholder
      totalUsers: 0, // Placeholder
      lastUpdate: DateTime.now(),
    );
  });
});