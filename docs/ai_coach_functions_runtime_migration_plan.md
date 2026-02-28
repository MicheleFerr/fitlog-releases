# AI Coach Functions Runtime Migration Plan

Data piano: 2026-02-23

## Stato attuale
- Runtime Functions: Node `20` (`functions/package.json`).
- `firebase-functions`: `^7.0.2`.
- `firebase-admin`: `^13.6.0`.
- Warning deploy: deprecazione runtime Node 20.

## Obiettivo
Migrare senza regressioni su:
- Runtime Node supportato (target: `22`).
- Dipendenze Functions aggiornate e compatibili.

## Fase 1: Pre-check (nessun deploy)
1. Verificare release notes Firebase Functions runtime per confermare Node 22 come target del progetto.
2. Verificare che tutte le funzioni compilino con TypeScript corrente.
3. Congelare una baseline:
   - `npm --prefix functions ci`
   - `npm --prefix functions run build`

## Fase 2: Upgrade controllato dipendenze
1. Aggiornare patch/minor sicure:
   - `firebase-functions` a `^7.0.5`
   - `firebase-admin` a `^13.6.1`
2. Rebuild e smoke test locale.
3. Verificare assenza breaking changes su:
   - callable v2 (`onCall`/`HttpsError`)
   - App Check enforcement
   - wrapper custom rate limit (`withRateLimit`)

## Fase 3: Runtime bump Node
1. Modificare `functions/package.json`:
   - `\"engines\": { \"node\": \"22\" }`
2. Deploy canary della sola function AI Coach:
   - `firebase deploy --only functions:aiCoachChatCompletion`
3. Verifiche post-deploy:
   - chiamata autenticata + App Check valida
   - tool-calling
   - errore quota (`resource-exhausted`)

## Fase 4: Rollout completo
1. Deploy completo funzioni dopo canary stabile.
2. Monitorare 24-48h:
   - error rate callable
   - latenza p95/p99
   - errori `failed-precondition`, `unavailable`, `resource-exhausted`

## Rollback rapido
1. Ripristinare `engines.node` al valore precedente.
2. Ridistribuire funzione canary.
3. Se necessario, pin temporaneo versione precedente `firebase-functions`.
