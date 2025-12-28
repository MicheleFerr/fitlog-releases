/// Coach Templates Screen
///
/// Main screen for managing coach templates with tabs:
/// - My Templates: Templates created by this coach
/// - Assigned: Templates currently assigned to athletes
/// - Library: Future feature for template sharing
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/coach_template_card.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/widgets/template_assignment_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Coach templates management screen
class CoachTemplatesScreen extends ConsumerStatefulWidget {
  const CoachTemplatesScreen({super.key});

  @override
  ConsumerState<CoachTemplatesScreen> createState() =>
      _CoachTemplatesScreenState();
}

class _CoachTemplatesScreenState extends ConsumerState<CoachTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.coachTemplates),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.myCoachTemplates),
            Tab(text: context.l10n.assignedTab),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              _MyTemplatesTab(),
              _AssignedTemplatesTab(),
            ],
          ),
          // DraggableActionButton for consistent FAB style
          DraggableActionButton(
            onPressed: _createNewTemplate,
            icon: AppIcons.add,
            label: context.l10n.newTemplate,
            positionKey: 'coach_templates',
          ),
        ],
      ),
    );
  }

  void _createNewTemplate() {
    context.pushNamed(AppRoutes.coachTemplateEditorName);
  }
}

/// Tab showing templates created by this coach
class _MyTemplatesTab extends ConsumerWidget {
  const _MyTemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(coachTemplatesProvider);

    return templatesAsync.when(
      data: (templates) => templates.isEmpty
          ? _EmptyTemplatesState(
              title: context.l10n.noTemplatesYet,
              subtitle: context.l10n.createFirstTemplate,
              icon: AppIcons.template,
            )
          : _TemplatesList(templates: templates),
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(
        child: Text('${context.l10n.error}: $error'),
      ),
    );
  }
}

/// Tab showing assigned templates with their status
class _AssignedTemplatesTab extends ConsumerWidget {
  const _AssignedTemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(coachTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        // Filter to only templates that have assignments
        final assignedTemplates =
            templates.where((t) => t.hasAssignments).toList();

        if (assignedTemplates.isEmpty) {
          return _EmptyTemplatesState(
            title: context.l10n.noTemplatesYet,
            subtitle: context.l10n.assignTemplate,
            icon: AppIcons.peopleOutline,
          );
        }

        return _TemplatesList(
          templates: assignedTemplates,
          showAssignmentCount: true,
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(
        child: Text('${context.l10n.error}: $error'),
      ),
    );
  }
}

/// List of templates
class _TemplatesList extends StatelessWidget {
  const _TemplatesList({
    required this.templates,
    this.showAssignmentCount = false,
  });

  final List<CoachTemplate> templates;
  final bool showAssignmentCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final template = templates[index];
        return CoachTemplateCard(
          template: template,
          showAssignmentCount: showAssignmentCount,
          onTap: () => _openTemplateDetails(context, template),
          onAssign: () => _showAssignmentSheet(context, template),
        );
      },
    );
  }

  void _openTemplateDetails(BuildContext context, CoachTemplate template) {
    context.pushNamed(
      AppRoutes.coachTemplateEditorName,
      extra: template,
    );
  }

  void _showAssignmentSheet(BuildContext context, CoachTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TemplateAssignmentSheet(template: template),
    );
  }
}

/// Empty state widget
class _EmptyTemplatesState extends StatelessWidget {
  const _EmptyTemplatesState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
