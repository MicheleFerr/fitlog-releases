import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_suggestion.dart';
import 'package:gymbro_flutter_new/features/smart_training/presentation/providers/smart_training_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget that displays smart training suggestions
class SmartSuggestionsWidget extends ConsumerWidget {
  const SmartSuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(smartSuggestionsProvider);
    final l10n = AppLocalizations.of(context);
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  AppIcons.tip,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.smartSuggestions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...suggestions.take(3).map((suggestion) => 
            SmartSuggestionTile(suggestion: suggestion)
          ),
        ],
      ),
    );
  }
}

/// Individual suggestion tile
class SmartSuggestionTile extends ConsumerWidget {
  
  const SmartSuggestionTile({
    super.key,
    required this.suggestion,
  });
  final SmartSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(context, suggestion.priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPriorityText(l10n, suggestion.priority),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(suggestion.confidence * 100).round()}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (suggestion.reasoning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.info,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.reasoning,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (suggestion.actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: suggestion.actions.map((action) => 
                _buildActionButton(context, ref, action)
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    SuggestionAction action,
  ) {
    return action.isPrimary
        ? ElevatedButton(
            onPressed: () => _handleAction(ref, action),
            child: Text(action.label),
          )
        : OutlinedButton(
            onPressed: () => _handleAction(ref, action),
            child: Text(action.label),
          );
  }

  void _handleAction(WidgetRef ref, SuggestionAction action) {
    final notifier = ref.read(smartSuggestionsProvider.notifier);
    
    switch (action.type) {
      case SuggestionActionType.applyChange:
        notifier.applySuggestion(suggestion.id);
        // TODO: Apply the actual change based on payload
        break;
      case SuggestionActionType.dismiss:
        notifier.dismissSuggestion(suggestion.id);
        break;
      case SuggestionActionType.viewDetails:
        // TODO: Navigate to details screen
        break;
      case SuggestionActionType.learnMore:
        // TODO: Open educational content
        break;
      case SuggestionActionType.remindLater:
        // TODO: Schedule reminder
        break;
      case SuggestionActionType.customizeWorkout:
        // TODO: Open workout customization
        break;
      case SuggestionActionType.startTemplate:
        // TODO: Start template workout
        break;
      case SuggestionActionType.adjustSettings:
        // TODO: Open settings
        break;
    }
  }

  Color _getPriorityColor(BuildContext context, SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.critical:
        return Colors.red;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.medium:
        return Colors.blue;
      case SuggestionPriority.low:
        return Colors.grey;
    }
  }

  String _getPriorityText(AppLocalizations l10n, SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.critical:
        return l10n.criticalPriority;
      case SuggestionPriority.high:
        return l10n.highPriority;
      case SuggestionPriority.medium:
        return l10n.mediumPriority;
      case SuggestionPriority.low:
        return l10n.lowPriority;
    }
  }
}
