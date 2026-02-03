// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_rate_limit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rate limit provider

@ProviderFor(AIRateLimit)
const aIRateLimitProvider = AIRateLimitProvider._();

/// Rate limit provider
final class AIRateLimitProvider
    extends $AsyncNotifierProvider<AIRateLimit, RateLimitResult> {
  /// Rate limit provider
  const AIRateLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aIRateLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aIRateLimitHash();

  @$internal
  @override
  AIRateLimit create() => AIRateLimit();
}

String _$aIRateLimitHash() => r'42fe7e205e0892906580648b5a58caf1dad6fb6a';

/// Rate limit provider

abstract class _$AIRateLimit extends $AsyncNotifier<RateLimitResult> {
  FutureOr<RateLimitResult> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<RateLimitResult>, RateLimitResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RateLimitResult>, RateLimitResult>,
              AsyncValue<RateLimitResult>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
