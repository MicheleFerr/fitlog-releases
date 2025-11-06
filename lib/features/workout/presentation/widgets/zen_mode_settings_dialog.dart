import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/zen_mode_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ZenModeSettingsDialog extends ConsumerWidget {
  const ZenModeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zenState = ref.watch(zenModeProvider);
    final zenNotifier = ref.read(zenModeProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.flexibility,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zen Mode',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Allenamento senza distrazioni',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main toggle
                  Switch.adaptive(
                    value: zenState.isEnabled,
                    onChanged: (_) => zenNotifier.toggleZenMode(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            
            // Settings list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (zenState.isEnabled) ...[
                      // Section: Nascondi Distrazioni
                      _buildSectionHeader(context, 'Nascondi Distrazioni'),
                      _buildToggleTile(
                        context: context,
                        title: 'Suggerimenti Community',
                        subtitle: 'Nasconde i suggerimenti dalla community',
                        icon: AppIcons.peopleOutline,
                        value: zenState.config.hideCommunitySuggestions,
                        onChanged: (value) => zenNotifier.updateConfigField('hideCommunitySuggestions', value),
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Card Riscaldamento',
                        subtitle: 'Nasconde i suggerimenti di warmup',
                        icon: AppIcons.whatshotOutlined,
                        value: zenState.config.hideWarmupCards,
                        onChanged: (value) => zenNotifier.updateConfigField('hideWarmupCards', value),
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Chips Muscoli',
                        subtitle: 'Nasconde chips come "Shoulders", "Chest"',
                        icon: AppIcons.labelOutline,
                        value: zenState.config.hideExerciseChips,
                        onChanged: (value) => zenNotifier.updateConfigField('hideExerciseChips', value),
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Animazioni XP',
                        subtitle: 'Nasconde le barre XP animate',
                        icon: AppIcons.autoAwesomeOutlined,
                        value: zenState.config.hideXPAnimations,
                        onChanged: (value) => zenNotifier.updateConfigField('hideXPAnimations', value),
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Tutorial',
                        subtitle: 'Nasconde overlay tutorial',
                        icon: AppIcons.help,
                        value: zenState.config.hideTutorials,
                        onChanged: (value) => zenNotifier.updateConfigField('hideTutorials', value),
                      ),
                      
                      const Divider(height: 32),
                      
                      // Section: Funzionalità Workout
                      _buildSectionHeader(context, 'Funzionalità Workout'),
                      _buildToggleTile(
                        context: context,
                        title: 'Schermo Sempre Attivo',
                        subtitle: 'Mantiene lo schermo acceso durante il workout',
                        icon: AppIcons.mobileScreenShare,
                        value: zenState.config.keepScreenOn,
                        onChanged: (value) => zenNotifier.updateConfigField('keepScreenOn', value),
                        isHighlighted: true,
                      ),
                      
                      const Divider(height: 32),
                      
                      // Section: Metriche Avanzate (Future)
                      _buildSectionHeader(context, 'Metriche Avanzate'),
                      _buildToggleTile(
                        context: context,
                        title: 'Time Under Tension (TUT)',
                        subtitle: 'Mostra tempo sotto tensione per set',
                        icon: AppIcons.timerOffOutlined,
                        value: zenState.config.showTUT,
                        onChanged: (value) => zenNotifier.updateConfigField('showTUT', value),
                        isComingSoon: true,
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Velocity Tracking',
                        subtitle: 'Mostra velocità di esecuzione',
                        icon: AppIcons.speed,
                        value: zenState.config.showVelocity,
                        onChanged: (value) => zenNotifier.updateConfigField('showVelocity', value),
                        isComingSoon: true,
                      ),
                      _buildToggleTile(
                        context: context,
                        title: 'Volume Totale',
                        subtitle: 'Mostra volume totale allenamento',
                        icon: AppIcons.analyticsOutlined,
                        value: zenState.config.showVolume,
                        onChanged: (value) => zenNotifier.updateConfigField('showVolume', value),
                      ),
                    ] else ...[
                      // Zen Mode disattivata
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              AppIcons.flexibility,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Attiva Zen Mode',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Elimina le distrazioni e concentrati solo sull\'allenamento',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildToggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    bool isHighlighted = false,
    bool isComingSoon = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isComingSoon 
            ? theme.colorScheme.outline
            : theme.colorScheme.primary,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isComingSoon
                  ? theme.colorScheme.outline
                  : null,
              ),
            ),
            if (isComingSoon) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Coming Soon',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isComingSoon
              ? theme.colorScheme.outline.withValues(alpha: 0.7)
              : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: isComingSoon ? null : onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        dense: true,
      ),
    );
  }
}
