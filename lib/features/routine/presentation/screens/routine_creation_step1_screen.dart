/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE CREATION STEP 1 SCREEN - Preset Selection Wizard
///
/// Features:
/// - Display 5 preset cards (PPL, Upper/Lower, Full Body, Bro Split, Custom)
/// - User selects preset → updates selectedPresetProvider
/// - Continue button → navigate to Step 2
/// - Back button → return to Routine Center
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/enhanced_preset_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Routine Creation Step 1 Screen - Preset Selection
class RoutineCreationStep1Screen extends ConsumerWidget {
  const RoutineCreationStep1Screen({super.key});

  /// Route name for navigation
  static const String routeName = '/routine-creation-step1';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPreset = ref.watch(selectedPresetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createRoutine),
        leading: IconButton(
          icon: Icon(AppIcons.close),
          onPressed: () {
            // Reset wizard state on back
            ref.read(selectedPresetProvider.notifier).state = null;
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator (1 of 2)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.5, // Step 1 of 2 = 50%
                    backgroundColor: context.colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '1/2',
                  style: context.textTheme.labelLarge,
                ),
              ],
            ),
          ),

          // Title and subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.selectPreset,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.selectPresetDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preset cards grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65, // Reduced to accommodate taller EnhancedPresetCard
              children: [
                EnhancedPresetCard(
                  preset: RoutinePreset.ppl6Day,
                  isSelected: selectedPreset == RoutinePreset.ppl6Day,
                  onTap: () {
                    ref.read(selectedPresetProvider.notifier).state =
                        RoutinePreset.ppl6Day;
                  },
                ),
                EnhancedPresetCard(
                  preset: RoutinePreset.upperLower4Day,
                  isSelected: selectedPreset == RoutinePreset.upperLower4Day,
                  onTap: () {
                    ref.read(selectedPresetProvider.notifier).state =
                        RoutinePreset.upperLower4Day;
                  },
                ),
                EnhancedPresetCard(
                  preset: RoutinePreset.fullBody3Day,
                  isSelected: selectedPreset == RoutinePreset.fullBody3Day,
                  onTap: () {
                    ref.read(selectedPresetProvider.notifier).state =
                        RoutinePreset.fullBody3Day;
                  },
                ),
                EnhancedPresetCard(
                  preset: RoutinePreset.broSplit5Day,
                  isSelected: selectedPreset == RoutinePreset.broSplit5Day,
                  onTap: () {
                    ref.read(selectedPresetProvider.notifier).state =
                        RoutinePreset.broSplit5Day;
                  },
                ),
                EnhancedPresetCard(
                  preset: RoutinePreset.custom,
                  isSelected: selectedPreset == RoutinePreset.custom,
                  onTap: () {
                    ref.read(selectedPresetProvider.notifier).state =
                        RoutinePreset.custom;
                  },
                ),
              ],
            ),
          ),

          // Continue button (bottom)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedPreset == null
                      ? null
                      : () {
                          // Navigate to Step 2
                          // TODO: Add navigation when RoutineCreationStep2Screen is ready
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.step2ComingSoon),
                            ),
                          );
                        },
                  child: Text(context.l10n.continueButton),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
