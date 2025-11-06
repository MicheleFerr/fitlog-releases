/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerStatefulWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseStartButton extends ConsumerStatefulWidget {
  
  const ExerciseStartButton({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.onStarted,
    this.isFirstSet = true,
  });
  final String exerciseId;
  final String exerciseName;
  final VoidCallback? onStarted;
  final bool isFirstSet;

  @override
  ConsumerState<ExerciseStartButton> createState() => _ExerciseStartButtonState();
}

class _ExerciseStartButtonState extends ConsumerState<ExerciseStartButton> {
  bool _isCountingDown = false;
  int _countdownValue = 3;
  Timer? _countdownTimer;
  bool _hasStarted = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });
    
    // Haptic feedback for start
    HapticFeedback.mediumImpact();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
        // Haptic tick for each countdown
        HapticFeedback.lightImpact();
      } else {
        // Final countdown reached
        timer.cancel();
        _onCountdownComplete();
      }
    });
  }

  void _onCountdownComplete() {
    // Heavy haptic for GO!
    HapticFeedback.heavyImpact();
    
    // Mark exercise as started for duration tracking
    final tracker = ref.read(setDurationTrackerProvider);
    tracker.markExerciseStarted(widget.exerciseId);
    
    // Debug: Verify timestamp was saved
    final startTime = tracker.getSetStartTime(widget.exerciseId, 1);
    if (startTime != null) {
      debugPrint('✅ Set 1 timestamp saved at: ${startTime.toIso8601String()}');
    } else {
      debugPrint('❌ WARNING: Set 1 timestamp not saved!');
    }
    
    setState(() {
      _isCountingDown = false;
      _hasStarted = true;
    });
    
    // Callback to parent
    widget.onStarted?.call();
    
    // Auto-hide after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _hasStarted = true;
        });
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdownValue = 3;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    
    // If exercise has started, show a subtle indicator instead
    if (_hasStarted) {
      return _buildStartedIndicator(context);
    }
    
    // Show countdown overlay
    if (_isCountingDown) {
      return _buildCountdownOverlay(context);
    }
    
    // Show start button
    return _buildStartButton(context);
  }

  Widget _buildStartButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: _startCountdown,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.play,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.startTrackingDuration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                l10n.tapToStart,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Countdown number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _countdownValue > 0 
                  ? colorScheme.primary 
                  : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _countdownValue > 0 ? '$_countdownValue' : '✓',
                  key: ValueKey(_countdownValue),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: _countdownValue > 0 ? 16 : 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _countdownValue > 0 ? l10n.getReady : l10n.goStartYourSet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: _countdownValue == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (_countdownValue > 0)
            TextButton(
              onPressed: _cancelCountdown,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                l10n.cancel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartedIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Return empty container - tracking happens invisibly
    return const SizedBox.shrink();
  }
}

