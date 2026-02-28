//
//  WatchStrings.swift
//  FitLogWatch Watch App
//
//  P1-2 FIX: Centralized localization strings
//  Replaces scattered `isItalian ? "..." : "..."` pattern
//

import Foundation

/// Centralized localization for Watch UI strings
/// Currently supports English (default) and Italian
enum WatchStrings {

    // MARK: - Generic Helper

    /// Centralized locale switch for one-off strings not yet mapped as dedicated keys.
    static func localized(_ locale: String, it: String, en: String) -> String {
        locale == "it" ? it : en
    }

    // MARK: - Connection & Waiting

    static func connected(_ locale: String) -> String {
        locale == "it" ? "Connesso" : "Connected"
    }

    static func waiting(_ locale: String) -> String {
        locale == "it" ? "In attesa..." : "Waiting..."
    }

    static func startWorkoutOnIPhone(_ locale: String) -> String {
        locale == "it" ? "Inizia un allenamento\nsu iPhone" : "Start a workout on\nyour iPhone"
    }

    static func waitingForWorkout(_ locale: String) -> String {
        locale == "it" ? "In attesa di allenamento..." : "Waiting for workout..."
    }

    static func openAppOnIPhone(_ locale: String) -> String {
        locale == "it" ? "Apri FitLog su iPhone" : "Open FitLog on iPhone"
    }

    static func workoutActive(_ locale: String) -> String {
        locale == "it" ? "Allenamento attivo" : "Workout Active"
    }

    // MARK: - Set Info

    static func setLabel(_ locale: String) -> String {
        locale == "it" ? "Serie" : "Set"
    }

    static func ofLabel(_ locale: String) -> String {
        locale == "it" ? "di" : "of"
    }

    static func nextSet(_ locale: String) -> String {
        locale == "it" ? "Prossima serie" : "Next Set"
    }

    static func completeSet(_ locale: String) -> String {
        locale == "it" ? "Completa serie" : "Complete Set"
    }

    static func warmupLabel(_ locale: String) -> String {
        locale == "it" ? "Riscaldamento" : "Warmup"
    }

    static func workingLabel(_ locale: String) -> String {
        locale == "it" ? "Lavorativa" : "Working"
    }

    static func complete(_ locale: String) -> String {
        locale == "it" ? "Completo" : "Complete"
    }

    static func done(_ locale: String) -> String {
        locale == "it" ? "Fatto!" : "Done!"
    }

    static func reps(_ locale: String) -> String {
        locale == "it" ? "rip" : "reps"
    }

    // MARK: - Rest Timer

    static func rest(_ locale: String) -> String {
        locale == "it" ? "Riposo" : "Rest"
    }

    static func skipRest(_ locale: String) -> String {
        locale == "it" ? "Salta riposo" : "Skip Rest"
    }

    static func addTime(_ locale: String) -> String {
        locale == "it" ? "Aggiungi tempo" : "Add Time"
    }

    static func paused(_ locale: String) -> String {
        locale == "it" ? "In pausa" : "Paused"
    }

    static func ready(_ locale: String) -> String {
        locale == "it" ? "Pronto!" : "Ready!"
    }

    static func tapToAddTime(_ locale: String) -> String {
        locale == "it" ? "Tocca per aggiungere tempo" : "Tap to add time"
    }

    static func start(_ locale: String) -> String {
        locale == "it" ? "Avvia" : "Start"
    }

    static func resume(_ locale: String) -> String {
        locale == "it" ? "Riprendi" : "Resume"
    }

    // MARK: - Stats

    static func duration(_ locale: String) -> String {
        locale == "it" ? "Durata" : "Duration"
    }

    static func calories(_ locale: String) -> String {
        locale == "it" ? "Calorie" : "Calories"
    }

    static func heartRate(_ locale: String) -> String {
        locale == "it" ? "Freq. cardiaca" : "Heart Rate"
    }

    static func avgHeartRate(_ locale: String) -> String {
        locale == "it" ? "FC Media" : "Avg HR"
    }

    static func time(_ locale: String) -> String {
        locale == "it" ? "tempo" : "time"
    }

    static func sets(_ locale: String) -> String {
        locale == "it" ? "serie" : "sets"
    }

    // MARK: - Actions

    static func endWorkout(_ locale: String) -> String {
        locale == "it" ? "Termina allenamento" : "End Workout"
    }

    static func end(_ locale: String) -> String {
        locale == "it" ? "Termina" : "End"
    }

    static func confirmEnd(_ locale: String) -> String {
        locale == "it" ? "Terminare allenamento?" : "End workout?"
    }

    static func save(_ locale: String) -> String {
        locale == "it" ? "Salva" : "Save"
    }

    static func discard(_ locale: String) -> String {
        locale == "it" ? "Scarta" : "Discard"
    }

    static func cancel(_ locale: String) -> String {
        locale == "it" ? "Annulla" : "Cancel"
    }

    static func confirm(_ locale: String) -> String {
        locale == "it" ? "Conferma" : "Confirm"
    }

    static func confirmed(_ locale: String) -> String {
        locale == "it" ? "Confermato" : "Confirmed"
    }

