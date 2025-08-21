import 'package:flutter/services.dart';

class TestSounds {
  static const MethodChannel _channel = MethodChannel('com.gymbro.timer/audio');
  
  static Future<void> testNotificationSounds() async {
    try {
      print('🧪 Testing notification sounds...');
      await _channel.invokeMethod('testSounds');
      print('✅ Test command sent to iOS');
    } catch (e) {
      print('❌ Error testing sounds: $e');
    }
  }
}