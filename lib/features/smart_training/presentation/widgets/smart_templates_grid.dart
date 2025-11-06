import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_workout_template.dart';
import 'package:gymbro_flutter_new/features/smart_training/presentation/providers/smart_training_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Grid widget that displays smart workout templates
class SmartTemplatesGrid extends ConsumerWidget {
  
  const SmartTemplatesGrid({
    super.key,
    this.showFilters = true,
  });
  final bool showFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(templateFilterProvider);
    final templates = ref.watch(filteredTemplatesProvider(filter));
    final searchQuery = ref.watch(templateSearchProvider);
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        if (showFilters) ...[
          _buildSearchBar(context, ref, l10n),
          const SizedBox(height: 16),
          _buildFilterChips(context, ref, l10n),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: templates.isEmpty
              ? _buildEmptyState(context, l10n)
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    return SmartTemplateCard(template: templates[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => ref.read(templateSearchProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: const Icon(AppIcons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final filter = ref.watch(templateFilterProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Difficulty filter
          _buildFilterChip(
            context,
            ref,
            'Difficulty',
            filter.difficulty?.name ?? 'All',
            () => _showDifficultyFilter(context, ref),
          ),
          const SizedBox(width: 8),
          // Category filter
          _buildFilterChip(
            context,
            ref,
            'Category',
            filter.category?.name ?? 'All',
            () => _showCategoryFilter(context, ref),
          ),
          const SizedBox(width: 8),
          // Style filter
          _buildFilterChip(
            context,
            ref,
            'Style',
            filter.style?.name ?? 'All',
            () => _showStyleFilter(context, ref),
          ),
          const SizedBox(width: 8),
          // Duration filter
          _buildFilterChip(
            context,
            ref,
            'Duration',
            filter.maxDuration != null ? '${filter.maxDuration}min' : 'Any',
            () => _showDurationFilter(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 4),
            Icon(
              AppIcons.arrowDropDown,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.searchOff,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficultyFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DifficultyFilterSheet(),
    );
  }

  void _showCategoryFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _CategoryFilterSheet(),
    );
  }

  void _showStyleFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StyleFilterSheet(),
    );
  }

  void _showDurationFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DurationFilterSheet(),
    );
  }
}

/// Individual template card
class SmartTemplateCard extends ConsumerWidget {
  
  const SmartTemplateCard({
    super.key,
    required this.template,
  });
  final SmartWorkoutTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _onTemplateTap(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template image/header
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getDifficultyColor(template.difficulty),
                    _getDifficultyColor(template.difficulty).withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (template.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PRO',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${template.estimatedDuration}min',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDifficultyText(l10n, template.difficulty),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Template info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          AppIcons.workout,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.exercises.length} exercises',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              AppIcons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              template.averageRating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
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

  void _onTemplateTap(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to template details or start workout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: Text(template.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Start workout from template
            },
            child: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }

  String _getDifficultyText(AppLocalizations l10n, DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return l10n.beginnerTemplate;
      case DifficultyLevel.intermediate:
        return l10n.intermediateTemplate;
      case DifficultyLevel.advanced:
        return l10n.advancedTemplate;
      case DifficultyLevel.expert:
        return l10n.expertTemplate;
    }
  }
}

// Filter bottom sheets
class _DifficultyFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(templateFilterProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Difficulty Level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...DifficultyLevel.values.map((difficulty) => 
            ListTile(
              title: Text(difficulty.name.toUpperCase()),
              leading: Radio<DifficultyLevel?>(
                value: difficulty,
                groupValue: currentFilter.difficulty,
                onChanged: (value) {
                  ref.read(templateFilterProvider.notifier).state = 
                      currentFilter.copyWith(difficulty: value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('ALL'),
            leading: Radio<DifficultyLevel?>(
              value: null,
              groupValue: currentFilter.difficulty,
              onChanged: (value) {
                ref.read(templateFilterProvider.notifier).state = 
                    currentFilter.copyWith(difficulty: null);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(templateFilterProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Workout Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...WorkoutCategory.values.map((category) => 
            ListTile(
              title: Text(category.name.toUpperCase()),
              leading: Radio<WorkoutCategory?>(
                value: category,
                groupValue: currentFilter.category,
                onChanged: (value) {
                  ref.read(templateFilterProvider.notifier).state = 
                      currentFilter.copyWith(category: value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('ALL'),
            leading: Radio<WorkoutCategory?>(
              value: null,
              groupValue: currentFilter.category,
              onChanged: (value) {
                ref.read(templateFilterProvider.notifier).state = 
                    currentFilter.copyWith(category: null);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(templateFilterProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Training Style',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...TrainingStyle.values.map((style) => 
            ListTile(
              title: Text(style.name.toUpperCase()),
              leading: Radio<TrainingStyle?>(
                value: style,
                groupValue: currentFilter.style,
                onChanged: (value) {
                  ref.read(templateFilterProvider.notifier).state = 
                      currentFilter.copyWith(style: value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('ALL'),
            leading: Radio<TrainingStyle?>(
              value: null,
              groupValue: currentFilter.style,
              onChanged: (value) {
                ref.read(templateFilterProvider.notifier).state = 
                    currentFilter.copyWith(style: null);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(templateFilterProvider);
    
    final durations = [30, 45, 60, 75, 90];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Max Duration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...durations.map((duration) => 
            ListTile(
              title: Text('$duration minutes'),
              leading: Radio<int?>(
                value: duration,
                groupValue: currentFilter.maxDuration,
                onChanged: (value) {
                  ref.read(templateFilterProvider.notifier).state = 
                      currentFilter.copyWith(maxDuration: value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('ANY DURATION'),
            leading: Radio<int?>(
              value: null,
              groupValue: currentFilter.maxDuration,
              onChanged: (value) {
                ref.read(templateFilterProvider.notifier).state = 
                    currentFilter.copyWith(maxDuration: null);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
