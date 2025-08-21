import ActivityKit
import WidgetKit
import SwiftUI

  // MARK: - Timer Activity Attributes
  struct GymBroTimerAttributes: ActivityAttributes {
      public struct ContentState: Codable, Hashable {
          // Dynamic data that changes during the activity
          var remainingSeconds: Int
          var totalSeconds: Int
          var isRunning: Bool
          var currentSet: Int
          var totalSets: Int
          var lastUpdated: Date
          // ✅ TIMER AUTONOMO: Data di fine per calcolo nativo iOS
          var endDate: Date?
          var startDate: Date?
          // ✅ RPE Support
          var isAwaitingRPE: Bool = false
          var targetReps: Int?
          var weight: Double?
          var actualReps: Int?
          var selectedRPE: Int?
      }

      // Static data that doesn't change during the activity
      var exerciseName: String
      var timerType: String // "rest", "workout", "warmup"
      var workoutName: String?
  }

  // MARK: - Helper Extensions
  extension GymBroTimerAttributes.ContentState {
      // ✅ CALCOLO NATIVO DEL TEMPO RIMANENTE
      var actualRemainingSeconds: Int {
          guard let endDate = endDate, isRunning else { 
              return remainingSeconds 
          }
          
          let now = Date()
          let remaining = endDate.timeIntervalSince(now)
          return max(0, Int(remaining))
      }
      
      var isTimerCompleted: Bool {
          return actualRemainingSeconds <= 0
      }
      
      var progress: Double {
          guard totalSeconds > 0 else { return 0.0 }
          let elapsed = totalSeconds - actualRemainingSeconds
          return Double(elapsed) / Double(totalSeconds)
      }

      var formattedTime: String {
          let seconds = actualRemainingSeconds
          let minutes = seconds / 60
          let secs = seconds % 60
          return String(format: "%02d:%02d", minutes, secs)
      }

      var progressColor: Color {
          let remaining = actualRemainingSeconds
          if remaining <= 15 {
              return Color.red // Critical: Very urgent
          } else if remaining <= 30 {
              return Color.orange // Warning: Getting urgent
          } else if remaining <= 60 {
              // Use amber instead of yellow for better visibility
              return Color(.systemOrange) // Attention: Moderate time left
          } else if remaining <= 120 {
              return Color(.systemBlue) // Active: Normal rest time
          } else {
              return Color(.systemGreen) // Relaxed: Plenty of time
          }
      }
      
      // High contrast color for text overlays
      var textColor: Color {
          let remaining = actualRemainingSeconds
          if remaining <= 15 {
              return Color.white // White text on red
          } else if remaining <= 30 {
              return Color.white // White text on orange
          } else if remaining <= 60 {
              return Color.black // Black text on amber/orange
          } else if remaining <= 120 {
              return Color.white // White text on blue
          } else {
              return Color.white // White text on green
          }
      }

      var statusText: String {
          if !isRunning {
              return "Paused"
          } else if isTimerCompleted {
              return "Time's up! 🎯"
          } else if actualRemainingSeconds <= 15 {
              return "Get ready! 💪"
          } else if actualRemainingSeconds <= 30 {
              return "Almost time..."
          } else if actualRemainingSeconds <= 60 {
              return "Prepare yourself"
          } else {
              return "Rest & recover"
          }
      }

      var setInfo: String {
          return "Set \(currentSet)/\(totalSets)"
      }
      
      // ✅ RPE Helper Properties
      var isInRPEMode: Bool {
          return isAwaitingRPE && isTimerCompleted
      }
      
      var rpeDisplayText: String {
          if let rpe = selectedRPE {
              return "RPE: \(rpe)/10"
          }
          return "Select RPE"
      }
      
      var repsDisplayText: String {
          let actual = actualReps ?? targetReps ?? 0
          let target = targetReps ?? 0
          return "\(actual)/\(target) reps"
      }
      
      var rpeColor: Color {
          guard let rpe = selectedRPE else { return Color.orange }
          
          switch rpe {
          case 5...6:
              return Color.green
          case 7...8:
              return Color.orange
          case 9...10:
              return Color.red
          default:
              return Color.gray
          }
      }
  }

// MARK: - ✅ RPE Activity Attributes
struct GymBroRPEAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic RPE data
        var repsCompleted: Bool
        var actualReps: Int?
        var selectedRPE: Int? // 5-10 scale
        var notes: String?
        var isConfirmed: Bool
        var lastUpdated: Date
    }
    
    // Static RPE data
    var exerciseName: String
    var targetReps: Int
    var weight: Double
    var currentSet: Int
    var totalSets: Int
    var workoutName: String?
}

// MARK: - RPE Helper Extensions
extension GymBroRPEAttributes.ContentState {
    var rpeDescription: String {
        guard let rpe = selectedRPE else { return "Select RPE" }
        
        switch rpe {
        case 5:
            return "Very Light"
        case 6:
            return "Light"
        case 7:
            return "Moderate"
        case 8:
            return "Hard"
        case 9:
            return "Very Hard"
        case 10:
            return "Max Effort"
        default:
            return "Invalid"
        }
    }
    
    var rpeColor: Color {
        guard let rpe = selectedRPE else { return Color.gray }
        
        switch rpe {
        case 5...6:
            return Color.green
        case 7...8:
            return Color.orange
        case 9...10:
            return Color.red
        default:
            return Color.gray
        }
    }
    
    var completionProgress: Double {
        if isConfirmed {
            return 1.0
        } else if selectedRPE != nil && actualReps != nil {
            return 0.8
        } else if actualReps != nil {
            return 0.5
        } else {
            return 0.0
        }
    }
}
