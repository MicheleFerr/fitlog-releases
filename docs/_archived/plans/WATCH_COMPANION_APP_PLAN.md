# 🍎 FitLog Pro - Apple Watch Companion App

## Piano di Implementazione Dettagliato

**Versione:** 1.0
**Data:** Dicembre 2024
**Target:** watchOS 10+, iOS 17+

---

## 📋 Executive Summary

### Obiettivo
Creare un'app companion per Apple Watch che permetta di:
1. **Avviare/controllare workout** direttamente dal Watch
2. **Tracciare heart rate in tempo reale** con calcolo calorie ACCURATE
3. **Sincronizzare dati bidirezionalmente** con l'app iPhone
4. **Mostrare progressi** tramite complications sul quadrante

### Vantaggio Competitivo
- Calorie REALI basate su heart rate (non stime)
- Workout tracking senza dover portare il telefono
- Integrazione nativa con Activity Rings di Apple
- Quick logging di set/rep direttamente dal polso

---

## 🏗️ Architettura

### Stack Tecnologico

| Componente | Tecnologia | Motivo |
|------------|------------|--------|
| Watch App | SwiftUI + HealthKit | Performance nativa, accesso HKWorkoutSession |
| iPhone Bridge | Swift + WatchConnectivity | Comunicazione bidirezionale |
| Flutter Layer | MethodChannel | Integrazione con app esistente |
| Data Sync | App Groups + UserDefaults | Dati condivisi per complications |

### Diagramma Architetturale

```
┌─────────────────────────────────────────────────────────────────┐
│                        APPLE WATCH                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   SwiftUI    │  │  HealthKit   │  │   WatchConnectivity  │  │
│  │   Views      │  │  HKWorkout   │  │   WCSession          │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                 │                      │              │
│         └────────┬────────┴──────────────────────┘              │
│                  │                                               │
│         ┌────────▼────────┐                                     │
│         │  WorkoutManager │  ← Coordina tutto                   │
│         └────────┬────────┘                                     │
│                  │                                               │
│         ┌────────▼────────┐                                     │
│         │   App Groups    │  ← Dati per Complications           │
│         └────────┬────────┘                                     │
└──────────────────┼──────────────────────────────────────────────┘
                   │ Bluetooth/WiFi
┌──────────────────┼──────────────────────────────────────────────┐
│                  │           iPHONE                              │
├──────────────────┼──────────────────────────────────────────────┤
│         ┌────────▼────────┐                                     │
│         │WatchConnectivity│                                     │
│         │    Manager      │                                     │
│         └────────┬────────┘                                     │
│                  │                                               │
│         ┌────────▼────────┐                                     │
│         │  MethodChannel  │                                     │
│         │  (Swift Bridge) │                                     │
│         └────────┬────────┘                                     │
│                  │                                               │
│         ┌────────▼────────┐                                     │
│         │     Flutter     │                                     │
│         │   (Dart App)    │                                     │
│         └─────────────────┘                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 Funzionalità

### MVP (Fase 1) - 4-6 settimane

#### 1. Workout Tracking Base
- [ ] Avvio workout dal Watch
- [ ] Tipi supportati: Strength Training, HIIT, Functional
- [ ] Timer rest automatico tra set
- [ ] Pausa/Resume/End workout
- [ ] Heart rate real-time display

#### 2. Metriche Real-Time
- [ ] Heart rate (BPM) con zone colorate
- [ ] Calorie bruciate (da HKWorkoutSession)
- [ ] Durata workout
- [ ] Set completati

#### 3. Sincronizzazione Base
- [ ] Sync workout completato → iPhone
- [ ] Sync template attivi iPhone → Watch
- [ ] Notifica su iPhone quando workout finisce

### Fase 2 - 3-4 settimane

#### 4. Quick Logging
- [ ] Log set direttamente dal Watch
- [ ] Picker peso (scroll crown)
- [ ] Picker reps
- [ ] Conferma haptic feedback

#### 5. Complications
- [ ] Circular: Workout in corso (tempo)
- [ ] Rectangular: Prossimo workout schedulato
- [ ] Corner: Streak giorni

#### 6. Integrazione Avanzata
- [ ] Mirror workout da iPhone su Watch
- [ ] Controlli remoti (pausa da Watch)
- [ ] Audio cue su AirPods dal Watch

### Fase 3 - 2-3 settimane

#### 7. Always On Display
- [ ] Metriche semplificate in AOD
- [ ] Aggiornamento 1/secondo

#### 8. Offline Mode
- [ ] Workout senza iPhone vicino
- [ ] Sync quando riconnesso

#### 9. Haptics Avanzati
- [ ] Pattern per fine rest
- [ ] Pattern per nuovo PR
- [ ] Pattern per goal raggiunto

---

## 🔧 Implementazione Tecnica

### 1. Setup Progetto Xcode

#### 1.1 Creare Target watchOS

```bash
# In Xcode:
# File → New → Target → watchOS → App
# Product Name: "FitLog Watch"
# Bundle ID: com.gymbro.flutter.watchkitapp
# Interface: SwiftUI
# Language: Swift
# Watch App for Existing iOS App: YES
```

#### 1.2 Configurazione Build Phases

```
Runner target → Build Phases:
1. Embed Frameworks
2. Embed Watch Content ← SPOSTARE QUI (prima di Thin Binary)
3. Thin Binary
```

#### 1.3 Entitlements (FitLogWatch.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.developer.healthkit</key>
    <true/>
    <key>com.apple.developer.healthkit.background-delivery</key>
    <true/>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.gymbro.flutter</string>
    </array>
</dict>
</plist>
```

