# Timer Request Examples - Come Fare Richieste Sicure

## 📋 **Template Obbligatorio**

Copia e incolla questo template per OGNI richiesta timer:

```
🎯 RICHIESTA TIMER: [Brief description]

📋 CONTESTO:
- Cosa voglio ottenere: [specific goal]
- Caso d'uso: [when/how it's used]
- Utente target: [who uses it]

🔍 VINCOLI ARCHITETTURALI:
- ✅ DEVE usare UnifiedTimerProvider esistente
- ✅ DEVE essere backward compatible
- ✅ DEVE usare feature flags se sperimentale
- ❌ NON creare nuovi provider/manager
- ❌ NON duplicare logica esistente

🧭 APPROCCIO PREFERITO:
[ ] Extension del provider esistente
[ ] Configurazione tramite enum/parameters
[ ] Servizio esterno iniettato
[ ] Modifica UI widget esistente

⚡ ESEMPIO COMPORTAMENTO ATTESO:
[Describe specific user flow]
```

---

## ✅ **Esempi di Richieste Sicure**

### **Esempio 1: Timer con Vibrazione Personalizzata**
```
🎯 RICHIESTA TIMER: Aggiungere pattern di vibrazione personalizzabili

📋 CONTESTO:
- Cosa voglio ottenere: Diversi pattern di vibrazione per diversi tipi di timer
- Caso d'uso: Timer rest = vibrazione singola, timer workout = vibrazione doppia
- Utente target: Tutti gli utenti che usano il timer

🔍 VINCOLI ARCHITETTURALI:
- ✅ DEVE usare UnifiedTimerProvider esistente
- ✅ DEVE essere backward compatible (vibrazione default)
- ✅ DEVE usare feature flags per test A/B
- ❌ NON creare VibrationTimerProvider
- ❌ NON duplicare gestione vibrazione esistente

🧭 APPROCCIO PREFERITO:
[x] Extension del provider esistente
[x] Configurazione tramite enum VibrationPattern
[ ] Servizio esterno iniettato
[ ] Modifica UI widget esistente

⚡ ESEMPIO COMPORTAMENTO ATTESO:
1. startTimer(type: TimerType.rest, vibrationPattern: VibrationPattern.single)
2. Timer funziona normalmente
3. Al completamento, vibra con pattern specificato
4. Fallback a vibrazione default se pattern non supportato
```

### **Esempio 2: Timer HIIT Multi-Fase**
```
🎯 RICHIESTA TIMER: Supporto per timer HIIT con fasi multiple

📋 CONTESTO:
- Cosa voglio ottenere: Timer che alterna automaticamente lavoro/riposo
- Caso d'uso: HIIT 30s lavoro + 10s riposo × 8 round automatico
- Utente target: Utenti che fanno allenamenti HIIT

🔍 VINCOLI ARCHITETTURALI:
- ✅ DEVE usare UnifiedTimerProvider esistente
- ✅ DEVE essere backward compatible
- ✅ DEVE supportare timer normali esistenti
- ❌ NON creare HIITTimerProvider
- ❌ NON creare sistema timer separato

🧭 APPROCCIO PREFERITO:
[x] Extension del provider esistente
[x] Configurazione tramite TimerType.interval + List<Duration>
[ ] Servizio esterno iniettato
[x] Modifica UI widget per mostrare fase attuale

⚡ ESEMPIO COMPORTAMENTO ATTESO:
1. startTimer(type: TimerType.interval, phases: [30s, 10s, 30s, 10s])
2. Timer conta 30s (mostra "LAVORO"), poi passa a 10s (mostra "RIPOSO")
3. Continua alternando fino alla fine di tutte le fasi
4. UI mostra progresso fase corrente e fase totale
```

