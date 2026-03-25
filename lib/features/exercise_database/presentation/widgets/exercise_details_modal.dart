import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_target_muscle_map.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_info_dialog.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/warmup_suggestion_chips.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';

class ExerciseDetailsModal extends StatefulWidget {
  const ExerciseDetailsModal({
    super.key,
    required this.exercise,
    this.currentExerciseIndex,
    this.onWarmupExerciseAdded,
  });

  final ExerciseDefinition exercise;
  final int? currentExerciseIndex;
  final void Function(WarmupSuggestion suggestion, int beforeIndex)?
  onWarmupExerciseAdded;

  static Future<void> show(
    BuildContext context,
    ExerciseDefinition exercise, {
    int? currentExerciseIndex,
    void Function(WarmupSuggestion, int)? onWarmupExerciseAdded,
  }) {
    return ModalService.showSheet(
      context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => ExerciseDetailsModal(
        exercise: exercise,
        currentExerciseIndex: currentExerciseIndex,
        onWarmupExerciseAdded: onWarmupExerciseAdded,
      ),
    );
  }

  @override
  State<ExerciseDetailsModal> createState() => _ExerciseDetailsModalState();
}

class _ExerciseDetailsModalState extends State<ExerciseDetailsModal> {
  final Set<String> _addedExerciseIds = {};

