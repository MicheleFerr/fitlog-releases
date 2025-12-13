import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/home/providers/home_customization_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class WidgetCustomizationMenu extends ConsumerWidget {
  const WidgetCustomizationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hiddenWidgets = ref.watch(homeCustomizationProvider.notifier).hiddenWidgets;
    
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: safeMax,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.widgets,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Widget Disponibili',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tocca per aggiungere alla home',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Widget list
            Expanded(
              child: hiddenWidgets.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: hiddenWidgets.length,
                      itemBuilder: (context, index) {
                        final widget = hiddenWidgets[index];
                        return _buildWidgetItem(context, ref, widget);
                      },
                    ),
            ),
            
            // Bottom actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showResetConfirmation(context, ref);
                        },
                        icon: const SemanticIcon(
  icon: AppIcons.restore,
  semanticLabel: 'Restore',
),
                        label: Text(AppLocalizations.of(context).resetLayout),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
),
                        label: Text(AppLocalizations.of(context).fatto),
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
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.completeOutline,
  semanticLabel: 'Complete outline',
  size: AppIconSize.medium,
  color: theme.colorScheme.primary.withValues(alpha: 0.5,
),
          ),
          const SizedBox(height: 16),
          Text(
            'Tutti i widget sono visibili',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Nascondi widget dalla modalità modifica',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetItem(BuildContext context, WidgetRef ref, HomeWidgetConfig widget) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ref.read(homeCustomizationProvider.notifier)
              .toggleWidgetVisibility(widget.id);
          HapticFeedback.lightImpact();

          SnackBarService.showSuccess(
            context,
            '${widget.title} aggiunto alla home',
            duration: const Duration(seconds: 2),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getWidgetDescription(widget.type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.add,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Aggiungi',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getWidgetDescription(String type) {
    switch (type) {
      case HomeWidgetType.recentWorkouts:
        return 'Visualizza gli ultimi allenamenti completati';
      case HomeWidgetType.weeklyGoals:
        return 'Monitora i tuoi obiettivi settimanali';
      case HomeWidgetType.motivationalQuote:
        return 'Citazione motivazionale giornaliera';
      case HomeWidgetType.exerciseOfTheDay:
        return 'Scopri un nuovo esercizio ogni giorno';
      case HomeWidgetType.nutritionTracker:
        return 'Traccia la tua alimentazione';
      case HomeWidgetType.waterIntake:
        return 'Monitora l\'idratazione giornaliera';
      case HomeWidgetType.sleepTracker:
        return 'Analizza la qualità del sonno';
      case HomeWidgetType.bodyMeasurements:
        return 'Registra le tue misure corporee';
      default:
        return 'Widget personalizzabile';
    }
  }
  
  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).resetLayout),
        content: const Text(
          'Vuoi ripristinare il layout predefinito? Tutte le tue personalizzazioni verranno perse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(homeCustomizationProvider.notifier).resetToDefaults();
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              Navigator.pop(context);

              SnackBarService.showInfo(context, 'Layout ripristinato');
            },
            child: Text(AppLocalizations.of(context).reset),
          ),
        ],
      ),
    );
  }
}