#### 1.4 Info.plist (Watch)

```xml
<key>NSHealthShareUsageDescription</key>
<string>FitLog needs to read your workout data to track progress</string>
<key>NSHealthUpdateUsageDescription</key>
<string>FitLog needs to save workouts to Health</string>
<key>WKBackgroundModes</key>
<array>
    <string>workout-processing</string>
</array>
```

### 2. Struttura Codice Watch

```
FitLogWatch/
├── FitLogWatchApp.swift          # Entry point
├── ContentView.swift             # Main navigation
├── Models/
│   ├── WatchWorkout.swift        # Workout model
│   └── WorkoutMetrics.swift      # Real-time metrics
├── Views/
│   ├── WorkoutListView.swift     # Lista workout/template
│   ├── ActiveWorkoutView.swift   # Durante workout
│   ├── MetricsView.swift         # Heart rate, calories
│   ├── ControlsView.swift        # Pause/Resume/End
│   └── SetLogView.swift          # Quick log set
├── Managers/
│   ├── WorkoutManager.swift      # HKWorkoutSession
│   ├── HealthKitManager.swift    # HealthKit queries
│   └── ConnectivityManager.swift # WatchConnectivity
└── Complications/
    └── ComplicationViews.swift   # Widget families
```

### 3. Core Implementation

#### 3.1 WorkoutManager.swift

