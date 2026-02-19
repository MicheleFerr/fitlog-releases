//
//  WaitingView.swift
//  FitLogWatch Watch App
//
//  Extracted from ContentView.swift (P1-1 audit split)
//  Waiting screen shown when no workout is active
//

import SwiftUI

// MARK: - Waiting View (No Active Workout) - Minimal Design

struct WaitingView: View {
    @EnvironmentObject var connectivity: ConnectivityManager

    // Localized strings (from Flutter app)
    private var isItalian: Bool { connectivity.appLocale == "it" }
    private var connectedText: String { isItalian ? "Connesso" : "Connected" }
    private var waitingText: String { isItalian ? "In attesa..." : "Waiting..." }
    private var startWorkoutText: String { isItalian ? "Inizia un allenamento\nsu iPhone" : "Start a workout on\nyour iPhone" }

    var body: some View {
        VStack(spacing: 12) {
            // Connection status
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.isReachable ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(connectivity.isReachable ? connectedText : waitingText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isItalian ? "Stato connessione: \(connectivity.isReachable ? connectedText : waitingText)" : "Connection status: \(connectivity.isReachable ? connectedText : waitingText)")

            Spacer()

            // Main icon - clean, no effects
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.blue)
                .accessibilityHidden(true)

            Text("FitLog")
                .font(.system(size: 17, weight: .semibold))
                .accessibilityAddTraits(.isHeader)

            Text(startWorkoutText)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            // Heart rate display (if available)
            if connectivity.currentHeartRate > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .accessibilityHidden(true)

                    Text("\(Int(connectivity.currentHeartRate))")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))

                    Text("BPM")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(isItalian ? "Frequenza cardiaca: \(Int(connectivity.currentHeartRate)) battiti per minuto" : "Heart rate: \(Int(connectivity.currentHeartRate)) beats per minute")
            }
        }
        .padding()
    }
}
