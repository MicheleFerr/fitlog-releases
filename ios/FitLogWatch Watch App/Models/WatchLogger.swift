//
//  WatchLogger.swift
//  FitLogWatch Watch App
//
//  P2-13 audit fix: Structured logging with os.Logger
//  Replaces print() for production-quality logging visible in Console.app
//

import os

/// Structured logger for the Watch app using os.Logger
/// Usage: WatchLogger.connectivity.info("Message received")
enum WatchLogger {
    /// Connectivity / WCSession messages
    static let connectivity = Logger(subsystem: "com.fitlog.watch", category: "connectivity")

    /// Workout / HealthKit
    static let workout = Logger(subsystem: "com.fitlog.watch", category: "workout")

    /// Timer / Rest periods
    static let timer = Logger(subsystem: "com.fitlog.watch", category: "timer")

    /// UI / Navigation
    static let ui = Logger(subsystem: "com.fitlog.watch", category: "ui")

    /// Haptic feedback
    static let haptic = Logger(subsystem: "com.fitlog.watch", category: "haptic")
}
