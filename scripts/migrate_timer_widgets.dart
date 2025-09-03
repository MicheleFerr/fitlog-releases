import 'dart:io';

/// Script to migrate timer widgets to use the unified timer system adapter
/// This automatically updates all timer widget files to use the new system
void main() async {
  final widgetFiles = [
    'lib/features/timer/presentation/widgets/draggable_timer_overlay.dart',
    'lib/features/timer/presentation/widgets/enhanced_timer_overlay.dart',
    'lib/features/timer/presentation/widgets/minimizable_timer_overlay.dart',
    'lib/features/timer/presentation/widgets/timer_test_screen.dart',
  ];
  
  for (final filePath in widgetFiles) {
    await migrateWidget(filePath);
  }
  
  print('✅ All timer widgets migrated to unified system!');
}

Future<void> migrateWidget(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    print('⚠️ File not found: $filePath');
    return;
  }
  
  String content = await file.readAsString();
  
  // Add import for timer system adapter
  if (!content.contains('timer_system_adapter.dart')) {
    final importIndex = content.lastIndexOf("import 'package:gymbro_flutter_new/");
    if (importIndex != -1) {
      final nextLineIndex = content.indexOf('\n', importIndex);
      if (nextLineIndex != -1) {
        content = content.substring(0, nextLineIndex + 1) +
            "import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_system_adapter.dart';\n" +
            content.substring(nextLineIndex + 1);
      }
    }
  }
  
  // Replace timer provider watches
  content = content.replaceAll(
    'ref.watch(currentTimerProvider)',
    'ref.watch(adaptiveCurrentTimerProvider)'
  );
  
  content = content.replaceAll(
    'ref.watch(currentTimerProvider.select((t) => t?.isActive ?? false))',
    'ref.watch(adaptiveTimerActiveProvider)'
  );
  
  content = content.replaceAll(
    'ref.watch(currentTimerProvider.select((timer) => timer?.isActive ?? false))',
    'ref.watch(adaptiveTimerActiveProvider)'
  );
  
  // Replace timer actions with controller calls
  content = content.replaceAllMapped(
    RegExp(r'ref\.read\(currentTimerProvider\.notifier\)\.(\w+)\(\)'),
    (match) {
      final method = match.group(1);
      return 'await ref.read(timerSystemControllerProvider).$method()';
    }
  );
  
  content = content.replaceAllMapped(
    RegExp(r'ref\.read\(currentTimerProvider\.notifier\)\.(\w+)\(([^)]*)\)'),
    (match) {
      final method = match.group(1);
      final params = match.group(2);
      return 'await ref.read(timerSystemControllerProvider).$method($params)';
    }
  );
  
  // Fix onPressed callbacks to be async
  content = content.replaceAllMapped(
    RegExp(r'onPressed: \(\) =>'),
    (match) => 'onPressed: () async =>'
  );
  
  content = content.replaceAllMapped(
    RegExp(r'onPressed: \(\) \{([^}]*await[^}]*)\}', dotAll: true),
    (match) => 'onPressed: () async {${match.group(1)}}'
  );
  
  await file.writeAsString(content);
  print('✅ Migrated: $filePath');
}