# 💰 Firestore Cost Analysis - Community Discovery & Search

## 📊 Executive Summary

**Feature**: Community Discovery & Search (Task 3-4 completato)
**Status**: ⚠️ Admin-only (testing phase)
**Estimated Cost**: ~$0.085/user/month (active users)

---

## 🔢 Operazioni Firestore per Scenario Utente

### Scenario 1: Apertura Discovery Screen

**Flow**:
1. `searchResultsProvider` stream iniziale
   - Query: `community_contributions` con `limit(60)` [over-fetch 3x per client-side filtering]
   - **Costo**: 60 document reads

2. `savedContributionIdsProvider`
   - Query: `user_saved_contributions/{userId}`
   - **Costo**: 1 document read

**TOTALE APERTURA**: **61 reads** = ~$0.00018 (61 × $0.000003/read)

---

### Scenario 2: Ricerca "bench press"

**Flow**:
1. Ogni keystroke aggiorna `searchQueryProvider`
   - **Client-side filtering** (no Firestore query)
   - **Costo**: 0 reads aggiuntive

**TOTALE RICERCA**: **0 reads** = $0

**Note**: La ricerca è completamente client-side. I 60 documenti sono già stati fetchati all'apertura dello screen. Pro: zero costo. Contro: ricerca limitata ai 60 documenti fetchati.

---

### Scenario 3: Cambio Filtri (es. difficulty: intermediate)

**Flow**:
1. `activeFiltersProvider` aggiornato
   - `searchResultsProvider` rebuilds con nuova query
   - Query: `community_contributions.where('difficulty', isEqualTo: 'intermediate').limit(20)`
   - **Costo**: 20 document reads

**TOTALE FILTRO**: **20 reads** = ~$0.00006

---

### Scenario 4: Save Contribution

**Flow**:
1. `saveContribution` transaction
   - Read: `contributions/{id}` (per verificare esistenza)
   - Write: update `saves` count
   - **Costo**: 1 read + 1 write

2. Update `user_saved_contributions`
   - Write: `arrayUnion([contributionId])`
   - **Costo**: 1 write

**TOTALE SAVE**: **1 read + 2 writes** = ~$0.000009 (1×$0.000003 + 2×$0.000003)

---

### Scenario 5: Unsave Contribution

**Flow**: Identico a Save
- 1 read (verify contribution exists)
- 1 write (decrement saves count)
- 1 write (arrayRemove from user_saved_contributions)

**TOTALE UNSAVE**: **1 read + 2 writes** = ~$0.000009

---

### Scenario 6: Increment View Count

**Flow**:
1. `incrementViewCount`
   - Write: update `viewCount` + `lastActivityAt`
   - **Costo**: 1 write

**TOTALE VIEW**: **1 write** = ~$0.000003

---

## 💰 Costo Mensile Stimato per Utente

### Utente Attivo (10 sessioni/giorno)

**Assunzioni**:
- 10x apertura discovery screen
- 30x ricerche (client-side, zero costo)
- 15x cambi filtro
- 5x save/unsave
- 20x view count increment

**Costo Giornaliero**:
```
Apertura:    10 × 61 reads   = 610 reads/giorno
Ricerche:    30 × 0 reads    = 0 reads/giorno
Filtri:      15 × 20 reads   = 300 reads/giorno
Save/Unsave: 5 × (1 read + 2 writes) = 5 reads + 10 writes/giorno
View Count:  20 × 1 write    = 20 writes/giorno

TOTALE GIORNALIERO:
- Reads: 915 reads/giorno
- Writes: 30 writes/giorno
```

**Costo Mensile (30 giorni)**:
```
Reads:  915 × 30 = 27,450 reads/mese  = ~$0.082/utente/mese
Writes: 30 × 30  = 900 writes/mese    = ~$0.0027/utente/mese

COSTO TOTALE: ~$0.085/utente/mese
```

---

## 📈 Scaling Estimates

| Users | Monthly Cost (Firestore) | Annual Cost |
|-------|--------------------------|-------------|
| 10 | $0.85 | $10.20 |
| 100 | $8.50 | $102 |
| 1,000 | $85 | $1,020 |
| 10,000 | $850 | $10,200 |
| 100,000 | $8,500 | $102,000 |

**Note**: Questi sono solo costi Firestore. Non includono:
- Hosting Firebase
- Cloud Functions (se usate)
- Storage (immagini, media)
- Authentication (gratis fino a 50K MAU)

---

## ⚠️ Costi Nascosti

### 1. Client-Side Search (Over-fetching)

**Problema**:
- Fetch 60 documenti per mostrarne ~20
- Spreco: **200% di reads extra**

**Cause**:
- Client-side filtering richiede over-fetching
- No Firestore full-text search nativo

