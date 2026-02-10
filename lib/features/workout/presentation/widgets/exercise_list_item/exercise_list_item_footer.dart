import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/tut_decoder_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Collapsible footer for Exercise Card
///
/// Displays configurable elements (Tips, TUT, Notes) in a compact chip row
/// that can be expanded to show full content.
///
/// Part of Exercise Card redesign to reduce information overload:
/// - Tips, TUT, Notes moved here from header
/// - Collapsed by default (configurable)
/// - 250ms smooth expand/collapse animation
///
/// Persona Impact:
/// - Marco (Beginner): ✅ Essential tips visible, not overwhelming
/// - Chiara (Multitask): ✅ Hidden by default, quick access when needed
/// - Luca (Powerlifter): ✅ All info available on demand
/// - Sofia (Aesthetic): ✅ Clean card, details tucked away
/// - Roberto (Busy): ✅ No clutter, expand only when needed
class ExerciseListItemFooter extends ConsumerStatefulWidget {
  const ExerciseListItemFooter({
    super.key,
    required this.exercise,
    this.formCues,
    this.onEditNotes,
    this.onShowTutExplanationModal,
    this.onShowTipsBottomSheet,
  });

  final Exercise exercise;
  final String? formCues;
  final VoidCallback? onEditNotes;
  final VoidCallback? onShowTutExplanationModal;
  final VoidCallback? onShowTipsBottomSheet;

  @override
  ConsumerState<ExerciseListItemFooter> createState() =>
      _ExerciseListItemFooterState();
}

class _ExerciseListItemFooterState
    extends ConsumerState<ExerciseListItemFooter> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Initialize from settings - note: we use read here for initial value
    _isExpanded = ref.read(exerciseFooterExpandedProvider);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final footerElements = ref.watch(exerciseFooterElementsProvider);

    // Don't render if no elements configured
    if (footerElements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter to elements that should be shown
    // ALL elements are ALWAYS shown if configured - allows adding new content
    final activeElements = footerElements.where((element) {
      switch (element) {
        case ExerciseFooterElement.notes:
          return true; // Always show - allows adding new notes
        case ExerciseFooterElement.tips:
          return true; // Always show Tips (opens Info/Warmup/Prevention)
        case ExerciseFooterElement.tut:
          return true; // Always show TUT (with default if not set)
      }
    }).toList();

    // Don't render if no elements configured to show
    if (activeElements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(
          height: 1,
          thickness: 1,
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),

        // Collapsed view: chip row + expand button
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Chips for each active element
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: activeElements.map((element) {
                      return _FooterChip(
                        element: element,
                        exercise: widget.exercise,
                        formCues: widget.formCues,
                        onTap: () => _handleChipTap(element),
                      );
                    }).toList(),
                  ),
                ),
                // Expand/collapse icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    AppIcons.expandMore,
                    size: AppIconSize.small,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded content
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? _FooterExpandedContent(
                  exercise: widget.exercise,
                  formCues: widget.formCues,
                  activeElements: activeElements,
                  onEditNotes: widget.onEditNotes,
                  onShowTutExplanationModal: widget.onShowTutExplanationModal,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _handleChipTap(ExerciseFooterElement element) {
    switch (element) {
      case ExerciseFooterElement.notes:
        widget.onEditNotes?.call();
        break;
      case ExerciseFooterElement.tips:
        // Open Tips bottom sheet (Info/Warmup/Prevention)
        widget.onShowTipsBottomSheet?.call();
        break;
      case ExerciseFooterElement.tut:
        widget.onShowTutExplanationModal?.call();
        break;
    }
  }
}

/// Individual chip in the footer
class _FooterChip extends StatelessWidget {
  const _FooterChip({
    required this.element,
    required this.exercise,
    this.formCues,
    this.onTap,
  });

  final ExerciseFooterElement element;
  final Exercise exercise;
  final String? formCues;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _getIconAndLabel(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.tiny,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String) _getIconAndLabel(BuildContext context) {
    switch (element) {
      case ExerciseFooterElement.tips:
        return (AppIcons.lightbulb, context.l10n.tips);
      case ExerciseFooterElement.tut:
        // Always show TUT value (use default 2-0-2-0 if not set)
        final tut = exercise.tut;
        final tutValue = tut != null && tut.isNotEmpty ? tut : '2-0-2-0';
        final tutLabel = TutDecoderService.decodeShort(tutValue);
        return (AppIcons.timer, tutLabel);
      case ExerciseFooterElement.notes:
        // Show "Notes" or "Add Note" based on whether notes exist
        final hasNotes = exercise.notes?.isNotEmpty ?? false;
        return (
          AppIcons.notes,
          hasNotes ? context.l10n.notes : context.l10n.addNote,
        );
    }
  }
}

