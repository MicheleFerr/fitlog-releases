import 'package:flutter/material.dart';

/// TODO: Implement LocationStep widget
/// This is a placeholder to fix compilation errors
class LocationStep extends StatelessWidget {

  const LocationStep({
    super.key,
    required this.maxDistance,
    this.currentLocation,
    required this.onDistanceChanged,
    required this.onLocationSet,
    required this.onNext,
    required this.onBack,
  });
  final double maxDistance;
  final String? currentLocation;
  final void Function(double) onDistanceChanged;
  final void Function(double, double, String) onLocationSet;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TODO: LocationStep implementation'),
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
