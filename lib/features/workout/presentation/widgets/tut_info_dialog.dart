import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Shows TUT (Time Under Tension) information in a bottom sheet modal
void showTutInfoBottomSheet(BuildContext context, String tutValue) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TutInfoBottomSheet(tutValue: tutValue),
  );
}

class TutInfoBottomSheet extends StatelessWidget {
  const TutInfoBottomSheet({
    super.key,
    required this.tutValue,
  });

  final String tutValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final phases = _parseTutValue(tutValue);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header - Fixed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        AppIcons.timer,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.tutTitle ?? 'TUT Info',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          AppIcons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Current TUT Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.tutCurrentTempo,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTutDisplay(phases),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Phase Breakdown
                  Text(
                    l10n.tutPhaseBreakdown,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Individual Phases
                  _buildPhaseInfo(
                    theme: theme,
                    l10n: l10n,
                    icon: AppIcons.arrowDownward,
                    label: l10n.tutEccentricPhase,
                    description: l10n.tutEccentricFullDescription,
                    value: phases.eccentric,
                    color: theme.colorScheme.error,
                  ),

                  const SizedBox(height: 12),

                  _buildPhaseInfo(
                    theme: theme,
                    l10n: l10n,
                    icon: AppIcons.pause,
                    label: l10n.tutBottomPausePhase,
                    description: l10n.tutBottomPauseFullDescription,
                    value: phases.bottomPause,
                    color: theme.colorScheme.tertiary,
                  ),

                  const SizedBox(height: 12),

                  _buildPhaseInfo(
                    theme: theme,
                    l10n: l10n,
                    icon: AppIcons.arrowUpward,
                    label: l10n.tutConcentricPhase,
                    description: l10n.tutConcentricFullDescription,
                    value: phases.concentric,
                    color: theme.colorScheme.secondary,
                  ),

                  const SizedBox(height: 12),

                  _buildPhaseInfo(
                    theme: theme,
                    l10n: l10n,
                    icon: AppIcons.stop,
                    label: l10n.tutTopPausePhase,
                    description: l10n.tutTopPauseFullDescription,
                    value: phases.topPause,
                    color: theme.colorScheme.primary,
                  ),

                  SizedBox(height: 80), // Extra space for button
                ],
              ),
            ),

            // Fixed Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseInfo({
    required ThemeData theme,
    required AppLocalizations l10n,
    required IconData icon,
    required String label,
    required String description,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value == 'X' ? 'EXP' : '${value}s',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TutPhases _parseTutValue(String value) {
    final parts = value.split('-');
    if (parts.length != 4) {
      return const TutPhases(
        eccentric: '3',
        bottomPause: '1',
        concentric: '2',
        topPause: '0',
      );
    }

    return TutPhases(
      eccentric: parts[0],
      bottomPause: parts[1],
      concentric: parts[2],
      topPause: parts[3],
    );
  }

  String _formatTutDisplay(TutPhases phases) {
    return '${phases.eccentric}-${phases.bottomPause}-${phases.concentric}-${phases.topPause}';
  }

}

class TutPhases {
  const TutPhases({
    required this.eccentric,
    required this.bottomPause,
    required this.concentric,
    required this.topPause,
  });

  final String eccentric;
  final String bottomPause;
  final String concentric;
  final String topPause;
}
