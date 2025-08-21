import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';

class WorkoutCustomizationModal extends ConsumerStatefulWidget {
  const WorkoutCustomizationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const WorkoutCustomizationModal(),
    );
  }

  @override
  ConsumerState<WorkoutCustomizationModal> createState() => _WorkoutCustomizationModalState();
}

class _WorkoutCustomizationModalState extends ConsumerState<WorkoutCustomizationModal> {
  late bool _rpeTracking;
  late bool _autoRestTimer;
  late bool _setDurationTracking;
  late bool _plateCalculator;
  late bool _warmupSuggestions;
  
  @override
  void initState() {
    super.initState();
    final config = ref.read(appConfigProvider);
    
    // Initialize with current settings or defaults
    _rpeTracking = config.rpeTracking ?? true;
    _autoRestTimer = config.autoRestTimer ?? true;
    _setDurationTracking = config.setDurationTracking ?? false;
    _plateCalculator = config.plateCalculator ?? false;
    _warmupSuggestions = config.warmupSuggestions ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalizza Workout',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Attiva o disattiva le funzionalità',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            
            // Settings list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // RPE Tracking
                  _buildSettingTile(
                    icon: Icons.speed,
                    iconColor: Colors.orange,
                    title: 'Monitoraggio RPE',
                    subtitle: 'Richiedi lo sforzo percepito dopo ogni serie',
                    value: _rpeTracking,
                    onChanged: (value) {
                      setState(() => _rpeTracking = value);
                      _saveSettings();
                    },
                  ),
                  
                  // Auto Rest Timer
                  _buildSettingTile(
                    icon: Icons.timer,
                    iconColor: Colors.blue,
                    title: 'Timer Riposo Automatico',
                    subtitle: 'Avvia automaticamente il timer dopo ogni serie',
                    value: _autoRestTimer,
                    onChanged: (value) {
                      setState(() => _autoRestTimer = value);
                      _saveSettings();
                    },
                  ),
                  
                  // Set Duration Tracking
                  _buildSettingTile(
                    icon: Icons.timelapse,
                    iconColor: Colors.green,
                    title: 'Durata Serie',
                    subtitle: 'Traccia il tempo di esecuzione di ogni serie',
                    value: _setDurationTracking,
                    onChanged: (value) {
                      setState(() => _setDurationTracking = value);
                      _saveSettings();
                    },
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  
                  // Plate Calculator
                  _buildSettingTile(
                    icon: Icons.calculate,
                    iconColor: Colors.purple,
                    title: 'Calcolatore Dischi',
                    subtitle: 'Mostra quali dischi caricare sul bilanciere',
                    value: _plateCalculator,
                    onChanged: (value) {
                      setState(() => _plateCalculator = value);
                      _saveSettings();
                    },
                  ),
                  
                  // Warmup Suggestions
                  _buildSettingTile(
                    icon: Icons.whatshot,
                    iconColor: Colors.red,
                    title: 'Suggerimenti Riscaldamento',
                    subtitle: 'Calcola automaticamente i set di warmup',
                    value: _warmupSuggestions,
                    onChanged: (value) {
                      setState(() => _warmupSuggestions = value);
                      _saveSettings();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Le impostazioni vengono salvate automaticamente e applicate a tutti i workout futuri',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: value 
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
  
  void _saveSettings() {
    // Save to provider
    ref.read(appConfigProvider.notifier).updateWorkoutSettings(
      rpeTracking: _rpeTracking,
      autoRestTimer: _autoRestTimer,
      setDurationTracking: _setDurationTracking,
      plateCalculator: _plateCalculator,
      warmupSuggestions: _warmupSuggestions,
    );
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Impostazioni salvate'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}