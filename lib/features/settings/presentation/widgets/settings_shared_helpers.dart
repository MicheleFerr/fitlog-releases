import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/cn_switch_list_tile.dart';

/// Shared setting tile builder used across multiple settings sections.
Widget buildSettingTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  Widget? leading,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  return ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    leading: leading,
    trailing:
        trailing ??
        const SemanticIcon(
          icon: AppIcons.chevronRight,
          semanticLabel: 'Chevron right',
        ),
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
  );
}

/// Shared switch tile builder used across multiple settings sections.
Widget buildSwitchTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
  Widget? leading,
}) {
  return CNSwitchListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
    secondary: leading,
    contentPadding: EdgeInsets.zero,
  );
}

/// Info tooltip for technical terms (RPE, RIR, Ghost Mode, etc.)
Widget buildInfoTooltip(BuildContext context, String message) {
  return Tooltip(
    message: message,
    triggerMode: TooltipTriggerMode.tap,
    showDuration: const Duration(seconds: 5),
    child: SemanticIcon(
      icon: AppIcons.info,
      semanticLabel: 'Info',
      size: AppIconSize.small,
      color: context.colors.onSurfaceVariant,
    ),
  );
}