```swift
import Foundation
import HealthKit
import WatchKit
import Combine

/// Manages HKWorkoutSession for real-time workout tracking
@MainActor
class WorkoutManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentHeartRateZone: HeartRateZone = .warmup

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var timer: Timer?
    private var startDate: Date?

    // MARK: - Heart Rate Zones

    enum HeartRateZone: String, CaseIterable {
        case warmup = "Warmup"      // < 50% max
        case fatBurn = "Fat Burn"   // 50-60%
        case cardio = "Cardio"      // 60-70%
        case peak = "Peak"          // 70-85%
        case extreme = "Extreme"    // > 85%

        var color: Color {
            switch self {
            case .warmup: return .gray
            case .fatBurn: return .blue
            case .cardio: return .green
            case .peak: return .orange
            case .extreme: return .red
            }
        }
    }

    // MARK: - Workout Types

    enum WorkoutType: String, CaseIterable {
        case strengthTraining = "Strength"
        case hiit = "HIIT"
        case functionalTraining = "Functional"

        var hkType: HKWorkoutActivityType {
            switch self {
            case .strengthTraining: return .traditionalStrengthTraining
            case .hiit: return .highIntensityIntervalTraining
            case .functionalTraining: return .functionalStrengthTraining
            }
        }
    }

    // MARK: - Public Methods

    func startWorkout(type: WorkoutType) async throws {
        // 1. Request authorization
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]

        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)

        // 2. Create workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type.hkType
        configuration.locationType = .indoor

        // 3. Create and start session
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()

        session?.delegate = self
        builder?.delegate = self

        // 4. Set data source for live workout
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        // 5. Start session and builder
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)

        self.startDate = startDate
        isWorkoutActive = true

        // 6. Start elapsed time timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    func pauseWorkout() {
        session?.pause()
    }

    func resumeWorkout() {
        session?.resume()
    }

    func endWorkout() async throws {
        session?.end()

        guard let builder = builder, let startDate = startDate else { return }

        try await builder.endCollection(at: Date())

        // Finalize and save workout
        let workout = try await builder.finishWorkout()

        // Notify iPhone app
        ConnectivityManager.shared.sendWorkoutCompleted(workout)

        // Reset state
        self.session = nil
        self.builder = nil
        self.timer?.invalidate()
        self.timer = nil
        self.isWorkoutActive = false
    }

    // MARK: - Private Methods

    private func updateElapsedTime() {
        guard let startDate = startDate else { return }
        elapsedTime = Date().timeIntervalSince(startDate)
    }

    private func calculateHeartRateZone(bpm: Double) -> HeartRateZone {
        // Assuming max HR = 220 - age (simplified)
        // TODO: Get age from HealthKit
        let maxHR: Double = 190 // Placeholder
        let percentage = bpm / maxHR

        switch percentage {
        case ..<0.5: return .warmup
        case 0.5..<0.6: return .fatBurn
        case 0.6..<0.7: return .cardio
        case 0.7..<0.85: return .peak
        default: return .extreme
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in
            // Handle state changes
            switch toState {
            case .running:
                isWorkoutActive = true
            case .paused:
                // Show paused UI
                break
            case .ended:
                isWorkoutActive = false
            default:
                break
            }
        }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        // Handle error
        print("Workout session failed: \(error)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        Task { @MainActor in
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else { continue }

                let statistics = workoutBuilder.statistics(for: quantityType)

                switch quantityType {
                case HKQuantityType(.heartRate):
                    let bpm = statistics?.mostRecentQuantity()?.doubleValue(
                        for: HKUnit.count().unitDivided(by: .minute())
                    ) ?? 0
                    heartRate = bpm
                    currentHeartRateZone = calculateHeartRateZone(bpm: bpm)

                case HKQuantityType(.activeEnergyBurned):
                    activeCalories = statistics?.sumQuantity()?.doubleValue(
                        for: .kilocalorie()
                    ) ?? 0

                default:
                    break
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(
        _ workoutBuilder: HKLiveWorkoutBuilder
    ) {
        // Handle workout events
    }
}
```

#### 3.2 ConnectivityManager.swift

```swift
import Foundation
import WatchConnectivity
import HealthKit

/// Manages bidirectional communication between Watch and iPhone
class ConnectivityManager: NSObject, ObservableObject {

    static let shared = ConnectivityManager()

    @Published var isReachable = false
    @Published var receivedTemplates: [WorkoutTemplate] = []

    private var session: WCSession?

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Send to iPhone

    /// Send completed workout to iPhone for sync
    func sendWorkoutCompleted(_ workout: HKWorkout) {
        guard let session = session, session.isReachable else {
            // Use background transfer if not reachable
            transferWorkoutInBackground(workout)
            return
        }

        let data: [String: Any] = [
            "type": "workoutCompleted",
            "duration": workout.duration,
            "calories": workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
            "startDate": workout.startDate.timeIntervalSince1970,
            "endDate": workout.endDate.timeIntervalSince1970,
            "workoutType": workout.workoutActivityType.rawValue
        ]

        session.sendMessage(data, replyHandler: nil) { error in
            print("Failed to send workout: \(error)")
        }
    }

    /// Request templates from iPhone
    func requestTemplates() {
        guard let session = session, session.isReachable else { return }

        session.sendMessage(
            ["type": "requestTemplates"],
            replyHandler: { [weak self] response in
                // Parse templates from response
                if let templatesData = response["templates"] as? [[String: Any]] {
                    // Convert to WorkoutTemplate objects
                    // self?.receivedTemplates = ...
                }
            },
            errorHandler: { error in
                print("Failed to request templates: \(error)")
            }
        )
    }

    /// Send set logged to iPhone
    func sendSetLogged(exerciseId: String, weight: Double, reps: Int) {
        let data: [String: Any] = [
            "type": "setLogged",
            "exerciseId": exerciseId,
            "weight": weight,
            "reps": reps,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Use application context for reliability
        try? session?.updateApplicationContext(data)
    }

    // MARK: - Background Transfer

    private func transferWorkoutInBackground(_ workout: HKWorkout) {
        let data: [String: Any] = [
            "type": "workoutCompleted",
            "duration": workout.duration,
            "calories": workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
            "startDate": workout.startDate.timeIntervalSince1970,
            "endDate": workout.endDate.timeIntervalSince1970
        ]

        session?.transferUserInfo(data)
    }
}

// MARK: - WCSessionDelegate

extension ConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    // Receive messages from iPhone
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "startWorkout":
            // iPhone requested to start workout
            // Handle in WorkoutManager
            break

        case "templatesUpdate":
            // iPhone sent updated templates
            if let templates = message["templates"] as? [[String: Any]] {
                // Parse and update
            }

        default:
            break
        }
    }

    // Receive application context (state sync)
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        // Handle synced state from iPhone
    }

    // Receive background transfers
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        // Handle background data from iPhone
    }
}
```

