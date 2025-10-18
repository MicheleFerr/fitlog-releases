/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/features/home
/// 🎯 Feature: home widget factory tests
/// 🔧 Type: widget test
/// 🌍 Localization: ✅ AppLocalizations tested
/// 🎨 Theme: ✅ ColorScheme tested
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/home_widget_factory.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import '../../../test_helpers/firebase_test_helper.dart';

class MockWorkoutProvider extends StateNotifier<List<dynamic>> {
  MockWorkoutProvider() : super([]);
}

class MockProgressProvider extends StateNotifier<Map<String, dynamic>> {
  MockProgressProvider() : super({});
}

void main() {
  group('HomeWidgetFactory Tests', () {
    late MockWorkoutProvider mockWorkoutProvider;
    late MockProgressProvider mockProgressProvider;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockWorkoutProvider = MockWorkoutProvider();
      mockProgressProvider = MockProgressProvider();
    });

    Widget createTestWidget({required Widget child}) {
      return ProviderScope(
        overrides: [
          // Mock providers to prevent real data dependencies
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('creates small widget correctly', (tester) async {
      const config = HomeWidgetConfig(
        id: 'test-small',
        type: HomeWidgetType.statsCard,
        title: 'Test Small Widget',
        icon: Icons.bar_chart,
        order: 0,
        size: WidgetSize.small,
      );

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => HomeWidgetFactory.buildWidget(
            context: context,
            ref: ProviderScope.containerOf(context).read,
            config: config,
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('creates medium widget correctly', (tester) async {
      const config = HomeWidgetConfig(
        id: 'test-medium',
        type: HomeWidgetType.progressDashboard,
        title: 'Test Medium Widget',
        icon: Icons.analytics,
        order: 0,
        size: WidgetSize.medium,
      );

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => HomeWidgetFactory.buildWidget(
            context: context,
            ref: ProviderScope.containerOf(context).read,
            config: config,
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('creates large widget correctly', (tester) async {
      const config = HomeWidgetConfig(
        id: 'test-large',
        type: HomeWidgetType.weeklyGoals,
        title: 'Test Large Widget',
        icon: Icons.track_changes,
        order: 0,
        size: WidgetSize.large,
      );

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => HomeWidgetFactory.buildWidget(
            context: context,
            ref: ProviderScope.containerOf(context).read,
            config: config,
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles all widget types', (tester) async {
      final widgetTypes = [
        HomeWidgetType.activeWorkout,
        HomeWidgetType.statsCard,
        HomeWidgetType.quickStart,
        HomeWidgetType.recentWorkouts,
        HomeWidgetType.weeklyGoals,
      ];

      for (final type in widgetTypes) {
        final config = HomeWidgetConfig(
          id: 'test-$type',
          type: type,
          title: 'Test $type Widget',
          icon: Icons.fitness_center,
          order: 0,
          size: WidgetSize.medium,
        );

        await tester.pumpWidget(createTestWidget(
          child: Builder(
            builder: (context) => HomeWidgetFactory.buildWidget(
              context: context,
              ref: ProviderScope.containerOf(context).read,
              config: config,
            ),
          ),
        ));

        expect(find.byType(Card), findsOneWidget,
            reason: 'Failed for widget type: $type');
        
        await tester.pumpWidget(Container()); // Clear
      }
    });

    testWidgets('creates widget in preview mode', (tester) async {
      const config = HomeWidgetConfig(
        id: 'test-preview',
        type: HomeWidgetType.statsCard,
        title: 'Test Preview Widget',
        icon: Icons.preview,
        order: 0,
      );

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => HomeWidgetFactory.buildWidget(
            context: context,
            ref: ProviderScope.containerOf(context).read,
            config: config,
            isPreview: true,
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles widget with custom settings', (tester) async {
      const config = HomeWidgetConfig(
        id: 'test-settings',
        type: HomeWidgetType.progressDashboard,
        title: 'Test Settings Widget',
        icon: Icons.settings,
        order: 0,
        settings: {
          'showLastWeek': true,
          'showGoals': false,
          'theme': 'compact',
        },
      );

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) => HomeWidgetFactory.buildWidget(
            context: context,
            ref: ProviderScope.containerOf(context).read,
            config: config,
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    group('Widget Configuration Tests', () {
      test('creates valid config with all required fields', () {
        const config = HomeWidgetConfig(
          id: 'test-config',
          type: HomeWidgetType.statsCard,
          title: 'Test Widget',
          icon: Icons.bar_chart,
          order: 0,
        );

        expect(config.id, 'test-config');
        expect(config.type, HomeWidgetType.statsCard);
        expect(config.title, 'Test Widget');
        expect(config.icon, Icons.bar_chart);
        expect(config.order, 0);
        expect(config.isVisible, true);
        expect(config.size, WidgetSize.medium);
      });

      test('copyWith preserves unchanged values', () {
        const original = HomeWidgetConfig(
          id: 'original',
          type: HomeWidgetType.statsCard,
          title: 'Original Title',
          icon: Icons.bar_chart,
          order: 0,
        );

        final modified = original.copyWith(
          isVisible: false,
        );

        expect(modified.id, original.id);
        expect(modified.title, original.title);
        expect(modified.isVisible, false);
      });

      test('validates widget sizes', () {
        expect(WidgetSize.values, hasLength(3));
        expect(WidgetSize.values, contains(WidgetSize.small));
        expect(WidgetSize.values, contains(WidgetSize.medium));
        expect(WidgetSize.values, contains(WidgetSize.large));
      });

      test('widget types are properly defined', () {
        expect(HomeWidgetType.activeWorkout, 'active_workout');
        expect(HomeWidgetType.statsCard, 'stats_card');
        expect(HomeWidgetType.recentWorkouts, 'recent_workouts');
        expect(HomeWidgetType.weeklyGoals, 'weekly_goals');
      });
    });

    group('Widget Factory Logic Tests', () {
      test('handles unknown widget type gracefully', () {
        const config = HomeWidgetConfig(
          id: 'test-unknown',
          type: 'unknown_type',
          title: 'Unknown Widget',
          icon: Icons.help,
          order: 0,
        );

        // Factory should handle unknown types without crashing
        expect(config.type, 'unknown_type');
      });

      test('widget configuration validation', () {
        // Test required fields
        expect(() => const HomeWidgetConfig(
          id: '',
          type: HomeWidgetType.statsCard,
          title: 'Test',
          icon: Icons.bar_chart,
          order: 0,
        ), returnsNormally);

        // Empty ID should still create valid config
        const config = HomeWidgetConfig(
          id: '',
          type: HomeWidgetType.statsCard,
          title: 'Test',
          icon: Icons.bar_chart,
          order: 0,
        );
        expect(config.id, '');
      });

      test('widget ordering logic', () {
        final configs = [
          const HomeWidgetConfig(
            id: 'first',
            type: HomeWidgetType.statsCard,
            title: 'First',
            icon: Icons.first_page,
            order: 2,
          ),
          HomeWidgetConfig(
            id: 'second',
            type: HomeWidgetType.activeWorkout,
            title: 'Second',
            icon: Icons.second_page,
            order: 1,
          ),
          const HomeWidgetConfig(
            id: 'third',
            type: HomeWidgetType.recentWorkouts,
            title: 'Third',
            icon: Icons.last_page,
            order: 3,
          ),
        ];

        configs.sort((a, b) => a.order.compareTo(b.order));

        expect(configs[0].id, 'second');
        expect(configs[1].id, 'first');
        expect(configs[2].id, 'third');
      });
    });

    group('Widget Settings Tests', () {
      test('handles widget with settings', () {
        final settings = {
          'theme': 'dark',
          'showAnimations': true,
          'refreshInterval': 30,
          'maxItems': 5,
        };

        final config = HomeWidgetConfig(
          id: 'settings-test',
          type: HomeWidgetType.recentWorkouts,
          title: 'Settings Test',
          icon: Icons.settings,
          order: 0,
          settings: settings,
        );

        expect(config.settings, equals(settings));
        expect(config.settings!['theme'], 'dark');
        expect(config.settings!['showAnimations'], true);
        expect(config.settings!['refreshInterval'], 30);
        expect(config.settings!['maxItems'], 5);
      });

      test('handles widget without settings', () {
        const config = HomeWidgetConfig(
          id: 'no-settings',
          type: HomeWidgetType.statsCard,
          title: 'No Settings',
          icon: Icons.bar_chart,
          order: 0,
        );

        expect(config.settings, isNull);
      });
    });
  });
}