    static func skip(_ locale: String) -> String {
        locale == "it" ? "Salta" : "Skip"
    }

    static func close(_ locale: String) -> String {
        locale == "it" ? "Chiudi" : "Close"
    }

    // MARK: - Edit

    static func edit(_ locale: String) -> String {
        locale == "it" ? "Modifica" : "Edit"
    }

    static func editTarget(_ locale: String) -> String {
        locale == "it" ? "Modifica target" : "Edit target"
    }

    static func editSet(_ locale: String) -> String {
        locale == "it" ? "Modifica Serie" : "Edit Set"
    }

    static func editReps(_ locale: String) -> String {
        locale == "it" ? "Modifica reps" : "Edit Reps"
    }

    static func tapToEdit(_ locale: String) -> String {
        locale == "it" ? "tocca per modificare" : "tap to edit"
    }

    static func copyToAll(_ locale: String) -> String {
        locale == "it" ? "Copia in tutti" : "Copy to all"
    }

    static func copyPrevious(_ locale: String) -> String {
        locale == "it" ? "Copia precedente" : "Copy previous"
    }

    static func undo(_ locale: String) -> String {
        locale == "it" ? "Annulla" : "Undo"
    }

    static func weight(_ locale: String) -> String {
        locale == "it" ? "Peso" : "Weight"
    }

    static func decrease(_ locale: String) -> String {
        locale == "it" ? "Diminuisci" : "Decrease"
    }

    static func increase(_ locale: String) -> String {
        locale == "it" ? "Aumenta" : "Increase"
    }

    static func crownToAdjust(_ locale: String) -> String {
        locale == "it" ? "Corona per regolare" : "Crown to adjust"
    }

    // MARK: - Effort

    static func effortTitle(_ locale: String) -> String {
        locale == "it" ? "Sforzo percepito" : "Perceived Effort"
    }

    static func turnCrown(_ locale: String) -> String {
        locale == "it" ? "Ruota corona" : "Turn crown"
    }

    // MARK: - Advanced Workouts

    static func supersetLabel(_ locale: String) -> String {
        locale == "it" ? "Superset" : "Superset"
    }

    static func roundLabel(_ locale: String) -> String {
        locale == "it" ? "Round" : "Round"
    }

    static func completeRound(_ locale: String) -> String {
        locale == "it" ? "Completa Round" : "Complete Round"
    }

    static func dropsetLabel(_ locale: String) -> String {
        locale == "it" ? "Drop Set" : "Drop Set"
    }

    static func stageLabel(_ locale: String) -> String {
        locale == "it" ? "Fase" : "Stage"
    }

    static func restPauseLabel(_ locale: String) -> String {
        locale == "it" ? "Rest-Pause" : "Rest-Pause"
    }

    // MARK: - Navigation

    static func exercises(_ locale: String) -> String {
        locale == "it" ? "Esercizi" : "Exercises"
    }

    static func previous(_ locale: String) -> String {
        locale == "it" ? "Precedente" : "Previous"
    }

    static func next(_ locale: String) -> String {
        locale == "it" ? "Successivo" : "Next"
    }

    static func go(_ locale: String) -> String {
        locale == "it" ? "Vai" : "Go"
    }

    static func selectSet(_ locale: String) -> String {
        locale == "it" ? "Seleziona Serie" : "Select Set"
    }

    static func goToExercise(_ locale: String) -> String {
        locale == "it" ? "Vai a Esercizio" : "Go to Exercise"
    }

    static func changeExercise(_ locale: String) -> String {
        locale == "it" ? "Cambia esercizio" : "Change exercise"
    }

    static func tapToSelectSet(_ locale: String) -> String {
        locale == "it" ? "tocca per selezionare serie" : "tap to select set"
    }

    // MARK: - Form Cues

    static func formCuesTitle(_ locale: String) -> String {
        locale == "it" ? "Note forma" : "Form Cues"
    }

    static func formNotesTitle(_ locale: String) -> String {
        locale == "it" ? "Note Tecniche" : "Form Cues"
    }

    static func noFormCues(_ locale: String) -> String {
        locale == "it" ? "Nessuna nota" : "No notes"
    }

    static func tutTitle(_ locale: String) -> String {
        locale == "it" ? "Tempo" : "Tempo"
    }

    // MARK: - Summary

    static func workoutComplete(_ locale: String) -> String {
        locale == "it" ? "Allenamento completato!" : "Workout Complete!"
    }

    static func completed(_ locale: String) -> String {
        locale == "it" ? "Completato!" : "Completed!"
    }

    static func discarded(_ locale: String) -> String {
        locale == "it" ? "Scartato" : "Discarded"
    }

    static func saved(_ locale: String) -> String {
        locale == "it" ? "Salvato" : "Saved"
    }

    static func greatJob(_ locale: String) -> String {
        locale == "it" ? "Ottimo lavoro!" : "Great job!"
    }

    static func checkPhone(_ locale: String) -> String {
        locale == "it" ? "Controlla iPhone" : "Check iPhone"
    }

    // MARK: - Formatting Helpers

    /// Format weight with appropriate unit
    static func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(weight))"
            : String(format: "%.1f", weight)
    }

    /// Format time from seconds to mm:ss
    static func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
