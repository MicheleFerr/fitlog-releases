import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../domain/models/home_widget_config.dart';
import 'package:intl/intl.dart';

class StreakTrackerWidget extends ConsumerWidget {
  final WidgetSize size;
  
  const StreakTrackerWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (size) {
      case WidgetSize.small:
        return _buildCompactView(context, ref);
      case WidgetSize.medium:
        return _buildStandardView(context, ref);
      case WidgetSize.large:
        return _buildExpandedView(context, ref);
    }
  }

  Widget _buildCompactView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();
    final streak = frequencyStats['currentStreak'] ?? 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withValues(alpha: 0.1),
              Colors.red.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Flame animation background
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.local_fire_department,
                size: 120,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (analyticsState.isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$streak',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: streak > 0 ? Colors.orange : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              streak == 1 ? 'giorno' : 'giorni',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getStreakMessage(streak),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: streak > 0 ? Colors.orange[700] : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();
    final streak = frequencyStats['currentStreak'] ?? 0;
    
    // Get last 7 days of activity
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Start from Monday
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    
    // Create activity map from real data
    final activityMap = <DateTime, bool>{};
    for (final activity in analyticsState.activities) {
      final date = DateTime(activity.createdAt.year, activity.createdAt.month, activity.createdAt.day);
      activityMap[date] = true;
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withValues(alpha: 0.08),
              Colors.red.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settimana Corrente',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Streak: $streak ${streak == 1 ? 'giorno' : 'giorni'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: streak > 0 ? Colors.orange : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildWeekView(context, weekDays, activityMap, analyticsState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();
    final streak = frequencyStats['currentStreak'] ?? 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withValues(alpha: 0.05),
              Colors.red.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendario Attività',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Clicca su un giorno per i dettagli',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStreakStat(
                      context,
                      label: 'Streak Attuale',
                      value: '$streak',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStreakStat(
                      context,
                      label: 'Allenamenti Totali',
                      value: '${analyticsState.activities.length}',
                      icon: Icons.fitness_center,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStreakStat(
                      context,
                      label: 'Questo Mese',
                      value: '${frequencyStats['daysInLast30'] ?? 0}',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calendar heatmap
              _buildFullCalendar(context, analyticsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, List<DateTime> weekDays, Map<DateTime, bool> activityMap, AnalyticsState state) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Week days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays.map((day) {
            final dayKey = DateTime(day.year, day.month, day.day);
            final isToday = dayKey == todayKey;
            final isFuture = dayKey.isAfter(todayKey);
            final hasWorkout = activityMap[dayKey] == true;
            
            // Count exercises for this day
            final dayActivities = state.activities.where((a) {
              final actDate = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
              return actDate == dayKey;
            }).toList();
            
            return GestureDetector(
              onTap: hasWorkout ? () => _showDayDetails(context, day, dayActivities) : null,
              child: Column(
                children: [
                  Text(
                    _getDayName(day.weekday),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isToday 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isFuture 
                        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                        : hasWorkout 
                          ? _getIntensityColor(dayActivities.length)
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ) : null,
                    ),
                    child: Center(
                      child: hasWorkout
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                              Text(
                                '${dayActivities.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${day.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isFuture 
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, 'Riposo', theme.colorScheme.surfaceContainerHighest),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Leggero', _getIntensityColor(1)),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Intenso', _getIntensityColor(3)),
          ],
        ),
      ],
    );
  }

  Widget _buildFullCalendar(BuildContext context, AnalyticsState state) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    
    // Adjust to start from Monday
    final firstWeekday = firstDayOfMonth.weekday;
    final daysBeforeMonth = firstWeekday - 1; // Monday = 1
    
    // Create activity map
    final activityMap = <DateTime, List<dynamic>>{};
    for (final activity in state.activities) {
      final date = DateTime(activity.createdAt.year, activity.createdAt.month, activity.createdAt.day);
      if (date.month == today.month && date.year == today.year) {
        activityMap[date] = (activityMap[date] ?? [])..add(activity);
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Month header
          Text(
            _getMonthName(today.month) + ' ${today.year}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Weekday headers (starting from Monday)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'].map((day) {
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysBeforeMonth + daysInMonth,
            itemBuilder: (context, index) {
              if (index < daysBeforeMonth) {
                return const SizedBox();
              }
              
              final day = index - daysBeforeMonth + 1;
              final date = DateTime(today.year, today.month, day);
              final isToday = day == today.day;
              final isFuture = date.isAfter(today);
              final activities = activityMap[date] ?? [];
              final hasWorkout = activities.isNotEmpty;
              
              return GestureDetector(
                onTap: hasWorkout 
                  ? () => _showDayDetails(context, date, activities)
                  : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isFuture
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : hasWorkout 
                        ? _getIntensityColor(activities.length)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasWorkout 
                              ? Colors.white 
                              : isFuture
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasWorkout) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${activities.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Nessuno', theme.colorScheme.surfaceContainerHighest),
              const SizedBox(width: 12),
              _buildLegendItem(context, '1-2 es.', _getIntensityColor(1)),
              const SizedBox(width: 12),
              _buildLegendItem(context, '3-4 es.', _getIntensityColor(3)),
              const SizedBox(width: 12),
              _buildLegendItem(context, '5+ es.', _getIntensityColor(5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Color _getIntensityColor(int exerciseCount) {
    if (exerciseCount == 0) return Colors.grey.withValues(alpha: 0.2);
    if (exerciseCount <= 2) return Colors.green.withValues(alpha: 0.5);
    if (exerciseCount <= 4) return Colors.orange.withValues(alpha: 0.7);
    return Colors.red.withValues(alpha: 0.8);
  }

  void _showDayDetails(BuildContext context, DateTime date, List<dynamic> activities) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE d MMMM', 'it').format(date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${activities.length} ${activities.length == 1 ? 'esercizio' : 'esercizi'} completati',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: activities.map<Widget>((activity) {
                      final totalVolume = activity.sets.fold<double>(
                        0,
                        (sum, set) => sum + (double.tryParse(set.weight) ?? 0) * (int.tryParse(set.reps) ?? 0),
                      );
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.exerciseName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${activity.sets.length} serie • ${totalVolume.toStringAsFixed(0)} kg totali',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Chiudi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStreakMessage(int days) {
    if (days == 0) return 'Inizia oggi il tuo streak!';
    if (days == 1) return 'Ottimo inizio!';
    if (days < 7) return 'Continua così!';
    if (days < 14) return 'Una settimana! 🔥';
    if (days < 30) return 'Inarrestabile!';
    if (days < 60) return 'Un mese di fuoco!';
    return 'Leggenda! 🏆';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mer';
      case 4: return 'Gio';
      case 5: return 'Ven';
      case 6: return 'Sab';
      case 7: return 'Dom';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return months[month - 1];
  }
}