/// Discrete timer events for state transitions.
///
/// Used with StreamController to notify consumers about structural
/// timer changes without triggering high-frequency Riverpod rebuilds.
sealed class TimerEvent {
  const TimerEvent();

  factory TimerEvent.started(Duration duration) = TimerStartedEvent;
  factory TimerEvent.paused() = TimerPausedEvent;
  factory TimerEvent.resumed() = TimerResumedEvent;
  factory TimerEvent.completed() = TimerCompletedEvent;
  factory TimerEvent.skipped() = TimerSkippedEvent;
}

class TimerStartedEvent extends TimerEvent {
  const TimerStartedEvent(this.duration);
  final Duration duration;
}

class TimerPausedEvent extends TimerEvent {
  const TimerPausedEvent();
}

class TimerResumedEvent extends TimerEvent {
  const TimerResumedEvent();
}

class TimerCompletedEvent extends TimerEvent {
  const TimerCompletedEvent();
}

class TimerSkippedEvent extends TimerEvent {
  const TimerSkippedEvent();
}
