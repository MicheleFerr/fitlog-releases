import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Localization Provider implementation for testing
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(const Locale('en', 'US'));
  
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('it', 'IT'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
  ];
  
  static const String _localeKey = 'app_locale';
  
  // Get current locale
  Locale get currentLocale => state;
  
  // Get language code
  String get languageCode => state.languageCode;
  
  // Get country code
  String? get countryCode => state.countryCode;
  
  // Get language name
  String get languageName {
    switch (state.languageCode) {
      case 'en':
        return 'English';
      case 'it':
        return 'Italiano';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'Unknown';
    }
  }
  
  // Get native language name
  String get nativeLanguageName {
    switch (state.languageCode) {
      case 'en':
        return 'English';
      case 'it':
        return 'Italiano';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return state.languageCode.toUpperCase();
    }
  }
  
  // Get flag emoji
  String get flagEmoji {
    final country = state.countryCode?.toUpperCase() ?? '';
    if (country.length != 2) return '🌐';
    
    final flag = country.codeUnits.map((code) => 
      String.fromCharCode(code + 127397)
    ).join();
    
    return flag;
  }
  
  // Set locale
  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) {
      throw Exception('Unsupported locale: $locale');
    }
    
    state = locale;
    _saveLocalePreference(locale);
  }
  
  // Set locale by language code
  void setLanguage(String languageCode) {
    final locale = supportedLocales.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'),
    );
    
    setLocale(locale);
  }
  
  // Load saved locale preference
  Future<void> loadLocale() async {
    // Simulate loading from storage
    await Future.delayed(const Duration(milliseconds: 50));
    
    // For testing, default to English
    state = const Locale('en', 'US');
  }
  
  // Save locale preference
  Future<void> _saveLocalePreference(Locale locale) async {
    // Simulate saving to storage
    await Future.delayed(const Duration(milliseconds: 10));
  }
  
  // Check if locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((l) => 
      l.languageCode == locale.languageCode
    );
  }
  
  // Get closest supported locale
  Locale getClosestSupported(Locale locale) {
    // First try exact match
    if (supportedLocales.contains(locale)) {
      return locale;
    }
    
    // Then try language match
    final languageMatch = supportedLocales.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => const Locale('en', 'US'),
    );
    
    return languageMatch;
  }
  
  // Reset to default
  void resetToDefault() {
    setLocale(const Locale('en', 'US'));
  }
}

// Translation helper class
class TranslationHelper {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'GymBro',
      'welcome': 'Welcome',
      'start_workout': 'Start Workout',
      'rest_timer': 'Rest Timer',
      'exercises': 'Exercises',
      'settings': 'Settings',
      'profile': 'Profile',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      'this_month': 'This Month',
    },
    'it': {
      'app_name': 'GymBro',
      'welcome': 'Benvenuto',
      'start_workout': 'Inizia Allenamento',
      'rest_timer': 'Timer Riposo',
      'exercises': 'Esercizi',
      'settings': 'Impostazioni',
      'profile': 'Profilo',
      'logout': 'Esci',
      'save': 'Salva',
      'cancel': 'Annulla',
      'delete': 'Elimina',
      'edit': 'Modifica',
      'add': 'Aggiungi',
      'search': 'Cerca',
      'filter': 'Filtra',
      'sort': 'Ordina',
      'today': 'Oggi',
      'yesterday': 'Ieri',
      'this_week': 'Questa Settimana',
      'this_month': 'Questo Mese',
    },
    'es': {
      'app_name': 'GymBro',
      'welcome': 'Bienvenido',
      'start_workout': 'Comenzar Entrenamiento',
      'rest_timer': 'Temporizador de Descanso',
      'exercises': 'Ejercicios',
      'settings': 'Configuración',
      'profile': 'Perfil',
      'logout': 'Cerrar Sesión',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'add': 'Añadir',
      'search': 'Buscar',
      'filter': 'Filtrar',
      'sort': 'Ordenar',
      'today': 'Hoy',
      'yesterday': 'Ayer',
      'this_week': 'Esta Semana',
      'this_month': 'Este Mes',
    },
  };
  
  // Get translation
  static String translate(String key, String languageCode) {
    final translations = _translations[languageCode] ?? _translations['en']!;
    return translations[key] ?? key;
  }
  
  // Get all keys
  static Set<String> get allKeys {
    return _translations['en']!.keys.toSet();
  }
  
  // Check if key exists
  static bool hasKey(String key) {
    return _translations['en']!.containsKey(key);
  }
  
  // Get available languages
  static List<String> get availableLanguages {
    return _translations.keys.toList();
  }
  
  // Format with parameters
  static String format(String template, Map<String, dynamic> params) {
    String result = template;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
  
  // Pluralize
  static String pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
}

