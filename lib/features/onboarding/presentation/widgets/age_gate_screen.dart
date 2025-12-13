import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Screen that verifies user age before allowing registration.
///
/// GDPR Art. 8 compliance:
/// - Blocks users under 14 (Italian privacy law threshold)
/// - Shows enhanced disclaimer for 14-17 (minors with parental consent)
/// - Allows 18+ without restrictions
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AgeGateScreen(
///       onAgeVerified: (birthDate) {
///         // Save birth date, proceed to registration
///       },
///       onAgeBlocked: () {
///         // Show error, exit registration flow
///       },
///     ),
///   ),
/// );
/// ```
class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({
    super.key,
    required this.onAgeVerified,
    required this.onAgeBlocked,
  });

  final Function(DateTime birthDate) onAgeVerified;
  final VoidCallback onAgeBlocked;

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  DateTime? _selectedBirthDate;

  /// Minimum age requirement (14 years per Italian law)
  static const int _minAgeYears = 14;

  /// Minor age threshold (18 years)
  static const int _minorThresholdYears = 18;

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: context.l10n.ageGateBirthDate,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _verifyContinue() {
    if (_selectedBirthDate == null) {
      // Show error: birth date required
      SnackBarService.showError(
        context,
        'Please select your date of birth',
      );
      return;
    }

    final age = _calculateAge(_selectedBirthDate!);

    if (age < _minAgeYears) {
      // Block: under 14
      _showAgeRestrictionDialog();
    } else if (age < _minorThresholdYears) {
      // Warning: 14-17 minor
      _showMinorWarningDialog();
    } else {
      // Allow: 18+
      widget.onAgeVerified(_selectedBirthDate!);
    }
  }

  void _showAgeRestrictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ageRestrictionTitle),
        content: Text(context.l10n.ageRestrictionMessage),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeBlocked();
            },
            child: Text(context.l10n.ageRestrictionOk),
          ),
        ],
      ),
    );
  }

  void _showMinorWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.warning,
              semanticLabel: 'Warning',
              size: AppIconSize.large,
              color: context.iconWarning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.ageMinorWarningTitle),
            ),
          ],
        ),
        content: Text(context.l10n.ageMinorWarningMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeBlocked();
            },
            child: Text(
              context.l10n.ageMinorWarningDecline,
              style: TextStyle(color: context.colors.error),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeVerified(_selectedBirthDate!);
            },
            child: Text(context.l10n.ageMinorWarningConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.ageGateTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SemanticIcon(
              icon: AppIcons.calendar,
              semanticLabel: context.l10n.ageGateTitle,
              size: AppIconSize.xxlarge,
              color: context.iconPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.ageGateTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.ageGateInstructions,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _selectBirthDate,
              icon: SemanticIcon(
                icon: AppIcons.calendar,
                semanticLabel: context.l10n.ageGateBirthDate,
                size: AppIconSize.medium,
                color: context.iconPrimary,
              ),
              label: Text(
                _selectedBirthDate == null
                    ? context.l10n.ageGateBirthDate
                    : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _verifyContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(context.l10n.ageGateContinue),
            ),
            const SizedBox(height: 16),
            Text(
              'Required by GDPR and Italian privacy laws',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
