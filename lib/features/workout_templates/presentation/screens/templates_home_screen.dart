/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Firebase: Through providers
/// - Hive: None
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_import_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_card.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/template_quota_indicator.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/exercise_selection_dialog.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/services/exercise_matching_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/utils/import_error_mapper.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/import_progress_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class TemplatesHomeScreen extends ConsumerStatefulWidget {
  const TemplatesHomeScreen({super.key});

  @override
  ConsumerState<TemplatesHomeScreen> createState() => _TemplatesHomeScreenState();
}

class _TemplatesHomeScreenState extends ConsumerState<TemplatesHomeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true; // State for view mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Add listener to rebuild UI when tab changes, to show/hide the view toggle button
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                l10n.workoutTemplates,
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
                    // Decorative pattern
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
                            label: l10n.myTemplates,
                            colorScheme: colorScheme,
                          ),
                          _buildStat(
                            icon: Icons.public,
                            value: '${templateState.publicTemplates.length}',
                            label: l10n.discover,
                            colorScheme: colorScheme,
                          ),
                          _buildStat(
                            icon: Icons.star,
                            value: '4.8',
                            label: l10n.avgRating,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Show view toggle button only on "My Templates" tab
              if (_tabController.index == 0)
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  tooltip: _isGridView ? l10n.listView : l10n.gridView,
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.secondary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person),
                  text: l10n.myTemplates,
                ),
                Tab(
                  icon: const Icon(Icons.explore),
                  text: l10n.discover,
                ),
                Tab(
                  icon: const Icon(Icons.trending_up),
                  text: l10n.trending,
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
              label: Text(l10n.newTemplate),
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
    final l10n = AppLocalizations.of(context);
    final templateState = ref.watch(templateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (templateState.isLoading) {
      return const Center(child: LoadingIndicator());
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

          // Templates content (Grid or List)
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
                      l10n.noTemplatesYet,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createFirstTemplate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _createNewTemplate(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createTemplate),
                    ),
                  ],
                ),
              ),
            )
          else
            _isGridView
                ? _buildMyTemplatesGrid(templateState.userTemplates, context)
                : _buildMyTemplatesList(templateState.userTemplates, context),
        ],
      ),
    );
  }

  Widget _buildMyTemplatesGrid(List<WorkoutTemplate> templates, BuildContext context) {
    return SliverPadding(
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
            final template = templates[index];
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
          childCount: templates.length,
        ),
      ),
    );
  }

  Widget _buildMyTemplatesList(List<WorkoutTemplate> templates, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    Icons.fitness_center, // Default icon - TemplateCategory.icon doesn't exist
                    size: 20,
                  ),
                ),
                title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  template.description != null && template.description!.isNotEmpty
                      ? template.description!
                      : l10n.noDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _editTemplate(context, template);
                    if (value == 'delete') _deleteTemplate(context, template);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(leading: const Icon(Icons.edit), title: Text(l10n.edit)),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(leading: const Icon(Icons.delete), title: Text(l10n.delete)),
                    ),
                  ],
                ),
                onTap: () => _openTemplate(context, template),
              ),
            );
          },
          childCount: templates.length,
        ),
      ),
    );
  }
  
  Widget _buildDiscoverTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  hintText: l10n.searchTemplates,
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
            SliverFillRemaining(
              child: Center(
                child: Text(l10n.noPublicTemplatesFound),
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
    final l10n = AppLocalizations.of(context);
    // Templates più popolari
    return Center(
      child: Text(l10n.trendingComingSoon),
    );
  }
  
  void _createNewTemplate(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final availablePrivate = ref.read(templateProvider.notifier)
        .getAvailableTemplateCount(TemplateVisibility.private);
    
    if (availablePrivate <= 0) {
      SnackBarService.showCustom(
        context,
        message: l10n.maxTemplatesReached,
        actionLabel: l10n.upgrade,
        onAction: () {
          // TODO: Navigate to premium screen
        },
      );
      return;
    }
    
    // Show options dialog
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.createTemplate,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.primary),
              title: Text(l10n.createManually),
              subtitle: Text(l10n.buildFromScratch),
              onTap: () {
                Navigator.pop(context);
                context.push('/templates/create');
              },
            ),
            // TODO: TEMPORARILY DISABLED - JSON import feature
            // Waiting for finalization of import policy and UI/UX review
            // Uncomment when ready to enable: import from JSON and file picker features
            /* const Divider(),
            ListTile(
              leading: Icon(Icons.upload_file, color: colorScheme.secondary),
              title: Text(l10n.importFromJSON),
              subtitle: Text(l10n.importJSONDescription),
              onTap: () {
                Navigator.pop(context);
                _showJsonImportDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.file_upload, color: colorScheme.tertiary),
              title: Text(l10n.importFromFile),
              subtitle: Text(l10n.importFileDescription),
              onTap: () {
                Navigator.pop(context);
                _showFilePickerImportDialog(context);
              },
            ), */
          ],
        ),
      ),
    );
  }
  
  void _openTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/${template.id}');
  }
  
  void _editTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/${template.id}/edit');
  }
  
  Future<void> _deleteTemplate(BuildContext context, WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate(template.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // TODO: Implement delete
      SnackBarService.showSuccess(
        context,
        '✅ ${l10n.templateDeleted}',
      );
    }
  }
  
  void _shareTemplate(BuildContext context, WorkoutTemplate template) {
    final l10n = AppLocalizations.of(context);
    // TODO: Implement share
    HapticFeedback.mediumImpact();
    SnackBarService.showSuccess(
      context,
      '🔗 ${l10n.shareLinkCopied}',
    );
  }
  
  void _viewPublicTemplate(BuildContext context, WorkoutTemplate template) {
    context.push('/templates/public/${template.id}');
  }
  
  Future<void> _downloadTemplate(BuildContext context, WorkoutTemplate template) async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    
    final success = await ref.read(templateProvider.notifier)
        .downloadTemplate(template.id);
    
    if (success) {
      SnackBarService.showSuccess(
        context,
        '✅ ${l10n.templateDownloaded(template.name)}',
      );
    } else {
      SnackBarService.showError(
        context,
        l10n.failedToDownload,
      );
    }
  }
  
  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const TemplateFiltersSheet(),
    );
  }

  void _showJsonImportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final jsonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.importFromJSON),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pasteWorkoutJSON,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              
              // Show JSON format example
              ExpansionTile(
                title: Text(
                  l10n.viewJSONFormat,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _getJsonFormatExample(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: Icon(
                            Icons.copy,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          tooltip: l10n.copyExample,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _getJsonFormatExample()));
                            SnackBarService.showSuccess(
                              context,
                              '📋 ${l10n.exampleCopied}',
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: jsonController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: l10n.pasteJSONHere,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final jsonText = jsonController.text.trim();
              if (jsonText.isEmpty) {
                SnackBarService.showWarning(
                  context,
                  l10n.pleaseProvideJSON,
                );
                return;
              }

              Navigator.pop(dialogContext);
              await _importFromJson(context, jsonText);
            },
            child: Text(l10n.import),
          ),
        ],
      ),
    );
  }

  String _getJsonFormatExample() {
    return '''{
  "name": "Push Day - Chest, Shoulders, Triceps",
  "description": "Upper body push workout",
  "exercises": [
    {
      "name": "Bench Press",
      "sets": [
        {"reps": 5, "weight": 80},
        {"reps": 5, "weight": 82.5},
        {"reps": 5, "weight": 85}
      ],
      "rest_seconds": 180
    },
    {
      "name": "Overhead Press",
      "sets": [
        {"reps": 8, "weight": 50},
        {"reps": 8, "weight": 50},
        {"reps": 8, "weight": 50}
      ],
      "rest_seconds": 120
    },
    {
      "name": "Dumbbell Flyes",
      "sets": [
        {"reps": 12, "weight": 15},
        {"reps": 12, "weight": 15},
        {"reps": 12, "weight": 15}
      ],
      "rest_seconds": 90
    }
  ]
}''';
  }

  Future<void> _importFromJson(BuildContext context, String jsonText) async {
    final l10n = AppLocalizations.of(context);

    // Show progress dialog
    showImportProgressDialog(
      context: context,
      currentPhase: l10n.importing,
      currentStep: '',
    );

    try {
      // Parse JSON
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      // Validate required fields
      if (!json.containsKey('name') || !json.containsKey('exercises')) {
        // Close progress dialog
        if (context.mounted) Navigator.of(context).pop();
        throw Exception('Invalid JSON format. Required fields: name, exercises');
      }

      // Create exercises from JSON with intelligent matching
      final exercisesJson = json['exercises'] as List;
      final exercises = <Exercise>[];
      
      for (int i = 0; i < exercisesJson.length; i++) {
        final exerciseJson = exercisesJson[i] as Map<String, dynamic>;
        
        // Validate exercise fields
        if (!exerciseJson.containsKey('name') || !exerciseJson.containsKey('sets')) {
          throw Exception('Invalid exercise at index $i. Required fields: name, sets');
        }
        
        final exerciseName = exerciseJson['name'] as String;
        
        // Try to find exact match first
        final exactMatch = await ExerciseMatchingService.instance.findExactMatch(exerciseName);
        
        String finalExerciseName = exerciseName;
        ExerciseCategory finalCategory = ExerciseCategory.other;
        
        if (exactMatch != null) {
          // Use exact match
          finalExerciseName = exactMatch.nome;
          finalCategory = _mapFocusToCategory(exactMatch.focus);
        } else {
          // Find suggested matches
          final matches = await ExerciseMatchingService.instance.findMatches(exerciseName);
          
          if (matches.isNotEmpty) {
            // Show selection dialog
            final selectedExercise = await _showExerciseSelectionDialog(
              context,
              exerciseName,
              matches,
            );
            
            if (selectedExercise != null) {
              finalExerciseName = selectedExercise['name'] as String;
              finalCategory = _mapFocusToCategory(selectedExercise['focus'] as String);
            }
            // If user skipped or cancelled, use original name with default category
          }
        }
        
        // Create sets from JSON
        final setsJson = exerciseJson['sets'] as List;
        final sets = <ExerciseSet>[];
        
        for (int j = 0; j < setsJson.length; j++) {
          final setJson = setsJson[j] as Map<String, dynamic>;
          
          // Validate set fields
          if (!setJson.containsKey('reps')) {
            throw Exception('Invalid set at exercise $i, set $j. Required field: reps');
          }
          
          final set = ExerciseSet(
            setNumber: j + 1,
            reps: setJson['reps'] as int,
            weight: setJson['weight']?.toDouble(),
          );
          
          sets.add(set);
        }
        
        // Create exercise
        final exercise = Exercise(
          name: finalExerciseName,
          type: ExerciseType.single,
          category: finalCategory,
          sets: sets,
          restTime: exerciseJson['rest_seconds'] as int?,
          notes: exerciseJson['notes'] as String?,
        );
        
        exercises.add(exercise);
      }
      
      // Create workout template
      final template = WorkoutTemplate(
        id: const Uuid().v4(),
        userId: 'local_user', // For local templates
        name: json['name'] as String,
        description: json['description'] as String?,
        exercises: exercises,
        category: TemplateCategory.custom,
        visibility: TemplateVisibility.private,
        createdAt: DateTime.now(),
      );
      
      // Save template using provider
      final templateId = await ref.read(templateProvider.notifier).createTemplate(template);

      if (templateId != null) {
        // Close loading dialog and show success
        if (context.mounted) {
          Navigator.of(context).pop(); // Close progress dialog

          // Show completion dialog
          await showImportProgressDialog(
            context: context,
            isCompleted: true,
            totalTemplates: 1,
            processedTemplates: 1,
          );

          SnackBarService.showSuccess(
            context,
            '✅ ${l10n.templateImportedSuccessfully(template.name)}',
          );
        }
      } else {
        throw Exception('Failed to save template');
      }
    } catch (e) {
      // Close progress dialog if open
      if (context.mounted) Navigator.of(context).pop();

      // Map technical error to user-friendly message
      final userMessage = ImportErrorMapper.mapToUserMessage(e, l10n);

      SnackBarService.showError(
        context,
        userMessage,
      );

      // Optional: Show suggestions if error is recoverable
      if (ImportErrorMapper.isRecoverable(e)) {
        final suggestions = ImportErrorMapper.getSuggestions(e, l10n);
        if (suggestions.isNotEmpty) {
          // Could show suggestions in a dialog or additional snackbar
          // For now, just log them for future implementation
          if (kDebugMode) {
            debugPrint('Import suggestions: ${suggestions.join(", ")}');
          }
        }
      }
    }
  }

  /// Import JSON using the provider-based approach (NEW - Priority Fix #5)
  Future<void> _importFromJsonWithProvider(BuildContext context, String jsonText) async {
    final l10n = AppLocalizations.of(context);

    // Reset provider state
    ref.read(templateImportProvider.notifier).reset();

    // Show progress dialog that listens to provider state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _buildImportProgressListener(dialogContext),
    );

    try {
      // Start import process via provider
      await ref.read(templateImportProvider.notifier).importFromJson(jsonText);

      // Check final state
      final importState = ref.read(templateImportProvider);

      if (importState.errors.any((e) => e.isBlocking == true)) {
        // Import failed with blocking errors
        if (context.mounted) Navigator.of(context).pop(); // Close progress dialog

        final errorMessage = ImportErrorMapper.mapToUserMessage(
          Exception(importState.errors.first.message),
          l10n,
        );

        SnackBarService.showError(context, errorMessage);
        return;
      }

      // Check if disambiguation needed
      if (importState.exerciseDisambiguations.isNotEmpty) {
        // Close progress dialog
        if (context.mounted) Navigator.of(context).pop();

        // Show disambiguation dialogs
        await _handleExerciseDisambiguations(context, importState.exerciseDisambiguations);

        // After disambiguation, continue with percentage conversion
        await ref.read(templateImportProvider.notifier).resolveExerciseDisambiguations();
      }

      // Check if percentage conversion needed
      if (importState.percentageConversions.isNotEmpty) {
        // Close progress dialog if still open
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        // Show percentage conversion UI (not implemented yet)
        // For now, skip this step
        await ref.read(templateImportProvider.notifier).finalizeImport();
      }

      // Finalize and save templates
      final success = await ref.read(templateImportProvider.notifier).finalizeImport();

      if (success) {
        // Close progress dialog
        if (context.mounted) Navigator.of(context).pop();

        // Save templates to repository
        for (final template in importState.finalTemplates) {
          // Convert and save each template
          // This would use the template provider to save
          if (kDebugMode) {
            debugPrint('✅ Template imported: ${template.name}');
          }
        }

        // Show success message
        if (context.mounted) {
          await showImportProgressDialog(
            context: context,
            isCompleted: true,
            totalTemplates: importState.finalTemplates.length,
            processedTemplates: importState.finalTemplates.length,
          );

          SnackBarService.showSuccess(
            context,
            l10n.templatesImportedSuccessfully(importState.finalTemplates.length),
          );
        }
      } else {
        // Import failed
        if (context.mounted) Navigator.of(context).pop();

        SnackBarService.showError(
          context,
          l10n.importFailed,
        );
      }
    } catch (e) {
      // Close progress dialog
      if (context.mounted) Navigator.of(context).pop();

      final userMessage = ImportErrorMapper.mapToUserMessage(e, l10n);
      SnackBarService.showError(context, userMessage);
    }
  }

  /// Build progress dialog that listens to import provider state
  Widget _buildImportProgressListener(BuildContext dialogContext) {
    return Consumer(
      builder: (context, ref, child) {
        final importState = ref.watch(templateImportProvider);

        return ImportProgressDialog(
          progress: importState.progress,
          currentPhase: _mapPhaseToString(importState.currentPhase, context),
          currentStep: importState.currentStep ?? '',
          isCompleted: importState.currentPhase == ImportPhase.completed,
        );
      },
    );
  }

  /// Map import phase to localized string
  String _mapPhaseToString(ImportPhase? phase, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (phase) {
      case ImportPhase.parsing:
        return l10n.parsing;
      case ImportPhase.exerciseMatching:
        return l10n.matchingExercises;
      case ImportPhase.percentageConversion:
        return l10n.convertingWeights;
      case ImportPhase.finalizing:
        return l10n.finalizing;
      case ImportPhase.completed:
        return l10n.completed;
      default:
        return l10n.importing;
    }
  }

  /// Handle exercise disambiguations
  Future<void> _handleExerciseDisambiguations(
    BuildContext context,
    List<ExerciseDisambiguation> disambiguations,
  ) async {
    for (final disambiguation in disambiguations) {
      // Show selection dialog for each disambiguation
      final selected = await _showExerciseSelectionDialog(
        context,
        disambiguation.originalName,
        disambiguation.options,
      );

      if (selected != null) {
        // Find the index of the selected option
        final selectedIndex = disambiguation.options.indexWhere(
          (opt) => opt.exercise.id == selected['id'],
        );

        if (selectedIndex >= 0) {
          ref.read(templateImportProvider.notifier).updateExerciseDisambiguation(
            disambiguation.exerciseId,
            selectedIndex,
          );
        }
      }
    }
  }

  /// Show file picker and import JSON from selected file
  Future<void> _showFilePickerImportDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Show file picker for JSON files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: false, // Don't load bytes, we'll read the file ourselves
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker
        return;
      }

      final file = result.files.first;

      // Check if we have a path (required for reading file)
      if (file.path == null) {
        SnackBarService.showError(
          context,
          l10n.errorFileAccess,
        );
        return;
      }

      // Show loading indicator while reading file
      if (!context.mounted) return;

      // Read file content
      final content = await _readFileFromPath(file.path!);

      // Import the JSON content
      if (!context.mounted) return;
      await _importFromJson(context, content);

    } catch (e) {
      if (!context.mounted) return;

      // Map technical error to user-friendly message
      final userMessage = ImportErrorMapper.mapToUserMessage(e, l10n);

      SnackBarService.showError(
        context,
        userMessage,
      );

      // Show suggestions if error is recoverable
      if (ImportErrorMapper.isRecoverable(e)) {
        final suggestions = ImportErrorMapper.getSuggestions(e, l10n);
        if (suggestions.isNotEmpty && kDebugMode) {
          debugPrint('File import suggestions: ${suggestions.join(", ")}');
        }
      }
    }
  }

  /// Read file content from file path
  Future<String> _readFileFromPath(String filePath) async {
    try {
      final file = await File(filePath).readAsString();

      if (file.trim().isEmpty) {
        throw Exception('File is empty');
      }

      return file;
    } catch (e) {
      rethrow;
    }
  }

  // Show exercise selection dialog for ambiguous matches
  Future<Map<String, dynamic>?> _showExerciseSelectionDialog(
    BuildContext context,
    String originalExerciseName,
    List<ExerciseMatch> matches,
  ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ExerciseSelectionDialog(
          originalExerciseName: originalExerciseName,
          suggestedMatches: matches,
          onExerciseSelected: (exerciseId, exerciseName) {
            // Find the selected exercise details
            final selectedMatch = matches.firstWhere(
              (match) => match.exercise.id == exerciseId,
            );
            
            Navigator.of(context).pop({
              'id': exerciseId,
              'name': exerciseName,
              'focus': selectedMatch.exercise.focus,
            });
          },
          onSkipExercise: () {
            Navigator.of(context).pop(null); // Skip this exercise
          },
          onCreateNew: () {
            // TODO: Implement create new exercise functionality
            Navigator.of(context).pop({
              'id': 'custom',
              'name': originalExerciseName,
              'focus': 'OTHER',
            });
          },
        );
      },
    );
  }

  // Map muscle focus from database to ExerciseCategory
  ExerciseCategory _mapFocusToCategory(String focus) {
    // Split focus string by comma to create a list (handles both single and multi-muscle)
    final focusList = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // Use centralized converter for consistent category mapping
    return ExerciseConverter.mapFocusToCategory(focusList);
  }
}

// Placeholder widgets (da implementare)
class TemplateFiltersSheet extends StatelessWidget {
  const TemplateFiltersSheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(l10n.filtersComingSoon),
    );
  }
}

class PublicTemplateCard extends StatelessWidget {
  
  const PublicTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDownload,
  });
  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                          l10n.byAuthor(template.authorName ?? l10n.anonymous),
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
                  const Icon(Icons.star, size: 16, color: Colors.amber),
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
                    l10n.exercisesCount(template.exercises.length),
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