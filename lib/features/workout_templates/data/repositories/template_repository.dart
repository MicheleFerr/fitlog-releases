/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data
 * 🎯 Feature: workout_templates
 * 🔧 Type: repository
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: Provider
 * - Firebase: Firestore
 * - Hive: None
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_template.dart';
import '../../../workout/domain/entities/exercise.dart';

class TemplateRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  TemplateRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;
  
  // Collections
  CollectionReference get _templatesCollection => 
      _firestore.collection('workout_templates');
  
  CollectionReference get _reviewsCollection => 
      _firestore.collection('template_reviews');
  
  CollectionReference get _commentsCollection => 
      _firestore.collection('template_comments');
  
  // CRUD Operations
  
  /// Crea un nuovo template
  Future<String> createTemplate(WorkoutTemplate template) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    // Controlla quota utente
    await _checkUserQuota(userId, template.visibility);
    
    final doc = _templatesCollection.doc();
    final newTemplate = template.copyWith(
      id: doc.id,
      userId: userId,
      createdAt: DateTime.now(),
      authorName: _auth.currentUser?.displayName,
      authorPhotoUrl: _auth.currentUser?.photoURL,
    );
    
    await doc.set(newTemplate.toJson());
    return doc.id;
  }
  
  /// Ottieni i template dell'utente corrente
  Future<List<WorkoutTemplate>> getUserTemplates() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    
    final snapshot = await _templatesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
  
  /// Ottieni template pubblici (con filtri)
  Future<List<WorkoutTemplate>> getPublicTemplates({
    TemplateCategory? category,
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
    int limit = 20,
  }) async {
    Query query = _templatesCollection
        .where('visibility', isEqualTo: TemplateVisibility.public.name);
    
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    
    if (difficultyLevel != null) {
      query = query.where('difficultyLevel', isEqualTo: difficultyLevel);
    }
    
    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }
    
    query = query.orderBy('downloadCount', descending: true).limit(limit);
    
    final snapshot = await query.get();
    
    var templates = snapshot.docs
        .map((doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    
    // Filtra per searchQuery se presente (client-side)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      templates = templates.where((t) => 
        t.name.toLowerCase().contains(lowerQuery) ||
        (t.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
      ).toList();
    }
    
    return templates;
  }
  
  /// Download/Copia template pubblico
  Future<void> downloadTemplate(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    // Ottieni il template
    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');
    
    final template = WorkoutTemplate.fromJson(templateDoc.data() as Map<String, dynamic>);
    
    // Crea una copia privata per l'utente
    final userCopy = template.copyWith(
      id: '', // Verrà generato nuovo ID
      userId: userId,
      visibility: TemplateVisibility.private,
      name: '${template.name} (Copy)',
      createdAt: DateTime.now(),
      downloadCount: 0,
      likeCount: 0,
      reviewCount: 0,
      averageRating: 0.0,
    );
    
    await createTemplate(userCopy);
    
    // Incrementa download count del template originale
    await _templatesCollection.doc(templateId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }
  
  /// Aggiungi review
  Future<void> addReview(TemplateReview review) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    // Controlla se l'utente ha già recensito
    final existing = await _reviewsCollection
        .where('templateId', isEqualTo: review.templateId)
        .where('userId', isEqualTo: userId)
        .get();
    
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already reviewed this template');
    }
    
    final doc = _reviewsCollection.doc();
    final newReview = review.copyWith(
      id: doc.id,
      userId: userId,
      userName: _auth.currentUser?.displayName ?? 'Anonymous',
      userPhotoUrl: _auth.currentUser?.photoURL,
      createdAt: DateTime.now(),
    );
    
    await doc.set(newReview.toJson());
    
    // Aggiorna statistiche template
    await _updateTemplateRating(review.templateId);
  }
  
  /// Aggiungi commento
  Future<void> addComment(TemplateComment comment) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    final doc = _commentsCollection.doc();
    final newComment = comment.copyWith(
      id: doc.id,
      userId: userId,
      userName: _auth.currentUser?.displayName ?? 'Anonymous',
      userPhotoUrl: _auth.currentUser?.photoURL,
      createdAt: DateTime.now(),
    );
    
    await doc.set(newComment.toJson());
  }
  
  /// Like/Unlike template
  Future<void> toggleTemplateLike(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    final templateRef = _templatesCollection.doc(templateId);
    
    await _firestore.runTransaction((transaction) async {
      final templateDoc = await transaction.get(templateRef);
      if (!templateDoc.exists) throw Exception('Template not found');
      
      final data = templateDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        transaction.update(templateRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(userId);
        transaction.update(templateRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }
  
  // Helper methods
  
  Future<void> _checkUserQuota(String userId, TemplateVisibility visibility) async {
    final userTemplates = await _templatesCollection
        .where('userId', isEqualTo: userId)
        .where('visibility', isEqualTo: visibility.name)
        .get();
    
    final count = userTemplates.docs.length;
    final isPremium = false; // TODO: Implementare check premium
    
    if (visibility == TemplateVisibility.private) {
      final limit = isPremium 
          ? TemplateQuota.maxPremiumPrivateTemplates 
          : TemplateQuota.maxPrivateTemplates;
      if (count >= limit) {
        throw Exception('You have reached the maximum number of private templates ($limit)');
      }
    } else if (visibility == TemplateVisibility.public) {
      final limit = isPremium 
          ? TemplateQuota.maxPremiumPublicTemplates 
          : TemplateQuota.maxPublicTemplates;
      if (count >= limit) {
        throw Exception('You have reached the maximum number of public templates ($limit)');
      }
    }
  }
  
  Future<void> _updateTemplateRating(String templateId) async {
    final reviews = await _reviewsCollection
        .where('templateId', isEqualTo: templateId)
        .get();
    
    if (reviews.docs.isEmpty) return;
    
    double totalRating = 0;
    for (var doc in reviews.docs) {
      final review = TemplateReview.fromJson(doc.data() as Map<String, dynamic>);
      totalRating += review.rating;
    }
    
    final averageRating = totalRating / reviews.docs.length;
    
    await _templatesCollection.doc(templateId).update({
      'reviewCount': reviews.docs.length,
      'averageRating': averageRating,
    });
  }
}

// Provider
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});