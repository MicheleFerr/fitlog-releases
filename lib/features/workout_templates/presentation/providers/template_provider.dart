/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout_templates
 * 🔧 Type: provider
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: StateNotifierProvider
 * - Firebase: Through repository
 * - Hive: None
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_template.dart';
import '../../data/repositories/template_repository.dart';

// State class
class TemplateState {
  final List<WorkoutTemplate> userTemplates;
  final List<WorkoutTemplate> publicTemplates;
  final bool isLoading;
  final String? error;
  final Map<String, List<TemplateReview>> templateReviews;
  final Map<String, List<TemplateComment>> templateComments;
  
  TemplateState({
    this.userTemplates = const [],
    this.publicTemplates = const [],
    this.isLoading = false,
    this.error,
    this.templateReviews = const {},
    this.templateComments = const {},
  });
  
  TemplateState copyWith({
    List<WorkoutTemplate>? userTemplates,
    List<WorkoutTemplate>? publicTemplates,
    bool? isLoading,
    String? error,
    Map<String, List<TemplateReview>>? templateReviews,
    Map<String, List<TemplateComment>>? templateComments,
  }) {
    return TemplateState(
      userTemplates: userTemplates ?? this.userTemplates,
      publicTemplates: publicTemplates ?? this.publicTemplates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      templateReviews: templateReviews ?? this.templateReviews,
      templateComments: templateComments ?? this.templateComments,
    );
  }
}

// Notifier
class TemplateNotifier extends StateNotifier<TemplateState> {
  final TemplateRepository _repository;
  
  TemplateNotifier(this._repository) : super(TemplateState()) {
    loadUserTemplates();
  }
  
  // Carica template dell'utente
  Future<void> loadUserTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final templates = await _repository.getUserTemplates();
      state = state.copyWith(
        userTemplates: templates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Carica template pubblici
  Future<void> loadPublicTemplates({
    TemplateCategory? category,
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final templates = await _repository.getPublicTemplates(
        category: category,
        searchQuery: searchQuery,
        tags: tags,
        difficultyLevel: difficultyLevel,
      );
      state = state.copyWith(
        publicTemplates: templates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Crea nuovo template
  Future<String?> createTemplate(WorkoutTemplate template) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final templateId = await _repository.createTemplate(template);
      
      // Ricarica template utente
      await loadUserTemplates();
      
      return templateId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  // Download template pubblico
  Future<bool> downloadTemplate(String templateId) async {
    try {
      await _repository.downloadTemplate(templateId);
      
      // Ricarica template utente per mostrare il nuovo
      await loadUserTemplates();
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  // Aggiungi review
  Future<bool> addReview(TemplateReview review) async {
    try {
      await _repository.addReview(review);
      
      // Aggiorna review locali
      final reviews = Map<String, List<TemplateReview>>.from(state.templateReviews);
      final templateReviews = reviews[review.templateId] ?? [];
      templateReviews.add(review);
      reviews[review.templateId] = templateReviews;
      
      state = state.copyWith(templateReviews: reviews);
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  // Aggiungi commento
  Future<bool> addComment(TemplateComment comment) async {
    try {
      await _repository.addComment(comment);
      
      // Aggiorna commenti locali
      final comments = Map<String, List<TemplateComment>>.from(state.templateComments);
      final templateComments = comments[comment.templateId] ?? [];
      templateComments.add(comment);
      comments[comment.templateId] = templateComments;
      
      state = state.copyWith(templateComments: comments);
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  // Toggle like
  Future<bool> toggleLike(String templateId) async {
    try {
      await _repository.toggleTemplateLike(templateId);
      
      // Aggiorna template nella lista locale
      final publicTemplates = state.publicTemplates.map((t) {
        if (t.id == templateId) {
          // Toggle like count (approssimativo, verrà aggiornato dal server)
          return t.copyWith(likeCount: t.likeCount + 1);
        }
        return t;
      }).toList();
      
      state = state.copyWith(publicTemplates: publicTemplates);
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  // Conta template disponibili per l'utente
  int getAvailableTemplateCount(TemplateVisibility visibility) {
    final userTemplateCount = state.userTemplates
        .where((t) => t.visibility == visibility)
        .length;
    
    final isPremium = false; // TODO: Implementare check premium
    
    if (visibility == TemplateVisibility.private) {
      final limit = isPremium 
          ? TemplateQuota.maxPremiumPrivateTemplates 
          : TemplateQuota.maxPrivateTemplates;
      return limit - userTemplateCount;
    } else {
      final limit = isPremium 
          ? TemplateQuota.maxPremiumPublicTemplates 
          : TemplateQuota.maxPublicTemplates;
      return limit - userTemplateCount;
    }
  }
}

// Provider
final templateProvider = StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return TemplateNotifier(repository);
});