#### 3.3 Active Workout View (SwiftUI)

```swift
import SwiftUI
import HealthKit

struct ActiveWorkoutView: View {
    @StateObject private var workoutManager = WorkoutManager()
    @Environment(\.isLuminanceReduced) var isLuminanceReduced // For Always On

    var body: some View {
        TabView {
            // Left: Controls
            ControlsView(workoutManager: workoutManager)

            // Center: Metrics
            MetricsView(workoutManager: workoutManager)

            // Right: Now Playing (if music)
            NowPlayingView()
        }
        .tabViewStyle(.page)
        .navigationBarBackButtonHidden(true)
    }
}

struct MetricsView: View {
    @ObservedObject var workoutManager: WorkoutManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    var body: some View {
        VStack(spacing: 8) {
            // Heart Rate (Hero)
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(workoutManager.currentHeartRateZone.color)

                Text("\(Int(workoutManager.heartRate))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(workoutManager.currentHeartRateZone.color)

                Text("BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Heart Rate Zone
            Text(workoutManager.currentHeartRateZone.rawValue)
                .font(.caption)
                .foregroundColor(workoutManager.currentHeartRateZone.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(workoutManager.currentHeartRateZone.color.opacity(0.2))
                )

            Divider()
                .padding(.vertical, 4)

            // Stats Grid
            HStack {
                // Calories
                VStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(Int(workoutManager.activeCalories))")
                        .font(.title3.bold())
                    Text("KCAL")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Duration
                VStack {
                    Image(systemName: "timer")
                        .foregroundColor(.green)
                    Text(formatTime(workoutManager.elapsedTime))
                        .font(.title3.bold())
                        // Hide subseconds in Always On
                        .monospacedDigit()
                    Text("TIME")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60

        if isLuminanceReduced {
            // Always On: show only minutes
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct ControlsView: View {
    @ObservedObject var workoutManager: WorkoutManager

    var body: some View {
        VStack(spacing: 16) {
            // Pause/Resume Button
            Button(action: {
                if workoutManager.isWorkoutActive {
                    workoutManager.pauseWorkout()
                } else {
                    workoutManager.resumeWorkout()
                }
            }) {
                Image(systemName: workoutManager.isWorkoutActive ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.yellow)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // End Button
            Button(action: {
                Task {
                    try? await workoutManager.endWorkout()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}
```

### 4. iPhone Bridge (Swift)

#### 4.1 WatchConnectivityBridge.swift

