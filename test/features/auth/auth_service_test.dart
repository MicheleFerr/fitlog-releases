import 'package:flutter_test/flutter_test.dart';

void main() {
  group('🔐 Password Validation Tests', () {
    // Test delle funzioni di validazione password senza Firebase
    
    test('✅ TEST 1: Password validation - valid password', () {
      // Valid password with all requirements
      final result = validatePassword('Test123!@#');
      expect(result, isNull); // null means valid
    });
    
    test('❌ TEST 2: Password validation - too short', () {
      // Password less than 8 characters
      final result = validatePassword('Test1!');
      expect(result, contains('at least 8 characters'));
    });
    
    test('❌ TEST 3: Password validation - no uppercase', () {
      // Password without uppercase letter
      final result = validatePassword('test123!@#');
      expect(result, contains('uppercase letter'));
    });
    
    test('❌ TEST 4: Password validation - no number', () {
      // Password without number
      final result = validatePassword('TestTest!@#');
      expect(result, contains('number'));
    });
    
    test('❌ TEST 5: Password validation - no special character', () {
      // Password without special character
      final result = validatePassword('Test12345');
      expect(result, contains('special character'));
    });
  });
  
  group('📧 Email Validation Tests', () {
    test('✅ TEST 6: Valid email format', () {
      final isValid = isValidEmail('user@example.com');
      expect(isValid, true);
    });
    
    test('❌ TEST 7: Invalid email - no @', () {
      final isValid = isValidEmail('userexample.com');
      expect(isValid, false);
    });
    
    test('❌ TEST 8: Invalid email - no domain', () {
      final isValid = isValidEmail('user@');
      expect(isValid, false);
    });
  });
}

// Funzioni di validazione standalone per testing
String? validatePassword(String password) {
  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'Password must contain at least one number';
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    return 'Password must contain at least one special character';
  }
  return null; // Password is valid
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}