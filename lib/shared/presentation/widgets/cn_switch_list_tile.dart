import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

/// A [ListTile] with a trailing [CNSwitch].
///
/// Drop-in replacement for [SwitchListTile] that renders a native iOS
/// UISwitch on Apple platforms via the `cupertino_native` package.
class CNSwitchListTile extends StatelessWidget {
  const CNSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.secondary,
    this.contentPadding,
    this.dense,
  });

  final Widget title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? subtitle;
  final Widget? secondary;
  final EdgeInsetsGeometry? contentPadding;
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: secondary,
      title: title,
      subtitle: subtitle,
      contentPadding: contentPadding,
      dense: dense,
      trailing: CNSwitch(
        value: value,
        onChanged: onChanged ?? (_) {},
        enabled: onChanged != null,
      ),
      onTap: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}
