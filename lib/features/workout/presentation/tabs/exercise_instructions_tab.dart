import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Tab Istruzioni: mostra warmup protocol e tips generici
class ExerciseInstructionsTab extends ConsumerWidget {

  const ExerciseInstructionsTab({
    super.key,
    required this.exerciseName,
  });
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome esercizio
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                exerciseName,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Warmup Protocol
          _buildWarmupSection(context),

          const SizedBox(height: 24),

          // Tips generici
          _buildTipsSection(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWarmupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              context.l10n.warmupProtocol,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWarmupPhase(
                  context,
                  '1',
                  context.l10n.warmupPhase1Title,
                  context.l10n.warmupPhase1Description,
                  Icons.accessibility_new,
                  Colors.blue,
                ),
                const Divider(height: 24),
                _buildWarmupPhase(
                  context,
                  '2',
                  context.l10n.warmupPhase2Title,
                  context.l10n.warmupPhase2Description,
                  AppIcons.flashOn,
                  Colors.orange,
                ),
                const Divider(height: 24),
                _buildWarmupPhase(
                  context,
                  '3',
                  context.l10n.warmupPhase3Title,
                  context.l10n.warmupPhase3Description,
                  Icons.fitness_center,
                  Colors.purple,
                ),
                const Divider(height: 24),
                _buildWarmupPhase(
                  context,
                  '4',
                  context.l10n.warmupPhase4Title,
                  context.l10n.warmupPhase4Description,
                  AppIcons.timer,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarmupPhase(
    BuildContext context,
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final tips = _getGeneralTips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              context.l10n.tips,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => _buildTipCard(context, tip)),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context, String tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              AppIcons.checkCircle,
              color: Colors.green,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getGeneralTips() {
    return [
      'Concentrati sulla corretta esecuzione del movimento',
      'Mantieni la tensione muscolare durante tutto l\'esercizio',
      'Respira correttamente: espira durante lo sforzo',
      'Non sacrificare la forma per aumentare il peso',
      'Monitora i progressi e adatta il carico progressivamente',
    ];
  }
}
