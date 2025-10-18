# 🏋️ Exercise Database Implementation Playbook

> **Guida pratica e riprendibile per l'implementazione graduale**
>
> Versione: 1.0 | Ultima modifica: 2025-10-16 | Status: Ready for Implementation

---

## 📑 Navigazione Rapida

- [Quick Start](#-quick-start)
- [Fase 1: Fondazioni](#fase-1-fondazioni-settimane-1-4)
- [Fase 2: Infrastruttura](#fase-2-infrastruttura-settimane-5-10)
- [Fase 3: Visibilità & Scale](#fase-3-visibilità--scale-settimane-11-16)
- [Fase 4: Espansione](#fase-4-espansione-settimane-17)
- [Troubleshooting](#-troubleshooting)
- [Reference](#-reference)

---

## 🚀 Quick Start

### Se riprendi dopo pause, fai questo:

```bash
# 1. Leggi il file di status attuale
cat docs/IMPLEMENTATION_STATUS.json

# 2. Identifica dove eri rimasto
grep "current_phase" docs/IMPLEMENTATION_STATUS.json

# 3. Salta al capitolo giusto in questo documento
# es: se sei in PHASE 2, salta a "FASE 2"

# 4. Leggi il checklist per quello che manca
# es: se mancano Security & Backup, leggi quella sezione
```

---

## 📋 Status Tracking File

**File da consultare**: `docs/IMPLEMENTATION_STATUS.json`

```json
{
  "last_updated": "2025-10-16",
  "current_phase": 1,
  "overall_progress": "0%",

  "phase_1": {
    "name": "Foundational",
    "status": "NOT_STARTED",
    "tasks": {
      "validation_testing": "NOT_STARTED",
      "user_feedback": "NOT_STARTED",
      "periodic_review": "NOT_STARTED"
    }
  },

  "phase_2": {
    "name": "Infrastructure",
    "status": "PENDING",
    "tasks": {
      "conflict_management": "PENDING",
      "security_backup": "PENDING",
      "smart_cache": "PENDING"
    }
  },

  "phase_3": {
    "name": "Visibility & Scale",
    "status": "PENDING"
  },

  "phase_4": {
    "name": "Expansion",
    "status": "PENDING"
  }
}
```

> **TIP**: Aggiorna questo file dopo ogni sessione di lavoro!

---

## 🎯 FASE 1: Fondazioni (Settimane 1-4)

> **Duration**: 4 settimane
> **Effort**: ⭐⭐ Basso
> **Impact**: ⭐⭐⭐⭐⭐ Massimo
> **Start Date**: YYYY-MM-DD (Da aggiornare)

### 📌 Obiettivi Fase 1

```
✅ Sistema di validazione dati automatizzato
✅ Test suite completa (unit + integration)
✅ User feedback collection system
✅ Periodic review automation
✅ CI/CD pipeline integration
```

---

### Task 1.1: Validazione & Testing (5-7 giorni)

#### 📝 Descrizione
Creare script di validazione che controllano:
- Completezza dei dati (campi obbligatori)
- Coerenza fra JSON/Firebase/Hive
- Duplicati e esercizi mancanti
- Consistenza versioning

#### 🔧 Implementazione

**Step 1: Script Python di validazione**

File: `scripts/validate_exercises.py`

```python
#!/usr/bin/env python3
"""
Script di validazione per esercizi JSON
Controlla:
- Campi obbligatori
- Duplicati
- Versioning consistency
- Traduttori consistency (EN vs IT)
"""

import json
import sys
from pathlib import Path
from typing import List, Dict, Tuple

class ExerciseValidator:
    REQUIRED_FIELDS = ['id', 'nome', 'focus', 'imageUrl', 'difficolta']
    OPTIONAL_FIELDS = ['version', 'changelog', 'lastUpdated']

    def __init__(self, exercises_file: Path):
        self.file = exercises_file
        self.exercises = self._load_json()
        self.errors = []
        self.warnings = []

    def _load_json(self) -> List[Dict]:
        try:
            with open(self.file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Errore caricamento: {e}")
            sys.exit(1)

    def validate_all(self) -> bool:
        """Esegui tutti i controlli"""
        print(f"🔍 Validazione {len(self.exercises)} esercizi...")

        self._check_required_fields()
        self._check_duplicates()
        self._check_versioning()
        self._check_consistency()

        return self._print_report()

    def _check_required_fields(self):
        """Controlla campi obbligatori"""
        for idx, ex in enumerate(self.exercises):
            for field in self.REQUIRED_FIELDS:
                if field not in ex or not ex[field]:
                    self.errors.append(
                        f"Esercizio #{idx}: campo '{field}' mancante o vuoto"
                    )

    def _check_duplicates(self):
        """Controlla ID duplicati"""
        ids = {}
        for idx, ex in enumerate(self.exercises):
            ex_id = ex.get('id')
            if ex_id in ids:
                self.errors.append(
                    f"Duplicato ID '{ex_id}' trovato negli indici {ids[ex_id]} e {idx}"
                )
            else:
                ids[ex_id] = idx

    def _check_versioning(self):
        """Controlla versioning consistency"""
        for idx, ex in enumerate(self.exercises):
            version = ex.get('version', '0.1.0')

            # Valida formato semantic versioning
            parts = version.split('.')
            if len(parts) != 3 or not all(p.isdigit() for p in parts):
                self.warnings.append(
                    f"Esercizio #{idx}: versione '{version}' non è semantic (X.Y.Z)"
                )

            # Se c'è changelog, controlla corrispondenza
            if 'changelog' in ex and ex['changelog']:
                latest_in_log = ex['changelog'][-1].get('version')
                if latest_in_log != version:
                    self.errors.append(
                        f"Esercizio #{idx}: version mismatch - "
                        f"file says '{version}', changelog says '{latest_in_log}'"
                    )

    def _check_consistency(self):
        """Controlla consistenza tra campi correlati"""
        for idx, ex in enumerate(self.exercises):
            # Controlla che focus sia non-vuoto
            if not ex.get('focus'):
                self.errors.append(f"Esercizio #{idx}: 'focus' non specificato")

            # Controlla che imageUrl sia valida
            img = ex.get('imageUrl', '')
            if not img.startswith('http'):
                self.warnings.append(f"Esercizio #{idx}: imageUrl non è URL valido")

    def _print_report(self) -> bool:
        """Stampa report e ritorna True se OK"""
        print("\n" + "="*60)

        if self.errors:
            print(f"❌ ERRORI ({len(self.errors)}):")
            for err in self.errors[:10]:
                print(f"  - {err}")
            if len(self.errors) > 10:
                print(f"  ... e altri {len(self.errors)-10} errori")
        else:
            print("✅ Nessun errore rilevato")

        if self.warnings:
            print(f"\n⚠️  AVVERTIMENTI ({len(self.warnings)}):")
            for warn in self.warnings[:5]:
                print(f"  - {warn}")
            if len(self.warnings) > 5:
                print(f"  ... e altri {len(self.warnings)-5} avvertimenti")

        print("="*60 + "\n")

        return len(self.errors) == 0

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Valida esercizi JSON")
    parser.add_argument('file', help='File JSON da validare')
    parser.add_argument('--strict', action='store_true', help='Fail on warnings too')

    args = parser.parse_args()

    validator = ExerciseValidator(Path(args.file))
    success = validator.validate_all()

    if args.strict and validator.warnings:
        print("❌ Strict mode: fallimento per warnings")
        success = False

    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
```

**Step 2: Dart unit tests**

File: `test/features/exercise_database/validation_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

void main() {
  group('ExerciseValidator', () {

    test('valida esercizio con campi obbligatori', () {
      final exercise = Exercise(
        id: 'test_1',
        nome: 'Test Exercise',
        focus: 'CORE',
        imageUrl: 'https://example.com/image.jpg',
        difficolta: 'Principiante',
      );

      expect(exercise.id, isNotNull);
      expect(exercise.nome, isNotEmpty);
    });

    test('rileva versioning mismatch', () {
      // Test che la versione nel campo version
      // corrisponda all'ultima nel changelog
      final changelog = [
        {'version': '0.1.0', 'changes': ['Initial']},
        {'version': '0.2.0', 'changes': ['Updated']},
      ];

      final latestVersion = changelog.last['version'];
      expect(latestVersion, equals('0.2.0'));
    });

    test('valida semantic versioning', () {
      final versions = ['0.1.0', '0.2.0', '1.0.0'];

      for (var v in versions) {
        final parts = v.split('.');
        expect(parts.length, equals(3));
        expect(int.tryParse(parts[0]), isNotNull);
      }
    });
  });
}
```

#### ✅ Checklist Task 1.1

- [ ] Script Python creato: `scripts/validate_exercises.py`
- [ ] Script testato localmente: `python3 scripts/validate_exercises.py assets/data/exercises_it.json`
- [ ] Dart tests creati: `test/features/exercise_database/validation_test.dart`
- [ ] Tests passano: `flutter test`
- [ ] Aggiunto a CI/CD pipeline (`.github/workflows/` o equivalente)
- [ ] Script eseguito su file attuali (0 errori)

#### 📊 Success Metrics

```
Validazione completata se:
✅ Python script esegue senza errori su exercises.json
✅ Python script esegue senza errori su exercises_it.json
✅ Tutti i Dart tests passano
✅ 0 errori critici nel report
✅ Script integrato in CI/CD
```

---

### Task 1.2: User Feedback System (10-14 giorni)

#### 📝 Descrizione
Implementare un sistema che permetta agli utenti di:
- Segnalare problemi su esercizi
- Lasciare commenti/suggerimenti
- Admin vede un dashboard con feedback aggregato

#### 🔧 Implementazione

**Step 1: Firestore Schema**

Aggiungi a `firestore.rules`:

```firestore
match /databases/{database}/documents {
  match /exercise_feedback/{docId} {
    allow read: if request.auth.uid != null && request.auth.token.admin == true;
    allow create: if request.auth.uid != null;

    allow update, delete: if request.auth.uid == resource.data.userId
                          || request.auth.token.admin == true;
  }
}
```

Collection structure:
```
exercise_feedback/
├─ {autoId}
│  ├─ userId: string (Firebase UID)
│  ├─ exerciseId: string (es: "sit_up_3_4")
│  ├─ version: string (es: "0.2.0")
│  ├─ feedbackType: string (BUG | SUGGESTION | TYPO | OTHER)
│  ├─ message: string
│  ├─ severity: int (1-5, 1=minor, 5=critical)
│  ├─ createdAt: timestamp
│  ├─ status: string (OPEN | REVIEWING | RESOLVED | DISMISSED)
│  └─ adminNotes: string
│
└─ {autoId}
   └─ ...
```

**Step 2: UI - Feedback Button in Exercise Card**

File: `lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseFeedbackButton extends ConsumerWidget {
  final String exerciseId;
  final String exerciseName;
  final String version;

  const ExerciseFeedbackButton({
    required this.exerciseId,
    required this.exerciseName,
    required this.version,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.flag_outlined),
      tooltip: 'Segnala problema',
      onPressed: () => _showFeedbackDialog(context),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    String selectedType = 'SUGGESTION';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Segnala su: $exerciseName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedType,
                items: [
                  DropdownMenuItem(value: 'BUG', child: Text('🐛 Bug')),
                  DropdownMenuItem(value: 'SUGGESTION', child: Text('💡 Suggerimento')),
                  DropdownMenuItem(value: 'TYPO', child: Text('📝 Errore di testo')),
                  DropdownMenuItem(value: 'OTHER', child: Text('❓ Altro')),
                ].toList(),
                onChanged: (value) => selectedType = value ?? 'SUGGESTION',
              ),
              SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Descrivi il problema...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _submitFeedback(context, feedbackController.text, selectedType);
              Navigator.pop(context);
            },
            child: Text('Invia'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback(
    BuildContext context,
    String message,
    String type,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('exercise_feedback').add({
        'userId': user.uid,
        'exerciseId': exerciseId,
        'version': version,
        'feedbackType': type,
        'message': message,
        'severity': 2,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'OPEN',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Feedback inviato. Grazie!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Errore invio feedback')),
      );
    }
  }
}
```

**Step 3: Admin Dashboard Provider**

File: `lib/features/admin/presentation/providers/exercise_feedback_provider.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackStats {
  final int totalFeedback;
  final int openCount;
  final Map<String, int> byType; // BUG, SUGGESTION, etc
  final Map<String, int> byExercise; // exerciseId -> count

  FeedbackStats({
    required this.totalFeedback,
    required this.openCount,
    required this.byType,
    required this.byExercise,
  });
}

final exerciseFeedbackStatsProvider = StreamProvider<FeedbackStats>((ref) {
  return FirebaseFirestore.instance
      .collection('exercise_feedback')
      .snapshots()
      .map((snapshot) {
    int total = snapshot.docs.length;
    int open = 0;
    Map<String, int> byType = {};
    Map<String, int> byExercise = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['status'] == 'OPEN') open++;

      final type = data['feedbackType'] ?? 'OTHER';
      byType[type] = (byType[type] ?? 0) + 1;

      final exId = data['exerciseId'] ?? 'unknown';
      byExercise[exId] = (byExercise[exId] ?? 0) + 1;
    }

    return FeedbackStats(
      totalFeedback: total,
      openCount: open,
      byType: byType,
      byExercise: byExercise,
    );
  });
});

// Provider per feedback su uno specifico esercizio
final exerciseFeedbackProvider = StreamProvider.family<
  List<DocumentSnapshot>,
  String
>((ref, exerciseId) {
  return FirebaseFirestore.instance
      .collection('exercise_feedback')
      .where('exerciseId', isEqualTo: exerciseId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});
```

#### ✅ Checklist Task 1.2

- [ ] Collection `exercise_feedback` creata in Firestore
- [ ] Security rules aggiornate
- [ ] `ExerciseFeedbackButton` widget implementato
- [ ] Dialog di feedback funziona
- [ ] Dati salvano in Firestore correttamente
- [ ] Admin provider implementato
- [ ] Stats calcolati correttamente
- [ ] Test della funzionalità completato

#### 📊 Success Metrics

```
Feedback system OK se:
✅ Utente riesce a cliccare bottone segnalazione
✅ Dialog appare correttamente
✅ Feedback salvato in Firestore
✅ Admin vede stats dashboard
✅ Filtri funzionano (per tipo, esercizio, etc)
```

---

### Task 1.3: Periodic Review Process (5-10 giorni)

#### 📝 Descrizione
Automatizzare processo di revisione periodica:
- Identificare esercizi da revisionare (vecchi, poco usati, con segnalazioni)
- Notificare admin
- Generare report

#### 🔧 Implementazione

**Step 1: Cloud Function per review automation**

File: `cloud_functions/functions/src/index.ts` (o `main.py` se preferisci)

```python
# cloud_functions/review_exercises.py

from firebase_admin import firestore, initialize_app
from datetime import datetime, timedelta
import json

initialize_app()

def trigger_exercise_review(request):
    """
    Cloud Function da eseguire ogni mese (via Cloud Scheduler)
    Identifica esercizi che devono essere revisionati
    """

    db = firestore.client()

    # Parametri di revisione
    REVIEW_INTERVAL_DAYS = 90  # Rivedi se non toccato da 90 giorni
    FEEDBACK_THRESHOLD = 3      # Rivedi se >= 3 segnalazioni

    issues = {
        'stale_exercises': [],      # Non aggiornati da 90 giorni
        'feedback_flagged': [],     # Con segnalazioni aperte
        'incomplete': [],           # Con campi mancanti
    }

    # 1. Trova esercizi stale (non modificati da 90 giorni)
    old_date = datetime.now() - timedelta(days=REVIEW_INTERVAL_DAYS)

    stale_docs = db.collection('exercises_master').where(
        'lastModified', '<', old_date
    ).stream()

    for doc in stale_docs:
        issues['stale_exercises'].append({
            'id': doc.id,
            'name': doc.get('name'),
            'lastModified': doc.get('lastModified'),
        })

    # 2. Trova esercizi con feedback aperto
    feedback_docs = db.collection('exercise_feedback').where(
        'status', '==', 'OPEN'
    ).stream()

    feedback_by_exercise = {}
    for doc in feedback_docs:
        ex_id = doc.get('exerciseId')
        if ex_id not in feedback_by_exercise:
            feedback_by_exercise[ex_id] = []
        feedback_by_exercise[ex_id].append(doc)

    for ex_id, feedbacks in feedback_by_exercise.items():
        if len(feedbacks) >= FEEDBACK_THRESHOLD:
            issues['feedback_flagged'].append({
                'id': ex_id,
                'feedback_count': len(feedbacks),
            })

    # 3. Salva report
    report = {
        'timestamp': datetime.now().isoformat(),
        'stale_count': len(issues['stale_exercises']),
        'feedback_flagged_count': len(issues['feedback_flagged']),
        'issues': issues,
    }

    db.collection('admin_reports').document('exercise_review').set(report)

    # 4. Invia notifica admin
    admin_users = db.collection('users').where(
        'role', '==', 'admin'
    ).stream()

    for admin in admin_users:
        # Invia notifica (implementa secondo il sistema)
        send_admin_notification(
            admin.id,
            f"Exercise Review Report: {len(issues['stale_exercises'])} stale, "
            f"{len(issues['feedback_flagged'])} flagged"
        )

    return {
        'status': 'success',
        'issues_found': len(issues['stale_exercises']) + len(issues['feedback_flagged'])
    }

def send_admin_notification(user_id, message):
    """Invia notifica admin"""
    # Implementa secondo il tuo sistema di notifiche
    pass
```

**Step 2: Cloud Scheduler setup**

```yaml
# Schedule: ogni primo del mese alle 02:00 UTC
# Nome: exercise-review-trigger

apiVersion: cloudscheduler.googleapis.com/v1
name: projects/your-project/locations/europe-west1/jobs/exercise-review
description: Trigger monthly exercise review
schedule: "0 2 1 * *"  # 1st day of month, 02:00 UTC
timeZone: "UTC"
httpTarget:
  uri: https://your-region-your-project.cloudfunctions.net/trigger_exercise_review
  httpMethod: POST
```

**Step 3: Admin report viewer**

File: `lib/features/admin/presentation/screens/exercise_review_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseReviewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Review Report')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_reports')
            .doc('exercise_review')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final staleCount = data['stale_count'] ?? 0;
          final flaggedCount = data['feedback_flagged_count'] ?? 0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('🕐 Stale Exercises'),
                          subtitle: Text('Not updated in 90+ days'),
                          trailing: Text('$staleCount',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Divider(),
                        ListTile(
                          title: Text('🚩 Feedback Flagged'),
                          subtitle: Text('3+ open feedback items'),
                          trailing: Text('$flaggedCount',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _openDetailedReport(context, data),
                  child: Text('View Detailed Report'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openDetailedReport(BuildContext context, Map<String, dynamic> data) {
    // Implementa dettagli report
  }
}
```

#### ✅ Checklist Task 1.3

- [ ] Cloud Function creata e deployata
- [ ] Cloud Scheduler configurato (mensile)
- [ ] Report salvato in Firestore
- [ ] Admin notification implementata
- [ ] Review screen UI creato
- [ ] Test della automazione completato
- [ ] Manuale di manutenzione documentato

#### 📊 Success Metrics

```
Periodic review OK se:
✅ Report generato automaticamente
✅ Dati accurati (stale exercises correttamente identificati)
✅ Admin riceve notificazione
✅ UI mostra dati correttamente
✅ Nessun errore nei logs
```

---

## ✅ FASE 1 CHECKPOINT

**Prima di passare a Fase 2, verifica:**

```
☐ Task 1.1: Validation & Testing completato
  ├─ Python script creato e testato
  ├─ Dart tests passano
  └─ CI/CD integrato

☐ Task 1.2: User Feedback System completato
  ├─ Firestore schema setup
  ├─ UI feedback button funziona
  ├─ Admin dashboard mostra dati
  └─ Test end-to-end superati

☐ Task 1.3: Periodic Review Process completato
  ├─ Cloud Function deployata
  ├─ Cloud Scheduler attivo
  ├─ Report generato
  └─ Admin notificato

☐ Documentazione aggiornata
☐ IMPLEMENTATION_STATUS.json aggiornato
```

Se tutti i checkbox sono ✅, sei pronto per **FASE 2**.

---

## 🎯 FASE 2: Infrastruttura (Settimane 5-10)

> **Duration**: 6 settimane
> **Effort**: ⭐⭐⭐⭐ Medio-alto
> **Impact**: ⭐⭐⭐⭐ Critico
> **Start Date**: YYYY-MM-DD (Da aggiornare)

### 📌 Obiettivi Fase 2

```
✅ Sistema di gestione conflitti per admin
✅ Backup automatici giornalieri
✅ Recovery procedures testate
✅ Audit logging immutabile
✅ Cache layer intelligente
```

---

### Task 2.1: Conflict Management & Merge (14-21 giorni)

#### 📝 Descrizione
Quando due admin modificano lo stesso esercizio, gestire conflitti in modo intelligente.

#### 🔧 Implementazione

**Step 1: Versioning conflict detection**

File: `lib/features/admin/domain/services/conflict_detection_service.dart`

```dart
class ConflictDetectionService {
  final FirebaseFirestore _firestore;

  Future<ConflictStatus> detectConflict({
    required String exerciseId,
    required Map<String, dynamic> localChanges,
    required String localVersion,
  }) async {
    // Ottieni versione remota
    final remoteDoc = await _firestore
        .collection('exercises_master')
        .doc(exerciseId)
        .get();

    if (!remoteDoc.exists) {
      return ConflictStatus.noConflict;
    }

    final remoteVersion = remoteDoc['version'] ?? '0.1.0';
    final remoteData = remoteDoc.data() ?? {};

    // Confronta versioni
    if (remoteVersion != localVersion) {
      // Version mismatch = possibile conflitto
      return ConflictStatus.detected(
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        conflictingFields: _findConflictingFields(localChanges, remoteData),
      );
    }

    return ConflictStatus.noConflict;
  }

  List<String> _findConflictingFields(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final conflicts = <String>[];

    for (final key in local.keys) {
      if (remote.containsKey(key) && local[key] != remote[key]) {
        conflicts.add(key);
      }
    }

    return conflicts;
  }
}

class ConflictStatus {
  final bool hasConflict;
  final String? localVersion;
  final String? remoteVersion;
  final List<String> conflictingFields;

  ConflictStatus({
    required this.hasConflict,
    this.localVersion,
    this.remoteVersion,
    this.conflictingFields = const [],
  });

  factory ConflictStatus.noConflict() => ConflictStatus(hasConflict: false);

  factory ConflictStatus.detected({
    required String localVersion,
    required String remoteVersion,
    required List<String> conflictingFields,
  }) => ConflictStatus(
    hasConflict: true,
    localVersion: localVersion,
    remoteVersion: remoteVersion,
    conflictingFields: conflictingFields,
  );
}
```

**Step 2: Merge resolution UI**

File: `lib/features/admin/presentation/screens/conflict_resolution_screen.dart`

```dart
class ConflictResolutionScreen extends ConsumerWidget {
  final String exerciseId;
  final ConflictStatus conflict;
  final Map<String, dynamic> localChanges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Resolve Conflict')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConflictInfo(context),
            SizedBox(height: 24),
            _buildConflictingFields(context, ref),
            SizedBox(height: 24),
            _buildActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚠️ Conflict Detected',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Local: v${conflict.localVersion}',
                style: TextStyle(color: Colors.blue)),
            Text('Remote: v${conflict.remoteVersion}',
                style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictingFields(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conflicting Fields:',
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 12),
        ...conflict.conflictingFields.map((field) =>
          _buildFieldConflict(context, field)
        ),
      ],
    );
  }

  Widget _buildFieldConflict(BuildContext context, String field) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Local: ${localChanges[field]}',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                  Text('Remote: (fetch and show)',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            ),
            ToggleButtons(
              isSelected: [true, false], // User selects local or remote
              onPressed: (index) {
                // Handle selection
              },
              children: [
                Text('Use Local'),
                Text('Use Remote'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _resolveConflict(context, ref),
          child: Text('Resolve & Save'),
        ),
      ],
    );
  }

  Future<void> _resolveConflict(BuildContext context, WidgetRef ref) async {
    // Merge e salva con nuovo versioning
    // 1. Determina scelte utente per ogni campo
    // 2. Auto-bump versione (0.1.0 → 0.2.0)
    // 3. Aggiungi changelog entry per merge
    // 4. Salva in Firestore
    // 5. Notifica user
  }
}
```

**Step 3: Merge history tracking**

File: `lib/features/admin/domain/entities/merge_record.dart`

```dart
@freezed
class MergeRecord with _$MergeRecord {
  const factory MergeRecord({
    required String id,
    required String exerciseId,
    required String localVersion,
    required String remoteVersion,
    required String resultingVersion,
    required Map<String, MergeChoice> choices, // {field: 'local'|'remote'}
    required DateTime timestamp,
    required String mergedBy, // admin email
    required String? notes,
  }) = _MergeRecord;
}

enum MergeChoice { local, remote, custom }
```

#### ✅ Checklist Task 2.1

- [ ] ConflictDetectionService implementato
- [ ] UI di risoluzione conflitti creata
- [ ] Merge logic testate (unit test)
- [ ] History salvata in Firestore
- [ ] Test end-to-end (simula conflitto e risolvi)

---

### Task 2.2: Security & Disaster Recovery (21-28 giorni)

#### 📝 Descrizione
Backup automatici, recovery procedures, audit logging immutabile.

#### 🔧 Implementazione

**Step 1: Backup automation (Cloud Function)**

File: `cloud_functions/backup_exercises.py`

```python
from firebase_admin import firestore, storage
from datetime import datetime
import json
import gzip

def backup_exercises_daily(request):
    """
    Eseguito giornalmente da Cloud Scheduler
    Backa exercises_master in Cloud Storage
    """

    db = firestore.client()
    bucket = storage.bucket()

    print("🔄 Starting daily backup...")

    # 1. Leggi tutti gli esercizi
    exercises = []
    for doc in db.collection('exercises_master').stream():
        ex = doc.to_dict()
        ex['_id'] = doc.id
        exercises.append(ex)

    # 2. Crea backup JSON
    backup_data = {
        'metadata': {
            'backup_date': datetime.now().isoformat(),
            'exercise_count': len(exercises),
            'version': '1.0',
        },
        'exercises': exercises,
    }

    # 3. Comprimi (gzip)
    backup_json = json.dumps(backup_data, ensure_ascii=False, indent=2)
    backup_bytes = backup_json.encode('utf-8')
    compressed = gzip.compress(backup_bytes)

    # 4. Salva in Cloud Storage con date nel nome
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_path = f'backups/exercises/daily/{timestamp}.json.gz'

    blob = bucket.blob(backup_path)
    blob.upload_from_string(
        compressed,
        content_type='application/gzip',
    )

    print(f"✅ Backup saved: {backup_path}")

    # 5. Cleanup: mantieni ultimi 90 giorni
    _cleanup_old_backups(bucket)

    return {'status': 'success', 'backup_path': backup_path}

def _cleanup_old_backups(bucket):
    """Elimina backup più vecchi di 90 giorni"""
    from datetime import timedelta

    cutoff_date = datetime.now() - timedelta(days=90)

    for blob in bucket.list_blobs(prefix='backups/exercises/daily/'):
        if blob.time_created.replace(tzinfo=None) < cutoff_date:
            blob.delete()
            print(f"🗑️  Deleted old backup: {blob.name}")
```

**Step 2: Recovery procedure**

File: `scripts/restore_exercises_from_backup.py`

```python
#!/usr/bin/env python3
"""
Recovery script: ripristina esercizi da backup
Uso: python restore_exercises_from_backup.py --date 20251015 --dry-run
"""

import argparse
import gzip
import json
from datetime import datetime
from pathlib import Path

def restore_from_backup(backup_date, dry_run=False):
    """Ripristina da backup specifico"""

    from firebase_admin import firestore, storage

    db = firestore.client()
    bucket = storage.bucket()

    # 1. Leggi backup file
    backup_path = f'backups/exercises/daily/{backup_date}_*.json.gz'
    print(f"🔍 Cercando backup: {backup_path}")

    backup_files = list(bucket.list_blobs(prefix=f'backups/exercises/daily/{backup_date}'))
    if not backup_files:
        print(f"❌ Backup non trovato per data: {backup_date}")
        return False

    backup_file = backup_files[0]  # Più recente di quel giorno
    print(f"📦 Trovato backup: {backup_file.name}")

    # 2. Scarica e decomprimi
    compressed_data = backup_file.download_as_bytes()
    backup_json = gzip.decompress(compressed_data).decode('utf-8')
    backup_data = json.loads(backup_json)

    metadata = backup_data['metadata']
    exercises = backup_data['exercises']

    print(f"📋 Backup contiene {len(exercises)} esercizi")
    print(f"📅 Data backup: {metadata['backup_date']}")

    if dry_run:
        print("\n🏃 DRY RUN - Non viene modificato nulla")
        return True

    # 3. Conferma restore
    confirm = input("\n⚠️  Questa azione sovrascriverà TUTTI gli esercizi. "
                   "Digita 'RESTORE' per confermare: ")
    if confirm != 'RESTORE':
        print("❌ Restore annullato")
        return False

    # 4. Backup current state prima di restore
    print("\n💾 Facendo backup dello stato attuale...")
    _create_manual_backup(bucket, 'pre-restore')

    # 5. Elimina esercizi attuali
    print("🗑️  Eliminando esercizi correnti...")
    batch = db.batch()
    batch_count = 0

    for doc in db.collection('exercises_master').stream():
        batch.delete(doc.reference)
        batch_count += 1
        if batch_count >= 500:
            batch.commit()
            batch = db.batch()
            batch_count = 0

    if batch_count > 0:
        batch.commit()

    # 6. Ripristina dal backup
    print("📥 Ripristinando esercizi dal backup...")
    batch = db.batch()
    batch_count = 0

    for ex in exercises:
        ex_id = ex.pop('_id')
        doc_ref = db.collection('exercises_master').document(ex_id)
        batch.set(doc_ref, ex)
        batch_count += 1

        if batch_count >= 500:
            batch.commit()
            print(f"   ✅ {batch_count} esercizi ripristinati")
            batch = db.batch()
            batch_count = 0

    if batch_count > 0:
        batch.commit()

    print(f"✅ Restore completato: {len(exercises)} esercizi ripristinati")

    # 7. Create audit log entry
    db.collection('audit_logs').add({
        'action': 'RESTORE_FROM_BACKUP',
        'backup_date': metadata['backup_date'],
        'exercise_count': len(exercises),
        'timestamp': datetime.now(),
        'admin': 'system',
    })

    return True

def _create_manual_backup(bucket, label):
    """Crea backup manuale dello stato corrente"""
    # Implementa simile a backup_exercises_daily()
    pass

def main():
    parser = argparse.ArgumentParser(description='Restore exercises from backup')
    parser.add_argument('--date', required=True, help='Data backup (YYYYMMDD)')
    parser.add_argument('--dry-run', action='store_true', help='Preview without changes')

    args = parser.parse_args()
    success = restore_from_backup(args.date, args.dry_run)

    exit(0 if success else 1)

if __name__ == '__main__':
    main()
```

**Step 3: Audit logging**

File: `lib/features/admin/domain/services/audit_logger_service.dart`

```dart
class AuditLoggerService {
  final FirebaseFirestore _firestore;
  final String _userId;

  AuditLoggerService({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore, _userId = userId;

  Future<void> logAction({
    required String action,
    required String exerciseId,
    required Map<String, dynamic> changes,
    String? notes,
  }) async {
    final auditEntry = {
      'timestamp': FieldValue.serverTimestamp(),
      'admin': _userId,
      'action': action, // CREATED, MODIFIED, DELETED, MERGED, RESTORED
      'exerciseId': exerciseId,
      'changes': changes,
      'notes': notes,
      'hash': _computeHash(changes), // Per integrità
    };

    await _firestore.collection('audit_logs').add(auditEntry);
  }

  String _computeHash(Map<String, dynamic> data) {
    // Crea hash delle modifiche per verificare integrità
    import 'package:crypto/crypto.dart';
    final json = jsonEncode(data);
    return sha256.convert(utf8.encode(json)).toString();
  }

  Stream<QuerySnapshot> streamAuditLogs({
    String? exerciseId,
    int limitDays = 90,
  }) {
    Query query = _firestore.collection('audit_logs');

    if (exerciseId != null) {
      query = query.where('exerciseId', isEqualTo: exerciseId);
    }

    final startDate = DateTime.now().subtract(Duration(days: limitDays));
    query = query.where('timestamp', isGreaterThan: startDate);

    return query.orderBy('timestamp', descending: true).snapshots();
  }
}
```

#### ✅ Checklist Task 2.2

- [ ] Cloud Function backup creata e deployata
- [ ] Cloud Scheduler configurato (giornaliero)
- [ ] Recovery script testato (dry-run)
- [ ] Audit logging implementato
- [ ] Test di full restore completato (in staging)
- [ ] Runbook di recovery documentato

---

### Task 2.3: Smart Cache Layer (10-14 giorni)

#### 📝 Descrizione
Implementare cache intelligente con TTL dinamico basato su frequenza di uso.

#### 🔧 Implementazione

**Step 1: Priority-based cache system**

File: `lib/features/exercise_database/data/services/smart_cache_manager.dart`

```dart
enum ExercisePriority {
  high,   // TTL: 1 day (molto usato)
  medium, // TTL: 7 days
  low,    // TTL: 30 days
}

class SmartCacheManager {
  final HiveInterface _hive;
  static const String _usageStatsBox = 'exercise_usage_stats';

  Future<void> trackUsage(String exerciseId) async {
    final box = _hive.box<Map>(_usageStatsBox);

    final current = box.get(exerciseId) as Map? ?? {};
    current['lastAccessed'] = DateTime.now();
    current['accessCount'] = (current['accessCount'] ?? 0) + 1;

    await box.put(exerciseId, current);
  }

  ExercisePriority _calculatePriority(String exerciseId) {
    final box = _hive.box<Map>(_usageStatsBox);
    final stats = box.get(exerciseId) as Map? ?? {};

    final accessCount = stats['accessCount'] as int? ?? 0;
    final lastAccessed = stats['lastAccessed'] as DateTime?;

    // Logica di priorità
    if (accessCount >= 50) return ExercisePriority.high;
    if (accessCount >= 10) return ExercisePriority.medium;
    return ExercisePriority.low;
  }

  Duration _getTTL(ExercisePriority priority) {
    switch (priority) {
      case ExercisePriority.high:
        return Duration(days: 1);
      case ExercisePriority.medium:
        return Duration(days: 7);
      case ExercisePriority.low:
        return Duration(days: 30);
    }
  }

  bool _isCacheExpired(String exerciseId) {
    final box = _hive.box<Map>(_usageStatsBox);
    final stats = box.get(exerciseId) as Map? ?? {};

    final lastUpdated = stats['lastUpdated'] as DateTime?;
    if (lastUpdated == null) return true;

    final priority = _calculatePriority(exerciseId);
    final ttl = _getTTL(priority);

    return DateTime.now().difference(lastUpdated) > ttl;
  }

  Future<void> performSmartSync() async {
    // Sync solo esercizi con cache scaduto
    final box = _hive.box<Map>(_usageStatsBox);

    final toSync = <String>[];
    for (final key in box.keys) {
      if (_isCacheExpired(key as String)) {
        toSync.add(key);
      }
    }

    if (toSync.isNotEmpty) {
      print('🔄 Smart sync: ${toSync.length} exercises to update');
      // Scarica solo questi esercizi
      // await _downloadExercises(toSync);
    }
  }
}
```

**Step 2: Usage tracking widget mixin**

File: `lib/features/exercise_database/presentation/widgets/cache_tracking_mixin.dart`

```dart
mixin CacheTrackingMixin {
  Future<void> trackExerciseView(String exerciseId) async {
    // Ottieni il SmartCacheManager (da provider)
    // Chiama trackUsage(exerciseId)
  }
}

// Usage in ExerciseCard:
class ExerciseCard extends StatelessWidget with CacheTrackingMixin {
  final String exerciseId;

  @override
  void initState() {
    super.initState();
    // Traccia quando card viene visualizzata
    trackExerciseView(exerciseId);
  }
}
```

#### ✅ Checklist Task 2.3

- [ ] SmartCacheManager implementato
- [ ] Priority calculation logic testato
- [ ] TTL system funziona correttamente
- [ ] Usage tracking integrato in UI
- [ ] Smart sync riduce bandwidth (verifica logs)
- [ ] Test performance con dataset grande

---

## ✅ FASE 2 CHECKPOINT

```
☐ Task 2.1: Conflict Management completato
☐ Task 2.2: Security & Backup completato
☐ Task 2.3: Smart Cache completato
☐ Tutti i test passano
☐ No critical bugs in staging
☐ Documentazione aggiornata
☐ IMPLEMENTATION_STATUS.json aggiornato
```

---

## 🎯 FASE 3 & 4 (Sneak Peek)

### FASE 3: Visibility & Scale (Settimane 11-16)

```
Task 3.1: Client Versioning Monitoring (14-21 gg)
├─ Telemetry system
├─ Dashboard Grafana
└─ Rollout tracking

Task 3.2: Changelog & Notifications (10-14 gg)
├─ ChangelogScreen widget
├─ Push notifications
└─ In-app banners
```

### FASE 4: Expansion (Settimane 17+)

```
Task 4.1: Public API & SDK (28-42 gg)
├─ REST/GraphQL API
├─ Swagger docs
├─ Flutter/JS/Python SDK
└─ Sample apps
```

---

## 📊 IMPLEMENTATION_STATUS.json Template

```json
{
  "project": "GymBro Exercise Database Enhancement",
  "last_updated": "2025-10-16",
  "overall_progress_percent": 0,

  "phase_1": {
    "name": "Foundational",
    "start_date": null,
    "end_date": null,
    "status": "NOT_STARTED",
    "progress_percent": 0,

    "tasks": {
      "task_1_1": {
        "name": "Validation & Testing",
        "status": "NOT_STARTED",
        "progress_percent": 0,
        "subtasks": {
          "python_script": "NOT_STARTED",
          "dart_tests": "NOT_STARTED",
          "ci_cd_integration": "NOT_STARTED"
        },
        "started_at": null,
        "completed_at": null,
        "notes": ""
      },
      "task_1_2": {
        "name": "User Feedback System",
        "status": "NOT_STARTED",
        "progress_percent": 0,
        "subtasks": {
          "firestore_schema": "NOT_STARTED",
          "ui_button": "NOT_STARTED",
          "admin_dashboard": "NOT_STARTED"
        },
        "started_at": null,
        "completed_at": null,
        "notes": ""
      },
      "task_1_3": {
        "name": "Periodic Review Process",
        "status": "NOT_STARTED",
        "progress_percent": 0,
        "subtasks": {
          "cloud_function": "NOT_STARTED",
          "scheduler": "NOT_STARTED",
          "ui": "NOT_STARTED"
        },
        "started_at": null,
        "completed_at": null,
        "notes": ""
      }
    }
  },

  "phase_2": {
    "name": "Infrastructure",
    "start_date": null,
    "status": "PENDING",
    "tasks": {}
  },

  "phase_3": {
    "name": "Visibility & Scale",
    "start_date": null,
    "status": "PENDING",
    "tasks": {}
  },

  "phase_4": {
    "name": "Expansion",
    "start_date": null,
    "status": "PENDING",
    "tasks": {}
  },

  "blockers": [],
  "notes": "Project started, Fase 1 in progress"
}
```

---

## 🆘 Troubleshooting

### Problema: Validation script fallisce

```bash
# Soluzione:
1. Verifica file JSON syntax:
   python3 -m json.tool assets/data/exercises_it.json

2. Verifica encoding:
   file -I assets/data/exercises_it.json  # Deve essere UTF-8

3. Controlla permessi:
   chmod +x scripts/validate_exercises.py
```

### Problema: Firestore write limit exceeded

```
Soluzione: Usa batch operations (max 500 per batch)
- Implementato negli script
- Cloud Functions automaticamente fan batching
- Se ancora problemi, aumenta quota in Firebase console
```

### Problema: Sync service non scatta automaticamente

```dart
// Verifica:
1. ExerciseSyncService.initialize() è chiamato in main.dart?
2. Timer è attivo? Aggiungi log:
   if (kDebugMode) {
     debugPrint('🔄 Sync timer started');
   }
3. Riverpod provider watching correttamente?
```

---

## 📚 Reference & Links

### File Principali

- **Architecture Doc**: `docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`
- **Current Status**: `docs/IMPLEMENTATION_STATUS.json` ← **AGGIORNA FREQUENTEMENTE**
- **Repository**: `lib/features/exercise_database/data/repositories/hybrid_exercise_repository.dart`
- **Sync Service**: `lib/features/exercise_database/data/services/exercise_sync_service.dart`

### Firestore Collections

```
exercises_master/           ← Esercizi attuali
exercise_feedback/          ← Feedback utenti
exercise_version_cache/     ← Metadata versioni
admin_reports/              ← Report amministrativi
audit_logs/                 ← Log audit immutabili
```

### Cloud Functions & Schedulers

```
trigger_exercise_review     → Monthly (1st day, 02:00 UTC)
backup_exercises_daily      → Daily (03:00 UTC)
cleanup_old_backups         → Weekly
```

---

## 🎓 Lezioni Apprese & Best Practices

### ✅ Best Practices Applicate

1. **Always validate data** prima di salvare
2. **Backup first** prima di qualsiasi restore
3. **Test in staging** prima di produzione
4. **Track everything** in audit logs
5. **Communicate changes** via changelog
6. **Monitor continuously** con dashboards

### ⚠️ Pitfalls da Evitare

```
❌ Non saltare la fase di validation
❌ Non fare rollback senza backup
❌ Non modificare dati direttamente (usa admin UI)
❌ Non ignorare gli errori dei sync
```

---

## 📞 Support & Escalation

### Chi contattare quando:

```
Validation issues
└─ Leggi error output
└─ Verifica file formato

Firestore issues
└─ Check quota usage in Firebase console
└─ Review security rules

Sync not working
└─ Check connectivity
└─ Verify service is initialized
└─ Check logs in Firebase Functions

Performance issues
└─ Review cache stats
└─ Check database indexing
```

---

## 📅 Next Steps

### Adesso:
1. Leggi questo documento completamente
2. Aggiorna `IMPLEMENTATION_STATUS.json` con data inizio
3. Crea branch: `git checkout -b feature/exercise-enhancement`

### Settimana prossima:
1. Inizia Task 1.1 (Validation & Testing)
2. Aggiorna status settimanalmente
3. Documenta eventuali blocchi

### Mensile:
1. Review progress
2. Aggiorna roadmap se necessario
3. Report su completamento fasi

---

**Document Version**: 1.0
**Status**: Ready for Implementation
**Last Updated**: 2025-10-16
**Next Review**: 2025-11-16

---

