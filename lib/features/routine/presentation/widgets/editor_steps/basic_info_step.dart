/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/editor_steps
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// BASIC INFO STEP - Step 1 of routine creation wizard
///
/// Collects:
/// - Routine name
/// - Description (optional)
/// - Routine type (weekly, monthly, etc.)
/// - Start and end dates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_editor_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 1: Basic information form
class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = ref.read(routineEditorProvider);
    _nameController.text = state.name;
    _descriptionController.text = state.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routineEditorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              context.l10n.routineBasicInfoTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.routineBasicInfoSubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Routine name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.routineNameLabel,
                hintText: context.l10n.routineNameHint,
                prefixIcon: const Icon(AppIcons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor:
                    context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.routineNameRequired;
                }
                if (value.length < 3) {
                  return context.l10n.routineNameMinLength;
                }
                return null;
              },
              onChanged: (value) {
                ref.read(routineEditorProvider.notifier).updateBasicInfo(
                      name: value,
                    );
              },
            ),

            const SizedBox(height: 20),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.routineDescriptionLabel,
                hintText: context.l10n.routineDescriptionHint,
                prefixIcon: const Icon(AppIcons.template),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor:
                    context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              maxLines: 3,
              onChanged: (value) {
                ref.read(routineEditorProvider.notifier).updateBasicInfo(
                      description: value.isEmpty ? null : value,
                    );
              },
            ),

            const SizedBox(height: 24),

            // Routine type
            Text(
              context.l10n.routineTypeLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeSelector(context, state.type),

            const SizedBox(height: 24),

            // Date range
            Text(
              context.l10n.routineDurationLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    label: context.l10n.routineStartDateLabel,
                    date: state.startDate,
                    onTap: () => _selectStartDate(context, state.startDate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    label: context.l10n.routineEndDateLabel,
                    date: state.endDate,
                    onTap: () => _selectEndDate(
                      context,
                      state.endDate,
                      state.startDate,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Duration info chip
            _buildDurationInfo(context, state.startDate, state.endDate),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, RoutineType selectedType) {
    final types = [
      (RoutineType.weekly, AppIcons.calendarViewWeek, context.l10n.routineTypeWeekly, context.l10n.routineTypeWeeklyDuration),
      (RoutineType.monthly, Icons.calendar_month, context.l10n.routineTypeMonthly, context.l10n.routineTypeMonthlyDuration),
      (RoutineType.bimonthly, AppIcons.dateRange, context.l10n.routineTypeBimonthly, context.l10n.routineTypeBimonthlyDuration),
      (RoutineType.semester, AppIcons.eventNote, context.l10n.routineTypeSemester, context.l10n.routineTypeSemesterDuration),
      (RoutineType.custom, AppIcons.tune, context.l10n.routineTypeCustom, context.l10n.routineTypeCustomDuration),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((typeData) {
        final type = typeData.$1;
        final icon = typeData.$2;
        final label = typeData.$3;
        final subtitle = typeData.$4;
        final isSelected = selectedType == type;

        return InkWell(
          onTap: () {
            // Calcola automaticamente la data di fine basata sul tipo
            final state = ref.read(routineEditorProvider);
            final startDate = state.startDate;
            DateTime endDate;

            switch (type) {
              case RoutineType.weekly:
                endDate = startDate.add(const Duration(days: 7));
                break;
              case RoutineType.monthly:
                endDate = startDate.add(const Duration(days: 30));
                break;
              case RoutineType.bimonthly:
                endDate = startDate.add(const Duration(days: 60));
                break;
              case RoutineType.semester:
                endDate = DateTime(
                  startDate.year,
                  startDate.month + 6,
                  startDate.day,
                );
                break;
              case RoutineType.custom:
                // Per custom, lascia la data attuale senza modificarla
                endDate = state.endDate;
                break;
            }

            ref.read(routineEditorProvider.notifier).updateBasicInfo(
                  type: type,
                  endDate: endDate,
                );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (context.screenWidth - 48) / 2, // 2 columns
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primaryContainer
                  : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onSurface.withValues(alpha: 0.7),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        AppIcons.complete,
                        color: context.colors.primary,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: 20,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo(
    BuildContext context,
    DateTime start,
    DateTime end,
  ) {
    final days = end.difference(start).inDays + 1;
    final weeks = (days / 7).floor();
    final remainingDays = days % 7;

    String durationText;
    if (weeks > 0) {
      final weeksText = context.l10n.routineDurationWeeks(weeks);
      if (remainingDays > 0) {
        final daysText = context.l10n.routineDurationDays(remainingDays);
        durationText = '$weeksText and $daysText';
      } else {
        durationText = weeksText;
      }
    } else {
      durationText = context.l10n.routineDurationDays(days);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.routineDurationInfo(durationText),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectStartDate(BuildContext context, DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      final state = ref.read(routineEditorProvider);
      DateTime? newEndDate;

      // Ricalcola la data di fine solo se non è custom
      if (state.type != RoutineType.custom) {
        switch (state.type) {
          case RoutineType.weekly:
            newEndDate = picked.add(const Duration(days: 7));
            break;
          case RoutineType.monthly:
            newEndDate = picked.add(const Duration(days: 30));
            break;
          case RoutineType.bimonthly:
            newEndDate = picked.add(const Duration(days: 60));
            break;
          case RoutineType.semester:
            newEndDate = DateTime(
              picked.year,
              picked.month + 6,
              picked.day,
            );
            break;
          case RoutineType.custom:
            // Non ricalcolare per custom
            break;
        }
      }

      ref.read(routineEditorProvider.notifier).updateBasicInfo(
            startDate: picked,
            endDate: newEndDate,
          );
    }
  }

  Future<void> _selectEndDate(
    BuildContext context,
    DateTime initial,
    DateTime minDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(minDate) ? initial : minDate.add(const Duration(days: 7)),
      firstDate: minDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      ref.read(routineEditorProvider.notifier).updateBasicInfo(
            endDate: picked,
          );
    }
  }
}
