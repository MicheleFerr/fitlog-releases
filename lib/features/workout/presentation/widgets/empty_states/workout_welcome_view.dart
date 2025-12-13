import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Vista di benvenuto quando non c'è un workout attivo
/// Differenziata per beginner (guidata) vs expert (minimal)
class WorkoutWelcomeView extends ConsumerWidget {
  const WorkoutWelcomeView({
    super.key,
    this.onCreateWorkout,
  });

  final VoidCallback? onCreateWorkout;

  /// GlobalKey for contextual overlay (Phase 1)
  static final GlobalKey createWorkoutButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final isBeginner = onboardingState.isBeginner;

    // Show beginner-friendly UI if user selected "beginner" in Quick Start
    return isBeginner
        ? _BeginnerEmptyState(
            onCreateWorkout: onCreateWorkout,
          )
        : _ExpertEmptyState(
            onCreateWorkout: onCreateWorkout,
          );
  }
}

/// Beginner empty state - Encouraging, guided, colorful
class _BeginnerEmptyState extends StatelessWidget {
  const _BeginnerEmptyState({
    this.onCreateWorkout,
  });

  final VoidCallback? onCreateWorkout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.secondary,
                    context.colors.success,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                AppIcons.workout,
                size: AppIconSize.xxlarge,
                color: colors.onPrimary,
              ),
            ),

            const SizedBox(height: 32),

            // Encouraging title
            Text(
              l10n.homeEmptyBeginnerTitle,
              style: context.textTheme.headlineMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Supportive description
            Text(
              l10n.homeEmptyBeginnerDescription,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Large, prominent CTA button (with GlobalKey for overlay)
            SizedBox(
              key: WorkoutWelcomeView.createWorkoutButtonKey,
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: onCreateWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.success,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      AppIcons.add,
                      size: AppIconSize.large,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.homeEmptyBeginnerCTA,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Supportive hint card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.lightbulb,
                    color: colors.primary,
                    size: AppIconSize.large,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tip: Start with 3-4 exercises, 3 sets each. I\'ll guide you!',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expert empty state - Minimal, efficient, action-oriented
class _ExpertEmptyState extends StatelessWidget {
  const _ExpertEmptyState({
    this.onCreateWorkout,
  });

  final VoidCallback? onCreateWorkout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple icon
            SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: colors.onSurface.withValues(alpha: 0.4,
),
            ),

            const SizedBox(height: 24),

            // Minimal title
            Text(
              l10n.homeEmptyExpertTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Brief description
            Text(
              l10n.homeEmptyExpertDescription,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Quick action buttons (horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quick start button
                Expanded(
                  child: SizedBox(
                    key: WorkoutWelcomeView.createWorkoutButtonKey,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onCreateWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(AppIcons.playCircle, size: AppIconSize.medium),
                          const SizedBox(width: 8),
                          Text(l10n.homeEmptyExpertCTA),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Template button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to templates
                        Navigator.of(context).pushNamed('/templates');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(AppIcons.template, size: AppIconSize.medium),
                          const SizedBox(width: 8),
                          Text(l10n.useTemplate),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
