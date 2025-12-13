# ADR-003: Local-first Hybrid Sync Architecture

## Status
Accepted

## Context

Initial architecture was cloud-first (all data in Firebase Firestore). This caused:
- **High costs**: ~$324/month in Firestore reads/writes
- **Poor offline UX**: App unusable without internet
- **Slow performance**: Network latency on every operation
- **Free user limitations**: Couldn't offer full functionality

## Decision

We implemented a **local-first hybrid sync** architecture:
- All data stored locally in Hive (always)
- Cloud sync only for Premium users
- Async background sync (5 min active, 30 min background)

## Consequences

### Pros

1. **95% cost reduction**: $324/month → $16/month
2. **Offline-first**: Full functionality without internet
3. **Instant UX**: No network latency for local operations
4. **Free users**: Complete app functionality
5. **Premium value**: Cross-device sync as paid feature

### Cons

1. **Complexity**: Must handle sync conflicts
2. **Data loss risk**: Local-only users lose data on device loss
3. **Duplicate logic**: Some logic in both local and cloud paths
4. **Testing**: More scenarios to test (online/offline/sync)

### Implementation

```
┌─────────────────────────────────────────┐
│           BaseHybridRepository          │
│  ┌──────────────┐  ┌──────────────┐    │
│  │ Local (Hive) │  │ Cloud Sync   │    │
│  │   ALWAYS     │  │  (Premium)   │    │
│  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────┘
```

All repositories extend `BaseHybridRepository<T>`:

```dart
class WorkoutRepository extends BaseHybridRepository<Workout> {
  WorkoutRepository() : super(
    featureName: 'workouts',
    collectionName: 'workouts',
    requiresPremiumForCloud: true,
  );
}
```

### Sync Timing

| State | Interval | Trigger |
|-------|----------|---------|
| Active (foreground) | 5 minutes | Timer |
| Background | 30 minutes | Background task |
| Manual | On demand | User action |
| Events | Immediate | Post-workout |

### Conflict Resolution

**Cloud wins** strategy for simplicity:
1. Local change queued for sync
2. On sync, fetch cloud version
3. If conflict, cloud version takes precedence
4. User notified of conflict resolution

## References

- [HYBRID_ARCHITECTURE.md](../TECHNICAL_FOUNDATION/HYBRID_ARCHITECTURE.md)
- [SNAPSHOT_DIFFERENTIAL_SYNC_ARCHITECTURE.md](../TECHNICAL_FOUNDATION/SNAPSHOT_DIFFERENTIAL_SYNC_ARCHITECTURE.md)
