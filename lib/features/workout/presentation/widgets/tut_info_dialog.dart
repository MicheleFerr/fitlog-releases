import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/tut_decoder_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Shows TUT (Time Under Tension) information in a bottom sheet modal
void showTutInfoBottomSheet(BuildContext context, String tutValue) {
  ModalService.showSheet(
    context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TutInfoBottomSheet(tutValue: tutValue),
  );
}

class TutInfoBottomSheet extends StatelessWidget {
  const TutInfoBottomSheet({super.key, required this.tutValue});

  final String tutValue;

  static const _phaseIcons = [
    AppIcons.arrowDownward,
    AppIcons.pause,
    AppIcons.arrowUpward,
    AppIcons.stop,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final decoded = TutDecoderService.decodeComplete(tutValue);
    final phases = decoded?.phases ?? [];

    final phaseColors = [
      theme.colorScheme.error,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
      theme.colorScheme.primary,
    ];

    final phaseLabels = [
      l10n.tutEccentricPhase,
      l10n.tutBottomPausePhase,
      l10n.tutConcentricPhase,
      l10n.tutTopPausePhase,
    ];

    final phaseDescriptions = [
      l10n.tutEccentricFullDescription,
      l10n.tutBottomPauseFullDescription,
      l10n.tutConcentricFullDescription,
      l10n.tutTopPauseFullDescription,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.timer,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.tutTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      AppIcons.close,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tempo Display Card
            if (phases.length >= 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTempoCard(theme, l10n, phases, decoded, phaseColors),
              ),

            const SizedBox(height: 16),

            // Visual Timeline Bar
            if (phases.length >= 4 && (decoded?.totalSeconds ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTimelineBar(theme, phases, phaseColors),
              ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Scrollable phase details
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  Text(
                    l10n.tutPhaseBreakdown,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  for (int i = 0; i < 4 && i < phases.length; i++) ...[
                    _buildPhaseCard(
                      theme: theme,
                      icon: _phaseIcons[i],
                      label: phaseLabels[i],
                      description: phaseDescriptions[i],
                      phase: phases[i],
                      color: phaseColors[i],
                    ),
                    if (i < 3) const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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

  /// Tempo display card with individual digit boxes and total time badge
  Widget _buildTempoCard(
    ThemeData theme,
    AppLocalizations l10n,
    List<TutPhase> phases,
    TutDecoded? decoded,
    List<Color> phaseColors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Digit boxes row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      ' - ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                _buildDigitBox(
                  theme: theme,
                  phase: phases[i],
                  color: phaseColors[i],
                  icon: _phaseIcons[i],
                ),
              ],
            ],
          ),

          // Total time badge
          if ((decoded?.totalSeconds ?? 0) > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.timer,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${decoded!.totalSeconds}s ${l10n.tutTotalPerRep}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Individual digit box with colored accent and phase icon
  Widget _buildDigitBox({
    required ThemeData theme,
    required TutPhase phase,
    required Color color,
    required IconData icon,
  }) {
    final isActive = phase.seconds > 0 || phase.isExplosive;
    final displayValue = phase.isExplosive ? 'X' : '${phase.seconds}';
    final effectiveColor = isActive
        ? color
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? color.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              displayValue,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Icon(icon, size: 12, color: effectiveColor),
      ],
    );
  }

  /// Horizontal proportional timeline bar
  Widget _buildTimelineBar(
    ThemeData theme,
    List<TutPhase> phases,
    List<Color> colors,
  ) {
    final activePhases = <int>[];
    for (int i = 0; i < phases.length && i < 4; i++) {
      if (phases[i].seconds > 0 || phases[i].isExplosive) {
        activePhases.add(i);
      }
    }

    if (activePhases.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            for (int i = 0; i < activePhases.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Flexible(
                flex: phases[activePhases[i]].isExplosive
                    ? 1
                    : phases[activePhases[i]].seconds,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[activePhases[i]].withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Phase detail card with left accent, dimmed for inactive phases
  Widget _buildPhaseCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String description,
    required TutPhase phase,
    required Color color,
  }) {
    final isActive = phase.seconds > 0 || phase.isExplosive;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.05)
            : theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 3,
              color: color.withValues(alpha: isActive ? 0.8 : 0.2),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color
                            .withValues(alpha: isActive ? 0.12 : 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: color
                            .withValues(alpha: isActive ? 1.0 : 0.4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface
                                  .withValues(
                                      alpha: isActive ? 1.0 : 0.5),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? color
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        phase.displayText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
