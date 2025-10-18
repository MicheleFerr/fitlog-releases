import 'package:flutter/material.dart';

/// TODO: Implement ProfileStep widget
/// This is a placeholder to fix compilation errors
class ProfileStep extends StatelessWidget {

  const ProfileStep({
    super.key,
    this.instagramHandle,
    this.bio,
    required this.allowMessages,
    required this.showOnMap,
    required this.onInstagramChanged,
    required this.onBioChanged,
    required this.onAllowMessagesChanged,
    required this.onShowOnMapChanged,
    required this.onNext,
    required this.onBack,
  });
  final String? instagramHandle;
  final String? bio;
  final bool allowMessages;
  final bool showOnMap;
  final void Function(String?) onInstagramChanged;
  final void Function(String?) onBioChanged;
  final void Function(bool) onAllowMessagesChanged;
  final void Function(bool) onShowOnMapChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TODO: ProfileStep implementation'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
