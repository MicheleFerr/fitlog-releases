# 🚀 Localization Quick Fix Guide

**For GymBro Developers**: How to fix localization violations in 5 minutes

---

## 📋 STEP-BY-STEP FIX PROCESS

### Step 1: Check if Your File Has Violations

```bash
cd /Users/michele/gymbro_flutter_new
./scan_localization_violations.sh | grep "your_file_name.dart"
```

### Step 2: Add Required Import

Add this import at the top of your file (with other imports):

```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

### Step 3: Identify Hardcoded Strings

Look for these patterns in your file:

```dart
// ❌ WRONG - Hardcoded strings
Text('Delete')
Text('Loading...')
AppBar(title: Text('Settings'))
SnackBar(content: Text('Saved successfully'))
InputDecoration(hintText: 'Enter name')
throw Exception('Invalid data')
```

### Step 4: Add Keys to ARB Files

For each hardcoded string, add entries to BOTH files:

**File 1**: `assets/i18n/app_en.arb`
```json
{
  "delete": "Delete",
  "@delete": {
    "description": "Delete button label"
  },
  "loading": "Loading...",
  "@loading": {
    "description": "Loading indicator text"
  }
}
```

**File 2**: `assets/i18n/app_it.arb`
```json
{
  "delete": "Elimina",
  "loading": "Caricamento..."
}
```

### Step 5: Generate Localization Files

```bash
flutter gen-l10n
```

### Step 6: Replace Hardcoded Strings

```dart
// ✅ CORRECT - Using localization
Text(context.l10n.delete)
Text(context.l10n.loading)
AppBar(title: Text(context.l10n.settings))
SnackBar(content: Text(context.l10n.savedSuccessfully))
InputDecoration(hintText: context.l10n.enterName)
```

### Step 7: Test Both Languages

1. Run the app
2. Go to Settings > Language
3. Switch between English and Italian
4. Verify your changes appear in both languages

---

## 🎯 COMMON PATTERNS & FIXES

### Pattern 1: Simple Text Widget

**Before**:
```dart
Text('Delete')
```

**After**:
```dart
Text(context.l10n.delete)
```

**ARB Keys**:
```json
// app_en.arb
{
  "delete": "Delete",
  "@delete": {
    "description": "Delete button label"
  }
}

// app_it.arb
{
  "delete": "Elimina"
}
```

---

### Pattern 2: Text with Variables

**Before**:
```dart
Text('Level $level')
```

**After**:
```dart
Text(context.l10n.levelN(level))
```

**ARB Keys**:
```json
// app_en.arb
{
  "levelN": "Level {level}",
  "@levelN": {
    "description": "Shows user level",
    "placeholders": {
      "level": {
        "type": "int",
        "example": "5"
      }
    }
  }
}

// app_it.arb
{
  "levelN": "Livello {level}"
}
```

---

### Pattern 3: Dialog Content

**Before**:
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Confirm Delete'),
    content: Text('Are you sure you want to delete this?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => _delete(),
        child: Text('Delete'),
      ),
    ],
  ),
)
```

**After**:
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text(context.l10n.confirmDelete),
    content: Text(context.l10n.confirmDeleteMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      TextButton(
        onPressed: () => _delete(),
        child: Text(context.l10n.delete),
      ),
    ],
  ),
)
```

**ARB Keys**:
```json
// app_en.arb
{
  "confirmDelete": "Confirm Delete",
  "@confirmDelete": {
    "description": "Dialog title for delete confirmation"
  },
  "confirmDeleteMessage": "Are you sure you want to delete this?",
  "@confirmDeleteMessage": {
    "description": "Dialog message for delete confirmation"
  },
  "cancel": "Cancel",
  "@cancel": {
    "description": "Cancel button label"
  },
  "delete": "Delete",
  "@delete": {
    "description": "Delete button label"
  }
}

// app_it.arb
{
  "confirmDelete": "Conferma Eliminazione",
  "confirmDeleteMessage": "Sei sicuro di voler eliminare questo?",
  "cancel": "Annulla",
  "delete": "Elimina"
}
```

---

### Pattern 4: SnackBar Messages

**Before**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Saved successfully')),
)
```

**After (Option 1 - Using SnackBarService)**:
```dart
SnackBarService.showSuccess(context, context.l10n.savedSuccessfully)
```

**After (Option 2 - Manual)**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(context.l10n.savedSuccessfully)),
)
```

**ARB Keys**:
```json
// app_en.arb
{
  "savedSuccessfully": "Saved successfully",
  "@savedSuccessfully": {
    "description": "Success message after saving"
  }
}

// app_it.arb
{
  "savedSuccessfully": "Salvato con successo"
}
```

---

### Pattern 5: Form Fields

**Before**:
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Exercise Name',
    hintText: 'Enter exercise name',
    errorText: errorMessage ? 'Name is required' : null,
  ),
)
```

**After**:
```dart
TextField(
  decoration: InputDecoration(
    labelText: context.l10n.exerciseName,
    hintText: context.l10n.enterExerciseName,
    errorText: errorMessage ? context.l10n.nameRequired : null,
  ),
)
```

