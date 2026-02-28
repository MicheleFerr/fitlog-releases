import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';

/// Wait for a StreamProvider to settle
Future<void> _pumpUntilSettled(
  ProviderContainer container,
  StreamProvider provider,
) async {
  container.listen(provider, (_, __) {});
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('DebugSectionStates', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty map', () {
      final states = container.read(debugSectionStatesProvider);
      expect(states, isEmpty);
    });

    test('isCollapsed returns true by default for unknown section', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      expect(notifier.isCollapsed('unknown-section'), isTrue);
    });

    test('toggle flips collapsed state', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);

      notifier.toggle('section1');
      expect(container.read(debugSectionStatesProvider)['section1'], isFalse);

      notifier.toggle('section1');
      expect(container.read(debugSectionStatesProvider)['section1'], isTrue);
    });

    test('expand sets section to not collapsed', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.expand('section1');
      expect(container.read(debugSectionStatesProvider)['section1'], isFalse);
    });

    test('collapse sets section to collapsed', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.expand('section1');
      notifier.collapse('section1');
      expect(container.read(debugSectionStatesProvider)['section1'], isTrue);
    });

    test('expandAll expands all sections', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.collapse('section1');
      notifier.collapse('section2');
      notifier.collapse('section3');

      notifier.expandAll();

      final states = container.read(debugSectionStatesProvider);
      expect(states.values.every((collapsed) => !collapsed), isTrue);
    });

    test('collapseAll collapses all sections', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.expand('section1');
      notifier.expand('section2');
      notifier.expand('section3');

      notifier.collapseAll();

      final states = container.read(debugSectionStatesProvider);
      expect(states.values.every((collapsed) => collapsed), isTrue);
    });

    test('toggle preserves other sections state', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.expand('section1');
      notifier.collapse('section2');

      notifier.toggle('section1');

      final states = container.read(debugSectionStatesProvider);
      expect(states['section1'], isTrue);
      expect(states['section2'], isTrue);
    });

    test('multiple independent sections tracked correctly', () {
      final notifier = container.read(debugSectionStatesProvider.notifier);
      notifier.expand('a');
      notifier.collapse('b');
      notifier.expand('c');

      expect(notifier.isCollapsed('a'), isFalse);
      expect(notifier.isCollapsed('b'), isTrue);
      expect(notifier.isCollapsed('c'), isFalse);
    });
  });

  group('isAdminCachedProvider', () {
    test('returns false when isAdminProvider has no data (loading)', () {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith((ref) => const Stream<bool>.empty()),
        ],
      );
      addTearDown(container.dispose);

      final isAdmin = container.read(isAdminCachedProvider);
      expect(isAdmin, isFalse);
    });

    test('returns true when isAdminProvider emits true', () async {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, isAdminProvider);

      final isAdmin = container.read(isAdminCachedProvider);
      expect(isAdmin, isTrue);
    });

    test('returns false when isAdminProvider emits false', () async {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, isAdminProvider);

      final isAdmin = container.read(isAdminCachedProvider);
      expect(isAdmin, isFalse);
    });

    test('returns false on stream error', () async {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith(
            (ref) => Stream<bool>.error(Exception('token error')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, isAdminProvider);

      final isAdmin = container.read(isAdminCachedProvider);
      expect(isAdmin, isFalse);
    });
  });

  group('showDebugSectionsProvider', () {
    test('returns true when admin', () async {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, isAdminProvider);

      expect(container.read(showDebugSectionsProvider), isTrue);
    });

    test('returns false when not admin', () async {
      final container = ProviderContainer(
        overrides: [
          isAdminProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpUntilSettled(container, isAdminProvider);

      expect(container.read(showDebugSectionsProvider), isFalse);
    });
  });

  group('debugSectionCollapsedProvider', () {
    test('defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(debugSectionCollapsedProvider), isTrue);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(debugSectionCollapsedProvider.notifier).state = false;
      expect(container.read(debugSectionCollapsedProvider), isFalse);
    });
  });
}
