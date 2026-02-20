# Code Quality Rules - FitLog Pro

> Tutte le regole sono enforce automaticamente da pre-commit hooks.
> Per i dettagli completi, vedi [`CLAUDE.md`](./CLAUDE.md).

## Regole Enforced (Hook Automatico)

| Regola | Corretto | Sbagliato |
|--------|----------|-----------|
| Icone | `AppIcons.*` | `Icons.*` |
| Testi | `context.l10n.*` | `'Hardcoded'` |
| Colori | `context.colors.*` | `Colors.blue` |
| Loading | `LoadingIndicator()` | `CircularProgressIndicator()` |
| Snackbar | `SnackBarService.*` | `ScaffoldMessenger.*` |
| Icon Size | `AppIconSize.medium` | `24` |
| State | `createStateProvider<T>(v)` | `StateProvider<T>()` |
| Hive | `HiveBoxManagerEnhanced().openBox()` | `Hive.openBox()` |
| Routes | `AppRoutes.settingsName` | `'/settings'` hardcoded |

## ColorScheme Palette

```dart
import 'build_context_extensions.dart';

// Primari
context.colors.primary / .onPrimary / .primaryContainer / .onPrimaryContainer

// Secondari
context.colors.secondary / .onSecondary / .secondaryContainer / .onSecondaryContainer

// Superficie
context.colors.surface / .onSurface
context.colors.surfaceContainerHighest / High / Container / Low / Lowest

// Semantici
context.colors.error / .onError / .errorContainer
context.colors.success / .warning  // via SemanticColors extension

// Utility
context.colors.outline / .outlineVariant / .shadow / .scrim
```

## Componenti Unificati

```dart
// Loading
LoadingIndicator()
LoadingIndicator(message: context.l10n.loading)

// Snackbar
SnackBarService.showSuccess(context, context.l10n.saved)
SnackBarService.showError(context, context.l10n.error)

// Modal
ModalService.showBottomSheet(context, child: MyWidget())
ModalService.showConfirmDialog(context, title: ..., message: ..., isDangerous: true)
```

## Import

```dart
// SEMPRE assoluti
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

// MAI relativi
// import '../../../shared/...'  // NO
```
