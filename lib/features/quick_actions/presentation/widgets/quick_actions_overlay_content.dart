/// Quick Actions Overlay Content
///
/// Main container for the 3 sections of the Quick Actions overlay:
/// 1. SmartWorkoutCard (smart suggestion)
/// 2. LogMeasurementsPopup (CNPopupMenuButton)
/// 3. CreateTemplatePopup (CNPopupMenuButton)
///
/// Handles all navigation after action selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/create_template_popup.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/log_measurements_popup.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/quick_measurement_input_sheet.dart';
import 'package:gymbro_flutter_new/features/quick_actions/presentation/widgets/smart_workout_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout_import/presentation/screens/workout_import_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Content widget for the Quick Actions overlay
///
/// Assembles the 3 sections with staggered animations.
/// All navigation is handled via `onClose()` callback followed by
/// `addPostFrameCallback` to navigate after the overlay is closed.
class QuickActionsOverlayContent extends ConsumerWidget {
  const QuickActionsOverlayContent({
    required this.animation,
    required this.onClose,
    required this.navigationShell,
    super.key,
  });

  final Animation<double> animation;
  final VoidCallback onClose;
  final dynamic navigationShell; // StatefulNavigationShell

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section 1: Smart Workout Card
          _buildAnimatedSection(
            delay: 0.0,
            child: SmartWorkoutCard(
              onStartSuggested: (templateId) =>
                  _handleStartSuggested(context, ref, templateId),
              onTemplateSelected: (template) =>
                  _handleTemplateSelected(context, ref, template),
              onViewAllTemplates: () => _handleFromTemplate(context),
              onEmpty: () => _handleEmptyWorkout(context, ref),
              onResumeDraft: () => _handleResumeDraft(context, ref),
              onDiscardDraft: () => _handleDiscardDraft(ref),
            ),
          ),

          const SizedBox(height: 16),

          // Section 2: Log Measurements
          _buildAnimatedSection(
            delay: 0.05,
            child: LogMeasurementsPopup(
              onMetricSelected: (metric) =>
                  _handleMetricSelected(context, metric),
              onAllMeasurements: () => _handleAllMeasurements(context),
            ),
          ),

          const SizedBox(height: 12),

          // Section 3: Create Template
          _buildAnimatedSection(
            delay: 0.1,
            child: CreateTemplatePopup(
              onCreateManually: () => _handleCreateManually(context),
              onImport: () => _handleImport(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required double delay,
    required Widget child,
  }) {
    final delayed = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(delayed),
      child: FadeTransition(
        opacity: delayed,
        child: child,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Navigation Handlers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _handleStartSuggested(
    BuildContext context,
    WidgetRef ref,
    String? templateId,
  ) {
    HapticFeedback.mediumImpact();
    onClose();
    _postFrameNavigate(context, () {
      if (templateId != null) {
        // Load template and start from it
        final templates =
            ref.read(customWorkoutTemplatesProvider).value ?? [];
        final template = templates.where((t) => t.id == templateId).firstOrNull;
        if (template != null) {
          ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);
        } else {
          // Template not found, start empty
          ref.read(currentWorkoutProvider.notifier).createWorkout('Workout');
          ref.read(currentWorkoutProvider.notifier).startWorkout();
        }
      } else {
        // Start empty workout
        ref.read(currentWorkoutProvider.notifier).createWorkout('Workout');
        ref.read(currentWorkoutProvider.notifier).startWorkout();
      }
      navigationShell.goBranch(1);
    });
  }

  void _handleTemplateSelected(
    BuildContext context,
    WidgetRef ref,
    dynamic template,
  ) {
    HapticFeedback.mediumImpact();
    onClose();
    _postFrameNavigate(context, () {
      // Start workout from the selected template
      ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);
      navigationShell.goBranch(1);
    });
  }

  void _handleFromTemplate(BuildContext context) {
    HapticFeedback.lightImpact();
    onClose();
    _postFrameNavigate(context, () {
      navigationShell.goBranch(1); // Switch to Workout branch first
      context.pushNamed(AppRoutes.templatesName);
    });
  }

  void _handleEmptyWorkout(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    onClose();
    _postFrameNavigate(context, () {
      ref.read(currentWorkoutProvider.notifier).createWorkout('Workout');
      ref.read(currentWorkoutProvider.notifier).startWorkout();
      navigationShell.goBranch(1);
    });
  }

  void _handleMetricSelected(BuildContext context, MetricType metric) {
    HapticFeedback.lightImpact();
    onClose();
    _postFrameNavigate(context, () {
      ModalService.showSheet(
        context,
        builder: (_) => QuickMeasurementInputSheet(metric: metric),
      );
    });
  }

  void _handleAllMeasurements(BuildContext context) {
    HapticFeedback.lightImpact();
    onClose();
    _postFrameNavigate(context, () {
      navigationShell.goBranch(2); // Switch to Profile branch first
      context.pushNamed(AppRoutes.bodyMeasurementsName);
    });
  }

  void _handleCreateManually(BuildContext context) {
    HapticFeedback.lightImpact();
    onClose();
    _postFrameNavigate(context, () {
      navigationShell.goBranch(1); // Switch to Workout branch first
      context.pushNamed(AppRoutes.templatesName);
    });
  }

  void _handleImport(BuildContext context) {
    HapticFeedback.lightImpact();
    onClose();
    _postFrameNavigate(context, () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const WorkoutImportScreen(),
        ),
      );
    });
  }

  /// Resume a pending workout draft
  void _handleResumeDraft(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    onClose();
    _postFrameNavigate(context, () async {
      final autoSave = ref.read(workoutAutoSaveProvider.notifier);
      final recovered = await autoSave.recoverDraft();
      if (recovered != null) {
        ref.read(currentWorkoutProvider.notifier).restoreFromDraft(recovered);
        navigationShell.goBranch(1);
      }
    });
  }

  /// Discard the pending draft and refresh the UI
  void _handleDiscardDraft(WidgetRef ref) {
    HapticFeedback.lightImpact();
    final autoSave = ref.read(workoutAutoSaveProvider.notifier);
    autoSave.discardDraft();
    // Invalidate to refresh the draft card
    ref.invalidate(pendingDraftInfoProvider);
  }

  /// Navigate after the overlay is fully closed
  void _postFrameNavigate(BuildContext context, VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        action();
      }
    });
  }
}
