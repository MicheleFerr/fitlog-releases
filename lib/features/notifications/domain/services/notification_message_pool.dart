/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/services
/// Feature: Local Notifications System
/// Type: Service - Message Pool & Rotation
///
/// Manages notification message pools and rotation to prevent fatigue.
/// Based on Duolingo's approach: vary messages, use "forgetting curve".
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Factory function that generates a body string from parameters.
typedef BodyFactory = String Function(Map<String, dynamic> params);

/// Service for managing notification message pools and rotation.
///
/// Features:
/// - Pool of 3-5 messages per notification type
/// - Rotation logic to avoid showing same message too often
/// - Parameter substitution for dynamic content (exercise name, streak count)
class NotificationMessagePool {
  final Random _random = Random();

  /// Get a message for the given notification type.
  ///
  /// [type] - The notification type
  /// [l10n] - AppLocalizations for localized messages
  /// [excludeKey] - Optional key to exclude (for rotation)
  /// [params] - Dynamic parameters (exerciseName, streakDays, volumePercent)
  NotificationMessage getMessage({
    required NotificationType type,
    required AppLocalizations l10n,
    String? excludeKey,
    Map<String, dynamic>? params,
  }) {
    final pool = _getMessagePool(type, l10n);

    // Filter out excluded key if provided
    final availableMessages = excludeKey != null
        ? pool.where((m) => m.key != excludeKey).toList()
        : pool;

    // If all messages excluded, use full pool
    final messagesToUse = availableMessages.isEmpty ? pool : availableMessages;

    // Random selection from available messages
    final template = messagesToUse[_random.nextInt(messagesToUse.length)];

    // Generate final message with params if needed
    return template.resolve(params ?? {});
  }

  /// Get the message pool for a notification type
  List<_MessageTemplate> _getMessagePool(
    NotificationType type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case NotificationType.workoutForgotten:
        return _workoutForgottenPool(l10n);
      case NotificationType.inactivity:
        return _inactivityPool(l10n);
      case NotificationType.insightPr:
        return _prPool(l10n);
      case NotificationType.insightStreak:
        return _streakPool(l10n);
      case NotificationType.insightVolume:
        return _volumePool(l10n);
    }
  }

  // ============================================
  // MESSAGE POOLS
  // ============================================

  List<_MessageTemplate> _workoutForgottenPool(AppLocalizations l10n) {
    return [
      _MessageTemplate(
        key: 'workout_forgotten_1',
        title: l10n.notificationWorkoutForgottenTitle,
        body: l10n.notificationWorkoutForgottenBody1,
      ),
      _MessageTemplate(
        key: 'workout_forgotten_2',
        title: l10n.notificationWorkoutForgottenTitle,
        body: l10n.notificationWorkoutForgottenBody2,
      ),
      _MessageTemplate(
        key: 'workout_forgotten_3',
        title: l10n.notificationWorkoutForgottenTitle,
        body: l10n.notificationWorkoutForgottenBody3,
      ),
    ];
  }

  List<_MessageTemplate> _inactivityPool(AppLocalizations l10n) {
    return [
      _MessageTemplate(
        key: 'inactivity_1',
        title: l10n.notificationInactivityTitle,
        body: l10n.notificationInactivityBody1,
      ),
      _MessageTemplate(
        key: 'inactivity_2',
        title: l10n.notificationInactivityTitle,
        body: l10n.notificationInactivityBody2,
      ),
      _MessageTemplate(
        key: 'inactivity_3',
        title: l10n.notificationInactivityTitle,
        body: l10n.notificationInactivityBody3,
      ),
    ];
  }

  List<_MessageTemplate> _prPool(AppLocalizations l10n) {
    return [
      _MessageTemplate(
        key: 'pr_1',
        title: l10n.notificationPrTitle,
        bodyFactory: (params) {
          final exerciseName = params['exerciseName'] as String? ?? 'exercise';
          return l10n.notificationPrBody1(exerciseName);
        },
      ),
      _MessageTemplate(
        key: 'pr_2',
        title: l10n.notificationPrTitle,
        bodyFactory: (params) {
          final exerciseName = params['exerciseName'] as String? ?? 'exercise';
          return l10n.notificationPrBody2(exerciseName);
        },
      ),
      _MessageTemplate(
        key: 'pr_3',
        title: l10n.notificationPrTitle,
        body: l10n.notificationPrBody3,
      ),
    ];
  }

  List<_MessageTemplate> _streakPool(AppLocalizations l10n) {
    return [
      _MessageTemplate(
        key: 'streak_1',
        title: l10n.notificationStreakTitle,
        bodyFactory: (params) {
          final streakDays = params['streakDays'] as int? ?? 7;
          return l10n.notificationStreakBody1(streakDays);
        },
      ),
      _MessageTemplate(
        key: 'streak_2',
        title: l10n.notificationStreakTitle,
        bodyFactory: (params) {
          final streakDays = params['streakDays'] as int? ?? 7;
          return l10n.notificationStreakBody2(streakDays);
        },
      ),
    ];
  }

  List<_MessageTemplate> _volumePool(AppLocalizations l10n) {
    return [
      _MessageTemplate(
        key: 'volume_1',
        title: l10n.notificationVolumeTitle,
        bodyFactory: (params) {
          final volumePercent = params['volumePercent'] as int? ?? 20;
          return l10n.notificationVolumeBody1(volumePercent);
        },
      ),
      _MessageTemplate(
        key: 'volume_2',
        title: l10n.notificationVolumeTitle,
        bodyFactory: (params) {
          final volumePercent = params['volumePercent'] as int? ?? 20;
          return l10n.notificationVolumeBody2(volumePercent);
        },
      ),
    ];
  }
}

/// Internal message template with optional factory for parameterized bodies.
class _MessageTemplate {
  _MessageTemplate({
    required this.key,
    required this.title,
    this.body,
    this.bodyFactory,
  }) : assert(
         body != null || bodyFactory != null,
         'Either body or bodyFactory must be provided',
       );

  final String key;
  final String title;
  final String? body;
  final BodyFactory? bodyFactory;

  /// Resolve the template to a final NotificationMessage.
  NotificationMessage resolve(Map<String, dynamic> params) {
    final resolvedBody = bodyFactory != null ? bodyFactory!(params) : body!;
    return NotificationMessage(key: key, title: title, body: resolvedBody);
  }
}

/// A notification message with title and body.
@immutable
class NotificationMessage {
  const NotificationMessage({
    required this.key,
    required this.title,
    required this.body,
  });

  /// Unique key for rotation tracking
  final String key;

  /// Notification title
  final String title;

  /// Notification body
  final String body;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationMessage &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}
