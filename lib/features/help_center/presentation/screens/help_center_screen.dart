/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/help_center/presentation/screens
/// 🎯 Feature: help_center
/// 🔧 Type: screen
///
/// Help Center Screen - Main help/FAQ screen with category list
///
/// **Features**:
/// - Category list with icons (12 categories)
/// - Navigate to FAQ list per category
/// - Localized content (IT/EN)
/// - Comprehensive coverage of ALL app features
library;

import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/help_center/data/faq_data.dart';
import 'package:gymbro_flutter_new/features/help_center/domain/entities/faq_category.dart';
import 'package:gymbro_flutter_new/features/help_center/presentation/screens/faq_list_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Help Center Screen - displays FAQ categories
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.helpCenter),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Category List (better for 12+ categories)
            _buildCategoryList(context),
          ],
        ),
      ),
    );
  }

  /// Build header with title and description
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.helpCenterWelcome,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.helpCenterDescription,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build category list (list layout for better readability with 12 categories)
  Widget _buildCategoryList(BuildContext context) {
    final categories = FAQData.categories;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _CategoryTile(
          category: categories[index],
          onTap: () => _navigateToCategory(context, categories[index]),
        );
      },
    );
  }

  /// Navigate to FAQ list for category
  void _navigateToCategory(BuildContext context, FAQCategory category) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FAQListScreen(category: category),
      ),
    );
  }
}

/// Category tile widget (list item style)
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
  });

  final FAQCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Get localized title and description
    final title = _getLocalizedString(context, category.titleKey);
    final description = _getLocalizedString(context, category.descriptionKey);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SemanticIcon(
            icon: category.icon,
            semanticLabel: title,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
        ),
        title: Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          AppIcons.chevronRight,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Get localized string from key - covers ALL 12 categories
  String _getLocalizedString(BuildContext context, String key) {
    final l10n = context.l10n;
    final strings = {
      // Getting Started
      'helpCategoryGettingStarted': l10n.helpCategoryGettingStarted,
      'helpCategoryGettingStartedDesc': l10n.helpCategoryGettingStartedDesc,
      // Workouts
      'helpCategoryWorkouts': l10n.helpCategoryWorkouts,
      'helpCategoryWorkoutsDesc': l10n.helpCategoryWorkoutsDesc,
      // Exercise Tracking
      'helpCategoryExerciseTracking': l10n.helpCategoryExerciseTracking,
      'helpCategoryExerciseTrackingDesc': l10n.helpCategoryExerciseTrackingDesc,
      // Advanced Techniques
      'helpCategoryAdvancedTechniques': l10n.helpCategoryAdvancedTechniques,
      'helpCategoryAdvancedTechniquesDesc':
          l10n.helpCategoryAdvancedTechniquesDesc,
      // Timer
      'helpCategoryTimer': l10n.helpCategoryTimer,
      'helpCategoryTimerDesc': l10n.helpCategoryTimerDesc,
      // Analytics
      'helpCategoryAnalytics': l10n.helpCategoryAnalytics,
      'helpCategoryAnalyticsDesc': l10n.helpCategoryAnalyticsDesc,
      // Premium
      'helpCategoryPremium': l10n.helpCategoryPremium,
      'helpCategoryPremiumDesc': l10n.helpCategoryPremiumDesc,
      // Account
      'helpCategoryAccount': l10n.helpCategoryAccount,
      'helpCategoryAccountDesc': l10n.helpCategoryAccountDesc,
      // Profile
      'helpCategoryProfile': l10n.helpCategoryProfile,
      'helpCategoryProfileDesc': l10n.helpCategoryProfileDesc,
      // Settings
      'helpCategorySettings': l10n.helpCategorySettings,
      'helpCategorySettingsDesc': l10n.helpCategorySettingsDesc,
      // Health Sync
      'helpCategoryHealthSync': l10n.helpCategoryHealthSync,
      'helpCategoryHealthSyncDesc': l10n.helpCategoryHealthSyncDesc,
      // Troubleshooting
      'helpCategoryTroubleshooting': l10n.helpCategoryTroubleshooting,
      'helpCategoryTroubleshootingDesc': l10n.helpCategoryTroubleshootingDesc,
      // Legacy keys (backwards compatibility)
      'helpCategoryAppUsage': l10n.helpCategoryGettingStarted,
      'helpCategoryAppUsageDesc': l10n.helpCategoryGettingStartedDesc,
      'helpCategoryProgress': l10n.helpCategoryAnalytics,
      'helpCategoryProgressDesc': l10n.helpCategoryAnalyticsDesc,
    };
    return strings[key] ?? key;
  }
}