**Ottimizzazione**:
- Implementare Algolia/Elastic Search
- Costo aggiuntivo: ~$1 per 1,000 requests
- Trade-off: Costo extra vs. user experience

**Decision**:
- ✅ **MVP**: Over-fetch accettabile (<1000 utenti)
- ⚠️ **Production**: Valutare Algolia se >10K utenti

---

### 2. Real-Time Listeners (Hot Paths)

**Problema**:
- `searchResultsProvider` è uno Stream (real-time)
- Ogni rebuild = nuova query = 60 reads
- Pericolo: Utente che cambia filtri rapidamente

**Scenario Worst-Case**:
```
User apre screen    → 60 reads
User cambia filtro  → 20 reads
User cambia filtro  → 20 reads (di nuovo)
User cambia filtro  → 20 reads (di nuovo)
...

Totale: 120+ reads in 10 secondi
```

**Ottimizzazione**:
- ✅ **IMPLEMENTATO**: Debounce sui filtri (500ms)
- ✅ **IMPLEMENTATO**: Cache client-side (Riverpod select)
- ⚠️ **TODO**: Rate limiting server-side

---

### 3. Composite Indexes (Hidden Costs)

**Problema**:
- Firestore crea automaticamente indici composti
- Ogni write aggiorna 3-5 indexes (dipende dalle query)
- Costo nascosto: 3-5x writes moltiplicatore

**Esempio**:
```
1 write (contribution) = 1 write visibile
+ 3 index updates (status, difficulty, createdAt)
= 4 writes totali (3x costo nascosto)
```

**Mitigation**:
- ✅ **DESIGN**: Minimizzare campi indicizzati
- ✅ **REVIEW**: Firestore console mostra indici necessari
- ⚠️ **MONITOR**: Cloud Firestore metrics per indice usage

---

## 🎯 Recommendations

### Phase 1: MVP (<1,000 users) - Current Status ✅

**Strategy**: Over-fetch + Client-side filtering
- ✅ Zero infrastructure cost (no Algolia)
- ✅ Fast development
- ⚠️ Costo Firestore: ~$85/month @ 1K users (acceptable)

**Action Items**:
- ✅ Implement debounce on filters (DONE)
- ✅ Add Riverpod caching (DONE)
- ⏳ Monitor Firestore metrics

---

### Phase 2: Growth (1,000-10,000 users)

**Strategy**: Optimize Firestore queries
- Reduce limit(60) → limit(30)
- Add pagination (load more on scroll)
- Cache popular searches server-side

**Estimated Savings**: 40-50% reduction
- From: $85/month @ 1K users
- To: $40-50/month @ 1K users

---

### Phase 3: Scale (>10,000 users)

**Strategy**: Algolia/Elastic Search
- Full-text search offloaded to specialized service
- Firestore only for write/update operations
- Algolia cost: ~$1/1,000 searches

**Cost Comparison**:
```
Firestore only:
- 10K users × $0.085/month = $850/month

Firestore + Algolia:
- Firestore writes: $200/month (60% reduction)
- Algolia searches: $300/month (10K users × 30 searches × $0.001)
- TOTAL: $500/month (40% savings)
```

---

## 📊 Mock Data Seeding Cost

**One-time operation**:
```
Upload 21 contributions = 21 writes
Create 3 user stats     = 3 writes
TOTAL: 24 writes = $0.000072 (~$0.00007)
```

**Negligible**: Less than $0.001 USD

---

## 🔍 Monitoring & Alerts

### Firebase Console Metrics

**Track**:
1. **Document reads/month** (target: <1M reads/month @ 1K users)
2. **Document writes/month** (target: <50K writes/month @ 1K users)
3. **Query patterns** (identify expensive queries)

**Alerts**:
- ⚠️ Reads spike >150% daily average
- 🚨 Writes spike >200% daily average
- 🚨 Single query >100 reads (indicates missing index)

**How to Setup**:
```
Firebase Console → Firestore → Usage tab
→ Set up budget alerts via GCP Billing
```

---

## ✅ Summary

**Current Implementation**:
- ✅ Admin-only (cost = $0 for testing)
- ✅ Over-fetch + client-side search (acceptable for MVP)
- ✅ Debounce + caching (optimized hot paths)
- ✅ Mock data seeding (negligible cost)

**Expected Cost**:
- 100 users: **$8.50/month**
- 1,000 users: **$85/month**
- 10,000 users: **$850/month**

**Next Steps**:
1. ✅ Test with mock data (READY)
2. ⏳ Monitor metrics for 1 week
3. ⏳ Decide: Keep over-fetch vs. Algolia (based on user count)
4. ⏳ Remove admin-only restriction when confident

**Risk**: LOW - Cost scales predictably, easy to optimize if needed.
