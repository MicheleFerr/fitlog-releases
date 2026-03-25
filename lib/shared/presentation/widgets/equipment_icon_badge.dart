library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class EquipmentIconBadge extends StatelessWidget {
  const EquipmentIconBadge({
    super.key,
    required this.equipment,
    this.size = 22,
    this.showBackground = true,
  });

  final String equipment;
  final double size;
  final bool showBackground;

  static const String _basePath = 'assets/images/equipment';
  static const Map<String, String> _fileNames = {
    'ab_wheel': 'ab_wheel',
    'altro': 'altro',
    'assistito': 'assistito',
    'barra_ez': 'barra_ez',
    'bilanciere': 'bilanciere',
    'cavi': 'cavi',
    'corde': 'corde',
    'corpo_libero': 'corpo_libero',
    'cyclette': 'cyclette',
    'elastici': 'elastici',
    'elastico': 'elastici',
    'ergometro': 'ergometro',
    'fitball': 'fitball',
    'foam_roller': 'foam_roller',
    'kettlebell': 'kettlebell',
    'macchina': 'macchina',
    'manubri': 'manubri',
    'palla_medica': 'palla_medica',
    'pneumatico': 'pneumatico',
    'ski_erg': 'skierg',
    'skierg': 'skierg',
    'slitta': 'slitta',
    'trap_bar': 'trap_bar',
    'vario': 'vario',
    'zavorre': 'zavorre',
  };

  @override
  Widget build(BuildContext context) {
    final iconPath = _getEquipmentIconPath(equipment);
    final icon = Image.asset(
      iconPath,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        AppIcons.fitnessCenter,
        size: size - 2,
        color: context.colors.onSurfaceVariant,
      ),
    );

    if (!showBackground) {
      return SizedBox(width: size, height: size, child: icon);
    }

    return Container(
      width: size + 8,
      height: size + 8,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: icon,
    );
  }

  String _getEquipmentIconPath(String value) {
    final normalized = _normalizeKey(value);
    final mapped = _fileNames[normalized] ?? normalized;
    return '$_basePath/$mapped.png';
  }

  String _normalizeKey(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
