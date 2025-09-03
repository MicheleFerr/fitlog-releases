import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/features/home/providers/home_customization_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('HomeCustomizationProvider - Unit Tests', () {
    // Test the default widgets directly without provider
    test('DefaultHomeWidgets has correct default configuration', () {
      final defaults = DefaultHomeWidgets.defaultWidgets;
      
      expect(defaults, isNotEmpty);
      expect(defaults.every((w) => w.id.isNotEmpty), true);
      expect(defaults.every((w) => w.type.isNotEmpty), true);
      expect(defaults.every((w) => w.title.isNotEmpty), true);
    });
    
    test('HomeWidgetConfig copyWith works correctly', () {
      final widget = HomeWidgetConfig(
        id: 'test-widget',
        type: 'workout',
        title: 'Test Widget',
        icon: Icons.fitness_center,
        order: 0,
        size: WidgetSize.medium,
        isVisible: true,
      );
      
      final updated = widget.copyWith(
        isVisible: false,
        size: WidgetSize.large,
      );
      
      expect(updated.id, equals(widget.id));
      expect(updated.type, equals(widget.type));
      expect(updated.isVisible, false);
      expect(updated.size, WidgetSize.large);
    });
    
    test('HomeWidgetConfig serialization works', () {
      final widget = HomeWidgetConfig(
        id: 'test-widget',
        type: 'workout',
        title: 'Test Widget',
        icon: Icons.fitness_center,
        order: 0,
        size: WidgetSize.medium,
      );
      
      final json = widget.toJson();
      expect(json['id'], equals('test-widget'));
      expect(json['type'], equals('workout'));
      expect(json['title'], equals('Test Widget'));
      expect(json['order'], equals(0));
    });
    
    test('HomeWidgetConfig deserialization works', () {
      final json = {
        'id': 'test-widget',
        'type': 'workout',
        'title': 'Test Widget',
        'icon': Icons.fitness_center.codePoint,
        'isVisible': false,
        'order': 5,
        'size': 'large',
      };
      
      final widget = HomeWidgetConfig.fromJson(json);
      expect(widget.id, equals('test-widget'));
      expect(widget.type, equals('workout'));
      expect(widget.title, equals('Test Widget'));
      expect(widget.isVisible, false);
      expect(widget.order, equals(5));
    });
  });
  
  group('Edit Mode Provider', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });

    test('can toggle edit mode', () {
      final editNotifier = container.read(isHomeEditingProvider.notifier);
      
      editNotifier.state = true;
      expect(container.read(isHomeEditingProvider), true);
      
      editNotifier.state = false;
      expect(container.read(isHomeEditingProvider), false);
    });
    
    test('WidgetSize enum values', () {
      expect(WidgetSize.values, contains(WidgetSize.small));
      expect(WidgetSize.values, contains(WidgetSize.medium));
      expect(WidgetSize.values, contains(WidgetSize.large));
    });
  });
}