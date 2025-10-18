import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';
import 'package:flutter/foundation.dart';

class PdfTemplateService {
  /// Genera un PDF dal template di allenamento
  /// [detailLevel] specifica il livello di dettaglio per la visualizzazione dei set
  static Future<Uint8List> generateTemplatePdf(
    WorkoutTemplate template, {
    PdfDetailLevel detailLevel = PdfDetailLevel.compact,
  }) async {
    final pdf = pw.Document();

    // Colori del tema
    final primaryColor = PdfColor.fromHex('#2196F3');
    final accentColor = PdfColor.fromHex('#FF9800');
    final darkColor = PdfColor.fromHex('#212121');
    final lightGray = PdfColor.fromHex('#757575');

    // Aggiungi pagina
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(primaryColor),
            pw.SizedBox(height: 20),

            // Titolo Template
            _buildTemplateTitle(template, darkColor, primaryColor),
            pw.SizedBox(height: 20),

            // Info Template
            _buildTemplateInfo(template, lightGray),
            pw.SizedBox(height: 30),

            // Esercizi
            _buildExercisesSection(template.exercises, primaryColor, lightGray, detailLevel),
            pw.SizedBox(height: 40),

            // Note e suggerimenti
            if (template.description.isNotEmpty)
              _buildNotesSection(template.description, accentColor, lightGray),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                color: lightGray,
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Header dell'app
  static pw.Widget _buildHeader(PdfColor primaryColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: primaryColor.shade(0.1),
        borderRadius: pw.BorderRadius.circular(8),
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
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.Text(
                'Workout Template',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: primaryColor.shade(0.7),
                ),
              ),
            ],
          ),
          pw.Text(
            DateTime.now().toString().substring(0, 10),
            style: pw.TextStyle(
              fontSize: 12,
              color: primaryColor.shade(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Titolo del template
  static pw.Widget _buildTemplateTitle(
    WorkoutTemplate template,
    PdfColor darkColor,
    PdfColor primaryColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          template.name,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: darkColor,
          ),
        ),
        if (template.isCustom)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: primaryColor.shade(0.1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Custom Template',
              style: pw.TextStyle(
                fontSize: 10,
                color: primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  /// Info del template
  static pw.Widget _buildTemplateInfo(
    WorkoutTemplate template,
    PdfColor lightGray,
  ) {
    return pw.Row(
      children: [
        _buildInfoItem(
          '${template.exercises.length} Exercises',
          lightGray,
        ),
        pw.SizedBox(width: 30),
        _buildInfoItem(
          '~${template.estimatedDuration} minutes',
          lightGray,
        ),
        if (template.usageCount > 0) ...[
          pw.SizedBox(width: 30),
          _buildInfoItem(
            'Used ${template.usageCount} times',
            lightGray,
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildInfoItem(String text, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 6,
          height: 6,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: color,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Sezione esercizi
  static pw.Widget _buildExercisesSection(
    List<ExerciseTemplate> exercises,
    PdfColor primaryColor,
    PdfColor lightGray,
    PdfDetailLevel detailLevel,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Text(
            'WORKOUT PROGRAM',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor.shade(0.3)),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(8),
              bottomRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header tabella
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: primaryColor.shade(0.05),
                ),
                children: [
                  _buildTableHeader('#'),
                  _buildTableHeader('Exercise'),
                  _buildTableHeader('Sets x Reps'),
                  _buildTableHeader('Weight'),
                  _buildTableHeader('Notes'),
                ],
              ),
              // Righe esercizi
              ...exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final isEven = index % 2 == 0;

                return pw.TableRow(
                  decoration: isEven
                      ? null
                      : const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('${index + 1}', lightGray),
                    _buildTableCell(exercise.exerciseName, null, bold: true),
                    _buildTableCell(
                      _formatSetsAndReps(exercise, detailLevel),
                      lightGray,
                    ),
                    _buildTableCell('_____', lightGray),
                    _buildTableCell(
                      exercise.restTime != null
                          ? 'Rest: ${exercise.restTime}s'
                          : '',
                      lightGray,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    PdfColor? color, {
    bool bold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
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

  static String _formatSetsAndReps(
    ExerciseTemplate exercise,
    PdfDetailLevel detailLevel,
  ) {
    // Se non ci sono set, ritorna un valore di default
    if (exercise.sets.isEmpty) {
      return '3 x 10';
    }

    switch (detailLevel) {
      case PdfDetailLevel.compact:
        // Formato compatto: raggruppa set identici
        final Map<int, int> repsCount = {};
        for (final set in exercise.sets) {
          final reps = set.targetReps ?? 10;
          repsCount[reps] = (repsCount[reps] ?? 0) + 1;
        }
        return repsCount.entries
            .map((e) => '${e.value} x ${e.key}')
            .join(', ');

      case PdfDetailLevel.detailedWithWeight:
        // Formato dettagliato con peso: mostra ogni set con peso e reps
        return exercise.sets.asMap().entries.map((entry) {
          final setNum = entry.key + 1;
          final set = entry.value;
          final weight = set.targetWeight != null ? '${set.targetWeight}kg' : '-';
          final reps = set.targetReps ?? 10;
          return 'Set $setNum: $weight x $reps';
        }).join('\n');

      case PdfDetailLevel.detailedWithoutWeight:
        // Formato dettagliato senza peso: mostra solo reps
        return exercise.sets.asMap().entries.map((entry) {
          final setNum = entry.key + 1;
          final set = entry.value;
          final reps = set.targetReps ?? 10;
          return 'Set $setNum: $reps reps';
        }).join('\n');
    }
  }

  /// Sezione note
  static pw.Widget _buildNotesSection(
    String description,
    PdfColor accentColor,
    PdfColor lightGray,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: accentColor.shade(0.3)),
        borderRadius: pw.BorderRadius.circular(8),
        color: accentColor.shade(0.05),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: accentColor,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '!',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Notes & Tips',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            description,
            style: pw.TextStyle(
              fontSize: 11,
              color: lightGray,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Condividi il PDF del template
  static Future<void> shareTemplatePdf(
    WorkoutTemplate template, {
    PdfDetailLevel detailLevel = PdfDetailLevel.compact,
  }) async {
    try {
      final pdfData = await generateTemplatePdf(template, detailLevel: detailLevel);

      await Printing.sharePdf(
        bytes: pdfData,
        filename: '${template.name.replaceAll(' ', '_')}_template.pdf',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sharing PDF: $e');
      }
      rethrow;
    }
  }

  /// Stampa il PDF del template
  static Future<void> printTemplatePdf(
    WorkoutTemplate template, {
    PdfDetailLevel detailLevel = PdfDetailLevel.compact,
  }) async {
    try {
      final pdfData = await generateTemplatePdf(template, detailLevel: detailLevel);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: '${template.name} - Template',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error printing PDF: $e');
      }
      rethrow;
    }
  }
}