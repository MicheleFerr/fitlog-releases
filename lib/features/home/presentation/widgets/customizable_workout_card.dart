import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class CustomizableWorkoutCard extends ConsumerStatefulWidget {
  const CustomizableWorkoutCard({super.key});

  @override
  ConsumerState<CustomizableWorkoutCard> createState() => _CustomizableWorkoutCardState();
}

class _CustomizableWorkoutCardState extends ConsumerState<CustomizableWorkoutCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isLongPress = false;
  bool _hasSeenHint = false;

  @override
  void initState() {
    super.initState();
    // print('🎯 CustomizableWorkoutCard inizializzato!');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Avvia animazione pulse per suggerire il long press
    if (!_hasSeenHint) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _animationController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    // print('🔥 Long press rilevato!');
    setState(() {
      _isLongPress = true;
      _hasSeenHint = true;
    });

    // Ferma animazione hint
    _animationController.stop();
    _animationController.reset();

    // Feedback aptico
    HapticFeedback.mediumImpact();

    // Mostra menu opzioni
    _showCustomizationMenu();
  }

  void _showCustomizationMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CustomizationMenu(
        onTemplateSelected: (template) {
          Navigator.pop(context);
          _savePreferredTemplate(template);
        },
      ),
    );
  }

  void _savePreferredTemplate(WorkoutTemplate? template) {
    ref.read(appConfigProvider.notifier).setPreferredTemplateId(template?.id);
    
    // Mostra feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          template != null
              ? AppLocalizations.of(context).preferredTemplateSet
              : AppLocalizations.of(context).preferredTemplateRemoved,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _startWorkout() async {
    final preferredTemplateId = ref.read(preferredTemplateIdProvider);
    
    if (preferredTemplateId != null) {
      // Carica il template preferito
      final templatesAsync = await ref.read(allWorkoutTemplatesProvider.future);
      final template = templatesAsync.firstWhere(
        (t) => t.id == preferredTemplateId,
        orElse: () => templatesAsync.first,
      );
      
      // Avvia allenamento con template
      ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);
      if (!context.mounted) return;
      context.goNamed('workout');
    } else {
      // Vai alla schermata workout vuota
      context.goNamed('workout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferredTemplateId = ref.watch(preferredTemplateIdProvider);
    final templatesAsync = ref.watch(allWorkoutTemplatesProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLongPress ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!_hasSeenHint)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3 * _pulseAnimation.value),
                    blurRadius: 20 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
              ],
            ),
            child: Card(
              elevation: 4,
              child: InkWell(
                onTap: _startWorkout,
                onLongPress: _handleLongPress,
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).newWorkout,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          templatesAsync.when(
                            data: (templates) {
                              if (preferredTemplateId != null) {
                                final template = templates.firstWhere(
                                  (t) => t.id == preferredTemplateId,
                                  orElse: () => templates.first,
                                );
                                return Column(
                                  children: [
                                    Text(
                                      template.name,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context).tapToStart,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }
                              return Text(
                                AppLocalizations.of(context).startFresh,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    // Indicatore personalizzazione
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedOpacity(
                        opacity: !_hasSeenHint ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.touch_app,
                            color: context.colors.surface,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    // Badge template preferito
                    if (preferredTemplateId != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: context.colors.surface,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomizationMenu extends ConsumerWidget {
  const _CustomizationMenu({
    required this.onTemplateSelected,
  });

  final Function(WorkoutTemplate?) onTemplateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allWorkoutTemplatesProvider);
    final currentPreferredId = ref.watch(preferredTemplateIdProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).choosePreferredTemplate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          if (currentPreferredId != null)
            ListTile(
              leading: const Icon(Icons.clear),
              title: Text(AppLocalizations.of(context).removePreferredTemplate),
              subtitle: Text(AppLocalizations.of(context).startWithEmptyWorkout),
              onTap: () => onTemplateSelected(null),
            ),
          const SizedBox(height: 8),
          Flexible(
            child: templatesAsync.when(
              data: (templates) => ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isSelected = template.id == currentPreferredId;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        _getIconForTemplate(template),
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      template.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${template.exercises.length} ${AppLocalizations.of(context).exercises}',
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => onTemplateSelected(template),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text(AppLocalizations.of(context).errorLoadingTemplates),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getIconForTemplate(WorkoutTemplate template) {
    final nameLower = template.name.toLowerCase();
    
    if (nameLower.contains('push') || nameLower.contains('petto') || nameLower.contains('chest')) {
      return Icons.fitness_center;
    }
    if (nameLower.contains('pull') || nameLower.contains('dorso') || nameLower.contains('back')) {
      return Icons.sports_gymnastics;
    }
    if (nameLower.contains('leg') || nameLower.contains('gamb')) {
      return Icons.directions_run;
    }
    if (nameLower.contains('cardio')) {
      return Icons.favorite;
    }
    if (nameLower.contains('full') || nameLower.contains('total')) {
      return Icons.accessibility_new;
    }
    
    return Icons.fitness_center;
  }
}