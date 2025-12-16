# FitLog Cleanup Analysis

Analizza il codebase per trovare file "zombie" che potrebbero creare confusione.

## Esegui prima lo script di health check

Esegui `.claude/scripts/health-check.sh` per ottenere una panoramica rapida.

## Poi analizza in dettaglio

Per ogni problema trovato:

### File Duplicati
Se ci sono file con lo stesso nome in directory diverse:
1. Leggi entrambi i file
2. Determina quale è quello corretto/aggiornato
3. Suggerisci quale eliminare o rinominare
4. Verifica che tutti gli import puntino al file corretto

### File Orfani
Se ci sono file non importati da nessuno:
1. Verifica se sono effettivamente inutilizzati
2. Controlla se sono entry point, barrel files, o test
3. Se davvero inutilizzati, suggerisci di eliminarli
4. Lista le dipendenze che andrebbero rimosse

### File Stale
Se ci sono file con pattern sospetti (old_, temp_, deprecated_):
1. Verifica se sono ancora necessari
2. Se contengono codice utile, suggerisci come integrarlo
3. Altrimenti suggerisci di eliminarli

### Import Rotti
Se ci sono import che non risolvono:
1. Trova il file corretto
2. Suggerisci la correzione dell'import
3. Verifica che non ci siano altri import rotti nello stesso file

## Output atteso

Fornisci un report strutturato con:
- Lista dei problemi trovati
- Per ogni problema: diagnosi e soluzione suggerita
- Comandi per applicare le fix (se applicabile)
- Warning su eventuali rischi

## Importante

- NON eliminare file automaticamente senza conferma
- Verifica sempre che il file "sopravvissuto" sia quello corretto
- Considera che alcuni file potrebbero essere usati dinamicamente
