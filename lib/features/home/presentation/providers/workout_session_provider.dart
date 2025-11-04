import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Manages the current workout session ID for analytics correlation
/// Each home screen view starts a new session ID for funnel tracking
final workoutSessionProvider = StateProvider<String?>((_) => null);

/// Generate a new session ID
String generateSessionId() => const Uuid().v4();
