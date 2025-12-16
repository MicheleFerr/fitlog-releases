# ⚡ Exercise Feedback System - Developer Quick Guide

**For Developers**: Quick reference to understand and improve the feedback system.

---

## 🚀 30-Second Overview

The Exercise Feedback System lets users report issues about exercises, and gives admins powerful tools to manage, prioritize, and act on that feedback in real-time.

**Key Tech**:
- Firestore real-time listeners (StreamProviders)
- Riverpod for state management
- Material Design 3 UI
- Full English/Italian localization

---

## 📁 Where's the Code?

| Component | Location | Type | Purpose |
|-----------|----------|------|---------|
| **User Form** | `lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart` | Widget | Users submit feedback |
| **Admin Dashboard** | `lib/features/admin/presentation/screens/exercise_feedback_screen.dart` | ConsumerWidget | View stats & list |
| **Detail Screen** | `lib/features/admin/presentation/screens/feedback_detail_screen.dart` | ConsumerStatefulWidget | Edit & manage |
| **Data Models** | `lib/features/admin/presentation/providers/exercise_feedback_provider.dart` | Riverpod | Providers + models |
| **Translations** | `assets/i18n/app_*.arb` | JSON | EN + IT strings |

---

## 💾 Database Structure

**Collection**: `exercise_feedback`

**Document Schema**:
```json
{
  "userId": "user123",
  "userEmail": "user@example.com",
  "exerciseId": "squat_id",
  "exerciseName": "Squat",
  "version": "1.0.0",
  "feedbackType": "BUG",           // BUG, SUGGESTION, TYPO, OTHER
  "message": "User's feedback text",
  "severity": 3,                   // 1-5 (Low to Urgent)
  "createdAt": Timestamp(...),
  "status": "OPEN",                // OPEN, REVIEWING, RESOLVED, DISMISSED
  "adminNotes": "Admin comments"   // Optional
}
```

---

## 🔄 Data Flow

```
User submits → Firestore add() → Real-time listener fires →
Admin dashboard updates → Admin clicks card → Detail screen opens →
Admin changes status/severity/notes → Firestore update() →
Real-time listener fires → Dashboard refreshes automatically
```

---

## 🎯 Key Providers (Riverpod)

| Provider | Returns | Use For |
|----------|---------|---------|
| `feedbackStatsProvider` | `FeedbackStats` | Dashboard stats cards |
| `criticalFeedbackProvider` | `List<ExerciseFeedback>` | Critical issues section |
| `feedbackByStatusProvider('OPEN')` | `List<ExerciseFeedback>` | Recent feedback list |
| `updateFeedbackStatusProvider` | `Future<void>` | Change status |
| `updateFeedbackNotesProvider` | `Future<void>` | Save admin notes |

---

## 🎨 UI Components

### Dashboard
- **Stats Cards**: Total, Open, Resolved counts
- **Type Distribution**: BUG, SUGGESTION, TYPO, OTHER grouped
- **Severity Distribution**: Low, Medium, High, Critical, Urgent
- **Critical Section**: Top 5 urgent items (Severity ≥ 4)
- **Recent Section**: Latest 10 unreviewed items

### Detail Screen
- **Info Card**: User, date, version, type, severity
- **Message**: Read-only user feedback
- **Severity Selector**: 5 buttons (1-5 levels)
- **Status Actions**: 4 buttons (Start Review, Mark Resolved, Dismiss, Reopen)
- **Admin Notes**: Text editor + save button

---

## 🌍 Localization Pattern

**NO HARDCODED STRINGS!** Every text must use l10n:

```dart
// ❌ Wrong
Text('Save Changes')

// ✅ Right
Text(l10n.feedbackDetailSaveNotes)
```

**Adding New String**:

1. Add to `app_en.arb`:
```json
{
  "myNewKey": "English text",
  "@myNewKey": {
    "description": "Explains what this string is for"
  }
}
```

2. Add to `app_it.arb`:
```json
{
  "myNewKey": "Testo italiano"
}
```

3. Run `flutter gen-l10n`

4. Use in code: `l10n.myNewKey`

---

## 🛠️ Common Tasks

### Add New Action Button

