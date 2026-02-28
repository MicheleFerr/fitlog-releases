import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class DefaultSetRepSetupSheet {
  static List<_PresetEntry> _parsePresetCsv(
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

  static String _encodePresetCsv(List<_PresetEntry> presets) =>
      presets.map((p) => '${p.sets}x${p.value}').join(',');

  static Future<int?> _showWheelPicker(
    BuildContext context, {
    required String title,
    required int min,
    required int max,
    required int initial,
  }) async {
    var selected = initial.clamp(min, max);
    final values = List.generate(max - min + 1, (i) => min + i);
    final initialItem = selected - min;
    final controller = FixedExtentScrollController(initialItem: initialItem);

    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: const Text('OK'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: controller,
                  onSelectedItemChanged: (index) {
                    selected = values[index];
                  },
                  children: values
                      .map(
                        (value) => Center(
                          child: Text(
                            '$value',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    AppConfig? initialConfig,
  }) async {
    final AppConfig config = initialConfig ?? ref.read(appConfigProvider);
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
    var restBetweenSets = config.defaultRestTime;
    var restBetweenExercises = config.defaultRestBetweenExercises;

    await ModalService.showBottomSheet<void>(
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

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Serie e ripetizioni predefinite',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Peso × Reps'),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < activePresets.length; i++) ...[
                    Text(
                      'Preset ${i + 1}: ${activePresets[i].sets}×${activePresets[i].value}${selectedMode == ExerciseCountingMode.time ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _PickerRow(
                      label: 'Serie',
                      value: '${activePresets[i].sets}',
                      onTap: () async {
                        final picked = await _showWheelPicker(
                          context,
                          title: 'Seleziona serie',
                          min: 1,
                          max: 8,
                          initial: activePresets[i].sets,
                        );
                        if (picked == null) return;
                        setState(() {
                          activePresets[i] = activePresets[i].copyWith(
                            sets: picked,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _PickerRow(
                      label: unitLabel,
                      value:
                          '${activePresets[i].value}${selectedMode == ExerciseCountingMode.time ? 's' : ''}',
                      onTap: () async {
                        final picked = await _showWheelPicker(
                          context,
                          title: 'Seleziona $unitLabel',
                          min: minValue,
                          max: maxValue,
                          initial: activePresets[i].value,
                        );
                        if (picked == null) return;
                        setState(() {
                          activePresets[i] = activePresets[i].copyWith(
                            value: picked,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Recuperi automatici',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PickerRow(
                    label: 'Tra set',
                    value: '${restBetweenSets}s',
                    onTap: () async {
                      final picked = await _showWheelPicker(
                        context,
                        title: 'Recupero tra set (secondi)',
                        min: 30,
                        max: 300,
                        initial: restBetweenSets,
                      );
                      if (picked == null) return;
                      setState(() {
                        restBetweenSets = picked;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _PickerRow(
                    label: 'Tra esercizi',
                    value: '${restBetweenExercises}s',
                    onTap: () async {
                      final picked = await _showWheelPicker(
                        context,
                        title: 'Recupero tra esercizi (secondi)',
                        min: 30,
                        max: 300,
                        initial: restBetweenExercises,
                      );
                      if (picked == null) return;
                      setState(() {
                        restBetweenExercises = picked;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annulla'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final weightedCsv = _encodePresetCsv(
                              weightedPresets,
                            );
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
                            await ref
                                .read(appConfigProvider.notifier)
                                .setDefaultRestTime(restBetweenSets);
                            await ref
                                .read(appConfigProvider.notifier)
                                .setDefaultRestBetweenExercises(
                                  restBetweenExercises,
                                );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              SnackBarService.showSuccess(
                                context,
                                'Preset aggiornati',
                              );
                            }
                          },
                          child: const Text('Salva'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PresetEntry {
  const _PresetEntry({required this.sets, required this.value});

  final int sets;
  final int value;

  _PresetEntry copyWith({int? sets, int? value}) {
    return _PresetEntry(sets: sets ?? this.sets, value: value ?? this.value);
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.unfold_more_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
