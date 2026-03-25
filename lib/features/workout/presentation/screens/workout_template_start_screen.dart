import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Transitional route that starts a workout from a template deep link.
class WorkoutTemplateStartScreen extends ConsumerStatefulWidget {
  const WorkoutTemplateStartScreen({super.key, required this.templateId});

  final String templateId;

  @override
  ConsumerState<WorkoutTemplateStartScreen> createState() =>
      _WorkoutTemplateStartScreenState();
}

class _WorkoutTemplateStartScreenState
    extends ConsumerState<WorkoutTemplateStartScreen> {
  bool _didAttemptStart = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startWorkoutFromTemplate());
    });
  }

  Future<void> _startWorkoutFromTemplate() async {
    if (_didAttemptStart) {
      return;
    }
    _didAttemptStart = true;

    final activeWorkout = ref.read(currentWorkoutProvider);
    if (activeWorkout != null && !activeWorkout.isCompleted) {
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.workoutPath);
      return;
    }

    try {
      final templates = await ref.read(allWorkoutTemplatesProvider.future);
      WorkoutTemplate? template;

      for (final candidate in templates) {
        if (candidate.id == widget.templateId) {
          template = candidate;
          break;
        }
      }

      if (template == null) {
        throw StateError('Template ${widget.templateId} not found');
      }

      if (!mounted) {
        return;
      }

      await ref
          .read(workoutScreenControllerProvider.notifier)
          .startWorkout(
            context: context,
            template: template,
            sessionId: 'deeplink_${DateTime.now().millisecondsSinceEpoch}',
          );

      if (!mounted) {
        return;
      }
      context.go(AppRoutes.workoutPath);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.startWorkout)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.templateNotFound,
                  style: context.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error.toString(),
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.templatesPath),
                  child: Text(context.l10n.goBack),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.startWorkout)),
      body: const Center(child: LoadingIndicator()),
    );
  }
}
