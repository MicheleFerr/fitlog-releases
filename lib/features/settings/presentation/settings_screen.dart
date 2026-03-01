import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/migration_dialog.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/exercise_card_settings_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_search_mixin.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_workout_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_user_info_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_advanced_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_account_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_help_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_units_language_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_premium_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SettingsSearchMixin {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final currentUser = ref.watch(firebaseUserProvider);
    final l10n = context.l10n;

    // Auto-load fitness profile when user is authenticated
    ref.watch(fitnessProfileAutoLoadProvider);

    // Section keywords for filtering
    final keywords = buildSectionKeywords(l10n);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: l10n.settingsSearchHint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                style: context.textTheme.titleMedium,
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
          onPressed: () {
            if (_isSearching) {
              _stopSearch();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const SemanticIcon(
                icon: AppIcons.close,
                semanticLabel: 'Close search',
              ),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const SemanticIcon(
                icon: AppIcons.search,
                semanticLabel: 'Search settings',
              ),
              onPressed: _startSearch,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show "no results" message if searching and nothing matches
            if (_searchQuery.isNotEmpty && !anyMatches(_searchQuery, keywords))
              _buildNoResultsMessage(context),

            // User Info Section
            if (sectionMatches(_searchQuery, keywords['account']!)) ...[
              SettingsUserInfoSection(currentUser: currentUser),
              const SizedBox(height: 24),
            ],

            // Appearance Settings
            if (sectionMatches(_searchQuery, keywords['appearance']!)) ...[
              SettingsAppearanceSection(config: config),
              const SizedBox(height: 24),
            ],

            // Workout Settings
            if (sectionMatches(_searchQuery, keywords['workout']!)) ...[
              SettingsWorkoutSection(config: config),
              const SizedBox(height: 24),
            ],

            // Exercise Card Settings
            if (sectionMatches(
              _searchQuery,
              keywords['exerciseCard']!,
            )) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ExerciseCardSettingsSection(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Units & Language
            if (sectionMatches(
              _searchQuery,
              keywords['unitsLanguage']!,
            )) ...[
              SettingsUnitsLanguageSection(config: config),
              const SizedBox(height: 24),
            ],

            // Data & Sync
            if (sectionMatches(_searchQuery, keywords['data']!)) ...[
              const SettingsDataSection(),
              const SizedBox(height: 24),
            ],

            // Premium CTA — shows "free during beta" with upgrade path ready
            if (sectionMatches(_searchQuery, keywords['premium']!)) ...[
              const SettingsPremiumSection(),
              const SizedBox(height: 24),
            ],

            // Help & Info
            if (sectionMatches(_searchQuery, keywords['help']!)) ...[
              const SettingsHelpSection(),
              const SizedBox(height: 24),
            ],

            // Advanced Settings
            if (sectionMatches(_searchQuery, keywords['advanced']!)) ...[
              SettingsAdvancedSection(config: config),
              const SizedBox(height: 24),
            ],

            // Account Actions (at bottom for safety - destructive actions)
            if (sectionMatches(_searchQuery, keywords['accountActions']!))
              const SettingsAccountSection(),

            // DEBUG: Migration tool (ferrara-michele only)
            if (currentUser.value?.email?.toString().contains(
                      'ferrara-michele',
                    ) ==
                    true &&
                sectionMatches(_searchQuery, keywords['debug']!))
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: FilledButton.tonalIcon(
                    onPressed: () => showMigrationDialog(context, ref),
                    icon: const SemanticIcon(
                      icon: AppIcons.analytics,
                      semanticLabel: 'Analytics',
                    ),
                    label: Text(context.l10n.migrateWorkoutHistory),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.primary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: context.colors.primary,
                    ),
                  ),
                ),
              ),

            // Bottom padding for tab bar overlay
            const TabBarBottomPadding(),
          ],
        ),
      ),
    );
  }

  /// Build "no results" message widget
  Widget _buildNoResultsMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.searchOff,
              size: 48,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '${context.l10n.settingsSearchNoResults} "$_searchQuery"',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
