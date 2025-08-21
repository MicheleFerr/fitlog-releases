import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'shared/domain/entities/app_config.dart';
import 'shared/domain/entities/theme_mode_adapter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters BEFORE opening boxes
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AppConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(100)) {
    Hive.registerAdapter(ThemeModeAdapter());
  }
  
  // Initialize secure storage boxes
  await _initializeStorage();
  
  runApp(
    const ProviderScope(
      child: GymBroApp(),
    ),
  );
}

/// Initialize all storage systems
Future<void> _initializeStorage() async {
  try {
    // Open Hive boxes for different data types
    debugPrint('📦 Opening auth_box...');
    await Hive.openBox('auth_box');
    
    debugPrint('📦 Opening timer_box...');
    await Hive.openBox('timer_box'); 
    
    debugPrint('📦 Opening workout_box...');
    await Hive.openBox('workout_box');
    
    debugPrint('📦 Opening settings_box...');
    await Hive.openBox('settings_box');
    
    debugPrint('📦 Opening app_config box...');
    await Hive.openBox<AppConfig>('app_config');
    
    debugPrint('✅ Storage initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Storage initialization failed: $e');
    debugPrint('📍 Stack trace: $stackTrace');
    // Continue anyway - the app should work even without persisted settings
  }
}
