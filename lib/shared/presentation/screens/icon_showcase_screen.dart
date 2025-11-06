import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Icon showcase/picker screen for developers
///
/// Debug utility that displays all centralized AppIcons with:
/// - Search/filter functionality
/// - Category grouping
/// - Tap to copy icon name to clipboard
/// - Visual preview of all icons
///
/// **Access:**
/// - Add to debug menu or admin dashboard
/// - Navigate via: `Navigator.push(context, MaterialPageRoute(builder: (_) => IconShowcaseScreen()))`
///
/// **Usage:**
/// 1. Search for icon by name
/// 2. Tap icon to copy "AppIcons.iconName" to clipboard
/// 3. Paste in code
///
/// This screen should ONLY be accessible in debug/dev builds.
class IconShowcaseScreen extends StatefulWidget {
  const IconShowcaseScreen({super.key});

  @override
  State<IconShowcaseScreen> createState() => _IconShowcaseScreenState();
}

class _IconShowcaseScreenState extends State<IconShowcaseScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  IconCategory _selectedCategory = IconCategory.all;

  // All app icons organized by category
  // This is manually curated - extend as needed
  final Map<IconCategory, Map<String, IconData>> _iconsByCategory = {
    IconCategory.workout: {
      'workout': AppIcons.workout,
      'cardio': AppIcons.cardio,
      'gymnastics': AppIcons.gymnastics,
      'sportsGymnastics': AppIcons.sportsGymnastics,
      'flexibility': AppIcons.flexibility,
      'accessibility': AppIcons.accessibility,
    },
    IconCategory.timer: {
      'timer': AppIcons.timer,
      'timerOff': AppIcons.timerOff,
      'schedule': AppIcons.schedule,
      'clock': AppIcons.clock, // Access time
      'history': AppIcons.history,
    },
    IconCategory.analytics: {
      'analytics': AppIcons.analytics,
      'barChart': AppIcons.barChart,
      'lineChart': AppIcons.lineChart, // Show chart
      'insights': AppIcons.insights,
      'speed': AppIcons.speed,
      'trendUp': AppIcons.trendUp, // Trending up
      'trendDown': AppIcons.trendDown, // Trending down
      'trendFlat': AppIcons.trendFlat, // Trending flat
    },
    IconCategory.status: {
      'complete': AppIcons.complete, // Check circle filled
      'completeOutline': AppIcons.completeOutline, // Check circle outline
      'check': AppIcons.check,
      'allDone': AppIcons.allDone,
      'doneAll': AppIcons.doneAll,
      'error': AppIcons.error, // Error outline
      'info': AppIcons.info, // Info outline
      'warning': AppIcons.warning,
    },
    IconCategory.action: {
      'add': AppIcons.add,
      'addCircleOutline': AppIcons.addCircleOutline,
      'edit': AppIcons.edit,
      'delete': AppIcons.delete,
      'deleteOutline': AppIcons.deleteOutline,
      'save': AppIcons.save,
      'copy': AppIcons.copy,
      'paste': AppIcons.paste,
      'undo': AppIcons.undo,
      'redo': AppIcons.redo,
      'refresh': AppIcons.refresh,
    },
    IconCategory.navigation: {
      'home': AppIcons.home,
      'close': AppIcons.close,
      'back': AppIcons.back, // Arrow back
      'forward': AppIcons.forward, // Arrow forward
      'forwardIos': AppIcons.forwardIos, // Arrow forward iOS
      'expandMore': AppIcons.expandMore,
      'expandLess': AppIcons.expandLess,
      'chevronRight': AppIcons.chevronRight,
      'chevronLeft': AppIcons.chevronLeft,
      'clear': AppIcons.clear,
      'remove': AppIcons.remove,
    },
    IconCategory.social: {
      'person': AppIcons.person,
      'people': AppIcons.people,
      'peopleOutline': AppIcons.peopleOutline,
      'verified': AppIcons.verified,
      'handshake': AppIcons.handshake,
      'star': AppIcons.star,
      'starOutline': AppIcons.starOutline, // Star border
      'achievement': AppIcons.achievement, // Trophy icon
      'streak': AppIcons.streak, // Fire icon
      'celebration': AppIcons.celebration,
      'thumbUp': AppIcons.thumbUp,
      'thumbDown': AppIcons.thumbDown,
    },
    IconCategory.settings: {
      'settings': AppIcons.settings,
      'admin': AppIcons.admin,
      'lock': AppIcons.lock,
      'unlock': AppIcons.unlock, // Lock open icon
      'notifications': AppIcons.notifications,
      'theme': AppIcons.theme, // Palette icon
      'language': AppIcons.language,
    },
    IconCategory.premium: {
      'premium': AppIcons.premium,
      'gift': AppIcons.gift,
      'rocket': AppIcons.rocket,
      'autoAwesome': AppIcons.autoAwesome,
    },
    IconCategory.media: {
      'play': AppIcons.play,
      'pause': AppIcons.pause,
      'stop': AppIcons.stop,
      'skipNext': AppIcons.skipNext,
      'repeat': AppIcons.repeat,
      'camera': AppIcons.camera,
      'image': AppIcons.image,
    },
    IconCategory.misc: {
      'search': AppIcons.search,
      'searchOff': AppIcons.searchOff,
      'filter': AppIcons.filter,
      'share': AppIcons.share,
      'download': AppIcons.download,
      'upload': AppIcons.upload,
      'document': AppIcons.document,
      'link': AppIcons.link,
      'email': AppIcons.email,
      'location': AppIcons.location,
      'cloud': AppIcons.cloud,
      'cloudSync': AppIcons.cloudSync,
      'chat': AppIcons.chat,
      'menu': AppIcons.menu,
      'moreVert': AppIcons.moreVert,
      'moreHoriz': AppIcons.moreHoriz,
      'visibility': AppIcons.visibility,
      'visibilityOff': AppIcons.visibilityOff,
      'lightMode': AppIcons.lightMode,
      'darkMode': AppIcons.darkMode,
      'colorLens': AppIcons.colorLens,
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, IconData>> _filteredIcons() {
    final query = _searchQuery.toLowerCase();

    // Get icons from selected category
    Map<String, IconData> icons;
    if (_selectedCategory == IconCategory.all) {
      // Merge all categories
      icons = {};
      for (final category in _iconsByCategory.values) {
        icons.addAll(category);
      }
    } else {
      icons = _iconsByCategory[_selectedCategory] ?? {};
    }

    // Filter by search query
    if (query.isEmpty) {
      return icons.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    }

    return icons.entries
        .where((e) => e.key.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  void _copyIconName(String iconName) {
    Clipboard.setData(ClipboardData(text: 'AppIcons.$iconName'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: AppIcons.$iconName'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredIcons = _filteredIcons();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Showcase'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search icons...',
                    prefixIcon: const Icon(AppIcons.search, size: AppIconSize.medium),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(AppIcons.clear, size: AppIconSize.medium),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Category filter
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: IconCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredIcons.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.search,
                    size: AppIconSize.emptyState,
                    color: context.colors.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No icons found',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final entry = filteredIcons[index];
                return _IconCard(
                  iconName: entry.key,
                  icon: entry.value,
                  onTap: () => _copyIconName(entry.key),
                );
              },
            ),
    );
  }
}

class _IconCard extends StatelessWidget {

  const _IconCard({
    required this.iconName,
    required this.icon,
    required this.onTap,
  });
  final String iconName;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.xlarge,
              color: context.colors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              iconName,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon categories for organization
enum IconCategory {
  all('All'),
  workout('Workout'),
  timer('Timer'),
  analytics('Analytics'),
  status('Status'),
  action('Action'),
  navigation('Navigation'),
  social('Social'),
  settings('Settings'),
  premium('Premium'),
  media('Media'),
  misc('Misc');

  final String displayName;
  const IconCategory(this.displayName);
}
