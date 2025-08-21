import Foundation
import ActivityKit
import Flutter


@available(iOS 16.1, *)
class LiveActivityHandler: NSObject {
    static let shared = LiveActivityHandler()
    private var currentActivity: Activity<GymBroTimerAttributes>?
    
    private override init() {
        super.init()
    }
    
    func setupMethodChannel(with binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.gymbro.timer/live_activity",
            binaryMessenger: binaryMessenger
        )
        
        // ✅ Salva riferimento al channel per callbacks
        self.methodChannel = channel
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLiveActivity":
            startLiveActivity(call.arguments as? [String: Any], result: result)
        case "updateLiveActivity":
            updateLiveActivity(call.arguments as? [String: Any], result: result)
        case "endLiveActivity":
            endLiveActivity(call.arguments as? [String: Any], result: result)
        case "isLiveActivitySupported":
            isLiveActivitySupported(result: result)
        case "getActiveLiveActivities":
            getActiveLiveActivities(result: result)
        // ✅ RPE Interactive Live Activities
        case "showRPEInterface":
            showRPEInterface(call.arguments as? [String: Any], result: result)
        case "updateRPEInterface":
            updateRPEInterface(call.arguments as? [String: Any], result: result)
        case "confirmRPEAndCompleteSet":
            confirmRPEAndCompleteSet(call.arguments as? [String: Any], result: result)
        case "dismissRPEInterface":
            dismissRPEInterface(call.arguments as? [String: Any], result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }
        
        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        // Extract parameters
        guard let exerciseName = args["exerciseName"] as? String,
              let timerType = args["timerType"] as? String,
              let totalSeconds = args["totalSeconds"] as? Int,
              let remainingSeconds = args["remainingSeconds"] as? Int,
              let isRunning = args["isRunning"] as? Bool,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int,
              let lastUpdated = args["lastUpdated"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        let workoutName = args["workoutName"] as? String
        
        // Create activity attributes
        let attributes = GymBroTimerAttributes(
            exerciseName: exerciseName,
            timerType: timerType,
            workoutName: workoutName
        )
        
        // ✅ Native iOS Timer: Precise startDate/endDate calculations
        let now = Date()
        
        // For native iOS timer to work correctly, we need precise timing
        let endDate = isRunning ? now.addingTimeInterval(TimeInterval(remainingSeconds)) : nil
        let startDate = isRunning ? now.addingTimeInterval(-TimeInterval(totalSeconds - remainingSeconds)) : nil
        
        // ✅ Longer staleDate for native timer (iOS handles updates internally)
        let staleDate = now.addingTimeInterval(TimeInterval(remainingSeconds + 10)) // Timer duration + buffer
        
        let initialContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets,
            lastUpdated: Date(timeIntervalSince1970: Double(lastUpdated) / 1000.0),
            endDate: endDate,
            startDate: startDate
        )
        
        do {
            // Start the activity
            let activity = try Activity<GymBroTimerAttributes>.request(
                attributes: attributes,
                content: ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: initialContentState,
                    staleDate: staleDate // ✅ React Native Method: Use staleDate for iOS
                ),
                pushType: nil
            )
            
