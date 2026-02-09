// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_suggestions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the exercise suggestion service

@ProviderFor(exerciseSuggestionService)
const exerciseSuggestionServiceProvider = ExerciseSuggestionServiceProvider._();

/// Provider for the exercise suggestion service

final class ExerciseSuggestionServiceProvider
    extends
        $FunctionalProvider<
          ExerciseSuggestionService,
          ExerciseSuggestionService,
          ExerciseSuggestionService
        >
    with $Provider<ExerciseSuggestionService> {
  /// Provider for the exercise suggestion service
  const ExerciseSuggestionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseSuggestionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseSuggestionServiceHash();

  @$internal
  @override
  $ProviderElement<ExerciseSuggestionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExerciseSuggestionService create(Ref ref) {
    return exerciseSuggestionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseSuggestionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseSuggestionService>(value),
    );
  }
}

String _$exerciseSuggestionServiceHash() =>
    r'd1db328114e9ce81fd74e6fae7bfa51ac25c352e';

/// State for exercise suggestions
///
/// **States**:
/// - data (empty list): No suggestions to show
/// - data (non-empty): Suggestions available
/// - loading: Search in progress (not exposed to UI)
/// - error: Search failed (silent, not exposed to UI)

@ProviderFor(ExerciseSuggestions)
const exerciseSuggestionsProvider = ExerciseSuggestionsProvider._();

/// State for exercise suggestions
///
/// **States**:
/// - data (empty list): No suggestions to show
/// - data (non-empty): Suggestions available
/// - loading: Search in progress (not exposed to UI)
/// - error: Search failed (silent, not exposed to UI)
final class ExerciseSuggestionsProvider
    extends
        $NotifierProvider<
          ExerciseSuggestions,
          AsyncValue<List<ExerciseSuggestion>>
        > {
  /// State for exercise suggestions
  ///
  /// **States**:
  /// - data (empty list): No suggestions to show
  /// - data (non-empty): Suggestions available
  /// - loading: Search in progress (not exposed to UI)
  /// - error: Search failed (silent, not exposed to UI)
  const ExerciseSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseSuggestionsHash();

  @$internal
  @override
  ExerciseSuggestions create() => ExerciseSuggestions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ExerciseSuggestion>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<ExerciseSuggestion>>>(value),
    );
  }
}

String _$exerciseSuggestionsHash() =>
    r'9279b5d0ddf4507ee03cac81983f5b04e9dfce1c';

/// State for exercise suggestions
///
/// **States**:
/// - data (empty list): No suggestions to show
/// - data (non-empty): Suggestions available
/// - loading: Search in progress (not exposed to UI)
/// - error: Search failed (silent, not exposed to UI)

abstract class _$ExerciseSuggestions
    extends $Notifier<AsyncValue<List<ExerciseSuggestion>>> {
  AsyncValue<List<ExerciseSuggestion>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ExerciseSuggestion>>,
              AsyncValue<List<ExerciseSuggestion>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ExerciseSuggestion>>,
                AsyncValue<List<ExerciseSuggestion>>
              >,
              AsyncValue<List<ExerciseSuggestion>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
