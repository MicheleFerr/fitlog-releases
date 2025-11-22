import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedLanguage = 'en';
  String _currentTitle = 'Choose your language';
  String _currentSubtitle = 'Select your preferred language for the app';
  String _currentButtonText = 'Continue';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Auto-detect device language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectDeviceLanguage();
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _detectDeviceLanguage() {
    final deviceLocale = Localizations.localeOf(context);
    final detectedLanguage = deviceLocale.languageCode == 'it' ? 'it' : 'en';

    setState(() {
      _selectedLanguage = detectedLanguage;
      _updateTexts(detectedLanguage);
    });
  }

  void _updateTexts(String languageCode) {
    setState(() {
      if (languageCode == 'it') {
        _currentTitle = 'Scegli la tua lingua';
        _currentSubtitle = 'Seleziona la tua lingua preferita per l\'app';
        _currentButtonText = 'Continua';
      } else {
        _currentTitle = 'Choose your language';
        _currentSubtitle = 'Select your preferred language for the app';
        _currentButtonText = 'Continue';
      }
    });
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
      _updateTexts(languageCode);
    });
  }

  Future<void> _confirmLanguage() async {
    // Save language to Hive
    final languageCode = _selectedLanguage;
    final countryCode = _selectedLanguage == 'it' ? 'IT' : 'US';

    await ref.read(appConfigProvider.notifier).setLanguage(languageCode, countryCode);

    // Navigate to onboarding
    if (mounted) {
      context.goNamed('onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SemanticIcon(
  icon: AppIcons.language,
  semanticLabel: 'Language',
  size: AppIconSize.medium,
  color: colorScheme.onPrimary,
),
                  ),

                  const SizedBox(height: 48),

                  // Title
                  Text(
                    _currentTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    _currentSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 18,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 64),

                  // Language options
                  Column(
                    children: [
                      // Italian option
                      _buildLanguageOption(
                        '🇮🇹',
                        'Italiano',
                        'it',
                        colorScheme,
                        theme,
                      ),

                      const SizedBox(height: 16),

                      // English option
                      _buildLanguageOption(
                        '🇬🇧',
                        'English',
                        'en',
                        colorScheme,
                        theme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 64),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _confirmLanguage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentButtonText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String flag,
    String language,
    String languageCode,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isSelected = _selectedLanguage == languageCode;

    return GestureDetector(
      onTap: () => _selectLanguage(languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surface,
          border: Border.all(
            color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
        ),
        child: Row(
          children: [
            // Flag
            Text(
              flag,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 32),
            ),

            const SizedBox(width: 20),

            // Language name
            Expanded(
              child: Text(
                language,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                AppIcons.complete,
                color: colorScheme.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
