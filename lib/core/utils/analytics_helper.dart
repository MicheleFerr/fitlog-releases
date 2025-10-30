class AnalyticsHelper {
  static Map<String, Object> sanitizeParameters(
    Map<String, dynamic> params,
  ) {
    final result = <String, Object>{};

    params.forEach((key, value) {
      if (value == null) {
        return; // Skip null values - Firebase Analytics doesn't accept them
      }

      if (value is bool) {
        result[key] = value ? 1 : 0; // Converti bool a int
      } else if (value is String || value is num) {
        result[key] = value as Object;
      } else {
        result[key] = value.toString(); // Converti altro a string
      }
    });

    return result;
  }
}