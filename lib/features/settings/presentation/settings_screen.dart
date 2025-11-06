import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/timer_sound.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_ui_state_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/timer_sound_selector.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/timer_sound_test_dialog.dart';
import 'package:gymbro_flutter_new/features/migration/presentation/providers/migration_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/template_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart' show isAdminCachedProvider;
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/screens/fitness_questionnaire_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/apre_calculation_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/onerm_calculation_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final currentUser = ref.watch(firebaseUserProvider);
    final l10n = context.l10n;

    // Auto-load fitness profile when user is authenticated
    ref.watch(fitnessProfileAutoLoadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: context.colors.surfaceContainerHighest,
        leading: IconButton(
          icon: Icon(AppIcons.back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DISABLED: Fitness Benchmark Hero Card
            // Reason: GDPR compliance - medical questionnaire data
            // Date: 2025-01-21
            // _buildFitnessBenchmarkCard(context, ref),
            // const SizedBox(height: 24),

            // User Info Section
            _buildUserInfoSection(context, ref, currentUser),
            const SizedBox(height: 24),

            // DISABLED: Fitness Profile Section
            // Reason: GDPR compliance - medical questionnaire data
            // Date: 2025-01-21
            // _buildFitnessProfileSection(context, ref),
            // const SizedBox(height: 24),

            // Appearance Settings
            _buildAppearanceSection(context, ref, config),
            SizedBox(height: 24),

            // Workout Settings
            _buildWorkoutSection(context, ref, config),
            SizedBox(height: 24),

            // Units & Language
            _buildUnitsLanguageSection(context, ref, config),
            SizedBox(height: 24),

            // iOS Features (if iOS)
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _buildIOSFeaturesSection(context, ref, config),
              const SizedBox(height: 24),
            ],

            // Audio & Feedback
            _buildAudioFeedbackSection(context, ref, config),
            const SizedBox(height: 24),

            // Advanced Settings
            _buildAdvancedSection(context, ref, config),
            SizedBox(height: 24),

            // Account Actions
            _buildAccountSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessBenchmarkCard(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(userFitnessQuestionnaireProvider);
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primaryContainer,
            context.colors.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const FitnessQuestionnaireScreen(),
            );
            if (result == true && context.mounted) {
              ref.invalidate(userFitnessQuestionnaireProvider);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.analytics,
                    size: 32,
                    color: context.colors.primary,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionnaire != null
                            ? l10n.fitnessBenchmarkUpdate
                            : l10n.fitnessBenchmarkCalculate,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        questionnaire != null
                            ? '${l10n.fitnessBenchmarkLevel}: ${questionnaire.experienceLevel.name}'
                            : l10n.fitnessBenchmarkDescription,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.forwardIos,
                  color: context.colors.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, WidgetRef ref, AsyncValue<dynamic> currentUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.person,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.account,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            currentUser.when(
              data: (user) => user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? Icon(AppIcons.person)
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName ?? 'GymBro User',
                                    style: context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user.email ?? 'No email',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colors.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Admin Dashboard Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.pushNamed('admin'),
                            icon: Icon(AppIcons.admin),
                            label: Text(context.l10n.adminDashboard),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Database Manager Button (Direct Access)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DatabaseManagerScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.storage),
                            label: Text(context.l10n.databaseManager),
                            style: FilledButton.styleFrom(
                              backgroundColor: context.colors.primary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text('Not logged in'),
              loading: () => Text('Loading...'),
              error: (_, __) => Text('Error loading user'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessProfileSection(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(userFitnessQuestionnaireProvider);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  l10n.fitnessQuestionnaireTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (questionnaire != null) ...[
              // Display current profile summary
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.fitnessQuestionnaireExperienceLevelLabel}: ${questionnaire.experienceLevel.name}',
                          style: context.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${l10n.fitnessQuestionnaireBodyweightLabel}: ${questionnaire.bodyweightKg.toStringAsFixed(1)} kg',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (questionnaire.completedAt != null)
                          Text(
                            'Last updated: ${questionnaire.completedAt!.day}/${questionnaire.completedAt!.month}/${questionnaire.completedAt!.year}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const FitnessQuestionnaireScreen(),
                    );
                    if (result == true && context.mounted) {
                      // Profile updated successfully
                      ref.invalidate(userFitnessQuestionnaireProvider);
                    }
                  },
                  icon: Icon(AppIcons.edit),
                  label: Text('Update Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                  ),
                ),
              ),
            ] else ...[
              // No profile yet - show setup button
              Text(
                l10n.weightSuggestionCompleteQuestionnaire,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const FitnessQuestionnaireScreen(),
                    );
                    if (result == true && context.mounted) {
                      // Profile created successfully
                      ref.invalidate(userFitnessQuestionnaireProvider);
                    }
                  },
                  icon: const Icon(AppIcons.add),
                  label: Text(l10n.fitnessQuestionnaireWelcomeStart),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.theme,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.appearance,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Theme Mode Selection
            _buildSettingTile(
              context,
              title: context.l10n.theme,
              subtitle: _getThemeModeText(context.l10n, config.themeMode),
              leading: Icon(_getThemeModeIcon(config.themeMode)),
              onTap: () => _showThemeDialog(context, ref, config.themeMode),
            ),

            const Divider(),

            // Font Size
            _buildFontSizeSection(context, ref, config),

            const Divider(),

            // Primary Color
            _buildSettingTile(
              context,
              title: 'Accent Color',
              subtitle: config.primaryColor.toUpperCase(),
              leading: Icon(
                AppIcons.colorLens,
                color: _getPrimaryColor(config.primaryColor),
              ),
              onTap: () => _showColorDialog(context, ref, config.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Workout',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Auto Start Timer
            _buildSwitchTile(
              context,
              title: 'Auto-start Timer',
              subtitle: 'Start rest timer after completing set',
              value: config.autoStartTimer,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setAutoStartTimer(value);
              },
            ),

            const Divider(),

            // Default Rest Time
            _buildSettingTile(
              context,
              title: 'Default Rest Time',
              subtitle: '${config.defaultRestTime}s',
              leading: const Icon(AppIcons.timer),
              onTap: () => _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),

            const Divider(),

            // Show Intensity Techniques
            _buildSwitchTile(
              context,
              title: 'Advanced Techniques',
              subtitle: 'Show drop sets, supersets, etc.',
              value: config.showIntensityTechniques,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setShowIntensityTechniques(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsLanguageSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.language,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Units & Language',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selection
            _buildSettingTile(
              context,
              title: 'Language',
              subtitle: _getLanguageText(config.languageCode),
              leading: const Icon(AppIcons.translate),
              onTap: () => _showLanguageDialog(context, ref, config.languageCode),
            ),

            const Divider(),

            // Measurement Unit
            _buildSettingTile(
              context,
              title: 'Weight Units',
              subtitle: config.measurementUnit.toUpperCase(),
              leading: const Icon(AppIcons.weight),
              onTap: () => _showUnitsDialog(context, ref, config.measurementUnit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSFeaturesSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.phoneIphone,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'iOS Features',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Activities
            _buildSwitchTile(
              context,
              title: 'Live Activities',
              subtitle: 'Show timer on lock screen & Dynamic Island',
              value: config.enableLiveActivities,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setEnableLiveActivities(value);
              },
            ),

            const Divider(),

            // HealthKit Sync
            _buildSwitchTile(
              context,
              title: 'Health App Sync',
              subtitle: 'Sync workouts to Apple Health',
              value: config.syncWithHealthKit,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSyncWithHealthKit(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioFeedbackSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.volumeUp,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Audio & Feedback',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sound Effects
            _buildSwitchTile(
              context,
              title: 'Sound Effects',
              subtitle: 'Play sounds for timer and completion',
              value: config.soundEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSoundEnabled(value);
              },
            ),

            const Divider(),

            // Vibrations
            _buildSwitchTile(
              context,
              title: 'Vibrations',
              subtitle: 'Haptic feedback for interactions',
              value: config.vibrationsEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setVibrationsEnabled(value);
              },
            ),

            const Divider(),

            // Timer Sound
            _buildSettingTile(
              context,
              title: context.l10n.timerSound,
              subtitle: TimerSound.fromFileName(config.timerSound).getLocalizedName(),
              leading: const Icon(AppIcons.notificationsActive),
              onTap: () => _showTimerSoundDialog(context, ref, config.timerSound),
              trailing: IconButton(
                icon: const Icon(AppIcons.playCircleOutline),
                tooltip: 'Test Sounds',
                onPressed: () => showTimerSoundTestDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.settingsApplications,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Advanced',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Export Settings
            _buildSettingTile(
              context,
              title: 'Export Settings',
              subtitle: 'Save settings as JSON file',
              leading: const Icon(AppIcons.fileDownload),
              onTap: () => _exportSettings(context, ref),
            ),

            const Divider(),

            // Import Settings
            _buildSettingTile(
              context,
              title: 'Import Settings',
              subtitle: 'Load settings from JSON file',
              leading: const Icon(AppIcons.fileUpload),
              onTap: () => _importSettings(context, ref),
            ),

            const Divider(),

            // Reset Timer Position
            _buildSettingTile(
              context,
              title: 'Reset Timer Position',
              subtitle: 'Reset draggable timer to default position',
              leading: Icon(AppIcons.pictureInPictureAlt),
              onTap: () => _resetTimerPosition(context, ref),
            ),

            const Divider(),

            // Clear Exercise Cache
            _buildSettingTile(
              context,
              title: context.l10n.clearCache,
              subtitle: context.l10n.clearExerciseCacheDesc,
              leading: const Icon(Icons.delete_sweep),
              onTap: () => _clearExerciseCache(context, ref),
            ),

            const Divider(),

            // APRE Calculation Method
            _buildAPRECalculationMethodSetting(context, ref),

            const Divider(),

            // Fitness Profile Debug (Admin Only)
            Consumer(
              builder: (context, ref, child) {
                final isAdmin = ref.watch(isAdminCachedProvider);
                if (!isAdmin) return const SizedBox.shrink();

                return Column(
                  children: [
                    // DISABLED: Fitness Profile Debug
                    // Reason: GDPR compliance - medical questionnaire data
                    // Date: 2025-01-21
                    // _buildSettingTile(
                    //   context,
                    //   title: 'Fitness Profile Debug',
                    //   subtitle: 'View fitness profile and weight suggestions status',
                    //   leading: Icon(Icons.bug_report),
                    //   onTap: () => context.pushNamed('fitness-profile-debug'),
                    // ),
                    // const Divider(),
                  ],
                );
              },
            ),

            // Reset Onboarding Tutorials (Admin Only)
            Consumer(
              builder: (context, ref, child) {
                final isAdmin = ref.watch(isAdminCachedProvider);
                if (!isAdmin) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildSettingTile(
                      context,
                      title: context.l10n.resetOnboarding,
                      subtitle: context.l10n.resetOnboardingDesc,
                      leading: const Icon(AppIcons.schoolOutlined),
                      onTap: () => _resetOnboarding(context, ref),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),

            // Data Migration
            Consumer(
              builder: (context, ref, child) {
                final migrationState = ref.watch(migrationProvider);
                return _buildSettingTile(
                  context,
                  title: context.l10n.dataMigration,
                  subtitle: migrationState.hasDataToMigrate
                    ? 'Hai dati da migrare dalla versione precedente'
                    : 'Migrazione completata o non necessaria',
                  leading: Icon(
                    AppIcons.syncAlt,
                    color: migrationState.hasDataToMigrate
                      ? context.colors.primary
                      : context.colors.outline,
                  ),
                  trailing: migrationState.hasDataToMigrate
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Disponibile',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      )
                    : null,
                  onTap: () => context.push('/migration'),
                );
              },
            ),

            const Divider(),

            // Beta Mode Toggle
            Consumer(
              builder: (context, ref, child) {
                final betaModeEnabled = ref.watch(betaModeEnabledProvider);
                return SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        AppIcons.science,
                        color: betaModeEnabled
                          ? context.colors.tertiary
                          : context.colors.outline,
                      ),
                      SizedBox(width: 16),
                      Text(context.l10n.settingsBetaMode),
                      if (betaModeEnabled) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BETA',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    betaModeEnabled
                      ? 'Tutte le funzionalità premium sbloccate per testing'
                      : 'Abilita accesso temporaneo a tutte le funzionalità premium',
                  ),
                  value: betaModeEnabled,
                  activeThumbColor: context.colors.tertiary,
                  onChanged: (value) {
                    ref.read(appConfigProvider.notifier).setBetaMode(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                            ? '🧪 Beta Mode attivato - Tutte le funzionalità premium sbloccate!'
                            : 'Beta Mode disattivato',
                        ),
                        backgroundColor: value
                          ? context.colors.tertiaryContainer
                          : null,
                      ),
                    );
                  },
                );
              },
            ),

            const Divider(),

            // Reset to Defaults
            _buildSettingTile(
              context,
              title: 'Reset to Defaults',
              subtitle: 'Restore all settings to default',
              leading: const Icon(AppIcons.restore, color: Colors.red),
              onTap: () => _showResetDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.logout,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Account Actions',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sign Out
            _buildSettingTile(
              context,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              leading: const Icon(AppIcons.logout, color: Colors.red),
              onTap: () => _showSignOutDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: leading,
      trailing: trailing ?? const Icon(AppIcons.chevronRight),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFontSizeSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.formatSize),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    _getFontSizeText(config.fontSize),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: config.fontSize,
          min: 0.8,
          max: 1.2,
          divisions: 4,
          onChanged: (value) {
            ref.read(appConfigProvider.notifier).setFontSize(value);
          },
        ),
      ],
    );
  }

  // Dialog Methods
  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeLight),
                subtitle: Text(l10n.themeLightDesc),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeDark),
                subtitle: Text(l10n.themeDarkDesc),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeSystem),
                subtitle: Text(l10n.themeSystemDesc),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Language'),
        content: RadioGroup<String>(
          groupValue: currentLang,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setLanguage(value, value == 'en' ? 'US' : 'IT');
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(context.l10n.languageEnglish),
                subtitle: const Text('English (US)'),
                value: 'en',
              ),
              const RadioListTile<String>(
                title: Text('Italiano'),
                subtitle: Text('Italian (IT)'),
                value: 'it',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref, String currentUnit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Units'),
        content: RadioGroup<String>(
          groupValue: currentUnit,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setMeasurementUnit(value);
              Navigator.pop(context);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Kilograms (kg)'),
                subtitle: Text('Metric system'),
                value: 'kg',
              ),
              RadioListTile<String>(
                title: Text('Pounds (lbs)'),
                subtitle: Text('Imperial system'),
                value: 'lbs',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, WidgetRef ref, String currentColor) {
    final colors = ['blue', 'red', 'green', 'purple', 'orange', 'teal'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accent Color'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              ref.read(appConfigProvider.notifier).setPrimaryColor(color);
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPrimaryColor(color),
                shape: BoxShape.circle,
                border: currentColor == color
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: currentColor == color
                  ? const Icon(AppIcons.check, color: Colors.white)
                  : null,
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showRestTimeDialog(BuildContext context, WidgetRef ref, int currentTime) {
    int selectedTime = currentTime;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Rest Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${selectedTime}s'),
              Slider(
                value: selectedTime.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.round();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                ref.read(appConfigProvider.notifier).setDefaultRestTime(selectedTime);
                Navigator.pop(context);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _resetTimerPosition(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Timer Position'),
        content: Text('This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              // Reset timer position to default
              ref.read(timerUIStateProvider.notifier).updatePosition(const Offset(20, 100));
              Navigator.pop(context);
              SnackBarService.showSuccess(context, 'Timer position reset to default');
            },
            child: Text('Reset Position'),
          ),
        ],
      ),
    );
  }

  void _clearExerciseCache(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                // Clear exercise cache from repository
                final repository = ref.read(hybridExerciseRepositoryProvider);
                await repository.clearCache();

                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarService.showSuccess(context, l10n.exerciseCacheCleared);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarService.showError(context, 'Failed to clear cache: $e');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _resetOnboarding(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetOnboarding),
        content: Text(l10n.resetOnboardingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              // Reset both template and exercise onboarding
              await ref.read(templateOnboardingProvider.notifier).resetOnboarding();
              await ref.read(exerciseOnboardingProvider.notifier).resetOnboarding();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.onboardingResetSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('Are you sure you want to reset all settings to defaults? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(appConfigProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              SnackBarService.showSuccess(context, 'Settings reset to defaults');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.signOutButton),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.signOutButton),
          ),
        ],
      ),
    );
  }

  void _exportSettings(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider.notifier).exportConfig();
    // In a real app, you'd save this to a file or share it
    SnackBarService.showInfo(context, 'Export functionality coming soon');
  }

  void _importSettings(BuildContext context, WidgetRef ref) {
    // In a real app, you'd pick a file and import it
    SnackBarService.showInfo(context, 'Import functionality coming soon');
  }

  void _showTimerSoundDialog(BuildContext context, WidgetRef ref, String currentSound) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.timerSound),
        content: SizedBox(
          width: double.maxFinite,
          child: TimerSoundSelector(
            selectedSound: TimerSound.fromFileName(currentSound),
            onSoundSelected: (sound) {
              ref.read(appConfigProvider.notifier).setTimerSound(sound.fileName);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _getThemeModeText(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppIcons.lightMode;
      case ThemeMode.dark:
        return AppIcons.darkMode;
      case ThemeMode.system:
        return AppIcons.autoMode;
    }
  }

  String _getFontSizeText(double fontSize) {
    if (fontSize < 0.9) return 'Small';
    if (fontSize > 1.1) return 'Large';
    return 'Normal';
  }

  String _getLanguageText(String code) {
    switch (code) {
      case 'it':
        return 'Italiano';
      case 'en':
      default:
        return 'English';
    }
  }

  /// APRE Calculation Method Setting
  Widget _buildAPRECalculationMethodSetting(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(apreCalculationConfigProvider);

    return configAsync.when(
      data: (currentConfig) => ExpansionTile(
        leading: Icon(AppIcons.calculate),
        title: Text(context.l10n.apreCalculationMethodTitle),
        subtitle: Text(currentConfig.displayName),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.apreCalculationMethodDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16),
                ...OneRMCalculationConfig.values.map((config) {
                  return RadioListTile<OneRMCalculationConfig>(
                    title: Text(config.displayName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.description),
                        SizedBox(height: 4),
                        Text(
                          config.useCase,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    value: config,
                    groupValue: currentConfig,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(apreCalculationConfigProvider.notifier)
                            .setConfig(value);
                        SnackBarService.showSuccess(
                          context,
                          'APRE calculation method updated to ${value.displayName}',
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      loading: () => const ListTile(
        leading: Icon(AppIcons.calculate),
        title: Text('APRE Calculation Method'),
        subtitle: Text('Loading...'),
      ),
      error: (error, stack) => ListTile(
        leading: Icon(AppIcons.error, color: context.colors.error),
        title: const Text('APRE Calculation Method'),
        subtitle: Text('Error: $error'),
      ),
    );
  }

  Color _getPrimaryColor(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      case 'blue':
      default:
        return Colors.blue;
    }
  }
}
