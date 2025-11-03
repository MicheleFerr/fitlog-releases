import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/home/providers/volume_settings_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/volume_details_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class VolumeDisplayWidget extends ConsumerWidget {
  
  const VolumeDisplayWidget({
    super.key,
    required this.volumeInKg,
    this.showSettings = true,
    this.expandedView = false,
  });
  final double volumeInKg;
  final bool showSettings;
  final bool expandedView;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(volumeSettingsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Converti il peso nell'unità selezionata
    final displayVolume = settings.convertWeight(volumeInKg);
    
    // Formatta il numero
    final formattedVolume = _formatVolume(displayVolume);
    
    // Ottieni la label del periodo
    final periodLabel = _getPeriodLabel(settings.period, l10n);
    
    if (expandedView) {
      return _buildExpandedView(
        context, 
        ref,
        formattedVolume, 
        settings.unitSymbol, 
        periodLabel,
        settings,
      );
    }
    
    return _buildCompactView(
      context,
      ref, 
      formattedVolume, 
      settings.unitSymbol, 
      periodLabel,
      settings,
    );
  }
  
  Widget _buildExpandedView(
    BuildContext context,
    WidgetRef ref,
    String volume,
    String unit,
    String period,
    VolumeSettings settings,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return InkWell(
      onTap: () => _showVolumeDetails(context, ref),
      borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalVolume,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        period,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showSettings)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showVolumeSettings(context, ref),
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                volume,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTrendIndicator(context),
        ],
      ),
      ),
    );
  }
  
  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    String volume,
    String unit,
    String period,
    VolumeSettings settings,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return InkWell(
      onTap: () => _showVolumeDetails(context, ref),
      onLongPress: showSettings ? () => _showVolumeSettings(context, ref) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.volume,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      volume,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showSettings) ...[
              const SizedBox(width: 8),
              Icon(
                AppIcons.arrowDropDown,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    // TODO: Calcolare il trend reale confrontando con il periodo precedente
    const isPositiveTrend = true;
    const trendPercentage = 12.5;
    
    return Row(
      children: [
        const Icon(
          isPositiveTrend ? Icons.trending_up : Icons.trending_down,
          color: isPositiveTrend ? context.colors.success : context.colors.error,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositiveTrend ? '+' : ''}${trendPercentage.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isPositiveTrend ? context.colors.success : context.colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          l10n.comparedToPrevious,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
  
  void _showVolumeSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _VolumeSettingsSheet(),
    );
  }
  
  void _showVolumeDetails(BuildContext context, WidgetRef ref) {
    // TODO: Ottenere i dati reali dal provider
    // Per ora usiamo dati di esempio
    final dailyData = <DateTime, double>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      // Simula dati con pattern realistico
      if (date.weekday == 1 || date.weekday == 3 || date.weekday == 5) {
        dailyData[date] = 10000 + (i * 100).toDouble();
      } else if (date.weekday == 7) {
        dailyData[date] = 5000; // Domenica più leggera
      } else if (date.weekday == 6) {
        dailyData[date] = 15000; // Sabato più pesante
      } else {
        dailyData[date] = 0; // Giorni di riposo
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeDetailsModal(
        currentVolume: volumeInKg,
        dailyVolumeData: dailyData,
      ),
    );
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    } else {
      return volume.toStringAsFixed(0);
    }
  }
  
  static String _getPeriodLabel(VolumePeriod period, AppLocalizations l10n) {
    switch (period) {
      case VolumePeriod.week:
        return l10n.lastWeek;
      case VolumePeriod.month:
        return l10n.lastMonth;
      case VolumePeriod.year:
        return l10n.lastYear;
      case VolumePeriod.allTime:
        return l10n.allTime;
    }
  }
}

class _VolumeSettingsSheet extends ConsumerWidget {
  const _VolumeSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(volumeSettingsProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.volumeSettings,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Selezione unità di misura
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weightUnit,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _UnitButton(
                          label: 'Kg',
                          isSelected: settings.unit == WeightUnit.kg,
                          onTap: () {
                            ref.read(volumeSettingsProvider.notifier).setUnit(WeightUnit.kg);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _UnitButton(
                          label: 'Lbs',
                          isSelected: settings.unit == WeightUnit.lbs,
                          onTap: () {
                            ref.read(volumeSettingsProvider.notifier).setUnit(WeightUnit.lbs);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Selezione periodo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.timePeriod,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VolumePeriod.values.map((period) {
                      final isSelected = settings.period == period;
                      return ChoiceChip(
                        label: Text(VolumeDisplayWidget._getPeriodLabel(period, l10n)),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(volumeSettingsProvider.notifier).setPeriod(period);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text(l10n.done)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  
  const _UnitButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}