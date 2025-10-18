import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// GitHub-style heatmap showing workout volume over time
class VolumeHeatmap extends StatefulWidget {

  const VolumeHeatmap({
    super.key,
    required this.activities,
    this.onDayTapped,
  });
  final List<ExerciseActivity> activities;
  final Function(DateTime)? onDayTapped;

  @override
  State<VolumeHeatmap> createState() => _VolumeHeatmapState();
}

class _VolumeHeatmapState extends State<VolumeHeatmap> {
  late Map<DateTime, double> _volumeData;
  DateTime? _selectedDate;
  int _weeksToShow = 12;

  @override
  void initState() {
    super.initState();
    _prepareVolumeData();
  }

  @override
  void didUpdateWidget(VolumeHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activities != oldWidget.activities) {
      _prepareVolumeData();
    }
  }

  void _prepareVolumeData() {
    _volumeData = VolumeCalculator.calculateDailyVolume(widget.activities);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, localizations, colorScheme),
            const SizedBox(height: 8),
            _buildControls(context, localizations),
            const SizedBox(height: 20),
            _buildHeatmap(context, colorScheme),
            const SizedBox(height: 16),
            _buildLegend(context, localizations, colorScheme),
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              _buildSelectedDayInfo(context, localizations),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.calendar_view_month,
          color: colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          localizations.volumeHeatmap,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '${_volumeData.length} ${localizations.workoutDays}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, AppLocalizations localizations) {
    return Row(
      children: [
        Text(
          localizations.weeksToShow,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 4, label: Text('4')),
            ButtonSegment(value: 8, label: Text('8')),
            ButtonSegment(value: 12, label: Text('12')),
            ButtonSegment(value: 26, label: Text('26')),
          ],
          selected: {_weeksToShow},
          onSelectionChanged: (Set<int> selection) {
            setState(() {
              _weeksToShow = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeatmap(BuildContext context, ColorScheme colorScheme) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _weeksToShow * 7));
    
    // Build week labels
    final weekLabels = <String>[];
    for (int i = 0; i < _weeksToShow; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      if (i % 4 == 0) {
        weekLabels.add('${weekStart.month}/${weekStart.day}');
      } else {
        weekLabels.add('');
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week labels
          Row(
            children: [
              const SizedBox(width: 40), // Space for day labels
              ...weekLabels.map((label) => SizedBox(
                width: 28,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          // Heatmap grid
          ...List.generate(7, (dayOfWeek) {
            return Row(
              children: [
                // Day label
                SizedBox(
                  width: 40,
                  child: Text(
                    _getDayLabel(dayOfWeek),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // Day boxes
                ...List.generate(_weeksToShow, (weekIndex) {
                  final date = startDate.add(Duration(
                    days: weekIndex * 7 + dayOfWeek,
                  ));
                  
                  if (date.isAfter(now)) {
                    return const SizedBox(width: 28);
                  }
                  
                  return _buildDayBox(date, colorScheme);
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayBox(DateTime date, ColorScheme colorScheme) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final volume = _volumeData[normalizedDate] ?? 0;
    final intensity = _getIntensityLevel(volume);
    final color = _getColorForIntensity(intensity, colorScheme);
    final isSelected = _selectedDate == normalizedDate;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = _selectedDate == normalizedDate ? null : normalizedDate;
        });
        if (normalizedDate != _selectedDate) {
          widget.onDayTapped?.call(normalizedDate);
        }
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: volume > 0
            ? Center(
                child: Text(
                  intensity.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: intensity > 2 ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, AppLocalizations localizations, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.less,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getColorForIntensity(index, colorScheme),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          localizations.more,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo(BuildContext context, AppLocalizations localizations) {
    if (_selectedDate == null) return const SizedBox.shrink();
    
    final volume = _volumeData[_selectedDate] ?? 0;
    final activitiesOnDay = widget.activities.where((a) {
      final activityDate = DateTime(
        a.createdAt.year,
        a.createdAt.month,
        a.createdAt.day,
      );
      return activityDate == _selectedDate;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${localizations.totalVolume}: ${volume.toStringAsFixed(0)}kg',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${localizations.exercises}: ${activitiesOnDay.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (activitiesOnDay.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              localizations.exercisesPerformed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...activitiesOnDay.map((a) => Text(
              '• ${a.exerciseName}',
              style: Theme.of(context).textTheme.bodySmall,
            )),
          ],
        ],
      ),
    );
  }

  int _getIntensityLevel(double volume) {
    if (volume == 0) return 0;
    
    final allVolumes = _volumeData.values.where((v) => v > 0).toList();
    if (allVolumes.isEmpty) return 0;
    
    allVolumes.sort();
    final percentile = allVolumes.indexOf(volume) / allVolumes.length;
    
    if (percentile < 0.2) return 1;
    if (percentile < 0.4) return 2;
    if (percentile < 0.6) return 3;
    if (percentile < 0.8) return 4;
    return 5;
  }

  Color _getColorForIntensity(int intensity, ColorScheme colorScheme) {
    switch (intensity) {
      case 0:
        return colorScheme.surfaceContainerLow;
      case 1:
        return colorScheme.primary.withValues(alpha: 0.2);
      case 2:
        return colorScheme.primary.withValues(alpha: 0.4);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.6);
      case 4:
        return colorScheme.primary.withValues(alpha: 0.8);
      case 5:
        return colorScheme.primary;
      default:
        return colorScheme.surfaceContainerLow;
    }
  }

  String _getDayLabel(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }
}