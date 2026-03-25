# Registro Audit Fix

Ultimo aggiornamento: 2026-03-11

## Scopo

Registro operativo unico per:

- bug trovati durante l'audit
- fix gia applicati
- verifiche eseguite
- punti ancora aperti

Questo documento deve essere aggiornato man mano che ogni fix viene
completato, cosi il team ha un unico punto di riferimento per capire cosa e
cambiato e cosa resta ancora da sistemare.

## Baseline Attuale

Controllato il 2026-03-11:

- `npm run build` in `functions/`: superato
- `flutter analyze lib`: nessun errore analyzer, ma restano molti warning/info
- `flutter analyze test`: fallisce; la suite test al momento non e ancora una gate verde affidabile
- build native (`flutter build ios` / `flutter build apk`): non ancora eseguite in questo passaggio di audit

## Importato Dalla Sessione Di Audit Precedente

I fix seguenti erano gia stati riportati come completati prima di questa
sessione. Restano qui come baseline storica per l'audit corrente.

### Fix Applicativi / Dati

- `lib/features/analytics/presentation/providers/analytics_provider.dart`
  - separata la lookup legacy attivita per email dalla lookup PR/Firestore per uid
- `lib/features/analytics/domain/services/pr_tracker.dart`
  - aggiunto cache/fallback locale per la visibilita dei PR durante errori Firestore/rete
- `lib/features/progress/presentation/providers/cached_progress_provider.dart`
  - spostate le query statistiche/attivita recenti su `users/{uid}/workouts` e `endTime`
- `lib/features/progress/presentation/providers/progress_provider.dart`
  - spostate le query statistiche/attivita recenti su `users/{uid}/workouts` e `endTime`
- `lib/features/settings/presentation/providers/cloud_sync_provider.dart`
  - allineate le scritture cache template alla cache usata davvero dalla UI
  - ripristinati gli esercizi custom nel datasource attivo
  - riallineata la sync locale dei PR
- `lib/features/history/data/repositories/workout_history_repository_enhanced.dart`
  - aggiornate le letture history al path workout annidato e alla compatibilita date legacy/nuove
- `lib/features/workout/data/services/workout_history_service.dart`
  - aggiornate le letture ultimo workout/prefill al path workout annidato e a date compatibili
- `lib/features/history/domain/entities/workout_history_detail.dart`
  - aggiunta compatibilita date Firestore legacy/nuove per `startedAt` / `startTime` e `completedAt` / `endTime`
  - ricava `userId` dal path del documento padre quando manca nel payload
  - riscrive alias di compatibilita verso Firestore per schemi workout misti vecchi/nuovi
- `lib/features/workout/data/datasources/firebase_workout_datasource.dart`
  - i nuovi documenti workout includono ora `userId` anche nel body del documento oltre che nel path
- `lib/features/analytics/data/repositories/workout_analytics_repository_impl.dart`
  - aggiornata la sync analytics Firebase -> Hive al path workout annidato
- `lib/features/analytics/data/services/analytics_migration_service.dart`
  - aggiornate le letture migrazione al path workout annidato
- `lib/features/workout/presentation/providers/add_exercise_provider.dart`
  - aggiornata la lookup esercizi/workout recenti al path workout annidato
- `lib/features/scheduling/data/repositories/scheduling_repository_impl.dart`
  - i workout scaduti passano ora a `missed`
- `lib/features/custom_exercises/data/datasources/custom_exercise_local_datasource.dart`
  - corretto l'handling delle chiavi user-scoped per operazioni clear/count

### Fix Native / Piattaforma

- `ios/Runner/LiveActivityHandler.swift`
  - i callback async `FlutterResult` per timer/RPE/schedule vengono dispatchati sul main thread

### Fix Cloud Functions / Tooling

- `functions/src/index.ts`
  - esportato il modulo notifiche nell'entrypoint functions attivo
- `functions/tsconfig.json`
  - il sorgente notifiche e ora incluso nella build
- `functions/src/notifications/index.ts`
  - trigger workout allineato a `users/{userId}/workouts/{workoutId}`
  - trigger personal record allineato a `personalRecords/{recordId}`
  - mapping campi payload PR allineato a `value` / `previousValue`
  - typing del payload streak irrobustito cosi il modulo compila correttamente
- `functions/src/notifications/queue/NotificationQueue.ts`
  - migrata la call multicast a `sendEachForMulticast`
- `functions/src/notifications/personalization/NotificationPersonalization.ts`
  - aggiunta implementazione personalization mancante richiesta dal modulo notifiche
- `functions/src/notifications/privacy/NotificationPrivacy.ts`
  - aggiunta implementazione privacy mancante richiesta dal modulo notifiche
- `functions/src/notifications/monitoring/SystemMonitor.ts`
  - aggiunta implementazione monitoring mancante richiesta dal modulo notifiche
- `scripts/check_bugs.sh`
  - ora fallisce esplicitamente quando Flutter non e disponibile
- `scripts/quick_bug_check.sh`
  - ora fallisce esplicitamente quando Flutter non e disponibile

## Risultati Di Questa Sessione

### Completati

