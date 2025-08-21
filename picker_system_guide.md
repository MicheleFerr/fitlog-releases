# 🎯 Number Picker System Guide

## ⚖️ **Weight Picker**

### **Features:**
- **Range**: 0 - 500 kg/lbs
- **Increment**: 0.5 (perfect for progressive overload)
- **Smooth Scrolling**: ListWheelScrollView with physics
- **Quick Select**: Common weight plates [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100]
- **Unit Aware**: Automatic kg/lbs display based on user settings
- **Visual Feedback**: Selection indicator + animated text

### **UX Flow:**
```
Edit Set Modal → Tap Weight Selector → Weight Picker Opens
├── Scroll wheel to fine-tune weight
├── Quick select chips for common weights  
└── Select button → Updates set weight
```

## 🔄 **Reps Picker**

### **Features:**
- **Range**: 1 - 100 reps
- **Increment**: 1 rep
- **Quick Select**: Common rep ranges [1, 3, 5, 6, 8, 10, 12, 15, 20, 25, 30]
- **Smooth Animation**: 200ms transitions for selection
- **Rep-Specific Design**: Secondary color scheme (blue)

### **UX Flow:**
```
Edit Set Modal → Tap Reps Selector → Reps Picker Opens  
├── Scroll wheel for precise rep count
├── Quick select for standard rep ranges
└── Select button → Updates set reps
```

## 🎨 **Design System**

### **Color Coding:**
- **Weight Picker**: Primary color (red/orange) + fitness_center icon
- **Reps Picker**: Secondary color (blue) + repeat icon
- **Selection Indicator**: Highlighted background + border
- **Quick Select**: FilterChips with selection state

### **Animations:**
- **Scroll Physics**: FixedExtentScrollPhysics for tactile feel
- **Text Transitions**: AnimatedSwitcher for smooth changes  
- **Selection Feedback**: Scale and color transitions
- **Modal Appearance**: Bottom sheet with rounded corners

## 🚀 **Advantages over Keyboard Input**

1. **⚡ Speed**: No typing, just scroll and tap
2. **🎯 Precision**: Exact 0.5kg increments, no input errors
3. **📱 Native Feel**: iOS-style wheel picker experience  
4. **🧠 Cognitive Load**: Visual selection vs mental calculation
5. **👆 One-Handed**: Easy to use during workout
6. **🔢 Valid Ranges**: No invalid inputs (negative weights, etc.)

## 💡 **Pro Tips for Users**
- **Quick Plates**: Use quick select for standard plate weights
- **Progressive Overload**: Easy 0.5kg increments for gradual progression
- **Rep Ranges**: Quick select for strength (1-5), hypertrophy (8-12), endurance (15+)
- **Scroll Momentum**: Flick for fast navigation, fine-tune for precision

Perfect for gym environment: fast, intuitive, error-free! 🏋️‍♂️✨