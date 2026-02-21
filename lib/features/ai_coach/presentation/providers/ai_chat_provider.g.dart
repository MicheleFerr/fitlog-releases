// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI Coach service provider

@ProviderFor(aiCoachService)
const aiCoachServiceProvider = AiCoachServiceProvider._();

/// AI Coach service provider

final class AiCoachServiceProvider
    extends
        $FunctionalProvider<
          AICoachServiceImpl,
          AICoachServiceImpl,
          AICoachServiceImpl
        >
    with $Provider<AICoachServiceImpl> {
  /// AI Coach service provider
  const AiCoachServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiCoachServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiCoachServiceHash();

  @$internal
  @override
  $ProviderElement<AICoachServiceImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AICoachServiceImpl create(Ref ref) {
    return aiCoachService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AICoachServiceImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AICoachServiceImpl>(value),
    );
  }
}

String _$aiCoachServiceHash() => r'c175f5a9c6bd93d4e7ed2f524e6a9cbcd45d22b0';

/// AI Chat provider

@ProviderFor(AIChat)
const aIChatProvider = AIChatProvider._();

/// AI Chat provider
final class AIChatProvider extends $NotifierProvider<AIChat, AIChatState> {
  /// AI Chat provider
  const AIChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aIChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aIChatHash();

  @$internal
  @override
  AIChat create() => AIChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIChatState>(value),
    );
  }
}

String _$aIChatHash() => r'75a9c5414f315a71bb08c4e8d7b64bd4ba51331c';

/// AI Chat provider

abstract class _$AIChat extends $Notifier<AIChatState> {
  AIChatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AIChatState, AIChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AIChatState, AIChatState>,
              AIChatState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