- `lib/features/history/data/repositories/workout_history_repository_enhanced.dart`
  - il bootstrap history non tronca piu sempre tutto a 90 giorni: per account premium scarica ora lo storico completo e fa backfill completo anche dopo upgrade da free a premium
  - la lettura pubblica del repository continua comunque ad applicare il cutoff free a 90 giorni, cosi downgrade o consumer secondari non riespongono storico oltre policy
  - le chiavi Hive legacy senza `userId` non vengono piu attribuite automaticamente all'utente corrente
  - impatto rimosso: su reinstall/device nuovo un premium non perde piu i workout piu vecchi di 3 mesi; su device condivisi workout legacy orfani non possono piu comparire sotto l'account sbagliato
  - stato: corretto

- `lib/features/workout/data/services/firestore_workout_history_reader.dart`
  - aggiunto reader condiviso per le letture Firestore di workout completati con fallback schema `endTime` / `completedAt`
  - applica il cutoff free di 90 giorni anche ai consumer secondari di storico
  - stato: corretto

- `lib/features/workout/data/services/workout_history_service.dart`
  - le letture storico/prefill non dipendono piu solo da `endTime` e rispettano il cutoff free di 90 giorni
  - impatto rimosso: se l'utente free apre prefill o storico esercizio dopo 3 mesi, non riaffiora piu storico bloccato; se un workout legacy ha solo `completedAt`, non sparisce piu dai risultati
  - stato: corretto

- `lib/features/workout/presentation/providers/previous_workout_provider.dart`
  - il recupero ultimo workout template usa ora fallback `completedAt` e rispetto del cutoff free
  - stato: corretto

- `lib/features/progress/presentation/providers/progress_provider.dart`
  - `recentActivityProvider` usa ora lettura compatibile legacy e tier-aware
  - stato: corretto

- `lib/features/workout/presentation/providers/add_exercise_provider.dart`
  - il backfill esercizi recenti da Firestore usa ora solo workout completati visibili secondo tier e schema compatibile legacy
  - impatto rimosso: su account free non riappaiono esercizi usati solo oltre i 3 mesi; workout legacy con solo `completedAt` contribuiscono di nuovo al backfill
  - stato: corretto

- `lib/core/data/repositories/base_hybrid_repository.dart`
  - il profilo `null` non viene piu trattato come premium nel gating cloud
  - stato: corretto

- `lib/core/data/repositories/optimized_base_hybrid_repository.dart`
  - il profilo `null` non viene piu trattato come premium nel gating cloud
  - stato: corretto

- `lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart`
  - il profilo `null` non viene piu trattato come premium nei percorsi repository workout
  - impatto rimosso: prima del caricamento profilo o dopo errori profilo si potevano aprire branch premium e storico oltre policy dei 3 mesi
  - stato: corretto

- `lib/features/workout/data/repositories/hybrid_exercise_activity_repository.dart`
  - il profilo `null` non viene piu trattato come premium nei vecchi percorsi activity/workout
  - stato: corretto

- `lib/features/history/domain/entities/workout_history_detail.dart`
  - `fromMap` e `SetHistoryDetail.fromMap` supportano ora alias/local payload legacy (`startTime` / `endTime`, `_userId`, valori `DateTime`)
  - impatto rimosso: cache/storici legacy non vengono piu ricostruiti con date sbagliate o `userId` perso durante il restore locale
  - stato: corretto

- `lib/features/exercise_merge/data/repositories/exercise_merge_repository_impl.dart`
  - corretto il riuso del batch Firestore ricreando `WriteBatch` dopo ogni commit boundary
  - impatto rimosso: merge grandi non si fermano piu dopo la prima finestra batch
  - stato: corretto

- `lib/features/workout/data/services/workout_sync_service.dart`
  - la sync incrementale ora viene persistita tramite `SharedPreferences`
  - aggiunto caricamento/salvataggio reale del timestamp ultimo sync
  - stato: corretto

- `lib/features/workout/data/datasources/firebase_workout_datasource.dart`
  - le letture sync ora possono interrogare `updatedAt` tramite `useUpdatedAt`
  - il payload Firestore ora scrive `userId` e alias compatibili per le date start/end workout
  - stato: corretto

- `lib/features/settings/presentation/providers/cloud_sync_provider.dart`
  - la sync workout ora pagina le letture Firestore e cancella le entry Hive locali stale
  - impatto rimosso: i workout cancellati nel cloud non sopravvivono piu in locale come ghost entries
  - stato: corretto

- `lib/features/workout/domain/usecases/complete_workout_usecase.dart`
  - il default di `saveAsActivities` e stato cambiato a `false`
  - stato: corretto

- `lib/features/workout/data/services/workout_sync_service.dart`
  - il gating premium trattava il profilo `null` come premium perche `null != AccountTier.free`
  - impatto: la sync poteva bypassare il controllo premium e fallire piu avanti nei check di connettivita
  - stato: corretto

- `test/shared/auth/entities/user_profile_test.dart`
  - test aggiornati alla API `TemplateQuota` attuale store-first (`library` / `distribution`)
  - impatto rimosso: i test entita auth/quota non falliscono piu sui vecchi nomi costruttore `private/public`
  - stato: corretto

