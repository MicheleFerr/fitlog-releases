/// Import Result Widget
///
/// Shows the final result after import completes.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget showing import completion result
class ImportResultWidget extends StatelessWidget {
  const ImportResultWidget({super.key, required this.result});

  final ImportFinalResult result;

  @override
  Widget build(BuildContext context) {
    final hasErrors = result.errors.isNotEmpty;
    final isSuccess = result.workoutsImported > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success/Warning icon
          Icon(
            isSuccess
                ? (hasErrors ? AppIcons.warning : AppIcons.check)
                : AppIcons.error,
            size: 80,
            color: isSuccess
                ? (hasErrors ? context.colors.warning : context.colors.success)
                : context.colors.error,
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            isSuccess ? context.l10n.importComplete : context.l10n.importFailed,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            isSuccess
                ? context.l10n.importSuccessMessage(result.workoutsImported)
                : context.l10n.importFailedMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    icon: AppIcons.workout,
                    label: context.l10n.workoutsImported,
                    value: '${result.workoutsImported}',
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    icon: AppIcons.exercise,
                    label: context.l10n.exercisesImported,
                    value: '${result.exercisesImported}',
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    icon: AppIcons.formatListNumbered,
                    label: context.l10n.setsImported,
                    value: '${result.setsImported}',
                  ),
                  if (result.workoutsSkipped > 0) ...[
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      icon: AppIcons.skipNext,
                      label: context.l10n.workoutsSkipped,
                      value: '${result.workoutsSkipped}',
                      isWarning: true,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Errors
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              color: context.colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppIcons.error, color: context.colors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.importErrors,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...result.errors.take(5).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $e',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onErrorContainer,
                            ),
                          ),
                        )),
                    if (result.errors.length > 5)
                      Text(
                        context.l10n.andMoreErrors(result.errors.length - 5),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: context.colors.onErrorContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(AppIcons.check),
            label: Text(context.l10n.done),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: isWarning ? context.colors.warning : context.colors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isWarning ? context.colors.warning : null,
          ),
        ),
      ],
    );
  }
}