1. Add localization keys:
   - `feedbackActionMyAction` - Button label
   - `feedbackMyActionSuccess` - Success message
   - `feedbackMyActionError` - Error message

2. Add to detail screen:
```dart
_buildActionButton(
  context,
  label: l10n.feedbackActionMyAction,
  icon: Icons.icon_name,
  color: Colors.blue,
  onTap: () => _handleMyAction(),
)
```

3. Implement handler:
```dart
Future<void> _handleMyAction() async {
  setState(() => _isSaving = true);
  try {
    await FirebaseFirestore.instance
        .collection('exercise_feedback')
        .doc(widget.feedback.id)
        .update({'field': value});

    if (mounted) {
      SnackBarService.showSuccess(context, l10n.feedbackMyActionSuccess);
    }
  } catch (e) {
    if (mounted) {
      SnackBarService.showError(context, l10n.feedbackMyActionError);
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
```

### Add New Filter/Sort

1. Modify `feedbackByStatusProvider` or create new provider
2. Update Firestore query with `.where()` or `.orderBy()`
3. Add UI to filter/sort in dashboard
4. Test with sample data

### Add Bulk Actions

1. Create selection state in dashboard
2. Add checkboxes to feedback cards
3. Create "select all" / "select none" buttons
4. Add bulk action buttons (batch update)
5. Create batch update method in provider

---

## ⚠️ Common Pitfalls

### ❌ Don't
- Hardcode any text (strings, numbers, dates)
- Query Firestore without proper indexes
- Forget to dispose controllers
- Update UI without checking `if (mounted)`
- Ignore error handling
- Mix business logic with UI code

### ✅ Do
- Use `l10n` for all text
- Check existing providers first
- Follow Riverpod patterns
- Test with both themes (light/dark)
- Handle errors gracefully
- Keep business logic in providers

---

## 🧪 Testing Checklist

Before submitting PR:

- [ ] All text uses `context.l10n`
- [ ] No console errors in debug mode
- [ ] Works in English and Italian
- [ ] Works in light and dark themes
- [ ] Error messages are clear
- [ ] Loading states show spinner
- [ ] No UI freezes on Firestore operations
- [ ] Real-time updates work (create, update, delete)
- [ ] Permissions enforced (admin-only access)
- [ ] No memory leaks (providers dispose correctly)

---

## 📊 Performance Notes

**Current Metrics**:
- Dashboard load: ~500ms (first time)
- Real-time update: <50ms
- Critical query: ~100-150ms
- Stats aggregation: ~50-100ms

**Optimization Opportunities**:
- Add pagination for large lists
- Cache feedback stats locally
- Batch Firestore queries
- Implement fuzzy search for feedback
- Add offline support for dashboard view

---

## 🐛 Debugging Tips

**Print Debug Info**:
```dart
if (kDebugMode) {
  debugPrint('📊 Dashboard stats: $stats');
}
```

**Check Firestore**:
- Firebase Console → Firestore → exercise_feedback collection
- Look for documents and their fields
- Check indexes exist for queries

**Monitor Real-time**:
- Open Firebase Console
- Watch documents update as you make changes
- Verify listeners fire correctly

---

## 📚 Full Documentation

For detailed architecture and design decisions, see:

**[EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md](./EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md)**

- Complete system design
- Data flow diagrams
- Component architecture
- Security model
- Error handling patterns
- Testing strategy
- Improvement roadmap

---

## 🎯 Next Steps for Improvement

**Quick Wins (1-2 hours)**:
1. Add search/filter for feedback
2. Improve empty state messages
3. Add last-updated timestamp to dashboard
4. Highlight feedback from same user

**Medium Tasks (3-5 hours)**:
1. Add bulk status updates
2. Add date range filtering
3. Create CSV export
4. Add feedback statistics chart

**Strategic Features (1+ day)**:
1. Auto-categorization of feedback
2. Related feedback grouping
3. User notification on status change
4. Integration with issue tracker

---

## 💬 Questions?

- **Architecture details?** → See EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md
- **Hit an error?** → Check ERROR_KB.md
- **Localization help?** → See LOCALIZATION_GUIDE.md
- **How to run tests?** → See QUICK_REFERENCE.md

---

**Happy coding! 🚀**
