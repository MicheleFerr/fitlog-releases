/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE CREATION STEP 2 SCREEN - Training Days + Template Assignment Wizard
///
/// Features:
/// - Weekday toggles (Mon-Sun) - pre-selected based on preset from Step 1
/// - User toggles days on/off
/// - For each selected day: show template assignment card
/// - Tap card → open template picker modal (TODO: implement in Task 21)
/// - Routine name input field
/// - Back button → return to Step 1
/// - Create button → save routine to Firestore (uses RoutineNotifier)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Routine Creation Step 2 Screen - Training Days + Template Assignment
class RoutineCreationStep2Screen extends ConsumerStatefulWidget {
  const RoutineCreationStep2Screen({super.key});

  /// Route name for navigation
  static const String routeName = '/routine-creation-step2';

  @override
  ConsumerState<RoutineCreationStep2Screen> createState() =>
      _RoutineCreationStep2ScreenState();
}

class _RoutineCreationStep2ScreenState
    extends ConsumerState<RoutineCreationStep2Screen> {
  // Routine name input controller
  final _routineNameController = TextEditingController();

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPreset = ref.watch(selectedPresetProvider);
    final trainingDays = ref.watch(trainingDaysProvider);
    final dayTemplates = ref.watch(dayTemplatesProvider);
    final isComplete = ref.watch(isRoutineCreationCompleteProvider);

    // Edge case: no preset selected (shouldn't happen if navigated from Step 1)
    if (selectedPreset == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.createRoutine)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noPresetSelected,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.goBack),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createRoutine),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator (2 of 2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1.0, // Step 2 of 2 = 100%
                    backgroundColor: context.colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '2/2',
                  style: context.textTheme.labelLarge,
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    context.l10n.configureRoutine,
                    style: context.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.configureRoutineDescription,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Routine name input
                  TextField(
                    controller: _routineNameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.routineName,
                      hintText: context.l10n.routineNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Training days section
                  Text(
                    context.l10n.trainingDays,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildDayToggles(trainingDays),

                  const SizedBox(height: 24),

                  // Template assignment section
                  if (trainingDays.isNotEmpty) ...[
                    Text(
                      context.l10n.assignTemplates,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildTemplateAssignments(trainingDays, dayTemplates),
                  ],
                ],
              ),
            ),
          ),

          // Create button (bottom)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (!isComplete || _routineNameController.text.trim().isEmpty)
                      ? null
                      : () => _createRoutine(
                            context,
                            selectedPreset: selectedPreset,
                            trainingDays: trainingDays,
                            dayTemplates: dayTemplates,
                          ),
                  child: Text(context.l10n.createRoutine),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build weekday toggles (Mon-Sun)
  Widget _buildDayToggles(Set<int> trainingDays) {
    final weekdays = [
      (1, context.l10n.monday),
      (2, context.l10n.tuesday),
      (3, context.l10n.wednesday),
      (4, context.l10n.thursday),
      (5, context.l10n.friday),
      (6, context.l10n.saturday),
      (7, context.l10n.sunday),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weekdays.map((entry) {
        final day = entry.$1;
        final name = entry.$2;
        final isSelected = trainingDays.contains(day);

        return FilterChip(
          label: Text(name),
          selected: isSelected,
          onSelected: (selected) {
            final newDays = Set<int>.from(trainingDays);
            if (selected) {
              newDays.add(day);
            } else {
              newDays.remove(day);
              // Also remove template assignment for this day
              final newTemplates = {...ref.read(dayTemplatesProvider)};
              newTemplates.remove(day);
              ref.read(dayTemplatesProvider.notifier).state = newTemplates;
            }
            ref.read(trainingDaysProvider.notifier).state = newDays;
          },
        );
      }).toList(),
    );
  }

  /// Build template assignment cards for each selected day
  Widget _buildTemplateAssignments(
    Set<int> trainingDays,
    Map dayTemplates,
  ) {
    final sortedDays = trainingDays.toList()..sort();

    return Column(
      children: sortedDays.map((day) {
        final dayName = _getDayName(day);
        final template = dayTemplates[day];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              template != null ? Icons.check_circle : Icons.circle_outlined,
              color: template != null
                  ? context.colors.primary
                  : context.colors.outline,
            ),
            title: Text(dayName),
            subtitle: Text(
              template != null
                  ? template.name
                  : context.l10n.tapToAssignTemplate,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open template picker modal (Task 21)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.templatePickerComingSoon),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  /// Get weekday name by number (1=Monday, 7=Sunday)
  String _getDayName(int day) {
    switch (day) {
      case 1:
        return context.l10n.monday;
      case 2:
        return context.l10n.tuesday;
      case 3:
        return context.l10n.wednesday;
      case 4:
        return context.l10n.thursday;
      case 5:
        return context.l10n.friday;
      case 6:
        return context.l10n.saturday;
      case 7:
        return context.l10n.sunday;
      default:
        return '';
    }
  }

  /// Create routine and save to Firestore
  Future<void> _createRoutine(
    BuildContext context, {
    required selectedPreset,
    required Set<int> trainingDays,
    required Map dayTemplates,
  }) async {
    // Store context-dependent values before async
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final errorColor = context.colors.error;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.userNotLoggedIn)),
        );
      }
      return;
    }

    final routineName = _routineNameController.text.trim();
    if (routineName.isEmpty) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.routineNameRequired)),
        );
      }
      return;
    }

    // Create FlexibleRoutine entity
    final routine = FlexibleRoutine(
      id: '', // Firestore will generate
      userId: userId,
      name: routineName,
      presetType: selectedPreset,
      trainingDays: trainingDays,
      workoutSchedule: Map<int, String>.fromEntries(
        dayTemplates.entries.map((e) => MapEntry(e.key as int, (e.value as dynamic).id as String)),
      ),
      isActive: false, // User must activate manually from Routine Center
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save via RoutineNotifier
    await ref.read(flexibleRoutineNotifierProvider.notifier).createRoutine(routine);

    // Check for errors
    final state = ref.read(flexibleRoutineNotifierProvider);
    if (state.errorMessage != null) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: errorColor,
          ),
        );
      }
      return;
    }

    // Success: reset wizard state and navigate back to Routine Center
    ref.read(selectedPresetProvider.notifier).state = null;
    ref.read(trainingDaysProvider.notifier).state = {};
    ref.read(dayTemplatesProvider.notifier).state = {};

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.routineCreated)),
      );
      navigator.popUntil((route) => route.isFirst);
    }
  }
}