```swift
import Foundation
import WatchConnectivity
import Flutter

/// Bridge between Flutter and WatchConnectivity
class WatchConnectivityBridge: NSObject {

    static let shared = WatchConnectivityBridge()

    private var session: WCSession?
    private var methodChannel: FlutterMethodChannel?

    func setupChannel(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.gymbro/watch_connectivity",
            binaryMessenger: messenger
        )

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "isWatchPaired":
                result(self?.session?.isPaired ?? false)

            case "isWatchReachable":
                result(self?.session?.isReachable ?? false)

            case "sendMessage":
                if let args = call.arguments as? [String: Any] {
                    self?.sendMessage(args, result: result)
                }

            case "updateApplicationContext":
                if let args = call.arguments as? [String: Any] {
                    self?.updateContext(args, result: result)
                }

            case "sendTemplates":
                if let args = call.arguments as? [[String: Any]] {
                    self?.sendTemplates(args, result: result)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Activate WCSession
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    private func sendMessage(_ data: [String: Any], result: @escaping FlutterResult) {
        guard let session = session, session.isReachable else {
            result(FlutterError(code: "NOT_REACHABLE", message: "Watch not reachable", details: nil))
            return
        }

        session.sendMessage(data, replyHandler: { response in
            result(response)
        }, errorHandler: { error in
            result(FlutterError(code: "SEND_ERROR", message: error.localizedDescription, details: nil))
        })
    }

    private func updateContext(_ data: [String: Any], result: @escaping FlutterResult) {
        do {
            try session?.updateApplicationContext(data)
            result(true)
        } catch {
            result(FlutterError(code: "CONTEXT_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func sendTemplates(_ templates: [[String: Any]], result: @escaping FlutterResult) {
        let data: [String: Any] = [
            "type": "templatesUpdate",
            "templates": templates
        ]

        do {
            try session?.updateApplicationContext(data)
            result(true)
        } catch {
            result(FlutterError(code: "TEMPLATES_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    /// Notify Flutter of watch events
    private func notifyFlutter(event: String, data: [String: Any]) {
        methodChannel?.invokeMethod(event, arguments: data)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityBridge: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        notifyFlutter(event: "watchConnectivityChanged", data: [
            "isPaired": session.isPaired,
            "isReachable": session.isReachable
        ])
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate for switching watches
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        notifyFlutter(event: "watchReachabilityChanged", data: [
            "isReachable": session.isReachable
        ])
    }

    // Receive messages from Watch
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        guard let type = message["type"] as? String else {
            replyHandler(["error": "Missing type"])
            return
        }

        switch type {
        case "workoutCompleted":
            notifyFlutter(event: "workoutCompletedOnWatch", data: message)
            replyHandler(["success": true])

        case "setLogged":
            notifyFlutter(event: "setLoggedOnWatch", data: message)
            replyHandler(["success": true])

        case "requestTemplates":
            // Flutter will respond with templates
            notifyFlutter(event: "watchRequestedTemplates", data: [:])
            // Reply will be sent separately
            replyHandler(["pending": true])

        default:
            replyHandler(["error": "Unknown type"])
        }
    }

    // Receive background transfers
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        notifyFlutter(event: "receivedBackgroundData", data: userInfo)
    }
}
```

### 5. Flutter Integration

#### 5.1 watch_connectivity_service.dart

```dart
import 'package:flutter/services.dart';

/// Service for Apple Watch connectivity
class WatchConnectivityService {
  static const _channel = MethodChannel('com.gymbro/watch_connectivity');

  // Callbacks
  Function(Map<String, dynamic>)? onWorkoutCompleted;
  Function(Map<String, dynamic>)? onSetLogged;
  Function()? onTemplatesRequested;
  Function(bool)? onReachabilityChanged;

  WatchConnectivityService() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'workoutCompletedOnWatch':
        onWorkoutCompleted?.call(Map<String, dynamic>.from(call.arguments));
        break;
      case 'setLoggedOnWatch':
        onSetLogged?.call(Map<String, dynamic>.from(call.arguments));
        break;
      case 'watchRequestedTemplates':
        onTemplatesRequested?.call();
        break;
      case 'watchReachabilityChanged':
        final data = Map<String, dynamic>.from(call.arguments);
        onReachabilityChanged?.call(data['isReachable'] as bool);
        break;
    }
  }

  /// Check if Watch is paired
  Future<bool> isWatchPaired() async {
    return await _channel.invokeMethod<bool>('isWatchPaired') ?? false;
  }

  /// Check if Watch is reachable
  Future<bool> isWatchReachable() async {
    return await _channel.invokeMethod<bool>('isWatchReachable') ?? false;
  }

  /// Send templates to Watch
  Future<bool> sendTemplates(List<Map<String, dynamic>> templates) async {
    try {
      return await _channel.invokeMethod<bool>('sendTemplates', templates) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Send message to Watch
  Future<Map<String, dynamic>?> sendMessage(Map<String, dynamic> data) async {
    try {
      final result = await _channel.invokeMethod<Map>('sendMessage', data);
      return result?.cast<String, dynamic>();
    } catch (e) {
      return null;
    }
  }
}
```

---

## 📦 Complications (WidgetKit)

### Setup

```swift
// ComplicationController.swift
import WidgetKit
import SwiftUI

struct FitLogComplication: Widget {
    let kind: String = "FitLogComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("FitLog")
        .description("Workout tracking")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let workoutInProgress: Bool
    let currentStreak: Int
    let nextWorkout: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: Date(), workoutInProgress: false, currentStreak: 7, nextWorkout: "Push Day")
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        // Read from App Groups
        let defaults = UserDefaults(suiteName: "group.com.gymbro.flutter")
        let streak = defaults?.integer(forKey: "currentStreak") ?? 0
        let nextWorkout = defaults?.string(forKey: "nextWorkout")

        completion(ComplicationEntry(
            date: Date(),
            workoutInProgress: false,
            currentStreak: streak,
            nextWorkout: nextWorkout
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        // Similar to snapshot, but with refresh policy
        let defaults = UserDefaults(suiteName: "group.com.gymbro.flutter")
        let streak = defaults?.integer(forKey: "currentStreak") ?? 0
        let nextWorkout = defaults?.string(forKey: "nextWorkout")

        let entry = ComplicationEntry(
            date: Date(),
            workoutInProgress: false,
            currentStreak: streak,
            nextWorkout: nextWorkout
        )

        // Refresh every hour
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}
```

