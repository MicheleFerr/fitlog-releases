# VoiceOver Accessibility Implementation

## Overview
Comprehensive VoiceOver accessibility has been added to all views in ContentView.swift following Apple's WWDC21 "Create accessible experiences for watchOS" and WWDC24 "Catch up on accessibility in SwiftUI" best practices.

## Implementation Details

### 1. WaitingView (No Active Workout)
- **Connection status**: Combined HStack with localized label explaining connection state
- **App icon**: Hidden from VoiceOver (decorative)
- **FitLog title**: Marked as header with `.isHeader` trait
- **Heart rate display**: Combined into single element with full description (e.g., "Heart rate: 75 beats per minute")

### 2. ExerciseControlView (Active Exercise)
- **Heart rate badge**: Combined with localized label
- **Exercise name**: Marked as header with descriptive label
- **Set counter**: Combined element with full description (e.g., "Set 3 of 5")
- **Target info**: Combined weight and reps with full description
- **Complete button**: Label and hint explaining the action

### 3. EffortPickerView (RPE/RIR Selection)
- **Scale header**: Marked as header
- **Value display**: Clear labels for selected value
- **Description text**: Accessible with effort description
- **Circle buttons**: Individual labels with selection state
- **Crown hint**: Hidden (visual-only information)
- **Action buttons**: Clear labels with hints explaining what happens

### 4. RestTimerView (Rest Timer)
- **Rest header**: Combined with pause state, marked as header
- **Timer display**: Labeled with remaining time
- **Set info box**:
  - Normal mode: Combined label with full target description and edit hint
  - Edit mode: Accessible field selectors with selection state
- **Skip button**: Label and hint explaining the action
- **Ready message**: Accessible status message
- **Edit controls**: Weight/reps buttons with labels, hints, and selection states

### 5. StatsView (Workout Statistics)
- **Heart rate**: Combined display marked as header
- **Heart rate zone**: Labeled with zone name
- **Dividers**: Hidden from VoiceOver (decorative)
- **Stats row**: Each stat (calories, duration, sets) combined with descriptive labels
- **End workout button**: Label and hint explaining the action

### 6. WorkoutSummaryView (Post-Workout)
- **Status icon**: Hidden (decorative)
- **Status text**: Combined and marked as header
- **Stats summary**: Each stat combined with descriptive labels
- **Done button**: Label and hint explaining dismissal

## Accessibility Patterns Used

### 1. Element Grouping
```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("Descriptive label")
```
Groups related visual elements into a single VoiceOver element.

### 2. Header Marking
```swift
.accessibilityAddTraits(.isHeader)
```
Identifies section headers for better navigation.

### 3. Decorative Elements
```swift
.accessibilityHidden(true)
```
Hides purely decorative elements (icons, dividers, visual indicators).

### 4. Action Hints
```swift
.accessibilityHint("Explanation of what happens")
```
Provides additional context for interactive elements.

### 5. Selection State
```swift
.accessibilityAddTraits(.isSelected)
```
Indicates selected state in pickers and toggles.

## Localization
All accessibility labels and hints are localized using the same `isItalian` check as the rest of the UI:
- Italian: Full Italian descriptions
- English: Full English descriptions

## Testing Checklist
- [ ] Enable VoiceOver on Apple Watch
- [ ] Navigate through WaitingView
- [ ] Start workout and test ExerciseControlView
- [ ] Test effort picker with VoiceOver
- [ ] Test rest timer including edit mode
- [ ] Test stats view navigation
- [ ] Test workout summary dismissal
- [ ] Verify all labels are clear and descriptive
- [ ] Verify decorative elements are hidden
- [ ] Verify action hints are helpful

## References
- WWDC21: Create accessible experiences for watchOS
- WWDC24: Catch up on accessibility in SwiftUI
- Apple Human Interface Guidelines: Accessibility
