/// Log Measurements Popup
///
/// Section 2 of the Quick Actions overlay.
/// Uses CNPopupMenuButton to show a native popup menu
/// with body measurement options.
library;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Popup button for quick measurement logging
class LogMeasurementsPopup extends StatelessWidget {
  const LogMeasurementsPopup({
    required this.onMetricSelected,
    required this.onAllMeasurements,
    super.key,
  });

  /// Called when user selects a specific metric to log
  final void Function(MetricType metric) onMetricSelected;

  /// Called when user selects "Other measurements..."
  final VoidCallback onAllMeasurements;

  /// Menu item definitions with their corresponding MetricType
  /// Items before the divider are "primary", after are "secondary"
  static const _primaryItems = [
    _MenuItem('scalemass', MetricType.weight),
    _MenuItem('ruler', MetricType.waistCircumference),
    _MenuItem('percent', MetricType.bodyFatPercentage),
  ];

  static const _secondaryItems = [
    _MenuItem('figure.arms.open', MetricType.bicepRightCircumference),
    _MenuItem('figure.walk', MetricType.thighRightCircumference),
    _MenuItem('figure.stand', MetricType.chestCircumference),
    _MenuItem(
      'figure.stand.line.dotted.figure.stand',
      MetricType.hipCircumference,
    ),
    _MenuItem(
      'figure.strengthtraining.traditional',
      MetricType.shoulderCircumference,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Build labels using l10n
    final labels = _buildLabels(context);

    return CNPopupMenuButton(
      buttonLabel: context.l10n.quickActionLogMeasurements,
      buttonStyle: CNButtonStyle.glass,
      height: 44,
      items: [
        // Primary items
        for (final item in _primaryItems)
          CNPopupMenuItem(
            label: labels[item.metric]!,
            icon: CNSymbol(item.sfSymbol),
          ),

        // Divider
        const CNPopupMenuDivider(),

        // Secondary items
        for (final item in _secondaryItems)
          CNPopupMenuItem(
            label: labels[item.metric]!,
            icon: CNSymbol(item.sfSymbol),
          ),

        // "Other measurements..."
        CNPopupMenuItem(
          label: context.l10n.quickActionOtherMeasurements,
          icon: const CNSymbol('ellipsis'),
        ),
      ],
      onSelected: (index) => _handleSelection(index),
    );
  }

  void _handleSelection(int index) {
    // Primary: 0, 1, 2
    if (index < _primaryItems.length) {
      onMetricSelected(_primaryItems[index].metric);
      return;
    }

    // Divider is at index 3 (skip it)
    final secondaryStartIndex = _primaryItems.length + 1; // +1 for divider

    // Secondary: 4, 5, 6, 7, 8
    final secondaryIndex = index - secondaryStartIndex;
    if (secondaryIndex >= 0 && secondaryIndex < _secondaryItems.length) {
      onMetricSelected(_secondaryItems[secondaryIndex].metric);
      return;
    }

    // Last item = "Other measurements..."
    onAllMeasurements();
  }

  Map<MetricType, String> _buildLabels(BuildContext context) {
    return {
      MetricType.weight: context.l10n.quickActionWaist == context.l10n.quickActionWaist
          ? context.l10n.weight
          : context.l10n.weight,
      MetricType.waistCircumference: context.l10n.quickActionWaist,
      MetricType.bodyFatPercentage: context.l10n.quickActionBodyFat,
      MetricType.bicepRightCircumference: context.l10n.quickActionArmsLR,
      MetricType.thighRightCircumference: context.l10n.quickActionThighsLR,
      MetricType.chestCircumference: context.l10n.quickActionChest,
      MetricType.hipCircumference: context.l10n.quickActionHips,
      MetricType.shoulderCircumference: context.l10n.quickActionShoulders,
    };
  }
}

class _MenuItem {
  const _MenuItem(this.sfSymbol, this.metric);
  final String sfSymbol;
  final MetricType metric;
}
