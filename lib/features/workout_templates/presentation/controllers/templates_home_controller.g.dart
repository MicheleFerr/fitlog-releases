// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'templates_home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TemplatesHomeController)
const templatesHomeControllerProvider = TemplatesHomeControllerProvider._();

final class TemplatesHomeControllerProvider
    extends $NotifierProvider<TemplatesHomeController, TemplatesHomeState> {
  const TemplatesHomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templatesHomeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templatesHomeControllerHash();

  @$internal
  @override
  TemplatesHomeController create() => TemplatesHomeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemplatesHomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemplatesHomeState>(value),
    );
  }
}

String _$templatesHomeControllerHash() =>
    r'63a0b36dc831397536864f44e7d8301559efa3a2';

abstract class _$TemplatesHomeController extends $Notifier<TemplatesHomeState> {
  TemplatesHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TemplatesHomeState, TemplatesHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TemplatesHomeState, TemplatesHomeState>,
              TemplatesHomeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
