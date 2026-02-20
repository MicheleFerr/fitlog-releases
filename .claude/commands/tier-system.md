# Tier System - Dual Architecture

FitLog ha DUE sistemi tier SEPARATI:

## 1. UserTier (XP-based) - ATTIVO

```dart
enum UserTier {
  starter,   // 0 XP
  bronze,    // 100 XP
  silver,    // 500 XP
  gold,      // 1500 XP
  platinum,  // 5000 XP
}
```

**Fonte**: Progressione XP da allenamenti/achievements
**Usato per**: Determinare limiti custom exercises/templates
**Provider**: `userTierProvider` in `user_xp_provider.dart`

## 2. AccountTier (Subscription) - NON IMPLEMENTATO

```dart
enum AccountTier {
  free,     // Default (TUTTI gli utenti)
  premium,  // SOLO per testing (non rilasciato)
}
```

**Status**: Codice preparatorio per monetizzazione futura
**Attualmente**: Tutti gli utenti sono `AccountTier.free`
**Usato per**: Testing limiti nel debug screen admin-only

## Regole Sviluppo

```dart
// CORRETTO - Usa UserTier (XP)
final tier = ref.watch(userTierProvider);
final maxExercises = tier.maxCustomSingleExercises;

// SBAGLIATO - AccountTier non e' attivo in produzione
if (accountTier == AccountTier.premium) { ... }  // Mai true!
```

## Logica Consolidamento

`TierEntitlements` prende il **massimo** tra XP tier e Account tier:

```dart
// UserTier.starter (4 templates) + AccountTier.premium (999) = 999
// UserTier.platinum (30) + AccountTier.free (4) = 30
```

Logica gia pronta per IAP futuro, basta attivare.
