// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for managing Discover tab filter state

@ProviderFor(DiscoverFilters)
const discoverFiltersProvider = DiscoverFiltersProvider._();

/// Provider for managing Discover tab filter state
final class DiscoverFiltersProvider
    extends $NotifierProvider<DiscoverFilters, DiscoverFiltersState> {
  /// Provider for managing Discover tab filter state
  const DiscoverFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverFiltersHash();

  @$internal
  @override
  DiscoverFilters create() => DiscoverFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoverFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoverFiltersState>(value),
    );
  }
}

String _$discoverFiltersHash() => r'786a5c21c9161bb237959dfb10043b874cfdf1d2';

/// Provider for managing Discover tab filter state

abstract class _$DiscoverFilters extends $Notifier<DiscoverFiltersState> {
  DiscoverFiltersState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DiscoverFiltersState, DiscoverFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoverFiltersState, DiscoverFiltersState>,
              DiscoverFiltersState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider that filters templates based on current filter state

@ProviderFor(filteredDiscoverTemplates)
const filteredDiscoverTemplatesProvider = FilteredDiscoverTemplatesFamily._();

/// Provider that filters templates based on current filter state

final class FilteredDiscoverTemplatesProvider
    extends
        $FunctionalProvider<
          List<WorkoutTemplate>,
          List<WorkoutTemplate>,
          List<WorkoutTemplate>
        >
    with $Provider<List<WorkoutTemplate>> {
  /// Provider that filters templates based on current filter state
  const FilteredDiscoverTemplatesProvider._({
    required FilteredDiscoverTemplatesFamily super.from,
    required List<WorkoutTemplate> super.argument,
  }) : super(
         retry: null,
         name: r'filteredDiscoverTemplatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredDiscoverTemplatesHash();

  @override
  String toString() {
    return r'filteredDiscoverTemplatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<WorkoutTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<WorkoutTemplate> create(Ref ref) {
    final argument = this.argument as List<WorkoutTemplate>;
    return filteredDiscoverTemplates(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<WorkoutTemplate> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<WorkoutTemplate>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredDiscoverTemplatesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredDiscoverTemplatesHash() =>
    r'f1b698e9284a10136f977c7039bc4da9cea44592';

/// Provider that filters templates based on current filter state

final class FilteredDiscoverTemplatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<WorkoutTemplate>,
          List<WorkoutTemplate>
        > {
  const FilteredDiscoverTemplatesFamily._()
    : super(
        retry: null,
        name: r'filteredDiscoverTemplatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that filters templates based on current filter state

  FilteredDiscoverTemplatesProvider call(List<WorkoutTemplate> templates) =>
      FilteredDiscoverTemplatesProvider._(argument: templates, from: this);

  @override
  String toString() => r'filteredDiscoverTemplatesProvider';
}
