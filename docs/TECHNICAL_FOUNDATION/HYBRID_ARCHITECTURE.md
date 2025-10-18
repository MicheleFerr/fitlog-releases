# 🏗️ GymBro Hybrid Architecture Documentation

## 📋 Executive Summary

GymBro now implements a **local-first hybrid architecture** that dramatically reduces operational costs while providing a premium sync experience for paying users.

### 🎯 Key Benefits:
- **95% reduction in Firebase/Firestore costs**
- **100% offline functionality for free users**
- **Premium cross-device sync for paying users**
- **Automatic sync enforcement for all new features**

---

## 🏛️ Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    USER INTERFACE                    │
├─────────────────────────────────────────────────────┤
│                  RIVERPOD PROVIDERS                  │
├─────────────────────────────────────────────────────┤
│               HYBRID REPOSITORIES                    │
│  ┌─────────────────────────────────────────────┐   │
│  │         BaseHybridRepository<T>             │   │
│  │  ┌──────────────┐  ┌──────────────┐       │   │
│  │  │ Local (Hive) │  │ Cloud Sync   │       │   │
│  │  │   ALWAYS     │  │  (Premium)   │       │   │
│  │  └──────────────┘  └──────────────┘       │   │
│  └─────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────┤
│                   SYNC MANAGER                       │
│         (5 min active / 30 min background)          │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Free Users:
1. **Write**: Data → Hive (local) → ✅ Done
2. **Read**: Hive (local) → Data → ✅ Done
3. **Cost**: $0 (no cloud operations)

### Premium Users:
1. **Write**: Data → Hive (local) → Sync Queue → Cloud (async)
2. **Read**: Hive (local) + Cloud (merge) → Data
3. **Cost**: Minimal (batched sync operations)

---

## 🛠️ Implementation Guide

### 1. Creating a New Feature Repository

**ALWAYS** extend `BaseHybridRepository`:

```dart
class MyFeatureRepository extends BaseHybridRepository<MyEntity> {
  MyFeatureRepository() : super(
    featureName: 'my_feature',
    collectionName: 'my_collection',
    requiresPremiumForCloud: true, // or false for always-sync features
  );

  @override
  Map<String, dynamic> toJson(MyEntity entity) => entity.toJson();

  @override
  MyEntity fromJson(Map<String, dynamic> json) => MyEntity.fromJson(json);

  @override
  String getId(MyEntity entity) => entity.id;

  @override
  bool validate(MyEntity entity) => entity.id.isNotEmpty;
}
```

### 2. Using the Repository

```dart
// In your provider
final myFeatureProvider = Provider<MyFeatureRepository>((ref) {
  return MyFeatureRepository();
});

// Save data (automatic local + premium sync)
await repository.save(myEntity);

// Get data (automatic local + cloud merge for premium)
final entity = await repository.get(id);

// Get all data
final entities = await repository.getAll();
```

---

## 📊 Feature Status

| Feature | Local Storage | Premium Sync | Repository |
|---------|--------------|--------------|------------|
| ✅ Workouts | Hive | ✅ 5 min | `HybridWorkoutRepositoryImpl` |
| ✅ Templates | Hive | ✅ On change | `HybridTemplateRepository` |
| ✅ Achievements | Hive | ✅ On unlock | `HybridAchievementRepository` |
| ✅ Community | Hive | ✅ Premium only | `HybridCommunityRepository` |
| ✅ Preferences | Hive | ✅ On change | `HybridAppConfigRepository` |
| ✅ Exercise Activity | Hive | ✅ 5 min | `HybridExerciseActivityRepository` |

---

## ⏱️ Sync Timing

### Active App (Foreground):
- **Interval**: 5 minutes
- **Trigger**: Timer-based + manual after workout
- **Battery**: Normal operation

### Background App:
- **Interval**: 30 minutes
- **Trigger**: Background task
- **Battery**: Optimized (skips if < 20%)

### Manual Triggers:
- App launch
- After workout completion
- User manual sync request
- Network reconnection

---

## 💰 Cost Analysis

### Before (All Firebase):
- **Reads**: ~100,000/day @ $0.06/100k = $1.80/day
- **Writes**: ~50,000/day @ $0.18/100k = $9.00/day
- **Total**: ~$324/month

### After (Hybrid):
- **Free Users (90%)**: $0 (local only)
- **Premium Users (10%)**: 
  - Reads: ~5,000/day = $0.09/day
  - Writes: ~2,500/day = $0.45/day
