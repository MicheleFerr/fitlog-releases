/// 🔧 TEMPORARY DEBUG WIDGET - Remove after fixing template sync issues
///
/// Shows all templates in Firebase (including ghost templates) and allows deletion.
/// Use this to diagnose and fix the quota discrepancy issue.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Shows a dialog with all Firebase templates for debugging
void showTemplateDebugDialog(BuildContext context) {
  ModalService.showSheet(context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const TemplateDebugSheet(),
  );
}

class TemplateDebugSheet extends ConsumerStatefulWidget {
  const TemplateDebugSheet({super.key});

  @override
  ConsumerState<TemplateDebugSheet> createState() => _TemplateDebugSheetState();
}

class _TemplateDebugSheetState extends ConsumerState<TemplateDebugSheet> {
  @override
  void initState() {
    super.initState();
    // Run diagnostics when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(templateDiagnosticNotifierProvider.notifier).runDiagnostics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateDiagnosticNotifierProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Template Debug',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(templateDiagnosticNotifierProvider.notifier)
                            .invalidateCacheAndRefresh();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Force Refresh',
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: LoadingIndicator())
                    : state.error != null
                        ? Center(
                            child: Text(
                              'Errore: ${state.error}',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          )
                        : _buildContent(context, state, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TemplateDiagnosticState state,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    final info = state.diagnosticInfo;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Diagnostic Info Card
        if (info != null)
          Card(
            color: info.hasGhostTemplates
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostica',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow('User ID', info.userId),
                  _infoRow('Cache', '${info.cacheCount} templates'),
                  _infoRow('Firebase', '${info.firebaseCount} templates'),
                  _infoRow('Cache Age', '${info.cacheAgeMinutes} min'),
                  if (info.hasGhostTemplates)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${info.discrepancy} template fantasma su Firebase!',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Templates List
        Text(
          'Template su Firebase (${state.firebaseTemplates.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        if (state.firebaseTemplates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Nessun template trovato'),
          )
        else
          ...state.firebaseTemplates.map((template) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(template['name'] as String? ?? 'Senza nome'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${template['id']}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Esercizi: ${template['exerciseCount']} | '
                      'Pubblico: ${template['isPublic']}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () => _confirmDelete(context, template),
                  icon: Icon(
                    Icons.delete,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Elimina',
                ),
              ),
            );
          }),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Map<String, dynamic> template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Template'),
        content: Text(
          'Vuoi eliminare definitivamente "${template['name']}"?\n\n'
          'Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(templateDiagnosticNotifierProvider.notifier)
          .deleteTemplate(template['id'] as String);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Template eliminato'
                  : 'Errore durante l\'eliminazione',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
