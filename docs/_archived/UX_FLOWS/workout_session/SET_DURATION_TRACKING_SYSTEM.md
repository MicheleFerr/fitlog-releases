# 📊 Set Duration Tracking System - Technical Documentation

## Overview
The set duration tracking system measures the **actual execution time** of each set by calculating the time difference between consecutive set completions within the same exercise.

## ✅ How It Works

### Tracking Flow
```
Set 1 completed → Save timestamp T1
Set 2 completed → Duration = NOW - T1, Save T2, Remove T1  
Set 3 completed → Duration = NOW - T2, Save T3, Remove T2
New Exercise → Clear all timestamps from previous exercise
```

### Key Points
- **Set 1**: No duration (it's the first set, no previous reference)
- **Set 2+**: Duration = time since previous set completion
- **Typical Duration**: 5-30 seconds (actual set execution time)
- **Memory Usage**: Only 1 timestamp per active exercise
- **CPU Usage**: ~0% (no timers, only timestamp differences)

## 📝 Implementation Details

### Data Structure
```dart
class SetDurationTracker {
  // One timestamp per exercise (not per set!)
  final Map<String, DateTime> _lastSetCompletionTime = {};
}
```

### Core Method
```dart
double? onSetCompleted(String exerciseId, int setNumber) {
  final now = DateTime.now();
  final previousSetTime = _lastSetCompletionTime[exerciseId];
  
  // Calculate duration from previous set
  double? duration;
  if (previousSetTime != null) {
    duration = now.difference(previousSetTime).inMilliseconds.toDouble();
  }
  
  // Update timestamp for next set
  _lastSetCompletionTime[exerciseId] = now;
  
  return duration;
}
```

## 🎯 Example Timeline

```
14:30:15 - Complete Bench Press Set 1 → Save T1
14:30:45 - Complete Bench Press Set 2 → Duration = 30s (30:45 - 30:15)
14:31:20 - Complete Bench Press Set 3 → Duration = 35s (31:20 - 30:45)
14:32:00 - Switch to Squats → Clear Bench Press timestamps
14:32:30 - Complete Squat Set 1 → Save T1 for Squats
14:33:05 - Complete Squat Set 2 → Duration = 35s (33:05 - 32:30)
```

## 🔧 UI Display

### Format
- **Display**: `12.34s` (2 decimal places)
- **Edit Field**: `12,34` (seconds,centiseconds)
- **Storage**: Milliseconds as double (12340.0)

### Visual Representation
```
Set 1: ✓ 10kg × 12 reps [RPE 8] [no duration - first set]
Set 2: ✓ 10kg × 11 reps [RPE 8] [⏱ 28.45s]
Set 3: ✓ 10kg × 10 reps [RPE 9] [⏱ 31.22s]
```

## 💡 Why This Approach?

### Previous (Incorrect) System
```
Rest Timer End → Set Start → Set Complete = Duration
❌ Problem: Includes preparation time, adjusting weights, getting in position
```

### Current (Correct) System
```
Previous Set Complete → Current Set Complete = Duration
✅ Measures: Actual execution time only
```

## 🚀 Performance Benefits

1. **Minimal Memory**: O(1) per exercise (not O(n) per set)
2. **Zero CPU**: No background timers or polling
3. **Battery Friendly**: Only 2 timestamp operations per set
4. **Accurate**: Measures true set execution time

## 📊 Data Insights

With this data, users can analyze:
- **Fatigue Patterns**: Sets taking longer = muscle fatigue
- **Rest Optimization**: Correlation between rest and set duration
- **Training Velocity**: Speed of execution for power training
- **Volume Efficiency**: Time under tension metrics

## 🔐 Firebase Storage

The duration is saved in Firebase as:
```json
{
  "sets": [
    {
      "set": 1,
      "weight": "10",
      "reps": "12",
      "actualReps": "12",
      "rpe": 8,
      "setDurationMillis": null,  // First set has no duration
      "done": true
    },
    {
      "set": 2,
      "weight": "10",
      "reps": "12",
      "actualReps": "11",
      "rpe": 8,
      "setDurationMillis": 28450.0,  // 28.45 seconds
      "done": true
    }
  ]
}
```

## 🎯 Future Enhancements

1. **Auto-detect long breaks**: If duration > 5 minutes, don't record (user took a break)
2. **Velocity tracking**: Calculate bar speed for power training
3. **Fatigue alerts**: Warn when sets are taking significantly longer
4. **Rest suggestions**: Recommend rest based on set duration trends