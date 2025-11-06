import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_category.dart';

/// Rich metadata system for icon discovery and documentation
///
/// Provides comprehensive metadata for each icon including:
/// - Human-readable descriptions
/// - Suggested use cases
/// - Related/alternative icons
/// - Accessibility label suggestions
/// - Search keywords/tags
/// - Platform-specific notes
///
/// **Usage:**
/// ```dart
/// // Get metadata for an icon
/// final metadata = AppIcons.workout.metadata;
/// print(metadata?.description); // "Exercise and workout tracking"
///
/// // Search icons by keyword
/// final results = AppIconMetadata.search('timer');
///
/// // Get suggested semantic label
/// final label = AppIcons.timer.suggestedSemanticLabel;
/// ```
class IconMetadata {

  const IconMetadata({
    required this.description,
    required this.useCases,
    required this.relatedIcons,
    required this.suggestedSemanticLabel,
    required this.keywords,
    this.platformNotes,
    this.exampleUsage,
  });
  /// Human-readable description of what this icon represents
  final String description;

  /// Suggested use cases and contexts where this icon should be used
  final List<String> useCases;

  /// Related icons that could be alternatives or complements
  final List<IconData> relatedIcons;

  /// Suggested semantic label for accessibility (WCAG 2.1 AA)
  final String suggestedSemanticLabel;

  /// Search keywords/tags for discovery
  final List<String> keywords;

  /// Platform-specific notes (iOS/Android differences)
  final String? platformNotes;

  /// Code example showing typical usage
  final String? exampleUsage;

  /// Check if this metadata matches a search query
  bool matches(String query) {
    final q = query.toLowerCase();
    return description.toLowerCase().contains(q) ||
        keywords.any((k) => k.toLowerCase().contains(q)) ||
        suggestedSemanticLabel.toLowerCase().contains(q);
  }
}

/// Centralized metadata for all AppIcons
///
/// Contains rich metadata for icon discovery, documentation, and accessibility.
/// Metadata is manually curated to ensure accuracy and usefulness.
class AppIconMetadata {
  AppIconMetadata._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WORKOUT ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const workout = IconMetadata(
    description: 'Exercise and workout tracking',
    useCases: [
      'Workout screen navigation',
      'Start workout action',
      'Workout history entries',
    ],
    relatedIcons: [AppIcons.cardio, AppIcons.gymnastics, AppIcons.flexibility],
    suggestedSemanticLabel: 'Workout',
    keywords: ['workout', 'exercise', 'training', 'gym', 'fitness'],
  );

  static const cardio = IconMetadata(
    description: 'Cardio and heart rate tracking',
    useCases: [
      'Cardio exercise filter',
      'Heart rate monitoring',
      'Aerobic workouts',
    ],
    relatedIcons: [AppIcons.workout, AppIcons.speed],
    suggestedSemanticLabel: 'Cardio',
    keywords: ['cardio', 'heart', 'running', 'aerobic', 'endurance'],
  );

  static const timer = IconMetadata(
    description: 'Timer and countdown functionality',
    useCases: [
      'Rest timer between sets',
      'Workout duration tracking',
      'Timer settings',
    ],
    relatedIcons: [AppIcons.timerOff, AppIcons.schedule, AppIcons.clock],
    suggestedSemanticLabel: 'Timer',
    keywords: ['timer', 'countdown', 'rest', 'stopwatch', 'time'],
    platformNotes: 'iOS: Integrates with Live Activities and Dynamic Island',
    exampleUsage: '''
SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: context.l10n.timerLabel,
  size: AppIconSize.large,
)''',
  );

