import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/export_service.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Dialog for exporting analytics data
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  ExportCSVType _selectedCSVType = ExportCSVType.workouts;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(AppIcons.download, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(localizations.exportData),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectExportFormat,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            RadioGroup<ExportFormat>(
              groupValue: _selectedFormat,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                    _errorMessage = null;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormatOption(
                    context,
                    ExportFormat.pdf,
                    'PDF Report',
                    'Complete analytics report with charts and insights',
                    Icons.picture_as_pdf,
                  ),
                  const SizedBox(height: 8),
                  _buildFormatOption(
                    context,
                    ExportFormat.csv,
                    'CSV Spreadsheet',
                    'Raw data for analysis in Excel or Google Sheets',
                    AppIcons.tableChart,
                  ),
                ],
              ),
            ),
            if (_selectedFormat == ExportFormat.csv) ...[
              const SizedBox(height: 16),
              Text(
                localizations.selectDataType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildCSVTypeDropdown(context),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.error,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _handleExport,
          icon: _isExporting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(AppIcons.download),
          label: Text(_isExporting ? localizations.exporting : localizations.export),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    ExportFormat format,
    String title,
    String description,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
          _errorMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Radio<ExportFormat>(
              value: format,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCSVTypeDropdown(BuildContext context) {
    return DropdownButtonFormField<ExportCSVType>(
      initialValue: _selectedCSVType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: ExportCSVType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getCSVTypeLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCSVType = value!;
          _errorMessage = null;
        });
      },
    );
  }

  String _getCSVTypeLabel(ExportCSVType type) {
    switch (type) {
      case ExportCSVType.workouts:
        return 'Workout Summary';
      case ExportCSVType.exercises:
        return 'Detailed Sets & Reps';
      case ExportCSVType.volume:
        return 'Volume Progress';
      case ExportCSVType.personalRecords:
        return 'Personal Records';
    }
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });

    try {
      final analyticsState = ref.read(analyticsProvider);
      final user = ref.read(firebaseUserProvider).valueOrNull;
      final userName = user?.displayName ?? user?.email ?? 'User';

      String filePath;

      if (_selectedFormat == ExportFormat.pdf) {
        // Prepare statistics
        final statistics = {
          'totalWorkouts': analyticsState.activities.length,
          'totalVolume': analyticsState.activities.fold<double>(
            0, (sum, a) => sum + a.totalVolume
          ),
          'avgDuration': analyticsState.activities.isEmpty ? 0 :
            analyticsState.activities.fold<int>(0, (sum, a) => sum + (a.duration ?? 0)) ~/
            analyticsState.activities.length,
          'currentStreak': ref.read(analyticsProvider.notifier).getFrequencyStats()['currentStreak'],
          'longestStreak': ref.read(analyticsProvider.notifier).getFrequencyStats()['longestStreak'],
          'totalPRs': analyticsState.personalRecords.length,
          'mostTrainedMuscle': _getMostTrainedMuscle(analyticsState.muscleBalance),
          'favoriteExercise': _getFavoriteExercise(analyticsState.activities),
        };

        filePath = await ExportService.exportToPDF(
          activities: analyticsState.activities,
          personalRecords: analyticsState.personalRecords,
          insights: analyticsState.insights,
          statistics: statistics,
          userName: userName,
        );
      } else {
        filePath = await ExportService.exportToCSV(
          activities: analyticsState.activities,
          type: _selectedCSVType,
        );
      }

      // Share the file
      await ExportService.shareFile(filePath);
      
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Export failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getMostTrainedMuscle(dynamic muscleBalance) {
    if (muscleBalance.volumeDistribution.isEmpty) return 'N/A';
    
    var maxEntry = muscleBalance.volumeDistribution.entries.first;
    for (final entry in muscleBalance.volumeDistribution.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  String _getFavoriteExercise(List<dynamic> activities) {
    if (activities.isEmpty) return 'N/A';
    
    final Map<String, int> exerciseCount = {};
    for (final activity in activities) {
      exerciseCount[activity.exerciseName] = 
        (exerciseCount[activity.exerciseName] ?? 0) + 1;
    }
    
    var maxEntry = exerciseCount.entries.first;
    for (final entry in exerciseCount.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  void _showSuccessSnackbar() {
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.complete, color: Colors.white),
            const SizedBox(width: 12),
            Text(localizations.exportSuccess),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

enum ExportFormat {
  pdf,
  csv,
}
