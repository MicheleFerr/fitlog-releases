import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class LevelInfoModal extends ConsumerWidget {
  
  const LevelInfoModal({
    super.key,
    required this.currentLevel,
    required this.currentXp,
    required this.xpForNextLevel,
  });
  final int currentLevel;
  final int currentXp;
  final int xpForNextLevel;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getLevelColor(currentLevel),
                        _getLevelColor(currentLevel).withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getLevelIcon(currentLevel),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.levelSystem,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${l10n.currentLevel}: ${_getLevelName(currentLevel, l10n)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _getLevelColor(currentLevel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.yourProgress,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$currentXp / $xpForNextLevel XP',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: currentXp / xpForNextLevel,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(currentLevel)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((currentXp / xpForNextLevel) * 100).toStringAsFixed(1)}% ${l10n.toNextLevel}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Levels List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 10, // Show first 10 levels
              itemBuilder: (context, index) {
                final level = index + 1;
                final isCurrentLevel = level == currentLevel;
                final isUnlocked = level <= currentLevel;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isCurrentLevel
                      ? _getLevelColor(level).withValues(alpha: 0.1)
                      : isUnlocked
                        ? theme.colorScheme.surface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentLevel
                        ? _getLevelColor(level)
                        : isUnlocked
                          ? theme.colorScheme.outline.withValues(alpha: 0.2)
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                      width: isCurrentLevel ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked
                          ? _getLevelColor(level).withValues(alpha: 0.2)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isUnlocked
                          ? Icon(
                              _getLevelIcon(level),
                              color: _getLevelColor(level),
                              size: 24,
                            )
                          : Icon(
                              Icons.lock_outline,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              size: 20,
                            ),
                      ),
                    ),
                    title: Text(
                      '${l10n.level} $level - ${_getLevelName(level, l10n)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.w600,
                        color: isUnlocked 
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _getLevelDescription(level, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._getLevelBenefits(level, l10n).map((benefit) => 
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isUnlocked ? Icons.check_circle : Icons.circle_outlined,
                                  size: 16,
                                  color: isUnlocked
                                    ? Colors.green
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isUnlocked
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: isCurrentLevel
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getLevelColor(level),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.current,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getLevelColor(int level) {
    if (level <= 2) return Colors.grey;
    if (level <= 4) return Colors.green;
    if (level <= 6) return Colors.blue;
    if (level <= 8) return Colors.purple;
    return Colors.orange;
  }
  
  IconData _getLevelIcon(int level) {
    if (level <= 2) return Icons.fitness_center;
    if (level <= 4) return Icons.trending_up;
    if (level <= 6) return Icons.star;
    if (level <= 8) return Icons.emoji_events;
    return Icons.diamond;
  }
  
  String _getLevelName(int level, AppLocalizations l10n) {
    switch (level) {
      case 1: return l10n.beginner;
      case 2: return l10n.novice;
      case 3: return l10n.intermediate;
      case 4: return l10n.advanced;
      case 5: return l10n.expert;
      case 6: return l10n.master;
      case 7: return l10n.grandmaster;
      case 8: return l10n.champion;
      case 9: return l10n.legend;
      case 10: return l10n.titan;
      default: return l10n.elite;
    }
  }
  
  String _getLevelDescription(int level, AppLocalizations l10n) {
    switch (level) {
      case 1: return l10n.levelDesc1;
      case 2: return l10n.levelDesc2;
      case 3: return l10n.levelDesc3;
      case 4: return l10n.levelDesc4;
      case 5: return l10n.levelDesc5;
      case 6: return l10n.levelDesc6;
      case 7: return l10n.levelDesc7;
      case 8: return l10n.levelDesc8;
      case 9: return l10n.levelDesc9;
      case 10: return l10n.levelDesc10;
      default: return '';
    }
  }
  
  List<String> _getLevelBenefits(int level, AppLocalizations l10n) {
    switch (level) {
      case 1:
        return [
          l10n.benefit1_1,
          l10n.benefit1_2,
        ];
      case 2:
        return [
          l10n.benefit2_1,
          l10n.benefit2_2,
        ];
      case 3:
        return [
          l10n.benefit3_1,
          l10n.benefit3_2,
          l10n.benefit3_3,
        ];
      case 4:
        return [
          l10n.benefit4_1,
          l10n.benefit4_2,
          l10n.benefit4_3,
        ];
      case 5:
        return [
          l10n.benefit5_1,
          l10n.benefit5_2,
          l10n.benefit5_3,
        ];
      case 6:
        return [
          l10n.benefit6_1,
          l10n.benefit6_2,
          l10n.benefit6_3,
        ];
      case 7:
        return [
          l10n.benefit7_1,
          l10n.benefit7_2,
          l10n.benefit7_3,
        ];
      case 8:
        return [
          l10n.benefit8_1,
          l10n.benefit8_2,
          l10n.benefit8_3,
        ];
      case 9:
        return [
          l10n.benefit9_1,
          l10n.benefit9_2,
          l10n.benefit9_3,
        ];
      case 10:
        return [
          l10n.benefit10_1,
          l10n.benefit10_2,
          l10n.benefit10_3,
        ];
      default:
        return [];
    }
  }
}