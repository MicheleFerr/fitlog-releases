/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: NotifierProvider (Riverpod 2.x)
/// - Firebase: Through repository
/// - Hive: None
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

// State class
class TemplateState {

  TemplateState({
    this.userTemplates = const [],
    this.publicTemplates = const [],
    this.isLoading = false,
    this.error,
    this.templateReviews = const {},
    this.templateComments = const {},
  });
  final List<WorkoutTemplate> userTemplates;
  final List<WorkoutTemplate> publicTemplates;
  final bool isLoading;
  final String? error;
  final Map<String, List<TemplateReview>> templateReviews;
  final Map<String, List<TemplateComment>> templateComments;

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

// Notifier (Riverpod 2.x)
class TemplateNotifier extends Notifier<TemplateState> {

  late final TemplateRepository _repository;

  @override
  TemplateState build() {
    // FIX: Use ref.read() to avoid re-initialization on rebuild
    // Repository doesn't change, so we don't need to watch it
    _repository = ref.read(templateRepositoryProvider);

    // 🔧 FIX: Use ref.listen instead of ref.watch to avoid blocking build()
    // currentUserProvider is a StreamProvider<User?> that might be in loading state
    // Using ref.watch() causes _SelectorSubscription errors when stream is loading
    // ref.listen() reacts to user changes (login/logout) without blocking build
    ref.listen(currentUserProvider, (previous, next) {
      // Reload templates when user state changes (login/logout)
      next.whenData((_) {
        if (kDebugMode) {
          debugPrint('🔄 [TemplateProvider] User state changed, reloading templates');
        }
        loadUserTemplates();
      });
    });

    // Load user templates on initialization
    Future.microtask(() => loadUserTemplates());
    return TemplateState();
  }
  
  // Carica template dell'utente
  Future<void> loadUserTemplates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final templates = await _repository.getUserTemplates();
      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Loaded ${templates.length} user templates');
      }
      state = state.copyWith(
        userTemplates: templates,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error loading user templates: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
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
      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Loaded ${templates.length} public templates (category: $category, search: $searchQuery)');
      }
      state = state.copyWith(
        publicTemplates: templates,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error loading public templates: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Crea nuovo template
  Future<String?> createTemplate(WorkoutTemplate template) async {
    // Input validation
    if (template.name.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot create template with empty name');
      }
      state = state.copyWith(error: 'Template name cannot be empty');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // ✅ FIXED: Pass premium status to repository
      final isPremium = ref.read(isPremiumUserProvider);

      if (kDebugMode) {
        debugPrint('📝 [TemplateProvider] Creating template: ${template.name} (isPremium: $isPremium)');
      }

      final templateId = await _repository.createTemplate(template, isPremium: isPremium);

      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Template created with ID: $templateId');
      }

      // Ricarica template utente
      await loadUserTemplates();

      return templateId;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error creating template: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  // Download template pubblico
  Future<bool> downloadTemplate(String templateId) async {
    // Input validation
    if (templateId.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot download template with empty ID');
      }
      state = state.copyWith(error: 'Invalid template ID');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        debugPrint('📥 [TemplateProvider] Downloading template: $templateId');
      }

      await _repository.downloadTemplate(templateId);

      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Template downloaded successfully');
      }

      // Ricarica template utente per mostrare il nuovo
      await loadUserTemplates();

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error downloading template: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  // Aggiungi review
  Future<bool> addReview(TemplateReview review) async {
    // Input validation
    if (review.templateId.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot add review with empty template ID');
      }
      state = state.copyWith(error: 'Invalid template ID');
      return false;
    }

    if (review.rating < 1 || review.rating > 5) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Invalid rating: ${review.rating} (must be 1-5)');
      }
      state = state.copyWith(error: 'Rating must be between 1 and 5');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        debugPrint('⭐ [TemplateProvider] Adding review for template: ${review.templateId} (rating: ${review.rating})');
      }

      await _repository.addReview(review);

      // Aggiorna review locali
      final reviews = Map<String, List<TemplateReview>>.from(state.templateReviews);
      final templateReviews = reviews[review.templateId] ?? [];
      templateReviews.add(review);
      reviews[review.templateId] = templateReviews;

      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Review added successfully');
      }

      state = state.copyWith(
        templateReviews: reviews,
        isLoading: false,
      );

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error adding review: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  // Aggiungi commento
  Future<bool> addComment(TemplateComment comment) async {
    // Input validation
    if (comment.templateId.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot add comment with empty template ID');
      }
      state = state.copyWith(error: 'Invalid template ID');
      return false;
    }

    if (comment.text.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot add empty comment');
      }
      state = state.copyWith(error: 'Comment cannot be empty');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        debugPrint('💬 [TemplateProvider] Adding comment to template: ${comment.templateId}');
      }

      await _repository.addComment(comment);

      // Aggiorna commenti locali
      final comments = Map<String, List<TemplateComment>>.from(state.templateComments);
      final templateComments = comments[comment.templateId] ?? [];
      templateComments.add(comment);
      comments[comment.templateId] = templateComments;

      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Comment added successfully');
      }

      state = state.copyWith(
        templateComments: comments,
        isLoading: false,
      );

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error adding comment: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  // Toggle like
  Future<bool> toggleLike(String templateId) async {
    // Input validation
    if (templateId.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [TemplateProvider] Cannot toggle like with empty template ID');
      }
      state = state.copyWith(error: 'Invalid template ID');
      return false;
    }

    try {
      if (kDebugMode) {
        debugPrint('❤️ [TemplateProvider] Toggling like for template: $templateId');
      }

      await _repository.toggleTemplateLike(templateId);

      // Aggiorna template nella lista locale
      final publicTemplates = state.publicTemplates.map((t) {
        if (t.id == templateId) {
          // Toggle like count (approssimativo, verrà aggiornato dal server)
          return t.copyWith(likeCount: t.likeCount + 1);
        }
        return t;
      }).toList();

      if (kDebugMode) {
        debugPrint('✅ [TemplateProvider] Like toggled successfully');
      }

      state = state.copyWith(publicTemplates: publicTemplates);

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error toggling like: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  // Conta template disponibili per l'utente
  int getAvailableTemplateCount(TemplateVisibility visibility) {
    try {
      final userTemplateCount = state.userTemplates
          .where((t) => t.visibility == visibility)
          .length;

      // ✅ FIXED: Use actual premium check from provider
      final isPremium = ref.read(isPremiumUserProvider);

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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error calculating available template count: $e');
      }
      // Return 0 as safe fallback - prevents creating templates if error
      return 0;
    }
  }
}

// Provider (Riverpod 2.x)
final templateProvider = NotifierProvider<TemplateNotifier, TemplateState>(
  TemplateNotifier.new,
);