---
description: Analyze and optimize code performance
---

# Performance Optimization Analysis

Please analyze the following file(s) for performance optimization opportunities:

**Target**: `$1`

Focus on:

## 🔍 Widget Performance
- Identify widgets that should be `const`
- Find unnecessary rebuilds in ConsumerWidget/StatefulWidget
- Check for proper use of `.select()` in Riverpod providers
- Spot heavy computations in build methods

## 💾 Memory Management
- Check for proper `dispose()` of controllers, timers, and streams
- Identify potential memory leaks
- Review StreamSubscription and AnimationController cleanup

## ⚡ Riverpod Optimization
- Find providers that cause excessive rebuilds
- Suggest `.select()` usage for granular watching
- Check for proper provider dependencies

## 📱 Flutter Best Practices
- Verify proper use of `setState`
- Check widget tree depth and suggest extractions
- Review list rendering (ListView.builder, lazy loading)
- Check for proper use of keys in dynamic lists

## 🎨 Theme & Localization
- Ensure use of `context.colors` instead of hardcoded colors
- Verify use of `context.l10n` for all text
- Check BuildContext extensions usage

Please provide:
1. ✅ **Issues Found**: List of performance problems
2. 💡 **Recommendations**: Specific code changes with before/after examples
3. 📊 **Impact**: Estimated performance improvement for each fix
4. 🔧 **Priority**: Critical/High/Medium/Low for each issue

Use the performance-optimizer agent if needed for deep analysis.
