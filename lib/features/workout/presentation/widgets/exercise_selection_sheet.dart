import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_selection_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_onboarding_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// 🚀 TIER-1: Optimized selection sheet with lazy loading
class ExerciseSelectionSheet extends ConsumerStatefulWidget {
  
  const ExerciseSelectionSheet({
    super.key,
    this.targetType,
    required this.onConfirm,
  });
  final ExerciseType? targetType;
  final void Function(List<ExerciseData> selected) onConfirm;
  
  @override
  ConsumerState<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends ConsumerState<ExerciseSelectionSheet> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  // GlobalKeys for onboarding (steps 2-5)
  final _searchBarKey = GlobalKey();
  final _filtersKey = GlobalKey();
  final _firstExerciseKey = GlobalKey();
  final _confirmButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    
    // Set target type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseSelectionProvider.notifier).setTargetType(widget.targetType);
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    // Reset selection state when closing
    ref.read(exerciseSelectionProvider.notifier).reset();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = ref.watch(exerciseSelectionProvider);
    final exercises = ref.watch(filteredExercisesProvider);

    return Stack(
      children: [
        DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              _buildHeader(context, selection),
              
              // Search bar
              _buildSearchBar(context),
              
              // Category chips
              _buildCategoryChips(context),
              
              // Exercise list
              Expanded(
                child: exercises.when(
                  data: (exerciseList) => _buildExerciseList(
                    context,
                    exerciseList,
                    scrollController,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
              
              // Bottom actions
              _buildBottomActions(context, selection),
            ],
          ),
        );
      },
        ),

        // Onboarding overlay (steps 2-5 visible in this sheet)
        ExerciseOnboardingOverlay(
          singleExerciseTabKey: GlobalKey(), // Dummy - used in EnhancedAddExerciseModal
          selectExerciseButtonKey: GlobalKey(), // Dummy - used in EnhancedAddExerciseModal
          searchBarKey: _searchBarKey,
          firstExerciseKey: _firstExerciseKey,
          filtersKey: _filtersKey,
          confirmButtonKey: _confirmButtonKey,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ExerciseSelectionState selection) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    String title;
    switch (selection.targetType) {
      case ExerciseType.superset:
        title = l10n.selectExercisesForSuperset;
      case ExerciseType.dropset:
        title = l10n.selectExerciseForDropset;
      case ExerciseType.restPause:
        title = l10n.selectExerciseForRestPause;
      default:
        title = l10n.selectExercise;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ),
                if (selection.selectedIds.isNotEmpty)
                  Text(
                    '${selection.selectedIds.length} ${l10n.selected}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (selection.targetType == ExerciseType.superset && selection.selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                ref.read(exerciseSelectionProvider.notifier).clearSelection();
              },
              icon: const SemanticIcon(
  icon: AppIcons.clearAll,
  semanticLabel: 'Clear all',
  size: AppIconSize.small,
),
              label: Text(l10n.clearAll),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      key: _searchBarKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchExercises,
          prefixIcon: const SemanticIcon(
  icon: AppIcons.search,
  semanticLabel: 'Search',
),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const SemanticIcon(
  icon: AppIcons.clear,
  semanticLabel: 'Clear',
),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(exerciseSelectionProvider.notifier).updateSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_searchController.text == value) {
              ref.read(exerciseSelectionProvider.notifier).updateSearch(value);
            }
          });
        },
      ),
    );
  }
  
  Widget _buildCategoryChips(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['PETTO', 'DORSO', 'GAMBE', 'SPALLE', 'BRACCIA', 'ADDOME'];
    final selection = ref.watch(exerciseSelectionProvider.select((s) => s.focusedCategory));

    return SizedBox(
      key: _filtersKey,
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selection == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(exerciseSelectionProvider.notifier)
                    .setCategory(selected ? category : null);
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExerciseList(
    BuildContext context,
    List<ExerciseData> exercises,
    ScrollController scrollController,
  ) {
    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
  icon: AppIcons.searchOff,
  semanticLabel: 'Search off',
  size: AppIconSize.medium,
  color: Theme.of(context,
).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noExercisesFound,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    
    // Use ListView.builder for lazy loading
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: exercises.length,
      itemExtent: 80, // Fixed height for better performance
      cacheExtent: 160, // Cache 2 items above and below
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseSelectionTile(
          key: index == 0 ? _firstExerciseKey : ValueKey(exercise.id),
          exercise: exercise,
        );
      },
    );
  }
  
  Widget _buildBottomActions(BuildContext context, ExerciseSelectionState selection) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    // Validation based on exercise type
    bool canConfirm = false;
    String confirmText = l10n.confirm;
    
    switch (selection.targetType) {
      case ExerciseType.superset:
        canConfirm = selection.selectedIds.length >= 2;
        confirmText = '${l10n.confirm} (${selection.selectedIds.length})';
        break;
      case ExerciseType.dropset:
      case ExerciseType.restPause:
        canConfirm = selection.selectedIds.length == 1;
        break;
      default:
        canConfirm = selection.selectedIds.isNotEmpty;
    }
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              key: _confirmButtonKey,
              onPressed: canConfirm
                  ? () {
                      final selected = ref.read(selectedExercisesProvider);
                      widget.onConfirm(selected);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text(confirmText),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🚀 TIER-1: Optimized exercise tile with const constructor
class ExerciseSelectionTile extends ConsumerWidget {
  
  const ExerciseSelectionTile({
    super.key,
    required this.exercise,
  });
  final ExerciseData exercise;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      exerciseSelectionProvider.select((s) => s.selectedIds.contains(exercise.id)),
    );
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(exerciseSelectionProvider.notifier).toggleSelection(exercise.id);
        },
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Image with placeholder
              _buildExerciseImage(theme),
              
              const SizedBox(width: 12),
              
              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exercise.nome,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.focus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurfaceVariant,
),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.attrezzatura,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(exercise.difficolta, theme)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exercise.difficolta,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getDifficultyColor(exercise.difficolta, theme),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onPrimary,
),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildExerciseImage(ThemeData theme) {
    if (exercise.imageUrl == null || exercise.imageUrl!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurfaceVariant,
),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: exercise.imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        memCacheWidth: 120, // Cache at 2x size for retina
        memCacheHeight: 120,
        placeholder: (context, url) => Container(
          width: 60,
          height: 60,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 60,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: SemanticIcon(
  icon: AppIcons.brokenImage,
  semanticLabel: 'Broken image',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurfaceVariant,
),
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return theme.colorScheme.success;
      case 'intermedio':
        return theme.colorScheme.secondary;
      case 'avanzato':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
