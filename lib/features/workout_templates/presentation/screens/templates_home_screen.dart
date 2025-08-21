/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout_templates
 * 🔧 Type: screen
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: ConsumerWidget
 * - Firebase: Through providers
 * - Hive: None
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/workout_template.dart';
import '../providers/template_provider.dart';
import '../widgets/template_card.dart';
import '../widgets/template_quota_indicator.dart';

class TemplatesHomeScreen extends ConsumerStatefulWidget {
  const TemplatesHomeScreen({super.key});

  @override
  ConsumerState<TemplatesHomeScreen> createState() => _TemplatesHomeScreenState();
}

class _TemplatesHomeScreenState extends ConsumerState<TemplatesHomeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final templateState = ref.watch(templateProvider);
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Workout Templates',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern decorativo
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Stats
                    Positioned(
                      left: 16,
                      bottom: 60,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            icon: Icons.folder_outlined,
                            value: '${templateState.userTemplates.length}',
                            label: 'My Templates',
                            colorScheme: colorScheme,
                          ),
                          _buildStat(
                            icon: Icons.public,
                            value: '${templateState.publicTemplates.length}',
                            label: 'Discover',
                            colorScheme: colorScheme,
                          ),
                          _buildStat(
                            icon: Icons.star,
                            value: '4.8',
                            label: 'Avg Rating',
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.secondary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person),
                  text: 'My Templates',
                ),
                Tab(
                  icon: const Icon(Icons.explore),
                  text: 'Discover',
                ),
                Tab(
                  icon: const Icon(Icons.trending_up),
                  text: 'Trending',
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyTemplatesTab(context),
            _buildDiscoverTab(context),
            _buildTrendingTab(context),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _createNewTemplate(context),
              icon: const Icon(Icons.add),
              label: const Text('New Template'),
              backgroundColor: colorScheme.primary,
            )
          : null,
    );
  }
  
  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.onPrimary.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMyTemplatesTab(BuildContext context) {
    final templateState = ref.watch(templateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (templateState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(templateProvider.notifier).loadUserTemplates(),
      child: CustomScrollView(
        slivers: [
          // Quota indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TemplateQuotaIndicator(
                usedPrivate: templateState.userTemplates
                    .where((t) => t.visibility == TemplateVisibility.private)
                    .length,
                usedPublic: templateState.userTemplates
                    .where((t) => t.visibility == TemplateVisibility.public)
                    .length,
                maxPrivate: TemplateQuota.maxPrivateTemplates,
                maxPublic: TemplateQuota.maxPublicTemplates,
              ),
            ),
          ),
          
          // Templates grid
          if (templateState.userTemplates.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No templates yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first workout template',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _createNewTemplate(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Template'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = templateState.userTemplates[index];
                    return TemplateCard(
                      template: template,
                      onTap: () => _openTemplate(context, template),
                      onEdit: () => _editTemplate(context, template),
                      onDelete: () => _deleteTemplate(context, template),
                      onShare: template.visibility == TemplateVisibility.public
                          ? () => _shareTemplate(context, template)
                          : null,
                    );
                  },
                  childCount: templateState.userTemplates.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDiscoverTab(BuildContext context) {
    final templateState = ref.watch(templateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return RefreshIndicator(
      onRefresh: () => ref.read(templateProvider.notifier).loadPublicTemplates(),
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => _showFilters(context),
                  ),
                ),
                onSubmitted: (query) {
                  ref.read(templateProvider.notifier).loadPublicTemplates(
                    searchQuery: query,
                  );
                },
              ),
            ),
          ),
          
          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: TemplateCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name.toUpperCase()),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(templateProvider.notifier).loadPublicTemplates(
                            category: category,
                          );
                        } else {
                          ref.read(templateProvider.notifier).loadPublicTemplates();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // Public templates
          if (templateState.publicTemplates.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No public templates found'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = templateState.publicTemplates[index];
                    return PublicTemplateCard(
                      template: template,
                      onTap: () => _viewPublicTemplate(context, template),
                      onDownload: () => _downloadTemplate(context, template),
                    );
                  },
                  childCount: templateState.publicTemplates.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTrendingTab(BuildContext context) {
    // Templates più popolari
    return const Center(
      child: Text('Trending templates coming soon!'),
    );
  }
  
  void _createNewTemplate(BuildContext context) {
    final availablePrivate = ref.read(templateProvider.notifier)
        .getAvailableTemplateCount(TemplateVisibility.private);
    
    if (availablePrivate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have reached the maximum number of templates'),
          action: SnackBarAction(
            label: 'Upgrade',
            onPressed: () {
              // TODO: Navigate to premium screen
            },
          ),
        ),
      );
      return;
    }
    
    context.push('/templates/create');
  }
  
  void _openTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/${template.id}');
  }
  
  void _editTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/${template.id}/edit');
  }
  
  Future<void> _deleteTemplate(BuildContext context, WorkoutTemplate template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // TODO: Implement delete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template deleted')),
      );
    }
  }
  
  void _shareTemplate(BuildContext context, WorkoutTemplate template) {
    // TODO: Implement share
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share link copied to clipboard!')),
    );
  }
  
  void _viewPublicTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/public/${template.id}');
  }
  
  Future<void> _downloadTemplate(BuildContext context, WorkoutTemplate template) async {
    HapticFeedback.mediumImpact();
    
    final success = await ref.read(templateProvider.notifier)
        .downloadTemplate(template.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "${template.name}" downloaded!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download template'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const TemplateFiltersSheet(),
    );
  }
}

// Placeholder widgets (da implementare)
class TemplateFiltersSheet extends StatelessWidget {
  const TemplateFiltersSheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Filters coming soon'),
    );
  }
}

class PublicTemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  
  const PublicTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDownload,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: template.authorPhotoUrl != null
                        ? NetworkImage(template.authorPhotoUrl!)
                        : null,
                    child: template.authorPhotoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'by ${template.authorName ?? "Anonymous"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
              if (template.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  template.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    template.averageRating.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${template.reviewCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.download, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${template.downloadCount}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.fitness_center, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${template.exercises.length} exercises',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}