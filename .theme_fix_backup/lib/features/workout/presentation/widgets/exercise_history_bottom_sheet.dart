/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal - TIER 1 DESIGN PRO
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Exercise History Provider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:flutter/foundation.dart';

class ExerciseHistoryBottomSheet extends ConsumerStatefulWidget {

  const ExerciseHistoryBottomSheet({
    super.key,
    required this.exerciseName,
  });
  final String exerciseName;

  @override
  ConsumerState<ExerciseHistoryBottomSheet> createState() => _ExerciseHistoryBottomSheetState();
}

class _ExerciseHistoryBottomSheetState extends ConsumerState<ExerciseHistoryBottomSheet> 
    with TickerProviderStateMixin {
  
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;
  
  final Map<DateTime, bool> _expandedDays = {};
  
  static const double _maxHeaderHeight = 140.0; // More compact header
  static const double _minHeaderHeight = 70.0; // Smaller collapsed height
  static const double _maxStatsHeight = 280.0; // Increased height to prevent cutting
  
  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _statsAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    const scrollThreshold = 120.0; // Lower threshold for header collapse
    const statsScrollThreshold = 50.0; // Hide stats quickly when scrolling
    
    final scrollOffset = _scrollController.offset;
    
    // Header animation - collapse header when scrolling down
    if (scrollOffset > scrollThreshold && _headerAnimationController.value < 1.0) {
      _headerAnimationController.forward();
    } else if (scrollOffset <= scrollThreshold && _headerAnimationController.value > 0.0) {
      _headerAnimationController.reverse();
    }
    
    // Stats animation - keep stats visible much longer
    if (scrollOffset > statsScrollThreshold && _statsAnimationController.value < 1.0) {
      _statsAnimationController.forward();
    } else if (scrollOffset <= statsScrollThreshold && _statsAnimationController.value > 0.0) {
      _statsAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final historyAsync = ref.watch(exerciseHistoryDataGroupedProvider(widget.exerciseName));
    final statsAsync = ref.watch(exerciseStatsFromActivitiesProvider(widget.exerciseName));

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, -12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Premium handle bar
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            // Collapsible Header
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                final progress = 1.0 - _headerAnimation.value;
                final height = _minHeaderHeight + (_maxHeaderHeight - _minHeaderHeight) * progress;
                
                return Container(
                  height: height,
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 8), // Reduced bottom margin
                  padding: EdgeInsets.all(progress * 16 + 8), // More compact padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.9 * progress + 0.3),
                        theme.colorScheme.secondaryContainer.withValues(alpha: 0.7 * progress + 0.2),
                        theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5 * progress + 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.06 * progress),
                        blurRadius: 20 * progress,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Collapsible icon
                      Container(
                        padding: EdgeInsets.all(8 + 4 * progress), // Smaller icon container
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: progress > 0.5 ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: theme.colorScheme.primary,
                          size: 20 + 6 * progress, // Smaller icon
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (progress > 0.3) ...[
                              Text(
                                l10n.exerciseHistory.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: theme.colorScheme.primary.withValues(alpha: progress),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                              SizedBox(height: 6 * progress),
                            ],
                            Text(
                              widget.exerciseName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: theme.colorScheme.onSurface,
                                height: 1.0,
                                fontSize: (theme.textTheme.headlineMedium?.fontSize ?? 24) * (0.65 + 0.25 * progress), // Smaller text
                              ),
                              maxLines: progress > 0.5 ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Premium close button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Collapsible Stats section
            AnimatedBuilder(
              animation: _statsAnimation,
              builder: (context, child) {
                final progress = 1.0 - _statsAnimation.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: progress > 0 ? null : 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: progress,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: statsAsync.when(
                        data: (stats) => _buildPremiumStatsSection(context, theme, l10n, stats),
                        loading: () => _buildStatsLoadingState(theme),
                        error: (_, __) => const SizedBox(),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Premium History list
            Expanded(
              child: historyAsync.when(
                data: (groupedHistory) => _buildPremiumHistoryList(
                  context, 
                  theme, 
                  l10n, 
                  groupedHistory,
                ),
                loading: () => _buildHistoryLoadingState(theme),
                error: (error, _) => _buildErrorState(context, theme, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ({
      double? maxWeight,
      int totalSets,
      double avgWeight,
      DateTime? firstWorkout,
      DateTime? lastWorkout,
    }) stats,
  ) {
    if (stats.totalSets == 0) return const SizedBox();

    final statCards = [
      _StatCardData(
        label: l10n.maxWeight,
        value: stats.maxWeight != null ? '${stats.maxWeight!.toStringAsFixed(1)}kg' : '--',
        icon: Icons.fitness_center_rounded,
        color: theme.colorScheme.primary,
        isPrimary: true,
      ),
      _StatCardData(
        label: l10n.totalSets,
        value: stats.totalSets.toString(),
        icon: Icons.repeat_rounded,
        color: theme.colorScheme.secondary,
        isPrimary: false,
      ),
      _StatCardData(
        label: l10n.avgWeight,
        value: stats.avgWeight > 0 ? '${stats.avgWeight.toStringAsFixed(1)}kg' : '--',
        icon: Icons.trending_up_rounded,
        color: theme.colorScheme.tertiary,
        isPrimary: false,
      ),
      _StatCardData(
        label: 'Last Workout', // Changed from firstWorkout to lastWorkout
        value: stats.lastWorkout != null 
          ? DateFormat('MMM d').format(stats.lastWorkout!)
          : '--',
        icon: Icons.schedule_rounded,
        color: theme.colorScheme.outline,
        isPrimary: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.statistics.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Premium stats grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: statCards.length,
          itemBuilder: (context, index) {
            final stat = statCards[index];
            return _buildPremiumStatCard(context, theme, stat);
          },
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(BuildContext context, ThemeData theme, _StatCardData stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: stat.isPrimary 
          ? LinearGradient(
              colors: [
                stat.color.withValues(alpha: 0.15),
                stat.color.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: stat.isPrimary 
            ? stat.color.withValues(alpha: 0.2)
            : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.isPrimary 
              ? stat.color.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.02),
            blurRadius: stat.isPrimary ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon with sophisticated background
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stat.isPrimary
                    ? theme.colorScheme.surface.withValues(alpha: 0.9)
                    : stat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: stat.isPrimary ? [
                    BoxShadow(
                      color: stat.color.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  stat.icon,
                  color: stat.color,
                  size: 24,
                ),
              ),
            ],
          ),
          
          // Value and label with premium typography
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHistoryList(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Map<DateTime, List<ExerciseHistoryData>> groupedHistory,
  ) {
    if (kDebugMode) {
      debugPrint('DEBUG ExerciseHistoryBottomSheet: Received ${groupedHistory.length} days of history');
    }
    for (final entry in groupedHistory.entries) {
      if (kDebugMode) {
        debugPrint('DEBUG ExerciseHistoryBottomSheet: Date ${entry.key} has ${entry.value.length} items');
      }
      for (final item in entry.value) {
        if (kDebugMode) {
          debugPrint('DEBUG ExerciseHistoryBottomSheet: - ${item.workoutName}: ${item.weight}kg x ${item.reps}');
        }
      }
    }
    
    if (groupedHistory.isEmpty) {
      if (kDebugMode) {
        debugPrint('DEBUG ExerciseHistoryBottomSheet: No history data, showing empty state');
      }
      return _buildEmptyState(context, theme, l10n);
    }

    final sortedDates = groupedHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Initialize expanded state for all days
    for (final date in sortedDates) {
      _expandedDays.putIfAbsent(date, () => true);
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Premium section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'WORKOUT HISTORY',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // History items
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final date = sortedDates[index];
              final dayHistory = groupedHistory[date]!;
              final isExpanded = _expandedDays[date] ?? false;
              
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expandable date header
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedDays[date] = !isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                                theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getDateIcon(date),
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatPremiumDate(date, l10n),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${dayHistory.length}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Expandable sets for this date
                    if (isExpanded)
                      Column(
                        children: dayHistory.map((historyData) => _buildPremiumHistoryItem(
                          context, 
                          theme, 
                          l10n, 
                          historyData,
                        )).toList(),
                      ),
                  ],
                ),
              );
            },
            childCount: sortedDates.length,
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildPremiumHistoryItem(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ExerciseHistoryData historyData,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () => _showEditHistoryDialog(context, theme, l10n, historyData),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16), // More compact padding
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Compact weight and reps section
              Expanded(
                child: Row(
                  children: [
                    if (historyData.weight != null) ...[ 
                      Container(
                        padding: const EdgeInsets.all(6), // More compact
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${historyData.weight!.toStringAsFixed(historyData.weight! % 1 == 0 ? 0 : 1)}kg',
                        style: theme.textTheme.titleMedium?.copyWith( // Smaller text
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (historyData.reps != null) ...[ 
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.repeat_rounded,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${historyData.reps}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.reps.toLowerCase(),
                        style: theme.textTheme.bodySmall?.copyWith( // Smaller label
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditHistoryDialog(
    BuildContext context, 
    ThemeData theme, 
    AppLocalizations l10n, 
    ExerciseHistoryData historyData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.colorScheme.surface,
          title: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Set',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight: ${historyData.weight?.toStringAsFixed(1) ?? '--'}kg',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reps: ${historyData.reps ?? '--'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Workout: ${historyData.workoutName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Edit functionality coming soon!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                'Edit',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noHistoryFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.completeWorkoutsToSeeHistory,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsLoadingState(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingHistory,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPremiumDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == yesterday) {
      return l10n.yesterday;
    } else if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  IconData _getDateIcon(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return Icons.today_rounded;
    } else if (dateOnly == yesterday) {
      return Icons.schedule_rounded;
    } else if (now.difference(dateOnly).inDays < 7) {
      return Icons.date_range_rounded;
    } else {
      return Icons.calendar_month_rounded;
    }
  }
}

class _StatCardData {

  _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPrimary,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPrimary;
}