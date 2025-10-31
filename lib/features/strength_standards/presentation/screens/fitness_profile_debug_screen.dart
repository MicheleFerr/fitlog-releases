import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Debug screen to show fitness profile status and weight suggestions
class FitnessProfileDebugScreen extends ConsumerWidget {
  const FitnessProfileDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(userFitnessQuestionnaireProvider);
    final medicalClearance = ref.watch(medicalClearanceQuestionnaireProvider);
    final suggestionsEnabled = ref.watch(weightSuggestionsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Profile Debug'),
        backgroundColor: context.colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Questionnaire Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        questionnaire != null ? Icons.check_circle : Icons.warning,
                        color: questionnaire != null ? context.colors.success : context.colors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Questionnaire Status',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (questionnaire != null) ...[
                    const Text('✅ Questionnaire loaded: YES'),
                    Text('✅ Is valid: ${UserFitnessQuestionnaireExtension(questionnaire).isValid}'),
                    Text('✅ Experience: ${questionnaire.experienceLevel.name}'),
                    Text('✅ Bodyweight: ${questionnaire.bodyweightKg.toStringAsFixed(1)} kg'),
                    Text('✅ Age: ${questionnaire.age}'),
                    Text('✅ Sex: ${questionnaire.sex.name}'),
                    if (questionnaire.completedAt != null)
                      Text('✅ Completed: ${questionnaire.completedAt}'),
                    const SizedBox(height: 8),
                    Text('Max Lifts:', style: context.textTheme.titleSmall),
                    if (questionnaire.benchPressMax != null)
                      Text('  Bench: ${questionnaire.benchPressMax!.toStringAsFixed(1)} kg'),
                    if (questionnaire.squatMax != null)
                      Text('  Squat: ${questionnaire.squatMax!.toStringAsFixed(1)} kg'),
                    if (questionnaire.deadliftMax != null)
                      Text('  Deadlift: ${questionnaire.deadliftMax!.toStringAsFixed(1)} kg'),
                    if (questionnaire.overheadPressMax != null)
                      Text('  OHP: ${questionnaire.overheadPressMax!.toStringAsFixed(1)} kg'),
                  ] else ...[
                    const Text('❌ Questionnaire: NOT LOADED'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await ref.read(userFitnessQuestionnaireProvider.notifier).loadQuestionnaire();
                      },
                      child: const Text('Try to Load Questionnaire'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Medical Clearance Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        medicalClearance != null ? Icons.check_circle : Icons.warning,
                        color: medicalClearance != null ? context.colors.success : context.colors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Medical Clearance',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (medicalClearance != null) ...[
                    const Text('✅ Medical clearance loaded: YES'),
                    Text('✅ Risk level: ${medicalClearance.clearanceLevel.name}'),
                    Text('✅ Needs medical clearance: ${MedicalClearanceExtension(medicalClearance).needsMedicalClearance}'),
                  ] else ...[
                    const Text('❌ Medical clearance: NOT LOADED'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Weight Suggestions Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        suggestionsEnabled ? Icons.check_circle : Icons.error,
                        color: suggestionsEnabled ? context.colors.success : context.colors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weight Suggestions',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    suggestionsEnabled
                        ? '✅ Weight suggestions: ENABLED'
                        : '❌ Weight suggestions: DISABLED',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To enable: Complete questionnaire with valid data',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Available Mappings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Mappings',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final mappingsAsync = ref.watch(exerciseMappingsProvider);

                      return mappingsAsync.when(
                        data: (mappings) {
                          final highConfidence = mappings.where((m) => m.confidence >= 0.8).toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ Total mappings: ${mappings.length}'),
                              Text('✅ High confidence (≥80%): ${highConfidence.length}'),
                              const SizedBox(height: 8),
                              Text(
                                'High confidence exercises:',
                                style: context.textTheme.titleSmall,
                              ),
                              ...highConfidence.take(10).map((m) => Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text(
                                  '${m.gymbroName} (${(m.confidence * 100).toStringAsFixed(0)}%)',
                                  style: context.textTheme.bodySmall,
                                ),
                              )),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error loading mappings: $e'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(userFitnessQuestionnaireProvider.notifier).loadQuestionnaire();
                        await ref.read(medicalClearanceQuestionnaireProvider.notifier).loadClearance();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload Profile from Storage'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.invalidate(userFitnessQuestionnaireProvider);
                        ref.invalidate(medicalClearanceQuestionnaireProvider);
                        ref.invalidate(exerciseMappingsProvider);
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Invalidate All Providers'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
