import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/export_format.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_export_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/analytics_service.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';

/// Provider for template export service
final templateExportServiceProvider = Provider<TemplateExportService>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return TemplateExportService(analyticsService);
});

/// State for template export
class TemplateExportState {

  const TemplateExportState({
    this.isExporting = false,
    this.exportedData,
    this.error,
  });
  final bool isExporting;
  final String? exportedData;
  final String? error;

  TemplateExportState copyWith({
    bool? isExporting,
    String? exportedData,
    String? error,
  }) {
    return TemplateExportState(
      isExporting: isExporting ?? this.isExporting,
      exportedData: exportedData ?? this.exportedData,
      error: error,
    );
  }
}

/// Provider for template export state
final templateExportProvider = StateNotifierProvider<TemplateExportNotifier, TemplateExportState>((ref) {
  return TemplateExportNotifier(ref);
});

class TemplateExportNotifier extends StateNotifier<TemplateExportState> {

  TemplateExportNotifier(this._ref) : super(const TemplateExportState());
  final Ref _ref;

  Future<String> exportTemplates(
    List<WorkoutTemplate> templates, {
    ExportFormat format = ExportFormat.json,
    bool includeAnalytics = false,
  }) async {
    state = state.copyWith(isExporting: true, error: null);

    try {
      final exportService = _ref.read(templateExportServiceProvider);
      final user = await _ref.read(unifiedUserProvider.future);

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final exportedData = await exportService.exportTemplates(
        templates,
        user,
        format: format,
        includeAnalytics: includeAnalytics,
      );

      state = state.copyWith(
        isExporting: false,
        exportedData: exportedData,
      );

      return exportedData;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}
