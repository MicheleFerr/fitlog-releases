import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_selector.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_info_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Info bar minimalista e professionale per mostrare categoria, tipo e TUT
class ExerciseInfoBar extends StatefulWidget {
  
  const ExerciseInfoBar({
    super.key,
    required this.exercise,
    this.exerciseData,
    this.onTutTap,
    this.onTutChanged,
  });
  final Exercise exercise;
  final Map<String, dynamic>? exerciseData;
  final VoidCallback? onTutTap;
  final Function(String)? onTutChanged;
  
  @override
  State<ExerciseInfoBar> createState() => _ExerciseInfoBarState();
}

class _ExerciseInfoBarState extends State<ExerciseInfoBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isPressed = false;
  bool _isDataLoaded = false;
  bool _showTutSelector = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Trigger shimmer effect on first load
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tut = widget.exerciseData?['tempoEsecuzione'];
    final hasValidTut = tut != null && tut != '' && tut != 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: hasValidTut ? (_) {
            setState(() => _isPressed = true);
            _animationController.forward();
            HapticFeedback.lightImpact();
          } : null,
          onTapUp: hasValidTut ? (_) {
            setState(() => _isPressed = false);
            _animationController.reverse();
            if (widget.onTutChanged != null) {
              setState(() => _showTutSelector = !_showTutSelector);
            } else {
              _showTutInfoDialog(context, tut!);
            }
          } : null,
          onTapCancel: hasValidTut ? () {
            setState(() => _isPressed = false);
            _animationController.reverse();
          } : null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPressed || _showTutSelector
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: _isPressed || _showTutSelector
                      ? Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                  ),
                  child: _isDataLoaded
                    ? _buildContent(theme, tut, hasValidTut)
                    : _buildShimmer(theme),
                ),
              );
            },
          ),
        ),

        // TUT Selector Overlay
        if (_showTutSelector && hasValidTut && widget.onTutChanged != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TutSelector(
              initialValue: tut,
              isCompact: true,
              onChanged: (newTut) {
                widget.onTutChanged!(newTut);
                setState(() => _showTutSelector = false);
              },
            ),
          ),
      ],
    );
  }
  
  Widget _buildContent(ThemeData theme, String? tut, bool hasValidTut) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Categoria con icona
        AnimatedSlide(
          offset: _isDataLoaded ? Offset.zero : const Offset(-0.2, 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _isDataLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildInfoItem(
              icon: _getCategoryIcon(widget.exercise.category),
              text: _getCategoryDisplayName(widget.exercise.category),
              color: theme.colorScheme.onSurfaceVariant,
              theme: theme,
            ),
          ),
        ),
        
        _buildSeparator(theme),
        
        // Tipo
        AnimatedSlide(
          offset: _isDataLoaded ? Offset.zero : const Offset(-0.2, 0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _isDataLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: _buildInfoItem(
              icon: _getTypeIcon(widget.exercise.type),
              text: _getTypeDisplayName(widget.exercise.type),
              color: _getTypeColor(widget.exercise.type, theme),
              theme: theme,
            ),
          ),
        ),
        
        // TUT solo se disponibile e valido
        if (hasValidTut) ...[
          _buildSeparator(theme),
          Expanded(
            child: AnimatedSlide(
              offset: _isDataLoaded ? Offset.zero : const Offset(-0.2, 0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _isDataLoaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: _buildInfoItem(
                        icon: AppIcons.timer,
                        text: _formatTut(tut!),
                        color: theme.colorScheme.primary,
                        theme: theme,
                        isHighlighted: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 3.14159,
                          child: Icon(
                            _showTutSelector
                              ? AppIcons.close
                              : (widget.onTutChanged != null
                                  ? AppIcons.expandMore
                                  : AppIcons.info),
                            size: 14,
                            color: _isPressed || _showTutSelector
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildShimmer(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Row(
          children: [
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: value * 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: value * 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: value * 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
      onEnd: () {
        // Loop the animation
        if (mounted && !_isDataLoaded) {
          setState(() {});
        }
      },
    );
  }
  
  Widget _buildInfoItem({
    required IconData? icon,
    required String text,
    required Color color,
    required ThemeData theme,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 14,
            color: color.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          fontSize: 10,
        ),
      ),
    );
  }
  
  String _formatTut(String tut) {
    if (tut == 'ISO') return 'ISO';
    if (tut == 'EXP') return 'EXP';
    // Mantieni il formato completo, gli zeri indicano esplosività
    return tut;
  }
  
  String _getCategoryDisplayName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Chest';
      case ExerciseCategory.shoulders:
        return 'Shoulders';
      case ExerciseCategory.back:
        return 'Back';
      case ExerciseCategory.arms:
        return 'Arms';
      case ExerciseCategory.legs:
        return 'Legs';
      case ExerciseCategory.abs:
        return 'Core';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.other:
        return 'Other';
    }
  }
  
  String _getTypeDisplayName(ExerciseType type) {
    switch (type) {
      case ExerciseType.single:
        return 'S';  // Single Set
      case ExerciseType.superset:
        return 'SS';  // SuperSet
      case ExerciseType.dropset:
        return 'DS';  // DropSet
      case ExerciseType.restPause:
        return 'RP';  // Rest-Pause
    }
  }
  
  IconData? _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return AppIcons.workout;
      case ExerciseCategory.shoulders:
        return AppIcons.accessibility;
      case ExerciseCategory.back:
        return AppIcons.sportsGymnastics;
      case ExerciseCategory.arms:
        return AppIcons.sportsMma;
      case ExerciseCategory.legs:
        return AppIcons.cardio;
      case ExerciseCategory.abs:
        return AppIcons.flexibility;
      case ExerciseCategory.cardio:
        return AppIcons.favorite;
      case ExerciseCategory.other:
        return AppIcons.workout;
    }
  }
  
  IconData? _getTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.single:
        return null; // Nessuna icona per standard
      case ExerciseType.superset:
        return AppIcons.link;
      case ExerciseType.dropset:
        return AppIcons.trendDown;
      case ExerciseType.restPause:
        return AppIcons.pause;
    }
  }
  
  Color _getTypeColor(ExerciseType type, ThemeData theme) {
    switch (type) {
      case ExerciseType.single:
        return theme.colorScheme.onSurfaceVariant;
      case ExerciseType.superset:
        return theme.colorScheme.secondary;
      case ExerciseType.dropset:
        return theme.colorScheme.tertiary;
      case ExerciseType.restPause:
        return theme.colorScheme.error;
    }
  }

  void _showTutInfoDialog(BuildContext context, String tutValue) {
    showTutInfoBottomSheet(context, tutValue);
  }
}
