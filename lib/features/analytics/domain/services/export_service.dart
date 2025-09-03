import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/analytics_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:intl/intl.dart';

/// Service for exporting analytics data to various formats
class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _fullDateFormat = DateFormat('MMMM d, yyyy');
  
  /// Export analytics data to PDF
  static Future<String> exportToPDF({
    required List<AnalyticsActivity> activities,
    required List<PersonalRecord> personalRecords,
    required List<TrainingInsight> insights,
    required Map<String, dynamic> statistics,
    required String userName,
    Directory? customDirectory,
  }) async {
    final pdf = pw.Document();
    
    // Add cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildCoverPage(context, userName),
      ),
    );
    
    // Add statistics overview
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildStatisticsPage(context, statistics),
      ),
    );
    
    // Add personal records
    if (personalRecords.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildPersonalRecordsPage(context, personalRecords),
        ),
      );
    }
    
    // Add recent workouts
    if (activities.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildWorkoutsPage(context, activities),
        ),
      );
    }
    
    // Add insights
    if (insights.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildInsightsPage(context, insights),
        ),
      );
    }
    
    // Save PDF
    final directory = customDirectory ?? await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/gymbro_analytics_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
  
  /// Export analytics data to CSV
  static Future<String> exportToCSV({
    required List<AnalyticsActivity> activities,
    required ExportCSVType type,
    Directory? customDirectory,
  }) async {
    List<List<dynamic>> rows = [];
    
    switch (type) {
      case ExportCSVType.workouts:
        rows = _generateWorkoutCSV(activities);
        break;
      case ExportCSVType.exercises:
        rows = _generateExerciseCSV(activities);
        break;
      case ExportCSVType.volume:
        rows = _generateVolumeCSV(activities);
        break;
      case ExportCSVType.personalRecords:
        rows = _generatePRCSV(activities);
        break;
    }
    
    final csv = const ListToCsvConverter().convert(rows);
    
    // Save CSV
    final directory = customDirectory ?? await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${type.name}_$timestamp.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);
    
    return file.path;
  }
  
  /// Share exported file
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
  
  /// Build PDF cover page
  static pw.Widget _buildCoverPage(pw.Context context, String userName) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'GymBro Analytics Report',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Training Performance Analysis',
            style: const pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            userName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _fullDateFormat.format(DateTime.now()),
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  /// Build PDF statistics page
  static pw.Widget _buildStatisticsPage(
    pw.Context context,
    Map<String, dynamic> statistics,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Training Statistics',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildTableRow('Total Workouts', statistics['totalWorkouts']?.toString() ?? '0'),
            _buildTableRow('Total Volume', '${(statistics['totalVolume'] ?? 0) / 1000} tons'),
            _buildTableRow('Average Workout Duration', '${statistics['avgDuration'] ?? 0} min'),
            _buildTableRow('Current Streak', '${statistics['currentStreak'] ?? 0} days'),
            _buildTableRow('Longest Streak', '${statistics['longestStreak'] ?? 0} days'),
            _buildTableRow('Personal Records', statistics['totalPRs']?.toString() ?? '0'),
            _buildTableRow('Most Trained Muscle', statistics['mostTrainedMuscle'] ?? 'N/A'),
            _buildTableRow('Favorite Exercise', statistics['favoriteExercise'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }
  
  /// Build PDF personal records page
  static pw.Widget _buildPersonalRecordsPage(
    pw.Context context,
    List<PersonalRecord> personalRecords,
  ) {
    final sortedPRs = personalRecords.toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Personal Records',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Exercise', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...sortedPRs.take(20).map((pr) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_dateFormat.format(pr.achievedAt)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(pr.exerciseName),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(pr.type.name),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_formatPRValue(pr)),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  /// Build PDF workouts page
  static pw.Widget _buildWorkoutsPage(
    pw.Context context,
    List<AnalyticsActivity> activities,
  ) {
    final recentActivities = activities.take(30).toList();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Workouts',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Exercise', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Sets', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Volume', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Best Set', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            ...recentActivities.map((activity) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_dateFormat.format(activity.date)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(activity.exerciseName),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(activity.sets.length.toString()),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('${activity.totalVolume.toStringAsFixed(0)}kg'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_getBestSet(activity)),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  /// Build PDF insights page
  static pw.Widget _buildInsightsPage(
    pw.Context context,
    List<TrainingInsight> insights,
  ) {
    final highPriorityInsights = insights
        .where((i) => i.priority == InsightPriority.high)
        .take(10)
        .toList();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Training Insights',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        ...highPriorityInsights.map((insight) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 15),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                insight.title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(insight.message),
              pw.SizedBox(height: 5),
              pw.Text(
                'Recommendation: ${insight.recommendation}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  /// Helper method to build table rows
  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
  
  /// Generate workout CSV data
  static List<List<dynamic>> _generateWorkoutCSV(List<AnalyticsActivity> activities) {
    List<List<dynamic>> rows = [
      ['Date', 'Exercise', 'Sets', 'Total Reps', 'Total Volume (kg)', 'Max Weight (kg)', 'Duration (min)']
    ];
    
    for (final activity in activities) {
      rows.add([
        _dateFormat.format(activity.date),
        activity.exerciseName,
        activity.sets.length,
        activity.totalReps,
        activity.totalVolume.toStringAsFixed(1),
        activity.maxWeight.toStringAsFixed(1),
        activity.duration ?? 0,
      ]);
    }
    
    return rows;
  }
  
  /// Generate exercise CSV data
  static List<List<dynamic>> _generateExerciseCSV(List<AnalyticsActivity> activities) {
    List<List<dynamic>> rows = [
      ['Date', 'Exercise', 'Set', 'Reps', 'Weight (kg)', 'Volume (kg)', 'RPE', 'Rest (sec)']
    ];
    
    for (final activity in activities) {
      for (int i = 0; i < activity.sets.length; i++) {
        final set = activity.sets[i];
        rows.add([
          _dateFormat.format(activity.date),
          activity.exerciseName,
          i + 1,
          set.reps,
          set.weight.toStringAsFixed(1),
          (set.weight * set.reps).toStringAsFixed(1),
          set.rpe ?? '',
          set.restTime ?? '',
        ]);
      }
    }
    
    return rows;
  }
  
  /// Generate volume CSV data
  static List<List<dynamic>> _generateVolumeCSV(List<AnalyticsActivity> activities) {
    // Group by date
    Map<DateTime, double> dailyVolume = {};
    
    for (final activity in activities) {
      final date = DateTime(activity.date.year, activity.date.month, activity.date.day);
      dailyVolume[date] = (dailyVolume[date] ?? 0) + activity.totalVolume;
    }
    
    List<List<dynamic>> rows = [
      ['Date', 'Total Volume (kg)', 'Total Volume (tons)']
    ];
    
    final sortedDates = dailyVolume.keys.toList()..sort();
    for (final date in sortedDates) {
      final volume = dailyVolume[date]!;
      rows.add([
        _dateFormat.format(date),
        volume.toStringAsFixed(1),
        (volume / 1000).toStringAsFixed(3),
      ]);
    }
    
    return rows;
  }
  
  /// Generate personal records CSV data
  static List<List<dynamic>> _generatePRCSV(List<AnalyticsActivity> activities) {
    List<List<dynamic>> rows = [
      ['Date', 'Exercise', 'Type', 'Value', 'Previous Best', 'Improvement %']
    ];
    
    // Track PRs per exercise
    Map<String, Map<String, double>> exercisePRs = {};
    
    for (final activity in activities) {
      final exercise = activity.exerciseName;
      exercisePRs[exercise] ??= {};
      
      // Check for weight PR
      if (activity.maxWeight > (exercisePRs[exercise]!['weight'] ?? 0)) {
        final previous = exercisePRs[exercise]!['weight'] ?? 0;
        final improvement = previous > 0 ? ((activity.maxWeight - previous) / previous * 100) : 0;
        
        rows.add([
          _dateFormat.format(activity.date),
          exercise,
          'Weight',
          '${activity.maxWeight.toStringAsFixed(1)}kg',
          previous > 0 ? '${previous.toStringAsFixed(1)}kg' : 'N/A',
          improvement > 0 ? '+${improvement.toStringAsFixed(1)}%' : 'First Record',
        ]);
        
        exercisePRs[exercise]!['weight'] = activity.maxWeight;
      }
      
      // Check for volume PR
      if (activity.totalVolume > (exercisePRs[exercise]!['volume'] ?? 0)) {
        final previous = exercisePRs[exercise]!['volume'] ?? 0;
        final improvement = previous > 0 ? ((activity.totalVolume - previous) / previous * 100) : 0;
        
        rows.add([
          _dateFormat.format(activity.date),
          exercise,
          'Volume',
          '${activity.totalVolume.toStringAsFixed(0)}kg',
          previous > 0 ? '${previous.toStringAsFixed(0)}kg' : 'N/A',
          improvement > 0 ? '+${improvement.toStringAsFixed(1)}%' : 'First Record',
        ]);
        
        exercisePRs[exercise]!['volume'] = activity.totalVolume;
      }
    }
    
    return rows;
  }
  
  /// Format PR value for display
  static String _formatPRValue(PersonalRecord pr) {
    switch (pr.type) {
      case PRType.weight:
      case PRType.oneRM:
        return '${pr.value.toStringAsFixed(1)}kg';
      case PRType.volume:
        return '${pr.value.toStringAsFixed(0)}kg';
      case PRType.reps:
      case PRType.totalSets:
        return pr.value.toInt().toString();
      case PRType.duration:
        return '${pr.value.toInt()}min';
    }
  }
  
  /// Get best set from activity
  static String _getBestSet(AnalyticsActivity activity) {
    if (activity.sets.isEmpty) return 'N/A';
    
    final bestSet = activity.sets.reduce((a, b) => 
      (a.weight * a.reps) > (b.weight * b.reps) ? a : b
    );
    
    return '${bestSet.weight.toStringAsFixed(1)}kg x ${bestSet.reps}';
  }
}

/// Export CSV types
enum ExportCSVType {
  workouts,
  exercises,
  volume,
  personalRecords,
}