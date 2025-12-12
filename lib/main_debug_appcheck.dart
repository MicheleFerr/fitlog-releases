/// 🔐 Temporary Debug Helper - App Check Token Generator
///
/// **Purpose**: Get debug token for Firebase App Check testing
/// **Usage**: flutter run lib/main_debug_appcheck.dart
/// **Delete**: After getting token and registering it in Firebase Console
///
library;
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate App Check with debug token generation
  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.debug,
    androidProvider: AndroidProvider.debug,
  );

  // Get and print debug token
  if (kDebugMode) {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('🔐 FIREBASE APP CHECK DEBUG TOKEN:');
      debugPrint('');
      debugPrint('   $token');
      debugPrint('');
      debugPrint('📋 STEPS:');
      debugPrint('1. Copy the token above');
      debugPrint('2. Go to: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps');
      debugPrint('3. Click "Debug tokens" tab');
      debugPrint('4. Click "Add debug token"');
      debugPrint('5. Paste token and save');
      debugPrint('6. Wait 5-10 minutes');
      debugPrint('7. Delete this file (lib/main_debug_appcheck.dart)');
      debugPrint('═══════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
    }
  }

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.security, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Check Console for Debug Token',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text('Close app after copying token'),
            ],
          ),
        ),
      ),
    ),
  );
}
