# Brainstorm con Personas

**Trigger**: `/brainstorm [sezione o feature]`

L'utente vuole analizzare e migliorare: $ARGUMENTS

---

## Workflow

### Step 1: Carica contesto

1. Leggi `docs/USER_PERSONAS.md` per avere le 12 personas in mente
2. Esplora il codice della sezione menzionata
3. Identifica lo stato attuale

### Step 2: Analisi per Persona

Per ogni persona PRIMARIA (Marco, Chiara, Luca, Sofia, Roberto):

```
### [Nome Persona] - [Profilo]

**Attualmente**: Come vive questa sezione oggi?
**Pain Points**: Cosa non funziona per lei/lui?
**Opportunità**: Cosa la renderebbe migliore?
**Idea concreta**: 1 miglioramento specifico
```

### Step 3: Sintesi Idee

Raccogli le migliori idee emerse:

```
┌─────────────────────────────────────────────────────────────┐
│ TOP 5 MIGLIORAMENTI per [sezione]                          │
├────┬────────────────────────────────┬───────────────────────┤
│ #  │ Idea                           │ Personas beneficiate  │
├────┼────────────────────────────────┼───────────────────────┤
│ 1  │ [idea]                         │ Marco, Chiara, ...    │
│ 2  │ [idea]                         │ Luca, Sofia, ...      │
│ 3  │ [idea]                         │ ...                   │
│ 4  │ [idea]                         │ ...                   │
│ 5  │ [idea]                         │ ...                   │
└────┴────────────────────────────────┴───────────────────────┘
```

### Step 4: Prioritizzazione

Ordina per impatto:
- **Quick Wins**: Facili da implementare, alto impatto
- **Big Bets**: Più complessi ma trasformativi
- **Nice to Have**: Miglioramenti minori

### Step 5: Proposta

Presenta 2-3 idee prioritarie con:
- Descrizione chiara
- Personas beneficiate
- Effort stimato (S/M/L)
- Domanda: "Vuoi che sviluppi [idea X]?"

---

## Output Atteso

```
## Brainstorm: [Sezione]

### Analisi Personas

[Analisi per ogni persona...]

### Top Idee

[Tabella con 5 idee...]

### Raccomandazione

La mia proposta è implementare:
1. **[Idea principale]** - [perché]
2. **[Seconda idea]** - [perché]

Vuoi che proceda con una di queste?
```

---

## Esempio

Input: `/brainstorm home screen`

Output: Analisi di come ogni persona vive la home, pain points, e 5 idee concrete per migliorarla, con prioritizzazione.
