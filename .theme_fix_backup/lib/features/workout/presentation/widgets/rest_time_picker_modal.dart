import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/data/providers/preset_service_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/models/workout_preset.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/preset_selection_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';

class RestTimePickerModal extends ConsumerStatefulWidget {
  const RestTimePickerModal({
    super.key,
    this.initialRestTime,
    required this.onRestTimeSelected,
    this.source = 'rest_time_picker_modal',
    this.exerciseId,
  });

  final int? initialRestTime; // in seconds
  final Function(int?) onRestTimeSelected;

  /// Source screen/modal for analytics tracking
  final String source;

  /// Optional exercise ID for per-exercise tracking
  final String? exerciseId;

  @override
  ConsumerState<RestTimePickerModal> createState() => _RestTimePickerModalState();
}

class _RestTimePickerModalState extends ConsumerState<RestTimePickerModal> {
  late int _selectedMinutes;
  late int _selectedSeconds;
  late bool _hasRestTime;
  List<RestTimePreset>? _presets;

  @override
  void initState() {
    super.initState();
    if (widget.initialRestTime != null) {
      _selectedMinutes = widget.initialRestTime! ~/ 60;
      _selectedSeconds = widget.initialRestTime! % 60;
      _hasRestTime = true;
    } else {
      _selectedMinutes = 1;
      _selectedSeconds = 30;
      _hasRestTime = false;
    }

    // Load presets
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presetService = ref.read(presetServiceProvider);
    final presets = await presetService.getRestTimePresets();
    if (mounted) {
      setState(() {
        _presets = presets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = PresetSelectionTracker(analytics);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    const Icon(Icons.timer, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.restTime,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.restTimeDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Switch to enable/disable timer
                SwitchListTile(
                  value: _hasRestTime,
                  onChanged: (value) {
                    setState(() => _hasRestTime = value);
                  },
                  title: Text(context.l10n.useCustomTimer),
                  subtitle: Text(
                    _hasRestTime
                        ? context.l10n.timerActiveForExercise
                        : context.l10n.noSpecificTimer,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                if (_hasRestTime) ...[
                  // Quick presets
                  Text(
                    context.l10n.quickPresets,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_presets != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets!.where((p) => p.seconds != null).map((preset) {
                        final isSelected = _hasRestTime &&
                            preset.seconds == (_selectedMinutes * 60 + _selectedSeconds);

                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(preset.icon, size: 16),
                              const SizedBox(width: 4),
                              Text(_getLocalizedPresetLabel(context, preset.labelKey)),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) async {
                            if (selected && preset.seconds != null) {
                              // Track preset selection
                              await tracker.trackRestTimePresetSelected(
                                presetId: preset.id,
                                seconds: preset.seconds,
                                source: widget.source,
                                exerciseId: widget.exerciseId,
                              );

                              setState(() {
                                _selectedMinutes = preset.seconds! ~/ 60;
                                _selectedSeconds = preset.seconds! % 60;
                              });
                            }
                          },
                          selectedColor: context.colors.primary.withValues(alpha: 0.3),
                          checkmarkColor: context.colors.primary,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // Custom picker
                  Text(
                    context.l10n.customTimer,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colors.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Minutes
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  context.l10n.minutes,
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 28,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: _selectedMinutes,
                                  ),
                                  onSelectedItemChanged: (index) {
                                    setState(() => _selectedMinutes = index);
                                  },
                                  children: List.generate(11, (index) {
                                    return Center(
                                      child: Text(
                                        '$index',
                                        style: context.textTheme.titleMedium,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 1,
                          color: context.colors.outline.withValues(alpha: 0.3),
                        ),

                        // Seconds
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  context.l10n.seconds,
                                  style: context.textTheme.labelLarge,
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 28,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: _selectedSeconds ~/ 15,
                                  ),
                                  onSelectedItemChanged: (index) {
                                    setState(() => _selectedSeconds = index * 15);
                                  },
                                  children: List.generate(4, (index) {
                                    final seconds = index * 15;
                                    return Center(
                                      child: Text(
                                        seconds.toString().padLeft(2, '0'),
                                        style: context.textTheme.titleMedium,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Preview of selected time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 20,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.timerSet,
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          _formatTime(_selectedMinutes * 60 + _selectedSeconds),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final restTime = _hasRestTime
                                ? (_selectedMinutes * 60 + _selectedSeconds)
                                : null;

                            // Track timer selection
                            if (restTime == null) {
                              // No timer selected
                              await tracker.trackRestTimePresetSelected(
                                presetId: 'no_timer',
                                seconds: null,
                                source: widget.source,
                                exerciseId: widget.exerciseId,
                              );
                            } else {
                              // Check if custom timer (not matching any preset)
                              final matchesPreset = _presets?.any(
                                (p) => p.seconds == restTime,
                              ) ?? false;

                              if (!matchesPreset) {
                                // Custom timer
                                await tracker.trackCustomTimerSet(
                                  seconds: restTime,
                                  source: widget.source,
                                  exerciseId: widget.exerciseId,
                                );
                              }
                              // Note: Preset selections already tracked in FilterChip callback
                            }

                            widget.onRestTimeSelected(restTime);
                            Navigator.of(context).pop();
                          },
                          child: Text(context.l10n.confirm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get localized preset label by key
  String _getLocalizedPresetLabel(BuildContext context, String key) {
    final l10n = context.l10n;

    switch (key) {
      case 'restPresetNoTimer':
        return l10n.restPresetNoTimer;
      case 'restPresetThirtySeconds':
        return l10n.restPresetThirtySeconds;
      case 'restPresetOneMinute':
        return l10n.restPresetOneMinute;
      case 'restPresetOneMinuteThirty':
        return l10n.restPresetOneMinuteThirty;
      case 'restPresetTwoMinutes':
        return l10n.restPresetTwoMinutes;
      case 'restPresetThreeMinutes':
        return l10n.restPresetThreeMinutes;
      case 'restPresetFiveMinutes':
        return l10n.restPresetFiveMinutes;
      default:
        return key; // Fallback to key if not found
    }
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '0:00';

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes == 0) {
      return '${seconds}s';
    } else if (seconds == 0) {
      return '${minutes}min';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
