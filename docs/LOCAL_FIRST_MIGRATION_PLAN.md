# 📱 Piano Migrazione Local-First GymBro

## 🎯 Obiettivo
Rendere GymBro 100% funzionale offline per utenti FREE, con Firestore solo per utenti PREMIUM.

## 📊 Stato Attuale

### ✅ GIÀ MIGRATO
- [x] Workout saving (HybridExerciseActivityRepository)
- [x] Exercise activities 
- [x] Progress/Analytics base

### ❌ DA MIGRARE

#### 1. **Workout Templates** 🔴 CRITICO
**Attuale**: Tutto su Firestore
**Target**: 
- FREE: Templates locali (Hive)
- PREMIUM: Templates locali + cloud + community sharing

**Files da modificare**:
- `/lib/features/workout_templates/data/repositories/template_repository.dart`

**Implementazione**:
```dart
class HybridTemplateRepository {
  // FREE: Salva in Hive
  // PREMIUM: Salva in Hive + sync Firestore
  
  Future<void> saveTemplate(template) {
    await hive.save(template); // Sempre
    if (isPremium) {
      firestore.save(template); // Solo premium
    }
  }
}
```

#### 2. **Achievements & XP System** 🟡 IMPORTANTE
**Attuale**: Firestore per XP e achievements
**Target**:
- FREE: XP/Achievements locali
- PREMIUM: Sync + leaderboard globale

**Files da modificare**:
- `/lib/features/home/providers/achievement_xp_provider.dart`
- `/lib/features/home/providers/optimized_achievement_xp_provider.dart`

#### 3. **Weekly Goals** 🟢 FACILE
**Attuale**: Firestore
**Target**: 100% locale per tutti

**Files da modificare**:
- `/lib/features/home/presentation/widgets/weekly_goals_widget.dart`

#### 4. **Notifications** 🟢 FACILE
**Attuale**: Firestore
**Target**: 100% locale per tutti

**Files da modificare**:
- `/lib/features/notifications/presentation/providers/notification_provider.dart`

#### 5. **Home Customization** 🟢 FACILE
**Attuale**: Firestore
**Target**: 100% locale (già parzialmente fatto con Hive)

**Files da modificare**:
- `/lib/features/home/providers/home_customization_provider.dart`

## 🏗️ Architettura Proposta

```
USER FREE (95%)
├── 📱 App Completa
│   ├── ✅ Tutti i workout locali
│   ├── ✅ Tutti i template locali
│   ├── ✅ Analytics completi locali
│   ├── ✅ XP/Achievements locali
│   ├── ✅ Goals locali
│   └── ✅ Export/Import manuale
│
└── ❌ NON HA
    ├── Sync multi-device
    ├── Backup cloud automatico
    ├── Template community
    └── Leaderboard globale

USER PREMIUM (5%)
├── 📱 Tutto di FREE +
│   ├── ☁️ Sync automatico
│   ├── 🌍 Template community
│   ├── 🏆 Leaderboard globale
│   ├── 💾 Backup cloud
│   └── 📊 Analytics avanzate
```

## 💰 Risparmio Stimato

| Feature | Writes/mese FREE | Costo Prima | Costo Dopo |
|---------|------------------|-------------|------------|
| Workouts | 750 | $0.14 | $0 ✅ |
| Templates | 50 | $0.01 | $0 ✅ |
| XP/Achievements | 300 | $0.05 | $0 ✅ |
| Goals | 100 | $0.02 | $0 ✅ |
| Notifications | 200 | $0.03 | $0 ✅ |
| **TOTALE** | **1400** | **$0.25** | **$0** |

Con 1000 utenti: **$250/mese → $12.50/mese** (solo 50 premium)

## 🚀 Implementazione Step-by-Step

### FASE 1 (1 giorno)
1. Creare `HybridTemplateRepository`
2. Migrare template system
3. Test salvataggio/caricamento locale

### FASE 2 (1 giorno)
1. Migrare XP/Achievements
2. Migrare Weekly Goals
3. Migrare Notifications

### FASE 3 (1 giorno)
1. Testing completo
2. UI per mostrare stato premium
3. Pagina upgrade premium

## ✅ Checklist Funzionalità FREE

- [ ] Creare nuovo workout
- [ ] Salvare workout completato
- [ ] Vedere storia workout
- [ ] Analytics e grafici
- [ ] Creare template personali
- [ ] Usare template salvati
- [ ] Sistema XP locale
- [ ] Achievements locali
- [ ] Goals settimanali
- [ ] Timer con Live Activity
- [ ] Export dati CSV/PDF
- [ ] Import backup

## 🎯 Risultato Finale

**UTENTE FREE**:
- App 100% funzionale offline
- Zero costi cloud
- Tutte le features core
- Privacy garantita (dati locali)

**UTENTE PREMIUM** ($2.99/mese):
- Tutto di FREE +
- Sync multi-device
- Backup automatico cloud
- Community features
- Priorità supporto

## 📝 Note Implementazione

1. **Hive Boxes necessari**:
   - `templates_box` - per template locali
   - `achievements_box` - per XP/achievements
   - `goals_box` - per obiettivi
   - `notifications_box` - per notifiche

2. **Migration Helper**:
   - Script per migrare dati esistenti da Firestore a locale
   - Backup automatico prima della migrazione

3. **UI Changes**:
   - Badge "Premium" su features cloud
   - Prompt upgrade su azioni premium
   - Stato sync nella settings

## 🔒 Sicurezza

- Dati locali criptati con `flutter_secure_storage`
- Export protetto da password (opzionale)
- Nessun dato sensibile in cloud per FREE users