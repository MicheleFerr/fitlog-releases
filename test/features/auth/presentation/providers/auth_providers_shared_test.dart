import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_providers_shared.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class FakeUser implements User {
  FakeUser({
    this.uid = 'test-uid',
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.isAnonymous = false,
  });

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool isAnonymous;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Wait for a StreamProvider to settle by pumping microtasks
Future<void> _pumpUntilSettled(
  ProviderContainer container,
  StreamProvider provider,
) async {
  // Subscribe to ensure provider is active
  container.listen(provider, (_, __) {});
  // Pump event loop to let stream emit + propagate
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('AuthState enum', () {
    test('has all expected values', () {
      expect(AuthState.values.length, 3);
      expect(AuthState.values, contains(AuthState.loading));
      expect(AuthState.values, contains(AuthState.authenticated));
      expect(AuthState.values, contains(AuthState.unauthenticated));
    });

    test('name returns correct strings', () {
      expect(AuthState.loading.name, 'loading');
      expect(AuthState.authenticated.name, 'authenticated');
      expect(AuthState.unauthenticated.name, 'unauthenticated');
    });
  });

  group('authStateProvider', () {
    test('returns loading when firebaseUserProvider is loading', () {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => const Stream<User?>.empty(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(authStateProvider);
      expect(state, AuthState.loading);
    });

    test('returns authenticated when user is present', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => Stream.value(FakeUser()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, firebaseUserProvider);

      final state = container.read(authStateProvider);
      expect(state, AuthState.authenticated);
    });

    test('returns unauthenticated when user is null', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, firebaseUserProvider);

      final state = container.read(authStateProvider);
      expect(state, AuthState.unauthenticated);
    });

    test('returns unauthenticated on stream error', () {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWithValue(
            AsyncError<User?>(Exception('network'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(authStateProvider);
      expect(state, AuthState.unauthenticated);
    });
  });

  group('firebaseUserProvider', () {
    test('emits loading initially', () {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => const Stream<User?>.empty(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.isLoading, isTrue);
    });

    test('emits user when authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => Stream.value(FakeUser(uid: 'abc123')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, firebaseUserProvider);

      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.value?.uid, 'abc123');
    });

    test('emits null when not authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, firebaseUserProvider);

      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.hasValue, isTrue);
      expect(asyncUser.value, isNull);
    });

    test('emits error on stream error', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseUserProvider.overrideWith(
            (ref) => Stream<User?>.error(Exception('network')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, firebaseUserProvider);

      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.hasError, isTrue);
    });
  });
}
