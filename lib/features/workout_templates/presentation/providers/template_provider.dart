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
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';

// State class
class TemplateState {
  TemplateState({
    this.userTemplates = const [],
    this.isLoading = false,
    this.error,
  });
  final List<WorkoutTemplate> userTemplates;
  final bool isLoading;
  final String? error;

  TemplateState copyWith({
    List<WorkoutTemplate>? userTemplates,
    bool? isLoading,
    String? error,
  }) {
    return TemplateState(
      userTemplates: userTemplates ?? this.userTemplates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
          debugPrint(
            '🔄 [TemplateProvider] User state changed, reloading templates',
          );
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
        debugPrint(
          '✅ [TemplateProvider] Loaded ${templates.length} user templates',
        );
      }
      state = state.copyWith(userTemplates: templates, isLoading: false);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error loading user templates: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Crea nuovo template
  Future<String?> createTemplate(WorkoutTemplate template) async {
    // Input validation
    if (template.name.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [TemplateProvider] Cannot create template with empty name',
        );
      }
      state = state.copyWith(error: 'Template name cannot be empty');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // GDPR: Check social consent before publishing public templates
      if (template.visibility == TemplateVisibility.public &&
          !template.isAnonymous) {
        final hasConsent = await ConsentService().hasSocialConsent();
        if (!hasConsent) {
          state = state.copyWith(isLoading: false);
          throw Exception('social_consent_required');
        }
      }

      // ✅ FIXED: Use consolidated tier entitlements (UserTier + AccountTier)
      final entitlements = ref.read(tierEntitlementsProvider);

      if (kDebugMode) {
        debugPrint(
          '📝 [TemplateProvider] Creating template: ${template.name} '
          '(maxPrivate: ${entitlements.maxTemplates}, maxPublic: ${entitlements.maxPublicTemplates})',
        );
      }

      final templateId = await _repository.createTemplate(
        template,
        maxPrivateTemplates: entitlements.maxTemplates,
        maxPublicTemplates: entitlements.maxPublicTemplates,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [TemplateProvider] Template created with ID: $templateId',
        );
      }

      // Ricarica template utente
      await loadUserTemplates();

      return templateId;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [TemplateProvider] Error creating template: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Conta template disponibili per l'utente
  int getAvailableTemplateCount(TemplateVisibility visibility) {
    try {
      final userTemplateCount = state.userTemplates
          .where((t) => t.visibility == visibility)
          .length;

      // ✅ FIXED: Use consolidated tier entitlements (UserTier + AccountTier)
      final entitlements = ref.read(tierEntitlementsProvider);

      if (visibility == TemplateVisibility.private) {
        return entitlements.maxTemplates - userTemplateCount;
      } else {
        return entitlements.maxPublicTemplates - userTemplateCount;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [TemplateProvider] Error calculating available template count: $e',
        );
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
