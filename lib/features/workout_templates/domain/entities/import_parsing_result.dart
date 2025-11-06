import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';

/// Result of template import parsing operation
class ImportParsingResult {

  const ImportParsingResult({
    this.success = true,
    this.errorMessage,
    this.data,
    this.template,
  });
  final bool success;
  final String? errorMessage;
  final dynamic data;
  final WorkoutTemplateImportData? template;

  /// Creates a copy with optional new values
  ImportParsingResult copyWith({
    bool? success,
    String? errorMessage,
    dynamic data,
    WorkoutTemplateImportData? template,
  }) {
    return ImportParsingResult(
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      template: template ?? this.template,
    );
  }
}
