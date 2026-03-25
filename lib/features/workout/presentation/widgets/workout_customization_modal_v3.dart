/// Workout Customization Modal V5 - Simplified
///
/// Streamlined modal with clear organization:
/// - Tracciamento: RPE system with sub-options (collapsible)
/// - Aspetto: Visual customization (collapsible)
///
/// Core workout behavior can be adjusted per session from this modal.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/interface_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Simplified Workout Customization Modal
class WorkoutCustomizationModalV3 extends ConsumerStatefulWidget {
  const WorkoutCustomizationModalV3({super.key});

  static Future<void> show(BuildContext context) {
    return ModalService.showSheet(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => const WorkoutCustomizationModalV3(),
    );
  }

  @override
  ConsumerState<WorkoutCustomizationModalV3> createState() =>
      _WorkoutCustomizationModalV3State();
}

class _WorkoutCustomizationModalV3State
    extends ConsumerState<WorkoutCustomizationModalV3> {
  // === COMPORTAMENTO ===
  late bool _autoRestTimer;

  // === TRACCIAMENTO ===
  late bool _rpeTracking;
  late bool _autoAdjustWeightFromRpe;
  late bool _autoAdjustRestFromRpe;
  late bool _setDurationTracking;
  late bool _metronomeEnabled;

  // === ASPETTO (from ExerciseCardSettings - single source of truth) ===
  late bool _showInsight;
  late bool _showTimer;
  late bool _showPlates;
  late bool _showRpe;
  late InterfaceSize _interfaceSize;

  // ✅ Initial values for change tracking (feedback on close)
  late bool _initialAutoRestTimer;
  late bool _initialRpeTracking;
  late bool _initialAutoAdjustWeightFromRpe;
  late bool _initialAutoAdjustRestFromRpe;
  late bool _initialSetDurationTracking;
  late bool _initialMetronomeEnabled;
  late bool _initialShowInsight;
  late bool _initialShowTimer;
  late bool _initialShowPlates;
  late bool _initialShowRpe;
  late InterfaceSize _initialInterfaceSize;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);
    final cardSettings = ref.read(exerciseCardSettingsProvider);

    // Comportamento
    _autoRestTimer = config.isAutoRestTimerEnabled;

    // Tracciamento
    _rpeTracking = config.rpeTracking ?? false;
    _autoAdjustWeightFromRpe = config.autoAdjustWeightFromRpe ?? false;
    _autoAdjustRestFromRpe = config.autoAdjustRestFromRpe ?? false;
    _setDurationTracking = config.setDurationTracking ?? false;
    _metronomeEnabled = config.metronomeEnabled;

    // Aspetto - reads from ExerciseCardSettings (single source of truth)
    _showInsight = cardSettings.showInsight;
    _showTimer = cardSettings.showTimer;
    _showPlates = cardSettings.showPlates;
    _showRpe = cardSettings.showRpe;
    _interfaceSize =
        config.interfaceSize ?? InterfaceSize.fromFontSize(config.fontSize);

    // ✅ Store initial values for change tracking
    _initialAutoRestTimer = _autoRestTimer;
    _initialRpeTracking = _rpeTracking;
    _initialAutoAdjustWeightFromRpe = _autoAdjustWeightFromRpe;
    _initialAutoAdjustRestFromRpe = _autoAdjustRestFromRpe;
    _initialSetDurationTracking = _setDurationTracking;
    _initialMetronomeEnabled = _metronomeEnabled;
    _initialShowInsight = _showInsight;
    _initialShowTimer = _showTimer;
    _initialShowPlates = _showPlates;
    _initialShowRpe = _showRpe;
    _initialInterfaceSize = _interfaceSize;
  }

  /// ✅ Calculate number of changes made in this session
  int _countChanges() {
    int changes = 0;
    if (_autoRestTimer != _initialAutoRestTimer) changes++;
    if (_rpeTracking != _initialRpeTracking) changes++;
    if (_autoAdjustWeightFromRpe != _initialAutoAdjustWeightFromRpe) changes++;
    if (_autoAdjustRestFromRpe != _initialAutoAdjustRestFromRpe) changes++;
    if (_setDurationTracking != _initialSetDurationTracking) changes++;
    if (_metronomeEnabled != _initialMetronomeEnabled) changes++;
    if (_showInsight != _initialShowInsight) changes++;
    if (_showTimer != _initialShowTimer) changes++;
    if (_showPlates != _initialShowPlates) changes++;
    if (_showRpe != _initialShowRpe) changes++;
    if (_interfaceSize != _initialInterfaceSize) changes++;
    return changes;
  }

  /// ✅ Handle modal close - show feedback toast
  void _handleClose(BuildContext context) {
    final changes = _countChanges();
    if (changes > 0) {
      // Show toast with number of changes
      final message = changes == 1
          ? context.l10n.settingsChangedSingular
          : context.l10n.settingsChangedPlural(changes);
      SnackBarService.showInfo(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleClose(context);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.tune,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.customizeWorkout,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),

                    // === COMPORTAMENTO ===
                    _buildExpandableSection(
                      context,
                      icon: AppIcons.timer,
                      title: context.l10n.behaviorSection,
                      subtitle: context.l10n.autoRestTimerSubtitle,
                      color: context.colors.primary,
                      initiallyExpanded: false,
                      children: [
                        _buildToggleRow(
                          context,
                          icon: AppIcons.timer,
                          title: context.l10n.autoRestTimerTitle,
                          subtitle: context.l10n.autoRestTimerDescription,
                          value: _autoRestTimer,
                          onChanged: (v) {
                            setState(() => _autoRestTimer = v);
                            _saveAll();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // === TRACCIAMENTO AVANZATO ===
                    _buildExpandableSection(
                      context,
                      icon: AppIcons.speed,
                      title: context.l10n.advancedTrackingTitle,
                      subtitle: context.l10n.advancedTrackingSubtitle,
                      color: context.colors.tertiary,
                      initiallyExpanded: _rpeTracking,
                      onInfoPressed: () => _showAdvancedTrackingInfo(context),
                      children: [
                        _buildToggleRow(
                          context,
                          icon: AppIcons.speed,
                          title: context.l10n.rpeTitle,
                          subtitle: context.l10n.rpeSubtitle,
                          value: _rpeTracking,
                          onChanged: (v) {
                            setState(() {
                              _rpeTracking = v;
                              if (!v) {
                                _autoAdjustWeightFromRpe = false;
                                _autoAdjustRestFromRpe = false;
                              }
                            });
                            _saveAll();
                          },
                        ),
                        // Sub-options (only visible when RPE is ON)
                        if (_rpeTracking) ...[
                          _buildDivider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _buildToggleRow(
                              context,
                              icon: AppIcons.workout,
                              title: context.l10n.suggestWeightTitle,
                              subtitle: context.l10n.suggestWeightSubtitle,
                              value: _autoAdjustWeightFromRpe,
                              onChanged: (v) {
                                setState(() => _autoAdjustWeightFromRpe = v);
                                _saveAll();
                              },
                              compact: true,
                            ),
                          ),
                          _buildDivider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _buildToggleRow(
                              context,
                              icon: AppIcons.timer,
                              title: context.l10n.adjustRestTitle,
                              subtitle: context.l10n.adjustRestSubtitle,
                              value: _autoAdjustRestFromRpe,
                              onChanged: (v) {
                                setState(() => _autoAdjustRestFromRpe = v);
                                _saveAll();
                              },
                              compact: true,
                            ),
                          ),
                        ],
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.schedule,
                          title: context.l10n.setDurationTitle,
                          subtitle: context.l10n.setDurationSubtitle,
                          value: _setDurationTracking,
                          onChanged: (v) {
                            setState(() => _setDurationTracking = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.metronome,
                          title: context.l10n.metronomeSettingTitle,
                          subtitle: context.l10n.metronomeSettingSubtitle,
                          value: _metronomeEnabled,
                          onChanged: (v) {
                            setState(() => _metronomeEnabled = v);
                            _saveAll();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // === ASPETTO (unified with ExerciseCardSettings) ===
                    _buildExpandableSection(
                      context,
                      icon: AppIcons.colorLens,
                      title: context.l10n.appearanceSection,
                      subtitle: context.l10n.appearanceSubtitle,
                      color: context.colors.secondary,
                      initiallyExpanded: false,
                      children: [
                        _buildToggleRow(
                          context,
                          icon: AppIcons.insights,
                          title: context.l10n.showInsight,
                          subtitle: context.l10n.showInsightDescription,
                          value: _showInsight,
                          onChanged: (v) {
                            setState(() => _showInsight = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.timer,
                          title: context.l10n.showTimer,
                          subtitle: context.l10n.showTimerDescription,
                          value: _showTimer,
                          onChanged: (v) {
                            setState(() => _showTimer = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.calculateRounded,
                          title: context.l10n.showPlates,
                          subtitle: context.l10n.showPlatesDescription,
                          value: _showPlates,
                          onChanged: (v) {
                            setState(() => _showPlates = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildToggleRow(
                          context,
                          icon: AppIcons.speed,
                          title: context.l10n.showRpe,
                          subtitle: context.l10n.showRpeDescription,
                          value: _showRpe,
                          onChanged: (v) {
                            setState(() => _showRpe = v);
                            _saveAll();
                          },
                        ),
                        _buildDivider(),
                        _buildInterfaceSizeSelector(context),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.changesAutoSaved,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === BUILDERS ===

  Widget _buildExpandableSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool initiallyExpanded,
    required List<Widget> children,
    VoidCallback? onInfoPressed,
  }) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: theme.colorScheme.surface.withValues(alpha: 0),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onInfoPressed != null)
                IconButton(
                  icon: Icon(
                    AppIcons.infoOutline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onInfoPressed,
                  tooltip: _isItalian(context)
                      ? 'Come funziona il tracciamento avanzato'
                      : 'How advanced tracking works',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool compact = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: compact ? 18 : 22,
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      (compact
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.bodyLarge)
                          ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: value,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Interface Size Selector (unified font + layout) — Slider variant
  Widget _buildInterfaceSizeSelector(BuildContext context) {
    final theme = Theme.of(context);
    const sizes =
        InterfaceSize.values; // [extraSmall, small, medium, mediumLarge, large]
    final currentIndex = sizes.indexOf(_interfaceSize).toDouble();

    // Labels for each stop
    final labels = [
      context.l10n.settingsFontSizeExtraSmall,
      context.l10n.settingsFontSizeSmall,
      context.l10n.settingsFontSizeNormal,
      context.l10n.settingsFontSizeMediumLarge,
      context.l10n.settingsFontSizeLarge,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(AppIcons.formatSize, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.interfaceSize,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      labels[currentIndex.round()],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  context.l10n.interfaceSizeSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: currentIndex,
                    min: 0,
                    max: (sizes.length - 1).toDouble(),
                    divisions: sizes.length - 1,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      final newSize = sizes[value.round()];
                      setState(() => _interfaceSize = newSize);
                      ref
                          .read(appConfigProvider.notifier)
                          .setInterfaceSize(newSize);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  bool _isItalian(BuildContext context) => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('it');

  void _showAdvancedTrackingInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isItalian = _isItalian(context);

    final title = isItalian
        ? 'Guida Tracciamento Avanzato'
        : 'Advanced Tracking Guide';
    final intro = isItalian
        ? 'Queste opzioni rendono l’allenamento più intelligente: registrano la fatica reale e adattano suggerimenti in tempo reale.'
        : 'These options make training smarter: they track real fatigue and adapt suggestions in real time.';
    final howItWorksTitle = isItalian ? 'Funzionamenti' : 'How It Works';
    final howItWorksItems = isItalian
        ? const <String>[
            'RPE: dopo ogni serie indichi lo sforzo percepito (1-10).',
            'Suggerisci peso: usa l’RPE della serie precedente per proporti il carico successivo.',
            'Regola riposo: aumenta o riduce il recupero in base alla fatica rilevata.',
            'Durata esecuzione set: traccia il tempo sotto tensione (TUT).',
            'Metronomo TUT: emette un tick per mantenere il ritmo del set.',
          ]
        : const <String>[
            'RPE: after each set, you rate perceived effort (1-10).',
            'Suggest weight: uses previous set RPE to propose your next load.',
            'Adjust rest: increases or reduces recovery based on fatigue.',
            'Set execution time: tracks time under tension (TUT).',
            'TUT metronome: plays a tick to keep set tempo consistent.',
          ];
    final appearanceTitle = isItalian ? 'Come Appaiono' : 'How They Appear';
    final appearanceText = isItalian
        ? 'Le opzioni compaiono come toggle nella sezione Tracciamento Avanzato. Quando attivi RPE, si sbloccano automaticamente i controlli collegati (peso e riposo).'
        : 'Options appear as toggles in the Advanced Tracking section. When you enable RPE, linked controls (weight and rest) automatically become available.';
    final whyTitle = isItalian
        ? 'Perché Sono State Inserite'
        : 'Why They Were Added';
    final whyText = isItalian
        ? 'Per trasformare i dati della sessione in decisioni pratiche: carico più adatto, recupero più coerente, ritmo migliore e progressione più sostenibile.'
        : 'To turn session data into practical decisions: better load selection, more consistent recovery, better tempo, and more sustainable progression.';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                intro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              _buildInfoSection(
                context,
                title: howItWorksTitle,
                icon: AppIcons.speed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in howItWorksItems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '• $item',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                context,
                title: appearanceTitle,
                icon: AppIcons.insights,
                child: Text(appearanceText, style: theme.textTheme.bodyMedium),
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                context,
                title: whyTitle,
                icon: AppIcons.lightning,
                child: Text(whyText, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // === SAVE ===

  void _saveAll() {
    // Save workout/tracking settings to AppConfig
    ref
        .read(appConfigProvider.notifier)
        .updateWorkoutSettings(
          autoRestTimer: _autoRestTimer,
          autoCollapseCompleted: true, // Always enabled
          rpeTracking: _rpeTracking,
          autoAdjustWeightFromRpe: _autoAdjustWeightFromRpe,
          autoAdjustRestFromRpe: _autoAdjustRestFromRpe,
          setDurationTracking: _setDurationTracking,
          metronomeEnabled: _metronomeEnabled,
        );

    // Save appearance settings to ExerciseCardSettings (single source of truth)
    final notifier = ref.read(exerciseCardSettingsProvider.notifier);
    notifier.setShowInsight(_showInsight);
    notifier.setShowTimer(_showTimer);
    notifier.setShowPlates(_showPlates);
    notifier.setShowRpe(_showRpe);

    // Sound is always enabled (hardcoded)
    ref.read(appConfigProvider.notifier).setSoundEnabled(true);
  }
}