  @override
  Widget build(BuildContext context) {
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: safeMax,
      minChildSize: 0.5,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            _buildHandleBar(context),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    if (_hasTechnicalNotes()) ...[
                      _buildTechnicalNotesSection(context),
                      const SizedBox(height: 20),
                    ],
                    if (_hasWarmupProtocol()) ...[
                      _buildWarmupSection(context),
                      const SizedBox(height: 20),
                    ],
                    if (_hasInjuryPreventionDetails())
                      _buildInjuryPreventionSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      width: 56,
      height: 5,
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasMuscleData =
        widget.exercise.focus.isNotEmpty ||
        widget.exercise.muscoliSecondari.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.exercise.nome,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colors.onSurface,
            letterSpacing: -0.8,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 18),
        _buildSectionCard(
          context,
          padding: const EdgeInsets.all(20),
          child: hasMuscleData
              ? _buildUnifiedOverviewCard(context)
              : _buildFallbackOverviewCard(context),
        ),
      ],
    );
  }

  Widget _buildUnifiedOverviewCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionEyebrow(context, 'Muscoli Coinvolti'),
        const SizedBox(height: 8),
        Text(
          _buildMuscleSummary(),
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.1),
              ),
            ),
            child: ExerciseTargetMuscleMap(
              primaryMuscles: widget.exercise.focus,
              secondaryMuscles: widget.exercise.muscoliSecondari,
              previewWidth: 164,
              previewHeight: 136,
            ),
          ),
        ),
        if (widget.exercise.muscoliSecondari.isNotEmpty) ...[
          const SizedBox(height: 18),
          _buildSectionEyebrow(context, context.l10n.secondaryMuscles),
          const SizedBox(height: 6),
          Text(
            widget.exercise.muscoliSecondari.join(', '),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.45,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 20),
        _buildOverviewFacts(context),
      ],
    );
  }

  Widget _buildFallbackOverviewCard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _buildFactCard(
            context,
            icon: AppIcons.workout,
            label: 'Muscoli Coinvolti',
            content: Text(
              widget.exercise.focusDisplayName,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          _buildEquipmentFactCard(context),
          _buildDifficultyFactCard(context),
        ];

        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildOverviewFacts(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              _buildEquipmentFactCard(context),
              const SizedBox(height: 12),
              _buildDifficultyFactCard(context),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildEquipmentFactCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildDifficultyFactCard(context)),
          ],
        );
      },
    );
  }

  Widget _buildEquipmentFactCard(BuildContext context) {
    return _buildFactCard(
      context,
      icon: AppIcons.sportsGymnastics,
      label: context.l10n.equipment,
      content: Row(
        children: [
          EquipmentIconBadge(equipment: widget.exercise.attrezzatura, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.exercise.attrezzatura,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFactCard(BuildContext context) {
    final color = _getDifficultyColor(context);

    return _buildFactCard(
      context,
      icon: AppIcons.barChart,
      label: context.l10n.difficulty,
      accentColor: color,
      content: Text(
        widget.exercise.difficolta,
        style: context.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
      ),
    );
  }

  Widget _buildFactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget content,
    Color? accentColor,
  }) {
    final resolvedAccent = accentColor ?? context.colors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: resolvedAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: resolvedAccent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            context.colors.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? accentColor,
    Widget? trailing,
  }) {
    final resolvedAccent = accentColor ?? context.colors.primary;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: resolvedAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: resolvedAccent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colors.onSurface,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildSectionEyebrow(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  String _buildMuscleSummary() {
    if (widget.exercise.focus.isEmpty) {
      return widget.exercise.focusDisplayName;
    }

    return widget.exercise.focus.join(', ');
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (widget.exercise.difficolta.toLowerCase()) {
      case 'principiante':
        return context.colors.success;
      case 'intermedio':
        return context.colors.secondary;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.onSurface;
    }
  }

  Widget _buildTechnicalNotesSection(BuildContext context) {
    return _buildSectionCard(
      context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            icon: AppIcons.tip,
            title: context.l10n.technicalNotes,
          ),
          const SizedBox(height: 20),
          ..._buildFormattedSteps(context, widget.exercise.noteTecniche!),
        ],
      ),
    );
  }

  Widget _buildWarmupSection(BuildContext context) {
    return _buildSectionCard(
      context,
      padding: const EdgeInsets.all(20),
      backgroundColor: context.colors.secondaryContainer.withValues(
        alpha: 0.18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            icon: AppIcons.wbSunnyOutlined,
            title: context.l10n.warmupProtocol,
            accentColor: context.colors.secondary,
            trailing: IconButton(
              onPressed: () => WarmupInfoDialog.show(context),
              icon: Icon(
                AppIcons.info,
                color: context.colors.secondary,
                size: 20,
              ),
              tooltip: context.l10n.warmupPhaseInfo,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.exercise.warmupSuggestions?.isNotEmpty == true &&
              widget.onWarmupExerciseAdded != null) ...[
            WarmupSuggestionChips(
              suggestions: widget.exercise.warmupSuggestions!,
              addedExerciseIds: _addedExerciseIds,
              onAdd: _handleAddWarmupExercise,
            ),
            const SizedBox(height: 18),
          ],
          if (widget.exercise.mobilitaPre != null) ...[
            _buildDetailCard(
              context,
              icon: '🔄',
              title: context.l10n.warmupPhase1Title.replaceAll('🔄 ', ''),
              content: widget.exercise.mobilitaPre!,
            ),
            const SizedBox(height: 14),
          ],
          if (widget.exercise.attivazionePre != null)
            _buildDetailCard(
              context,
              icon: '⚡',
              title: context.l10n.warmupPhase2Title.replaceAll('⚡ ', ''),
              content: widget.exercise.attivazionePre!,
            ),
          if (_hasText(widget.exercise.warmupSets)) ...[
            const SizedBox(height: 14),
            _buildDetailCard(
              context,
              icon: '🏋️',
              title: context.l10n.exerciseOptionsWarmupSets,
              content: widget.exercise.warmupSets!,
              isMonospace: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInjuryPreventionSection(BuildContext context) {
    return _buildSectionCard(
      context,
      padding: const EdgeInsets.all(20),
      backgroundColor: context.colors.success.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            icon: AppIcons.shieldOutlined,
            title: context.l10n.exerciseOptionsInjuryPreventionTitle,
            accentColor: context.colors.success,
          ),
          if (_hasText(widget.exercise.prevenzioneInfortuni)) ...[
            const SizedBox(height: 20),
            _buildDetailCard(
              context,
              icon: '🛡️',
              title: context.l10n.exerciseOptionsInjuryPreventionSection,
              content: widget.exercise.prevenzioneInfortuni!,
            ),
          ],
          if (_hasText(widget.exercise.cooldownConsigliato)) ...[
            const SizedBox(height: 14),
            _buildDetailCard(
              context,
              icon: '🧘',
              title: context.l10n.exerciseOptionsRecommendedCooldown,
              content: widget.exercise.cooldownConsigliato!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String content,
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: context.textTheme.bodyLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildDetailContent(context, content, isMonospace: isMonospace),
        ],
      ),
    );
  }

  List<Widget> _buildFormattedSteps(BuildContext context, String text) {
    final steps = _splitInstructionText(text);

    if (steps.isEmpty) {
      return [
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ];
    }

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<String> _splitInstructionText(String text) {
    return text
        .split(RegExp(r'\s*\|\s*|\n+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  List<Widget> _buildDetailContent(
    BuildContext context,
    String text, {
    required bool isMonospace,
  }) {
    final parts = _splitInstructionText(text);

    if (parts.length <= 1) {
      return [
        Text(
          text.replaceAll('|', ' ').trim(),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.8),
            fontFamily: isMonospace ? 'monospace' : null,
            height: 1.4,
          ),
          softWrap: true,
        ),
      ];
    }

    return parts.asMap().entries.map((entry) {
      final isLast = entry.key == parts.length - 1;

      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.8),
                  fontFamily: isMonospace ? 'monospace' : null,
                  height: 1.4,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  bool _hasTechnicalNotes() {
    return _hasText(widget.exercise.noteTecniche);
  }

  bool _hasWarmupProtocol() {
    return _hasText(widget.exercise.mobilitaPre) ||
        _hasText(widget.exercise.attivazionePre) ||
        _hasText(widget.exercise.warmupSets);
  }

  bool _hasInjuryPreventionDetails() {
    return _hasText(widget.exercise.prevenzioneInfortuni) ||
        _hasText(widget.exercise.cooldownConsigliato);
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  void _handleAddWarmupExercise(WarmupSuggestion suggestion) {
    if (widget.currentExerciseIndex == null ||
        widget.onWarmupExerciseAdded == null) {
      return;
    }

    setState(() {
      _addedExerciseIds.add(suggestion.exerciseId);
    });

    widget.onWarmupExerciseAdded!(suggestion, widget.currentExerciseIndex!);

    SnackBarService.showSuccess(
      context,
      context.l10n.warmupExerciseAddedBefore(
        suggestion.exerciseName,
        widget.exercise.nome,
      ),
    );
  }
}
