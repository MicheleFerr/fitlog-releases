# Local Notification System - Piano Implementazione

**Generated**: 2025-01-26
**Source**: Claude Code (ricerca validata)
**Complexity Score**: MEDIUM
**Total Tasks**: 12
**Estimated Time**: ~6h
**Plan Version**: 1.0

---

## Original Request

> Implementare sistema notifiche locali per retention con 3 casi d'uso:
> 1. Workout dimenticato (timer attivo, app in background)
> 2. Inattività 3+ giorni
> 3. Nuovi insight (PR, streak, volume)

---

## Design Validato (Post-Ricerca)

### Parametri Globali Anti-Spam

| Parametro | Valore | Fonte |
|-----------|--------|-------|
| Cool-down tra notifiche | 24h | Best practice |
| Max notifiche/settimana | 3 | [MobileLoud](https://www.mobiloud.com/blog/push-notification-statistics) |
| Quiet hours | 22:00-08:00 | Best practice |
| Stop-after-ignore | 3 consecutive | [Duolingo](https://blog.duolingo.com/hi-its-duo-the-ai-behind-the-meme/) |
| iOS max scheduled | 10 (refresh on open) | [GitHub Issue #200](https://github.com/MaikuB/flutter_local_notifications/issues/200) |
| Message rotation | Pool 3-5 per tipo | [Duolingo AI](https://www.ngrow.ai/blog/decoding-duolingo-analyzing-the-effectiveness-of-their-push-notification-strategy) |

### Notifica 1: Workout Dimenticato

| Campo | Valore |
|-------|--------|
| Trigger | Timer attivo + App background ≥25min + No set in 25min |
| Delay | Immediato (schedulato a +25min quando app va in background) |
| Max | 1/sessione workout |
| Deep link | `/workout/active` |
| Stop | Non ripetere se ignorata nella stessa sessione |

**Messaggi (rotation pool)**:
1. "Workout in corso! Torna per salvarlo."
2. "Hai un allenamento attivo. Completa o salva!"
3. "Il tuo workout ti aspetta. Non perderlo!"

### Notifica 2: Inattività (Sequenza Progressiva)

| Giorno | Azione | Messaggio |
|--------|--------|-----------|
| 3 | Prima notifica | "3 giorni senza allenarti. Pronto per tornare?" |
| 7 | Se ignorata | "Una settimana di pausa. Il tuo corpo è pronto!" |
| 14 | Se ignorata | "Due settimane... Un workout veloce oggi?" |
| 14+ | STOP | Non inviare più (utente ha scelto) |

| Campo | Valore |
|-------|--------|
| Trigger | Ultimo workout completato ≥N giorni |
| Scheduling | 09:00 del giorno target |
| Deep link | `/home` |
| Reset | Qualsiasi workout completato resetta sequenza |

### Notifica 3: Insight (Differenziato per Valore)

**PR (Alto Valore)**:
| Campo | Valore |
|-------|--------|
| Trigger | Nuovo PR rilevato da InsightsEngine |
| Delay | 15-30 min dopo completamento workout |
| Max | 1/giorno |
| Deep link | `/analytics` |

**Messaggi PR**:
1. "Nuovo record su {exercise}! Vedi i dettagli."
2. "PR battuto: {exercise}! Continua così."
3. "Record personale raggiunto! Scopri di più."

**Streak/Volume (Basso Valore)**:
| Campo | Valore |
|-------|--------|
| Trigger | Streak milestone (7,14,30) o Volume +20% |
| Delay | Next morning 09:00 (batch) |
| Max | 1/giorno (insieme a PR se presente, PR ha priorità) |
| Deep link | `/analytics` |

**Messaggi Streak**:
1. "{N} giorni consecutivi! Ottimo lavoro."
2. "Streak di {N} giorni! Continua così."

**Messaggi Volume**:
1. "Volume +{X}% questa settimana!"
2. "Settimana super: volume aumentato del {X}%!"

---

## Architettura

```
lib/features/notifications/
├── domain/
│   ├── entities/
│   │   ├── notification_type.dart          # Enum: workout_forgotten, inactivity, insight_pr, insight_streak
│   │   ├── notification_record.dart        # Record di notifica inviata (per tracking)
│   │   └── notification_config.dart        # Configurazione anti-spam
│   ├── repositories/
│   │   └── notification_repository.dart    # Interface
│   └── services/
│       ├── notification_scheduler.dart     # Logica scheduling + anti-spam
│       └── notification_message_pool.dart  # Message rotation
├── data/
│   ├── repositories/
│   │   └── notification_repository_impl.dart
│   └── datasources/
│       ├── local_notification_datasource.dart  # flutter_local_notifications wrapper
│       └── notification_storage_datasource.dart # Hive per tracking
└── presentation/
    └── providers/
        └── notification_provider.dart      # Riverpod integration
```

**Integrazione con esistente**:
- `AppLifecycleManager` → trigger workout_forgotten
- `InsightsEngine` → trigger insight notifications
- `WorkoutRepository` → trigger inactivity check

---

## Task Breakdown

### Fase 1: Foundation (Domain Layer)

- [ ] **Task 1.1**: Creare `NotificationType` enum
  - **Layer**: Domain
  - **File**: `lib/features/notifications/domain/entities/notification_type.dart`
  - **Est. Time**: 15 min
  - **Verification**: Enum compila, include tutti i tipi

- [ ] **Task 1.2**: Creare `NotificationRecord` entity
  - **Layer**: Domain
  - **File**: `lib/features/notifications/domain/entities/notification_record.dart`
  - **Est. Time**: 20 min
  - **Dependencies**: Task 1.1
  - **Verification**: Entity con freezed, include timestamp, type, wasOpened

- [ ] **Task 1.3**: Creare `NotificationConfig` con costanti anti-spam
  - **Layer**: Domain
  - **File**: `lib/features/notifications/domain/entities/notification_config.dart`
  - **Est. Time**: 15 min
  - **Verification**: Costanti per cooldown, max/week, quiet hours

- [ ] **Task 1.4**: Creare `NotificationMessagePool` service
  - **Layer**: Domain
  - **File**: `lib/features/notifications/domain/services/notification_message_pool.dart`
  - **Est. Time**: 30 min
  - **Verification**: Pool messaggi per tipo, rotation logic

### Fase 2: Data Layer

- [ ] **Task 2.1**: Creare `NotificationStorageDatasource` (Hive)
  - **Layer**: Data
  - **File**: `lib/features/notifications/data/datasources/notification_storage_datasource.dart`
  - **Est. Time**: 30 min
  - **Dependencies**: Task 1.2
  - **Verification**: Save/load NotificationRecord, query by type/date

- [ ] **Task 2.2**: Creare `LocalNotificationDatasource` wrapper
  - **Layer**: Data
  - **File**: `lib/features/notifications/data/datasources/local_notification_datasource.dart`
  - **Est. Time**: 45 min
  - **Verification**: schedule(), cancel(), pendingNotifications()

- [ ] **Task 2.3**: Creare `NotificationRepositoryImpl`
  - **Layer**: Data
  - **File**: `lib/features/notifications/data/repositories/notification_repository_impl.dart`
  - **Est. Time**: 30 min
  - **Dependencies**: Task 2.1, 2.2
  - **Verification**: Implementa interface, coordina datasources

### Fase 3: Scheduling Logic

- [ ] **Task 3.1**: Creare `NotificationScheduler` con anti-spam
  - **Layer**: Domain
  - **File**: `lib/features/notifications/domain/services/notification_scheduler.dart`
  - **Est. Time**: 1h
  - **Dependencies**: Task 2.3, 1.3, 1.4
  - **Verification**:
    - canSendNotification() rispetta cooldown/max/quiet hours
    - scheduleWorkoutForgotten() schedula a +25min
    - scheduleInactivity() schedula sequenza 3/7/14
    - scheduleInsight() con delay appropriato per tipo

### Fase 4: Integration

- [ ] **Task 4.1**: Creare `NotificationProvider` Riverpod
  - **Layer**: Presentation
  - **File**: `lib/features/notifications/presentation/providers/notification_provider.dart`
  - **Est. Time**: 30 min
  - **Dependencies**: Task 3.1
  - **Verification**: Provider espone metodi per trigger notifiche

- [ ] **Task 4.2**: Integrare con `AppLifecycleManager`
  - **Layer**: Integration
  - **File**: Modifica `lib/shared/presentation/widgets/app_lifecycle_manager.dart`
  - **Est. Time**: 30 min
  - **Dependencies**: Task 4.1
  - **Verification**: App background → schedula workout_forgotten se timer attivo

- [ ] **Task 4.3**: Integrare con completamento workout
  - **Layer**: Integration
  - **File**: Modifica workout completion flow
  - **Est. Time**: 30 min
  - **Dependencies**: Task 4.1
  - **Verification**:
    - Workout completato → check inactivity reset
    - Workout completato → check insight notifications (PR)

### Fase 5: Localization & Testing

- [ ] **Task 5.1**: Aggiungere traduzioni EN/IT
  - **Layer**: Localization
  - **Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
  - **Est. Time**: 20 min
  - **Verification**: Tutti i messaggi localizzati, `flutter gen-l10n` passa

- [ ] **Task 5.2**: Test manuale flussi
  - **Layer**: Testing
  - **Est. Time**: 30 min
  - **Verification**:
    - [ ] Workout forgotten: timer attivo → background → notifica dopo 25min
    - [ ] Inactivity: non aprire app 3 giorni → notifica
    - [ ] Insight PR: completare workout con PR → notifica
    - [ ] Anti-spam: verificare cooldown e max/week

---

## Implementation Order

**MUST DO FIRST** (blocking):
→ Task 1.1, 1.2, 1.3 (entities) - ~50 min

**THEN** (sequential):
→ Task 1.4, 2.1, 2.2, 2.3 (data layer) - ~2h 15min

**THEN**:
→ Task 3.1 (scheduler core) - ~1h

**FINALLY**:
→ Task 4.1, 4.2, 4.3, 5.1, 5.2 (integration) - ~2h 20min

**Total Critical Path**: ~6h

---

## Notes & Decisions

*Spazio per annotazioni durante implementazione*

---

## Version History

### v1.0 - 2025-01-26

**Initial plan** basato su ricerca validata

**Key design decisions**:
- 25 min trigger per workout forgotten (non 10 min - troppo aggressivo)
- Sequenza 3/7/14 per inattività con stop-after-ignore
- PR notification veloce (15-30 min), streak/volume batch a 09:00
- Message rotation per evitare fatigue
