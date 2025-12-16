# FitLog Context Loader

Carica il contesto della sessione corrente per capire lo stato del progetto.

## Esegui

Esegui lo script `.claude/scripts/gather-context.sh` e mostra l'output all'utente.

## Poi

Dopo aver mostrato il contesto:

1. **Riassumi** brevemente cosa stava succedendo (se ci sono file modificati o context precedente)
2. **Suggerisci** possibili prossimi step basandoti su:
   - Branch attuale (se è un feature branch, cosa manca?)
   - File modificati (cosa si stava facendo?)
   - TODO trovati (cosa resta da fare?)
   - Context file precedente (se esiste)

3. **Chiedi** all'utente cosa vuole fare in questa sessione

## Salvataggio Context

Se l'utente sta per chiudere la sessione o chiede di salvare il contesto:

1. Crea/aggiorna `.fitlog-context.md` con:
   - Data e ora
   - Cosa è stato fatto in questa sessione
   - TODO aperti
   - Decisioni prese
   - Prossimi step suggeriti

2. Questo file verrà letto automaticamente alla prossima sessione