void main() {
  group('🌍 Localization Provider Tests', () {
    late LocalizationNotifier notifier;
    late ProviderContainer container;
    
    setUp(() {
      notifier = LocalizationNotifier();
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('🌐 Locale Management', () {
      test('✅ Initial locale is English', () {
        expect(notifier.currentLocale, const Locale('en', 'US'));
        expect(notifier.languageCode, 'en');
        expect(notifier.countryCode, 'US');
        expect(notifier.languageName, 'English');
      });
      
      test('✅ Set Italian locale', () {
        notifier.setLocale(const Locale('it', 'IT'));
        
        expect(notifier.currentLocale, const Locale('it', 'IT'));
        expect(notifier.languageCode, 'it');
        expect(notifier.countryCode, 'IT');
        expect(notifier.languageName, 'Italiano');
        expect(notifier.nativeLanguageName, 'Italiano');
      });
      
      test('✅ Set Spanish locale', () {
        notifier.setLocale(const Locale('es', 'ES'));
        
        expect(notifier.currentLocale, const Locale('es', 'ES'));
        expect(notifier.languageName, 'Español');
      });
      
      test('✅ Set French locale', () {
        notifier.setLocale(const Locale('fr', 'FR'));
        
        expect(notifier.currentLocale, const Locale('fr', 'FR'));
        expect(notifier.languageName, 'Français');
      });
      
      test('✅ Set German locale', () {
        notifier.setLocale(const Locale('de', 'DE'));
        
        expect(notifier.currentLocale, const Locale('de', 'DE'));
        expect(notifier.languageName, 'Deutsch');
      });
      
      test('✅ Set language by code', () {
        notifier.setLanguage('it');
        expect(notifier.languageCode, 'it');
        
        notifier.setLanguage('es');
        expect(notifier.languageCode, 'es');
      });
      
      test('❌ Reject unsupported locale', () {
        expect(
          () => notifier.setLocale(const Locale('zh', 'CN')),
          throwsException,
        );
      });
      
      test('✅ Load saved locale', () async {
        await notifier.loadLocale();
        expect(notifier.currentLocale, const Locale('en', 'US'));
      });
      
      test('✅ Reset to default', () {
        notifier.setLocale(const Locale('it', 'IT'));
        notifier.resetToDefault();
        
        expect(notifier.currentLocale, const Locale('en', 'US'));
      });
    });
    
    group('🏳️ Flag Emojis', () {
      test('✅ Get flag for US', () {
        notifier.setLocale(const Locale('en', 'US'));
        expect(notifier.flagEmoji, '🇺🇸');
      });
      
      test('✅ Get flag for Italy', () {
        notifier.setLocale(const Locale('it', 'IT'));
        expect(notifier.flagEmoji, '🇮🇹');
      });
      
      test('✅ Get flag for Spain', () {
        notifier.setLocale(const Locale('es', 'ES'));
        expect(notifier.flagEmoji, '🇪🇸');
      });
      
      test('✅ Get flag for France', () {
        notifier.setLocale(const Locale('fr', 'FR'));
        expect(notifier.flagEmoji, '🇫🇷');
      });
      
      test('✅ Get flag for Germany', () {
        notifier.setLocale(const Locale('de', 'DE'));
        expect(notifier.flagEmoji, '🇩🇪');
      });
    });
    
    group('🌍 Locale Support', () {
      test('✅ Check supported locales', () {
        expect(notifier.isSupported(const Locale('en', 'US')), true);
        expect(notifier.isSupported(const Locale('it', 'IT')), true);
        expect(notifier.isSupported(const Locale('es', 'ES')), true);
        expect(notifier.isSupported(const Locale('fr', 'FR')), true);
        expect(notifier.isSupported(const Locale('de', 'DE')), true);
      });
      
      test('✅ Check unsupported locale', () {
        expect(notifier.isSupported(const Locale('zh', 'CN')), false);
        expect(notifier.isSupported(const Locale('ja', 'JP')), false);
      });
      
      test('✅ Get closest supported locale', () {
        // Exact match
        expect(
          notifier.getClosestSupported(const Locale('it', 'IT')),
          const Locale('it', 'IT'),
        );
        
        // Language match
        expect(
          notifier.getClosestSupported(const Locale('en', 'GB')),
          const Locale('en', 'US'),
        );
        
        // No match - default to English
        expect(
          notifier.getClosestSupported(const Locale('zh', 'CN')),
          const Locale('en', 'US'),
        );
      });
    });
    
    group('🔤 Translation Helper', () {
      test('✅ Get English translations', () {
        expect(TranslationHelper.translate('welcome', 'en'), 'Welcome');
        expect(TranslationHelper.translate('start_workout', 'en'), 'Start Workout');
        expect(TranslationHelper.translate('settings', 'en'), 'Settings');
      });
      
      test('✅ Get Italian translations', () {
        expect(TranslationHelper.translate('welcome', 'it'), 'Benvenuto');
        expect(TranslationHelper.translate('start_workout', 'it'), 'Inizia Allenamento');
        expect(TranslationHelper.translate('settings', 'it'), 'Impostazioni');
      });
      
      test('✅ Get Spanish translations', () {
        expect(TranslationHelper.translate('welcome', 'es'), 'Bienvenido');
        expect(TranslationHelper.translate('start_workout', 'es'), 'Comenzar Entrenamiento');
        expect(TranslationHelper.translate('settings', 'es'), 'Configuración');
      });
      
      test('✅ Fallback for missing translation', () {
        expect(TranslationHelper.translate('non_existent_key', 'it'), 'non_existent_key');
      });
      
      test('✅ Get all translation keys', () {
        final keys = TranslationHelper.allKeys;
        
        expect(keys.contains('welcome'), true);
        expect(keys.contains('settings'), true);
        expect(keys.contains('start_workout'), true);
        expect(keys.length, greaterThan(15));
      });
      
      test('✅ Check if key exists', () {
        expect(TranslationHelper.hasKey('welcome'), true);
        expect(TranslationHelper.hasKey('settings'), true);
        expect(TranslationHelper.hasKey('non_existent'), false);
      });
      
      test('✅ Get available languages', () {
        final languages = TranslationHelper.availableLanguages;
        
        expect(languages.contains('en'), true);
        expect(languages.contains('it'), true);
        expect(languages.contains('es'), true);
        expect(languages.length, greaterThanOrEqualTo(3));
      });
      
      test('✅ Format string with parameters', () {
        final result = TranslationHelper.format(
          'Hello {name}, you have {count} messages',
          {'name': 'John', 'count': 5},
        );
        
        expect(result, 'Hello John, you have 5 messages');
      });
      
      test('✅ Pluralize strings', () {
        expect(TranslationHelper.pluralize(1, 'item', 'items'), 'item');
        expect(TranslationHelper.pluralize(0, 'item', 'items'), 'items');
        expect(TranslationHelper.pluralize(2, 'item', 'items'), 'items');
        expect(TranslationHelper.pluralize(100, 'item', 'items'), 'items');
      });
    });
    
    group('🌐 Supported Locales', () {
      test('✅ All supported locales', () {
        expect(LocalizationNotifier.supportedLocales.length, 5);
        expect(
          LocalizationNotifier.supportedLocales,
          contains(const Locale('en', 'US')),
        );
        expect(
          LocalizationNotifier.supportedLocales,
          contains(const Locale('it', 'IT')),
        );
      });
    });
  });
}