/// Expanded content section
class _FooterExpandedContent extends StatelessWidget {
  const _FooterExpandedContent({
    required this.exercise,
    required this.activeElements,
    this.formCues,
    this.onEditNotes,
    this.onShowTutExplanationModal,
  });

  final Exercise exercise;
  final List<ExerciseFooterElement> activeElements;
  final String? formCues;
  final VoidCallback? onEditNotes;
  final VoidCallback? onShowTutExplanationModal;

  @override
  Widget build(BuildContext context) {
    final hasNotes = exercise.notes?.isNotEmpty ?? false;
    final hasTut = exercise.tut?.isNotEmpty ?? false;
    final hasTips = formCues?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tips section - show content if available
          if (activeElements.contains(ExerciseFooterElement.tips) &&
              hasTips) ...[
            _buildSection(
              context,
              icon: AppIcons.lightbulb,
              title: context.l10n.tips,
              content: formCues!,
            ),
            const SizedBox(height: 8),
          ],

          // TUT section - always show with default if not set
          if (activeElements.contains(ExerciseFooterElement.tut)) ...[
            _buildTutSection(context, hasTut: hasTut),
            const SizedBox(height: 8),
          ],

          // Notes section - always show, with placeholder if empty
          if (activeElements.contains(ExerciseFooterElement.notes)) ...[
            _buildNotesSection(context, hasNotes: hasNotes),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, {required bool hasNotes}) {
    return InkWell(
      onTap: onEditNotes,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasNotes
                ? context.colors.outlineVariant.withValues(alpha: 0.3)
                : context.colors.primary.withValues(alpha: 0.3),
            style: hasNotes ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.notes,
              size: AppIconSize.small,
              color: hasNotes
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasNotes
                    ? exercise.notes!
                    : context.l10n.tapToAddNotes,
                style: context.textTheme.bodySmall?.copyWith(
                  color: hasNotes
                      ? context.colors.onSurface
                      : context.colors.onSurfaceVariant,
                  fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: hasNotes ? null : 1,
              ),
            ),
            Icon(
              hasNotes ? AppIcons.edit : AppIcons.add,
              size: AppIconSize.tiny,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(
                    AppIcons.edit,
                    size: AppIconSize.tiny,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutSection(BuildContext context, {required bool hasTut}) {
    // Use actual TUT or default 2-0-2-0
    final tutValue = hasTut ? exercise.tut! : '2-0-2-0';
    final tutDecoded = TutDecoderService.decodeComplete(tutValue);
    if (tutDecoded == null) return const SizedBox.shrink();

    return InkWell(
      onTap: onShowTutExplanationModal,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.timer,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.tutTitle,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  AppIcons.info,
                  size: AppIconSize.tiny,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TutPhase(
                  label: context.l10n.tutEccentricPhase,
                  seconds: tutDecoded.phases.isNotEmpty
                      ? tutDecoded.phases[0].seconds
                      : 0,
                ),
                _TutPhase(
                  label: context.l10n.tutBottomPausePhase,
                  seconds: tutDecoded.phases.length > 1
                      ? tutDecoded.phases[1].seconds
                      : 0,
                ),
                _TutPhase(
                  label: context.l10n.tutConcentricPhase,
                  seconds: tutDecoded.phases.length > 2
                      ? tutDecoded.phases[2].seconds
                      : 0,
                ),
                _TutPhase(
                  label: context.l10n.tutTopPausePhase,
                  seconds: tutDecoded.phases.length > 3
                      ? tutDecoded.phases[3].seconds
                      : 0,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${tutDecoded.code} = ${tutDecoded.totalSeconds}s',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual TUT phase display
class _TutPhase extends StatelessWidget {
  const _TutPhase({
    required this.label,
    required this.seconds,
  });

  final String label;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${seconds}s',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