---

## 📋 Timeline di Sviluppo

### Settimana 1-2: Setup & Infrastruttura
- [ ] Creare target watchOS in Xcode
- [ ] Configurare entitlements e capabilities
- [ ] Setup WatchConnectivity base
- [ ] Creare MethodChannel bridge
- [ ] Test comunicazione bidirezionale

### Settimana 3-4: Workout Core
- [ ] Implementare WorkoutManager con HKWorkoutSession
- [ ] UI ActiveWorkoutView con metriche real-time
- [ ] Heart rate monitoring e zone
- [ ] Calcolo calorie accurate

### Settimana 5-6: Sync & Templates
- [ ] Sync templates da iPhone a Watch
- [ ] Sync workout completati da Watch a iPhone
- [ ] Gestione offline mode
- [ ] Test end-to-end

### Settimana 7-8: Quick Logging & Polish
- [ ] UI per log set rapido
- [ ] Crown picker per peso/reps
- [ ] Haptic feedback
- [ ] Always On Display support

### Settimana 9-10: Complications
- [ ] Circular complication (workout attivo)
- [ ] Rectangular complication (prossimo workout)
- [ ] App Groups per dati condivisi
- [ ] Refresh policy ottimizzata

### Settimana 11-12: Testing & Release
- [ ] Test su dispositivi reali (simulatore limitato)
- [ ] Performance profiling
- [ ] App Store submission
- [ ] Documentazione utente

---

## ⚠️ Note Importanti

### Limitazioni
1. **Flutter NON gira su Watch** - App Watch è 100% Swift/SwiftUI
2. **Simulatore limitato** - WatchConnectivity funziona solo su device reali
3. **HKWorkoutSession solo su Watch** - iPhone può solo mirrorare
4. **Background mode** - Richiede workout-processing entitlement

### Best Practices
1. **Comunicazione lightweight** - Solo dati essenziali via WatchConnectivity
2. **App Groups** - Per complications che leggono dati
3. **Offline-first** - Watch deve funzionare senza iPhone
4. **Battery** - Minimizzare polling, usare delegate

### Testing
- Test su Apple Watch REALE obbligatorio
- Testare tutti i workout types
- Testare offline mode
- Testare Always On Display

---

## 📚 Risorse

### Documentazione Apple
- [Build a workout app for Apple Watch](https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/build_a_workout_app_for_apple_watch)
- [Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity)
- [HKWorkoutSession](https://developer.apple.com/documentation/healthkit/hkworkoutsession)
- [Creating accessory widgets and complications](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications)

### WWDC Sessions
- [Build a workout app for Apple Watch - WWDC21](https://developer.apple.com/videos/play/wwdc2021/10009/)
- [There and back again: Data transfer on Apple Watch - WWDC21](https://developer.apple.com/videos/play/wwdc2021/10003/)
- [Design and build apps for watchOS 10 - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10138/)
- [Complications and widgets: Reloaded - WWDC22](https://developer.apple.com/videos/play/wwdc2022/10050/)

### Tutorial & Guide
- [Cheesecake Labs: Flutter + Apple Watch Integration](https://cheesecakelabs.com/blog/flutter-apps-apple-watch-integration/)
- [Medium: Building a WatchOS Companion App for Flutter](https://medium.com/@Toglefritz/building-a-watchos-companion-app-for-flutter-08f80ea8cb1b)
- [Kodeco: watchOS With SwiftUI by Tutorials](https://www.kodeco.com/books/watchos-with-swiftui-by-tutorials)
- [Gorilla Logic: Apple Watch HealthKit Tutorial](https://gorillalogic.com/blog-and-resources/apple-watch-healthkit-developer-tutorial-how-to-build-a-workout-app)

### Sample Projects
- [GitHub: SpeedySloth (Apple Sample)](https://github.com/nurseybushc/SpeedySlothCreatingAWorkout)
- [GitHub: basicwatch (Flutter + watchOS)](https://github.com/magnatronus/basicwatch)
