/// 🚨 DEPRECATED: Use InputValidator instead
///
/// This file is deprecated and will be removed in a future release.
/// All functionality has been consolidated into [InputValidator].
///
/// Migration guide:
/// ```dart
/// // OLD:
/// import 'package:gymbro_flutter_new/shared/domain/services/input_sanitizer.dart';
/// InputSanitizer.sanitizeName(input);
///
/// // NEW:
/// import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart';
/// InputValidator.sanitizeName(input);
/// ```
///
/// @deprecated Use [InputValidator] from input_validator.dart instead
library;

import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart';

// Re-export everything from InputValidator for backward compatibility
export 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart'
    show InputValidator, ValidationResult, ValidationException;

/// @deprecated Use [InputValidator] instead
///
/// This class is deprecated. All methods are now available in [InputValidator].
/// This typedef exists only for backward compatibility during migration.
@Deprecated('Use InputValidator instead - this class will be removed')
typedef InputSanitizer = InputValidator;
