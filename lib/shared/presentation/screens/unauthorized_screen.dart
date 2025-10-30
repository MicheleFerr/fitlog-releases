/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/screens
/// 🎯 Feature: Unauthorized Screen (STUB)
/// 🔧 Type: Screen Widget
///
/// Temporary stub to prevent compilation errors
library;

import 'package:flutter/material.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unauthorized')),
      body: const Center(
        child: Text('You do not have permission to access this page.'),
      ),
    );
  }
}
