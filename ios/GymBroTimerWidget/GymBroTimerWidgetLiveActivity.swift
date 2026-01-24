import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

  // MARK: - Live Activity Widget
  @available(iOS 16.1, *)
  struct GymBroTimerLiveActivity: Widget {
      var body: some WidgetConfiguration {
          ActivityConfiguration(for: GymBroTimerAttributes.self) { context in
              // Lock Screen / Banner UI
              LockScreenTimerView(context: context)
          } dynamicIsland: { context in
              // Dynamic Island UI
              DynamicIsland {
                  // Expanded UI
                  DynamicIslandExpandedRegion(.leading) {
                      HStack {
                          Image(systemName: "timer")
                              .foregroundColor(context.state.progressColor)
                              .font(.title2)

                          VStack(alignment: .leading, spacing: 2) {
                              Text(context.attributes.exerciseName)
                                  .font(.caption)
                                  .fontWeight(.medium)
                                  .lineLimit(1)

                              Text(context.state.setInfo)
                                  .font(.caption2)
                                  .foregroundColor(.secondary)
                          }
                      }
                  }

                  DynamicIslandExpandedRegion(.trailing) {
                      VStack(alignment: .trailing, spacing: 4) {
                          // ✅ Native iOS Timer - Updates automatically every second
                          if let startDate = context.state.startDate, 
                             let endDate = context.state.endDate,
                             context.state.isRunning {
                              Text(timerInterval: startDate...endDate, countsDown: true)
                                  .font(.title2)
                                  .fontWeight(.bold)
                                  .monospacedDigit()
                          } else {
                              Text(context.state.formattedTime)
                                  .font(.title2)
                                  .fontWeight(.bold)
                                  .monospacedDigit()
                          }

                          Text(context.state.statusText)
                              .font(.caption2)
                              .foregroundColor(.secondary)
                      }
                  }

                  DynamicIslandExpandedRegion(.bottom) {
                      // Progress bar with Native iOS Timer
                      if let startDate = context.state.startDate, 
                         let endDate = context.state.endDate,
                         context.state.isRunning {
                          // ✅ Native iOS Timer Progress Bar
                          ProgressView(
                              timerInterval: startDate...endDate,
                              countsDown: true,
                              label: { EmptyView() },
                              currentValueLabel: { EmptyView() }
                          )
                          .progressViewStyle(LinearProgressViewStyle())
                          .tint(context.state.progressColor)
                          .scaleEffect(y: 2.0)
                      } else {
                          // Fallback for paused/stopped state
                          ProgressView(value: context.state.progress)
                              .progressViewStyle(LinearProgressViewStyle())
                              .tint(context.state.progressColor)
                              .scaleEffect(y: 2.0)
                      }
                  }

              } compactLeading: {
                  // Compact Leading with progress ring
                  ZStack {
                      Circle()
                          .stroke(context.state.progressColor.opacity(0.3), lineWidth: 2)
                          .frame(width: 20, height: 20)
                      
                      Circle()
                          .trim(from: 0, to: context.state.progress)
                          .stroke(context.state.progressColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                          .frame(width: 20, height: 20)
                          .rotationEffect(.degrees(-90))
                      
                      Text("\(context.state.currentSet)")
                          .font(.system(size: 8, weight: .bold))
                          .foregroundColor(context.state.textColor)
                  }

              } compactTrailing: {
                  // Compact Trailing with enhanced time display
                  VStack(spacing: 0) {
                      // ✅ Native iOS Timer - Compact view
                      if let startDate = context.state.startDate, 
                         let endDate = context.state.endDate,
                         context.state.isRunning {
                          Text(timerInterval: startDate...endDate, countsDown: true)
                              .font(.system(size: 12, weight: .bold, design: .monospaced))
                              .foregroundColor(context.state.textColor)
                              .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                      } else {
                          Text(context.state.formattedTime)
                              .font(.system(size: 12, weight: .bold, design: .monospaced))
                              .foregroundColor(context.state.textColor)
                              .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                      }
                      
                      Text("REST")
                          .font(.system(size: 6, weight: .medium))
                          .foregroundColor(context.state.textColor.opacity(0.8))
                          .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                  }

              } minimal: {
                  // Minimal view with pulsing animation
                  ZStack {
                      Circle()
                          .fill(context.state.progressColor)
                          .frame(width: 12, height: 12)
                          .scaleEffect(context.state.isRunning ? 1.0 : 0.8)
                          .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: context.state.isRunning)
                      
                      if !context.state.isRunning {
                          Image(systemName: "pause.fill")
                              .font(.system(size: 6))
                              .foregroundColor(.white)
                      }
                  }
              }
              .widgetURL(URL(string: "gymbro://timer"))
              .keylineTint(context.state.progressColor)
          }
      }
  }

  // MARK: - Lock Screen Timer View
  @available(iOS 16.1, *)
  struct LockScreenTimerView: View {
      let context: ActivityViewContext<GymBroTimerAttributes>

      var body: some View {
          VStack(spacing: 12) {
              // Header with exercise info
              HStack {
                  Image(systemName: context.state.isInRPEMode ? "star.fill" : "dumbbell.fill")
                      .foregroundColor(context.state.isInRPEMode ? Color.orange : context.state.progressColor)
                      .font(.title3)

                  VStack(alignment: .leading, spacing: 2) {
                      Text(context.state.isInRPEMode ? "💪 Set Completato!" : context.attributes.exerciseName)
                          .font(.headline)
                          .fontWeight(.semibold)
                          .lineLimit(1)

                      HStack {
                          Text(context.state.setInfo)
                              .font(.subheadline)
                              .foregroundColor(.secondary)

                          Spacer()

                          Text(context.state.isInRPEMode ? "Rate this set" : context.state.statusText)
                              .font(.subheadline)
                              .foregroundColor(context.state.isInRPEMode ? .orange : (context.state.isRunning ? .primary : .orange))
                      }
                  }

                  Spacer()

                  // Timer display OR RPE display
                  VStack(alignment: .trailing, spacing: 4) {
                      if context.state.isInRPEMode {
                          // RPE Mode Display
                          VStack(alignment: .trailing, spacing: 2) {
                              Text(context.state.rpeDisplayText)
                                  .font(.title2)
                                  .fontWeight(.bold)
                                  .foregroundColor(context.state.rpeColor)
                              
                              if let weight = context.state.weight {
                                  Text("\(weight, specifier: "%.1f")kg")
                                      .font(.caption)
                                      .foregroundColor(.secondary)
                              }
                          }
                      } else {
                          // Timer Mode Display with Native iOS Timer
                          if let startDate = context.state.startDate, 
                             let endDate = context.state.endDate,
                             context.state.isRunning {
                              // ✅ Native iOS Timer - Main display
                              Text(timerInterval: startDate...endDate, countsDown: true)
                                  .font(.title)
                                  .fontWeight(.bold)
                                  .monospacedDigit()
                                  .foregroundColor(context.state.progressColor)
                                  .shadow(color: context.state.progressColor.opacity(0.3), radius: 2, x: 0, y: 1)
                          } else {
                              // Fallback for paused/stopped state
                              Text(context.state.formattedTime)
                                  .font(.title)
                                  .fontWeight(.bold)
                                  .monospacedDigit()
                                  .foregroundColor(context.state.progressColor)
                                  .shadow(color: context.state.progressColor.opacity(0.3), radius: 2, x: 0, y: 1)
                          }

                          // Small progress indicator with native timer progress
                          if let startDate = context.state.startDate, 
                             let endDate = context.state.endDate,
                             context.state.isRunning {
                              ProgressView(
                                  timerInterval: startDate...endDate,
                                  countsDown: true,
                                  label: { EmptyView() },
                                  currentValueLabel: { EmptyView() }
                              )
                              .progressViewStyle(LinearProgressViewStyle())
                              .tint(context.state.progressColor)
                              .frame(width: 60)
                              .scaleEffect(y: 1.5)
                          } else {
                              ProgressView(value: context.state.progress)
                                  .progressViewStyle(LinearProgressViewStyle())
                                  .tint(context.state.progressColor)
                                  .frame(width: 60)
                                  .scaleEffect(y: 1.5)
                          }
                      }
                  }
              }

              // Full width progress bar OR RPE content
              if context.state.isInRPEMode {
                  // RPE Information Display
                  HStack(spacing: 16) {
                      VStack {
                          Text("🔢")
                              .font(.title2)
                          Text("\(context.state.actualReps ?? context.state.targetReps ?? 0)")
                              .font(.title3)
                              .fontWeight(.bold)
                          Text("reps")
                              .font(.caption2)
                              .foregroundColor(.secondary)
                      }
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 8)
                      .background(Color(.systemGray6))
                      .cornerRadius(8)

                      VStack {
                          Text("⚡")
                              .font(.title2)
                          Text(context.state.selectedRPE != nil ? "\(context.state.selectedRPE!)" : "?")
                              .font(.title3)
                              .fontWeight(.bold)
                              .foregroundColor(context.state.rpeColor)
                          Text("RPE")
                              .font(.caption2)
                              .foregroundColor(.secondary)
                      }
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 8)
                      .background(Color(.systemGray6))
                      .cornerRadius(8)
                  }
              } else {
                  VStack(spacing: 8) {
                      // Timer Progress Bar with Native iOS Timer
                      if let startDate = context.state.startDate,
                         let endDate = context.state.endDate,
                         context.state.isRunning {
                          // ✅ Native iOS Timer Progress Bar
                          ProgressView(
                              timerInterval: startDate...endDate,
                              countsDown: true,
                              label: { EmptyView() },
                              currentValueLabel: { EmptyView() }
                          )
                          .progressViewStyle(LinearProgressViewStyle())
                          .tint(context.state.progressColor)
                          .scaleEffect(y: 2.0)
                      } else {
                          // Fallback for paused/stopped state
                          ProgressView(value: context.state.progress)
                              .progressViewStyle(LinearProgressViewStyle())
                              .tint(context.state.progressColor)
                              .scaleEffect(y: 2.0)
                      }

                      // ✅ INTERACTIVE BUTTONS - INSTANT RESPONSE (NO APP WAKE)
                      HStack(spacing: 12) {
                          // Pause/Resume Button
                          Button(intent: PauseResumeIntent()) {
                              HStack(spacing: 6) {
                                  Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                                      .font(.system(size: 14, weight: .semibold))
                                  Text(context.state.isRunning ? "Pause" : "Resume")
                                      .font(.system(size: 14, weight: .semibold))
                              }
                              .frame(maxWidth: .infinity)
                              .padding(.vertical, 10)
                              .background(context.state.isRunning ? Color.orange : Color.green)
                              .foregroundColor(.white)
                              .cornerRadius(8)
                          }
                          .buttonStyle(.plain)

                          // Add 30s Button
                          Button(intent: AddTimeIntent()) {
                              HStack(spacing: 6) {
                                  Image(systemName: "plus.circle.fill")
                                      .font(.system(size: 14, weight: .semibold))
                                  Text("+30s")
                                      .font(.system(size: 14, weight: .semibold))
                              }
                              .frame(maxWidth: .infinity)
                              .padding(.vertical, 10)
                              .background(Color.blue)
                              .foregroundColor(.white)
                              .cornerRadius(8)
                          }
                          .buttonStyle(.plain)

                          // Skip Button
                          Button(intent: SkipTimerIntent()) {
                              HStack(spacing: 6) {
                                  Image(systemName: "forward.fill")
                                      .font(.system(size: 14, weight: .semibold))
                                  Text("Skip")
                                      .font(.system(size: 14, weight: .semibold))
                              }
                              .frame(maxWidth: .infinity)
                              .padding(.vertical, 10)
                              .background(Color(.systemGray3))
                              .foregroundColor(.white)
                              .cornerRadius(8)
                          }
                          .buttonStyle(.plain)
                      }
                  }
              }
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(Color(.systemBackground))
          .cornerRadius(16)
          // ✅ NESSUNA OMBREGGIATURA per RPE Live Activities
      }
  }

