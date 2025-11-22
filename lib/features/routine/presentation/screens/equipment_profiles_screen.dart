/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: Equipment Profiles Screen (STUB)
/// 🔧 Type: Screen Widget
///
/// Temporary stub to prevent compilation errors
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class EquipmentProfilesScreen extends StatelessWidget {
  const EquipmentProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.equipmentProfiles)),
      body: Center(
        child: Text(context.l10n.equipmentProfilesUnderConstruction),
      ),
    );
  }
}
