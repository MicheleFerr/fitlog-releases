import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/core/providers/effective_premium_access_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
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
    final premiumAccess = ref.watch(effectivePremiumAccessProvider);
    final isRevenueCatConfigured = ref.watch(revenueCatConfiguredProvider);
    final effectiveStatus = premiumAccess.subscriptionStatus;
    final premiumSubtitle = premiumAccess.isActive
        ? _buildPremiumSubtitle(context.l10n, effectiveStatus)
        : isRevenueCatConfigured
        ? context.l10n.premiumTagline
        : context.l10n.allFeaturesFreeInBeta;
    final l10n = context.l10n;
    final userEmail = currentUser.value?.email?.toString();
    final hasDebugTools =
        userEmail != null && userEmail.contains('ferrara-michele');

    // Auto-load fitness profile when user is authenticated
    ref.watch(fitnessProfileAutoLoadProvider);

    // Section keywords for filtering
    final keywords = buildSectionKeywords(l10n);
    final entries = _buildEntries(
      context,
      config: config,
      currentUser: currentUser,
      userEmail: userEmail,
      premiumSubtitle: premiumSubtitle,
      hasDebugTools: hasDebugTools,
    );
    final filteredEntries = entries
        .where(
          (entry) =>
              _searchQuery.isEmpty ||
              sectionMatches(
                _searchQuery,
                keywords[entry.keywordKey] ?? <String>[entry.title],
              ),
        )
        .toList();
    final showQuickDropdowns =
        _searchQuery.isEmpty ||
        sectionMatches(_searchQuery, keywords['appearance']!) ||
        sectionMatches(_searchQuery, keywords['unitsLanguage']!);
    final hasResults = filteredEntries.isNotEmpty || showQuickDropdowns;

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: AppBar(
        centerTitle: true,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: [
          if (!hasResults && _searchQuery.isNotEmpty)
            _buildNoResultsMessage(context),

          if (showQuickDropdowns) _buildQuickDropdownSection(context, config),

          ..._buildGroupedMenu(context, filteredEntries),

          const TabBarBottomPadding(),
        ],
      ),
    );
  }

  List<_SettingsEntry> _buildEntries(
    BuildContext context, {
    required AppConfig config,
    required AsyncValue<dynamic> currentUser,
    required String? userEmail,
    required String premiumSubtitle,
    required bool hasDebugTools,
  }) {
    final l10n = context.l10n;

    return [
      _SettingsEntry(
        groupKey: 'general',
        keywordKey: 'account',
        icon: AppIcons.person,
        title: l10n.account,
        subtitle: userEmail ?? l10n.settingsNotLoggedIn,
        onTap: () => _openSubmenu(
          context,
          l10n.account,
          SettingsUserInfoSection(currentUser: currentUser),
        ),
      ),
      _SettingsEntry(
        groupKey: 'general',
        keywordKey: 'appearance',
        icon: AppIcons.theme,
        title: l10n.appearance,
        subtitle: _themeModeLabel(l10n, config.appThemeMode),
        onTap: () => _openConfigSubmenu(
          context,
          l10n.appearance,
          (liveConfig) => SettingsAppearanceSection(config: liveConfig),
        ),
      ),
      _SettingsEntry(
        groupKey: 'general',
        keywordKey: 'unitsLanguage',
        icon: AppIcons.language,
        title: l10n.settingsUnitsLanguage,
        subtitle:
            '${_languageLabel(l10n, config.languageCode)} · ${config.measurementUnit.toUpperCase()}',
        onTap: () => _openConfigSubmenu(
          context,
          l10n.settingsUnitsLanguage,
          (liveConfig) => SettingsUnitsLanguageSection(config: liveConfig),
        ),
      ),
      _SettingsEntry(
        groupKey: 'general',
        keywordKey: 'premium',
        icon: AppIcons.star,
        title: l10n.gymbroPremium,
        subtitle: premiumSubtitle,
        onTap: () => _openSubmenu(
          context,
          l10n.gymbroPremium,
          const SettingsPremiumSection(),
        ),
      ),
      _SettingsEntry(
        groupKey: 'workout',
        keywordKey: 'workout',
        icon: AppIcons.workout,
        title: l10n.settingsWorkout,
        subtitle: '${l10n.settingsDefaultRestTime}: ${config.defaultRestTime}s',
        onTap: () => _openConfigSubmenu(
          context,
          l10n.settingsWorkout,
          (liveConfig) => SettingsWorkoutSection(config: liveConfig),
        ),
      ),
      _SettingsEntry(
        groupKey: 'workout',
        keywordKey: 'exerciseCard',
        icon: AppIcons.workout,
        title: l10n.exerciseCardSettings,
        subtitle: '${l10n.preview} · ${l10n.cardDensity}',
        onTap: () => _openSubmenu(
          context,
          l10n.exerciseCardSettings,
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ExerciseCardSettingsSection(),
            ),
          ),
        ),
      ),
      _SettingsEntry(
        groupKey: 'workout',
        keywordKey: 'advanced',
        icon: AppIcons.tune,
        title: l10n.settingsAdvancedTitle,
        subtitle: l10n.settingsAdvancedDesc,
        onTap: () => _openConfigSubmenu(
          context,
          l10n.settingsAdvancedTitle,
          (liveConfig) =>
              SettingsAdvancedSection(config: liveConfig, collapsible: false),
        ),
      ),
      _SettingsEntry(
        groupKey: 'data',
        keywordKey: 'data',
        icon: AppIcons.storage,
        title: l10n.dataBackup,
        subtitle: l10n.exportDataSubtitle,
        onTap: () =>
            _openSubmenu(context, l10n.dataBackup, const SettingsDataSection()),
      ),
      _SettingsEntry(
        groupKey: 'support',
        keywordKey: 'help',
        icon: AppIcons.help,
        title: l10n.settingsTutorialHelp,
        subtitle: l10n.helpCenterDescription,
        onTap: () => _openSubmenu(
          context,
          l10n.settingsTutorialHelp,
          const SettingsHelpSection(),
        ),
      ),
      if (hasDebugTools)
        _SettingsEntry(
          groupKey: 'support',
          keywordKey: 'debug',
          icon: AppIcons.analytics,
          title: l10n.migrateWorkoutHistory,
          onTap: () => showMigrationDialog(context, ref),
        ),
      _SettingsEntry(
        groupKey: 'danger',
        keywordKey: 'accountActions',
        icon: AppIcons.warning,
        title: l10n.settingsAccountActions,
        subtitle: l10n.settingsSignOutDesc,
        destructive: true,
        onTap: () => _openSubmenu(
          context,
          l10n.settingsAccountActions,
          const SettingsAccountSection(),
        ),
      ),
    ];
  }

  List<Widget> _buildGroupedMenu(
    BuildContext context,
    List<_SettingsEntry> entries,
  ) {
    final l10n = context.l10n;
    final groupOrder = ['general', 'workout', 'data', 'support', 'danger'];
    final groupTitles = <String, String>{
      'general': l10n.settingsTitle,
      'workout': l10n.settingsWorkout,
      'data': l10n.dataBackup,
      'support': l10n.settingsTutorialHelp,
      'danger': l10n.settingsAccountActions,
    };
    final grouped = <String, List<_SettingsEntry>>{};

    for (final entry in entries) {
      grouped.putIfAbsent(entry.groupKey, () => []).add(entry);
    }

    return [
      for (final groupKey in groupOrder)
        if ((grouped[groupKey] ?? []).isNotEmpty)
          _buildSettingsGroup(
            context,
            title: groupTitles[groupKey]!,
            entries: grouped[groupKey]!,
          ),
    ];
  }

  Widget _buildQuickDropdownSection(BuildContext context, AppConfig config) {
    final l10n = context.l10n;
    final themeMode = config.appThemeMode;

    return _buildDropdownGroup(
      context,
      title: '${l10n.appearance} · ${l10n.settingsUnitsLanguage}',
      rows: [
        _buildQuickDropdownRow<AppThemeMode>(
          context,
          icon: AppIcons.theme,
          title: l10n.theme,
          value: themeMode,
          items: AppThemeMode.values
              .map(
                (mode) => DropdownMenuItem<AppThemeMode>(
                  value: mode,
                  child: Text(
                    _themeModeLabel(l10n, mode),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setAppThemeMode(value);
            }
          },
        ),
        _buildQuickDropdownRow<String>(
          context,
          icon: AppIcons.translate,
          title: l10n.settingsLanguage,
          value: config.languageCode,
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(
                l10n.languageEnglish,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'it',
              child: Text(
                l10n.settingsItaliano,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(appConfigProvider.notifier)
                  .setLanguage(value, value == 'en' ? 'US' : 'IT');
            }
          },
        ),
        _buildQuickDropdownRow<String>(
          context,
          icon: AppIcons.weight,
          title: l10n.weightUnits,
          value: config.measurementUnit,
          items: [
            DropdownMenuItem(
              value: 'kg',
              child: Text(
                l10n.settingsKilogramsKg,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'lbs',
              child: Text(
                l10n.settingsPoundsLbs,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setMeasurementUnit(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsEntry> entries,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _buildMenuTile(context, entries[i]),
                  if (i < entries.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: context.colors.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownGroup(
    BuildContext context, {
    required String title,
    required List<Widget> rows,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i < rows.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: context.colors.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, _SettingsEntry entry) {
    final titleColor = entry.destructive
        ? context.colors.error
        : context.colors.onSurface;
    final iconColor = entry.destructive
        ? context.colors.error
        : context.colors.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: entry.onTap,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(entry.icon, size: 18, color: iconColor),
        ),
      ),
      title: Text(
        entry.title,
        style: context.textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: entry.subtitle == null
          ? null
          : Text(
              entry.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
      trailing: Icon(
        AppIcons.chevronRight,
        size: 18,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildQuickDropdownRow<T>(
    BuildContext context, {
    required IconData icon,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: context.colors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(
                  AppIcons.chevronDown,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                style: context.textTheme.bodyMedium,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
      case AppThemeMode.ultraDark:
        return l10n.themeUltraDark;
      case AppThemeMode.pink:
        return l10n.themePink;
      case AppThemeMode.darkPink:
        return l10n.themeDarkPink;
      case AppThemeMode.system:
        return l10n.themeSystem;
    }
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'it':
        return l10n.settingsItaliano;
      case 'en':
      default:
        return l10n.languageEnglish;
    }
  }

  void _openSubmenu(BuildContext context, String title, Widget child) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _SettingsSubmenuScreen(title: title, child: child),
      ),
    );
  }

  void _openConfigSubmenu(
    BuildContext context,
    String title,
    Widget Function(AppConfig config) builder,
  ) {
    _openSubmenu(
      context,
      title,
      Consumer(
        builder: (context, ref, _) {
          final liveConfig = ref.watch(appConfigProvider);
          return builder(liveConfig);
        },
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

  String _buildPremiumSubtitle(
    AppLocalizations l10n,
    SubscriptionStatus status,
  ) {
    if (status.isLifetime) return l10n.subscriptionLifetime;
    if (status.expirationDate != null) {
      final expiration = status.expirationDate!;
      return l10n.subscriptionActiveUntil(
        '${expiration.day}/${expiration.month}/${expiration.year}',
      );
    }
    return l10n.premiumMembership;
  }
}

class _SettingsEntry {
  const _SettingsEntry({
    required this.groupKey,
    required this.keywordKey,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final String groupKey;
  final String keywordKey;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;
}

class _SettingsSubmenuScreen extends StatelessWidget {
  const _SettingsSubmenuScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: AppBar(centerTitle: true, title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: [child, const TabBarBottomPadding()],
      ),
    );
  }
}
