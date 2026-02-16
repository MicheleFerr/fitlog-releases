import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/firebase_workout_template_repository.dart';
import 'package:flutter/foundation.dart';

/// Provider specifico per Firebase template con sincronizzazione automatica
final firebaseTemplateRepositoryProvider =
    Provider<FirebaseWorkoutTemplateRepository>((ref) {
      return FirebaseWorkoutTemplateRepository();
    });

/// Auth state listener per gestire sync automatico
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Template stream dal cloud (real-time)
final firebaseTemplatesStreamProvider =
    StreamProvider.autoDispose<List<WorkoutTemplate>>((ref) {
      final repository = ref.watch(firebaseTemplateRepositoryProvider);
      return repository.templatesStream();
    });

/// Provider per sincronizzazione automatica
final templateSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  final user = await ref.watch(authStateProvider.future);

  if (user != null) {
    final repository = ref.read(firebaseTemplateRepositoryProvider);

    // Inizializza template predefiniti se necessario
    await repository.initializePredefinedTemplates();

    // Verifica se è necessario un sync
    final needsSync = await repository.needsSync();
    if (needsSync) {
      await repository.syncWithCloud();
    }

    // Processa sync in sospeso (offline changes)
    await repository.processPendingSync();
  }
});

/// Notifier per gestione Firebase template con sync intelligente
final firebaseTemplateNotifierProvider =
    NotifierProvider<FirebaseTemplateNotifier, FirebaseTemplateState>(
      FirebaseTemplateNotifier.new,
    );

class FirebaseTemplateState {
  const FirebaseTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.lastSyncTime,
    this.hasOfflineChanges = false,
  });
  final List<WorkoutTemplate> templates;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final DateTime? lastSyncTime;
  final bool hasOfflineChanges;

  FirebaseTemplateState copyWith({
    List<WorkoutTemplate>? templates,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    DateTime? lastSyncTime,
    bool? hasOfflineChanges,
  }) {
    return FirebaseTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      hasOfflineChanges: hasOfflineChanges ?? this.hasOfflineChanges,
    );
  }
}

class FirebaseTemplateNotifier extends Notifier<FirebaseTemplateState> {
  late final FirebaseWorkoutTemplateRepository _repository;

  @override
  FirebaseTemplateState build() {
    _initialize();
    return const FirebaseTemplateState();
  }

  void _initialize() async {
    _repository = ref.read(firebaseTemplateRepositoryProvider);

    // Ascolta cambiamenti di autenticazione
    // ⚠️ NOTE: No debounce needed - auth state changes are rare (login/logout)
    // Debouncing would delay critical sync operations after authentication
    ref.listen(authStateProvider, (previous, next) async {
      if (next.hasValue && next.value != null && previous?.value == null) {
        // User appena loggato - sincronizza
        await _performFullSync();
      } else if (next.hasValue && next.value == null) {
        // User disconnesso - carica solo cache locale
        await _loadLocalTemplates();
      }
    });

    await _loadTemplates();
  }

  /// Carica template (cloud se autenticato, locale altrimenti)
  Future<void> _loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final templates = await _repository.getAllTemplates();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Carica solo template locali
  Future<void> _loadLocalTemplates() async {
    try {
      // Usa metodo privato per caricare solo dalla cache
      final templates = await _repository.getAllTemplates();
      state = state.copyWith(templates: templates, hasOfflineChanges: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sincronizzazione completa con cloud
  Future<void> _performFullSync() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      await _repository.syncWithCloud();
      await _loadTemplates();

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        hasOfflineChanges: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Errore sincronizzazione: $e',
      );
    }
  }

  /// Salva template con sync intelligente
  Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      await _repository.saveTemplate(template);

      // Aggiorna lista locale immediatamente
      final updatedTemplates = [...state.templates];
      final existingIndex = updatedTemplates.indexWhere(
        (t) => t.id == template.id,
      );

      if (existingIndex != -1) {
        updatedTemplates[existingIndex] = template;
      } else {
        updatedTemplates.insert(0, template);
      }

      state = state.copyWith(
        templates: updatedTemplates,
        hasOfflineChanges: FirebaseAuth.instance.currentUser == null,
      );

      // Invalida provider cache
      ref.invalidate(templateSyncProvider);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Elimina template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _repository.deleteTemplate(templateId);

      // Rimuovi dalla lista locale
      final updatedTemplates = state.templates
          .where((template) => template.id != templateId)
          .toList();

      state = state.copyWith(
        templates: updatedTemplates,
        hasOfflineChanges: FirebaseAuth.instance.currentUser == null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Incrementa utilizzo template
  Future<void> incrementUsage(String templateId) async {
    try {
      await _repository.incrementUsage(templateId);

      // Aggiorna lista locale
      final updatedTemplates = state.templates.map((template) {
        if (template.id == templateId) {
          return template.incrementUsage();
        }
        return template;
      }).toList();

      state = state.copyWith(templates: updatedTemplates);
    } catch (e) {
      // Silently fail per incrementUsage
      if (kDebugMode) {
        debugPrint('Errore incremento utilizzo: $e');
      }
    }
  }

  /// Forza sincronizzazione manuale
  Future<void> forcSync() async {
    await _performFullSync();
  }

  /// Pulisce errori
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider per stato sincronizzazione
final syncStatusProvider = Provider<String>((ref) {
  final templateState = ref.watch(firebaseTemplateNotifierProvider);
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return 'Offline - Solo cache locale';
  }

  if (templateState.isSyncing) {
    return 'Sincronizzazione in corso...';
  }

  if (templateState.hasOfflineChanges) {
    return 'Modifiche offline in attesa di sync';
  }

  if (templateState.lastSyncTime != null) {
    final timeDiff = DateTime.now().difference(templateState.lastSyncTime!);
    if (timeDiff.inMinutes < 5) {
      return 'Sincronizzato di recente';
    } else {
      return 'Ultimo sync: ${timeDiff.inMinutes}min fa';
    }
  }

  return 'Pronto per sincronizzazione';
});
