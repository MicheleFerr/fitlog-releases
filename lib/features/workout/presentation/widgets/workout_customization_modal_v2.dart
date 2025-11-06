import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// 🚀 Workout Customization Modal V2 - Improved UX with tooltips and logical grouping
class WorkoutCustomizationModalV2 extends ConsumerStatefulWidget {
  const WorkoutCustomizationModalV2({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkoutCustomizationModalV2(),
    );
  }

  @override
  ConsumerState<WorkoutCustomizationModalV2> createState() => _WorkoutCustomizationModalV2State();
}

class _WorkoutCustomizationModalV2State extends ConsumerState<WorkoutCustomizationModalV2> {
  // Core features
  late bool _autoRestTimer;
  late bool _warmupSuggestions;
  late bool _autoCollapseCompleted;
  late bool _isProMode;

  // APRE Auto-regulation settings
  late bool _enableApre;
  late int _defaultApreProtocol;
  late bool _autoAdjustRestTimeApre;

  // RPE Auto-regulation settings
  late bool _rpeTracking;
  late bool _autoAdjustWeightFromRpe;
  late bool _autoAdjustRestFromRpe;

  // TUT Tracking
  late bool _setDurationTracking;

  // Information & Insights
  late bool _showExerciseDetails; // Combined notes + insights
  late bool _showCommunitySuggestions;
  late bool _showTutInfo;

  // Quick Access
  late bool _showQuickAccessIcons; // Combined all 3 icons