            self.currentActivity = activity
            result(activity.id)
            
        } catch {
            result(FlutterError(
                code: "START_FAILED",
                message: "Failed to start Live Activity: \(error.localizedDescription)",
                details: nil
            ))
        }
    }
    
    private func updateLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find the activity by ID
        let activity = Activity<GymBroTimerAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
            return
        }
        
        // Extract update parameters
        guard let remainingSeconds = args["remainingSeconds"] as? Int,
              let totalSeconds = args["totalSeconds"] as? Int,
              let isRunning = args["isRunning"] as? Bool,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int,
              let lastUpdated = args["lastUpdated"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        // Extract RPE data if present
        let isAwaitingRPE = args["isAwaitingRPE"] as? Bool ?? false
        let targetReps = args["targetReps"] as? Int
        let weight = args["weight"] as? Double
        let actualReps = args["actualReps"] as? Int
        let selectedRPE = args["selectedRPE"] as? Int
        
        // ✅ Native iOS Timer: Precise calculations for smooth countdown
        let now = Date()
        
        // Calculate precise dates for native timer
        let endDate: Date?
        let startDate: Date?
        
        if isRunning {
            // Timer is running - calculate end time from now
            endDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
            // Calculate when timer originally started
            startDate = now.addingTimeInterval(-TimeInterval(totalSeconds - remainingSeconds))
            
            print("🔄 Timer Update - Native iOS Timer Dates:")
            print("🔄   Current time: \(now)")
            print("🔄   Start date: \(startDate?.description ?? "nil")")
            print("🔄   End date: \(endDate?.description ?? "nil")")
            print("🔄   Duration: \(totalSeconds)s, Remaining: \(remainingSeconds)s")
        } else {
            // Timer is paused - don't use native timer
            endDate = nil
            startDate = nil
            print("🔄 Timer Paused - Using manual countdown")
        }
        
        // Create updated content state with native timer
        let updatedContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            currentSet: currentSet,
            totalSets: totalSets,
            lastUpdated: Date(timeIntervalSince1970: Double(lastUpdated) / 1000.0),
            endDate: endDate,
            startDate: startDate,
            isAwaitingRPE: isAwaitingRPE,
            targetReps: targetReps,
            weight: weight,
            actualReps: actualReps,
            selectedRPE: selectedRPE
        )
        
        Task {
            // ✅ Native iOS Timer: Longer staleDate for timer-based Live Activities
            let staleDate = isRunning ? 
                Date().addingTimeInterval(TimeInterval(remainingSeconds + 10)) : // Timer duration + buffer
                Date().addingTimeInterval(60) // 1 minute for paused state
            
            await activity.update(
                ActivityContent<GymBroTimerAttributes.ContentState>(
                    state: updatedContentState,
                    staleDate: staleDate
                )
            )
            
            print("✅ Live Activity updated with native iOS timer support")
            result(true)
        }
    }
    
    private func endLiveActivity(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        let dismissalPolicy = args["dismissalPolicy"] as? String ?? "immediate"
        
        // Find the activity by ID
        let activity = Activity<GymBroTimerAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
            return
        }
        
        // Create final content state
        let finalContentState = GymBroTimerAttributes.ContentState(
            remainingSeconds: 0,
            totalSeconds: activity.content.state.totalSeconds,
            isRunning: false,
            currentSet: activity.content.state.currentSet,
            totalSets: activity.content.state.totalSets,
            lastUpdated: Date(),
            endDate: nil,
            startDate: nil
        )
        
        Task {
            if dismissalPolicy == "immediate" {
                await activity.end(
                    ActivityContent<GymBroTimerAttributes.ContentState>(
                        state: finalContentState,
                        staleDate: nil as Date?
                    ),
                    dismissalPolicy: .immediate
                )
            } else {
                await activity.end(
                    ActivityContent<GymBroTimerAttributes.ContentState>(
                        state: finalContentState,
                        staleDate: nil as Date?
                    ),
                    dismissalPolicy: .after(Date().addingTimeInterval(30))
                )
            }
            
            if self.currentActivity?.id == activityId {
                self.currentActivity = nil
            }
            
            result(true)
        }
    }
    
    private func isLiveActivitySupported(result: @escaping FlutterResult) {
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
    }
    
    private func getActiveLiveActivities(result: @escaping FlutterResult) {
        let activityIds = Activity<GymBroTimerAttributes>.activities.map { $0.id }
        result(activityIds)
    }
    
    // MARK: - ✅ RPE Interactive Live Activities Implementation
    private var currentRPEActivity: Activity<GymBroRPEAttributes>?
    private var methodChannel: FlutterMethodChannel?
    
    private func showRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }
        
        guard let args = arguments else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        // Extract RPE parameters
        guard let exerciseName = args["exerciseName"] as? String,
              let targetReps = args["targetReps"] as? Int,
              let weight = args["weight"] as? Double,
              let currentSet = args["currentSet"] as? Int,
              let totalSets = args["totalSets"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required RPE parameters", details: nil))
            return
        }
        
        let workoutName = args["workoutName"] as? String
        
        // Create RPE activity attributes  
        let attributes = GymBroRPEAttributes(
            exerciseName: exerciseName,
            targetReps: targetReps,
            weight: weight,
            currentSet: currentSet,
            totalSets: totalSets,
            workoutName: workoutName
        )
        
        // Create initial RPE content state
        let initialContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: false,
            actualReps: targetReps, // Default
            selectedRPE: nil,
            notes: nil,
            isConfirmed: false,
            lastUpdated: Date()
        )
        
        do {
            // Start RPE Live Activity
            let activity = try Activity<GymBroRPEAttributes>.request(
                attributes: attributes,
                content: ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: initialContentState,
                    staleDate: nil as Date?
                ),
                pushType: nil
            )
            
            self.currentRPEActivity = activity
            result(activity.id)
            
        } catch {
            result(FlutterError(
                code: "RPE_START_FAILED",
                message: "Failed to start RPE Live Activity: \(error.localizedDescription)",
                details: nil
            ))
        }
    }
    
    private func updateRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        // Extract update parameters
        let repsCompleted = args["repsCompleted"] as? Bool ?? false
        let actualReps = args["actualReps"] as? Int
        let selectedRPE = args["selectedRPE"] as? Int
        let notes = args["notes"] as? String
        
        // Create updated content state
        let updatedContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: repsCompleted,
            actualReps: actualReps ?? activity.content.state.actualReps,
            selectedRPE: selectedRPE,
            notes: notes,
            isConfirmed: false,
            lastUpdated: Date()
        )
        
        Task {
            await activity.update(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: updatedContentState,
                    staleDate: nil as Date?
                )
            )
            result(true)
        }
    }
    
    private func confirmRPEAndCompleteSet(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String,
              let actualReps = args["actualReps"] as? Int,
              let rpe = args["rpe"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required confirmation parameters", details: nil))
            return
        }
        
        let notes = args["notes"] as? String
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        // Create final confirmed state
        let confirmedContentState = GymBroRPEAttributes.ContentState(
            repsCompleted: true,
            actualReps: actualReps,
            selectedRPE: rpe,
            notes: notes,
            isConfirmed: true,
            lastUpdated: Date()
        )
        
        Task {
            // Update with confirmed state
            await activity.update(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: confirmedContentState,
                    staleDate: nil as Date?
                )
            )
            
            // Send confirmation back to Flutter
            if let channel = self.methodChannel {
                await MainActor.run {
                    channel.invokeMethod("onRPEConfirmed", arguments: [
                        "actualReps": actualReps,
                        "rpe": rpe,
                        "notes": notes
                    ])
                }
            }
            
            // End activity after a brief display
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                Task {
                    await activity.end(
                        ActivityContent<GymBroRPEAttributes.ContentState>(
                            state: confirmedContentState,
                            staleDate: nil as Date?
                        ),
                        dismissalPolicy: .immediate
                    )
                    
                    if self.currentRPEActivity?.id == activityId {
                        self.currentRPEActivity = nil
                    }
                }
            }
            
            result(true)
        }
    }
    
    private func dismissRPEInterface(_ arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing activityId", details: nil))
            return
        }
        
        // Find RPE activity by ID
        let activity = Activity<GymBroRPEAttributes>.activities.first { $0.id == activityId }
        
        guard let activity = activity else {
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "RPE Activity not found", details: nil))
            return
        }
        
        Task {
            // Send cancellation back to Flutter
            if let channel = self.methodChannel {
                await MainActor.run {
                    channel.invokeMethod("onRPECancelled", arguments: nil)
                }
            }
            
            // End activity immediately
            await activity.end(
                ActivityContent<GymBroRPEAttributes.ContentState>(
                    state: activity.content.state,
                    staleDate: nil as Date?
                ),
                dismissalPolicy: .immediate
            )
            
            if self.currentRPEActivity?.id == activityId {
                self.currentRPEActivity = nil
            }
            
            result(true)
        }
    }
}