**ARB Keys**:
```json
// app_en.arb
{
  "exerciseName": "Exercise Name",
  "@exerciseName": {
    "description": "Label for exercise name field"
  },
  "enterExerciseName": "Enter exercise name",
  "@enterExerciseName": {
    "description": "Hint text for exercise name field"
  },
  "nameRequired": "Name is required",
  "@nameRequired": {
    "description": "Error message when name field is empty"
  }
}

// app_it.arb
{
  "exerciseName": "Nome Esercizio",
  "enterExerciseName": "Inserisci nome esercizio",
  "nameRequired": "Il nome è obbligatorio"
}
```

---

### Pattern 6: AppBar Title

**Before**:
```dart
AppBar(
  title: Text('Settings'),
)
```

**After**:
```dart
AppBar(
  title: Text(context.l10n.settings),
)
```

**ARB Keys**:
```json
// app_en.arb
{
  "settings": "Settings",
  "@settings": {
    "description": "Settings screen title"
  }
}

// app_it.arb
{
  "settings": "Impostazioni"
}
```

---

### Pattern 7: Button Labels

**Before**:
```dart
ElevatedButton(
  onPressed: _save,
  child: Text('Save Changes'),
)
```

**After**:
```dart
ElevatedButton(
  onPressed: _save,
  child: Text(context.l10n.saveChanges),
)
```

**ARB Keys**:
```json
// app_en.arb
{
  "saveChanges": "Save Changes",
  "@saveChanges": {
    "description": "Button to save changes"
  }
}

// app_it.arb
{
  "saveChanges": "Salva Modifiche"
}
```

---

## 🔧 SPECIFIC FILE FIXES

### Exercise List Item (50 violations)

**File**: `lib/features/workout/presentation/widgets/exercise_list_item.dart`

**Line 936**: `Text('Delete', style: TextStyle(color: Colors.red))`
```dart
// Fix
Text(context.l10n.delete, style: TextStyle(color: Colors.red))
```

**Line 950**: `Text('Edit')`
```dart
// Fix
Text(context.l10n.edit)
```

**Line 960**: `Text('Duplicate')`
```dart
// Fix
Text(context.l10n.duplicate)
```

**Line 974**: `Text('Insight')`
```dart
// Fix
Text(context.l10n.insight)
```

**Required ARB Keys**:
```json
// app_en.arb
{
  "delete": "Delete",
  "edit": "Edit",
  "duplicate": "Duplicate",
  "insight": "Insight"
}

// app_it.arb
{
  "delete": "Elimina",
  "edit": "Modifica",
  "duplicate": "Duplica",
  "insight": "Analisi"
}
```

---

### Settings Screen (33 violations)

**File**: `lib/features/settings/presentation/settings_screen.dart`

**Line 259**: `Text("Not logged in")`
```dart
// Fix
Text(context.l10n.notLoggedIn)
```

**Line 260**: `Text("Loading...")`
```dart
// Fix
Text(context.l10n.loading)
```

**Line 1058**: Dialog with `title: Text('Choose Language')`
```dart
// Fix
title: Text(context.l10n.chooseLanguage)
```

**Required ARB Keys**:
```json
// app_en.arb
{
  "notLoggedIn": "Not logged in",
  "loading": "Loading...",
  "chooseLanguage": "Choose Language",
  "englishUS": "English (US)",
  "italiano": "Italiano",
  "weightUnits": "Weight Units",
  "kilogramsKg": "Kilograms (kg)",
  "poundsLbs": "Pounds (lbs)",
  "metricSystem": "Metric system",
  "imperialSystem": "Imperial system"
}

// app_it.arb
{
  "notLoggedIn": "Non autenticato",
  "loading": "Caricamento...",
  "chooseLanguage": "Scegli Lingua",
  "englishUS": "English (US)",
  "italiano": "Italiano",
  "weightUnits": "Unità di Peso",
  "kilogramsKg": "Chilogrammi (kg)",
  "poundsLbs": "Libbre (lbs)",
  "metricSystem": "Sistema metrico",
  "imperialSystem": "Sistema imperiale"
}
```

---

## ⚠️ SPECIAL CASES

### Case 1: Emoji or Symbols

**Before**:
```dart
Text('⚠️')
Text('• ')
```

