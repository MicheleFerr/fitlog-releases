/// Template Report Repository
///
/// Handles reporting of community templates for moderation.
///
/// **Layer**: Data - Repository
/// **Feature**: workout_templates
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_report.dart';

class TemplateReportRepository {
  TemplateReportRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _reportsCollection =>
      _firestore.collection('template_reports');

  /// Submit a report for a template
  ///
  /// Throws if user already reported this template.
  Future<void> reportTemplate({
    required String templateId,
    required TemplateReportReason reason,
    String? details,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check for duplicate report
    final existing = await _reportsCollection
        .where('templateId', isEqualTo: templateId)
        .where('reporterId', isEqualTo: userId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already reported this template');
    }

    final doc = _reportsCollection.doc();
    final report = TemplateReport(
      id: doc.id,
      templateId: templateId,
      reporterId: userId,
      reason: reason,
      details: details,
      createdAt: DateTime.now(),
    );

    await doc.set(report.toJson());
  }

  /// Check if user has already reported a template
  Future<bool> hasReported(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final existing = await _reportsCollection
        .where('templateId', isEqualTo: templateId)
        .where('reporterId', isEqualTo: userId)
        .get();

    return existing.docs.isNotEmpty;
  }
}

// Provider
final templateReportRepositoryProvider =
    Provider<TemplateReportRepository>((ref) {
  return TemplateReportRepository();
});