  // Interface & Performance
  late bool _showAdvancedMenu;
  late bool _showCustomTimers;
  late bool _showCollapseCountdown;
  late bool _simplifiedAnimations;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);

    // Initialize settings
    _isProMode = config.isProMode ?? false;

    // Core features
    _autoRestTimer = config.autoRestTimer ?? true;
    _warmupSuggestions = config.warmupSuggestions ?? false;
    _autoCollapseCompleted = config.autoCollapseCompleted ?? false;

    // APRE settings
    _enableApre = config.enableApre ?? false;
    _defaultApreProtocol = config.defaultApreProtocol ?? 6;
    _autoAdjustRestTimeApre = config.autoAdjustRestTime ?? true;

    // RPE settings
    _rpeTracking = config.rpeTracking ?? true;
    _autoAdjustWeightFromRpe = config.autoAdjustWeightFromRpe ?? false;
    _autoAdjustRestFromRpe = config.autoAdjustRestFromRpe ?? false;

    // TUT Tracking
    _setDurationTracking = config.setDurationTracking ?? false;

    // Information (combine notes + insights)
    _showExerciseDetails = (config.showExerciseNotes ?? false) || (config.showExerciseInsights ?? false);
    _showCommunitySuggestions = config.showCommunitySuggestions ?? false;
    _showTutInfo = config.showTutInfo ?? false;

    // Quick Access (combine all 3 icons)
    _showQuickAccessIcons = (config.showQuickInfoIcon ?? false) ||
                            (config.showWarmupIcon ?? false) ||
                            (config.showPreventionIcon ?? false);

    // Interface
    _showAdvancedMenu = config.showAdvancedMenu ?? false;
    _showCustomTimers = config.showCustomTimers ?? false;
    _showCollapseCountdown = config.showCollapseCountdown ?? false;
    _simplifiedAnimations = config.simplifiedAnimations ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tune,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.customizeWorkout,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.customizeWorkoutSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mode Toggle
            _buildModeToggleSection(theme, l10n),

            Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
              height: 24,
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Core Features Section
                  _buildSectionHeader(
                    theme,
                    l10n,
                    icon: AppIcons.workout,
                    title: l10n.coreFeaturesSection,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.timer,
                    iconColor: Colors.blue,
                    title: l10n.autoRestTimerTitle,
                    subtitle: l10n.autoRestTimerDescription,
                    tooltip: l10n.autoRestTimerTooltip,
                    value: _autoRestTimer,
                    onChanged: (value) {
                      setState(() => _autoRestTimer = value);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.whatshot,
                    iconColor: Colors.orange,
                    title: l10n.warmupSuggestionsTitle,
                    subtitle: l10n.warmupSuggestionsDescription,
                    tooltip: l10n.warmupSuggestionsTooltip,
                    value: _warmupSuggestions,
                    onChanged: (value) {
                      setState(() => _warmupSuggestions = value);
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.unfoldLess,
                    iconColor: Colors.indigo,
                    title: l10n.autoCollapseTitle,
                    subtitle: l10n.autoCollapseDescription,
                    tooltip: l10n.autoCollapseTooltip,
                    value: _autoCollapseCompleted,
                    onChanged: (value) {
                      setState(() => _autoCollapseCompleted = value);
                      _saveSettings();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Auto-Regulation Section
                  _buildSectionHeader(
                    theme,
                    l10n,
                    icon: AppIcons.autoAwesome,
                    title: l10n.intelligentAutoRegulation,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 16),

                  // APRE Subsection
                  _buildSubsectionHeader(theme, l10n, l10n.apreSystemTitle, l10n.apreSystemSubtitle),
                  const SizedBox(height: 12),
                  _buildApreSection(theme, l10n),

                  const SizedBox(height: 16),

                  // RPE Subsection
                  _buildSubsectionHeader(theme, l10n, l10n.rpeSystemTitle, l10n.rpeSystemSubtitle),
                  const SizedBox(height: 12),
                  _buildRpeSection(theme, l10n),

                  const SizedBox(height: 24),

                  // Information & Insights Section
                  _buildSectionHeader(
                    theme,
                    l10n,
                    icon: AppIcons.insights,
                    title: l10n.informationInsightsSection,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.noteAlt,
                    iconColor: Colors.amber,
                    title: l10n.exerciseDetailsTitle,
                    subtitle: l10n.exerciseDetailsDescription,
                    tooltip: l10n.exerciseDetailsTooltip,
                    value: _showExerciseDetails,
                    onChanged: (value) {
                      setState(() => _showExerciseDetails = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.lightbulb,
                    iconColor: Colors.orange,
                    title: l10n.communitySuggestionsTitle,
                    subtitle: l10n.communitySuggestionsDescription,
                    tooltip: l10n.communitySuggestionsTooltip,
                    value: _showCommunitySuggestions,
                    onChanged: (value) {
                      setState(() => _showCommunitySuggestions = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.timerOffOutlined,
                    iconColor: Colors.teal,
                    title: l10n.tutInfoTitle,
                    subtitle: l10n.tutInfoDescription,
                    tooltip: l10n.tutInfoTooltip,
                    value: _showTutInfo,
                    onChanged: (value) {
                      setState(() => _showTutInfo = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.timer,
                    iconColor: Colors.blue,
                    title: l10n.enableTutTitle,
                    subtitle: l10n.enableTutDescription,
                    tooltip: l10n.enableTutTooltip,
                    value: _setDurationTracking,
                    onChanged: (value) {
                      setState(() => _setDurationTracking = value);
                      _saveSettings();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Quick Access Section
                  _buildSectionHeader(
                    theme,
                    l10n,
                    icon: AppIcons.touchApp,
                    title: l10n.quickAccessSection,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.info,
                    iconColor: Colors.blue,
                    title: l10n.quickAccessIconsTitle,
                    subtitle: l10n.quickAccessIconsDescription,
                    tooltip: l10n.quickAccessIconsTooltip,
                    value: _showQuickAccessIcons,
                    onChanged: (value) {
                      setState(() => _showQuickAccessIcons = value);
                      _saveDisplaySettings();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Interface & Performance Section
                  _buildSectionHeader(
                    theme,
                    l10n,
                    icon: AppIcons.settings,
                    title: l10n.interfaceSection,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.moreVert,
                    iconColor: Colors.red,
                    title: l10n.advancedMenuTitle,
                    subtitle: l10n.advancedMenuDescription,
                    tooltip: l10n.advancedMenuTooltip,
                    value: _showAdvancedMenu,
                    onChanged: (value) {
                      setState(() => _showAdvancedMenu = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.timerOffOutlined,
                    iconColor: Colors.green,
                    title: l10n.customTimersTitle,
                    subtitle: l10n.customTimersDescription,
                    tooltip: l10n.customTimersTooltip,
                    value: _showCustomTimers,
                    onChanged: (value) {
                      setState(() => _showCustomTimers = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.visibilityOff,
                    iconColor: Colors.cyan,
                    title: l10n.collapseCountdownTitle,
                    subtitle: l10n.collapseCountdownDescription,
                    tooltip: l10n.collapseCountdownTooltip,
                    value: _showCollapseCountdown,
                    onChanged: (value) {
                      setState(() => _showCollapseCountdown = value);
                      _saveDisplaySettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildToggleCard(
                    theme,
                    l10n,
                    icon: AppIcons.animation,
                    iconColor: Colors.deepOrange,
                    title: l10n.simplifiedAnimationsTitle,
                    subtitle: l10n.simplifiedAnimationsDescription,
                    tooltip: l10n.simplifiedAnimationsTooltip,
                    value: _simplifiedAnimations,
                    onChanged: (value) {
                      setState(() => _simplifiedAnimations = value);
                      _saveDisplaySettings();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.info,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settingsAutoSaved,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.education,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.displayMode,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.displayModeDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  label: l10n.baseMode,
                  isSelected: !_isProMode,
                  onTap: () => _setMode(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeButton(
                  label: l10n.proMode,
                  isSelected: _isProMode,
                  onTap: () => _setMode(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSubsectionHeader(ThemeData theme, AppLocalizations l10n, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    ThemeData theme,
    AppLocalizations l10n, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tooltip,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                AppIcons.help,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showTooltip(context, title, tooltip),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: '',
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildApreSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildToggleCard(
          theme,
          l10n,
          icon: AppIcons.workout,
          iconColor: Colors.deepPurple,
          title: l10n.enableApreTitle,
          subtitle: l10n.enableApreDescription,
          tooltip: l10n.enableApreTooltip,
          value: _enableApre,
          onChanged: (value) {
            setState(() => _enableApre = value);
            _saveSettings();
          },
        ),
        if (_enableApre) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.apreProtocolTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment<int>(
                      value: 3,
                      label: Text(l10n.apre3),
                      icon: const Icon(Icons.looks_3, size: 20),
                    ),
                    ButtonSegment<int>(
                      value: 6,
                      label: Text(l10n.apre6),
                      icon: const Icon(Icons.looks_6, size: 20),
                    ),
                    ButtonSegment<int>(
                      value: 10,
                      label: Text(l10n.apre10),
                      icon: const Icon(AppIcons.filter9Plus, size: 20),
                    ),
                  ],
                  selected: {_defaultApreProtocol},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _defaultApreProtocol = newSelection.first;
                    });
                    _saveSettings();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _getApreProtocolDescription(_defaultApreProtocol, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.deepPurple.withOpacity(0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustRestApreTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustRestApreDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        AppIcons.help,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustRestApreTitle,
                        l10n.autoAdjustRestApreTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustRestTimeApre,
                      onChanged: (value) {
                        setState(() => _autoAdjustRestTimeApre = value);
                        _saveSettings();
                      },
                      activeThumbColor: Colors.deepPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRpeSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildToggleCard(
          theme,
          l10n,
          icon: AppIcons.speed,
          iconColor: Colors.orange,
          title: l10n.enableRpeTitle,
          subtitle: l10n.enableRpeDescription,
          tooltip: l10n.enableRpeTooltip,
          value: _rpeTracking,
          onChanged: (value) {
            setState(() => _rpeTracking = value);
            _saveSettings();
          },
        ),
        if (_rpeTracking) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustWeightRpeTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustWeightRpeDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        AppIcons.help,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustWeightRpeTitle,
                        l10n.autoAdjustWeightRpeTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustWeightFromRpe,
                      onChanged: (value) {
                        setState(() => _autoAdjustWeightFromRpe = value);
                        _saveSettings();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.orange.withOpacity(0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.autoAdjustRestRpeTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.autoAdjustRestRpeDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        AppIcons.help,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _showTooltip(
                        context,
                        l10n.autoAdjustRestRpeTitle,
                        l10n.autoAdjustRestRpeTooltip,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Switch(
                      value: _autoAdjustRestFromRpe,
                      onChanged: (value) {
                        setState(() => _autoAdjustRestFromRpe = value);
                        _saveSettings();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showTooltip(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.info,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).gotIt),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setMode(bool isProMode) {
    setState(() {
      _isProMode = isProMode;

      if (isProMode) {
        // Pro Mode defaults
        _autoRestTimer = true;
        _warmupSuggestions = false;
        _autoCollapseCompleted = true;
        _rpeTracking = true;
        _setDurationTracking = true; // ✅ Enable TUT tracking in Pro mode
        _showExerciseDetails = true;
        _showCommunitySuggestions = true;
        _showTutInfo = true;
        _showQuickAccessIcons = true;
        _showAdvancedMenu = true;
        _showCustomTimers = true;
        _showCollapseCountdown = true;
        _simplifiedAnimations = false;
      } else {
        // Base Mode defaults
        _autoRestTimer = true;
        _warmupSuggestions = true;
        _autoCollapseCompleted = false;
        _rpeTracking = false;
        _setDurationTracking = false; // ✅ Disable TUT tracking in Base mode
        _showExerciseDetails = false;
        _showCommunitySuggestions = false;
        _showTutInfo = false;
        _showQuickAccessIcons = false;
        _showAdvancedMenu = false;
        _showCustomTimers = false;
        _showCollapseCountdown = false;
        _simplifiedAnimations = true;
      }
    });

    _saveSettings();
  }

  void _saveSettings() {
    final l10n = AppLocalizations.of(context);

    ref.read(appConfigProvider.notifier).updateWorkoutSettings(
      rpeTracking: _rpeTracking,
      autoRestTimer: _autoRestTimer,
      setDurationTracking: _setDurationTracking, // ✅ Fixed: use state variable instead of hardcoded false
      plateCalculator: true,
      warmupSuggestions: _warmupSuggestions,
      autoCollapseCompleted: _autoCollapseCompleted,
      isProMode: _isProMode,
      enableApre: _enableApre,
      defaultApreProtocol: _defaultApreProtocol,
      autoAdjustRestTime: _autoAdjustRestTimeApre,
      autoAdjustWeightFromRpe: _autoAdjustWeightFromRpe,
      autoAdjustRestFromRpe: _autoAdjustRestFromRpe,
    );

    _saveDisplaySettings();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isProMode ? l10n.proModeActivated : l10n.baseModeActivated),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _saveDisplaySettings() {
    ref.read(appConfigProvider.notifier).updateDisplaySettings(
      showTutInfo: _showTutInfo,
      showExerciseNotes: _showExerciseDetails,
      showCommunitySuggestions: _showCommunitySuggestions,
      showExerciseInsights: _showExerciseDetails,
      showCustomTimers: _showCustomTimers,
      showAdvancedMenu: _showAdvancedMenu,
      showCollapseCountdown: _showCollapseCountdown,
      simplifiedAnimations: _simplifiedAnimations,
      showQuickInfoIcon: _showQuickAccessIcons,
      showWarmupIcon: _showQuickAccessIcons,
      showPreventionIcon: _showQuickAccessIcons,
    );
  }

  String _getApreProtocolDescription(int protocol, AppLocalizations l10n) {
    switch (protocol) {
      case 3:
        return l10n.apre3Description;
      case 6:
        return l10n.apre6Description;
      case 10:
        return l10n.apre10Description;
      default:
        return '';
    }
  }
}
