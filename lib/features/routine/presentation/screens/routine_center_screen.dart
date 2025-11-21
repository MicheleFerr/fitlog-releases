/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE CENTER SCREEN - Main Hub for Routine Management (v2.0)
///
/// Features:
/// - Active routine display with quick actions
/// - Create new routine button → RoutineCreationStep1Screen
/// - Routine list (all user's routines) with activate/delete actions
/// - Empty state when no routines exist
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Routine Center Screen - Main hub for routine management
class RoutineCenterScreen extends ConsumerWidget {
  const RoutineCenterScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/routine-center';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch active routine and all user routines
    final activeRoutineAsync = ref.watch(activeRoutineProvider);
    final userRoutinesAsync = ref.watch(userRoutinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.routineCenter),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both providers
          ref.invalidate(activeRoutineProvider);
          ref.invalidate(userRoutinesProvider);
        },
        child: userRoutinesAsync.when(
          data: (routines) {
            // Empty state: no routines exist
            if (routines.isEmpty) {
              return _buildEmptyState(context);
            }

            // Routines exist: show list
            return _buildRoutineList(
              context,
              ref,
              routines: routines,
              activeRoutineAsync: activeRoutineAsync,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
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
                  context.l10n.errorLoadingRoutines,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userRoutinesProvider);
                  },
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to routine creation wizard
          // TODO: Add navigation when RoutineCreationStep1Screen is ready
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.createRoutineComingSoon),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createRoutine),
      ),
    );
  }

  /// Empty state widget (no routines)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noRoutinesYet,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.createYourFirstRoutine,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navigate to routine creation wizard
                // TODO: Add navigation when RoutineCreationStep1Screen is ready
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.createRoutineComingSoon),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(context.l10n.createRoutine),
            ),
          ],
        ),
      ),
    );
  }

  /// Routine list widget
  Widget _buildRoutineList(
    BuildContext context,
    WidgetRef ref, {
    required List routines,
    required activeRoutineAsync,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length + 1, // +1 for active routine card at top
      itemBuilder: (context, index) {
        // First item: Active routine card
        if (index == 0) {
          return activeRoutineAsync.when(
            data: (activeRoutine) {
              if (activeRoutine == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: context.colors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.noActiveRoutine,
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.selectRoutineBelow,
                          style: context.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Active routine exists
              return Card(
                color: context.colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.activeRoutine,
                            style: context.textTheme.labelLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeRoutine.name,
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${activeRoutine.presetType.displayName} • ${activeRoutine.trainingDays.length} ${context.l10n.daysPerWeek}',
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          );
        }

        // Subsequent items: All routines
        final routine = routines[index - 1];
        return Card(
          child: ListTile(
            leading: Icon(
              routine.isActive ? Icons.check_circle : Icons.circle_outlined,
              color: routine.isActive
                  ? context.colors.primary
                  : context.colors.outline,
            ),
            title: Text(routine.name),
            subtitle: Text(
              '${routine.presetType.displayName} • ${routine.trainingDays.length} ${context.l10n.daysPerWeek}',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (!routine.isActive)
                  PopupMenuItem(
                    child: Text(context.l10n.activate),
                    onTap: () {
                      // TODO: Activate routine
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.activatingRoutine),
                        ),
                      );
                    },
                  ),
                PopupMenuItem(
                  child: Text(context.l10n.viewDetails),
                  onTap: () {
                    // TODO: Navigate to RoutineDetailScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.viewDetailsComingSoon),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: Text(
                    context.l10n.delete,
                    style: TextStyle(color: context.colors.error),
                  ),
                  onTap: () {
                    // TODO: Delete routine with confirmation dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.deleteComingSoon),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
