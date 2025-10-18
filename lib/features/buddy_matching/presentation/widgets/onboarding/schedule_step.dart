import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';

/// TODO: Implement ScheduleStep widget
/// This is a placeholder to fix compilation errors
class ScheduleStep extends StatelessWidget {

  const ScheduleStep({
    super.key,
    required this.selectedTimes,
    required this.selectedDays,
    required this.onTimesChanged,
    required this.onDaysChanged,
    required this.onNext,
    required this.onBack,
  });
  final List<PreferredTime> selectedTimes;
  final List<String> selectedDays;
  final void Function(List<PreferredTime>) onTimesChanged;
  final void Function(List<String>) onDaysChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TODO: ScheduleStep implementation'),
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
