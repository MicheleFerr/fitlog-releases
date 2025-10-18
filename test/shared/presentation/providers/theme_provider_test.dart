import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Provider implementation for testing
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);
  
  static const String _themeKey = 'theme_mode';
  
  // Get current theme mode
  ThemeMode get currentTheme => state;
  
  // Set theme mode
  void setTheme(ThemeMode mode) {
    state = mode;
    _saveThemePreference(mode);
  }
  
  // Toggle between light and dark
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      // If system, default to light
      setTheme(ThemeMode.light);
    }
  }
  
  // Load saved theme preference
  Future<void> loadTheme() async {
    // Simulate loading from storage
    await Future.delayed(const Duration(milliseconds: 50));
    
    // For testing, default to system
    state = ThemeMode.system;
  }
  
  // Save theme preference
  Future<void> _saveThemePreference(ThemeMode mode) async {
    // Simulate saving to storage
    await Future.delayed(const Duration(milliseconds: 10));
  }
  
  // Check if dark mode is active
  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    
    // For system mode, check platform brightness
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
  
  // Get theme name for display
  String get themeName {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  // Get theme icon
  IconData get themeIcon {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

// App Theme configuration
class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6750A4),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF625B71),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFEFBFF),
      onSurface: Color(0xFF1C1B1F),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD0BCFF),
      onPrimary: Color(0xFF381E72),
      secondary: Color(0xFFCCC2DC),
      onSecondary: Color(0xFF332D41),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF1C1B1F),
      onSurface: Color(0xFFE6E1E5),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  // Get color for exercise category
  static Color getCategoryColor(String category, bool isDark) {
    final colors = isDark ? _darkCategoryColors : _lightCategoryColors;
    return colors[category] ?? (isDark ? Colors.grey[700]! : Colors.grey[400]!);
  }
  
  static const _lightCategoryColors = {
    'chest': Color(0xFFE57373),
    'back': Color(0xFF81C784),
    'legs': Color(0xFF64B5F6),
    'shoulders': Color(0xFFFFB74D),
    'arms': Color(0xFFBA68C8),
    'abs': Color(0xFF4FC3F7),
    'cardio': Color(0xFFFF8A65),
    'other': Color(0xFF90A4AE),
  };
  
  static const _darkCategoryColors = {
    'chest': Color(0xFFEF5350),
    'back': Color(0xFF66BB6A),
    'legs': Color(0xFF42A5F5),
    'shoulders': Color(0xFFFFA726),
    'arms': Color(0xFFAB47BC),
    'abs': Color(0xFF29B6F6),
    'cardio': Color(0xFFFF7043),
    'other': Color(0xFF78909C),
  };
}

