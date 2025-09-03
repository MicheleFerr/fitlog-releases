import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';

// Mock AuthService per testing
class MockAuthService {
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  
  // Email/Password authentication
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate authentication delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_isValidEmail(email)) {
      return AuthResult(
        success: false,
        error: 'Invalid email format',
      );
    }
    
    if (password.length < 8) {
      return AuthResult(
        success: false,
        error: 'Password must be at least 8 characters',
      );
    }
    
    // Mock successful login
    if (email == 'test@example.com' && password == 'Test123!@#') {
      _isAuthenticated = true;
      _currentUser = UserModel(
        uid: 'test-uid-123',
        email: email,
        displayName: 'Test User',
        createdAt: DateTime.now(),
        isGuest: false,
        preferences: const UserPreferences(),
        stats: const UserStats(),
      );
      return AuthResult(
        success: true,
        user: _currentUser,
      );
    }
    
    return AuthResult(
      success: false,
      error: 'Invalid email or password',
    );
  }
  
  // Registration
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_isValidEmail(email)) {
      return AuthResult(
        success: false,
        error: 'Invalid email format',
      );
    }
    
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      return AuthResult(
        success: false,
        error: passwordError,
      );
    }
    
    if (displayName.isEmpty) {
      return AuthResult(
        success: false,
        error: 'Display name is required',
      );
    }
    
    // Mock successful registration
    _isAuthenticated = true;
    _currentUser = UserModel(
      uid: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      isGuest: false,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
    
    return AuthResult(
      success: true,
      user: _currentUser,
    );
  }
  
  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock Google sign in
    _isAuthenticated = true;
    _currentUser = UserModel(
      uid: 'google-user-123',
      email: 'google@example.com',
      displayName: 'Google User',
      photoURL: 'https://example.com/photo.jpg',
      createdAt: DateTime.now(),
      isGuest: false,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
    
    return AuthResult(
      success: true,
      user: _currentUser,
    );
  }
  
  // Apple Sign In
  Future<AuthResult> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock Apple sign in
    _isAuthenticated = true;
    _currentUser = UserModel(
      uid: 'apple-user-123',
      email: 'apple@privaterelay.appleid.com',
      displayName: 'Apple User',
      createdAt: DateTime.now(),
      isGuest: false,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
    
    return AuthResult(
      success: true,
      user: _currentUser,
    );
  }
  
  // Guest Sign In
  Future<AuthResult> signInAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    _isAuthenticated = true;
    _currentUser = UserModel(
      uid: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@gymbro.local',
      displayName: 'Guest User',
      createdAt: DateTime.now(),
      isGuest: true,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
    
    return AuthResult(
      success: true,
      user: _currentUser,
    );
  }
  
  // Sign Out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isAuthenticated = false;
    _currentUser = null;
  }
  
  // Password Reset
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!_isValidEmail(email)) {
      return AuthResult(
        success: false,
        error: 'Invalid email format',
      );
    }
    
    // Mock successful password reset
    return AuthResult(
      success: true,
      message: 'Password reset email sent to $email',
    );
  }
  
  // Delete Account
  Future<AuthResult> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentUser == null) {
      return AuthResult(
        success: false,
        error: 'No user logged in',
      );
    }
    
    if (_currentUser!.isGuest) {
      return AuthResult(
        success: false,
        error: 'Cannot delete guest account',
      );
    }
    
    _isAuthenticated = false;
    _currentUser = null;
    
    return AuthResult(
      success: true,
      message: 'Account deleted successfully',
    );
  }
  
  // Update Profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_currentUser == null) {
      return AuthResult(
        success: false,
        error: 'No user logged in',
      );
    }
    
    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoURL: photoURL ?? _currentUser!.photoURL,
    );
    
    return AuthResult(
      success: true,
      user: _currentUser,
    );
  }
  
  // Helpers
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final String? message;
  final UserModel? user;
  
  AuthResult({
    required this.success,
    this.error,
    this.message,
    this.user,
  });
}

