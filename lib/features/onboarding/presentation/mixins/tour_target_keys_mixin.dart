import 'package:flutter/material.dart';

/// Mixin that provides GlobalKeys for tour target widgets
///
/// Use this mixin in screens that participate in the onboarding tour.
/// Attach the keys to the target widgets using the `key` parameter.
mixin TourTargetKeysMixin<T extends StatefulWidget> on State<T> {
  // GlobalKeys for each tour target widget
  final GlobalKey aiCoachCardKey = GlobalKey(debugLabel: 'aiCoachCard');
  final GlobalKey quickStartFabKey = GlobalKey(debugLabel: 'quickStartFab');
  final GlobalKey smartWorkoutCardKey = GlobalKey(debugLabel: 'smartWorkoutCard');
  final GlobalKey analyticsCardKey = GlobalKey(debugLabel: 'analyticsCard');
  final GlobalKey historyCardKey = GlobalKey(debugLabel: 'historyCard');
  final GlobalKey communityCardKey = GlobalKey(debugLabel: 'communityCard');
  final GlobalKey notificationHubKey = GlobalKey(debugLabel: 'notificationHub');

  /// Get map of all target keys for the tour overlay
  Map<String, GlobalKey> get tourTargetKeys => {
        'aiCoach': aiCoachCardKey,
        'fab': quickStartFabKey,
        'smartWorkout': smartWorkoutCardKey,
        'analytics': analyticsCardKey,
        'history': historyCardKey,
        'community': communityCardKey,
        'notifications': notificationHubKey,
      };
}