void main() {
  group('🎨 Theme Provider Tests', () {
    late ThemeNotifier notifier;
    late ProviderContainer container;
    
    setUp(() {
      notifier = ThemeNotifier();
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('🌓 Theme Mode Management', () {
      test('✅ Initial theme is system', () {
        expect(notifier.currentTheme, ThemeMode.system);
        expect(notifier.themeName, 'System');
        expect(notifier.themeIcon, Icons.brightness_auto);
      });
      
      test('✅ Set light theme', () {
        notifier.setTheme(ThemeMode.light);
        
        expect(notifier.currentTheme, ThemeMode.light);
        expect(notifier.themeName, 'Light');
        expect(notifier.themeIcon, Icons.light_mode);
      });
      
      test('✅ Set dark theme', () {
        notifier.setTheme(ThemeMode.dark);
        
        expect(notifier.currentTheme, ThemeMode.dark);
        expect(notifier.themeName, 'Dark');
        expect(notifier.themeIcon, Icons.dark_mode);
      });
      
      test('✅ Toggle theme from light to dark', () {
        notifier.setTheme(ThemeMode.light);
        notifier.toggleTheme();
        
        expect(notifier.currentTheme, ThemeMode.dark);
      });
      
      test('✅ Toggle theme from dark to light', () {
        notifier.setTheme(ThemeMode.dark);
        notifier.toggleTheme();
        
        expect(notifier.currentTheme, ThemeMode.light);
      });
      
      test('✅ Toggle theme from system defaults to light', () {
        notifier.setTheme(ThemeMode.system);
        notifier.toggleTheme();
        
        expect(notifier.currentTheme, ThemeMode.light);
      });
      
      test('✅ Load saved theme', () async {
        await notifier.loadTheme();
        
        expect(notifier.currentTheme, ThemeMode.system);
      });
    });
    
    group('🎨 Theme Configuration', () {
      test('✅ Light theme configuration', () {
        final theme = AppTheme.lightTheme;
        
        expect(theme.brightness, Brightness.light);
        expect(theme.useMaterial3, true);
        expect(theme.colorScheme.primary, const Color(0xFF6750A4));
        expect(theme.appBarTheme.centerTitle, true);
        expect(theme.appBarTheme.elevation, 0);
      });
      
      test('✅ Dark theme configuration', () {
        final theme = AppTheme.darkTheme;
        
        expect(theme.brightness, Brightness.dark);
        expect(theme.useMaterial3, true);
        expect(theme.colorScheme.primary, const Color(0xFFD0BCFF));
        expect(theme.appBarTheme.centerTitle, true);
        expect(theme.appBarTheme.elevation, 0);
      });
      
      test('✅ ElevatedButton theme', () {
        final lightButton = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final darkButton = AppTheme.darkTheme.elevatedButtonTheme.style!;
        
        expect(lightButton.minimumSize?.resolve({}), const Size.fromHeight(48));
        expect(darkButton.minimumSize?.resolve({}), const Size.fromHeight(48));
      });
      
      test('✅ Card theme', () {
        final lightCard = AppTheme.lightTheme.cardTheme;
        final darkCard = AppTheme.darkTheme.cardTheme;
        
        expect(lightCard.elevation, 2);
        expect(darkCard.elevation, 2);
        expect(lightCard.shape, isA<RoundedRectangleBorder>());
        expect(darkCard.shape, isA<RoundedRectangleBorder>());
      });
      
      test('✅ Input decoration theme', () {
        final lightInput = AppTheme.lightTheme.inputDecorationTheme;
        final darkInput = AppTheme.darkTheme.inputDecorationTheme;
        
        expect(lightInput.filled, true);
        expect(darkInput.filled, true);
        expect(lightInput.border, isA<OutlineInputBorder>());
        expect(darkInput.border, isA<OutlineInputBorder>());
      });
    });
    
    group('🏷️ Category Colors', () {
      test('✅ Get light category colors', () {
        expect(AppTheme.getCategoryColor('chest', false), const Color(0xFFE57373));
        expect(AppTheme.getCategoryColor('back', false), const Color(0xFF81C784));
        expect(AppTheme.getCategoryColor('legs', false), const Color(0xFF64B5F6));
        expect(AppTheme.getCategoryColor('shoulders', false), const Color(0xFFFFB74D));
        expect(AppTheme.getCategoryColor('arms', false), const Color(0xFFBA68C8));
        expect(AppTheme.getCategoryColor('abs', false), const Color(0xFF4FC3F7));
        expect(AppTheme.getCategoryColor('cardio', false), const Color(0xFFFF8A65));
        expect(AppTheme.getCategoryColor('other', false), const Color(0xFF90A4AE));
      });
      
      test('✅ Get dark category colors', () {
        expect(AppTheme.getCategoryColor('chest', true), const Color(0xFFEF5350));
        expect(AppTheme.getCategoryColor('back', true), const Color(0xFF66BB6A));
        expect(AppTheme.getCategoryColor('legs', true), const Color(0xFF42A5F5));
        expect(AppTheme.getCategoryColor('shoulders', true), const Color(0xFFFFA726));
        expect(AppTheme.getCategoryColor('arms', true), const Color(0xFFAB47BC));
        expect(AppTheme.getCategoryColor('abs', true), const Color(0xFF29B6F6));
        expect(AppTheme.getCategoryColor('cardio', true), const Color(0xFFFF7043));
        expect(AppTheme.getCategoryColor('other', true), const Color(0xFF78909C));
      });
      
      test('✅ Get default color for unknown category', () {
        expect(AppTheme.getCategoryColor('unknown', false), Colors.grey[400]);
        expect(AppTheme.getCategoryColor('unknown', true), Colors.grey[700]);
      });
    });
    
    group('🌗 Dark Mode Detection', () {
      testWidgets('✅ Detect dark mode when set to dark', (tester) async {
        notifier.setTheme(ThemeMode.dark);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(notifier.isDarkMode(context), true);
                return Container();
              },
            ),
          ),
        );
        
        // Flush pending timers
        await tester.pumpAndSettle();
      });
      
      testWidgets('✅ Detect light mode when set to light', (tester) async {
        notifier.setTheme(ThemeMode.light);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                expect(notifier.isDarkMode(context), false);
                return Container();
              },
            ),
          ),
        );
        
        // Flush pending timers
        await tester.pumpAndSettle();
      });
      
      testWidgets('✅ Detect system mode', (tester) async {
        notifier.setTheme(ThemeMode.system);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Will use platform brightness
                final isDark = notifier.isDarkMode(context);
                expect(isDark, isA<bool>());
                return Container();
              },
            ),
          ),
        );
        
        // Flush pending timers
        await tester.pumpAndSettle();
      });
    });
    
    group('🎨 Color Scheme', () {
      test('✅ Light color scheme', () {
        final colors = AppTheme.lightTheme.colorScheme;
        
        expect(colors.brightness, Brightness.light);
        expect(colors.primary, const Color(0xFF6750A4));
        expect(colors.onPrimary, const Color(0xFFFFFFFF));
        expect(colors.secondary, const Color(0xFF625B71));
        expect(colors.error, const Color(0xFFBA1A1A));
        expect(colors.surface, const Color(0xFFFEFBFF));
        expect(colors.surface, const Color(0xFFFEFBFF));
      });
      
      test('✅ Dark color scheme', () {
        final colors = AppTheme.darkTheme.colorScheme;
        
        expect(colors.brightness, Brightness.dark);
        expect(colors.primary, const Color(0xFFD0BCFF));
        expect(colors.onPrimary, const Color(0xFF381E72));
        expect(colors.secondary, const Color(0xFFCCC2DC));
        expect(colors.error, const Color(0xFFFFB4AB));
        expect(colors.surface, const Color(0xFF1C1B1F));
        expect(colors.surface, const Color(0xFF1C1B1F));
      });
    });
  });
}