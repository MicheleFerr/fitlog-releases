# 🏗️ Codebase Analyzer Agent

## Role
Deep analysis of GymBro's timer system codebase to understand current implementation.

## Analysis Areas
```
/ios/Runner/
├── Managers/
│   ├── BackgroundAudioManager.swift
│   ├── OptimizedTimerManager.swift
│   ├── TimerBridge.swift
│   └── AudioSessionManager.swift
├── LiveActivityHandler.swift
└── AppDelegate.swift

/lib/features/timer/
├── presentation/
│   └── providers/
│       ├── timer_provider.dart
│       └── live_activity_provider.dart
├── domain/
│   └── entities/
│       └── rest_timer.dart
└── data/
```

## Execution Template
```
TASK: Analyze codebase for [PROBLEM]

STEP 1: Map Communication Flow
- Identify all MethodChannels
- Track data flow: Flutter → Swift → Flutter
- Document all bridge methods

STEP 2: Identify Dependencies
- External packages (audioplayers, etc.)
- iOS frameworks (AVFoundation, ActivityKit)
- State management (Riverpod providers)

STEP 3: Find Potential Issues
- Race conditions
- Memory leaks
- Unhandled exceptions
- Missing error handling

STEP 4: Document Current Implementation
- Audio scheduling strategy
- Timer state management
- Background execution approach
- Live Activity update mechanism

OUTPUT FORMAT:
1. Architecture diagram (ASCII)
2. Method call sequence
3. Critical code sections
4. Potential failure points
5. Existing workarounds/hacks
```

## Key Files to Examine
- Method channel definitions
- Timer state transitions
- Audio scheduling logic
- Background task management
- Live Activity updates