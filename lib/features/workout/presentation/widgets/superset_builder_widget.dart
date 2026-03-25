import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_target_muscle_map.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_round_config_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Tier-1 UX widget for creating supersets with professional fitness app design
class SupersetBuilderWidget extends ConsumerStatefulWidget {
  const SupersetBuilderWidget({super.key, required this.onSupersetCreated});
  final Function(SupersetConfiguration) onSupersetCreated;

  @override
  ConsumerState<SupersetBuilderWidget> createState() =>
      _SupersetBuilderWidgetState();
}

class _SupersetBuilderWidgetState extends ConsumerState<SupersetBuilderWidget>
    with TickerProviderStateMixin {
  final List<ExerciseDB.Exercise> _selectedExercises = [];
  SupersetConfiguration? _configuration;

  // ✅ NEW: Info card collapsed state
  bool _isInfoCardExpanded = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // ✅ Auto-collapse info card after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isInfoCardExpanded) {
        setState(() => _isInfoCardExpanded = false);
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
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card with superset explanation
            _buildInfoCard(theme, l10n),
            const SizedBox(height: 20),

            // Exercise selection section
            _buildExerciseSection(theme, l10n),
            const SizedBox(height: 20),

            // Configuration section (opens ConfigSheet modal)
            if (_selectedExercises.length >= 2) ...[
              _buildConfigurationSection(theme, l10n),
              const SizedBox(height: 20),
            ],

            // Create superset button
            if (_selectedExercises.length >= 2 && _configuration != null)
              _buildCreateButton(theme, l10n),
          ],
        ),
      ),
    );
  }

  /// ✅ NEW: Collapsible info card - auto-collapses after 3s, tap to expand/collapse
  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        setState(() => _isInfoCardExpanded = !_isInfoCardExpanded);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.all(_isInfoCardExpanded ? 16 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_isInfoCardExpanded ? 16 : 12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: EdgeInsets.all(_isInfoCardExpanded ? 8 : 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.link,
                color: theme.colorScheme.primary,
                size: _isInfoCardExpanded ? 24 : 18,
              ),
            ),
            SizedBox(width: _isInfoCardExpanded ? 16 : 10),

            // Content
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                crossFadeState: _isInfoCardExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                // Expanded state
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supersetTraining,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.supersetDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Collapsed state - just title
                secondChild: Text(
                  l10n.supersetTraining,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Expand/collapse indicator
            AnimatedRotation(
              duration: const Duration(milliseconds: 400),
              turns: _isInfoCardExpanded ? 0.5 : 0,
              child: Icon(
                AppIcons.keyboardArrowDown,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectedExercises,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Selected exercises list
        if (_selectedExercises.isNotEmpty) ...[
          ...List.generate(_selectedExercises.length, (index) {
            final exercise = _selectedExercises[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildExerciseCard(exercise, index, theme),
            );
          }),
          const SizedBox(height: 8),
        ],

        // Add exercise button
        _buildAddExerciseButton(theme, l10n),

        if (_selectedExercises.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.addAtLeastTwoExercises,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(
    ExerciseDB.Exercise exercise,
    int index,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          exercise.nome,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: _buildExerciseSummary(theme, exercise),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              _selectedExercises.removeAt(index);
            });
            HapticFeedback.lightImpact();
          },
          icon: Icon(AppIcons.close, color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildExerciseSummary(ThemeData theme, ExerciseDB.Exercise exercise) {
    final hasMuscleData =
        exercise.focus.isNotEmpty || exercise.muscoliSecondari.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMuscleData)
            ExerciseTargetMuscleMap(
              primaryMuscles: exercise.focus,
              secondaryMuscles: exercise.muscoliSecondari,
              previewWidth: 78,
              previewHeight: 58,
              enableFullscreen: false,
            ),
          if (hasMuscleData && exercise.attrezzatura.isNotEmpty)
            const SizedBox(height: 6),
          if (exercise.attrezzatura.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EquipmentIconBadge(
                    equipment: exercise.attrezzatura,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(exercise.attrezzatura, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: InkWell(
        onTap: _openExerciseSelection,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.addCircleOutline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.addExercise,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Configuration section with compact ConfigSheet
  Widget _buildConfigurationSection(ThemeData theme, AppLocalizations l10n) {
    final hasConfiguration = _configuration != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.roundsConfiguration,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (hasConfiguration) ...[
          // Show configuration summary
          _buildConfigurationSummary(theme, l10n),
          const SizedBox(height: 12),
        ],

        // Configure/Edit button
        Card(
          child: InkWell(
            onTap: _openConfigSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasConfiguration ? AppIcons.edit : AppIcons.settings,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasConfiguration
                        ? l10n.editConfiguration
                        : l10n.configureRounds,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Summary card showing current configuration
  Widget _buildConfigurationSummary(ThemeData theme, AppLocalizations l10n) {
    final config = _configuration!;

    return Card(
      color: context.colors.success.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.checkCircle,
                  color: context.colors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.configured,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${config.rounds.length} ${config.rounds.length == 1 ? l10n.round : l10n.rounds} • '
              '${config.exercises.length} ${l10n.exercises} • '
              '${config.restAfterRound}s ${l10n.rest}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme, AppLocalizations l10n) {
    final isValid = _configuration?.isValid ?? false;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isValid ? () => _createSuperset(_configuration!) : null,
        icon: const SemanticIcon(
          icon: AppIcons.workout,
          semanticLabel: 'Workout',
        ),
        label: Text(l10n.createSuperset),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openExerciseSelection() async {
    final result = await Navigator.of(context).push<List<ExerciseDB.Exercise>>(
      MaterialPageRoute(
        builder: (context) => const ExerciseSearchScreen(multiSelectMode: true),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        // Add new exercises, avoiding duplicates
        for (final exercise in result) {
          if (!_selectedExercises.any((e) => e.id == exercise.id)) {
            _selectedExercises.add(exercise);
          }
        }
        // Reset configuration when exercises change
        _configuration = null;
      });
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _openConfigSheet() async {
    final result = await SupersetRoundConfigSheet.show(
      context: context,
      exercises: _selectedExercises,
      initialConfiguration: _configuration,
    );

    if (result != null && mounted) {
      setState(() {
        _configuration = result;
      });
      unawaited(HapticFeedback.mediumImpact());

      // ✅ NEW: Auto-create superset immediately after configuration
      // No need to scroll and click "Crea Superset" anymore!
      if (result.isValid) {
        // Small delay for better UX feedback
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _createSuperset(result);
        }
      }
    }
  }

  void _createSuperset(SupersetConfiguration config) {
    HapticFeedback.mediumImpact();
    widget.onSupersetCreated(config);
  }
}
