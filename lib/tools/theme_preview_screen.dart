/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: tools
/// 🎯 Feature: development
/// 🔧 Type: screen
///
/// Theme Preview Screen - Hot Reload Testing Tool
///
/// **Developer Tool Only** - Non incluso in production
///
/// Permette di:
/// - Testare rapidamente light/dark theme
/// - Vedere tutti i component side-by-side
/// - Verificare semantic colors
/// - Testare spacing system
/// - Debug visual issues
///
/// ## Utilizzo:
///
/// 1. Naviga a questa screen durante sviluppo
/// 2. Tap su brightness icon per toggle light/dark
/// 3. Hot reload dopo modifiche al theme
/// 4. Verifica visual consistency
///
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Theme Preview Screen - Developer Tool
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Preview',
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🎨 Theme Preview'),
          actions: [
            IconButton(
              icon: Icon(
                _themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              ),
              onPressed: _toggleTheme,
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            // Section: Colors
            _buildSection(
              context,
              title: '🎨 Colors',
              children: [
                _ColorPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Semantic Colors
            _buildSection(
              context,
              title: '🏷️ Semantic Colors',
              children: [
                _SemanticColorPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Typography
            _buildSection(
              context,
              title: '✍️ Typography',
              children: [
                _TypographyPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Spacing
            _buildSection(
              context,
              title: '📏 Spacing',
              children: [
                _SpacingPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Buttons
            _buildSection(
              context,
              title: '🔘 Buttons',
              children: [
                _ButtonsPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Cards
            _buildSection(
              context,
              title: '🃏 Cards',
              children: [
                _CardsPreview(),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionSpacing),

            // Section: Loading & States
            _buildSection(
              context,
              title: '⏳ Loading & States',
              children: [
                _LoadingPreview(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }
}

// ========================================
// Color Preview
// ========================================
class _ColorPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _colorSwatch(context, 'primary', context.colors.primary),
        _colorSwatch(context, 'onPrimary', context.colors.onPrimary),
        _colorSwatch(context, 'secondary', context.colors.secondary),
        _colorSwatch(context, 'onSecondary', context.colors.onSecondary),
        _colorSwatch(context, 'tertiary', context.colors.tertiary),
        _colorSwatch(context, 'surface', context.colors.surface),
        _colorSwatch(context, 'onSurface', context.colors.onSurface),
        _colorSwatch(context, 'error', context.colors.error),
        _colorSwatch(context, 'onError', context.colors.onError),
      ],
    );
  }

  Widget _colorSwatch(BuildContext context, String name, Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            color: _getContrastColor(color),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// ========================================
// Semantic Color Preview
// ========================================
class _SemanticColorPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _semanticCard(context, 'Success', context.successColor, context.textOnSuccess),
        SizedBox(height: AppSpacing.xs),
        _semanticCard(context, 'Error', context.errorColor, context.textOnError),
        SizedBox(height: AppSpacing.xs),
        _semanticCard(context, 'Warning', context.warningColor, context.textOnWarning),
        SizedBox(height: AppSpacing.xs),
        _semanticCard(context, 'Info', context.infoColor, context.textOnInfo),
      ],
    );
  }

  Widget _semanticCard(BuildContext context, String label, Color bg, Color fg) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Typography Preview
// ========================================
class _TypographyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Headline Large', style: context.textTheme.headlineLarge),
        Text('Headline Medium', style: context.textTheme.headlineMedium),
        Text('Headline Small', style: context.textTheme.headlineSmall),
        SizedBox(height: AppSpacing.sm),
        Text('Title Large', style: context.textTheme.titleLarge),
        Text('Title Medium', style: context.textTheme.titleMedium),
        Text('Title Small', style: context.textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        Text('Body Large', style: context.textTheme.bodyLarge),
        Text('Body Medium', style: context.textTheme.bodyMedium),
        Text('Body Small', style: context.textTheme.bodySmall),
      ],
    );
  }
}

// ========================================
// Spacing Preview
// ========================================
class _SpacingPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacingBox(context, 'xxs (4px)', AppSpacing.xxs),
        _spacingBox(context, 'xs (8px)', AppSpacing.xs),
        _spacingBox(context, 'sm (12px)', AppSpacing.sm),
        _spacingBox(context, 'md (16px)', AppSpacing.md),
        _spacingBox(context, 'lg (20px)', AppSpacing.lg),
        _spacingBox(context, 'xl (24px)', AppSpacing.xl),
        _spacingBox(context, 'xxl (32px)', AppSpacing.xxl),
      ],
    );
  }

  Widget _spacingBox(BuildContext context, String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: size,
            height: 24,
            color: context.colors.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(label, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ========================================
// Buttons Preview
// ========================================
class _ButtonsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('Elevated'),
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('Filled'),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Text'),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite),
        ),
      ],
    );
  }
}

// ========================================
// Cards Preview
// ========================================
class _CardsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standard Card',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'This is a standard card with default padding.',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 4,
          child: Padding(
            padding: AppSpacing.card,
            child: Row(
              children: [
                Icon(Icons.info, color: context.colors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Elevated Card',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// Loading Preview
// ========================================
class _LoadingPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        LoadingIndicator(),
        SizedBox(width: 16),
        LoadingIndicator(size: 32),
        SizedBox(width: 16),
        LoadingIndicator(size: 16),
      ],
    );
  }
}