void main() {
  group('🔐 Complete Auth Service Tests', () {
    late MockAuthService authService;
    
    setUp(() {
      authService = MockAuthService();
    });
    
    tearDown(() async {
      await authService.signOut();
    });
    
    group('📧 Email/Password Authentication', () {
      test('✅ Successful login with valid credentials', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
        );
        
        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, 'test@example.com');
        expect(authService.isAuthenticated, true);
      });
      
      test('❌ Failed login with invalid email', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'invalid-email',
          password: 'Test123!@#',
        );
        
        expect(result.success, false);
        expect(result.error, contains('Invalid email'));
        expect(authService.isAuthenticated, false);
      });
      
      test('❌ Failed login with short password', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'short',
        );
        
        expect(result.success, false);
        expect(result.error, contains('at least 8 characters'));
        expect(authService.isAuthenticated, false);
      });
      
      test('❌ Failed login with wrong credentials', () async {
        final result = await authService.signInWithEmailAndPassword(
          email: 'wrong@example.com',
          password: 'Wrong123!@#',
        );
        
        expect(result.success, false);
        expect(result.error, contains('Invalid email or password'));
        expect(authService.isAuthenticated, false);
      });
    });
    
    group('📝 User Registration', () {
      test('✅ Successful registration with valid data', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'NewUser123!@#',
          displayName: 'New User',
        );
        
        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, 'newuser@example.com');
        expect(result.user!.displayName, 'New User');
        expect(result.user!.isGuest, false);
        expect(authService.isAuthenticated, true);
      });
      
      test('❌ Failed registration - invalid email', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'invalid',
          password: 'Test123!@#',
          displayName: 'Test User',
        );
        
        expect(result.success, false);
        expect(result.error, contains('Invalid email'));
      });
      
      test('❌ Failed registration - weak password', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'weak',
          displayName: 'Test User',
        );
        
        expect(result.success, false);
        expect(result.error, contains('at least 8 characters'));
      });
      
      test('❌ Failed registration - no uppercase', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'test123!@#',
          displayName: 'Test User',
        );
        
        expect(result.success, false);
        expect(result.error, contains('uppercase letter'));
      });
      
      test('❌ Failed registration - no special char', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test12345',
          displayName: 'Test User',
        );
        
        expect(result.success, false);
        expect(result.error, contains('special character'));
      });
      
      test('❌ Failed registration - empty display name', () async {
        final result = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
          displayName: '',
        );
        
        expect(result.success, false);
        expect(result.error, contains('Display name is required'));
      });
    });
    
    group('🌐 Social Authentication', () {
      test('✅ Successful Google Sign In', () async {
        final result = await authService.signInWithGoogle();
        
        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, 'google@example.com');
        expect(result.user!.photoURL, isNotNull);
        expect(authService.isAuthenticated, true);
      });
      
      test('✅ Successful Apple Sign In', () async {
        final result = await authService.signInWithApple();
        
        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.email, contains('appleid.com'));
        expect(authService.isAuthenticated, true);
      });
      
      test('✅ Successful Guest Sign In', () async {
        final result = await authService.signInAsGuest();
        
        expect(result.success, true);
        expect(result.user, isNotNull);
        expect(result.user!.isGuest, true);
        expect(result.user!.email, contains('guest@'));
        expect(authService.isAuthenticated, true);
      });
    });
    
    group('🔑 Password Management', () {
      test('✅ Send password reset email - valid email', () async {
        final result = await authService.sendPasswordResetEmail('test@example.com');
        
        expect(result.success, true);
        expect(result.message, contains('Password reset email sent'));
      });
      
      test('❌ Send password reset - invalid email', () async {
        final result = await authService.sendPasswordResetEmail('invalid-email');
        
        expect(result.success, false);
        expect(result.error, contains('Invalid email'));
      });
    });
    
    group('👤 Profile Management', () {
      test('✅ Update profile - display name', () async {
        // First login
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
        );
        
        final result = await authService.updateProfile(
          displayName: 'Updated Name',
        );
        
        expect(result.success, true);
        expect(result.user!.displayName, 'Updated Name');
        expect(authService.currentUser!.displayName, 'Updated Name');
      });
      
      test('✅ Update profile - photo URL', () async {
        // First login
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
        );
        
        final result = await authService.updateProfile(
          photoURL: 'https://example.com/newphoto.jpg',
        );
        
        expect(result.success, true);
        expect(result.user!.photoURL, 'https://example.com/newphoto.jpg');
      });
      
      test('❌ Update profile - not logged in', () async {
        final result = await authService.updateProfile(
          displayName: 'New Name',
        );
        
        expect(result.success, false);
        expect(result.error, contains('No user logged in'));
      });
    });
    
    group('🗑️ Account Management', () {
      test('✅ Delete account - regular user', () async {
        // First login
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
        );
        
        final result = await authService.deleteAccount();
        
        expect(result.success, true);
        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);
      });
      
      test('❌ Delete account - guest user', () async {
        await authService.signInAsGuest();
        
        final result = await authService.deleteAccount();
        
        expect(result.success, false);
        expect(result.error, contains('Cannot delete guest account'));
      });
      
      test('❌ Delete account - not logged in', () async {
        final result = await authService.deleteAccount();
        
        expect(result.success, false);
        expect(result.error, contains('No user logged in'));
      });
    });
    
    group('🚪 Sign Out', () {
      test('✅ Sign out successfully', () async {
        // First login
        await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!@#',
        );
        
        expect(authService.isAuthenticated, true);
        
        await authService.signOut();
        
        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);
      });
    });
  });
}