- `test/shared/auth/entities/user_profile_extended_test.dart`
  - fixture test e aspettative quota aggiornate alla API `TemplateQuota` attuale
  - impatto rimosso: i test Firestore/profile non validano piu un contratto quota superato
  - stato: corretto

- `test/features/workout_templates/presentation/template_widgets_test.dart`
  - allineati i test di `TemplateQuotaIndicator` alla UI e al copy attuale della Library quota
  - impatto rimosso: i test widget non falliscono piu per il passaggio del prodotto da quote `private/public` a `library/distribution`
  - stato: corretto

- `test/features/onboarding/p0_bug_fixes_test.dart`
  - sostituito l'uso dell'enum tutorial rimosso con lo step attuale `editSetGestures`
  - impatto rimosso: i test onboarding pause/resume compilano di nuovo contro il flow tutorial attivo
  - stato: corretto

- `test/features/stress_index/domain/services/template_suggestion_engine_extended_test.dart`
  - sostituito l'uso non valido del matcher `isFinite` e ripuliti i relativi problemi analyzer
  - impatto rimosso: i test stress index compilano e validano correttamente output numerici finiti
  - stato: corretto

- `test/features/workout_templates/domain/services/template_cloud_service_test.dart`
  - riallineati i test del value object quota alla API `TemplateQuotaInfo` attuale (`library` / `distribution`)
  - impatto rimosso: i test quota cloud template non falliscono piu su parametri costruttore `private/public` rimossi
  - stato: corretto

- `test/widget/auth/settings_screen_migration_spot_test.dart`
  - aggiornate le aspettative quota al modello attuale di Library quota per il tier free
  - impatto rimosso: il migration spot test non asserisce piu limiti free-tier obsoleti
  - stato: corretto

- `test/widget/auth/settings_screen_migration_test.dart`
  - aggiornate le aspettative quota al modello attuale di Library quota per il tier free
  - impatto rimosso: il migration widget test non asserisce piu limiti free-tier obsoleti
  - stato: corretto

- `test/core/repositories/hybrid_repository_test.dart`
  - documentato l'uso intenzionale di mock Firestore low-level per tipi SDK `sealed`, cosi da rimuovere rumore analyzer
  - impatto rimosso: l'analisi test non riporta piu questa suite come warning di compatibilita sealed-class
  - stato: corretto

- `test/features/analytics/data/repositories/pr_celebration_repository_impl_test.dart`
  - documentato l'uso intenzionale di mock Firestore low-level per tipi SDK `sealed`
  - impatto rimosso: l'analisi test non riporta piu falsi positivi come warning sealed-class
  - stato: corretto

- `test/features/analytics/data/repositories/workout_analytics_repository_impl_test.dart`
  - documentato l'uso intenzionale di mock Firestore low-level per tipi SDK `sealed`
  - impatto rimosso: l'analisi test non riporta piu falsi positivi come warning sealed-class
  - stato: corretto

- `test/features/auth/data/auth_service_impl_test.dart`
  - documentata la strategia intenzionale di mock Firestore e soppressi i warning correlati di immutabilita nei test double
  - impatto rimosso: l'analisi auth service non riporta piu warning Firestore sealed-class / fake mutability
  - stato: corretto

- `test/features/auth/presentation/providers/auth_provider_test.dart`
  - rimossi import ridondanti e documentata la strategia intenzionale di mock Firestore
  - impatto rimosso: l'analisi provider test non riporta piu rumore warning su mock/sealed
  - stato: corretto

### Ancora Aperti

### Infrastruttura Test

- `flutter analyze test`
  - non restano piu errori ne warning nel passaggio `flutter analyze test --no-pub`
  - restano pero molti `info` storici di stile/manutenzione nelle suite piu vecchie
  - stato: aperto

## Log Verifiche

### 2026-03-11

- `npm run build` in `functions/`: superato
- `flutter analyze lib`: superato senza errori analyzer
- `flutter analyze test`: fallito
  - il cluster principale di compile-break era attorno alle API quota template rinominate e a test onboarding/stress obsoleti
- `flutter analyze` su file workout/merge e test mirati: superato senza problemi
- `flutter test test/features/workout/data/services/workout_sync_service_test.dart`: superato
- `flutter test test/features/workout/data/repositories/workout_repository_impl_test.dart`: superato
- `flutter analyze` sui file test riparati di quota/onboarding/stress/settings: superato senza problemi
- `flutter analyze` sul cluster test con warning Firestore-mock: superato senza problemi
- `flutter analyze test --no-pub` filtrato su `warning`/`error`: nessun risultato

## Prossimo Ordine Di Esecuzione

1. Ridurre il volume warning di `flutter analyze test` pulendo i prossimi cluster ad alto segnale (import/local inutilizzati e doc test obsolete)
2. Decidere se rifattorizzare i test Firestore-heavy lontano dai mock low-level SDK o mantenere soppressioni analyzer esplicite dove il mocking e intenzionale
3. Riaprire l'audit piu ampio su path legacy auth/sync e su letture repository ancora legate a schemi storici