// MARK: - ✅ RPE Live Activity Widget
@available(iOS 16.1, *)
struct GymBroRPELiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GymBroRPEAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenRPEView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text("💪")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.exerciseName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text("Set \(context.attributes.currentSet)/\(context.attributes.totalSets)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        if let rpe = context.state.selectedRPE {
                            Text("RPE: \(rpe)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(context.state.rpeColor)
                        } else {
                            Text("RPE?")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        Text("\(context.state.actualReps ?? context.attributes.targetReps) reps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Progress bar for completion
                    ProgressView(value: context.state.completionProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(context.state.rpeColor)
                        .scaleEffect(y: 2.0)
                }
                
            } compactLeading: {
                // Compact Leading
                Text("💪")
                    .font(.system(size: 16))
                
            } compactTrailing: {
                // Compact Trailing
                if let rpe = context.state.selectedRPE {
                    VStack(spacing: 0) {
                        Text("\(rpe)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(context.state.rpeColor)
                        
                        Text("RPE")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("RPE?")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                }
                
            } minimal: {
                // Minimal view
                ZStack {
                    Circle()
                        .fill(context.state.isConfirmed ? .green : .orange)
                        .frame(width: 12, height: 12)
                    
                    if context.state.isConfirmed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 6))
                            .foregroundColor(.white)
                    } else {
                        Text("?")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .widgetURL(URL(string: "gymbro://rpe"))
            .keylineTint(context.state.rpeColor)
        }
    }
}

// MARK: - Lock Screen RPE View (SENZA OMBREGGIATURE)
@available(iOS 16.1, *)
struct LockScreenRPEView: View {
    let context: ActivityViewContext<GymBroRPEAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("💪")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Set Completato!")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(context.attributes.exerciseName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("\(context.attributes.weight, specifier: "%.1f")kg • Set \(context.attributes.currentSet)/\(context.attributes.totalSets)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                VStack(alignment: .trailing, spacing: 4) {
                    if context.state.isConfirmed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Confermato")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("In attesa")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // RPE and Reps info
            HStack(spacing: 20) {
                // Reps
                VStack(spacing: 4) {
                    Text("🔢")
                        .font(.title2)
                    Text("\(context.state.actualReps ?? context.attributes.targetReps)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // RPE
                VStack(spacing: 4) {
                    Text("⚡")
                        .font(.title2)
                    if let rpe = context.state.selectedRPE {
                        Text("\(rpe)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(context.state.rpeColor)
                        Text(context.state.rpeDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("Select RPE")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Progress bar
            ProgressView(value: context.state.completionProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(context.state.rpeColor)
                .scaleEffect(y: 2.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        // ✅ NESSUNA OMBREGGIATURA come richiesto
    }
}

// MARK: - ✅ Schedule Countdown Live Activity Widget
@available(iOS 16.1, *)
struct GymBroScheduleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GymBroScheduleAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenScheduleView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: context.state.iconName)
                            .foregroundColor(context.state.urgencyColor)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.workoutName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            Text(context.state.statusText)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        // Countdown display
                        if context.state.isTimeUp {
                            Text(WidgetStrings.Schedule.go)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        } else {
                            Text(context.state.formattedTimeRemaining)
                                .font(.title2)
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .foregroundColor(context.state.urgencyColor)
                        }

                        Text("\(WidgetStrings.Common.at) \(context.state.scheduledTimeFormatted)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    // Countdown progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray4))
                                .frame(height: 8)

                            // Progress fill (shrinks as time approaches)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(context.state.urgencyColor)
                                .frame(width: geometry.size.width * context.state.countdownProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }

            } compactLeading: {
                // Compact Leading with icon
                Image(systemName: context.state.iconName)
                    .foregroundColor(context.state.urgencyColor)
                    .font(.system(size: 16))

            } compactTrailing: {
                // Compact Trailing with countdown
                VStack(spacing: 0) {
                    Text(context.state.shortTimeRemaining)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(context.state.urgencyColor)

                    Text(WidgetStrings.Schedule.left)
                        .font(.system(size: 6, weight: .medium))
                        .foregroundColor(.secondary)
                }

            } minimal: {
                // Minimal view with urgency indicator
                ZStack {
                    Circle()
                        .fill(context.state.urgencyColor)
                        .frame(width: 12, height: 12)

                    if context.state.isTimeUp {
                        Image(systemName: "figure.run")
                            .font(.system(size: 6))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.white)
                    }
                }
            }
            .widgetURL(URL(string: "gymbro://schedule/\(context.attributes.workoutId)"))
            .keylineTint(context.state.urgencyColor)
        }
    }
}

// MARK: - Lock Screen Schedule View
@available(iOS 16.1, *)
struct LockScreenScheduleView: View {
    let context: ActivityViewContext<GymBroScheduleAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Header with workout info
            HStack {
                // Icon with urgency color
                ZStack {
                    Circle()
                        .fill(context.state.urgencyColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: context.state.iconName)
                        .foregroundColor(context.state.urgencyColor)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.workoutName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    HStack {
                        Text(context.state.statusText)
                            .font(.subheadline)
                            .foregroundColor(context.state.urgencyColor)

                        Spacer()

                        Text("\(WidgetStrings.Common.at) \(context.state.scheduledTimeFormatted)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Countdown display
                VStack(alignment: .trailing, spacing: 4) {
                    if context.state.isTimeUp {
                        VStack(spacing: 2) {
                            Text("🏋️")
                                .font(.title2)
                            Text(WidgetStrings.Schedule.start)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text(context.state.formattedTimeRemaining)
                            .font(.title)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(context.state.urgencyColor)

                        Text(WidgetStrings.Schedule.remaining)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Progress bar showing time remaining
            if !context.state.isTimeUp {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [context.state.urgencyColor, context.state.urgencyColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * context.state.countdownProgress, height: 8)
                    }
                }
                .frame(height: 8)
            } else {
                // "Time to start" call to action
                HStack {
                    Spacer()

                    Label(WidgetStrings.Schedule.tapToStart, systemImage: "arrow.right.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)

                    Spacer()
                }
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    context.state.urgencyColor.opacity(0.05),
                    context.state.urgencyColor.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}
