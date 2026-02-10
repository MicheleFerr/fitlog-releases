/// Rest Timer widget integrato nell'header del workout
///
/// Design: rettangolo stondato con testo grande e leggibile
/// - Tap: mostra modal "Timer personalizzato" per scegliere durata
/// - Auto-reset quando arriva a 0
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/timer_action_bubble.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Timer compatto per l'header del workout
///
/// Design: rettangolo stondato con countdown ben leggibile
/// - Idle: mostra icona timer + "Rest"
/// - Running: mostra countdown MM:SS con progress bar
/// - Completed: auto-reset a idle
class HeaderRestTimer extends ConsumerStatefulWidget {
  const HeaderRestTimer({super.key, this.compact = false});

  /// Se true, usa dimensioni più piccole (per minimized view)
  final bool compact;

  @override
  ConsumerState<HeaderRestTimer> createState() => _HeaderRestTimerState();
}

class _HeaderRestTimerState extends ConsumerState<HeaderRestTimer> {
  /// Key per ottenere la posizione del timer (per il bubble)
  final GlobalKey _timerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // 🔧 PERF FIX: Consolidate 8 watches into 3 strategic watches using records
    // Watch 1: Timer state flags (boolean values)
    final timerFlags = ref.watch(
      unifiedTimerProvider.select((state) => (
        isTimerActive: state != null,
        isIdle: state == null || state.isIdle,
        isRunning: state?.isActive ?? false,
        isPaused: state?.isPaused ?? false,
        isCompleted: state?.isCompleted ?? false,
        isInterExercise: state?.type == TimerType.interExercise,
      )),
    );

    // Watch 2: Time values (numbers that update frequently)
    final timeValues = ref.watch(
      unifiedTimerProvider.select((state) => (
        remainingSeconds: state?.remainingSeconds ?? 0,
        remainingProgress: state?.remainingProgress ?? 0.0,
      )),
    );

    // Watch 3: Config (separate provider)
    final timerSound = ref.watch(appConfigProvider.select((c) => c.timerSound));

    // Extract flags for easier reading
    final isTimerActive = timerFlags.isTimerActive;
    final isIdle = timerFlags.isIdle;
    final isRunning = timerFlags.isRunning;
    final isPaused = timerFlags.isPaused;
    final isCompleted = timerFlags.isCompleted;
    final isInterExercise = timerFlags.isInterExercise;

    // Extract time values
    final remainingSeconds = timeValues.remainingSeconds;
    final remainingProgress = timeValues.remainingProgress;

    // Auto-reset quando completa (status completed O remainingSeconds == 0)
    final shouldReset =
        isTimerActive && (isCompleted || (remainingSeconds <= 0 && !isIdle));

