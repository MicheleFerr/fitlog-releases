/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: history
/// 🔧 Type: entity
///
/// Sync status enum for workout history
library;

/// Sync status enum
enum SyncStatus { notSynced, initialSyncing, syncing, synced, needsSync, error }