- **Total**: ~$16.20/month
- **Savings**: 95% reduction

---

## 🔒 Security & Privacy

### Local Storage:
- Encrypted with Hive
- User-specific keys
- Auto-cleanup on logout

### Cloud Sync:
- Firebase Security Rules
- User ID validation
- Premium tier verification
- GDPR compliant

---

## 🧪 Testing

### Unit Tests:
```dart
test('should save locally for free users', () async {
  final repo = MyFeatureRepository();
  // Mock as free user
  final result = await repo.save(entity);
  expect(localBox.contains(entity.id), true);
  expect(syncQueue.isEmpty, true);
});

test('should queue sync for premium users', () async {
  final repo = MyFeatureRepository();
  // Mock as premium user
  final result = await repo.save(entity);
  expect(localBox.contains(entity.id), true);
  expect(syncQueue.isNotEmpty, true);
});
```

### Integration Tests:
- Offline mode testing
- Sync conflict resolution
- Premium upgrade flow
- Data migration

---

## 🚀 Migration Checklist

When adding a new feature:

- [ ] Extend `BaseHybridRepository<T>`
- [ ] Implement required abstract methods
- [ ] Add feature to `PremiumSyncManager`
- [ ] Update this documentation
- [ ] Write unit tests
- [ ] Test offline mode
- [ ] Test premium sync
- [ ] Update Firebase rules if needed

---

## 📱 Premium Features

### What Premium Users Get:
1. **Cross-device sync** - Access data on all devices
2. **Cloud backup** - Never lose data
3. **Community access** - Global exercise database
4. **Real-time sync** - 5-minute intervals
5. **Priority support** - Direct assistance

### What Free Users Get:
1. **Full app functionality** - Everything works offline
2. **Unlimited local storage** - No limits
3. **All features** - Nothing locked
4. **Local backup** - Export/import
5. **Community support** - Forums

---

## 🔧 Troubleshooting

### Sync Not Working:
1. Check premium status: `repository.isPremiumUser`
2. Check sync queue: `repository.getSyncStats()`
3. Check connectivity: `PremiumSyncManager.getSyncStatus()`
4. Force sync: `syncManager.syncNow(force: true)`

### Data Not Appearing:
1. Check local first: `Hive.box('feature_data').get(key)`
2. Check sync status: `repository.getSyncStats()`
3. Clear cache: `repository.clearLocalData()`
4. Re-sync: `repository.processSyncQueue()`

---

## 📚 Code Examples

### Complete Feature Implementation:

```dart
// 1. Entity
class MyFeature {
  final String id;
  final String name;
  final DateTime createdAt;
  
  Map<String, dynamic> toJson() => {...};
  factory MyFeature.fromJson(Map json) => MyFeature(...);
}

// 2. Repository
class MyFeatureRepository extends BaseHybridRepository<MyFeature> {
  // Implementation as shown above
}

// 3. Provider
final myFeatureProvider = Provider<MyFeatureRepository>((ref) {
  return MyFeatureRepository();
});

// 4. Usage in UI
class MyFeatureScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final repo = ref.read(myFeatureProvider);
    
    // Save
    await repo.save(myFeature);
    
    // Get all
    final features = await repo.getAll();
    
    return ListView(...);
  }
}
```

---

## 🎯 Best Practices

1. **Always extend BaseHybridRepository** - Never create direct Firebase repositories
2. **Test offline first** - Ensure app works without connection
3. **Batch operations** - Use sync queue for efficiency
4. **Handle conflicts** - Cloud data wins on conflict
5. **Monitor sync** - Use sync events and statistics
6. **Optimize queries** - Use filters and limits
7. **Cache smartly** - Keep frequently accessed data local

---

## 📈 Future Enhancements

- [ ] Selective sync (choose what to sync)
- [ ] Compression for large data
- [ ] Differential sync (only changes)
- [ ] P2P sync between user devices
- [ ] Offline collaboration features
- [ ] Advanced conflict resolution
- [ ] Sync analytics dashboard

---

## 🤝 Contributing

When contributing new features:
1. **Must** extend BaseHybridRepository
2. **Must** work offline for free users
3. **Must** include tests
4. **Must** update this documentation
5. **Should** optimize for minimal sync

---

## 📞 Support

For issues with the hybrid architecture:
- Check this documentation first
- Review BaseHybridRepository implementation
- Check sync logs: `repository.getSyncStats()`
- File issue with sync statistics

---

*Last Updated: 2025*
*Version: 1.0.0*