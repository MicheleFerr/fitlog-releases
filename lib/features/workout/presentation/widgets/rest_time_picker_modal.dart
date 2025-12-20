import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
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

  // 🔧 FIX: Store controllers to allow programmatic scrolling when presets are selected
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

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

    // Initialize scroll controllers
    _minutesController = FixedExtentScrollController(initialItem: _selectedMinutes);
    _secondsController = FixedExtentScrollController(initialItem: _selectedSeconds ~/ 15);

    // Load presets
    _loadPresets();
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    try {
      // 🐛 BUG FIX: Use async provider to ensure service is initialized
      // This prevents "JSONPresetService not initialized" race condition
      final presetService = await ref.read(presetServiceAsyncProvider.future);
      final presets = await presetService.getRestTimePresets();
      if (mounted) {
        setState(() {
          _presets = presets;
        });
      }
    } catch (e) {
      // Service initialization failed - presets will be empty but modal still works
      // The time picker wheel still allows custom time selection
      debugPrint('❌ Failed to load rest time presets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = PresetSelectionTracker(analytics);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Row(
            children: [
              const Icon(AppIcons.timer, size: 24),
              const SizedBox(width: 8),
              Text(
                context.l10n.restTime,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.restTimeDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

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
              style: context.textTheme.bodySmall,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          if (_hasRestTime) ...[
            const SizedBox(height: 12),

            // Quick presets
            Text(
              context.l10n.quickPresets,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

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
                        Icon(preset.icon, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _getLocalizedPresetLabel(context, preset.labelKey),
                          style: context.textTheme.labelMedium,
                        ),
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

                        final newMinutes = preset.seconds! ~/ 60;
                        final newSeconds = preset.seconds! % 60;

                        setState(() {
                          _selectedMinutes = newMinutes;
                          _selectedSeconds = newSeconds;
                        });

                        // 🔧 FIX: Animate pickers to new position so UI reflects selection
                        // Use jumpToItem for instant update (no await needed)
                        _minutesController.jumpToItem(newMinutes);
                        _secondsController.jumpToItem(newSeconds ~/ 15);
                      }
                    },
                    selectedColor: context.colors.primary.withValues(alpha: 0.3),
                    checkmarkColor: context.colors.primary,
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Compact custom picker
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Minutes
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            context.l10n.minutes,
                            style: context.textTheme.labelSmall,
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 28,
                            // 🔧 FIX: Use stored controller for programmatic scrolling
                            scrollController: _minutesController,
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
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    color: context.colors.outline.withValues(alpha: 0.3),
                  ),

                  // Seconds
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            context.l10n.seconds,
                            style: context.textTheme.labelSmall,
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 28,
                            // 🔧 FIX: Use stored controller for programmatic scrolling
                            scrollController: _secondsController,
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

            const SizedBox(height: 8),

            // Preview of selected time - compact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.timer,
                    size: 18,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.timerSet,
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_selectedMinutes * 60 + _selectedSeconds),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons - always visible at bottom
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
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
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(context.l10n.confirm),
                ),
              ),
            ],
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
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
