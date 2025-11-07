/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ROUTINE CENTER SCREEN - Main hub for managing flexible routines
///
/// Features:
/// - Display active routine with prominent badge
/// - List all inactive/paused routines
/// - Create new routine button
/// - Activate/Archive/Delete actions
/// - Real-time sync with Firebase
/// - Empty state for new users
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
// TODO: Reimplementare onboarding migliore
// import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/routine_card.dart';
// TODO: Reimplementare onboarding migliore
// import 'package:gymbro_flutter_new/features/routine/presentation/widgets/onboarding/routine_onboarding_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/skip_recovery_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_editor_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_detail_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_reminder_service_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/workout_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_suggestion_card.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Main screen for managing all flexible routines
class RoutineCenterScreen extends ConsumerStatefulWidget {
  const RoutineCenterScreen({super.key});

  @override
  ConsumerState<RoutineCenterScreen> createState() =>
      _RoutineCenterScreenState();
}

class _RoutineCenterScreenState extends ConsumerState<RoutineCenterScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Reimplementare onboarding migliore
    // Check onboarding status after first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkOnboarding();
    // });
  }

  // TODO: Reimplementare onboarding migliore
  // Future<void> _checkOnboarding() async {
  //   final hasSeenOnboarding = ref.read(routineOnboardingProvider);
  //
  //   if (!hasSeenOnboarding && mounted) {
  //     // Show onboarding as fullscreen dialog
  //     await Navigator.of(context).push(
  //       MaterialPageRoute(
  //         fullscreenDialog: true,
  //         builder: (context) => RoutineOnboardingScreen(
  //           onComplete: () {
  //             // Mark as completed
  //             ref.read(routineOnboardingProvider.notifier).completeOnboarding();
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(userFlexibleRoutinesProvider);
    final activeRoutineAsync = ref.watch(activeFlexibleRoutineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routine Center',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back),
          onPressed: () async {
            // First try Navigator pop (for internal navigation like detail screens)
            final didPop = await Navigator.of(context).maybePop();

            if (!didPop && context.mounted) {
              // Check if GoRouter can pop, otherwise go home
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          // Create new routine button
          IconButton(
            onPressed: () => _navigateToCreateRoutine(context),
            icon: Icon(AppIcons.addCircleOutline),
            color: context.colors.primary,
            iconSize: 28,
            tooltip: 'Create New Routine',
          ),
          // TODO: Reimplementare onboarding migliore
          // More options menu
          // PopupMenuButton<String>(
          //   onSelected: (value) {
          //     if (value == 'tutorial') {
          //       _showTutorialAgain();
          //     }
          //   },
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(
          //       value: 'tutorial',
          //       child: Row(
          //         children: [
          //           Icon(AppIcons.education, size: 20),
          //           SizedBox(width: 12),
          //           Text('Show Tutorial'),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) =>
            _buildContent(context, ref, routines, activeRoutineAsync.value),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<FlexibleRoutine> allRoutines,
    FlexibleRoutine? activeRoutine,
  ) {
    // Separate active and inactive routines
    final inactiveRoutines = allRoutines
        .where((r) => !r.isActive && !r.isArchived && !r.isCompleted)
        .toList();

    final archivedRoutines =
        allRoutines.where((r) => r.isArchived).toList();

    // If no routines at all
    if (allRoutines.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh routines
        ref.invalidate(userFlexibleRoutinesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Active routine section
          if (activeRoutine != null) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: 'Active Routine',
                icon: AppIcons.playCircle,
                color: context.colors.primary,
              ),
            ),
            SliverToBoxAdapter(
              child: RoutineCard(
                routine: activeRoutine,
                showActiveBadge: true,
                onTap: () => _navigateToRoutineDetail(context, activeRoutine),
                onArchive: () =>
                    _archiveRoutine(context, ref, activeRoutine.id),
                onDelete: () => _deleteRoutine(context, ref, activeRoutine.id),
              ),
            ),
            // Workout Suggestion Card (AI-powered next workout prediction)
            SliverToBoxAdapter(
              child: _buildWorkoutSuggestionCard(context, ref),
            ),
            // Skip Recovery Card
            SliverToBoxAdapter(
              child: _buildSkipRecoveryCard(context, ref, activeRoutine),
            ),
          ],

          // Inactive routines section
          if (inactiveRoutines.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: 'Other Routines',
                icon: AppIcons.folderOutlined,
                color: context.colors.secondary,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final routine = inactiveRoutines[index];
                  return RoutineCard(
                    routine: routine,
                    showActiveBadge: false,
                    onTap: () => _navigateToRoutineDetail(context, routine),
                    onActivate: () => _activateRoutine(context, ref, routine),
                    onArchive: () => _archiveRoutine(context, ref, routine.id),
                    onDelete: () => _deleteRoutine(context, ref, routine.id),
                  );
                },
                childCount: inactiveRoutines.length,
              ),
            ),
          ],

          // Archived routines section
          if (archivedRoutines.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                title: 'Archived',
                icon: AppIcons.archive,
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final routine = archivedRoutines[index];
                  return RoutineCard(
                    routine: routine,
                    showActiveBadge: false,
                    onTap: () => _navigateToRoutineDetail(context, routine),
                    onActivate: () => _activateRoutine(context, ref, routine),
                    onArchive: () =>
                        _unarchiveRoutine(context, ref, routine.id),
                    onDelete: () => _deleteRoutine(context, ref, routine.id),
                  );
                },
                childCount: archivedRoutines.length,
              ),
            ),
          ],

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.calendarTodayOutlined,
              size: 80,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 24),
            Text(
              'No Routines Yet',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Create your first flexible routine to start tracking your fitness journey with multi-period planning and smart skip recovery.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateRoutine(context),
              icon: Icon(AppIcons.add, color: context.colors.onPrimary),
              label: Text(
                'Create Your First Routine',
                style: TextStyle(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Choose from popular patterns or create your own custom schedule',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final isPermissionError =
        error.toString().toLowerCase().contains('permission');
    final errorMessage = isPermissionError
        ? 'Please check your Firebase permissions and authentication status'
        : error.toString();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.errorOutlineRounded,
              size: 64,
              color: context.colors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading routines',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // First try Navigator pop (for internal navigation)
                final didPop = await Navigator.of(context).maybePop();

                if (!didPop && context.mounted) {
                  // Check if GoRouter can pop, otherwise go home
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                }
              },
              icon: Icon(AppIcons.back),
              label: Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Reimplementare onboarding migliore
  // void _showTutorialAgain() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       fullscreenDialog: true,
  //       builder: (context) => RoutineOnboardingScreen(
  //         onComplete: () {
  //           Navigator.of(context).pop();
  //           SnackBarService.showSuccess(context, 'Tutorial completed! 📚');
  //         },
  //       ),
  //     ),
  //   );
  // }

  // === NAVIGATION ===

  void _navigateToCreateRoutine(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RoutineEditorScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _navigateToRoutineDetail(
    BuildContext context,
    FlexibleRoutine routine,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoutineDetailScreen(routineId: routine.id),
      ),
    );
  }

  // === ACTIONS ===

  Future<void> _activateRoutine(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
  ) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Activate Routine',
      message:
          'Activating "${routine.name}" will deactivate your current active routine. Continue?',
      isDangerous: false,
    );

    if (confirmed) {
      final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
      final success = await notifier.activateRoutine(routine.id);

      if (context.mounted) {
        if (success) {
          SnackBarService.showSuccess(
            context,
            '"${routine.name}" is now active 🎯',
          );
        } else {
          final error = ref.read(flexibleRoutineNotifierProvider).error;
          SnackBarService.showError(
            context,
            error ?? 'Failed to activate routine',
          );
        }
      }
    }
  }

  Future<void> _archiveRoutine(
    BuildContext context,
    WidgetRef ref,
    String routineId,
  ) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Archive Routine',
      message:
          'Archived routines can be unarchived later. Your progress will be preserved.',
      isDangerous: false,
    );

    if (confirmed) {
      final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
      final success = await notifier.archiveRoutine(routineId);

      if (context.mounted) {
        if (success) {
          SnackBarService.showSuccess(
            context,
            'Routine archived 📦',
          );
        } else {
          final error = ref.read(flexibleRoutineNotifierProvider).error;
          SnackBarService.showError(
            context,
            error ?? 'Failed to archive routine',
          );
        }
      }
    }
  }

  Future<void> _unarchiveRoutine(
    BuildContext context,
    WidgetRef ref,
    String routineId,
  ) async {
    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.unarchiveRoutine(routineId);

    if (context.mounted) {
      if (success) {
        SnackBarService.showSuccess(
          context,
          'Routine unarchived ✅',
        );
      } else {
        final error = ref.read(flexibleRoutineNotifierProvider).error;
        SnackBarService.showError(
          context,
          error ?? 'Failed to unarchive routine',
        );
      }
    }
  }

  Future<void> _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    String routineId,
  ) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Delete Routine',
      message:
          'This action cannot be undone. All progress and history will be permanently deleted.',
      isDangerous: true,
    );

    if (confirmed) {
      final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
      final success = await notifier.deleteRoutine(routineId);

      if (context.mounted) {
        if (success) {
          SnackBarService.showSuccess(
            context,
            'Routine deleted',
          );
        } else {
          final error = ref.read(flexibleRoutineNotifierProvider).error;
          SnackBarService.showError(
            context,
            error ?? 'Failed to delete routine',
          );
        }
      }
    }
  }

  // === WORKOUT SUGGESTION ===

  Widget _buildWorkoutSuggestionCard(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(workoutSuggestionProvider);
    final completionStatusAsync = ref.watch(todayCompletionStatusProvider);

    // ✅ NEW: Check if today's workout is already completed
    final isCompletedToday = completionStatusAsync != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: isCompletedToday
          ? _buildCompletionMessage(context, ref, completionStatusAsync)
          : suggestionAsync.when(
              data: (suggestion) => WorkoutSuggestionCard(
                suggestion: suggestion,
                onStartWorkout: (workoutName) async {
                  // Haptic feedback
                  await HapticFeedback.mediumImpact();

                  // Get template by name
                  final templatesAsync = ref.read(customWorkoutTemplatesProvider);

                  await templatesAsync.when(
                    data: (templates) async {
                      // Find template by normalized name (case-insensitive)
                      final template = templates.firstWhere(
                        (t) => t.name.toLowerCase() == workoutName.toLowerCase(),
                        orElse: () => templates.first, // Fallback to first template if not found
                      );

                      // Start workout from template
                      ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);

                      // Navigate to workout screen
                      if (context.mounted) {
                        context.goNamed('workout');
                      }
                    },
                    loading: () {
                      SnackBarService.showInfo(
                        context,
                        'Loading template...',
                      );
                    },
                    error: (error, _) {
                      SnackBarService.showError(
                        context,
                        'Failed to load template: $error',
                      );
                    },
                  );
                },
                onShowAlternatives: () {
                  // TODO: Show alternatives dialog with other suggestions
                  SnackBarService.showInfo(
                    context,
                    'Alternatives feature coming soon!',
                  );
                },
                onWhyThisSuggestion: () {
                  // Show explanation of why this workout was suggested
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Why This Suggestion?'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Suggestion Level: ${_getLevelName(suggestion.level)}',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              suggestion.reason,
                              style: context.textTheme.bodyMedium,
                            ),
                            if (suggestion.patternInfo != null) ...[
                              SizedBox(height: 12),
                              Text(
                                suggestion.patternInfo!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (suggestion.frequencyData != null) ...[
                              SizedBox(height: 12),
                              Text(
                                suggestion.frequencyData!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                      SizedBox(height: 16),
                      Text(
                        'Confidence: ${suggestion.displayConfidence}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const WorkoutSuggestionLoadingState(),
        error: (error, stack) {
          // If <6 workouts, show empty state instead of error
          if (error.toString().contains('Insufficient')) {
            return WorkoutSuggestionEmptyState(
              onCreateWorkout: () {
                // TODO: Navigate to create workout screen
                SnackBarService.showInfo(
                  context,
                  'Create workout feature coming soon!',
                );
              },
            );
          }

          // For other errors, don't show card at all
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getLevelName(SuggestionLevel level) {
    switch (level) {
      case SuggestionLevel.pattern:
        return 'Pattern Detection';
      case SuggestionLevel.routine:
        return 'Routine Schedule';
      case SuggestionLevel.frequency:
        return 'Frequency Analysis';
      case SuggestionLevel.dayBased:
        return 'Day-Based Default';
    }
  }

  /// ✅ NEW: Build completion message when today's workout is completed
  ///
  /// Shows congratulations message and link to view completed workout instead
  /// of showing the next workout suggestion
  Widget _buildCompletionMessage(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? completionStatus,
  ) {
    final isRecovery = (completionStatus?['isRecovery'] as bool?) ?? false;
    final templateId = completionStatus?['templateId'] as String?;

    // Get template name
    final templateAsync = templateId != null
        ? ref.watch(templateByIdProvider(templateId))
        : const AsyncValue.data(null);

    final templateName = templateAsync.maybeWhen(
      data: (template) => template?.name,
      orElse: () => null,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      color: context.colors.successContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with congratulations
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.complete,
                    color: context.colors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 Grande oggi ti sei allenato!',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSuccessContainer,
                        ),
                      ),
                      // ✅ NEW: Show template name if available
                      if (templateName != null)
                        Text(
                          templateName,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSuccessContainer
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (isRecovery)
                        Text(
                          'Workout recuperato! 💪',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSuccessContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // View completed workout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to workout history to view completed workout
                  context.goNamed('workout_history');
                },
                icon: Icon(AppIcons.visibility),
                label: Text('Consulta la Scheda Completata'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.success,
                  foregroundColor: context.colors.onSuccess,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === SKIP RECOVERY ===

  Widget _buildSkipRecoveryCard(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine activeRoutine,
  ) {
    return FutureBuilder<int>(
      future: _countSkippedDays(ref, activeRoutine.id),
      builder: (context, snapshot) {
        final skippedCount = snapshot.data ?? 0;

        // Don't show if no skipped days
        if (skippedCount == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            color: context.colors.secondaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: context.colors.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _showSkipRecoveryDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.restore,
                        color: context.colors.secondary,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.routineSkipRecovery,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSecondaryContainer,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            skippedCount == 1
                                ? '$skippedCount day to recover'
                                : '$skippedCount days to recover',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSecondaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      AppIcons.arrowForwardRounded,
                      size: 18,
                      color: context.colors.onSecondaryContainer
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int> _countSkippedDays(WidgetRef ref, String routineId) async {
    final reminderService = ref.read(routineReminderServiceProvider);
    try {
      // Get active routine to pass to service
      final activeRoutineAsync = ref.read(activeFlexibleRoutineProvider);
      final activeRoutine = activeRoutineAsync.when(
        data: (routine) => routine,
        loading: () => null,
        error: (_, __) => null,
      );

      if (activeRoutine == null || activeRoutine.id != routineId) {
        return 0;
      }

      final skippedDays = await reminderService.getRecoverableSkippedDays(
        routine: activeRoutine,
      );
      return skippedDays.length;
    } catch (e) {
      return 0;
    }
  }

  void _showSkipRecoveryDialog(BuildContext context) {
    // Light haptic feedback when opening bottom sheet
    HapticFeedback.selectionClick();

    // ✅ NEW: Use BottomSheet instead of Dialog
    SkipRecoveryBottomSheet.show(context);
  }
}
