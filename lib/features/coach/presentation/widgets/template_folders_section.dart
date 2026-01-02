/// Template Folders Section Widget
///
/// Manages template folder organization for coaches.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_folder.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/template_folders_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Section for managing template folders
class TemplateFoldersSection extends ConsumerWidget {
  const TemplateFoldersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(templateFoldersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add folder button
            OutlinedButton.icon(
              onPressed: () => _showCreateFolderDialog(context, ref),
              icon: const Icon(AppIcons.createNewFolder),
              label: Text(context.l10n.createFolder),
            ),
            const SizedBox(height: AppSpacing.md),

            // Folders list
            foldersAsync.when(
              data: (folders) => folders.isEmpty
                  ? _buildEmptyState(context)
                  : _buildFoldersList(context, ref, folders),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: LoadingIndicator(),
                ),
              ),
              error: (err, stack) => _buildErrorState(context, err),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            AppIcons.folderOpen,
            size: 48,
            color: context.colors.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.noFolders,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        error.toString(),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.error,
        ),
      ),
    );
  }

  Widget _buildFoldersList(
    BuildContext context,
    WidgetRef ref,
    List<TemplateFolder> folders,
  ) {
    // Sort by depth, then by sortOrder
    final sortedFolders = List<TemplateFolder>.from(folders)
      ..sort((a, b) {
        final depthCompare = a.depth.compareTo(b.depth);
        if (depthCompare != 0) return depthCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedFolders.length,
      onReorder: (oldIndex, newIndex) {
        _reorderFolders(ref, sortedFolders, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final folder = sortedFolders[index];
        return _FolderTile(
          key: ValueKey(folder.id),
          folder: folder,
          onEdit: () => _showEditFolderDialog(context, ref, folder),
          onDelete: () => _deleteFolder(context, ref, folder),
        );
      },
    );
  }

  void _reorderFolders(
    WidgetRef ref,
    List<TemplateFolder> folders,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) newIndex--;
    final folder = folders[oldIndex];
    ref.read(templateFoldersProvider.notifier).updateSortOrder(
          folder.id,
          newIndex,
        );
  }

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    FolderIcon selectedIcon = FolderIcon.folder;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.createFolder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.folderName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Icon selector
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: FolderIcon.values.map((icon) {
                  final isSelected = icon == selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => selectedIcon = icon),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                        ),
                      ),
                      child: Icon(
                        _getFolderIconData(icon),
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.outline,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.create),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      await HapticFeedback.mediumImpact();
      await ref.read(templateFoldersProvider.notifier).createFolder(
            name: nameController.text.trim(),
            icon: selectedIcon,
          );
      if (context.mounted) {
        SnackBarService.showSuccess(context, context.l10n.folderCreated);
      }
    }

    nameController.dispose();
  }

  Future<void> _showEditFolderDialog(
    BuildContext context,
    WidgetRef ref,
    TemplateFolder folder,
  ) async {
    final nameController = TextEditingController(text: folder.name);
    FolderIcon selectedIcon = folder.icon;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.editFolder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.folderName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: FolderIcon.values.map((icon) {
                  final isSelected = icon == selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => selectedIcon = icon),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                        ),
                      ),
                      child: Icon(
                        _getFolderIconData(icon),
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.outline,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      await HapticFeedback.mediumImpact();
      await ref.read(templateFoldersProvider.notifier).updateFolder(
            folder.id,
            name: nameController.text.trim(),
            icon: selectedIcon,
          );
    }

    nameController.dispose();
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    TemplateFolder folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteFolder),
        content: Text(context.l10n.deleteFolderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HapticFeedback.mediumImpact();
      await ref.read(templateFoldersProvider.notifier).deleteFolder(folder.id);
      if (context.mounted) {
        SnackBarService.showInfo(context, context.l10n.folderDeleted);
      }
    }
  }

  IconData _getFolderIconData(FolderIcon icon) {
    return switch (icon) {
      FolderIcon.folder => AppIcons.folder,
      FolderIcon.star => AppIcons.star,
      FolderIcon.fire => AppIcons.localFireDepartment,
      FolderIcon.muscle => AppIcons.fitnessCenter,
      FolderIcon.dumbbell => AppIcons.fitnessCenter,
      FolderIcon.run => AppIcons.directionsRun,
      FolderIcon.heart => AppIcons.favorite,
      FolderIcon.trophy => AppIcons.emojiEvents,
      FolderIcon.calendar => AppIcons.calendarToday,
      FolderIcon.target => AppIcons.gpsFixed,
    };
  }
}

/// Individual folder tile
class _FolderTile extends StatelessWidget {
  const _FolderTile({
    super.key,
    required this.folder,
    required this.onEdit,
    required this.onDelete,
  });

  final TemplateFolder folder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _iconData {
    return switch (folder.icon) {
      FolderIcon.folder => AppIcons.folder,
      FolderIcon.star => AppIcons.star,
      FolderIcon.fire => AppIcons.localFireDepartment,
      FolderIcon.muscle => AppIcons.fitnessCenter,
      FolderIcon.dumbbell => AppIcons.fitnessCenter,
      FolderIcon.run => AppIcons.directionsRun,
      FolderIcon.heart => AppIcons.favorite,
      FolderIcon.trophy => AppIcons.emojiEvents,
      FolderIcon.calendar => AppIcons.calendarToday,
      FolderIcon.target => AppIcons.gpsFixed,
    };
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2196F3); // Fallback to blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _iconData,
        color: folder.color != null
            ? _parseColor(folder.color!)
            : context.colors.primary,
      ),
      title: Text(folder.name),
      subtitle: folder.templateCount > 0
          ? Text('${folder.templateCount} templates')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(AppIcons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(AppIcons.delete, color: context.colors.error),
            onPressed: onDelete,
          ),
          ReorderableDragStartListener(
            index: 0,
            child: Icon(
              AppIcons.dragHandle,
              color: context.colors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
