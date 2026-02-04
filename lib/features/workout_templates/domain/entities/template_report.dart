/// Template Report Entity
///
/// Entity for reporting inappropriate/misleading community templates.
///
/// **Layer**: Domain - Entity
/// **Feature**: workout_templates
library;

enum TemplateReportReason {
  inappropriateContent,
  misleading,
  spam,
  copyright,
  other,
}

class TemplateReport {
  const TemplateReport({
    required this.id,
    required this.templateId,
    required this.reporterId,
    required this.reason,
    this.details,
    required this.createdAt,
  });

  factory TemplateReport.fromJson(Map<String, dynamic> json) {
    return TemplateReport(
      id: json['id'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      reason: TemplateReportReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => TemplateReportReason.other,
      ),
      details: json['details'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  final String id;
  final String templateId;
  final String reporterId;
  final TemplateReportReason reason;
  final String? details;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'reporterId': reporterId,
      'reason': reason.name,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
