import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';

/// Dati dei record personali per un esercizio
class ExerciseRecordsData {
  const ExerciseRecordsData({
    required this.exerciseName,
    required this.maxWeight,
    this.maxWeightDate,
    this.maxWeightReps,
    required this.best1RM,
    this.best1RMDate,
    this.best1RMWeight,
    this.best1RMReps,
    required this.bestSetVolume,
    this.bestSetVolumeDate,
    this.bestSetVolumeWeight,
    this.bestSetVolumeReps,
    required this.totalWorkouts,
    required this.historyData,
  });

  final String exerciseName;
  final double maxWeight;
  final DateTime? maxWeightDate;
  final int? maxWeightReps;
  final double best1RM;
  final DateTime? best1RMDate;
  final double? best1RMWeight;
  final int? best1RMReps;
  final double bestSetVolume;
  final DateTime? bestSetVolumeDate;
  final double? bestSetVolumeWeight;
  final int? bestSetVolumeReps;
  final int totalWorkouts;
  final Map<DateTime, List<ExerciseHistoryData>> historyData;
}

/// Servizio per generazione PDF statistiche esercizio
class PdfExerciseService {
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Genera un PDF con le statistiche dell'esercizio
  static Future<Uint8List> generateExercisePdf(ExerciseRecordsData data) async {
    final pdf = pw.Document();

    // Colori del tema FitLog Pro
    final primaryColor = PdfColor.fromHex('#2196F3');
    final accentColor = PdfColor.fromHex('#FF9800');
    final successColor = PdfColor.fromHex('#4CAF50');
    final darkColor = PdfColor.fromHex('#212121');
    final lightGray = PdfColor.fromHex('#757575');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header FitLog Pro
            _buildHeader(primaryColor),
            pw.SizedBox(height: 24),

            // Titolo Esercizio
            _buildExerciseTitle(data.exerciseName, darkColor),
            pw.SizedBox(height: 8),

            // Sottotitolo con data generazione
            pw.Text(
              'Report generato il ${_dateFormatter.format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 11, color: lightGray),
            ),
            pw.SizedBox(height: 30),

            // Sezione Record Personali
            _buildRecordsSection(data, primaryColor, successColor, lightGray),
            pw.SizedBox(height: 30),

            // Sezione Cronologia
            if (data.historyData.isNotEmpty)
              _buildHistorySection(data, primaryColor, accentColor, lightGray),
          ];
        },
        footer: (pw.Context context) =>
            _buildFooter(primaryColor, lightGray, context),
      ),
    );

    return pdf.save();
  }

  /// Header FitLog Pro
  static pw.Widget _buildHeader(PdfColor primaryColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primaryColor, primaryColor.shade(0.7)],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FitLog Pro',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Exercise Performance Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white.shade(0.8),
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white.shade(0.2),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'PR',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Titolo esercizio
  static pw.Widget _buildExerciseTitle(String name, PdfColor darkColor) {
    return pw.Text(
      name,
      style: pw.TextStyle(
        fontSize: 26,
        fontWeight: pw.FontWeight.bold,
        color: darkColor,
      ),
    );
  }

  /// Sezione Record Personali
  static pw.Widget _buildRecordsSection(
    ExerciseRecordsData data,
    PdfColor primaryColor,
    PdfColor successColor,
    PdfColor lightGray,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: pw.BoxDecoration(
            color: successColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Text(
            'RECORD PERSONALI',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        // Cards record
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: successColor.shade(0.3)),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(8),
              bottomRight: pw.Radius.circular(8),
            ),
          ),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              // Max Weight
              _buildRecordCard(
                'Max Peso',
                '${data.maxWeight.toStringAsFixed(1)} kg',
                data.maxWeightDate != null
                    ? '${data.maxWeightReps ?? 0} reps - ${_dateFormatter.format(data.maxWeightDate!)}'
                    : null,
                primaryColor,
                lightGray,
              ),

              // Best 1RM
              _buildRecordCard(
                'Best 1RM',
                '${data.best1RM.toStringAsFixed(1)} kg',
                data.best1RMDate != null && data.best1RMWeight != null
                    ? '${data.best1RMWeight!.toStringAsFixed(1)}kg x ${data.best1RMReps} - ${_dateFormatter.format(data.best1RMDate!)}'
                    : null,
                successColor,
                lightGray,
              ),

              // Best Volume
              _buildRecordCard(
                'Best Volume',
                '${data.bestSetVolume.toStringAsFixed(0)} kg',
                data.bestSetVolumeDate != null &&
                        data.bestSetVolumeWeight != null
                    ? '${data.bestSetVolumeWeight!.toStringAsFixed(1)}kg x ${data.bestSetVolumeReps} - ${_dateFormatter.format(data.bestSetVolumeDate!)}'
                    : null,
                PdfColor.fromHex('#9C27B0'),
                lightGray,
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 12),

        // Stats box
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: primaryColor.shade(0.05),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: primaryColor.shade(0.2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Totale allenamenti con questo esercizio: ',
                style: pw.TextStyle(fontSize: 12, color: lightGray),
              ),
              pw.Text(
                '${data.totalWorkouts}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card singolo record
  static pw.Widget _buildRecordCard(
    String title,
    String value,
    String? subtitle,
    PdfColor color,
    PdfColor lightGray,
  ) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.05),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color.shade(0.3)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              color: lightGray,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(fontSize: 8, color: lightGray),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Sezione Cronologia
  static pw.Widget _buildHistorySection(
    ExerciseRecordsData data,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor lightGray,
  ) {
    // Ordina le date (più recenti prima) e prendi le ultime 10
    final sortedDates = data.historyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final recentDates = sortedDates.take(10).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: pw.BoxDecoration(
            color: accentColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Text(
            'CRONOLOGIA RECENTE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        // Tabella cronologia
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: accentColor.shade(0.3)),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(8),
              bottomRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: accentColor.shade(0.1)),
                children: [
                  _buildTableHeader('Data'),
                  _buildTableHeader('Set'),
                  _buildTableHeader('Miglior Set'),
                  _buildTableHeader('Volume'),
                ],
              ),
              // Righe
              ...recentDates.asMap().entries.map((entry) {
                final date = entry.value;
                final sets = data.historyData[date]!;
                final isEven = entry.key % 2 == 0;

                // Calcola il miglior set e volume totale
                double bestWeight = 0;
                int bestReps = 0;
                double totalVolume = 0;

                for (final set in sets) {
                  final weight = set.weight ?? 0;
                  final reps = set.reps ?? 0;
                  final volume = weight * reps;
                  totalVolume += volume;

                  if (weight > bestWeight) {
                    bestWeight = weight;
                    bestReps = reps;
                  }
                }

                return pw.TableRow(
                  decoration: isEven
                      ? null
                      : const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell(_dateFormatter.format(date), null),
                    _buildTableCell('${sets.length}', lightGray),
                    _buildTableCell(
                      bestWeight > 0
                          ? '${bestWeight.toStringAsFixed(1)}kg x $bestReps'
                          : '-',
                      primaryColor,
                      bold: true,
                    ),
                    _buildTableCell(
                      '${totalVolume.toStringAsFixed(0)} kg',
                      lightGray,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),

        if (sortedDates.length > 10)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              '+ ${sortedDates.length - 10} sessioni precedenti',
              style: pw.TextStyle(
                fontSize: 10,
                color: lightGray,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    PdfColor? color, {
    bool bold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  /// Footer con branding
  static pw.Widget _buildFooter(
    PdfColor primaryColor,
    PdfColor lightGray,
    pw.Context context,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: lightGray.shade(0.3))),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'FitLog Pro',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Generato da FitLog Pro',
                style: pw.TextStyle(fontSize: 10, color: lightGray),
              ),
            ],
          ),
          pw.Text(
            'Pagina ${context.pageNumber} di ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10, color: lightGray),
          ),
        ],
      ),
    );
  }

  /// Condividi il PDF dell'esercizio
  /// Returns ShareResultStatus to handle dismiss/success
  static Future<ShareResultStatus> shareExercisePdf(
    ExerciseRecordsData data,
  ) async {
    File? tempFile;
    try {
      final pdfData = await generateExercisePdf(data);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = '${data.exerciseName.replaceAll(' ', '_')}_stats.pdf';
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pdfData);

      // Share with share_plus
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(tempFile.path)], subject: data.exerciseName),
      );

      return result.status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sharing exercise PDF: $e');
      }
      rethrow;
    } finally {
      // Clean up temp file
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
