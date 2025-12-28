/// Template Assignment Sheet
///
/// Bottom sheet modal for assigning a template to athletes.
/// Shows list of athletes with checkboxes for selection.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Bottom sheet for assigning templates to athletes
class TemplateAssignmentSheet extends ConsumerStatefulWidget {
  const TemplateAssignmentSheet({
    required this.template,
    super.key,
  });

  final CoachTemplate template;

  @override
  ConsumerState<TemplateAssignmentSheet> createState() =>
      _TemplateAssignmentSheetState();
}

class _TemplateAssignmentSheetState
    extends ConsumerState<TemplateAssignmentSheet> {
  late Set<String> _selectedAthleteIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select currently assigned athletes
    _selectedAthleteIds = widget.template.assignedTo.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final athletesAsync = ref.watch(athletesListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.assignTemplateToAthletes(widget.template.name),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          AppIcons.infoOutlined,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            context.l10n.changesWillSync,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection counter
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.peopleOutline,
                      size: 20,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.athletesSelected(_selectedAthleteIds.length),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedAthleteIds.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedAthleteIds.clear();
                          });
                        },
                        child: Text(context.l10n.clearAll),
                      ),
                  ],
                ),
              ),
              const Divider(),

              // Athletes list
              Expanded(
                child: athletesAsync.when(
                  data: (athletes) => _buildAthletesList(
                    athletes,
                    scrollController,
                  ),
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (error, _) => Center(
                    child: Text('${context.l10n.error}: $error'),
                  ),
                ),
              ),

              // Action buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _confirmAssignment,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: LoadingIndicator(),
                                )
                              : Text(context.l10n.confirmAssignment),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAthletesList(
    List<CoachRelationship> athletes,
    ScrollController scrollController,
  ) {
    if (athletes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.peopleOutline,
              size: 48,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.noAthletesYet,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.addYourFirstAthlete,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: athletes.length,
      itemBuilder: (context, index) {
        final athlete = athletes[index];
        final isSelected = _selectedAthleteIds.contains(athlete.athleteId);
        final wasOriginallyAssigned =
            widget.template.assignedTo.contains(athlete.athleteId);

        return _AthleteSelectionTile(
          athlete: athlete,
          isSelected: isSelected,
          wasOriginallyAssigned: wasOriginallyAssigned,
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedAthleteIds.add(athlete.athleteId);
              } else {
                _selectedAthleteIds.remove(athlete.athleteId);
              }
            });
          },
        );
      },
    );
  }

  Future<void> _confirmAssignment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final actions = ref.read(coachTemplateActionsProvider.notifier);
      await actions.updateAssignments(
        templateId: widget.template.id,
        athleteIds: _selectedAthleteIds.toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, context.l10n.templateAssigned);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, '${context.l10n.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Individual athlete selection tile
class _AthleteSelectionTile extends StatelessWidget {
  const _AthleteSelectionTile({
    required this.athlete,
    required this.isSelected,
    required this.wasOriginallyAssigned,
    required this.onChanged,
  });

  final CoachRelationship athlete;
  final bool isSelected;
  final bool wasOriginallyAssigned;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: onChanged,
      title: Text(
        athlete.athleteName ?? athlete.athleteId,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: wasOriginallyAssigned && isSelected
          ? Text(
              context.l10n.alreadyAssigned,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
              ),
            )
          : null,
      secondary: CircleAvatar(
        backgroundColor: context.colors.primaryContainer,
        child: Text(
          _getInitials(athlete.athleteName ?? 'A'),
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