  static const analytics = IconMetadata(
    description: 'Analytics and progress tracking',
    useCases: [
      'Analytics screen navigation',
      'Progress dashboard',
      'Statistics and charts',
    ],
    relatedIcons: [AppIcons.barChart, AppIcons.lineChart, AppIcons.insights],
    suggestedSemanticLabel: 'Analytics',
    keywords: ['analytics', 'stats', 'progress', 'data', 'metrics'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const complete = IconMetadata(
    description: 'Completed action or success state',
    useCases: [
      'Workout completion',
      'Goal achieved',
      'Success message',
    ],
    relatedIcons: [AppIcons.completeOutline, AppIcons.check, AppIcons.allDone],
    suggestedSemanticLabel: 'Completed',
    keywords: ['complete', 'done', 'success', 'finished', 'check'],
    exampleUsage: '''
Icon(
  AppIcons.complete,
  color: context.iconSuccess,
  size: AppIconSize.medium,
)''',
  );

  static const error = IconMetadata(
    description: 'Error state or failed action',
    useCases: [
      'Error messages',
      'Validation failures',
      'Alert dialogs',
    ],
    relatedIcons: [AppIcons.warning, AppIcons.info],
    suggestedSemanticLabel: 'Error',
    keywords: ['error', 'failure', 'problem', 'alert', 'danger'],
  );

  static const warning = IconMetadata(
    description: 'Warning or caution state',
    useCases: [
      'Warning messages',
      'Caution prompts',
      'Review needed',
    ],
    relatedIcons: [AppIcons.error, AppIcons.info],
    suggestedSemanticLabel: 'Warning',
    keywords: ['warning', 'caution', 'attention', 'alert'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ACTION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const add = IconMetadata(
    description: 'Add new item or create action',
    useCases: [
      'Add exercise button',
      'Create workout template',
      'Add new entry',
    ],
    relatedIcons: [AppIcons.addCircleOutline],
    suggestedSemanticLabel: 'Add',
    keywords: ['add', 'create', 'new', 'plus', 'insert'],
  );

  static const edit = IconMetadata(
    description: 'Edit or modify existing item',
    useCases: [
      'Edit workout details',
      'Modify exercise',
      'Change settings',
    ],
    relatedIcons: [AppIcons.save, AppIcons.delete],
    suggestedSemanticLabel: 'Edit',
    keywords: ['edit', 'modify', 'change', 'update', 'pencil'],
  );

  static const delete = IconMetadata(
    description: 'Delete or remove item (filled variant)',
    useCases: [
      'Delete workout',
      'Remove exercise',
      'Clear data',
    ],
    relatedIcons: [AppIcons.deleteOutline],
    suggestedSemanticLabel: 'Delete',
    keywords: ['delete', 'remove', 'trash', 'clear', 'discard'],
    platformNotes: 'Use deleteOutline for less destructive contexts',
  );

  static const save = IconMetadata(
    description: 'Save changes or data',
    useCases: [
      'Save workout template',
      'Confirm changes',
      'Store data',
    ],
    relatedIcons: [AppIcons.edit, AppIcons.check],
    suggestedSemanticLabel: 'Save',
    keywords: ['save', 'store', 'keep', 'preserve', 'disk'],
  );

  static const refresh = IconMetadata(
    description: 'Refresh or reload data',
    useCases: [
      'Sync with cloud',
      'Reload exercise database',
      'Refresh analytics',
    ],
    relatedIcons: [AppIcons.cloudSync],
    suggestedSemanticLabel: 'Refresh',
    keywords: ['refresh', 'reload', 'sync', 'update', 'renew'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NAVIGATION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const home = IconMetadata(
    description: 'Home screen navigation',
    useCases: [
      'Bottom navigation bar',
      'Return to home screen',
      'Main dashboard',
    ],
    relatedIcons: [AppIcons.workout, AppIcons.analytics],
    suggestedSemanticLabel: 'Home',
    keywords: ['home', 'dashboard', 'main', 'start'],
  );

  static const close = IconMetadata(
    description: 'Close dialog or modal',
    useCases: [
      'Close modal bottom sheets',
      'Dismiss dialogs',
      'Cancel action',
    ],
    relatedIcons: [AppIcons.back, AppIcons.clear],
    suggestedSemanticLabel: 'Close',
    keywords: ['close', 'dismiss', 'cancel', 'exit', 'x'],
  );

  static const back = IconMetadata(
    description: 'Navigate back to previous screen',
    useCases: [
      'App bar back button',
      'Navigation stack pop',
      'Return to previous screen',
    ],
    relatedIcons: [AppIcons.forward, AppIcons.close],
    suggestedSemanticLabel: 'Back',
    keywords: ['back', 'previous', 'return', 'arrow', 'navigate'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SOCIAL ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const star = IconMetadata(
    description: 'Favorite or rating (filled variant)',
    useCases: [
      'Favorite exercise',
      'Rating indicator',
      'Featured item',
    ],
    relatedIcons: [AppIcons.starOutline],
    suggestedSemanticLabel: 'Favorite',
    keywords: ['star', 'favorite', 'rating', 'featured', 'bookmark'],
  );

  static const achievement = IconMetadata(
    description: 'Achievement or trophy',
    useCases: [
      'Personal record badge',
      'Achievement unlocked',
      'Goal completed',
    ],
    relatedIcons: [AppIcons.celebration, AppIcons.streak],
    suggestedSemanticLabel: 'Achievement',
    keywords: ['trophy', 'achievement', 'award', 'prize', 'win'],
  );

  static const streak = IconMetadata(
    description: 'Streak or consistency indicator',
    useCases: [
      'Workout streak counter',
      'Consistency badge',
      'Daily goal tracking',
    ],
    relatedIcons: [AppIcons.achievement, AppIcons.celebration],
    suggestedSemanticLabel: 'Streak',
    keywords: ['fire', 'streak', 'consistency', 'daily', 'habit'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETTINGS ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const settings = IconMetadata(
    description: 'Settings and configuration',
    useCases: [
      'Settings screen navigation',
      'App configuration',
      'Preferences',
    ],
    relatedIcons: [AppIcons.theme, AppIcons.notifications, AppIcons.language],
    suggestedSemanticLabel: 'Settings',
    keywords: ['settings', 'config', 'preferences', 'options', 'gear'],
  );

  static const theme = IconMetadata(
    description: 'Theme or appearance settings',
    useCases: [
      'Dark/light mode toggle',
      'Color scheme selection',
      'UI customization',
    ],
    relatedIcons: [AppIcons.lightMode, AppIcons.darkMode, AppIcons.colorLens],
    suggestedSemanticLabel: 'Theme',
    keywords: ['theme', 'appearance', 'color', 'palette', 'design'],
  );

  static const notifications = IconMetadata(
    description: 'Notifications and alerts',
    useCases: [
      'Notification settings',
      'Push notification toggle',
      'Alert preferences',
    ],
    relatedIcons: [AppIcons.settings],
    suggestedSemanticLabel: 'Notifications',
    keywords: ['notifications', 'alerts', 'bell', 'reminders', 'push'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PREMIUM ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const premium = IconMetadata(
    description: 'Premium features and subscription',
    useCases: [
      'Premium upgrade screen',
      'Premium feature badge',
      'Subscription status',
    ],
    relatedIcons: [AppIcons.gift, AppIcons.rocket, AppIcons.autoAwesome],
    suggestedSemanticLabel: 'Premium',
    keywords: ['premium', 'pro', 'subscription', 'paid', 'upgrade'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MEDIA ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const play = IconMetadata(
    description: 'Play or start action',
    useCases: [
      'Start workout timer',
      'Resume timer',
      'Play video',
    ],
    relatedIcons: [AppIcons.pause, AppIcons.stop],
    suggestedSemanticLabel: 'Play',
    keywords: ['play', 'start', 'begin', 'resume', 'go'],
  );

  static const pause = IconMetadata(
    description: 'Pause or suspend action',
    useCases: [
      'Pause workout timer',
      'Suspend activity',
      'Pause video',
    ],
    relatedIcons: [AppIcons.play, AppIcons.stop],
    suggestedSemanticLabel: 'Pause',
    keywords: ['pause', 'suspend', 'halt', 'stop'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MISC ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const searchIcon = IconMetadata(
    description: 'Search functionality',
    useCases: [
      'Exercise search',
      'Template search',
      'Global search',
    ],
    relatedIcons: [AppIcons.searchOff, AppIcons.filter],
    suggestedSemanticLabel: 'Search',
    keywords: ['search', 'find', 'lookup', 'query', 'magnify'],
  );

  static const filter = IconMetadata(
    description: 'Filter or refine results',
    useCases: [
      'Exercise filter',
      'Analytics filter',
      'Sort and filter',
    ],
    relatedIcons: [AppIcons.search],
    suggestedSemanticLabel: 'Filter',
    keywords: ['filter', 'refine', 'sort', 'funnel', 'narrow'],
  );

  static const share = IconMetadata(
    description: 'Share data or export',
    useCases: [
      'Share workout',
      'Export data',
      'Social sharing',
    ],
    relatedIcons: [AppIcons.download, AppIcons.upload],
    suggestedSemanticLabel: 'Share',
    keywords: ['share', 'export', 'send', 'distribute', 'forward'],
  );

  static const cloudSync = IconMetadata(
    description: 'Cloud synchronization',
    useCases: [
      'Sync with Firebase',
      'Cloud backup',
      'Data synchronization',
    ],
    relatedIcons: [AppIcons.cloud, AppIcons.refresh],
    suggestedSemanticLabel: 'Sync',
    keywords: ['cloud', 'sync', 'backup', 'upload', 'download'],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // METADATA REGISTRY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Registry mapping IconData to IconMetadata
  static final Map<IconData, IconMetadata> _registry = {
    // Workout
    AppIcons.workout: workout,
    AppIcons.cardio: cardio,
    AppIcons.timer: timer,
    AppIcons.analytics: analytics,

    // Status
    AppIcons.complete: complete,
    AppIcons.error: error,
    AppIcons.warning: warning,

    // Action
    AppIcons.add: add,
    AppIcons.edit: edit,
    AppIcons.delete: delete,
    AppIcons.save: save,
    AppIcons.refresh: refresh,

    // Navigation
    AppIcons.home: home,
    AppIcons.close: close,
    AppIcons.back: back,

    // Social
    AppIcons.star: star,
    AppIcons.achievement: achievement,
    AppIcons.streak: streak,

    // Settings
    AppIcons.settings: settings,
    AppIcons.theme: theme,
    AppIcons.notifications: notifications,

    // Premium
    AppIcons.premium: premium,

    // Media
    AppIcons.play: play,
    AppIcons.pause: pause,

    // Misc
    AppIcons.search: searchIcon,
    AppIcons.filter: filter,
    AppIcons.share: share,
    AppIcons.cloudSync: cloudSync,
  };

  /// Get metadata for a specific icon
  static IconMetadata? metadataFor(IconData icon) {
    return _registry[icon];
  }

  /// Search icons by keyword, description, or semantic label
  ///
  /// Returns list of (IconData, IconMetadata) tuples matching the query.
  /// Search is case-insensitive and matches partial strings.
  static List<MapEntry<IconData, IconMetadata>> search(String query) {
    if (query.isEmpty) return [];

    return _registry.entries
        .where((entry) => entry.value.matches(query))
        .toList();
  }

  /// Get all icons in a specific category with metadata
  static Map<IconData, IconMetadata> byCategory(AppIconCategory category) {
    final categoryIcons = category.icons.values.toSet();
    return Map.fromEntries(
      _registry.entries.where((entry) => categoryIcons.contains(entry.key)),
    );
  }

  /// Get all icons with specific keyword
  static List<MapEntry<IconData, IconMetadata>> byKeyword(String keyword) {
    final k = keyword.toLowerCase();
    return _registry.entries
        .where((entry) => entry.value.keywords.any((kw) => kw.contains(k)))
        .toList();
  }

  /// Get related icons for a given icon
  static List<IconData> relatedTo(IconData icon) {
    final metadata = metadataFor(icon);
    return metadata?.relatedIcons ?? [];
  }

  /// Check if metadata exists for an icon
  static bool hasMetadata(IconData icon) {
    return _registry.containsKey(icon);
  }

  /// Get total count of icons with metadata
  static int get metadataCount => _registry.length;

  /// Get all icons with metadata
  static Map<IconData, IconMetadata> get all => Map.unmodifiable(_registry);
}

/// Extension to easily access metadata from IconData
extension IconDataMetadata on IconData {
  /// Get metadata for this icon (returns null if not available)
  IconMetadata? get metadata => AppIconMetadata.metadataFor(this);

  /// Get suggested semantic label for accessibility
  String? get suggestedSemanticLabel => metadata?.suggestedSemanticLabel;

  /// Get description of this icon
  String? get description => metadata?.description;

  /// Get related icons
  List<IconData> get relatedIcons => metadata?.relatedIcons ?? [];

  /// Get search keywords
  List<String> get keywords => metadata?.keywords ?? [];

  /// Check if this icon has metadata
  bool get hasMetadata => metadata != null;
}

/// Helper to generate documentation for icons
class IconDocumentation {
  IconDocumentation._();

  /// Generate markdown documentation for an icon
  static String generateDocs(IconData icon) {
    final metadata = icon.metadata;
    if (metadata == null) {
      return 'No metadata available for this icon.';
    }

    final buffer = StringBuffer();
    buffer.writeln('# Icon Documentation\n');
    buffer.writeln('**Description:** ${metadata.description}\n');
    buffer.writeln('**Semantic Label:** "${metadata.suggestedSemanticLabel}"\n');
    buffer.writeln('## Use Cases\n');
    for (final useCase in metadata.useCases) {
      buffer.writeln('- $useCase');
    }
    buffer.writeln('\n## Related Icons\n');
    for (final related in metadata.relatedIcons) {
      final relatedMeta = related.metadata;
      buffer.writeln('- ${relatedMeta?.description ?? "Related icon"}');
    }
    buffer.writeln('\n## Keywords\n');
    buffer.writeln(metadata.keywords.join(', '));

    if (metadata.platformNotes != null) {
      buffer.writeln('\n## Platform Notes\n');
      buffer.writeln(metadata.platformNotes);
    }

    if (metadata.exampleUsage != null) {
      buffer.writeln('\n## Example Usage\n');
      buffer.writeln('```dart');
      buffer.writeln(metadata.exampleUsage);
      buffer.writeln('```');
    }

    return buffer.toString();
  }

  /// Generate markdown table of all icons with metadata
  static String generateTable() {
    final buffer = StringBuffer();
    buffer.writeln('| Icon | Description | Use Cases | Keywords |');
    buffer.writeln('|------|-------------|-----------|----------|');

    for (final entry in AppIconMetadata.all.entries) {
      final metadata = entry.value;
      final useCases = metadata.useCases.take(2).join(', ');
      final keywords = metadata.keywords.take(3).join(', ');
      buffer.writeln(
        '| Icon | ${metadata.description} | $useCases | $keywords |',
      );
    }

    return buffer.toString();
  }
}
