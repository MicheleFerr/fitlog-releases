# 🚀 Beta Launch Checklist - FitLog Pro

**Target**: Espansione da 1 a ~10-20 beta tester
**Status**: 🧪 Pre-Beta
**Last Updated**: 2026-02-10

---

## 📋 INDICE

- [1. Code Quality & Standards](#1-code-quality--standards)
- [2. Performance & Stability](#2-performance--stability)
- [3. User Experience (Personas)](#3-user-experience-personas)
- [4. Data & Backend](#4-data--backend)
- [5. Testing & QA](#5-testing--qa)
- [6. Documentation](#6-documentation)
- [7. Deployment & Distribution](#7-deployment--distribution)
- [8. Monitoring & Feedback](#8-monitoring--feedback)
- [9. Legal & Privacy](#9-legal--privacy)
- [10. Rollback Plan](#10-rollback-plan)

---

## 1. Code Quality & Standards

### 1.1 Regole Critiche (Pre-commit Enforced)
- [ ] Tutte le icone usano `AppIcons.*` (no `Icons.*`)
- [ ] Tutti i testi usano `context.l10n.*` (no hardcoded strings)
- [ ] Tutti i colori usano `context.colors.*` (no `Colors.*`)
- [ ] Loading indicators usano `LoadingIndicator()` (no `CircularProgressIndicator()`)
- [ ] Snackbar usano `SnackBarService.*` (no `ScaffoldMessenger.*`)
- [ ] Icon sizes usano `AppIconSize.*` (no numeri hardcoded)

### 1.2 iOS Build Compliance
- [ ] NESSUN `const` con `context.l10n` (causa build error iOS)
- [ ] `context.l10n` usato SOLO in presentation layer
- [ ] Import corretto: `hide Either, Right, Left` con fpdart
- [ ] Swift native code (`ios/Runner/`) non modificato

### 1.3 Code Analysis
```bash
# Esegui prima del lancio:
flutter analyze
flutter test
.claude/scripts/performance-check.sh lib/
```

- [ ] Zero errori da `flutter analyze`
- [ ] Zero warning critici
- [ ] Performance check passa senza alert gravi

---

## 2. Performance & Stability

### 2.1 Anti-Pattern Check
- [ ] NO risorse (Hive box, Firebase) aperte in loop
- [ ] Batch operations (`putAll`) invece di loop con `put()`
- [ ] Manager/Limiter come singleton statici
- [ ] `Future.wait()` per operazioni async parallele
- [ ] Debounce su event handlers rapidi (min 100ms)
- [ ] `ref.keepAlive()` su provider con risorse costose

### 2.2 Memory & Resources
- [ ] Tutti i timer hanno `ref.onDispose()` con cancellazione
- [ ] Stream subscription dispose correttamente
- [ ] Nessun memory leak nei workout timer
- [ ] Live Activities cleanup su iOS
- [ ] Background task manager cleanup

### 2.3 App Performance
- [ ] Cold start < 3s su iPhone 12/Pixel 5
- [ ] Hot reload funziona senza crash
- [ ] Scroll lists 60fps con 500+ items
- [ ] Image loading con cache efficiente
- [ ] Nessun rebuild inutile nei provider

---

## 3. User Experience (Personas)

### 3.1 Marco (Principiante Intimidito)
- [ ] Onboarding chiaro e guidato
- [ ] Default settings sensati (no configurazione obbligatoria)
- [ ] Errori con messaggi comprensibili (no tecnicismi)
- [ ] Tutorial in-app per funzioni principali
- [ ] Help contestuale dove necessario

### 3.2 Chiara (Mamma Multitasking)
- [ ] Quick actions accessibili (max 2 tap per azioni comuni)
- [ ] Timer workout funziona in background
- [ ] Notifiche non invasive
- [ ] Sync automatico (no azioni manuali)
- [ ] Ripresa workout dopo interruzione

### 3.3 Luca (Powerlifter Serio)
- [ ] Dati dettagliati disponibili (volume, intensità, progressive overload)
- [ ] Export dati completo
- [ ] Grafici progressi accurati
- [ ] Custom exercises funzionanti
- [ ] Note per set/esercizi/workout

### 3.4 Sofia (Estetica-Driven)
- [ ] Grafici progressi visivamente accattivanti
- [ ] Achievements e XP system funzionanti
- [ ] UI coerente con design system
- [ ] Animazioni smooth (no jank)
- [ ] Dark mode consistente

### 3.5 Roberto (Professionista Busy)
- [ ] Template workout quick select
- [ ] Bulk edit operations
- [ ] Keyboard shortcuts dove possibile
- [ ] Offline mode funzionale
- [ ] Sync veloce (<2s)

### 3.6 Cross-Persona
- [ ] Nessuna feature con impact "--" su persona primaria
- [ ] Max 1 feature con impact "-" su 2+ personas
- [ ] Tutte le mitigazioni implementate per impatti negativi

---

## 4. Data & Backend

### 4.1 Firebase Setup
- [ ] Firestore rules in produzione testate
- [ ] Storage rules configurate correttamente
- [ ] Backup automatici attivi
- [ ] Rate limiting configurato
- [ ] Security audit completato

### 4.2 Data Integrity
- [ ] Migration script testati (se presenti)
- [ ] Rollback procedure definite
- [ ] Data validation su tutti gli input
- [ ] Conflitti sync risolti correttamente
- [ ] Orphaned data cleanup automatico

### 4.3 Cloud Functions
- [ ] Exercise popularity aggregation testata
- [ ] Scheduled functions (daily/weekly) validate
- [ ] Error handling e retry logic
- [ ] Monitoring e alerting attivi
- [ ] Timeout appropriati (max 60s)

### 4.4 Local Storage (Hive)
- [ ] Box migration strategy definita
- [ ] Corruption handling testato
- [ ] Lazy loading per box grandi
- [ ] Cleanup vecchi dati automatico
- [ ] Backup locale prima di migration

---

## 5. Testing & QA

### 5.1 Automated Tests
```bash
# Test suite completo:
flutter test
flutter test --coverage
```

- [ ] Unit tests: core business logic
- [ ] Widget tests: UI components critici
- [ ] Integration tests: user flows principali
- [ ] Golden tests: regression UI
- [ ] Coverage > 60% su domain/data layer

### 5.2 Manual Testing - Critical Flows
- [ ] **Onboarding**: Signup → Profile setup → First workout
- [ ] **Workout Creation**: Template → Custom exercises → Start
- [ ] **Timer Flow**: Start → Pause → Resume → Complete
- [ ] **Sync**: Offline changes → Online → Conflict resolution
- [ ] **Live Activities (iOS)**: Start workout → Lock screen → Updates
- [ ] **XP System**: Workout completion → XP grant → Tier progression
- [ ] **Template Sync**: Create → Edit → Cloud sync → Multi-device

### 5.3 Device Testing
- [ ] **iOS**: iPhone 12 Pro, iOS 16.0+
- [ ] **iOS**: iPhone SE 2020 (small screen)
- [ ] **Android**: Pixel 5, Android 12+
- [ ] **Android**: Samsung Galaxy A52 (mid-range)
- [ ] Dark mode su tutti i device
- [ ] Landscape orientation dove applicabile

### 5.4 Edge Cases
- [ ] App kill durante workout attivo
- [ ] Network loss durante sync
- [ ] Low battery mode (iOS/Android)
- [ ] Background app refresh disabled
- [ ] Storage full scenarios
- [ ] Clock/timezone changes

---

## 6. Documentation

### 6.1 User-Facing
- [ ] Privacy Policy aggiornata
- [ ] Terms of Service chiari
- [ ] FAQ per problemi comuni
- [ ] Feedback form accessibile
- [ ] Contact support visibile

### 6.2 Developer Documentation
- [ ] [`docs/INDEX.md`](INDEX.md) aggiornato
- [ ] [`CLAUDE.md`](../CLAUDE.md) riflette stato attuale
- [ ] ADR per decisioni architetturali recenti
- [ ] Known issues documentati
- [ ] Setup instructions per nuovi dev

### 6.3 Beta Tester Resources
- [ ] Beta testing guide (come segnalare bug)
- [ ] Roadmap condivisa (cosa aspettarsi)
- [ ] Changelog per ogni release
- [ ] TestFlight/Play Store beta notes
- [ ] Feedback survey preparato

---

## 7. Deployment & Distribution

### 7.1 Build Configuration
- [ ] Version number incrementato (`pubspec.yaml`)
- [ ] Build number incrementato
- [ ] Flavor corretto: `beta` o `production`
- [ ] Debug flags disabilitati
- [ ] Logging levels appropriati (no verbose in prod)

### 7.2 iOS (TestFlight)
- [ ] Provisioning profiles aggiornati
- [ ] Capabilities configurate (Background modes, Push notifications)
- [ ] App Store Connect: Beta info compilate
- [ ] Screenshots aggiornati (almeno 1 per device size)
- [ ] Beta tester groups creati
- [ ] Compliance info complete

### 7.3 Android (Play Console - Beta Track)
- [ ] App Bundle (AAB) generato correttamente
- [ ] ProGuard/R8 rules testate
- [ ] Signing key backup sicuro
- [ ] Beta track configurato
- [ ] Tester list preparata (email/gruppi)
- [ ] Store listing draft completo

### 7.4 CI/CD
- [ ] GitHub Actions/Codemagic configurato per beta
- [ ] Automated build su push a `beta` branch
- [ ] Test automatici passano
- [ ] Notifiche deploy attive
- [ ] Rollback automatico su failure

---

## 8. Monitoring & Feedback

### 8.1 Error Tracking
- [ ] Firebase Crashlytics configurato
- [ ] Sentry (opzionale) setup
- [ ] Custom error reporting per critical flows
- [ ] Email alerts per crash rate > 1%
- [ ] Dashboard monitoring setup

### 8.2 Analytics
- [ ] Firebase Analytics eventi chiave:
  - [ ] `workout_started`
  - [ ] `workout_completed`
  - [ ] `template_created`
  - [ ] `achievement_unlocked`
  - [ ] `user_tier_progression`
- [ ] User properties configurate (tier, days_active)
- [ ] Conversion funnels definiti
- [ ] Retention cohorts setup

### 8.3 Feedback Channels
- [ ] In-app feedback form
- [ ] Email support attivo (response time < 24h)
- [ ] Discord/Slack community (opzionale)
- [ ] GitHub issues per bug tecnici
- [ ] Survey post-workout (opzionale, non invasivo)

### 8.4 Performance Monitoring
- [ ] Firebase Performance Monitoring attivo
- [ ] Custom traces per:
  - [ ] App startup time
  - [ ] Workout load time
  - [ ] Sync duration
  - [ ] Template fetch time
- [ ] Network request monitoring
- [ ] Screen rendering performance

---

## 9. Legal & Privacy

### 9.1 GDPR Compliance
- [ ] Privacy Policy include:
  - [ ] Dati raccolti (workout, XP, Firebase Analytics)
  - [ ] Finalità utilizzo dati
  - [ ] Diritti utente (accesso, cancellazione, portabilità)
  - [ ] Cookie policy (se web app)
  - [ ] Contatto DPO/Support
- [ ] Consent management implementato
- [ ] Data deletion flow testato
- [ ] Data export funzionante

### 9.2 Terms of Service
- [ ] Beta testing disclaimer
- [ ] Limitation of liability
- [ ] Data loss disclaimer (backup responsabilità utente)
- [ ] Feature changes senza preavviso (beta)
- [ ] Termination policy

### 9.3 App Store Compliance
- [ ] iOS: App Store Review Guidelines 2.5 (Performance)
- [ ] iOS: Guideline 5.1 (Privacy, data collection disclosure)
- [ ] Android: Google Play Developer Policy
- [ ] Age rating corretto (4+ / Everyone)
- [ ] Content rating questionnaire completato

---

## 10. Rollback Plan

### 10.1 Emergency Rollback
- [ ] Versione stabile precedente archiviata
- [ ] Procedura rollback documentata (< 15 min)
- [ ] Firebase rules rollback procedure
- [ ] Cloud functions rollback testato
- [ ] Communication plan per utenti

### 10.2 Data Recovery
- [ ] Backup Firestore automatici (retention 7 giorni)
- [ ] Script recovery testati
- [ ] Local backup user export funzionante
- [ ] Migration rollback SQL/scripts

### 10.3 Incident Response
- [ ] On-call contact definito
- [ ] Severity levels definiti (P0-P3)
- [ ] Response time SLA (P0 < 1h, P1 < 4h)
- [ ] Post-mortem template preparato
- [ ] Communication templates (email/in-app)

---

## ✅ SIGN-OFF

**Pre-Launch Review:**

| Area | Owner | Status | Sign-off | Date |
|------|-------|--------|----------|------|
| Code Quality | Michele | ⬜ | | |
| Performance | Michele | ⬜ | | |
| UX (Personas) | Michele | ⬜ | | |
| Backend | Michele | ⬜ | | |
| Testing | Michele | ⬜ | | |
| Documentation | Michele | ⬜ | | |
| Deployment | Michele | ⬜ | | |
| Monitoring | Michele | ⬜ | | |
| Legal | Michele | ⬜ | | |
| Rollback Plan | Michele | ⬜ | | |

**Final GO/NO-GO Decision:**
- [ ] Tutti i "MUST HAVE" completati (❌ blocca lancio)
- [ ] Max 2 "NICE TO HAVE" pendenti (⚠️ non blocca)
- [ ] Zero P0 bugs aperti
- [ ] Max 3 P1 bugs aperti (con workaround)

**Launch Date Target**: _________________

**Approved By**: _________________

**Date**: _________________

---

## 📝 NOTES & DEVIATIONS

_Documentare qui eventuali eccezioni, rischi accettati, o deviazioni dalla checklist:_

---

## 🔗 RELATED DOCS

- [INDEX.md](INDEX.md) - Documentazione principale
- [DEVELOPMENT_RULES.md](DEVELOPMENT_RULES.md) - Regole sviluppo
- [USER_PERSONAS.md](USER_PERSONAS.md) - Personas dettagliate
- [TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md](TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md) - Sync templates
- [AI_COACH_DOCUMENTS_IMPLEMENTATION.md](AI_COACH_DOCUMENTS_IMPLEMENTATION.md) - AI Coach (se beta include)
