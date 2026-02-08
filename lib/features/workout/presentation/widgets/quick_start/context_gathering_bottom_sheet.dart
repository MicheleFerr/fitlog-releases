/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
///
/// **Enhanced UX Features (2025):**
/// - "Use Last Settings" quick action for returning users
/// - Animated progress ring with step indicators
/// - Haptic feedback on all interactions
/// - Celebration animation on completion
/// - XP bonus for fast completion
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_context_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start/workout_category_bottom_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Bottom sheet for gathering workout context before category selection
///
/// Enhanced UX Features:
/// - Quick action "Use Last Settings" for returning users
/// - Step 1: Time available (5, 15, 30, 45+ min) - REQUIRED
/// - Step 2: Experience level (Beginner, Intermediate, Advanced) - CONDITIONAL
/// - Step 3: Demographics (Gender) - OPTIONAL, skip-enabled
/// - Progress ring animation
/// - Haptic feedback throughout
/// - Celebration on completion
class ContextGatheringBottomSheet extends ConsumerStatefulWidget {
  const ContextGatheringBottomSheet({super.key});

  @override
  ConsumerState<ContextGatheringBottomSheet> createState() =>
      _ContextGatheringBottomSheetState();
}

class _ContextGatheringBottomSheetState
    extends ConsumerState<ContextGatheringBottomSheet>
    with SingleTickerProviderStateMixin {
  // State
  int currentStep = 0;
  int? selectedTime;
  ExperienceLevel? selectedLevel;
  String? selectedGender;
  bool hasLastSettings = false;
  WorkoutContext? lastContext;

  // Analytics
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _step1StartTime;
  DateTime? _step2StartTime;

  // Edge cases
  bool showHelpHint = false;
  Timer? _helpTimer;

  // Page controller for smooth transitions
  final PageController _pageController = PageController();

  // Animation controller for progress ring
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _step1StartTime = DateTime.now();

    // Setup progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    // Check for last settings
    _checkLastSettings();
  }

  Future<void> _checkLastSettings() async {
    final savedContext = ref.read(workoutContextProvider);
    if (savedContext != null) {
      setState(() {
        hasLastSettings = true;
        lastContext = savedContext;
      });
    }
  }

  void _updateProgress(int step) {
    final targetProgress = (step + 1) / 3;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: targetProgress,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward(from: 0);
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _helpTimer?.cancel();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated progress ring
          _buildProgressRing(),
          const SizedBox(height: AppSpacing.lg),

          // Quick action: Use last settings (if available)
          if (hasLastSettings && currentStep == 0) ...[
            _buildUseLastSettingsCard(),
            const SizedBox(height: AppSpacing.md),
            _buildDividerWithText(context.l10n.orChooseNew),
            const SizedBox(height: AppSpacing.md),
          ],

          // PageView for steps
          SizedBox(
            height: hasLastSettings && currentStep == 0 ? 280 : 350,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1TimeSelection(),
                _buildStep2ExperienceLevel(),
                _buildStep3Demographics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Animated progress ring with step indicators
  Widget _buildProgressRing() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    CustomPaint(
                      size: const Size(48, 48),
                      painter: _ProgressRingPainter(
                        progress: 1.0,
                        color: context.colors.surfaceContainerHighest,
                        strokeWidth: 4,
                      ),
                    ),
                    // Animated progress ring
                    CustomPaint(
                      size: const Size(48, 48),
                      painter: _ProgressRingPainter(
                        progress: _progressAnimation.value,
                        color: context.colors.primary,
                        strokeWidth: 4,
                      ),
                    ),
                    // Step number
                    Text(
                      '${currentStep + 1}/3',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Step labels
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStepTitle(currentStep),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getStepSubtitle(currentStep),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStepTitle(int step) {
    return switch (step) {
      0 => context.l10n.contextTimeTitle,
      1 => context.l10n.contextExperienceTitle,
      2 => context.l10n.contextDemographicsTitle,
      _ => '',
    };
  }

  String _getStepSubtitle(int step) {
    return switch (step) {
      0 => context.l10n.stepRequired,
      1 => context.l10n.stepRecommended,
      2 => context.l10n.stepOptional,
      _ => '',
    };
  }

  /// "Use Last Settings" quick action card
  Widget _buildUseLastSettingsCard() {
    if (lastContext == null) return const SizedBox.shrink();

    return Material(
      color: context.colors.primaryContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _useLastSettings,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.flashOn,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.useLastSettings,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lastContext!.timeAvailable} min • ${lastContext!.experienceLevel?.localizedName(context) ?? context.l10n.any}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.arrowForwardIos,
                color: context.colors.primary,
                size: AppIconSize.small,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: context.colors.outlineVariant),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: context.colors.outlineVariant),
        ),
      ],
    );
  }

  void _useLastSettings() {
    HapticFeedback.mediumImpact();

    // Use the saved context directly
    if (lastContext != null) {
      // Update context with new timestamp
      final updatedContext = lastContext!.copyWith(
        timestamp: DateTime.now(),
        completionTimeMs: 0, // Instant
      );

      ref.read(workoutContextProvider.notifier).setContext(updatedContext);

      // Show quick feedback
      _showQuickStartConfirmation(updatedContext);
    }
  }

  void _showQuickStartConfirmation(WorkoutContext ctx) {
    // Close this bottom sheet
    Navigator.pop(context);

    // Open category selection bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const WorkoutCategoryBottomSheet(),
    );
  }

  /// Step 1: Time available selection
  Widget _buildStep1TimeSelection() {
    // Start help timer (15 seconds)
    _helpTimer?.cancel();
    _helpTimer = Timer(const Duration(seconds: 15), () {
      if (selectedTime == null && mounted) {
        setState(() => showHelpHint = true);
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time chips (2x2 grid)
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(5, '⚡', context.colors.tertiary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeChip(15, '🕐', context.colors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(30, '💪', context.colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeChip(45, '🏋️', context.colors.success),
                ),
              ],
            ),
          ],
        ),

        // Help hint (if user is slow)
        if (showHelpHint) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.helpOutline,
                  size: AppIconSize.small,
                  color: context.colors.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.contextTimeHelp,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeChip(int minutes, String emoji, Color color) {
    final isSelected = selectedTime == minutes;

    return Semantics(
      label: context.l10n.selectTimeMinutes(minutes),
      button: true,
      enabled: true,
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onTimeSelected(minutes),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : context.colors.surface.withValues(alpha: 0),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: context.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  context.l10n.timeMinutes(minutes),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTimeSelected(int time) {
    HapticFeedback.lightImpact();

    setState(() {
      selectedTime = time;
      showHelpHint = false;
    });

    // Log step 1 completion time
    final step1Time = DateTime.now()
        .difference(_step1StartTime!)
        .inMilliseconds;
    if (kDebugMode) {
      debugPrint('Step 1 completed in ${step1Time}ms');
    }

    // Update progress animation
    _updateProgress(1);

    // Navigate to Step 2 after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          currentStep = 1;
          _step2StartTime = DateTime.now();
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Step 2: Experience level selection (conditional UI)
  Widget _buildStep2ExperienceLevel() {
    final fastUI = selectedTime != null && selectedTime! < 30;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Experience level chips
        Column(
          children: [
            _buildExperienceChip(
              ExperienceLevel.beginner,
              showDescription: !fastUI,
            ),
            const SizedBox(height: 12),
            _buildExperienceChip(
              ExperienceLevel.intermediate,
              showDescription: !fastUI,
            ),
            const SizedBox(height: 12),
            _buildExperienceChip(
              ExperienceLevel.advanced,
              showDescription: !fastUI,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceChip(
    ExperienceLevel level, {
    required bool showDescription,
  }) {
    final isSelected = selectedLevel == level;
    final levelColor = level.badgeColor(context.isDarkMode);

    return Semantics(
      label: context.l10n.selectExperienceLevel(level.localizedName(context)),
      button: true,
      enabled: true,
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onExperienceSelected(level),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? levelColor.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? levelColor
                    : context.colors.surface.withValues(alpha: 0),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(level.emoji, style: context.textTheme.headlineMedium),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.localizedName(context),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? levelColor
                              : context.colors.onSurface,
                        ),
                      ),
                      if (showDescription) ...[
                        const SizedBox(height: 4),
                        Text(
                          level.localizedDescription(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    AppIcons.checkCircle,
                    color: levelColor,
                    size: AppIconSize.medium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onExperienceSelected(ExperienceLevel level) {
    HapticFeedback.lightImpact();

    setState(() {
      selectedLevel = level;
    });

    // Log step 2 completion time
    final step2Time = DateTime.now()
        .difference(_step2StartTime!)
        .inMilliseconds;
    if (kDebugMode) {
      debugPrint('Step 2 completed in ${step2Time}ms');
    }

    // Update progress animation
    _updateProgress(2);

    // Check if turbo user (total time <6 sec)
    final totalTime = _stopwatch.elapsedMilliseconds;
    if (totalTime < 6000) {
      _showTurboConfirmation();
    } else {
      _proceedToStep3();
    }
  }

  void _proceedToStep3() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          currentStep = 2;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Step 3: Demographics (optional, skip-enabled)
  Widget _buildStep3Demographics() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender chips
        Column(
          children: [
            _buildGenderChip('male', '👤', context.l10n.genderMale),
            const SizedBox(height: 12),
            _buildGenderChip('female', '👤', context.l10n.genderFemale),
            const SizedBox(height: 12),
            _buildGenderChip('other', '👤', context.l10n.genderOther),
          ],
        ),

        const SizedBox(height: 24),

        // Skip button (prominent but not pushy)
        Center(
          child: TextButton.icon(
            onPressed: _onDemographicsSkipped,
            icon: const Icon(AppIcons.skipNext, size: AppIconSize.small),
            label: Text(context.l10n.contextSkipForNow),
          ),
        ),

        // Bottom text (reassurance)
        const SizedBox(height: 8),
        Center(
          child: Text(
            context.l10n.contextDemographicsReassurance,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip(String value, String emoji, String label) {
    final isSelected = selectedGender == value;

    return Semantics(
      label: context.l10n.selectGender(label),
      button: true,
      enabled: true,
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onGenderSelected(value),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primary.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surface.withValues(alpha: 0),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: context.textTheme.headlineMedium),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.onSurface,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Icon(
                    AppIcons.checkCircle,
                    color: context.colors.primary,
                    size: AppIconSize.medium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onGenderSelected(String gender) {
    HapticFeedback.lightImpact();

    setState(() {
      selectedGender = gender;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _completeContextGathering();
    });
  }

  void _onDemographicsSkipped() {
    HapticFeedback.lightImpact();
    _completeContextGathering();
  }

  /// Show turbo confirmation dialog
  void _showTurboConfirmation() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.quickConfirmation),
        content: Text(
          context.l10n.quickConfirmationMessage(
            selectedTime!,
            selectedLevel!.localizedName(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Reset to step 1
              setState(() {
                currentStep = 0;
                selectedTime = null;
                selectedLevel = null;
                _stopwatch.reset();
                _stopwatch.start();
                _step1StartTime = DateTime.now();
              });
              _updateProgress(0);
              _pageController.jumpToPage(0);
            },
            child: Text(context.l10n.changeAnswers),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _proceedToStep3();
            },
            child: Text(context.l10n.letsGo),
          ),
        ],
      ),
    );
  }

  /// Complete context gathering and navigate to category selection
  void _completeContextGathering() {
    final totalTime = _stopwatch.elapsedMilliseconds;

    // Celebration haptic for completion
    HapticFeedback.heavyImpact();

    // Create context
    final ctx = WorkoutContext(
      timeAvailable: selectedTime!,
      experienceLevel: selectedLevel,
      gender: selectedGender,
      timestamp: DateTime.now(),
      completionTimeMs: totalTime,
    );

    // Save context to provider
    ref.read(workoutContextProvider.notifier).setContext(ctx);

    // Log analytics
    if (kDebugMode) {
      debugPrint('Context gathering completed:');
      debugPrint('  Time: ${ctx.timeAvailable}min');
      debugPrint('  Level: ${ctx.experienceLevel?.name ?? 'none'}');
      debugPrint('  Gender: ${ctx.gender ?? 'none'}');
      debugPrint(
        '  Total time: ${totalTime}ms (${ctx.completionSpeedCategory})',
      );
      debugPrint('  Suggested exercises: ${ctx.suggestedExerciseCount}');
    }

    // Close this bottom sheet
    Navigator.pop(context);

    // Open category selection bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const WorkoutCategoryBottomSheet(),
    );
  }
}

/// Custom painter for progress ring
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
