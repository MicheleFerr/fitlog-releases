import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/workout_fatigue.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class FatigueRatingDialog extends StatefulWidget {

  const FatigueRatingDialog({
    super.key,
    required this.onRatingSubmitted,
    required this.totalVolume,
    required this.exercisesPerformed,
  });
  final Function(int fatigueLevel, String? notes) onRatingSubmitted;
  final double totalVolume;
  final List<String> exercisesPerformed;

  @override
  State<FatigueRatingDialog> createState() => _FatigueRatingDialogState();
}

class _FatigueRatingDialogState extends State<FatigueRatingDialog> {
  int _selectedFatigue = 3;
  final _notesController = TextEditingController();
  final bool _isHovering = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.ai,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'How are you feeling?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rate your fatigue level to improve recovery insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // Fatigue level selector
            ...FatigueLevel.values.map((level) => _buildFatigueOption(level, theme)),
            
            const SizedBox(height: 24),
            
            // Optional notes field
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any specific muscle soreness or observations?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const SemanticIcon(
  icon: AppIcons.noteAdd,
  semanticLabel: 'Note add',
),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Muscle Efficiency Preview
            _buildEfficiencyPreview(theme),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Skip'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onRatingSubmitted(
                      _selectedFatigue,
                      _notesController.text.isNotEmpty ? _notesController.text : null,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFatigueOption(FatigueLevel level, ThemeData theme) {
    final isSelected = _selectedFatigue == level.value;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedFatigue = level.value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                level.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${level.value}. ${level.label}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    Text(
                      level.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  AppIcons.complete,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEfficiencyPreview(ThemeData theme) {
    final fatigueLevel = FatigueLevel.fromValue(_selectedFatigue);
    final efficiencyScore = ((widget.totalVolume / 1000) / _selectedFatigue * 20)
        .clamp(0, 100)
        .toDouble();
    
    final efficiencyColor = efficiencyScore >= 70
        ? context.colors.success
        : efficiencyScore >= 40
            ? context.colors.secondary
            : context.colors.error;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.speed,
                color: efficiencyColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Muscle Efficiency Score',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${efficiencyScore.toStringAsFixed(0)}/100',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: efficiencyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(widget.totalVolume / 1000).toStringAsFixed(1)}k kg volume',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Recovery: ~${fatigueLevel.value * 12 + 12}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: efficiencyScore / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(efficiencyColor),
          ),
        ],
      ),
    );
  }
}
