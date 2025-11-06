import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class TutSelector extends StatefulWidget {
  const TutSelector({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.isCompact = false,
    this.showLabels = true,
  });

  final String? initialValue;
  final Function(String) onChanged;
  final bool isCompact;
  final bool showLabels;

  @override
  State<TutSelector> createState() => _TutSelectorState();
}

class _TutSelectorState extends State<TutSelector> {
  late TutPhases _phases;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _phases = _parseTutValue(widget.initialValue ?? '3-1-2-0');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (widget.isCompact && !_isExpanded) {
      return _buildCompactView(theme, l10n);
    }

    return _buildExpandedView(theme, l10n);
  }

  Widget _buildCompactView(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTutValue(_phases),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 12,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tutTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.isCompact)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Current TUT Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              _formatTutValue(_phases),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Phase Selectors
          ..._buildPhaseSelectors(theme, l10n),

          const SizedBox(height: 16),

          // Preset Buttons
          _buildPresetButtons(theme, l10n),
        ],
      ),
    );
  }

  List<Widget> _buildPhaseSelectors(ThemeData theme, AppLocalizations l10n) {
    return [
      _buildPhaseSelector(
        theme: theme,
        label: l10n.tutEccentricPhase,
        description: l10n.tutEccentricDescription,
        value: _phases.eccentric,
        onChanged: (value) {
          setState(() {
            _phases = _phases.copyWith(eccentric: value);
            widget.onChanged(_formatTutValue(_phases));
          });
        },
        color: theme.colorScheme.error,
      ),
      const SizedBox(height: 12),

      _buildPhaseSelector(
        theme: theme,
        label: l10n.tutBottomPausePhase,
        description: l10n.tutBottomPauseDescription,
        value: _phases.bottomPause,
        onChanged: (value) {
          setState(() {
            _phases = _phases.copyWith(bottomPause: value);
            widget.onChanged(_formatTutValue(_phases));
          });
        },
        color: theme.colorScheme.tertiary,
      ),
      const SizedBox(height: 12),

      _buildPhaseSelector(
        theme: theme,
        label: l10n.tutConcentricPhase,
        description: l10n.tutConcentricDescription,
        value: _phases.concentric,
        onChanged: (value) {
          setState(() {
            _phases = _phases.copyWith(concentric: value);
            widget.onChanged(_formatTutValue(_phases));
          });
        },
        color: theme.colorScheme.secondary,
      ),
      const SizedBox(height: 12),

      _buildPhaseSelector(
        theme: theme,
        label: l10n.tutTopPausePhase,
        description: l10n.tutTopPauseDescription,
        value: _phases.topPause,
        onChanged: (value) {
          setState(() {
            _phases = _phases.copyWith(topPause: value);
            widget.onChanged(_formatTutValue(_phases));
          });
        },
        color: theme.colorScheme.primary,
      ),
    ];
  }

  Widget _buildPhaseSelector({
    required ThemeData theme,
    required String label,
    required String description,
    required String value,
    required Function(String) onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),

        // Value Selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              for (int i = 0; i < _tutOptions.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(_tutOptions[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: value == _tutOptions[i]
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left: i == 0 ? const Radius.circular(7) : Radius.zero,
                          right: i == _tutOptions.length - 1 ? const Radius.circular(7) : Radius.zero,
                        ),
                      ),
                      child: Text(
                        _tutOptions[i] == 'X' ? 'EXP' : _tutOptions[i],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: value == _tutOptions[i]
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: value == _tutOptions[i]
                              ? color
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < _tutOptions.length - 1)
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButtons(ThemeData theme, AppLocalizations l10n) {
    final presets = [
      {'label': l10n.tutPresetStandard, 'value': '3-1-2-0'},
      {'label': l10n.tutPresetSlow, 'value': '4-2-2-1'},
      {'label': l10n.tutPresetExplosive, 'value': '3-0-X-0'},
      {'label': l10n.tutPresetIsometric, 'value': '0-5-0-0'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tutPresets,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            final isSelected = _formatTutValue(_phases) == preset['value'];
            return GestureDetector(
              onTap: () {
                final newPhases = _parseTutValue(preset['value']!);
                setState(() {
                  _phases = newPhases;
                  widget.onChanged(preset['value']!);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${preset['label']} (${preset['value']})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static const List<String> _tutOptions = ['0', '1', '2', '3', '4', '5', 'X'];

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

  String _formatTutValue(TutPhases phases) {
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

  TutPhases copyWith({
    String? eccentric,
    String? bottomPause,
    String? concentric,
    String? topPause,
  }) {
    return TutPhases(
      eccentric: eccentric ?? this.eccentric,
      bottomPause: bottomPause ?? this.bottomPause,
      concentric: concentric ?? this.concentric,
      topPause: topPause ?? this.topPause,
    );
  }
}