/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: buddy_matching
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: None
 * - Firebase: None
 * - Hive: None
 */

import 'package:flutter/material.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../domain/entities/buddy_preferences.dart';
import '../fitness_level_badge.dart';

class FitnessLevelStep extends StatelessWidget {
  final FitnessLevel selectedLevel;
  final Function(FitnessLevel) onLevelChanged;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const FitnessLevelStep({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
    this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            'Qual è il tuo livello di fitness attuale?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          
          Text(
            'Questo ci aiuterà a trovarti partner con un livello simile',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Fitness levels
          Expanded(
            child: ListView(
              children: FitnessLevel.values.map((level) {
                return _buildLevelCard(context, theme, level);
              }).toList(),
            ),
          ),
          
          // Navigation buttons
          Row(
            children: [
              if (onBack != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Indietro'),
                  ),
                ),
              
              if (onBack != null) const SizedBox(width: 16),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Continua'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, ThemeData theme, FitnessLevel level) {
    final isSelected = selectedLevel == level;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onLevelChanged(level),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Level icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getLevelColor(level).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLevelIcon(level),
                    color: _getLevelColor(level),
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Level info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLevelDescription(level),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return Colors.green;
      case FitnessLevel.intermediate:
        return Colors.orange;
      case FitnessLevel.advanced:
        return Colors.red;
      case FitnessLevel.expert:
        return Colors.purple;
    }
  }

  IconData _getLevelIcon(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return Icons.fitness_center;
      case FitnessLevel.intermediate:
        return Icons.trending_up;
      case FitnessLevel.advanced:
        return Icons.local_fire_department;
      case FitnessLevel.expert:
        return Icons.emoji_events;
    }
  }

  String _getLevelDescription(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return 'Nuovo al fitness, ancora imparando le basi';
      case FitnessLevel.intermediate:
        return 'Allena da alcuni mesi, conosce gli esercizi base';
      case FitnessLevel.advanced:
        return 'Esperienza pluriennale, routine avanzate';
      case FitnessLevel.expert:
        return 'Atleta esperto o personal trainer';
    }
  }
}