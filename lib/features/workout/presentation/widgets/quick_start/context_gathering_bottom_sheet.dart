/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_context_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start/workout_category_bottom_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Bottom sheet for gathering workout context before category selection
///
/// Features:
/// - Step 1: Time available (5, 15, 30, 45+ min) - REQUIRED
/// - Step 2: Experience level (Beginner, Intermediate, Advanced) - CONDITIONAL
///   - If ≥30min: Full UI with descriptions
///   - If <30min: Fast UI without descriptions
/// - Step 3: Demographics (Gender) - OPTIONAL, skip-enabled
/// - Edge cases handling:
///   - Turbo user (<6 sec): Confirmation dialog
///   - Slow user (>15 sec): Help hint tooltip
///   - Mid-flow abandonment: State persistence + resume option
/// - Full analytics tracking (P50/P75/P90 timing metrics)
/// - Material Design 3 compliant
/// - Theme-aware colors (dark/light mode)
class ContextGatheringBottomSheet extends ConsumerStatefulWidget {
  const ContextGatheringBottomSheet({super.key});

  @override
  ConsumerState<ContextGatheringBottomSheet> createState() =>
      _ContextGatheringBottomSheetState();
}

class _ContextGatheringBottomSheetState
    extends ConsumerState<ContextGatheringBottomSheet> {
  // State
  int currentStep = 0;
  int? selectedTime;
  ExperienceLevel? selectedLevel;
  String? selectedGender;

  // Analytics
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _step1StartTime;
  DateTime? _step2StartTime;

  // Edge cases
  bool showHelpHint = false;
  Timer? _helpTimer;

  // Page controller for smooth transitions
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _step1StartTime = DateTime.now();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _helpTimer?.cancel();
    _pageController.dispose();
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
          // Progress indicator (dots)
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // PageView for steps
          SizedBox(
            height: 350,
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

  /// Progress indicator (3 dots)
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
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
        // Title
        Text(
          context.l10n.contextTimeTitle,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          context.l10n.contextTimeSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onTimeSelected(minutes),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
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
    setState(() {
      selectedTime = time;
      showHelpHint = false;
    });

    // Log step 1 completion time
    final step1Time = DateTime.now().difference(_step1StartTime!).inMilliseconds;
    if (kDebugMode) {
      debugPrint('Step 1 completed in ${step1Time}ms');
    }

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
        // Title
        Text(
          context.l10n.contextExperienceTitle,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle (only if not fast UI)
        if (!fastUI)
          Text(
            context.l10n.contextExperienceSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 24),

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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onExperienceSelected(level),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? levelColor.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? levelColor : Colors.transparent,
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
                          color: isSelected ? levelColor : context.colors.onSurface,
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
    setState(() {
      selectedLevel = level;
    });

    // Log step 2 completion time
    final step2Time = DateTime.now().difference(_step2StartTime!).inMilliseconds;
    if (kDebugMode) {
      debugPrint('Step 2 completed in ${step2Time}ms');
    }

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
        // Title (Value-First Messaging)
        Text(
          context.l10n.contextDemographicsTitle,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle (explain value)
        Text(
          context.l10n.contextDemographicsSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

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
          child: TextButton(
            onPressed: _onDemographicsSkipped,
            child: Text(context.l10n.contextSkipForNow),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onGenderSelected(value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primary.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? context.colors.primary : Colors.transparent,
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
                    color: isSelected ? context.colors.primary : context.colors.onSurface,
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
    setState(() {
      selectedGender = gender;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _completeContextGathering();
    });
  }

  void _onDemographicsSkipped() {
    _completeContextGathering();
  }

  /// Show turbo confirmation dialog
  void _showTurboConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
              // Reset to step 1
              setState(() {
                currentStep = 0;
                selectedTime = null;
                selectedLevel = null;
                _stopwatch.reset();
                _stopwatch.start();
                _step1StartTime = DateTime.now();
              });
              _pageController.jumpToPage(0);
            },
            child: Text(context.l10n.changeAnswers),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
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

    // Create context
    final context = WorkoutContext(
      timeAvailable: selectedTime!,
      experienceLevel: selectedLevel,
      gender: selectedGender,
      timestamp: DateTime.now(),
      completionTimeMs: totalTime,
    );

    // Save context to provider
    ref.read(workoutContextProvider.notifier).setContext(context);

    // Log analytics
    if (kDebugMode) {
      debugPrint('Context gathering completed:');
    }
    debugPrint('  Time: ${context.timeAvailable}min');
    if (kDebugMode) {
      debugPrint('  Level: ${context.experienceLevel?.name ?? 'none'}');
    }
    debugPrint('  Gender: ${context.gender ?? 'none'}');
    if (kDebugMode) {
      debugPrint('  Total time: ${totalTime}ms (${context.completionSpeedCategory})');
    }
    debugPrint('  Suggested exercises: ${context.suggestedExerciseCount}');

    // Close this bottom sheet
    Navigator.pop(this.context);

    // Open category selection bottom sheet
    showModalBottomSheet(
      context: this.context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const WorkoutCategoryBottomSheet(),
    );
  }
}
