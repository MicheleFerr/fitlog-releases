import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class TimerRestStep extends StatefulWidget {

  const TimerRestStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  State<TimerRestStep> createState() => _TimerRestStepState();
}

class _TimerRestStepState extends State<TimerRestStep> with TickerProviderStateMixin {
  bool _showDemo = false;
  bool _isCompleted = false;
  bool _timerRunning = false;
  final int _remainingTime = 90; // 1:30 rest time
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startDemo() {
    setState(() {
      _showDemo = true;
    });
    _slideController.forward();
  }

  void _startTimer() {
    setState(() {
      _timerRunning = true;
    });

    // Simulate timer completion after 3 seconds for demo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _scaleController.forward().then((_) {
          setState(() {
            _isCompleted = true;
            _timerRunning = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
  size: AppIconSize.medium,
  color: colorScheme.primary,
),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingTimerRestTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingTimerRestDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Interactive Demo Section
          if (!_showDemo) ...[
            FilledButton.icon(
              onPressed: _startDemo,
              icon: const SemanticIcon(
  icon: AppIcons.play,
  semanticLabel: 'Play',
),
              label: Text(l10n.onboardingTryItOut),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ] else ...[
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Mock screen with timer overlay
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surface.withValues(alpha: 0.3),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background hint
                          Center(
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'it'
                                  ? 'Durante l\'allenamento'
                                  : 'During workout',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Timer overlay in top left
                          if (_timerRunning || _isCompleted)
                            Positioned(
                              top: 16,
                              left: 16,
                              child: ScaleTransition(
                                scale: _isCompleted ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                                child: _MockTimerOverlay(
                                  colorScheme: colorScheme,
                                  theme: theme,
                                  isCompleted: _isCompleted,
                                  remainingTime: _remainingTime,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start timer button or completion
                    if (!_timerRunning && !_isCompleted) ...[
                      FilledButton.icon(
                        onPressed: _startTimer,
                        icon: const SemanticIcon(
  icon: AppIcons.play,
  semanticLabel: 'Play',
),
                        label: Text(
                          Localizations.localeOf(context).languageCode == 'it'
                              ? 'Avvia Timer Riposo'
                              : 'Start Rest Timer',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Localizations.localeOf(context).languageCode == 'it'
                            ? 'Tocca per avviare il timer tra le serie'
                            : 'Tap to start rest timer between sets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (_isCompleted) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.complete,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.onboardingCompleted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        Localizations.localeOf(context).languageCode == 'it'
                            ? 'Timer in corso...'
                            : 'Timer running...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MockTimerOverlay extends StatelessWidget {

  const _MockTimerOverlay({
    required this.colorScheme,
    required this.theme,
    required this.isCompleted,
    required this.remainingTime,
  });
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isCompleted;
  final int remainingTime;

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? AppIcons.complete : AppIcons.timer,
            size: 16,
            color: isCompleted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'Complete!' : _formatTime(remainingTime),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCompleted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(width: 6),
            SemanticIcon(
  icon: AppIcons.pause,
  semanticLabel: 'Pause',
  size: AppIconSize.medium,
  color: colorScheme.onSurfaceVariant,
),
          ],
        ],
      ),
    );
  }
}
