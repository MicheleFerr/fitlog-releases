// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI context provider - aggregates user data

@ProviderFor(aiContext)
const aiContextProvider = AiContextProvider._();

/// AI context provider - aggregates user data

final class AiContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<AIContext>,
          AIContext,
          FutureOr<AIContext>
        >
    with $FutureModifier<AIContext>, $FutureProvider<AIContext> {
  /// AI context provider - aggregates user data
  const AiContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiContextHash();

  @$internal
  @override
  $FutureProviderElement<AIContext> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AIContext> create(Ref ref) {
    return aiContext(ref);
  }
}

String _$aiContextHash() => r'3285aa927644813148ef26acf94640aae730bfad';
