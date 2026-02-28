import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/equipment_profiles_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';
import 'package:cupertino_native/cupertino_native.dart';

class _PresetEntry {
  const _PresetEntry({required this.sets, required this.value});

  final int sets;
  final int value;

  _PresetEntry copyWith({int? sets, int? value}) {
    return _PresetEntry(sets: sets ?? this.sets, value: value ?? this.value);
  }
}

/// Workout settings section: rest times, sounds, vibration, screen, equipment.
class SettingsWorkoutSection extends ConsumerWidget {
  const SettingsWorkoutSection({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: 'Workout settings',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsWorkout,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Default Rest Time (between sets)
            buildSettingTile(
              context,
              title: context.l10n.settingsDefaultRestTime,
              subtitle: '${config.defaultRestTime}s',
              leading: const SemanticIcon(
                icon: AppIcons.timer,
                semanticLabel: 'Timer',
              ),
              onTap: () =>
                  _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),

            const Divider(),

            // Default Rest Between Exercises
            buildSettingTile(
              context,
              title: context.l10n.restBetweenExercises,
              subtitle: '${config.defaultRestBetweenExercises}s',
              leading: const SemanticIcon(
                icon: AppIcons.skipNext,
                semanticLabel: 'Rest between exercises',
              ),
              onTap: () => _showRestBetweenExercisesDialog(
                context,
                ref,
                config.defaultRestBetweenExercises,
              ),
            ),

            const Divider(),

            // Default sets/reps setup
            buildSettingTile(
              context,
              title: 'Preset rapido serie \u00d7 ripetizioni',
              subtitle:
                  '${config.defaultExerciseSets}\u00d7${config.defaultExerciseReps}',
              leading: const SemanticIcon(
                icon: AppIcons.tune,
                semanticLabel: 'Set and reps preset',
              ),
              onTap: () => _showDefaultSetRepSetupDialog(context, ref, config),
            ),

            const Divider(),

            // Sound toggle
            buildSwitchTile(
              context,
              title: context.l10n.settingsSounds,
              subtitle: context.l10n.settingsSoundsDesc,
              value: config.soundEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSoundEnabled(value);
              },
              leading: SemanticIcon(
                icon: config.soundEnabled
                    ? AppIcons.volumeUp
                    : AppIcons.volumeOff,
                semanticLabel: 'Sound',
                size: AppIconSize.medium,
              ),
            ),

            // Timer sound selection (only if sounds enabled)
            if (config.soundEnabled) ...[
              const Divider(),
              _buildTimerSoundSelector(context, ref, config),
            ],

            const Divider(),

            // Vibration toggle
            buildSwitchTile(
              context,
              title: context.l10n.settingsVibrations,
              subtitle: context.l10n.settingsVibrationsDesc,
              value: config.vibrationsEnabled,
              onChanged: (value) {
                ref
                    .read(appConfigProvider.notifier)
                    .setVibrationsEnabled(value);
              },
              leading: const SemanticIcon(
                icon: AppIcons.vibration,
                semanticLabel: 'Vibration',
                size: AppIconSize.medium,
              ),
            ),

            const Divider(),

            // Keep screen awake toggle
            buildSwitchTile(
              context,
              title: context.l10n.settingsKeepScreenAwake,
              subtitle: context.l10n.settingsKeepScreenAwakeDesc,
              value: config.keepScreenAwakeDuringWorkout,
              onChanged: (value) {
                ref
                    .read(appConfigProvider.notifier)
                    .setKeepScreenAwakeDuringWorkout(value);
              },
              leading: const SemanticIcon(
                icon: AppIcons.screenLockPortrait,
                semanticLabel: 'Screen lock',
                size: AppIconSize.medium,
              ),
            ),

            const Divider(),

            // Equipment Profiles
            buildSettingTile(
              context,
              title: context.l10n.equipmentProfiles,
              subtitle: context.l10n.equipmentProfilesDescription,
              leading: const SemanticIcon(
                icon: AppIcons.location,
                semanticLabel: 'Equipment profiles',
                size: AppIconSize.medium,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EquipmentProfilesScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Timer Sound Selector ---

  Widget _buildTimerSoundSelector(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
    String getSoundDisplayName(String soundName) {
      switch (soundName) {
        case 'sound':
          return context.l10n.settingsTimerSoundClassic;
        case 'timer_complete':
          return context.l10n.settingsTimerSoundComplete;
        case 'LightWeight':
          return context.l10n.settingsTimerSoundLightWeight;
        case 'YehBuddie':
          return context.l10n.settingsTimerSoundYehBuddie;
        default:
          return soundName;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SemanticIcon(
        icon: AppIcons.volumeUp,
        semanticLabel: 'Timer sound',
        size: AppIconSize.medium,
      ),
      title: Text(context.l10n.settingsTimerSound),
      subtitle: Text(getSoundDisplayName(config.timerSound)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview button
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.playCircleFilled,
              semanticLabel: 'Preview sound',
              size: AppIconSize.medium,
            ),
            onPressed: () => _previewTimerSound(config.timerSound),
            tooltip: context.l10n.settingsTimerSoundPreview,
          ),
          const SizedBox(width: 8),
          const SemanticIcon(
            icon: AppIcons.chevronRight,
            semanticLabel: 'Select sound',
          ),
        ],
      ),
      onTap: () => _showTimerSoundPicker(context, ref, config),
    );
  }

  // --- Timer Sound Picker ---

  void _showTimerSoundPicker(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
    final availableSounds = [
      {'name': 'sound', 'displayName': context.l10n.settingsTimerSoundClassic},
      {
        'name': 'timer_complete',
        'displayName': context.l10n.settingsTimerSoundComplete,
      },
      {
        'name': 'LightWeight',
        'displayName': context.l10n.settingsTimerSoundLightWeight,
      },
      {
        'name': 'YehBuddie',
        'displayName': context.l10n.settingsTimerSoundYehBuddie,
      },
    ];

    ModalService.showSheet(
      context,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SemanticIcon(
                      icon: AppIcons.volumeUp,
                      semanticLabel: 'Timer sound',
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.settingsTimerSound,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Sound list
              ...availableSounds.map((sound) {
                final soundName = sound['name']!;
                final displayName = sound['displayName']!;
                final isSelected = config.timerSound == soundName;

                return ListTile(
                  leading: SemanticIcon(
                    icon: isSelected
                        ? AppIcons.checkCircle
                        : AppIcons.radioButtonUnchecked,
                    semanticLabel: isSelected ? 'Selected' : 'Not selected',
                    size: AppIconSize.medium,
                    color: isSelected ? context.colors.primary : null,
                  ),
                  title: Text(
                    displayName,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? context.colors.primary : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const SemanticIcon(
                      icon: AppIcons.playCircleFilled,
                      semanticLabel: 'Preview',
                      size: AppIconSize.medium,
                    ),
                    onPressed: () => _previewTimerSound(soundName),
                  ),
                  onTap: () {
                    ref
                        .read(appConfigProvider.notifier)
                        .setTimerSound(soundName);
                    Navigator.of(bottomSheetContext).pop();

                    // Show feedback
                    SnackBarService.showSuccess(
                      context,
                      '${context.l10n.settingsTimerSound}: $displayName',
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // --- Preview Timer Sound ---

  void _previewTimerSound(String soundName) {
    const platform = MethodChannel(PlatformChannels.timerSoundFix);

    try {
      platform.invokeMethod('playTimerSound', {'soundName': soundName});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to preview timer sound: $e');
      }
    }
  }

  // --- Rest Time Dialog ---

  void _showRestTimeDialog(
    BuildContext context,
    WidgetRef ref,
    int currentTime,
  ) {
    int selectedTime = currentTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.settingsDefaultRestTimeDialog),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${selectedTime}s'),
              CNSlider(
                value: selectedTime.toDouble(),
                min: 30,
                max: 300,
                step: 10.0,
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
              onPressed: () async {
                await ref
                    .read(appConfigProvider.notifier)
                    .setDefaultRestTime(selectedTime);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  // --- Rest Between Exercises Dialog ---

  void _showRestBetweenExercisesDialog(
    BuildContext context,
    WidgetRef ref,
    int currentTime,
  ) {
    int selectedTime = currentTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.restBetweenExercises),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${selectedTime}s'),
              CNSlider(
                value: selectedTime.toDouble(),
                min: 30,
                max: 300,
                step: 10.0,
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
              onPressed: () async {
                await ref
                    .read(appConfigProvider.notifier)
                    .setDefaultRestBetweenExercises(selectedTime);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  // --- Default Set/Rep Setup Dialog ---

  List<_PresetEntry> _parsePresetCsv(
    String csv, {
    required List<_PresetEntry> fallback,
  }) {
    final tokens = csv.split(',');
    final parsed = <_PresetEntry>[];
    for (final token in tokens) {
      final parts = token.trim().toLowerCase().split('x');
      if (parts.length != 2) continue;
      final sets = int.tryParse(parts[0]);
      final value = int.tryParse(parts[1]);
      if (sets == null || value == null) continue;
      parsed.add(_PresetEntry(sets: sets, value: value));
    }
    return parsed.length == 3 ? parsed : fallback;
  }

  String _encodePresetCsv(List<_PresetEntry> presets) =>
      presets.map((p) => '${p.sets}x${p.value}').join(',');

  void _showDefaultSetRepSetupDialog(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
    final weightedPresets = _parsePresetCsv(
      config.defaultWeightedPresets,
      fallback: const [
        _PresetEntry(sets: 3, value: 10),
        _PresetEntry(sets: 4, value: 8),
        _PresetEntry(sets: 5, value: 5),
      ],
    );
    final repsPresets = _parsePresetCsv(
      config.defaultRepsPresets,
      fallback: const [
        _PresetEntry(sets: 3, value: 15),
        _PresetEntry(sets: 4, value: 12),
        _PresetEntry(sets: 2, value: 20),
      ],
    );
    final timePresets = _parsePresetCsv(
      config.defaultTimePresets,
      fallback: const [
        _PresetEntry(sets: 3, value: 30),
        _PresetEntry(sets: 3, value: 60),
        _PresetEntry(sets: 4, value: 45),
      ],
    );

    var selectedMode = ExerciseCountingMode.weighted;

    ModalService.showBottomSheet<void>(
      context,
      child: StatefulBuilder(
        builder: (context, setState) {
          List<_PresetEntry> activePresets;
          String unitLabel;
          int minValue;
          int maxValue;

          switch (selectedMode) {
            case ExerciseCountingMode.weighted:
              activePresets = weightedPresets;
              unitLabel = 'Ripetizioni';
              minValue = 3;
              maxValue = 20;
              break;
            case ExerciseCountingMode.reps:
              activePresets = repsPresets;
              unitLabel = 'Ripetizioni';
              minValue = 3;
              maxValue = 30;
              break;
            case ExerciseCountingMode.time:
              activePresets = timePresets;
              unitLabel = 'Secondi';
              minValue = 10;
              maxValue = 180;
              break;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serie e ripetizioni predefinite',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Peso \u00d7 Reps'),
                      selected: selectedMode == ExerciseCountingMode.weighted,
                      onSelected: (_) => setState(
                        () => selectedMode = ExerciseCountingMode.weighted,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Reps'),
                      selected: selectedMode == ExerciseCountingMode.reps,
                      onSelected: (_) => setState(
                        () => selectedMode = ExerciseCountingMode.reps,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Durata'),
                      selected: selectedMode == ExerciseCountingMode.time,
                      onSelected: (_) => setState(
                        () => selectedMode = ExerciseCountingMode.time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Preset disponibili',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < activePresets.length; i++) ...[
                  Text(
                    'Preset ${i + 1}: ${activePresets[i].sets}\u00d7${activePresets[i].value}${selectedMode == ExerciseCountingMode.time ? 's' : ''}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('Serie: ${activePresets[i].sets}'),
                  CNSlider(
                    value: activePresets[i].sets.toDouble(),
                    min: 1,
                    max: 8,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        activePresets[i] = activePresets[i].copyWith(
                          sets: value.round(),
                        );
                      });
                    },
                  ),
                  Text('$unitLabel: ${activePresets[i].value}'),
                  CNSlider(
                    value: activePresets[i].value.toDouble(),
                    min: minValue.toDouble(),
                    max: maxValue.toDouble(),
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        activePresets[i] = activePresets[i].copyWith(
                          value: value.round(),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final weightedCsv = _encodePresetCsv(weightedPresets);
                          final repsCsv = _encodePresetCsv(repsPresets);
                          final timeCsv = _encodePresetCsv(timePresets);

                          final primary = weightedPresets.first;
                          await ref
                              .read(appConfigProvider.notifier)
                              .setDefaultExercisePresets(
                                weightedPresets: weightedCsv,
                                repsPresets: repsCsv,
                                timePresets: timeCsv,
                              );
                          await ref
                              .read(appConfigProvider.notifier)
                              .setDefaultExerciseSetup(
                                sets: primary.sets,
                                reps: primary.value,
                              );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            SnackBarService.showSuccess(
                              context,
                              'Preset aggiornati',
                            );
                          }
                        },
                        child: Text(context.l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