    if (shouldReset) {
      // Schedule reset after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(unifiedTimerProvider.notifier).resetTimer();
        }
      });
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (isIdle) {
          _showTimerModal(context, timerSound);
        } else if (isRunning || isPaused) {
          // Mostra bubble con azioni: Pausa/Riprendi, +30s, Salta
          showTimerActionBubble(context: context, timerKey: _timerKey);
        }
      },
      // Long press to skip timer - kept as shortcut
      // NOTE: Previously wrapped in Tooltip, but Tooltip intercepts long-press
      // on mobile to show its message, preventing our onLongPress from firing.
      // Removed Tooltip - haptic feedback + visual reset is sufficient UX.
      onLongPress: () {
        if (!isIdle) {
          HapticFeedback.heavyImpact();
          ref.read(unifiedTimerProvider.notifier).skipTimer();
        }
      },
      child: AnimatedContainer(
        key: _timerKey,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 8 : 10,
          vertical: widget.compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(
            context,
            isIdle,
            isRunning,
            isPaused,
            remainingSeconds,
            isInterExercise: isInterExercise,
          ),
          borderRadius: BorderRadius.circular(widget.compact ? 10 : 12),
          border: Border.all(
            color: _getBorderColor(
              context,
              isIdle,
              isRunning,
              isPaused,
              remainingSeconds,
              isInterExercise: isInterExercise,
            ),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icona timer (skipNext per inter-exercise)
            Icon(
              isInterExercise
                  ? AppIcons.skipNext
                  : (isRunning
                      ? AppIcons.timer
                      : (isPaused ? AppIcons.pause : AppIcons.timer)),
              size: widget.compact ? AppIconSize.tiny : AppIconSize.small,
              color: _getTextColor(
                context,
                isIdle,
                isRunning,
                isPaused,
                remainingSeconds,
                isInterExercise: isInterExercise,
              ),
            ),
            SizedBox(width: widget.compact ? 4 : 6),
            // Testo
            if (isIdle)
              Text(
                context.l10n.restTime,
                style: TextStyle(
                  fontSize: widget.compact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(
                    context,
                    isIdle,
                    isRunning,
                    isPaused,
                    remainingSeconds,
                  ),
                ),
              )
            else
              _buildCountdown(
                context,
                remainingSeconds,
                remainingProgress,
                isRunning,
                isPaused,
                isInterExercise: isInterExercise,
              ),
          ],
        ),
      ),
    );
  }

  /// Countdown grande e leggibile
  /// 🔧 PERF FIX: Accept primitives instead of full UnifiedTimerState
  /// 🔧 PERF FIX: Wrap in RepaintBoundary to isolate frequent repaints
  Widget _buildCountdown(
    BuildContext context,
    int remainingSeconds,
    double progress,
    bool isRunning,
    bool isPaused, {
    bool isInterExercise = false,
  }) {
    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tempo rimanente
          Text(
            _formatTime(remainingSeconds),
            style: TextStyle(
              fontSize: widget.compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: _getTextColor(
                context,
                false,
                isRunning,
                isPaused,
                remainingSeconds,
                isInterExercise: isInterExercise,
              ),
            ),
          ),
          SizedBox(width: widget.compact ? 4 : 6),
          // Mini progress bar
          SizedBox(
            width: widget.compact ? 24 : 36,
            height: widget.compact ? 3 : 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: context.colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(
                    context,
                    remainingSeconds,
                    isInterExercise: isInterExercise,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra modal per selezione timer personalizzato
  // 🔧 PERF FIX: Accept timerSound directly instead of entire config
  void _showTimerModal(BuildContext context, String timerSound) {
    showModalBottomSheet(
      context: context,
      // 🔧 PERF FIX: Use theme color instead of hardcoded Colors.transparent
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (context) => _CustomTimerModal(
        onSelectDuration: (seconds) {
          Navigator.pop(context);
          ref
              .read(unifiedTimerProvider.notifier)
              .startTimer(
                durationSeconds: seconds,
                type: TimerType.rest,
                exerciseName: 'Rest',
                customSound: timerSound,
              );
        },
      ),
    );
  }

  /// 🔧 PERF FIX: Accept remainingSeconds directly instead of UnifiedTimerState
  Color _getBackgroundColor(
    BuildContext context,
    bool isIdle,
    bool isRunning,
    bool isPaused,
    int remainingSeconds, {
    bool isInterExercise = false,
  }) {
    if (isIdle) {
      return context.colors.surfaceContainerHighest.withValues(alpha: 0.8);
    }
    if (isPaused) {
      return context.colors.secondaryContainer.withValues(alpha: 0.5);
    }
    if (isRunning) {
      if (remainingSeconds <= 5) {
        return context.colors.errorContainer.withValues(alpha: 0.5);
      } else if (remainingSeconds <= 15) {
        return context.colors.tertiaryContainer.withValues(alpha: 0.5);
      }
      // Use tertiary container for inter-exercise timer
      return isInterExercise
          ? context.colors.tertiaryContainer.withValues(alpha: 0.5)
          : context.colors.primaryContainer.withValues(alpha: 0.5);
    }
    return context.colors.surfaceContainerHighest;
  }

  /// 🔧 PERF FIX: Accept remainingSeconds directly instead of UnifiedTimerState
  Color _getBorderColor(
    BuildContext context,
    bool isIdle,
    bool isRunning,
    bool isPaused,
    int remainingSeconds, {
    bool isInterExercise = false,
  }) {
    if (isIdle) {
      return context.colors.outline.withValues(alpha: 0.3);
    }
    if (isPaused) {
      return context.colors.secondary.withValues(alpha: 0.5);
    }
    if (isRunning) {
      return _getProgressColor(
        context,
        remainingSeconds,
        isInterExercise: isInterExercise,
      ).withValues(alpha: 0.5);
    }
    return context.colors.outline.withValues(alpha: 0.3);
  }

  /// 🔧 PERF FIX: Accept remainingSeconds directly instead of UnifiedTimerState
  Color _getTextColor(
    BuildContext context,
    bool isIdle,
    bool isRunning,
    bool isPaused,
    int remainingSeconds, {
    bool isInterExercise = false,
  }) {
    if (isIdle) {
      return context.colors.onSurfaceVariant;
    }
    if (isPaused) {
      return context.colors.secondary;
    }
    if (isRunning) {
      return _getProgressColor(
        context,
        remainingSeconds,
        isInterExercise: isInterExercise,
      );
    }
    return context.colors.onSurface;
  }

  Color _getProgressColor(
    BuildContext context,
    int remainingSeconds, {
    bool isInterExercise = false,
  }) {
    if (remainingSeconds <= 5) {
      return context.colors.error;
    } else if (remainingSeconds <= 15) {
      return context.colors.tertiary;
    }
    // Use tertiary color for inter-exercise timer to distinguish it
    return isInterExercise ? context.colors.tertiary : context.colors.primary;
  }

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Modal per timer personalizzato
class _CustomTimerModal extends StatefulWidget {
  const _CustomTimerModal({required this.onSelectDuration});

  final void Function(int seconds) onSelectDuration;

  @override
  State<_CustomTimerModal> createState() => _CustomTimerModalState();
}

class _CustomTimerModalState extends State<_CustomTimerModal> {
  int _selectedMinutes = 1;
  int _selectedSeconds = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titolo
          Text(
            context.l10n.customTimer,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.selectRestDuration,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Preset chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _PresetChip(
                label: '30s',
                seconds: 30,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '45s',
                seconds: 45,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '1:00',
                seconds: 60,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '1:30',
                seconds: 90,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '2:00',
                seconds: 120,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '3:00',
                seconds: 180,
                onTap: widget.onSelectDuration,
              ),
              _PresetChip(
                label: '5:00',
                seconds: 300,
                onTap: widget.onSelectDuration,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider con "oppure"
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.orCustom,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: context.colors.outline.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Picker personalizzato
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minuti
              _buildNumberPicker(
                context,
                value: _selectedMinutes,
                maxValue: 10,
                label: context.l10n.minutes,
                onChanged: (val) => setState(() => _selectedMinutes = val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Secondi
              _buildNumberPicker(
                context,
                value: _selectedSeconds,
                maxValue: 59,
                label: context.l10n.seconds,
                onChanged: (val) => setState(() => _selectedSeconds = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pulsante Start
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: context.l10n.a11yPlayTimer,
              button: true,
              child: FilledButton.icon(
                onPressed: () {
                  final totalSeconds =
                      (_selectedMinutes * 60) + _selectedSeconds;
                  if (totalSeconds > 0) {
                    HapticFeedback.mediumImpact();
                    widget.onSelectDuration(totalSeconds);
                  }
                },
                icon: const Icon(AppIcons.play),
                label: Text(
                  '${context.l10n.start} ${_formatDuration(_selectedMinutes, _selectedSeconds)}',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumberPicker(
    BuildContext context, {
    required int value,
    required int maxValue,
    required String label,
    required void Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement
              Semantics(
                label: context.l10n.a11yDecreaseTimer,
                button: true,
                child: IconButton(
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                  icon: const Icon(AppIcons.remove),
                  iconSize: AppIconSize.small,
                ),
              ),
              // Value
              SizedBox(
                width: 50,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              // Increment
              Semantics(
                label: context.l10n.a11yIncreaseTimer,
                button: true,
                child: IconButton(
                  onPressed: value < maxValue
                      ? () => onChanged(value + 1)
                      : null,
                  icon: const Icon(AppIcons.add),
                  iconSize: AppIconSize.small,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int minutes, int seconds) {
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Chip preset per selezione rapida
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.seconds,
    required this.onTap,
  });

  final String label;
  final int seconds;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(seconds);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
