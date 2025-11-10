// Test file per verificare che il pre-commit hook funzioni velocemente
// dopo aver fixato tutti e 3 i check incompleti

import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hook test - should pass quickly');
  }
}
