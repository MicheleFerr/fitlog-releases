/// Create Template Popup
///
/// Section 3 of the Quick Actions overlay.
/// Uses CNPopupMenuButton to show a native popup menu
/// with template creation options.
library;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/core/config/feature_flags.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Popup button for template creation/import
class CreateTemplatePopup extends StatelessWidget {
  const CreateTemplatePopup({
    required this.onCreateManually,
    required this.onImport,
    super.key,
  });

  /// Called when user selects "Create Manually"
  final VoidCallback onCreateManually;

  /// Called when user selects "Import"
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final items = [
      CNPopupMenuItem(
        label: context.l10n.createManually,
        icon: const CNSymbol('square.and.pencil'),
      ),
      if (FeatureFlags.workoutImportEnabled)
        CNPopupMenuItem(
          label: context.l10n.quickActionImport,
          icon: const CNSymbol('square.and.arrow.down'),
        ),
    ];

    return CNPopupMenuButton(
      buttonLabel: context.l10n.createTemplate,
      buttonStyle: CNButtonStyle.glass,
      height: 44,
      items: items,
      onSelected: (index) {
        switch (index) {
          case 0:
            onCreateManually();
          case 1:
            if (FeatureFlags.workoutImportEnabled) {
              onImport();
            }
        }
      },
    );
  }
}
