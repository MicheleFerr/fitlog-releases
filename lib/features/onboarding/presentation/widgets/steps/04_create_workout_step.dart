import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class CreateWorkoutStep extends StatefulWidget {

  const CreateWorkoutStep({
    super.key,
    required this.onNext,
  });
  final VoidCallback onNext;

  @override
  State<CreateWorkoutStep> createState() => _CreateWorkoutStepState();
}

class _CreateWorkoutStepState extends State<CreateWorkoutStep> with TickerProviderStateMixin {
  bool _showDemo = false;
  bool _isCompleted = false;
  bool _fabExpanded = false;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _expandFab() {
    setState(() {
      _fabExpanded = true;
    });
  }

  void _selectWorkoutOption(String option) {
    setState(() {
      _fabExpanded = false;
    });

    // Simulate creating workout
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward().then((_) {
        setState(() {
          _isCompleted = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.addCircleOutline,
  semanticLabel: 'Add circle outline',
  size: AppIconSize.medium,
  color: colorScheme.primary,
),
          const SizedBox(height: 32),
          Text(
            l10n.createWorkoutStepTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.createWorkoutStepDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Video Placeholder Section
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
  icon: AppIcons.videoLibraryOutlined,
  semanticLabel: 'Video library outlined',
  size: AppIconSize.medium,
  color: colorScheme.onSurface.withValues(alpha: 0.4,
),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).onboardingVideoPlaceholder,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).onboardingVideoComingSoon,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          if (false) ...[
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Mock FAB Demo
                    if (!_isCompleted) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: colorScheme.surface.withValues(alpha: 0.3),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background hint
                            Center(
                              child: Text(
                                Localizations.localeOf(context).languageCode == 'it'
                                    ? 'Schermata Allenamento'
                                    : 'Workout Screen',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // FAB in bottom right
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: _fabExpanded
                                ? _MockExpandedFab(
                                    colorScheme: colorScheme,
                                    theme: theme,
                                    l10n: l10n,
                                    onSelectOption: _selectWorkoutOption,
                                  )
                                : _MockFab(
                                    colorScheme: colorScheme,
                                    onTap: _expandFab,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Mock Workout Card after selection
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _MockWorkoutCard(
                          colorScheme: colorScheme,
                          theme: theme,
                          l10n: l10n,
                          isCompleted: _isCompleted,
                        ),
                      ),
                    ],
                    if (!_isCompleted && !_fabExpanded) ...[
                      const SizedBox(height: 16),
                      Text(
                        Localizations.localeOf(context).languageCode == 'it'
                            ? 'Tocca il pulsante + per iniziare'
                            : 'Tap the + button to start',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.complete,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.onboardingCompleted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MockFab extends StatelessWidget {

  const _MockFab({
    required this.colorScheme,
    required this.onTap,
  });
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const SemanticIcon(
  icon: AppIcons.add,
  semanticLabel: 'Add',
),
    );
  }
}

class _MockExpandedFab extends StatelessWidget {

  const _MockExpandedFab({
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    required this.onSelectOption,
  });
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final Function(String) onSelectOption;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _FabOption(
          icon: AppIcons.flashOn,
          label: isItalian ? 'Allenamento Rapido' : 'Quick Workout',
          colorScheme: colorScheme,
          theme: theme,
          onTap: () => onSelectOption('quick'),
        ),
        const SizedBox(height: 8),
        _FabOption(
          icon: AppIcons.libraryBooks,
          label: isItalian ? 'Da Template' : 'From Template',
          colorScheme: colorScheme,
          theme: theme,
          onTap: () => onSelectOption('template'),
        ),
        const SizedBox(height: 8),
        _FabOption(
          icon: AppIcons.addCircle,
          label: isItalian ? 'Nuovo Allenamento' : 'New Workout',
          colorScheme: colorScheme,
          theme: theme,
          onTap: () => onSelectOption('new'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {

  const _FabOption({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: onTap,
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            child: Icon(icon, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MockWorkoutCard extends StatelessWidget {

  const _MockWorkoutCard({
    required this.colorScheme,
    required this.theme,
    required this.l10n,
    required this.isCompleted,
  });
  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppLocalizations l10n;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCompleted ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
            color: isCompleted ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.workout,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isItalian ? 'Petto e Tricipiti' : 'Chest & Triceps',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isItalian ? 'Upper Body • Push' : 'Upper Body • Push',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCompleted
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(
                    AppIcons.complete,
                    color: colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: AppIcons.timer,
                  label: '45 min',
                  colorScheme: colorScheme,
                  theme: theme,
                  isCompleted: isCompleted,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: AppIcons.trendUp,
                  label: isItalian ? '4 esercizi' : '4 exercises',
                  colorScheme: colorScheme,
                  theme: theme,
                  isCompleted: isCompleted,
                ),
              ],
            ),
          ],
        ),
      );
  }
}

class _InfoChip extends StatelessWidget {

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.theme,
    required this.isCompleted,
  });
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
          ? colorScheme.primary.withValues(alpha: 0.1)
          : colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isCompleted
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCompleted
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
