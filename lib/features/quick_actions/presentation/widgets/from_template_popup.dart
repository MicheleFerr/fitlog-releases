/// From Template Popup
///
/// Popup menu showing user's workout templates.
/// Uses CNPopupMenuButton to show a native popup menu
/// with all available workout templates.
library;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Popup button for selecting a workout template
class FromTemplatePopup extends ConsumerWidget {
  const FromTemplatePopup({
    required this.onTemplateSelected,
    required this.onViewAll,
    super.key,
  });

  /// Called when user selects a specific template
  final void Function(WorkoutTemplate template) onTemplateSelected;

  /// Called when user selects "View all templates..."
  final VoidCallback onViewAll;

  /// Max templates to show before adding "View all..."
  static const int _maxTemplates = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => CNPopupMenuButton(
        buttonLabel: context.l10n.fromTemplate,
        buttonStyle: CNButtonStyle.glass,
        height: 44,
        items: const [
          CNPopupMenuItem(
            label: 'Loading...',
            icon: CNSymbol('hourglass'),
          ),
        ],
        onSelected: (_) {},
      ),
      error: (_, __) => CNPopupMenuButton(
        buttonLabel: context.l10n.fromTemplate,
        buttonStyle: CNButtonStyle.glass,
        height: 44,
        items: [
          CNPopupMenuItem(
            label: context.l10n.quickActionNoTemplates,
            icon: const CNSymbol('exclamationmark.triangle'),
          ),
        ],
        onSelected: (_) {},
      ),
      data: (templates) => _buildPopup(context, templates),
    );
  }

  Widget _buildPopup(BuildContext context, List<WorkoutTemplate> templates) {
    // Se non ci sono template, mostra messaggio
    if (templates.isEmpty) {
      return CNPopupMenuButton(
        buttonLabel: context.l10n.fromTemplate,
        buttonStyle: CNButtonStyle.glass,
        height: 44,
        items: [
          CNPopupMenuItem(
            label: context.l10n.quickActionNoTemplates,
            icon: const CNSymbol('tray'),
          ),
          const CNPopupMenuDivider(),
          CNPopupMenuItem(
            label: context.l10n.quickActionViewAllTemplates,
            icon: const CNSymbol('rectangle.stack'),
          ),
        ],
        onSelected: (index) {
          if (index == 2) {
            // "View all templates..."
            onViewAll();
          }
        },
      );
    }

    // Prendi solo i primi N template
    final displayTemplates = templates.take(_maxTemplates).toList();
    final hasMore = templates.length > _maxTemplates;

    return CNPopupMenuButton(
      buttonLabel: context.l10n.fromTemplate,
      buttonStyle: CNButtonStyle.glass,
      height: 44,
      items: [
        // Template items
        for (final template in displayTemplates)
          CNPopupMenuItem(
            label: template.name,
            icon: CNSymbol(_getTemplateIcon(template)),
          ),

        // Divider se ci sono più template
        if (hasMore) const CNPopupMenuDivider(),

        // "View all templates..." se ci sono più template
        if (hasMore)
          CNPopupMenuItem(
            label: context.l10n.quickActionViewAllTemplates,
            icon: const CNSymbol('rectangle.stack'),
          ),
      ],
      onSelected: (index) => _handleSelection(
        index,
        displayTemplates,
        hasMore,
      ),
    );
  }

  void _handleSelection(
    int index,
    List<WorkoutTemplate> displayTemplates,
    bool hasMore,
  ) {
    // Se è uno dei template
    if (index < displayTemplates.length) {
      onTemplateSelected(displayTemplates[index]);
      return;
    }

    // Se è "View all templates..."
    if (hasMore && index == displayTemplates.length + 1) {
      // +1 per il divider
      onViewAll();
    }
  }

  /// Get SF Symbol icon based on template category/type
  String _getTemplateIcon(WorkoutTemplate template) {
    // Usa la categoria del template per scegliere l'icona
    final category = template.effectiveCategory;

    return switch (category.name) {
      'strength' => 'dumbbell',
      'cardio' => 'figure.run',
      'flexibility' => 'figure.yoga',
      'hybrid' => 'figure.strengthtraining.traditional',
      _ => 'figure.strengthtraining.traditional',
    };
  }
}
