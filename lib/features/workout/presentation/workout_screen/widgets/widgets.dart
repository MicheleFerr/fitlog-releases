/// Workout screen widgets
///
/// This barrel file exports all widgets used in the workout screen.
/// These widgets have been extracted from the monolithic WorkoutScreen
/// to improve maintainability and testability.
///
/// ## Widgets:
/// - [QuickStartList] - Tabbed list of custom and predefined templates
/// - [TemplateGrid] - Grid/list view of templates with empty states
/// - [TemplateGridCard] - Individual template card in grid layout
/// - [FallbackTemplates] - Hardcoded fallback templates for offline use
library;

export 'fallback_templates.dart';
export 'quick_start_list.dart';
export 'template_grid.dart';
export 'template_grid_card.dart';
