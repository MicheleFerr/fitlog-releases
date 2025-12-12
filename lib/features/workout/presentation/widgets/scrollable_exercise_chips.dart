import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Widget che mostra chips scrollabili per categoria, tipo e TUT dell'esercizio
class ScrollableExerciseChips extends StatefulWidget {
  
  const ScrollableExerciseChips({
    super.key,
    required this.exercise,
    this.exerciseData,
    this.onTutTap,
  });
  final Exercise exercise;
  final Map<String, dynamic>? exerciseData;
  final VoidCallback? onTutTap;

  @override
  State<ScrollableExerciseChips> createState() => _ScrollableExerciseChipsState();
}

class _ScrollableExerciseChipsState extends State<ScrollableExerciseChips> {
  late PageController _pageController;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.45);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Prepara i chip items
    final chipItems = <_ChipItem>[
      // Categoria (es: Shoulders)
      _ChipItem(
        label: widget.exercise.category.name.toUpperCase(),
        icon: _getCategoryIcon(widget.exercise.category),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        textColor: theme.colorScheme.onSurfaceVariant,
      ),
      // Tipo (es: Singles)
      _ChipItem(
        label: widget.exercise.type.name.toUpperCase(),
        icon: _getTypeIcon(widget.exercise.type),
        backgroundColor: _getTypeColor(widget.exercise.type, theme).withValues(alpha: 0.1),
        textColor: _getTypeColor(widget.exercise.type, theme),
      ),
    ];
    
    // Aggiungi TUT se disponibile
    if (widget.exerciseData != null) {
      final tut = widget.exerciseData!['tempoEsecuzione'];
      final tutNote = widget.exerciseData!['tempoNote'];
      
      if (tut != null && tut != '') {
        chipItems.add(
          _ChipItem(
            label: tut == 'ISO' ? 'ISOMETRICO' : 
                   tut == 'EXP' ? 'ESPLOSIVO' : 
                   tut.toString(), // Mostra solo i numeri, più pulito
            icon: AppIcons.infoOutline, // Icona info più chiara per il tap
            backgroundColor: context.colors.tertiary.withValues(alpha: 0.15), // Più visibile
            textColor: context.colors.tertiary,
            subtitle: 'TUT', // Indica che è TUT nel subtitle
            onTap: widget.onTutTap,
            isHighlighted: true, // Rende il chip più prominente
          ),
        );
      }
      
      // Aggiungi range ripetizioni se disponibile
      final rangeRipetizioni = widget.exerciseData!['rangeRipetizioni'];
      if (rangeRipetizioni != null && rangeRipetizioni != '') {
        chipItems.add(
          _ChipItem(
            label: 'REP: $rangeRipetizioni',
            icon: AppIcons.repeat,
            backgroundColor: context.colors.secondary.withValues(alpha: 0.1),
            textColor: context.colors.secondary,
          ),
        );
      }
    }
    
    // Se c'è solo 1 o 2 chips, mostrali normalmente
    if (chipItems.length <= 2) {
      return Row(
        children: chipItems.map((item) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(item, theme),
          )
        ).toList(),
      );
    }
    
    // Altrimenti usa PageView per scrolling
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Haptic feedback on scroll
              HapticFeedback.selectionClick();
            },
            itemCount: chipItems.length,
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildChip(chipItems[index], theme),
                ),
              );
            },
          ),
          // Indicatori di pagina (dots)
          if (chipItems.length > 2)
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  chipItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == index ? 8 : 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          // Frecce di navigazione (solo se più di 2 chips)
          if (chipItems.length > 2) ...[
            if (_currentPage > 0)
              Positioned(
                left: 0,
                child: IconButton(
                  icon: Icon(
                    AppIcons.chevronLeft,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            if (_currentPage < chipItems.length - 1)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: Icon(
                    AppIcons.chevronRight,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChip(_ChipItem item, ThemeData theme) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: item.isHighlighted ? 10 : 8, 
        vertical: item.isHighlighted ? 6 : 4
      ),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(item.isHighlighted ? 10 : 8),
        border: Border.all(
          color: item.textColor.withValues(alpha: item.isHighlighted ? 0.4 : 0.2),
          width: item.isHighlighted ? 1.0 : 0.5,
        ),
        boxShadow: item.isHighlighted ? [
          BoxShadow(
            color: item.textColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: item.isHighlighted ? 14 : 12,
                color: item.textColor,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: item.isHighlighted ? 12 : 10,
                      fontWeight: item.isHighlighted ? FontWeight.w700 : FontWeight.w600,
                      color: item.textColor,
                      fontFamily: item.isHighlighted ? 'monospace' : null, // Font monospace per i numeri TUT
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color: item.textColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    if (item.onTap != null) {
      return GestureDetector(
        onTap: item.onTap,
        child: chip,
      );
    }
    
    return chip;
  }
  
  IconData _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return AppIcons.workout;
      case ExerciseCategory.shoulders:
        return AppIcons.accessibility;
      case ExerciseCategory.back:
        return AppIcons.gymnastics;
      case ExerciseCategory.arms:
        return AppIcons.sportsMma;
      case ExerciseCategory.legs:
        return AppIcons.cardio;
      case ExerciseCategory.abs:
        return AppIcons.flexibility;
      case ExerciseCategory.cardio:
        return AppIcons.cardio;
      case ExerciseCategory.other:
        return AppIcons.workout;
    }
  }
  
  IconData? _getTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.single:
        return null; // No icon for single
      case ExerciseType.superset:
        return AppIcons.doubleArrow;
      case ExerciseType.dropset:
        return AppIcons.trendDown;
      case ExerciseType.restPause:
        return AppIcons.pauseCircleOutline;
    }
  }
  
  Color _getTypeColor(ExerciseType type, ThemeData theme) {
    switch (type) {
      case ExerciseType.single:
        return theme.colorScheme.primary;
      case ExerciseType.superset:
        return theme.colorScheme.secondary;
      case ExerciseType.dropset:
        return theme.colorScheme.tertiary;
      case ExerciseType.restPause:
        return theme.colorScheme.error;
    }
  }
}

class _ChipItem {
  
  const _ChipItem({
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.subtitle,
    this.onTap,
    this.isHighlighted = false,
  });
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isHighlighted;
}