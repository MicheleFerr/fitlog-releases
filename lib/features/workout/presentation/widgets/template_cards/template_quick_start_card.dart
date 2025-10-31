/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class TemplateQuickStartCard extends StatelessWidget {

  const TemplateQuickStartCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final wt.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: template.isCustom ? () => _showContextMenu(context) : null,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildTemplateIcon(context),
              const SizedBox(width: 16),
              Expanded(child: _buildTemplateInfo(context)),
              _buildArrowIcon(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: template.isCustom 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        template.isCustom ? Icons.person : Icons.star,
        color: template.isCustom 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        size: 24,
      ),
    );
  }

  Widget _buildTemplateInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          template.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          template.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _buildTemplateStats(context),
      ],
    );
  }

  Widget _buildTemplateStats(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          Icons.fitness_center,
          '${template.exercises.length}',
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          context,
          Icons.schedule,
          '${template.estimatedDuration}min',
        ),
        if (template.usageCount > 0) ...[
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            Icons.trending_up,
            '${template.usageCount}',
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIcon(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      size: 16,
    );
  }

  void _showContextMenu(BuildContext context) {
    // Haptic feedback per il long press
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContextMenuSheet(context),
    );
  }

  Widget _buildContextMenuSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          const SizedBox(height: 16),
          _buildSheetHeader(context),
          const SizedBox(height: 20),
          _buildMenuOption(
            context,
            icon: Icons.play_arrow,
            title: AppLocalizations.of(context).startWorkout,
            subtitle: AppLocalizations.of(context).startWorkoutNow,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.of(context).pop();
              onTap();
            },
          ),
          if (onEdit != null)
            _buildMenuOption(
              context,
              icon: Icons.edit,
              title: AppLocalizations.of(context).editTemplate,
              subtitle: AppLocalizations.of(context).editTemplateDescription,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                Navigator.of(context).pop();
                onEdit!();
              },
            ),
          if (onDelete != null)
            _buildMenuOption(
              context,
              icon: Icons.delete,
              title: AppLocalizations.of(context).deleteTemplate,
              subtitle: AppLocalizations.of(context).deleteTemplatePermanently,
              color: Theme.of(context).colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                onDelete!();
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          template.isCustom ? Icons.person : Icons.star,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            template.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}