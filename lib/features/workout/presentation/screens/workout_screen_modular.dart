import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_analytics_bar.dart';
import '../providers/workout_provider.dart';
import '../providers/zen_mode_provider.dart';
import '../widgets/workout_view.dart';
import '../widgets/empty_states/workout_welcome_view.dart';
import '../widgets/workout_actions/workout_fab.dart';
import '../widgets/workout_actions/workout_settings_menu.dart';
import '../widgets/draggable_tutorial_overlay.dart';

/// WorkoutScreen modulare e ottimizzato - Tier 1 Architecture
/// Orchestrator principale che coordina i componenti modulari
class WorkoutScreenModular extends ConsumerWidget {
  const WorkoutScreenModular({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Performance optimization: use .select() for specific properties
    final currentWorkout = ref.watch(
      currentWorkoutProvider.select((w) => w),
    );
    final workoutName = ref.watch(
      currentWorkoutProvider.select((w) => w?.name),
    );
    final workoutIsActive = ref.watch(
      currentWorkoutProvider.select((w) => w?.isActive ?? false),
    );
    
    // Zen mode state with optimized selectors
    final zenIsEnabled = ref.watch(
      zenModeProvider.select((z) => z.isEnabled),
    );
    final zenHideTutorials = ref.watch(
      zenModeProvider.select((z) => z.config.hideTutorials),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackNavigation(context, ref);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(
          context: context,
          ref: ref,
          workoutName: workoutName,
          workoutIsActive: workoutIsActive,
          zenIsEnabled: zenIsEnabled,
          currentWorkout: currentWorkout,
        ),
        body: Column(
          children: [
            // Analytics bar at top (non-intrusive)
            if (currentWorkout != null && workoutIsActive)
              const WorkoutAnalyticsBar(),
            
            // Main content area
            Expanded(
              child: Stack(
                children: [
                  // Main content
                  currentWorkout == null
                      ? const WorkoutWelcomeView()
                      : WorkoutView(workout: currentWorkout),
                  
                  // Tier-1 Timer Overlay
                  Consumer(
                    builder: (context, ref, child) {
                      final shouldShow = ref.watch(shouldShowTier1TimerProvider);
                      return shouldShow ? const Tier1MinimalTimerOverlay() : const SizedBox.shrink();
                    },
                  ),
                  
                  // TimerRecoveryFAB rimosso - non necessario con bottom sheet
                ],
              ),
            ),
          ],
        ),
        // floatingActionButton: _buildFAB(
        //   context: context,
        //   ref: ref,
        //   showTutorial: !zenIsEnabled || !zenHideTutorials,
        // ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required WidgetRef ref,
    required String? workoutName,
    required bool workoutIsActive,
    required bool zenIsEnabled,
    required dynamic currentWorkout,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Row(
        children: [
          if (zenIsEnabled) ...[
            _buildZenBadge(context),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              workoutName ?? l10n.gymbroTracklog,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: _buildLeadingButton(
        context: context,
        ref: ref,
        workoutIsActive: workoutIsActive,
        hasWorkout: currentWorkout != null,
      ),
      actions: [
        if (currentWorkout != null && workoutIsActive)
          IconButton(
            onPressed: () => _completeWorkout(context, ref),
            icon: const Icon(Icons.check_circle),
            tooltip: l10n.completeWorkout,
          ),
        IconButton(
          onPressed: () => _showSettingsMenu(context, ref),
          icon: const Icon(Icons.more_vert),
          tooltip: l10n.settings,
        ),
      ],
    );
  }

  Widget _buildZenBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.self_improvement,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'ZEN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingButton({
    required BuildContext context,
    required WidgetRef ref,
    required bool workoutIsActive,
    required bool hasWorkout,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (hasWorkout && workoutIsActive) {
      return IconButton(
        icon: const Icon(Icons.home),
        onPressed: () => _handleBackNavigation(context, ref),
        tooltip: l10n.backToHomeKeepActive,
      );
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.goNamed('home'),
      tooltip: l10n.backToHome,
    );
  }

  Widget _buildFAB({
    required BuildContext context,
    required WidgetRef ref,
    required bool showTutorial,
  }) {
    if (showTutorial) {
      return const DraggableTutorialOverlay(
        child: WorkoutFAB(),
      );
    }

    return const WorkoutFAB();
  }

  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    final l10n = AppLocalizations.of(context)!;

    if (currentWorkout != null && currentWorkout.isActive) {
      // Show dialog to confirm keeping workout active
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.keepWorkoutActive),
          content: Text(l10n.keepWorkoutActiveDescription),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed('home');
              },
              child: Text(l10n.keepActive),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currentWorkoutProvider.notifier).cancelWorkout();
                context.goNamed('home');
              },
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
    } else {
      context.goNamed('home');
    }
  }

  void _completeWorkout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completeWorkout),
        content: Text(l10n.completeWorkoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.complete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(currentWorkoutProvider.notifier).completeWorkout();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.workoutCompleted),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.goNamed('home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorCompletingWorkout),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkoutSettingsMenu(),
    );
  }
}

// TimerRecoveryFAB rimosso - non più necessario con il timer bottom sheet

// Placeholder for draggable tutorial overlay
class DraggableTutorialOverlay extends StatelessWidget {
  final Widget child;
  
  const DraggableTutorialOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}