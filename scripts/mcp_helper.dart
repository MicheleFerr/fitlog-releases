#!/usr/bin/env dart

/// MCP Helper Script per Claude Code
/// Questo script fornisce funzionalità MCP direttamente utilizzabili in Claude Code
/// 
/// Uso:
/// dart scripts/mcp_helper.dart get-errors
/// dart scripts/mcp_helper.dart screenshot
/// dart scripts/mcp_helper.dart widget-tree

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  if (args.isEmpty) {
    printHelp();
    exit(0);
  }

  final command = args[0];

  switch (command) {
    case 'get-errors':
      await getAppErrors();
      break;
    case 'screenshot':
      await captureScreenshot();
      break;
    case 'widget-tree':
      await getWidgetTree();
      break;
    case 'hot-reload':
      await hotReload();
      break;
    case 'restart':
      await hotRestart();
      break;
    case 'analyze':
      await analyzeCode();
      break;
    case 'test':
      await runTests();
      break;
    case 'help':
    default:
      printHelp();
  }
}

Future<void> getAppErrors() async {
  print('🔍 Recupero errori dall\'app Flutter...\n');
  
  // Cerca nel log di Flutter
  final result = await Process.run('flutter', ['logs', '--clear']);
  if (result.exitCode != 0) {
    print('❌ Errore nel recupero dei log: ${result.stderr}');
    return;
  }
  
  // Attendi alcuni secondi per raccogliere errori
  print('⏳ Raccolta errori in corso (5 secondi)...');
  await Future.delayed(Duration(seconds: 5));
  
  final logs = await Process.run('flutter', ['logs']);
  if (logs.stdout.toString().contains('Error') || 
      logs.stdout.toString().contains('Exception')) {
    print('❌ Errori trovati:\n');
    final lines = logs.stdout.toString().split('\n');
    for (final line in lines) {
      if (line.contains('Error') || line.contains('Exception')) {
        print('  • $line');
      }
    }
  } else {
    print('✅ Nessun errore rilevato');
  }
}

Future<void> captureScreenshot() async {
  print('📸 Cattura screenshot...\n');
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final filename = 'screenshot_$timestamp.png';
  
  final result = await Process.run('flutter', [
    'screenshot',
    '--out=$filename',
  ]);
  
  if (result.exitCode == 0) {
    print('✅ Screenshot salvato: $filename');
    print('📍 Path: ${Directory.current.path}/$filename');
  } else {
    print('❌ Errore nella cattura: ${result.stderr}');
  }
}

Future<void> getWidgetTree() async {
  print('🌳 Analisi albero widget...\n');
  
  final result = await Process.run('flutter', [
    'inspect',
    '--widget-tree',
  ]);
  
  if (result.exitCode == 0) {
    print(result.stdout);
  } else {
    print('ℹ️  Il comando widget inspector richiede che l\'app sia in esecuzione in debug mode');
    print('Usa: flutter run --debug');
  }
}

Future<void> hotReload() async {
  print('🔄 Hot reload in corso...\n');
  
  // Invia comando 'r' al processo Flutter in esecuzione
  print('ℹ️  Premi "r" nella console dove Flutter è in esecuzione');
  print('    oppure usa il comando da VSCode/Android Studio');
}

Future<void> hotRestart() async {
  print('🔄 Hot restart in corso...\n');
  
  // Invia comando 'R' al processo Flutter in esecuzione
  print('ℹ️  Premi "R" nella console dove Flutter è in esecuzione');
  print('    oppure usa il comando da VSCode/Android Studio');
}

Future<void> analyzeCode() async {
  print('🔍 Analisi codice Flutter...\n');
  
  final result = await Process.run('flutter', ['analyze']);
  
  if (result.exitCode == 0) {
    print('✅ Nessun problema trovato!');
  } else {
    print('⚠️  Problemi trovati:\n');
    print(result.stdout);
  }
}

Future<void> runTests() async {
  print('🧪 Esecuzione test...\n');
  
  final result = await Process.run('flutter', ['test']);
  
  if (result.exitCode == 0) {
    print('✅ Tutti i test passati!');
    print(result.stdout);
  } else {
    print('❌ Test falliti:\n');
    print(result.stdout);
  }
}

void printHelp() {
  print('''
🤖 MCP Helper per Claude Code
==============================

Comandi disponibili:

  get-errors    📋 Recupera errori dall'app Flutter in esecuzione
  screenshot    📸 Cattura uno screenshot dell'app
  widget-tree   🌳 Mostra l'albero dei widget
  hot-reload    🔄 Trigger hot reload
  restart       🔁 Trigger hot restart  
  analyze       🔍 Analizza il codice per problemi
  test          🧪 Esegue i test
  help          ❓ Mostra questo messaggio

Esempi:
  dart scripts/mcp_helper.dart get-errors
  dart scripts/mcp_helper.dart screenshot
  dart scripts/mcp_helper.dart analyze

Note:
  • L'app deve essere in esecuzione per alcuni comandi
  • Usa 'flutter run' prima di usare comandi come screenshot
  • Per debug avanzato, usa 'flutter run --debug'
''');
}