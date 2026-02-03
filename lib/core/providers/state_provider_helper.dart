/// TEMPORARY: StateProvider replacement for Riverpod 3.x migration
///
/// StateProvider was removed in Riverpod 3.x.
/// This helper provides a drop-in replacement using NotifierProvider.
///
/// TODO: Migrate to @riverpod codegen for proper state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates a simple state notifier that mimics StateProvider behavior
class _StateNotifier<T> extends Notifier<T> {
  _StateNotifier(this._initialValue);

  final T _initialValue;

  @override
  T build() => _initialValue;

  /// Update the state (mimics StateProvider.state setter)
  // ignore: avoid_setters_without_getters
  set state(T value) => super.state = value;
}

/// Creates a NotifierProvider that behaves like StateProvider
///
/// Usage:
/// ```dart
/// // Old (Riverpod 2.x):
/// final myProvider = StateProvider<bool>((ref) => false);
///
/// // New (Riverpod 3.x with this helper):
/// final myProvider = createStateProvider<bool>(false);
/// ```
// ignore: non_constant_identifier_names
NotifierProvider<_StateNotifier<T>, T> createStateProvider<T>(T initialValue) {
  return NotifierProvider<_StateNotifier<T>, T>(
    () => _StateNotifier(initialValue),
  );
}

/// Creates an auto-dispose NotifierProvider that behaves like StateProvider.autoDispose
///
/// Usage:
/// ```dart
/// // Old (Riverpod 2.x):
/// final myProvider = StateProvider.autoDispose<bool>((ref) => false);
///
/// // New (Riverpod 3.x with this helper):
/// final myProvider = createStateProviderAutoDispose<bool>(false);
/// ```
createStateProviderAutoDispose<T>(T initialValue) {
  return NotifierProvider.autoDispose<_StateNotifier<T>, T>(
    () => _StateNotifier(initialValue),
  );
}