### **Esempio 3: Analytics per Timer**
```
🎯 RICHIESTA TIMER: Tracking analytics per uso timer

📋 CONTESTO:
- Cosa voglio ottenere: Raccogliere dati su come gli utenti usano il timer
- Caso d'uso: Capire durate più comuni, abbandoni, completamenti
- Utente target: Analytics interne, non visibile agli utenti

🔍 VINCOLI ARCHITETTURALI:
- ✅ DEVE usare UnifiedTimerProvider esistente
- ✅ DEVE essere backward compatible (analytics opzionale)
- ✅ DEVE essere toggleabile via feature flag
- ❌ NON creare TimerAnalyticsProvider
- ❌ NON modificare logica timer core

🧭 APPROCCIO PREFERITO:
[ ] Extension del provider esistente
[ ] Configurazione tramite enum/parameters
[x] Servizio esterno TimerAnalyticsService iniettato
[ ] Modifica UI widget esistente

⚡ ESEMPIO COMPORTAMENTO ATTESO:
1. Timer inizia: analytics.trackTimerStart(type, duration)
2. Timer funziona normalmente senza interferenze
3. Timer completa: analytics.trackTimerComplete(actualDuration)
4. Timer viene abbandonato: analytics.trackTimerAbandoned(remainingTime)
```

---

## ❌ **Esempi di Richieste Pericolose da Evitare**

### **❌ RICHIESTA PERICOLOSA 1**
```
"Voglio un sistema timer avanzato per i powerlifter che gestisce rest più lunghi"
```
**Problema**: Non usa template, non specifica vincoli, sembra richiedere sistema separato

### **❌ RICHIESTA PERICOLOSA 2**
```
"Crea PowerliftingTimerProvider che eredita da UnifiedTimerProvider"
```
**Problema**: Chiede esplicitamente nuovo provider, anche se eredita

### **❌ RICHIESTA PERICOLOSA 3**
```
"Refactoring completo del sistema timer per supportare workout complessi"
```
**Problema**: "Refactoring completo" suggerisce riscrivere invece di estendere

---

## 🎯 **Come Claude Dovrebbe Rispondere**

### **✅ Richiesta Sicura (Con Template)**
```
Michele: [Usa template completo]

Claude: ✅ Perfetto! La richiesta rispetta tutti i vincoli architetturali.

APPROCCIO CONFERMATO:
- Estendo UnifiedTimerProvider con extension method
- Aggiungo VibrationPattern enum a UnifiedTimerState
- Mantengo backward compatibility
- Uso feature flags per rollout graduale

Procedo con l'implementazione seguendo questo piano sicuro.
```

### **❌ Richiesta Pericolosa (Senza Template)**
```
Michele: "Voglio un timer diverso per il cardio"

Claude: 🛑 Per evitare di creare layer inutili, potresti riformulare usando il template sicuro?

Specificatamente:
- Cosa deve fare di diverso questo timer cardio?
- È una configurazione diversa (TimerType.cardio) o logica nuova?
- Possiamo estendere UnifiedTimerProvider?

Per favore usa il template in CLAUDE.md sezione 'TIMER DEVELOPMENT RULES' così posso implementare in modo sicuro.
```

### **⚠️ Richiesta Ambigua**
```
Michele: "Sistema di notifiche avanzate per il timer"

Claude: ⚠️ Questa richiesta potrebbe portare a creare nuovo layer.

APPROCCIO SICURO che propongo:
1. Creare NotificationService esterno (non TimerNotificationProvider)
2. Iniettarlo in UnifiedTimerProvider esistente
3. Configurare tramite enum NotificationType
4. Feature flag per rollout graduale

Sei d'accordo con questo approccio che mantiene architettura pulita?
```

---

## 🛡️ **Setup Protezione Automatica**

Per abilitare la protezione automatica:

```bash
# Abilita protezione pre-commit
make timer-protection

# O manualmente
./scripts/setup-timer-protection.sh
```

La protezione bloccherà automaticamente:
- Nuovi file `*timer*provider*.dart`
- Nuovi file `*Timer*Manager*.swift`
- Nuovi platform channels timer
- Superamento dei limiti (3 provider max, 1 manager iOS max)

---

## 📝 **Quick Reference**

### **Sempre OK**
- Extension methods su UnifiedTimerProvider
- Nuovi enum per configurazione (TimerType, TimerBehavior)
- Servizi esterni iniettati
- Feature flags per nuove funzionalità

### **Sempre Bloccato**
- Nuovi `*TimerProvider` classes
- Nuovi `*TimerManager` iOS
- Duplicazione logica esistente
- Platform channels aggiuntivi

### **In Dubbio?**
- Usa il template obbligatorio
- Specifica i vincoli architetturali
- Chiedi conferma dell'approccio prima dell'implementazione

**Golden Rule**: Se stai per creare un nuovo layer timer, FERMATI e usa il template.