**After**: Keep as-is (emojis/symbols don't need translation)
```dart
Text('⚠️')  // OK - emoji
Text('• ')   // OK - bullet point
```

---

### Case 2: Language Names

**Before**:
```dart
Text('English (US)')
Text('Italiano')
```

**After**: Keep in native form (acceptable exception)
```dart
// Always show language name in its native form
Text('English')   // Always 'English'
Text('Italiano')  // Always 'Italiano'
```

---

### Case 3: Variables Only

**Before**:
```dart
Text('$value')  // Just a variable
Text(exerciseName)  // Just a variable
```

**After**: No change needed (already localized if variable is localized)

---

### Case 4: Exception Messages (Low Priority)

**Before**:
```dart
throw Exception('Invalid configuration')
```

**After (Option 1 - Error code)**:
```dart
throw Exception('ERR_INVALID_CONFIG')  // Return error code
```

**After (Option 2 - Localized)**:
```dart
throw Exception(context.l10n.invalidConfiguration)
```

**Recommended**: Use error codes for exceptions, translate in UI

---

## 🎯 KEY NAMING CONVENTIONS

Follow these conventions when creating ARB keys:

### Screen Titles
```
Pattern: screenNameTitle
Example: settingsTitle, workoutTitle, analyticsTitle
```

### Actions
```
Pattern: verbNoun
Example: saveChanges, deleteExercise, editSet
```

### Validation Messages
```
Pattern: fieldNameValidation
Example: emailRequired, passwordTooShort, nameInvalid
```

### Confirmation Messages
```
Pattern: confirmAction
Example: confirmDelete, confirmSignOut, confirmReset
```

### Success Messages
```
Pattern: actionSuccessful
Example: savedSuccessfully, deletedSuccessfully, updatedSuccessfully
```

### Error Messages
```
Pattern: errorActioningNoun
Example: errorLoadingUser, errorSavingWorkout, errorDeletingExercise
```

---

## ✅ CHECKLIST BEFORE COMMITTING

- [ ] All hardcoded strings replaced with `context.l10n.*`
- [ ] Required import added: `build_context_extensions.dart`
- [ ] All keys added to `app_en.arb` with descriptions
- [ ] All keys added to `app_it.arb` with translations
- [ ] Ran `flutter gen-l10n` successfully
- [ ] Tested in English - works correctly
- [ ] Tested in Italian - works correctly
- [ ] No new warnings from `flutter analyze`
- [ ] File appears correct in scanner: `./scan_localization_violations.sh`

---

## 🆘 TROUBLESHOOTING

### Problem: "context.l10n.myKey doesn't exist"

**Solution**:
1. Check if you added the key to both ARB files
2. Run `flutter gen-l10n`
3. Restart your IDE/analyzer
4. Check for typos in key name

### Problem: "The getter 'l10n' isn't defined for the type 'BuildContext'"

**Solution**: Add the import:
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

### Problem: Text shows "myKey" instead of translation

**Solution**:
1. Check if key exists in ARB file
2. Make sure you ran `flutter gen-l10n`
3. Hot restart (not just hot reload)

### Problem: Italian translation not showing

**Solution**:
1. Verify key exists in `app_it.arb`
2. Check language setting in app (Settings > Language)
3. Verify translation doesn't have typos/formatting errors

---

## 📊 BEFORE & AFTER EXAMPLE

### Complete Widget Example

**BEFORE (Hardcoded)**:
```dart
class MySettingsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text('Settings'),
        ElevatedButton(
          onPressed: _save,
          child: Text('Save Changes'),
        ),
        TextButton(
          onPressed: _reset,
          child: Text('Reset to Defaults'),
        ),
      ],
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved')),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Reset'),
        content: Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _doReset,
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}
```

**AFTER (Localized)**:
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class MySettingsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(context.l10n.settings),
        ElevatedButton(
          onPressed: _save,
          child: Text(context.l10n.saveChanges),
        ),
        TextButton(
          onPressed: _reset,
          child: Text(context.l10n.resetToDefaults),
        ),
      ],
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsSaved)),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.confirmReset),
        content: Text(context.l10n.confirmResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: _doReset,
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }
}
```

**Required ARB Keys**:
```json
// app_en.arb
{
  "settings": "Settings",
  "saveChanges": "Save Changes",
  "resetToDefaults": "Reset to Defaults",
  "settingsSaved": "Settings saved",
  "confirmReset": "Confirm Reset",
  "confirmResetMessage": "Are you sure?",
  "cancel": "Cancel",
  "reset": "Reset"
}

// app_it.arb
{
  "settings": "Impostazioni",
  "saveChanges": "Salva Modifiche",
  "resetToDefaults": "Ripristina Predefiniti",
  "settingsSaved": "Impostazioni salvate",
  "confirmReset": "Conferma Ripristino",
  "confirmResetMessage": "Sei sicuro?",
  "cancel": "Annulla",
  "reset": "Ripristina"
}
```

---

## 🚀 AUTOMATION TOOLS

### Quick Command: Fix All Instances of a String

```bash
# Example: Replace all 'Loading...' with context.l10n.loading
find lib -name "*.dart" -type f -exec sed -i '' "s/Text('Loading\\.\\.\\.'/Text(context.l10n.loading)/g" {} \;
```

**⚠️ WARNING**: Always review changes after automated replacement!

---

## 📚 ADDITIONAL RESOURCES

- **Full Report**: `LOCALIZATION_VIOLATIONS_COMPREHENSIVE_REPORT.md`
- **Project Guidelines**: `CLAUDE.md` (Section: REGOLA #1: MULTILINGUA OBBLIGATORIO)
- **Localization Guide**: `docs/LOCALIZATION_GUIDE.md`
- **Extensions File**: `lib/shared/presentation/extensions/build_context_extensions.dart`
- **Scanner Script**: `scan_localization_violations.sh`

---

**Remember**: Every hardcoded string is a bad user experience for Italian users. Fix them all!

**Questions?** Check CLAUDE.md or ask in team chat.
