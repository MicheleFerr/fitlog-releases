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
}
