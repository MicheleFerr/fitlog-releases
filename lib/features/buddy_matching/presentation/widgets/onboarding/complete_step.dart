import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';

/// TODO: Implement CompleteStep widget
/// This is a placeholder to fix compilation errors
class CompleteStep extends StatelessWidget {

  const CompleteStep({
    super.key,
    required this.preferences,
    required this.onComplete,
    required this.onBack,
  });
  final BuddyPreferences preferences;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TODO: CompleteStep implementation'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onComplete,
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
